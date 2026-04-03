library(rvest)
library(dplyr)
library(readr)
library(progress)
library(here)
library(DBI)
library(RSQLite)

#' Get Rotten Tomatoes' scores
#'
#' @param url string for the Rotten Tomatoes' movie link
#'
#' @returns list of elements `tomatometer` and `popcornmeter`
get_rt_scores <- function(url) {

  # Navigate to page
  message(paste("Reading in URL:", url))
  page <- tryCatch({
    read_html(url)
  }, error = function(e) {
    message(paste("Error reading URL:", url))
    return(NULL)
  })
  
  if (is.null(page)) return(NULL)

  title <- page |>
    html_element("title") |>
    html_text2() |>
    gsub(" | Rotten Tomatoes", "", x = _, fixed = TRUE) |>
    gsub(" \\(\\d{4}\\)", "", x = _)  # Remove year if present

  critics_score <- page |>
    html_element("rt-text[slot='critics-score']") |>
    html_text2()

  critics_reviews <- page |>
    html_element("rt-link[slot='critics-reviews']") |>
    html_text2() |>
    gsub(" Reviews", "", x = _, fixed = TRUE)

  audience_score <- page |>
    html_element("rt-text[slot='audience-score']") |>
    html_text2()

  audience_reviews <- page |>
    html_element("rt-link[slot='audience-reviews']") |>
    html_text2() |>
    gsub("+ Ratings", "", x = _, fixed = TRUE) |>
    gsub("+ Verified Ratings", "", x = _, fixed = TRUE) |>
    gsub(",", "", x = _, fixed = TRUE)

  tibble(
    film = title,
    tomatometer_value = critics_score,
    tomatometer_reviews = critics_reviews,
    popcornmeter_value = audience_score,
    popcornmeter_reviews = audience_reviews
  )
}

# Set page to pull all movies from
url <- "https://editorial.rottentomatoes.com/guide/all-pixar-movies-ranked/"

# Read in page and pull relevant links from the list
message("Reading and extracting Rotten Tomatoes rankings list...")
page <- read_html(url)
movie_links <-
  page |>
  html_elements("[id^='countdown-index-']") |> # divs whose id starts with "countdown-index-"
  html_elements("a") |>
  html_attr("href") |>
  (\(x) x[grepl("^https://www\\.rottentomatoes\\.com/m/", x)])() |>
  unique()

# Loop through links to pull ratings from
rt_ratings <- tibble()
pb <- progress_bar$new(total = length(movie_links))
for (film_link in movie_links) {
  pb$tick()
  
  # Pull film ratings and append to them running list
  tmp_rt_ratings <- tryCatch({
    get_rt_scores(film_link)
  }, error = function(e) {
    message(paste("Error fetching:", film_link))
    return(NULL)
  })
  
  if (!is.null(tmp_rt_ratings)) {
    rt_ratings <- bind_rows(rt_ratings, tmp_rt_ratings)
  }

  Sys.sleep(1)
}

# Write out to staging database
message("Connecting to staging database...")
con <- dbConnect(SQLite(), here("data-raw", "pixar_staging.db"))
message("Saving Rotten Tomatoes ratings to staging database...")
dbWriteTable(con, "raw_rt_ratings", rt_ratings, overwrite = TRUE)
dbDisconnect(con)

message("Success! Rotten Tomatoes data written to staging database.")
