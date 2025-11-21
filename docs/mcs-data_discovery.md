# Data Discovery


- [Download the R script for this page](../purl/mcs-data_discovery.R)
- [Download the equivalent Stata script for this
  page](../do_files/mcs-data_discovery.do)

# Introduction

In this section, we show a few `R` functions for exploring MCS data;
there’s a lot of data in the MCS, so finding a specific variable can be
challenging. Variables do not generally have names that are descriptive
and there can be some slight changes in naming conventions across
sweeps. (The variable for height in centimeters is `ECHTCMA0` in Sweep 5
but `[A-G]CHTCM00` in other sweeps, for example.) In what follows, we
will use the `R` functions to find variables for cohort members’ SDQ,
which has been collected in many of the sweeps.

The packages we will use are:

``` r
# Load Packages
library(tidyverse) # For data manipulation
library(haven) # For importing .dta files
library(labelled) # For searching imported datasets
library(codebookr) # For creating .docx codebooks
```

# `labelled::lookfor()`

The `labelled` package contains functionality for attaching and
examining metadata in dataframes (for instance, adding labels to
variables \[columns\]). Beyond this, it also contains the `lookfor()`
function, which replicates similar functionality in `Stata`. `lookfor()`
also one to search for variables in a dataframe by keyword (regular
expression); the function searches variable names as well as associated
metadata. It returns an object containing matching variables, their
labels, and their types, etc.. Below, we read in the MCS 17-year sweep
(Sweep 7) CM-level derived data which contains derived variables
(`17y/mcs7_cm_derived.dta`) and use `lookfor()` to search for variables
related to the `"SDQ"` (Strengths and Difficulties Questionnaire).

``` r
mcs_17y <- read_dta("17y/mcs7_cm_derived.dta")

lookfor(mcs_17y, "sdq")
```

     pos variable   label                     col_type missing values             
     12  GEMOTION_C S7 DV Self-reported CM s~ dbl+lbl  0       [-9] Refusal       
                                                               [-8] Don't know    
                                                               [-1] Not applicable
     13  GCONDUCT_C S7 DV Self-reported CM s~ dbl+lbl  0       [-9] Refusal       
                                                               [-8] Don't know    
                                                               [-1] Not applicable
     14  GHYPER_C   S7 DV Self-reported CM s~ dbl+lbl  0       [-9] Refusal       
                                                               [-8] Don't know    
                                                               [-1] Not applicable
     15  GPEER_C    S7 DV Self-reported CM s~ dbl+lbl  0       [-9] Refusal       
                                                               [-8] Don't know    
                                                               [-1] Not applicable
     16  GPROSOC_C  S7 DV Self-reported CM s~ dbl+lbl  0       [-9] Refusal       
                                                               [-8] Don't know    
                                                               [-1] Not applicable
     17  GEBDTOT_C  S7 DV Self-reported CM s~ dbl+lbl  0       [-9] Refusal       
                                                               [-8] Don't know    
                                                               [-1] Not applicable
     18  GEMOTION   S7 DV Parent-reported CM~ dbl+lbl  0       [-9] Refusal       
                                                               [-8] Don't know    
                                                               [-1] Not applicable
     19  GCONDUCT   S7 DV Parent-reported CM~ dbl+lbl  0       [-9] Refusal       
                                                               [-8] Don't know    
                                                               [-1] Not applicable
     20  GHYPER     S7 DV Parent-reported CM~ dbl+lbl  0       [-9] Refusal       
                                                               [-8] Don't know    
                                                               [-1] Not applicable
     21  GPEER      S7 DV Parent-reported CM~ dbl+lbl  0       [-9] Refusal       
                                                               [-8] Don't know    
                                                               [-1] Not applicable
     22  GPROSOC    S7 DV Parent-reported CM~ dbl+lbl  0       [-9] Refusal       
                                                               [-8] Don't know    
                                                               [-1] Not applicable
     23  GEBDTOT    S7 DV Parent-reported CM~ dbl+lbl  0       [-9] Refusal       
                                                               [-8] Don't know    
                                                               [-1] Not applicable

Users may consider it easier to create a tibble of the `lookfor()`
output, which can be searched and filtered using `dplyr` functions.
Below, we create a `tibble` (a type of `data.frame` with good printing
defaults) of the `lookfor()` output and use `filter()` to find variables
with `"sdq"` in their labels. Note, we convert both the variable names
and labels to lower case to make the search case insensitive.

