# Load packages and data --------------------------------------------------
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


# Clean films -------------------------------------------------------------

# Steps
# - Rename and clean column names
# - Remove random rows
# - Remove square brackets from all data
# - Replace TBA with NA
# - Process release date into dates

# Replace first row with row names because writers columns have two rows
colnames(films) <- head(films, 1)
films <- tail(films, nrow(films) - 1)

films <-
  films %>%
  # Clean column names
  clean_names() %>%

  # 2024-09-30 Wikipedians have separated released films and upcoming
  # Remove rows that are odd because of how Wikipedia formats tables
  # filter(!number %in% c("Released films", "Upcoming films")) %>%

  # 2024-09-30 Wikipedians have removed citations in the table
  # Remove citations for data because unneeded for our data
  # mutate_all(function(x) {
  #   str_replace_all(x, "\\[[A-Za-z0-9]\\]", "")
  # }) %>%

  # 2024-09-30 Wikipedians have removed any missing values
  # Replace TBA with NA for now
  # mutate_all(function(x) {
  #   ifelse(x == "TBA", NA, x)
  # }) %>%

  # Clean up and format release date, like remove spaces and process into ymd()
  # mutate(release_date = str_extract(release_date, "\\(.*\\)")) %>%
  # mutate(release_date = str_replace_all(release_date, "\\(|\\)", "")) %>%
  mutate(release_date = mdy(release_date)) %>%

  # Arrange and add ordering
  arrange(release_date) %>%
  mutate(number = row_number())


## pixar_films ----

# Create table of just films
pixar_films <-
  films %>%
  select(number, film, release_date)

# Convert to tibble for easier viewing
pixar_films <- as_tibble(pixar_films)


## pixar_people ----

# Create table of film-people rows
# - Directors
# - Screenwriters
# - Story writer
# - Producer
# - Musician
pixar_people <-
  films %>%
  select(-c(number, release_date)) %>%
  pivot_longer(
    cols = -film,
    names_to = "role_type",
    values_to = "name"
  ) %>%
  separate_rows(name, sep = ", ")

# Fix multiple co-directors per film
all_directors <-
  pixar_people %>%
  filter(str_detect(name, "Co-directed by")) %>%
  separate_rows(name, sep = "Co-directed ")

# Process all co-directors
co_directors <-
  all_directors %>%
  filter(str_detect(name, "by:")) %>%
  rename(old_name = name) %>%
  mutate(name = str_remove(old_name, "^by:")) %>%
  select(-old_name) %>%
  separate_rows(name, sep = " & ") %>%
  mutate(role_type = "Co-director")

# Remember the main directors
directors <-
  all_directors %>%
  filter(!str_detect(name, "by:")) %>%
  separate_rows(name, sep = " & ")

# Pull non-directors first to then join in back with updated directors
pixar_people <-
  pixar_people %>%
  filter(!str_detect(name, "Co-directed by")) %>%
  bind_rows(co_directors, directors) %>%
  separate_rows(name, sep = " & ") %>%
  rename(old_name = name) %>%
  mutate(name = str_remove(old_name, "\\[[A-Za-z]\\]")) %>%
  select(-old_name)


# Fix people using just last names to ensure consistency
full_names <-
  pixar_people %>%
  select(name) %>%
  filter(str_detect(name, " ")) %>%
  distinct(name) %>%
  rename(full_name = name)

single_names <-
  pixar_people %>%
  select(name) %>%
  filter(!str_detect(name, " ")) %>%
  distinct(name) %>%
  rename(short_name = name)

# Create mapping for short names that appear in table
ci_str_detect <- function(x, y) {
  # Note space before y is because the last name will have a space before it
  str_detect(x, regex(str_c(" ", y), ignore_case = TRUE))
}
name_map <-
  full_names %>%
  fuzzy_left_join(
    single_names,
    by = c("full_name" = "short_name"),
    match_fun = ci_str_detect
  ) %>%
  filter(!is.na(short_name))

# NOTE Edge case with multiple people with the same last name
name_map <-
  name_map %>%
  filter(!short_name %in% c("Andrews"))

# Fill in names and address edge case(s) above
pixar_people <-
  pixar_people %>%
  left_join(name_map, by = join_by(name == short_name)) %>%
  mutate(full_name = case_when(
    film == "Brave" ~ "Mark Andrews",
    film == "Luca" ~ "Jesse Andrews",
    is.na(full_name) ~ name,
    TRUE ~ full_name
  )) %>%
  select(-name) %>%
  rename(name = full_name)

# Remove rows with no movie
pixar_people <-
  pixar_people %>%
  drop_na(film)

