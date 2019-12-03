# Phonies ----------------------------------------------------------------------

all: data

clean:
	rm data/*

# Data -------------------------------------------------------------------------

data: data/a5a.xlsx

data/a5a.xlsx: R/import_data.R
	Rscript R/import_data.R



