# Load Packages
library(tidyverse) # For data manipulation
library(haven) # For importing .dta files

df_42y <- read_dta("42y/bcs70_2012_derived.dta",
                      col_select = c("BCSID", "BD9HGHTM", "BD9WGHTK")) %>%
rename_with(str_to_lower)

df_51y <- read_dta("51y/bcs11_age51_main.dta",
                   col_select = c("bcsid", "bd11hghtm", "bd11wghtk"))

df_wide <- df_42y %>%
  full_join(df_51y, by = "bcsid")

df_long <- df_wide %>%
  pivot_longer(cols = matches("^bd"),
               names_to = c("sweep", ".value"),
               names_pattern = "^bd(\\d{1,2})([A-Za-z].+)$")

df_long

df_long %>%
  pivot_wider(names_from = sweep,
              values_from = c(hghtm, wghtk),
              names_glue = "{.value}_{sweep}")
