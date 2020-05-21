library(glue)
library(lubridate)
library(tidyverse)

ln.data = read_tsv('raw/ln.data.1.AllData.tsv')

ln.data

gender.unemployment.codes = tribble(
  ~series_id, ~table.name,
  'LNS14000000', 'unemployment.rate.all',
  'LNS14000001', 'unemployment.rate.men',
  'LNS14000002', 'unemployment.rate.women'
)

gender.unemployment = ln.data %>% 
  right_join(gender.unemployment.codes) %>% 
  filter(period != 'M13') %>% 
  mutate(
    report.date = glue('{year}-{str_replace(period, "M", "")}-01')
  ) %>% 
  select(report.date, table.name, value) %>% 
  pivot_wider(names_from = 'table.name', values_from = 'value') %>% 
  arrange(report.date)

gender.unemployment

gender.unemployment %>% tail()

gender.unemployment %>% 
  pivot_longer(-report.date, names_to = 'value', values_to = 'percent') %>% 
  mutate(
    value = str_replace(value, 'unemployment.rate.', ''),
    report.date = ymd(report.date)
  ) %>% 
  filter(value != 'all') %>% 
  ggplot(aes(report.date, percent)) +
  geom_line() +
  facet_wrap(. ~ value) +
  theme_minimal()
