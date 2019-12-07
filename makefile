# Phonies ----------------------------------------------------------------------

all: data

clean:
	rm input/*

# Data -------------------------------------------------------------------------

data: input/a5a.xlsx

input/a5a.xlsx: scripts/import_data.R R/*
	Rscript scripts/import_data.R


