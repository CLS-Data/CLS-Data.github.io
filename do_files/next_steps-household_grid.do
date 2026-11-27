clear all
set more off

* Finding Mother
use NSID W1HhID W1Sex W1R_1 W1EmpStat using "household_grids/wave_one_lsype_household_grid_file_2020.dta", clear
numlabel, add // Adds numeric values to value labels
tabulate W1Sex
tabulate W1R_1
keep if W1R_1 == 8 & W1Sex == 2
bysort NSID: gen n = _N
keep if n == 1
drop n
keep NSID W1HhID W1EmpStat

* Mother's Employment
tabulate W1EmpStat
gen mother_works = .
replace mother_works = 1 if inrange(W1EmpStat, 1, 2)
replace mother_works = 0 if inrange(W1EmpStat, 3, 9)
keep NSID mother_works
tabulate mother_works, missing

* Main and Second Parent
use NSID W1HhID W1Sex W1R_1 W1mainres W1secores using "household_grids/wave_one_lsype_household_grid_file_2020.dta", clear
gen role = "Main parent" if W1HhID == W1mainres
replace role = "Second parent" if W1HhID == W1secores & role == ""
drop if role == ""
bysort role: tabulate W1R_1 W1Sex

* Changes in Main Parent Across Sweeps
use NSID W1HhID W1mainres using "household_grids/wave_one_lsype_household_grid_file_2020.dta", clear
keep if W1HhID == W1mainres
rename W1HhID w1_main_hhid
keep NSID w1_main_hhid
save "temp_w1_main.dta", replace

use NSID W2HhID W2mainres using "household_grids/wave_two_lsype_household_grid_file_2020.dta", clear
keep if W2HhID == W2mainres
rename W2HhID w2_main_hhid
keep NSID w2_main_hhid

merge 1:1 NSID using "temp_w1_main.dta", keep(match) nogenerate
gen same_person = w1_main_hhid == w2_main_hhid
tabulate same_person

* Relationships
use NSID W1HhID W1R_* using "household_grids/wave_one_lsype_household_grid_file_2020.dta", clear
list W1HhID W1R_1 W1R_2 W1R_3 if NSID == NSID[1]

* Reshape for Partner
reshape long W1R_, i(NSID W1HhID) j(W1HhID_alter)
keep if inlist(W1R_, 1, 2)
keep NSID W1HhID W1HhID_alter
rename W1HhID_alter partner_hhid
list in 1/10 // One row per couple: each relationship is only recorded for the person with the higher person number
save "temp_couples.dta", replace

* Add Row for Other Partner
rename (W1HhID partner_hhid) (partner_hhid W1HhID) // Swaps the person numbers of the two partners
append using "temp_couples.dta"
order NSID W1HhID partner_hhid
sort NSID W1HhID
list in 1/10
