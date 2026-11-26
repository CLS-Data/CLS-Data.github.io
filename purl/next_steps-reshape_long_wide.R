# Load Packages
library(tidyverse) # For data manipulation
library(haven) # For importing .dta files

df_w8 <- read_dta("safeguarded_eul/ns8_2015_main_interview.dta",
                  col_select = c("NSID", "W8HEIGHT", "W8WEIGHT"))

df_w9 <- read_dta("safeguarded_eul/ns9_2022_main_interview.dta",
                  col_select = c("NSID", "W9HEIGHT", "W9WEIGHT"))

df_wide <- df_w8 %>%
  full_join(df_w9, by = "NSID")

df_wide

df_long <- df_wide %>%
  pivot_longer(cols = matches("^W\\d(HEIGHT|WEIGHT)$"),
               names_to = c("sweep", ".value"),
               names_pattern = "^W(\\d)(.*)$",
               names_transform = list(sweep = as.integer))

df_long

df_long %>%
  pivot_wider(names_from = sweep,
              values_from = c(HEIGHT, WEIGHT),
              names_glue = "W{sweep}{.value}")

ages <- c(14, 15, 16, 17, 18, 19, 20, 25, 32)

df_long_clean <- df_long %>%
  mutate(age = ages[sweep],
         height = ifelse(HEIGHT > 0, HEIGHT, NA),
         weight = ifelse(WEIGHT > 0, WEIGHT, NA)) %>%
  select(NSID, age, height, weight)

df_long_clean

df_wide_clean <- df_long_clean %>%
  pivot_wider(names_from = age,
              values_from = c(height, weight),
              names_glue = "{.value}_{age}")

df_wide_clean

df_wide_clean %>%
  pivot_longer(cols = matches("_\\d\\d$"),
               names_to = c(".value", "age"),
               names_pattern = "(.*)_(\\d\\d)$",
               names_transform = list(age = as.integer))
