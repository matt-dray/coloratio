#' Get Contrast Ratio of Two Colors
#'
#' Calculate the color contrast ratio of two provided colors. Intended as an
#' visual accessibility aid when selecting a text color to place over a single-
#' color background. The output value should be 4.5 or higher to ensure
#' sufficient contrast and readability. This function is currently based on
#' \href{https://www.w3.org/TR/WCAG21/}{WCAG 2.1}. See
#' \href{w3.org/TR/WCAG/#dfn-relative-luminance}{WCAG} for more information
#' about the calculation.
#'
#' @param col1 Hex value preceded by '#' or a named color.
#' @param col2 Hex value preceded by '#' or a named color.
#' @param quiet Whether to print warning when the ratio value is lower than 4.5.
#'
#' @return A double.
#' @export
#'
#' @examples cr_get_ratio("#FFFFFF", "white")

cr_get_ratio <- function(col_1, col_2, quiet = FALSE) {

  if (class(col_1) != "character" | class(col_2) != "character" |
      length(col_1) > 1 | length(col_2) > 1) {
    stop("Color arguments must be single character values (hex or named).")
  }

  if (class(quiet) != "logical") {
    stop("Argument 'quiet' must be TRUE or FALSE.")
  }

  d <- t(col2rgb(c(col_1, col_2))) / 255

  d <- apply(
    d, 2, function(x) ifelse(
      x <= 0.03928, x / 12.92, ((x + 0.055) / 1.055) ^ 2.4
    )
  )

  d <- as.data.frame(d)

  d$L <- (0.2126 * d$red) + (0.7152 * d$green) + (0.0722 * d$blue)

  d <- d[order(d$L), ]

  cr <- (d[2, "L"] + 0.05) / (d[1, "L"] + 0.05)

  if (!quiet & cr <= 4.5) {
    warning("Aim for a value of 4.5 or higher.")
  }

  return(cr)

}

#' Choose White or Black for Text Overlaying Supplied Color
#'
#' Given a background color, what's a better color for overlay text: white or
#' black? Calculated as per \code{\link{cr_get_ratio}}. Defaults to black in the
#' case of a tie.
#'
#' @param col_bg Background colour on which to overlay text. Hex value preceded
#'     by '#' or a named color.
#'
#' @return A character value: "white" or "black".
#' @export
#'
#' @examples cr_choose_bw("grey90")

cr_choose_bw <- function(col_bg) {

  if (class(col_bg) != "character" | length(col_bg) > 1) {
    stop("Color arguments must be single character values (hex or named).")
  }

  w <- cr_get_ratio(col_bg, "white", quiet = TRUE)
  b <- cr_get_ratio(col_bg, "black", quiet = TRUE)

  if (w > b) {
    result <- "white"
  } else if (w < b) {
    result <- "black"
  } else if (w == b) {
    warning("There's a tie. Black chosen.")
    result <- "black"
  }

  return(result)

}
