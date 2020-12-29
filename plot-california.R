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

ca.counties = ca.counties %>% 
  bind_rows(ca.total)

ca.counties %>% tail()

gfx.data = ca.counties %>% 
  filter(report.month >= '2020-01-01') %>% 
  select(month = report.month, county, rate = unemployment.rate) %>% 
  mutate(
    county = str_remove_all(county, ' County'),
    county = str_to_lower(county),
    county = str_replace_all(county, ' ', '_')
  ) %>% 
  pivot_wider(month, names_from = 'county', values_from = 'rate')

gfx.data

gfx.data %>% write_csv('ca_counties_unemployment_rates.csv', na = '')

ca.counties %>% 
  filter(report.month >= '2020-01-01') %>% 
  ggplot(aes(report.month, unemployment.rate)) +
  geom_line(data = . %>% rename(county2 = county), aes(group = county2), color = 'grey') +
  geom_line(data = . %>% rename(county3 = county) %>% filter(county3 == 'State'), color = 'red') +
  geom_line() +
  facet_wrap(. ~ county) +
  theme_minimal()
