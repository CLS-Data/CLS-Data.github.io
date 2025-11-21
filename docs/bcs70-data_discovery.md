# Data Discovery


- [Download the R script for this page](../purl/bcs70-data_discovery.R)
- [Download the equivalent Stata script for this
  page](../do_files/bcs70-data_discovery.do)

# Introduction

In this section, we show a few `R` functions for exploring BCS70 data;
as noted, historical sweeps of the BCS70 did not use modern metadata
standards, so finding a specific variable can be challenging. Variables
do not always have names that are descriptive or follow a consistent
naming convention across sweeps. (The variable for cohort member sex in
the `0y/bcs7072a.dta` file is `a0255`, for example.) In what follows, we
will use the `R` functions to find variables on cohort members’ smoking,
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
labels, and their types, etc.. Below, we read in the BCS70 38-year sweep
derived variable dataset (`38y/bcs8derived.dta`) and use `lookfor()` to
search for variables which mention `"smok"` in their name or metadata.

``` r
bcs70_38y <- read_dta("38y/bcs8derived.dta")

lookfor(bcs70_38y, "smok|cigar")
```

     pos variable label                col_type missing values                    
     11  BD8SMOKE 2008: Smoking habits dbl+lbl  0       [-8] Dont Know            
                                                        [-1] Not applicable       
                                                        [0] Never smoked          
                                                        [1] Ex smoker             
                                                        [2] Occasional smoker     
                                                        [3] Up to 10 a day        
                                                        [4] 11 to 20 a day        
                                                        [5] More than 20 a day    
                                                        [6] Daily but frequency n~

Users may consider it easier to create a tibble of the `lookfor()`
output, which can be searched and filtered using `dplyr` functions.
Below, we create a `tibble` (a type of `data.frame` with good printing
defaults) of the `lookfor()` output and use `filter()` to find variables
with `"smok"` or `"cigar"` in their labels. Note, we convert both the
variable names and labels to lower case to make the search case
insensitive.

``` r
bcs70_38y_lookfor <- lookfor(bcs70_38y) %>%
  as_tibble() %>%
  mutate(variable_low = str_to_lower(variable),
         label_low = str_to_lower(label))

bcs70_38y_lookfor %>%
  filter(str_detect(label_low, "smok|cigar"))
```

    # A tibble: 1 × 9
        pos variable label         col_type missing levels value_labels variable_low
      <int> <chr>    <chr>         <chr>      <int> <name> <named list> <chr>       
    1    11 BD8SMOKE 2008: Smokin… dbl+lbl        0 <NULL> <dbl [9]>    bd8smoke    
    # ℹ 1 more variable: label_low <chr>

# `codebookr::codebook()`

The BCS70 datasets that are downloadable from the UK Data Service come
bundled with data dictionaries within the `mrdoc` subfolder. However,
these are limited in some ways. The `codebookr` package enables the
creation of data dictionaries that are more customisable, and in our
opinion, easier-to-read. Below we create a codebook for the BCS70
51-year sweep dataset. These codebooks are intended to be saved and
viewed in Microsoft Word.

``` r
cdb <- codebook(bcs70_38y)
print(cdb, "bcs70_38y_codebook.docx") # Saves as .docx (Word) file
```

A screenshot of the codebook is shown below.

![Codebook created by
codebookr::codebook()](../images/bcs70-data_discovery.png)

# Create a Lookup Table Across All Datasets

Creating the `lookfor()` and `codebook()` one dataset at a time does not
allow one to get a quick overview of the variables available in the
BCS70, including the sweeps repeatedly measured characteristics are
available in. Below we create a `tibble`, `df_lookfor`, that contains
`lookfor()` results for all the `.dta` files in the BCS70 folder.

To do this, we create a function, `create_lookfor()`, that takes a file
path to a `.dta` file, reads in the first row of the dataset (faster
than reading the full dataset), and applies `lookfor()` to it. We call
this function with a `mutate()` function call to create a set of lookups
for every `.dta` file we can find in the BCS70 folder. `map()` loops
over every value in the `file_path` column, creating a corresponding
lookup table for that file, stored as a
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

    Warning: Expected 2 pieces. Additional pieces discarded in 3174 rows [28943, 28944,
    28945, 28946, 28947, 28948, 28949, 28950, 28951, 28952, 28953, 28954, 28955,
    28956, 28957, 28958, 28959, 28960, 28961, 28962, ...].

We can use the resulting object to search for variables with `"smok"` or
`"cigar"` in their labels.

``` r
df_lookfor %>%
  filter(str_detect(label_low, "smok|cigar")) %>%
  select(file, variable, label)
```

    # A tibble: 294 × 3
       file         variable label                                   
       <chr>        <chr>    <chr>                                   
     1 bcs7072a.dta a0043b   SMOKING DURING PREGNANCY                
     2 bcs7072b.dta b0024    DOES THE CHILD'S MOTHER SMOKE TOBACCO ? 
     3 bcs7072b.dta b0025    IF NO WHEN DID SHE LAST SMOKE (MONTH) ? 
     4 bcs7072b.dta b0026    IF NO WHEN DID SHE LAST SMOKE (YEAR) ?  
     5 bcs7072b.dta b0027    ANSWER TO LAST SMOKED OTHER THAN A DATE 
     6 bcs7072b.dta b0028    HOW MANY SMOKED ( CIGARETTES ) ?        
     7 sn3723.dta   e9_1     MOTHER'S PRESENT SMOKING HABITS         
     8 sn3723.dta   e9_2     NO. OF CIGARETTES MOTHER SMOKES DAILY   
     9 sn3723.dta   e9_3     LENGTH OF TIME MOTHER HAS SMOKED        
    10 sn3723.dta   e10_1    MOTHER NON SMOKER NOW HAS SMOKED IN PAST
    # ℹ 284 more rows
