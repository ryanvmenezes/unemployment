library(tidyverse)
library(lubridate)

claims.states = read_csv('processed/unemployment-claims-states-weekly.csv')

claims.states

claims.states %>% 
  group_by(state.abbr) %>% 
  filter(report.date == max(report.date))

claims.usa = read_csv('processed/unemployment-claims-usa-weekly.csv')

claims.usa

claims.usa %>% tail(20)

plot.initial = claims.usa %>% 
  ggplot(aes(report.date, initial.claims / 1e6)) +
  geom_line() +
  ggtitle('Weekly initial claims') +
  ylab('In millions') +
  xlab('Date') +
  theme_minimal()

plot.initial

plot.weekly = claims.usa %>% 
  ggplot(aes(report.date, continued.claims / 1e6)) +
  geom_line() +
  ggtitle('Weekly total number of people on unemployment') +
  ylab('In millions') +
  xlab('Date') +
  theme_minimal()

plot.weekly

plot.pct.unemployed = claims.usa %>% 
  ggplot(aes(report.date, pct.unemployed * 100)) +
  geom_line() +
  ggtitle('Percentage of labor force on unemployment') +
  ylab('') +
  xlab('Date') +
  theme_minimal()

plot.pct.unemployed

# claims.usa %>%
#   filter(report.date >= '2020-01-01') %>%
#   ggplot(aes(report.date, continued.claims)) +
#   geom_line() +
#   geom_vline(xintercept = ymd('2020-03-24')) +
#   geom_point() +
#   geom_text(aes(label = week.number), color = 'red')

# last week before spike was week 11

post.spike.data = claims.states %>% 
  filter(year(reflected.week.ending) == 2020) %>% 
  filter(week.number > 11)

post.spike.data.summary = post.spike.data %>% 
  group_by(state.fips, state.abbr) %>% 
  summarise(
    new.claims.since.spike = sum(initial.claims),
    latest.total.on.unemployment = last(continued.claims),
    latest.pct.unemployed = last(pct.unemployed),
    labor.force = last(labor.force)
  )

post.spike.data.summary

pre.spike.data.summary = claims.states %>% 
  filter(year(reflected.week.ending) == 2020) %>% 
  filter(week.number == 11) %>% 
  select(state.fips, state.abbr, pre.spike.total.on.unemployment = continued.claims, pre.spike.pct.unemployed = pct.unemployed)
  
pre.spike.data.summary

spike.data.summary = pre.spike.data.summary %>% 
  left_join(post.spike.data.summary) %>% 
  mutate(
    pre.spike.pct.unemployed = round(pre.spike.pct.unemployed * 100, 1),
    latest.pct.unemployed = round(latest.pct.unemployed * 100, 1),
    change.pct.unemployment = latest.pct.unemployed - pre.spike.pct.unemployed,
    change.total.on.unemployment = latest.total.on.unemployment - pre.spike.total.on.unemployment,
  )

spike.data.summary

plot.spike.states = spike.data.summary %>% 
  # mutate(
  #   latest.total.on.unemployment = case_when(
  #     state.abbr == 'FL' ~ 339446,
  #     TRUE ~ latest.total.on.unemployment
  #   ),
  #   change.total.on.unemployment = latest.total.on.unemployment - pre.spike.total.on.unemployment
  # ) %>% 
  ggplot(aes(new.claims.since.spike / 1e6, change.total.on.unemployment / 1e6)) +
  # geom_point(aes(size = labor.force)) +
  geom_text(aes(label = state.abbr)) +
  geom_abline(slope = 1, intercept = 0) +
  xlab('Total new unemployment claims since spike (in millions)') +
  ylab('Change in number of people on unemployment since spike\n(in millions)') +
  theme_minimal() +
  ggtitle('New claims vs. additions to unemployment system by state\nSince spike in claims started March 15')

plot.spike.states

spike.data.summary %>% write_csv('tables/spike-summary-states.csv', na = '')

ggsave(filename = 'plots/national-initial-claims.png', plot = plot.initial, width = 12, height = 8)
ggsave(filename = 'plots/national-weekly-claims.png', plot = plot.weekly, width = 12, height = 8)
ggsave(filename = 'plots/national-pct-unemployed.png', plot = plot.pct.unemployed, width = 12, height = 8)
# ggsave(filename = 'plots/new-claims-additions-since-spike.png', plot = plot.spike.states, width = 12, height = 8)
