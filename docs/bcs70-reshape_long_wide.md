---
layout: default
title: Reshaping Data from Long to Wide (or Wide to Long)
nav_order: 4
parent: BCS70
format:
  gfm:
    variant: +yaml_metadata_block
---


- [Download the R script for this
  page](../purl/bcs70-reshape_long_wide.R)
- [Download the equivalent Stata script for this
  page](../do_files/bcs70-reshape_long_wide.do)

# Introduction

In this section, we show how to reshape data from long to wide (and vice
versa). To demonstrate, we use data from Sweeps 8 (51y) and 11 (51y) on
cohort member’s height and weight collected.

The packages we use are:

``` r
# Load Packages
library(tidyverse) # For data manipulation
library(haven) # For importing .dta files
```

# Reshaping Raw Data from Wide to Long

We begin by loading the data from each sweep and merging these together
into a single wide format data frame; see [Combining Data Across
Sweeps](https://cls-data.github.io/docs/bcs70-merging_across_sweeps.html)
for further explanation on how this is achieved. Note, the names of the
height and weight variables in Sweep 8 and Sweep 11 follow a similar
convention, which is the exception rather than the rule in BCS70 data.
Below, we convert the variable names in the Sweep 8 data frame to lower
case so that they closely match those in the Sweep 11 data frame. This
will make reshaping easier.

``` r
df_42y <- read_dta("42y/bcs70_2012_derived.dta",
                      col_select = c("BCSID", "BD9HGHTM", "BD9WGHTK")) %>%
rename_with(str_to_lower)

df_51y <- read_dta("51y/bcs11_age51_main.dta",
                   col_select = c("bcsid", "bd11hghtm", "bd11wghtk"))

df_wide <- df_42y %>%
  full_join(df_51y, by = "bcsid")
```

`df_wide` has 5 columns. Besides, the identifier, `bcsid`, there are 4
columns for height and weight measurements at each sweep. Each of these
4 columns is prefix by three characters indicating the sweep at
assessment. We can reshape the dataset into long format (one row per
person x sweep combination) using the `pivot_longer()` function so that
the resulting data frame has four columns: one person identifier, a
variable for age of assessment (`fup`), and variables for height and
weight. We specify the columns to be reshaped using the `cols` argument,
provide the new variable names in the `names_to` argument, and the
pattern the existing column names take using the `names_pattern`
argument. For `names_pattern` we specify `"^bd(\\d{1,2})([A-Za-z].+)$"`,
which breaks the column name into two pieces: one or two digits
indicating sweep (and after `bd`; `(\\d{1,2})`) and subsequent
characters at the end of the name (`"([A-Za-z].+)$"`). `names_pattern`
uses regular expressions. `.` matches single characters, and `.+`
modifies this to make one or more characters. `\\d` is a special
character denoting a digit. `[A-Za-z]` indicates any alphabetic
character, upper or lower case. As noted, the digits hold information on
sweep of assessment; in the reshaped data frame the character is stored
as a value in a new column `sweep`. `.value` is a placeholder for the
new columns in the reshaped data frame that store the values from the
columns selected by `cols`; these new columns are named using the first
piece from `names_pattern` - in this case `hghtm` (height) and `wghtk`
(weight).

``` r
df_long <- df_wide %>%
  pivot_longer(cols = matches("^bd"),
               names_to = c("sweep", ".value"),
               names_pattern = "^bd(\\d{1,2})([A-Za-z].+)$")

df_long
```

    # A tibble: 21,366 × 4
       bcsid   sweep hghtm     wghtk    
       <chr>   <chr> <dbl+lbl> <dbl+lbl>
     1 B10001N 9      1.55     55.8     
     2 B10001N 11     1.55     50.8     
     3 B10003Q 9      1.85     82.6     
     4 B10003Q 11     1.85     83.5     
     5 B10004R 9      1.60     57.2     
     6 B10004R 11     1.6      57.2     
     7 B10007U 9      1.52     82.6     
     8 B10007U 11    NA        NA       
     9 B10009W 9      1.63     54.9     
    10 B10009W 11     1.63     60.3     
    # ℹ 21,356 more rows

# Reshaping Raw Data from Long to Wide

We can also reshape the data from long to wide format using the
`pivot_wider()` function. In this case, we want to create two new
columns for each sweep: one for height and one for weight. We specify
the columns to be reshaped using the `values_from` argument, provide the
old column names in the `names_from` argument, and use the `names_glue`
argument to specify the convention to follow for the new column names.
The `names_glue` argument uses curly braces (`{}`) to reference the
values from the `names_from` and `.value` arguments. As we are
specifying multiple columns in `values_from`, `.value` is a placeholder
for the names of the variables selected in `values_from`.

``` r
df_long %>%
  pivot_wider(names_from = sweep,
              values_from = c(hghtm, wghtk),
              names_glue = "{.value}_{sweep}")
```

    # A tibble: 10,683 × 5
       bcsid   hghtm_9   hghtm_11  wghtk_9              wghtk_11 
       <chr>   <dbl+lbl> <dbl+lbl> <dbl+lbl>            <dbl+lbl>
     1 B10001N 1.55       1.55      55.8                 50.8    
     2 B10003Q 1.85       1.85      82.6                 83.5    
     3 B10004R 1.60       1.6       57.2                 57.2    
     4 B10007U 1.52      NA         82.6                 NA      
     5 B10009W 1.63       1.63      54.9                 60.3    
     6 B10010P 1.65      NA         -8 [No information]  NA      
     7 B10011Q 1.63       1.65      76.2                 82.6    
     8 B10013S 1.63       1.63      63.5                 66.7    
     9 B10015U 1.83       1.8       77.6                 82.6    
    10 B10016V 1.88       1.88     114.                 118      
    # ℹ 10,673 more rows

Note, in the original `df_wide` tibble, the height and weight variables
were labelled numeric vectors - this class allows users to add metadata
to variables (value labels, etc.). When reshaping to long format,
multiple variables are effectively appended together, but the final
reshape variables can only have one set of properties. `pivot_longer()`
tries to preserve variables attributes, but in some cases will throw an
error (where variables are of inconsistent types) or print a warning
(where value labels are inconsistent).
