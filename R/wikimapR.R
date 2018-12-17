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