library(httr)
library(stringr)
library(dplyr)
library(DBI)
library(RSQLite)
library(here)
library(janitor)

# Connect to staging database
message("Connecting to staging database...")
con <- dbConnect(SQLite(), here("data-raw", "pixar_staging.db"))

# Read film titles from Wikipedia data
message("Reading film titles from Wikipedia data...")
films <- dbReadTable(con, "raw_wiki_films") |> 
  pull(film) |> 
  unique() |>
  setdiff("Film") # Remove header if present

# Load API key
if (file.exists(here("config.txt"))) {
  config <- read.delim(here("config.txt"), header = FALSE)[1, 1]
} else {
  stop("Need OMDb API key in config.txt")
}

omdb_url <- "https://www.omdbapi.com/"
omdb_w_key <- paste0(omdb_url, "?apikey=", config, "&")

# Fetch movie data from OMDb
message("Fetching movie data from OMDb...")
results <- list()
for (f in films) {
  message(paste("Fetching:", f))
  query_str <- str_replace_all(f, " ", "+")
  
  # Edge case for WALL-E / WALL·E
  query_str <- str_replace(query_str, "WALL-E", "WALL·E")
  
  res <- tryCatch({
    GET(url = paste0(omdb_w_key, "t=", query_str)) |> content()
  }, error = function(e) {
    message(paste("Error fetching:", f))
    return(NULL)
  })
  
  if (!is.null(res) && !"Error" %in% names(res)) {
     # Convert list to dataframe
     # Some fields might be missing, so we'll unlist carefully
     results[[f]] <- as.data.frame(t(unlist(res)))
  }
  Sys.sleep(3) # Be kind to the API
}

# Bind all results together and save to staging database
if (length(results) > 0) {
  raw_omdb <- bind_rows(results) |> clean_names()
  message("Saving OMDb data to staging database...")
  dbWriteTable(con, "raw_omdb_data", raw_omdb, overwrite = TRUE)
} else {
  message("No data fetched from OMDb.")
}

# Clean up
dbDisconnect(con)
message("Success! OMDb data written to staging database.")
