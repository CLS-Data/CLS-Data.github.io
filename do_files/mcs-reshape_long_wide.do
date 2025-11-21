clear all
set more off

* Reshape Raw Wide to Long
global fups 0 3 5 7 11 14 17

capture program drop load_anthro_wide
program define load_anthro_wide, rclass
	args sweep
	
	local stublist CNUM00 CHTCMA0 CHTCM00 CWTCMA0 CWTCM00
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
	rename *CNUM00 CNUM00
end

load_anthro_wide 1

tempfile next_merge
forvalues sweep = 2/7 {	
    preserve
		load_anthro_wide `sweep'
		save "`next_merge'", replace
	restore
	merge 1:1 MCSID CNUM00 using "`next_merge'", nogenerate
}

rename ?C?TCMA0 ?C?TCM00

sort MCSID CNUM00 
list * in 1/10

** Reshape Raw Wide to Long
rename *CWTCM00 CWTCM00*
rename *CHTCM00 CHTCM00*
reshape long CWTCM00 CHTCM00, i(MCSID CNUM00) j(sweep_letter) string
list in 1/10

** Reshape Raw Long to Wide
reshape wide CHTCM00 CWTCM00, i(MCSID CNUM00) j(sweep_letter) string
rename CWTCM00* *CWTCM00
rename CHTCM00* *CHTCM00
list in 1/10


* Cleaned Data
rename *CWTCM00 CWTCM00*
rename *CHTCM00 CHTCM00*
reshape long CHTCM00 CWTCM00, i(MCSID CNUM00) j(sweep_letter) string
gen sweep = (strpos("`c(ALPHA)'", sweep_letter) + 1) / 2
gen fup = word("${fups}", sweep)
destring fup, replace

gen height = CHTCM00 if CHTCM00 > 0
gen weight = CWTCM00 if CWTCM00 > 0
keep MCSID CNUM00 fup height weight
list in 1/10

* Reshape Clean Long to Wide
reshape wide height weight, i(MCSID CNUM00) j(fup)
list in 1/10

* Reshape Clean Wide to Long
reshape long height weight, i(MCSID CNUM00) j(fup)
list in 1/10
