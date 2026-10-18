set scheme s2color
*/ checking parallel trends assumption for Group A (first election post 92 in 92-93)

preserve
    keep if gA
    collapse (mean) doc, by(year TREATED)
    label define tr 0 "Control" 1 "Treated", replace
    label values TREATED tr
    twoway (line doc year if TREATED==0, lpattern(solid)) ///
           (line doc year if TREATED==1, lpattern(dash)), ///
           legend(order(1 "Control" 2 "Treated") pos(6)) ///
           ytitle("Share with at least one doctor") xtitle("Year") ///
           xline(1993, lpattern(dot)) ///
           title("Group A: first post-1992 election in 1992–1993")
    graph export "$FIGURES/parallel_trends_groupA.png", replace width(2400)
restore

*/ checking parallel trends assumption for Group B (first election post 92 in 94-96)
preserve
    keep if gB
    collapse (mean) doc, by(year TREATED)
    label values TREATED tr
    twoway (line doc year if TREATED==0, lpattern(solid)) ///
           (line doc year if TREATED==1, lpattern(dash)), ///
           legend(order(1 "Control" 2 "Treated") pos(6)) ///
           ytitle("Share with at least one doctor") xtitle("Year") ///
           xline(1996, lpattern(dot)) ///
           title("Group B: first post-1992 election in 1994–1996")
    graph export "$FIGURES/parallel_trends_groupB.png", replace width(2400)
restore

*/ checking parallel trends assumption for Group C (first election post 92 in 97-00)
preserve
    keep if gC
    collapse (mean) doc, by(year TREATED)
    label values TREATED tr
    twoway (line doc year if TREATED==0, lpattern(solid)) ///
           (line doc year if TREATED==1, lpattern(dash)), ///
           legend(order(1 "Control" 2 "Treated") pos(6)) ///
           ytitle("Share with at least one doctor") xtitle("Year") ///
           xline(2000, lpattern(dot)) ///
           title("Group C: first post-1992 election in 1997–2000")
    graph export "$FIGURES/parallel_trends_groupC.png", replace width(2400)
restore