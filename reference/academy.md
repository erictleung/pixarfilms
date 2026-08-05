# Pixar Academy awards and nominations

A data set with the awards and nominations of the Academy Awards,
popularly known as the Oscars, each Pixar film has won.

## Usage

``` r
academy
```

## Format

A data frame with 72 rows and 3 variables:

- film:

  name of film

- award_type:

  name of award

- status:

  status of award

## Source

<https://en.wikipedia.org/wiki/List_of_Pixar_films>

## Details

This data set is put into a tidy format, where each row is a film-award
data point.

Some films did not qualify for categories so there is no data for that
film.

## Examples

``` r
academy
#> # A tibble: 88 × 3
#>    film         award_type          status                  
#>    <chr>        <chr>               <chr>                   
#>  1 Toy Story    Animated Feature    Award not yet introduced
#>  2 Toy Story    Original Screenplay Nominated               
#>  3 Toy Story    Adapted Screenplay  Ineligible              
#>  4 Toy Story    Original Score      Nominated               
#>  5 Toy Story    Original Song       Nominated               
#>  6 Toy Story    Other               Won Special Achievement 
#>  7 A Bug's Life Animated Feature    Award not yet introduced
#>  8 A Bug's Life Adapted Screenplay  Ineligible              
#>  9 A Bug's Life Original Score      Nominated               
#> 10 Toy Story 2  Animated Feature    Award not yet introduced
#> # ℹ 78 more rows
```
