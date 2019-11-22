#' Download a book from Wikisource
#'
#' Download a book using the url of a Wikisource content page into a
#' data frame. The Wikisource table of content page should link to all the
#' Wikisource pages constituting the book. The text in the Wikisource
#' pages is downloaded using the \code{wikisource_page()} function.
#'
#' @details The download could fail if the Wikisource paths listed
#' into content page strongly differ from the url path of the content page.
#'
#' @param url A url of a Wikisource content page listing the pages
#' constituting the book.
#' 
#' @param cleaned A boolean variable for cleaning Wikisource pages.
#'
#' @return A five column tbl_df (a type of data frame; see tibble or
#' dplyr packages) with one row for each line of the text or texts,
#' with columns.
#'
#' \describe{
#'   \item{text}{A character column}
#'   \item{title}{A character column with the title of the Wikisource
#'   summary page}
#'   \item{page}{Integer column with a number for the text from each
#'   Wikisource page downloaded}
#'   \item{language}{A character column with a two letter string refering
#'   the language of the text}
#'   \item{url}{A character column with the url of the Wikisource page
#'   of the text}
#' }
#'
#' @examples
#'
#' \dontrun{
#'
#' # download Voltaire's "Candide"
#' wikisource_book("https://en.wikisource.org/wiki/Candide")
#'
#' # download "Candide" in French and Spanish
#' library(purrr)
#'
#' fr <- "https://fr.wikisource.org/wiki/Candide,_ou_l%E2%80%99Optimisme/Garnier_1877"
#' es <- "https://es.wikisource.org/wiki/C%C3%A1ndido,_o_el_optimismo"
#' books <- map_df(c(fr, es), wikisource_book)
#' }
#'
#' @importFrom magrittr "%>%"
#' @importFrom rvest html_node
#' @importFrom rvest html_nodes
#' @importFrom rvest html_node
#' @importFrom rvest html_attr
#' @importFrom rvest html_text
#' @importFrom urltools scheme
#' @importFrom urltools domain
#' @importFrom purrr keep
#' @importFrom purrr pmap_df
#' @importFrom xml2 read_html
#'
#' @export

wikisource_book <- function(url, cleaned = TRUE) {
  # READING URL
  wiki_paths <- url %>%
    xml2::read_html() %>%
    rvest::html_node(".mw-parser-output")
  ## reading other wiki page structures
  if(length(wiki_paths) == 0) {
    wiki_paths <- url %>%
      xml2::read_html() %>%
      rvest::html_node("#mw-content-text")
  }

  # IMPROVING NODE SELECTION
  ## if nodes not empty, get the href/urls from various id or class selectors
  ## Note: other id or class selectors could be added in future releases of the package
  if(length(rvest::html_nodes(wiki_paths, ".ws-summary")) != 0) {
    wiki_paths <- wiki_paths %>%
      rvest::html_nodes(".ws-summary") %>%
      rvest::html_nodes("a") %>%
      rvest::html_attr("href")
  } else if(length(rvest::html_nodes(wiki_paths, ".subheadertemplate")) != 0) {
    wiki_paths <- wiki_paths %>%
      rvest::html_nodes(".subheadertemplate") %>%
      rvest::html_nodes("a") %>%
      rvest::html_attr("href")
  } else {
    wiki_paths <- wiki_paths %>%
      rvest::html_nodes("a") %>%
      rvest::html_attr("href")
  }

  # CREATING WIKI_URLS VECTOR
  url_cleaned <- gsub(pattern = "\\(.*", replacement = "", x = url) #error if parenthesis in main url
  wiki_urls <- paste0(urltools::scheme(url_cleaned), "://", urltools::domain(url_cleaned), wiki_paths) %>% #create urls
    purrr::keep(., grepl(pattern = paste0("^", url_cleaned), .)) %>% ## IMPORTANT: keep paths beginning like the main url
    gsub(pattern = "\\#.*", replacement = "", x = .) %>% #remove string after "#" (is url for text comparison with jpg text)
    unique(.) #keep unique paths

  # BUILDING WIKIBOOK DATAFRAME
  ## download all pages from wiki_urls using the wikisource_page function
  wikibook <- purrr::pmap_df(list(wiki_urls, 1:length(wiki_urls), cleaned), wikisource_page)

  # ADD TITLE OF BOOK VARIABLE
  title_book <- url %>%
    xml2::read_html() %>%
    rvest::html_node("#firstHeading") %>%
    rvest::html_text()
  
  wikibook$title <- title_book

  # WARNING MESSAGE IF THE DATA FRAME IS EMPTY
  if(nrow(wikibook) == 0){
    warning("Could not download a book at ", url)
  }

  return(wikibook)
}
