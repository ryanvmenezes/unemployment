library(tidyverse)

# data = read_tsv('raw/ln.data.1.AllData.tsv')

codes = read_tsv('raw/ln.series.tsv', col_types = cols(.default = 'c')) %>% 
  rename(seasonal_code = seasonal, footnote_code = footnote_codes)

codes

data.dir = 'raw/'
codebooks = list.files(data.dir) %>% 
  `[`(str_detect(., 'codes')) %>% 
  # set_names(., str_replace_all(., 'codes.ln.|.tsv', '')) %>%
  str_c(data.dir, .) %>%
  map(read_tsv, col_types = cols(.default = 'c'))

codebooks

all.codes = reduce(prepend(codebooks, list(codes)), left_join, .dir = 'forward') %>% 
  select(
    series_id, lfst_code, periodicity_code, series_title,
    begin_year, begin_period, end_year, end_period,
    ends_with('text'), ends_with('code')
  ) %>% 
  replace(. == 'N/A', '')

all.codes

all.codes.now = all.codes %>% 
  filter(end_year == '2020' & end_period == 'M04')

all.codes.now %>% write_csv('ln-codes.csv')

all.codes.now %>% 
  count(orig_text)
