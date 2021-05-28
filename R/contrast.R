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
#' @param view Whether to plot a demonstration of col_1 text on a col_2
#'     background, and vice versa, for visual inspection. Uses
#'     \code{\link{cr_view_contrast}}.
#'
#' @return A double.
#' @export
#'
#' @examples cr_get_ratio("#FFFFFF", "white")

cr_get_ratio <- function(col_1, col_2, quiet = FALSE, view = FALSE) {

  if(
    (!grepl("^#", col_1) & !col_1 %in% grDevices::colors() |
     !grepl("^#", col_2) & !col_2 %in% grDevices::colors()) |
    (grepl("^#", col_1) & !grepl("^#[0-9a-fA-F]{6}$", col_1) |
     grepl("^#", col_2) & !grepl("^#[0-9a-fA-F]{6}$", col_2))
  ) {
    stop('Inputs must be in colors() if named, or of the hex form "#RRGGBB".\n')
  }

  if (class(quiet) != "logical") {
    stop("Argument 'quiet' must be TRUE or FALSE.\n")
  }

  # Convert colous to RGB and scale 0 to 1
  d <- t(grDevices::col2rgb(c(col_1, col_2))) / 255

  # Convert value
  d <- apply(
    d, 2, function(x) ifelse(
      x <= 0.03928, x / 12.92, ((x + 0.055) / 1.055) ^ 2.4
    )
  )

  # Calculate luminance values
  d <- as.data.frame(d)
  d$L <- (0.2126 * d$red) + (0.7152 * d$green) + (0.0722 * d$blue)

  # Calculate contrast ratio
  d <- d[order(d$L), ]
  cr <- (d[2, "L"] + 0.05) / (d[1, "L"] + 0.05)

  # Warn if contrast threshold not reached
  if (!quiet & cr <= 4.5) {
    warning("Aim for a value of 4.5 or higher.\n")
  }

  # Plot contrast samples
  if (view) {
    cr_view_contrast(col_1, col_2)
  }

  return(cr)

}

#' Choose White or Black to Overlay On a Supplied Background Color
#'
#' Selects whether black or white has the greater contrast with a user-
#' supplied color. Useful for choosing a text color to overlay on a block-color
#' background, like value labels over the bars of a bar chart. Calculated as per
#' \code{\link{cr_get_ratio}}. Defaults to black in the case of a tie.
#'
#' @param col_bg A character vector of colors against which to select either
#'     black or white, whichever has maximum contrast. Supply colors as
#'     six-digit hex values preceded by '#', or named colors from
#'     \code{\link[grDevices]{colors}}.
#'
#' @return A character vector of values "black" or "white". The length matches
#'     the input.
#'
#' @export
#'
#' @examples cr_choose_bw(c("white", "gray90", "gray50", "gray10", "black"))

cr_choose_bw <- function(col_bg) {

  # Choose "black" or "white" for each element of col_bg, return vector
  vapply(
    col_bg,
    .choose_bw_one,
    character(1),
    USE.NAMES = FALSE
  )

}

#' Choose a High-Contrast Color for a Given Color
#'
#' Given a user-supplied color, what's a good color to pair it with for maximum
#' contrast? Compares provided color against all named R colors, as per
#' \code{\link[grDevices]{colors}}. Contrast calculated as per
#' \code{\link{cr_get_ratio}}.
#'
#' @param col A character value representing a color. Can be a six-digit hex
#'     value preceded by '#', or a named color from
#' @param n Number of named colors to return. Color with highest contrast
#'     is returned first.
#' @param ex_bw Exclude black and variants of white and gray variants?
#'
#' @return A character value that's a named R color.
#' @export
#'
#' @examples cr_choose_color("lightyellow")

cr_choose_color <- function(col, n = 1, ex_bw = FALSE) {

  if (class(n) != "numeric" | n < 1) {
    stop("'n' must be a positive numeric value.\n")
  }

  if (class(ex_bw) != "logical") {
    stop("Argument 'ex_bw' must be TRUE or FALSE.\n")
  }

  # Calculate all contrast ratios against the named colors
  ratios <- sapply(
    grDevices::colors(),
    function(x) cr_get_ratio(x, col, quiet = TRUE)
  )

  # Get the name of the result with the highest ratio
  if (!ex_bw) {
    result <- names(ratios[order(-ratios)][1:n])
  } else if (ex_bw) {
    bw_regex <-  "black|white|grey|gray"
    ratios_ex_bw <- ratios[!grepl(bw_regex, names(ratios))]
    result <- names(ratios_ex_bw[order(-ratios_ex_bw)][1:n])
  }

  return(result)

}

#' Plot a Demo of User-Supplied Color Pair
#'
#' Plots text of one color on a background of another color, and vice versa.
#' Used to visualise contrasts.
#'
#' @param col_1 Six-digit hex value preceded by '#', or a named color from
#'     \code{\link[grDevices]{colors}}.
#' @param col_2 Six-digit hex value preceded by '#', or a named color from
#'     \code{\link[grDevices]{colors}}.
#'
#' @return Character value or vector.
#' @export
#'
#' @examples cr_view_contrast("yellow", "black")

cr_view_contrast <- function(col_1, col_2) {

  if(
    (!grepl("^#", col_1) & !col_1 %in% grDevices::colors() |
     !grepl("^#", col_2) & !col_2 %in% grDevices::colors()) |
    (grepl("^#", col_1) & !grepl("^#[0-9a-fA-F]{6}$", col_1) |
     grepl("^#", col_2) & !grepl("^#[0-9a-fA-F]{6}$", col_2))
  ) {
    stop('Inputs must be in colors() if named, or of the hex form "#RRGGBB".\n')
  }

  # Reduce plot margins
  graphics::par(mar = rep(1, 4))

  # Plot stacked bar
  graphics::barplot(
    matrix(c(1, 1)),
    col = c(col_2, col_1),
    border = "white",
    yaxt = "n"
  )

  # Add overlaying text
  graphics::text(0.7, 0.5, paste(col_1, "\non", col_2), col = col_1, cex = 3)
  graphics::text(0.7, 1.5, paste(col_2, "\non", col_1), col = col_2, cex = 3)

}
