library(tidyverse)
library(haven)
library(glue)
library(labelled)

rm(list = ls())

setwd(Sys.getenv("mcs_fld"))

# 1. ----
fups <- c(0, 3, 5, 7, 11, 14, 17)

load_height_wide <- function(sweep){
  fup <- fups[sweep]
  prefix <- LETTERS[sweep]
  
  glue("{fup}y/mcs{sweep}_cm_interview.dta") %>%
    read_dta(col_select = c("MCSID", matches("^.(CNUM00|C(W|H)TCM(A|0)0)"))) %>%
    rename(cnum = matches("CNUM00"))
}

df_wide <- map(2:7, load_height_wide) %>%
  reduce(~ full_join(.x, .y, by = c("MCSID", "cnum")))

df_long <- df_wide %>%
  pivot_longer(cols = -c(MCSID, cnum),
               names_to = c("sweep", ".value"),
               names_pattern = "(.)(.*)")

# 2. ----
df_long %>%
  pivot_wider(names_from = sweep,
              values_from = matches("C(W|H)T"),
              names_glue = "{sweep}{.value}")

df_long %>%
  mutate(cnum = as.integer(cnum),
         sweep = match(sweep, LETTERS),
         fup = fups[sweep],
         height = ifelse(!is.na(CHTCM00), CHTCM00, CHTCMA0),
         weight = ifelse(!is.na(CWTCM00), CWTCM00, CWTCMA0)) %>%
  select(MCSID, cnum, fup, height, weight) %>%
  pivot_wider(names_from = fup,
              values_from = c(height, weight),
              names_glue = "{.value}_{fup}y")


df_long_clean <- df_long %>%
  mutate(cnum = as.integer(cnum),
         sweep = match(sweep, LETTERS),
         fup = fups[sweep],
         height = ifelse(CHTCM00 > 0, CHTCM00, NA),
         weight = ifelse(CWTCM00 > 0, CWTCM00, NA)) %>%
  select(MCSID, cnum, fup, height, weight)
  
df_wide_clean <- df_long_clean %>%
  pivot_wider(names_from = fup,
              values_from = c(height, weight),
              names_glue = "{.value}_{fup}y")

df_wide_clean


df_wide_clean %>%
  pivot_longer(cols = matches("_(\\d+)$"),
               names_to = c(".value", "fup"),
               names_pattern = "(.*)_(\\d+)$",
               names_transform = list(fup = as.integer))

