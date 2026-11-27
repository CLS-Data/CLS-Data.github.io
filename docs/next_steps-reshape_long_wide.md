---
layout: default
title: Reshaping Data from Long to Wide (or Wide to Long)
nav_order: 6
parent: Next Steps
format:
  gfm:
    variant: +yaml_metadata_block
---


- [Download the R script for this
  page](../purl/next_steps-reshape_long_wide.R)

# Introduction

In this section, we show how to reshape data from long to wide (and vice
versa). We do this for both raw and cleaned data. To demonstrate, we use
data on cohort members’ height and weight collected in Sweeps 8 and 9
(ages 25 and 32).

The packages we use are:

``` r
# Load Packages
library(tidyverse) # For data manipulation
library(haven) # For importing .dta files
```

# Reshaping Raw Data from Wide to Long

We begin by loading the data from each sweep and merging these together
into a single wide format data frame; see [Combining Data Across
Sweeps](https://cls-data.github.io/docs/next_steps-merging_across_sweeps.html)
for further explanation on how this is achieved. Height and weight are
stored in the main interview files for Sweeps 8 and 9
(`ns8_2015_main_interview.dta` and `ns9_2022_main_interview.dta`, both
in the `safeguarded_eul` subfolder). The names of the height and weight
variables follow the same convention in the two sweeps, differing only
in the prefix that denotes the sweep (`W8HEIGHT` and `W9HEIGHT`;
`W8WEIGHT` and `W9WEIGHT`). This is typical for variables collected in
Sweeps 8 and 9, but [not for variables collected in both earlier and
later
sweeps](https://cls-data.github.io/docs/next_steps-data_structures.html),
which usually need to be renamed before they can be reshaped.

``` r
df_w8 <- read_dta("safeguarded_eul/ns8_2015_main_interview.dta",
                  col_select = c("NSID", "W8HEIGHT", "W8WEIGHT"))

df_w9 <- read_dta("safeguarded_eul/ns9_2022_main_interview.dta",
                  col_select = c("NSID", "W9HEIGHT", "W9WEIGHT"))

df_wide <- df_w8 %>%
  full_join(df_w9, by = "NSID")

df_wide
```

    # A tibble: 9,408 × 5
       NSID     W8HEIGHT            W8WEIGHT             W9HEIGHT           W9WEIGHT
       <chr>    <dbl+lbl>           <dbl+lbl>            <dbl+lbl>          <dbl+lb>
     1 NS10001S  1.85                73.0                NA                  NA     
     2 NS10004W  1.55                55.3                -1 [Not applicabl…  51     
     3 NS10011M  1.73                75                  -1 [Not applicabl…  89     
     4 NS10020F  1.83                -1 [Not applicable] -1 [Not applicabl… 100     
     5 NS10021G  1.85                73.5                -1 [Not applicabl…  84.8   
     6 NS10026M  1.65                62.1                -1 [Not applicabl…  73.0   
     7 NS10027N  1.7                 64.0                -1 [Not applicabl…  64.0   
     8 NS10029Q -1 [Not applicable]  -1 [Not applicable]  1.78               87     
     9 NS10030A  2.01               106.                 -1 [Not applicabl…  80     
    10 NS10031B  1.7                 69.8                NA                  NA     
    # ℹ 9,398 more rows

`df_wide` has 5 columns. Besides the identifier, `NSID`, there are 4
columns for height and weight measurements at each sweep. Each of these
4 columns is prefixed by the letter `W` and a single digit indicating
the sweep. We can reshape the dataset into long format (one row per
person x sweep combination) using the `pivot_longer()` function so that
the resulting data frame has four columns: one person identifier, a
variable for sweep, and variables for height and weight. We specify the
columns to be reshaped using the `cols` argument, provide the new
variable names in the `names_to` argument, and the pattern the existing
column names take using the `names_pattern` argument. For
`names_pattern` we specify `"^W(\\d)(.*)$"`, which breaks the column
name into two pieces: the digit following the initial `W` (`"(\\d)"`)
and the rest of the name (`"(.*)"`). `names_pattern` uses regular
expressions.[^1] `\\d` is a special character denoting a digit, `.`
matches single characters, and `.*` modifies this to match zero or more
characters. As noted, the digit holds information on sweep; in the
reshaped data frame the digit is stored as a value in a new column
`sweep`. `.value` is a placeholder for the new columns in the reshaped
data frame that store the values from the columns selected by `cols`;
these new columns are named using the second piece from
`names_pattern` - in this case `HEIGHT` and `WEIGHT`. Finally, we use
the `names_transform` argument to convert `sweep` to an integer. As the
values of `sweep` are taken from the column names, they would otherwise
be stored as text (`"8"` and `"9"`), which is harder to work with: text
cannot be used in calculations, is sorted alphabetically rather than
numerically, and cannot be matched to a numeric sweep variable when
merging with other datasets.

``` r
df_long <- df_wide %>%
  pivot_longer(cols = matches("^W\\d(HEIGHT|WEIGHT)$"),
               names_to = c("sweep", ".value"),
               names_pattern = "^W(\\d)(.*)$",
               names_transform = list(sweep = as.integer))

df_long
```

    # A tibble: 18,816 × 4
       NSID     sweep HEIGHT              WEIGHT              
       <chr>    <int> <dbl+lbl>           <dbl+lbl>           
     1 NS10001S     8  1.85                73.0               
     2 NS10001S     9 NA                   NA                 
     3 NS10004W     8  1.55                55.3               
     4 NS10004W     9 -1 [Not applicable]  51                 
     5 NS10011M     8  1.73                75                 
     6 NS10011M     9 -1 [Not applicable]  89                 
     7 NS10020F     8  1.83                -1 [Not applicable]
     8 NS10020F     9 -1 [Not applicable] 100                 
     9 NS10021G     8  1.85                73.5               
    10 NS10021G     9 -1 [Not applicable]  84.8               
    # ℹ 18,806 more rows

Note, in the original `df_wide` tibble, the height and weight variables
were labelled numeric vectors - this class allows users to add metadata
to variables (value labels, etc.). When reshaping to long format,
multiple variables are effectively appended together, so the final
reshaped variables can only have one set of properties. `pivot_longer()`
tries to preserve variable attributes, but in some cases will throw an
error (where variables are of inconsistent types) or print a warning
(where value labels are inconsistent). This is the case here: the value
labels attached to the Sweep 8 and Sweep 9 variables are not identical,
so running the `pivot_longer()` code above produces a warning that the
variables have conflicting value labels, and the labels from the Sweep 8
variables are used. Where this is a concern, value labels can be removed
prior to reshaping with `zap_labels()` (from `haven`).

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
              values_from = c(HEIGHT, WEIGHT),
              names_glue = "W{sweep}{.value}")
```

    # A tibble: 9,408 × 5
       NSID     W8HEIGHT            W9HEIGHT            W8WEIGHT            W9WEIGHT
       <chr>    <dbl+lbl>           <dbl+lbl>           <dbl+lbl>           <dbl+lb>
     1 NS10001S  1.85               NA                   73.0                NA     
     2 NS10004W  1.55               -1 [Not applicable]  55.3                51     
     3 NS10011M  1.73               -1 [Not applicable]  75                  89     
     4 NS10020F  1.83               -1 [Not applicable]  -1 [Not applicabl… 100     
     5 NS10021G  1.85               -1 [Not applicable]  73.5                84.8   
     6 NS10026M  1.65               -1 [Not applicable]  62.1                73.0   
     7 NS10027N  1.7                -1 [Not applicable]  64.0                64.0   
     8 NS10029Q -1 [Not applicable]  1.78                -1 [Not applicabl…  87     
     9 NS10030A  2.01               -1 [Not applicable] 106.                 80     
    10 NS10031B  1.7                NA                   69.8                NA     
    # ℹ 9,398 more rows

# Reshaping Cleaned Data from Long to Wide

It is likely that you will not just need to reshape raw data, but
cleaned data too. In the next two sections we offer advice on naming
variables so that they are easy to select and reshape in long or wide
formats. First, we clean the long dataset by creating a new column for
the cohort member’s age at each sweep, and creating new `height` and
`weight` variables that replace negative values in the raw height and
weight data with `NA` (as well as giving these variables more
easy-to-understand names). To create the age variable, we create a
vector, `ages`, which contains the (approximate) age of cohort members
at each of the nine sweeps, and subset it using the sweep number (i.e.,
`ages[8]` returns `25`).

``` r
ages <- c(14, 15, 16, 17, 18, 19, 20, 25, 32)

df_long_clean <- df_long %>%
  mutate(age = ages[sweep],
         height = ifelse(HEIGHT > 0, HEIGHT, NA),
         weight = ifelse(WEIGHT > 0, WEIGHT, NA)) %>%
  select(NSID, age, height, weight)

df_long_clean
```

    # A tibble: 18,816 × 4
       NSID       age height weight
       <chr>    <dbl>  <dbl>  <dbl>
     1 NS10001S    25   1.85   73.0
     2 NS10001S    32  NA      NA  
     3 NS10004W    25   1.55   55.3
     4 NS10004W    32  NA      51  
     5 NS10011M    25   1.73   75  
     6 NS10011M    32  NA      89  
     7 NS10020F    25   1.83   NA  
     8 NS10020F    32  NA     100  
     9 NS10021G    25   1.85   73.5
    10 NS10021G    32  NA      84.8
    # ℹ 18,806 more rows

To reshape the clean data from long to wide format, we can use the
`pivot_wider()` function as before. This time, we specify the column
containing the cohort member’s age in the `names_from` argument, the
columns to be reshaped in the `values_from` argument, and use the
`names_glue` argument to specify the new column names. The `names_glue`
argument uses curly braces (`{}`) to reference the values from the
`names_from` and `.value` arguments. As we are specifying multiple
columns in `values_from`, `.value` is a placeholder for the variable
name.

``` r
df_wide_clean <- df_long_clean %>%
  pivot_wider(names_from = age,
              values_from = c(height, weight),
              names_glue = "{.value}_{age}")

df_wide_clean
```

    # A tibble: 9,408 × 5
       NSID     height_25 height_32 weight_25 weight_32
       <chr>        <dbl>     <dbl>     <dbl>     <dbl>
     1 NS10001S      1.85     NA         73.0      NA  
     2 NS10004W      1.55     NA         55.3      51  
     3 NS10011M      1.73     NA         75        89  
     4 NS10020F      1.83     NA         NA       100  
     5 NS10021G      1.85     NA         73.5      84.8
     6 NS10026M      1.65     NA         62.1      73.0
     7 NS10027N      1.7      NA         64.0      64.0
     8 NS10029Q     NA         1.78      NA        87  
     9 NS10030A      2.01     NA        106.       80  
    10 NS10031B      1.7      NA         69.8      NA  
    # ℹ 9,398 more rows

Notice that the new variable names consist of a descriptive stem, an
underscore, and the age at measurement. A consistent convention such as
this makes it simple to subset variables either by name (e.g.,
`select(matches("^height_\\d\\d$"))`) or by numerical range (e.g.,
`select(matches("^(h|w)eight_2[0-9]$"))`).[^2] As cohort members were
aged between 14 and 32 in Sweeps 1-9, the age is always two characters
long. In studies that include measurements from earlier in life, it is
worth padding ages with a leading zero (e.g., `height_05`) so that the
names of similar variables are the same length.

# Reshaping Cleaned Data from Wide to Long

Finally, we can reshape the clean wide dataset back to long format using
the `pivot_longer()` function. We specify the columns to be reshaped
using the `cols` argument, provide the new variable names in the
`names_to` argument, and the pattern the existing column names take
using the `names_pattern` argument. For `names_pattern` we specify
`"(.*)_(\\d\\d)$"`, which breaks the column name into two pieces: the
variable name (`"(.*)"`), and the age (`"(\\d\\d)"`). As before, we use
the `names_transform` argument to convert the age to an integer. Note
how easy it is to identify the variables we want to reshape in `cols`:
because we used a consistent naming structure for the cleaned variables,
a short regular expression (`"_\\d\\d$"`) selects all of them.

``` r
df_wide_clean %>%
  pivot_longer(cols = matches("_\\d\\d$"),
               names_to = c(".value", "age"),
               names_pattern = "(.*)_(\\d\\d)$",
               names_transform = list(age = as.integer))
```

    # A tibble: 18,816 × 4
       NSID       age height weight
       <chr>    <int>  <dbl>  <dbl>
     1 NS10001S    25   1.85   73.0
     2 NS10001S    32  NA      NA  
     3 NS10004W    25   1.55   55.3
     4 NS10004W    32  NA      51  
     5 NS10011M    25   1.73   75  
     6 NS10011M    32  NA      89  
     7 NS10020F    25   1.83   NA  
     8 NS10020F    32  NA     100  
     9 NS10021G    25   1.85   73.5
    10 NS10021G    32  NA      84.8
    # ℹ 18,806 more rows

# Footnotes

[^1]: Regular expressions are extremely useful and compact ways of
    working with text. See [Chapter 15 in the R for Data Science
    textbook](https://r4ds.hadley.nz/regexps.html) for more information.
    ChatGPT and similar services are very useful for writing and
    interpreting regular expressions.

[^2]: In regular expressions, `^` and `$` are special characters that
    match the beginning and end of a string, respectively.
    `"^height_\\d\\d$"` matches any string that begins “height\_”,
    immediately followed by two digits (0, 1, …, 9) that end the string.
    `"^(h|w)eight_2[0-9]$"` matches any string that begins height or
    weight, immediately followed by a number between 20 and 29 (`[0-9]`
    is a compact way of matching the integer range 0, 1, …, 9).
