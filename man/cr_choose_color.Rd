% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/contrast.R
\name{cr_choose_color}
\alias{cr_choose_color}
\title{Choose a High-Contrast Color for a Given Color}
\usage{
cr_choose_color(col, n = 1, ex_bw = FALSE)
}
\arguments{
\item{col}{A character value representing a color. Can be a six-digit hex
value preceded by '#', or a named color from}

\item{n}{Number of named colors to return. Color with highest contrast
is returned first.}

\item{ex_bw}{Exclude black and variants of white and gray variants?}
}
\value{
A character value that's a named R color.
}
\description{
Given a user-supplied color, what's a good color to pair it with for maximum
contrast? Compares provided color against all named R colors, as per
\code{\link[grDevices]{colors}}. Contrast calculated as per
\code{\link{cr_get_ratio}}.
}
\examples{
cr_choose_color("lightyellow")
}
