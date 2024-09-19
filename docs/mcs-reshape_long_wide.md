---
layout: default
title: Reshaping Data from Long to Wide (or Wide to Long)
nav_order: 6
parent: MCS
format: docusaurus-md
---




# Introduction

In this section, we show how to reshape data from long to wide (and vice
versa). We do this for both raw and cleaned data. To demonstrate, we use
data on cohort member’s height and weight collected in Sweeps 3-7.

The packages we use are:

```r
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

```r
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

str(df_wide)
```

``` text
tibble [16,618 × 12] (S3: tbl_df/tbl/data.frame)
 $ MCSID    : chr [1:16618] "M10001N" "M10002P" "M10007U" "M10011Q" ...
  ..- attr(*, "label")= chr "MCS Research ID - Anonymised Family/Household Identifier"
  ..- attr(*, "format.stata")= chr "%7s"
 $ CNUM00   : dbl+lbl [1:16618] 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1...
   ..@ labels: Named num [1:3] 1 2 3
   .. ..- attr(*, "names")= chr [1:3] "1st Cohort Member of the family" "2nd Cohort Member of the family" "3rd Cohort Member of the family"
   ..@ label : chr "Cohort Member number within an MCS family"
 $ CCHTCM00 : dbl+lbl [1:16618] 114, 110, 118, 121, 110, 118, 110, 113, 112, 108, 11...
   ..@ label       : chr "PHYS: Height in cms"
   ..@ format.stata: chr "%12.0g"
   ..@ labels      : Named num [1:5] -9 -8 -1 99998 99999
   .. ..- attr(*, "names")= chr [1:5] "Refusal" "Don't Know" "Not applicable" "Refusal" ...
 $ CCWTCM00 : dbl+lbl [1:16618] 21.2, 19.2, 25.3, 32.9, 19.7, 23.0, 18.9, 19.4, 20.6...
   ..@ label       : chr "PHYS: Weight in Kilograms"
   ..@ format.stata: chr "%12.0g"
   ..@ labels      : Named num [1:3] -9 -8 -1
   .. ..- attr(*, "names")= chr [1:3] "Refusal" "Don't Know" "Not applicable"
 $ DCHTCM00 : dbl+lbl [1:16618] 128, 123, 129, 137, 122, 130, 121, 128, 123, 121,  N...
   ..@ label       : chr "Height in cms"
   ..@ format.stata: chr "%12.0g"
   ..@ labels      : Named num [1:3] -9 -8 -1
   .. ..- attr(*, "names")= chr [1:3] "Refusal" "Don''t Know" "Not applicable"
 $ DCWTCM00 : dbl+lbl [1:16618] 25.5, 26.2, 26.5, 51.2, 24.1, 29.0, 21.7, 22.0, 24.6...
   ..@ label       : chr "Weight in Kilos"
   ..@ format.stata: chr "%12.0g"
   ..@ labels      : Named num [1:3] -9 -8 -1
   .. ..- attr(*, "names")= chr [1:3] "Refusal" "Don''t Know" "Not applicable"
 $ ECHTCM00 : dbl+lbl [1:16618]  NA, 144, 154, 168, 143, 152,  NA, 150, 141, 147, 15...
   ..@ label       : chr "Height in cms"
   ..@ format.stata: chr "%12.0g"
   ..@ labels      : Named num [1:2] -7 -1
   .. ..- attr(*, "names")= chr [1:2] "No answer" "Not applicable"
 $ ECWTCMA00: dbl+lbl [1:16618]   NA, 41.8, 40.6, 74.0, 38.2, 41.5,   NA, 37.3, 33.8...
   ..@ label       : chr "Weight in kilos"
   ..@ format.stata: chr "%12.0g"
   ..@ labels      : Named num [1:2] -7 -1
   .. ..- attr(*, "names")= chr [1:2] "No answer" "Not applicable"
 $ FCHTCM00 : dbl+lbl [1:16618]  NA, 163, 174,  NA, 164, 167,  NA, 164, 161, 157, 16...
   ..@ label       : chr "Height in centimeters"
   ..@ format.stata: chr "%12.0g"
   ..@ labels      : Named num [1:2] -5 -1
   .. ..- attr(*, "names")= chr [1:2] "UNABLE TO OBTAIN HEIGHT MEASUREMENT" "Not applicable"
 $ FCWTCM00 : dbl+lbl [1:16618]   NA, 52.3, 57.1,   NA, 56.2, 51.5,   NA, 56.9, 46.8...
   ..@ label       : chr "Weight in kilos"
   ..@ format.stata: chr "%12.0g"
   ..@ labels      : Named num [1:2] -5 -1
   .. ..- attr(*, "names")= chr [1:2] "UNABLE TO OBTAIN HEIGHT MEASUREMENT" "Not applicable"
 $ GCHTCM00 : dbl+lbl [1:16618]  NA, 174, 181,  NA, 169, 185,  NA, 166,  NA, 157, 18...
   ..@ label       : chr "Height in cms"
   ..@ format.stata: chr "%12.0g"
   ..@ labels      : Named num [1:2] -5 -1
   .. ..- attr(*, "names")= chr [1:2] "Unable to obtain height measurement" "Not applicable"
 $ GCWTCM00 : dbl+lbl [1:16618]    NA,  59.4,  71.4,    NA,  75.7,  74.1,    NA,  56...
   ..@ label       : chr "Weight in kilos"
   ..@ format.stata: chr "%12.0g"
   ..@ labels      : Named num [1:2] -5 -1
   .. ..- attr(*, "names")= chr [1:2] "Unable to obtain weight measurement" "Not applicable"
