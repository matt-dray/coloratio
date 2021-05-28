.choose_bw_one <- function(col_bg) {

  # Calculate contrast ratios against black and white
  w <- cr_get_ratio(col_bg, "white", quiet = TRUE)
  b <- cr_get_ratio(col_bg, "black", quiet = TRUE)

  # Higher value means higher contrast
  if (w > b) {
    result <- "white"
  } else if (w < b | w == b) {  # ties default to black
    result <- "black"
  }

  return(result)

}