# Rename role types
pixar_people <-
  pixar_people %>%
  mutate(role_type = case_when(
    role_type == "director_s" ~ "Director",
    role_type == "screenplay" ~ "Screenwriter",
    role_type == "story" ~ "Storywriter",
    role_type == "composer_s" ~ "Musician",
    role_type == "producer_s" ~ "Producer",
    TRUE ~ role_type
  ))

# Reorder for polish
pixar_people <-
  pixar_people %>%
  left_join(pixar_films %>% select(number, film)) %>%
  arrange(number, role_type) %>%
  select(-number)


## IMDb information ----

# Add IMDb information from OMDb
# - Genres
omdb_url <- "https://www.omdbapi.com/"
omdb_w_key <- paste0(omdb_url, "?apikey=", config, "&")

# Query genres and add to film table
raw_genres <-
  films %>%
  select(film) %>%
  mutate(genre = NA_character_,
         run_time = NA_character_,
         film_rating = NA_character_,
         poster_url = NA_character_,
         plot = NA_character_,
         imdb_rating = NA_character_,
         imdb_votes = NA_character_)

pb <- progress_bar$new(total = nrow(raw_genres))
pb$tick(0) # Start progress
for (film in 1:nrow(raw_genres)) {  # Production use
# for (film in 1:3) {  # Uncomment use for testing API and logic
  pb$tick()

  # Example:
  # http://www.omdbapi.com/?apikey=<KEY>t=Toy+Story
  query_str <- str_replace_all(raw_genres$film[film], " ", "+")

  # Edge case for WALL-E / WALL·E
  query_str <- str_replace(query_str, "WALL-E", "WALL·E")

  omdb_data <- tryCatch({
    content(GET(url = paste0(omdb_w_key, "t=", query_str)))
  })
  if ("Error" %in% names(omdb_data)) {
    omdb_data$Genre <- NA_character_
    omdb_data$Runtime <- NA_character_
    omdb_data$Rated <- NA_character_
    omdb_data$Poster <- NA_character_
    omdb_data$Plot <- NA_character_
    omdb_data$imdbRating <- NA_character_
    omdbc_data$imdbVotes <- NA_character_
  }

  # Fill in data if we have it
  raw_genres[film, "genre"] <- omdb_data$Genre
  raw_genres[film, "run_time"] <- omdb_data$Runtime
  raw_genres[film, "film_rating"] <- omdb_data$Rated
  raw_genres[film, "poster_url"] <- omdb_data$Poster
  raw_genres[film, "plot"] <- omdb_data$Plot
  raw_genres[film, "imdb_rating"] <- omdb_data$imdbRating
  raw_genres[film, "imdb_votes"] <- omdb_data$imdbVotes

  # Pause for a few seconds to be a little kind to the OMDb API
  Sys.sleep(3)
}

# Move around data from OMDb to movie information before dealing with genres
pixar_films <-
  pixar_films %>%
  left_join(
    raw_genres %>%
      select(film, run_time, film_rating, plot),
    by = "film"
  ) %>%
  mutate(run_time = as.numeric(str_extract(run_time, "[0-9]*")))

# Save posters for another analysis
posters <-
  raw_genres %>%
  select(film, poster_url)

# Save IMDb ratings for future
imdb_ratings <-
  raw_genres %>%
  select(film, starts_with("imdb")) %>%
  mutate(
    imdb_rating = as.numeric(imdb_rating),
    imdb_votes = as.numeric(str_remove_all(imdb_votes, ","))
  )

# Clean up multi-genre rows to make tidy data
# 2024-11-10 Genres from OMDb have been reduced to just animation, adventure,
#   comedy. So I'm going to hard code these from IMDb
genres <-
  raw_genres %>%
  select(-c(run_time, poster_url, film_rating, plot, imdb_rating, imdb_votes)) %>%
  separate_rows(genre, sep = ", ") %>%
  drop_na(film) %>%
  mutate(category = "Genre") %>%
  rename(value = genre) %>%
  select(film, category, value)

