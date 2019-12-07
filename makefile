# Phonies ----------------------------------------------------------------------

all: data transformations

clean:
	rm input/*

# Data -------------------------------------------------------------------------

data: input/a5a.xlsx input/a1.xlsx

input/a5a.xlsx: scripts/import_voting_rate_data.R R/*
	Rscript scripts/import_voting_rate_data.R

input/a1.xlsx: scripts/import_voting_pop_data.R R/*
	Rscript scripts/import_voting_pop_data.R

# Transformations --------------------------------------------------------------

transformations: output/transformations.conf

output/transformations.conf: scripts/transform.R R/* input/a5a.xlsx input/a1.xlsx
	Rscript scripts/transform.R