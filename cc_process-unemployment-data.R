library(tidyverse)
library(lubridate)

fips = read_csv('raw/fips.csv')

fips

# bls unemployment rate by county -----------------------------------------

bls.counties = read_lines('raw/laucntycur14.txt') %>% 
  head(-6) %>% 
  tail(-6) %>% 
  paste(collapse = "\n") %>% 
  read_delim(delim = '|', trim_ws = TRUE, col_names = FALSE) %>% 
  rename(
    laus.code = X1,
    state.fips = X2,
    county.fips = X3,
    area.name = X4,
    report.month = X5,
    civilian.labor.force = X6,
    employed = X7,
    unemployed = X8,
    rate.unemployed = X9,
  ) %>% 
  separate(report.month, into = c('report.month', 'preliminary'), sep = '\\(', extra = 'drop', fill = 'right') %>% 
  mutate(preliminary = !is.na(preliminary)) %>% 
  mutate(area.name = if_else(area.name == 'District of Columbia', 'District of Columbia, DC', area.name)) %>% 
  separate(area.name, into = c('county', 'state.abbr'), sep = ', ') %>% 
  mutate(
    report.month = str_replace(report.month, '-', '-01-'),
    report.month = mdy(report.month)
  ) %>% 
  arrange(laus.code, state.fips, county.fips, report.month)

bls.counties

bls.counties %>% write_csv('processed/bls-unemployment-14-months-counties.csv', na = '')

# bls state statistics ----------------------------------------------------

bls.state.table.ids = tribble(
  ~table.id, ~data.value,
  '03', 'unemployment.rate',
  '04', 'unemployment',
  '05', 'employment',
  '06', 'labor.force',
  '07', 'employment.population.ratio',
  '08', 'labor.force.participation.rate',
  '09', 'civilian.noninstitutional.population',
)

bls.state.table.ids

bls.states = read_tsv('raw/la.data.2.AllStatesU.tsv') %>% 
  filter(period != 'M13') %>% 
  mutate(
    state.fips = str_sub(series_id, start = 6, end = 7),
    table.id = str_sub(series_id, start = -2)
  ) %>% 
  unite(col = 'report.month', year, period, sep = '-') %>% 
  mutate(
    report.month = str_replace(report.month, '-M', '-'),
    report.month = str_c(report.month, '-01'),
    report.month = ymd(report.month)
  ) %>% 
  left_join(bls.state.table.ids) %>% 
  left_join(
    fips %>% 
      distinct(state.fips, state, state.abbr)
  ) %>% 
  select(state.fips, state, state.abbr, report.month, data.value, value) %>% 
  pivot_wider(names_from = 'data.value', values_from = 'value')

bls.states

bls.states %>% write_csv('processed/bls-unemployment-states.csv', na = '')

# bls county data ---------------------------------------------------------

bls.counties.raw = read_tsv('raw/la.data.64.County.tsv')

bls.counties = bls.counties.raw %>% 
  filter(period != 'M13') %>% 
  mutate(
    state.fips = str_sub(series_id, start = 6, end = 7),
    county.fips = str_sub(series_id, start = 8, end = 10),
    table.id = str_sub(series_id, start = -2)
  ) %>%
  unite(col = 'report.month', year, period, sep = '-') %>% 
  mutate(
    report.month = str_replace(report.month, '-M', '-'),
    report.month = str_c(report.month, '-01'),
    report.month = ymd(report.month)
  ) %>% 
  left_join(bls.state.table.ids) %>% 
  left_join(fips) %>% 
  select(state.fips, county.fips, county, state, state.abbr, report.month, data.value, value) %>% 
  pivot_wider(names_from = 'data.value', values_from = 'value')

bls.counties

bls.counties %>% write_csv('processed/bls-unemployment-counties.csv', na = '')

# dept of labor unemployment claims ---------------------------------------

## weekly claims by state

CLAIMS = read_csv('raw/ar539.csv')

CLAIMS

claims = CLAIMS %>% 
  transmute(
    state.abbr = st,
    report.date = mdy(rptdate),
    reflected.week.ending = mdy(c2),
    report.month = floor_date(reflected.week.ending, unit = 'months'),
    week.number = c1,
    initial.claims = c3,
    continued.claims = c8,
    covered.employment = c18,
    # insured.unemployment.rate = c19
  ) %>%
  left_join(fips %>% distinct(state, state.abbr)) %>% 
  left_join(bls.states %>% select(state.abbr, report.month, labor.force)) %>% 
  select(state, everything()) %>% 
  group_by(state.abbr) %>% 
  fill(labor.force, .direction = 'down') %>% 
  mutate(pct.unemployed = (initial.claims + continued.claims) / labor.force) %>% 
  ungroup()
  
claims

# national totals 

claims.national = claims %>% 
  group_by(report.date, reflected.week.ending, report.month, week.number) %>% 
  summarise(
    count.states= n(),
    initial.claims = sum(initial.claims),
    continued.claims = sum(continued.claims),
    covered.employment = sum(covered.employment)
  ) %>%
  ungroup() %>% 
  left_join(
    bls.states %>%
      group_by(report.month) %>%
      summarise(labor.force = sum(labor.force))
  ) %>% 
  fill(labor.force, .direction = 'down') %>% 
  mutate(pct.unemployed = (initial.claims + continued.claims) / labor.force) %>% 
  filter(report.month >= '1990-01-01')

claims.national

claims.national %>% tail(20)

claims %>% write_csv('processed/unemployment-claims-states-weekly.csv', na = '')
claims.national %>% write_csv('processed/unemployment-claims-usa-weekly.csv', na = '')
