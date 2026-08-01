# Get Pixar film rankings from the internet

# Load libraries
library(rvest)
library(dplyr)
library(readr)
library(progress)
library(here)
library(DBI)
library(RSQLite)


# Get rankings ------------------------------------------------------------

# Some rankings are very similarly formatted, so here's a function to do that
get_rankings_standard <- function(link, film_regex = NA) {
  page <- read_html(link)

  if (is.na(film_regex)) {
    film_regex <-
      regex("^([0-9]{1,2}). ([A-Za-z0-9-’',. ]+?) \\(([0-9]{4,4})\\)$")
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
link <-
  "https://editorial.rottentomatoes.com/guide/all-pixar-movies-ranked/"
page <- read_html(link)
rotten_tomatoes_ranking <-
  tibble(
    source = "Rotten Tomatoes",
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
ign_ranking <- add_source(ign_ranking, "IGN")


## Get IndieWire ranking ----
link <- "https://www.indiewire.com/features/best-of/pixar-movies-ranked-best-worst-96815/"
indie_wire_ranking <- get_rankings_standard(link)
indie_wire_ranking <- add_source(ign_ranking, "IndieWire")


## Get Slant ranking ----
link <- "https://www.slantmagazine.com/film/every-pixar-movie-ranked-from-worst-to-best/"
slant_ranking <- get_rankings_standard(link)
slant_ranking <- add_source(slant_ranking, "Slant")


## Get Vox ranking ----
link <- "https://www.vox.com/culture/2019/6/27/18715845/pixar-movies-rankings"
vox_ranking <- get_rankings_standard(link)
vox_ranking <- add_source(vox_ranking, "Vox")


## Get WIRED ranking ----
link <- "https://www.wired.com/story/best-pixar-movies/"
wired_ranking <- get_rankings_standard(link)
wired_ranking <- add_source(wired_ranking, "WIRED")


## Get Thrillist ranking ----
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
link <- "https://screenrant.com/pixar-movies-ranked-best-worst/"
film_regex <- regex("^([0-9]{1,2}). ([A-Za-z0-9-’',. ]+)")
screenrant_ranking <- get_rankings_standard(link, film_regex)
screenrant_ranking <- add_source(screenrant_ranking, "ScreenRant")


## Get Polygon ranking ----
link <-
  "https://www.polygon.com/movies/22239548/best-pixar-movies-ranked"
polygon_ranking <- get_rankings_standard(link)
polygon_ranking <- add_source(polygon_ranking, "Polygon")


## Get Buzzfeed ranking ----
link <-
  "https://www.buzzfeed.com/amatullahshaw/all-pixar-movies-ranked"
film_regex <- regex("^([0-9]{1,2}).[\n ]+([A-Za-z0-9-’',. ]+) ")
buzzfeed_ranking <- get_rankings_standard(link, film_regex)
buzzfeed_ranking <- add_source(buzzfeed_ranking, "Buzzfeed")


## Get CNET ranking ----
link <-
  "https://www.cnet.com/tech/services-and-software/the-best-pixar-movies-ranked-from-inside-out-2-to-toy-story/"
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
insider_ranking <- add_source(insider_ranking, "Insider")


## Get AV Club ranking ----
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
link <-
  "https://www.vulture.com/article/best-pixar-movies-ranked.html"
film_regex <- regex(
  "([0-9]{1,2}).[\n ]+([A-Za-z0-9-’',. ]+?) \\(([0-9]{4,4})\\)"
)
vulture_ranking <- get_rankings_standard(link, film_regex)
vulture_ranking <-
  vulture_ranking %>%
  mutate(film = trimws(film)) %>%
  add_source("Vulture")


## Get Independent ranking ----
link <-
  "https://www.independent.co.uk/arts-entertainment/films/features/pixar-movies-ranked-list-best-worst-soul-b1777684.html"
page <- read_html(link)
film_regex <- regex("^([0-9]{1,2}). ([A-Za-z0-9-’',. ]+)")
independent_ranking <-
  tibble(
    raw = page %>%
      html_elements("strong") %>%
      html_text()
  ) %>%
  mutate(raw = raw %>% trimws()) %>%
  mutate(
    ranking = str_extract(raw, film_regex, group = 1),
    film = str_extract(raw, film_regex, group = 2),
  ) %>%
  select(film, ranking) %>%
  filter(!is.na(film))
independent_ranking <- add_source(independent_ranking, "Independent")


## Get Forbes ranking ----
link <-
  "https://www.forbes.com/sites/simonthompson/2019/06/24/with-toy-story-4-out-every-pixar-movie-box-office-opening-ranked-worst-to-best/?sh=5e14a401242e"
page <- read_html(link)
film_regex <- regex("^([0-9]{1,2}). ([A-Za-z0-9-’',. ]+) ")
forbes_ranking <-
  tibble(
    raw = page %>%
      html_elements("strong") %>%
      html_text()
  ) %>%
  mutate(raw = raw %>% trimws()) %>%
  filter(str_detect(raw, "^[0-9]")) %>%
  mutate(
    ranking = str_extract(raw, film_regex, group = 1),
    film = str_extract(raw, film_regex, group = 2),
  ) %>%
  select(film, ranking)
forbes_ranking <- add_source(forbes_ranking, "Forbes")


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
    forbes_ranking
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
