---
layout: default
title: Combining Data Within A Sweep
nav_order: 5
parent: MCS
format: docusaurus-md
---




# Introduction

In this section, we show how to merge, collapse and reshape the various
data structures within a given sweep of the Millennium Cohort Study
(MCS) to create a dataset at the cohort member-level (i.e., one row per
cohort member). This is likely to be the most useful data structure for
most analyses, but similar principles can be applied to create other
structures as needed (e.g., family-level datasets).

We use the following packages:

```r
# Load Packages
library(tidyverse) # For data manipulation
library(haven) # For importing .dta files
```

# Data Cleaning

We create a small dataset that contains information from Sweep 2 on:
family country of residence, cohort member’s ethnicity, whether any
parent reads to the child, the warmth of the relationship between the
parent and the child, family social class (National Statistics
Socio-economic Classification; NS-SEC), and mother’s highest education
level. Constructing and combining these variables involves restructing
the data in various ways, and spans the most common data engineering
tasks involved in bringing together information from a single sweep.

The datasets we use in this tutorial are:

```r
family <- read_dta("3y/mcs2_family_derived.dta") # One row per family
cm <- read_dta("3y/mcs2_cm_derived.dta") # One row per cohort member
parent <- read_dta("3y/mcs2_parent_derived.dta") # One row per parent (responding)
parent_cm <- read_dta("3y/mcs2_parent_cm_interview.dta") # One row per parent (responding) per cohort member
hhgrid <- read_dta("3y/mcs2_hhgrid.dta") # One row per household member
```

We begin with the simplest variables: cohort member’s ethnicity and
family country of residence. Cohort member’s ethnicity is stored in a
cohort-member level dataset already (`mcs2_cm_derived`), so it does not
need further processing. Below we rename the relevant variables and
select it along with the cohort member identifiers, `MCSID` and
`BCNUM00`.

```r
df_ethnic_group <- cm %>%
  select(MCSID, BCNUM00, ethnic_group = BDC08E00) # Retains the listed variables, renaming BDC08E00 as ethnic_group

df_ethnic_group
```

``` text
# A tibble: 15,778 × 3
   MCSID   BCNUM00                             ethnic_group       
   <chr>   <dbl+lbl>                           <dbl+lbl>          
 1 M10001N 1 [1st Cohort Member of the family]  1 [White]         
 2 M10002P 1 [1st Cohort Member of the family]  1 [White]         
 3 M10007U 1 [1st Cohort Member of the family]  1 [White]         
 4 M10008V 1 [1st Cohort Member of the family]  1 [White]         
 5 M10008V 2 [2nd Cohort Member of the family]  1 [White]         
 6 M10011Q 1 [1st Cohort Member of the family]  2 [Mixed]         
 7 M10014T 1 [1st Cohort Member of the family]  1 [White]         
 8 M10015U 1 [1st Cohort Member of the family]  1 [White]         
 9 M10016V 1 [1st Cohort Member of the family]  1 [White]         
10 M10017W 1 [1st Cohort Member of the family] -1 [Not applicable]
# ℹ 15,768 more rows
```

Family country of residence is stored in a family-level dataset
(`mcs2_family_derived`). This also does not need any further processing
at this stage. Later when we merging this data with `df_ethnic_group`,
we perform a 1-to-many merge, so the data will be automatically repeated
for cases where there are multiple cohort members in a family.[^1]

```r
df_country <- family %>%
  select(MCSID, country = BACTRY00)
```

