---
layout: default
title: Combining Data Across Sweeps
nav_order: 4
parent: MCS
format: docusaurus-md
---




# Introduction

In this tutorial, we will learn how to combine MCS data across sweeps.
We will use data on cohort members’ height, which was recorded in Sweeps
2-7 and is available in the `mcs[2-7]_cm_interview.dta` files. These
files contain one row per cohort-member. As a reminder, we have
organised the data files so that each sweep [has its own folder, which
is named according to the age of
follow-up](https://cls-data.github.io/docs/mcs-sweep_folders.html)
(e.g., 3y for the second sweep).

We will begin by combining data from the second and third sweeps. We
will show code to combine datasets in **wide** (one row per
observational unit) and **long** (multiple rows per observational unit)
formats by *merging* and *appending*, respectively. We will then explore
how to combine data from multiple sweeps programmatically using the
`dplyr` and `purrr` packages (from the `tidyverse`).

We will use the following packages:

```r
# Load Packages
library(tidyverse) # For data manipulation
library(haven) # For importing .dta files
```

# Merging Across Sweeps

The variable `[B-G]CHTCM00` contains the height of the cohort member at
each sweep (except for Sweep 5, where the variable is called
`ECHTCMA0`). [The cohort-member identifiers are stored across two
variables](https://cls-data.github.io/docs/mcs-data_structures.html) in
the `mcs[2-7]_cm_interview.dta` files: `MCSID` and `[A-G]CNUM00`.
`MCSID` is the family identifier and `[A-G]CNUM00` identifies the cohort
member within the family. We will use the `read_dta()` function from the
`haven` package to read in the data from the second and third sweeps,
specifying the `col_select` argument to keep only the variables we need.

```r
df_3y <- read_dta("3y/mcs2_cm_interview.dta",
                  col_select = c("MCSID", "BCNUM00", "BCHTCM00"))

df_5y <- read_dta("5y/mcs3_cm_interview.dta",
                  col_select = c("MCSID", "CCNUM00", "CCHTCM00"))
```

We can merge the data using the `*_join()` family of functions. These
share a common syntax. They take two data frames (`x` and `y`) as
arguments, as well as a `by` argument that specifies the variable(s) to
join on. The `*_join()` functions are:

1.  `full_join()`: Returns all rows from `x` and `y`, and all columns
    from `x` and `y`. Where there are not matching values, uses `NA` in
    the non-joining columns.
2.  `inner_join()`: Returns all rows from `x` and `y` where there are
    matching values in both data frames.
3.  `left_join()`: Returns all rows from `x`, and all columns from `x`
    and `y`. Rows in `x` with no match in `y` will have `NA` values in
    the new columns.
4.  `right_join()`: Returns all rows from `y`, and all columns from `x`
    and `y`. Rows in `y` with no match in `x` will have `NA` values in
    the columns of `x` that are not used as identifiers.

In the current context, where `x` is data from the second sweep
(`df_3y`) and `y` is data from the third sweep (`df_5y`): `full_join()`
will return a row for each individual present in the second or third
sweeps, with the height from each sweep in the same row; `inner_join()`
will return a row for each individual who was present in both sweeps,
with the height from each sweep in the same row; `left_join()` will
return a row for each individual in the second sweep, with the height
from the third sweep in the same row if the individual was present in
the third sweep; `right_join()` will return a row for each individual in
the third sweep, with the height from the second sweep in the same row
if the individual was present in the second sweep.

The `*_join()` functions can handle multiple variables to join on, and
can also handle situations where the identifiers have different names
across `x` and `y`. To specify the identifiers, we pass a vector to the
`by` argument. In this case, we pass a *named vector* so that `BCNUM00`
in `df_3y` can be matched to `CCNUM00` in `df_5y`.

```r
df_3y %>%
  full_join(df_5y, by = c("MCSID", BCNUM00 = "CCNUM00"))
```

``` text
# A tibble: 17,242 × 4
   MCSID   BCNUM00                             BCHTCM00                 CCHTCM00
   <chr>   <dbl+lbl>                           <dbl+lbl>                <dbl+lb>
 1 M10001N 1 [1st Cohort Member of the family]  97                      114.    
 2 M10002P 1 [1st Cohort Member of the family]  96                      110.    
 3 M10007U 1 [1st Cohort Member of the family] 102                      118     
 4 M10008V 1 [1st Cohort Member of the family]  -2 [No Measurement tak…  NA     
 5 M10008V 2 [2nd Cohort Member of the family]  -2 [No Measurement tak…  NA     
 6 M10011Q 1 [1st Cohort Member of the family] 106                      121     
 7 M10014T 1 [1st Cohort Member of the family]  97                       NA     
 8 M10015U 1 [1st Cohort Member of the family]  94                      110.    
 9 M10016V 1 [1st Cohort Member of the family] 102                      118.    
10 M10017W 1 [1st Cohort Member of the family]  99                      110.    
# ℹ 17,232 more rows
```

```r
df_3y %>%
  inner_join(df_5y, by = c("MCSID", BCNUM00 = "CCNUM00"))
```

``` text
# A tibble: 13,967 × 4
   MCSID   BCNUM00                             BCHTCM00  CCHTCM00 
   <chr>   <dbl+lbl>                           <dbl+lbl> <dbl+lbl>
 1 M10001N 1 [1st Cohort Member of the family]  97       114.     
 2 M10002P 1 [1st Cohort Member of the family]  96       110.     
 3 M10007U 1 [1st Cohort Member of the family] 102       118      
 4 M10011Q 1 [1st Cohort Member of the family] 106       121      
 5 M10015U 1 [1st Cohort Member of the family]  94       110.     
 6 M10016V 1 [1st Cohort Member of the family] 102       118.     
 7 M10017W 1 [1st Cohort Member of the family]  99       110.     
 8 M10018X 1 [1st Cohort Member of the family]  97       113.     
 9 M10020R 1 [1st Cohort Member of the family]  97       112.     
10 M10021S 1 [1st Cohort Member of the family]  90       108      
# ℹ 13,957 more rows
```

```r
df_3y %>%
  left_join(df_5y, by = c("MCSID", BCNUM00 = "CCNUM00"))
```

``` text
# A tibble: 15,778 × 4
   MCSID   BCNUM00                             BCHTCM00                 CCHTCM00
   <chr>   <dbl+lbl>                           <dbl+lbl>                <dbl+lb>
 1 M10001N 1 [1st Cohort Member of the family]  97                      114.    
 2 M10002P 1 [1st Cohort Member of the family]  96                      110.    
 3 M10007U 1 [1st Cohort Member of the family] 102                      118     
 4 M10008V 1 [1st Cohort Member of the family]  -2 [No Measurement tak…  NA     
 5 M10008V 2 [2nd Cohort Member of the family]  -2 [No Measurement tak…  NA     
 6 M10011Q 1 [1st Cohort Member of the family] 106                      121     
 7 M10014T 1 [1st Cohort Member of the family]  97                       NA     
 8 M10015U 1 [1st Cohort Member of the family]  94                      110.    
 9 M10016V 1 [1st Cohort Member of the family] 102                      118.    
10 M10017W 1 [1st Cohort Member of the family]  99                      110.    
# ℹ 15,768 more rows
```

```r
df_3y %>%
  right_join(df_5y, by = c("MCSID", BCNUM00 = "CCNUM00"))
```

``` text
# A tibble: 15,431 × 4
   MCSID   BCNUM00                             BCHTCM00  CCHTCM00 
   <chr>   <dbl+lbl>                           <dbl+lbl> <dbl+lbl>
 1 M10001N 1 [1st Cohort Member of the family]  97       114.     
 2 M10002P 1 [1st Cohort Member of the family]  96       110.     
 3 M10007U 1 [1st Cohort Member of the family] 102       118      
 4 M10011Q 1 [1st Cohort Member of the family] 106       121      
 5 M10015U 1 [1st Cohort Member of the family]  94       110.     
 6 M10016V 1 [1st Cohort Member of the family] 102       118.     
 7 M10017W 1 [1st Cohort Member of the family]  99       110.     
 8 M10018X 1 [1st Cohort Member of the family]  97       113.     
 9 M10020R 1 [1st Cohort Member of the family]  97       112.     
10 M10021S 1 [1st Cohort Member of the family]  90       108      
# ℹ 15,421 more rows
```

# Appending Sweeps

To put the data into long format, we can use the `bind_rows()` function.
To work properly, we need to name the variables consistently across
sweeps, which in this case means removing the sweep-specific prefixes
(i.e., the letter `B` from `df_3y` and the letter `C` from `df_5y`). We
also need to add a variable to identify the sweep the data comes from.
Below, we use the `mutate()` function to create a `sweep` variable and
then use the `rename_with()` function to remove the prefixes and rename
the variables consistently across sweeps.

```r
df_3y_nopre <- df_3y %>%
  mutate(sweep = 2, .before = 1) %>%
  rename_with(~ str_remove(.x, "^B"))

df_5y_nopre <- df_5y %>%
  mutate(sweep = 3, .before = 1) %>%
  rename_with(~ str_remove(.x, "^C"))
```

`rename_with()` applies a function to the names of the variables. In
this case, we use the `str_remove()` function from the `stringr` package
(part of the `tidyverse`) to remove the prefix from the variable names.
The `~` symbol is used to create an *anonymous function*, which is
applied to each variable name. The `.x` symbol in the anonymous function
is a placeholder for the variable name. `str_remove()` takes a regular
expression. The `^` symbol is used to match the start of the string (so
`^C` removes the `C` where it is the first character in a variable
name - this is necessary to avoid removing the `C` within, e.g.,
`MCSID`). Note, for the `mutate()` call, the `.before` argument is used
to specify the position of the new variable in the data frame - here we
want it as the first column. Below we see what the formatted data frames
look like:

```r
df_3y_nopre
```

``` text
# A tibble: 15,778 × 4
   sweep MCSID   CNUM00                              CHTCM00                   
   <dbl> <chr>   <dbl+lbl>                           <dbl+lbl>                 
 1     2 M10001N 1 [1st Cohort Member of the family]  97                       
 2     2 M10002P 1 [1st Cohort Member of the family]  96                       
 3     2 M10007U 1 [1st Cohort Member of the family] 102                       
 4     2 M10008V 1 [1st Cohort Member of the family]  -2 [No Measurement taken]
 5     2 M10008V 2 [2nd Cohort Member of the family]  -2 [No Measurement taken]
 6     2 M10011Q 1 [1st Cohort Member of the family] 106                       
 7     2 M10014T 1 [1st Cohort Member of the family]  97                       
 8     2 M10015U 1 [1st Cohort Member of the family]  94                       
 9     2 M10016V 1 [1st Cohort Member of the family] 102                       
10     2 M10017W 1 [1st Cohort Member of the family]  99                       
# ℹ 15,768 more rows
```

```r
df_5y_nopre
```

``` text
# A tibble: 15,431 × 4
   sweep MCSID   CNUM00                              CHTCM00  
   <dbl> <chr>   <dbl+lbl>                           <dbl+lbl>
 1     3 M10001N 1 [1st Cohort Member of the family] 114.     
 2     3 M10002P 1 [1st Cohort Member of the family] 110.     
 3     3 M10007U 1 [1st Cohort Member of the family] 118      
 4     3 M10011Q 1 [1st Cohort Member of the family] 121      
 5     3 M10015U 1 [1st Cohort Member of the family] 110.     
 6     3 M10016V 1 [1st Cohort Member of the family] 118.     
 7     3 M10017W 1 [1st Cohort Member of the family] 110.     
 8     3 M10018X 1 [1st Cohort Member of the family] 113.     
 9     3 M10020R 1 [1st Cohort Member of the family] 112.     
10     3 M10021S 1 [1st Cohort Member of the family] 108      
# ℹ 15,421 more rows
```

Now the data have been prepared, we can use `bind_rows()` to append the
data frames together. This will stack the data frames on top of each
other, so the number of rows is equal to the sum of rows in the
individual datasets. The `bind_rows()` function can handle data frames
with different numbers of columns. Missing columns are filled with `NA`
values.

```r
bind_rows(df_3y_nopre, df_5y_nopre)
```

``` text
Warning: `..1$CHTCM00` and `..2$CHTCM00` have conflicting value labels.
ℹ Labels for these values will be taken from `..1$CHTCM00`.
✖ Values: -1
```

``` text
# A tibble: 31,209 × 4
   sweep MCSID   CNUM00                              CHTCM00                   
   <dbl> <chr>   <dbl+lbl>                           <dbl+lbl>                 
 1     2 M10001N 1 [1st Cohort Member of the family]  97                       
 2     2 M10002P 1 [1st Cohort Member of the family]  96                       
 3     2 M10007U 1 [1st Cohort Member of the family] 102                       
 4     2 M10008V 1 [1st Cohort Member of the family]  -2 [No Measurement taken]
 5     2 M10008V 2 [2nd Cohort Member of the family]  -2 [No Measurement taken]
 6     2 M10011Q 1 [1st Cohort Member of the family] 106                       
 7     2 M10014T 1 [1st Cohort Member of the family]  97                       
 8     2 M10015U 1 [1st Cohort Member of the family]  94                       
 9     2 M10016V 1 [1st Cohort Member of the family] 102                       
10     2 M10017W 1 [1st Cohort Member of the family]  99                       
# ℹ 31,199 more rows
```

# Combing Sweeps Programatically

Combining sweeps manually can become tedious when you need to combine
more than two sweeps together. Instead, [iterative
programming](https://r4ds.hadley.nz/iteration) can be used automate the
process. Below we show how to merge and append multiple sweeps together
with very little code using the `purrr` package (part of the
`tidyverse`).

## Merging Programmatically

Before merging the datasets together, we need to load the data for each
sweep. We can do this by creating a function, `load_height_wide()`,
which takes a single argument `sweep` and loads the height data for that
sweep. The function uses the `glue()` function from the `glue` package
to create the file path. We create and subset a vector of follow-up ages
(`fups`) to identify the correct folder to obtain the
`mcs{sweep}_cm_interview.dta` file from. The `glue()` function is used
to create strings from `R` objects. The curly braces (`{}`) act as
placeholders for variables or function calls that are computed when the
string is evaluated - e.g., when `sweep = 1`,
`{fup}y/mcs{sweep}_cm_interview.dta` = `0y/mcs1_cm_interview.dta`.
(`fup` is determined by subsetting the relevant element in the vectors
`fups`.) `glue` is part of the `tidyverse`, but is not a *core* package,
so needs to be loaded explicitly.

The file path is fed to the `read_dta()` function from the `haven`
package to read in the data, with the `col_select` argument used to keep
only the variables we need. Note we use a regular expression to select
the `CNUM` and height variables as these have slightly different names
each sweep. Typically variable names only differ on the sweep prefix
used (`ACHTM00`, `BCHTM00`), but in Sweep 5 (age 11y), the name of the
height variable (`ECHTCMA00`) diverges slightly from this pattern.
Below, we also include a step to `rename()` the `[B-G]CNUM00` variable
to `cnum` to ensure consistency across sweeps as this will make merging
more straightforward later.

```r
library(glue)
fups <- c(0, 3, 5, 7, 11, 14, 17)

load_height_wide <- function(sweep){
  fup <- fups[sweep]
  prefix <- LETTERS[sweep]
  
  glue("{fup}y/mcs{sweep}_cm_interview.dta") %>%
    read_dta(col_select = c("MCSID", matches("^.(CNUM00|CHTCM(A|0)0)"))) %>%
    rename(cnum = matches("CNUM00"))
}
```

To confirm the function is working correctly, let’s use it to load the
data the second and third sweeps.

```r
load_height_wide(2)
```

``` text
# A tibble: 15,778 × 3
   MCSID   cnum                                BCHTCM00                  
   <chr>   <dbl+lbl>                           <dbl+lbl>                 
 1 M10001N 1 [1st Cohort Member of the family]  97                       
 2 M10002P 1 [1st Cohort Member of the family]  96                       
 3 M10007U 1 [1st Cohort Member of the family] 102                       
 4 M10008V 1 [1st Cohort Member of the family]  -2 [No Measurement taken]
 5 M10008V 2 [2nd Cohort Member of the family]  -2 [No Measurement taken]
 6 M10011Q 1 [1st Cohort Member of the family] 106                       
 7 M10014T 1 [1st Cohort Member of the family]  97                       
 8 M10015U 1 [1st Cohort Member of the family]  94                       
 9 M10016V 1 [1st Cohort Member of the family] 102                       
10 M10017W 1 [1st Cohort Member of the family]  99                       
# ℹ 15,768 more rows
```

```r
load_height_wide(3)
```

``` text
# A tibble: 15,431 × 3
   MCSID   cnum                                CCHTCM00 
   <chr>   <dbl+lbl>                           <dbl+lbl>
 1 M10001N 1 [1st Cohort Member of the family] 114.     
 2 M10002P 1 [1st Cohort Member of the family] 110.     
 3 M10007U 1 [1st Cohort Member of the family] 118      
 4 M10011Q 1 [1st Cohort Member of the family] 121      
 5 M10015U 1 [1st Cohort Member of the family] 110.     
 6 M10016V 1 [1st Cohort Member of the family] 118.     
 7 M10017W 1 [1st Cohort Member of the family] 110.     
 8 M10018X 1 [1st Cohort Member of the family] 113.     
 9 M10020R 1 [1st Cohort Member of the family] 112.     
10 M10021S 1 [1st Cohort Member of the family] 108      
# ℹ 15,421 more rows
```

Now, we could manually load and merge successively using multiple
`load_height_wide()` and `full_join()` function calls. However, this is
rather verbose.

```r
load_height_wide(2) %>%
  full_join(load_height_wide(3), by = c("MCSID", "cnum")) %>%
  full_join(load_height_wide(4), by = c("MCSID", "cnum")) %>%
  full_join(load_height_wide(6), by = c("MCSID", "cnum")) %>%
  full_join(load_height_wide(7), by = c("MCSID", "cnum"))
```

``` text
# A tibble: 17,568 × 7
   MCSID   cnum                    BCHTCM00  CCHTCM00 DCHTCM00 FCHTCM00 GCHTCM00
   <chr>   <dbl+lbl>               <dbl+lbl> <dbl+lb> <dbl+lb> <dbl+lb> <dbl+lb>
 1 M10001N 1 [1st Cohort Member o…  97       114.     128.      NA       NA     
 2 M10002P 1 [1st Cohort Member o…  96       110.     123      163.     174.    
 3 M10007U 1 [1st Cohort Member o… 102       118      129      174.     181.    
 4 M10008V 1 [1st Cohort Member o…  -2 [No …  NA       NA       NA       NA     
 5 M10008V 2 [2nd Cohort Member o…  -2 [No …  NA       NA       NA       NA     
 6 M10011Q 1 [1st Cohort Member o… 106       121      137       NA       NA     
 7 M10014T 1 [1st Cohort Member o…  97        NA       NA       NA       NA     
 8 M10015U 1 [1st Cohort Member o…  94       110.     122.     164.     169     
 9 M10016V 1 [1st Cohort Member o… 102       118.     130      167      185.    
10 M10017W 1 [1st Cohort Member o…  99       110.     121.      NA       NA     
# ℹ 17,558 more rows
```

More efficiently, we can use the `map()` function from the `purrr`
package (part of the `tidyverse`) to apply the `load_height_wide()`
function to each sweep in turn. The `map()` function takes an object to
be looped over as its first argument and a function to apply as its
second argument. The function can be written as an anonymous function,
similar to `rename_with()`. `.x` is a placeholder for the current
elements of the object being looped over. The `map()` function returns
the results as a `list`. (Variants of `map()` return other data types,
as we will see shortly). Below we use `map()` to run
`load_height_wide()` for sweeps 2-7. To save space, we do not print the
output.

```r
map(2:7, ~ load_height_wide(.x))
```

To merge list of datasets returned by `map()` together, we can use the
`reduce()` function from `purrr` package. `reduce()` has a similar
syntax to `map()`: it takes an object as its first argument, and a
function as its second argument. It applies the function to the first
*two* elements of the list, and then progressively applies the function
to the result and the next element of the list, until the list is
finished. Below, we use `reduce()` to apply the `full_join()` function
to the list of data frames. We specify `full_join()` in an anonymous
function. `.x` and `.y` the first and second inputs, respectively. So,
at the first iteration sweep 2 (`.x`) is merged with sweep 3 (`.y`), and
at the second iteration, the result of the first iteration (`.x`) is
merged with sweep 4 (`.y`). This is repeated until sweep 7 has been
merged in.

```r
map(2:7, load_height_wide) %>%
  reduce(~ full_join(.x, .y, by = c("MCSID", "cnum")))
```

``` text
# A tibble: 17,614 × 8
   MCSID   cnum           BCHTCM00  CCHTCM00 DCHTCM00 ECHTCMA0 FCHTCM00 GCHTCM00
   <chr>   <dbl+lbl>      <dbl+lbl> <dbl+lb> <dbl+lb> <dbl+lb> <dbl+lb> <dbl+lb>
 1 M10001N 1 [1st Cohort…  97       114.     128.      NA       NA       NA     
 2 M10002P 1 [1st Cohort…  96       110.     123      144.     163.     174.    
 3 M10007U 1 [1st Cohort… 102       118      129      154.     174.     181.    
 4 M10008V 1 [1st Cohort…  -2 [No …  NA       NA       NA       NA       NA     
 5 M10008V 2 [2nd Cohort…  -2 [No …  NA       NA       NA       NA       NA     
 6 M10011Q 1 [1st Cohort… 106       121      137      168.      NA       NA     
 7 M10014T 1 [1st Cohort…  97        NA       NA       NA       NA       NA     
 8 M10015U 1 [1st Cohort…  94       110.     122.     143      164.     169     
 9 M10016V 1 [1st Cohort… 102       118.     130      152.     167      185.    
10 M10017W 1 [1st Cohort…  99       110.     121.      NA       NA       NA     
# ℹ 17,604 more rows
```

## Appending Programmatically

Programatically appending datasets together is slightly more
straightforward as we can use a variant of `map()` called `map_dfr()`
which instead of returning a list, returns a data frame by calling
`bind_rows()` on the result in the background. First, we create a
function, `load_height_long()`, to load the height data a given sweep,
formatting it so that it can be appended to the other sweeps. The
`rename_with()` function renames the variables to remove the
sweep-specific prefixes. The relevant prefix is determined by subsetting
the inbuilt `LETTERS` vectors, which contains the letters of the
alphabet in upper case (`"A"`, `"B"`, `"C"`, …, `"Z"`; i.e.,
`LETTERS[2]` returns `"B"`).

```r
load_height_long <- function(sweep){
  fup <- fups[sweep]
  prefix <- LETTERS[sweep]
  
  glue("{fup}y/mcs{sweep}_cm_interview.dta") %>%
    read_dta(col_select = c("MCSID", matches("^.(CNUM00|CHTCM(A|0)0)"))) %>%
    rename_with(~ str_replace(.x, glue("^{prefix}"), "")) %>%
    mutate(sweep = !!sweep, .before = 1)
}
```

To load data from sweeps 2-7 and append them together, we can use
`map_dfr()` with the `load_height_long()` function. Note, if we just
provide the name of the function to `map_dfr()` (and `map()`,
`reduce()`, `rename_with()`, etc.), the current element of the object
being looped over is inputted as the first argument to that function.
(We could also have done this above, but anonymous functions are
extremely useful when writing complex code and arguably clarify the
action that is being done.)

```r
map_dfr(2:7, load_height_long)
```

``` text
Warning: `..1$CHTCM00` and `..2$CHTCM00` have conflicting value labels.
ℹ Labels for these values will be taken from `..1$CHTCM00`.
✖ Values: -1
```

``` text
Warning: `..1$CHTCM00` and `..3$CHTCM00` have conflicting value labels.
ℹ Labels for these values will be taken from `..1$CHTCM00`.
✖ Values: -8 and -1
```

``` text
Warning: `..1$CHTCM00` and `..5$CHTCM00` have conflicting value labels.
ℹ Labels for these values will be taken from `..1$CHTCM00`.
✖ Values: -1
```

``` text
Warning: `..1$CHTCM00` and `..6$CHTCM00` have conflicting value labels.
ℹ Labels for these values will be taken from `..1$CHTCM00`.
✖ Values: -5 and -1
```

``` text
# A tibble: 80,873 × 5
   sweep MCSID   CNUM00                              CHTCM00             CHTCMA0
   <int> <chr>   <dbl+lbl>                           <dbl+lbl>           <dbl+l>
 1     2 M10001N 1 [1st Cohort Member of the family]  97                 NA     
 2     2 M10002P 1 [1st Cohort Member of the family]  96                 NA     
 3     2 M10007U 1 [1st Cohort Member of the family] 102                 NA     
 4     2 M10008V 1 [1st Cohort Member of the family]  -2 [No Measuremen… NA     
 5     2 M10008V 2 [2nd Cohort Member of the family]  -2 [No Measuremen… NA     
 6     2 M10011Q 1 [1st Cohort Member of the family] 106                 NA     
 7     2 M10014T 1 [1st Cohort Member of the family]  97                 NA     
 8     2 M10015U 1 [1st Cohort Member of the family]  94                 NA     
 9     2 M10016V 1 [1st Cohort Member of the family] 102                 NA     
10     2 M10017W 1 [1st Cohort Member of the family]  99                 NA     
# ℹ 80,863 more rows
```

# Coda: Merging Parent Level Files

As discussed in the [Data Structures
page](https://cls-data.github.io/docs/mcs-data_structures.html), the
`mcs[1-7]_parent_*.dta` files contain identifiers for the respondent
(`MCSID` and `[A-G]PNUM00`), but also for the type of interview they
completed (`MCSID` and `[A-G]ELIG00`). We can use either of these to
merge parent-level datasets together across sweeps. When doing so, it is
sometimes worth keep the information on the other identifiers to retain
information on the respondent or interview; for instance, this may help
to determine why a variable was missing for an individual in a
particular sweep.

```r
df_parent_5y <- read_dta("5y/mcs3_parent_cm_interview.dta",
                         col_select = c("MCSID", "CCNUM00", "CPNUM00", "CELIG00", "CPFRTP00"))

df_parent_7y <- read_dta("7y/mcs4_parent_cm_interview.dta",
                         col_select = c("MCSID", "DCNUM00", "DPNUM00", "DELIG00", "DPFRTP00"))

df_parent_5y %>%
  full_join(df_parent_7y, 
             by = c("MCSID",
                    "CCNUM00" = "DCNUM00",
                    "CPNUM00" = "DPNUM00")) # Merge by person
```

``` text
# A tibble: 27,861 × 7
   MCSID   CPNUM00   CELIG00               CCNUM00     CPFRTP00 DELIG00 DPFRTP00
   <chr>   <dbl+lbl> <dbl+lbl>             <dbl+lbl>   <dbl+lb> <dbl+l> <dbl+lb>
 1 M10001N 1         1 [Main Interview]    1 [1st Coh…  2 [Two] 1 [Mai… 2 [Two] 
 2 M10002P 1         1 [Main Interview]    1 [1st Coh…  3 [Thr… 1 [Mai… 3 [Thre…
 3 M10002P 2         2 [Partner Interview] 1 [1st Coh… -1 [Not… 2 [Par… 3 [Thre…
 4 M10007U 1         1 [Main Interview]    1 [1st Coh…  3 [Thr… 1 [Mai… 3 [Thre…
 5 M10007U 2         2 [Partner Interview] 1 [1st Coh… -1 [Not… 2 [Par… 3 [Thre…
 6 M10011Q 1         1 [Main Interview]    1 [1st Coh…  3 [Thr… 1 [Mai… 3 [Thre…
 7 M10011Q 2         2 [Partner Interview] 1 [1st Coh… -1 [Not… 2 [Par… 3 [Thre…
 8 M10015U 1         1 [Main Interview]    1 [1st Coh…  2 [Two] 1 [Mai… 1 [One] 
 9 M10015U 2         2 [Partner Interview] 1 [1st Coh… -1 [Not… 2 [Par… 1 [One] 
10 M10016V 1         1 [Main Interview]    1 [1st Coh…  2 [Two] 1 [Mai… 2 [Two] 
# ℹ 27,851 more rows
```

```r
df_parent_5y %>%
  full_join(df_parent_7y, 
            by = c("MCSID", 
                   "CCNUM00" = "DCNUM00",
                   "CELIG00" = "DELIG00"))  # Merge by interview type
```

``` text
# A tibble: 27,770 × 7
   MCSID   CPNUM00   CELIG00               CCNUM00     CPFRTP00 DPNUM00 DPFRTP00
   <chr>   <dbl+lbl> <dbl+lbl>             <dbl+lbl>   <dbl+lb> <dbl+l> <dbl+lb>
 1 M10001N 1         1 [Main Interview]    1 [1st Coh…  2 [Two] 1       2 [Two] 
 2 M10002P 1         1 [Main Interview]    1 [1st Coh…  3 [Thr… 1       3 [Thre…
 3 M10002P 2         2 [Partner Interview] 1 [1st Coh… -1 [Not… 2       3 [Thre…
 4 M10007U 1         1 [Main Interview]    1 [1st Coh…  3 [Thr… 1       3 [Thre…
 5 M10007U 2         2 [Partner Interview] 1 [1st Coh… -1 [Not… 2       3 [Thre…
 6 M10011Q 1         1 [Main Interview]    1 [1st Coh…  3 [Thr… 1       3 [Thre…
 7 M10011Q 2         2 [Partner Interview] 1 [1st Coh… -1 [Not… 2       3 [Thre…
 8 M10015U 1         1 [Main Interview]    1 [1st Coh…  2 [Two] 1       1 [One] 
 9 M10015U 2         2 [Partner Interview] 1 [1st Coh… -1 [Not… 2       1 [One] 
10 M10016V 1         1 [Main Interview]    1 [1st Coh…  2 [Two] 1       2 [Two] 
# ℹ 27,760 more rows
```
