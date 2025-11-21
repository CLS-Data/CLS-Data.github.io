clear all
set more off

* Merging Across Sweeps
use MCSID BCNUM00 BCHTCM00 using "3y/mcs2_cm_interview.dta", clear
rename BCNUM00 CNUM00
save "temp_3y.dta", replace

use MCSID CCNUM00 CCHTCM00 using "5y/mcs3_cm_interview.dta", clear
rename CCNUM00 CNUM00
save "temp_5y.dta", replace

use "temp_3y.dta", clear
merge 1:1 MCSID CNUM00 using "temp_5y.dta"
list MCSID CNUM00 BCHTCM00 CCHTCM00 _merge in 1/10

* Appending Sweeps
use "temp_3y.dta", clear
rename B* *
gen sweep = 2
save "temp_3y_long.dta", replace

use "temp_5y.dta", clear
rename C* *
gen sweep = 3
save "temp_5y_long.dta", replace

use "temp_3y_long.dta", clear
append using "temp_5y_long.dta"
sort MCSID CNUM00 sweep
list MCSID CNUM00 sweep CHTCM00 in 1/10

* Programmatic Merging
global fups 0 3 5 7 11 14 17

capture program drop load_height_wide
program define load_height_wide, rclass
	args sweep
	
	local stublist CNUM00 CHTCMA0 CHTCM00
    local prefix : word `sweep' of `c(ALPHA)'
	local fup : word `sweep' of ${fups}
	
	local prefixed_list ""
	foreach stubvar of local stublist {
		local prefixed_list "`prefixed_list' `prefix'`stubvar'"
	}
	
	describe using "`fup'y/mcs`sweep'_cm_interview.dta", varlist
	local varlist `r(varlist)'
	local in_file: list prefixed_list & varlist
	
	use MCSID `in_file' using "`fup'y/mcs`sweep'_cm_interview.dta", clear
end

load_height_wide 3
rename *CNUM00 CNUM00

tempfile next_merge
forvalues sweep = 4/7 {	
    preserve
		load_height_wide `sweep'
		rename *CNUM00 CNUM00
		save "`next_merge'", replace
	restore
	merge 1:1 MCSID CNUM00 using "`next_merge'", nogenerate
}

sort MCSID CNUM00 
list * in 1/10


* Programmatic Appending
capture program drop load_height_long
program define load_height_long, rclass
	args sweep
	
	load_height_wide `sweep'
    local prefix : word `sweep' of `c(ALPHA)'
	rename `prefix'* *
	rename CHTCM?0 CHTCM00
	local fup : word `sweep' of ${fups}
	gen fup = `fup', after(CNUM00)	
end

load_height_long 3

tempfile next_append
forvalues sweep = 4/7 {	
    preserve
		load_height_long `sweep'
		save "`next_append'", replace
	restore
    append using "`next_append'"
}

sort MCSID CNUM00 fup
list * in 1/10
