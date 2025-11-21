# Working with the Household Grid


- [Download the R script for this page](../purl/mcs-household_grid.R)
- [Download the equivalent Stata script for this
  page](../do_files/mcs-household_grid.do)

# Introduction

In this section, we describe the basics of using the household grid.
Specifically, we show how to use the household grid to:

1.  Identify particular family members

2.  Create family-member specific variables

3.  Determine the relationships between non-cohort members within a
    family.

We use the following packages:

``` r
# Load Packages
library(tidyverse) # For data manipulation
library(haven) # For importing .dta files
```

# Finding Mother of Cohort Members

To show how to perform 1 & 2, we use the example of finding natural
mothers’ smoking status at the first sweep. We load just four variables
from the Sweep 1 household grid: `MCSID` and `APNUM00`, which together
uniquely identify an individual, and `AHPSEX00` and `AHCREL00`, which
contain information on the individual’s sex and their relationship to
the household’s cohort member(s). `AHCREL00 == 7` identifies natural
parents and `AHPSEX00 == 2` identifies females. Combining the two
identifies natural mothers. Below, we use `count()` to show the
different (observed) values for the sex and relationship variables. We
also use the `filter()` function (which retains observations where the
conditions are `TRUE`) to create a dataset containing the identifiers
(`MCSID` and `APNUM00`) of natural mothers only; we will merge this with
the smoking information shortly. `add_count(MCSID) %>% filter(n == 1)`
is included as an interim step to ensure there is just one natural
mother per family.[^1]

``` r
df_0y_hhgrid <- read_dta("0y/mcs1_hhgrid.dta") %>%
  select(MCSID, APNUM00, AHPSEX00, AHCREL00) # Retains the listed variables

df_0y_hhgrid %>%
  count(AHPSEX00) # Tabulates each sex; AHPSEX00 does not record the sex of cohort members
```

    # A tibble: 4 × 2
      AHPSEX00                n
      <dbl+lbl>           <int>
    1 -2 [Unknown]           55
    2 -1 [Not applicable] 18734
    3  1 [Male]           26438
    4  2 [Female]         29567

``` r
df_0y_hhgrid %>%
  count(AHCREL00) # Tabulates each relationship to a cohort member
```

    # A tibble: 16 × 2
       AHCREL00                                n
       <dbl+lbl>                           <int>
     1 -9 [Refusal]                            5
     2 -8 [Dont Know]                          1
     3  7 [Natural parent]                 33812
     4  8 [Adoptive parent]                    2
     5  9 [Foster parent]                      3
     6 10 [Step-parent/partner of parent]     50
     7 11 [Natural brother/Natural sister] 13873
     8 12 [Half-brother/Half-sister]        3486
     9 13 [Step-brother/Step-sister]          16
    10 14 [Adopted brother/Adopted sister]     8
    11 15 [Foster brother/Foster sister]       9
    12 17 [Grandparent]                     2164
    13 18 [Nanny/au pair]                     20
    14 19 [Other relative]                  2326
    15 20 [Other non-relative]               233
    16 96 [Self]                           18786

``` r
df_0y_mothers <- df_0y_hhgrid %>%
  filter(
    AHCREL00 == 7, # Keep natural parents...
    AHPSEX00 == 2 # ...who are female.
  ) %>%
  add_count(MCSID) %>% # Creates new variable (n) containing # of records with given MCSID
  filter(n == 1) %>% # Keep where only one recorded natural mother per family
  select(MCSID, APNUM00) # Keep identifier variables
```

Note, where a cohort member is part of a family (`MCSID`) with two or
more cohort members, the cohort member will have been a multiple birth
(i.e., twin or triplet), so familial relationships should apply to all
cohort members in the family, which is why there is just one
relationship (`[A-G]HCREL00`) variable per household grid file. This
will change as the cohort members age, moving into separate residences
and starting their own families.

# Creating a Mother’s Smoking Variable

