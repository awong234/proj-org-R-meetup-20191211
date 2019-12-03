#' @title Fill Left
#' @description Fills missing values using the values to the left, if not missing
#' @param vector A vector with missing values to be filled
#' @return A vector of the same length as vector, without any missing values, filled as requested.

fill_left = function(vector) {
  val = vector[1]
  if (is.na(val)) {
    warning("The first value is missing; any subsequent missing values will remain missing until the first non-missing value is encountered.")
  }
  for (i in seq_along(vector)[-1]) {
    if (is.na(vector[i])) {
      vector[i] = vector[i-1]
    }
  }
  return(vector)
}

#' @title Merge down
#' @description Combines two rows of character data into one, separating by a character.
#' @param sep The character to separate the values
#' @return A single vector of the same length as the inputs, with elements containing each string in the column separated by a given character
#' 

merge_down = function(data, sep = '_') {
  
  new_data = character(ncol(data))
  
  for (i in seq_along(data)) {
    new_data[i] = paste0(data[[i]], collapse = sep)
  }
  
  return(new_data)
  
}
