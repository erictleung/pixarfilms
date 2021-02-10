#' @importFrom tibble tibble
NULL


#' Pixar films
#'
#' A data set containing Pixar films, their release order, and release date.
#'
#' @format A data frame with 27 rows and 3 variables:
#' \describe{
#'   \item{number}{order of release}
#'   \item{film}{name of film}
#'   \item{release_date}{date film premiered}
#' }
#' @source \url{https://en.wikipedia.org/wiki/List_of_Pixar_films}
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
#' @format A data frame with 228 rows and 3 variables:
#' \describe{
#'   \item{film}{name of film}
#'   \item{role_type}{one of five roles: Director, Musician, Producer,
#'     Screenwriter, Storywriter}
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
#' categorized into five genres.
#'
#' @format A data frame with 128 rows and 2 variables:
#' \describe{
#'   \item{film}{name of film}
#'   \item{genre}{genre film is categorized into}
#' }
#' @source \url{https://www.omdbapi.com/}
#' @examples
#' genres
"genres"


#' Box office reception numbers
#'
#' A data set with financial and box office gross numbers for each film.
#'
#' @format A data frame with 23 rows and 5 variables:
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
#' @format A data frame with 23 rows and 5 variables:
#' \describe{
#'   \item{film}{name of film}
#'   \item{rotten_tomatoes}{score from the American review-aggregation website
#'     Rotten Tomatoes; scored out of 100}
#'   \item{metacritic}{score from Metacritic where scores are weighted average
#'     of reviews; scored out of 100}
#'   \item{cinema_score}{score from market research firm CinemaScore; scored by
#'     grades A, B, C, D, and F}
#'   \item{critics_choice}{score from Critics' Choice Movie Awards presented by
#'     the American-Canadian Critics Choice Association (CCA); scored out of
#'     100}
#' }
#' @source \url{https://en.wikipedia.org/wiki/List_of_Pixar_films}
#' @examples
#' public_response
"public_response"


#' Pixar awards and nominations
#'
#' A data set with the awards and nominations each Pixar film has won.
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
