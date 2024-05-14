---
layout: default
title: Reshaping Data from Long to Wide (or Wide to Long)
nav_order: 4
parent: MCS
format: docusaurus-md
---




# Introduction

In this tutorial, we will learn how to reshape data from long to wide
(and vice versa) using the `tidyverse` package in `R`. We will use data
on cohort member’s height and weight collected in Sweeps 2-7 to
demonstrate the process.

```r
# Load Packages
library(tidyverse) # For data manipulation
library(haven) # For importing .dta files
library(glue) # For creating strings
```

# Reshaping from Wide to Long

We begin by loading the data from each sweep and merging these together
into a single wide format data frame; see [Combining Data Across
Sweeps](https://cls-data.github.io/docs/mcs-merging_across_sweeps.html)
for more details. Note, the names of the height and weight variables in
Sweep 5 (`ECHTCMA0` and `ECWTCMAO`) diverge slightly from the rubric
used for other sweeps (`[A-G]CHTCM00` and `[A-G]CWTCM00` where `[A-G]`
denotes sweep), hence the need for the complex regular expression in
`read_dta(col_select = ...)` function call. To simplify the names of the
columns in the wide dataset, we rename the Sweep 5 variables so they
follow the rubric for Sweeps 2-4 and 6-7.

```r
fups <- c(0, 3, 5, 7, 11, 14, 17)

load_height_wide <- function(sweep){
  fup <- fups[sweep]
  prefix <- LETTERS[sweep]
  
  glue("{fup}y/mcs{sweep}_cm_interview.dta") %>%
    read_dta(col_select = c("MCSID", matches("^.(CNUM00|C(H|W)TCM(A|0)0)"))) %>%
    rename(cnum = matches("CNUM00"))
}

df_wide <- map(2:7, load_height_wide) %>%
  reduce(~ full_join(.x, .y, by = c("MCSID", "cnum"))) %>%
  rename(ECHTCM00 = ECHTCMA0, ECWTCMA00 = ECWTCMA0)

str(df_wide)
```

``` text
tibble [17,614 × 13] (S3: tbl_df/tbl/data.frame)
 $ MCSID    : chr [1:17614] "M10001N" "M10002P" "M10007U" "M10008V" ...
  ..- attr(*, "label")= chr "MCS Research ID - Anonymised Family/Household Identifier"
  ..- attr(*, "format.stata")= chr "%7s"
 $ cnum     : dbl+lbl [1:17614] 1, 1, 1, 1, 2, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1...
   ..@ labels: Named num [1:3] 1 2 3
   .. ..- attr(*, "names")= chr [1:3] "1st Cohort Member of the family" "2nd Cohort Member of the family" "3rd Cohort Member of the family"
   ..@ label : chr "Cohort Member number within an MCS family"
 $ BCHTCM00 : dbl+lbl [1:17614]  97,  96, 102,  -2,  -2, 106,  97,  94, 102,  99,  9...
   ..@ label       : chr "PHYS Child's standing height (cm)"
   ..@ format.stata: chr "%8.0g"
   ..@ labels      : Named num [1:2] -2 -1
   .. ..- attr(*, "names")= chr [1:2] "No Measurement taken" "Not answered / missing"
 $ CCHTCM00 : dbl+lbl [1:17614] 114, 110, 118,  NA,  NA, 121,  NA, 110, 118, 110, 11...
   ..@ label       : chr "PHYS: Height in cms"
   ..@ format.stata: chr "%12.0g"
   ..@ labels      : Named num [1:5] -9 -8 -1 99998 99999
   .. ..- attr(*, "names")= chr [1:5] "Refusal" "Don't Know" "Not applicable" "Refusal" ...
 $ CCWTCM00 : dbl+lbl [1:17614] 21.2, 19.2, 25.3,   NA,   NA, 32.9,   NA, 19.7, 23.0...
   ..@ label       : chr "PHYS: Weight in Kilograms"
   ..@ format.stata: chr "%12.0g"
   ..@ labels      : Named num [1:3] -9 -8 -1
   .. ..- attr(*, "names")= chr [1:3] "Refusal" "Don't Know" "Not applicable"
 $ DCHTCM00 : dbl+lbl [1:17614] 128, 123, 129,  NA,  NA, 137,  NA, 122, 130, 121, 12...
   ..@ label       : chr "Height in cms"
   ..@ format.stata: chr "%12.0g"
   ..@ labels      : Named num [1:3] -9 -8 -1
   .. ..- attr(*, "names")= chr [1:3] "Refusal" "Don''t Know" "Not applicable"
 $ DCWTCM00 : dbl+lbl [1:17614] 25.5, 26.2, 26.5,   NA,   NA, 51.2,   NA, 24.1, 29.0...
   ..@ label       : chr "Weight in Kilos"
   ..@ format.stata: chr "%12.0g"
   ..@ labels      : Named num [1:3] -9 -8 -1
   .. ..- attr(*, "names")= chr [1:3] "Refusal" "Don''t Know" "Not applicable"
 $ ECHTCM00 : dbl+lbl [1:17614]  NA, 144, 154,  NA,  NA, 168,  NA, 143, 152,  NA, 15...
   ..@ label       : chr "Height in cms"
   ..@ format.stata: chr "%12.0g"
   ..@ labels      : Named num [1:2] -7 -1
   .. ..- attr(*, "names")= chr [1:2] "No answer" "Not applicable"
 $ ECWTCMA00: dbl+lbl [1:17614]   NA, 41.8, 40.6,   NA,   NA, 74.0,   NA, 38.2, 41.5...
   ..@ label       : chr "Weight in kilos"
   ..@ format.stata: chr "%12.0g"
   ..@ labels      : Named num [1:2] -7 -1
   .. ..- attr(*, "names")= chr [1:2] "No answer" "Not applicable"
 $ FCHTCM00 : dbl+lbl [1:17614]  NA, 163, 174,  NA,  NA,  NA,  NA, 164, 167,  NA, 16...
   ..@ label       : chr "Height in centimeters"
   ..@ format.stata: chr "%12.0g"
   ..@ labels      : Named num [1:2] -5 -1
   .. ..- attr(*, "names")= chr [1:2] "UNABLE TO OBTAIN HEIGHT MEASUREMENT" "Not applicable"
 $ FCWTCM00 : dbl+lbl [1:17614]   NA, 52.3, 57.1,   NA,   NA,   NA,   NA, 56.2, 51.5...
   ..@ label       : chr "Weight in kilos"
   ..@ format.stata: chr "%12.0g"
   ..@ labels      : Named num [1:2] -5 -1
   .. ..- attr(*, "names")= chr [1:2] "UNABLE TO OBTAIN HEIGHT MEASUREMENT" "Not applicable"
 $ GCHTCM00 : dbl+lbl [1:17614]  NA, 174, 181,  NA,  NA,  NA,  NA, 169, 185,  NA, 16...
   ..@ label       : chr "Height in cms"
   ..@ format.stata: chr "%12.0g"
   ..@ labels      : Named num [1:2] -5 -1
   .. ..- attr(*, "names")= chr [1:2] "Unable to obtain height measurement" "Not applicable"
 $ GCWTCM00 : dbl+lbl [1:17614]    NA,  59.4,  71.4,    NA,    NA,    NA,    NA,  75...
   ..@ label       : chr "Weight in kilos"
   ..@ format.stata: chr "%12.0g"
   ..@ labels      : Named num [1:2] -5 -1
   .. ..- attr(*, "names")= chr [1:2] "Unable to obtain weight measurement" "Not applicable"
```

`df_wide` has 14 columns. Besides, the identifiers, `MCSID` and `cnum`,
there are 12 columns for height and weight measurements at each sweep.
Each of these 12 columns is prefixed by a single letter indicating the
sweep. We can reshape the dataset into long format (one row per person x
sweep combination) using the `pivot_longer()` function so that the
resulting data frame has five columns: two person identifiers, a
variable for sweep, and variables for height and weight. We specify the
columns to be reshaped using the `cols` argument, provide the new
variable names in the `names_to` argument, and the pattern the existing
column names take using the `names_pattern` argument. For
`names_pattern` we specify `"(.)(.*)"`, which breaks the column name
into two pieces: the first character (`"(.)"`) and the rest of the name
(`"(.*)"`). As noted, the first character holds information on sweep. In
`names_to`, `.value` is a placeholder for the second piece of the column
name.

```r
df_long <- df_wide %>%
  pivot_longer(cols = matches("C(H|W)TCM00"),
               names_to = c("sweep", ".value"),
               names_pattern = "(.)(.*)")
```

``` text
Warning: `BCHTCM00` and `CCHTCM00` have conflicting value labels.
ℹ Labels for these values will be taken from `BCHTCM00`.
✖ Values: -1
```

``` text
Warning: `BCHTCM00` and `DCHTCM00` have conflicting value labels.
ℹ Labels for these values will be taken from `BCHTCM00`.
✖ Values: -8 and -1
```

``` text
Warning: `BCHTCM00` and `ECHTCM00` have conflicting value labels.
ℹ Labels for these values will be taken from `BCHTCM00`.
✖ Values: -1
```

``` text
Warning: `BCHTCM00` and `FCHTCM00` have conflicting value labels.
ℹ Labels for these values will be taken from `BCHTCM00`.
✖ Values: -1
```

``` text
Warning: `BCHTCM00` and `GCHTCM00` have conflicting value labels.
ℹ Labels for these values will be taken from `BCHTCM00`.
✖ Values: -5 and -1
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
# A tibble: 105,684 × 6
   MCSID   cnum                                ECWTCMA00 sweep CHTCM00   CWTCM00
   <chr>   <dbl+lbl>                           <dbl+lbl> <chr> <dbl+lbl> <dbl+l>
 1 M10001N 1 [1st Cohort Member of the family] NA        B      97       NA     
 2 M10001N 1 [1st Cohort Member of the family] NA        C     114.      21.2   
 3 M10001N 1 [1st Cohort Member of the family] NA        D     128.      25.5   
 4 M10001N 1 [1st Cohort Member of the family] NA        E      NA       NA     
 5 M10001N 1 [1st Cohort Member of the family] NA        F      NA       NA     
 6 M10001N 1 [1st Cohort Member of the family] NA        G      NA       NA     
 7 M10002P 1 [1st Cohort Member of the family] 41.8      B      96       NA     
 8 M10002P 1 [1st Cohort Member of the family] 41.8      C     110.      19.2   
 9 M10002P 1 [1st Cohort Member of the family] 41.8      D     123       26.2   
10 M10002P 1 [1st Cohort Member of the family] 41.8      E     144.      NA     
# ℹ 105,674 more rows
```

# Reshaping from Long to Wide

We can also reshape the data from long to wide format using the
`pivot_wider()` function. In this case, we want to create two new
columns for each sweep: one for height and one for weight. We specify
the columns to be reshaped using the `values_from` argument, provide the
new column names in the `names_from` argument, and use the `names_glue`
argument to specify the new column names. The `names_glue` argument uses
curly braces (`{}`) to reference the values from the `names_from` and
`.value` arguments. As we are specifying multiple columns in
`values_from`, `.value` is a placeholder for the variable name.

```r
df_long %>%
  pivot_wider(names_from = sweep,
              values_from = matches("C(W|H)T"),
              names_glue = "{sweep}{.value}")
```

``` text
# A tibble: 17,614 × 20
   MCSID   cnum           BECWTCMA00 CECWTCMA00 DECWTCMA00 EECWTCMA00 FECWTCMA00
   <chr>   <dbl+lbl>      <dbl+lbl>  <dbl+lbl>  <dbl+lbl>  <dbl+lbl>  <dbl+lbl> 
 1 M10001N 1 [1st Cohort… NA         NA         NA         NA         NA        
 2 M10002P 1 [1st Cohort… 41.8       41.8       41.8       41.8       41.8      
 3 M10007U 1 [1st Cohort… 40.6       40.6       40.6       40.6       40.6      
 4 M10008V 1 [1st Cohort… NA         NA         NA         NA         NA        
 5 M10008V 2 [2nd Cohort… NA         NA         NA         NA         NA        
 6 M10011Q 1 [1st Cohort… 74         74         74         74         74        
 7 M10014T 1 [1st Cohort… NA         NA         NA         NA         NA        
 8 M10015U 1 [1st Cohort… 38.2       38.2       38.2       38.2       38.2      
 9 M10016V 1 [1st Cohort… 41.5       41.5       41.5       41.5       41.5      
10 M10017W 1 [1st Cohort… NA         NA         NA         NA         NA        
# ℹ 17,604 more rows
# ℹ 13 more variables: GECWTCMA00 <dbl+lbl>, BCHTCM00 <dbl+lbl>,
#   CCHTCM00 <dbl+lbl>, DCHTCM00 <dbl+lbl>, ECHTCM00 <dbl+lbl>,
#   FCHTCM00 <dbl+lbl>, GCHTCM00 <dbl+lbl>, BCWTCM00 <dbl+lbl>,
#   CCWTCM00 <dbl+lbl>, DCWTCM00 <dbl+lbl>, ECWTCM00 <dbl+lbl>,
#   FCWTCM00 <dbl+lbl>, GCWTCM00 <dbl+lbl>
```

# Reshape a Cleaned Dataset from Long to Wide

It is likely that you will not just need to reshape raw data, but
cleaned data too. In the next two sections we offer advice on naming
variables so that they are easy to select and reshape in long or wide
formats. First, let’s clean the long dataset by converting the `cnum`
and `sweep` columns to integers, creating a new column for follow-up
time, and creating new `height` and `weight` variables that replace
negative values in the raw height and weight data with `NA` (as well as
giving these variables more easy-to-understand names).

```r
df_long_clean <- df_long %>%
  mutate(cnum = as.integer(cnum),
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
  pivot_wider(names_from = fup,
              values_from = c(height, weight),
              names_glue = "{.value}_{fup}y")

df_wide_clean
```

``` text
# A tibble: 17,614 × 14
   MCSID    cnum height_3y height_5y height_7y height_11y height_14y height_17y
   <chr>   <int>     <dbl>     <dbl>     <dbl>      <dbl>      <dbl>      <dbl>
 1 M10001N     1        97      114.      128.        NA         NA         NA 
 2 M10002P     1        96      110.      123        144.       163.       174.
 3 M10007U     1       102      118       129        154.       174.       181.
 4 M10008V     1        NA       NA        NA         NA         NA         NA 
 5 M10008V     2        NA       NA        NA         NA         NA         NA 
 6 M10011Q     1       106      121       137        168.        NA         NA 
 7 M10014T     1        97       NA        NA         NA         NA         NA 
 8 M10015U     1        94      110.      122.       143        164.       169 
 9 M10016V     1       102      118.      130        152.       167        185.
10 M10017W     1        99      110.      121.        NA         NA         NA 
# ℹ 17,604 more rows
# ℹ 6 more variables: weight_3y <dbl>, weight_5y <dbl>, weight_7y <dbl>,
#   weight_11y <dbl>, weight_14y <dbl>, weight_17y <dbl>
```

# Reshape a Cleaned Dataset from Long to Wide

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
  pivot_longer(cols = matches("_.*y$"),
               names_to = c(".value", "fup"),
               names_pattern = "(.*)_(\\d+)y$",
               names_transform = list(fup = as.integer))
```

``` text
# A tibble: 105,684 × 5
   MCSID    cnum   fup height weight
   <chr>   <int> <int>  <dbl>  <dbl>
 1 M10001N     1     3    97    NA  
 2 M10001N     1     5   114.   21.2
 3 M10001N     1     7   128.   25.5
 4 M10001N     1    11    NA    NA  
 5 M10001N     1    14    NA    NA  
 6 M10001N     1    17    NA    NA  
 7 M10002P     1     3    96    NA  
 8 M10002P     1     5   110.   19.2
 9 M10002P     1     7   123    26.2
10 M10002P     1    11   144.   NA  
# ℹ 105,674 more rows
```
