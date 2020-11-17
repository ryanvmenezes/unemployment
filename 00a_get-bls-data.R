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