library(tidyverse)

# data = read_tsv('raw/ln.data.1.AllData.tsv')

codes = read_tsv('raw/sm.series.tsv', col_types = cols(.default = 'c')) %>% 
  rename(seasonal_code = seasonal, footnote_code = footnote_codes)

codes

data.dir = 'raw/'
codebooks = list.files(data.dir) %>% 
  `[`(str_detect(., 'codes.sm')) %>% 
  # set_names(., str_replace_all(., 'codes.ln.|.tsv', '')) %>%
  str_c(data.dir, .) %>%
  map(read_tsv, col_types = cols(.default = 'c'))

codebooks

all.codes = reduce(prepend(codebooks, list(codes)), left_join, .dir = 'forward') %>% 
  rename_at(vars(ends_with('_text')), ~str_replace(., '_text', '_name')) %>% 
  replace(. == 'N/A', '')

all.codes

all.codes %>% write_csv('sm-codes.csv')

all.codes.now %>%
  filter(state_code == '06') %>% 
  filter(area_code == '00000') %>% 
  filter(data_type_code == '01') %>% 
  view()
  count(industry_name)
