library(pdftools)
library(tesseract)
library(stringr)
library(dplyr)

# https://www.scriptslug.com/script/toy-story-1995
toy_story <- "https://www.scriptslug.com/assets/uploads/scripts/toy-story-1995.pdf"

# Process and convert PDF to PNG files to be read
# https://cran.r-project.org/web/packages/tesseract/vignettes/intro.html
eng <- tesseract("eng")
text <- tesseract::ocr(toy_story, engine = eng)


# Inspiration:
# https://github.com/averyrobbins1/appa/blob/master/data-raw/avatar-complete-dataset.R
# Format
# | character | parenthetical | character_words | scene_actions |

save(text, file = "GitHub/pixarfilms/data-raw/text.RData")  # Temporary


# Page 1
