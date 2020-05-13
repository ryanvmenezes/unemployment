library(tidyverse)

states = read_csv('data/processed/unemployment/bls-unemployment-states.csv')

bls.states = states %>% 
  group_by(report.month) %>% 
  summarise(
    unemployment = sum(unemployment),
    labor.force = sum(labor.force),
  ) %>% 
  mutate(unemployment.rate = unemployment / labor.force)

bls.states

claims.usa

plot.unemployment.rate.comparison = ggplot() +
  geom_line(data = bls.states %>% filter(report.month >= '1990-01-01'), aes(report.month, unemployment.rate * 100)) +
  # geom_smooth(data = bls.states, aes(report.month, unemployment.rate)) +
  geom_line(data = claims.usa, aes(report.date, pct.unemployed * 100), color = 'maroon') +
  # geom_smooth(data = claims.usa, aes(report.date, pct.unemployed)) +
  ggtitle('Unemployment rate according to BLS survey (black)\nvs. unemployment insurance claims (red)') +
  xlab('') +
  ylab('Unemployment rate') +
  theme_minimal()

plot.unemployment.rate.comparison

ggsave(filename = 'unemployment/plots/unemployment-rate-comparison.png', plot = plot.unemployment.rate.comparison, width = 12, height = 8)
