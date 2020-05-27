library(lubridate)
library(tidyverse)

bls.states = read_csv('processed/bls-unemployment-states.csv')

bls.states

aprils.usa = bls.states %>% 
  # filter(state.fips == '06') %>% 
  filter(report.month == '2019-04-01' | report.month == '2020-04-01') %>% 
  mutate(
    report.year = year(report.month),
  ) %>% 
  select(state.abbr, report.year, unemployment.rate) %>% 
  pivot_wider(names_from = 'report.year', values_from = 'unemployment.rate') %>% 
  mutate(change = `2020` - `2019`) %>% 
  arrange(change)

aprils.usa

plot.change.states.unemp = aprils.usa %>% 
  filter(state.abbr != 'PR') %>% 
  mutate(state.abbr = fct_inorder(state.abbr)) %>% 
  ggplot(aes(state.abbr)) +
  geom_segment(aes(x = state.abbr, xend = state.abbr, y = `2019`, yend = `2020`)) +
  geom_segment(
    aes(x = state.abbr, xend = state.abbr, y = `2019`, yend = `2020`),
    data = . %>% filter(state.abbr == 'CA'),
    color = 'blue'
  ) +
  geom_point(aes(y = `2019`), color = 'pink') +
  geom_point(aes(y = `2020`), color = 'red') +
  coord_flip() +
  ggtitle("April unemployment rate: 2019 v. 2020") +
  ylab('Unemployment rate') +
  xlab('') +
  theme_minimal()

plot.change.states.unemp

ggsave(plot = plot.change.states.unemp, filename = 'plots/states-unemployment-change.png', width = 16/1.2, height = 9/1.2)

ca.counties = read_csv('processed/edd-california-counties.csv') %>% 
  mutate(county = word(county, end = -2))

ca.counties

aprils.ca = ca.counties %>% 
  filter(year(date) %in% c(2019, 2020) & month(date) == 4) %>% 
  transmute(
    year = year(date),
    county,    
    unemployment.rate
  ) %>%
  pivot_wider(names_from = 'year', values_from = 'unemployment.rate') %>% 
  mutate(
    change = `2020` - `2019`
  ) %>% 
  arrange(change) %>% 
  left_join(
    ca.counties %>% 
      filter(date == '2020-04-01') %>% 
      select(county, labor.force)
  )

aprils.ca

# aprils.ca %>% 
#   ggplot(aes(`2019`, `2020`)) +
#   # geom_text(aes(label = county)) +
#   geom_point(aes(size = labor.force)) +
#   geom_abline(intercept = 0, slope = 1)

plot.change.ca.counties.unemp = aprils.ca %>% 
  mutate(county = fct_inorder(county)) %>% 
  ggplot(aes(county)) +
  geom_segment(aes(x = county, xend = county, y = `2019`, yend = `2020`)) +
  geom_segment(
    aes(x = county, xend = county, y = `2019`, yend = `2020`),
    data = . %>% filter(county == 'Los Angeles'),
    color = 'blue'
  ) +
  geom_point(aes(y = `2019`), color = 'pink') +
  geom_point(aes(y = `2020`), color = 'red') +
  coord_flip() +
  ggtitle("April unemployment rate: 2019 v. 2020") +
  ylab('Unemployment rate') +
  xlab('') +
  theme_minimal()

plot.change.ca.counties.unemp

ggsave(plot = plot.change.ca.counties.unemp, filename = 'plots/ca-counties-unemployment-change.png', width = 16/1.2, height = 9/1.2)

plots.counties.grid = ca.counties %>%
  left_join(
    aprils.ca %>% 
      mutate(county.f = fct_rev(fct_inorder(county))) %>% 
      select(county, county.f)
  ) %>% 
  ggplot(aes(date, unemployment.rate)) +
  geom_line(data = . %>% rename(county2 = county.f), aes(group = county2), color = 'grey') +
  geom_line() +
  geom_point(
    data = . %>% 
      filter(date == '2020-04-01'),
    color = 'red'
  ) +
  geom_point(
    data = . %>% 
      filter(date == '2019-04-01'),
    color = 'pink'
  ) +
  facet_wrap(. ~ county.f) +
  theme_minimal()

plots.counties.grid

ggsave(plot = plots.counties.grid, filename = 'plots/ca-counties-unemployment-grid.png', width = 16/1.2, height = 9/1.2)

library(sf)
library(tidycensus)

ca.acs = get_acs(
  geography = 'county',
  year = 2018,
  geometry = TRUE,
  state = 'CA',
  variables = 'B01001_001'
)

map.chor = ca.acs %>% 
  st_transform(3311) %>% 
  mutate(
    county = str_replace(NAME, ' County, California', ''),
    centroid = st_centroid(geometry),
  ) %>%
  left_join(aprils.ca) %>% 
  ggplot() +
  geom_sf(aes(fill = change)) +
  scale_fill_gradient(low = "#56B1F7", high = "#132B43") +
  labs(
    x = '',
    title = 'Unemployment change by county',
    caption = "Comparing April 2019 to April 2020"
  ) +
  theme_minimal()

map.chor

map.chor.points = ca.acs %>% 
  st_transform(3311) %>% 
  mutate(
    county = str_replace(NAME, ' County, California', ''),
    centroid = st_centroid(geometry),
  ) %>%
  left_join(aprils.ca) %>% 
  mutate(labor.force = labor.force / 1000000) %>% 
  ggplot() +
  geom_sf(fill = 'white') +
  stat_sf_coordinates(aes(size = labor.force, color = change)) +
  scale_color_gradient(low = "#56B1F7", high = "#132B43") +
  labs(
    x = '',
    title = 'Unemployment change by county',
    subtitle = 'Circles sized by labor force',
    caption = "Comparing April 2019 to April 2020"
  ) +
  theme_minimal()

map.chor.points

ggsave(plot = map.chor, filename = 'plots/ca-unemployment-change-choropleth.png', height = 9/1.2, width = 16/1.2)
ggsave(plot = map.chor.points, filename = 'plots/ca-unemployment-change-choropleth-dots.png', height = 9/1.2, width = 16/1.2)
