*******************************************************
* 2×2 cell-mean grids with DiD estimates
*******************************************************
capture program drop _grid
program define _grid, rclass
    args G POSTVAR OUTFILE

    quietly summarize doc if TREATED==0 & `POSTVAR'==0, meanonly
    scalar m00 = r(mean)
    quietly summarize doc if TREATED==1 & `POSTVAR'==0, meanonly
    scalar m10 = r(mean)
    quietly summarize doc if TREATED==0 & `POSTVAR'==1, meanonly
    scalar m01 = r(mean)
    quietly summarize doc if TREATED==1 & `POSTVAR'==1, meanonly
    scalar m11 = r(mean)

    scalar d_pre   = m10 - m00 //treated pre - control pre
    scalar d_post  = m11 - m01 //treated post- control post
    scalar d_ctrl  = m01 - m00 //control post-control pre
    scalar d_treat = m11 - m10 //treated post- treated pre
    scalar did     = d_post - d_pre

    matrix GRID = ( m00 , m10 , d_pre  \ ///
                    m01 , m11 , d_post \ ///
                    d_ctrl , d_treat , did )
    matrix colnames GRID = "TREATED = 0" "TREATED = 1" "Difference"
    matrix rownames GRID = "POST = 0" "POST = 1" "Difference"

    di as txt "=== Group `G' (cell means & differences) ==="
    matlist GRID, names format(%9.3f) rowtitle("")
    return scalar did = did

	 esttab matrix(GRID, fmt(%9.3f)) using "`OUTFILE'", replace booktabs ///
        nomtitles nonumbers ///
        title("Group `G': cell means of presence of doctor") ///
        coeflabels(POST0 "POST = 0" POST1 "POST = 1" Difference "Difference") ///
        collabels("TREATED = 0" "TREATED = 1" "Difference")
end

* --- Group A ---
preserve
    keep if gA
    _grid "A" POST_A "$TABLES/groupA_matrix.tex"
restore

* --- Group B ---
preserve
    keep if gB
    _grid "B" POST_B "$TABLES/groupB_matrix.tex"
restore

* --- Group C ---
preserve
    keep if gC
    _grid "C" POST_C "$TABLES/groupC_matrix.tex"
restore

*******************************************************
*Simple DiD per group (cluster idkab_num) 
*******************************************************
preserve
    keep if gA
    quietly regress doc i.TREATED##c.POST_A, vce(cluster idkab_num)
    eststo gA_DiD
    esttab gA_DiD using "$TABLES/groupA.tex", replace ///
        booktabs se star(* 0.10 ** 0.05 *** 0.01) b(%9.3f) se(%9.3f) ///
        keep(1.TREATED#c.POST_A 1.TREATED POST_A) ///
        coeflabels(1.TREATED#c.POST_A "DiD (Treated×Post)" 1.TREATED "Treated" POST_A "Post") ///
        title("DiD (Group A; clustered at idkab\\_num)") ///
        addnotes("Outcome: Presence of Doctor")
    local b  = _b[1.TREATED#c.POST_A]
    local se = _se[1.TREATED#c.POST_A]
    local t  = `b'/`se'
    local p  = 2*ttail(e(df_r), abs(`t'))
    di as txt "Group A — DiD: " as res %9.3f `b' as txt "  SE: " as res %9.3f `se' as txt "  p: " as res %9.3f `p'
restore

preserve
    keep if gB
    quietly regress doc i.TREATED##c.POST_B, vce(cluster idkab_num)
    eststo gB_DiD
    esttab gB_DiD using "$TABLES/groupB.tex", replace ///
        booktabs se star(* 0.10 ** 0.05 *** 0.01) b(%9.3f) se(%9.3f) ///
        keep(1.TREATED#c.POST_B 1.TREATED POST_B) ///
        coeflabels(1.TREATED#c.POST_B "DiD (Treated×Post)" 1.TREATED "Treated" POST_B "Post") ///
        title("DiD (Group B; clustered at idkab\\_num)") ///
        addnotes("Outcome: Presence of Doctor")
    local b  = _b[1.TREATED#c.POST_B]
    local se = _se[1.TREATED#c.POST_B]
    local t  = `b'/`se'
    local p  = 2*ttail(e(df_r), abs(`t'))
    di as txt "DiD: " as res %9.3f `b' as txt "  SE: " as res %9.3f `se' as txt "  p: " as res %9.3f `p'
restore

preserve
    keep if gC
    quietly regress doc i.TREATED##c.POST_C, vce(cluster idkab_num)
    eststo gC_DiD
    esttab gC_DiD using "$TABLES/groupC.tex", replace ///
        booktabs se star(* 0.10 ** 0.05 *** 0.01) b(%9.3f) se(%9.3f) ///
        keep(1.TREATED#c.POST_C 1.TREATED POST_C) ///
        coeflabels(1.TREATED#c.POST_C "DiD (Treated×Post)" 1.TREATED "Treated" POST_C "Post") ///
        title("DiD (Group C; clustered at idkab\\_num)") ///
        addnotes("Outcome: Presence of Doctor")
    local b  = _b[1.TREATED#c.POST_C]
    local se = _se[1.TREATED#c.POST_C]
    local t  = `b'/`se'
    local p  = 2*ttail(e(df_r), abs(`t'))
    di as txt "Group C — DiD: " as res %9.3f `b' as txt "  SE: " as res %9.3f `se' as txt "  p: " as res %9.3f `p'
restore

*******************************************************
* Pooled TWFE (village & year FE; cluster idkab_num) 
*******************************************************
quietly reghdfe doc c.POST##i.TREATED, absorb(v_id year) vce(cluster idkab_num)
eststo twfe_pooled
esttab twfe_pooled using "$TABLES/twfe_pooled.tex", replace ///
	booktabs se star(* 0.10 ** 0.05 *** 0.01) b(%9.3f) se(%9.3f) ///
	keep(1.TREATED#c.POST POST) ///
	coeflabels(1.TREATED#c.POST "Treated×POST" POST "POST") ///
	title("Pooled TWFE (Village & Year FE; clustered at idkab\\_num)") ///
	addnotes("Outcome: Presence of Doctor"; "Absorbed FE: v\\_id and year")
local b  = _b[1.TREATED#c.POST]
local se = _se[1.TREATED#c.POST]
local t  = `b'/`se'
local p  = 2*ttail(e(df_r), abs(`t'))
di as txt "TWFE — Treated×POST: " as res %9.3f `b' as txt "  SE: " as res %9.3f `se' as txt "  p: " as res %9.3f `p'


di as res "LaTeX tables saved to: `TABLES'/"