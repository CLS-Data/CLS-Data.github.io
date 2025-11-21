clear all
set more off

* Ethnicity
use MCSID BCNUM00 BDC08E00 using "3y/mcs2_cm_derived.dta", clear
rename BDC08E00 ethnic_group
save "df_ethnic_group.dta", replace

* Country
use MCSID BACTRY00 using "3y/mcs2_family_derived.dta", clear
rename BACTRY00 country
save "df_country.dta", replace

* Parent Reads
use MCSID BPNUM00 BCNUM00 BPOFRE00 using "3y/mcs2_parent_cm_interview.dta", clear
gen parent_reads = .
replace parent_reads = 1 if inrange(BPOFRE00, 1, 3)
replace parent_reads = 0 if inrange(BPOFRE00, 4, 6)
drop if missing(parent_reads)
collapse (max) parent_reads, by(MCSID BCNUM00)
save "df_reads.dta", replace

* Warmth
use MCSID BCNUM00 BELIG00 BPPIAW00 using "3y/mcs2_parent_cm_interview.dta", clear
gen warmth = .
replace warmth = 0 if inrange(BPPIAW00, 1, 6)
replace warmth = 1 if BPPIAW00 == 5
gen var_name = "main_warm" if BELIG00 == 1
replace var_name = "secondary_warm" if BELIG00 != 1
keep MCSID BCNUM00 var_name warmth
reshape wide warmth, i(MCSID BCNUM00) j(var_name) string
rename warmthmain_warm main_warm
rename warmthsecondary_warm secondary_warm
save "df_warm.dta", replace

* NS-SEC
use MCSID BPNUM00 BDD05S00 using "3y/mcs2_parent_derived.dta", clear
rename BDD05S00 parent_nssec
replace parent_nssec = . if parent_nssec < 0
drop if missing(parent_nssec)
collapse (min) family_nssec = parent_nssec, by(MCSID)
save "df_nssec.dta", replace

* Mother Education
use MCSID BPNUM00 BHCREL00 BHPSEX00 using "3y/mcs2_hhgrid.dta", clear
keep if inrange(BPNUM00, 1, 99) & BHCREL00 == 7 & BHPSEX00 == 2
duplicates drop MCSID BPNUM00, force
bysort MCSID: gen n = _N
keep if n == 1
keep MCSID BPNUM00
save "temp_mothers.dta", replace

use MCSID BPNUM00 BDDNVQ00 using "3y/mcs2_parent_derived.dta", clear
rename BDDNVQ00 mother_nvq
merge 1:1 MCSID BPNUM00 using "temp_mothers.dta", keep(using match)
drop BPNUM00
save "df_mother_edu.dta", replace

* Merge All
use "df_ethnic_group.dta", clear
merge m:1 MCSID using "df_country.dta", keep(master match) nogenerate
merge m:1 MCSID using "df_nssec.dta", keep(master match) nogenerate
merge m:1 MCSID using "df_mother_edu.dta", keep(master match) nogenerate
merge 1:1 MCSID BCNUM00 using "df_reads.dta", keep(master match) nogenerate
merge 1:1 MCSID BCNUM00 using "df_warm.dta", keep(master match) nogenerate
list in 1/10