subgenres <-
  tribble(
    ~film, ~raw_genre,
    "Toy Story", "Buddy Comedy, Computer Animation, Supernatural Fantasy, Urban Adventure, Adventure, Animation, Comedy, Family, Fantasy",
    # https://www.imdb.com/title/tt0114709/

    "A Bug's Life", "Animal Adventure, Computer Animation, Quest, Adventure, Animation, Comedy, Family",
    # https://www.imdb.com/title/tt0120623/

    "Toy Story 2", "Computer Animation, Quest, Supernatural Fantasy, Urban Adventure, Adventure, Animation, Comedy, Family, Fantasy",
    # https://www.imdb.com/title/tt0120363/

    "Monsters, Inc.", "Buddy Comedy, Computer Animation, Supernatural Fantasy, Urban Adventure, Adventure, Animation, Comedy, Family, Fantasy",
      # https://www.imdb.com/title/tt0198781/

    "Finding Nemo", "Animal Adventure, Buddy Comedy, Computer Animation, Quest, Sea Adventure, Adventure, Animation, Comedy, Family",
    # https://www.imdb.com/title/tt0266543/

    "The Incredibles", "Computer Animation, Superhero, Urban Adventure, Action, Adventure, Animation, Family",
    # https://www.imdb.com/title/tt0317705/

    "Cars", "Computer Animation, Motorsport, Adventure, Animation, Comedy, Family, Sport",
    # https://www.imdb.com/title/tt0317219/?

    "Ratatouille", "Animal Adventure, Computer Animation, Adventure, Animation, Comedy, Family, Fantasy",
    # https://www.imdb.com/title/tt0382932/?

    "WALL-E", "Adventure Epic, Artificial Intelligence, Computer Animation, Dystopian Sci-Fi, Space Sci-Fi, Adventure, Animation, Family, Sci-Fi",
    # https://www.imdb.com/title/tt0910970/?

    "Up", "Coming-of-Age, Computer Animation, Globetrotting Adventure, Adventure, Animation, Comedy, Drama, Family",
    # https://www.imdb.com/title/tt1049413/?

    "Toy Story 3", "Computer Animation, Supernatural Fantasy, Urban Adventure, Adventure, Animation, Comedy, Family, Fantasy",
    # https://www.imdb.com/title/tt0435761/

    "Cars 2", "Car Action, Computer Animation, Motorsport, Spy, Adventure, Animation, Comedy, Crime, Family, Sport",
    # https://www.imdb.com/title/tt1216475/

    "Brave", "Coming-of-Age, Computer Animation, Fairy Tale, Quest, Sword & Sorcery, Teen Adventure, Action, Adventure, Animation",
    # https://www.imdb.com/title/tt1217209/

    "Monsters University", "Computer Animation, Adventure, Animation, Comedy, Family, Fantasy",
    # https://www.imdb.com/title/tt1453405/

    "Inside Out", "Coming-of-Age, Computer Animation, Adventure, Animation, Comedy, Drama, Family, Fantasy",
    # https://www.imdb.com/title/tt2096673/

    "The Good Dinosaur", "Animal Adventure, Buddy Comedy, Computer Animation, Dinosaur Adventure, Action, Adventure, Animation, Comedy, Drama, Family",
    # https://www.imdb.com/title/tt1979388/

    "Finding Dory", "Animal Adventure, Computer Animation, Sea Adventure, Adventure, Animation, Comedy, Family, Fantasy",
    # https://www.imdb.com/title/tt2277860/

    "Cars 3", "Car Action, Computer Animation, Motorsport, Adventure, Animation, Comedy, Family, Sport",
    # https://www.imdb.com/title/tt3606752/

    "Coco", "Computer Animation, Supernatural Fantasy, Adventure, Animation, Drama, Family, Fantasy, Music, Mystery",
    # https://www.imdb.com/title/tt2380307/

    "Incredibles 2", "Computer Animation, Superhero, Urban Adventure, Action, Adventure, Animation, Comedy, Family, Sci-Fi",
    # https://www.imdb.com/title/tt3606756/

    "Toy Story 4", "Computer Animation, Road Trip, Supernatural Fantasy, Urban Adventure, Adventure, Animation, Comedy, Family, Fantasy",
    # https://www.imdb.com/title/tt1979376/

    "Onward", "Computer Animation, Fantasy Epic, Quest, Supernatural Fantasy, Sword & Sorcery, Adventure, Animation, Comedy, Drama, Family",
    # https://www.imdb.com/title/tt7146812/

    "Soul", "Computer Animation, Adventure, Animation, Comedy, Drama, Family, Fantasy, Music",
    # https://www.imdb.com/title/tt2948372/

    "Luca", "Coming-of-Age, Computer Animation, Fairy Tale, Sea Adventure, Adventure, Animation, Comedy, Drama, Family, Fantasy",
    # https://www.imdb.com/title/tt12801262/

    "Turning Red", "Coming-of-Age, Computer Animation, Teen Comedy, Adventure, Animation, Comedy, Drama, Family, Fantasy, Music",
    # https://www.imdb.com/title/tt8097030/

    "Lightyear", "Computer Animation, Space Sci-Fi, Superhero, Time Travel, Action, Adventure, Animation, Comedy, Family, Sci-Fi",
    # https://www.imdb.com/title/tt10298810/

    "Elemental", "Computer Animation, Urban Adventure, Adventure, Animation, Comedy, Family, Fantasy, Romance",
    # https://www.imdb.com/title/tt15789038/

    "Inside Out 2", "Coming-of-Age, Computer Animation, Quest, Teen Comedy, Teen Drama, Adventure, Animation, Comedy, Drama, Family"
    # https://www.imdb.com/title/tt22022452/
  )

