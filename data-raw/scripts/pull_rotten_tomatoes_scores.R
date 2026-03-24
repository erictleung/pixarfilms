# Pull Rotten Tomatoes scores

# Load packages and data ----
# R version tested: 4.2.2
# Last run: 2026-03-22

library(rvest)
library(dplyr)
library(readr)
library(progress)
library(here)
library(chromote)

#' Get Rotten Tomatoes' scores
#'
#' @param url string for the Rotten Tomatoes' movie link
#'
#' @returns list of elements `tomatometer` and `popcornmeter`
get_rt_scores <- function(url) {

  # Navigate to page
  message("Reading in URL...")
  b$Page$navigate(url)
  Sys.sleep(3) # wait for JS to render
  rendered_html <- b$Runtime$evaluate(
    "document.documentElement.outerHTML"
  )$result$value
  message("Saving rendered HTML!")

  message("Extracting elements from rendered page...")
  page <- read_html(rendered_html)

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

  message("Completed extracting elements from page!")

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
message("Completed extraction of Rotten Tomatoes ranking list!")

# Testing
# get_rt_scores("https://www.rottentomatoes.com/m/toy_story_2")

# Create browser session to loop through
message("Opening Chrome session to help pull data")
b <- ChromoteSession$new()

# Loop through links to pull ratings from
rt_ratings <- tibble()
pb <- progress_bar$new(total = length(movie_links))
for (film in 1:length(movie_links)) {
  # Production use
  # for (film in 1:3) {  # Uncomment use for testing API and logic
  pb$tick()

  # Pull film ratings and append to them running list
  tmp_rt_ratings <- get_rt_scores(movie_links[film])
  rt_ratings <- bind_rows(rt_ratings, tmp_rt_ratings)

  # Pause for a few seconds to be a little kind to the OMDb API
  Sys.sleep(1)
}

# Close browser used to pull data
b$close()

# Write out data
write_csv(
  rt_ratings,
  file = here("data-raw", "data", "rt_ratings_raw.csv")
)
