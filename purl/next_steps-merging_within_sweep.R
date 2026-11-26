# Load Packages
library(tidyverse) # For data manipulation
library(haven) # For importing .dta files

yp <- read_dta("safeguarded_eul/wave_one_lsype_young_person_2020.dta") # One row per cohort member
family <- read_dta("safeguarded_eul/wave_one_lsype_family_background_2020.dta") # One row per cohort member
hhgrid <- read_dta("household_grids/wave_one_lsype_household_grid_file_2020.dta") # One row per household member

df_yp <- yp %>%
  select(NSID, sex = W1sexYP, school_attitude = W1yschat1) # Retains the listed variables, renaming W1sexYP as sex and W1yschat1 as school_attitude

df_yp

df_tenure <- family %>%
  select(NSID, tenure = W1hous12HH)

df_nssec <- family %>%
  select(NSID, W1nssecMP, W1nssecSP) %>%
  mutate(across(c(W1nssecMP, W1nssecSP),
                ~ if_else(between(.x, 1, 8), as.numeric(.x), NA))) %>% # Values outside 1-8 denote various forms of missingness
  mutate(family_nssec = pmin(W1nssecMP, W1nssecSP, na.rm = TRUE)) %>% # Takes the lowest value of the two variables in each row
  select(NSID, family_nssec)

df_nssec

df_parent <- family %>%
  select(NSID, W1HhIDMP = W1mainres, W1HhIDSP = W1secores, W1nssecMP, W1nssecSP) %>%
  zap_labels() %>% # Removes value labels
  pivot_longer(cols = -NSID, # Reshape all columns except NSID
               names_to = c(".value", "parent"),
               names_pattern = "^(.*)(MP|SP)$")

df_parent

df_mother_nssec <- hhgrid %>%
  select(NSID, W1HhID, W1Sex, W1R_1) %>%
  inner_join(df_parent, by = c("NSID", "W1HhID")) %>%
  filter(W1R_1 == 8, # Keep natural parents...
         W1Sex == 2) %>% # ...who are female
  add_count(NSID) %>% # Creates new variable (n) containing # of records with given NSID
  filter(n == 1) %>% # Keep where only one natural mother identified per cohort member
  mutate(mother_nssec = if_else(between(W1nssec, 1, 8), W1nssec, NA)) %>%
  select(NSID, mother_nssec)

df_siblings <- hhgrid %>%
  select(NSID, W1HhID, W1R_1) %>%
  group_by(NSID) %>% # Groups the data so summarise() is performed per cohort member
  summarise(n_siblings = sum(W1R_1 %in% 13:17), # Counts the number of rows where W1R_1 is between 13 and 17
            .groups = "drop") # Removes the grouping from the resulting dataframe

df_siblings

df_yp %>%
  left_join(df_tenure, by = "NSID") %>%
  left_join(df_nssec, by = "NSID") %>%
  left_join(df_mother_nssec, by = "NSID") %>%
  left_join(df_siblings, by = "NSID")
