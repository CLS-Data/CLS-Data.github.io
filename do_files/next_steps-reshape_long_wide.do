clear all
set more off

* Load and Merge
use NSID W8HEIGHT W8WEIGHT using "safeguarded_eul/ns8_2015_main_interview.dta", clear
save "temp_w8.dta", replace

use NSID W9HEIGHT W9WEIGHT using "safeguarded_eul/ns9_2022_main_interview.dta", clear
merge 1:1 NSID using "temp_w8.dta", nogenerate
order NSID W8HEIGHT W8WEIGHT W9HEIGHT W9WEIGHT
sort NSID
list in 1/10

* Reshape Raw Wide to Long
rename (W#HEIGHT W#WEIGHT) (HEIGHT# WEIGHT#) // Moves the sweep number to the end of the name, where reshape expects it by default
reshape long HEIGHT WEIGHT, i(NSID) j(sweep)
list in 1/10

* Reshape Raw Long to Wide
reshape wide HEIGHT WEIGHT, i(NSID) j(sweep)
rename (HEIGHT# WEIGHT#) (W#HEIGHT W#WEIGHT)
list in 1/10

* Cleaned Data
global ages 14 15 16 17 18 19 20 25 32

rename (W#HEIGHT W#WEIGHT) (HEIGHT# WEIGHT#)
reshape long HEIGHT WEIGHT, i(NSID) j(sweep)
gen age = real(word("${ages}", sweep))
gen double height = HEIGHT if HEIGHT > 0 // double keeps the full precision of the raw values
gen double weight = WEIGHT if WEIGHT > 0
keep NSID age height weight
list in 1/10

* Reshape Clean Long to Wide
reshape wide height weight, i(NSID) j(age)
rename (height# weight#) (height_# weight_#)
list in 1/10

* Reshape Clean Wide to Long
reshape long height_ weight_, i(NSID) j(age)
rename (height_ weight_) (height weight)
list in 1/10
