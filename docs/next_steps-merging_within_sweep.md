---
layout: default
title: Combining Data Within A Sweep
nav_order: 5
parent: Next Steps
format:
  gfm:
    variant: +yaml_metadata_block
---


- [Download the R script for this
  page](../purl/next_steps-merging_within_sweep.R)

# Introduction

In this section, we show how to merge, collapse and reshape the various
data structures within a given sweep of Next Steps to create a dataset
at the cohort member-level (i.e., one row per cohort member). This is
likely to be the most useful data structure for most analyses.

[Most Next Steps files already have one row per cohort
member](https://cls-data.github.io/docs/next_steps-data_structures.html)
and all files are linked with a single identifier, `NSID`, so combining
data within a sweep is more straightforward than in, e.g., the
[MCS](https://cls-data.github.io/docs/mcs-merging_within_sweep.html).
There are two complications. First, information about cohort members’
parents is stored in separate variables for the “main parent” and
“second parent”, so some work is required to create variables that
summarise both parents or that relate to a particular parent (such as
the mother). Second, a small number of files - notably the household
grid - have more than one row per cohort member and need to be collapsed
before they are merged with other data.

We use the following packages:

``` r
# Load Packages
library(tidyverse) # For data manipulation
library(haven) # For importing .dta files
```

# Data Cleaning

We create a small dataset that contains information from Sweep 1 on: the
cohort member’s sex and attitude to school, housing tenure, family
social class (National Statistics Socio-economic Classification;
NS-SEC), mother’s social class, and the number of siblings living with
the cohort member. Constructing and combining these variables involves
restructuring the data in various ways, and spans the most common data
engineering tasks involved in bringing together information from a
single sweep.

The datasets we use in this tutorial are below. Note, the household grid
is stored in a different subfolder to the young person and family
background files.

``` r
yp <- read_dta("safeguarded_eul/wave_one_lsype_young_person_2020.dta") # One row per cohort member
family <- read_dta("safeguarded_eul/wave_one_lsype_family_background_2020.dta") # One row per cohort member
hhgrid <- read_dta("household_grids/wave_one_lsype_household_grid_file_2020.dta") # One row per household member
```

We begin with the simplest variables: the cohort member’s sex and their
attitude to school. These are stored in a cohort-member level dataset
already (`wave_one_lsype_young_person_2020`), so they do not need
further processing. Below we rename the relevant variables and select
them along with the cohort member identifier, `NSID`.

``` r
df_yp <- yp %>%
  select(NSID, sex = W1sexYP, school_attitude = W1yschat1) # Retains the listed variables, renaming W1sexYP as sex and W1yschat1 as school_attitude

df_yp
```

    # A tibble: 15,760 × 3
       NSID     sex        school_attitude
       <chr>    <dbl+lbl>  <dbl+lbl>      
     1 NS10001S 1 [Male]   22             
     2 NS10002T 2 [Female] 19             
     3 NS10003V 1 [Male]   26             
     4 NS10004W 2 [Female] 40             
     5 NS10005X 1 [Male]   27             
     6 NS10006Y 2 [Female] 38             
     7 NS10007Z 1 [Male]   43             
     8 NS10008A 2 [Female] 29             
     9 NS10009B 2 [Female] 20             
    10 NS10010L 1 [Male]   43             
    # ℹ 15,750 more rows

Housing tenure is a characteristic of the household and is stored in the
family background file (`wave_one_lsype_family_background_2020`). As
there is one cohort member per family in Next Steps, this file also has
one row per cohort member, and the variable does not need any further
processing at this stage.

``` r
df_tenure <- family %>%
  select(NSID, tenure = W1hous12HH)
```

Next, we create a variable for family social class using data on both
parents. The family background file contains the NS-SEC of the main
parent (`W1nssecMP`) and the second parent (`W1nssecSP`). As these are
stored in separate *columns* (rather than separate rows), we can create
a summary variable by operating across the columns. We first replace
values outside the range 1-8 with `NA` (negative values denote various
forms of missingness - for instance, `-98` indicates there is no second
parent in the household). We then take the minimum of the two variables
using `pmin()` (lower values of NS-SEC indicate higher social class).
`pmin()` returns the minimum for each row; the argument `na.rm = TRUE`
means that where NS-SEC is only available for one parent, that parent’s
value is used.[^1]

``` r
df_nssec <- family %>%
  select(NSID, W1nssecMP, W1nssecSP) %>%
  mutate(across(c(W1nssecMP, W1nssecSP),
                ~ if_else(between(.x, 1, 8), as.numeric(.x), NA))) %>% # Values outside 1-8 denote various forms of missingness
  mutate(family_nssec = pmin(W1nssecMP, W1nssecSP, na.rm = TRUE)) %>% # Takes the lowest value of the two variables in each row
  select(NSID, family_nssec)

df_nssec
```

    # A tibble: 15,760 × 2
       NSID     family_nssec
       <chr>           <dbl>
     1 NS10001S            2
     2 NS10002T            1
     3 NS10003V            6
     4 NS10004W           NA
     5 NS10005X            2
     6 NS10006Y            7
     7 NS10007Z            3
     8 NS10008A            5
     9 NS10009B            7
    10 NS10010L            4
    # ℹ 15,750 more rows

We next show a different way of using the main and second parent
variables: reshaping the data from wide to long so that we have one row
per *parent*. This is useful where we want to create a variable for a
particular parent - in this case, the cohort member’s mother. [The main
and second parent are roles in the
interview](https://cls-data.github.io/docs/next_steps-data_structures.html),
and either could be the cohort member’s mother, so we need to bring in
information from the household grid to find out who each parent is.

The family background file contains the variables `W1mainres` and
`W1secores`, which record the person number of the main and second
parent in the household grid. Below, we first rename these variables so
that they follow the same convention as the NS-SEC variables (a common
stem, followed by `MP` or `SP`). We then reshape the data from [wide to
long using
`pivot_longer()`](https://r4ds.hadley.nz/data-tidy.html#sec-pivoting).
The `names_pattern` argument uses a regular expression to split the
variable names into two pieces: the stem (`"(.*)"`) and the suffix
(`"(MP|SP)"`). The stem is used to name the new columns (`.value`) and
the suffix is stored in a new variable, `parent`. The result is a
dataset with two rows per cohort member, one for each parent.[^2]

``` r
df_parent <- family %>%
  select(NSID, W1HhIDMP = W1mainres, W1HhIDSP = W1secores, W1nssecMP, W1nssecSP) %>%
  zap_labels() %>% # Removes value labels
  pivot_longer(cols = -NSID, # Reshape all columns except NSID
               names_to = c(".value", "parent"),
               names_pattern = "^(.*)(MP|SP)$")

df_parent
```

    # A tibble: 31,520 × 4
       NSID     parent W1HhID W1nssec
       <chr>    <chr>   <dbl>   <dbl>
     1 NS10001S MP          2       7
     2 NS10001S SP          3       2
     3 NS10002T MP          2       1
     4 NS10002T SP          3       6
     5 NS10003V MP          2       6
     6 NS10003V SP          3       7
     7 NS10004W MP          2     -99
     8 NS10004W SP          3     -99
     9 NS10005X MP          3       6
    10 NS10005X SP          2       2
    # ℹ 31,510 more rows

`df_parent` now contains the person number of each parent (`W1HhID`). We
can use this to merge in each parent’s sex (`W1Sex`) and relationship to
the cohort member (`W1R_1`) from the household grid (see [*Working with
the Household
Grid*](https://cls-data.github.io/docs/next_steps-household_grid.html)).
We use `inner_join()` so that we only keep rows where the parent is
found in the household grid (this drops, for instance, rows for second
parents in families where there is no second parent). We then keep the
rows for natural mothers (`W1R_1 == 8` \[Natural parent\] and
`W1Sex == 2` \[Female\]). The result is a dataset with one row per
cohort member whose natural mother was the main or second parent,
containing the mother’s NS-SEC.[^3]

``` r
df_mother_nssec <- hhgrid %>%
  select(NSID, W1HhID, W1Sex, W1R_1) %>%
  inner_join(df_parent, by = c("NSID", "W1HhID")) %>%
  filter(W1R_1 == 8, # Keep natural parents...
         W1Sex == 2) %>% # ...who are female
  add_count(NSID) %>% # Creates new variable (n) containing # of records with given NSID
  filter(n == 1) %>% # Keep where only one natural mother identified per cohort member
  mutate(mother_nssec = if_else(between(W1nssec, 1, 8), W1nssec, NA)) %>%
  select(NSID, mother_nssec)
```

Finally, we create a variable for the number of siblings living with the
cohort member. This involves collapsing the household grid, which has
one row per household member, so that it has one row per cohort member.
`W1R_1` records each household member’s relationship to the cohort
member, with values between 13 and 17 indicating different types of
sibling (natural, half-, step-, adopted and foster siblings). We count
the number of rows that meet this condition using `summarise()` on a
[grouped data frame](https://r4ds.hadley.nz/data-transform.html#groups)
(`group_by(NSID)`) to ensure this is calculated per cohort member.

``` r
df_siblings <- hhgrid %>%
  select(NSID, W1HhID, W1R_1) %>%
  group_by(NSID) %>% # Groups the data so summarise() is performed per cohort member
  summarise(n_siblings = sum(W1R_1 %in% 13:17), # Counts the number of rows where W1R_1 is between 13 and 17
            .groups = "drop") # Removes the grouping from the resulting dataframe

df_siblings
```

    # A tibble: 15,760 × 2
       NSID     n_siblings
       <chr>         <int>
     1 NS10001S          1
     2 NS10002T          3
     3 NS10003V          3
     4 NS10004W          3
     5 NS10005X          2
     6 NS10006Y          2
     7 NS10007Z          2
     8 NS10008A          2
     9 NS10009B          0
    10 NS10010L          2
    # ℹ 15,750 more rows

The same principles apply to the “hierarchical” files from Sweeps 8 and
9 - for instance, `ns8_2015_children.dta`, which has one row for each of
the cohort member’s children. Note, though, that cohort members only
appear in these files if they have at least one record (e.g., at least
one child), so some care is needed when merging the collapsed data with
other files: cohort members who do not appear in the file should
typically be assigned a count of zero, rather than `NA`.

# Merging the Datasets

Now we have cleaned each variable, we can merge them together. The
cleaned datasets are all at the cohort member level. We begin with
`df_yp` as this has all the cohort members participating at Sweep 1 in
it. We then use `left_join()` to merge in other data so original rows
are kept (and no more are added). As `NSID` uniquely identifies cohort
members, we use `left_join(..., by = "NSID")` in each case.

``` r
df_yp %>%
  left_join(df_tenure, by = "NSID") %>%
  left_join(df_nssec, by = "NSID") %>%
  left_join(df_mother_nssec, by = "NSID") %>%
  left_join(df_siblings, by = "NSID")
```

    # A tibble: 15,760 × 7
       NSID     sex     school_attitude tenure  family_nssec mother_nssec n_siblings
       <chr>    <dbl+l> <dbl+lbl>       <dbl+l>        <dbl>        <dbl>      <int>
     1 NS10001S 1 [Mal… 22              2 [Bei…            2            7          1
     2 NS10002T 2 [Fem… 19              1 [Own…            1            6          3
     3 NS10003V 1 [Mal… 26              2 [Bei…            6            6          3
     4 NS10004W 2 [Fem… 40              2 [Bei…           NA           NA          3
     5 NS10005X 1 [Mal… 27              2 [Bei…            2            6          2
     6 NS10006Y 2 [Fem… 38              4 [Ren…            7            7          2
     7 NS10007Z 1 [Mal… 43              2 [Bei…            3            3          2
     8 NS10008A 2 [Fem… 29              2 [Bei…            5            5          2
     9 NS10009B 2 [Fem… 20              2 [Bei…            7            7          0
    10 NS10010L 1 [Mal… 43              2 [Bei…            4            6          2
    # ℹ 15,750 more rows

As noted in [*Combining Data Across
Sweeps*](https://cls-data.github.io/docs/next_steps-merging_across_sweeps.html),
`left_join()` will not throw an error if a cohort member appears more
than once in one of the datasets - it will simply add rows. If you want
`R` to enforce that each row is matched to at most one row in the other
dataset, you can add the argument `relationship = "one-to-one"` to the
`*_join()` function call.

# Footnotes

[^1]: `wave_one_lsype_family_background_2020` also contains a derived
    variable for family NS-SEC, `W1nssecfam`, which is instead based on
    the occupation of the household reference person. We create our own
    variable here to demonstrate the principle, which can be applied to
    any pair of `MP` and `SP` variables.

[^2]: We use `zap_labels()` to remove value labels from the variables
    prior to reshaping. `pivot_longer()` stacks the main and second
    parent variables on top of each other, and will print a warning
    where their value labels are not identical. For more on reshaping
    data, see [*Reshaping Data from Long to Wide (or Wide to
    Long)*](https://cls-data.github.io/docs/next_steps-reshape_long_wide.html).

[^3]: More detail on merging with `inner_join()` (and other `*_join()`
    variants) is provided in [*Combining Data Across
    Sweeps*](https://cls-data.github.io/docs/next_steps-merging_across_sweeps.html),
    as well as [Chapter 19 of the R for Data Science
    textbook](https://r4ds.hadley.nz/joins.html#sec-mutating-joins).
    Note, for many characteristics, the family background file already
    contains derived variables for mothers and fathers - in this case,
    `W1nssecmum` and `W1nssecdad`. The approach here is needed for `MP`
    and `SP` variables that do not have such an equivalent.
