#' Import 'Wikimapia' Data as Simple Features via API
#'
#' Download and import of 'Wikimapia' data as 'sf'
#' objects.  'Wikimapia' data are extracted via the 'Wikimapia' API and
#' converted to `sf` objects retaining all recevied fields.
#'
#' @author Egor Kotov \email{kotov.egor@gmail.com}
#' @docType package
#' @name wikimapR
"_PACKAGE"


# Wrappers ----------------------------------------------------------------

safe_GET <- purrr::safely( httr::GET )

quiet_st_cast <- purrr::quietly(sf::st_cast)

# Helper functions --------------------------------------------------------

construct_polygon <- function(points_list) {

  polygon <- rbind( data.frame( x = points_list %>% purrr::map_dbl(~.x$x),
                                y = points_list %>% purrr::map_dbl(~.x$y)),
                    data.frame( x = points_list %>% purrr::map_dbl(~.x$x) %>% .[[1]],
                                y = points_list %>% purrr::map_dbl(~.x$y) %>% .[[1]])
                    ) %>%
    as.matrix(.) %>% list() %>% sf::st_polygon() %>% sf::st_sfc(crs = 4326)

  return(polygon)
}

#' Set Wikimapia API Key
#'
#' Sets an API key to make it available for all wikimapR functions calls. See details
#'
#' @param api_key Wikimapia API key
#'
#' @details
#' Use \code{set_wikimapia_api_key} to make API keys available for all Wikimapia API
#' calls in a session so you don't have to keep specifying the \code{wm_api_key} argument
#' each time.
#'
#' @references mapdeck https://github.com/SymbolixAU/mapdeck code related to API key handling was used as a template.
#'
#' @export
set_wikimapia_api_key <- function(api_key) {
  options <- api_key
  class(options) <- "wikimapia_api"
  options(wikimapia_api_key = options)
  invisible(NULL)
}




