#' Get contrast ratio of two colours
#'
#' Calculate the colour contrast ratio of two provided colours. Intended as an
#' visual accessibility aid when selecting a text colour to place over a block-
#' coloured background. The output value should be 4.5 or higher to ensure
#' sufficient contrast and readability. This function is currently based on
#' \href{https://www.w3.org/TR/WCAG21/}{WCAG 2.1}. See
#' \href{w3.org/TR/WCAG/#dfn-relative-luminance}{WCAG} for more information
#' about the calculation.
#'
#' @param col1 Hex value preceded by '#' or a named colour.
#' @param col2 Hex value preceded by '#' or a named colour.
#' @param quiet Whether to print warning when the ratio value is lower than 4.5.
#'
#' @return A double.
#' @export
#'
#' @examples get_ratio("#FFFFFF", "white")

get_ratio <- function(col1, col2, quiet = FALSE) {

  d <- t(col2rgb(c(col1, col2))) / 255

  d <- apply(
    d, 2,
    function(x) ifelse(x <= 0.03928, x / 12.92, ((x + 0.055) / 1.055) ^ 2.4)
  )

  d <- as.data.frame(d)

  d$L <- (0.2126 * d$red) + (0.7152 * d$green) + (0.0722 * d$blue)

  d <- d[order(d$L), ]

  cr <- (d[2, "L"] + 0.05) / (d[1, "L"] + 0.05)

  if (!quiet & cr <= 4.5) {
    warning("You should aim for a contrast ratio value of 4.5 or more.\n")
  }

  return(cr)

}
