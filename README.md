
<!-- README.md is generated from README.Rmd. Please edit that file. -->

# pixarfilms <img src="man/figures/logo.png" align="right" alt="" width="120" />

<!-- badges: start -->

[![CRAN
status](https://www.r-pkg.org/badges/version/pixarfilms)](https://CRAN.R-project.org/package=pixarfilms)
[![R build
status](https://github.com/erictleung/pixarfilms/workflows/R-CMD-check/badge.svg)](https://github.com/erictleung/pixarfilms/actions)
[![downloads](https://cranlogs.r-pkg.org/badges/pixarfilms)](https://cran.r-project.org/package=pixarfilms)
[![total\_downloads](https://cranlogs.r-pkg.org/badges/grand-total/pixarfilms)](https://cran.r-project.org/package=pixarfilms)
[![frictionless](https://github.com/erictleung/pixarfilms/actions/workflows/frictionless.yml/badge.svg)](https://github.com/erictleung/pixarfilms/actions/workflows/frictionless.yml)
[![License
CC0](https://img.shields.io/cran/l/pixarfilms)](https://img.shields.io/cran/l/pixarfilms)
[![Project Type Toy
Badge](https://img.shields.io/badge/project%20type-toy-blue)](https://project-types.github.io/#toy)
<!-- badges: end -->

> R data package to explore Pixar films, the people, and reception data

This package contains six data sets provided mostly in part by
[Wikipedia](https://en.wikipedia.org/wiki/List_of_Pixar_films).

-   `pixar_films` - released and upcoming films
-   `pixar_people` - main people involved in creating films
-   `genres` - movie genres for each film
-   `box_office` - box office reception and budget information
-   `public_response` - critical and public response
-   `academy` - academy awards and nominations

Feel free to [explore the data
immediately](https://pixarfilms-datasette.herokuapp.com/pixarfilms) in
your web browser using [datasette](https://github.com/simonw/datasette)
and SQL.

## Installation

Install `pixarfilms` from CRAN:

``` r
install.packages("pixarfilms")
```

Or you can install the development version of `pixarfilms` from GitHub
with:

``` r
remotes::install_github("erictleung/pixarfilms")
```

## Example

``` r
library(pixarfilms)
pixar_films
#> # A tibble: 27 x 5
#>    number film            release_date run_time film_rating
#>    <chr>  <chr>           <date>          <dbl> <chr>      
#>  1 1      Toy Story       1995-11-22         81 G          
#>  2 2      A Bug's Life    1998-11-25         95 G          
#>  3 3      Toy Story 2     1999-11-24         92 G          
#>  4 4      Monsters, Inc.  2001-11-02         92 G          
#>  5 5      Finding Nemo    2003-05-30        100 G          
#>  6 6      The Incredibles 2004-11-05        115 PG         
#>  7 7      Cars            2006-06-09        117 G          
#>  8 8      Ratatouille     2007-06-29        111 G          
#>  9 9      WALL-E          2008-06-27         98 G          
#> 10 10     Up              2009-05-29         96 PG         
#> # ... with 17 more rows
```

## Documentation

You can find information about the data sets and more
[here](https://erictleung.com/pixarfilms/). The official CRAN release page can
be found [here](https://cran.r-project.org/package=pixarfilms). And last, a
list of vignettes showcasing some analyses you can do with this package can be
found [here](https://erictleung.com/pixarfilms/articles/).

## Data

This data here within is not constrained to exploring just within R.

Here are other accessible means of using this data.

-   Through [your
    browser](https://pixarfilms-datasette.herokuapp.com/pixarfilms)
    using datasette and a SQLite database (located at
    `/data-raw/pixarfilms.db`).
-   Through CSV files found within the `data-raw/` directory.

Here are direct links to each data set.

    https://raw.githubusercontent.com/erictleung/pixarfilms/main/data-raw/academy.csv
    https://raw.githubusercontent.com/erictleung/pixarfilms/main/data-raw/box_office.csv
    https://raw.githubusercontent.com/erictleung/pixarfilms/main/data-raw/genres.csv
    https://raw.githubusercontent.com/erictleung/pixarfilms/main/data-raw/pixar_films.csv
    https://raw.githubusercontent.com/erictleung/pixarfilms/main/data-raw/pixar_people.csv
    https://raw.githubusercontent.com/erictleung/pixarfilms/main/data-raw/public_response.csv

There’s also a `datapackage.json` file (located at
`/data-raw/datapackage.json`) to be a computer-readable data dictionary
describing the contents of each data file as described in [the data
package
specifications](https://specs.frictionlessdata.io/data-package/).

## Feedback

If you have any feedback or suggestions on other data that can be added,
please file an issue
[here](https://github.com/erictleung/pixarfilms/issues).

## Code of Conduct

Please note that the {pixarfilms} project is released with a
[Contributor Code of
Conduct](https://contributor-covenant.org/version/2/0/CODE_OF_CONDUCT.html).
By contributing to this project, you agree to abide by its terms.

## Acknowledgments

-   [Wikipedia](https://www.wikipedia.org)
-   [OMDb API](https://www.omdbapi.com/)
-   [babynames](https://github.com/hadley/babynames) (for inspiration)
