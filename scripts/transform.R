# This file will reformat the data to how we want to use it in the future.
# Notably, the data come in as an excel file -- let's turn this into something
# else.

# Setup ------------------------------------------------------------------------

{
  library(readxl)
  library(vroom)
  library(tidyr)
  library(janitor)
  library(dplyr)
}

source("R/transform_functions.R")

# Import data ------------------------------------------------------------------

# This is the proportion of citizens, and all inhabitants voting

a5a = readxl::read_excel('input/a5a.xlsx', range = "A4:O58")

# Data needs cleaning ----------------------------------------------------------

# The headers are from merged columns, and so the values apply to multiple columns
a5a_headers = a5a[1:2, 2:15]
# The data are fine, but the labels could use work and the data are in wide form.
a5a_data    = a5a[4:nrow(a5a),]

# The goal here is to fill in the NA values using the previous (left) values,
# and then combine down the columns to get an informative label for each col.
a5a_headers[1,] = fill_left(a5a_headers[1,])
a5a_headers     = merge_down(a5a_headers)

# Now set these informative names to be the names of the data.
names(a5a_data) = c(names(a5a_data)[1], a5a_headers)

# Pivot the wide data into long data, and separate the "year_type" columns into two.
a5a_longer = pivot_longer(a5a_data, cols = `2016_Total`:`1992_Citizen`, names_to = "year_type", values_to = "voting_rate")
a5a_longer = separate(a5a_longer, col = year_type, into = c("year", "type"), remove = TRUE)
a5a_longer = clean_names(a5a_longer)

# Write to disk ----------------------------------------------------------------

vroom_write(a5a_longer, path = 'output/voting_rates.tsv')

# Confirm pass -----------------------------------------------------------------

system('touch output/transformations.conf')

# END --------------------------------------------------------------------------