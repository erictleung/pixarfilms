# Load packages and data --------------------------------------------------
# R version tested: 4.2.2
# Last run: 2026-03-22

# Utility packages
library(here) # CRAN v1.0.2
library(janitor) # CRAN v2.1.1
library(readr) # CRAN v2.2.0

# Replace first row with row names because some columns have two rows
get_col_names_from_row <- function(df) {
  colnames(df) <- head(df, 1)
  return(tail(df, nrow(df) - 1))
}

# Extract data
page <- read_html("https://en.wikipedia.org/wiki/List_of_Pixar_films")
tbls <- html_table(page, fill = TRUE)

# Extract actual tables
# Note: tbls[[2]] is upcoming films as of [2024-09-30]
# Note: Wikipedia page as of [2024-10-20] has a banner regarding a merge so
#   the table elements will be off by one
banner_offset <- 0 # Off set amount temporary
films <- tbls[[1 + banner_offset]] # Films, release info, top-level people
boxoffice <- tbls[[3 + banner_offset]] #  Box office
publicresponse <- tbls[[4 + banner_offset]] # Critical and public response
academy <- tbls[[5 + banner_offset]] # Academy awards

# Replace first row with row names because writers columns have two rows
films <- get_col_names_from_row(films)
boxoffice <- get_col_names_from_row(boxoffice)
publicresponse <- get_col_names_from_row(publicresponse)
academy <- get_col_names_from_row(academy)

# Basic clean up using janitor
films <- clean_names(films)
boxoffice <- clean_names(boxoffice)
publicresponse <- clean_names(publicresponse)
academy <- clean_names(academy)

# Write out data
write_csv(
  films,
  file = here("data-raw", "data", "films_raw.csv")
)
write_csv(
  boxoffice,
  file = here("data-raw", "data", "box_office_raw.csv")
)
write_csv(
  publicresponse,
  file = here("data-raw", "data", "public_response_raw.csv")
)
write_csv(
  academy,
  file = here("data-raw", "data", "academy_raw.csv")
)
