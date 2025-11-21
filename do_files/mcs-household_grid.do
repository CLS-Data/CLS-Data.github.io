clear all
set more off

* Finding Mother
use MCSID APNUM00 AHPSEX00 AHCREL00 using "0y/mcs1_hhgrid.dta", clear
label list AHPSEX00 AHCREL00
numlabel AHPSEX00 AHCREL00, add // Alternatively tabulate
tabulate AHPSEX00
tabulate AHCREL00
keep if AHCREL00 == 7 & AHPSEX00 == 2
bysort MCSID: gen n = _N
keep if n == 1
drop n
keep MCSID APNUM00
save "temp_mothers.dta", replace

* Mother's Smoking
use MCSID APNUM00 APSMUS0A using "0y/mcs1_parent_interview.dta", clear
label list APSMUS0A
gen parent_smoker = .
replace parent_smoker = 1 if inrange(APSMUS0A, 2, 95)
replace parent_smoker = 0 if APSMUS0A == 1
keep MCSID APNUM00 parent_smoker
save "temp_smoking.dta", replace

* Merge
use "temp_mothers.dta", clear
merge 1:1 MCSID APNUM00 using "temp_smoking.dta", keep(master match)
drop _merge
rename parent_smoker mother_smoker
tabulate mother_smoker

* Relationships
use MCSID APNUM00 AHPREL* using "0y/mcs1_hhgrid.dta", clear
list APNUM00 AHPRELA0 AHPRELB0 AHPRELC0 if MCSID == "M10001N"

* Reshape for Partner
reshape long AHPREL, i(MCSID APNUM00) j(alt) string
gen alt_letter = substr(alt, 1, 1)
gen APNUM00_alt = (strpos("`c(ALPHA)'", alt_letter) + 1) / 2 // c(ALPHA) is inbuilt upper-case alphabet with spaces between letters
keep if AHPREL == 1
keep MCSID APNUM00 APNUM00_alt
rename APNUM00_alt partner_pnum
list in 1/10
