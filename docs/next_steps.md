---
layout: default
title: Next Steps
has_children: true
nav_order: 5
---

This section presents code to clean and handle data from Next Steps (formerly the Longitudinal Study of Young People in England, LSYPE). Next Steps has relatively straightforward data structures: every file is linked with a single identifier, `NSID`, and most files have one row per cohort member. Difficulties mainly arise from the study's history. Next Steps was managed by the Department for Education (DfE) for its first seven sweeps and by CLS thereafter, and the naming of files and variables differs between the two eras. We provide an [introduction to the data](https://cls-data.github.io/docs/next_steps-data_structures.html) as necessary background.

Unlike the other CLS cohorts, the End User Licence data for Next Steps are downloaded from the UK Data Service as a single study ([SN 5545](https://datacatalogue.ukdataservice.ac.uk/studies/study/5545)) that covers every sweep. The Stata (`.dta`) files are provided in three subfolders:

-   `safeguarded_eul` contains the main survey files for each sweep.
-   `household_grids` contains files with information on the people the cohort member lives with.
-   `activity_histories` contains files with cohort members' education and employment histories.

There is no pressing need to reorganise the files before using them, so we do not provide code for creating a folder structure. The code in this section assumes that your working directory is the folder that contains these three subfolders (at the time of writing, `UKDA-5545-stata/stata/stata13` within the unzipped download), and refers to files using both the subfolder and file name (e.g., `safeguarded_eul/ns8_2015_derived.dta`).

## Miscellanea

There are a few characteristics of Next Steps that data users should be aware of.

-   DfE documentation uses the term "wave" rather than "sweep" (hence the `W` prefix in variable names). We use "sweep" on this website. Sweeps 1-7 took place annually between 2004 and 2010 (ages 14 to 20), Sweep 8 took place in 2015/16 (age 25), and Sweep 9 in 2022/23 (age 32).
-   Parents were interviewed in Sweeps 1-4. Information on a cohort member's "main parent" and "second parent" is stored in the same row (i.e., in *wide* format), in separate variables suffixed `MP` and `SP`, rather than in separate rows. The main and second parent are not necessarily the same people in each sweep.
-   An ethnic minority boost sample was added to the study at Sweep 4. These cohort members have no data from Sweeps 1-3. Boost sample members can be identified with the variable `W4Boost` in `safeguarded_eul/wave_four_lsype_young_person_2020.dta` or `MAINBOOST` in `safeguarded_eul/ns9_2022_longitudinal_file.dta`.
-   `safeguarded_eul/ns9_2022_longitudinal_file.dta` has one row for every cohort member and contains information on sample design, survey weights and fieldwork outcomes at each sweep. Users should consider using this dataset to define their sample.
-   Negative values are typically reserved for different forms of missingness ("Don't know", "Refused", "Not applicable", etc.), but the codes used differ between the DfE and CLS eras (e.g., "Refused" is `-92` in Sweeps 1-7 but `-9` in Sweeps 8 and 9).
