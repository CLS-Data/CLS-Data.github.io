* Load Packages
clear all
set more off

* lookfor
use "38y/bcs8derived.dta", clear
lookfor "smok" "cigar"

* codebook
log using codebook.log
codebook
log close

* Create a Lookup Table Across All Datasets
* ssc install filelist
filelist, pattern("*.dta")
keep if !strmatch(dirname, "*UKDS*")
tempfile file_list
save `file_list'

clear
tempfile all_vars
save `all_vars', emptyok

use `file_list', clear
local n_files = _N
forvalues i = 1/`n_files' {
    use `file_list' in `i', clear
	local filename = filename[1]
    local dirname = dirname[1]
    use "`dirname'/`filename'", clear
	describe *, replace
	gen dir = "`dirname'"
	gen file = "`filename'"
	append using `all_vars'
	save `all_vars', replace
}

use `all_vars', clear
gen name_low = lower(name)
gen varlab_low = lower(varlab)
list dir file name varlab if strmatch(varlab_low, "*smok*") | strmatch(varlab_low, "*cigar*")