# Separate row values so that data is tidy
# Also remove overlap between genres and subgenres to make it cleaner
subgenres <-
  subgenres %>%
    separate_longer_delim(raw_genre, delim = ", ") %>%
    mutate(category = "Subgenre") %>%
    rename(value = raw_genre) %>%
    filter(!value %in% genres$value) %>%
    select(film, category, value)

# Put genres and subgenre categories into a single table and polish
genres <-
  genres %>%
  bind_rows(subgenres) %>%
  left_join(pixar_films %>% select(number, film), by = "film") %>%
  arrange(number, category, value) %>%
  select(-number) %>%
  distinct()


# Clean box office information --------------------------------------------

# Steps
# - Remove random rows
# - Remove reference columns
# - Clean column names
# - Format money

box_office <-
  boxoffice %>%
  clean_names() %>%
  filter(film != "Film") %>%
  select(-c(ref, year)) %>%  # 2024-11-10 Rename of column from ref_s -> ref
  rename(
    box_office_us_canada = box_office_gross,
    box_office_other = box_office_gross_2,
    box_office_worldwide = box_office_gross_3
  ) %>%
  mutate(budget = as.numeric(str_extract(budget, "[0-9-]+")) * 1e6) %>%

  # Convert US and Canada box office information
  mutate(box_office_us_canada = str_replace_all(
    box_office_us_canada,
    "(\\$)|(,)|(\\[.*\\])", ""
  )) %>%
  mutate(box_office_us_canada = if_else(box_office_us_canada == "N/A",
    NA_character_,
    box_office_us_canada
  )) %>%
  mutate(box_office_us_canada = as.numeric(box_office_us_canada)) %>%

  # Convert other territory information
  mutate(box_office_other = str_replace_all(
    box_office_other,
    "(\\$)|(,)|(\\[.*\\])", ""
  )) %>%
  mutate(box_office_other = if_else(box_office_other == "N/A",
    NA_character_,
    box_office_other
  )) %>%
  mutate(box_office_other = as.numeric(box_office_other)) %>%

  # Convert worldwide box office information
  mutate(box_office_worldwide = str_replace_all(
    box_office_worldwide,
    "(\\$)|(,)|(\\[.*\\])", ""
  )) %>%
  mutate(box_office_worldwide = if_else(box_office_worldwide == "N/A",
    NA_character_,
    box_office_worldwide
  )) %>%
  mutate(box_office_worldwide = as.numeric(box_office_worldwide))

# Convert to tibble for easier viewing
box_office <- as_tibble(box_office)


# Clean public response data ----------------------------------------------

# Steps
# - Clean column names
# - Clean Rotten Tomatoes
# - Clean Metacritic
# - Clean Critics' Choice
# - Add IMDb score

# Manually input audience Rotten Tomatoes rating
# https://editorial.rottentomatoes.com/article/audience-score-update/
rt_audience <- tribble(
  ~film, ~rt_popcorn_meter_score, ~rt_popcorn_meter_votes,
  "Toy Story", 92, 250000,
  "A Bug's Life", 73, 250000,
  "Toy Story 2", 87, 250000,
  "Monsters, Inc.", 90, 250000,
  "Finding Nemo", 86, 250000,
  "The Incredibles", 75, 250000,
  "Cars", 80, 250000,
  "Ratatouille", 87, 250000,
  "WALL-E", 90, 250000,
  "Up", 90, 250000,
  "Toy Story 3", 90, 250000,
  "Cars 2", 49, 100000,
  "Brave", 75, 250000,
  "Monsters University", 81, 250000,
  "Inside Out", 89, 100000,
  "The Good Dinosaur", 64, 50000,
  "Finding Dory", 84, 100000,
  "Cars 3", 68, 25000,
  "Coco", 94, 25000,
  "Incredibles 2", 84, 10000,
  "Toy Story 4", 94, 50000,
  "Onward", 95, 5000,
  "Soul", 88, 5000,
  "Luca", 84, 2500,
  "Turning Red", 67, 5000,
  "Lightyear", 84, 5000,
  "Elemental", 93, 2500,
  "Inside Out 2", 95, 5000
)

