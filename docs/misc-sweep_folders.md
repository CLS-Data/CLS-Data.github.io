---
layout: default
title: "Creating Per-Sweep Folders"
nav_order: 1
parent: Miscellaneous
format: docusaurus-md
---

# Introduction {#introduction}

This page shows code for taking UKDS zipped files, unzipping them and
placing in per-sweep folders. For this code to work, you should download
UKDS Stata files for a single study.

To begin you will need to create a folder, XX. Alternatively, this code
can be downloaded by cloning the this GitHub repository, saving, opening
the `.Rpoj` file

Why is this not working?

``` r
df <- read_dta("3y/mcs2_cm_interview.dta")
df
```

``` text
# A tibble: 15,778 × 56
   MCSID   BCNUM00       BCMEAS00 BCHSER00  BCHPOU00 BCHCOU00 BCBKHT00 BCHTCM00 
   <chr>   <dbl+lbl>     <dbl+lb> <dbl+lbl> <dbl+lb> <dbl+lb> <dbl+lb> <dbl+lbl>
 1 M10001N 1 [1st Cohor… 1 [Both…  26        1 [Par…  1 [Chi… -1 [Not…  97      
 2 M10002P 1 [1st Cohor… 1 [Both… 159        1 [Par…  1 [Chi… -1 [Not…  96      
 3 M10007U 1 [1st Cohor… 1 [Both…  74        1 [Par…  1 [Chi… -1 [Not… 102      
 4 M10008V 1 [1st Cohor… 0 [No m…  -2 [No … -2 [No … -2 [No … -2 [No …  -2 [No …
 5 M10008V 2 [2nd Cohor… 0 [No m…  -2 [No … -2 [No … -2 [No … -2 [No …  -2 [No …
 6 M10011Q 1 [1st Cohor… 1 [Both…  96        1 [Par…  1 [Chi… -1 [Not… 106      
 7 M10014T 1 [1st Cohor… 1 [Both… 246        1 [Par…  1 [Chi… -1 [Not…  97      
 8 M10015U 1 [1st Cohor… 1 [Both…  28        1 [Par…  1 [Chi… -1 [Not…  94      
 9 M10016V 1 [1st Cohor… 1 [Both… 153        1 [Par…  1 [Chi… -1 [Not… 102      
10 M10017W 1 [1st Cohor… 1 [Both… 125        1 [Par…  1 [Chi… -1 [Not…  99      
# ℹ 15,768 more rows
# ℹ 48 more variables: BCHTMM00 <dbl+lbl>, BCHCMC00 <dbl+lbl>,
#   BCHMMC00 <dbl+lbl>, BCHTOC00 <dbl+lbl>, BCHTAM00 <dbl+lbl>,
#   BCHBKD00 <dbl+lbl>, BCHBKM00 <dbl+lbl>, BCHBKY00 <dbl+lbl>,
#   BCHTAT00 <dbl+lbl>, BCHTTM00 <dbl+lbl>, BCHTIM00 <dbl+lbl>,
#   BCHTRL0A <dbl+lbl>, BCHTRL0B <dbl+lbl>, BCHTRL0C <dbl+lbl>,
#   BCHTRL0D <dbl+lbl>, BCHTRL0E <dbl+lbl>, BCHTRL0F <dbl+lbl>, …
```

