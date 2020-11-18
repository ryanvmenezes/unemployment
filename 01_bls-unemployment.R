library(tidyverse)
library(lubridate)

counties = read_csv('processed/bls-unemployment-counties.csv')

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
    by = c("state.fips", "county.fips"),
    suffix = c('.19', '.20')
  ) %>% 
  mutate(unemp.rate.diff = round(unemployment.rate.20 - unemployment.rate.19, 1)) %>% 
  select(
    state.fips, county.fips,
    report.month.19, labor.force.19, unemployment.19, unemployment.rate.19,
    report.month.20, labor.force.20, unemployment.20, unemployment.rate.20,
    unemp.rate.diff
  ) %>% 
  arrange(-unemp.rate.diff)

compare.counties

states = counties %>% 
  group_by(state.fips, report.month) %>% 
  summarise(
    labor.force = sum(labor.force),
    unemployment = sum(unemployment)
  ) %>% 
  mutate(unemployment.rate = round(unemployment / labor.force * 100, 1))

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
    by = "state.fips",
    suffix = c('.19', '.20')
  ) %>% 
  mutate(unemp.rate.diff = round(unemployment.rate.20 - unemployment.rate.19, 1)) %>% 
  select(
    state.fips,
    report.month.19, labor.force.19, unemployment.19, unemployment.rate.19,
    report.month.20, labor.force.20, unemployment.20, unemployment.rate.20,
    unemp.rate.diff
  ) %>% 
  arrange(-unemp.rate.diff)

compare.states

compare.counties %>% write_csv('tables/county-unemployment-comparison.csv', na = '')
compare.states %>% write_csv('tables/state-unemployment-comparison.csv', na = '')