# Create data frame and adjust column names because first row is actual name
public_response <- publicresponse
colnames(public_response) <-
  publicresponse %>%
  first() %>%
  unlist(use.names=FALSE)
public_response <- public_response[-1, ]  # Remove redundant column names

# Clean up values
# 2024-11-10 Look's like Critic's Choice got removed
public_response <-
  public_response %>%
  clean_names() %>%
  mutate_all(function(x) {
    ifelse(x == "N/A", NA, x)
  }) %>%
  mutate(
    rotten_tomatoes = str_replace(rotten_tomatoes, "\\%", ""),
    metacritic = str_replace(metacritic, "\\/100", ""),
    cinema_score = str_replace(cinema_score, "\\[.*\\]", "")
  ) %>%
  mutate(
    rotten_tomatoes_score = str_extract(rotten_tomatoes, "^[0-9]+"),
    metacritic_score = str_extract(metacritic, "^[0-9]+"),
    rotten_tomatoes_counts = str_extract(
      rotten_tomatoes,
      "\\(([0-9]+) reviews\\)",
      group = 1
    ),
    metacritic_counts = str_extract(
      metacritic,
      "\\(([0-9]+) reviews\\)",
      group = 1)
  )


# Some of the Cinema Scores use the em-dash instead of a simple dash when
# rating, or at least on Wikipedia. So here let's replace those scores manually
# with simple dashes.
problem_films <- c("Cars 2", "Onward", "Lightyear")
public_response <-
  public_response %>%
  mutate(cinema_score = if_else(film %in% problem_films,
                                "A-",
                                cinema_score)) %>%
  mutate(cinema_score = if_else(cinema_score == "—", NA, cinema_score))

# Convert to tibble for easier viewing
public_response <-
  public_response %>%
  as_tibble() %>%
  select(-c(rotten_tomatoes, metacritic)) %>%
  select(
    film,
    starts_with("rotten"),
    starts_with("metacritic"),
    cinema_score
  ) %>%
  left_join(
    imdb_ratings %>%
      rename(imdb_score = imdb_rating, imdb_counts = imdb_votes),
    by = "film"
  ) %>%
  mutate(
    across(starts_with("rotten"), ~ as.numeric(.x)),
    across(starts_with("metacritic"), ~ as.numeric(.x)),
    across(starts_with("imdb"), ~ as.numeric(.x))
  )

# Join with Rotten Tomatoes audience meter
public_response <-
  public_response %>%
  left_join(rt_audience, by = "film")


# Manual quality checks, scores should be 0-100 or 0-10 and counts >0
summary(public_response)


# Clean academy data ------------------------------------------------------

# Steps
# - Remove random rows
# - Clean columns
# - Melt to longer data
# - Remove missing data

academy <-
  academy %>%
  clean_names() %>%
  filter(film != "Film") %>%
  mutate_all(function(x) {
    ifelse(x == "", NA, x)
  }) %>%
  pivot_longer(
    cols = -film,
    names_to = "award_type",
    values_to = "status"
  ) %>%
  drop_na(status) %>%
  mutate(award_type = str_replace_all(award_type, "_", " ")) %>%
  mutate(award_type = str_to_title(award_type)) %>%
  mutate(award_type = case_when(
    award_type == "Sound A" ~ "Sound Editing",
    award_type == "Sound A 2" ~ "Sound Mixing",
    TRUE ~ award_type
  ))

# Manual quality checks on if there are any typos or anomalous values
academy %>%
  group_by(award_type) %>%
  count(award_type) %>%
  arrange(n)

academy %>%
  group_by(status) %>%
  count(status) %>%
  arrange(n)


# Convert Vox analysis matrix ---------------------------------------------

# Source:
# https://www.vox.com/2015/11/23/9780818/pixar-chart-movies-toy-story-anniversary
# Other:
# - https://screencraft.org/2015/12/01/pixar-screenwriting-themes/
# - https://screencraft.org/2014/06/30/pixars-22-rules-storytelling-with-movie-stills/
# - https://thescriptlab.com/features/screenwriting-101/11835-top-10-themes-of-pixar-movies/

# Themes
theme_mismatch <- "A mismatched pair of partners"
theme_philsophy_diff <- "With serious philosophical differences"
theme_wacky_journey <- "Go on a wacky journey"
theme_lost_love <- "A loved one is lost"
theme_come_of_age <- "A child comes of age"
theme_nothing_forever <- "Their parent figure realizes nothing lasts forever"
theme_sad_music <- "There's a super sad piece of music"
theme_wacky_ensemble <- "And a wacky ensemble of supporting players"
theme_everyday_objects <- "We explore the hidden world of everyday objects"
theme_finds_calling <- "Someone finds their calling"
theme_community_formed <- "An ad hoc community is formed by movie's end"
theme_talking_cars <- "Cars can talk"

