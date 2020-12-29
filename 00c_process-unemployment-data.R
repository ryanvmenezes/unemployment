library(tidyverse)
library(lubridate)

fips = read_csv('raw/fips.csv')

fips

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

bls.states = read_tsv('raw/la/la.data.3.AllStatesS.tsv') %>% 
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
  # left_join(
  #   fips %>% 
  #     distinct(state.fips, state, state.abbr)
  # ) %>% 
  select(state.fips, report.month, data.value, value) %>% 
  pivot_wider(names_from = 'data.value', values_from = 'value')

bls.states

bls.states %>% write_csv('processed/bls-unemployment-states.csv', na = '')

# bls county data ---------------------------------------------------------

bls.counties.raw = read_tsv('raw/la/la.data.64.County.tsv')

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
  # left_join(fips) %>% 
  select(state.fips, county.fips, report.month, data.value, value) %>% 
  pivot_wider(names_from = 'data.value', values_from = 'value')

bls.counties

bls.counties %>% write_csv('processed/bls-unemployment-counties.csv', na = '')


# # edd california data -----------------------------------------------------
# 
# california = read_csv('raw/edd-california.csv')
# 
# california %>% count(`Area Type`)
# 
# california %>% 
#   filter(`Area Type` == 'Sub-County Place') %>% 
#   count(`Area Name`)
# 
# seasonally.adjusted.data.points = california %>%
#   distinct(`Area Name`, `Seasonally Adjusted (Y/N)`) %>%
#   filter(`Seasonally Adjusted (Y/N)` == 'Y')
# 
# seasonally.adjusted.data.points
# 
# ca.counties = california %>% 
#   filter(`Area Type` == 'County') %>% 
#   filter(`Seasonally Adjusted (Y/N)` != 'Y') %>% 
#   select(-`Area Type`) %>% 
#   transmute(
#     county = `Area Name`,
#     date = mdy(Date),
#     labor.force = `Labor Force`,
#     employed = `Employment`,
#     unemployment = `Unemployment`,
#     unemployment.rate = round(unemployment / labor.force * 100, 1)
#   ) %>% 
#   distinct()
# 
# ca.counties
# 
# ca.counties %>% tail()
# 
# ca.counties %>% write_csv('processed/edd-california-counties.csv')

# ca.cities.cdps = california %>% 
#   filter(`Area Type` == 'Sub-County Place') %>% 
#   filter(`Seasonally Adjusted (Y/N)` != 'Y') %>% 
#   select(-`Area Type`) %>% 
#   transmute(
#     county = `Area Name`,
#     date = mdy(Date),
#     labor.force = `Labor Force`,
#     employed = `Employment`,
#     unemployment = `Unemployment`,
#     unemployment.rate = round(unemployment / labor.force * 100, 1)
#   ) %>% 
#   arrange(date)
# 
# ca.cities.cdps
# 
# tail(ca.cities.cdps)



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
  left_join(fips %>% distinct(state.abbr, state.fips)) %>%
  left_join(bls.states %>% select(state.fips, report.month, labor.force)) %>% 
  select(state.fips, state.abbr, everything()) %>% 
  group_by(state.fips, state.abbr) %>% 
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
