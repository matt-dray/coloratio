
<!-- README.md is generated from README.Rmd. Please edit that file -->

# coloratio

<!-- badges: start -->

[![Project Status: Concept – Minimal or no implementation has been done
yet, or the repository is only intended to be a limited example, demo,
or
proof-of-concept.](https://www.repostatus.org/badges/latest/concept.svg)](https://www.repostatus.org/#concept)
<!-- badges: end -->

This work-in-progress package helps calculate colour-contrast values so
you can make decisions to improve the visual accessibility of text on
block-coloured backgrounds.

The ultimate aim is to create a tool for compliance with [WCAG
3.0](https://w3c.github.io/silver/guidelines/).

## Installation

You can install the development version of {coloratio} from GitHub with:

``` r
remotes::install_github("matt-dray/coloratio")
```

## Example

There is currently one function, which assesses the colour-contrast
ratio of two user-provided colours. You can provide hex values, namee
colours, or both.

``` r
library(coloratio)
get_ratio("#000000", "white")
#> [1] 21
```

You should aim for a value of 4.5 or greater. You’ll get a warning if
the contrast between the colours is insufficient.

``` r
library(coloratio)
get_ratio("black", "grey10")
#> Warning in get_ratio("black", "grey10"): You should aim for a contrast ratio value of 4.5 or more.
#> [1] 1.206596
```

[Read more about the
calculation](w3.org/TR/WCAG/#dfn-relative-luminance) in the WCAG 2.1
guidance.
