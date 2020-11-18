library(tidyverse)

fips = read_csv('raw/fips.csv')

fips

counties = read_csv('processed/bls-unemployment-counties.csv')

counties

ca.counties = fips %>% 
  right_join(counties) %>% 
  filter(state.abbr == 'CA')

ca.counties

ca.total = california %>% 
  group_by(report.month) %>% 
  summarise(
    unemployment = sum(unemployment),
    employment = sum(employment),
    labor.force = sum(labor.force),
    unemployment.rate = round(unemployment / labor.force * 100, 1)
  ) %>% 
  mutate(county = 'State')

ca.total
