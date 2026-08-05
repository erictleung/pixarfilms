# This script serves to precompile the vignettes to update them
# These vignettes are not built on CRAN, so these occasionally need to be
# updated.

library(knitr)

knit(
  "vignettes/pixar_film_ratings.Rmd.orig",
  "vignettes/pixar_film_ratings.Rmd"
)

fs::dir_copy("figure", "vignettes/figure", overwrite = TRUE)
fs::dir_delete("figure")
