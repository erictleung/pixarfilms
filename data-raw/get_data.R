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
  genres[film, "film_rating"] <- omdb_data$Rated
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


# Convert Vox analysis matrix ---------------------------------------------

# Source:
# https://www.vox.com/2015/11/23/9780818/pixar-chart-movies-toy-story-anniversary
# Other:
# - https://screencraft.org/2015/12/01/pixar-screenwriting-themes/
# - https://screencraft.org/2014/06/30/pixars-22-rules-storytelling-with-movie-stills/
# - https://thescriptlab.com/features/screenwriting-101/11835-top-10-themes-of-pixar-movies/
themes_vox <-
  tribble(
    ~film, ~theme,
    # Mismatched partners
    "Toy Story", "A mismatched pair of partners",
    "Toy Story 2", "A mismatched pair of partners",
    "Monsters, Inc.", "A mismatched pair of partners",
    "Finding Nemo", "A mismatched pair of partners",
    "Ratatouille", "A mismatched pair of partners",
    "WALL-E", "A mismatched pair of partners",
    "Up", "A mismatched pair of partners",
    "Toy Story 3", "A mismatched pair of partners",
    "Cars 2", "A mismatched pair of partners",
    "Brave", "A mismatched pair of partners",
    "Monsters University", "A mismatched pair of partners",
    "Inside Out", "A mismatched pair of partners",
    "The Good Dinosaur", "A mismatched pair of partners",
    "Finding Dory", "A mismatched pair of partners",

    # Philosophical differences
    "Toy Story", "With serious philosophical differences",
    "Toy Story 2", "With serious philosophical differences",
    "Finding Nemo", "With serious philosophical differences",
    "Brave", "With serious philosophical differences",
    "Monsters University", "With serious philosophical differences",
    "Inside Out", "With serious philosophical differences",
    "The Good Dinosaur", "With serious philosophical differences",
    "Finding Dory", "With serious philosophical differences",

    # Wacky journey
    "Toy Story", "Go on a wacky journey",
    "Bug's Life", "Go on a wacky journey",
    "Toy Story 2", "Go on a wacky journey",
    "Monsters, Inc.", "Go on a wacky journey",
    "Finding Nemo", "Go on a wacky journey",
    "The Incredibles", "Go on a wacky journey",
    "WALL-E", "Go on a wacky journey",
    "Up", "Go on a wacky journey",
    "Toy Story 3", "Go on a wacky journey",
    "Cars 2", "Go on a wacky journey",
    "Inside Out", "Go on a wacky journey",
    "The Good Dinosaur", "Go on a wacky journey",
    "Finding Dory", "Go on a wacky journey",

    # A loved one is lost
    "Toy Story 2", "A loved one is lost",
    "Finding Nemo", "A loved one is lost",
    "Ratatouille", "A loved one is lost",
    "WALL-E", "A loved one is lost",
    "Up", "A loved one is lost",
    "Toy Story 3", "A loved one is lost",
    "Inside Out", "A loved one is lost",
    "The Good Dinosaur", "A loved one is lost",
    "Finding Dory", "A loved one is lost",

    # A child comes of age
    "Toy Story", "A child comes of age",
    "Toy Story 2", "A child comes of age",
    "Monsters, Inc.", "A child comes of age",
    "Finding Nemo", "A child comes of age",
    "The Incredibles", "A child comes of age",
    "Up", "A child comes of age",
    "Toy Story 3", "A child comes of age",
    "Brave", "A child comes of age",
    "Inside Out", "A child comes of age",
    "The Good Dinosaur", "A child comes of age",
    "Finding Dory", "A child comes of age",

    # Their parents realize nothing is forever
    "Toy Story 2", "Their parent figure realizes nothing lasts forever",
    "Monsters, Inc.", "Their parent figure realizes nothing lasts forever",
    "Finding Nemo", "Their parent figure realizes nothing lasts forever",
    "The Incredibles", "Their parent figure realizes nothing lasts forever",
    "Brave", "Their parent figure realizes nothing lasts forever",
    "Inside Out", "Their parent figure realizes nothing lasts forever",
    "Finding Dory", "Their parent figure realizes nothing lasts forever",

    # Sad music
    "Toy Story 2", "There's a super sad piece of music",
    "Finding Nemo", "There's a super sad piece of music",
    "Cars", "There's a super sad piece of music",
    "WALL-E", "There's a super sad piece of music",
    "Up", "There's a super sad piece of music",
    "Toy Story 3", "There's a super sad piece of music",
    "Inside Out", "There's a super sad piece of music",

    # Wacky ensemble
    "Toy Story", "And a wacky ensemble of supporting players",
    "Bug's Life", "And a wacky ensemble of supporting players",
    "Toy Story 2", "And a wacky ensemble of supporting players",
    "Monsters, Inc.", "And a wacky ensemble of supporting players",
    "Finding Nemo", "And a wacky ensemble of supporting players",
    "The Incredibles", "And a wacky ensemble of supporting players",
    "Cars", "And a wacky ensemble of supporting players",
    "Up", "And a wacky ensemble of supporting players",
    "Toy Story 3", "And a wacky ensemble of supporting players",
    "Cars 2", "And a wacky ensemble of supporting players",
    "Monsters University", "And a wacky ensemble of supporting players",
    "Inside Out", "And a wacky ensemble of supporting players",
    "Finding Dory", "And a wacky ensemble of supporting players",

    # Everyday objects
    "Toy Story", "We explore the hidden world of everyday objects",
    "Bug's Life", "We explore the hidden world of everyday objects",
    "Toy Story 2", "We explore the hidden world of everyday objects",
    "Monsters, Inc.", "We explore the hidden world of everyday objects",
    "Finding Nemo", "We explore the hidden world of everyday objects",
    "Cars", "We explore the hidden world of everyday objects",
    "Ratatouille", "We explore the hidden world of everyday objects",
    "Toy Story 3", "We explore the hidden world of everyday objects",
    "Cars 2", "We explore the hidden world of everyday objects",
    "Monsters University", "We explore the hidden world of everyday objects",
    "Inside Out", "We explore the hidden world of everyday objects",
    "Finding Dory", "We explore the hidden world of everyday objects",

    # Finds calling
    "Toy Story", "Someone finds their calling",
    "Bug's Life", "Someone finds their calling",
    "Toy Story 2", "Someone finds their calling",
    "Monsters, Inc.", "Someone finds their calling",
    "The Incredibles", "Someone finds their calling",
    "Cars", "Someone finds their calling",
    "Ratatouille", "Someone finds their calling",
    "WALL-E", "Someone finds their calling",
    "Toy Story 3", "Someone finds their calling",
    "Brave", "Someone finds their calling",
    "Monsters University", "Someone finds their calling",
    "Inside Out", "Someone finds their calling",
    "The Good Dinosaur", "Someone finds their calling",
    "Finding Dory", "Someone finds their calling",

    # Community formed
    "Toy Story", "An ad hoc community is formed by movie's end",
    "Bug's Life", "An ad hoc community is formed by movie's end",
    "Toy Story 2", "An ad hoc community is formed by movie's end",
    "Monsters, Inc", "An ad hoc community is formed by movie's end",
    "Finding Nemo", "An ad hoc community is formed by movie's end",
    "The Incredibles", "An ad hoc community is formed by movie's end",
    "Cars", "An ad hoc community is formed by movie's end",
    "Ratatouille", "An ad hoc community is formed by movie's end",
    "WALL-E", "An ad hoc community is formed by movie's end",
    "Up", "An ad hoc community is formed by movie's end",
    "Toy Story 3", "An ad hoc community is formed by movie's end",
    "Monsters University", "An ad hoc community is formed by movie's end",
    "Inside Out", "An ad hoc community is formed by movie's end",
    "Finding Dory", "An ad hoc community is formed by movie's end",

    # Talking cars
    "Cars", "Cars can talk",
    "Cars 2", "Cars can talk"
  )


# Save out data for use ---------------------------------------------------

# Join all data into single data frame
# TODO Test and save out accordingly
all_pixar <-
    pixar_films %>%
    inner_join(pixar_people) %>%
    inner_join(academy) %>%
    inner_join(genres) %>%
    inner_join(box_office) %>%
    inner_join(public_response)

# Save out for external use as CSV files
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

# Save out for package use as RDA files in `data/` directory
use_data(
  pixar_films,
  pixar_people,
  genres,
  box_office,
  public_response,
  academy,
  overwrite = TRUE
)
