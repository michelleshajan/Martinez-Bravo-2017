# Stata Replication Code

This folder contains the modular Stata scripts used to replicate the empirical analysis from Martinez-Bravo (2017).

## Execution Order

To run the full analysis, open Stata, set your working directory to the project root, and execute the master script:

```stata
do code/master.do

## Replication Results

The pooled TWFE specification implemented in `code/03_main_estimates.do` matches the baseline difference-in-differences estimates found in **Table 3, Panel B (Dependent variable: Doctors in the village)** of Martinez-Bravo (2017).
