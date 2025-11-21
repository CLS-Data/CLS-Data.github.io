# Load Packages
library(tidyverse) # For data manipulation
library(haven) # For importing .dta files

df_0y_hhgrid <- read_dta("0y/mcs1_hhgrid.dta") %>%
  select(MCSID, APNUM00, AHPSEX00, AHCREL00) # Retains the listed variables

df_0y_hhgrid %>%
  count(AHPSEX00) # Tabulates each sex; AHPSEX00 does not record the sex of cohort members

df_0y_hhgrid %>%
  count(AHCREL00) # Tabulates each relationship to a cohort member

df_0y_mothers <- df_0y_hhgrid %>%
  filter(
    AHCREL00 == 7, # Keep natural parents...
    AHPSEX00 == 2 # ...who are female.
  ) %>%
  add_count(MCSID) %>% # Creates new variable (n) containing # of records with given MCSID
  filter(n == 1) %>% # Keep where only one recorded natural mother per family
  select(MCSID, APNUM00) # Keep identifier variables

df_0y_parent <- read_dta("0y/mcs1_parent_interview.dta") %>%
  select(MCSID, APNUM00, APSMUS0A) # Retains only the variables we need

df_0y_parent %>%
  count(APSMUS0A)

df_0y_smoking <- df_0y_parent %>%
  mutate(parent_smoker = case_when(APSMUS0A %in% 2:95 ~ 1, # If APSMUS0A is integer between 2 and 95, then 1
                            APSMUS0A == 1 ~ 0)) %>% # If APSMUS0A is 1, then 0
  select(MCSID, APNUM00, parent_smoker)

# install.packages("janitor") # Uncomment if you need to install
library(janitor)
df_0y_mothers %>%
  left_join(df_0y_smoking, by = c("MCSID", "APNUM00")) %>%
  select(MCSID, mother_smoker = parent_smoker) %>%
  tabyl(mother_smoker)

df_0y_hhgrid_prel <- read_dta("0y/mcs1_hhgrid.dta") %>%
  select(MCSID, APNUM00, matches("AHPREL[A-Z]0"))

df_0y_hhgrid_prel %>%
  filter(MCSID == "M10001N") %>% # To look at just one family
  select(APNUM00, AHPRELA0, AHPRELB0, AHPRELC0) # To look at first few relationship variables

df_0y_hhgrid_prel %>%
  pivot_longer(cols = matches("AHPREL[A-Z]0"),
               names_to = "alt",
               values_to = "relationship") %>%
  mutate(APNUM00_alt = match(str_sub(alt, -2, -2), LETTERS)) %>% # Creates alt's PNUM00 by matching penultimate letter to position in alphabet
  filter(relationship == 1) %>% # Keep where husband or wife
  select(MCSID, APNUM00, partner_pnum = APNUM00_alt)
