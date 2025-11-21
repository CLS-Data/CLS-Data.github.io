clear all
set more off

* Load 42y data
use BCSID BD9HGHTM using "42y/bcs70_2012_derived.dta", clear
rename *, lower
save "temp_42y.dta", replace

* Load 51y data
use bcsid bd11hghtm using "51y/bcs11_age51_main.dta", clear
save "temp_51y.dta", replace

* Full Join
use "temp_42y.dta", clear
merge 1:1 bcsid using "temp_51y.dta"
list * in 1/10
// Use `drop _merge == x`to or run `merge ..., keep(x)` to keep a specific type of match/non-match.

* Appending Sweeps
use "temp_42y.dta", clear
rename bd9* *
gen sweep = 9
save "temp_42y_long.dta", replace

use "temp_51y.dta", clear
rename bd11* *
gen sweep = 11
save "temp_51y_long.dta", replace

use "temp_42y_long.dta", clear
append using "temp_51y_long.dta"
sort bcsid sweep
list * in 1/10

* Adding Missing Rows
fillin bcsid sweep
list * in 1/10
