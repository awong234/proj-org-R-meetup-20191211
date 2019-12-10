# Phonies ----------------------------------------------------------------------

all: data transformations analyses reports

clean:
	rm input/*; rm output/*; rm report/report.html; rm img/*

# Data -------------------------------------------------------------------------

data: input/a5a.xlsx

input/a5a.xlsx: scripts/import_voting_rate_data.R \
R/*
	Rscript scripts/import_voting_rate_data.R

# Transformations --------------------------------------------------------------

transformations: output/voting_rates.tsv

output/voting_rates.tsv: \
scripts/transform.R \
R/* \
input/a5a.xlsx 
	Rscript scripts/transform.R
	
# Analyses --------------------------------------------------------------------- 

analyses: output/model_tbl.RDS 

output/model_tbl.RDS: output/voting_rates.tsv \
scripts/analyze.R \
R/*
	Rscript scripts/analyze.R

# Reports ----------------------------------------------------------------------

reports: report/report.html

report/report.html: output/model_tbl.RDS \
report/report.Rmd R/*
	Rscript -e "rmarkdown::render(input = 'report/report.Rmd', output_file = 'report/report.html', output_dir = 'report', knit_root_dir = here::here())"

