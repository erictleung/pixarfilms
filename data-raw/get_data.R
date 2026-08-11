# Load packages and data --------------------------------------------------
# R version tested: 4.0.4
# Last run: 2021-05-01

# Utility packages
library(here) # CRAN v1.0.2
library(janitor) # CRAN v2.1.0
library(usethis) # CRAN v2.0.1
library(lubridate) # CRAN v1.7.10
library(progress) # CRAN v1.2.2
library(readr) # CRAN v1.4.0
library(stringr) # CRAN v1.4.0

# Data wrangling packages
library(dplyr) # CRAN v1.0.6
library(tibble) # CRAN v3.2.1
library(tidyr) # CRAN v1.1.4
library(fuzzyjoin) # CRAN v0.1.6

# Web scraping
library(rvest) # CRAN v1.0.1
library(httr) # CRAN v1.4.2
library(gtrendsR) # [github::PMassicotte/gtrendsR] v1.5.1.9000
library(RSelenium) # CRAN v1.7.9

# Other analysis
library(votesys) # CRAN v0.1.1
# library(imagick)
# library(imager)
library(ggplot2)

# Extract data ------------------------------------------------------------

page <- read_html("https://en.wikipedia.org/wiki/List_of_Pixar_films")
tbls <- html_table(page, fill = TRUE)

# Extract actual tables
# Note: tbls[[2]] is upcoming films as of [2024-09-30]
# Note: Wikipedia page as of [2024-10-20] has a banner regarding a merge so
#   the table elements will be off by one
banner_offset <- 0 # Off set amount temporary
raw_films <- tbls[[1 + banner_offset]] # Films, release info, top-level people
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
# - Remove random rows and built-in header
# - Remove citations for data because unneeded for our data
# - Remove square brackets from all data
# - Replace TBA with NA
# - Process release date into dates

# Replace first row with row names because writers columns have two rows
colnames(raw_films) <- head(raw_films, 1)
raw_films <- tail(raw_films, nrow(raw_films) - 1)


## pixar_films ----

films <-
  raw_films %>%
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
  mutate(number = row_number()) %>%

  # Polishing
  filter(film != "Film") %>%
  mutate_all(function(x) {
    str_replace_all(x, "\\[[A-Za-z0-9]\\]", "")
  }) %>%
  mutate_all(function(x) {
    ifelse(x == "TBA", NA, x)
  })


# Create tibble table of just films
pixar_films <-
  films %>%
  distinct(film, release_date) %>%
  arrange(release_date) %>%
  mutate(number = row_number()) %>%
  select(number, film, release_date) %>%
  as_tibble()


## pixar_people ----

# Create table of film-people rows
# - Directors
# - Screenwriters
# - Story writer
# - Producer
# - Musician
# Other steps:
# - Remove "Co-directed by:" and other information
# - Fix abbreviation in table
pixar_people <-
  films %>%
  select(-c(number, release_date)) %>%
  pivot_longer(
    cols = -film,
    names_to = "role_type",
    values_to = "name"
  )

# Fix multiple co-directors per film
all_co_directors <-
  pixar_people %>%

  # Get all co-directors and separate them into their own rows
  filter(str_detect(name, "Co-director")) %>%

  # Deal with easier case
  separate_wider_delim(
    name,
    delim = regex("Co-director(s)?:"),
    names = c("directors", "co_director"),
  ) |>

  # Deal with edge cases
  separate_longer_delim(
    co_director,
    delim = regex(" &")
  ) |>
  separate_longer_delim(
    directors,
    delim = regex(" &")
  ) |>

  # Clean up
  select(-role_type) |>
  pivot_longer(
    cols = c(co_director),
    names_to = "role_type",
    values_to = "name"
  )


# Remember the main directors
pixar_people <-
  pixar_people |>
  filter(!str_detect(name, "Co-director")) %>%
  separate_rows(name, sep = "(, ?)|( & ?)") |>

  bind_rows(
    all_co_directors |>
      select(film, role_type, name) |>
      mutate(role_type = "Co-director") |>
      distinct(),
    all_co_directors |>
      select(film, directors) |>
      mutate(role_type = "Director") |>
      rename(name = directors) |>
      select(film, role_type, name) |>
      distinct()
  )


# Fix people using just last names to ensure consistency
# full_names <-
#   pixar_people %>%
#   select(name) %>%
#   filter(str_detect(name, " ")) %>%
#   distinct(name) %>%
#   rename(full_name = name)

# single_names <-
#   pixar_people %>%
#   select(name) %>%
#   filter(!str_detect(name, " ")) %>%
#   distinct(name) %>%
#   rename(short_name = name)

# Create mapping for short names that appear in table
# ci_str_detect <- function(x, y) {
#   # Note space before y is because the last name will have a space before it
#   str_detect(x, regex(str_c(" ", y), ignore_case = TRUE))
# }
# name_map <-
#   full_names %>%
#   fuzzy_left_join(
#     single_names,
#     by = c("full_name" = "short_name"),
#     match_fun = ci_str_detect
#   ) %>%
#   filter(!is.na(short_name))

# NOTE Edge case with multiple people with the same last name
# name_map <-
#   name_map %>%
#   filter(!short_name %in% c("Andrews"))

# Fill in names and address edge case(s) above
# pixar_people <-
#   pixar_people %>%
#   left_join(name_map, by = join_by(name == short_name)) %>%
#   mutate(
#     full_name = case_when(
#       film == "Brave" ~ "Mark Andrews",
#       film == "Luca" ~ "Jesse Andrews",
#       is.na(full_name) ~ name,
#       TRUE ~ full_name
#     )
#   ) %>%
#   select(-name) %>%
#   rename(name = full_name)

# TODO CHECK WHETHER THIS STILL WORKS CORRECTLY
#   separate_rows(name, sep = "(, )|( & )") %>%
#   mutate(name = str_replace(name,
#                             "^.*Co-directed by:",
#                             "")) %>%
#   mutate(name = str_replace(name,
#                             "^.*Original Concept and Development by:",
#                             "")) %>%
#   mutate(name = case_when(
#     name == "Jeff" ~ "Jeff Danna",
#     name == "Lasseter" ~ "John Lasseter",
#     name == "Stanton" ~ "Andrew Stanton",
#     name == "Docter" ~ "Pete Docter",
#     name == "Bird" ~ "Brad Bird",
#     TRUE ~ name
#   )) %>%
#   drop_na(film) %>%  # Remove rows with no movie
#   View()

# Rename role types
pixar_people <-
  pixar_people %>%
  mutate(
    role_type = case_when(
      role_type %in% c("directed_by", "director_s") ~ "Director",
      role_type %in% c("screenplay_by", "screenplay") ~ "Screenwriter",
      role_type %in%
        c("story", "story_by", "writer_s", "writers_s_2") ~ "Storywriter",
      role_type %in% c("music_by", "composer_s") ~ "Musician",
      role_type %in% c("produced_by", "producers", "producer_s") ~ "Producer",
      TRUE ~ role_type
    )
  )

# Reorder for polish
pixar_people <-
  pixar_people %>%
  left_join(pixar_films %>% select(number, film), by = "film") %>%
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
  mutate(
    genre = NA_character_,
    run_time = NA_character_,
    film_rating = NA_character_,
    poster_url = NA_character_,
    plot = NA_character_,
    imdb_rating = NA_character_,
    imdb_votes = NA_character_
  )

