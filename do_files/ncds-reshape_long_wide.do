clear all
set more off

* Load 23y data
use ncdsid dvwt23 dvht23 using "23y/ncds4.dta", clear
rename *, upper
save "temp_23y.dta", replace

* Load 50y data
use NCDSID DVWT50 DVHT50 using "50y/ncds_2008_followup.dta", clear
save "temp_50y.dta", replace

* Merge
use "temp_23y.dta", clear
merge 1:1 NCDSID using "temp_50y.dta"
keep if _merge == 3 // Keeps matches. `merge ..., keep(3)` would also work.
drop _merge

* Reshape Long
reshape long DVHT DVWT, i(NCDSID) j(fup)
list * in 1/10

* Reshape Wide
reshape wide DVHT DVWT, i(NCDSID) j(fup)
list * in 1/10

