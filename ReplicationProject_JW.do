*Replication project

*Just a test: is this added to github?

** Regressions  
clear all

* Set working directory depending on user. Comment out the other directory name
global working "/Volumes/grads-1/Joakim documents/1- Coursework/215C/Replication project/"

* Set project directory depending on user. Comment out the other directory name
global project "/Volumes/grads-1/Joakim documents/1- Coursework/215C/Replication project/"

* Set output directory depending on user. Comment out the other directory name
global output "/Volumes/grads-1/Joakim documents/1- Coursework/215C/Replication project/output"

*log using "$working/tso_APSR_2018_regs.log", replace

set matsize 10000
set more off

cd "$working"

use "$working/Files authors/tso_APSR_2018_rep2.dta"


do "$working/authors_regressions.do"