pb <- progress_bar$new(total = nrow(raw_genres))
pb$tick(0) # Start progress
for (film in 1:nrow(raw_genres)) {
  # Production use
  # for (film in 1:3) {  # Uncomment use for testing API and logic
  pb$tick()

  # Example:
  # http://www.omdbapi.com/?apikey=<KEY>t=Toy+Story
  query_str <- str_replace_all(raw_genres$film[film], " ", "+")

  # Edge case for WALL-E / WALL·E
  # query_str <- str_replace(query_str, "WALL-E", "WALL·E")
  query_str <- str_replace(query_str, "WALL-E", "WALL%C2%B7E")

  omdb_data <- tryCatch({
    content(GET(url = paste0(omdb_w_key, "t=", query_str)))
  })
  if ("Error" %in% names(omdb_data) | is.null(names(omdb_data))) {
    omdb_data$Genre <- NA_character_
    omdb_data$Runtime <- NA_character_
    omdb_data$Rated <- NA_character_
    omdb_data$Poster <- NA_character_
    omdb_data$Plot <- NA_character_
    omdb_data$imdbRating <- NA_character_
    omdb_data$imdbVotes <- NA_character_
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
  select(
    -c(run_time, poster_url, film_rating, plot, imdb_rating, imdb_votes)
  ) %>%
  separate_rows(genre, sep = ", ") %>%
  drop_na(film) %>%
  mutate(category = "Genre") %>%
  rename(value = genre) %>%
  select(film, category, value)

subgenres <-
  tribble(
    ~film                 , ~raw_genre                                                                                                                          ,
    "Toy Story"           , "Buddy Comedy, Computer Animation, Supernatural Fantasy, Urban Adventure, Adventure, Animation, Comedy, Family, Fantasy"            ,
    # https://www.imdb.com/title/tt0114709/

    "A Bug's Life"        , "Animal Adventure, Computer Animation, Quest, Adventure, Animation, Comedy, Family"                                                 ,
    # https://www.imdb.com/title/tt0120623/

    "Toy Story 2"         , "Computer Animation, Quest, Supernatural Fantasy, Urban Adventure, Adventure, Animation, Comedy, Family, Fantasy"                   ,
    # https://www.imdb.com/title/tt0120363/

    "Monsters, Inc."      , "Buddy Comedy, Computer Animation, Supernatural Fantasy, Urban Adventure, Adventure, Animation, Comedy, Family, Fantasy"            ,
    # https://www.imdb.com/title/tt0198781/

    "Finding Nemo"        , "Animal Adventure, Buddy Comedy, Computer Animation, Quest, Sea Adventure, Adventure, Animation, Comedy, Family"                    ,
    # https://www.imdb.com/title/tt0266543/

    "The Incredibles"     , "Computer Animation, Superhero, Urban Adventure, Action, Adventure, Animation, Family"                                              ,
    # https://www.imdb.com/title/tt0317705/

    "Cars"                , "Computer Animation, Motorsport, Adventure, Animation, Comedy, Family, Sport"                                                       ,
    # https://www.imdb.com/title/tt0317219/?

    "Ratatouille"         , "Animal Adventure, Computer Animation, Adventure, Animation, Comedy, Family, Fantasy"                                               ,
    # https://www.imdb.com/title/tt0382932/?

    "WALL-E"              , "Adventure Epic, Artificial Intelligence, Computer Animation, Dystopian Sci-Fi, Space Sci-Fi, Adventure, Animation, Family, Sci-Fi" ,
    # https://www.imdb.com/title/tt0910970/?

    "Up"                  , "Coming-of-Age, Computer Animation, Globetrotting Adventure, Adventure, Animation, Comedy, Drama, Family"                           ,
    # https://www.imdb.com/title/tt1049413/?

    "Toy Story 3"         , "Computer Animation, Supernatural Fantasy, Urban Adventure, Adventure, Animation, Comedy, Family, Fantasy"                          ,
    # https://www.imdb.com/title/tt0435761/

    "Cars 2"              , "Car Action, Computer Animation, Motorsport, Spy, Adventure, Animation, Comedy, Crime, Family, Sport"                               ,
    # https://www.imdb.com/title/tt1216475/

    "Brave"               , "Coming-of-Age, Computer Animation, Fairy Tale, Quest, Sword & Sorcery, Teen Adventure, Action, Adventure, Animation"               ,
    # https://www.imdb.com/title/tt1217209/

    "Monsters University" , "Computer Animation, Adventure, Animation, Comedy, Family, Fantasy"                                                                 ,
    # https://www.imdb.com/title/tt1453405/

    "Inside Out"          , "Coming-of-Age, Computer Animation, Adventure, Animation, Comedy, Drama, Family, Fantasy"                                           ,
    # https://www.imdb.com/title/tt2096673/

    "The Good Dinosaur"   , "Animal Adventure, Buddy Comedy, Computer Animation, Dinosaur Adventure, Action, Adventure, Animation, Comedy, Drama, Family"       ,
    # https://www.imdb.com/title/tt1979388/

    "Finding Dory"        , "Animal Adventure, Computer Animation, Sea Adventure, Adventure, Animation, Comedy, Family, Fantasy"                                ,
    # https://www.imdb.com/title/tt2277860/

    "Cars 3"              , "Car Action, Computer Animation, Motorsport, Adventure, Animation, Comedy, Family, Sport"                                           ,
    # https://www.imdb.com/title/tt3606752/

    "Coco"                , "Computer Animation, Supernatural Fantasy, Adventure, Animation, Drama, Family, Fantasy, Music, Mystery"                            ,
    # https://www.imdb.com/title/tt2380307/

    "Incredibles 2"       , "Computer Animation, Superhero, Urban Adventure, Action, Adventure, Animation, Comedy, Family, Sci-Fi"                              ,
    # https://www.imdb.com/title/tt3606756/

    "Toy Story 4"         , "Computer Animation, Road Trip, Supernatural Fantasy, Urban Adventure, Adventure, Animation, Comedy, Family, Fantasy"               ,
    # https://www.imdb.com/title/tt1979376/

    "Onward"              , "Computer Animation, Fantasy Epic, Quest, Supernatural Fantasy, Sword & Sorcery, Adventure, Animation, Comedy, Drama, Family"       ,
    # https://www.imdb.com/title/tt7146812/

    "Soul"                , "Computer Animation, Adventure, Animation, Comedy, Drama, Family, Fantasy, Music"                                                   ,
    # https://www.imdb.com/title/tt2948372/

    "Luca"                , "Coming-of-Age, Computer Animation, Fairy Tale, Sea Adventure, Adventure, Animation, Comedy, Drama, Family, Fantasy"                ,
    # https://www.imdb.com/title/tt12801262/

    "Turning Red"         , "Coming-of-Age, Computer Animation, Teen Comedy, Adventure, Animation, Comedy, Drama, Family, Fantasy, Music"                       ,
    # https://www.imdb.com/title/tt8097030/

    "Lightyear"           , "Computer Animation, Space Sci-Fi, Superhero, Time Travel, Action, Adventure, Animation, Comedy, Family, Sci-Fi"                    ,
    # https://www.imdb.com/title/tt10298810/

    "Elemental"           , "Computer Animation, Urban Adventure, Adventure, Animation, Comedy, Family, Fantasy, Romance"                                       ,
    # https://www.imdb.com/title/tt15789038/

    "Inside Out 2"        , "Coming-of-Age, Computer Animation, Quest, Teen Comedy, Teen Drama, Adventure, Animation, Comedy, Drama, Family"                    ,
    # https://www.imdb.com/title/tt22022452/

    "Elio"                , "Alien Invasion, Computer Animation, Space Sci-Fi, Adventure, Animation, Comedy, Drama, Family, Fantasy, Sci-Fi"                    ,
    # https://www.imdb.com/title/tt4900148/

    "Hoppers"             , "Animal Adventure, Body Swap Comedy, Computer Animation, High-Concept Comedy, Spy, Adventure, Animation, Comedy, Family, Sci-Fi"    ,
    # https://www.imdb.com/title/tt26443616/

    "Toy Story 5"         , "Buddy Comedy, Computer Animation, Urban Adventure, Adventure, Animation, Comedy, Drama, Family, Fantasy"
    # https://www.imdb.com/title/tt29355505
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
  select(-c(ref, year)) %>% # 2024-11-10 Rename of column from ref_s -> ref
  rename(
    box_office_us_canada = box_office_gross,
    box_office_other = box_office_gross_2,
    box_office_worldwide = box_office_gross_3
  ) %>%
  mutate(budget = as.numeric(str_extract(budget, "[0-9-]+")) * 1e6) %>%

  # Convert US and Canada box office information
  mutate(
    box_office_us_canada = str_replace_all(
      box_office_us_canada,
      "(\\$)|(,)|(\\[.*\\])",
      ""
    )
  ) %>%
  mutate(
    box_office_us_canada = if_else(
      box_office_us_canada == "N/A",
      NA_character_,
      box_office_us_canada
    )
  ) %>%
  mutate(box_office_us_canada = as.numeric(box_office_us_canada)) %>%

  # Convert other territory information
  mutate(
    box_office_other = str_replace_all(
      box_office_other,
      "(\\$)|(,)|(\\[.*\\])",
      ""
    )
  ) %>%
  mutate(
    box_office_other = if_else(
      box_office_other == "N/A",
      NA_character_,
      box_office_other
    )
  ) %>%
  mutate(box_office_other = as.numeric(box_office_other)) %>%

  # Convert worldwide box office information
  mutate(
    box_office_worldwide = str_replace_all(
      box_office_worldwide,
      "(\\$)|(,)|(\\[.*\\])",
      ""
    )
  ) %>%
  mutate(
    box_office_worldwide = if_else(
      box_office_worldwide == "N/A",
      NA_character_,
      box_office_worldwide
    )
  ) %>%
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
  ~film                 , ~rotten_tomatoes_score_top_critics , ~rotten_tomatoes_score_top_critics_votes , ~rotten_tomatoes_popcorn_meter_score , ~rotten_tomatoes_popcorn_meter_votes , ~rotten_tomatoes_popcorn_meter_verified , ~rotten_tomatoes_popcorn_meter_verified_votes ,
  "Toy Story"           ,                                100 ,                                       55 ,                                   92 ,                               250000 , NA                                      , NA                                            ,
  "A Bug's Life"        ,                                 96 ,                                       25 ,                                   73 ,                               250000 , NA                                      , NA                                            ,
  "Toy Story 2"         ,                                100 ,                                       48 ,                                   87 ,                               250000 , NA                                      , NA                                            ,
  "Monsters, Inc."      ,                                 92 ,                                       50 ,                                   90 ,                               250000 , NA                                      , NA                                            ,
  "Finding Nemo"        ,                                 99 ,                                       67 ,                                   86 ,                               250000 , NA                                      , NA                                            ,
  "The Incredibles"     ,                                 96 ,                                       52 ,                                   75 ,                               250000 , NA                                      , NA                                            ,
  "Cars"                ,                                 73 ,                                       51 ,                                   80 ,                               250000 , NA                                      , NA                                            ,
  "Ratatouille"         ,                                 98 ,                                       61 ,                                   87 ,                               250000 , NA                                      , NA                                            ,
  "WALL-E"              ,                                 97 ,                                       65 ,                                   90 ,                               250000 , NA                                      , NA                                            ,
  "Up"                  ,                                 97 ,                                       69 ,                                   90 ,                               250000 , NA                                      , NA                                            ,
  "Toy Story 3"         ,                                 99 ,                                       71 ,                                   90 ,                               250000 , NA                                      , NA                                            ,
  "Cars 2"              ,                                 42 ,                                       59 ,                                   49 ,                               100000 , NA                                      , NA                                            ,
  "Brave"               ,                                 69 ,                                       62 ,                                   75 ,                               250000 , NA                                      , NA                                            ,
  "Monsters University" ,                                 72 ,                                       56 ,                                   81 ,                               250000 , NA                                      , NA                                            ,
  "Inside Out"          ,                                 99 ,                                       86 ,                                   89 ,                               100000 , NA                                      , NA                                            ,
  "The Good Dinosaur"   ,                                 75 ,                                       55 ,                                   64 ,                                50000 , NA                                      , NA                                            ,
  "Finding Dory"        ,                                 94 ,                                       85 ,                                   84 ,                               100000 , NA                                      , NA                                            ,
  "Cars 3"              ,                                 64 ,                                       55 ,                                   68 ,                                25000 , NA                                      , NA                                            ,
  "Coco"                ,                                 95 ,                                       78 ,                                   94 ,                                25000 , NA                                      , NA                                            ,
  "Incredibles 2"       ,                                 88 ,                                       86 ,                                   84 ,                                10000 , NA                                      , NA                                            ,
  "Toy Story 4"         ,                                 96 ,                                       80 ,                                   94 ,                                50000 ,                                      94 ,                                         50000 ,
  "Onward"              ,                                 78 ,                                       60 ,                                   95 ,                                 5000 ,                                      95 ,                                          5000 ,
  "Soul"                ,                                 89 ,                                       71 ,                                   88 ,                                 5000 , NA                                      , NA                                            ,
  "Luca"                ,                                 90 ,                                       60 ,                                   85 ,                                 2500 , NA                                      , NA                                            ,
  "Turning Red"         ,                                 95 ,                                       57 ,                                   67 ,                                 5000 , NA                                      , NA                                            ,
  "Lightyear"           ,                                 62 ,                                       65 ,                                   84 ,                                 5000 ,                                      84 ,                                          5000 ,
  "Elemental"           ,                                 63 ,                                       57 ,                                   93 ,                                 2500 ,                                      93 ,                                          2500 ,
  "Inside Out 2"        ,                                 89 ,                                       66 ,                                   94 ,                                10000 ,                                      94 ,                                         10000 ,
  "Elio"                ,                                 82 ,                                       45 ,                                   89 ,                                 2500 ,                                      89 ,                                          2500 ,
  "Hoppers"             ,                                 94 ,                                       48 ,                                   93 ,                                 5000 ,                                      93 ,                                          5000 ,
  "Toy Story 5"         ,                                 85 ,                                       59 ,                                   94 ,                                10000 ,                                      94 ,                                         10000
)

# Create data frame and adjust column names because first row is actual name
public_response <- publicresponse
colnames(public_response) <-
  publicresponse |>
  first() |>
  unlist(use.names = FALSE)
public_response <- public_response[-1, ] # Remove redundant column names

# Clean up values
# 2024-11-10 Look's like Critic's Choice got removed
public_response <-
  public_response |>
  clean_names() |>
  mutate_all(function(x) {
    ifelse(x == "—N/a", NA, x)
  }) |>
  mutate(
    rotten_tomatoes = str_replace(rotten_tomatoes, "\\%", ""),
    metacritic = str_replace(metacritic, "\\/100", ""),
    cinema_score = str_replace(cinema_score, "\\[.*\\]", "")
  ) |>
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
      group = 1
    )
  )


