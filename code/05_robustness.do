* 3.1 ROBUSTNESS: add time-varying covariates
* Standard DiD (TREATED x POST) with FE and covariates x year
reghdfe doc i.TREATED##i.POST ///
    c.dum_otrocop_pre#i.year c.num_bank_pre#i.year c.pedati_pre#i.year, ///
    absorb(v_id year) vce(cluster idkab_num)

* 3.2 ROBUSTNESS: placebo (pre-treatment only: 1986 & 1990)
preserve
keep if inlist(year,1986,1990)
gen byte POST_placebo = (year==1990)
label var POST_placebo "Placebo POST (1990=1)"

reghdfe doc i.TREATED##i.POST_placebo, ///
    absorb(v_id year) vce(cluster idkab_num)
restore
