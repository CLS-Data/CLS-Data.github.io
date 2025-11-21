# Load Packages
library(tidyverse) # For data manipulation
library(haven) # For importing .dta files
library(glue) # For creating strings

fups <- c(0, 3, 5, 7, 11, 14, 17)

load_height_wide <- function(sweep){
  fup <- fups[sweep]
  prefix <- LETTERS[sweep]
  
  glue("{fup}y/mcs{sweep}_cm_interview.dta") %>%
    read_dta(col_select = c("MCSID", matches("^.(CNUM00|C(H|W)TCM(A|0)0)"))) %>%
    rename(CNUM00 = matches("CNUM00"))
}

df_wide <- map(3:7, load_height_wide) %>%
  reduce(~ full_join(.x, .y, by = c("MCSID", "CNUM00"))) %>%
  rename(ECHTCM00 = ECHTCMA0, ECWTCMA00 = ECWTCMA0)

df_wide

df_long <- df_wide %>%
  pivot_longer(cols = matches("C(H|W)TCM00"),
               names_to = c("sweep", ".value"),
               names_pattern = "(.)(.*)")

df_long

df_long %>%
  pivot_wider(names_from = sweep,
              values_from = matches("C(W|H)T"),
              names_glue = "{sweep}{.value}")

df_long_clean <- df_long %>%
  mutate(cnum = as.integer(CNUM00),
         sweep = match(sweep, LETTERS),
         fup = fups[sweep],
         height = ifelse(CHTCM00 > 0, CHTCM00, NA),
         weight = ifelse(CWTCM00 > 0, CWTCM00, NA)) %>%
  select(MCSID, cnum, fup, height, weight)

df_wide_clean <- df_long_clean %>%
  mutate(fup = ifelse(fup < 10, glue("0{fup}"), as.character(fup))) %>%
  pivot_wider(names_from = fup,
              values_from = c(height, weight),
              names_glue = "{.value}_{fup}")

df_wide_clean

df_wide_clean %>%
  pivot_longer(cols = matches("_\\d\\d$"),
               names_to = c(".value", "fup"),
               names_pattern = "(.*)_(\\d\\d)$",
               names_transform = list(fup = as.integer))