# Some of the Cinema Scores use the em-dash instead of a simple dash when
# rating, or at least on Wikipedia. So here let's replace those scores manually
# with simple dashes.
problem_films <- c("Cars 2", "Onward", "Lightyear")
public_response <-
  public_response %>%
  mutate(
    cinema_score = if_else(film %in% problem_films, "A-", cinema_score)
  ) %>%
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

# Letterboxd numbers
letterboxd_audience <- tribble(
  ~film                 , ~letterboxd_rating , ~letterboxd_counts , ~letterboxd_num_fans ,
  "Toy Story"           , 4.1                ,            2663870 ,                17000 ,
  # https://letterboxd.com/film/toy-story/

  "A Bug's Life"        , 3.5                ,             843874 ,                 2400 ,
  # https://letterboxd.com/film/a-bugs-life/

  "Toy Story 2"         , 3.9                ,            1745885 ,                 8100 ,
  # https://letterboxd.com/film/toy-story-2/

  "Monsters, Inc."      , 4.1                ,            2494430 ,                15000 ,
  # https://letterboxd.com/film/monsters-inc/

  "Finding Nemo"        , 4.0                ,            2525019 ,                12000 ,
  # https://letterboxd.com/film/finding-nemo/

  "The Incredibles"     , 4.1                ,            2470115 ,                20000 ,
  # https://letterboxd.com/film/the-incredibles/

  "Cars"                , 3.9                ,            2018334 ,                54000 ,
  # https://letterboxd.com/film/cars/

  "Ratatouille"         , 4.2                ,            3904354 ,                82000 ,
  # https://letterboxd.com/film/ratatouille/

  "WALL-E"              , 4.2                ,            2841436 ,                52000 ,
  # https://letterboxd.com/film/walle/

  "Up"                  , 4.1                ,            3198987 ,                17000 ,
  # https://letterboxd.com/film/up/

  "Toy Story 3"         , 4.1                ,            1854227 ,                14000 ,
  # https://letterboxd.com/film/toy-story-3/

  "Cars 2"              , 3.2                ,            1066794 ,                14000 ,
  # https://letterboxd.com/film/cars-2/

  "Brave"               , 3.5                ,            1343083 ,                 6300 ,
  # https://letterboxd.com/film/brave-2012/

  "Monsters University" , 3.5                ,            1187027 ,                 5500 ,
  # https://letterboxd.com/film/monsters-university/

  "Inside Out"          , 3.8                ,            3345686 ,                13000 ,
  # https://letterboxd.com/film/inside-out-2015/

  "The Good Dinosaur"   , 3.0                ,             451150 ,                  956 ,
  # https://letterboxd.com/film/the-good-dinosaur/

  "Finding Dory"        , 3.3                ,            1143479 ,                  808 ,
  # https://letterboxd.com/film/finding-dory/

  "Cars 3"              , 3.1                ,             692272 ,                 2700 ,
  # https://letterboxd.com/film/cars-3/

  "Coco"                , 4.1                ,            3188686 ,                31000 ,
  # https://letterboxd.com/film/coco-2017/

  "Incredibles 2"       , 3.4                ,            1541325 ,                  754 ,
  # https://letterboxd.com/film/incredibles-2/

  "Toy Story 4"         , 3.3                ,            1399444 ,                  928 ,
  # https://letterboxd.com/film/toy-story-4/

  "Onward"              , 3.3                ,             684325 ,                  949 ,
  # https://letterboxd.com/film/onward-2020/

  "Soul"                , 3.9                ,            2551470 ,                38000 ,
  # https://letterboxd.com/film/soul-2020/

  "Luca"                , 3.7                ,            1499531 ,                 9800 ,
  # https://letterboxd.com/film/luca-2021/

  "Turning Red"         , 3.3                ,            1266320 ,                 2900 ,
  # https://letterboxd.com/film/turning-red/

  "Lightyear"           , 2.7                ,             443123 ,                  121 ,
  # https://letterboxd.com/film/lightyear-2022/

  "Elemental"           , 3.3                ,            1129806 ,                 4000 ,
  # https://letterboxd.com/film/elemental-2023/

  "Inside Out 2"        , 3.5                ,            2826134 ,                 3400 ,
  # https://letterboxd.com/film/inside-out-2-2024/

  "Elio"                , 3.3                ,             306231 ,                  309 ,
  # https://letterboxd.com/film/elio/

  "Hoppers"             , 3.7                ,             906693 ,                 1900 ,
  # https://letterboxd.com/film/hoppers/

  "Toy Story 5"         , 3.7                ,             922617 ,                  691
  # https://letterboxd.com/film/toy-story-5/
)

