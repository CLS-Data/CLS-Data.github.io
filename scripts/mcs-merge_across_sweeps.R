library(tidyverse)
library(haven)
library(labelled)

rm(list = ls())

setwd(Sys.getenv("mcs_fld"))


# 1. Straightforward merge (wide) ----
df_3y <- read_dta("3y/mcs2_cm_interview.dta") %>%
  select(MCSID, BCNUM00, BCHTCM00)

df_5y <- read_dta("5y/mcs3_cm_interview.dta") %>%
  select(MCSID, CCNUM00, CCHTCM00)


df_3y %>%
  full_join(df_5y, by = c("MCSID", BCNUM00 = "CCNUM00"))

df_3y %>%
  left_join(df_5y, by = c("MCSID", BCNUM00 = "CCNUM00"))

df_3y %>%
  inner_join(df_5y, by = c("MCSID", BCNUM00 = "CCNUM00"))


# 2. Append ----
df_3y_nopre <- df_3y %>%
  mutate(sweep = 2, .before = 1) %>%
  rename_with(~ str_replace(.x, "^B", ""))

df_5y_nopre <- df_5y %>%
  mutate(sweep = 3, .before = 1) %>%
  rename_with(~ str_replace(.x, "^C", ""))

bind_rows(df_3y_nopre, df_5y_nopre)

# 3. Doing it programatically ----
df_3y_rename <- df_3y %>%
  rename(cnum = BCNUM00)
df_5y_rename <- df_5y %>%
  rename(cnum = CCNUM00)

df_3y_rename %>%
  full_join(df_5y_rename, by = c("MCSID", "cnum"))

library(glue)
fups <- c(0, 3, 5, 7, 11, 14, 17)

load_height_long <- function(sweep){
  fup <- fups[sweep]
  prefix <- LETTERS[sweep]
  
  glue("{fup}y/mcs{sweep}_cm_interview.dta") %>%
    read_dta(col_select = c("MCSID", matches("CNUM00|CHTCM00"))) %>%
    rename_with(~ str_replace(.x, glue("^{prefix}"), "")) %>%
    mutate(sweep = !!sweep, .before = 1)
}

bind_rows(load_height_long(2),
          load_height_long(3), 
          load_height_long(4),
          load_height_long(6),
          load_height_long(7))

map_dfr(c(2:4, 6:7), load_height_long)

load_height_wide <- function(sweep){
  fup <- fups[sweep]
  prefix <- LETTERS[sweep]
  
  glue("{fup}y/mcs{sweep}_cm_interview.dta") %>%
    read_dta(col_select = c("MCSID", matches("CNUM00|CHTCM00"))) %>%
    rename(cnum = matches("CNUM00"))
}

load_height_wide(2) %>%
  full_join(load_height_wide(3), by = c("MCSID", "cnum")) %>%
  full_join(load_height_wide(4), by = c("MCSID", "cnum")) %>%
  full_join(load_height_wide(6), by = c("MCSID", "cnum")) %>%
  full_join(load_height_wide(7), by = c("MCSID", "cnum"))

map(c(2:4, 6:7), load_height_wide) %>%
  reduce(~ full_join(.x, .y, by = c("MCSID", "cnum")))



  