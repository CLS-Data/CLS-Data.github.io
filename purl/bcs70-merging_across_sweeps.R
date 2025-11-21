# Load Packages
library(tidyverse) # For data manipulation
library(haven) # For importing .dta files

df_42y <- read_dta("42y/bcs70_2012_derived.dta",
                      col_select = c("BCSID", "BD9HGHTM"))

df_51y <- read_dta("51y/bcs11_age51_main.dta",
                   col_select = c("bcsid", "bd11hghtm"))

df_42y %>%
full_join(df_51y, by = c(BCSID = "bcsid"))

df_42y %>%
inner_join(df_51y, by = c(BCSID = "bcsid"))

df_42y %>%
left_join(df_51y, by = c(BCSID = "bcsid"))

df_42y %>%
right_join(df_51y, by = c(BCSID = "bcsid"))

df_42y %>%
rename_with(str_to_lower) %>% # Converts all variable names to upper case
full_join(df_51y)

df_42y_nosuffix <- df_42y %>%
rename_with(str_to_lower) %>%
rename_with(~ str_remove(.x, "^bd9")) %>%  # Removes the suffix '23' from variable names
mutate(sweep = 9, .before = 1)

df_51y_nosuffix <- df_51y %>%
rename_with(~ str_remove(.x, "^bd11")) %>%
mutate(sweep = 11, .before = 1)

df_42y_nosuffix
df_51y_nosuffix

bind_rows(df_42y_nosuffix, df_51y_nosuffix) %>%
arrange(BCSID, sweep) # Sorts the dataset by ID and sweep

bind_rows(df_42y_nosuffix, df_51y_nosuffix) %>%
complete(BCSID, sweep) %>% # Ensure cohort members have a row for each sweep
arrange(BCSID, sweep) 
