test_that("read_bed_data return a tibble", {
  # setup
  example_bed_path <- targets::tar_read(redcap121BedRawPath)

  # execution
  res <- read_bed_data(example_bed_path)

  # expectations
  expect_tibble(res)
  expect_equal(names(res[1]), "sbl")
  expect_true("elapsed" %in% names(res))
})



test_that("preprocess_bed return a tibble", {
  # setup
  db <- targets::tar_read(redcap121Bed)

  # execution
  res <- preprocess_bed(db)

  # expectations
  expect_tibble(res)
  expect_true("cum_elapsed" %in% names(res))
  expect_equal(res[["cum_elapsed"]][1:2], c(300, 600))
})

