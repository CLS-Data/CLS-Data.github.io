clear all
set more off

* Missing Values
capture program drop negative_to_na
program define negative_to_na
	syntax varlist(numeric)

	recode `varlist' (min/-1 = .)
end

use NSID W1alceverYP using "safeguarded_eul/wave_one_lsype_young_person_2020.dta", clear
numlabel, add // Adds numeric values to value labels
tabulate W1alceverYP, missing // Raw variable
negative_to_na W1alceverYP // Replaces values of -1 or below with missing (.)
tabulate W1alceverYP, missing // Cleaned variable
