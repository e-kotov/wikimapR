#' Get Wikimapia Objects by ID
#'
#' Retrieves Wikimapia objects by ID.
#'
#' Uses [`place.getbyid`](http://wikimapia.org/api#placegetbyid) Wikimapia API function to retrieve full object details.
#'
#' @param x a numeric or characted vector of length 1 with Wikimapia object ID to fetch. You can get a list of objects to fetch using \link[wikimapR]{wm_get_from_bbox}
#'
#' @param language Wikimapia language to retrieve. This is specified language in ISO 639-1 format. Default language is 'ru'.
#'
#' @param wm_api_key Your wikimapia API Key. If not specified, the default 'example' key is used, however it is limited to about 1 request per 30 seconds and is for testing purposes only.
#'
#' @param data_blocks The comma-separated blocks of data you want to return: main, geometry, edit, location, attached, photos, comments, translate, similar_places, nearest_places, nearest_comments, nearest_streets, nearest_hotels. Default is "main,geometry,edit,location,attached,photos,comments,translate".
#'
#' @return `sf` objects with nested details.
#'
#' @import purrr dplyr
#'
#' @importFrom rlist list.stack
#'
#' @export
wm_get_by_id <- function(x, language = "ru", wm_api_key = "example", data_blocks = "main,geometry,edit,location,attached,photos,comments,translate"){

  wm_objects <- x %>% purrr::map( ~ {
    if( wm_api_key == "example" ) {
      Sys.sleep(30)
    } else {
      Sys.sleep(3)
    }
    wikimapR:::wm_get_by_id_single(x = .x, language = language, wm_api_key = wm_api_key, data_blocks = data_blocks)
    }, .progress = T
  )

  wm_sf_all <- rlist::list.stack(wm_objects, fill = T, data.table = T) %>% st_sf()

  return(wm_sf_all)
}



# non-vectorised ----------------------------------------------------------

#' Get one Wikimapia object by ID
#'
#' Retrieves single Wikimapia object by ID.
#'
#' Uses [`place.getbyid`](http://wikimapia.org/api#placegetbyid) Wikimapia API function to retrieve full object details.
#'
#' @param x a numeric or characted vector of length 1 with Wikimapia object ID to fetch. You can get a list of objects to fetch using \link[wikimapR]{wm_get_from_bbox}
#'
#' @param language Wikimapia language to retrieve. This is specified language in ISO 639-1 format. Default language is 'ru'.
#'
#' @param wm_api_key Your wikimapia API Key. If not specified, the default 'example' key is used, however it is limited to about 1 request per 30 seconds and is for testing purposes only.
#'
#' @param data_blocks The comma-separated blocks of data you want to return: main, geometry, edit, location, attached, photos, comments, translate, similar_places, nearest_places, nearest_comments, nearest_streets, nearest_hotels. Default is "main,geometry,edit,location,attached,photos,comments,translate".
#'
#' @import purrr httr dplyr
#'
#' @return `sf` object with nested details.
#'
wm_get_by_id_single <- function(x, language = "ru", wm_api_key = "example", data_blocks = "main,geometry,edit,location,attached,photos,comments,translate") {


  if ( wm_api_key == "example" ){
    warning("Using 'example' API key. This key can only be used for testing. The interval for using this key is 30 seconds. Get your own API key at http://wikimapia.org/api?action=create_key .")
  }

  base_url <- "http://api.wikimapia.org/?function=place.getbyid"

  request_url <- paste0(base_url,
                        "&id=", x,
                        "&language=", language,
                        "&key=", wm_api_key,
                        "&data_blocks=", data_blocks,
                        "&format=json")

  response <- wikimapR:::safe_GET(request_url)

  response_content <- httr::content(response$result, as = "parsed", type = "application/json", encoding = "UTF-8")

  while( any(names(response_content) %in% "debug" == TRUE) ) {
    print(response_content$debug$message)
    print("Waiting for cool down. You have probalby reached your API rate limit or using.")
    if( wm_api_key == "example" ) {
      Sys.sleep(30)
    } else {
      Sys.sleep(3)
    }
    print("Retrying...")
    response <- wikimapR:::safe_GET(request_url)
    response_content <- httr::content(response$result, as = "parsed", type = "application/json", encoding = "UTF-8")
  }

  # process the recevied JSON

  # create polygon
  polygon <- wikimapR:::construct_polygon(response_content$polygon)

  # get flat features
  response_content_flat <- response_content[ grep("data\\.frame|list|NULL", sapply(response_content, class), invert = TRUE ) ]
  response_content_flat_df <- as.data.frame(response_content_flat, stringsAsFactors = F)

  # create an sf object
  wm_sf <- sf::st_sf(response_content_flat_df, geometry = polygon, crs = 4326)

  # add edit info
  wm_sf <- wm_sf %>% dplyr::bind_cols( response_content$edit_info %>% unlist() %>% t() %>% data.frame() )

  # add other list elements as nested lists
  response_content_nested <- response_content[ grep("data\\.frame|list|NULL", sapply(response_content, class), invert = FALSE ) ] %>%
    .[ grep("polygon|edit_info", names(.), invert = T) ]

  wm_sf_with_nested_cols <- wm_sf %>% mutate(details = list(response_content_nested))

  return(wm_sf_with_nested_cols)

}