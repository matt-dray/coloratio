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
#' @param col_1 Six-digit hex value preceded by '#', or a named color from
#'     \code{\link[grDevices]{colors}}
#' @param col_2 Six-digit hex value preceded by '#', or a named color from
#'     \code{\link[grDevices]{colors}}
#' @param quiet Whether to print warning when the ratio value is lower than 4.5.
#'
#' @return A double.
#' @export
#'
#' @examples cr_get_ratio("#FFFFFF", "white")

cr_get_ratio <- function(col_1, col_2, quiet = FALSE) {

  if(
    (!grepl("^#", col_1) & !col_1 %in% grDevices::colors() |
     !grepl("^#", col_2) & !col_2 %in% grDevices::colors()) |
    (grepl("^#", col_1) & !grepl("^#\\w{6}$", col_1) |
     grepl("^#", col_2) & !grepl("^#\\w{6}$", col_2))
  ) {
    stop("Inputs must match colors() if named, or the hex form #RRGGBB.")
  }

  if (class(quiet) != "logical") {
    stop("Argument 'quiet' must be TRUE or FALSE.")
  }

  # Convert colours to RGB
  d <- t(grDevices::col2rgb(c(col_1, col_2))) / 255

  # Generate sRGB values
  d <- apply(
    d, 2, function(x) ifelse(
      x <= 0.03928, x / 12.92, ((x + 0.055) / 1.055) ^ 2.4
    )
  )

  # Calculate luminance values from RGB
  d <- as.data.frame(d)
  d$L <- (0.2126 * d$red) + (0.7152 * d$green) + (0.0722 * d$blue)

  # Calculate contrast ratio
  d <- d[order(d$L), ]
  cr <- (d[2, "L"] + 0.05) / (d[1, "L"] + 0.05)  # higher value as denominator

  # Warn if contrast threshold not reached
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
#' @param col_bg Background colour on which to overlay text. Six-digit hex value
#'     preceded by '#', or a named color from \code{\link[grDevices]{colors}}.
#'
#' @return A character value: "white" or "black".
#' @export
#'
#' @examples cr_choose_bw("grey90")

cr_choose_bw <- function(col_bg) {

  # Calculate contrast ratios against black and white
  w <- cr_get_ratio(col_bg, "white", quiet = TRUE)
  b <- cr_get_ratio(col_bg, "black", quiet = TRUE)

  # Higher value means higher contrast
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
