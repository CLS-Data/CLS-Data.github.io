clear all
set more off

* Load 23y data
use ncdsid dvwt23 using "23y/ncds4.dta", clear
rename *, upper
save "temp_23y.dta", replace

* Load 50y data
use NCDSID DVWT50 using "50y/ncds_2008_followup.dta", clear
save "temp_50y.dta", replace

* Full Join
use "temp_23y.dta", clear
merge 1:1 NCDSID using "temp_50y.dta"
list * in 1/10
// Use `drop _merge == x`to or run `merge ..., keep(x)` to keep a specific type of match/non-match.

* Appending Sweeps
use "temp_23y.dta", clear
rename DVWT23 DVWT
gen sweep = 23
save "temp_23y_long.dta", replace

use "temp_50y.dta", clear
rename DVWT50 DVWT
gen sweep = 50
save "temp_50y_long.dta", replace

use "temp_23y_long.dta", clear
append using "temp_50y_long.dta"
sort NCDSID sweep
list * in 1/10

* Add missing rows
fillin NCDSID sweep
list * in 1/10
