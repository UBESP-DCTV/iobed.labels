
# Here below put your main project's functions ---------------------
read_bed_data <- function(path) {
  readr::read_rds(path)
}


preprocess_bed <- function(x, initial_deltams = 0) {

  processed <- x |>
    tibble::as_tibble() |>
    dplyr::mutate(
      cum_elapsed = cumsum(.data[["elapsed"]])
    )

  row_to_retain <- processed[["cum_elapsed"]] > initial_deltams
  processed[row_to_retain, , drop = FALSE]
}


get_time_from_filename <- function(filepath) {
  basename(filepath) |>
    stringr::str_extract("^\\d+") |>
    lubridate::ymd_hms()
}


milliseconds_gap <- function(video_start_time, bed_start_time) {
  diff_s <- video_start_time - bed_start_time
  1000L * as.integer(diff_s)
}


delta_ms_from_paths <- function(video_path, bed_path) {

  video_file_type <- stringr::str_extract(video_path, "\\..{3}$")
  bed_file_type <- stringr::str_extract(bed_path, "\\..{3}$")

  if (video_file_type != ".mp4" || bed_file_type != ".rds") {
    usethis::ui_stop(
      paste(
        "video_path must be the path to the .mp4 video and",
        "bed_path must be a path to the bed .rds"
      )
    )
  }

  video_time <- get_time_from_filename(video_path)
  bed_time <- get_time_from_filename(bed_path)

  milliseconds_gap(video_time, bed_time)
}


create_output_xlsx_path <- function(bed_path) {
  out_dir <- dirname(bed_path)

  today <- lubridate::today() |>
    stringr::str_remove_all("-")

  filename <- basename(bed_path) |>
    stringr::str_replace("^\\d+", today) |>
    stringr::str_remove("-bed") |>
    stringr::str_replace("\\.rds", ".xlsx")

  file.path(out_dir, filename) |>
    normalizePath(mustWork = FALSE)
}


write_labeling_xlsx <- function(db, out_path) {
  writexl::write_xlsx(db, out_path)
}



