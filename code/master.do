version 17
clear all
set more off

global PROJ "Martinez_Bravo_2017"   
global DATA "$PROJ/data"
global OUT  "$PROJ/output"
global FIGURES "$OUT/figures"
global TABLES  "$OUT/tables"

cap mkdir "$OUT"
cap mkdir "$OUT/tables"
cap mkdir "$OUT/figures"

do "$PROJ/code/00_setup.do"
do "$PROJ/code/01_data_prep.do"
do "$PROJ/code/02_parallel_trends.do"
do "$PROJ/code/03_main_estimates.do"
do "$PROJ/code/04_heterogeneity.do"
do "$PROJ/code/05_robustness.do"