Next, we create a variable that indicates whether *any* parent reads to
the cohort member; in other words, we create a summary variable using
data from individual parents. The `mcs2_parent_cm_interview` dataset
contains a variable for the parent’s reading habit to a given child
(`BPOFRE00`). We first create a binary variable that indicates whether
the parent reads to the cohort member at least once a week, and then
create a summary variable indicating whether any (interviewed) parent
reads (`max(parent_reads)`) by collapsing the data using `summarise()`
on a [grouped data
frame](https://r4ds.hadley.nz/data-transform.html#groups)
(`group_by(MCSID, BCNUM00)`) to ensure this is calculated per cohort
member. The result is a dataset with one row per cohort member with data
on whether any parent reads to them.[^2]

```r
df_reads <- parent_cm %>%
  select(MCSID, BPNUM00, BCNUM00, BPOFRE00) %>%
  mutate(parent_reads = case_when(between(BPOFRE00, 1, 3) ~ 1, # Create binary variable for reading habit
                                  between(BPOFRE00, 4, 6) ~ 0)) %>%
  drop_na() %>% # Drops rows with any missing value (ensures we get a value where at least 1 parent gave a valid response).
  group_by(MCSID, BCNUM00) %>% # Groups the data so summarise() is performed per cohort member.
  summarise(parent_reads = max(parent_reads), # Calculates maximum value per cohort member
            .groups = "drop") # Removes the grouping from the resulting dataframe.

df_reads
```

``` text
# A tibble: 15,684 × 3
   MCSID   BCNUM00                             parent_reads
   <chr>   <dbl+lbl>                                  <dbl>
 1 M10001N 1 [1st Cohort Member of the family]            1
 2 M10002P 1 [1st Cohort Member of the family]            1
 3 M10007U 1 [1st Cohort Member of the family]            1
 4 M10008V 1 [1st Cohort Member of the family]            1
 5 M10008V 2 [2nd Cohort Member of the family]            1
 6 M10011Q 1 [1st Cohort Member of the family]            1
 7 M10014T 1 [1st Cohort Member of the family]            1
 8 M10015U 1 [1st Cohort Member of the family]            1
 9 M10016V 1 [1st Cohort Member of the family]            1
10 M10017W 1 [1st Cohort Member of the family]            1
# ℹ 15,674 more rows
```

We next show a different way of using `mcs2_parent_cm_interview`,
reshaping the data from long to wide so that we have one row per cohort
member. As an example, we create separate variables for whether the
responding parent has a warm relationship with the cohort member
(`BPPIAW00`), one using responses from the main carer and one from the
secondary carer. As `mcs2_parent_cm_interview` have one row per parent x
cohort member combination, we first create a variable indicating which
parent is which (using information from `BELIG00`), and then reshape the
warmth variable from [long to wide using
`pivot_wider()`](https://r4ds.hadley.nz/data-tidy.html#widening-data).

```r
df_warm <- parent_cm %>%
  select(MCSID, BCNUM00, BELIG00, BPPIAW00) %>%
  mutate(var_name = ifelse(BELIG00 == 1, "main_warm", "secondary_warm"),
         warmth = case_when(BPPIAW00 == 5 ~ 1,
                           between(BPPIAW00, 1, 6) ~ 0)) %>%
  select(MCSID, BCNUM00, var_name, warmth) %>%
  pivot_wider(names_from = var_name, # The new variables are named main_warm and secondary_warm...
              values_from = warmth) # ... and take values from "warmth"
```

Next, we show an example of creating family level data using data from
individual parents; in this case, a variable for family social class
(NS-SEC) using data from `mcs2_parent_derived`. As `mcs2_parent_derived`
a parent level dataset, we take the minimum of parents’ NS-SEC
(`BDD05S00`) within a family (lower values of `BDD05S00` indicate higher
social class).

```r
df_nssec <- parent %>%
  select(MCSID, BPNUM00, parent_nssec = BDD05S00) %>%
  mutate(parent_nssec = if_else(parent_nssec < 0, NA, parent_nssec)) %>% # Negative values denote various forms of missingness.
  drop_na() %>%
  group_by(MCSID) %>%
  summarise(family_nssec = min(parent_nssec))
```

Finally, we create a variable for the mother’s highest education level
using the `mcs2_parent_derived` dataset. This involves merging in
relationship information from the household grid and subsetting the rows
so we are left with data for mothers only (see [*Working with the
Household
Grid*](https://cls-data.github.io/docs/mcs-household_grid.html). We
separately filter the household grid for mothers only (`BHCREL00 == 7`
\[Natural Parent\] and `BHPSEX00 == 2` \[Female\]) and select the
highest education level variable (`BDDNVQ00`) from the
`mcs2_parent_derived` dataset. We then merge the datasets together use
`right_join()`, which in this case, gives a row for every mother in the
dataset, regardless of whether they have education data or not
(`right_join()` fills variables with `NA` where [the retained row does
not have a
match](https://r4ds.hadley.nz/missing-values.html#sec-missing-implicit)).[^3]

```r
df_mother <- hhgrid %>%
  select(MCSID, BPNUM00, BHCREL00, BHPSEX00) %>%
  filter(between(BPNUM00, 1, 99),
         BHCREL00 == 7,
         BHPSEX00 == 2) %>%
  distinct(MCSID, BPNUM00) %>%
  add_count(MCSID) %>%
  filter(n == 1) %>%
  select(MCSID, BPNUM00)

df_parent_edu <- parent %>%
  select(MCSID, BPNUM00, mother_nvq = BDDNVQ00)

df_mother_edu <- df_parent_edu %>%
  right_join(df_mother, by = c("MCSID", "BPNUM00")) %>%
  select(-BPNUM00)
```

# Merging the Datasets

Now we have cleaned each variable, we can merge them together. The
cleaned datasets are either at the family level (`df_country`,
`df_nssec`, `df_mother_edu`) or cohort member level (`df_ethnic_group`,
`df_reads`, `df_warm`). We begin with `df_ethnic_group` as this has all
the cohort members participating at Sweep 2 in it. We then use
`left_join()` to merge in other data so original rows are kept (and no
more are added). To merge with a family-level dataset, we use
`left_join(..., by = "MCSID")` as `MCSID` is the unique identifier for
each cohort member. For the cohort member level datasets, we use
`left_join(..., by = c("MCSID", "BCNUM00"))` as the combination of
`MCSID` and `BCNUM00` uniquely identifies cohort members.

```r
df_ethnic_group %>%
  left_join(df_country, by = "MCSID") %>%
  left_join(df_reads, by = c("MCSID", "BCNUM00")) %>%
  left_join(df_warm, by = c("MCSID", "BCNUM00")) %>%
  left_join(df_nssec, by = "MCSID") %>%
  left_join(df_mother_edu, by = "MCSID")
```

``` text
# A tibble: 15,778 × 9
   MCSID   BCNUM00    ethnic_group country parent_reads main_warm secondary_warm
   <chr>   <dbl+lbl>  <dbl+lbl>    <dbl+l>        <dbl>     <dbl>          <dbl>
 1 M10001N 1 [1st Co…  1 [White]   2 [Wal…            1        NA             NA
 2 M10002P 1 [1st Co…  1 [White]   2 [Wal…            1         1              1
 3 M10007U 1 [1st Co…  1 [White]   2 [Wal…            1         0              1
 4 M10008V 1 [1st Co…  1 [White]   1 [Eng…            1         1              1
 5 M10008V 2 [2nd Co…  1 [White]   1 [Eng…            1         1              1
 6 M10011Q 1 [1st Co…  2 [Mixed]   1 [Eng…            1         1             NA
 7 M10014T 1 [1st Co…  1 [White]   3 [Sco…            1         1              1
 8 M10015U 1 [1st Co…  1 [White]   1 [Eng…            1         1              1
 9 M10016V 1 [1st Co…  1 [White]   4 [Nor…            1         1              1
10 M10017W 1 [1st Co… -1 [Not app… 1 [Eng…            1        NA             NA
# ℹ 15,768 more rows
# ℹ 2 more variables: family_nssec <dbl+lbl>, mother_nvq <dbl+lbl>
```

# Footnotes

[^1]: It is also possible to expand a family level dataset so that it
    has as many rows as there are cohort-members in the family.
    `mcs2_family_derived.dta` contains a variable, `BDNOCM00`, with this
    information that can be used with the `tidyverse` function
    `uncount(BDNOCM00)` to achieve this. (The dataset
    `mcs_longitudinal_family_file` contains a variable `NOCMHH` which
    holds similar information.)

[^2]: Below, for simplicity, we drop any rows with missing values
    (`drop_na()` step). Proper analyses may opt to use a different rule,
    which may require merging in other information (e.g., setting the
    value to missing unless all resident parents have been interviewed
    and provided a valid response).

[^3]: More detail on merging with `right_join()` (and other `*_join()`
    variants) is provided in [*Combining Data Across
    Sweeps*](https://cls-data.github.io/docs/mcs-merging_across_sweeps.html),
    as well as [Chapter 19 of the R for Data Science
    textbook](https://r4ds.hadley.nz/joins.html#sec-mutating-joins).
