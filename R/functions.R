
# Here below put your main project's functions ---------------------
read_bed_data <- function(path) {
  readr::read_rds(path)
}


preprocess_bed <- function(x) {
  x |>
    dplyr::mutate(
      cum_elapsed = cumsum(.data[["elapsed"]])
    )
}
