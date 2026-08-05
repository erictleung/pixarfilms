# Pixar films

A data set containing Pixar films, their release order, and release
date.

## Usage

``` r
pixar_films
```

## Format

A data frame with 27 rows and 3 variables:

- number:

  order of release

- film:

  name of film

- release_date:

  date film premiered

- run_time:

  film length in minutes

- film_rating:

  rating based on Motion Picture Association (MPA) film rating system

- plot:

  brief description of the movie plot

## Source

<https://en.wikipedia.org/wiki/List_of_Pixar_films>

<https://www.omdbapi.com>

## Examples

``` r
pixar_films
#> # A tibble: 28 × 6
#>    number film            release_date run_time film_rating plot                
#>     <int> <chr>           <date>          <dbl> <chr>       <chr>               
#>  1      1 Toy Story       1995-11-22         81 G           "A cowboy doll is p…
#>  2      2 A Bug's Life    1998-11-25         95 G           "A misfit ant, look…
#>  3      3 Toy Story 2     1999-11-24         92 G           "When Woody is stol…
#>  4      4 Monsters, Inc.  2001-11-02         92 G           "In order to power …
#>  5      5 Finding Nemo    2003-05-30        100 G           "After his son is c…
#>  6      6 The Incredibles 2004-11-05        115 PG          "While trying to le…
#>  7      7 Cars            2006-06-09        116 G           "On the way to the …
#>  8      8 Ratatouille     2007-06-29        111 G           "A rat who can cook…
#>  9      9 WALL-E          2008-06-27         98 G           "A robot who is res…
#> 10     10 Up              2009-05-29         96 PG          "78-year-old Carl F…
#> # ℹ 18 more rows
```
