---
layout: default
title: Introduction
nav_order: 1
---

# Introduction

The Centre for Longitudinal Studies (CLS) manages four cohort studies for which data is currently available to researchers:

1. [The National Child Development Study (NCDS)](https://doi.org/10.1093/ije/dyi183), a birth cohort of individuals born in Britain in a single week of March 1958.
2. [The 1970 British Cohort Study (BCS70)](https://doi.org/10.1093/ije/dyac148), a birth cohort of individuals born in Britain in a single week of April 1970.
3. [Next Steps](https://doi.org/10.5334/ohd.16), a cohort of English schoolchildren followed from age 13/14 and born in 1989/90.
4. [The Millennium Cohort Study (MCS)](https://doi.org/10.1093/ije/dyu001), a birth cohort of individuals born in Britain in 2000/02.

This website provides guided walkthroughs for using `R` for common data management tasks in each of the studies. This include merging files across survey sweeps, reshaping data from wide to long format, and using the correct variables to identify observational units (e.g., cohort members, families, parents, and so on). A separate website providing `Stata` walkthroughs will be developed in due course, though `Stata .do` files can be downloaded on each of the pages here.

For background on CLS' studies, please see cohort profile papers (linked above) and the [CLS website](https://cls.ucl.ac.uk/cls-studies/). Queries about the data can be sent to the [CLS Data team](mailto:clsdata@ucl.ac.uk). Queries, comments and requests about this website can be directed to [Liam Wright](mailto:liam.wright@ucl.ac.uk) or raised as an issue on the [GitHub repository page](https://github.com/CLS-Data/CLS-Data.github.io).

# Data Access

Most of the data is available to researchers via the UK Data Service (links: [NCDS](https://doi.org/10.5255/UKDA-Series-2000032), [BCS70](https://doi.org/10.5255/UKDA-Series-200001), [Next Steps](https://doi.org/10.5255/UKDA-Series-2000030), and [MCS](https://doi.org/10.5255/UKDA-Series-2000031)). This includes a series of harmonized measures created by [CLOSER](https://doi.org/10.5255/UKDA-Series-2000111). Most of the UKDS data is available via the minimally restrictive End User Licence. More sensitive variables, such as low-level geographies, are available by Special Licence or Secure Access only. 

Some data, such as raw genetic data and biological samples, are only available by application to CLS directly. More information is available on the [CLS website](https://cls.ucl.ac.uk/data-access-training/data-access/).

# Preliminaries
The code presented on this website will presume you have downloaded the data from the UKDS in `Stata` (`.dta`) format. For historical reasons, data on the UKDS for the NCDS, BCS70 and MCS are separated by survey sweep. To get all of the survey data for these studies, you therefore need to download multiple individual datasets. This can make merging data across sweeps a little challenging as the data as downloaded are dispersed across multiple folders. The file and folder names are also often not comprehensible.

To make using the datasets easier, we provide code reorganise the `.dta` files into a simple directory structure with a folder for each sweep. This code is described under each study section (e.g., `MCS -> Creating a Simple Folder Structure`). We will assume you have organised the files in this way in other code we present.

We use the `tidyverse` (an `R` package) extensively in the code presented on this website. If you are new to the `tidyverse`, we recommend Hadley Wickham and colleagues' book *R for Data Science* which is [available for free online](https://r4ds.had.co.nz/). We also link to sections in this book, where relevant.

# Code Sharing
This website can obviously not provide all the code you may need to carry out the analyses you may want to with CLS data. We have therefore set up the [`#britishcohorts` hashtag on GitHub Gist](https://gist.github.com/search?q=%23britishcohorts) for people to share code snippets that are useful for CLS analyses. Please consider sharing your own code snippets (for instance, code to derive a useful variable) on GitHub Gist adding the `#britishcohorts` hashtag and a study specific hashtag (`#mcs`, `#bcs70`, `#nextsteps`, `#ncds`) to the Gist description to make it findable. 

Please also consider sharing the full code for papers you publish on the [Open Science Framework website (OSF)](https://osf.io) - it helps others reproduce your work and lowers the cost for others in learning CLS's data. You can add the tag 'british-cohorts' (plus a study-specific tag) to make your project findable.