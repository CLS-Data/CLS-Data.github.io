---
layout: default
title: Next Steps
nav_order: 5
---

This section presents code to clean and handle data from Next Steps.

## Miscellanea

There are a few characteristics of Next Steps that data users should be aware of.

* Next Steps was formerly managed by the Department for Education (DfE) and, between Waves 1-7, known as the Longitudinal Study of Young People in England (LSYPE). There is a marked change in the naming of files between CLS and DfE eras. In each dataset, variable names following the rubric `WX...` where X is a number indicating wave (e.g., `W2ghq` is from the second wave). However, variable names for similar variables are not always named consistently across eras (though typically are within an era).
* Almost all datasets are at the cohort member level, withone row per-cohort member. Exception include the activity history datasets, which are at the activity level (one row per activity).
* Negative variable values are typically reserved for different forms of missingness ("Don't know", "Refuse", "Not applicable", etc.).