```

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

```r
df_long <- df_wide %>%
  pivot_longer(cols = matches("C(H|W)TCM00"),
               names_to = c("sweep", ".value"),
               names_pattern = "(.)(.*)")
```

``` text
Warning: `CCHTCM00` and `DCHTCM00` have conflicting value labels.
ℹ Labels for these values will be taken from `CCHTCM00`.
✖ Values: -8
```

``` text
Warning: `CCHTCM00` and `GCHTCM00` have conflicting value labels.
ℹ Labels for these values will be taken from `CCHTCM00`.
✖ Values: -5
```

``` text
Warning: `CCWTCM00` and `DCWTCM00` have conflicting value labels.
ℹ Labels for these values will be taken from `CCWTCM00`.
✖ Values: -8
```

``` text
Warning: `CCWTCM00` and `GCWTCM00` have conflicting value labels.
ℹ Labels for these values will be taken from `CCWTCM00`.
✖ Values: -5
```

```r
df_long
```

``` text
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
```

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

```r
df_long %>%
  pivot_wider(names_from = sweep,
              values_from = matches("C(W|H)T"),
              names_glue = "{sweep}{.value}")
```

``` text
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
```

# Reshaping Cleaned Data from Long to Wide

It is likely that you will not just need to reshape raw data, but
cleaned data too. In the next two sections we offer advice on naming
variables so that they are easy to select and reshape in long or wide
formats. First, we clean the long dataset by converting the `cnum` and
`sweep` columns to integers, creating a new column for follow-up time,
and creating new `height` and `weight` variables that replace negative
values in the raw height and weight data with `NA` (as well as giving
these variables more easy-to-understand names).

```r
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

```r
df_wide_clean <- df_long_clean %>%
  mutate(fup = ifelse(fup < 10, glue("0{fup}"), as.character(fup))) %>%
  pivot_wider(names_from = fup,
              values_from = c(height, weight),
              names_glue = "{.value}_{fup}")

df_wide_clean
```

``` text
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
```

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

```r
df_wide_clean %>%
  pivot_longer(cols = matches("_\\d\\d$"),
               names_to = c(".value", "fup"),
               names_pattern = "(.*)_(\\d\\d)$",
               names_transform = list(fup = as.integer))
```

``` text
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
```

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
