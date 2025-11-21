clear all
set more off

* Load 42y data
use BCSID BD9HGHTM BD9WGHTK using "42y/bcs70_2012_derived.dta", clear
rename *, lower
save "temp_42y.dta", replace

* Load 51y data
use bcsid bd11hghtm bd11wghtk using "51y/bcs11_age51_main.dta", clear
save "temp_51y.dta", replace

* Merge
use "temp_42y.dta", clear
merge 1:1 bcsid using "temp_51y.dta"
keep if _merge == 3 // Keeps matches. `merge ..., keep(3)` would also work.
drop _merge

* Rename
rename bd9* *9
rename bd11* *11

* Reshape Long
reshape long hghtm wghtk, i(bcsid) j(sweep)
list * in 1/10

* Reshape Wide
reshape wide hghtm wghtk, i(bcsid) j(sweep)
list * in 1/10
