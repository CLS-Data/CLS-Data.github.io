---
layout: default
title: Data Structures
nav_order: 2
parent: Next Steps
format:
  gfm:
    variant: +yaml_metadata_block
---


- [Download the R script for this
  page](../purl/next_steps-data_structures.R)

# Introduction

Once you have downloaded the Next Steps data from the UK Data Service,
you will find over fifty data files, split across three subfolders. The
files differ in the sweep(s) they relate to, the part of the interview
they cover, and - in some cases - the observational unit they describe.
Most files contain one row per cohort member, but some contain one row
per household member, one row per activity, and so on. The aim of this
page is to give you an overview of the files and of the features of the
study design that determine how they should be used.

Compared with the [Millennium Cohort
Study](https://cls-data.github.io/docs/mcs-data_structures.html), the
data structures in Next Steps are simple. There is one cohort member per
family, so a single variable, `NSID`, identifies both the cohort member
and their family. `NSID` appears, with the same name, in every file.
Further, where information was collected from or about a cohort member’s
parents, it is stored in the cohort member’s row (in separate variables
for each parent) rather than in separate rows. As a result, most files
can be merged one-to-one using `NSID` alone.

# Subfolders

The data files are provided in three subfolders. Unlike the other CLS
cohorts, the subfolders do not correspond to sweeps - each contains
files from several sweeps.

- `safeguarded_eul`
  - Contains the main survey files for each sweep, including the cohort
    member and parent interviews and derived variables. Almost all of
    the files with one row per cohort member are found here.
- `household_grids`
  - Contains files with one row for each person the cohort member lives
    with (see [below](#household-grid-files)).
- `activity_histories`
  - Contains files with one row for each spell of education, employment
    or other activity reported by the cohort member.

The code on this website assumes that your working directory is the
folder that contains these three subfolders, so files are referred to by
both their subfolder and file name (e.g.,
`safeguarded_eul/ns8_2015_derived.dta`).

# Naming Conventions

Next Steps was managed by the Department for Education (DfE) for Sweeps
1-7, when it was known as the Longitudinal Study of Young People in
England (LSYPE), and by CLS from Sweep 8 onwards. The file names reflect
this history. Files from Sweeps 1-7 begin `wave_[one-seven]` (the sweep
is written as a word), while files from Sweeps 8 and 9 begin `ns8_2015`
and `ns9_2022`, respectively. A small number of files combine
information from several sweeps. The star (`*`) in the file names below
is used as a wildcard.

| File(s) | Subfolder | Sweeps | One row per… | Identifier(s) |
|----|----|----|----|----|
| `wave_*_lsype_young_person_2020.dta` | `safeguarded_eul` | 1-7 | Cohort member | `NSID` |
| `wave_*_lsype_family_background_2020.dta` | `safeguarded_eul` | 1-5 | Cohort member | `NSID` |
| `wave_*_lsype_parental_attitudes_*.dta` | `safeguarded_eul` | 1-4 | Cohort member | `NSID` |
| `wave_*_lsype_household_grid_file_2020.dta` | `household_grids` | 1-7 | Household member | `NSID` and a person number |
| `wave_*_activity_history_file_2020.dta` | `activity_histories` | 4-7 | Activity | `NSID` and an activity number |
| `ns8_2015_main_interview.dta`, `ns8_2015_self_completion.dta`, `ns8_2015_derived.dta` | `safeguarded_eul` | 8 | Cohort member | `NSID` |
| `ns9_2022_main_interview.dta`, `ns9_2022_derived_variables.dta` | `safeguarded_eul` | 9 | Cohort member | `NSID` |
| Other `ns8_2015_*.dta` and `ns9_2022_*.dta` files | All three | 8-9 | Partnership, child, household member, etc. | `NSID` and a second identifier |
| `ns9_2022_longitudinal_file.dta` | `safeguarded_eul` | All | Cohort member | `NSID` |

We describe each of these in more detail below.

# Variable Names

Variable names begin with a prefix that identifies the sweep: `W1` for
Sweep 1, `W2` for Sweep 2, and so on (“W” stands for wave, the term used
in DfE documentation). In Sweeps 1-7, the prefix is followed by the name
of the question in the questionnaire and then, usually, a suffix that
identifies who the question was asked of or relates to. The most common
suffixes are:

- `YP` - the young person (i.e., the cohort member)
- `MP` - the main parent
- `SP` - the second parent
- `HH` - the household

For instance, `W1hiqualgMP` and `W1hiqualgSP` contain the highest
qualification of the main parent and second parent, respectively, at
Sweep 1. Questions where more than one answer could be given are stored
as a set of binary variables, one for each answer, with a further
two-character suffix (`0a`, `0b`, `0c`, …) at the end of the variable
name.

Variable labels in Sweeps 1-7 also begin with a prefix identifying the
source of the variable: `YP:`, `MP:`, `SP:`, `HH:` (household section),
`HR:` (history section), `DV:` (derived variable), and `Admin:` (survey
administration). Derived variables do not always carry a suffix.

In Sweeps 8 and 9, variable names are in upper case and do not have a
suffix, as only the cohort member was interviewed (e.g., `W8HEIGHT`).
Derived variables begin `W8D` or `W9D` (e.g., `W8DGHQSC`).

There are two things to be careful of. First, variables measuring the
same thing are usually named consistently between sweeps within the DfE
era (Sweeps 1-7) and within the CLS era (Sweeps 8-9), but not across
eras. Second, the use of upper and lower case is not consistent, even
for variables that are otherwise named identically (e.g., `W1alceverYP`
and `W4AlcEverYP`; `W1wrk2MP` and `W1Wrk2SP`). In a few places, the
sweep prefix itself is in lower case (e.g., `w3HhID` in the Sweep 3
household grid). See [*Data
Discovery*](https://cls-data.github.io/docs/next_steps-data_discovery.html)
for ways of finding the variables you need.

# Young Person, Family Background and Parental Attitudes Files

In Sweeps 1-7, the main survey data are split across up to three files
(within the `safeguarded_eul` subfolder), each with one row per cohort
member:

- `wave_[one-seven]_lsype_young_person_2020.dta`
  - Contains the cohort member’s interview, as well as answers given by
    the main parent about the cohort member (e.g., on special
    educational needs).
- `wave_[one-five]_lsype_family_background_2020.dta`
  - Contains information about the household (e.g., housing tenure) and
    about the cohort member’s parents (e.g., their qualifications,
    employment and health). Parents were not interviewed after Sweep 4.
    At Sweep 5, limited information on parents was provided by the
    cohort member.
- `wave_[one-four]_lsype_parental_attitudes_*.dta`
  - Contains the main parent’s attitudes to the cohort member’s
    schooling and their aspirations for the cohort member.

As each of these files has one row per cohort member, they can be merged
using `NSID` alone (see [*Combining Data Within A
Sweep*](https://cls-data.github.io/docs/next_steps-merging_within_sweep.html)).
Below is a schematic of the family background file, which shows how
information on the main and second parent is stored in separate columns,
rather than separate rows.

| `NSID` | `W1hous12HH`  | `W1hiqualgMP`   | `W1hiqualgSP`        | …   |
|--------|---------------|-----------------|----------------------|-----|
| NS0001 | 1 (Household) | 1 (Main parent) | 4 (Second parent)    | …   |
| NS0002 | 4 (Household) | 3 (Main parent) | -98 (SP not present) | …   |
| NS0003 | 2 (Household) | 7 (Main parent) | 2 (Second parent)    | …   |
| …      | …             | …               | …                    | …   |

A further file,
`lsype_history_file_wave_one_and_wave_two_june_2008.dta`, contains
information on the cohort member’s early life (e.g., birth weight) and
their family history, as reported by a parent at Sweep 1 or 2.
`wave_four_lsype_history_2020.dta` contains similar information
collected at Sweep 4.

# Main and Second Parents

In Sweeps 1-4, up to two of the cohort member’s parents (or guardians)
were interviewed. These are referred to as the “main parent” and the
“second parent”. It is important to understand that these are *roles in
the interview*, not fixed individuals:

- In Sweeps 1-3, the main parent was defined as the parent most involved
  in the young person’s education. At Sweep 4, the main parent could be
  either parent - for the original sample, interviewers selected the
  parent they felt was more likely to take part. For the Sweep 4 boost
  sample, the main parent was the natural mother if available, then the
  natural father, then the parent most involved in the young person’s
  education.
- At Sweep 1, the second parent was defined as another adult with a
  parental relationship to the young person (a natural, step, adoptive
  or foster parent). From Sweep 2, the second parent was defined as the
  partner or spouse of the main parent.
- There was no separate second parent interview at Sweep 3. Instead, the
  main parent answered questions on behalf of both parents. At Sweep 4,
  questions about the second parent were answered by the second parent
  if they were present and by the main parent otherwise.
- Parents were not interviewed where the young person had moved out of
  the parental home.

The main and second parent roles were not carried forward from one sweep
to the next. A mother may have been the main parent at Sweep 1 and the
second parent at Sweep 2, for example, and the person occupying a role
may also have changed because someone joined or left the household. A
variable such as `W2hiqualgMP` does not, therefore, necessarily refer to
the same person as `W1hiqualgMP`.

There are two ways of working out who the main and second parent are:

1.  For many characteristics, the family background files contain
    derived variables that refer to the cohort member’s mother and
    father, rather than the main and second parent (e.g., `W1hiqualgmum`
    and `W1hiqualgdad`). The files also contain the sex of the main and
    second parent (e.g., `W1sexMP` and `W1sexSP`).
2.  The family background and household grid files contain variables
    that give the position of the main and second parent in the
    household grid (e.g., `W1mainres` and `W1secores` at Sweep 1). The
    household grid records each household member’s sex and their
    relationship to the cohort member. As a household member is intended
    to keep the same position in the household grid in each sweep, these
    variables can also be compared across sweeps to see whether the
    person in a given role has changed.

We show how to use the second of these in [*Working with the Household
Grid*](https://cls-data.github.io/docs/next_steps-household_grid.html).

Where a variable relates to a parent who was not identified or not
interviewed, specific missing value codes are used: `-98` indicates that
there is no such parent in the household (e.g., there is no second
parent in a lone parent family) and `-99` that the parent was not
interviewed.

# Household Grid Files

The `wave_[one-seven]_lsype_household_grid_file_2020.dta` files, which
are stored in the `household_grids` subfolder, contain rosters of
household members. There is one row for each individual in the
household, including the cohort member. Individuals are identified by
the combination of `NSID` and a person number, which is named `W1HhID`,
`W2HhID`, `w3HhID`, and `W4hhid` in Sweeps 1-4 and `HHID` in Sweeps 5-7.
The cohort member is always person number 1.

| `NSID` | `W1HhID` | `W1Sex`    | `W1R_1`                     | …   |
|--------|----------|------------|-----------------------------|-----|
| NS0001 | 1        | 2 (Female) | -91 (Not applicable)        | …   |
| NS0001 | 2        | 2 (Female) | 8 (Natural parent)          | …   |
| NS0001 | 3        | 1 (Male)   | 8 (Natural parent)          | …   |
| NS0001 | 4        | 1 (Male)   | 13 (Natural brother/sister) | …   |
| NS0002 | 1        | 1 (Male)   | -91 (Not applicable)        | …   |
| NS0002 | 2        | 2 (Female) | 8 (Natural parent)          | …   |
| …      | …        | …          | …                           | …   |

In Sweeps 1-4, the household grid was typically completed by a parent
and records the relationships between household members in a series of
variables (`W1R_1`, `W1R_2`, and so on, at Sweep 1). The number at the
end of the variable name is the person number of the other household
member. Each relationship is only recorded once, in the row of the
person with the higher person number (so, at Sweep 1, `W1R_2` is only
filled in for household members with a person number of 3 or more), and
the variables are otherwise coded as not applicable (`-91`). As the
cohort member is person number 1, `W1R_1` records every other household
member’s relationship to the cohort member. The person numbers of the
main parent and second parent are also recorded (`W1mainres` and
`W1secores` at Sweep 1). In Sweeps 5-7, the household grid was completed
by the cohort member and contains much less information: a single, less
detailed variable (e.g., `W5RELATION`) records each person’s
relationship to the cohort member (at Sweep 7, this is only filled in
for people who are new to the household at that sweep).

The household grid files are described further in [*Working with the
Household
Grid*](https://cls-data.github.io/docs/next_steps-household_grid.html).

# Sweep 8 and 9 Files

From Sweep 8, only the cohort member was interviewed. For each sweep,
the bulk of the data is stored in “flat” files with one row per cohort
member:

- `ns8_2015_main_interview.dta` and `ns9_2022_main_interview.dta`
  - Contain the main interview.
- `ns8_2015_self_completion.dta`
  - Contains the Sweep 8 self-completion questionnaire. (At Sweep 9,
    self-completion questions are included in the main interview file.)
- `ns8_2015_derived.dta` and `ns9_2022_derived_variables.dta`
  - Contain derived variables (e.g., body mass index).

The remaining files are “hierarchical”. These store the answers to sets
of questions that were repeated as many times as necessary - for
instance, once for each of the cohort member’s children. Each can have
multiple rows per cohort member and include a second identifier that
distinguishes the rows belonging to the same cohort member. Cohort
members for whom the questions were not relevant (e.g., those without
children) do not appear in the file at all.

| File | One row per… | Identifiers |
|----|----|----|
| `ns8_2015_partnerships.dta` | Relationship | `NSID`, `W8RELID` |
| `ns8_2015_children.dta` | Child of the cohort member | `NSID`, `W8CHID` |
| `ns8_2015_household_members.dta` | Other household member | `NSID`, `W8HHMID` |
| `ns8_2015_activity_history.dta` | Activity | `NSID`, `W8HISTID` |
| `ns8_2015_benefits.dta` | Benefit received | `NSID`, `W8BENID` |
| `ns9_2022_partnerships.dta` | Relationship | `NSID`, `W9RELID` |
| `ns9_2022_person_grid.dta` | Partner, child or other household member | `NSID`, `GRIDID` |
| `ns9_2022_non_resident_children.dta` | Non-resident child | `NSID`, `GRIDID` |
| `ns9_2022_pregnancy_history.dta` | Child within a pregnancy | `NSID`, `W9PREGID`, `W9CHILDNO` |
| `ns9_2022_activity_history.dta` | Activity | `NSID`, `W9ACTID` |
| `ns9_2022_benefits.dta` | Benefit received | `NSID`, `W9BENID` |

Most of these files are stored in the `safeguarded_eul` subfolder
alongside the flat files. The exceptions are
`ns8_2015_household_members.dta` and `ns9_2022_person_grid.dta`, which
are in the `household_grids` subfolder, and the two activity history
files, which are in the `activity_histories` subfolder.

To use these files alongside the flat files, they generally need to be
collapsed or reshaped so that they have one row per cohort member. We
show an example of this in [*Combining Data Within A
Sweep*](https://cls-data.github.io/docs/next_steps-merging_within_sweep.html).

# Cross-Sweep Files

A small number of files bring together information from several sweeps.
These are all stored in the `safeguarded_eul` subfolder.

- `ns9_2022_longitudinal_file.dta`
  - Contains one row for every cohort member, regardless of the sweeps
    they took part in. It includes the sample design variables
    (`SAMPPSU` and `SAMPSTRATUM`), survey weights, the fieldwork outcome
    at each sweep (`W[1-9]OUTCOME`), and an indicator of whether the
    cohort member is part of the original or boost sample (`MAINBOOST`).
    This is a useful starting point for defining your sample.
- `lsype_main_activity_w4-7_nov2011_suppressed.dta`
  - Contains one row per cohort member, with a variable for the cohort
    member’s main activity (e.g., education or employment) in each month
    between September 2006 and May 2010.
- `next_steps_activities_longitudinal.dta`
  - Contains one row per activity, summarising the activity histories
    collected in Sweeps 4-8.

# The Sweep 4 Boost Sample

The original Next Steps sample was drawn in 2004, when cohort members
were in Year 9 at school. At Sweep 4, the study was enlarged with an
ethnic minority boost sample of 352 young people from Black African and
Black Caribbean backgrounds, selected from schools that did not take
part in the original sampling.

This has important consequences for how the data are used:

- Boost sample members have no data for Sweeps 1-3. This is not a result
  of non-response. Some background information that was collected from
  the original sample in Sweeps 1-3 was instead collected from the boost
  sample at Sweep 4, so the Sweep 4 files contain variables that were
  only asked of boost sample members.
- Analyses that use data from Sweeps 1-3 are necessarily restricted to
  the original sample, and different survey weights are provided for
  analyses that include and exclude the boost sample (e.g.,
  `W4WEIGHT_MAIN_BOOST` and `W4WEIGHT_MAIN` in
  `ns9_2022_longitudinal_file.dta`).

Boost sample members can be identified in two ways:

- `W4Boost` in `wave_four_lsype_young_person_2020.dta` (`1 [Yes]` or
  `2 [No]`). This variable is also available in the other Sweep 4 files.
- `MAINBOOST` in `ns9_2022_longitudinal_file.dta` (`1 [Main]` or
  `2 [Boost]`). As this file contains every cohort member, `MAINBOOST`
  is available for individuals who did not take part in Sweep 4.

# Missing Values

Negative values are used to indicate different forms of missing data.
The values used differ between the DfE and CLS eras. The most common are
shown below, though individual variables may use other codes. It is
always worth checking the value labels of a variable before using it.

| Sweeps 1-7 |  | Sweeps 8-9 |  |
|----|----|----|----|
| `-1` | Don’t know | `-1` | Not applicable |
| `-91` | Not applicable | `-3` | Not asked |
| `-92` | Refused | `-8` | Don’t know or insufficient information |
| `-94` | Insufficient information | `-9` | Refused |
| `-96` | Unable to complete self-completion section |  |  |
| `-97` | Refused self-completion section |  |  |
| `-98` | Parent not present in household |  |  |
| `-99` | Respondent not interviewed |  |  |
| `-996` | No parent in household |  |  |
| `-997` | Script error |  |  |
| `-998` | Interviewer missed question |  |  |
| `-999` | Missing household data |  |  |

Note in particular that `-1` means “Don’t know” in Sweeps 1-7 but “Not
applicable” in Sweeps 8 and 9.

`R` does not know that these values denote missing data. Unless they are
dealt with, negative values are treated as valid values: a mean or a
regression model would include values such as `-92`, for instance, and
each type of missingness would appear as a category of its own in a
tabulation. Negative values therefore usually need to be converted to
`R`’s missing value, `NA`, before a variable is used in an analysis.
Below, we show one way of doing this, using the following packages:

``` r
# Load Packages
library(tidyverse) # For data manipulation
library(haven) # For importing .dta files
library(labelled) # For handling missing values
```

We create a short function, `negative_to_na()`, which uses two functions
from the `labelled` package: `na_range()` declares that all values
between negative infinity (`-Inf`) and `-1` denote missing data, and
`user_na_to_na()` converts the values that have been declared as missing
to `NA`.

``` r
negative_to_na <- function(x){
  na_range(x) <- c(-Inf, -1)
  user_na_to_na(x)
}
```

To show the function in action, we load the variable `W1alceverYP`
(whether the cohort member has ever had a proper alcoholic drink) from
the Sweep 1 young person file, and use `count()` to tabulate the
variable before and after applying `negative_to_na()`.

``` r
df_w1 <- read_dta("safeguarded_eul/wave_one_lsype_young_person_2020.dta",
                  col_select = c("NSID", "W1alceverYP"))

df_w1 %>%
  count(W1alceverYP) # Tabulates the raw variable
```

    # A tibble: 7 × 2
      W1alceverYP                                  n
      <dbl+lbl>                                <int>
    1 -99 [YP not interviewed]                   339
    2 -97 [YP refused CASI section]              133
    3 -96 [YP unable to complete CASI section]   102
    4 -92 [Refused]                              279
    5  -1 [Don't know]                           319
    6   1 [Yes]                                 6740
    7   2 [No]                                  7848

``` r
df_w1 %>%
  mutate(W1alceverYP = negative_to_na(W1alceverYP)) %>% # Replaces negative values with NA
  count(W1alceverYP) # Tabulates the cleaned variable
```

    # A tibble: 3 × 2
      W1alceverYP     n
      <dbl+lbl>   <int>
    1  1 [Yes]     6740
    2  2 [No]      7848
    3 NA           1172

In the second table, the negative values have been replaced with `NA`.
Note, `negative_to_na()` treats *every* negative value as missing, so it
should not be used with variables that can take genuinely negative
values.
