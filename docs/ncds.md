---
layout: default
title: NCDS
has_children: true
nav_order: 3
---

This section presents code to clean and handle data from the National Child Development Study (NCDS). The NCDS has relatively straightforward data structures. Difficulties mainly arise from its historic nature - data from older sweeps does not conform to modern metadata standards (e.g., file and variable names are not explanatory). This can make it challenging to find relevant variables. In "Data Discovery", we provide code to assist with data discovery (i.e., creating searchable data dictionaries).

## Miscellanea

There are a few characteristics of the NCDS that data users should be aware of.

-   The cohort member identifier variable is `NCDSID`. In earlier datasets, this variable is stored in lower case, `ncdsid`.
-   Almost all datasets are at the cohort member level, with one row per-cohort member. Exceptions include the Age 33y Mother-Child dataset `ncds5mc.dta`, which has one row per child and the derived partnership histories and activity histories datasets.
-   There is a small number of twins and triplets in the NCDS. Multiples can be be identified with the `MULTCODE` variable within the `ncds_response.dta` dataset. The effectively works as a family ID variable for multiples and is set to `-1 [Not applicable]` for singleton births.
-   `ncds0123.dta` combines data from the 0y, 7y, 11y, and 16y sweeps. The NCDS was originally known as the Perinatal Mortality Survey for its initial (0y) sweep. The sweep in which a variable was collected can be ascertained from the variable label (`0`, `1`, `2`, `3`).
-   Later sweeps of the NCDS follow consistent naming conventions (e.g., self-rated health is named `N*HLTHGN` [where `*` is a sweep number]), but earlier sweeps do not (e.g., self-rated health is named `n503913` at age 33y).
-   Later sweeps of the NCDS have included survey items also collected in the BCS70. Both studies use the same naming conventions for variable names in these sweeps, which can help with harmonisation.
-   The NCDS recruited immigrants to the UK during childhood sweeps using school enrollment information. These immigrants met the same eligibility criteria as original cohort members (born in a single week of March 1958). Immigrant additions can be ascertained using the variables `OUTCME00`, `OUTCME01`, `OUTCME02`, `OUTCME03` in `ncds_response.dta`.
-   Negative values are typically reserved for different forms of missingness ("Don't know", "Refuse", "Not applicable", etc.), but in some cases - especially with older datasets - missing values have positive values instead.