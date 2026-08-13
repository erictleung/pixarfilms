# People behind Pixar

A data set containing the main people involved in each Pixar film.

## Usage

``` r
pixar_people
```

## Format

A data frame with 286 rows and 3 columns:

- film:

  name of film

- role_type:

  one of six roles: Director, Musician, Producer, Screenwriter,
  Storywriter, Co-director

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
#> # A tibble: 286 × 3
#>    film      role_type    name            
#>    <chr>     <chr>        <chr>           
#>  1 Toy Story Director     John Lasseter   
#>  2 Toy Story Musician     Randy Newman    
#>  3 Toy Story Producer     Bonnie Arnold   
#>  4 Toy Story Producer     Ralph Guggenheim
#>  5 Toy Story Screenwriter Joss Whedon     
#>  6 Toy Story Screenwriter Andrew Stanton  
#>  7 Toy Story Screenwriter Joel Cohen      
#>  8 Toy Story Screenwriter Alec Sokolow    
#>  9 Toy Story Storywriter  John Lasseter   
#> 10 Toy Story Storywriter  Pete Docter     
#> # ℹ 276 more rows
unique(pixar_people$role_type)
#> [1] "Director"     "Musician"     "Producer"     "Screenwriter" "Storywriter" 
#> [6] "Co-director" 
```
