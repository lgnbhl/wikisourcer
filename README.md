<!-- badges: start -->
[![CRAN status](https://www.r-pkg.org/badges/version/wikisourcer)](https://CRAN.R-project.org/package=wikisourcer)
[![](http://cranlogs.r-pkg.org/badges/grand-total/wikisourcer?color=green)](https://cran.r-project.org/package=wikisourcer)
<!-- badges: end -->


<!-- badges: start -->

[![CRAN
status](https://www.r-pkg.org/badges/version/wikisourcer)](https://CRAN.R-project.org/package=wikisourcer)
[![](https://cranlogs.r-pkg.org/badges/grand-total/polyglot)](https://cran.r-project.org/package=wikisourcer)
<!-- badges: end -->

# wikisourcer <img src="man/figures/logo.png" align="right" />

The **wikisourcer** R package helps you download public domain works
from the free library [Wikisource](https://wikisource.org/).

It includes two functions for downloading books and pages by url.

  - `wikisource_book()` to download a book.
  - `wikisource_page()` to download a
page.

### Installation

``` r
install.packages("wikisourcer") # or devtools::install_github("lgnbhl/wikisourcer")
```

### Minimal examples

Download Voltaire’s philosophical novel *Candide*.

``` r
library(wikisourcer)

wikisource_book(url = "https://en.wikisource.org/wiki/Candide")
```

Download Chapter 1 of *Candide*.

``` r
wikisource_page("https://en.wikisource.org/wiki/Candide/Chapter_1", 
                page = "Chapter 1")
```

Download *Candide* in French, Spanish and Italian.

``` r
library(purrr)

fr <- "https://fr.wikisource.org/wiki/Candide,_ou_l%E2%80%99Optimisme/Garnier_1877"
es <- "https://es.wikisource.org/wiki/C%C3%A1ndido,_o_el_optimismo"
it <- "https://it.wikisource.org/wiki/Candido"

purrr::map_df(c(fr, es, it), wikisource_book)
```

For more information on how to use **wikisourcer**, please read [the
vignette](https://felixluginbuhl.com/wikisourcer/articles/wikisourcer.html).
