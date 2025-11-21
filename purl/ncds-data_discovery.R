# Load Packages
library(tidyverse) # For data manipulation
library(haven) # For importing .dta files
library(labelled) # For searching imported datasets
library(codebookr) # For creating .docx codebooks

ncds_55y <- read_dta("55y/ncds_2013_derived.dta")

lookfor(ncds_55y, "height")

ncds_55y_lookfor <- lookfor(ncds_55y) %>%
  as_tibble() %>%
  mutate(variable_low = str_to_lower(variable),
         label_low = str_to_lower(label))

ncds_55y_lookfor %>%
  filter(str_detect(label_low, "height"))

cdb <- codebook(ncds_55y)
print(cdb, "ncds_55y_codebook.docx") # Saves as .docx (Word) file

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
  filter(str_detect(label_low, "height")) %>%
  select(file, variable, label)
