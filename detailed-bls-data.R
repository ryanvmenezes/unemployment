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
    report.date = glue('{year}-{str_replace(period, "M", "")}-01'),
    report.date = ymd(report.date),
    table.name = str_replace(table.name, 'unemployment.rate.', '')
  ) %>% 
  select(report.date, table.name, value) %>% 
  arrange(report.date, table.name)

gender.unemployment

gender.unemployment %>% tail()

plot.gender.unemployment = gender.unemployment %>%
  filter(table.name != 'all') %>% 
  ggplot(aes(report.date, value)) +
  geom_line() +
  geom_hline(yintercept = 14.7, linetype = 'dashed', color = 'red') +
  facet_wrap(. ~ table.name) +
  ylab('Unemployment rate, seasonally adjusted') +
  xlab('Month') +
  theme_minimal()

plot.gender.unemployment

ggsave('plots/men-women-unemployment-rate.png', width = 11, height = 8)

occupation.type.codes = read_csv('occupation-type-tables.csv')

occupation.employed.counts = ln.data %>% 
  right_join(occupation.type.codes) %>% 
  filter(period != 'M13') %>% 
  mutate(
    report.date = glue('{year}-{str_replace(period, "M", "")}-01'),
    report.date = ymd(report.date),
    occupation_text = str_replace(occupation_text, ' occupations', '')
  )

occupation.employed.counts

add.newlines = function(string, words = 4) {
  split.string = str_split(string, ' ')[[1]] %>% 
    str_c(., ' ')
  n.words = length(split.string)
  if(n.words <= words) return(string)
  result = ''
  starts = seq(from = 1, to = n.words, by = words)
  ends = c(seq(from = words, to = n.words, by = words), n.words)
  for(i in 1:length(starts)) {
    result = str_c(result, str_c(split.string[starts[i]:ends[i]], collapse = ''))
    if(i != length(starts)) result = str_c(result, '\n')
  }
  return(result)
}

occupation.employed.counts %>%
  count(occupation_text) %>% 
  mutate(
    occupation.text.split = map_chr(occupation_text, add.newlines)
  )


plot.employed.by.occupation = occupation.employed.counts %>% 
  mutate(occupation_text = map_chr(occupation_text, add.newlines)) %>% 
  ggplot(aes(report.date, value)) +
  geom_line() +
  geom_point(
    data = . %>% 
      group_by(occupation_text) %>% 
      filter(report.date == max(report.date)),
    color = 'red'
  ) +
  geom_point(
    data = . %>% 
      group_by(occupation_text) %>% 
      filter(report.date != max(report.date)) %>% 
      filter(report.date != max(report.date)) %>% 
      filter(report.date == max(report.date)),
    color = 'green'
  ) +
  annotate(
    'rect',
    xmin = ymd('2008-10-01'),
    xmax = ymd('2011-01-01'),
    ymin = 0,
    ymax = Inf,
    alpha = 0.3
  ) +
  facet_wrap(. ~ occupation_text, scales = 'free_y') +
  ylab('Unadjusted count of employed (in thousands)') +
  theme_minimal()

plot.employed.by.occupation

ggsave('plots/employed-count-by-job-sector.png', width = 20, height = 8)
