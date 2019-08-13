#' Subdivide large bounding box into smaller ones
#'
#' Subdivide large bounding box into smaller ones.
#'
#'
#'
#' @param x a numeric vector of length four, with xmin, ymin, xmax and ymax values; or a `bbox` object that is an output of \link[sf]{st_bbox}. The values must be in WGS 84 (EPSG 4326)
#'
#' @param bbox_cell_size bounding box cell size is in degrees (need to somehow fix that to work with meters across the globe). Default of 0.045 is reasonably large, roughly equivalent to 2845x5010 meters. The grid will be created in WGS84 coordinate reference system and then transformed into CRS set by `out_crs`, which is also WGS84 by default (EPSG:4326).
#'
#' @param return_bbox_or_sf object type to retun. If set to default "bbox", returns objects of type `bbox`, "sf" - returns `sf polygons` (good for plotting), "both" - returns a list of length 2 with both `bbox` and `sf` named accorgingly.
#'
#' @param out_crs EPSG code or proj4 string for the desired coordinate reference system of the output bounding box coordinates. The grid will be created in WGS84 coordinate reference system and then transformed into CRS set by `out_crs`. Default value is 4326 for WGS84.
#'
#' @import sf dplyr purrr
#'
#' @return an `sf` object grid with consequtive IDs. Also prints out a message with the number of bounding boxes and the average cell dimensions in meters.
#'
#' @export
subdivide_bbox <- function(x, bbox_cell_size = 0.045, return_bbox_or_sf = "bbox", out_crs = 4326)
{
  # x <- bbox # remove this
  # create corner coords
  corner_coords <- c( x[c(1,2)], # bottom left coord
                      x[c(1,4)], # top left coord
                      x[c(3,4)], # top right coord
                      x[c(3,2)], # bottom right coord
                      x[c(1,2)]) # bottom left coord to close the polygon

  # generate polygon from bounding box corner coordinates
  bbox_polygon <- corner_coords %>%
    matrix(ncol = 2, byrow = T) %>%
    list() %>%
    sf::st_polygon() %>%
    sf::st_sfc(crs = 4326)

  # create a grid object of type sf with consequtive IDs
  bbox_grid_sf <- sf::st_make_grid(bbox_polygon, cellsize = bbox_cell_size) %>%
    sf::st_sf() %>%
    dplyr::mutate(fid = seq(from = 1, to = nrow(.), by = 1)) %>%
    sf::st_transform(crs = out_crs)

  # get the bounding boxes of the cells in the grid object
  bbox_grid_bbox <- purrr::map(.x = bbox_grid_sf$geometry, .f = ~ sf::st_bbox(.x) )

  # evaluate approximate grid dimensions
  first_bbox_point <- bbox_grid_sf[1,] %>% wikimapR:::quiet_st_cast("POINT") %>% .$result
  size_x <- sf::st_distance(x = first_bbox_point[1,], y = first_bbox_point[2,]) %>% round(digits = 0)
  size_y <- sf::st_distance(x = first_bbox_point[2,], y = first_bbox_point[3,]) %>% round(digits = 0)

  message( paste0(nrow(bbox_grid_sf), " bounding boxes created with approximate cell size of ", size_x, "x", size_y, " meters.") )

  if (return_bbox_or_sf == "bbox") {
    return(bbox_grid_bbox)
  }

  else if (return_bbox_or_sf == "sf") {
    return(bbox_grid_sf)
  }

  else if (return_bbox_or_sf == "both") {
    bboxes <- list( bbox = bbox_grid_bbox, sf = bbox_grid_sf)
    return(bboxes)
  }
}
