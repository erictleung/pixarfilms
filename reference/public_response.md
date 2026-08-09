# Critical and public response

A data set with scores of critical and public response.

## Usage

``` r
public_response
```

## Format

A data frame with 31 rows and 17 columns:

- film:

  name of film

- rotten_tomatoes_score:

  score from the American review-aggregation website Rotten Tomatoes;
  scored out of 100

- rotten_tomatoes_counts:

  number of critics contributing to Rotten Tomatoes score

- metacritic_score:

  score from Metacritic where scores are weighted average of reviews;
  scored out of 100

- metacritic_counts:

  number of critics contributing to Metacritic score

- cinema_score:

  score from market research firm CinemaScore; scored by grades A, B, C,
  D, and F

- imdb_score:

  score from IMDb where scores are weighted average of reviews; scored
  out of 100

- imdb_counts:

  number of critics contributing to IMDb score

- rotten_tomatoes_score_top_critics:

  score for only top critics from Rotten Tomatoes; scored out of 100

- rotten_tomatoes_score_top_critics_votes:

  number of top critics contributing to Rotten Tomatoes score

- rotten_tomatoes_popcorn_meter_score:

  percentage of users who rated this 3.5 stars or higher; scored out of
  100

- rotten_tomatoes_popcorn_meter_votes:

  number of users contributing to the Popcorn Meter score on Rotten
  Tomatoes

- rotten_tomatoes_popcorn_meter_verified:

  percentage of users who made a verified movie ticket purchase rating
  this 3.5 stars or higher

- rotten_tomatoes_popcorn_meter_verified_votes:

  number of users who made a verified movie ticket purchase rating this
  3.5 stars or higher contributing to the Popcorn Meter score on Rotten
  Tomatoes

- letterboxd_rating:

  score from Letterboxd where scores are weighted average of reviews;
  scored out of 5

- letterboxd_counts:

  number of users contributing to Letterboxd score

- letterboxd_fans:

  number of users this film as one of their four favorites on Letterboxd

## Source

<https://en.wikipedia.org/wiki/List_of_Pixar_films>

## Examples

``` r
public_response
#> # A tibble: 31 × 17
#>    film            rotten_tomatoes_score rotten_tomatoes_counts metacritic_score
#>    <chr>                           <dbl>                  <dbl>            <dbl>
#>  1 Toy Story                         100                    163               96
#>  2 A Bug's Life                       92                     90               78
#>  3 Toy Story 2                       100                    176               88
#>  4 Monsters, Inc.                     96                    191               79
#>  5 Finding Nemo                       99                    266               90
#>  6 The Incredibles                    97                    248               90
#>  7 Cars                               74                    198               73
#>  8 Ratatouille                        96                    251               96
#>  9 WALL-E                             95                    258               95
#> 10 Up                                 98                    291               88
#> # ℹ 21 more rows
#> # ℹ 13 more variables: metacritic_counts <dbl>, cinema_score <chr>,
#> #   imdb_score <dbl>, imdb_counts <dbl>,
#> #   rotten_tomatoes_score_top_critics <dbl>,
#> #   rotten_tomatoes_score_top_critics_votes <dbl>,
#> #   rotten_tomatoes_popcorn_meter_score <dbl>,
#> #   rotten_tomatoes_popcorn_meter_votes <dbl>, …
```
