---
layout: default
title: Reshaping Data from Long to Wide (or Wide to Long)
nav_order: 4
parent: NCDS
format:
  gfm:
    variant: +yaml_metadata_block
---


- [Download the R script for this
  page](../purl/ncds-reshape_long_wide.R)
- [Download the equivalent Stata script for this
  page](../do_files/ncds-reshape_long_wide.do)

# Introduction

In this section, we show how to reshape data from long to wide (and vice
versa). To demonstrate, we use data from Sweeps 4 (23y) and 8 (50y) on
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
Sweeps](https://cls-data.github.io/docs/ncds-merging_across_sweeps.html)
for further explanation on how this is achieved. Note, the names of the
height and weight variables in Sweep 4 and Sweep 8 follow a similar
convention, which is the exception rather than the rule in NCDS data.
Below, we convert the variable names in the Sweep 4 data frame to upper
case so that they closely match those in the Sweep 8 data frame. This
will make reshaping easier.

``` r
df_23y <- read_dta("23y/ncds4.dta",
                      col_select = c("ncdsid", "dvwt23", "dvht23")) %>%
rename_with(str_to_upper)

df_50y <- read_dta("50y/ncds_2008_followup.dta",
                   col_select = c("NCDSID", "DVWT50", "DVHT50"))

df_wide <- df_23y %>%
  full_join(df_50y, by = "NCDSID")
```

`df_wide` has 5 columns. Besides, the identifier, `NCDSID`, there are 4
columns for height and weight measurements at each sweep. Each of these
4 columns is suffixed by two numbers indicating the age at assessment.
We can reshape the dataset into long format (one row per person x sweep
combination) using the `pivot_longer()` function so that the resulting
data frame has four columns: one person identifier, a variable for age
of assessment (`fup`), and variables for height and weight. We specify
the columns to be reshaped using the `cols` argument, provide the new
variable names in the `names_to` argument, and the pattern the existing
column names take using the `names_pattern` argument. For
`names_pattern` we specify `"^(.*)(\\d\\d)$"`, which breaks the column
name into two pieces: the first characters (`"(.*)"`) and two digits at
the end of the name (`"(\\d\\d)$"`). `names_pattern` uses regular
expressions. `.` matches single characters, and `.*` modifies this to
make zero or more characters. `\\d` is a special character denoting a
digit. As noted, the final two digits character hold information on age
of assessment; in the reshaped data frame the character is stored as a
value in a new column `fup`. `.value` is a placeholder for the new
columns in the reshaped data frame that store the values from the
columns selected by `cols`; these new columns are named using the first
piece from `names_pattern` - in this case `DVHT` (height) and `DVWT`
(weight).

``` r
df_long <- df_wide %>%
  pivot_longer(cols = matches("DV(HT|WT)\\d\\d"),
               names_to = c(".value", "fup"),
               names_pattern = "^(.*)(\\d\\d)$")

df_long
```

    # A tibble: 28,028 × 4
       NCDSID  fup   DVHT      DVWT     
       <chr>   <chr> <dbl+lbl> <dbl+lbl>
     1 N10001N 23     1.63     59.4     
     2 N10001N 50    NA        66.7     
     3 N10002P 23     1.90     73.5     
     4 N10002P 50    NA        79.4     
     5 N10004R 23     1.65     76.2     
     6 N10004R 50    NA        NA       
     7 N10007U 23     1.63     52.2     
     8 N10007U 50    NA        72.1     
     9 N10009W 23     1.73     66.7     
    10 N10009W 50     1.7      78       
    # ℹ 28,018 more rows

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
  pivot_wider(names_from = fup,
              values_from = matches("DV(HT|WT)"),
              names_glue = "{.value}{fup}")
```

    # A tibble: 14,014 × 5
       NCDSID  DVHT23    DVHT50    DVWT23    DVWT50   
       <chr>   <dbl+lbl> <dbl+lbl> <dbl+lbl> <dbl+lbl>
     1 N10001N 1.63      NA         59.4      66.7    
     2 N10002P 1.90      NA         73.5      79.4    
     3 N10004R 1.65      NA         76.2      NA      
     4 N10007U 1.63      NA         52.2      72.1    
     5 N10009W 1.73       1.7       66.7      78      
     6 N10011Q 1.68       1.7       63.5      95      
     7 N10012R 1.96      NA        114.      133.     
     8 N10013S 1.78      NA         83.5      95.2    
     9 N10014T 1.55      NA         57.2      63.5    
    10 N10015U 1.80      NA         73.0      78      
    # ℹ 14,004 more rows

Note, in the original `df_wide` tibble, `DVHT23` and `DVWT23` were
labelled numeric vectors - this class allows users to add metadata to
variables (value labels, etc.). `DVHT50` and `DVWT50`, on the other
hand, were standard numeric vectors. When reshaping to long format,
multiple variables are effectively appended together. The final reshape
variables can only have one set of properties. `pivot_longer()` merges
variables together to preserve variables attributes, but in some cases
will throw an error (where variables are of inconsistent types) or print
a warning (where value labels are inconsistent). Note above, where we
reshape `df_long` back to wide format, all weight and height variables
now have labelled numeric type.
