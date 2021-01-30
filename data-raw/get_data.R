library(dplyr)
library(rvest)
library(tidyr)
library(usethis)

# Extract data
page <- read_html("https://en.wikipedia.org/wiki/List_of_Pixar_films")
tbls <- html_table(page, fill = TRUE)

# Extract actual tables
films <- tbls[1]  # Films
boxoffice <- tbls[2]  # Box office
publicresponse <- tbls[3]  # Critical and public response
academy <- tbls[4]  # Academy awards
