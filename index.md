# pixarfilms

> R data package to explore Pixar films, the people, and reception data

This package contains nine data sets provided mostly in part by
[Wikipedia](https://en.wikipedia.org/wiki/List_of_Pixar_films).

Here are a few of them:

- `pixar_films` - released and upcoming films
- `pixar_people` - main people involved in creating films
- `genres` - movie genres for each film
- `box_office` - box office reception and budget information
- `public_response` - critical and public response
- `academy` - academy awards and nominations

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
#> # A tibble: 31 × 6
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
#> # ℹ 21 more rows
```

## Documentation

You can find information about the data sets and more
[here](https://erictleung.com/pixarfilms/). The official CRAN release
page can be found [here](https://cran.r-project.org/package=pixarfilms).
And last, a list of vignettes showcasing some analyses you can do with
this package can be found
[here](https://erictleung.com/pixarfilms/articles/).

## Data

This data here within is not constrained to exploring just within R.

Here are direct links to each data set.

``` R
https://raw.githubusercontent.com/erictleung/pixarfilms/main/data-raw/academy.csv
https://raw.githubusercontent.com/erictleung/pixarfilms/main/data-raw/box_office.csv
https://raw.githubusercontent.com/erictleung/pixarfilms/main/data-raw/genres.csv
https://raw.githubusercontent.com/erictleung/pixarfilms/main/data-raw/pixar_films.csv
https://raw.githubusercontent.com/erictleung/pixarfilms/main/data-raw/pixar_franchises.csv
https://raw.githubusercontent.com/erictleung/pixarfilms/main/data-raw/pixar_people.csv
https://raw.githubusercontent.com/erictleung/pixarfilms/main/data-raw/pixar_rankings.csv
https://raw.githubusercontent.com/erictleung/pixarfilms/main/data-raw/public_response.csv
https://raw.githubusercontent.com/erictleung/pixarfilms/main/data-raw/themes_vox.csv
```

Below is some code to import the data into Python.

``` python
import pandas as pd

pixar_films = pd.read_csv("https://raw.githubusercontent.com/erictleung/pixarfilms/main/data-raw/pixar_films.csv")
academy = pd.read_csv("https://raw.githubusercontent.com/erictleung/pixarfilms/main/data-raw/academy.csv")
box_office = pd.read_csv("https://raw.githubusercontent.com/erictleung/pixarfilms/main/data-raw/box_office.csv")
genres = pd.read_csv("https://raw.githubusercontent.com/erictleung/pixarfilms/main/data-raw/genres.csv")
pixar_franchises = pd.read_csv("https://raw.githubusercontent.com/erictleung/pixarfilms/main/data-raw/pixar_franchises.csv")
pixar_people = pd.read_csv("https://raw.githubusercontent.com/erictleung/pixarfilms/main/data-raw/pixar_people.csv")
pixar_rankings = pd.read_csv("https://raw.githubusercontent.com/erictleung/pixarfilms/main/data-raw/pixar_rankings.csv")
public_response = pd.read_csv("https://raw.githubusercontent.com/erictleung/pixarfilms/main/data-raw/public_response.csv")
themes_vox = pd.read_csv("https://raw.githubusercontent.com/erictleung/pixarfilms/main/data-raw/themes_vox.csv")
```

You can also immediately explore the data using
[here](https://pixarfilms-datasette.vercel.app/) using SQL, thanks to
[Datasette](https://datasette.io/).

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

- [Wikipedia](https://www.wikipedia.org)
- [OMDb API](https://www.omdbapi.com/)
- [babynames](https://github.com/hadley/babynames) (for inspiration)
- [The Numbers](https://www.the-numbers.com/)
- [Box Office Mojo](https://www.boxofficemojo.com/)
