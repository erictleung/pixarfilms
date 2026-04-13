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
message("Reading raw academy data from staging...")
academy_raw <- dbReadTable(staging_con, "raw_wiki_academy")

# Clean academy awards data
message("Cleaning academy awards data...")
academy <- academy_raw %>%
  filter(film != "Film") %>%
  mutate(across(everything(), ~ifelse(.x == "", NA, .x))) %>%
  pivot_longer(
    cols = -film,
    names_to = "award_type",
    values_to = "status"
  ) %>%
  drop_na(status) %>%
  mutate(award_type = str_to_title(str_replace_all(award_type, "_", " "))) %>%
  mutate(award_type = case_when(
    award_type == "Sound A" ~ "Sound Editing",
    award_type == "Sound A 2" ~ "Sound Mixing",
    TRUE ~ award_type
  ))

# Write to production database
message("Saving cleaned academy data to production database...")
dbWriteTable(prod_con, "academy", academy, overwrite = TRUE)

# Clean up
dbDisconnect(staging_con)
dbDisconnect(prod_con)
message("Success! Academy awards cleaned and saved to production database.")
