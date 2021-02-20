context("data regression tests")

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

test_that("Pixar box office head and tail", {
  expect_known_output(
    first_last(box_office),
    "test-data_box_office.txt",
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
