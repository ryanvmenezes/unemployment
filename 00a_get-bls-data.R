# these are large files updated monthly, they do not need to be re-downloaded often

# bls unemployment by county

download.file(
  'https://www.bls.gov/web/metro/laucntycur14.txt',
  'raw/laucntycur14.txt'
)

# all bls state statistics (lau)

download.file(
  'https://download.bls.gov/pub/time.series/la/la.data.3.AllStatesS',
  'raw/la.data.3.AllStatesS.tsv'
)

# all bls county statistics (lau)

download.file(
  'https://download.bls.gov/pub/time.series/la/la.data.64.County',
  'raw/la.data.64.County.tsv'
)

# lau for california

download.file(
  'https://data.edd.ca.gov/api/views/e6gw-gvii/rows.csv?accessType=DOWNLOAD',
  'raw/edd-california.csv'
)

# LN	Labor Force Statistics from the Current Population Survey (NAICS)

download.file(
  'https://download.bls.gov/pub/time.series/ln/ln.data.1.AllData',
  'raw/ln.data.1.AllData.tsv'
)

download.file(
  'https://download.bls.gov/pub/time.series/ln/ln.series',
  'raw/ln.series.tsv'
)

codebooks = c(
  'ln.absn','ln.activity','ln.ages','ln.born','ln.cert',
  'ln.chld','ln.class','ln.disa','ln.duration','ln.education',
  'ln.entr','ln.expr','ln.footnote','ln.hheader','ln.hour',
  'ln.indy','ln.jdes','ln.lfst','ln.look','ln.mari',
  'ln.mjhs','ln.occupation','ln.orig','ln.pcts','ln.periodicity',
  'ln.race','ln.rjnw','ln.rnlf','ln.rwns','ln.seasonal',
  'ln.seek','ln.sexs','ln.tdat','ln.vets','ln.wkst'
)

purrr::walk2(
  paste('https://download.bls.gov/pub/time.series/ln/', codebooks, sep = ''),
  paste('raw/codes.', codebooks, '.tsv', sep = ''),
  download.file
)

# OE	Occupation Employment Statistics

download.file(
  'https://download.bls.gov/pub/time.series/sm/sm.data.5b.California',
  'raw/sm.data.5b.California.tsv'
)

download.file(
  'https://download.bls.gov/pub/time.series/sm/sm.data.5c.California',
  'raw/sm.data.5c.California.tsv'
)

download.file(
  'https://download.bls.gov/pub/time.series/sm/sm.series',
  'raw/sm.series.tsv'
)

codebooks = c(
  'area', 'data_type', 'footnote', 'industry',
  'seasonal', 'state', 'supersector'
)

purrr::walk2(
  paste('https://download.bls.gov/pub/time.series/sm/sm.', codebooks, sep = ''),
  paste('raw/codes.sm.', codebooks, '.tsv', sep = ''),
  download.file
)
