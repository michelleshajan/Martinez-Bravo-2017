*******************************************************
* Course: 5304
* Instructor: Jaakko Meriläinen
* Date: October 9th, 2025
* PS6 

*Abstract 
*\ A by-product of the extension of mass education is the increase in the level of education of those eligible for political offices. This can have a profound impact on the effectiveness of local governments. In this paper, I examine the effects of a large school construction program in Indonesia on local governance and public good provision. The results show that the program led to important increases in the provision of public goods. Furthermore, I provide evidence consistent with the hypothesis that the increase in the education of the village heads was one of the main mechanisms behind these results.*\
*******************************************************

* Change file path if necessary
local PS6DIR "C:\Users\miche\Downloads"

* ---------- Do not run if already installed ----------
* ssc install reghdfe, replace
* ssc install ftools, replace
* ssc instal estout

use "`PS6DIR'/Data/DID_Data_Martinez-Bravo (2017).dta", clear
set more off
cap mkdir "`PS6DIR'/tables"

*******************************************************
* 1) Treatment, groups, and POSTs
*******************************************************
capture drop TREATED gA gB gC POST_A POST_B POST_C POST_u
gen TREATED=(num_PSINPRES1980>0)

gen byte gA = inrange(ele1v_post92, 1992, 1993)
gen byte gB = inrange(ele1v_post92, 1994, 1996)
gen byte gC = inrange(ele1v_post92, 1997, 2000)

gen byte POST_A = .
replace POST_A = year >= 1993 if gA

gen byte POST_B = .
replace POST_B = year >= 1996 if gB

gen byte POST_C = .
replace POST_C = year >= 2000 if gC

gen byte POST_u = .
replace POST_u = POST_A if gA
replace POST_u = POST_B if gB
replace POST_u = POST_C if gC

*******************************************************
* Q2.1 — 2×2 cell-mean grids (console + LaTeX)
*******************************************************
capture program drop _q21_grid
program define _q21_grid, rclass
    args G POSTVAR OUTFILE

    quietly summarize HEALTH_CENTER_VL if TREATED==0 & `POSTVAR'==0, meanonly
    scalar m00 = r(mean)
    quietly summarize HEALTH_CENTER_VL if TREATED==1 & `POSTVAR'==0, meanonly
    scalar m10 = r(mean)
    quietly summarize HEALTH_CENTER_VL if TREATED==0 & `POSTVAR'==1, meanonly
    scalar m01 = r(mean)
    quietly summarize HEALTH_CENTER_VL if TREATED==1 & `POSTVAR'==1, meanonly
    scalar m11 = r(mean)

    scalar d_pre   = m10 - m00
    scalar d_post  = m11 - m01
    scalar d_ctrl  = m01 - m00
    scalar d_treat = m11 - m10
    scalar did     = d_post - d_pre

    matrix GRID = ( m00 , m10 , d_pre  \ ///
                    m01 , m11 , d_post \ ///
                    d_ctrl , d_treat , did )
    matrix colnames GRID = "TREATED = 0" "TREATED = 1" "Difference"
    matrix rownames GRID = "POST = 0" "POST = 1" "Difference"

    di as txt "=== Q2.1 — Group `G' (cell means & differences) ==="
    matlist GRID, names format(%9.3f) rowtitle("")
    return scalar did = did

    * Write LaTeX
    cap file close _tbl
    file open _tbl using "`OUTFILE'", write replace
    file write _tbl "\begin{table}[htbp]\centering" _n
    file write _tbl "\caption{Q2.1 --- Group `G': Cell Means of \texttt{HEALTH\_CENTER\_VL}}" _n
    file write _tbl "\begin{tabular}{lccc}\hline\hline" _n
    file write _tbl " & \textbf{TREATED = 0} & \textbf{TREATED = 1} & \textbf{Difference} \\\\" _n
    file write _tbl "\hline" _n
    file write _tbl " \textbf{POST = 0} & " %9.3f (m00) " & " %9.3f (m10) " & " %9.3f (d_pre)  " \\\\" _n
    file write _tbl " \textbf{POST = 1} & " %9.3f (m01) " & " %9.3f (m11) " & " %9.3f (d_post) " \\\\" _n
    file write _tbl " \textbf{Difference} & " %9.3f (d_ctrl) " & " %9.3f (d_treat) " & " %9.3f (did)    " \\\\" _n
    file write _tbl "\hline\hline" _n
    file write _tbl "\end{tabular}" _n
    file write _tbl "\end{table}" _n
    file close _tbl
