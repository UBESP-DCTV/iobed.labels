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
  packages = c("readr"),
  error = "continue"
)

# End this file with a list of target objects.
list(

  # Import your file from custom (shared) location, and preprocess them
  tar_target(
    redcap121BedRawPath,
    file.path(
      get_input_data_path("REDCAP121/20221012122623-REDCAP121-bed.rds")
    ),
    format = "file"
  ),
  tar_target(redcap121BedRaw, read_bed_data(redcap121BedRawPath)),

  tar_target(redcap121Bed, preprocess_bed(redcap121BedRaw)),









  # compile yor report
  tar_render(report, here::here("reports/report.Rmd"))


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
