library(tidyverse)
library(haven)
library(glue)

fups <- c(0, 3, 5, 7, 11, 14, 17)
mcs_fld <- Sys.getenv("mcs_fld")

load_hhgrid_rel <- function(sweep){
  file_path <- glue("{mcs_fld}/{fups[sweep]}y/mcs{sweep}_hhgrid.dta")
  
  read_dta(file_path) %>%
    select(MCSID, ego = matches("^.PNUM"), matches("PREL")) %>%
    pivot_longer(matches("PREL"), names_to = "alt", values_to = "rel") %>%
    filter(rel != -1) %>%
    mutate(sweep = !!sweep)
}

map_dfr(1:7, load_hhgrid_rel) %>% filter(ego < 100) %>%
  mutate(pos = case_when(sweep %in% 1:4 ~ -2,
                         sweep == 5 ~ -3,
                         sweep %in% 6:7 ~ -1),
         alt = str_sub(alt, pos, pos) %>% 
           match(LETTERS)) %>%
  filter(rel == 96) %>%
  ungroup() %>%
  filter(ego != alt)


load_hhgrid_id <- function(sweep){
  file_path <- glue("{mcs_fld}/{fups[sweep]}y/mcs{sweep}_hhgrid.dta")
  
  read_dta(file_path) %>%
    select(MCSID, cnum = matches("^.CNUM"), pnum = matches("^.PNUM")) %>%
    mutate(sweep = !!sweep)
}

map_dfr(1:7, load_hhgrid_id) %>%
  filter(cnum %in% 1:2) %>%
  count(sweep, cnum, pnum)
