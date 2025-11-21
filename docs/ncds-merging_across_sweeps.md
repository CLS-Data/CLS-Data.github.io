# Combining Data Across Sweeps


- [Download the R script for this
  page](../purl/ncds-merging_across_sweeps.R)
- [Download the equivalent Stata script for this
  page](../do_files/ncds-merging_across_sweeps.do)

# Introduction

In this section, we show how to combine NCDS data across sweeps.

As an example, we use data on cohort members’ weight. These are
contained in files which have one row per cohort-member. As a reminder,
we have organised the data files so that each sweep [has its own folder,
which is named according to the age of
follow-up](https://cls-data.github.io/docs/ncds-sweep_folders.html)
(e.g., 55y for the ninth major sweep).

We begin by combining data from the Sweeps 4 (23y) and Sweep 8 (50y),
showing how to combine these datasets in **wide** (one row per
observational unit) and **long** (multiple rows per observational unit)
formats by *merging* and *appending*, respectively. Because variable
names change between sweeps in unpredictable ways, it is not
straightforwardly possible to combine data from multiple sweeps
*programmatically* (as we are able to do for, e.g., the
[MCS](https://cls-data.github.io/docs/mcs-merging_across_sweeps.html)).

We use the following packages:

``` r
# Load Packages
library(tidyverse) # For data manipulation
library(haven) # For importing .dta files
```

# Merging Across Sweeps

The variables `dvwt23` and `DVWT50` contains the weight of the cohort
member at Sweeps 4 (23y) and Sweep 8 (50y), respectively. Note, these
are derived variable which convert raw weight measurements into
kilograms. The variable names follow the same convention (with the
exception that at age 23y, lower case is used). This bucks the more
general case where conceptually similar variables have different
(potentially, non-descriptive) names, when combining data including
early sweeps.

We will use the `read_dta()` function from `haven` to read in the data
from the four sweeps, specifying the `col_select` argument to keep only
the variables we need (the identifier and weight variables).

``` r
df_23y <- read_dta("23y/ncds4.dta",
                      col_select = c("ncdsid", "dvwt23"))

df_50y <- read_dta("50y/ncds_2008_followup.dta",
                   col_select = c("NCDSID", "DVWT50"))
```

We can merge these datasets by row using the `*_join()` family of
functions. These share a common syntax. They take two data frames (`x`
and `y`) as arguments, as well as a `by` argument that specifies the
variable(s) to join on. The `*_join()` functions are:

1.  `full_join()`: Returns all rows from `x` and `y`, and all columns
    from `x` and `y`. For rows without matches in both `x` and `y`, the
    missing value `NA` is used for columns that are not used as
    identifiers.
2.  `inner_join()`: Returns all rows from `x` and `y` where there are
    matching rows in both data frames.
3.  `left_join()`: Returns all rows from `x`, and all columns from `x`
    and `y`. Rows in `x` with no match in `y` will have `NA` values in
    the new columns from `y`.
4.  `right_join()`: Returns all rows from `y`, and all columns from `x`
    and `y`. Rows in `y` with no match in `x` will have `NA` values in
    the columns of `x`.

In the current context, where `x` is data from the Sweeps 4 (`df_23y`)
and `y` is data from the 50y sweep (`df_50y`): `full_join()` will return
a row for each individual present in the Sweep 4 or Sweep 8, with the
weight from each sweep in the same row; `inner_join()` will return a row
for each individual who was present in all these sweeps, with the weight
from each sweep in the same row; `left_join()` will return a row for
each individual in the fourth sweep, with the weight from the eighth
sweep in the same row if the individual was present in the eighth sweep;
`right_join()` will return a row for each individual in the eighth
sweep, with the weight from the fourth sweep in the same row if the
individual was present in the fourth sweep.

The `*_join()` functions can handle multiple variables to join on, and
can also handle situations where the identifiers have different names
across `x` and `y`. To specify the identifiers, we pass a vector to the
`by` argument. In this case, we pass a *named vector* so that `ncdsid`
in `df_23y` can be matched to `NCDSID` in `df_50y`.

``` r
df_23y %>%
full_join(df_50y, by = c(ncdsid = "NCDSID"))
```

    # A tibble: 14,014 × 3
       ncdsid  dvwt23    DVWT50
       <chr>   <dbl+lbl>  <dbl>
     1 N10001N  59.4       66.7
     2 N10002P  73.5       79.4
     3 N10004R  76.2       NA  
     4 N10007U  52.2       72.1
     5 N10009W  66.7       78  
     6 N10011Q  63.5       95  
     7 N10012R 114.       133. 
     8 N10013S  83.5       95.2
     9 N10014T  57.2       63.5
    10 N10015U  73.0       78  
    # ℹ 14,004 more rows

``` r
df_23y %>%
inner_join(df_50y, by = c(ncdsid = "NCDSID"))
```

    # A tibble: 8,313 × 3
       ncdsid  dvwt23    DVWT50
       <chr>   <dbl+lbl>  <dbl>
     1 N10001N  59.4       66.7
     2 N10002P  73.5       79.4
     3 N10007U  52.2       72.1
     4 N10009W  66.7       78  
     5 N10011Q  63.5       95  
     6 N10012R 114.       133. 
     7 N10013S  83.5       95.2
     8 N10014T  57.2       63.5
     9 N10015U  73.0       78  
    10 N10016V  63.5       70.8
    # ℹ 8,303 more rows

``` r
df_23y %>%
left_join(df_50y, by = c(ncdsid = "NCDSID"))
```

    # A tibble: 12,537 × 3
       ncdsid  dvwt23    DVWT50
       <chr>   <dbl+lbl>  <dbl>
     1 N10001N  59.4       66.7
     2 N10002P  73.5       79.4
     3 N10004R  76.2       NA  
     4 N10007U  52.2       72.1
     5 N10009W  66.7       78  
     6 N10011Q  63.5       95  
     7 N10012R 114.       133. 
     8 N10013S  83.5       95.2
     9 N10014T  57.2       63.5
    10 N10015U  73.0       78  
    # ℹ 12,527 more rows

``` r
df_23y %>%
right_join(df_50y, by = c(ncdsid = "NCDSID"))
```

    # A tibble: 9,790 × 3
       ncdsid  dvwt23    DVWT50
       <chr>   <dbl+lbl>  <dbl>
     1 N10001N  59.4       66.7
     2 N10002P  73.5       79.4
     3 N10007U  52.2       72.1
     4 N10009W  66.7       78  
     5 N10011Q  63.5       95  
     6 N10012R 114.       133. 
     7 N10013S  83.5       95.2
     8 N10014T  57.2       63.5
     9 N10015U  73.0       78  
    10 N10016V  63.5       70.8
    # ℹ 9,780 more rows

Note, the `*_join()` functions will merge any matching rows. Unlike
`Stata`, we do not have to explicitly state whether we want a 1-to-1,
many-to-1, 1-to-many, or many-to-many merge. This is determined by the
data that are inputted to `*_join()`.

When the `by = ...` isn’t used explicitly, the `*_join()` will merge on
any variables which have the same names across the two datasets. As
`df_23y` has variables in lower case and `df_50y` has variables in upper
case, we could have renamed the variables in `df_23y` in one fell swoop
with `rename_with(str_to_upper)`. There are usually many ways of
achieving the same thing.

``` r
df_23y %>%
rename_with(str_to_upper) %>% # Converts all variable names to upper case
full_join(df_50y)
```

    Joining with `by = join_by(NCDSID)`

    # A tibble: 14,014 × 3
       NCDSID  DVWT23    DVWT50
       <chr>   <dbl+lbl>  <dbl>
     1 N10001N  59.4       66.7
     2 N10002P  73.5       79.4
     3 N10004R  76.2       NA  
     4 N10007U  52.2       72.1
     5 N10009W  66.7       78  
     6 N10011Q  63.5       95  
     7 N10012R 114.       133. 
     8 N10013S  83.5       95.2
     9 N10014T  57.2       63.5
    10 N10015U  73.0       78  
    # ℹ 14,004 more rows

# Appending Sweeps

To put the data into long format, we can use the `bind_rows()` function.
(In this case, the data will have one row per cohort-member x sweep
combination.) To work properly, we need to name the variables
consistently across sweeps, which here means removing the age-specific
suffixes (e.g., the number `23` from `dvwt23` in `df_3y`). We also need
to add a variable to identify the sweep the data comes from. Below, we
use the `mutate()` function to create a `sweep` variable and then use
the `rename_with()` function to remove the suffixes and rename the
variables consistently across sweeps. (Given we only had one variable to
rename, we could have done this manually with `rename()`, but this
approach is more scalable.)

``` r
df_23y_nosuffix <- df_23y %>%
rename_with(str_to_upper) %>%
rename_with(~ str_remove(.x, "23$")) %>%  # Removes the suffix '23' from variable names
mutate(sweep = 23, .before = 1)

df_50y_nosuffix <- df_50y %>%
rename_with(~ str_remove(.x, "50$")) %>%
mutate(sweep = 50, .before = 1)
```

`rename_with()` applies a function to the names of the variables. In
this case, we use the `str_remove()` function from the `stringr` package
(part of the `tidyverse`) to remove the suffix from the variable names.
The `~` symbol is used to create an [*anonymous
function*](https://r4ds.hadley.nz/iteration.html), which is applied to
each variable name. The `.x` symbol in the anonymous function is a
placeholder for the variable name. `str_remove()` takes a regular
expression. The `$` symbol is used to match the end of the string (so
`23$` removes the `23` where it is the last characters in a variable
name). Note, for the `mutate()` call, the `.before` argument is used to
specify the position of the new variable in the data frame - here we
specify `sweep` as the first column. Below we see what the formatted
data frames look like:

``` r
df_23y_nosuffix
```

    # A tibble: 12,537 × 3
       sweep NCDSID  DVWT     
       <dbl> <chr>   <dbl+lbl>
     1    23 N10001N  59.4    
     2    23 N10002P  73.5    
     3    23 N10004R  76.2    
     4    23 N10007U  52.2    
     5    23 N10009W  66.7    
     6    23 N10011Q  63.5    
     7    23 N10012R 114.     
     8    23 N10013S  83.5    
     9    23 N10014T  57.2    
    10    23 N10015U  73.0    
    # ℹ 12,527 more rows

``` r
df_50y_nosuffix
```

    # A tibble: 9,790 × 3
       sweep NCDSID   DVWT
       <dbl> <chr>   <dbl>
     1    50 N10001N  66.7
     2    50 N10002P  79.4
     3    50 N10007U  72.1
     4    50 N10008V  69.8
     5    50 N10009W  78  
     6    50 N10011Q  95  
     7    50 N10012R 133. 
     8    50 N10013S  95.2
     9    50 N10014T  63.5
    10    50 N10015U  78  
    # ℹ 9,780 more rows

Now the data have been prepared, we can use `bind_rows()` to append the
data frames together. This will stack the data frames on top of each
other, so the number of rows is equal to the sum of rows in the
individual datasets. The `bind_rows()` function can handle data frames
with different numbers of columns. Missing columns are filled with `NA`
values.

``` r
bind_rows(df_23y_nosuffix, df_50y_nosuffix) %>%
arrange(NCDSID, sweep) # Sorts the dataset by ID and sweep
```

    # A tibble: 22,327 × 3
       sweep NCDSID  DVWT     
       <dbl> <chr>   <dbl+lbl>
     1    23 N10001N 59.4     
     2    50 N10001N 66.7     
     3    23 N10002P 73.5     
     4    50 N10002P 79.4     
     5    23 N10004R 76.2     
     6    23 N10007U 52.2     
     7    50 N10007U 72.1     
     8    50 N10008V 69.8     
     9    23 N10009W 66.7     
    10    50 N10009W 78       
    # ℹ 22,317 more rows

Notice that with `bind_rows()` a cohort member has only as many rows of
data as the times they appeared in Sweeps 4 and 8. This differs from
`*_join()` where an explicit missing `NA` value is generated for the
missing sweep. The `tidyverse` function `complete()` [can be used to
create missing
rows](https://r4ds.hadley.nz/missing-values.html#sec-missing-implicit),
which can be useful if you need to generate a balanced panel of
observations from which to begin analysis with (e.g., when performing
multiple imputation in long format).

``` r
bind_rows(df_23y_nosuffix, df_50y_nosuffix) %>%
complete(NCDSID, sweep) %>% # Ensure cohort members have a row for each sweep
arrange(NCDSID, sweep) 
```

    # A tibble: 28,028 × 3
       NCDSID  sweep DVWT     
       <chr>   <dbl> <dbl+lbl>
     1 N10001N    23 59.4     
     2 N10001N    50 66.7     
     3 N10002P    23 73.5     
     4 N10002P    50 79.4     
     5 N10004R    23 76.2     
     6 N10004R    50 NA       
     7 N10007U    23 52.2     
     8 N10007U    50 72.1     
     9 N10008V    23 NA       
    10 N10008V    50 69.8     
    # ℹ 28,018 more rows
