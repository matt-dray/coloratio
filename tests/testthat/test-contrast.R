test_that("cr_get_ratio() expected outputs are returned", {

  expect_type(cr_get_ratio("black", "white"), "double")
  expect_type(cr_get_ratio("black", "white", view = TRUE), "double")

})

test_that("cr_choose_bw() expected outputs are returned", {

  expect_type(cr_choose_bw("black"), "character")
  expect_identical(cr_choose_bw("black"), "white")
  expect_identical(cr_choose_bw("white"), "black")

  expect_type(cr_choose_bw(c("black", "white")), "character")
  expect_identical(cr_choose_bw(c("black", "white")), c("white", "black"))
  expect_length(cr_choose_bw(c("black", "white")), 2)

  expect_type(cr_choose_bw(list("black", "white")), "character")
  expect_identical(cr_choose_bw(list("black", "white")), c("white", "black"))
  expect_length(cr_choose_bw(list("black", "white")), 2)

})

test_that("cr_choose_color() expected outputs are returned", {

  expect_type(cr_choose_color("black"), "character")
  expect_length(cr_choose_color("black", n = 3), 3)
  expect_setequal(
    cr_choose_color("black", n = 3), c("white", "gray100", "grey100")
  )
  expect_setequal(
    cr_choose_color("black", n = 3, ex_bw = TRUE),
    c("ivory", "ivory1", "lightyellow")
  )

})

test_that("cr_view_contrast() expected outputs are returned", {

  expect_silent(cr_view_contrast("black", "white"))  # produces a plot

})

test_that("cr_get_ratio() errors/warnings as expected", {

  expect_error(cr_get_ratio("blurple", "white"))  # not a real color
  expect_error(cr_get_ratio("000000", "white"))  # not preceded by #
  expect_error(cr_get_ratio("black", "white", "gray"))  # too many colors
  expect_error(cr_get_ratio(1, "white"))  # numeric not accepted
  expect_error(cr_get_ratio(TRUE, "white"))  # logical not accepted

  expect_warning(cr_get_ratio("black", "black"))  # low contrast
  expect_silent(cr_get_ratio("black", "black", quiet = TRUE))  # no warning

})

test_that("cr_choose_bw() errors as expected", {

  expect_error(cr_choose_bw("blurple"))  # not a real color
  expect_error(cr_choose_bw("000000"))  # not preceded by #
  expect_error(cr_choose_bw("black", "white"))  # too many colors
  expect_error(cr_choose_bw(1))  # numeric not accepted
  expect_error(cr_choose_bw(TRUE))  # logical not accepted

})

test_that("cr_choose_color() errors as expected", {

  expect_error(cr_choose_color("blurple"))  # not a real color
  expect_error(cr_choose_color("000000"))  # not preceded by #
  expect_error(cr_choose_color("black", "white"))  # too many colors
  expect_error(cr_choose_color(1))  # numeric not accepted
  expect_error(cr_choose_color(TRUE))  # logical not accepted

  expect_error(cr_choose_color("black", n = "x"))  # n must be numeric
  expect_error(cr_choose_color("black", n = -1))  # n must be >=1
  expect_error(cr_choose_color("black", ex_bw = "x"))  # ex_bw must be logical
  expect_error(cr_choose_color("black", ex_bw = 1))  # ex_bw must be logical

})

test_that("cr_view_contrast() errors as expected", {

  expect_error(cr_view_contrast("blurple", "white"))  # not a real color
  expect_error(cr_view_contrast("000000", "white"))  # not preceded by #
  expect_error(cr_view_contrast("black", "white", "gray"))  # too many colors
  expect_error(cr_view_contrast(1, "white"))  # numeric not accepted
  expect_error(cr_view_contrast(TRUE, "white"))  # logical not accepted

})
