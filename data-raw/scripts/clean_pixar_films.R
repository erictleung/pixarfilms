# Clean Pixar films data

# Load packages and data ----
# R version tested: 4.2.2
# Last run: 2026-03-22

# Load packages
library(here) # CRAN v1.0.2
library(dplyr) # CRAN v1.2.0
library(janitor) # CRAN v2.2.1
library(readr) # CRAN v2.2.1
library(lubridate) # CRAN v1.9.5

# Read data back into R
films <- read_csv(file = here("data-raw", "data", "films_raw.csv"))

# Steps
# - Remove random rows
# - Remove square brackets from all data
# - Replace TBA with NA (if applicable)
# - Process release date into dates
# pixar_films <-
films %>%

  # 2024-09-30 Wikipedians have separated released films and upcoming
  # Remove rows that are odd because of how Wikipedia formats tables
  # filter(!number %in% c("Released films", "Upcoming films")) %>%

  # 2024-09-30 Wikipedians have removed citations in the table
  # Remove citations for data because unneeded for our data
  # mutate_all(function(x) {
  #   str_replace_all(x, "\\[[A-Za-z0-9]\\]", "")
  # }) %>%

  # 2024-09-30 Wikipedians have removed any missing values
  # Replace TBA with NA for now
  # mutate_all(function(x) {
  #   ifelse(x == "TBA", NA, x)
  # }) %>%

  # Clean up and format release date, like remove spaces and process into ymd()
  # mutate(release_date = str_extract(release_date, "\\(.*\\)")) %>%
  # mutate(release_date = str_replace_all(release_date, "\\(|\\)", "")) %>%
  mutate(release_date = mdy(release_date)) %>%

  # Arrange and add ordering
  arrange(release_date) %>%
  mutate(number = row_number()) %>%
  select(number, film, release_date)


# Write out results
write_csv(
  pixar_films,
  file = here("data-raw", "data", "pixar_films_init.csv")
)
