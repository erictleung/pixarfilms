# Load packages and data --------------------------------------------------
# Last run: 2021-05-01

# Utility packages
library(here)
library(janitor)
library(usethis)
library(lubridate)
library(progress)
library(readr)
library(stringr)

# Data wrangling packages
library(dplyr)
library(tidyr)

# Web scraping
library(rvest)
library(httr)


# Extract data ------------------------------------------------------------

# Extract data
page <- read_html("https://en.wikipedia.org/wiki/List_of_Pixar_films")
tbls <- html_table(page, fill = TRUE)

# Extract actual tables
films <- tbls[[1]] # Films
boxoffice <- tbls[[2]] #  Box office
publicresponse <- tbls[[3]] # Critical and public response
academy <- tbls[[4]] # Academy awards

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
  mutate_all(function(x) {
    ifelse(x == "TBA", NA, x)
  }) %>%

  # Clean up and format release date
  mutate(release_date = str_extract(release_date, "\\(.*\\)")) %>%
  mutate(release_date = str_replace_all(release_date, "\\(|\\)", "")) %>%
  mutate(release_date = ymd(release_date))


# Create table of just films
pixar_films <-
  films %>%
  select(number, film, release_date)

# Convert to tibble for easier viewing
pixar_films <- as_tibble(pixar_films)


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

# Query genres and add to film table
genres <-
  films %>%
  select(film) %>%
  mutate(genre = NA_character_,
         run_time = NA_character_,
         rated = NA_character_)

pb <- progress_bar$new(total = nrow(genres))
pb$tick(0) # Start progress
for (film in 1:nrow(genres)) {
  pb$tick()

  # Example:
  # http://www.omdbapi.com/?apikey=<KEY>t=Toy+Story
  query_str <- str_replace_all(genres$film[film], " ", "+")
  omdb_data <- tryCatch({
    content(GET(url = paste0(omdb_w_key, "t=", query_str)))
  })
  if ("Error" %in% names(omdb_data)) {
    omdb_data$Genre <- NA_character_
    omdb_data$Runtime <- NA_character_
    omdb_data$Rated <- NA_character_
  }

  genres[film, "genre"] <- omdb_data$Genre
  genres[film, "run_time"] <- omdb_data$Runtime
  genres[film, "rated"] <- omdb_data$Rated
}

# Move around data from OMDb to movie information before dealing with genres
pixar_films <-
  pixar_films %>%
  left_join(
    genres %>%
      select(film, run_time, rated),
    by = "film"
  ) %>%
  mutate(run_time = as.numeric(str_extract(run_time, "[0-9]*")))

# Clean up multi-genre rows
genres <-
  genres %>%
  select(-c(run_time, rated)) %>%
  separate_rows(genre, sep = ", ") %>%
  drop_na(film)


# Clean box office information --------------------------------------------

# Steps
# - Remove random rows
# - Remove reference columns
# - Clean column names
# - Format money

box_office <-
  boxoffice %>%
  clean_names() %>%
  filter(film != "Film") %>%
  select(-ref_s) %>%
  rename(
    box_office_us_canada = box_office_gross,
    box_office_other = box_office_gross_2,
    box_office_worldwide = box_office_gross_3
  ) %>%
  mutate(budget = as.numeric(str_extract(budget, "[0-9-]+")) * 1e6) %>%

  # Convert US and Canada box office information
  mutate(box_office_us_canada = str_replace_all(
    box_office_us_canada,
    "(\\$)|(,)", ""
  )) %>%
  mutate(box_office_us_canada = if_else(box_office_us_canada == "N/A",
    NA_character_,
    box_office_us_canada
  )) %>%
  mutate(box_office_us_canada = as.numeric(box_office_us_canada)) %>%

  # Convert other territory information
  mutate(box_office_other = str_replace_all(
    box_office_other,
    "(\\$)|(,)", ""
  )) %>%
  mutate(box_office_other = if_else(box_office_other == "N/A",
    NA_character_,
    box_office_other
  )) %>%
  mutate(box_office_other = as.numeric(box_office_other)) %>%

  # Convert worldwide box office information
  mutate(box_office_worldwide = str_replace_all(
    box_office_worldwide,
    "(\\$)|(,)", ""
  )) %>%
  mutate(box_office_worldwide = if_else(box_office_worldwide == "N/A",
    NA_character_,
    box_office_worldwide
  )) %>%
  mutate(box_office_worldwide = as.numeric(box_office_worldwide))

# Convert to tibble for easier viewing
box_office <- as_tibble(box_office)


# Clean public response data ----------------------------------------------

# Steps
# - Clean column names
# - Clean Rotten Tomatoes
# - Clean Metacritic
# - Clean Critics' Choice
# - Add IMDb score

colnames(publicresponse) <-
  publicresponse %>%
  colnames() %>%
  str_replace_all("\\[|[0-9]|\\]", "")

public_response <-
  publicresponse %>%
  clean_names() %>%
  mutate_all(function(x) {
    ifelse(x == "N/A", NA, x)
  }) %>%
  mutate(
    rotten_tomatoes = str_replace(rotten_tomatoes, "%", ""),
    critics_choice = str_replace(critics_choice, "\\/100", ""),
    metacritic = str_replace(metacritic, "\\/100", "")
  ) %>%
  mutate(
    rotten_tomatoes = as.numeric(rotten_tomatoes),
    metacritic = as.numeric(metacritic),
    critics_choice = as.numeric(critics_choice)
  )

# Some of the Cinema Scores use the em-dash instead of a simple dash when
# rating, or at least on Wikipedia. So here let's replace those scores manually
# with simple dashes.
problem_films <- c("Cars 2", "Onward")
public_response <-
  public_response %>%
  mutate(cinema_score = if_else(film %in% problem_films,
                                "A-",
                                cinema_score))

# Convert to tibble for easier viewing
public_response <- as_tibble(public_response)


# Clean academy data ------------------------------------------------------

# Steps
# - Remove random rows
# - Clean columns
# - Melt to longer data
# - Remove missing data

academy <-
  academy %>%
  clean_names() %>%
  filter(film != "Film") %>%
  mutate_all(function(x) {
    ifelse(x == "", NA, x)
  }) %>%
  pivot_longer(
    cols = -film,
    names_to = "award_type",
    values_to = "status"
  ) %>%
  drop_na(status) %>%
  mutate(award_type = str_replace_all(award_type, "_", " ")) %>%
  mutate(award_type = str_to_title(award_type)) %>%
  mutate(award_type = case_when(
    award_type == "Sound A" ~ "Sound Editing",
    award_type == "Sound A 2" ~ "Sound Mixing",
    TRUE ~ award_type
  ))


# Save out data for use ---------------------------------------------------


# Save out for external use
save_data <- function(x) {
  # Notes on deparse() and substitute()
  # https://stackoverflow.com/a/14577878/6873133
  str_path <- paste0(deparse(substitute(x)), ".csv")
  write_csv(x, here("data-raw", str_path))
}
save_data(pixar_films)
save_data(pixar_people)
save_data(genres)
save_data(box_office)
save_data(public_response)
save_data(academy)

# Save out for package use
use_data(
  pixar_films,
  pixar_people,
  genres,
  box_office,
  public_response,
  academy,
  overwrite = TRUE
)
