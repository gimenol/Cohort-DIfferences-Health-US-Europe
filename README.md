# Cohort differences in physical health and disability in the United States and Europe 

This repository contains Stata code for the main analysis of [Gimeno, Goisis, Dowd & Ploubidis (2024)](https://doi.org/10.1093/geronb/gbae113), which explores trends in physical health and disability across pseudo-cohorts constructed from harmonised HRS, SHARE and ELSA data collected between 2004 and 2018. 

The data comes from the following studies: 
* The Health and Retirement Survey (HRS), a survey of adults aged 51+ from the US. More information about [HRS](https://hrs.isr.umich.edu/).
* The English Longitudinal Study of Ageing (ELSA), a survey of adults aged 50+ from England. More information about [ELSA](https://www.elsa-project.ac.uk/).
* The Survey of Health, Ageing and Retirement in Europe (SHARE), a survey of adults aged 50+ from countries in continental Europe (we use data from 11 countries who participated since 2004). More information about [SHARE](http://www.share-project.org/home0.html).

This study uses already harmonised data from these surveys, which can be accessed through the [Gateway to Global Ageing Data](https://g2aging.org/). The sepecific versions of the data used were Harmonised HRS version C, Harmonised ELSA version G2, and Harmonised SHARE Version F.

The code is numbered in the following way: 
* 1_filename: Data extraction and preparation
* 2_filename: Wrangling
* 3_filename: Inverse probability weight derivation
* 4_filename: Regression models
* 5_filename: Random effects meta-analyses
* 6_filename: Data visualisation
* 7_filename: Additional analyses using biomarkers in ELSA
