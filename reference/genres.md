# Genres describing Pixar films

A data set with the different genre categories for each Pixar film.

## Usage

``` r
genres
```

## Format

A data frame with 204 rows and 3 variables:

- film:

  name of film

- category:

  classification of genre as either "Genre" or "Subgenre"

- value:

  value for genre or subgenre film is categorized as

## Source

<https://www.omdbapi.com/>

## Details

This data set is put into a tidy format, where each row is a film-genre
data point. Each film can have multiple genres. For example, Toy Story
is categorized into three genres. Moreover, Toy Story has five
subgenres.

## Examples

``` r
genres
#> # A tibble: 204 × 3
#>    film         category value               
#>    <chr>        <chr>    <chr>               
#>  1 Toy Story    Genre    Adventure           
#>  2 Toy Story    Genre    Animation           
#>  3 Toy Story    Genre    Comedy              
#>  4 Toy Story    Subgenre Buddy Comedy        
#>  5 Toy Story    Subgenre Computer Animation  
#>  6 Toy Story    Subgenre Fantasy             
#>  7 Toy Story    Subgenre Supernatural Fantasy
#>  8 Toy Story    Subgenre Urban Adventure     
#>  9 A Bug's Life Genre    Adventure           
#> 10 A Bug's Life Genre    Animation           
#> # ℹ 194 more rows
```
