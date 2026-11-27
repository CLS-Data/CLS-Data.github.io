* Load Packages
clear all
set more off

* lookfor
use "safeguarded_eul/ns8_2015_derived.dta", clear
lookfor "ghq"

* codebook
log using codebook.log, replace
codebook
log close

* Create a Lookup Table Across All Datasets
* ssc install filelist
filelist, pattern("*.dta")
keep if inlist(dirname, "./safeguarded_eul", "./household_grids", "./activity_histories") // Keeps files in the three Next Steps subfolders
tempfile file_list
save "`file_list'"

clear
tempfile all_vars
save "`all_vars'", emptyok

use "`file_list'", clear
local n_files = _N
forvalues i = 1/`n_files' {
    use "`file_list'" in `i', clear
	local filename = filename[1]
    local dirname = dirname[1]
    use "`dirname'/`filename'", clear
	describe *, replace
	gen dir = "`dirname'"
	gen file = "`filename'"
	append using "`all_vars'"
	save "`all_vars'", replace
}

use "`all_vars'", clear
gen name_low = lower(name)
gen varlab_low = lower(varlab)
gen sweep = real(regexs(1)) if regexm(name_low, "^w([0-9])") // Extracts sweep from the variable name
list dir file sweep name varlab if strmatch(varlab_low, "*ghq*")
list dir file sweep name varlab if strmatch(varlab_low, "*ghq*") & strmatch(varlab_low, "*score*")
