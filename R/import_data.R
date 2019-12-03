# Import data from some place -- say a website. We're not going to do any
# cleaning here to keep things minimal -- one output per script, and a few steps
# to take full advantage of make's dependency chain.

# Setup ------------------------------------------------------------------------

{
  library(curl)
}

# Data pull --------------------------------------------------------------------

url = "https://www2.census.gov/programs-surveys/cps/tables/time-series/voting-historical-time-series/a5a.xlsx"

curl_download(url = url, destfile = 'data/a5a.xlsx')
