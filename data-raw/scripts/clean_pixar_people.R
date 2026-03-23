# Load packages and data --------------------------------------------------
# R version tested: 4.2.2
# Last run: 2026-03-22

# Load packages
library(here) # CRAN v1.0.2
library(dplyr) # CRAN v1.2.0
library(janitor) # CRAN v2.2.1
library(readr) # CRAN v2.2.1
library(lubridate) # CRAN v1.9.5

# Read data back into R
people <- read_csv(file = here("data-raw", "data", "pixar_films_raw.csv"))

# Create table of film-people rows
# - Directors
# - Screenwriters
# - Story writer
# - Producer
# - Musician
# pixar_people <-
films |>
  select(-c(release_date)) |>
  pivot_longer(
    cols = -film,
    names_to = "role_type",
    values_to = "name"
  ) |>
  separate_rows(name, sep = ", ")
