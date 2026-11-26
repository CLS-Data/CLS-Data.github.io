# Load Packages
library(tidyverse) # For data manipulation
library(haven) # For importing .dta files
library(labelled) # For handling missing values

df_w2 <- read_dta("safeguarded_eul/wave_two_lsype_young_person_2020.dta",
                  col_select = c("NSID", "W2ghq12scr"))

df_w4 <- read_dta("safeguarded_eul/wave_four_lsype_young_person_2020.dta",
                  col_select = c("NSID", "W4ghq12scr"))

df_w2 %>%
  full_join(df_w4, by = "NSID")

df_w2 %>%
  inner_join(df_w4, by = "NSID")

df_w2 %>%
  left_join(df_w4, by = "NSID")

df_w2 %>%
  right_join(df_w4, by = "NSID")

df_w2_noprefix <- df_w2 %>%
  mutate(sweep = 2, .before = 1) %>%
  rename_with(~ str_remove(.x, "^W2"))

df_w4_noprefix <- df_w4 %>%
  mutate(sweep = 4, .before = 1) %>%
  rename_with(~ str_remove(.x, "^W4"))

df_w2_noprefix
df_w4_noprefix

bind_rows(df_w2_noprefix, df_w4_noprefix) %>%
  arrange(NSID, sweep) # Sorts the dataset by ID and sweep

bind_rows(df_w2_noprefix, df_w4_noprefix) %>%
  complete(NSID, sweep) %>% # Ensure cohort members have a row for each sweep
  arrange(NSID, sweep)

df_files <- tribble(
  ~sweep, ~file,                                                   ~ghq_var,
  2,      "safeguarded_eul/wave_two_lsype_young_person_2020.dta",  "W2ghq12scr",
  4,      "safeguarded_eul/wave_four_lsype_young_person_2020.dta", "W4ghq12scr",
  8,      "safeguarded_eul/ns8_2015_derived.dta",                  "W8DGHQSC",
  9,      "safeguarded_eul/ns9_2022_derived_variables.dta",        "W9DGHQSC"
)

df_files

load_ghq_wide <- function(sweep, file, ghq_var){
  read_dta(file, col_select = all_of(c("NSID", ghq_var)))
}

load_ghq_wide(8, "safeguarded_eul/ns8_2015_derived.dta", "W8DGHQSC")

load_ghq_wide(2, "safeguarded_eul/wave_two_lsype_young_person_2020.dta", "W2ghq12scr") %>%
  full_join(load_ghq_wide(4, "safeguarded_eul/wave_four_lsype_young_person_2020.dta", "W4ghq12scr"),
            by = "NSID") %>%
  full_join(load_ghq_wide(8, "safeguarded_eul/ns8_2015_derived.dta", "W8DGHQSC"),
            by = "NSID") %>%
  full_join(load_ghq_wide(9, "safeguarded_eul/ns9_2022_derived_variables.dta", "W9DGHQSC"),
            by = "NSID")

pmap(df_files, load_ghq_wide)

df_ghq_wide <- pmap(df_files, load_ghq_wide) %>%
  reduce(~ full_join(.x, .y, by = "NSID"))

df_ghq_wide

load_ghq_long <- function(sweep, file, ghq_var){
  read_dta(file, col_select = all_of(c("NSID", ghq_var))) %>%
    rename(ghq12 = all_of(ghq_var)) %>%
    mutate(ghq12 = zap_labels(ghq12),
           sweep = sweep, .before = 1)
}

df_ghq_long <- pmap(df_files, load_ghq_long) %>%
  bind_rows() %>%
  arrange(NSID, sweep) # Sorts the dataset by ID and sweep

df_ghq_long

negative_to_na <- function(x){
  na_range(x) <- c(-Inf, -1)
  user_na_to_na(x)
}

df_ghq_long %>%
  mutate(ghq12 = negative_to_na(ghq12)) # Replaces negative values with NA

df_longitudinal <- read_dta("safeguarded_eul/ns9_2022_longitudinal_file.dta",
                            col_select = c("NSID", "MAINBOOST", matches("^W\\dOUTCOME$")))

df_longitudinal %>%
  count(MAINBOOST)

df_longitudinal %>%
  left_join(df_ghq_wide, by = "NSID")
