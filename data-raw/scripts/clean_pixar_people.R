library(DBI)
library(RSQLite)
library(dplyr)
library(tidyr)
library(stringr)
library(here)

# Connect to databases
message("Connecting to staging and production databases...")
staging_con <- dbConnect(SQLite(), here("data-raw", "pixar_staging.db"))
prod_con <- dbConnect(SQLite(), here("data-raw", "pixarfilms.db"))

# Read raw data
message("Reading raw wiki films from staging...")
films_raw <- dbReadTable(staging_con, "raw_wiki_films")

# Clean people data
message("Cleaning Pixar people data...")
pixar_people <- films_raw |>
  select(-c(release_date)) |>
  pivot_longer(
    cols = -film,
    names_to = "role_type",
    values_to = "name"
  ) |>
  separate_rows(name, sep = ", ") |>
  mutate(role_type = case_when(
    role_type %in% c("directed_by", "director_s") ~ "Director",
    role_type %in% c("screenplay_by") ~ "Screenwriter",
    role_type %in% c("story_by", "writer_s", "writers_s_2") ~ "Storywriter",
    role_type %in% c("music_by") ~ "Musician",
    role_type %in% c("produced_by", "producers") ~ "Producer",
    TRUE ~ role_type
  )) |>
  filter(film != "Film") # Remove header if present

# Write to production database
message("Saving cleaned Pixar people to production database...")
dbWriteTable(prod_con, "pixar_people", pixar_people, overwrite = TRUE)

# Clean up
dbDisconnect(staging_con)
dbDisconnect(prod_con)
message("Success! Pixar people cleaned and saved to production database.")