end

* --- Group A ---
preserve
    keep if gA
    _q21_grid "A" POST_A "`PS6DIR'/tables/q2_1_groupA_grid.tex"
restore

* --- Group B ---
preserve
    keep if gB
    _q21_grid "B" POST_B "`PS6DIR'/tables/q2_1_groupB_grid.tex"
restore

* --- Group C ---
preserve
    keep if gC
    _q21_grid "C" POST_C "`PS6DIR'/tables/q2_1_groupC_grid.tex"
restore

*******************************************************
* 2.2) Simple DiD per group (cluster idkab_num) -> LaTeX + console
*******************************************************
preserve
    keep if gA
    quietly regress HEALTH_CENTER_VL i.TREATED##c.POST_A, vce(cluster idkab_num)
    eststo q2_2_gA
    esttab q2_2_gA using "`PS6DIR'/tables/q2_2_groupA.tex", replace ///
        booktabs se star(* 0.10 ** 0.05 *** 0.01) b(%9.3f) se(%9.3f) ///
        keep(1.TREATED#c.POST_A 1.TREATED POST_A) ///
        coeflabels(1.TREATED#c.POST_A "DiD (Treated×Post)" 1.TREATED "Treated" POST_A "Post") ///
        title("Q2.2 — DiD (Group A; clustered at idkab\\_num)") ///
        addnotes("Outcome: HEALTH\\_CENTER\\_VL")
    local b  = _b[1.TREATED#c.POST_A]
    local se = _se[1.TREATED#c.POST_A]
    local t  = `b'/`se'
    local p  = 2*ttail(e(df_r), abs(`t'))
    di as txt "Q2.2 Group A — DiD: " as res %9.3f `b' as txt "  SE: " as res %9.3f `se' as txt "  p: " as res %9.3f `p'
restore

preserve
    keep if gB
    quietly regress HEALTH_CENTER_VL i.TREATED##c.POST_B, vce(cluster idkab_num)
    eststo q2_2_gB
    esttab q2_2_gB using "`PS6DIR'/tables/q2_2_groupB.tex", replace ///
        booktabs se star(* 0.10 ** 0.05 *** 0.01) b(%9.3f) se(%9.3f) ///
        keep(1.TREATED#c.POST_B 1.TREATED POST_B) ///
        coeflabels(1.TREATED#c.POST_B "DiD (Treated×Post)" 1.TREATED "Treated" POST_B "Post") ///
        title("Q2.2 — DiD (Group B; clustered at idkab\\_num)") ///
        addnotes("Outcome: HEALTH\\_CENTER\\_VL")
    local b  = _b[1.TREATED#c.POST_B]
    local se = _se[1.TREATED#c.POST_B]
    local t  = `b'/`se'
    local p  = 2*ttail(e(df_r), abs(`t'))
    di as txt "Q2.2 Group B — DiD: " as res %9.3f `b' as txt "  SE: " as res %9.3f `se' as txt "  p: " as res %9.3f `p'
restore

preserve
    keep if gC
    quietly regress HEALTH_CENTER_VL i.TREATED##c.POST_C, vce(cluster idkab_num)
    eststo q2_2_gC
    esttab q2_2_gC using "`PS6DIR'/tables/q2_2_groupC.tex", replace ///
        booktabs se star(* 0.10 ** 0.05 *** 0.01) b(%9.3f) se(%9.3f) ///
        keep(1.TREATED#c.POST_C 1.TREATED POST_C) ///
        coeflabels(1.TREATED#c.POST_C "DiD (Treated×Post)" 1.TREATED "Treated" POST_C "Post") ///
        title("Q2.2 — DiD (Group C; clustered at idkab\\_num)") ///
        addnotes("Outcome: HEALTH\\_CENTER\\_VL")
    local b  = _b[1.TREATED#c.POST_C]
    local se = _se[1.TREATED#c.POST_C]
    local t  = `b'/`se'
    local p  = 2*ttail(e(df_r), abs(`t'))
    di as txt "Q2.2 Group C — DiD: " as res %9.3f `b' as txt "  SE: " as res %9.3f `se' as txt "  p: " as res %9.3f `p'
restore

*******************************************************
* 2.3) Pooled TWFE (village & year FE; cluster idkab_num) -> LaTeX + console
*******************************************************
cap which reghdfe
if _rc==0 {
    quietly reghdfe HEALTH_CENTER_VL c.POST_u##i.TREATED, absorb(v_id year) vce(cluster idkab_num)
    eststo q2_3_twfe
    esttab q2_3_twfe using "`PS6DIR'/tables/q2_3_twfe.tex", replace ///
        booktabs se star(* 0.10 ** 0.05 *** 0.01) b(%9.3f) se(%9.3f) ///
        keep(1.TREATED#c.POST_u POST_u) ///
        coeflabels(1.TREATED#c.POST_u "Treated×POST" POST_u "POST") ///
        title("Q2.3 — Pooled TWFE (Village & Year FE; clustered at idkab\\_num)") ///
        addnotes("Outcome: HEALTH\\_CENTER\\_VL"; "Absorbed FE: v\\_id and year")
    local b  = _b[1.TREATED#c.POST_u]
    local se = _se[1.TREATED#c.POST_u]
    local t  = `b'/`se'
    local p  = 2*ttail(e(df_r), abs(`t'))
    di as txt "Q2.3 TWFE — Treated×POST: " as res %9.3f `b' as txt "  SE: " as res %9.3f `se' as txt "  p: " as res %9.3f `p'
}
else {
    quietly areg HEALTH_CENTER_VL c.POST_u##i.TREATED i.year, absorb(v_id) vce(cluster idkab_num)
    eststo q2_3_twfe
    esttab q2_3_twfe using "`PS6DIR'/tables/q2_3_twfe.tex", replace ///
        booktabs se star(* 0.10 ** 0.05 *** 0.01) b(%9.3f) se(%9.3f) ///
        keep(1.TREATED#c.POST_u POST_u) ///
        coeflabels(1.TREATED#c.POST_u "Treated×POST" POST_u "POST") ///
        title("Q2.3 — Pooled TWFE (Village FE & Year FE; clustered at idkab\\_num)") ///
        addnotes("Outcome: HEALTH\\_CENTER\\_VL"; "Absorbed FE: v\\_id and year")
    local b  = _b[1.TREATED#c.POST_u]
    local se = _se[1.TREATED#c.POST_u]
    local t  = `b'/`se'
    local p  = 2*ttail(e(df_r), abs(`t'))
    di as txt "Q2.3 TWFE — Treated×POST: " as res %9.3f `b' as txt "  SE: " as res %9.3f `se' as txt "  p: " as res %9.3f `p'
}

di as res "LaTeX tables saved to: `PS6DIR'/tables/"

*******************************************************
* (Optional) Part 1 pre-trend figures — keep if you still want PNGs
*******************************************************
cap mkdir "`PS6DIR'/figures"
set scheme s2color

preserve
    keep if gA
    collapse (mean) HEALTH_CENTER_VL, by(year TREATED)
    label define tr 0 "Control" 1 "Treated", replace
    label values TREATED tr
    twoway (line HEALTH_CENTER_VL year if TREATED==0, lpattern(solid)) ///
           (line HEALTH_CENTER_VL year if TREATED==1, lpattern(dash)), ///
           legend(order(1 "Control" 2 "Treated") pos(6)) ///
           ytitle("Share with health center") xtitle("Year") ///
           xline(1993, lpattern(dot)) ///
           title("Group A: first post-1992 election in 1992–1993")
    graph export "`PS6DIR'/figures/q1_parallel_trends_groupA.png", replace width(2400)
restore

preserve
    keep if gB
    collapse (mean) HEALTH_CENTER_VL, by(year TREATED)
    label values TREATED tr
    twoway (line HEALTH_CENTER_VL year if TREATED==0, lpattern(solid)) ///
           (line HEALTH_CENTER_VL year if TREATED==1, lpattern(dash)), ///
           legend(order(1 "Control" 2 "Treated") pos(6)) ///
           ytitle("Share with health center") xtitle("Year") ///
           xline(1996, lpattern(dot)) ///
           title("Group B: first post-1992 election in 1994–1996")
    graph export "`PS6DIR'/figures/q1_parallel_trends_groupB.png", replace width(2400)
restore

preserve
    keep if gC
    collapse (mean) HEALTH_CENTER_VL, by(year TREATED)
    label values TREATED tr
    twoway (line HEALTH_CENTER_VL year if TREATED==0, lpattern(solid)) ///
           (line HEALTH_CENTER_VL year if TREATED==1, lpattern(dash)), ///
           legend(order(1 "Control" 2 "Treated") pos(6)) ///
           ytitle("Share with health center") xtitle("Year") ///
           xline(2000, lpattern(dot)) ///
           title("Group C: first post-1992 election in 1997–2000")
    graph export "`PS6DIR'/figures/q1_parallel_trends_groupC.png", replace width(2400)
restore

* Treatment indicator (>=1 INPRES school)
capture confirm variable TREATED
if _rc {
    gen byte TREATED = num_PSINPRES1980 > 0
    label var TREATED "1 if village had >=1 INPRES school"
}

* Make sure POST is a clean 0/1 dummy per your PS definition
capture confirm variable POST
if _rc {
     gen byte POST = (year >= 1992)
     label var POST "Post period (per PS definition)"
 }

* Election timing groups (keep only if needed by your PS)
capture drop group
gen group = .
replace group = 1 if inrange(ele1v_post92,1992,1993)
replace group = 2 if inrange(ele1v_post92,1994,1996)
replace group = 3 if inrange(ele1v_post92,1997,2000)
label define gr 1 "1992-93" 2 "1994-96" 3 "1997-2000"
label values group gr

* Labels (optional)
label var HEALTH_CENTER_VL "Village has health center (puskesmas)"
label var num_PSINPRES1980 "# INPRES schools by 1980"
label var bdum "Baseline deficiency dummy"
label var idkab_num "Kabupaten cluster id"

* 2.4 INTENSITY DiD (pooled)
reghdfe HEALTH_CENTER_VL POST i.POST##c.num_PSINPRES1980, ///
    absorb(v_id year) vce(cluster idkab_num)
margins POST, dydx(num_PSINPRES1980)											/* Marginal effect of one more school by POST status*/


* 2.5 HETEROGENEITY by baseline provision (bdum)
reghdfe HEALTH_CENTER_VL i.POST##i.bdum##c.num_PSINPRES1980, ///
    absorb(v_id year) vce(cluster idkab_num)
margins bdum, dydx(num_PSINPRES1980) at(POST=(0 1))								/* Marginal effect of intensity by bdum and POST*/

* (Optional) Run 2.4 and 2.5 within each election group
*forvalues g = 1/3 {
 *   reghdfe HEALTH_CENTER_VL i.POST##c.num_PSINPRES1980 if group==`g', ///
        absorb(v_id year) vce(cluster idkab_num)

  *  reghdfe HEALTH_CENTER_VL i.POST##i.bdum##c.num_PSINPRES1980 if group==`g', ///
        absorb(v_id year) vce(cluster idkab_num)
*}

* 3.1 ROBUSTNESS: add time-varying covariates
* Standard DiD (TREATED x POST) with FE and covariates x year
reghdfe HEALTH_CENTER_VL i.TREATED##i.POST ///
    c.dum_otrocop_pre#i.year c.num_bank_pre#i.year c.pedati_pre#i.year, ///
    absorb(v_id year) vce(cluster idkab_num)

* 3.2 ROBUSTNESS: placebo (pre-treatment only: 1986 & 1990)
preserve
keep if inlist(year,1986,1990)
gen byte POST_placebo = (year==1990)
label var POST_placebo "Placebo POST (1990=1)"

reghdfe HEALTH_CENTER_VL i.TREATED##i.POST_placebo, ///
    absorb(v_id year) vce(cluster idkab_num)
restore
