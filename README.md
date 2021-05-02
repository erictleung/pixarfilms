
<!-- README.md is generated from README.Rmd. Please edit that file. -->

# pixarfilms <img src="man/figures/logo.png" align="right" alt="" width="120" />

<!-- badges: start -->

[![CRAN
status](https://www.r-pkg.org/badges/version/pixarfilms)](https://CRAN.R-project.org/package=pixarfilms)
[![R build
status](https://github.com/erictleung/pixarfilms/workflows/R-CMD-check/badge.svg)](https://github.com/erictleung/pixarfilms/actions)
[![downloads](https://cranlogs.r-pkg.org/badges/pixarfilms)](https://cran.rstudio.com/web/packages/pixarfilms/index.html)
[![total\_downloads](https://cranlogs.r-pkg.org/badges/grand-total/pixarfilms)](https://cran.rstudio.com/web/packages/pixarfilms/index.html)
[![License
CC0](https://img.shields.io/cran/l/pixarfilms)](https://img.shields.io/cran/l/pixarfilms)
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

``` r
# Install from CRAN
install.packages("pixarfilms")

# Install directly from GitHub
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
