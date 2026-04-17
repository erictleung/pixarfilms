# Load libraries
library(DBI)
library(RSQLite)
library(dplyr)
library(lubridate)
library(here)
library(stringr)

# Connect to databases
message("Connecting to staging and production databases...")
staging_con <- dbConnect(SQLite(), here("data-raw", "pixar_staging.db"))
prod_con <- dbConnect(SQLite(), here("data-raw", "pixarfilms.db"))

# Read raw data
message("Reading raw data from staging...")
films_raw <- dbReadTable(staging_con, "raw_wiki_films")
omdb_raw <- dbReadTable(staging_con, "raw_omdb_data")

# Clean films data
message("Cleaning Pixar films data...")
pixar_films <- films_raw %>%
  mutate(release_date = mdy(release_date)) %>%
  arrange(release_date) %>%
  mutate(number = row_number()) %>%
  select(number, film, release_date)

# Join with OMDb data
# Handle potentially missing columns in omdb_raw
omdb_cols <- colnames(omdb_raw)
omdb_clean <- omdb_raw %>%
  select(
    film = title, 
    run_time = if("runtime" %in% omdb_cols) "runtime" else "NULL",
    film_rating = if("rated" %in% omdb_cols) "rated" else "NULL",
    plot = if("plot" %in% omdb_cols) "plot" else "NULL"
  ) %>%
  mutate(run_time = as.numeric(str_extract(run_time, "[0-9]*")))

pixar_films <- pixar_films %>%
  left_join(omdb_clean, by = "film")

# Write to production database
message("Saving cleaned Pixar films to production database...")
dbWriteTable(prod_con, "pixar_films", pixar_films, overwrite = TRUE)

# Clean up
dbDisconnect(staging_con)
dbDisconnect(prod_con)
message("Success! Pixar films cleaned and saved to production database.")
