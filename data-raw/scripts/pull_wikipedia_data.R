# Pull tables with data from Wikipedia
# Tables include:
# - Pixar films
# - Box office
# - Public response
# - Academy awards


# Load libraries
library(rvest)
library(dplyr)
library(DBI)
library(RSQLite)
library(janitor)
library(here)


# Connect to staging database
message("Connecting to staging database...")
con <- dbConnect(SQLite(), here("data-raw", "pixar_staging.db"))
message("Done!")


# Scrape Wikipedia page
message("Scraping Wikipedia page...")
page <- read_html("https://en.wikipedia.org/wiki/List_of_Pixar_films")
tbls <- html_table(page, fill = TRUE)
message("Done!")


# Extract and save tables
message("Saving raw tables to staging database pixar_staging.db...")
banner_offset <- 0 # Adjust if Wikipedia adds banners
dbWriteTable(con, "raw_wiki_films", tbls[[1 + banner_offset]] |> clean_names(), overwrite = TRUE)
dbWriteTable(con, "raw_wiki_box_office", tbls[[3 + banner_offset]] |> clean_names(), overwrite = TRUE)
dbWriteTable(con, "raw_wiki_public_response", tbls[[4 + banner_offset]] |> clean_names(), overwrite = TRUE)
dbWriteTable(con, "raw_wiki_academy", tbls[[5 + banner_offset]] |> clean_names(), overwrite = TRUE)
message("Success! Tables written to staging database.")
message("Wrote films, box office, public response, and academy response datasets.")


# Clean up
dbDisconnect(con)
message("Done!")
