# these are large files updated monthly, they do not need to be re-downloaded often

# LOCAL AREA UNEMPLOYMENT STATISTICS (LA)

## state

download.file(
  'https://download.bls.gov/pub/time.series/la/la.data.3.AllStatesS',
  'raw/la/la.data.3.AllStatesS.tsv'
)

## county

download.file(
  'https://download.bls.gov/pub/time.series/la/la.data.64.County',
  'raw/la/la.data.64.County.tsv'
)

# LN	Labor Force Statistics from the Current Population Survey (NAICS)

download.file(
  'https://download.bls.gov/pub/time.series/ln/ln.data.1.AllData',
  'raw/ln/ln.data.1.AllData.tsv'
)

download.file(
  'https://download.bls.gov/pub/time.series/ln/ln.series',
  'raw/ln/ln.series.tsv'
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
  paste('raw/ln/codes.', codebooks, '.tsv', sep = ''),
  download.file
)






# # bls unemployment by county
# 
# download.file(
#   'https://www.bls.gov/web/metro/laucntycur14.txt',
#   'raw/laucntycur14.txt'
# )



# # lau for california from state
# 
# download.file(
#   'https://data.edd.ca.gov/api/views/e6gw-gvii/rows.csv?accessType=DOWNLOAD',
#   'raw/edd-california.csv'
# )