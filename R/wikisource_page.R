#' Download a page from Wikisource
#'
#' Download the text of a Wikisource page into a data frame using its url.
#'
#' @param wikiurl The url of a Wikisource page that will
#' be downloaded.
#'
#' @param page A string naming the Wikisource page downloaded.
#' 
#' @param cleaned A boolean variable for cleaning the Wikisource page.
#'
#' @return A four column tbl_df (a type of data frame; see tibble or
#' dplyr packages) with one row for each line of the text or texts,
#' with four columns.
#'
#' \describe{
#'   \item{text}{A character column}
#'   \item{page}{A column naming the page downloaded}
#'   \item{language}{A character column with a two letter string refering
#'   to the language of the text}
#'   \item{url}{A character column with the url of the Wikisource page
#'   of the text}
#' }
#'
#' @examples
#'
#' \dontrun{
#' # download Sonnet 18 of Shakespeare
#' wikisource_page("https://en.wikisource.org/wiki/Shakespeare%27s_Sonnets/Sonnet_18", "Sonnet 18")
#'
#' # download Sonnets 116, 73 and 130 of Shakespeare
#' library(purrr)
#'
#' urls <- paste0("https://en.wikisource.org/wiki/Shakespeare%27s_Sonnets/Sonnet_", c(116, 73, 130))
#' sonnets <- map2_df(urls, paste0("Sonnet ", c(116, 73, 130)), wikisource_page)
#' }
#'
#' @importFrom rvest html_node
#' @importFrom rvest html_nodes
#' @importFrom rvest html_text
#' @importFrom magrittr "%>%"
#' @importFrom tibble tibble
#' @importFrom xml2 read_html
#' @importFrom xml2 xml_remove
#' @importFrom urltools domain
#' @importFrom urltools suffix_extract
#'
#' @export

wikisource_page <- function(wikiurl, page = NA, cleaned = TRUE) {

  # READING WIKIPAGE FROM WIKISOURCE
  wikipage <- wikiurl %>%
    xml2::read_html() %>%
    rvest::html_node(".mw-parser-output")
  ## reading other wiki page structures
  if(length(wikipage) == 0) {
    wikipage <- wikiurl %>%
      xml2::read_html() %>%
      rvest::html_node("#mw-content-text")
  }

  # IMPROVING NODE SELECTION
  ## if nodes not empty, remove selected id or class nodes
  ## Note: other id or class nodes could be added in future releases of the package
  if(cleaned) {
    if(length(rvest::html_nodes(wikipage, ".ws-noexport")) != 0) {
      wiki_nodes_remove <- rvest::html_nodes(wikipage, ".ws-noexport")
      xml2::xml_remove(wiki_nodes_remove)
    }
    if(length(rvest::html_nodes(wikipage, ".noprint")) != 0) {
      wiki_nodes_remove <- rvest::html_nodes(wikipage, ".noprint")
      xml2::xml_remove(wiki_nodes_remove)
    }
    if(length(rvest::html_nodes(wikipage, "#headerContainer")) != 0) {
      wiki_nodes_remove <- rvest::html_nodes(wikipage, "#headerContainer")
      xml2::xml_remove(wiki_nodes_remove)
    }
    if(length(rvest::html_nodes(wikipage, "#headertemplate")) != 0) {
      wiki_nodes_remove <- rvest::html_nodes(wikipage, "#headertemplate")
      xml2::xml_remove(wiki_nodes_remove)
    }
    if(length(rvest::html_nodes(wikipage, "#subheader")) != 0) {
      wiki_nodes_remove <- rvest::html_nodes(wikipage, "#subheader")
      xml2::xml_remove(wiki_nodes_remove)
    }
    if(length(rvest::html_nodes(wikipage, ".subheadertemplate")) != 0) {
      wiki_nodes_remove <- rvest::html_nodes(wikipage, ".subheadertemplate")
      xml2::xml_remove(wiki_nodes_remove)
    }
    if(length(rvest::html_nodes(wikipage, ".catlinks")) != 0) {
      wiki_nodes_remove <- rvest::html_nodes(wikipage, ".catlinks")
      xml2::xml_remove(wiki_nodes_remove)
    }
    if(length(rvest::html_nodes(wikipage, "table")) != 0) {
      wiki_nodes_remove <- rvest::html_nodes(wikipage, "table")
      xml2::xml_remove(wiki_nodes_remove)
    }
  }

  # EXTRACTING LANGUAGE OF THE WIKIPAGE
  language <- tryCatch(wikiurl %>%
                         urltools::domain() %>%
                         urltools::suffix_extract() %>%
                         .$subdomain,
                       error = function(e) NA)

  # CREATING WIKIPAGE DATAFRAME
  wikipage <- wikipage %>%
    rvest::html_text() %>%
    strsplit(., "\n") %>% #stringr::str_split("\n") %>%
    unlist() %>%
    #purrr::discard(!str_detect(., ""),
                   #!str_detect(., " "),
                   #!str_detect(., "  ")) %>% #remove blank cells
    tibble::tibble(text = .,
                   page = page,
                   language = language,
                   url = wikiurl)
  return(wikipage)
  }
