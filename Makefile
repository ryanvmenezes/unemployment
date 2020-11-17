getbls:
	Rscript 00a_get-bls-data.R
  
getdol:
	Rscript 00b_get-dol-data.R
  
get:
	make getbls
	make getdol

update:
	Rscript 00c_process-unemployment-data.R
	Rscript 01_bls-unemployment.R
	Rscript 02_unemployment-claims.R