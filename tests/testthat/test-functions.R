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
  expect_equal(res[["cum_elapsed"]][1:3], c(0, 300, 601))

  expect_equal(res_deltams[["cum_elapsed"]][1:3], c(0, 298, 598))
  expect_lt(nrow(res_deltams), nrow(res))
  expect_false("clock" %in% names(res))

  expect_names(
    c(
      "static_bed", "static_self", "dyn_bed", "dyn_self",
      "frame_n", "video_time"
    ),
    subset.of = names(res)
  )

  c("static_bed", "static_self", "dyn_bed", "dyn_self") |>
    purrr::walk(~expect_true(all(is.na(res[[.x]]))))

  expect_equal(res[["frame_n"]][[1]], 1)
  expect_equal(res[["frame_n"]][[2]], 10)
  expect_equal(res[["video_time"]][[1]], "0S")
  expect_equal(res[["video_time"]][[2]], "0.3S")

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


test_that("ms2frame works correctly", {
  # setup
  time_1s <- 1000
  time_2s <- 2000
  time_05s <- 500
  time_0533s <- 533
  time_0534s <- 534
  time_300 <- 300

  # evaluation
  res_1s <- ms2frame(time_1s)
  res_2s <- ms2frame(time_2s)
  res_05s <- ms2frame(time_05s)
  res_0533s <- ms2frame(time_0533s)
  res_0534s <- ms2frame(time_0534s)
  res_300 <- ms2frame(time_300)

  # test
  expect_equal(res_1s, 31)
  expect_equal(res_2s, 61)
  expect_equal(res_05s, 16)
  expect_equal(res_0533s, 16)
  expect_equal(res_0534s, 17)
  expect_equal(res_300, 10)
})


test_that("ms2frame works correctly", {
  # setup
  ms_1s <- 1000
  ms_03s <- 300
  ms_60s <- 60000
  ms_1h <- 3600000
  ms_strange <- 60221

  # evaluation
  res_1s <- ms2time(ms_1s)
  res_03s <- ms2time(ms_03s)
  res_60s <- ms2time(ms_60s)
  res_1h <- ms2time(ms_1h)
  res_strange <- ms2time(ms_strange)

  # test
  expect_equal(res_1s, "1S")
  expect_equal(res_03s, "0.3S")
  expect_equal(res_60s, "1M 0S")
  expect_equal(res_1h, "1H 0M 0S")
  expect_equal(res_strange, "1M 0.221S")
})
