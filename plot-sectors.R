library(tidyverse)

sm = read_tsv('raw/sm/sm.data.5c.California.tsv')

sm

sm.codes = read_csv('sm-codes.csv')

sm.codes

ca.local.data = sm.codes %>% 
  filter(state_code == '06') %>% 
  filter(area_name != 'Statewide') %>% 
  filter(!str_detect(area_name, 'Metropolitan Division')) %>% 
  filter(data_type_code == '01') %>% 
  filter(industry_name == supersector_name) %>% 
  left_join(sm)

ca.local.data

ca.local.data %>% count(period)

plots = ca.local.data %>% 
  filter(period != 'M13') %>% 
  filter(seasonal_code == 'U') %>% 
  mutate(date = lubridate::make_date(year = year, month = str_remove(period, 'M'), 1)) %>% 
  arrange(date) %>% 
  filter(date >= '2019-01-01') %>% 
  group_by(area_name) %>% 
  nest() %>% 
  mutate(
    plot = map2(
      data,
      area_name,
      ~.x %>% 
        ggplot(aes(date, value)) +
        geom_line() +
        facet_wrap(. ~ industry_name, scales = 'free') +
        labs(
          x = '',
          y = '',
          title = .y,
          subtitle = 'Employment in thousands'
        ) +
        geom_vline(xintercept = lubridate::ymd('2020-03-01'), color = 'red') +
        theme_minimal()
    )
  ) %>% 
  mutate(fname = area_name %>% str_remove(', CA') %>% str_to_lower() %>% str_replace(' ', '-'))

plots

plots %>% 
  ungroup() %>% 
  select(fname, plot) %>% 
  pwalk(
    ~ggsave(filename = glue::glue('plots/sectors/{..1}.png'), plot = ..2, width = 12, height = 8)
  )

plots$data[[1]] %>% 
  filter(industry_name == 'Total Nonfarm') %>% 
  view()