themes_vox <-
  tribble(
    ~film, ~theme,
    # Mismatched partners
    "Toy Story", theme_mismatch,
    "Toy Story 2", theme_mismatch,
    "Monsters, Inc.", theme_mismatch,
    "Finding Nemo", theme_mismatch,
    "Ratatouille", theme_mismatch,
    "WALL-E", theme_mismatch,
    "Up", theme_mismatch,
    "Toy Story 3", theme_mismatch,
    "Cars 2", theme_mismatch,
    "Brave", theme_mismatch,
    "Monsters University", theme_mismatch,
    "Inside Out", theme_mismatch,
    "The Good Dinosaur", theme_mismatch,
    "Finding Dory", theme_mismatch,

    # Philosophical differences
    "Toy Story", theme_philsophy_diff,
    "Toy Story 2", theme_philsophy_diff,
    "Finding Nemo", theme_philsophy_diff,
    "Brave", theme_philsophy_diff,
    "Monsters University", theme_philsophy_diff,
    "Inside Out", theme_philsophy_diff,
    "The Good Dinosaur", theme_philsophy_diff,
    "Finding Dory", theme_philsophy_diff,

    # Wacky journey
    "Toy Story", theme_wacky_journey,
    "Bug's Life", theme_wacky_journey,
    "Toy Story 2", theme_wacky_journey,
    "Monsters, Inc.", theme_wacky_journey,
    "Finding Nemo", theme_wacky_journey,
    "The Incredibles", theme_wacky_journey,
    "WALL-E", theme_wacky_journey,
    "Up", theme_wacky_journey,
    "Toy Story 3", theme_wacky_journey,
    "Cars 2", theme_wacky_journey,
    "Inside Out", theme_wacky_journey,
    "The Good Dinosaur", theme_wacky_journey,
    "Finding Dory", theme_wacky_journey,

    # A loved one is lost
    "Toy Story 2", theme_lost_love,
    "Finding Nemo", theme_lost_love,
    "Ratatouille", theme_lost_love,
    "WALL-E", theme_lost_love,
    "Up", theme_lost_love,
    "Toy Story 3", theme_lost_love,
    "Inside Out", theme_lost_love,
    "The Good Dinosaur", theme_lost_love,
    "Finding Dory", theme_lost_love,

    # A child comes of age
    "Toy Story", theme_come_of_age,
    "Toy Story 2", theme_come_of_age,
    "Monsters, Inc.", theme_come_of_age,
    "Finding Nemo", theme_come_of_age,
    "The Incredibles", theme_come_of_age,
    "Up", theme_come_of_age,
    "Toy Story 3", theme_come_of_age,
    "Brave", theme_come_of_age,
    "Inside Out", theme_come_of_age,
    "The Good Dinosaur", theme_come_of_age,
    "Finding Dory", theme_come_of_age,

    # Their parents realize nothing is forever
    "Toy Story 2", theme_nothing_forever,
    "Monsters, Inc.", theme_nothing_forever,
    "Finding Nemo", theme_nothing_forever,
    "The Incredibles", theme_nothing_forever,
    "Brave", theme_nothing_forever,
    "Inside Out", theme_nothing_forever,
    "Finding Dory", theme_nothing_forever,

    # Sad music
    "Toy Story 2", theme_sad_music,
    "Finding Nemo", theme_sad_music,
    "Cars", theme_sad_music,
    "WALL-E", theme_sad_music,
    "Up", theme_sad_music,
    "Toy Story 3", theme_sad_music,
    "Inside Out", theme_sad_music,

    # Wacky ensemble
    "Toy Story", theme_wacky_ensemble,
    "Bug's Life", theme_wacky_ensemble,
    "Toy Story 2", theme_wacky_ensemble,
    "Monsters, Inc.", theme_wacky_ensemble,
    "Finding Nemo", theme_wacky_ensemble,
    "The Incredibles", theme_wacky_ensemble,
    "Cars", theme_wacky_ensemble,
    "Up", theme_wacky_ensemble,
    "Toy Story 3", theme_wacky_ensemble,
    "Cars 2", theme_wacky_ensemble,
    "Monsters University", theme_wacky_ensemble,
    "Inside Out", theme_wacky_ensemble,
    "Finding Dory", theme_wacky_ensemble,

    # Everyday objects
    "Toy Story", theme_everyday_objects,
    "Bug's Life", theme_everyday_objects,
    "Toy Story 2", theme_everyday_objects,
    "Monsters, Inc.", theme_everyday_objects,
    "Finding Nemo", theme_everyday_objects,
    "Cars", theme_everyday_objects,
    "Ratatouille", theme_everyday_objects,
    "Toy Story 3", theme_everyday_objects,
    "Cars 2", theme_everyday_objects,
    "Monsters University", theme_everyday_objects,
    "Inside Out", theme_everyday_objects,
    "Finding Dory", theme_everyday_objects,

    # Finds calling
    "Toy Story", theme_finds_calling,
    "Bug's Life", theme_finds_calling,
    "Toy Story 2", theme_finds_calling,
    "Monsters, Inc.", theme_finds_calling,
    "The Incredibles", theme_finds_calling,
    "Cars", theme_finds_calling,
    "Ratatouille", theme_finds_calling,
    "WALL-E", theme_finds_calling,
    "Toy Story 3", theme_finds_calling,
    "Brave", theme_finds_calling,
    "Monsters University", theme_finds_calling,
    "Inside Out", theme_finds_calling,
    "The Good Dinosaur", theme_finds_calling,
    "Finding Dory", theme_finds_calling,

    # Community formed
    "Toy Story", theme_community_formed,
    "Bug's Life", theme_community_formed,
    "Toy Story 2", theme_community_formed,
    "Monsters, Inc", theme_community_formed,
    "Finding Nemo", theme_community_formed,
    "The Incredibles", theme_community_formed,
    "Cars", theme_community_formed,
    "Ratatouille", theme_community_formed,
    "WALL-E", theme_community_formed,
    "Up", theme_community_formed,
    "Toy Story 3", theme_community_formed,
    "Monsters University", theme_community_formed,
    "Inside Out", theme_community_formed,
    "Finding Dory", theme_community_formed,

    # Talking cars
    "Cars", theme_talking_cars,
    "Cars 2", theme_talking_cars
  )


