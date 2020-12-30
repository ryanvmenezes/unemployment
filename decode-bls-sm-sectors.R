library(tidyverse)

# data = read_tsv('raw/ln.data.1.AllData.tsv')

codes = read_tsv('raw/sm/sm.series.tsv', col_types = cols(.default = 'c')) %>% 
  rename(seasonal_code = seasonal, footnote_code = footnote_codes)

codes

data.dir = 'raw/sm/'
codebooks = list.files(data.dir) %>% 
  `[`(str_detect(., 'codes.sm')) %>% 
  str_c(data.dir, .) %>%
  set_names(., str_replace_all(., 'raw/sm/codes.sm.|.tsv', '')) %>%
  map(read_tsv, col_types = cols(.default = 'c'))

codebooks

all.codes = reduce(prepend(codebooks, list(codes)), left_join, .dir = 'forward') %>% 
  select(
    series_id, state_code, area_code, benchmark_year, begin_year, begin_period, end_year, end_period,
    ends_with('name'), ends_with('text'), ends_with('code'),
  ) %>% 
  # rename_at(vars(ends_with('_text')), ~str_replace(., '_text', '_name')) %>% 
  replace(. == 'N/A', '')

all.codes

all.codes %>% write_csv('sm-codes.csv')


