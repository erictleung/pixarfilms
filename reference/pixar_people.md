# People behind Pixar

A data set containing the main people involved in each Pixar film.

## Usage

``` r
pixar_people
```

## Format

A data frame with 228 rows and 3 variables:

- film:

  name of film

- role_type:

  one of five roles: Director, Musician, Producer, Screenwriter,
  Storywriter

- name:

  individual's name

## Source

<https://en.wikipedia.org/wiki/List_of_Pixar_films>

## Details

This data set is put into a tidy format, where each row is a film-role
data point. Each film can have multiple individuals per role. For
example, Toy Story has four screenwriters.

## Examples

``` r
pixar_people
#> # A tibble: 260 × 3
#>    film      role_type    name            
#>    <chr>     <chr>        <chr>           
#>  1 Toy Story Director     John Lasseter   
#>  2 Toy Story Musician     Randy Newman    
#>  3 Toy Story Producer     Bonnie Arnold   
#>  4 Toy Story Producer     Ralph Guggenheim
#>  5 Toy Story Screenwriter Joel Cohen      
#>  6 Toy Story Screenwriter Alec Sokolow    
#>  7 Toy Story Screenwriter Andrew Stanton  
#>  8 Toy Story Screenwriter Joss Whedon     
#>  9 Toy Story Storywriter  Pete Docter     
#> 10 Toy Story Storywriter  John Lasseter   
#> # ℹ 250 more rows
```
