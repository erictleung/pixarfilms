# Exploration of Pixar Films Rankings

``` r

library(pixarfilms)
library(ggplot2)
library(dplyr)
#> 
#> Attaching package: 'dplyr'
#> The following objects are masked from 'package:stats':
#> 
#>     filter, lag
#> The following objects are masked from 'package:base':
#> 
#>     intersect, setdiff, setequal, union
library(forcats)
library(gghighlight)
```

## Distribution of rankings

``` r

pixar_rankings |>
  mutate(film = fct_reorder(film, ranking, .fun = median, .desc = TRUE)) |>
  ggplot(aes(x = film, y = ranking)) +
  geom_boxplot(fill = "#89B9F7") +
  coord_flip() +
  labs(
    title = "Distribution of Pixar Films rankings",
    subtitle = "Ordered by median ranking",
    x = "Film",
    y = "Ranking"
  ) +
  theme_bw()
```

![](pixar_rankings_files/figure-html/unnamed-chunk-2-1.png)

``` r


# Save out for presentation use
# ggsave(
#   here::here("vignettes", "pixar_rankings.png"),
#   width = 8,
#   height = 5
# )
```

## Highlighting variation in rankings

A couple of things we notice from the boxplot above are that some films
have a low variance in their rankings, while others have a higher
variance. We can calculate the standard deviation of the rankings for
each film to see which films have the lowest variance.

``` r

summary_ranks <-
  pixar_rankings |>
  group_by(film) |>
  summarize(
    sd = sd(ranking),
    q1 = quantile(ranking, 0.25),
    q3 = quantile(ranking, 0.75),
    iqr = IQR(ranking),
    lower_bound = q1 - 1.5 * iqr,
    upper_bound = q3 + 1.5 * iqr
  ) |>
  arrange(sd)
print(summary_ranks)
#> # A tibble: 32 × 7
#>    film             sd    q1    q3   iqr lower_bound upper_bound
#>    <chr>         <dbl> <dbl> <dbl> <dbl>       <dbl>       <dbl>
#>  1 Toy Story      1.99  2      4    2          -1            7  
#>  2 NA             2.83  2      4    2          -1            7  
#>  3 Inside Out     2.97  4.25   8    3.75       -1.38        13.6
#>  4 Finding Nemo   3.02  3      8    5          -4.5         15.5
#>  5 Luca           3.20 14.8   19.5  4.75        7.62        26.6
#>  6 Cars 2         3.30 24     29    5          16.5         36.5
#>  7 Incredibles 2  3.39 15.2   20    4.75        8.12        27.1
#>  8 Toy Story 3    3.49  4      6    2           1            9  
#>  9 Coco           3.66  7     11    4           1           17  
#> 10 Ratatouille    3.78  4     10.5  6.5        -5.75        20.2
#> # ℹ 22 more rows
```

We can see that Toy Story, NA, Inside Out, Finding Nemo, Luca, Cars 2
have the lowest variance in their rankings. We can highlight these films
in the boxplot above to see how they compare to the other films.

``` r

pixar_rankings |>
  mutate(film = fct_reorder(film, ranking, .fun = median, .desc = TRUE)) |>
  ggplot(aes(x = film, y = ranking)) +
  geom_boxplot(fill = "#89B9F7") +
  coord_flip() +
  gghighlight(
    film %in% pull(head(arrange(summary_ranks, sd), 3), film),
    use_group_by = FALSE
  ) +
  labs(
    title = "Lowest variation of Pixar Films rankings",
    subtitle = "Ordered by median ranking",
    x = "Film",
    y = "Ranking"
  ) +
  theme_bw()
```

![](pixar_rankings_files/figure-html/unnamed-chunk-4-1.png)

``` r


# Save out for presentation use
# ggsave(
#   here::here("vignettes", "pixar_rankings.png"),
#   width = 8,
#   height = 5
# )
```

We can also see that Toy Story, NA, Toy Story 3, Inside Out, Coco have
the smallest IQR ranges in their rankings. We can highlight these films
in the boxplot above to see how they compare to the other films.

``` r

pixar_rankings |>
  mutate(film = fct_reorder(film, ranking, .fun = median, .desc = TRUE)) |>
  ggplot(aes(x = film, y = ranking)) +
  geom_boxplot(fill = "#89B9F7") +
  coord_flip() +
  gghighlight(
    film %in% pull(head(arrange(summary_ranks, iqr), 3), film),
    use_group_by = FALSE
  ) +
  labs(
    title = "Smallest IQRs of Pixar Films rankings",
    subtitle = "Ordered by median ranking",
    x = "Film",
    y = "Ranking"
  ) +
  theme_bw()
```

![](pixar_rankings_files/figure-html/unnamed-chunk-5-1.png)

``` r


# Save out for presentation use
# ggsave(
#   here::here("vignettes", "pixar_rankings.png"),
#   width = 8,
#   height = 5
# )
```

Now let’s highlight the highest variation in rankings. We can see that
Soul, Elemental, Cars, A Bug’s Life, Toy Story 4 have the highest
variance in their rankings. We can highlight these films in the boxplot
above to see how they compare to the other films.

``` r

pixar_rankings |>
  mutate(film = fct_reorder(film, ranking, .fun = median, .desc = TRUE)) |>
  ggplot(aes(x = film, y = ranking)) +
  geom_boxplot(fill = "#89B9F7") +
  coord_flip() +
  gghighlight(
    film %in% pull(head(arrange(summary_ranks, desc(sd)), 3), film),
    use_group_by = FALSE
  ) +
  labs(
    title = "Highest variation of Pixar Films rankings",
    subtitle = "Ordered by median ranking",
    x = "Film",
    y = "Ranking"
  ) +
  theme_bw()
```

![](pixar_rankings_files/figure-html/unnamed-chunk-6-1.png)

``` r


# Save out for presentation use
# ggsave(
#   here::here("vignettes", "pixar_rankings.png"),
#   width = 8,
#   height = 5
# )
```

Now let’s highlight the outliers in the rankings.

``` r

outlier_films <-
  pixar_rankings |>
  left_join(summary_ranks, by = "film") |>
  filter(ranking < lower_bound | ranking > upper_bound) |>
  distinct(film)

pixar_rankings |>
  mutate(film = fct_reorder(film, ranking, .fun = median, .desc = TRUE)) |>
  ggplot(aes(x = film, y = ranking)) +
  geom_boxplot(fill = "#89B9F7") +
  coord_flip() +
  gghighlight(
    film %in% outlier_films$film,
    use_group_by = FALSE
  ) +
  labs(
    title = "Pixar Films rankings with outliers",
    subtitle = "Ordered by median ranking",
    x = "Film",
    y = "Ranking"
  ) +
  theme_bw()
```

![](pixar_rankings_files/figure-html/unnamed-chunk-7-1.png)

``` r


# Save out for presentation use
# ggsave(
#   here::here("vignettes", "pixar_rankings.png"),
#   width = 8,
#   height = 5
# )
```