# Get Google Trends data --------------------------------------------------
# WIP

# Google Trends filters on the web interface:
# - United States
# - 2004 - Present
# - Animated Films
# - Web Search
res <- gtrends(
  "Cars",
  # time = "all",
  geo = "US",
  category = 1104  # See data(categories) for other values
)
iot <- res$interest_over_time

iot %>%
  ggplot() + geom_line(aes(x = date,
                           y = hits,
                           color = keyword)) +
  theme_minimal() +
  labs(title = "Zoom vs Slack - in 2020",
       subtitle = "Google Trends Report",
       caption = "Courtesy: gtrendsR package")


# Get rankings ------------------------------------------------------------

# Some rankings are very similarly formatted, so here's a function to do that
get_rankings_standard <- function(link, film_regex=NA) {
  page <- read_html(link)

  if (is.na(film_regex)) {
    film_regex <- regex("^([0-9]{1,2}). ([A-Za-z0-9-’',. ]+?) \\(([0-9]{4,4})\\)$")
  }

  tibble(raw = page %>% html_elements("h2") %>% html_text()) %>%
    mutate(raw = raw %>% trimws() %>% str_replace_all("“|”", "")) %>%
    filter(str_detect(raw, "^[0-9]")) %>%
    mutate(
      ranking = str_extract(raw, film_regex, group = 1),
      film = str_extract(raw, film_regex, group = 2)
    ) %>%
    select(film, ranking)
}


## Get Rotten Tomatoes ranking ----
link <- "https://editorial.rottentomatoes.com/guide/all-pixar-movies-ranked/"
page <- read_html(link)
rotten_tomatoes_ranking <-
  tibble(
    film = page %>%
      html_element(".articleContentBody") %>%
      html_elements(".countdown-item") %>%
      html_elements(".article_movie_title") %>%
      html_text() %>%
      trimws() %>%
      str_replace(" \\([0-9]+\\)\n.*", ""),
    ranking = page %>%
      html_element(".articleContentBody") %>%
      html_elements(".countdown-item") %>%
      html_elements(".countdown-index-resposive") %>%
      html_text() %>%
      str_replace("#", "")
  )


## Get IGN ranking ----
link <- "https://www.ign.com/articles/best-ranking-pixar-movies"
film_regex <- regex("^([0-9]{1,2}). ([A-Za-z0-9-’',. ]+)")
ign_ranking <- get_rankings_standard(link, film_regex)


## Get IndieWire ranking ----
link <- "https://www.indiewire.com/features/best-of/pixar-movies-ranked-best-worst-96815/"
indie_wire_ranking <- get_rankings_standard(link)


## Get Slant ranking ----
link <- "https://www.slantmagazine.com/film/every-pixar-movie-ranked-from-worst-to-best/"
slant_ranking <- get_rankings_standard(link)


