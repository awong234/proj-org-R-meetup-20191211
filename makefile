# Phonies ----------------------------------------------------------------------

all: data transformations

clean:
	rm input/*; rm output/*

# Data -------------------------------------------------------------------------

data: input/a5a.xlsx

input/a5a.xlsx: scripts/import_voting_rate_data.R R/*
	Rscript scripts/import_voting_rate_data.R

# Transformations --------------------------------------------------------------

transformations: output/transformations.conf

output/transformations.conf: \
scripts/transform.R \
R/* \
input/a5a.xlsx 
	Rscript scripts/transform.R