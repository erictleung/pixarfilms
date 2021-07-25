test_that("Pixar films head and tail", {
  old <- options(tibble.print_min = 20)
  on.exit(options(old))

  # convenience function for getting first and last 10 rows
  # source:
  # https://github.com/hadley/babynames/blob/master/tests/testthat/test-data.R
  first_last <- function(x) {
    n <- nrow(x)
    if (n >= 20) {
      x[c(1:10, (n - 9):n), ]
    } else {
      return(x)
    }
  }

  expect_snapshot(first_last(pixar_films))
  expect_snapshot(first_last(pixar_people))
  expect_snapshot(first_last(genres))

  # Wide data frames truncate large numbers in inconsistent ways
  expect_snapshot(first_last(box_office[, c("film", "budget")]))
  box_office_cols <- c("film", "box_office_us_canada", "box_office_other",
                       "box_office_worldwide")
  expect_snapshot(first_last(box_office[, box_office_cols]))

  expect_snapshot(first_last(public_response))
  expect_snapshot(first_last(academy))
})