## Get Vox ranking ----
link <- "https://www.vox.com/culture/2019/6/27/18715845/pixar-movies-rankings"
vox_ranking <- get_rankings_standard(link)


## Get WIRED ranking ----
link <- "https://www.wired.com/story/best-pixar-movies/"
wired_ranking <- get_rankings_standard(link)


## Get Thrillist ranking ----
# Some reason, the scraping of these movies will fail the regular expression
thrillist_fillin <- tribble(
  ~film, ~ranking,
  "The Good Dinosaur", "20",
  "A Bug's Life", "19",
  "Luca", "17",
  "Onward", "16",
  "Toy Story 3", "5",
  "WALL-E", "2"
)
link <- "https://www.thrillist.com/entertainment/nation/pixar-movies-ranked"
thrillist_ranking <- get_rankings_standard(link)
thrillist_ranking <-
  thrillist_ranking %>%
  filter(!is.na(film)) %>%
  bind_rows(thrillist_fillin) %>%
  mutate(ranking = as.numeric(ranking)) %>%
  arrange(desc(ranking)) %>%
  mutate(ranking = as.character(ranking))


## Get ScreenRant ranking ----
link <- "https://screenrant.com/pixar-movies-ranked-best-worst/"
film_regex <- regex("^([0-9]{1,2}). ([A-Za-z0-9-’',. ]+)")
screenrant_ranking <- get_rankings_standard(link, film_regex)


## Get Polygon ranking ----
link <- "https://www.polygon.com/movies/22239548/best-pixar-movies-ranked"
polygon_ranking <- get_rankings_standard(link)


## Get Buzzfeed ranking ----
link <- "https://www.buzzfeed.com/amatullahshaw/all-pixar-movies-ranked"
film_regex <- regex("^([0-9]{1,2}).[\n ]+([A-Za-z0-9-’',. ]+) ")
buzzfeed_ranking <- get_rankings_standard(link, film_regex)


## Get CNET ranking ----
link <- "https://www.cnet.com/tech/services-and-software/the-best-pixar-movies-ranked-from-inside-out-2-to-toy-story/"
page <- read_html(link)
film_regex <- regex("^([0-9]{1,2}). ([A-Za-z0-9-’',. ]+?) \\(([0-9]{4,4})\\)$")
cnet_ranking <-
  tibble(raw = page %>% html_elements("h3") %>% html_text()) %>%
  mutate(raw = raw %>% trimws() %>% str_replace_all("“|”", "")) %>%
  filter(str_detect(raw, "^[0-9]")) %>%
  # mutate(raw = stringi::stri_encode(raw, to = "UTF-8")) %>%
  mutate(
    ranking = str_extract(raw, film_regex, group = 1),
    film = str_extract(raw, film_regex, group = 2),
  ) %>%
  select(film, ranking)


## TEMP FOR TESTING IF A RANKING SCRAPE FAILS
page <- read_html(link)
# film_regex <- regex("^([0-9]{1,2}). ([A-Za-z0-9-’',. ]+?) \\(([0-9]{4,4})\\)$")
film_regex <- regex("^([0-9]{1,2}).[\n ]+([A-Za-z0-9-’',. ]+) ")
tibble(raw = page %>% html_elements("h2") %>% html_text()) %>%
  mutate(raw = raw %>% trimws() %>% str_replace_all("“|”", "")) %>%
  filter(str_detect(raw, "^[0-9]")) %>%
  # mutate(raw = stringi::stri_encode(raw, to = "UTF-8")) %>%
  mutate(
    ranking = str_extract(raw, film_regex, group = 1),
    film = str_extract(raw, film_regex, group = 2),
    encoding = Encoding(raw)
  )


# Save out data for use ---------------------------------------------------

# Join all data into single, long data frame
# TODO Test and save out accordingly
all_pixar <-
    pixar_films %>%
    inner_join(pixar_people) %>%
    inner_join(academy) %>%
    inner_join(genres) %>%
    inner_join(box_office) %>%
    inner_join(public_response) %>%
    inner_join(theme_vox)

# Save out for external use as CSV files
save_data <- function(x) {
  # Notes on deparse() and substitute()
  # https://stackoverflow.com/a/14577878/6873133
  str_path <- paste0(deparse(substitute(x)), ".csv")
  write_csv(x, here("data-raw", str_path))
}
save_data(pixar_films)
save_data(pixar_people)
save_data(genres)
save_data(box_office)
save_data(public_response)
save_data(academy)

# Save out for package use as RDA files in `data/` directory
use_data(
  pixar_films,
  pixar_people,
  genres,
  box_office,
  public_response,
  academy,
  overwrite = TRUE
)
