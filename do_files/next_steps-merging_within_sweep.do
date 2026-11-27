clear all
set more off

* Sex and Attitude to School
use NSID W1sexYP W1yschat1 using "safeguarded_eul/wave_one_lsype_young_person_2020.dta", clear
rename (W1sexYP W1yschat1) (sex school_attitude)
save "df_yp.dta", replace

* Tenure
use NSID W1hous12HH using "safeguarded_eul/wave_one_lsype_family_background_2020.dta", clear
rename W1hous12HH tenure
save "df_tenure.dta", replace

* Family NS-SEC
use NSID W1nssecMP W1nssecSP using "safeguarded_eul/wave_one_lsype_family_background_2020.dta", clear
replace W1nssecMP = . if !inrange(W1nssecMP, 1, 8) // Values outside 1-8 denote various forms of missingness
replace W1nssecSP = . if !inrange(W1nssecSP, 1, 8)
egen family_nssec = rowmin(W1nssecMP W1nssecSP) // Lowest value of the two variables in each row
keep NSID family_nssec
save "df_nssec.dta", replace

* Mother's NS-SEC
use NSID W1mainres W1secores W1nssecMP W1nssecSP using "safeguarded_eul/wave_one_lsype_family_background_2020.dta", clear
rename (W1mainres W1secores) (W1HhIDMP W1HhIDSP)
reshape long W1HhID W1nssec, i(NSID) j(parent) string // One row per parent
save "temp_parent.dta", replace

use NSID W1HhID W1Sex W1R_1 using "household_grids/wave_one_lsype_household_grid_file_2020.dta", clear
joinby NSID W1HhID using "temp_parent.dta" // Keeps matched rows only
keep if W1R_1 == 8 & W1Sex == 2
bysort NSID: gen n = _N
keep if n == 1
gen mother_nssec = W1nssec if inrange(W1nssec, 1, 8)
keep NSID mother_nssec
save "df_mother_nssec.dta", replace

* Number of Siblings
use NSID W1HhID W1R_1 using "household_grids/wave_one_lsype_household_grid_file_2020.dta", clear
gen sibling = inrange(W1R_1, 13, 17)
collapse (sum) n_siblings = sibling, by(NSID)
save "df_siblings.dta", replace

* Merge All
use "df_yp.dta", clear
merge 1:1 NSID using "df_tenure.dta", keep(master match) nogenerate
merge 1:1 NSID using "df_nssec.dta", keep(master match) nogenerate
merge 1:1 NSID using "df_mother_nssec.dta", keep(master match) nogenerate
merge 1:1 NSID using "df_siblings.dta", keep(master match) nogenerate
set linesize 255 // Widens the output so that each row of the listing fits on one line
list in 1/10
