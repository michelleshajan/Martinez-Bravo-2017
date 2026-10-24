capture drop group
gen group = .
replace group = 1 if inrange(ele1v_post92,1992,1993)
replace group = 2 if inrange(ele1v_post92,1994,1996)
replace group = 3 if inrange(ele1v_post92,1997,2000)
label define gr 1 "1992-93" 2 "1994-96" 3 "1997-2000"
label values group gr


* INTENSITY DiD (pooled)
reghdfe doc POST i.POST##c.num_PSINPRES1980, ///
    absorb(v_id year) vce(cluster idkab_num)
margins POST, dydx(num_PSINPRES1980)											/* Marginal effect of one more school by POST status*/


* HETEROGENEITY by baseline provision (bdum)
reghdfe doc i.POST##i.bdum##c.num_PSINPRES1980, ///
    absorb(v_id year) vce(cluster idkab_num)
margins bdum, dydx(num_PSINPRES1980) at(POST=(0 1))								/* Marginal effect of intensity by bdum and POST*/

* Run above within each election group
forvalues g = 1/3 {
reghdfe doc i.POST##c.num_PSINPRES1980 if group==`g', ///
        absorb(v_id year) vce(cluster idkab_num)

reghdfe doc i.POST##i.bdum##c.num_PSINPRES1980 if group==`g', ///
        absorb(v_id year) vce(cluster idkab_num)
}
