`# Load packages and data --------------------------------------------------
# R version tested: 4.0.4
# Last run: 2021-05-01

# Utility packages
library(here)               # CRAN v1.0.1
library(janitor)            # CRAN v2.1.0
library(usethis)            # CRAN v2.0.1
library(lubridate)          # CRAN v1.7.10
library(progress)           # CRAN v1.2.2
library(readr)              # CRAN v1.4.0
library(stringr)            # CRAN v1.4.0

# Data wrangling packages
library(dplyr)              # CRAN v1.0.6
library(tidyr)              # CRAN v1.1.4
library(fuzzyjoin)

# Web scraping
library(rvest)              # CRAN v1.0.1
library(httr)               # CRAN v1.4.2
library(gtrendsR)

# Image analysis
# library(imagick)
# library(imager)


# Extract data ------------------------------------------------------------

#' Get Wikipedia data and OMDb configuration file
#'
#' The exact code for extracting actual tables may change depending on the
#' format of the Wikipedia tables themselves. Keep an eye out for those when
#' updating the data.
#'
#' @return list
#' @export
#'
#' @examples
#' wiki_data <- get_wiki_data()
get_wiki_data <- function() {
  # Extract data
  page <- read_html("https://en.wikipedia.org/wiki/List_of_Pixar_films")
  tbls <- html_table(page, fill = TRUE)

  # Extract actual tables
  # Note: tbls[[2]] is upcoming films as of [2024-09-30]
  # Note: Wikipedia page as of [2024-10-20] has a banner regarding a merge so
  #   the table elements will be off by one
  banner_offset <- 1  # Off set amount temporary
  films <- tbls[[1 + banner_offset]] # Films, release info, top-level people
  boxoffice <- tbls[[3 + banner_offset]] #  Box office
  publicresponse <- tbls[[4 + banner_offset]] # Critical and public response
  academy <- tbls[[5 + banner_offset]] # Academy awards

  # Get OMDb key to query movie information
  if (file.exists(here("config.txt"))) {
    config <- read.delim(here("config.txt"), header = FALSE)[1, 1]
  } else {
    message("Need to have OMDb API key to query movie database")
  }

  return(list(
    films = films,
    boxoffice = boxoffice,
    publicresponse = publicresponse,
    academy = academy,
    config = config
  ))
}


# Main --------------------------------------------------------------------

main <- function(){
  # Pull relevant data from Wikipedia and pull IMDb API key
  wiki_data <- get_wiki_data()

  # Unpack data
  films <- wiki_data$films
  boxoffice <- wiki_data$boxoffice
  publicresponse <- wiki_data$publicresponse
  academy <- wiki_data$academy
  config = wiki_data$config
}
main()  # Run all steps
