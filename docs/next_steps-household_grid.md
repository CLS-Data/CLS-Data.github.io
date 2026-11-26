---
layout: default
title: Working with the Household Grid
nav_order: 3
parent: Next Steps
format:
  gfm:
    variant: +yaml_metadata_block
---


- [Download the R script for this
  page](../purl/next_steps-household_grid.R)
- [Download the equivalent Stata script for this
  page](../do_files/next_steps-household_grid.do)

# Introduction

In this section, we describe the basics of using the household grid.
Specifically, we show how to use the household grid to:

1.  Identify particular family members

2.  Create family-member specific variables

3.  Find out who the “main parent” and “second parent” are, and whether
    these are the same people in each sweep

4.  Determine the relationships between other members of the household.

We use the following packages:

``` r
# Load Packages
library(tidyverse) # For data manipulation
library(haven) # For importing .dta files
```

# Finding Mother of Cohort Members

To show how to perform 1 & 2, we use the example of finding natural
mothers’ employment status at the first sweep. The household grids are
stored in their own subfolder, `household_grids`. The Sweep 1 household
grid (`household_grids/wave_one_lsype_household_grid_file_2020.dta`) has
one row for each member of the cohort member’s household, [including the
cohort member
themselves](https://cls-data.github.io/docs/next_steps-data_structures.html).
We load just five variables: `NSID` and `W1HhID`, which together
uniquely identify an individual, `W1Sex` and `W1R_1`, which contain
information on the individual’s sex and their relationship to the cohort
member, and `W1EmpStat`, which contains their employment status.

`W1HhID` is the individual’s person number within the household. The
cohort member is always person number 1. The household grid records the
relationships between household members in the variables `W1R_1`,
`W1R_2`, …, `W1R_14`; the number at the end of the variable name is the
person number of the *other* household member. `W1R_1` therefore records
the relationship of the person in the row to person number 1 - that is,
to the cohort member.

`W1R_1 == 8` identifies natural parents and `W1Sex == 2` identifies
females. Combining the two identifies natural mothers. Below, we use
`count()` to show the different (observed) values for the sex and
relationship variables. We also use the `filter()` function (which
retains observations where the conditions are `TRUE`) to create a
dataset containing natural mothers only.
`add_count(NSID) %>% filter(n == 1)` is included as an interim step to
ensure there is just one natural mother per family.[^1]

``` r
df_w1_hhgrid <- read_dta("household_grids/wave_one_lsype_household_grid_file_2020.dta") %>%
  select(NSID, W1HhID, W1Sex, W1R_1, W1EmpStat) # Retains the listed variables

df_w1_hhgrid %>%
  count(W1Sex) # Tabulates each sex
```

    # A tibble: 3 × 2
      W1Sex                             n
      <dbl+lbl>                     <int>
    1 -999 [Missing household data]   104
    2    1 [Male]                   33916
    3    2 [Female]                 36573

``` r
df_w1_hhgrid %>%
  count(W1R_1) # Tabulates each relationship to the cohort member
```

    # A tibble: 22 × 2
       W1R_1                              n
       <dbl+lbl>                      <int>
     1 -999 [Missing household data]    104
     2  -92 [Refused]                    26
     3  -91 [Not applicable]          15656
     4    1 [Husband/ Wife]               1
     5    3 [Natural son/ daughter]       3
     6    5 [Foster child]                2
     7    6 [Step-son/ Step-daughter]     1
     8    8 [Natural parent]          24959
     9    9 [Adoptive parent]           152
    10   10 [Foster parent]             138
    # ℹ 12 more rows

``` r
df_w1_mothers <- df_w1_hhgrid %>%
  filter(
    W1R_1 == 8, # Keep natural parents of the cohort member...
    W1Sex == 2 # ...who are female.
  ) %>%
  add_count(NSID) %>% # Creates new variable (n) containing # of records with given NSID
  filter(n == 1) %>% # Keep where only one recorded natural mother per family
  select(NSID, W1HhID, W1EmpStat) # Keep identifier variables and employment status
```

Note, there is one cohort member per family in Next Steps. There is,
therefore, no ambiguity about which cohort member a relationship refers
to.

# Creating a Mother’s Employment Variable

Unlike in the [Millennium Cohort
Study](https://cls-data.github.io/docs/mcs-household_grid.html), the
Next Steps household grid holds several characteristics of each
household member, including their employment status (`W1EmpStat`),
marital status (`W1MarStat`) and ethnic group (`W1EthGrp`). Having
identified natural mothers, we can therefore create a variable for
whether the cohort member’s mother is in paid work directly. `W1EmpStat`
takes the values `1` and `2` for individuals in full-time and part-time
paid work, respectively, and values between `3` and `9` for other
statuses (e.g., looking after the family or household). Below, we use
`case_when()` to create a binary variable, `mother_works`, and use
`count()` to tabulate the number and proportion of mothers who are and
are not in paid work.

``` r
df_w1_mothers %>%
  count(W1EmpStat)
```

    # A tibble: 13 × 2
       W1EmpStat                                                n
       <dbl+lbl>                                            <int>
     1 -92 [Refused]                                            3
     2 -91 [Not applicable]                                    51
     3   1 [Doing paid work for 30 or more hours a week]     4727
     4   2 [Doing paid work for fewer than 30 hours a week]  4649
     5   3 [Unemployed/ Looking for a job]                    212
     6   4 [On a training course or scheme]                    86
     7   5 [In full-time education/ at school]                155
     8   6 [Looking after the family/ household]             4510
     9   7 [Retired from work altogether]                      22
    10   8 [Sick/ disabled]                                   256
    11   9 [Other]                                             79
    12  11                                                      3
    13  12 [Not Stated]                                         2

``` r
df_w1_mother_works <- df_w1_mothers %>%
  mutate(mother_works = case_when(W1EmpStat %in% 1:2 ~ 1, # If W1EmpStat is 1 or 2, then 1
                                  W1EmpStat %in% 3:9 ~ 0)) %>% # If W1EmpStat is between 3 and 9, then 0
  select(NSID, mother_works)

df_w1_mother_works %>%
  count(mother_works) %>%
  mutate(prop = n / sum(n))
```

    # A tibble: 3 × 3
      mother_works     n    prop
             <dbl> <int>   <dbl>
    1            0  5320 0.361  
    2            1  9376 0.635  
    3           NA    59 0.00400

The result is a dataset with one row per family with an identified
natural mother, which can be merged with other cohort member-level
datasets using `NSID`. Note, the family background files contain derived
variables for some characteristics of the cohort member’s mother and
father (in this case, `W1empsmum` and `W1empsdad` in
`safeguarded_eul/wave_one_lsype_family_background_2020.dta`). The
approach shown here is needed where a derived variable is not available,
or where you are interested in other family members, such as siblings or
grandparents.

# Identifying the Main and Second Parent

In Sweeps 1-4, [interviews were conducted with a “main parent” and a
“second
parent”](https://cls-data.github.io/docs/next_steps-data_structures.html).
Variables relating to these individuals are suffixed `MP` and `SP` (for
example, `W1hiqualgMP` and `W1hiqualgSP` in
`safeguarded_eul/wave_one_lsype_family_background_2020.dta`). To
interpret these variables, it is helpful to know who the main and second
parent are.

The household grid contains the variables `W1mainres` and `W1secores`,
which record the person numbers of the main parent and second parent,
respectively. These variables take the same value for every member of a
household. Below, we create a variable, `role`, by comparing each
individual’s person number (`W1HhID`) to these variables, and keep the
rows for individuals who are either the main or second parent. We then
tabulate the sex of main and second parents and their relationship to
the cohort member. `as_factor()` (from `haven`) converts the `labelled`
variables to factors so that value labels, rather than numeric values,
are displayed.

``` r
df_w1_parents <- read_dta("household_grids/wave_one_lsype_household_grid_file_2020.dta") %>%
  select(NSID, W1HhID, W1Sex, W1R_1, W1mainres, W1secores) %>%
  mutate(role = case_when(W1HhID == W1mainres ~ "Main parent",
                          W1HhID == W1secores ~ "Second parent")) %>%
  drop_na(role) # Drops rows for individuals who are not the main or second parent

df_w1_parents %>%
  mutate(across(c(W1Sex, W1R_1), as_factor)) %>%
  count(role, W1Sex, W1R_1) %>%
  print(n = Inf) # Prints all rows
```

    # A tibble: 33 × 4
       role          W1Sex  W1R_1                               n
       <chr>         <fct>  <fct>                           <int>
     1 Main parent   Male   Natural parent                   2598
     2 Main parent   Male   Adoptive parent                    16
     3 Main parent   Male   Foster parent                      11
     4 Main parent   Male   Step-parent                        79
     5 Main parent   Male   Natural brother/ sister            34
     6 Main parent   Male   Half-brother/ -sister               1
     7 Main parent   Male   Brother-in-law/ Sister-in-law       1
     8 Main parent   Male   Grandparent                        16
     9 Main parent   Male   Other relative                     12
    10 Main parent   Male   Other non-relative                  2
    11 Main parent   Female Refused                             4
    12 Main parent   Female Natural parent                  12485
    13 Main parent   Female Adoptive parent                    62
    14 Main parent   Female Foster parent                      71
    15 Main parent   Female Step-parent                        61
    16 Main parent   Female Parent-in-law/ Partner's parent     1
    17 Main parent   Female Natural brother/ sister            36
    18 Main parent   Female Half-brother/ -sister               1
    19 Main parent   Female Foster brother/ Foster sister       1
    20 Main parent   Female Brother-in-law/ Sister-in-law       1
    21 Main parent   Female Grandparent                        85
    22 Main parent   Female Other relative                     35
    23 Main parent   Female Other non-relative                  9
    24 Second parent Male   Natural parent                   7544
    25 Second parent Male   Adoptive parent                    60
    26 Second parent Male   Foster parent                      45
    27 Second parent Male   Step-parent                      1263
    28 Second parent Male   Natural brother/ sister             5
    29 Second parent Female Natural parent                   2218
    30 Second parent Female Adoptive parent                    11
    31 Second parent Female Foster parent                       9
    32 Second parent Female Step-parent                       111
    33 Second parent Female Natural brother/ sister             1

`df_w1_parents` has one row per parent. It can be used to create
variables for a specific type of parent from the `MP` and `SP`
variables. We show an example of this in [*Combining Data Within A
Sweep*](https://cls-data.github.io/docs/next_steps-merging_within_sweep.html).

## Changes in the Main and Second Parent Across Sweeps

The main and second parent are roles in the interview rather than fixed
individuals: the person interviewed as the main parent in one sweep is
not necessarily the person interviewed as the main parent in the next.
This matters when using `MP` and `SP` variables from more than one
sweep.

A household member is intended to keep the same person number in each
sweep, so we can check whether the main parent has changed by comparing
the person number of the main parent across sweeps. Below, we do this
for Sweeps 1 and 2. For each sweep, we create a dataset containing the
row for the main parent from that sweep’s household grid, keeping their
person number. (The Sweep 2 household grid,
`household_grids/wave_two_lsype_household_grid_file_2020.dta`, contains
equivalent variables to the Sweep 1 grid, with the prefix `W2` rather
than `W1`.) We use `zap_labels()` (from `haven`) to remove the value
labels from the person numbers, leaving standard numeric variables that
can be compared directly.

``` r
df_w1_main <- read_dta("household_grids/wave_one_lsype_household_grid_file_2020.dta") %>%
  filter(W1HhID == W1mainres) %>% # Keeps the row for the main parent
  mutate(w1_main_hhid = zap_labels(W1HhID)) %>% # Removes value labels
  select(NSID, w1_main_hhid)

df_w2_main <- read_dta("household_grids/wave_two_lsype_household_grid_file_2020.dta") %>%
  filter(W2HhID == W2mainres) %>%
  mutate(w2_main_hhid = zap_labels(W2HhID)) %>%
  select(NSID, w2_main_hhid)
```

We then merge the two datasets using `inner_join()`, so that we keep the
families where a main parent was identified in both sweeps, and tabulate
whether the main parent has the same person number in the two sweeps.

``` r
df_main <- df_w1_main %>%
  inner_join(df_w2_main, by = "NSID")

df_main %>%
  count(same_person = w1_main_hhid == w2_main_hhid)
```

    # A tibble: 2 × 2
      same_person     n
      <lgl>       <int>
    1 FALSE        1223
    2 TRUE        12212

Where the main parent is not the same person in the two sweeps, a
variable such as `W2hiqualgMP` describes a different person to
`W1hiqualgMP`. Where this matters for your analysis, you could restrict
the sample to families where the main parent is unchanged, or use the
approach shown above to create variables for a particular parent (e.g.,
the mother) in each sweep.

# Determining Relationships between Other Household Members

So far we have only used `W1R_1`, the relationship of each household
member to the cohort member. The remaining relationship variables
(`W1R_2` to `W1R_14`) can be used to identify the relationships between
other members of the household. Specifically, they record the person in
the row’s (ego) relationship to the person denoted by the column
(alter); the number at the end of the variable name corresponds to the
alter’s `W1HhID`. For instance, the variable `W1R_2` denotes the
relationship of the person in the row to the person in the same
household with `W1HhID == 2`. Below, we extract a small set of data from
the Sweep 1 household grid to show this in action.

``` r
df_w1_hhgrid_rel <- read_dta("household_grids/wave_one_lsype_household_grid_file_2020.dta") %>%
  select(NSID, W1HhID, matches("^W1R_\\d+$"))

df_w1_hhgrid_rel %>%
  filter(NSID == first(NSID)) %>% # To look at just one household
  select(W1HhID, W1R_1, W1R_2, W1R_3) # To look at first few relationship variables
```

    # A tibble: 4 × 4
      W1HhID    W1R_1                         W1R_2                       W1R_3     
      <dbl+lbl> <dbl+lbl>                     <dbl+lbl>                   <dbl+lbl> 
    1 1         -91 [Not applicable]          -91 [Not applicable]        -91 [Not …
    2 2           8 [Natural parent]          -91 [Not applicable]        -91 [Not …
    3 3          11 [Step-parent]               1 [Husband/ Wife]         -91 [Not …
    4 4          13 [Natural brother/ sister]   3 [Natural son/ daughter]   6 [Step…

Each row shows the relationships of one household member to the first
three people in the household. For instance, where the person with
`W1HhID == 2` is the natural parent of the cohort member, their row has
`W1R_1 == 8 [Natural parent]`. Note, each relationship is only recorded
once, in the row of the person with the *higher* person number: a
relationship variable is only filled in where the individual’s `W1HhID`
is greater than the number at the end of the variable name, and is
otherwise coded as not applicable (`-91`). `W1R_2`, for instance, is
only filled in for individuals with a `W1HhID` of 3 or more, and every
relationship variable is coded as not applicable for the cohort member
(`W1HhID == 1`). The relationship in the other direction is not recorded
and has to be inferred - if the person with `W1HhID == 2` is the natural
parent of the cohort member, then the cohort member is the natural child
of that person.

If we want to find the particular person occupying a specific
relationship for an individual (e.g., we want to know the `W1HhID` of
the person’s partner), we need to reshape the data into long-format with
one row per ego-alter relationship within a household (for more on
reshaping data, see [*Reshaping Data from Long to Wide (or Wide to
Long)*](https://cls-data.github.io/docs/next_steps-reshape_long_wide.html)).
For instance, to find the individuals who are spouses or partners, we
can do the following:

``` r
df_w1_couples <- df_w1_hhgrid_rel %>%
  pivot_longer(cols = matches("^W1R_\\d+$"),
               names_to = "W1HhID_alter",
               names_prefix = "W1R_", # Removes "W1R_" from the names, leaving the alter's person number
               names_transform = as.integer, # Converts the alter's person number to an integer
               values_to = "relationship") %>%
  filter(relationship %in% 1:2) %>% # Keep where husband/wife or partner/cohabitee
  mutate(W1HhID = as.integer(W1HhID)) %>% # Converts the person number to an integer (removing its value labels)
  select(NSID, W1HhID, partner_hhid = W1HhID_alter)

df_w1_couples
```

    # A tibble: 11,709 × 3
       NSID     W1HhID partner_hhid
       <chr>     <int>        <int>
     1 NS23533L      3            2
     2 NS24676Q      3            2
     3 NS21482P      3            2
     4 NS25978V      3            2
     5 NS23018R      3            2
     6 NS21572X      3            2
     7 NS21185L      3            2
     8 NS13972M      3            2
     9 NS20913T      3            2
    10 NS14531V      3            2
    # ℹ 11,699 more rows

As each relationship is only recorded once, `df_w1_couples` has one row
per *couple*, with the partner with the higher person number in the
`W1HhID` column. To find each person’s spouse or partner (conditional on
one being present), both members of a couple need a row. Below, we
create a copy of the dataset in which the person numbers of the two
partners are swapped, and append this to the original using
`bind_rows()`. Swapping the person numbers is sufficient here as the
relationship is the same in both directions; for other relationships
(e.g., parent and child), the relationship itself would also need to be
recoded.

``` r
df_w1_couples_rev <- df_w1_couples %>%
  select(NSID, W1HhID = partner_hhid, partner_hhid = W1HhID) # Swaps the person numbers of the two partners

bind_rows(df_w1_couples, df_w1_couples_rev) %>% # Appends the two datasets
  arrange(NSID, W1HhID) # Sorts the dataset by ID and person number
```

    # A tibble: 23,418 × 3
       NSID     W1HhID partner_hhid
       <chr>     <int>        <int>
     1 NS10001S      2            3
     2 NS10001S      3            2
     3 NS10002T      2            3
     4 NS10002T      3            2
     5 NS10003V      2            3
     6 NS10003V      3            2
     7 NS10004W      2            3
     8 NS10004W      3            2
     9 NS10005X      2            3
    10 NS10005X      3            2
    # ℹ 23,408 more rows

# Coda

This only scratches the surface of what can be achieved with the
household grid. A few further points are worth noting:

- The household grids for Sweeps 2-4
  (`wave_[two-four]_lsype_household_grid_file_2020.dta`) have a similar
  structure to the Sweep 1 grid. The relationship variables (`W2R_1`,
  `w3R_1`, `W4R_1`, and so on) follow the same rule: each relationship
  is only recorded once, in the row of the person with the higher person
  number. Variable names differ in their use of upper and lower case,
  however: for instance, the person number is `W2HhID` in Sweep 2,
  `w3HhID` in Sweep 3 and `W4hhid` in Sweep 4.[^2] These grids also
  include people who have left the household since an earlier sweep; the
  variables `W2SHGInt`, `w3SHGint` and `W4SHGint` record whether a
  person is still living with the cohort member.
- From Sweep 5, the household grid was completed by the cohort member
  and is much less detailed. The Sweep 5-7 grids
  (`wave_[five-seven]_lsype_household_grid_file_2020.dta`) contain a
  single variable recording a simplified relationship to the cohort
  member (e.g., `W5RELATION`), and the main and second parent are no
  longer identified. The person number is named `HHID` in these files.
  Note, at Sweep 7, `W7RELATION` is only filled in for people who are
  new to the household at that sweep
  (`W7SHGINT == 2 [Present - New at current wave]`) and is coded
  `-91 [Not applicable]` for everyone else; at Sweeps 5 and 6, the
  relationship is recorded for all people present in the household (this
  is not documented in the user guide). For people who were already in
  the household at Sweep 7, the relationship to the cohort member
  therefore needs to be taken from the Sweep 5 or 6 grid, by matching on
  `NSID` and `HHID`.
- At Sweeps 8 and 9, information on the people the cohort member lives
  with is contained in `ns8_2015_household_members.dta` and
  `ns9_2022_person_grid.dta` (both also in the `household_grids`
  subfolder). These files do not include a row for the cohort member,
  and the relationship to the cohort member is recorded in the variables
  `W8RELTOKEY` and `W9RELTOKEY`, respectively.

# Footnotes

[^1]: Loading the `.dta` files into `R` with `haven::read_dta()` retains
    the dataset metadata, including variable names and labels, mainly by
    storing variables as `labelled` class objects. See the [`labelled`
    package help
    files](https://cran.r-project.org/web/packages/labelled/vignettes/intro_labelled.html)
    for more information on working with this metadata - for instance,
    converting `labelled` variables to standard `R` factor variables or
    replacing negative values (generally reserved in Next Steps data to
    indicate missingness) with `R`’s native `NA` value.

[^2]: `rename_with()` can be used to rename variables *en masse* so that
    they follow the same rubric. For instance,
    `rename_with(str_to_upper)` converts every variable name in a
    dataset to upper case, so that the person number would be named
    `W2HHID`, `W3HHID` and `W4HHID` in Sweeps 2, 3 and 4, respectively.
    See [*Combining Data Across
    Sweeps*](https://cls-data.github.io/docs/next_steps-merging_across_sweeps.html)
    for more on `rename_with()`.
