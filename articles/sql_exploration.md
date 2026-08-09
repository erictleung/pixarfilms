# SQL Tutorial and Exploration

## Overview

This vignette aims to be a brief introduction and overview of using SQL.
The tutorial will illustrate common functions by answering questions
around Pixar films and their performance.

## Setup

Load packages.

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
library(dbplyr)
#> 
#> Attaching package: 'dbplyr'
#> The following objects are masked from 'package:dplyr':
#> 
#>     ident, sql, sql_escape_ident, sql_escape_string
```

Load data into temporary database to interact with.

``` r

con <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
copy_to(con, pixar_films)
```

## Top movies

Develop query.

``` r

query <- "
select * from pixar_films
"
```

Let’s execute it now.

``` r

DBI::dbGetQuery(conn = con, statement = query)
#>    number                film release_date run_time film_rating
#> 1       1           Toy Story         9456       81           G
#> 2       2        A Bug's Life        10555       95           G
#> 3       3         Toy Story 2        10919       92           G
#> 4       4      Monsters, Inc.        11628       92           G
#> 5       5        Finding Nemo        12202      100           G
#> 6       6     The Incredibles        12727      115          PG
#> 7       7                Cars        13308      116           G
#> 8       8         Ratatouille        13693      111           G
#> 9       9              WALL-E        14057       98           G
#> 10     10                  Up        14393       96          PG
#> 11     11         Toy Story 3        14778      103           G
#> 12     12              Cars 2        15149      106           G
#> 13     13               Brave        15513       93          PG
#> 14     14 Monsters University        15877      104           G
#> 15     15          Inside Out        16605       95          PG
#> 16     16   The Good Dinosaur        16764       93          PG
#> 17     17        Finding Dory        16969       97          PG
#> 18     18              Cars 3        17333      102           G
#> 19     19                Coco        17492      105          PG
#> 20     20       Incredibles 2        17697      118          PG
#> 21     21         Toy Story 4        18068      100           G
#> 22     22              Onward        18327      102          PG
#> 23     23                Soul        18621      100          PG
#> 24     24                Luca        18796       95          PG
#> 25     25         Turning Red        19062      100          PG
#> 26     26           Lightyear        19160      105          PG
#> 27     27           Elemental        19524      101          PG
#> 28     28        Inside Out 2        19888       96          PG
#> 29     29                Elio        20259       98          PG
#> 30     30             Hoppers        20518      104          PG
#> 31     31         Toy Story 5        20623      102          PG
#>                                                                                                                                                                                                                                         plot
#> 1    A cowboy doll is profoundly jealous when a new spaceman action figure supplants him as the top toy in a boy's bedroom. When circumstances separate them from their owner, the duo have to put aside their differences to return to him.
#> 2                                                                                     A misfit ant, looking for "warriors" to save his colony from greedy grasshoppers, recruits a group of bugs that turn out to be an inept circus troupe.
#> 3                                    When Woody is stolen by a toy collector, Buzz and his friends set out on a rescue mission to save Woody before he becomes a museum toy property with his roundup gang Jessie, Prospector, and Bullseye.
#> 4                  In order to power the city, monsters have to scare children so that they scream. However, the children are toxic to the monsters, and after a child gets through, two monsters realize things may not be what they think.
#> 5                                                                                                        After his son is captured in the Great Barrier Reef and taken to Sydney, a timid clownfish sets out on a journey to bring him home.
#> 6                                                                                                                   While trying to lead a quiet suburban life, a family of undercover superheroes are forced into action to save the world.
#> 7                                                                                    On the way to the biggest race of his life, a hotshot rookie race car gets stranded in a rundown town and learns that winning isn't everything in life.
#> 8                                                                                                                                     A rat who can cook makes an unusual alliance with a young kitchen worker at a famous Paris restaurant.
#> 9                                                     A robot who is responsible for cleaning a waste-covered Earth meets another robot and falls in love with her. Together, they set out on a journey that will alter the fate of mankind.
#> 10                                                                                                         78-year-old Carl Fredricksen travels to South America in his house equipped with balloons, inadvertently taking a young stowaway.
#> 11                         The toys are mistakenly delivered to a day-care center instead of the attic right before Andy leaves for college, and it's up to Woody to convince the other toys that they weren't abandoned and to return home.
#> 12 Star race car Lightning McQueen and his pal Mater head overseas to compete in the World Grand Prix race. But the road to the championship becomes rocky as Mater gets caught up in an intriguing adventure of his own: international e...
#> 13                              Determined to make her own path in life, Princess Merida defies a custom that brings chaos to her kingdom. Granted one wish, Merida must rely on her bravery and her archery skills to undo a beastly curse.
#> 14                                                               A look at the relationship between Mike Wazowski and James P. "Sully" Sullivan during their days at Monsters University, when they weren't necessarily the best of friends.
#> 15                                     After young Riley is uprooted from her Midwest life and moved to San Francisco, her emotions, Joy, Fear, Anger, Disgust, and Sadness, conflict on how best to navigate a new city, house, and school.
#> 16                                                                                                                        In a world where dinosaurs and humans live side-by-side, an Apatosaurus named Arlo makes an unlikely human friend.
#> 17                                                                          Friendly but forgetful blue tang Dory begins a search for her long-lost parents and everyone learns a few things about the real meaning of family along the way.
#> 18                                                                                                                         Lightning McQueen sets out to prove to a new generation of racers that he's still the best race car in the world.
#> 19                                                                       Aspiring musician Miguel, confronted with his family's ancestral ban on music, enters the Land of the Dead to find his great-great-grandfather, a legendary singer.
#> 20                                      The Incredibles family takes on a new mission which involves a change in family roles: Bob Parr (Mr. Incredible) must manage the house while his wife Helen (Elastigirl) goes out to save the world.
#> 21                                                                  When Woody, Buzz, and the gang join Bonnie on a road trip with her new craft project turned toy, Forky, the innocent little spork's antics launch Woody on a wild quest.
#> 22        Teenage elf brothers Ian and Barley embark on a magical quest to spend one more day with their late father. Like any good adventure, their journey is filled with cryptic maps, impossible obstacles and unimaginable discoveries.
#> 23    Joe is a middle-school band teacher whose life hasn't quite gone the way he expected. His true passion is jazz. But when he travels to another realm to help someone find their passion, he soon discovers what it means to have soul.
#> 24                                                                                                             On the Italian Riviera, an unlikely but strong friendship grows between a human being and a sea monster disguised as a human.
#> 25 A thirteen-year-old girl named Mei Lee is torn between staying her mother's dutiful daughter and the changes of adolescence. And as if the challenges were not enough, whenever she gets overly excited Mei transforms into a giant re...
#> 26                                     While spending years attempting to return home, marooned Space Ranger Buzz Lightyear encounters an army of ruthless robots commanded by Zurg who are attempting to steal the fuel source of his ship.
#> 27                                                                                                                                                          Follow Ember and Wade, in a city where fire, water, earth and air live together.
#> 28            A sequel that features Riley entering puberty and experiencing brand new, more complex emotions as a result. As Riley tries to adapt to her teenage years, her old emotions try to adapt to the possibility of being replaced.
#> 29 Elio, a space fanatic with an active imagination, finds himself on a cosmic misadventure where he must form new bonds with alien lifeforms, navigate a crisis of intergalactic proportions and somehow discover who he is truly meant ...
#> 30                                                                       A 19-year-old animal lover uses technology that places her consciousness into a robotic beaver to uncover mysteries within the animal world beyond her imagination.
#> 31                                                                                                      Woody, Buzz, Jessie and the rest of the gang's jobs are challenged when they're introduced to electronics, a new threat to playtime.
```

## 

## Summary

Here, let’s review the functions of SQL covered above.

- `SELECT` = text that follows this chooses the columns you want in your
  query, and doing `SELECT *` will select all columns

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
#> [1] dbplyr_2.6.0     dplyr_1.2.1      pixarfilms_0.2.1
#> 
#> loaded via a namespace (and not attached):
#>  [1] bit_4.6.0         jsonlite_2.0.0    compiler_4.6.1    tidyselect_1.2.1 
#>  [5] blob_1.3.0        jquerylib_0.1.4   systemfonts_1.3.2 textshaping_1.0.5
#>  [9] yaml_2.3.12       fastmap_1.2.0     R6_2.6.1          generics_0.1.4   
#> [13] knitr_1.51        htmlwidgets_1.6.4 tibble_3.3.1      desc_1.4.3       
#> [17] DBI_1.3.0         bslib_0.12.0      pillar_1.11.1     rlang_1.3.0      
#> [21] cachem_1.1.0      xfun_0.60         fs_2.1.0          sass_0.4.10      
#> [25] bit64_4.8.2       otel_0.2.0        RSQLite_3.53.3    memoise_2.0.1    
#> [29] cli_3.6.6         pkgdown_2.2.1     magrittr_2.0.5    digest_0.6.39    
#> [33] lifecycle_1.0.5   vctrs_0.7.3       evaluate_1.0.5    glue_1.8.1       
#> [37] ragg_1.5.2        rmarkdown_2.31    tools_4.6.1       pkgconfig_2.0.3  
#> [41] htmltools_0.5.9
```
