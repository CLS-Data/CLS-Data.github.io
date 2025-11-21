library(tidyverse)
library(knitr)
library(glue)
library(quarto)

rm(list = ls())


# 0. Set Up Environment ----
dir.create("purl")

quarto_files <- list.files("quarto", "\\.qmd$") %>%
  set_names(., .)
# quarto_file <- "bcs70-data_discovery.qmd" 

# 1. Extract Chunks ----
extract_chunks <- function(quarto_file){
  purl_file <- str_replace(quarto_file, "\\.qmd$", ".R") %>%
    file.path("purl", .)
  
  purl(file.path("quarto", quarto_file), 
       purl_file, 
       documentation = 0)
  
  tibble(line = read_lines(purl_file)) %>%
    filter(!str_detect(line, "Sys\\.getenv")) %>%
    filter(!(line == "" & lead(line) == "")) %>%
    pull(line) %>%
    write_lines(purl_file)
  
  return(quarto_file)
}

walk(quarto_files, extract_chunks)

# 2. Add Download Link ----
add_download_link <- function(quarto_file){
  
  quarto_path <- file.path("quarto", quarto_file)
  
  qmd <- read_lines(quarto_path)
  yaml_indices <- which(qmd == "---")
  
  purl_file <- str_replace(quarto_file, "\\.qmd$", ".R") %>%
    file.path("purl", .)
  do_file <- str_replace(quarto_file, "\\.qmd$", ".do") %>%
    file.path("do_files", .)
  download_links <- c(glue("- [Download the R script for this page](../{purl_file})"),
                     glue("- [Download the equivalent Stata script for this page](../{do_file})")) %>%
    glue_collapse("\n")
  
  if (!any(str_detect(qmd, "Download the R script for this page"))){
    qmd_download <- append(qmd, 
                           values = c("", download_links, ""), 
                           after = yaml_indices[2]) %>%
      tibble(line = .) %>%
      filter(!(line == "" & lead(line) == "")) %>%
      pull(line)
    
    write_lines(qmd_download, quarto_path)
    
    return("Added download link")
  } else{
    return("Download link already exists")
  }
  
}

map(quarto_files, add_download_link)


# 3. Remove Download Link ----
remove_download_link <- function(quarto_file){
  
  quarto_path <- file.path("quarto", quarto_file)
  qmd <- read_lines(quarto_path)
  
  if (any(str_detect(qmd, "Download the R script for this page"))){
    qmd_remove <- tibble(line = qmd) %>%
      filter(!str_detect(line, "Download the R script for this page"),
             !str_detect(line, "Download the equivalent Stata script for this page")) %>%
      filter(!(line == "" & lead(line) == "")) %>%
      pull(line)
    
    write_lines(qmd_remove, quarto_path)
    
    return("Removed download link")
  } else{
    return("No link present")
  }
  
}

map(quarto_files, remove_download_link)


# 4. Render Quarto Pages ----
make_quarto <- function(quarto_file){
  
  quarto_path <- file.path("quarto", quarto_file)
  
  md_path <- str_replace(quarto_file, "\\.qmd$", ".md")
  
  study <- str_extract(quarto_file, "^[^-]+")
  study_fld <- glue("{study}_fld") %>% Sys.getenv()
  
  quarto_render(quarto_path,
                output_file = md_path,
                execute_dir = study_fld)
}

make_quarto("bcs70-data_discovery.qmd")
map(quarto_files, make_quarto)


# 5. Move /docs/quarto ----
list.files("docs/quarto", "\\.md$", full.names = TRUE) %>%
  file.copy("docs", overwrite = TRUE)
unlink("docs/quarto", recursive = TRUE)