``` r
mcs_17y_lookfor <- lookfor(mcs_17y) %>%
  as_tibble() %>%
  mutate(variable_low = str_to_lower(variable),
         label_low = str_to_lower(label))

mcs_17y_lookfor %>%
  filter(str_detect(label_low, "sdq"))
```

    # A tibble: 12 × 9
         pos variable   label      col_type missing levels value_labels variable_low
       <int> <chr>      <chr>      <chr>      <int> <name> <named list> <chr>       
     1    12 GEMOTION_C S7 DV Sel… dbl+lbl        0 <NULL> <dbl [3]>    gemotion_c  
     2    13 GCONDUCT_C S7 DV Sel… dbl+lbl        0 <NULL> <dbl [3]>    gconduct_c  
     3    14 GHYPER_C   S7 DV Sel… dbl+lbl        0 <NULL> <dbl [3]>    ghyper_c    
     4    15 GPEER_C    S7 DV Sel… dbl+lbl        0 <NULL> <dbl [3]>    gpeer_c     
     5    16 GPROSOC_C  S7 DV Sel… dbl+lbl        0 <NULL> <dbl [3]>    gprosoc_c   
     6    17 GEBDTOT_C  S7 DV Sel… dbl+lbl        0 <NULL> <dbl [3]>    gebdtot_c   
     7    18 GEMOTION   S7 DV Par… dbl+lbl        0 <NULL> <dbl [3]>    gemotion    
     8    19 GCONDUCT   S7 DV Par… dbl+lbl        0 <NULL> <dbl [3]>    gconduct    
     9    20 GHYPER     S7 DV Par… dbl+lbl        0 <NULL> <dbl [3]>    ghyper      
    10    21 GPEER      S7 DV Par… dbl+lbl        0 <NULL> <dbl [3]>    gpeer       
    11    22 GPROSOC    S7 DV Par… dbl+lbl        0 <NULL> <dbl [3]>    gprosoc     
    12    23 GEBDTOT    S7 DV Par… dbl+lbl        0 <NULL> <dbl [3]>    gebdtot     
    # ℹ 1 more variable: label_low <chr>

# `codebookr::codebook()`

The MCS datasets that are downloadable from the UK Data Service come
bundled with data dictionaries within the `mrdoc` subfolder. However,
these are limited in some ways. The `codebookr` package enables the
creation of data dictionaries that are more customisable, and in our
opinion, easy to read. Below we create a codebook for the MCS 17-year
sweep derived variable dataset. These codebooks are intended to be saved
and viewed in Microsoft Word.

``` r
cdb <- codebook(mcs_17y)
print(cdb, "mcs_17y_codebook.docx") # Saves as .docx (Word) file
```

A screenshot of the codebook is shown below.

![Codebook created by
codebookr::codebook()](../images/mcs-data_discovery.png)

# Create a Lookup Table Across All Datasets

Creating the `lookfor()` and `codebook()` one dataset at a time does not
allow one to get a quick overview of the variables available in the MCS,
including the sweeps repeatedly measured characteristics are available
in. Below we create a `tibble`, `df_lookfor`, that contains `lookfor()`
results for all the `.dta` files in the MCS folder.

To do this, we create a function, `create_lookfor()`, that takes a file
path to a `.dta` file, reads in the first row of the dataset (faster
than reading the full dataset), and applies `lookfor()` to it. We call
this function with a `mutate()` function call to create a set of lookups
for every `.dta` file we can find in the MCS folder. `map()` loops over
every value in the `file_path` column, creating a corresponding lookup
table for that file, stored as a
[`list-column`](https://r4ds.hadley.nz/rectangling.html#list-columns).
`unnest()` expands the results out, so rather than have one row per
`file_path`, we have one row per variable.

``` r
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
```

We can use the resulting object to search for variables with `"sdq"` in
their labels.

``` r
df_lookfor %>%
  filter(str_detect(label_low, "sdq")) %>%
  select(file, variable, label)
```

    # A tibble: 73 × 3
       file                       variable label                                    
       <chr>                      <chr>    <chr>                                    
     1 mcs5_cm_teacher_survey.dta EEMOTI_T S5 DV TEACHER SDQ Emotional Symptoms     
     2 mcs5_cm_teacher_survey.dta ECOND_T  S5 DV TEACHER SDQ Conduct Problems       
     3 mcs5_cm_teacher_survey.dta EHYPER_T S5 DV TEACHER SDQ Hyperactivity/Inattent…
     4 mcs5_cm_teacher_survey.dta EPEER_T  S5 DV TEACHER SDQ Peer Problems          
     5 mcs5_cm_teacher_survey.dta EPROSO_T S5 DV TEACHER SDQ Prosocial              
     6 mcs5_cm_teacher_survey.dta EEBDTO_T S5 DV TEACHER SDQ Total Difficulties     
     7 mcs5_cm_teacher_survey.dta EEBDIF_T S5 DV TEACHER SDQ CM has Difficulties in…
     8 mcs6_cm_derived.dta        FEMOTION S6 DV Parent-reported CM SDQ Emotional S…
     9 mcs6_cm_derived.dta        FCONDUCT S6 DV Parent-reported CM SDQ Conduct Pro…
    10 mcs6_cm_derived.dta        FHYPER   S6 DV Parent-reported CM SDQ Hyperactivi…
    # ℹ 63 more rows
