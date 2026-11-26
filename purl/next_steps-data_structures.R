# Load Packages
library(tidyverse) # For data manipulation
library(haven) # For importing .dta files
library(labelled) # For handling missing values

negative_to_na <- function(x){
  na_range(x) <- c(-Inf, -1)
  user_na_to_na(x)
}

df_w1 <- read_dta("safeguarded_eul/wave_one_lsype_young_person_2020.dta",
                  col_select = c("NSID", "W1alceverYP"))

df_w1 %>%
  count(W1alceverYP) # Tabulates the raw variable

df_w1 %>%
  mutate(W1alceverYP = negative_to_na(W1alceverYP)) %>% # Replaces negative values with NA
  count(W1alceverYP) # Tabulates the cleaned variable
