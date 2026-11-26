# Load Packages
library(tidyverse) # For data manipulation
library(haven) # For importing .dta files
library(labelled) # For searching imported datasets
library(codebookr) # For creating .docx codebooks

ns_w8 <- read_dta("safeguarded_eul/ns8_2015_derived.dta")

lookfor(ns_w8, "ghq")

ns_w8_lookfor <- lookfor(ns_w8) %>%
  as_tibble() %>%
  mutate(variable_low = str_to_lower(variable),
         label_low = str_to_lower(label))

ns_w8_lookfor %>%
  filter(str_detect(label_low, "ghq"))

cdb <- codebook(ns_w8)
print(cdb, "ns_w8_codebook.docx") # Saves as .docx (Word) file

create_lookfor <- function(file_path){
  read_dta(file_path, n_max = 1) %>%
    lookfor() %>%
    as_tibble()
}

folders <- c("activity_histories", "household_grids", "safeguarded_eul")

df_lookfor <- tibble(file_path = list.files(folders, pattern = "\\.dta$", full.names = TRUE)) %>%
  mutate(lookfor = map(file_path, create_lookfor)) %>%
  unnest(lookfor) %>%
  mutate(variable_low = str_to_lower(variable),
         label_low = str_to_lower(label),
         sweep = str_extract(variable_low, "^w(\\d)", group = 1) %>%
           as.integer()) %>%
  separate(file_path,
           into = c("folder", "file"),
           sep = "/",
           remove = FALSE) %>%
  relocate(sweep, .after = file) %>%
  relocate(file_path, pos, .after = last_col())

df_lookfor %>%
  filter(str_detect(label_low, "ghq")) %>%
  select(file, sweep, variable, label)

df_lookfor %>%
  filter(str_detect(label_low, "ghq"),
         str_detect(label_low, "score")) %>%
  select(file, sweep, variable, label)
