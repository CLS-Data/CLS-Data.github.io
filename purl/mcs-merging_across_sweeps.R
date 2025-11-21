# Load Packages
library(tidyverse) # For data manipulation
library(haven) # For importing .dta files

df_3y <- read_dta("3y/mcs2_cm_interview.dta",
                  col_select = c("MCSID", "BCNUM00", "BCHTCM00"))

df_5y <- read_dta("5y/mcs3_cm_interview.dta",
                  col_select = c("MCSID", "CCNUM00", "CCHTCM00"))

df_3y %>%
  full_join(df_5y, by = c("MCSID", BCNUM00 = "CCNUM00"))

df_3y %>%
  inner_join(df_5y, by = c("MCSID", BCNUM00 = "CCNUM00"))

df_3y %>%
  left_join(df_5y, by = c("MCSID", BCNUM00 = "CCNUM00"))

df_3y %>%
  right_join(df_5y, by = c("MCSID", BCNUM00 = "CCNUM00"))

df_3y_noprefix <- df_3y %>%
  mutate(sweep = 2, .before = 1) %>%
  rename_with(~ str_remove(.x, "^B"))

df_5y_noprefix <- df_5y %>%
  mutate(sweep = 3, .before = 1) %>%
  rename_with(~ str_remove(.x, "^C"))

df_3y_noprefix
df_5y_noprefix

bind_rows(df_3y_noprefix, df_5y_noprefix) %>%
  arrange(MCSID, CNUM00, sweep) # Sorts the dataset by ID and sweep

bind_rows(df_3y_noprefix, df_5y_noprefix) %>%
    complete(sweep, MCSID, CNUM00) %>% # Ensure cohort members have a row for each sweep
    arrange(MCSID, CNUM00, sweep) 

library(glue)
fups <- c(0, 3, 5, 7, 11, 14, 17)

load_height_wide <- function(sweep){
  fup <- fups[sweep]
  prefix <- LETTERS[sweep]
  
  glue("{fup}y/mcs{sweep}_cm_interview.dta") %>%
    read_dta(col_select = c("MCSID", matches("^.(CNUM00|CHTCM(A|0)0)"))) %>%
    rename(CNUM00 = matches("CNUM00"))
}

load_height_wide(2)
load_height_wide(3)

load_height_wide(2) %>%
  full_join(load_height_wide(3), by = c("MCSID", "CNUM00")) %>%
  full_join(load_height_wide(4), by = c("MCSID", "CNUM00")) %>%
  full_join(load_height_wide(6), by = c("MCSID", "CNUM00")) %>%
  full_join(load_height_wide(7), by = c("MCSID", "CNUM00"))

map(2:7, ~ load_height_wide(.x))

map(2:7, load_height_wide) %>%
  reduce(~ full_join(.x, .y, by = c("MCSID", "CNUM00")))

load_height_long <- function(sweep){
  fup <- fups[sweep]
  prefix <- LETTERS[sweep]
  
  glue("{fup}y/mcs{sweep}_cm_interview.dta") %>%
    read_dta(col_select = c("MCSID", matches("^.(CNUM00|CHTCM(A|0)0)"))) %>%
    rename_with(~ str_replace(.x, glue("^{prefix}"), "")) %>%
    mutate(sweep = !!sweep, .before = 1)
}

map_dfr(2:7, ~ load_height_long(.x))

df_parent_5y <- read_dta("5y/mcs3_parent_cm_interview.dta",
                         col_select = c("MCSID", "CCNUM00", "CPNUM00", "CELIG00", "CPFRTP00"))

df_parent_7y <- read_dta("7y/mcs4_parent_cm_interview.dta",
                         col_select = c("MCSID", "DCNUM00", "DPNUM00", "DELIG00", "DPFRTP00"))

df_parent_5y %>%
  full_join(df_parent_7y, 
             by = c("MCSID",
                    "CCNUM00" = "DCNUM00",
                    "CPNUM00" = "DPNUM00")) # Merge by person

df_parent_5y %>%
  full_join(df_parent_7y, 
            by = c("MCSID", 
                   "CCNUM00" = "DCNUM00",
                   "CELIG00" = "DELIG00"))  # Merge by interview type
