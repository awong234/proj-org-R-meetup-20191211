# This file will reformat the data to how we want to use it in the future.
# Notably, the data come in as an excel file -- let's turn this into something
# else.

# Setup ------------------------------------------------------------------------

{
  library(readxl)
  library(vroom)
  library(tidyr)
}

source("R/transform_functions.R")

# Import data ------------------------------------------------------------------

a5a = readxl::read_excel('data/a5a.xlsx', range = "A4:O58")

# Data needs cleaning ----------------------------------------------------------

a5a_headers = a5a[1:2, 2:15]
a5a_data    = a5a[4:nrow(a5a),]

a5a_headers[1,] = fill_left(a5a_headers[1,])
a5a_headers     = merge_down(a5a_headers)

names(a5a_data) = c(names(a5a_data)[1], a5a_headers)

a5a_longer = pivot_longer()