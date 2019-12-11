source("renv/activate.R")

climessage = function(note){

  # Do you have crayon & glue?
  missingpackages =
    suppressWarnings({
      suppressPackageStartupMessages({
        ! require(crayon, quietly = T) | ! require(glue, quietly = T)
        })
      })

  if(interactive()){ # If within R . . .
    if(missingpackages){ # Print ordinarily if packages are missing
      warning("Packages `glue` and `crayon` are not installed; output highlighting may not work properly")
      message(note)
    } else { # Otherwise print with STYLE
      message(glue::glue_col(paste0("{green ", note, "}")))
    }
  } else { # Print with color if outside R in terminal
    if(missingpackages){
      warning("Packages `glue` and `crayon` are not installed; output highlighting may not work properly")
      system(command = sprintf("echo -en '\\\\e[01;93m%s\\\\e[0m\n'", note))
    }
      system(command = sprintf("echo -en '\\\\e[01;32m%s\\\\e[0m\n'", glue(note)))
    }

}
