# Critical and public response

A data set with scores of critical and public response.

## Usage

``` r
public_response
```

## Format

A data frame with 23 rows and 5 variables:

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

## Source

<https://en.wikipedia.org/wiki/List_of_Pixar_films>

## Examples

``` r
public_response
#> # A tibble: 28 × 8
#>    film            rotten_tomatoes_score rotten_tomatoes_counts metacritic_score
#>    <chr>                           <dbl>                  <dbl>            <dbl>
#>  1 Toy Story                         100                     96               95
#>  2 A Bug's Life                       92                     91               78
#>  3 Toy Story 2                       100                    172               88
#>  4 Monsters, Inc.                     96                    199               79
#>  5 Finding Nemo                       99                    270               90
#>  6 The Incredibles                    97                    250               90
#>  7 Cars                               75                    204               73
#>  8 Ratatouille                        96                    253               96
#>  9 WALL-E                             95                    261               95
#> 10 Up                                 98                    297               88
#> # ℹ 18 more rows
#> # ℹ 4 more variables: metacritic_counts <dbl>, cinema_score <chr>,
#> #   imdb_score <dbl>, imdb_counts <dbl>
```
