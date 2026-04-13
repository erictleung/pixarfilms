library(DBI)
library(RSQLite)
library(dplyr)
library(stringr)
library(here)
library(tidyr)
library(janitor)

# Connect to databases
message("Connecting to staging and production databases...")
staging_con <- dbConnect(SQLite(), here("data-raw", "pixar_staging.db"))
prod_con <- dbConnect(SQLite(), here("data-raw", "pixarfilms.db"))

# Read raw data
message("Reading raw public response data from staging...")
public_response_raw <- dbReadTable(staging_con, "raw_wiki_public_response")
rt_ratings_raw <- dbReadTable(staging_con, "raw_rt_ratings")

# Clean public response data
message("Cleaning public response data...")
# Wikipedia table has: film, critical (RT), critical_2 (MC), public (CS)
public_response <- public_response_raw %>%
  filter(film != "Film") %>%
  mutate(across(everything(), ~ifelse(.x == "N/A", NA, .x))) %>%
  mutate(
    rotten_tomatoes_score = as.numeric(str_extract(critical, "^[0-9]+")),
    metacritic_score = as.numeric(str_extract(critical_2, "^[0-9]+")),
    cinema_score = str_replace(public, "\\[.*\\]", "")
  ) %>%
  select(film, rotten_tomatoes_score, metacritic_score, cinema_score)

# Join with RT detailed ratings from staging
rt_detailed <- rt_ratings_raw %>%
  mutate(
    rotten_tomatoes_score = as.numeric(gsub("%", "", tomatometer_value)),
    rotten_tomatoes_counts = as.numeric(tomatometer_reviews),
    popcornmeter_score = as.numeric(gsub("%", "", popcornmeter_value)),
    popcornmeter_counts = as.numeric(popcornmeter_reviews)
  ) %>%
  select(film, rotten_tomatoes_score, rotten_tomatoes_counts, popcornmeter_score, popcornmeter_counts)

# Update with detailed data if possible
public_response <- public_response %>%
  left_join(rt_detailed, by = "film", suffix = c(".wiki", "")) %>%
  mutate(rotten_tomatoes_score = coalesce(rotten_tomatoes_score, rotten_tomatoes_score.wiki)) %>%
  select(film, rotten_tomatoes_score, rotten_tomatoes_counts, metacritic_score, popcornmeter_score, popcornmeter_counts, cinema_score)

# Write to production database
message("Saving cleaned public response to production database...")
dbWriteTable(prod_con, "public_response", public_response, overwrite = TRUE)

# Clean up
dbDisconnect(staging_con)
dbDisconnect(prod_con)
message("Success! Public response cleaned and saved to production database.")
