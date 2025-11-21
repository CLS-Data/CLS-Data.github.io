library(tidyverse)
library(haven)
library(janitor)

rm(list = ls())

setwd(Sys.getenv("mcs_fld"))


# 1. Straightforward merge (wide) ----
df_0y_hhgrid <- read_dta("0y/mcs1_hhgrid.dta") %>%
  select(MCSID, APNUM00, AHPSEX00, AHCREL00)

df_0y_parent <- read_dta("0y/mcs1_parent_interview.dta") %>%
  select(MCSID, APNUM00, APSMUS0A)


df_0y_hhgrid %>% lookfor()


df_0y_hhgrid %>%
  count(AHPSEX00)

df_0y_hhgrid %>%
  count(AHCREL00)

df_0y_mothers <- df_0y_hhgrid %>%
  filter(AHCREL00 == 7,
         AHPSEX00 == 2) %>%
  add_count(MCSID) %>%
  filter(n == 1) %>%
  select(MCSID, APNUM00)

df_0y_parent %>%
  count(APSMUS0A)

df_0y_smoking <- df_0y_parent %>%
  mutate(smoker = case_when(APSMUS0A %in% 2:95 ~ 1,
                            APSMUS0A == 1 ~ 0)) %>%
  select(MCSID, APNUM00, smoker)


df_0y_mothers %>%
  left_join(df_0y_smoking, by = c("MCSID", "APNUM00")) %>%
  select(MCSID, mother_smoker = smoker) %>%
  tabyl(mother_smoker)
