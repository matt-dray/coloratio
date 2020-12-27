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
    (grepl("^#", col_1) & !grepl("^#\\w{6}$", col_1) |
     grepl("^#", col_2) & !grepl("^#\\w{6}$", col_2))
  ) {
    stop("Inputs must match colors() if named, or the hex form #RRGGBB.\n")
  }

  if (class(quiet) != "logical") {
    stop("Argument 'quiet' must be TRUE or FALSE.\n")
  }

  # Convert colours to RGB and scale 0 to 1
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

#' Choose White or Black to Overlay a Supplied Underlying Color
#'
#' Given a background color, what's a better color for overlay elements: white
#' or black? Calculated as per \code{\link{cr_get_ratio}}. Defaults to black in
#' the case of a tie.
#'
#' @param col_bg Background colour on which to overlay black or white elements.
#'     Six-digit hex value preceded by '#', or a named color from
#'     \code{\link[grDevices]{colors}}.
#'
#' @return A character value: "white" or "black".
#' @export
#'
#' @examples cr_choose_bw("gray90")

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
    warning("There's a tie. Black chosen.\n")
    result <- "black"
  }

  return(result)

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
#'     \code{\link[grDevices]{colors}}.
#' @param n Number of named colours to return. Color with highest contrast
#'     is returned first.
#' @param ex_bw Exclude black and variants of white and gray variants?
#'
#' @return Character value or vector.
#' @export
#'
#' @examples cr_choose_color("lightyellow")

cr_choose_color <- function(col, n = 1, ex_bw = FALSE) {

  if (!n %in% 1:length(grDevices::colors())) {
    stop(
      "Arg 'n' can't be greater than the number of named colors (657).\n")
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
#' Plots text of one colour on a background of another colour, and vice versa.
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
    (grepl("^#", col_1) & !grepl("^#\\w{6}$", col_1) |
     grepl("^#", col_2) & !grepl("^#\\w{6}$", col_2))
  ) {
    stop("Inputs must match colors() if named, or the hex form #RRGGBB.\n")
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
