# Load packages and data --------------------------------------------------

library(dplyr)
library(rvest)
library(tidyr)
library(janitor)
library(here)
library(usethis)

# Extract data
page <- read_html("https://en.wikipedia.org/wiki/List_of_Pixar_films")
tbls <- html_table(page, fill = TRUE)


# Extract data ------------------------------------------------------------

# Extract actual tables
films <- tbls[[1]]           # Films
boxoffice <- tbls[[2]]       #  Box office
publicresponse <- tbls[[3]]  # Critical and public response
academy <- tbls[[4]]         # Academy awards

# Get OMDb key to query movie information
config <- read.delim(here("config.txt"), header = FALSE)[1, 1]


# Clean films -------------------------------------------------------------

# Steps
# - Remove random rows
# - Rename and clean column names
# - Process release date into dates
# - Remove square bracket information from films
# - Remove square bracket information from directed by
# - Remove square bracket information from screenplay by
# - Create table of just films
# - Create table of film-people rows

films

# Add IMDb information
# - Genres


# Clean box office information --------------------------------------------

# Steps
# - Remove random rows
# - Remove reference columns
# - Clean column names
# - Format money


# Clean public response data ----------------------------------------------

# Steps
# - Clean column names
# - Clean Rotten Tomatoes
# - Clean Metacritic
# - Clean Critics' Choice
# - Add IMDb score


# Clean academy data ------------------------------------------------------

# Steps
# - Remove random rows
# - Clean columns
# - Melt to longer data
# - Remove missing data


# Save out data for use ---------------------------------------------------


