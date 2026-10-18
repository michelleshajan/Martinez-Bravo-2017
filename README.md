# Replication of Martinez-Bravo (2017)

This repository contains Stata code that replicates parts of Monica Martinez-Bravo's "The Local Political Economy Effects of School Construction in Indonesia" (*American Economic Journal: Applied Economics*, 2017). The paper uses the 1970s INPRES school construction programme and the staggered timing of village elections to estimate how local governance affects public good provision.


## Requirements

- **Stata 17 or later.** `master.do` sets `version 17`.
- **Stata packages:** `reghdfe`, `ftools`, `estout`. `code/00_setup.do` installs any that are missing from SSC. 
- **Data:** not included in this repository. See [Data](#data).

## Repository structure

```
martinez-bravo-replication/
├── README.md
├── master.do                  # sets paths and runs all scripts in order
├── code/
│   ├── 00_setup.do            # installs required packages
│   ├── 01_data_prep.do        # treatment, election groups, timing variables
│   ├── 02_parallel_trends.do  # pre-trend graphs by election group
│   ├── 03_main_estimates.do   # cell means, group-level DiD, pooled TWFE
│   ├── 04_heterogeneity.do    # INPRES intensity and baseline deficiency
│   └── 05_robustness.do       # covariate check and placebo test
├── data/
│   └── README.md              # data source instructions (the .dta file is not tracked)

```

## Data

The data come from the replication package for Martinez-Bravo (2017), deposited with the AEA and hosted on openICPSR:

- DOI: https://doi.org/10.3886/E113664V1
- Project page: https://www.openicpsr.org/openicpsr/project/113664/version/V1/view

Setup:

1. Download the dataset (VHeduc_Data) from the openICPSR page.
2. Place the Stata .dta file in `data/`.
3. Make sure the file name matches the `use` line at the top of `code/01_data_prep.do` and change the directory in the master do file.


## Replication results

### Reproduced

**Table 3, Panel B, column (3): doctors in the village, binary INPRES treatment**

Pooled two-way fixed effects (village and year), standard errors clustered at the district level (`idkab_num`). Code: `code/03_main_estimates.do`.

| | Paper | This replication |
|---|---|---|
| Post | −0.006 (0.005) | −0.006 (0.004) |
| Treated × Post | 0.010 (0.005) | 0.010 (0.005) |
| Observations | 59,130 | 59,130 |
| R² | 0.820 | 0.820 |

The interaction, sample size and R² match. The interaction's standard error matches exactly. The post term's standard error differs by 0.001.

## Citation

> Martinez-Bravo, Monica. 2017. "The Local Political Economy Effects of School Construction in Indonesia." *American Economic Journal: Applied Economics* 9(2): 256–289. https://doi.org/10.1257/app.20150447


