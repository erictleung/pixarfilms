library(DBI)
library(RSQLite)
library(dplyr)
library(stringr)
library(here)

# Connect to databases
message("Connecting to staging and production databases...")
staging_con <- dbConnect(SQLite(), here("data-raw", "pixar_staging.db"))
prod_con <- dbConnect(SQLite(), here("data-raw", "pixarfilms.db"))

# Read raw data
message("Reading raw box office data from staging...")
box_office_raw <- dbReadTable(staging_con, "raw_wiki_box_office")

# Clean box office data
message("Cleaning box office data...")
box_office <- box_office_raw %>%
  filter(film != "Film") %>%
  select(-any_of(c("ref", "year", "ref_s"))) %>%
  rename(
    box_office_us_canada = box_office_gross,
    box_office_other = box_office_gross_2,
    box_office_worldwide = box_office_gross_3
  ) %>%
  mutate(budget = as.numeric(str_extract(budget, "[0-9-]+")) * 1e6) %>%
  mutate(across(starts_with("box_office"), ~as.numeric(str_replace_all(.x, "(\\$)|(,)|(\\[.*\\])", ""))))

# Write to production database
message("Saving cleaned box office to production database...")
dbWriteTable(prod_con, "box_office", box_office, overwrite = TRUE)

# Clean up
dbDisconnect(staging_con)
dbDisconnect(prod_con)
message("Success! Box office cleaned and saved to production database.")
