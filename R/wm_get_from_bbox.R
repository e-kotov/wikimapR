#' Get Wikimapia Objects in a Bounding Box
#'
#' Retrieves objects in the given boundary box either with or without geometry. May also fetch just the metadata.
#'
#' Currenlty only supports bbox parameter, but not &lon_min, &lat_min, &lon_max, &lat_max and not &x, &y, &z for tiles. `Box`` endpoint is claimed to be deprecated, but the `Place.Getbyarea` does not seem to work properly.
#'
#' @param x a numeric vector of length 4, with xmin, ymin, xmax and ymax values; or a `bbox` object that is an output of \link[sf]{st_bbox}. The values must be in WGS 84 (EPSG 4326)
#'
#' @param page This is page number. 1 is default. There are usually more objects in a bounding box than the limit of 100 objects per page. Therefore you need to specify page other than 1 to get other objects. The returned list object contains number of found features and the required number of pages to retrieve them all.
#'
#' @param n_per_page This is a variable that determines the number of results per page. 100 is default (5 min, 100 max). This is `count` parameter in Wikimapia terminilogy, but different name is used here so that it does not conflict with the `dplyr::count()` function.
#'
#' @param language Wikimapia language to retrieve. This is specified language in ISO 639-1 format. Default language is 'ru'.
#'
#' @param category This is wikimapia category code: category=17 - Shop, category=203 - School etc. (a detailed list will be published later) or category text query in UTF-8: category=School, category=Church etc. Default is NULL to get all categories.
#'
#' @param get_location Specifies whether to get location (centroid) and polygon geometry. You may want to disable it if you are only using the \link[wikimapR]{wm_get_from_bbox} to estimate the number of objects to reduce the returned object size.
#'
#' @param wm_api_key Your wikimapia API Key. If not specified, the default 'example' key is used, however it is limited to about 1 request per 30 seconds and is for testing purposes only.
#'
#' @param meta_only only return metadata from the response, do not return feature attributes or geometry.
#'
#' @return If `meta_only = FALSE` returns a list with data.frame of object attributes (and object geometry if `get_location = TRUE`). If `meta_only = TRUE` only returns metadata of the responce: the number of objects in the bounding box (`found`), version, language, current page, current `n_per_page`.
#' If `get_location = TRUE` returns a list object with `sf polygons` with all object attributes, `sf points` with all object attributes (the centroids), and also the metadata described above.
#'
#' @import purrr httr dplyr
#'
#' @export
wm_get_from_bbox <- function(x, page = 1, n_per_page = 100, language = "ru", category = NULL,
                             get_location = TRUE, wm_api_key = "example", meta_only = FALSE){

  if ( wm_api_key == "example" ){
    warning("Using 'example' API key. This key can only be used for testing. The interval for using this key is 30 seconds. Get your own API key at http://wikimapia.org/api?action=create_key .")
  }

  bbox_string <- paste(x, collapse = ",")

  base_url <- "http://api.wikimapia.org/?function=box"

  request_url <- paste0(base_url,
                        "&page=", page,
                        "&count=", n_per_page,
                        "&language=", language,
                        if(is.null(category) == FALSE) { paste0("&category=", category)  } ,
                        "&bbox=", bbox_string,
                        if(get_location == FALSE) { "&disable=location,polygon" },
                        "&key=", wm_api_key,
                        "&format=json")



  response <- wikimapR:::safe_GET(request_url)

  response_content <- httr::content(response$result, as = "parsed", type = "application/json", encoding = "UTF-8")

  while( any(names(response_content) %in% "debug" == TRUE) ) {
    print(response_content$debug$message)
    print("Waiting for cool down. You have probalby reached your API rate limit or using 'example' API key.")
    if( wm_api_key == "example" ) {
      Sys.sleep(30)
    } else {
      Sys.sleep(3)
    }
    print("Retrying...")
    response <- wikimapR:::safe_GET(request_url)
    response_content <- httr::content(response$result, as = "parsed", type = "application/json", encoding = "UTF-8")
  }

  meta_df <- response_content[c("version", "language", "page", "count", "found")] %>% as.data.frame(stringsAsFactors = FALSE)
  meta_df$found <- as.integer(meta_df$found)

  if ( meta_only == TRUE ) {
    return(meta_df)
  }

  # process the received JSON

  ## get primary data about objects
  wm_objects_attributes <- data.frame(id = response_content$folder %>% purrr::map_chr(~ .x$id),
                                      name = response_content$folder %>% purrr::map_chr(~ .x$name),
                                      url = response_content$folder %>% purrr::map_chr(~ .x$url),
                                      stringsAsFactors = FALSE)

  if ( get_location == FALSE ){
    wm <- list(df = wm_objects_attributes,
               meta = meta_df)
    return(wm)
  }

  ## create polygons and centroids from raw JSON data
  if (  get_location == TRUE ) {

    # create polygons
    polygons <- response_content$folder %>%
      purrr::map(~ wikimapR:::construct_polygon(.x$polygon) ) %>%
      do.call(c, .) %>%
      sf::st_sf(geometry = .) %>%
      dplyr::mutate(id = wm_objects_attributes$id) %>%
      merge(x = ., y = wm_objects_attributes, by = "id", all = T)


    # create centroids
    centroids <- response_content$folder %>%
      purrr::map(~ c( x = .x$location$lon,
                      y = .x$location$lat)) %>%
      purrr::map(~ st_point(.) %>% sf::st_sfc(crs = 4326) ) %>%
      do.call(c, .) %>%
      sf::st_sf(geometry = ., id = wm_objects_attributes$id) %>%
      merge(x = ., y = wm_objects_attributes, by = "id", all = T)

    wm <- list(polygons = polygons,
               centroids = centroids,
               meta = meta_df)
    return(wm)
  }
}
