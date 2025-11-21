# Combining Data Across Sweeps


- [Download the R script for this
  page](../purl/bcs70-merging_across_sweeps.R)
- [Download the equivalent Stata script for this
  page](../do_files/bcs70-merging_across_sweeps.do)

# Introduction

In this section, we show how to combine NCDS data across sweeps.

As an example, we use data on cohort members’ height. These are
contained in files which have one row per cohort-member. As a reminder,
we have organised the data files so that each sweep [has its own folder,
which is named according to the age of
follow-up](https://cls-data.github.io/docs/bcs70-sweep_folders.html)
(e.g., 10y for the third major sweep).

We begin by combining data from the Sweeps 9 (42y) and Sweep 11 (51y),
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

The variables `BD9HGHTM` and `bd11hghtm` contains the height of the
cohort member at Sweeps 9 (42y) and Sweep 11 (51y), respectively. Note,
these are derived variable which convert raw height measurements into
kilograms. The variable names follow the same convention (with the
exception that at age 51, lower case is used). This bucks the more
general case where conceptually similar variables have different
(potentially, non-descriptive) names, when combining data including
early sweeps.

We will use the `read_dta()` function from `haven` to read in the data
from the four sweeps, specifying the `col_select` argument to keep only
the variables we need (the identifier and height variables).

``` r
df_42y <- read_dta("42y/bcs70_2012_derived.dta",
                   col_select = c("BCSID", "BD9HGHTM"))

df_51y <- read_dta("51y/bcs11_age51_main.dta",
                   col_select = c("bcsid", "bd11hghtm"))
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

In the current context, where `x` is data from Sweep 9 (`df_42y`) and
`y` is data from Sweep 11 (`df_51y`): `full_join()` will return a row
for each individual present in Sweep 9 or Sweep 11, with the height from
each sweep in the same row; `inner_join()` will return a row for each
individual who was present in both these sweeps, with the height from
each sweep in the same row; `left_join()` will return a row for each
individual in the 9th sweep, with the height from the 11th sweep in the
same row if the individual was present in the 11th sweep; `right_join()`
will return a row for each individual in the 11th sweep, with the height
from the 9th sweep in the same row if the individual was present in the
9th sweep.

The `*_join()` functions can handle multiple variables to join on, and
can also handle situations where the identifiers have different names
across `x` and `y`. To specify the identifiers, we pass a vector to the
`by` argument. In this case, we pass a *named vector* so that `BCSID` in
`df_42y` can be matched to `bcsid` in `df_51y`.

``` r
df_42y %>%
  full_join(df_51y, by = c(BCSID = "bcsid"))
```

    # A tibble: 10,683 × 3
       BCSID   BD9HGHTM  bd11hghtm
       <chr>   <dbl+lbl> <dbl+lbl>
     1 B10001N 1.55       1.55    
     2 B10003Q 1.85       1.85    
     3 B10004R 1.60       1.6     
     4 B10007U 1.52      NA       
     5 B10009W 1.63       1.63    
     6 B10010P 1.65      NA       
     7 B10011Q 1.63       1.65    
     8 B10013S 1.63       1.63    
     9 B10015U 1.83       1.8     
    10 B10016V 1.88       1.88    
    # ℹ 10,673 more rows

``` r
df_42y %>%
  inner_join(df_51y, by = c(BCSID = "bcsid"))
```

    # A tibble: 7,174 × 3
       BCSID   BD9HGHTM  bd11hghtm
       <chr>   <dbl+lbl> <dbl+lbl>
     1 B10001N 1.55      1.55     
     2 B10003Q 1.85      1.85     
     3 B10004R 1.60      1.6      
     4 B10009W 1.63      1.63     
     5 B10011Q 1.63      1.65     
     6 B10013S 1.63      1.63     
     7 B10015U 1.83      1.8      
     8 B10016V 1.88      1.88     
     9 B10018X 1.73      1.7      
    10 B10020R 1.50      1.47     
    # ℹ 7,164 more rows

``` r
df_42y %>%
  left_join(df_51y, by = c(BCSID = "bcsid"))
```

    # A tibble: 9,841 × 3
       BCSID   BD9HGHTM  bd11hghtm
       <chr>   <dbl+lbl> <dbl+lbl>
     1 B10001N 1.55       1.55    
     2 B10003Q 1.85       1.85    
     3 B10004R 1.60       1.6     
     4 B10007U 1.52      NA       
     5 B10009W 1.63       1.63    
     6 B10010P 1.65      NA       
     7 B10011Q 1.63       1.65    
     8 B10013S 1.63       1.63    
     9 B10015U 1.83       1.8     
    10 B10016V 1.88       1.88    
    # ℹ 9,831 more rows

``` r
df_42y %>%
  right_join(df_51y, by = c(BCSID = "bcsid"))
```

    # A tibble: 8,016 × 3
       BCSID   BD9HGHTM  bd11hghtm
       <chr>   <dbl+lbl> <dbl+lbl>
     1 B10001N 1.55      1.55     
     2 B10003Q 1.85      1.85     
     3 B10004R 1.60      1.6      
     4 B10009W 1.63      1.63     
     5 B10011Q 1.63      1.65     
     6 B10013S 1.63      1.63     
     7 B10015U 1.83      1.8      
     8 B10016V 1.88      1.88     
     9 B10018X 1.73      1.7      
    10 B10020R 1.50      1.47     
    # ℹ 8,006 more rows

Note, the `*_join()` functions will merge any matching rows. Unlike
`Stata`, we do not have to explicitly state whether we want a 1-to-1,
many-to-1, 1-to-many, or many-to-many merge. This is determined by the
data that are inputted to `*_join()`.

When the `by = ...` isn’t used explicitly, the `*_join()` will merge on
any variables which have the same names across the two datasets. As
`df_42y` has variables in upper case and `df_51y` has variables in lower
case, we could have renamed the variables in `df_42y` in one fell swoop
with `rename_with(str_to_lower)`. There are usually many ways of
achieving the same thing.

``` r
df_42y %>%
  rename_with(str_to_lower) %>% # Converts all variable names to upper case
  full_join(df_51y)
```

    Joining with `by = join_by(bcsid)`

    # A tibble: 10,683 × 3
       bcsid   bd9hghtm  bd11hghtm
       <chr>   <dbl+lbl> <dbl+lbl>
     1 B10001N 1.55       1.55    
     2 B10003Q 1.85       1.85    
     3 B10004R 1.60       1.6     
     4 B10007U 1.52      NA       
     5 B10009W 1.63       1.63    
     6 B10010P 1.65      NA       
     7 B10011Q 1.63       1.65    
     8 B10013S 1.63       1.63    
     9 B10015U 1.83       1.8     
    10 B10016V 1.88       1.88    
    # ℹ 10,673 more rows

# Appending Sweeps

To put the data into long format, we can use the `bind_rows()` function.
(In this case, the data will have one row per cohort-member x sweep
combination.) To work properly, we need to name the variables
consistently across sweeps, which here means removing the sweep-specific
lettering (e.g., the string `BD9` from `BD9HGHTM` in `df_42y`). We also
need to add a variable to identify the sweep the data comes from. Below,
we use the `mutate()` function to create a `sweep` variable and then use
the `rename_with()` function to remove the suffixes and rename the
variables consistently across sweeps. (Given we only had one variable to
rename, we could have done this manually with `rename()`, but this
approach is more scalable.)

``` r
df_42y_nosuffix <- df_42y %>%
  rename_with(str_to_lower) %>%
  rename_with(~ str_remove(.x, "^bd9")) %>%  # Removes the suffix '23' from variable names
  mutate(sweep = 9, .before = 1)

df_51y_nosuffix <- df_51y %>%
  rename_with(~ str_remove(.x, "^bd11")) %>%
  mutate(sweep = 11, .before = 1)
```

`rename_with()` applies a function to the names of the variables. In
this case, we use the `str_remove()` function from the `stringr` package
(part of the `tidyverse`) to remove the suffix from the variable names.
The `~` symbol is used to create an [*anonymous
function*](https://r4ds.hadley.nz/iteration.html), which is applied to
each variable name. The `.x` symbol in the anonymous function is a
placeholder for the variable name. `str_remove()` takes a regular
expression. The `^` symbol is used to match the start of the string (so
`^bd9` removes the `bd9` where it is the first characters in a variable
name). Note, for the `mutate()` call, the `.before` argument is used to
specify the position of the new variable in the data frame - here we
specify `sweep` as the first column. Below we see what the formatted
data frames look like:

``` r
df_42y_nosuffix
```

    # A tibble: 9,841 × 3
       sweep bcsid   hghtm    
       <dbl> <chr>   <dbl+lbl>
     1     9 B10001N 1.55     
     2     9 B10003Q 1.85     
     3     9 B10004R 1.60     
     4     9 B10007U 1.52     
     5     9 B10009W 1.63     
     6     9 B10010P 1.65     
     7     9 B10011Q 1.63     
     8     9 B10013S 1.63     
     9     9 B10015U 1.83     
    10     9 B10016V 1.88     
    # ℹ 9,831 more rows

``` r
df_51y_nosuffix
```

    # A tibble: 8,016 × 3
       sweep bcsid   hghtm    
       <dbl> <chr>   <dbl+lbl>
     1    11 B10001N 1.55     
     2    11 B10003Q 1.85     
     3    11 B10004R 1.6      
     4    11 B10009W 1.63     
     5    11 B10011Q 1.65     
     6    11 B10013S 1.63     
     7    11 B10015U 1.8      
     8    11 B10016V 1.88     
     9    11 B10018X 1.7      
    10    11 B10020R 1.47     
    # ℹ 8,006 more rows

Now the data have been prepared, we can use `bind_rows()` to append the
data frames together. This will stack the data frames on top of each
other, so the number of rows is equal to the sum of rows in the
individual datasets. The `bind_rows()` function can handle data frames
with different numbers of columns. Missing columns are filled with `NA`
values.

``` r
bind_rows(df_42y_nosuffix, df_51y_nosuffix) %>%
  arrange(bcsid, sweep) # Sorts the dataset by ID and sweep
```

    # A tibble: 17,857 × 3
       sweep bcsid   hghtm    
       <dbl> <chr>   <dbl+lbl>
     1     9 B10001N 1.55     
     2    11 B10001N 1.55     
     3     9 B10003Q 1.85     
     4    11 B10003Q 1.85     
     5     9 B10004R 1.60     
     6    11 B10004R 1.6      
     7     9 B10007U 1.52     
     8     9 B10009W 1.63     
     9    11 B10009W 1.63     
    10     9 B10010P 1.65     
    # ℹ 17,847 more rows

Notice that with `bind_rows()` a cohort member has only as many rows of
data as the times they appeared in Sweeps 9 and 11. This differs from
`*_join()` where an explicit missing `NA` value is generated for the
missing sweep. The `tidyverse` function `complete()` [can be used to
create missing
rows](https://r4ds.hadley.nz/missing-values.html#sec-missing-implicit),
which can be useful if you need to generate a balanced panel of
observations from which to begin analysis with (e.g., when performing
multiple imputation in long format).

``` r
bind_rows(df_42y_nosuffix, df_51y_nosuffix) %>%
  complete(bcsid, sweep) %>% # Ensure cohort members have a row for each sweep
  arrange(bcsid, sweep) 
```

    # A tibble: 21,366 × 3
       bcsid   sweep hghtm    
       <chr>   <dbl> <dbl+lbl>
     1 B10001N     9  1.55    
     2 B10001N    11  1.55    
     3 B10003Q     9  1.85    
     4 B10003Q    11  1.85    
     5 B10004R     9  1.60    
     6 B10004R    11  1.6     
     7 B10007U     9  1.52    
     8 B10007U    11 NA       
     9 B10009W     9  1.63    
    10 B10009W    11  1.63    
    # ℹ 21,356 more rows
