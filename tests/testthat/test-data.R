context("data regression tests")
options(tibble.print_min = 20)

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

test_that("Pixar films head and tail", {
  expect_known_output(
    first_last(pixar_films),
    "test-data_pixar_films.txt",
    print = TRUE
  )
})

test_that("Pixar people head and tail", {
  expect_known_output(
    first_last(pixar_people),
    "test-data_pixar_people.txt",
    print = TRUE
  )
})

test_that("Pixar genres head and tail", {
  expect_known_output(
    first_last(genres),
    "test-data_genres.txt",
    print = TRUE
  )
})

# For too wide of data, the output of tibble makes some long column names
# truncated. These next two tests are testing the same thing but need to be
# split up so that there isn't any issue with comparing the truncation
# character, which is sometimes the tilde character and sometimes an ellipses.
test_that("Pixar box office budget head and fail", {
  expect_known_output(
    first_last(box_office[, c("film", "budget")]),
    "test-data_box_office_budget.txt",
    print = TRUE
  )
})

test_that("Pixar box office numbers head and fail", {
  expect_known_output(
    first_last(box_office[, -2]),
    "test-data_box_office_numbers.txt",
    print = TRUE
  )
})

test_that("Pixar public response head and tail", {
  expect_known_output(
    first_last(public_response),
    "test-data_public_response.txt",
    print = TRUE
  )
})

test_that("Pixar academy head and tail", {
  expect_known_output(
    first_last(academy),
    "test-data_academy.txt",
    print = TRUE
  )
})
