
<!-- README.md is generated from README.Rmd. Please edit that file. -->

# pixarfilms <img src="man/figures/logo.png" align="right" alt="" width="120" />

<!-- badges: start -->

[![CRAN
status](https://www.r-pkg.org/badges/version/pixarfilms)](https://CRAN.R-project.org/package=pixarfilms)
[![R build
status](https://github.com/erictleung/pixarfilms/workflows/R-CMD-check/badge.svg)](https://github.com/erictleung/pixarfilms/actions)
[![downloads](http://cranlogs.r-pkg.org/badges/pixarfilms)](http://cran.rstudio.com/web/packages/pixarfilms/index.html)
<!-- badges: end -->

> R data package to explore Pixar films, the people, and reception data

This package contains six data sets provided mostly in part by
[Wikipedia](https://en.wikipedia.org/wiki/List_of_Pixar_films).

  - `pixar_films` - released and upcoming films
  - `pixar_people` - main people involved in creating films
  - `genres` - movie genres for each film
  - `box_office` - box office reception and budget information
  - `public_response` - critical and public response
  - `academy` - academy awards and nominations

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
#> # A tibble: 27 x 3
#>    number film            release_date
#>    <chr>  <chr>           <date>      
#>  1 1      Toy Story       1995-11-22  
#>  2 2      A Bug's Life    1998-11-25  
#>  3 3      Toy Story 2     1999-11-24  
#>  4 4      Monsters, Inc.  2001-11-02  
#>  5 5      Finding Nemo    2003-05-30  
#>  6 6      The Incredibles 2004-11-05  
#>  7 7      Cars            2006-06-09  
#>  8 8      Ratatouille     2007-06-29  
#>  9 9      WALL-E          2008-06-27  
#> 10 10     Up              2009-05-29  
#> # ... with 17 more rows
```
