#' @importFrom tibble tibble
NULL


#' Pixar films
#'
#' A data set containing Pixar films, their release order, and release date.
#'
#' @format A data frame with 31 rows and 6 columns:
#' \describe{
#'   \item{number}{order of release}
#'   \item{film}{name of film}
#'   \item{release_date}{date film premiered}
#'   \item{run_time}{film length in minutes}
#'   \item{film_rating}{rating based on Motion Picture Association (MPA) film
#'   rating system}
#'   \item{plot}{brief description of the movie plot}
#' }
#' @source \url{https://en.wikipedia.org/wiki/List_of_Pixar_films}
#' @source \url{https://www.omdbapi.com}
#' @examples
#' pixar_films
"pixar_films"


#' People behind Pixar
#'
#' A data set containing the main people involved in each Pixar film.
#'
#' This data set is put into a tidy format, where each row is a film-role data
#' point. Each film can have multiple individuals per role. For example, Toy
#' Story has four screenwriters.
#'
#' @format A data frame with 286 rows and 3 columns:
#' \describe{
#'   \item{film}{name of film}
#'   \item{role_type}{one of six roles: Director, Musician, Producer,
#'     Screenwriter, Storywriter, Co-director}
#'   \item{name}{individual's name}
#' }
#' @source \url{https://en.wikipedia.org/wiki/List_of_Pixar_films}
#' @examples
#' pixar_people
"pixar_people"


#' Genres describing Pixar films
#'
#' A data set with the different genre categories for each Pixar film.
#'
#' This data set is put into a tidy format, where each row is a film-genre data
#' point. Each film can have multiple genres. For example, Toy Story is
#' categorized into three genres. Moreover, Toy Story has five subgenres.
#'
#' @format A data frame with 204 rows and 3 variables:
#' \describe{
#'   \item{film}{name of film}
#'   \item{category}{classification of genre as either "Genre" or "Subgenre"}
#'   \item{value}{value for genre or subgenre film is categorized as}
#' }
#' @source \url{https://www.omdbapi.com/}
#' @examples
#' genres
"genres"


#' Box office reception numbers
#'
#' A data set with financial and box office gross numbers for each film.
#'
#' @format A data frame with 24 rows and 5 variables:
#' \describe{
#'   \item{film}{name of film}
#'   \item{budget}{movie budget in U.S. dollars}
#'   \item{box_office_us_canada}{box office gross amount in U.S. dollars for
#'     U.S. and Canada}
#'   \item{box_office_other}{box office gross amount in U.S. dollars for other
#'     territories}
#'   \item{box_office_worldwide}{box office gross amount in U.S. dollars
#'     worldwide}
#' }
#' @source \url{https://en.wikipedia.org/wiki/List_of_Pixar_films}
#' @examples
#' box_office
"box_office"


#' Critical and public response
#'
#' A data set with scores of critical and public response.
#'
#' @format A data frame with 31 rows and 17 columns:
#' \describe{
#'   \item{film}{name of film}
#'   \item{rotten_tomatoes_score}{score from the American review-aggregation
#'     website Rotten Tomatoes; scored out of 100}
#'   \item{rotten_tomatoes_counts}{number of critics contributing to Rotten
#'     Tomatoes score}
#'   \item{metacritic_score}{score from Metacritic where scores are weighted
#'     average of reviews; scored out of 100}
#'   \item{metacritic_counts}{number of critics contributing to Metacritic
#'     score}
#'   \item{cinema_score}{score from market research firm CinemaScore; scored by
#'     grades A, B, C, D, and F}
#'   \item{imdb_score}{score from IMDb where scores are weighted average of
#'     reviews; scored out of 100}
#'   \item{imdb_counts}{number of critics contributing to IMDb score}
#'   \item{rotten_tomatoes_score_top_critics}{score for only top critics from
#'     Rotten Tomatoes; scored out of 100}
#'   \item{rotten_tomatoes_score_top_critics_votes}{number of top critics
#'     contributing to Rotten Tomatoes score}
#'   \item{rotten_tomatoes_popcorn_meter_score}{percentage of users who rated
#      this 3.5 stars or higher; scored out of 100}
#'   \item{rotten_tomatoes_popcorn_meter_votes}{number of users contributing to
#'     Rotten Tomatoes'}
#'   \item{rotten_tomatoes_popcorn_meter_verified}{percentage of users who made
#'     a verified movie ticket purchase rating this 3.5 stars or higher}
#'   \item{rotten_tomatoes_popcorn_meter_votes}{number of users contributing to
#'     Rotten Tomatoes' Popcorn Meter}
#'   \item{letterboxd_rating}{score from Letterboxd where scores are weighted
#'     average of reviews; scored out of 5}
#'   \item{letterboxd_counts}{number of users contributing to Letterboxd score}
#'   \item{letterboxd_fans}{number of users this film as one of their four
#'     favorites on Letterboxd}
#' }
#' @source \url{https://en.wikipedia.org/wiki/List_of_Pixar_films}
#' @examples
#' public_response
"public_response"


#' Pixar Academy awards and nominations
#'
#' A data set with the awards and nominations of the Academy Awards, popularly
#' known as the Oscars, each Pixar film has won.
#'
#' This data set is put into a tidy format, where each row is a film-award data
#' point.
#'
#' Some films did not qualify for categories so there is no data for that film.
#'
#' @format A data frame with 72 rows and 3 variables:
#' \describe{
#'   \item{film}{name of film}
#'   \item{award_type}{name of award}
#'   \item{status}{status of award}
#' }
#' @source \url{https://en.wikipedia.org/wiki/List_of_Pixar_films}
#' @examples
#' academy
"academy"


#' Themes in Pixar films by Vox
#'
#' A data set with the themes in Pixar films as described by Vox.
#'
#' @format A data frame with 124 rows and 2 columns:
#' \describe{
#'   \item{film}{name of film}
#'   \item{theme}{theme in film}
#' }
#' @source \url{https://www.vox.com/2015/11/23/9780818/pixar-chart-movies-toy-story-anniversary}
#' @examples
#' themes_vox
'themes_vox'


#' Pixar film rankings
#'
#' A data set with the rankings of Pixar films from various sources.
#'
#' The sources include these websites:
#'
#' \enumerate{
#'   \item Rotten Tomatoes
#'   \item IGN
#'   \item IndieWire
#'   \item Slant
#'   \item Vox
#'   \item WIRED
#'   \item Thrillist
#'   \item ScreenRant
#'   \item Polygon
#'   \item Buzzfeed
#'   \item CNET
#'   \item BusinessInsider
#'   \item AV Club
#'   \item Vulture
#'   \item Independent
#'   \item MensHealth
#'   \item Time
#'   \item Esquire
#'   \item Mashable
#' }
#'
#' @format A data frame with 521 rows and 3 columns:
#' \describe{
#'   \item{film}{name of film}
#'   \item{source}{name of internet ranking source}
#'   \item{ranking}{numerical ranking of the film}
#' }
#' @examples
#' pixar_rankings
'pixar_rankings'


#' Pixar film franchises
#'
#' A data set with the Pixar films that are part of a franchise and the name of
#' the franchise.
#'
#' Note, not all Pixar films are part of a franchise. For example, "A Bug's
#' Life" is not part of a franchise, but "Toy Story 2" is part of the "Toy Story"
#' franchise.
#'
#' @format A data frame with 17 rows and 2 columns:
#' \describe{
#'   \item{film}{name of film}
#'   \item{franchise}{name of franchise the film is part of}
#' }
#' @examples
#' pixar_franchises
'pixar_franchises'
