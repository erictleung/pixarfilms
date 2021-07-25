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
  expect_snapshot(first_last(box_office))
  expect_snapshot(first_last(public_response))
  expect_snapshot(first_last(academy))
})
