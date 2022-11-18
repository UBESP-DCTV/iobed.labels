library(targets)
library(tarchetypes)
# This is an example _targets.R file. Every
# {targets} pipeline needs one.
# Use tar_script() to create _targets.R and tar_edit()
# to open it again for editing.
# Then, run tar_make() to run the pipeline
# and tar_read(result) to view the results.

# Define custom functions and other global objects.
# This is where you write source(\"R/functions.R\")
# if you keep your functions in external scripts.
list.files(here::here("R"), pattern = "\\.R$", full.names = TRUE) |>
  lapply(source) |> invisible()

# Set target-specific options such as packages.
tar_option_set(
  packages = c("readr", "lubridate"),
  error = "continue",
  workspace_on_error = TRUE
)

# End this file with a list of target objects.
list(

  # Import your file from custom (shared) location, and preprocess them
  tar_files_input(
    RedcapIdFolders,
    get_input_data_path() |>
      list.dirs(recursive = FALSE) |>
      normalizePath(mustWork = FALSE)
  ),



  tar_target(
    redcapBedRawPath,
    file.path(
      list.files(
        RedcapIdFolders,
        pattern = "-bed\\.rds$",
        full.names = TRUE
      ) |> normalizePath()
    ),
    pattern = map(RedcapIdFolders),
    format = "file"
  ),


  tar_target(
    redcapVideoRawPath,
    file.path(
      list.files(
        RedcapIdFolders,
        pattern = "\\.mp4$",
        full.names = TRUE
      ) |> normalizePath()
    ),
    pattern = map(RedcapIdFolders),
    format = "file"
  ),

  tar_target(
    deltaMsVideoBed,
    delta_ms_from_paths(redcapVideoRawPath, redcapBedRawPath),
    pattern = map(redcapVideoRawPath, redcapBedRawPath)
  ),




  tar_target(
    redcapBedRaw,
    read_bed_data(redcapBedRawPath),
    pattern = map(redcapBedRawPath),
    iteration = "list",
    format = "qs"
  ),

  tar_target(
    redcap,
    preprocess_bed(
      redcapBedRaw,
      initial_deltams = deltaMsVideoBed
    ),
    pattern = map(redcapBedRaw, deltaMsVideoBed),
    iteration = "list",
    format = "qs"
  ),


  tar_target(
    redcapXlsxOutputPath,
    create_output_xlsx_path(redcapBedRawPath),
    pattern = map(redcapBedRawPath)
  ),

  tar_target(
    outputXlsx,
    write_labeling_xlsx(redcap, redcapXlsxOutputPath),
    format = "file",
    pattern = map(redcap, redcapXlsxOutputPath)
  )










  # compile yor report
  # tar_render(report, here::here("reports/report.Rmd"))


  # Decide what to share with other, and do it in a standard RDS format
  # tar_target(
  #   objectToShare,
  #   list(
  #     relevant_result = relevantResult
  #   )
  # ),
  # tar_target(
  #   shareOutput,
  #   share_objects(objectToShare),
  #   format = "file",
  #   pattern = map(objectToShare)
  # )
)
