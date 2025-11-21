---
layout: default
title: Reshaping Data from Long to Wide (or Wide to Long)
nav_order: 7
parent: MCS
format:
  gfm:
    variant: +yaml_metadata_block
---


- [Download the R script for this page](../purl/mcs-reshape_long_wide.R)
- [Download the equivalent Stata script for this
  page](../do_files/mcs-reshape_long_wide.do)

# Introduction

In this section, we show how to reshape data from long to wide (and vice
versa). We do this for both raw and cleaned data. To demonstrate, we use
data on cohort member’s height and weight collected in Sweeps 3-7.

The packages we use are:

``` r
# Load Packages
library(tidyverse) # For data manipulation
library(haven) # For importing .dta files
library(glue) # For creating strings
```

# Reshaping Raw Data from Wide to Long

We begin by loading the data from each sweep and merging these together
into a single wide format data frame; see [Combining Data Across
Sweeps](https://cls-data.github.io/docs/mcs-merging_across_sweeps.html)
for further explanation on how this is achieved. Note, the names of the
height and weight variables in Sweep 5 (`ECHTCMA0` and `ECWTCMAO`)
diverge slightly from the convention used for other sweeps
(`[C-G]CHTCM00` and `[C-G]CWTCM00` where `[C-G]` denotes sweep), hence
the need for the complex regular expression in
`read_dta(col_select = ...)` function call.[^1] To make the names of the
columns in the wide dataset consistent (useful preparation for reshaping
data), we rename the Sweep 5 variables so they follow the convention for
the other sweeps.

``` r
fups <- c(0, 3, 5, 7, 11, 14, 17)

load_height_wide <- function(sweep){
  fup <- fups[sweep]
  prefix <- LETTERS[sweep]
  
  glue("{fup}y/mcs{sweep}_cm_interview.dta") %>%
    read_dta(col_select = c("MCSID", matches("^.(CNUM00|C(H|W)TCM(A|0)0)"))) %>%
    rename(CNUM00 = matches("CNUM00"))
}

df_wide <- map(3:7, load_height_wide) %>%
  reduce(~ full_join(.x, .y, by = c("MCSID", "CNUM00"))) %>%
  rename(ECHTCM00 = ECHTCMA0, ECWTCMA00 = ECWTCMA0)

df_wide
```

    # A tibble: 16,618 × 12
       MCSID CNUM00  CCHTCM00 CCWTCM00 DCHTCM00 DCWTCM00 ECHTCM00 ECWTCMA00 FCHTCM00
       <chr> <dbl+l> <dbl+lb> <dbl+lb> <dbl+lb> <dbl+lb> <dbl+lb> <dbl+lbl> <dbl+lb>
     1 M100… 1 [1st… 114.     21.2     128.     25.5      NA      NA         NA     
     2 M100… 1 [1st… 110.     19.2     123      26.2     144.     41.8      163.    
     3 M100… 1 [1st… 118      25.3     129      26.5     154.     40.6      174.    
     4 M100… 1 [1st… 121      32.9     137      51.2     168.     74         NA     
     5 M100… 1 [1st… 110.     19.7     122.     24.1     143      38.2      164.    
     6 M100… 1 [1st… 118.     23       130      29       152.     41.5      167     
     7 M100… 1 [1st… 110.     18.9     121.     21.7      NA      NA         NA     
     8 M100… 1 [1st… 113.     19.4     128.     22       150.     37.3      164.    
     9 M100… 1 [1st… 112.     20.6     123      24.6     141.     33.8      161     
    10 M100… 1 [1st… 108      18.4     121      24.2     147      40.3      157     
    # ℹ 16,608 more rows
    # ℹ 3 more variables: FCWTCM00 <dbl+lbl>, GCHTCM00 <dbl+lbl>,
    #   GCWTCM00 <dbl+lbl>

`df_wide` has 12 columns. Besides, the identifiers, `MCSID` and `cnum`,
there are 10 columns for height and weight measurements at each sweep.
Each of these 10 columns is prefixed by a single letter indicating the
sweep. We can reshape the dataset into long format (one row per person x
sweep combination) using the `pivot_longer()` function so that the
resulting data frame has five columns: two person identifiers, a
variable for sweep, and variables for height and weight. We specify the
columns to be reshaped using the `cols` argument, provide the new
variable names in the `names_to` argument, and the pattern the existing
column names take using the `names_pattern` argument. For
`names_pattern` we specify `"(.)(.*)"`, which breaks the column name
into two pieces: the first character (`"(.)"`) and the rest of the name
(`"(.*)"`). `names_pattern` uses regular expressions. `.` matches single
characters, and `.*` modifies this to make zero or more characters. As
noted, the first character holds information on sweep; in the reshaped
data frame the character is stored as a value in a new column `sweep`.
`.value` is a placeholder for the new columns in the reshaped data frame
that store the values from the columns selected by `cols`; these new
columns are named using the second piece from `names_pattern` - in this
case `CHTCM00` (height) and `CWTCM00` (weight).

``` r
df_long <- df_wide %>%
  pivot_longer(cols = matches("C(H|W)TCM00"),
               names_to = c("sweep", ".value"),
               names_pattern = "(.)(.*)")

df_long
```

    # A tibble: 83,090 × 6
       MCSID   CNUM00                              ECWTCMA00 sweep CHTCM00   CWTCM00
       <chr>   <dbl+lbl>                           <dbl+lbl> <chr> <dbl+lbl> <dbl+l>
     1 M10001N 1 [1st Cohort Member of the family] NA        C     114.      21.2   
     2 M10001N 1 [1st Cohort Member of the family] NA        D     128.      25.5   
     3 M10001N 1 [1st Cohort Member of the family] NA        E      NA       NA     
     4 M10001N 1 [1st Cohort Member of the family] NA        F      NA       NA     
     5 M10001N 1 [1st Cohort Member of the family] NA        G      NA       NA     
     6 M10002P 1 [1st Cohort Member of the family] 41.8      C     110.      19.2   
     7 M10002P 1 [1st Cohort Member of the family] 41.8      D     123       26.2   
     8 M10002P 1 [1st Cohort Member of the family] 41.8      E     144.      NA     
     9 M10002P 1 [1st Cohort Member of the family] 41.8      F     163.      52.3   
    10 M10002P 1 [1st Cohort Member of the family] 41.8      G     174.      59.4   
    # ℹ 83,080 more rows

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
              values_from = matches("C(W|H)T"),
              names_glue = "{sweep}{.value}")
```

    # A tibble: 16,618 × 17
       MCSID CNUM00  CECWTCMA00 DECWTCMA00 EECWTCMA00 FECWTCMA00 GECWTCMA00 CCHTCM00
       <chr> <dbl+l> <dbl+lbl>  <dbl+lbl>  <dbl+lbl>  <dbl+lbl>  <dbl+lbl>  <dbl+lb>
     1 M100… 1 [1st… NA         NA         NA         NA         NA         114.    
     2 M100… 1 [1st… 41.8       41.8       41.8       41.8       41.8       110.    
     3 M100… 1 [1st… 40.6       40.6       40.6       40.6       40.6       118     
     4 M100… 1 [1st… 74         74         74         74         74         121     
     5 M100… 1 [1st… 38.2       38.2       38.2       38.2       38.2       110.    
     6 M100… 1 [1st… 41.5       41.5       41.5       41.5       41.5       118.    
     7 M100… 1 [1st… NA         NA         NA         NA         NA         110.    
     8 M100… 1 [1st… 37.3       37.3       37.3       37.3       37.3       113.    
     9 M100… 1 [1st… 33.8       33.8       33.8       33.8       33.8       112.    
    10 M100… 1 [1st… 40.3       40.3       40.3       40.3       40.3       108     
    # ℹ 16,608 more rows
    # ℹ 9 more variables: DCHTCM00 <dbl+lbl>, ECHTCM00 <dbl+lbl>,
    #   FCHTCM00 <dbl+lbl>, GCHTCM00 <dbl+lbl>, CCWTCM00 <dbl+lbl>,
    #   DCWTCM00 <dbl+lbl>, ECWTCM00 <dbl+lbl>, FCWTCM00 <dbl+lbl>,
    #   GCWTCM00 <dbl+lbl>

# Reshaping Cleaned Data from Long to Wide

It is likely that you will not just need to reshape raw data, but
cleaned data too. In the next two sections we offer advice on naming
variables so that they are easy to select and reshape in long or wide
formats. First, we clean the long dataset by converting the `cnum` and
`sweep` columns to integers, creating a new column for follow-up time,
and creating new `height` and `weight` variables that replace negative
values in the raw height and weight data with `NA` (as well as giving
these variables more easy-to-understand names).

``` r
df_long_clean <- df_long %>%
  mutate(cnum = as.integer(CNUM00),
         sweep = match(sweep, LETTERS),
         fup = fups[sweep],
         height = ifelse(CHTCM00 > 0, CHTCM00, NA),
         weight = ifelse(CWTCM00 > 0, CWTCM00, NA)) %>%
  select(MCSID, cnum, fup, height, weight)
```

To reshape the clean data from long to wide format, we can use the
`pivot_wider()` function as before. This time, we specify the columns to
be reshaped using the `names_from` argument, provide the new column
names in the `values_from` argument, and use the `names_glue` argument
to specify the new column names. The `names_glue` argument uses curly
braces (`{}`) to reference the values from the `names_from` and `.value`
arguments. As we are specifying multiple columns in `values_from`,
`.value` is a placeholder for the variable name.

``` r
df_wide_clean <- df_long_clean %>%
  mutate(fup = ifelse(fup < 10, glue("0{fup}"), as.character(fup))) %>%
  pivot_wider(names_from = fup,
              values_from = c(height, weight),
              names_glue = "{.value}_{fup}")

df_wide_clean
```

    # A tibble: 16,618 × 12
       MCSID    cnum height_05 height_07 height_11 height_14 height_17 weight_05
       <chr>   <int>     <dbl>     <dbl>     <dbl>     <dbl>     <dbl>     <dbl>
     1 M10001N     1      114.      128.       NA        NA        NA       21.2
     2 M10002P     1      110.      123       144.      163.      174.      19.2
     3 M10007U     1      118       129       154.      174.      181.      25.3
     4 M10011Q     1      121       137       168.       NA        NA       32.9
     5 M10015U     1      110.      122.      143       164.      169       19.7
     6 M10016V     1      118.      130       152.      167       185.      23  
     7 M10017W     1      110.      121.       NA        NA        NA       18.9
     8 M10018X     1      113.      128.      150.      164.      166.      19.4
     9 M10020R     1      112.      123       141.      161        NA       20.6
    10 M10021S     1      108       121       147       157       157.      18.4
    # ℹ 16,608 more rows
    # ℹ 4 more variables: weight_07 <dbl>, weight_11 <dbl>, weight_14 <dbl>,
    #   weight_17 <dbl>

Notice that prior to reshaping, we convert the `fup` variable to a
string and ensure it has two characters (`5` becomes `05`). The reason
for including this step is to make the names of similar variables the
same length. This consistency makes it simpler to subset variables
either by name (e.g., `select(matches("^height_\d\d$"))`) or by
numerical range (e.g., `select(matches("^(h|w)eight_1[1-4]$"))`).[^2]

# Reshaping Cleaned Data from Wide to Long

Finally, we can reshape the clean wide dataset back to long format using
the `pivot_longer()` function. We specify the columns to be reshaped
using the `cols` argument, provide the new variable names in the
`names_to` argument, and the pattern the existing column names take
using the `names_pattern` argument. For `names_pattern` we specify
`"(.*)_(.*)y"`, which breaks the column name into two pieces: the
variable name (`"(.*)"`), and the follow-up time (`"(.*)y"`). We also
use the `names_transform` argument to convert the follow-up time to an
integer.

``` r
df_wide_clean %>%
  pivot_longer(cols = matches("_\\d\\d$"),
               names_to = c(".value", "fup"),
               names_pattern = "(.*)_(\\d\\d)$",
               names_transform = list(fup = as.integer))
```

    # A tibble: 83,090 × 5
       MCSID    cnum   fup height weight
       <chr>   <int> <int>  <dbl>  <dbl>
     1 M10001N     1     5   114.   21.2
     2 M10001N     1     7   128.   25.5
     3 M10001N     1    11    NA    NA  
     4 M10001N     1    14    NA    NA  
     5 M10001N     1    17    NA    NA  
     6 M10002P     1     5   110.   19.2
     7 M10002P     1     7   123    26.2
     8 M10002P     1    11   144.   NA  
     9 M10002P     1    14   163.   52.3
    10 M10002P     1    17   174.   59.4
    # ℹ 83,080 more rows

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
    `"^(h|w)eight_1[1-4]"` matches any string that begins height or
    weight, immediately followed by 11, 12, 13, or 14 (`[1-4]` is a
    compact way of matching the integer range 1, 2, 3 or 4).
