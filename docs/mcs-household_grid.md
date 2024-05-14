---
layout: default
title: Working with the Household Grid
nav_order: 4
parent: MCS
format: docusaurus-md
---




# Introduction

In this tutorial, we will learn the basics of using the household grid.
Specifically, we will see how to identify particular family members, how
to use the household grid to create family-member specific variables,
and how to determine the relationships between family members. We will
use the example of finding natural mothers smoking status at the first
sweep.

```r
# Load Packages
library(tidyverse) # For data manipulation
library(haven) # For importing .dta files
```

# Finding Mother of Cohort Members

We will load just four variables from the household grid: `MCSID` and
`APNUM00`, which uniquely identify an individual, and `AHPSEX00` and
`AHCREL00`, which contain information on the individual’s sex and their
relationship to the household’s cohort member(s). `AHCREL00 == 7`
identifies natural parents and `AHPSEX00 == 2` identifies females.
Combining the two identifies natural mothers. Below, we use `count()` to
show the different (observed) values for the sex and relationship
variables. We also use the `filter()` function (which retains
observations where the conditions are `TRUE`) to create a dataset
containing the identifiers (`MCSID` and `APNUM00` of natural mothers
only; we will merge this will smoking information shortly.
`add_count(MCSID) %>% filter(n == 1)` is included as an interim step to
ensure there is just one natural mother per family.

```r
df_0y_hhgrid <- read_dta("0y/mcs1_hhgrid.dta") %>%
  select(MCSID, APNUM00, AHPSEX00, AHCREL00)

df_0y_hhgrid %>%
  count(AHPSEX00)
```

``` text
# A tibble: 4 × 2
  AHPSEX00                n
  <dbl+lbl>           <int>
1 -2 [Unknown]           55
2 -1 [Not applicable] 18734
3  1 [Male]           26438
4  2 [Female]         29567
```

```r
df_0y_hhgrid %>%
  count(AHCREL00)
```

``` text
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
```

```r
df_0y_mothers <- df_0y_hhgrid %>%
  filter(AHCREL00 == 7,
         AHPSEX00 == 2) %>%
  add_count(MCSID) %>%
  filter(n == 1) %>%
  select(MCSID, APNUM00)
```

Note, where a cohort member is part of a family (`MCSID`) with two or
more cohort members, the cohort member will have been a multiple birth
(i.e., twin or triplet), so familial relationships should apply to all
cohort members in the family, which is why there is just one
relationship (`[A-G]HCREL00`) variable per household grid file. This
will change as the cohort members age, move into separate residences and
start their own families.

# Creating a Mother’s Smoking Variable

Now we have a dataset containing the IDs of natural mothers, we can load
the smoking information from the Sweep 1 parent interview file. The
smoking variable used is called `APSMUS0A` which contains information on
the tobacco products a parent uses. We classify a parent as a smoker if
they use any tobacco product (`mutate(smoker = case_when(...))`).

```r
df_0y_parent <- read_dta("0y/mcs1_parent_interview.dta") %>%
  select(MCSID, APNUM00, APSMUS0A)

df_0y_parent %>%
  count(APSMUS0A)
```

``` text
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
```

```r
df_0y_smoking <- df_0y_parent %>%
  mutate(smoker = case_when(APSMUS0A %in% 2:95 ~ 1,
                            APSMUS0A == 1 ~ 0)) %>%
  select(MCSID, APNUM00, smoker)
```

Now we can merge the two datasets together to ensure we only keep rows
in `df_0y_smoking` that appear in `df_0y_mothers`. We use `left_join()`
to do this, with `df_0y_mothers` as the dataset determining the
outputted rows, so that we have one row per identified mother. The
result is a dataset with one row per family with an identified mother.
We rename the `smoker` variable to `mother_smoker` to clarify that it
refers to the mother’s smoking status.

Below we also pipe this dataset into the `tabyl()` function (from
`janitor`) to tabulate the number and proportions of mothers who smoke
and those who do not.

```r
# install.packages("janitor") # Uncomment if you need to install
library(janitor)
```

``` text

Attaching package: 'janitor'
```

``` text
The following objects are masked from 'package:stats':

    chisq.test, fisher.test
```

```r
df_0y_mothers %>%
  left_join(df_0y_smoking, by = c("MCSID", "APNUM00")) %>%
  select(MCSID, mother_smoker = smoker) %>%
  tabyl(mother_smoker)
```

``` text
 mother_smoker     n     percent valid_percent
             0 12883 0.695814205     0.6968304
             1  5605 0.302727518     0.3031696
            NA    27 0.001458277            NA
```

# Determining Relationships between Non-Cohort Members

The household grids include another set of relationship variables
(`[A-G]HPREL[A-Z]0`). These can be used to identify the relationships
between family members. These variables record the person in the row’s
(ego) relationship to the person denoted by the column (alt); the
penultimate letter `[A-Z]` in `[A-G]HPREL[A-Z]0` corresponds to the
person’s `PNUM00`. For instance, the variable `AHPRELB0` would denote
the relationship of the person in the row to the person with
`APNUM00 == 2`. We will extract a small set of data from the Sweep 1
household grid to show this in action.

```r
df_0y_hhgrid_prel <- read_dta("0y/mcs1_hhgrid.dta") %>%
  select(MCSID, APNUM00, matches("AHPREL[A-Z]0"))

df_0y_hhgrid_prel %>%
  filter(MCSID == "M10001N") %>% # To look at just one family
  select(APNUM00, AHPRELA0, AHPRELB0, AHPRELC0)
```

``` text
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
```

There are seven members in this family, one of whom is a cohort member
(`APNUM00 == 100`). `APNUM00`’s 1 and 2 are the (natural) parents, and
`APNUM00`’s 3-6 and 100 are the (natural) children. The relationship
variables show that `APNUM00`’s 1 and 2 are married, and `APNUM00`’s 3-7
are siblings. Note, the symmetry in the relationships. Where,
`APNUM00 == 1`, `AHPRELC0 == 7 [Natural Parent]` and where
`APNUM00 == 3`, `AHPRELA0 == 3 [Natural Child]`.

If we want to find the particular person occupying a particular
relationship for an individual (e.g., we want to know the `PNUM00` of
the person’s partner), we need to reshape the data into long-format with
one row per ego-alt relationship within a family. For instance, if we
want to find each person’s spouse (conditional on one being present), we
can do the following:

```r
df_0y_hhgrid_prel %>%
  pivot_longer(cols = matches("AHPREL[A-Z]0"),
               names_to = "alt",
               values_to = "relationship") %>%
  mutate(APNUM00_alt = match(str_sub(alt, 7, 7), LETTERS)) %>%
  filter(relationship == 1) %>%
  select(MCSID, APNUM00, partner_pnum = APNUM00_alt)
```

``` text
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
```

# Coda

This only scratches the surface of what can be achieved with the
household grid. The `mcs[1-7]_hhgrid.dta` also contain information on
cohort-member and family-member’s dates of birth, which can be used to,
for example, identify the number of resident younger siblings, determine
maternal and paternal age at birth, and so on.
