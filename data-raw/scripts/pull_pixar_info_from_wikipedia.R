# Load packages and data --------------------------------------------------
# R version tested: 4.0.4
# Last run: 2021-05-01

# Utility packages
library(here)               # CRAN v1.0.1
library(janitor)            # CRAN v2.1.0
library(readr)              # CRAN v1.4.0

# Extract data
page <- read_html("https://en.wikipedia.org/wiki/List_of_Pixar_films")
tbls <- html_table(page, fill = TRUE)

# Extract actual tables
# Note: tbls[[2]] is upcoming films as of [2024-09-30]
# Note: Wikipedia page as of [2024-10-20] has a banner regarding a merge so
#   the table elements will be off by one
banner_offset <- 0  # Off set amount temporary
films <- clean_names(tbls[[1 + banner_offset]]) # Films, release info, top-level people
boxoffice <- clean_names(tbls[[3 + banner_offset]]) #  Box office
publicresponse <- clean_names(tbls[[4 + banner_offset]]) # Critical and public response
academy <- clean_names(tbls[[5 + banner_offset]]) # Academy awards

# Write out data
write_csv(films, file = here("data-raw", "data", "films_raw.csv"))
write_csv(boxoffice, file = here("data-raw", "data", "box_office_raw.csv"))
write_csv(publicresponse, file = here("data-raw", "data", "public_response_raw.csv"))
write_csv(academy, file = here("data-raw", "data", "academy_raw.csv"))
