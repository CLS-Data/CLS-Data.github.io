# Load Packages
library(tidyverse) # For data manipulation
library(haven) # For importing .dta files

df_23y <- read_dta("23y/ncds4.dta",
                      col_select = c("ncdsid", "dvwt23"))

df_50y <- read_dta("50y/ncds_2008_followup.dta",
                   col_select = c("NCDSID", "DVWT50"))

df_23y %>%
full_join(df_50y, by = c(ncdsid = "NCDSID"))

df_23y %>%
inner_join(df_50y, by = c(ncdsid = "NCDSID"))

df_23y %>%
left_join(df_50y, by = c(ncdsid = "NCDSID"))

df_23y %>%
right_join(df_50y, by = c(ncdsid = "NCDSID"))

df_23y %>%
rename_with(str_to_upper) %>% # Converts all variable names to upper case
full_join(df_50y)

df_23y_nosuffix <- df_23y %>%
rename_with(str_to_upper) %>%
rename_with(~ str_remove(.x, "23$")) %>%  # Removes the suffix '23' from variable names
mutate(sweep = 23, .before = 1)

df_50y_nosuffix <- df_50y %>%
rename_with(~ str_remove(.x, "50$")) %>%
mutate(sweep = 50, .before = 1)

df_23y_nosuffix
df_50y_nosuffix

bind_rows(df_23y_nosuffix, df_50y_nosuffix) %>%
arrange(NCDSID, sweep) # Sorts the dataset by ID and sweep

bind_rows(df_23y_nosuffix, df_50y_nosuffix) %>%
complete(NCDSID, sweep) %>% # Ensure cohort members have a row for each sweep
arrange(NCDSID, sweep) 
