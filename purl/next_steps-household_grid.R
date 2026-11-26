# Load Packages
library(tidyverse) # For data manipulation
library(haven) # For importing .dta files

df_w1_hhgrid <- read_dta("household_grids/wave_one_lsype_household_grid_file_2020.dta") %>%
  select(NSID, W1HhID, W1Sex, W1R_1, W1EmpStat) # Retains the listed variables

df_w1_hhgrid %>%
  count(W1Sex) # Tabulates each sex

df_w1_hhgrid %>%
  count(W1R_1) # Tabulates each relationship to the cohort member

df_w1_mothers <- df_w1_hhgrid %>%
  filter(
    W1R_1 == 8, # Keep natural parents of the cohort member...
    W1Sex == 2 # ...who are female.
  ) %>%
  add_count(NSID) %>% # Creates new variable (n) containing # of records with given NSID
  filter(n == 1) %>% # Keep where only one recorded natural mother per family
  select(NSID, W1HhID, W1EmpStat) # Keep identifier variables and employment status

df_w1_mothers %>%
  count(W1EmpStat)

df_w1_mother_works <- df_w1_mothers %>%
  mutate(mother_works = case_when(W1EmpStat %in% 1:2 ~ 1, # If W1EmpStat is 1 or 2, then 1
                                  W1EmpStat %in% 3:9 ~ 0)) %>% # If W1EmpStat is between 3 and 9, then 0
  select(NSID, mother_works)

df_w1_mother_works %>%
  count(mother_works) %>%
  mutate(prop = n / sum(n))

df_w1_parents <- read_dta("household_grids/wave_one_lsype_household_grid_file_2020.dta") %>%
  select(NSID, W1HhID, W1Sex, W1R_1, W1mainres, W1secores) %>%
  mutate(role = case_when(W1HhID == W1mainres ~ "Main parent",
                          W1HhID == W1secores ~ "Second parent")) %>%
  drop_na(role) # Drops rows for individuals who are not the main or second parent

df_w1_parents %>%
  mutate(across(c(W1Sex, W1R_1), as_factor)) %>%
  count(role, W1Sex, W1R_1) %>%
  print(n = Inf) # Prints all rows

df_w1_main <- read_dta("household_grids/wave_one_lsype_household_grid_file_2020.dta") %>%
  filter(W1HhID == W1mainres) %>% # Keeps the row for the main parent
  mutate(w1_main_hhid = zap_labels(W1HhID)) %>% # Removes value labels
  select(NSID, w1_main_hhid)

df_w2_main <- read_dta("household_grids/wave_two_lsype_household_grid_file_2020.dta") %>%
  filter(W2HhID == W2mainres) %>%
  mutate(w2_main_hhid = zap_labels(W2HhID)) %>%
  select(NSID, w2_main_hhid)

df_main <- df_w1_main %>%
  inner_join(df_w2_main, by = "NSID")

df_main %>%
  count(same_person = w1_main_hhid == w2_main_hhid)

df_w1_hhgrid_rel <- read_dta("household_grids/wave_one_lsype_household_grid_file_2020.dta") %>%
  select(NSID, W1HhID, matches("^W1R_\\d+$"))

df_w1_hhgrid_rel %>%
  filter(NSID == first(NSID)) %>% # To look at just one household
  select(W1HhID, W1R_1, W1R_2, W1R_3) # To look at first few relationship variables

df_w1_couples <- df_w1_hhgrid_rel %>%
  pivot_longer(cols = matches("^W1R_\\d+$"),
               names_to = "W1HhID_alter",
               names_prefix = "W1R_", # Removes "W1R_" from the names, leaving the alter's person number
               names_transform = as.integer, # Converts the alter's person number to an integer
               values_to = "relationship") %>%
  filter(relationship %in% 1:2) %>% # Keep where husband/wife or partner/cohabitee
  mutate(W1HhID = as.integer(W1HhID)) %>% # Converts the person number to an integer (removing its value labels)
  select(NSID, W1HhID, partner_hhid = W1HhID_alter)

df_w1_couples

df_w1_couples_rev <- df_w1_couples %>%
  select(NSID, W1HhID = partner_hhid, partner_hhid = W1HhID) # Swaps the person numbers of the two partners

bind_rows(df_w1_couples, df_w1_couples_rev) %>% # Appends the two datasets
  arrange(NSID, W1HhID) # Sorts the dataset by ID and person number
