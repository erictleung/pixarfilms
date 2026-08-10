# Pixar film rankings

A data set with the rankings of Pixar films from various sources.

## Usage

``` r
pixar_rankings
```

## Format

A data frame with 521 rows and 3 columns:

- film:

  name of film

- source:

  name of internet ranking source

- ranking:

  numerical ranking of the film

## Details

The sources include these websites:

1.  Rotten Tomatoes

2.  IGN

3.  IndieWire

4.  Slant

5.  Vox

6.  WIRED

7.  Thrillist

8.  ScreenRant

9.  Polygon

10. Buzzfeed

11. CNET

12. BusinessInsider

13. AV Club

14. Vulture

15. Independent

16. MensHealth

17. Time

18. Esquire

19. Mashable

## Examples

``` r
pixar_rankings
#> # A tibble: 526 × 3
#>    film            source          ranking
#>    <chr>           <chr>             <dbl>
#>  1 Toy Story 2     Rotten Tomatoes       1
#>  2 Toy Story       Rotten Tomatoes       2
#>  3 Finding Nemo    Rotten Tomatoes       3
#>  4 Inside Out      Rotten Tomatoes       4
#>  5 Toy Story 3     Rotten Tomatoes       5
#>  6 Up              Rotten Tomatoes       6
#>  7 Toy Story 4     Rotten Tomatoes       7
#>  8 Coco            Rotten Tomatoes       8
#>  9 The Incredibles Rotten Tomatoes       9
#> 10 Ratatouille     Rotten Tomatoes      10
#> # ℹ 516 more rows
```
