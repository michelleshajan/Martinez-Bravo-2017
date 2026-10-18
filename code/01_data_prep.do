use "$DATA/VHeduc_Data.dta", clear
set more off
capture drop TREATED gA gB gC POST_A POST_B POST_C POST_u
gen TREATED=(num_PSINPRES1980>0) 
label define treat_lbl 0 "Control" 1 "Treated"
label var TREATED "Village has >=1 INPRES school"
label values TREATED treat_lbl
* at least one school constructed in the village with the INPRES program defines that village as treated. 

* Doctor outcome: census dummy 'doc' (at least one formally trained doctor).

* Election-timing groups, defined by the first post-1992 election in one of 1992-93, 94-96 or 97-00
gen byte gA = inrange(ele1v_post92, 1992, 1993)
gen byte gB = inrange(ele1v_post92, 1994, 1996)
gen byte gC = inrange(ele1v_post92, 1997, 2000)

* Post indicator, defined per group by its election year
gen byte POST_A = .
replace POST_A = year >= 1993 if gA

gen byte POST_B = .
replace POST_B = year >= 1996 if gB

gen byte POST_C = .
replace POST_C = year >= 2000 if gC

gen byte POST = .
replace POST = POST_A if gA
replace POST = POST_B if gB
replace POST = POST_C if gC
*creating one post variable that combines all post indicators. 


