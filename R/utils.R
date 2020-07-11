#' Fail gracefully if Wikisource resources are not available
#' 
#' The function allows to fail gracefully with an informative message 
#' if the Wikisource resource is not available (and not give a check warning nor error).
#' 
#' @details See full discussion to be compliante with the CRAN policy 
#' <https://community.rstudio.com/t/internet-resources-should-fail-gracefully/49199>
#' 
#' @param remote_url A remote URL.
#' 
#' @importFrom httr GET timeout http_error message_for_status
#' @importFrom curl has_internet
#' @importFrom xml2 read_html

gracefully_fail <- function(remote_url) {
  try_GET <- function(x, ...) {
    tryCatch(
      httr::GET(url = x, httr::timeout(600), ...), #timeout 10 minutes
      error = function(e) conditionMessage(e),
      warning = function(w) conditionMessage(w)
    )
  }
  is_response <- function(x) {
    class(x) == "response"
  }
  
  # First check internet connection
  if (!curl::has_internet()) {
    message("No internet connection.")
    return(invisible(NULL))
  }
  # Then try for timeout problems
  resp <- try_GET(remote_url)
  if (!is_response(resp)) {
    message(resp)
    return(invisible(NULL))
  }
  # Then stop if status > 400
  if (httr::http_error(resp)) { 
    httr::message_for_status(resp)
    return(invisible(NULL))
  }
  
  # If you are using rvest as I do you can easily read_html in the response
  xml2::read_html(resp)
}
