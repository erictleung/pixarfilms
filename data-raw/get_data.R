# Load packages and data --------------------------------------------------

# Utility packages
library(here)
library(janitor)
library(usethis)

# Data wrangling packages
library(dplyr)
library(tidyr)
library(purrr)

# Web scraping
library(rvest)
library(httr)

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
# - Rename and clean column names
# - Remove random rows
# - Remove square brackets from all data
# - Process release date into dates
# - Create table of just films
# - Create table of film-people rows

# films <-
  films %>%
  clean_names() %>%
  filter(!number %in% c("Released films", "Upcoming films")) %>%
  mutate_all(function(x) {
    str_replace_all(x, "\\[[A-Za-z0-9]\\]", "")
    })


# Add IMDb information from OMDb
# - Genres
omdb_url <- "https://www.omdbapi.com/"
omdb_w_key <- paste0(omdb_url, "?apikey=", config, "&")
query_str <- str_replace("Toy Story", " ", "+")
omdb_data <- content(GET(url = paste0(omdb_w_key, "t=", query_str)))
genre <- omdb_data$Genre

genres <-
  films %>%
  select(film)

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


