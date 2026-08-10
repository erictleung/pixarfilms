# The Multidimensional Success of Pixar Films Visualized

## Overview

This vignette is to recreate an analysis on Pixar ratings that can be
found
[here](https://thelittledataset.com/2015/06/30/the-multidimensional-success-of-pixar-films-visualized/).

## Setup

``` r

library(pixarfilms)
library(dplyr)
#> 
#> Attaching package: 'dplyr'
#> The following objects are masked from 'package:stats':
#> 
#>     filter, lag
#> The following objects are masked from 'package:base':
#> 
#>     intersect, setdiff, setequal, union
library(ggplot2)
library(lubridate)
#> 
#> Attaching package: 'lubridate'
#> The following objects are masked from 'package:base':
#> 
#>     date, intersect, setdiff, union
library(patchwork)
```

## Ratings

### Rotten Tomatoes

``` r

pixar_films %>%
  left_join(public_response) %>%
  left_join(academy) # %>% 
#> Joining with `by = join_by(film)`
#> Joining with `by = join_by(film)`
#> # A tibble: 93 × 24
#>    number film     release_date run_time film_rating plot  rotten_tomatoes_score
#>     <int> <chr>    <date>          <dbl> <chr>       <chr>                 <dbl>
#>  1      1 Toy Sto… 1995-11-22         81 G           "A c…                   100
#>  2      1 Toy Sto… 1995-11-22         81 G           "A c…                   100
#>  3      1 Toy Sto… 1995-11-22         81 G           "A c…                   100
#>  4      1 Toy Sto… 1995-11-22         81 G           "A c…                   100
#>  5      1 Toy Sto… 1995-11-22         81 G           "A c…                   100
#>  6      1 Toy Sto… 1995-11-22         81 G           "A c…                   100
#>  7      2 A Bug's… 1998-11-25         95 G           "A m…                    92
#>  8      2 A Bug's… 1998-11-25         95 G           "A m…                    92
#>  9      2 A Bug's… 1998-11-25         95 G           "A m…                    92
#> 10      3 Toy Sto… 1999-11-24         92 G           "Whe…                   100
#> # ℹ 83 more rows
#> # ℹ 17 more variables: rotten_tomatoes_counts <dbl>, metacritic_score <dbl>,
#> #   metacritic_counts <dbl>, cinema_score <chr>, imdb_score <dbl>,
#> #   imdb_counts <dbl>, rotten_tomatoes_score_top_critics <dbl>,
#> #   rotten_tomatoes_score_top_critics_votes <dbl>,
#> #   rotten_tomatoes_popcorn_meter_score <dbl>,
#> #   rotten_tomatoes_popcorn_meter_votes <dbl>, …
  # mutate(year = year(release_date)
  #        # best = case_when(
  #          
  #        )) %>%
  # ggplot(aes(x = ))
```

### IMDb

### Metacritic

## Session information

``` r

sessionInfo()
#> R version 4.6.1 (2026-06-24)
#> Platform: x86_64-pc-linux-gnu
#> Running under: Ubuntu 24.04.4 LTS
#> 
#> Matrix products: default
#> BLAS:   /usr/lib/x86_64-linux-gnu/openblas-pthread/libblas.so.3 
#> LAPACK: /usr/lib/x86_64-linux-gnu/openblas-pthread/libopenblasp-r0.3.26.so;  LAPACK version 3.12.0
#> 
#> locale:
#>  [1] LC_CTYPE=C.UTF-8       LC_NUMERIC=C           LC_TIME=C.UTF-8       
#>  [4] LC_COLLATE=C.UTF-8     LC_MONETARY=C.UTF-8    LC_MESSAGES=C.UTF-8   
#>  [7] LC_PAPER=C.UTF-8       LC_NAME=C              LC_ADDRESS=C          
#> [10] LC_TELEPHONE=C         LC_MEASUREMENT=C.UTF-8 LC_IDENTIFICATION=C   
#> 
#> time zone: UTC
#> tzcode source: system (glibc)
#> 
#> attached base packages:
#> [1] stats     graphics  grDevices utils     datasets  methods   base     
#> 
#> other attached packages:
#> [1] patchwork_1.3.2  lubridate_1.9.5  ggplot2_4.0.3    dplyr_1.2.1     
#> [5] pixarfilms_0.2.1
#> 
#> loaded via a namespace (and not attached):
#>  [1] gtable_0.3.6       jsonlite_2.0.0     compiler_4.6.1     tidyselect_1.2.1  
#>  [5] jquerylib_0.1.4    systemfonts_1.3.2  scales_1.4.0       textshaping_1.0.5 
#>  [9] yaml_2.3.12        fastmap_1.2.0      R6_2.6.1           generics_0.1.4    
#> [13] knitr_1.51         htmlwidgets_1.6.4  tibble_3.3.1       desc_1.4.3        
#> [17] bslib_0.12.0       pillar_1.11.1      RColorBrewer_1.1-3 rlang_1.3.0       
#> [21] utf8_1.2.6         cachem_1.1.0       xfun_0.60          fs_2.1.0          
#> [25] sass_0.4.10        S7_0.2.2           otel_0.2.0         timechange_0.4.0  
#> [29] cli_3.6.6          withr_3.0.3        pkgdown_2.2.1      magrittr_2.0.5    
#> [33] digest_0.6.39      grid_4.6.1         lifecycle_1.0.5    vctrs_0.7.3       
#> [37] evaluate_1.0.5     glue_1.8.1         farver_2.1.2       ragg_1.5.2        
#> [41] rmarkdown_2.31     tools_4.6.1        pkgconfig_2.0.3    htmltools_0.5.9
```
