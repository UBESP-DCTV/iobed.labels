# library(tidyverse)
# library(here)
# library(writexl)
#
#
# bed_redcap_121 <- read_rds(here(
#   "data-raw/REDCAP121/20221012122623-REDCAP121-bed.rds"
# ))
#
#
# tmp <- bed_redcap_121 |>
#   mutate(cum_elapsed = cumsum(elapsed))
#

#
# cumfreq_data <- cumsum(bed_redcap_121$elapsed)
# bed_redcap_121$cum_elapsed <- cumfreq_data
#
#

#
#
# bed_start_time <- gsub("\\D", "", "20221012122623-REDCAP121-bed.rds")
# bed_start_time <- as.integer(substr(bed_start_time, 9, 14))
#
#
#
# #video_redcap_121 <- read_rds("REDCAP121/20221012122645-REDCAP121.mp4")
# video_start_time <- gsub("\\D", "", "20221012122645-REDCAP121.mp4")
# video_start_time <- as.integer(substr(video_start_time, 9, 14))
# gap <- (video_start_time - bed_start_time)
#
#
#
# delete <- gap*1000 #find millisec at gap time
#
#
#
# row_to_delete <- (which.min(abs(bed_redcap_121$cum_elapsed - delete))) - 1
# bed_redcap_121_cut1 <- bed_redcap_121[-c(1:row_to_delete),] #video allineato con bed
#


## THIS IS REDUNTANT ==================================================
#
# cumfreq_data_2 <- cumsum(bed_redcap_121_cut1$elapsed)
# bed_redcap_121_cut1$cum_elapsed_2 <- cumfreq_data_2
# bed_redcap_121_cut1$fraz_sec <- bed_redcap_121_cut1$elapsed/1000
# bed_redcap_121_cut1$n_frame_record <- bed_redcap_121_cut1$fraz_sec*30
# cumfreq_data_3 <- cumsum(bed_redcap_121_cut1$n_frame_record)
# bed_redcap_121_cut1$cum_n_frame_record <- cumfreq_data_3
# #(which.min(abs(bed_redcap_121_cut1$cum_n_frame_record - 6480)))
#
# =====================================================================


write_xlsx(
  bed_redcap_121_cut1,
  here("output/REDCAP121/DB_REDCAP_121.xlsx")
)
