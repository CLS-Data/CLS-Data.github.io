---
layout: default
title: Combining Data Across Sweeps
nav_order: 4
parent: Next Steps
format:
  gfm:
    variant: +yaml_metadata_block
---


- [Download the R script for this
  page](../purl/next_steps-merging_across_sweeps.R)

# Introduction

In this section, we show how to combine Next Steps data across sweeps,
assuming the data to be merged have one row per cohort member; for
information on restructuring data that are not in this format see the
page [*Combining Data Within A
Sweep*](https://cls-data.github.io/docs/next_steps-merging_within_sweep.html).

As an example, we use data on cohort members’ GHQ-12 scores (a measure
of psychological distress), which were recorded in Sweeps 2, 4, 8 and 9
(ages 15, 17, 25 and 32). The scores are available in the Sweep 2 and 4
young person files (`wave_two_lsype_young_person_2020.dta` and
`wave_four_lsype_young_person_2020.dta`) and the Sweep 8 and 9 derived
variable files (`ns8_2015_derived.dta` and
`ns9_2022_derived_variables.dta`). These files contain one row per
cohort member. All four are stored in the `safeguarded_eul` subfolder.

We begin by combining data from the second and fourth sweeps, showing
how to combine these datasets in **wide** (one row per observational
unit) and **long** (multiple rows per observational unit) formats by
*merging* and *appending*, respectively. We then show how to combine
data from multiple sweeps *programmatically* using the `dplyr` and
`purrr` packages (from the `tidyverse`). This requires a little more
preparation than in, e.g., the
[MCS](https://cls-data.github.io/docs/mcs-merging_across_sweeps.html),
as the names of files and variables do not follow a single convention
across the whole study.

We use the following packages:

``` r
# Load Packages
library(tidyverse) # For data manipulation
library(haven) # For importing .dta files
library(labelled) # For handling missing values
```

# Merging Across Sweeps

The variables `W2ghq12scr` and `W4ghq12scr` contain the cohort member’s
GHQ-12 score at Sweep 2 and Sweep 4, respectively. [Variable names in
Next Steps begin with a prefix denoting the
sweep](https://cls-data.github.io/docs/next_steps-data_structures.html)
(`W2`, `W4`), and in this case the rest of the name is the same in the
two sweeps. Cohort members are identified with a single variable,
`NSID`, which has the same name in every file. We will use the
`read_dta()` function from `haven` to read in the data from the second
and fourth sweeps, specifying the `col_select` argument to keep only the
variables we need (the identifier and GHQ-12 score).

``` r
df_w2 <- read_dta("safeguarded_eul/wave_two_lsype_young_person_2020.dta",
                  col_select = c("NSID", "W2ghq12scr"))

df_w4 <- read_dta("safeguarded_eul/wave_four_lsype_young_person_2020.dta",
                  col_select = c("NSID", "W4ghq12scr"))
```

We can merge these datasets by row using the `*_join()` family of
functions. These share a common syntax. They take two data frames (`x`
and `y`) as arguments, as well as a `by` argument that specifies the
variable(s) to join on. The `*_join()` functions are:

1.  `full_join(x, y)`: Returns all rows from `x` and `y`, and all
    columns from `x` and `y`. For rows without matches in both `x` and
    `y`, the missing value `NA` is used for columns that are not used as
    identifiers.
2.  `inner_join(x, y)`: Returns all rows from `x` and `y` where there
    are matching rows in both data frames.
3.  `left_join(x, y)`: Returns all rows from `x`, and all columns from
    `x` and `y`. Rows in `x` with no match in `y` will have `NA` values
    in the new columns from `y`.
4.  `right_join(x, y)`: Returns all rows from `y`, and all columns from
    `x` and `y`. Rows in `y` with no match in `x` will have `NA` values
    in the columns of `x`.

In the current context, where `x` is data from the second sweep
(`df_w2`) and `y` is data from the fourth sweep (`df_w4`), and these
datasets only contain rows for *respondents*: `full_join()` will return
a row for each individual present in the second or fourth sweeps, with
the GHQ-12 score from each sweep in the same row; `inner_join()` will
return a row for each individual who was present in both sweeps, with
the GHQ-12 score from each sweep in the same row; `left_join()` will
return a row for each individual in the second sweep, with the GHQ-12
score from the fourth sweep in the same row if the individual was
present in the fourth sweep; `right_join()` will return a row for each
individual in the fourth sweep, with the GHQ-12 score from the second
sweep in the same row if the individual was present in the second sweep.

To specify the identifier, we pass its name to the `by` argument. The
`*_join()` functions can also handle multiple variables to join on, as
well as situations where the identifiers have different names across `x`
and `y`, but neither is necessary here.

``` r
df_w2 %>%
  full_join(df_w4, by = "NSID")
```

    # A tibble: 13,885 × 3
       NSID     W2ghq12scr    W4ghq12scr
       <chr>    <dbl+lbl>     <dbl+lbl> 
     1 NS10001S -92 [Refused]  0        
     2 NS10002T   3            5        
     3 NS10003V   0            0        
     4 NS10004W   4            1        
     5 NS10005X   2           NA        
     6 NS10006Y   0            0        
     7 NS10007Z   2            0        
     8 NS10008A   0            3        
     9 NS10010L   0           NA        
    10 NS10011M   0            5        
    # ℹ 13,875 more rows

``` r
df_w2 %>%
  inner_join(df_w4, by = "NSID")
```

    # A tibble: 11,436 × 3
       NSID     W2ghq12scr    W4ghq12scr
       <chr>    <dbl+lbl>     <dbl+lbl> 
     1 NS10001S -92 [Refused] 0         
     2 NS10002T   3           5         
     3 NS10003V   0           0         
     4 NS10004W   4           1         
     5 NS10006Y   0           0         
     6 NS10007Z   2           0         
     7 NS10008A   0           3         
     8 NS10011M   0           5         
     9 NS10014Q   1           0         
    10 NS10019W   0           0         
    # ℹ 11,426 more rows

``` r
df_w2 %>%
  left_join(df_w4, by = "NSID")
```

    # A tibble: 13,530 × 3
       NSID     W2ghq12scr    W4ghq12scr
       <chr>    <dbl+lbl>     <dbl+lbl> 
     1 NS10001S -92 [Refused]  0        
     2 NS10002T   3            5        
     3 NS10003V   0            0        
     4 NS10004W   4            1        
     5 NS10005X   2           NA        
     6 NS10006Y   0            0        
     7 NS10007Z   2            0        
     8 NS10008A   0            3        
     9 NS10010L   0           NA        
    10 NS10011M   0            5        
    # ℹ 13,520 more rows

``` r
df_w2 %>%
  right_join(df_w4, by = "NSID")
```

    # A tibble: 11,791 × 3
       NSID     W2ghq12scr    W4ghq12scr
       <chr>    <dbl+lbl>     <dbl+lbl> 
     1 NS10001S -92 [Refused] 0         
     2 NS10002T   3           5         
     3 NS10003V   0           0         
     4 NS10004W   4           1         
     5 NS10006Y   0           0         
     6 NS10007Z   2           0         
     7 NS10008A   0           3         
     8 NS10011M   0           5         
     9 NS10014Q   1           0         
    10 NS10019W   0           0         
    # ℹ 11,781 more rows

Note, the `*_join()` functions will merge any matching rows. Unlike
`Stata`, we do not have to explicitly state whether we want a 1-to-1,
many-to-1, 1-to-many, or many-to-many merge. This is determined by the
data that are inputted to `*_join()`. `R` will not throw an error if
matches are not 1-to-1 (though it does throw a warning where matches are
many-to-many), so care must be taken, for instance, when merging files
with different structures. See [*Combining Data Within A
Sweep*](https://cls-data.github.io/docs/next_steps-merging_within_sweep.html)
for more information.

# Appending Sweeps

To put the data into long format, we can use the `bind_rows()` function.
(In this case, the data will have one row per cohort-member x sweep
combination.) To work properly, we need to name the variables
consistently across sweeps, which here means removing the sweep-specific
prefixes (e.g., the `W2` from `W2ghq12scr` in `df_w2`). We also need to
add a variable to identify the sweep the data comes from. Below, we use
the `mutate()` function to create a `sweep` variable and then use the
`rename_with()` function to remove the prefixes and rename the variables
consistently across sweeps.

``` r
df_w2_noprefix <- df_w2 %>%
  mutate(sweep = 2, .before = 1) %>%
  rename_with(~ str_remove(.x, "^W2"))

df_w4_noprefix <- df_w4 %>%
  mutate(sweep = 4, .before = 1) %>%
  rename_with(~ str_remove(.x, "^W4"))
```

`rename_with()` applies a function to the names of the variables. In
this case, we use the `str_remove()` function from the `stringr` package
(part of the `tidyverse`) to remove the prefix from the variable names.
The `~` symbol is used to create an [*anonymous
function*](https://r4ds.hadley.nz/iteration.html), which is applied to
each variable name. The `.x` symbol in the anonymous function is a
placeholder for the variable name. `str_remove()` takes a regular
expression. The `^` symbol is used to match the start of the string (so
`^W2` removes `W2` where these are the first characters in a variable
name). Note, for the `mutate()` call, the `.before` argument is used to
specify the position of the new variable in the data frame - here we
specify `sweep` as the first column. Below we see what the formatted
data frames look like:

``` r
df_w2_noprefix
```

    # A tibble: 13,530 × 3
       sweep NSID     ghq12scr     
       <dbl> <chr>    <dbl+lbl>    
     1     2 NS10001S -92 [Refused]
     2     2 NS10002T   3          
     3     2 NS10003V   0          
     4     2 NS10004W   4          
     5     2 NS10005X   2          
     6     2 NS10006Y   0          
     7     2 NS10007Z   2          
     8     2 NS10008A   0          
     9     2 NS10010L   0          
    10     2 NS10011M   0          
    # ℹ 13,520 more rows

``` r
df_w4_noprefix
```

    # A tibble: 11,791 × 3
       sweep NSID     ghq12scr 
       <dbl> <chr>    <dbl+lbl>
     1     4 NS10001S 0        
     2     4 NS10002T 5        
     3     4 NS10003V 0        
     4     4 NS10004W 1        
     5     4 NS10006Y 0        
     6     4 NS10007Z 0        
     7     4 NS10008A 3        
     8     4 NS10011M 5        
     9     4 NS10014Q 0        
    10     4 NS10019W 0        
    # ℹ 11,781 more rows

Now the data have been prepared, we can use `bind_rows()` to append the
data frames together. This will stack the data frames on top of each
other, so the number of rows is equal to the sum of rows in the
individual datasets. The `bind_rows()` function can handle data frames
with different numbers of columns. Missing columns are filled with `NA`
values.

``` r
bind_rows(df_w2_noprefix, df_w4_noprefix) %>%
  arrange(NSID, sweep) # Sorts the dataset by ID and sweep
```

    # A tibble: 25,321 × 3
       sweep NSID     ghq12scr     
       <dbl> <chr>    <dbl+lbl>    
     1     2 NS10001S -92 [Refused]
     2     4 NS10001S   0          
     3     2 NS10002T   3          
     4     4 NS10002T   5          
     5     2 NS10003V   0          
     6     4 NS10003V   0          
     7     2 NS10004W   4          
     8     4 NS10004W   1          
     9     2 NS10005X   2          
    10     2 NS10006Y   0          
    # ℹ 25,311 more rows

Notice that with `bind_rows()` a cohort member has only as many rows of
data as the times they appeared in Sweeps 2 and 4. This differs from
`*_join()` where an explicit missing `NA` value is generated for the
missing sweep. The `tidyverse` function `complete()` [can be used to
create missing
rows](https://r4ds.hadley.nz/missing-values.html#sec-missing-implicit),
which can be useful if you need to generate a balanced panel of
observations from which to begin analysis with (e.g., when performing
multiple imputation in long format).

``` r
bind_rows(df_w2_noprefix, df_w4_noprefix) %>%
  complete(NSID, sweep) %>% # Ensure cohort members have a row for each sweep
  arrange(NSID, sweep)
```

    # A tibble: 27,770 × 3
       NSID     sweep ghq12scr     
       <chr>    <dbl> <dbl+lbl>    
     1 NS10001S     2 -92 [Refused]
     2 NS10001S     4   0          
     3 NS10002T     2   3          
     4 NS10002T     4   5          
     5 NS10003V     2   0          
     6 NS10003V     4   0          
     7 NS10004W     2   4          
     8 NS10004W     4   1          
     9 NS10005X     2   2          
    10 NS10005X     4  NA          
    # ℹ 27,760 more rows

Note, `rename_with()` can also be used to ensure that variables use the
same case in each sweep - for instance, `rename_with(str_to_upper)`
converts every variable name in a dataset to upper case. This is useful
in Next Steps as the use of upper and lower case in variable names
sometimes varies in hard-to-predict ways across sweeps (e.g.,
`W1alceverYP` and `W4AlcEverYP`).

# Combining Sweeps Programmatically

Combining sweeps manually can become tedious when more than two sweeps
need to be combined. Instead, [iterative
programming](https://r4ds.hadley.nz/iteration) can be used to automate
the process. Below we show how to merge and append multiple sweeps
together with very little code using the `purrr` package (part of the
`tidyverse`).

In some studies, file and variable names follow a formula, so the name
of the file and variable for a given sweep can be constructed from the
sweep number. This is not the case in Next Steps. The sweep is written
as a word in the names of files from Sweeps 1-7 (`wave_two_...`) and as
a number in the names of files from Sweeps 8 and 9 (`ns8_...`), and the
GHQ-12 score is named `W2ghq12scr` and `W4ghq12scr` in Sweeps 2 and 4
but `W8DGHQSC` and `W9DGHQSC` in Sweeps 8 and 9. A simple way of
handling this is to create a lookup table that lists the file and
variable to use for each sweep. Below, we create one using the
`tribble()` function, which allows a `tibble` to be written out
row-by-row. Note, the `file` column includes the subfolder in which each
file is stored. (See [*Data
Discovery*](https://cls-data.github.io/docs/next_steps-data_discovery.html)
for ways of finding the names of the files and variables you need.)

``` r
df_files <- tribble(
  ~sweep, ~file,                                                   ~ghq_var,
  2,      "safeguarded_eul/wave_two_lsype_young_person_2020.dta",  "W2ghq12scr",
  4,      "safeguarded_eul/wave_four_lsype_young_person_2020.dta", "W4ghq12scr",
  8,      "safeguarded_eul/ns8_2015_derived.dta",                  "W8DGHQSC",
  9,      "safeguarded_eul/ns9_2022_derived_variables.dta",        "W9DGHQSC"
)

df_files
```

    # A tibble: 4 × 3
      sweep file                                                  ghq_var   
      <dbl> <chr>                                                 <chr>     
    1     2 safeguarded_eul/wave_two_lsype_young_person_2020.dta  W2ghq12scr
    2     4 safeguarded_eul/wave_four_lsype_young_person_2020.dta W4ghq12scr
    3     8 safeguarded_eul/ns8_2015_derived.dta                  W8DGHQSC  
    4     9 safeguarded_eul/ns9_2022_derived_variables.dta        W9DGHQSC  

## Merging Programmatically

Before merging the datasets together, we need to load the data for each
sweep. We can do this by creating a function, `load_ghq_wide()`, which
takes three arguments - `sweep`, `file`, and `ghq_var` - corresponding
to the columns of `df_files`, and loads the GHQ-12 data from the
specified file. The `col_select` argument is again used to keep only the
variables we need. As the name of the GHQ-12 variable is stored in an
object (`ghq_var`), we wrap the names in `all_of()`, which tells
`read_dta()` to select the variables whose names are stored in the
vector.

``` r
load_ghq_wide <- function(sweep, file, ghq_var){
  read_dta(file, col_select = all_of(c("NSID", ghq_var)))
}
```

To confirm the function is working correctly, below we call it to load
data from the eighth sweep.

``` r
load_ghq_wide(8, "safeguarded_eul/ns8_2015_derived.dta", "W8DGHQSC")
```

    # A tibble: 7,705 × 2
       NSID     W8DGHQSC           
       <chr>    <dbl+lbl>          
     1 NS10001S  0                 
     2 NS10004W  6                 
     3 NS10011M  3                 
     4 NS10020F  0                 
     5 NS10021G  2                 
     6 NS10026M  5                 
     7 NS10027N  0                 
     8 NS10029Q -1 [Not applicable]
     9 NS10030A  2                 
    10 NS10031B  0                 
    # ℹ 7,695 more rows

We could manually load and merge successively using multiple
`load_ghq_wide()` and `full_join()` function calls. However, this is
rather verbose:

``` r
load_ghq_wide(2, "safeguarded_eul/wave_two_lsype_young_person_2020.dta", "W2ghq12scr") %>%
  full_join(load_ghq_wide(4, "safeguarded_eul/wave_four_lsype_young_person_2020.dta", "W4ghq12scr"),
            by = "NSID") %>%
  full_join(load_ghq_wide(8, "safeguarded_eul/ns8_2015_derived.dta", "W8DGHQSC"),
            by = "NSID") %>%
  full_join(load_ghq_wide(9, "safeguarded_eul/ns9_2022_derived_variables.dta", "W9DGHQSC"),
            by = "NSID")
```

    # A tibble: 14,586 × 5
       NSID     W2ghq12scr    W4ghq12scr W8DGHQSC  W9DGHQSC 
       <chr>    <dbl+lbl>     <dbl+lbl>  <dbl+lbl> <dbl+lbl>
     1 NS10001S -92 [Refused]  0          0        NA       
     2 NS10002T   3            5         NA         0       
     3 NS10003V   0            0         NA        NA       
     4 NS10004W   4            1          6         0       
     5 NS10005X   2           NA         NA        NA       
     6 NS10006Y   0            0         NA         7       
     7 NS10007Z   2            0         NA        NA       
     8 NS10008A   0            3         NA        NA       
     9 NS10010L   0           NA         NA        NA       
    10 NS10011M   0            5          3         0       
    # ℹ 14,576 more rows

More efficiently, we can use the `pmap()` function from the `purrr`
package (part of the `tidyverse`) to apply the `load_ghq_wide()`
function to each row of `df_files` in turn. `pmap()` takes a data frame
(or list) as its first argument and a function to apply as its second
argument. It calls the function once per row of the data frame, matching
the columns of the data frame to the arguments of the function by name
(which is why the arguments of `load_ghq_wide()` have the same names as
the columns of `df_files`). `pmap()` returns the results as a `list`.
Below we use `pmap()` to run `load_ghq_wide()` for Sweeps 2, 4, 8 and 9.
To save space, we do not print the output.

``` r
pmap(df_files, load_ghq_wide)
```

To merge the list of datasets returned by `pmap()` together, we can use
the `reduce()` function from `purrr`. `reduce()` takes an object as its
first argument, and a function as its second argument. It applies the
function to the first *two* elements of the object placed into the first
argument, and then successively applies the function to the result and
the third element of the list onwards, until the list is finished.
Below, we use `reduce()` to apply the `full_join()` function to the list
of data frames. We specify `full_join()` in an anonymous function. `.x`
and `.y` are the first and second inputs, respectively. In this case, at
the first iteration Sweep 2 (`.x`) is merged with Sweep 4 (`.y`), and at
the second iteration, the result of the first iteration (`.x`) is merged
with Sweep 8 (`.y`). This process is repeated until Sweep 9 has been
merged in.

``` r
df_ghq_wide <- pmap(df_files, load_ghq_wide) %>%
  reduce(~ full_join(.x, .y, by = "NSID"))

df_ghq_wide
```

    # A tibble: 14,586 × 5
       NSID     W2ghq12scr    W4ghq12scr W8DGHQSC  W9DGHQSC 
       <chr>    <dbl+lbl>     <dbl+lbl>  <dbl+lbl> <dbl+lbl>
     1 NS10001S -92 [Refused]  0          0        NA       
     2 NS10002T   3            5         NA         0       
     3 NS10003V   0            0         NA        NA       
     4 NS10004W   4            1          6         0       
     5 NS10005X   2           NA         NA        NA       
     6 NS10006Y   0            0         NA         7       
     7 NS10007Z   2            0         NA        NA       
     8 NS10008A   0            3         NA        NA       
     9 NS10010L   0           NA         NA        NA       
    10 NS10011M   0            5          3         0       
    # ℹ 14,576 more rows

## Appending Programmatically

To append the datasets together, we create a second function,
`load_ghq_long()`, to load the GHQ-12 data from a given sweep and format
it so that it can be appended to the other sweeps (i.e., giving
variables consistent names). As the GHQ-12 variable is not named
consistently across sweeps, removing the sweep prefix is not sufficient
here. Instead, we use `rename()` to give the variable a new name,
`ghq12`. We also add a variable identifying the sweep. Note, the GHQ-12
scores are stored as `labelled` variables, with value labels attached to
the negative values that indicate different types of missing data. The
value labels (and the values used for missing data) differ between the
DfE and CLS eras, so we use `zap_labels()` (from `haven`) to remove the
labels, leaving a standard numeric variable.

``` r
load_ghq_long <- function(sweep, file, ghq_var){
  read_dta(file, col_select = all_of(c("NSID", ghq_var))) %>%
    rename(ghq12 = all_of(ghq_var)) %>%
    mutate(ghq12 = zap_labels(ghq12),
           sweep = sweep, .before = 1)
}
```

To load data from Sweeps 2, 4, 8 and 9 and append them together, we can
again use `pmap()` and pass the result to `bind_rows()`, which can take
a list of data frames as its input. As before, we use `arrange()` to
sort the dataset by ID and sweep.

``` r
df_ghq_long <- pmap(df_files, load_ghq_long) %>%
  bind_rows() %>%
  arrange(NSID, sweep) # Sorts the dataset by ID and sweep

df_ghq_long
```

    # A tibble: 40,305 × 3
       sweep NSID     ghq12
       <dbl> <chr>    <dbl>
     1     2 NS10001S   -92
     2     4 NS10001S     0
     3     8 NS10001S     0
     4     2 NS10002T     3
     5     4 NS10002T     5
     6     9 NS10002T     0
     7     2 NS10003V     0
     8     4 NS10003V     0
     9     2 NS10004W     4
    10     4 NS10004W     1
    # ℹ 40,295 more rows

Before using these data, the negative values would need to be replaced
with missing values (`NA`). Below, we do this with the
`negative_to_na()` function introduced in [*Data
Structures*](https://cls-data.github.io/docs/next_steps-data_structures.html#missing-values),
which uses the `labelled` package.

``` r
negative_to_na <- function(x){
  na_range(x) <- c(-Inf, -1)
  user_na_to_na(x)
}

df_ghq_long %>%
  mutate(ghq12 = negative_to_na(ghq12)) # Replaces negative values with NA
```

    # A tibble: 40,305 × 3
       sweep NSID     ghq12    
       <dbl> <chr>    <dbl+lbl>
     1     2 NS10001S NA       
     2     4 NS10001S  0       
     3     8 NS10001S  0       
     4     2 NS10002T  3       
     5     4 NS10002T  5       
     6     9 NS10002T  0       
     7     2 NS10003V  0       
     8     4 NS10003V  0       
     9     2 NS10004W  4       
    10     4 NS10004W  1       
    # ℹ 40,295 more rows

# Coda: Defining the Sample with the Longitudinal File

A cohort member only appears in a sweep’s files if they took part in
that sweep. The combined datasets created above therefore only include
cohort members who took part in at least one of the sweeps used, and do
not tell us *why* a cohort member has no data for a particular sweep.
This is especially relevant in Next Steps because [an ethnic minority
boost sample was added to the study at Sweep
4](https://cls-data.github.io/docs/next_steps-data_structures.html).
Boost sample members have no data for Sweeps 1-3 because they were not
yet part of the study, not because they did not respond.

The file `safeguarded_eul/ns9_2022_longitudinal_file.dta` contains one
row for every cohort member, along with the fieldwork outcome at each
sweep (`W1OUTCOME`, `W2OUTCOME`, …, `W9OUTCOME`) and a variable
indicating whether the cohort member belongs to the original or boost
sample (`MAINBOOST`). (Boost sample members can also be identified with
the variable `W4Boost` in `wave_four_lsype_young_person_2020.dta`.) It
is good practice to begin with this file and merge other data onto it
with `left_join()`, so that the dataset contains all cohort members.
Below, we load the file, tabulate `MAINBOOST`, and merge on the wide
GHQ-12 dataset created above (latter output not shown). Note, we can use
regular expressions in `col_select` (via `matches()`) to select several
variables at once.

``` r
df_longitudinal <- read_dta("safeguarded_eul/ns9_2022_longitudinal_file.dta",
                            col_select = c("NSID", "MAINBOOST", matches("^W\\dOUTCOME$")))

df_longitudinal %>%
  count(MAINBOOST)
```

    # A tibble: 2 × 2
      MAINBOOST     n
      <dbl+lbl> <int>
    1 1 [Main]  15770
    2 2 [Boost]   352

``` r
df_longitudinal %>%
  left_join(df_ghq_wide, by = "NSID")
```

The boost sample can then be dropped with `filter(MAINBOOST == 1)`
(`filter()` filters *in*) where an analysis uses data from Sweeps 1-3.
