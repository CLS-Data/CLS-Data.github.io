clear all
set more off

* Merging Across Sweeps
use NSID W2ghq12scr using "safeguarded_eul/wave_two_lsype_young_person_2020.dta", clear
save "temp_w2.dta", replace

use NSID W4ghq12scr using "safeguarded_eul/wave_four_lsype_young_person_2020.dta", clear
save "temp_w4.dta", replace

use "temp_w2.dta", clear
merge 1:1 NSID using "temp_w4.dta"
list NSID W2ghq12scr W4ghq12scr _merge in 1/10
// Use `drop if _merge == x` or run `merge ..., keep(x)` to keep a specific type of match/non-match.

* Appending Sweeps
use "temp_w2.dta", clear
rename W2* *
gen sweep = 2
save "temp_w2_long.dta", replace

use "temp_w4.dta", clear
rename W4* *
gen sweep = 4
save "temp_w4_long.dta", replace

use "temp_w2_long.dta", clear
append using "temp_w4_long.dta"
sort NSID sweep
list NSID sweep ghq12scr in 1/10

* Add Missing Rows
fillin NSID sweep
list * in 1/10

* Programmatic Merging
* Lookup lists: the nth word of each list gives the sweep, file and variable to use
global sweeps 2 4 8 9
global files safeguarded_eul/wave_two_lsype_young_person_2020.dta safeguarded_eul/wave_four_lsype_young_person_2020.dta safeguarded_eul/ns8_2015_derived.dta safeguarded_eul/ns9_2022_derived_variables.dta
global ghq_vars W2ghq12scr W4ghq12scr W8DGHQSC W9DGHQSC

capture program drop load_ghq_wide
program define load_ghq_wide
	args i

	local file : word `i' of ${files}
	local ghq_var : word `i' of ${ghq_vars}

	use NSID `ghq_var' using "`file'", clear
end

load_ghq_wide 3
list * in 1/10

load_ghq_wide 1

tempfile next_merge
forvalues i = 2/4 {
    preserve
		load_ghq_wide `i'
		save "`next_merge'", replace
	restore
	merge 1:1 NSID using "`next_merge'", nogenerate
}

sort NSID
list * in 1/10
save "temp_ghq_wide.dta", replace

* Programmatic Appending
capture program drop load_ghq_long
program define load_ghq_long
	args i

	load_ghq_wide `i'
	local ghq_var : word `i' of ${ghq_vars}
	local sweep : word `i' of ${sweeps}
	rename `ghq_var' ghq12
	label values ghq12 . // Removes value labels, which differ between sweeps
	gen sweep = `sweep'
end

load_ghq_long 1

tempfile next_append
forvalues i = 2/4 {
    preserve
		load_ghq_long `i'
		save "`next_append'", replace
	restore
    append using "`next_append'"
}

sort NSID sweep
list * in 1/10

* Replace Negative Values with Missing
capture program drop negative_to_na
program define negative_to_na
	syntax varlist(numeric)

	foreach var of varlist `varlist' {
		replace `var' = . if `var' < 0
	}
end

negative_to_na ghq12
list * in 1/10

* Defining the Sample with the Longitudinal File
use NSID MAINBOOST W?OUTCOME using "safeguarded_eul/ns9_2022_longitudinal_file.dta", clear
tabulate MAINBOOST
merge 1:1 NSID using "temp_ghq_wide.dta", keep(master match) nogenerate
list * in 1/10
