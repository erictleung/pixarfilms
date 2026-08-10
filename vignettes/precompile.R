# This script serves to precompile the vignettes to update them
# These vignettes are not built on CRAN, so these occasionally need to be
# updated.

library(knitr)

knit(
  "vignettes/manually_load.Rmd.orig",
  "vignettes/manually_load.Rmd"
)

fs::dir_copy("figure", "vignettes/figure", overwrite = TRUE)
fs::dir_delete("figure")
