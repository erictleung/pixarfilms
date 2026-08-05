# Using pixarfilms with dm

## Overview

The {pixarfilms} R package has been added to the {dm} R package, which
is a package “for working with multiple related tables, stored as data
frames or in a relational database.”

Because all of the tables created in {pixarfilms} are connected by each
film, this gives an interesting opportunity to explore these
interconnected tables together.

## Setup

``` r

library(dm)
#> ! In a coming version, dm will no longer reexport dplyr functions. For best
#>   results, run `library("dplyr")` before `library("dm")`.
#> ℹ To suppress this message unconditionally, set
#>   `options(dm.suppress_dplyr_startup_message = TRUE)`.
#> 
#> Attaching package: 'dm'
#> The following object is masked from 'package:stats':
#> 
#>     filter
library(pixarfilms)
```

## Setup

``` r

# Create dm object
dm <- dm(
  pixar_films,
  pixar_people,
  academy,
  box_office,
  genres,
  public_response
  # pixar_rankings  # Not yet in package
)

# Create primary keys
dm <-
  dm %>%
  dm_add_pk(pixar_films, film) %>%
  dm_add_pk(academy, c(film, award_type)) %>%
  dm_add_pk(box_office, film) %>%
  dm_add_pk(genres, c(film, category, value)) %>%
  # dm_add_pk(pixar_rankings, c(film, source)) %>%
  dm_add_pk(public_response, film)

# Create foreign keys
dm <-
  dm %>%
  dm_add_fk(pixar_people, film, pixar_films) %>%
  dm_add_fk(academy, film, pixar_films) %>%
  dm_add_fk(box_office, film, pixar_films) %>%
  dm_add_fk(genres, film, pixar_films) %>%
  # dm_add_fk(pixar_rankings, film, pixar_films) %>%
  dm_add_fk(public_response, film, pixar_films)

# Add splash of color
dm <-
  dm %>%
  dm_set_colors(
    `#5B9BD5` = pixar_films,
    `#ED7D31` = c(academy, box_office, genres, public_response),
    `#70AD47` = pixar_people
  )
```

## Explore

``` r

dm
#> ── Metadata ────────────────────────────────────────────────────────────────────
#> Tables: `pixar_films`, `pixar_people`, `academy`, `box_office`, `genres`, `public_response`
#> Columns: 28
#> Primary keys: 5
#> Foreign keys: 5
```

``` r

dm %>%
  dm_examine_cardinalities()
#> • FK: pixar_people$(`film`) -> pixar_films$(`film`): surjective mapping (child: 1 to n -> parent: 1)
#> • FK: academy$(`film`) -> pixar_films$(`film`): surjective mapping (child: 1 to n -> parent: 1)
#> • FK: box_office$(`film`) -> pixar_films$(`film`): bijective mapping (child: 1 -> parent: 1)
#> • FK: genres$(`film`) -> pixar_films$(`film`): surjective mapping (child: 1 to n -> parent: 1)
#> • FK: public_response$(`film`) -> pixar_films$(`film`): bijective mapping (child: 1 -> parent: 1)
```

``` r

dm %>%
  dm_examine_constraints()
#> ℹ All constraints satisfied.
```

## System information

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
#> [1] pixarfilms_0.2.1 dm_1.1.2        
#> 
#> loaded via a namespace (and not attached):
#>  [1] jsonlite_2.0.0     dplyr_1.2.1        compiler_4.6.1     Rcpp_1.1.2        
#>  [5] tidyselect_1.2.1   tidyr_1.3.2        DiagrammeR_1.0.12  jquerylib_0.1.4   
#>  [9] systemfonts_1.3.2  textshaping_1.0.5  yaml_2.3.12        fastmap_1.2.0     
#> [13] R6_2.6.1           generics_0.1.4     igraph_2.3.3       curl_7.1.0        
#> [17] knitr_1.51         htmlwidgets_1.6.4  visNetwork_2.1.4   backports_1.5.1   
#> [21] tibble_3.3.1       desc_1.4.3         bslib_0.12.0       pillar_1.11.1     
#> [25] RColorBrewer_1.1-3 rlang_1.3.0        V8_8.2.0           cachem_1.1.0      
#> [29] xfun_0.60          DiagrammeRsvg_0.1  fs_2.1.0           sass_0.4.10       
#> [33] otel_0.2.0         memoise_2.0.1      cli_3.6.6          withr_3.0.3       
#> [37] pkgdown_2.2.1      magrittr_2.0.5     digest_0.6.39      dbplyr_2.6.0      
#> [41] lifecycle_1.0.5    vctrs_0.7.3        evaluate_1.0.5     glue_1.8.1        
#> [45] ragg_1.5.2         rmarkdown_2.31     purrr_1.2.2        tools_4.6.1       
#> [49] pkgconfig_2.0.3    htmltools_0.5.9
```
