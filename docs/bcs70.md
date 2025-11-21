---
layout: default
title: BCS70
has_children: true
nav_order: 4
---

This section presents code to clean and handle data from the 1970 British Cohort Study (BCS70). The BCS70 has relatively straightforward data structures. Difficulties mainly arise from its historic nature - data from older sweeps does not conform to modern metadata standards (e.g., file and variable names are not explanatory). This can make it challenging to find relevant variables. In "Data Discovery", we provide code to assist with data discovery (i.e., creating searchable data dictionaries).

## Miscellanea

There are a few characteristics of the BCS70 that data users should be aware of.

-   The cohort member identifier variable is `BCSID`. In some datasets, this variable is stored in lower case, `bcsid`.
-   Almost all datasets are at the cohort member level, with one row per-cohort member. Exceptions the derived partnership histories and activity histories datasets.
-   There is a small number of twins in the BCS70. A cohort member's twin can be be identified with the `twincode` variable within the `bcs70_response_1970-2021.dta` dataset. The does not work as a family ID variable.
-   Later sweeps of the BCS70 follow consistent naming conventions (e.g., self-rated health is named `B*HLTHGN` [where `*` is a sweep number]), but earlier sweeps do not (e.g., self-rated health is named `b96043` at age 26y).
-   Later sweeps of the BCS70 have included survey items also collected in the NCDS. Both studies use the same naming conventions for variable names in these sweeps, which can help with harmonisation.
-   The BCS70 did not track all cohort members over time, including the 628 individuals born in Northern Ireland. The `bcs70_response_1970-2021.dta` dataset tracks only those individuals eligible for longitudinal follow-up, so sample sizes are smaller than if all wave-specific datasets are merged together. Users should consider using `bcs70_response_1970-2021.dta` to define their sample.
-   Negative values are typically reserved for different forms of missingness ("Don't know", "Refuse", "Not applicable", etc.), but in some cases - especially with older datasets - missing values have positive values instead.