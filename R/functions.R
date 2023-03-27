
# Here below put your main project's functions ---------------------
read_bed_data <- function(path) {
  readr::read_rds(path)
}


ms2frame <- function(ms) {
  floor(ms / 0.00004) # 25fps
}

ms2time <- function(ms) {
  lubridate::milliseconds(ms) |>
    lubridate::as.period(unit = "hours") |>
    round(3) |>
    as.character()
}


preprocess_bed <- function(x, initial_deltams = 0) {

  x |>
    tibble::as_tibble() |>
    dplyr::select(-dplyr::any_of("clock")) |>
    dplyr::mutate(
      cum_elapsed = cumsum(.data[["elapsed"]]) -
        dplyr::first(.data[["elapsed"]])
    ) |>
    dplyr::filter(.data[["cum_elapsed"]] >= initial_deltams) |>
    dplyr::mutate(
      cum_elapsed = .data[["cum_elapsed"]] -
        dplyr::first(.data[["cum_elapsed"]]),
      frame_n = ms2frame(.data[["cum_elapsed"]]),
      video_time = ms2time(.data[["cum_elapsed"]]),
      tilt_bed = NA,
      static_bed = NA,
      static_self = NA,
      dyn_bed = NA,
      dyn_self = NA,
      note = NA
    )
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
  db |>
    dplyr::select(-all_of(c("elapsed", "cum_elapsed"))) |>
    writexl::write_xlsx(out_path)
}
