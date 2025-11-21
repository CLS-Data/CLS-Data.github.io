# Load Packages
library(tidyverse) # For data manipulation
library(haven) # For importing .dta files

family <- read_dta("3y/mcs2_family_derived.dta") # One row per family
cm <- read_dta("3y/mcs2_cm_derived.dta") # One row per cohort member
parent <- read_dta("3y/mcs2_parent_derived.dta") # One row per parent (responding)
parent_cm <- read_dta("3y/mcs2_parent_cm_interview.dta") # One row per parent (responding) per cohort member
hhgrid <- read_dta("3y/mcs2_hhgrid.dta") # One row per household member

df_ethnic_group <- cm %>%
  select(MCSID, BCNUM00, ethnic_group = BDC08E00) # Retains the listed variables, renaming BDC08E00 as ethnic_group

df_ethnic_group

df_country <- family %>%
  select(MCSID, country = BACTRY00)

df_reads <- parent_cm %>%
  select(MCSID, BPNUM00, BCNUM00, BPOFRE00) %>%
  mutate(parent_reads = case_when(between(BPOFRE00, 1, 3) ~ 1, # Create binary variable for reading habit
                                  between(BPOFRE00, 4, 6) ~ 0)) %>%
  drop_na() %>% # Drops rows with any missing value (ensures we get a value where at least 1 parent gave a valid response).
  group_by(MCSID, BCNUM00) %>% # Groups the data so summarise() is performed per cohort member.
  summarise(parent_reads = max(parent_reads), # Calculates maximum value per cohort member
            .groups = "drop") # Removes the grouping from the resulting dataframe.

df_reads

df_warm <- parent_cm %>%
  select(MCSID, BCNUM00, BELIG00, BPPIAW00) %>%
  mutate(var_name = ifelse(BELIG00 == 1, "main_warm", "secondary_warm"),
         warmth = case_when(BPPIAW00 == 5 ~ 1,
                           between(BPPIAW00, 1, 6) ~ 0)) %>%
  select(MCSID, BCNUM00, var_name, warmth) %>%
  pivot_wider(names_from = var_name, # The new variables are named main_warm and secondary_warm...
              values_from = warmth) # ... and take values from "warmth"

df_nssec <- parent %>%
  select(MCSID, BPNUM00, parent_nssec = BDD05S00) %>%
  mutate(parent_nssec = if_else(parent_nssec < 0, NA, parent_nssec)) %>% # Negative values denote various forms of missingness.
  drop_na() %>%
  group_by(MCSID) %>%
  summarise(family_nssec = min(parent_nssec))

df_mother <- hhgrid %>%
  select(MCSID, BPNUM00, BHCREL00, BHPSEX00) %>%
  filter(between(BPNUM00, 1, 99),
         BHCREL00 == 7,
         BHPSEX00 == 2) %>%
  distinct(MCSID, BPNUM00) %>%
  add_count(MCSID) %>%
  filter(n == 1) %>%
  select(MCSID, BPNUM00)

df_parent_edu <- parent %>%
  select(MCSID, BPNUM00, mother_nvq = BDDNVQ00)

df_mother_edu <- df_parent_edu %>%
  right_join(df_mother, by = c("MCSID", "BPNUM00")) %>%
  select(-BPNUM00)

df_ethnic_group %>%
  left_join(df_country, by = "MCSID") %>%
  left_join(df_reads, by = c("MCSID", "BCNUM00")) %>%
  left_join(df_warm, by = c("MCSID", "BCNUM00")) %>%
  left_join(df_nssec, by = "MCSID") %>%
  left_join(df_mother_edu, by = "MCSID")
