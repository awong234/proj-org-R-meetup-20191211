# Import data from some place -- say a website. We're not going to do any
# cleaning here to keep things minimal -- one output per script, and a few steps
# to take full advantage of make's dependency chain.

# Setup ------------------------------------------------------------------------

{
  library(curl)
  library(assertthat)
}

# Data pull --------------------------------------------------------------------

url = "https://www2.census.gov/programs-surveys/cps/tables/time-series/voting-historical-time-series/a5a.xlsx"

# Check that the url works

climessage("Testing that the URL returns 200 status")

status = curl::curl_fetch_memory(url)

assert_that(
  status$status_code == 200,
  typeof(status$content) == 'raw',
  length(status$content) > 0
)

# Fetch the data

climessage("Downloading voting rate information to: input/a5a.xlsx")
curl_download(url = url, destfile = 'input/a5a.xlsx')

# Check that the data were downloaded correctly
climessage("Test that file exists.")
assert_that(
  file.exists('input/a5a.xlsx')
)

# END --------------------------------------------------------------------------
