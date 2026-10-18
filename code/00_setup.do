* Install required packages only if missing
foreach pkg in reghdfe ftools estout {
    cap which `pkg'
    if _rc ssc install `pkg', replace
}