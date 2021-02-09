# Load packages and data --------------------------------------------------

# Utility packages
library(here)
library(janitor)
library(usethis)
library(lubridate)
library(progress)

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
# - Replace TBA with NA
# - Process release date into dates


films <-
  films %>%
  # Clean column names
  clean_names() %>%

  # Remove rows that are odd because of how Wikipedia formats tables
  filter(!number %in% c("Released films", "Upcoming films")) %>%

  # Remove citations for data because unneeded for our data
  mutate_all(function(x) {
    str_replace_all(x, "\\[[A-Za-z0-9]\\]", "")
    }) %>%

  # Replace TBA with NA for now
  mutate_all(function(x) { ifelse(x == "TBA", NA, x) }) %>%

  # Clean up and format release date
  mutate(release_date = str_extract(release_date, "\\(.*\\)")) %>%
  mutate(release_date = str_replace_all(release_date, "\\(|\\)", "")) %>%
  mutate(release_date = ymd(release_date))


# Create table of just films
pixar_films <-
  films %>%
  select( number, film, release_date)

# Create table of film-people rows
# - Directors
# - Screenwriters
# - Story writer
# - Producer
# - Musician
pixar_people <-
  films %>%
  select(-c(number, release_date)) %>%
  pivot_longer(
    cols = -film,
    names_to = "role_type",
    values_to = "name"
  ) %>%
  separate_rows(name, sep = "(, )|( & )")

# Fix abbreviation in table
pixar_people <-
  pixar_people %>%
  mutate(name = if_else(name == "Jeff", "Jeff Danna", name))

# Remove rows with no movie
pixar_people <-
  pixar_people %>%
  drop_na(film)

# Rename role types
pixar_people <-
  pixar_people %>%
  mutate(role_type = case_when(
    role_type == "directed_by" ~ "Director",
    role_type == "screenplay_by" ~ "Screenwriter",
    role_type == "story_by" ~ "Storywriter",
    role_type == "music_by" ~ "Musician",
    role_type == "produced_by" ~ "Producer"
  ))


# Add IMDb information from OMDb
# - Genres
omdb_url <- "https://www.omdbapi.com/"
omdb_w_key <- paste0(omdb_url, "?apikey=", config, "&")

genres <-
  films %>%
  select(film) %>%
  mutate(genre = NA)
pb <- progress_bar$new(total = nrow(genres))
pb$tick(0)  # Start progress
for (film in 1:nrow(genres)) {
  pb$tick()
  query_str <- str_replace_all(genres$film[film], " ", "+")
  omdb_data <- tryCatch(
    {
      content(GET(url = paste0(omdb_w_key, "t=", query_str)))
    }
  )
  genres[film, "genre"] <- omdb_data$Genre
}



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


