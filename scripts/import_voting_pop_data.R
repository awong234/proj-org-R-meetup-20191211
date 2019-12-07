# Import some add'l data

# Setup ------------------------------------------------------------------------

{
  library(curl)
  library(assertthat)
}

# Data pull --------------------------------------------------------------------

url = 'https://www2.census.gov/programs-surveys/cps/tables/time-series/voting-historical-time-series/a1.xlsx'

# Check that the url works

status = curl::curl_fetch_memory(url)

assert_that(
  status$status_code == 200,
  typeof(status$content) == 'raw',
  length(status$content) > 0
)

# Fetch the data

curl_download(url = url, destfile = 'input/a1.xlsx')

# Check that the data were downloaded correctly

assert_that(
  file.exists('input/a1.xlsx')
)

# END --------------------------------------------------------------------------