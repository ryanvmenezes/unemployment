library(tidyverse)
library(lubridate)

counties = read_csv('data/processed/unemployment/bls-unemployment-14-months-counties.csv')

counties

max.month = counties %>% 
  filter(year(report.month) == 2020) %>% 
  summarise(month(max(report.month))) %>% 
  pull()

# take 2020 max month and same month in 2019
max.month.counties = counties %>% 
  mutate(report.year = year(report.month)) %>% 
  filter(month(report.month) == max.month)

max.month.counties

compare.counties = max.month.counties %>%
  filter(report.year == 2019) %>% 
  left_join(
    max.month.counties %>% 
      filter(report.year == 2020),
    by = c("laus.code", "state.fips", "county.fips", "county", "state.abbr"),
    suffix = c('.19', '.20')
  ) %>% 
  mutate(unemp.rate.diff = round(rate.unemployed.20 - rate.unemployed.19, 1)) %>% 
  select(
    state.fips, county.fips, county, state.abbr,
    report.month.19, civilian.labor.force.19, unemployed.19, rate.unemployed.19,
    report.month.20, civilian.labor.force.20, unemployed.20, rate.unemployed.20,
    unemp.rate.diff
  ) %>% 
  arrange(-unemp.rate.diff)

compare.counties %>% arrange(-unemp.rate.diff)

compare.counties

states = counties %>% 
  group_by(state.fips, state.abbr, report.month) %>% 
  summarise(
    civilian.labor.force = sum(civilian.labor.force),
    employed = sum(employed),
    unemployed = sum(unemployed)
  ) %>% 
  mutate(rate.unemployed = round(unemployed / civilian.labor.force * 100, 1))

states

max.month.states = states %>% 
  mutate(report.year = year(report.month)) %>% 
  filter(month(report.month) == max.month)

max.month.states

compare.states = max.month.states %>%
  filter(report.year == 2019) %>% 
  left_join(
    max.month.states %>% 
      filter(report.year == 2020),
    by = c("state.fips", "state.abbr"),
    suffix = c('.19', '.20')
  ) %>% 
  mutate(unemp.rate.diff = round(rate.unemployed.20 - rate.unemployed.19, 1)) %>% 
  select(
    state.fips, state.abbr,
    report.month.19, civilian.labor.force.19, unemployed.19, rate.unemployed.19,
    report.month.20, civilian.labor.force.20, unemployed.20, rate.unemployed.20,
    unemp.rate.diff
  ) %>% 
  arrange(-unemp.rate.diff)

compare.states

compare.counties %>% write_csv('unemployment/tables/county-unemployment-march-comparison.csv', na = '')
compare.states %>% write_csv('unemployment/tables/state-unemployment-march-comparison.csv', na = '')
