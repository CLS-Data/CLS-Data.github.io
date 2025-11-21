# Load Packages
library(tidyverse) # For data manipulation
library(haven) # For importing .dta files
library(labelled) # For searching imported datasets
library(codebookr) # For creating .docx codebooks

mcs_17y <- read_dta("17y/mcs7_cm_derived.dta")

lookfor(mcs_17y, "sdq")

mcs_17y_lookfor <- lookfor(mcs_17y) %>%
  as_tibble() %>%
  mutate(variable_low = str_to_lower(variable),
         label_low = str_to_lower(label))

mcs_17y_lookfor %>%
  filter(str_detect(label_low, "sdq"))

cdb <- codebook(mcs_17y)
print(cdb, "mcs_17y_codebook.docx") # Saves as .docx (Word) file

create_lookfor <- function(file_path){
  read_dta(file_path, n_max = 1) %>%
    lookfor() %>%
    as_tibble()
}

df_lookfor <- tibble(file_path = list.files(pattern = "\\.dta$", recursive = TRUE)) %>%
  filter(!str_detect(file_path, "^UKDS")) %>%
  mutate(lookfor = map(file_path, create_lookfor)) %>%
  unnest(lookfor) %>%
  mutate(variable_low = str_to_lower(variable),
         label_low = str_to_lower(label)) %>%
  separate(file_path, 
           into = c("sweep", "file"), 
           sep = "/", 
           remove = FALSE) %>% 
  relocate(file_path, pos, .after = last_col())

df_lookfor %>%
  filter(str_detect(label_low, "sdq")) %>%
  select(file, variable, label)