# Join with Rotten Tomatoes audience meter
public_response <-
  public_response %>%
  left_join(rt_audience, by = "film") |>
  left_join(letterboxd_audience, by = "film")


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
  mutate(
    award_type = case_when(
      award_type == "Sound A" ~ "Sound Editing",
      award_type == "Sound A 2" ~ "Sound Mixing",
      TRUE ~ award_type
    )
  )

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
# https://web.archive.org/web/20260615081252/https://www.vox.com/2015/11/23/9780818/pixar-chart-movies-toy-story-anniversary
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
    ~film                 , ~theme                 ,
    # Mismatched partners
    "Toy Story"           , theme_mismatch         ,
    "Toy Story 2"         , theme_mismatch         ,
    "Monsters, Inc."      , theme_mismatch         ,
    "Finding Nemo"        , theme_mismatch         ,
    "Ratatouille"         , theme_mismatch         ,
    "WALL-E"              , theme_mismatch         ,
    "Up"                  , theme_mismatch         ,
    "Toy Story 3"         , theme_mismatch         ,
    "Cars 2"              , theme_mismatch         ,
    "Brave"               , theme_mismatch         ,
    "Monsters University" , theme_mismatch         ,
    "Inside Out"          , theme_mismatch         ,
    "The Good Dinosaur"   , theme_mismatch         ,
    "Finding Dory"        , theme_mismatch         ,

    # Philosophical differences
    "Toy Story"           , theme_philsophy_diff   ,
    "Toy Story 2"         , theme_philsophy_diff   ,
    "Finding Nemo"        , theme_philsophy_diff   ,
    "Brave"               , theme_philsophy_diff   ,
    "Monsters University" , theme_philsophy_diff   ,
    "Inside Out"          , theme_philsophy_diff   ,
    "The Good Dinosaur"   , theme_philsophy_diff   ,
    "Finding Dory"        , theme_philsophy_diff   ,

    # Wacky journey
    "Toy Story"           , theme_wacky_journey    ,
    "Bug's Life"          , theme_wacky_journey    ,
    "Toy Story 2"         , theme_wacky_journey    ,
    "Monsters, Inc."      , theme_wacky_journey    ,
    "Finding Nemo"        , theme_wacky_journey    ,
    "The Incredibles"     , theme_wacky_journey    ,
    "WALL-E"              , theme_wacky_journey    ,
    "Up"                  , theme_wacky_journey    ,
    "Toy Story 3"         , theme_wacky_journey    ,
    "Cars 2"              , theme_wacky_journey    ,
    "Inside Out"          , theme_wacky_journey    ,
    "The Good Dinosaur"   , theme_wacky_journey    ,
    "Finding Dory"        , theme_wacky_journey    ,

    # A loved one is lost
    "Toy Story 2"         , theme_lost_love        ,
    "Finding Nemo"        , theme_lost_love        ,
    "Ratatouille"         , theme_lost_love        ,
    "WALL-E"              , theme_lost_love        ,
    "Up"                  , theme_lost_love        ,
    "Toy Story 3"         , theme_lost_love        ,
    "Inside Out"          , theme_lost_love        ,
    "The Good Dinosaur"   , theme_lost_love        ,
    "Finding Dory"        , theme_lost_love        ,

    # A child comes of age
    "Toy Story"           , theme_come_of_age      ,
    "Toy Story 2"         , theme_come_of_age      ,
    "Monsters, Inc."      , theme_come_of_age      ,
    "Finding Nemo"        , theme_come_of_age      ,
    "The Incredibles"     , theme_come_of_age      ,
    "Up"                  , theme_come_of_age      ,
    "Toy Story 3"         , theme_come_of_age      ,
    "Brave"               , theme_come_of_age      ,
    "Inside Out"          , theme_come_of_age      ,
    "The Good Dinosaur"   , theme_come_of_age      ,
    "Finding Dory"        , theme_come_of_age      ,

    # Their parents realize nothing is forever
    "Toy Story 2"         , theme_nothing_forever  ,
    "Monsters, Inc."      , theme_nothing_forever  ,
    "Finding Nemo"        , theme_nothing_forever  ,
    "The Incredibles"     , theme_nothing_forever  ,
    "Brave"               , theme_nothing_forever  ,
    "Inside Out"          , theme_nothing_forever  ,
    "Finding Dory"        , theme_nothing_forever  ,

    # Sad music
    "Toy Story 2"         , theme_sad_music        ,
    "Finding Nemo"        , theme_sad_music        ,
    "Cars"                , theme_sad_music        ,
    "WALL-E"              , theme_sad_music        ,
    "Up"                  , theme_sad_music        ,
    "Toy Story 3"         , theme_sad_music        ,
    "Inside Out"          , theme_sad_music        ,

    # Wacky ensemble
    "Toy Story"           , theme_wacky_ensemble   ,
    "Bug's Life"          , theme_wacky_ensemble   ,
    "Toy Story 2"         , theme_wacky_ensemble   ,
    "Monsters, Inc."      , theme_wacky_ensemble   ,
    "Finding Nemo"        , theme_wacky_ensemble   ,
    "The Incredibles"     , theme_wacky_ensemble   ,
    "Cars"                , theme_wacky_ensemble   ,
    "Up"                  , theme_wacky_ensemble   ,
    "Toy Story 3"         , theme_wacky_ensemble   ,
    "Cars 2"              , theme_wacky_ensemble   ,
    "Monsters University" , theme_wacky_ensemble   ,
    "Inside Out"          , theme_wacky_ensemble   ,
    "Finding Dory"        , theme_wacky_ensemble   ,

    # Everyday objects
    "Toy Story"           , theme_everyday_objects ,
    "Bug's Life"          , theme_everyday_objects ,
    "Toy Story 2"         , theme_everyday_objects ,
    "Monsters, Inc."      , theme_everyday_objects ,
    "Finding Nemo"        , theme_everyday_objects ,
    "Cars"                , theme_everyday_objects ,
    "Ratatouille"         , theme_everyday_objects ,
    "Toy Story 3"         , theme_everyday_objects ,
    "Cars 2"              , theme_everyday_objects ,
    "Monsters University" , theme_everyday_objects ,
    "Inside Out"          , theme_everyday_objects ,
    "Finding Dory"        , theme_everyday_objects ,

    # Finds calling
    "Toy Story"           , theme_finds_calling    ,
    "Bug's Life"          , theme_finds_calling    ,
    "Toy Story 2"         , theme_finds_calling    ,
    "Monsters, Inc."      , theme_finds_calling    ,
    "The Incredibles"     , theme_finds_calling    ,
    "Cars"                , theme_finds_calling    ,
    "Ratatouille"         , theme_finds_calling    ,
    "WALL-E"              , theme_finds_calling    ,
    "Toy Story 3"         , theme_finds_calling    ,
    "Brave"               , theme_finds_calling    ,
    "Monsters University" , theme_finds_calling    ,
    "Inside Out"          , theme_finds_calling    ,
    "The Good Dinosaur"   , theme_finds_calling    ,
    "Finding Dory"        , theme_finds_calling    ,

    # Community formed
    "Toy Story"           , theme_community_formed ,
    "Bug's Life"          , theme_community_formed ,
    "Toy Story 2"         , theme_community_formed ,
    "Monsters, Inc"       , theme_community_formed ,
    "Finding Nemo"        , theme_community_formed ,
    "The Incredibles"     , theme_community_formed ,
    "Cars"                , theme_community_formed ,
    "Ratatouille"         , theme_community_formed ,
    "WALL-E"              , theme_community_formed ,
    "Up"                  , theme_community_formed ,
    "Toy Story 3"         , theme_community_formed ,
    "Monsters University" , theme_community_formed ,
    "Inside Out"          , theme_community_formed ,
    "Finding Dory"        , theme_community_formed ,

    # Talking cars
    "Cars"                , theme_talking_cars     ,
    "Cars 2"              , theme_talking_cars
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
  category = 1104 # See data(categories) for other values
)
iot <- res$interest_over_time

