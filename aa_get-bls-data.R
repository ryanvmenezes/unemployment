# these are large files updated monthly, they do not need to be re-downloaded often

# bls unemployment by county

download.file(
  'https://www.bls.gov/web/metro/laucntycur14.txt',
  'raw/laucntycur14.txt'
)

# all bls state statistics (lau)

download.file(
  'https://download.bls.gov/pub/time.series/la/la.data.2.AllStatesU',
  'raw/la.data.2.AllStatesU.tsv'
)

# all bls county statistics (lau)

download.file(
  'https://download.bls.gov/pub/time.series/la/la.data.64.County',
  'raw/la.data.64.County.tsv'
)