Now we have a dataset containing the IDs of natural mothers, we can load
the smoking information from the Sweep 1 parent interview file
(`mcs1_parent_interview.dta`). The smoking variable we use is called
`APSMUS0A` and contains information on the tobacco product (if any) a
parent consumes. We classify a parent as a smoker if they use any
tobacco product (`mutate(parent_smoker = case_when(...))`).

``` r
df_0y_parent <- read_dta("0y/mcs1_parent_interview.dta") %>%
  select(MCSID, APNUM00, APSMUS0A) # Retains only the variables we need

df_0y_parent %>%
  count(APSMUS0A)
```

    # A tibble: 9 × 2
      APSMUS0A                            n
      <dbl+lbl>                       <int>
    1 -9 [Refusal]                        4
    2 -8 [Don't Know]                     3
    3 -1 [Not applicable]                10
    4  1 [No, does not smoke]         21229
    5  2 [Yes, cigarettes]             9003
    6  3 [Yes, roll-ups]               1246
    7  4 [Yes, cigars]                  217
    8  5 [Yes, a pipe]                    6
    9 95 [Yes, other tobacco product]    16

``` r
df_0y_smoking <- df_0y_parent %>%
  mutate(parent_smoker = case_when(APSMUS0A %in% 2:95 ~ 1, # If APSMUS0A is integer between 2 and 95, then 1
                            APSMUS0A == 1 ~ 0)) %>% # If APSMUS0A is 1, then 0
  select(MCSID, APNUM00, parent_smoker)
```

Now we can merge the two datasets together to ensure we only keep rows
in `df_0y_smoking` that appear in `df_0y_mothers`. We use `left_join()`
to do this, with `df_0y_mothers` as the dataset determining the
outputted rows, so that we have one row per identified mother.[^2] The
result is a dataset with one row per family with an identified mother.
We rename the `parent_smoker` variable to `mother_smoker` to clarify
that it refers to the mother’s smoking status.

Below we also pipe this dataset into the `tabyl()` function (from
`janitor`) to tabulate the number and proportions of mothers who smoke
and those who do not.

``` r
# install.packages("janitor") # Uncomment if you need to install
library(janitor)
df_0y_mothers %>%
  left_join(df_0y_smoking, by = c("MCSID", "APNUM00")) %>%
  select(MCSID, mother_smoker = parent_smoker) %>%
  tabyl(mother_smoker)
```

     mother_smoker     n     percent valid_percent
                 0 12883 0.695814205     0.6968304
                 1  5605 0.302727518     0.3031696
                NA    27 0.001458277            NA

# Determining Relationships between Non-Cohort Members

The household grids include another set of relationship variables
besides `[A-G]HCREL00`. These vary in name slightly between sweeps:
`[A-D]HPREL[A-Z]0` in `mcs[1-4]_hhgrid.dta`, `EPREL0[A-Z]00` in
`mcs5_hhgrid.dta`, and `[F-G]HPREL0[A-Z]` in `mcs[6-7]_hhgrid.dta`.
These variables can be used to identify the relationships between
non-cohort member family members. Specifically, they record the person
in the row’s (ego) relationship to the person denoted by the column
(alt); the letter `[A-Z]` in the variable name corresponds to the alt’s
`[A-D]PNUM00`. For instance, the variable `AHPRELB0` denotes the
relationship of the person in the row to the person in the same family
with `APNUM00 == 2`. Below, we extract a small set of data from the
Sweep 1 household grid to show this in action.

``` r
df_0y_hhgrid_prel <- read_dta("0y/mcs1_hhgrid.dta") %>%
  select(MCSID, APNUM00, matches("AHPREL[A-Z]0"))

df_0y_hhgrid_prel %>%
  filter(MCSID == "M10001N") %>% # To look at just one family
  select(APNUM00, AHPRELA0, AHPRELB0, AHPRELC0) # To look at first few relationship variables
```

    # A tibble: 7 × 4
      APNUM00 AHPRELA0                  AHPRELB0                  AHPRELC0          
        <dbl> <dbl+lbl>                 <dbl+lbl>                 <dbl+lbl>         
    1       1 96 [Self]                  1 [Husband/Wife]          7 [Natural paren…
    2       2  1 [Husband/Wife]         96 [Self]                  7 [Natural paren…
    3       3  3 [Natural son/daughter]  3 [Natural son/daughter] 96 [Self]         
    4       4  3 [Natural son/daughter]  3 [Natural son/daughter] 11 [Natural broth…
    5       5  3 [Natural son/daughter]  3 [Natural son/daughter] 11 [Natural broth…
    6       6  3 [Natural son/daughter]  3 [Natural son/daughter] 11 [Natural broth…
    7     100  3 [Natural son/daughter]  3 [Natural son/daughter] 11 [Natural broth…

There are seven members in this family, one of whom is a cohort member
(`APNUM00 == 100`). `APNUM00`’s 1 and 2 are the (natural) parents, and
`APNUM00`’s 3-6 and 100 are the (natural) children. The relationship
variables show that `APNUM00`’s 1 and 2 are married, and `APNUM00`’s 3-7
are siblings (`AHPRELC0 == 11 [Natural brother/sister]`) and biological
offspring of `APNUM00`’s 1 and 2
(`AHPREL[A-B]0 == 3 [Natural son/daughter]`). Note the symmetry in the
relationships. Where, `APNUM00 == 1`, `AHPRELC0 == 7 [Natural Parent]`
and where `APNUM00 == 3`, `AHPRELA0 == 3 [Natural son/daughter]`.

If we want to find the particular person occupying a specific
relationship for an individual (e.g., we want to know the `[A-G]PNUM00`
of the person’s partner), we need to reshape the data into long-format
with one row per ego-alt relationship within a family. For instance, if
we want to find each person’s spouse (conditional on one being present),
we can do the following:[^3]

``` r
df_0y_hhgrid_prel %>%
  pivot_longer(cols = matches("AHPREL[A-Z]0"),
               names_to = "alt",
               values_to = "relationship") %>%
  mutate(APNUM00_alt = match(str_sub(alt, -2, -2), LETTERS)) %>% # Creates alt's PNUM00 by matching penultimate letter to position in alphabet
  filter(relationship == 1) %>% # Keep where husband or wife
  select(MCSID, APNUM00, partner_pnum = APNUM00_alt)
```

    # A tibble: 23,616 × 3
       MCSID   APNUM00 partner_pnum
       <chr>     <dbl>        <int>
     1 M10001N       1            2
     2 M10001N       2            1
     3 M10002P       1            2
     4 M10002P       2            1
     5 M10007U       1            2
     6 M10007U       2            1
     7 M10011Q       1            2
     8 M10011Q       2            1
     9 M10015U       1            2
    10 M10015U       2            1
    # ℹ 23,606 more rows

# Coda

This only scratches the surface of what can be achieved with the
household grid. The `mcs[1-7]_hhgrid.dta` files also contain information
on cohort-member and family-member’s dates of birth, which can be used
to, for example, identify the number of resident younger siblings,
determine maternal and paternal age at birth, and so on.

# Footnotes

[^1]: Loading the `.dta` files into `R` with `haven::read_dta()` retains
    the dataset metadata, including variable names and labels, mainly by
    storing variables as `labelled` class objects. See the [`labelled`
    package help
    files](https://cran.r-project.org/web/packages/labelled/vignettes/intro_labelled.html)
    for more information on working with this metadata - for instance,
    converting `labelled` variables to standard `R` factor variables or
    replacing negative values (generally reserved in MCS data to
    indicate missingness) with `R`’s native `NA` value.

[^2]: `left_join()` takes as arguments two data frames and retains only
    the rows in the first data frame, regardless of whether there is a
    match with the second. See [*Combining Data Across
    Sweeps*](https://cls-data.github.io/docs/mcs-merging_across_sweeps.html)
    for more discussion of the `*_join()` functions.

[^3]: For more on reshaping data, see [*Reshaping Data from Long to Wide
    (or Wide to
    Long)*](https://cls-data.github.io/docs/mcs-reshape_long_wide.html)
    for more discussion of the `*_join()` functions.
