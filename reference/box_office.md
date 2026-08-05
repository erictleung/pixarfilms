# Box office reception numbers

A data set with financial and box office gross numbers for each film.

## Usage

``` r
box_office
```

## Format

A data frame with 24 rows and 5 variables:

- film:

  name of film

- budget:

  movie budget in U.S. dollars

- box_office_us_canada:

  box office gross amount in U.S. dollars for U.S. and Canada

- box_office_other:

  box office gross amount in U.S. dollars for other territories

- box_office_worldwide:

  box office gross amount in U.S. dollars worldwide

## Source

<https://en.wikipedia.org/wiki/List_of_Pixar_films>

## Examples

``` r
box_office
#> # A tibble: 28 × 5
#>    film        budget box_office_us_canada box_office_other box_office_worldwide
#>    <chr>        <dbl>                <dbl>            <dbl>                <dbl>
#>  1 Toy Story   3   e7            223225679        171210907            394436586
#>  2 A Bug's Li… 1.20e8            162798565        200460294            363258859
#>  3 Toy Story 2 9   e7            245852179        265506097            511358276
#>  4 Monsters, … 1.15e8            255873250        272900000            528773250
#>  5 Finding Ne… 9.40e7            339714978        531300000            871014978
#>  6 The Incred… 9.2 e7            261441092        370001000            631442092
#>  7 Cars        1.20e8            244082982        217900167            461983149
#>  8 Ratatouille 1.5 e8            206445654        417280431            623726085
#>  9 WALL-E      1.80e8            223808164        297503696            521311860
#> 10 Up          1.75e8            293004164        442094918            735099082
#> # ℹ 18 more rows
```