iot %>%
  ggplot() +
  geom_line(aes(x = date, y = hits, color = keyword)) +
  theme_minimal() +
  labs(
    title = "Zoom vs Slack - in 2020",
    subtitle = "Google Trends Report",
    caption = "Courtesy: gtrendsR package"
  )


# Get rankings ------------------------------------------------------------

# Some rankings are very similarly formatted, so here's a function to do that
get_rankings_standard <- function(link, film_regex = NA, debug = FALSE) {
  page <- read_html(link)

  if (is.na(film_regex)) {
    film_regex <-
      regex("^([0-9]{1,2}). ([A-Za-z0-9-’',. ]+?) \\(([0-9]{4,4})\\)$")
  }

  if (debug) {
    return(
      tibble(raw = page %>% html_elements("h2") %>% html_text()) %>%
        mutate(raw = raw %>% trimws() %>% str_replace_all("“|”", "")) %>%
        filter(str_detect(raw, "^[0-9]"))
    )
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

# Add source to data
add_source <- function(data, name) {
  data %>%
    mutate(source = {{ name }}) %>%
    select(source, everything())
}


## Get Rotten Tomatoes ranking ----
# Last updated: Toy Story 5
link <-
  "https://editorial.rottentomatoes.com/guide/all-pixar-movies-ranked/"
page <- read_html(link)
rotten_tomatoes_ranking <-
  tibble(
    source = "Rotten Tomatoes",
    film = page %>%
      html_elements(".meta-title") %>%
      html_text() %>%
      trimws() %>%
      str_replace(" \\([0-9]+\\)\n.*", ""),
    ranking = page %>%
      html_elements(".indicator") %>%
      html_text() %>%
      str_replace("#", "")
  )


## Get IGN ranking ----
# Last updated: 2026-03-06
link <- "https://www.ign.com/articles/best-ranking-pixar-movies"
film_regex <- regex("^([0-9]{1,2}). ([A-Za-z0-9-’',. ]+)")
ign_ranking <- get_rankings_standard(link, film_regex)
ign_ranking <- add_source(ign_ranking, "IGN")


## Get IndieWire ranking ----
# Last updated: 2026-06-22
link <- "https://www.indiewire.com/features/best-of/pixar-movies-ranked-best-worst-96815/"
indie_wire_ranking <- get_rankings_standard(link)
indie_wire_ranking <- add_source(ign_ranking, "IndieWire")


## Get Slant ranking ----
# Note: Adblocker, so just manually input for now.
# Last updated:2026-06-16
link <- "https://www.slantmagazine.com/film/every-pixar-movie-ranked-from-worst-to-best/"
# slant_ranking <- get_rankings_standard(link)
# slant_ranking <- add_source(slant_ranking, "Slant")
slant_ranking <-
  tribble(
    ~film                 , ~ranking , ~source ,
    "Cars 2"              , "31"     , "Slant" ,
    "Cars"                , "30"     , "Slant" ,
    "The Good Dinosaur"   , "29"     , "Slant" ,
    "Lightyear"           , "28"     , "Slant" ,
    "Elemental"           , "27"     , "Slant" ,
    "Monsters University" , "26"     , "Slant" ,
    "Cars 3"              , "25"     , "Slant" ,
    "Brave"               , "24"     , "Slant" ,
    "Onward"              , "23"     , "Slant" ,
    "Toy Story 5"         , "22"     , "Slant" ,
    "Hoppers"             , "21"     , "Slant" ,
    "Inside Out 2"        , "20"     , "Slant" ,
    "Turning Red"         , "19"     , "Slant" ,
    "Luca"                , "18"     , "Slant" ,
    "A Bug's Life"        , "17"     , "Slant" ,
    "Incredibles 2"       , "16"     , "Slant" ,
    "Soul"                , "15"     , "Slant" ,
    "Elio"                , "14"     , "Slant" ,
    "Toy Story 4"         , "13"     , "Slant" ,
    "Finding Dory"        , "12"     , "Slant" ,
    "Inside Out"          , "11"     , "Slant" ,
    "Coco"                , "10"     , "Slant" ,
    "Finding Nemo"        , "9"      , "Slant" ,
    "Toy Story 2"         , "8"      , "Slant" ,
    "The Incredibles"     , "7"      , "Slant" ,
    "Toy Story 3"         , "6"      , "Slant" ,
    "WALL-E"              , "5"      , "Slant" ,
    "Toy Story"           , "4"      , "Slant" ,
    "Monsters, Inc."      , "3"      , "Slant" ,
    "Ratatouille"         , "2"      , "Slant" ,
    "Up"                  , "1"      , "Slant"
  ) |>
  select(source, film, ranking)


## Get Vox ranking ----
# Last updated: 2020-12-29
link <- "https://www.vox.com/culture/2019/6/27/18715845/pixar-movies-rankings"
vox_ranking <- get_rankings_standard(link)
vox_ranking <- add_source(vox_ranking, "Vox")


## Get WIRED ranking ----
# Last updated: 2020-04-04
link <- "https://www.wired.com/story/best-pixar-movies/"
wired_ranking <- get_rankings_standard(link)
wired_ranking <- add_source(wired_ranking, "WIRED")


## Get Thrillist ranking ----
# Last updated: 2022-03-11
# Some reason, the scraping of these movies will fail the regular expression
thrillist_fillin <- tribble(
  ~film               , ~ranking ,
  "The Good Dinosaur" , "20"     ,
  "A Bug's Life"      , "19"     ,
  "Luca"              , "17"     ,
  "Onward"            , "16"     ,
  "Toy Story 3"       , "5"      ,
  "WALL-E"            , "2"
)
link <-
  "https://www.thrillist.com/entertainment/nation/pixar-movies-ranked"
thrillist_ranking <- get_rankings_standard(link)
thrillist_ranking <-
  thrillist_ranking %>%
  filter(!is.na(film)) %>%
  bind_rows(thrillist_fillin) %>%
  mutate(ranking = as.numeric(ranking)) %>%
  arrange(desc(ranking)) %>%
  mutate(ranking = as.character(ranking))
thrillist_ranking <- add_source(thrillist_ranking, "Thrillist")


## Get ScreenRant ranking ----
# Last updated: 2026-06-20
link <- "https://screenrant.com/pixar-movies-ranked-every/"
# film_regex <- regex("^([0-9]{1,2}). ([A-Za-z0-9-’',. ]+)")
# screenrant_ranking <- get_rankings_standard(link)
# screenrant_ranking <- add_source(screenrant_ranking, "ScreenRant")
screenrant_ranking <-
  tribble(
    ~film                 , ~ranking , ~source      ,
    "Cars 2"              , "31"     , "ScreenRant" ,
    "Cars 3"              , "30"     , "ScreenRant" ,
    "The Good Dinosaur"   , "29"     , "ScreenRant" ,
    "Lightyear"           , "28"     , "ScreenRant" ,
    "Cars"                , "27"     , "ScreenRant" ,
    "Monsters University" , "26"     , "ScreenRant" ,
    "Elemental"           , "25"     , "ScreenRant" ,
    "Finding Dory"        , "24"     , "ScreenRant" ,
    "Elio"                , "23"     , "ScreenRant" ,
    "Onward"              , "22"     , "ScreenRant" ,
    "Luca"                , "21"     , "ScreenRant" ,
    "A Bug's Life"        , "20"     , "ScreenRant" ,
    "Incredibles 2"       , "19"     , "ScreenRant" ,
    "Brave"               , "18"     , "ScreenRant" ,
    "Hoppers"             , "17"     , "ScreenRant" ,
    "Soul"                , "16"     , "ScreenRant" ,
    "Toy Story 5"         , "15"     , "ScreenRant" ,
    "Turning Red"         , "14"     , "ScreenRant" ,
    "Inside Out 2"        , "13"     , "ScreenRant" ,
    "Toy Story 4"         , "12"     , "ScreenRant" ,
    "Coco"                , "11"     , "ScreenRant" ,
    "Ratatouille"         , "10"     , "ScreenRant" ,
    "Monsters, Inc."      , "9"      , "ScreenRant" ,
    "Finding Nemo"        , "8"      , "ScreenRant" ,
    "Up"                  , "7"      , "ScreenRant" ,
    "Toy Story 2"         , "6"      , "ScreenRant" ,
    "The Incredibles"     , "5"      , "ScreenRant" ,
    "Toy Story 3"         , "4"      , "ScreenRant" ,
    "Inside Out"          , "3"      , "ScreenRant" ,
    "WALL-E"              , "2"      , "ScreenRant" ,
    "Toy Story"           , "1"      , "ScreenRant"
  ) |>
  select(source, film, ranking)


## Get Polygon ranking ----
# Last updated: 2024-06-18
link <-
  "https://www.polygon.com/movies/22239548/best-pixar-movies-ranked"
polygon_ranking <- get_rankings_standard(link)
polygon_ranking <- add_source(polygon_ranking, "Polygon")


## Get Buzzfeed ranking ----
# Last updated: 2021-10-02
link <-
  "https://www.buzzfeed.com/amatullahshaw/all-pixar-movies-ranked"
film_regex <- regex("^([0-9]{1,2}).[\n ]+([A-Za-z0-9-’',. ]+) ")
buzzfeed_ranking <- get_rankings_standard(link, film_regex)
buzzfeed_ranking <- add_source(buzzfeed_ranking, "Buzzfeed")


## Get CNET ranking ----
link <-
  "https://www.cnet.com/culture/entertainment/ranking-pixars-best-films-our-favorite-movies-from-elio-to-toy-story/"
page <- read_html(link)
film_regex <-
  regex("^([0-9]{1,2}). ([A-Za-z0-9-’',. ]+?) \\(([0-9]{4,4})\\)$")
cnet_ranking <-
  tibble(raw = page %>% html_elements("h3") %>% html_text()) %>%
  mutate(raw = raw %>% trimws() %>% str_replace_all("“|”", "")) %>%
  filter(str_detect(raw, "^[0-9]")) %>%
  mutate(
    ranking = str_extract(raw, film_regex, group = 1),
    film = str_extract(raw, film_regex, group = 2),
  ) %>%
  select(film, ranking)
cnet_ranking <- add_source(cnet_ranking, "CNET")


## Get Insider ranking ----
# Last updated: 2023-06-16
link <-
  "https://www.yahoo.com/entertainment/ranked-every-pixar-movie-worst-172845915.html"
page <- read_html(link)
film_regex <-
  regex("^([0-9]{1,2}). [\"']([A-Za-z0-9-’',. ]+?)[\"'] \\(([0-9]{4,4})\\)$")
insider_ranking <-
  tibble(raw = page %>% html_elements("p") %>% html_text()) %>%
  filter(str_detect(raw, "^[0-9]{1,2}\\.")) %>%
  mutate(raw = raw %>% trimws()) %>%
  mutate(
    ranking = str_extract(raw, film_regex, group = 1),
    film = str_extract(raw, film_regex, group = 2),
  ) %>%
  select(film, ranking)
insider_ranking <- add_source(insider_ranking, "BusinessInsider")


## Get AV Club ranking ----
# Last updated: 2024-06-14
link <-
  "https://www.avclub.com/pixar-movies-ranked-from-worst-to-best-1850545587"
page <- read_html(link)
film_regex <- regex("^([0-9]{1,2}). ([A-Za-z0-9-’',. ]+)")
av_club_ranking <-
  tibble(
    raw = page %>%
      html_elements(".jezebel-slideshow__slide_title") %>%
      html_text()
  ) %>%
  filter(str_detect(raw, "^[0-9]{1,2}\\.")) %>%
  mutate(raw = raw %>% trimws()) %>%
  mutate(
    ranking = str_extract(raw, film_regex, group = 1),
    film = str_extract(raw, film_regex, group = 2),
  ) %>%
  select(film, ranking)
av_club_ranking <- add_source(av_club_ranking, "AV Club")


## Get Vulture ranking ----
# Last updated: 2026-06-24
link <-
  "https://web.archive.org/web/20260807081020/https://www.vulture.com/article/best-pixar-movies-ranked.html"
film_regex <- regex("^([0-9]{1,2}).[\n ]+([A-Za-z0-9-’',. ]+)")
vulture_ranking <- get_rankings_standard(link, film_regex)
vulture_ranking <- add_source(vulture_ranking, "Vulture")


## Get Independent ranking ----
# Last updated: 2020-12-23
link <-
  "https://www.the-independent.com/arts-entertainment/films/features/pixar-movies-ranked-list-best-worst-soul-b1777684.html"
# page <- read_html(link)
# film_regex <- regex("^([0-9]{1,2}). ([A-Za-z0-9-’',. ]+)")
# independent_ranking <-
#   tibble(
#     raw = page %>%
#       html_elements("strong") %>%
#       html_text()
#   ) %>%
#   filter(!str_detect(raw, "Director|Runtime|Year"))
#   mutate(raw = raw %>% trimws()) %>%
#   mutate(
#     ranking = str_extract(raw, film_regex, group = 1),
#     film = str_extract(raw, film_regex, group = 2),
#   ) %>%
#   select(film, ranking) %>%
#   filter(!is.na(film))
# independent_ranking <- add_source(independent_ranking, "Independent")
independent_ranking <-
  tribble(
    ~film                 ,
    "Cars 2"              ,
    "Brave"               ,
    "The Good Dinosaur"   ,
    "Cars 3"              ,
    "Toy Story 4"         ,
    "Incredibles 2"       ,
    "A Bug's Life"        ,
    "Monsters University" ,
    "Cars"                ,
    "Finding Dory"        ,
    "Up"                  ,
    "WALL-E"              ,
    "Onward"              ,
    "The Incredibles"     ,
    "Finding Nemo"        ,
    "Inside Out"          ,
    "Coco"                ,
    "Toy Story 3"         ,
    "Soul"                ,
    "Monsters, Inc."      ,
    "Toy Story"           ,
    "Ratatouille"         ,
    "Toy Story 2"
  ) |>
  mutate(
    source = "Independent",
    ranking = as.character(n() + 1 - seq_len(n()))
  ) |>
  select(source, film, ranking)


## Men's Health ranking ----
# Last updated: 2026-04-16
link <- "https://www.menshealth.com/entertainment/g43876294/all-pixar-movies-ranked/"
film_regex <- regex("^([A-Za-z0-9-’',. ]+) \\(([0-9]{4,4})\\)")
page <- read_html(link)
menshealth_ranking <-
  tibble(raw = page %>% html_elements("h2") %>% html_text()) %>%
  mutate(raw = raw %>% trimws() %>% str_replace_all("“|”", "")) |>
  mutate(
    film = str_extract(raw, film_regex, group = 1)
  ) %>%
  mutate(
    film = case_when(
      str_detect(raw, "^WALL") ~ "WALL-E",
      TRUE ~ film
    )
  ) |>
  filter(raw != "Readers Also Read") |>
  select(film) |>
  bind_rows(
    data.frame(
      film = c(
        "Toy Story",
        "Coco",
        "Inside Out",
        "Up",
        "Soul",
        "Toy Story 3"
      )
    )
  ) |>
  mutate(
    source = "MensHealth",
    ranking = as.character(n() + 1 - seq_len(n()))
  ) |>
  select(source, film, ranking)


## Time ranking ----
# Last updated: 2025-06-26
link <- "https://time.com/7296051/pixar-movies-ranked/"
film_regex <- regex("^([0-9]{1,2}).[\n ]+([A-Za-z0-9-’',. ]+) ")
time_ranking <- get_rankings_standard(link, film_regex)
time_ranking <- add_source(time_ranking, "Time")


## Esquire ranking ----
# Last updated: 2026-06-22
link <- "https://www.esquire.com/entertainment/movies/a71628133/pixar-movies-ranked/"
film_regex <- regex("^([0-9]{1,2}).[\n ]+([A-Za-z0-9-’',. ]+) ")
esquire_ranking <- get_rankings_standard(link, film_regex)
esquire_ranking <- add_source(esquire_ranking, "Esquire")


## Mashable ranking ----
# Last updated: 2024-06-14
link <- "https://mashable.com/article/pixar-movies-ranked"
film_regex <- regex("^([0-9]{1,2}).[\n ]+([A-Za-z0-9-’',. ]+)")
mashable_ranking <- get_rankings_standard(link, film_regex)
mashable_ranking <- add_source(mashable_ranking, "Mashable")


## TEMP FOR TESTING IF A RANKING SCRAPE FAILS ----
# page <- read_html(link)
# film_regex <- regex("^([0-9]{1,2}). ([A-Za-z0-9-’',. ]+?) \\(([0-9]{4,4})\\)$")
# film_regex <- regex("^([0-9]{1,2}).[\n ]+([A-Za-z0-9-’',. ]+) ")
# tibble(raw = page %>% html_elements("h2") %>% html_text()) %>%
#   mutate(raw = raw %>% trimws() %>% str_replace_all("“|”", "")) %>%
#   filter(str_detect(raw, "^[0-9]")) %>%
#   # mutate(raw = stringi::stri_encode(raw, to = "UTF-8")) %>%
#   mutate(
#     ranking = str_extract(raw, film_regex, group = 1),
#     film = str_extract(raw, film_regex, group = 2),
#     encoding = Encoding(raw)
#   )

## Join all rankings together ----
pixar_rankings <-
  bind_rows(
    rotten_tomatoes_ranking,
    ign_ranking,
    indie_wire_ranking,
    slant_ranking,
    vox_ranking,
    wired_ranking,
    thrillist_ranking,
    screenrant_ranking,
    polygon_ranking,
    buzzfeed_ranking,
    cnet_ranking,
    insider_ranking,
    av_club_ranking,
    vulture_ranking,
    independent_ranking,
    menshealth_ranking,
    time_ranking,
    esquire_ranking,
    mashable_ranking
  ) %>%
  mutate(
    film = trimws(film),
    ranking = as.numeric(ranking)
  ) %>%
  mutate(
    film = case_when(
      film %in% c("Monsters Inc.", "Monsters, Inc") ~ "Monsters, Inc.",
      film == "Monster’s University" ~ "Monsters University",
      film == "Wall-E" ~ "WALL-E",
      film == "A Bug’s Life" ~ "A Bug's Life",
      film == "The Incredibles 2" ~ "Incredibles 2",
      TRUE ~ film
    )
  ) %>%
  select(film, source, ranking)


# Create franchise data ---------------------------------------------------

# Only some Pixar films are part of a franchise, so this is a mapping of which
# films belong to which franchise.

pixar_franchises <-
  tribble(
    ~film                 , ~franchise        ,
    "Toy Story"           , "Toy Story"       ,
    "Toy Story 2"         , "Toy Story"       ,
    "Monsters, Inc."      , "Monsters, Inc."  ,
    "Finding Nemo"        , "Finding Nemo"    ,
    "The Incredibles"     , "The Incredibles" ,
    "Cars"                , "Cars"            ,
    "Toy Story 3"         , "Toy Story"       ,
    "Cars 2"              , "Cars"            ,
    "Monsters University" , "Monsters, Inc."  ,
    "Inside Out"          , "Inside Out"      ,
    "Finding Dory"        , "Finding Nemo"    ,
    "Cars 3"              , "Cars"            ,
    "Incredibles 2"       , "The Incredibles" ,
    "Toy Story 4"         , "Toy Story"       ,
    "Lightyear"           , "Toy Story"       ,
    "Inside Out 2"        , "Inside Out"      ,
    "Toy Story 5"         , "Toy Story"
  )


# Calculate consensus ranking ---------------------------------------------

# Get each source's ranking and order them
get_film_ranking <- function(data, source) {
  data %>%
    filter(source == {{ source }}) %>%
    arrange(ranking) %>%
    pull(film)
}

raw_rankings <-
  pixar_rankings %>%
  pull(source) %>%
  unique() %>%
  lapply(function(x) {
    pixar_rankings %>%
      filter(source == {{ x }}) %>%
      arrange(ranking) %>%
      pull(film)
  })
vote <- create_vote(raw_rankings, xtype = 3, candidate = pixar_films$film)


## Borda method ----

# In modified Borda, the rule changes. Suppose there are 5 candidates. A voter
# writes down 5 candidates and his 1st choice gets 5 points. The one who gets
# the largest total score wins. However, if the voter only write down 2 names,
# then, his 1st choice gets only 2 points rather than 5 points.
y <- borda_method(vote, modified = TRUE) # Largest total wins
y$other_info$count_max %>%
  data.frame() %>%
  rownames_to_column("film") %>%
  as_tibble() %>%
  rename("score" = ".") %>%
  arrange(desc(score))


## Other methods ----

# Simple
y_simple <- cdc_simple(vote)
y_simple$winner # NULL

# Copeland
# Pairwise comparisons
y_copeland <- cdc_copeland(vote)
y_copeland$other_info$copeland_score %>%
  data.frame() %>%
  rownames_to_column("film") %>%
  as_tibble() %>%
  rename("score" = ".") %>%
  arrange(desc(score))

# Dodgson
# Checks number of votes each film will need to get from others
y_dodgson <- cdc_dodgson(vote)
y_dodgson$other_info$tideman %>%
  data.frame() %>%
  rownames_to_column("film") %>%
  as_tibble() %>%
  rename("score" = ".") %>%
  arrange(score)
y_dodgson$other_info$dodgson_quick %>%
  data.frame() %>%
  rownames_to_column("film") %>%
  as_tibble() %>%
  rename("score" = ".") %>%
  arrange(score)

# Instant-Runoff voting method
# Incremental rounds of removing the least popular film and continuing
y_irv <- irv_method(vote)
y_irv$other_info


# Tropes ------------------------------------------------------------------

parse_tropes <- function(x) {
  # Parse HTML page
  x %>%
    html_element("#main-article") %>%
    html_element("ul") %>%
    html_elements("li") %>%
    html_elements("a.twikilink") %>%
    html_attr("title") %>%
    str_remove("/pmwiki/pmwiki.php/Main/") %>%

    # Convert to tibble to filter and wrangle as data frame
    as_tibble() %>%
    filter(!str_detect(value, "pmwiki")) %>%
    distinct() %>%
    mutate(value = str_replace_all(value, "([A-Z])", " \\1")) %>%
    mutate(
      value = case_when(
        str_detect(value, "C G I") ~ str_replace(value, "C G I", "CGI"),
        str_detect(value, "P O V") ~ str_replace(value, "P O V", "POV"),
        str_detect(value, "B S O D") ~ str_replace(value, "B S O D", "BSoD"),
        TRUE ~ value
      )
    ) %>%
    mutate(value = trimws(value)) %>%
    pull(value)
}


# Vectorize how to construct web pages to scrape
base_trope <- "https://tvtropes.org/pmwiki/pmwiki.php/WesternAnimation/"
tropes_df <-
  pixar_films %>%
  mutate(slug = str_replace_all(film, "[ '-\\.]", "")) %>%
  mutate(
    slug = case_when(
      slug %in% c("ToyStory", "Cars", "TheIncredibles") ~ str_c(slug, "1"),
      slug == "Elemental" ~ str_c(slug, "2023"),
      TRUE ~ slug
    )
  ) %>%
  mutate(url = paste0(base_trope, slug))


all_tropes <- tibble()
for (i in 1:nrow(tropes_df)) {
  tmp_url <- tropes_df[[i, "url"]]
  tmp_tropes <- tmp_url %>%
    read_html() %>%
    parse_tropes()

  tmp_df <- data.frame(film = tropes_df[[i, "film"]], trope = tmp_tropes)
  all_tropes <- bind_rows(all_tropes, tmp_df)

  print(glue::glue("Scraped tropes for {tropes_df[[i, 'film']]}"))
  readline("Press anything to continue: ")
}

# QA
# count(all_tropes, film)

rD <- rsDriver(browser = "firefox", port = 4545L, verbose = F)


# Google Trends data ------------------------------------------------------

# https://datascienceplus.com/analyzing-google-trends-data-in-r/
d <- gtrends(keyword = "Coco (2017 Movie)", geo = "US")

d$interest_over_time %>%
  mutate(hits = ifelse(hits == "<1", "0", hits)) %>%
  mutate(hits = as.integer(hits))


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
save_data(themes_vox)
save_data(pixar_rankings)
save_data(pixar_franchises)

# Save out for package use as RDA files in `data/` directory
# Run just use_data(DATASET) for one-off saves
use_data(
  pixar_films,
  pixar_people,
  genres,
  box_office,
  public_response,
  academy,
  themes_vox,
  pixar_rankings,
  pixar_franchises,
  overwrite = TRUE
)
