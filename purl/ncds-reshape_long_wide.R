# Load Packages
library(tidyverse) # For data manipulation
library(haven) # For importing .dta files

df_23y <- read_dta("23y/ncds4.dta",
                      col_select = c("ncdsid", "dvwt23", "dvht23")) %>%
rename_with(str_to_upper)

df_50y <- read_dta("50y/ncds_2008_followup.dta",
                   col_select = c("NCDSID", "DVWT50", "DVHT50"))

df_wide <- df_23y %>%
  full_join(df_50y, by = "NCDSID")

df_long <- df_wide %>%
  pivot_longer(cols = matches("DV(HT|WT)\\d\\d"),
               names_to = c(".value", "fup"),
               names_pattern = "^(.*)(\\d\\d)$")

df_long

df_long %>%
  pivot_wider(names_from = fup,
              values_from = matches("DV(HT|WT)"),
              names_glue = "{.value}{fup}")
