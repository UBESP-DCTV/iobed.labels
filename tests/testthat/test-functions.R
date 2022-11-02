test_that("read_bed_data return a tibble", {
  skip_on_ci()
  # setup
  example_bed_path <- targets::tar_read(redcap121BedRawPath_470e5e38)

  # execution
  res <- read_bed_data(example_bed_path)

  # expectations
  expect_tibble(res)
  expect_equal(names(res[1]), "sbl")
  expect_true("elapsed" %in% names(res))
})



test_that("preprocess_bed return a tibble", {
  skip_on_ci()
  # setup
  db <- targets::tar_read(redcap121BedRaw_bd512a80)
  deltams <- 20000

  # execution
  res <- preprocess_bed(db)
  res_deltams <- preprocess_bed(db, initial_deltams = deltams)

  # expectations
  expect_tibble(res)
  expect_true("cum_elapsed" %in% names(res))
  expect_equal(res[["cum_elapsed"]][1:2], c(300, 600))

  expect_true(
    all(res_deltams[["cum_elapsed"]] > deltams)
  )
  expect_lt(nrow(res_deltams), nrow(res))
})

test_that("get_time_from_filename works", {
  skip_on_ci()
  # setup
  bed_name <- "20221012122623-REDCAP121-bed.rds"
  video_name <- "20221012122645-REDCAP121.mp4"

  bed_full_path <- get_input_data_path(
    "REDCAP121/20221012122623-REDCAP121-bed.rds"
  )

  # execution
  bed_time <- get_time_from_filename(bed_name)
  video_time <- get_time_from_filename(video_name)
  bed_full_path_time <- get_time_from_filename(bed_full_path)

  # expectations
  bed_time |>
    expect_equal(lubridate::ymd_hms("20221012122623"))

  video_time |>
    expect_equal(lubridate::ymd_hms("20221012122645"))

  bed_full_path_time |> expect_equal(bed_time)
})


test_that("milliseconds_gap works", {
  skip_on_ci()
  # setup
  video_start <- lubridate::ymd_hms("20221012122645")
  bed_start <-   lubridate::ymd_hms("20221012122623")

  # eval
  delta_s <- milliseconds_gap(video_start, bed_start)

  # test
  expect_integer(delta_s)
  expect_equal(delta_s, 22000)
})



test_that("milliseconds_gap works", {
  skip_on_ci()
  # setup
  bed_full_path <- get_input_data_path(
    "REDCAP121/20221012122623-REDCAP121-bed.rds"
  )
  video_full_path <- get_input_data_path(
    "REDCAP121/20221012122645-REDCAP121.mp4"
  )


  # eval
  delta_s <- delta_ms_from_paths(video_full_path, bed_full_path)

  # test
  expect_integer(delta_s)
  expect_equal(delta_s, 22000)

  # wrong order
  expect_error(
    delta_ms_from_paths(bed_full_path, video_full_path),
    paste(
      "video_path must be the path to the .mp4 video and",
      "bed_path must be a path to the bed .rds"
    )
  )
})




test_that("create_output_xlsx_path works", {
  skip_on_ci()
  # setup
  input_bed_path <- get_input_data_path(
    "REDCAP121/20221012122623-REDCAP121-bed.rds"
  )
  today <- lubridate::today() |>
    stringr::str_remove_all("-")

  # eval
  out_path <- create_output_xlsx_path(input_bed_path)

  # test
  expect_equal(
    basename(out_path), paste0(today, "-REDCAP121.xlsx")
  )
  expect_equal(dirname(out_path), dirname(input_bed_path))
})


test_that("write_labeling_xlsx works", {
  skip_on_ci()
  # setup
  db <- targets::tar_read(redcap121_53a0df9a)
  outpath <- fs::file_temp(ext = "xlsx")

  # eval
  write_labeling_xlsx(db, outpath)
  stored_db <- readxl::read_xlsx(outpath)

  # test
  expect_tibble(stored_db)
  expect_equal(names(stored_db[1]), "sbl")
  expect_true("cum_elapsed" %in% names(stored_db))
})
