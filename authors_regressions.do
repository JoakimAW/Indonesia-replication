


* Longer variable labels for summary statistics

label var ethfractd "\hspace{0.1cm} Ethnic Fractionalization (District)"
label var ethfractvil "\hspace{0.1cm} Ethnic Fractionalization (Village)"
label var coethd_vil "\hspace{0.1cm} Coethnicity (District-Village)"
label var ethclustvd "\hspace{0.1cm} Ethnic Clustering (D-V)"
label var ethclustsd "\hspace{0.1cm} Ethnic Clust. (SD-V)"
label var ethseg_d "\hspace{0.1cm} Ethnic Segregation"
label var es_area_d "\hspace{0.1cm} Eth. Seg. x Area (District)"
label var wgcovegd "\hspace{0.1cm} Horiz. Ineq. (D)"

label var relfractd "\hspace{0.1cm} Religious Fractionalization (D)"
label var relfractvil "\hspace{0.1cm} Religious Fractionalization (V)"
*label var coreld_vil "\hspace{0.1cm} Coreligiosity"
label var relclustvd "\hspace{0.1cm} Religious Clustering (D-V)"
label var relclustsd "\hspace{0.1cm} Religious Clustering (SD-V)"
label var relseg_d "\hspace{0.1cm} Religious Segregation"
label var wgcovrgd "\hspace{0.1cm} Horiz. Rel. Ineq. (D)"

label var health_a_distance "\hspace{0.1cm} Distance to Hospital"
label var health_b_distance "\hspace{0.1cm} Distance to Maternity Hospital"
label var health_d_distance "\hspace{0.1cm} Distance to Health Center"
label var health_e_distance "\hspace{0.1cm} Distance to Health Subcenter"
label var edu_b_distance "\hspace{0.1cm} Distance Primary School"
label var edu_c_distance "\hspace{0.1cm} Distance Middle School"
label var edu_d_distance "\hspace{0.1cm} Distance High School"
label var mdyredvil "\hspace{0.1cm} Median Years Education (Village)"
label var mnyredvil "\hspace{0.1cm} Mean Years Ed (V)"
label var mnyredsd "\hspace{0.1cm} Mean Years Ed (SD)"
label var mnyredd "\hspace{0.1cm} Mean Years Education (District)"

label var popd "\hspace{0.1cm} District Population"
label var popsd "\hspace{0.1cm} Subdistrict Population"
label var popv "\hspace{0.1cm} Village Population"
label var logsdpop "\hspace{0.1cm} Subdistrict Population"
label var logdpop "\hspace{0.1cm} Log District Pop"
label var major_agr "\hspace{0.1cm} Proportion Villages with Majority Agri. HHs"
label var area "\hspace{0.1cm} Village Area (1000s ha)" 


label var tot_area_d "\hspace{0.1cm} District Area (1000s ha)"
label var dist_d "\hspace{0.1cm} Distance to District Center"
label var dist_sd "\hspace{0.1cm} Distance to Subdistrict Center"
label var kelurahan "\hspace{0.1cm} Urban" 
label var mn_lurah_d "\hspace{0.1cm} Perc. Urban in District"
label var hilly_int "\hspace{0.1cm} Hilly"
label var perc_poorHH "\hspace{0.1cm} Poverty Rate (Village)"
label var perc_poorHH_d "\hspace{0.1cm} Poverty Rate (District)"
label var asphalt "\hspace{0.1cm} Asphalt Road"
label var asph_stone "\hspace{0.1cm} Asphalt/Stone Road"
label var dev_water_drink "\hspace{0.1cm} Developed Water"
label var gotong "\hspace{0.1cm} Mutual Assistance (Gotong Royong)"
label var arisan "\hspace{0.1cm} Rotating Credit (Arisan)"
label var total_funds "\hspace{0.1cm} District Budget"

label var vhhs "\hspace{0.1cm} Village Head High School or Above"
label var vhter "\hspace{0.1cm} Village Head Tertiary School"
label var vhage "\hspace{0.1cm} Village Head Age"
label var vhyrsoffice "\hspace{0.1cm} Years as Village Head"
label var vhpoorstatus "\hspace{0.1cm} Village Head Decides Poor Status"
label var turnout "\hspace{0.1cm} Voter Turnout"
label var golkar1 "\hspace{0.1cm} Golkar top votes"



* Baseline Specifications


local sum_stats health_d_distance health_e_distance edu_b_distance edu_c_distance edu_d_distance asphalt asph_stone ethfractd ethfractvil ethseg_d coethd_vil relfractd relfractvil relseg_d popd mn_lurah_d tot_area_d perc_poorHH_d popv perc_poorHH major_agr hilly_int kelurahan dist_d area vhage vhyrsoffice vhhs vhter vhpoorstatus turnout golkar1 total_funds 

  
* Prep data a bit more
destring prop* kab*, replace
drop if prop==31


*Summary Statistics
eststo clear
estpost tabstat `sum_stats', statistics(mean sd) columns(statistics)
esttab . using "$output/stats.tex", replace cells("mean(fmt(a3)) sd(fmt(a3))") refcat(health_d_distance "\emph{Panel A: Public Facilities}" ethfractd "\emph{Panel B: Heterogeneity Variables}" popd "\emph{Panel C: District Controls}" popv "\emph{Panel D: Village Controls}", nolabel) label nomtitles nonum noobs width(\hsize) f

eststo clear

****Section Figuring Out District Urbanization's Effect. Problem is that in the main results, we didn't include enough
****district level variables. So we need to include district aggregates, not just village variables.

xtile mn_lurah_d_dc=mn_lurah_d, nq(10)


* Following Gelman (2007): Standardize continuous inputs (before interactions) by subtracting means and dividing by 2 standard deviations
*     and subtracting means of binary variables. This allows for comparisons between continuous and binary substantive effect sizes

* Standardize all explanatory variables by 2 standard deviations
standard2 ethfractd ethfractvil ethseg_d coethd_vil relfractd relfractvil relseg_d
drop log_eth* log_coe* mc_eth* mc_coe* 

* Standardize interaction term
* Rescale without centering by 2 standard deviations (i.e. standardize without subtracting means first)
quietly summarize ethseg_d
g std2_nc_ethseg_d=ethseg_d/(2*r(sd))
quietly summarize tot_area_d
g std2_nc_tot_area_d=tot_area_d/(2*r(sd))
g std2_nc_es_area_d=std2_nc_ethseg_d*std2_nc_tot_area_d

* Standardize all controls
standard2 logdpop tot_area_d perc_poorHH_d mn_lurah_d logvillpop area perc_poorHH kelurahan hilly_int dist_d major_agr vhage vhyrsoffice vhter vhpoorstatus turnout golkar1 total_funds   

* Interaction of rural desa with segregation
g kd=!kelurahan
g std2_es_kd=std2_ethseg_d*kd


* Make a combined index of public goods using inverse covariance matrix weighted index (Anderson 2008)
g no_asphalt=!asphalt
make_index pg_access edu_c_distance edu_d_distance health_d_distance no_asphalt
label var index_pg_access "Lack of PG Access Index"

* Make dichotomous measures of public goods, 1 for above mean and 0 for below mean values for distance measures

g ms_dich=0 if edu_c_distance!=.
replace ms_dich=1 if edu_c_distance>5.29
label var ms_dich "Middle School Farther than Mean"

g hs_dich=0 if edu_d_distance!=.
replace hs_dich=1 if edu_d_distance>14.97
label var hs_dich "High School Farther than Mean"

g hc_dich=0 if health_d_distance!=.
replace hc_dich=1 if health_d_distance>8.51
label var hc_dich "Health Center Farther than Mean"


* Use shorter variable labels

label var ethfractd "EFD"
label var ethfractvil "EFV"
label var coethd_vil "Coethnicity"
label var ethclustvd "Ethnic Clust. (D-V)"
label var ethclustsd "Ethnic Clust. (SD-V)"
label var ethseg_d "Ethnic Segregation"
label var es_area_d "Eth. Seg. x Area (District)"
label var wgcovegd "Horiz. Ineq. (D)"

label var relfractd "RFD"
label var relfractvil "RFV"
label var relseg_d "Relig. Segregation"
label var relclustvd "Rel. Clust. (D-V)"
label var relclustsd "Rel. Clust. (SD-V)"
label var wgcovrgd "Horiz. Rel. Ineq. (D)"

label var health_a_distance "Dist Hospital"
label var health_b_distance "Dist Maternity"
label var health_d_distance "Dist Health Ctr"
label var health_e_distance "Dist Health Subctr"
label var edu_b_distance "Dist Primary Sch"
label var edu_c_distance "Dist Middle Sch"
label var edu_d_distance "Dist High Sch"
label var mdyredvil "Median yrs ed"

label var mnyredvil "Mean Years Ed (V)"
label var mnyredsd "Mean Years Ed (SD)"
label var mnyredd "Mean Years Ed (D)"

label var logvillpop "Log Village Population"
label var logsdpop "Log SD Pop"
label var logdpop "Log District Population"
label var major_agr "Majority Agri"
label var area "Village Area" 
label var tot_area_d "District Area"
label var dist_d "Dist District Ctr"
label var dist_sd "Dist Subdistrict Ctr"
label var kelurahan "Urban" 
label var hilly_int "Hilly"
label var perc_poorHH_d "Poverty Rate (District)"
label var perc_poorHH "Poverty Rate (Village)"
label var mn_lurah_d "Perc. Urban in District"
label var asphalt "Asphalt Road"
label var asph_stone "Asphalt/Stone Road"
label var dev_water_drink "Developed Water"
label var gotong "Mutual Assistance"
label var arisan "Rotating Credit"
label var total_funds "District Budget"

label var vhhs "VH High School or Above"
label var vhter "VH Tertiary School"
label var vhage "VH Age"
label var vhyrsoffice "Years as VH"
label var vhpoorstatus "VH Poor Status"
label var turnout "Voter Turnout"

label var golkar1 "Golkar top votes"

* Use shorter variable labels for standardized variables

label var std2_ethfractd "EFD"
label var std2_ethfractvil "EFV"
label var std2_coethd_vil "Coethnicity"

label var std2_ethseg_d "Ethnic Segregation"
label var std2_nc_es_area_d "Eth. Seg. x Area (District)"

label var std2_relfractd "RFD"
label var std2_relfractvil "RFV"
label var std2_relseg_d "Relig. Segregation"
label var std2_es_kd "Eth. Seg. x Desa"

label var std2_logvillpop "Log Village Population"
label var std2_logdpop "Log District Population"
label var mc_major_agr "Majority Agri"
label var std2_area "Village Area" 
label var std2_tot_area_d "District Area"
label var std2_dist_d "Dist District Ctr"
label var mc_kelurahan "Urban" 
label var mc_hilly_int "Hilly"
label var std2_perc_poorHH_d "Poverty Rate (District)"
label var std2_perc_poorHH "Poverty Rate (Village)"
label var std2_mn_lurah_d "Perc. Urban in District"

label var std2_total_funds "District Budget"

label var mc_vhter "VH Tertiary School"
label var std2_vhage "VH Age"
label var std2_vhyrsoffice "Years as VH"
label var mc_vhpoorstatus "VH Poor Status"
label var std2_turnout "Voter Turnout"
label var mc_golkar1 "Golkar top votes"

* Baseline specification with province fixed effects

eststo clear

*Standardized: All Ethnic Heterogeneity variables together
local EH     std2_ethfractd std2_ethfractvil
local EH_seg std2_ethfractd std2_ethfractvil std2_ethseg_d 
local EH_co std2_ethfractd std2_ethfractvil std2_coethd_vil
local EH_seg_co std2_ethfractd std2_ethfractvil std2_ethseg_d std2_coethd_vil
local EH_segx std2_ethfractd std2_ethfractvil std2_ethseg_d std2_nc_es_area_d


local RH     std2_relfractd std2_relfractvil
local RH_seg std2_relfractd std2_relfractvil std2_relseg_d 

*Standardized: Controls
local controls std2_logdpop std2_tot_area_d std2_perc_poorHH_d std2_mn_lurah_d std2_logvillpop std2_area std2_perc_poorHH mc_kelurahan mc_hilly_int std2_dist_d mc_major_agr std2_vhage mc_vhter mc_vhpoorstatus    
local controls_to std2_logdpop std2_tot_area_d std2_perc_poorHH_d std2_mn_lurah_d std2_logvillpop std2_area std2_perc_poorHH mc_kelurahan mc_hilly_int std2_dist_d mc_major_agr std2_vhage mc_vhter mc_vhpoorstatus turnout   
local controls_pol std2_logdpop std2_tot_area_d std2_perc_poorHH_d std2_mn_lurah_d std2_logvillpop std2_area std2_perc_poorHH mc_kelurahan mc_hilly_int std2_dist_d mc_major_agr std2_vhage mc_vhter mc_vhpoorstatus turnout golkar1
local controls_fd std2_logdpop std2_tot_area_d std2_perc_poorHH_d std2_mn_lurah_d std2_logvillpop std2_area std2_perc_poorHH mc_kelurahan mc_hilly_int std2_dist_d mc_major_agr std2_vhage mc_vhter mc_vhpoorstatus turnout total_funds   
local controls_all std2_logdpop std2_tot_area_d std2_perc_poorHH_d std2_mn_lurah_d std2_logvillpop std2_area std2_perc_poorHH mc_kelurahan mc_hilly_int std2_dist_d mc_major_agr std2_vhage mc_vhter mc_vhpoorstatus turnout golkar1 total_funds   
local controls_kd std2_logdpop std2_tot_area_d std2_perc_poorHH_d std2_mn_lurah_d std2_logvillpop std2_area std2_perc_poorHH mc_hilly_int std2_dist_d mc_major_agr std2_vhage mc_vhter mc_vhpoorstatus    

local controls_d std2_logdpop std2_tot_area_d std2_perc_poorHH_d std2_mn_lurah_d     


****EXCLUDING TOP DECILE****
preserve
keep if mn_lurah_d_dc!=10

***Main results

*Health Centers
areg health_d_distance `EH', a(propid) cluster(kabid)
eststo h1
areg health_d_distance `EH_seg', a(propid) cluster(kabid)
eststo h2
areg health_d_distance std2_ethfractd `controls', a(propid) cluster(kabid)
eststo h3
areg health_d_distance `EH' `controls', a(propid) cluster(kabid)
eststo h4
areg health_d_distance `EH_seg' `controls', a(propid) cluster(kabid)
eststo h5

*Asphalt Roads
areg asphalt `EH' , a(propid) cluster(kabid)
eststo a1
areg asphalt `EH_seg', a(propid) cluster(kabid)
eststo a2
areg asphalt std2_ethfractd `controls', a(propid) cluster(kabid)
eststo a3
areg asphalt `EH' `controls', a(propid) cluster(kabid)
eststo a4
areg asphalt `EH_seg' `controls', a(propid) cluster(kabid)
eststo a5


*Middle Schools

areg edu_c_distance `EH', a(propid) cluster(kabid)
eststo ms1
areg edu_c_distance `EH_seg', a(propid) cluster(kabid)
eststo ms2
areg edu_c_distance std2_ethfractd `controls', a(propid) cluster(kabid)
eststo ms3
areg edu_c_distance `EH' `controls', a(propid) cluster(kabid)
eststo ms4
areg edu_c_distance `EH_seg' `controls', a(propid) cluster(kabid)
eststo ms5

*High Schools
areg edu_d_distance `EH', a(propid) cluster(kabid)
eststo hs1
areg edu_d_distance `EH_seg', a(propid) cluster(kabid)
eststo hs2
areg edu_d_distance std2_ethfractd `controls', a(propid) cluster(kabid)
eststo hs3
areg edu_d_distance `EH' `controls', a(propid) cluster(kabid)
eststo hs4
areg edu_d_distance `EH_seg' `controls', a(propid) cluster(kabid)
eststo hs5

esttab h3 h4 h2 h5 a3 a4 a2 a5 using "$output/tso_ha.tex", replace booktabs fragment se b(%9.3f) se(%9.3f) collabels(none) mgroups("Health Centers (km)" "Asphalt Roads", pattern(1 0 0 0 1 0 0 0) span prefix(\multicolumn{@span}{c}{) suffix(}) erepeat(\cmidrule(lr){@span})) label star(* 0.05 ** 0.01) varlabels(_cons "Constant") order(`EH_seg') nomtitles stats(r2 N, fmt(%9.3f %9.0g) layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}") labels(`"R-Squared"' `"Observations"' )) 
esttab ms3 ms4 ms2 ms5 hs3 hs4 hs2 hs5 using "$output/tso_ed.tex", replace booktabs fragment se b(%9.3f) se(%9.3f) collabels(none) mgroups("Middle Schools (km)" "High Schools (km)", pattern(1 0 0 0 1 0 0 0) span prefix(\multicolumn{@span}{c}{) suffix(}) erepeat(\cmidrule(lr){@span})) label star(* 0.05 ** 0.01) varlabels(_cons "Constant") order(`EH_seg') nomtitles stats(r2 N, fmt(%9.3f %9.0g) layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}") labels(`"R-Squared"' `"Observations"' )) 


*Added Jo
esttab h3 h4 h2 h5 a3 a4 a2 a5 using "$output/tso_ha.tex", replace booktabs se b(%9.3f) se(%9.3f) collabels(none) mgroups("Health Centers (km)" "Asphalt Roads", pattern(1 0 0 0 1 0 0 0) span prefix(\multicolumn{@span}{c}{) suffix(}) erepeat(\cmidrule(lr){@span})) label star(* 0.05 ** 0.01) varlabels(_cons "Constant") order(`EH_seg') nomtitles stats(r2 N, fmt(%9.3f %9.0g) layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}") labels(`"R-Squared"' `"Observations"' )) 


eststo clear


*Sensitivity Analysis (Oster 2014); Setting rmax = 2.2 x R2 for fully controlled regressions

xi: reg health_d_distance `EH_seg' `controls' i.propid
xi: psacalc delta std2_ethseg_d, rmax(0.6963) mcontrol(`EH' i.propid)

xi: reg edu_c_distance `EH_seg' `controls' i.propid
xi: psacalc delta std2_ethseg_d, rmax(0.71654) mcontrol(`EH' i.propid)

xi: reg edu_d_distance `EH_seg' `controls' i.propid
xi: psacalc delta std2_ethseg_d, rmax(0.91058) mcontrol(`EH' i.propid)

xi: reg asphalt `EH_seg' `controls' i.propid
xi: psacalc delta std2_ethseg_d , rmax(0.36344) mcontrol(`EH' i.propid)

**Appendix 

eststo clear
***District only controls
areg edu_c_distance `EH_seg' `controls_d', a(propid) cluster(kabid)
eststo ms1
areg edu_d_distance `EH_seg' `controls_d', a(propid) cluster(kabid)
eststo hs1
areg health_d_distance `EH_seg' `controls_d', a(propid) cluster(kabid)
eststo h1
areg asphalt `EH_seg' `controls_d', a(propid) cluster(kabid)
eststo a1
esttab ms1 hs1 h1 a1 using "$output/tso_donly.tex", replace booktabs fragment se b(%9.3f) se(%9.3f) label star(* 0.05 ** 0.01) varlabels(_cons "Constant") order(`EH_seg')  stats(r2 N, fmt(%9.3f %9.0g) layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}") labels(`"R-Squared"' `"Observations"' )) 

***Main results with Index of Public Goods Access
eststo clear
*Health Centers

areg index_pg_access `EH', a(propid) cluster(kabid)
eststo in1
areg index_pg_access `EH_seg', a(propid) cluster(kabid)
eststo in2
areg index_pg_access std2_ethfractd `controls', a(propid) cluster(kabid)
eststo in3
areg index_pg_access `EH' `controls', a(propid) cluster(kabid)
eststo in4
areg index_pg_access `EH_seg' `controls', a(propid) cluster(kabid)
eststo in5

esttab in3 in4 in2 in5 using "$output/index.tex", replace booktabs fragment se b(%9.3f) se(%9.3f) collabels(none) label star(* 0.05 ** 0.01) varlabels(_cons "Constant") order(`EH_seg') nomtitles stats(r2 N, fmt(%9.3f %9.0g) layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}") labels(`"R-Squared"' `"Observations"' )) 

eststo clear


*Sensitivity Analysis (Oster 2014); Setting rmax = 2.2 x R2 for fully controlled regressions

xi: reg index_pg_access `EH_seg' `controls' i.propid
xi: psacalc delta std2_ethseg_d, rmax(0.65736) mcontrol(`EH' i.propid)


***Dichotomous Measures

*Health Centers
areg hc_dich `EH', a(propid) cluster(kabid)
eststo h1
areg hc_dich `EH_seg', a(propid) cluster(kabid)
eststo h2
areg hc_dich std2_ethfractd `controls', a(propid) cluster(kabid)
eststo h3
areg hc_dich `EH' `controls', a(propid) cluster(kabid)
eststo h4
areg hc_dich `EH_seg' `controls', a(propid) cluster(kabid)
eststo h5

*Asphalt Roads
areg asphalt `EH' , a(propid) cluster(kabid)
eststo a1
areg asphalt `EH_seg', a(propid) cluster(kabid)
eststo a2
areg asphalt std2_ethfractd `controls', a(propid) cluster(kabid)
eststo a3
areg asphalt `EH' `controls', a(propid) cluster(kabid)
eststo a4
areg asphalt `EH_seg' `controls', a(propid) cluster(kabid)
eststo a5


*Middle Schools

areg ms_dich `EH', a(propid) cluster(kabid)
eststo ms1
areg ms_dich `EH_seg', a(propid) cluster(kabid)
eststo ms2
areg ms_dich std2_ethfractd `controls', a(propid) cluster(kabid)
eststo ms3
areg ms_dich `EH' `controls', a(propid) cluster(kabid)
eststo ms4
areg ms_dich `EH_seg' `controls', a(propid) cluster(kabid)
eststo ms5

*High Schools
areg hs_dich `EH', a(propid) cluster(kabid)
eststo hs1
areg hs_dich `EH_seg', a(propid) cluster(kabid)
eststo hs2
areg hs_dich std2_ethfractd `controls', a(propid) cluster(kabid)
eststo hs3
areg hs_dich `EH' `controls', a(propid) cluster(kabid)
eststo hs4
areg hs_dich `EH_seg' `controls', a(propid) cluster(kabid)
eststo hs5

esttab h3 h4 h2 h5 a3 a4 a2 a5 using "$output/tso_ha_dich.tex", replace booktabs fragment se b(%9.3f) se(%9.3f) collabels(none) mgroups("Health Centers (km)" "Asphalt Roads", pattern(1 0 0 0 1 0 0 0) span prefix(\multicolumn{@span}{c}{) suffix(}) erepeat(\cmidrule(lr){@span})) label star(* 0.05 ** 0.01) varlabels(_cons "Constant") order(`EH_seg') nomtitles stats(r2 N, fmt(%9.3f %9.0g) layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}") labels(`"R-Squared"' `"Observations"' )) 
esttab ms3 ms4 ms2 ms5 hs3 hs4 hs2 hs5 using "$output/tso_ed_dich.tex", replace booktabs fragment se b(%9.3f) se(%9.3f) collabels(none) mgroups("Middle Schools (km)" "High Schools (km)", pattern(1 0 0 0 1 0 0 0) span prefix(\multicolumn{@span}{c}{) suffix(}) erepeat(\cmidrule(lr){@span})) label star(* 0.05 ** 0.01) varlabels(_cons "Constant") order(`EH_seg') nomtitles stats(r2 N, fmt(%9.3f %9.0g) layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}") labels(`"R-Squared"' `"Observations"' )) 

eststo clear


*Sensitivity Analysis (Oster 2014); Setting rmax = 2.2 x R2 for fully controlled regressions

xi: reg health_d_distance `EH_seg' `controls' i.propid
xi: psacalc delta std2_ethseg_d, rmax(0.6963) mcontrol(`EH' i.propid)

xi: reg edu_c_distance `EH_seg' `controls' i.propid
xi: psacalc delta std2_ethseg_d, rmax(0.71654) mcontrol(`EH' i.propid)

xi: reg edu_d_distance `EH_seg' `controls' i.propid
xi: psacalc delta std2_ethseg_d, rmax(0.91058) mcontrol(`EH' i.propid)

xi: reg asphalt `EH_seg' `controls' i.propid
xi: psacalc delta std2_ethseg_d , rmax(0.36344) mcontrol(`EH' i.propid)

****Public Goods Determined at Higher Levels

*Health Centers and Helper Health Centers (Puskesmas Pembantu)
areg health_distance_C `EH', a(propid) cluster(kabid)
eststo hh1
areg health_distance_C `EH_seg', a(propid) cluster(kabid)
eststo hh2
areg health_distance_C std2_ethfractd `controls', a(propid) cluster(kabid)
eststo hh3
areg health_distance_C `EH' `controls', a(propid) cluster(kabid)
eststo hh4
areg health_distance_C `EH_seg' `controls', a(propid) cluster(kabid)
eststo hh5

*Primary Schools
areg edu_b_distance `EH', a(propid) cluster(kabid)
eststo ps1
areg edu_b_distance `EH_seg', a(propid) cluster(kabid)
eststo ps2
areg edu_b_distance std2_ethfractd `controls', a(propid) cluster(kabid)
eststo ps3
areg edu_b_distance `EH' `controls', a(propid) cluster(kabid)
eststo ps4
areg edu_b_distance `EH_seg' `controls', a(propid) cluster(kabid)
eststo ps5


*Asphalt or Gravel Roads
areg asph_stone `EH' , a(propid) cluster(kabid)
eststo as1
areg asph_stone `EH_seg', a(propid) cluster(kabid)
eststo as2
areg asph_stone std2_ethfractd `controls', a(propid) cluster(kabid)
eststo as3
areg asph_stone `EH' `controls', a(propid) cluster(kabid)
eststo as4
areg asph_stone `EH_seg' `controls', a(propid) cluster(kabid)
eststo as5

*Sensitivity Analysis
xi: reg asph_stone `EH_seg' `controls' i.propid
psacalc delta std2_ethseg_d , rmax(0.56914) mcontrol(`EH')

esttab hh3 hh4 hh2 hh5 ps3 ps4 ps2 ps5 using "$output/tso_hh_ps.tex", replace booktabs fragment se b(%9.3f) se(%9.3f) collabels(none) mgroups("Health Centers/Subcenters (km)" "Primary Schools (km)", pattern(1 0 0 0 1 0 0 0) span prefix(\multicolumn{@span}{c}{) suffix(}) erepeat(\cmidrule(lr){@span})) label star(* 0.05 ** 0.01) varlabels(_cons "Constant") order(`EH_seg') nomtitles stats(r2 N, fmt(%9.3f %9.0g) layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}") labels(`"R-Squared"' `"Observations"' ))
esttab as3 as4 as2 as5 using "$output/tso_as.tex", replace booktabs fragment se b(%9.3f) se(%9.3f) collabels(none) mgroups("Asphalt or Gravel Roads", pattern(1 0 0 0) span prefix(\multicolumn{@span}{c}{) suffix(}) erepeat(\cmidrule(lr){@span})) label star(* 0.05 ** 0.01) varlabels(_cons "Constant") order(`EH_seg') nomtitles stats(r2 N, fmt(%9.3f %9.0g) layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}") labels(`"R-Squared"' `"Observations"' ))
esttab hh3 hh4 ps3 ps4 using "$output/tso_2.tex", replace booktabs fragment se b(%9.3f) se(%9.3f) collabels(none) mgroups("Health Centers/Subcenters" "Primary Schools", pattern(1 0 1 0) span prefix(\multicolumn{@span}{c}{) suffix(}) erepeat(\cmidrule(lr){@span})) label star(* 0.05 ** 0.01) varlabels(_cons "Constant") order(`EH_seg') nomtitles stats(r2 N, fmt(%9.3f %9.0g) layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}") labels(`"R-Squared"' `"Observations"' ))
esttab as3 as4 using "$output/tso_3.tex", replace booktabs fragment se b(%9.3f) se(%9.3f) collabels(none) mgroups("Asphalt or Gravel Roads", pattern(1 0) span prefix(\multicolumn{@span}{c}{) suffix(}) erepeat(\cmidrule(lr){@span})) label star(* 0.05 ** 0.01) varlabels(_cons "Constant") order(`EH_seg') nomtitles stats(r2 N, fmt(%9.3f %9.0g) layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}") labels(`"R-Squared"' `"Observations"' ))

eststo clear

***Heterogeneous Effects of Segregation on Desa vs. Kelurahan

*Health Centers
areg health_d_distance `EH_seg' if kelurahan==1, a(propid) cluster(kabid)
areg health_d_distance `EH_seg' `controls_kd' if kelurahan==1, a(propid) cluster(kabid)
eststo hk

*Asphalt Roads
areg asphalt `EH_seg'  if kelurahan==1, a(propid) cluster(kabid)
areg asphalt `EH_seg' `controls_kd' if kelurahan==1, a(propid) cluster(kabid)
eststo ak

*Middle Schools
areg edu_c_distance `EH_seg' if kelurahan==1, a(propid) cluster(kabid)
areg edu_c_distance `EH_seg' `controls_kd' if kelurahan==1, a(propid) cluster(kabid)
eststo msk

*High Schools
areg edu_d_distance `EH_seg'  if kelurahan==1, a(propid) cluster(kabid)
areg edu_d_distance `EH_seg' `controls_kd' if kelurahan==1, a(propid) cluster(kabid)
eststo hsk

*Health Centers
areg health_d_distance `EH_seg'  if kelurahan==0, a(propid) cluster(kabid)
areg health_d_distance `EH_seg' `controls_kd' if kelurahan==0, a(propid) cluster(kabid)
eststo hd

*Asphalt Roads
areg asphalt `EH_seg' if kelurahan==0, a(propid) cluster(kabid)
areg asphalt `EH_seg' `controls_kd' if kelurahan==0, a(propid) cluster(kabid)
eststo ad

*Middle Schools
areg edu_c_distance `EH_seg' if kelurahan==0, a(propid) cluster(kabid)
areg edu_c_distance `EH_seg' `controls_kd' if kelurahan==0, a(propid) cluster(kabid)
eststo msd

*High Schools
areg edu_d_distance `EH_seg' if kelurahan==0, a(propid) cluster(kabid)
areg edu_d_distance `EH_seg' `controls_kd' if kelurahan==0, a(propid) cluster(kabid)
eststo hsd

esttab msk msd hsk hsd hk hd ak ad  using "$output/tso_kdlrh.tex", replace booktabs fragment se b(%9.3f) se(%9.3f) collabels(none) mgroups("Middle Schools (km)" "High Schools (km)" "Health Centers (km)" "Asphalt Roads", pattern(1 0 1 0 1 0 1 0) span prefix(\multicolumn{@span}{c}{) suffix(}) erepeat(\cmidrule(lr){@span})) label star(* 0.05 ** 0.01) varlabels(_cons "Constant") order(`EH_seg') nomtitles stats(r2 N, fmt(%9.3f %9.0g) layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}") labels(`"R-Squared"' `"Observations"' )) 

eststo clear


*Sensitivity Analysis (Oster 2014); Setting rmax = 2.2 x R2 for fully controlled regressions

areg health_d_distance `EH_seg' `controls_kd' if kelurahan==0, a(propid) cluster(kabid)
xi: psacalc delta std2_ethseg_d, rmax(0.70114) mcontrol(`EH' i.propid)

areg edu_c_distance `EH_seg' `controls_kd' if kelurahan==0, a(propid) cluster(kabid)
xi: psacalc delta std2_ethseg_d, rmax(0.72292) mcontrol(`EH' i.propid)

areg edu_d_distance `EH_seg' `controls_kd' if kelurahan==0, a(propid) cluster(kabid)
xi: psacalc delta std2_ethseg_d, rmax(0.91476) mcontrol(`EH' i.propid)

areg asphalt `EH_seg' `controls_kd' if kelurahan==0, a(propid) cluster(kabid)
xi: psacalc delta std2_ethseg_d , rmax(0.32296) mcontrol(`EH' i.propid)

**Controlling for Coethnicity

*Health Centers
areg health_d_distance `EH_co', a(propid) cluster(kabid)
eststo h1
areg health_d_distance `EH_seg_co', a(propid) cluster(kabid)
eststo h2
areg health_d_distance std2_ethfractd std2_coethd_vil `controls', a(propid) cluster(kabid)
eststo h3
areg health_d_distance `EH_co' `controls', a(propid) cluster(kabid)
eststo h4
areg health_d_distance `EH_seg_co' `controls', a(propid) cluster(kabid)
eststo h5

*Asphalt Roads
areg asphalt `EH_co' , a(propid) cluster(kabid)
eststo a1
areg asphalt `EH_seg_co', a(propid) cluster(kabid)
eststo a2
areg asphalt std2_ethfractd std2_coethd_vil `controls', a(propid) cluster(kabid)
eststo a3
areg asphalt `EH_co' `controls', a(propid) cluster(kabid)
eststo a4
areg asphalt `EH_seg_co' `controls', a(propid) cluster(kabid)
eststo a5

*Middle Schools

areg edu_c_distance `EH_co', a(propid) cluster(kabid)
eststo ms1
areg edu_c_distance `EH_seg_co', a(propid) cluster(kabid)
eststo ms2
areg edu_c_distance std2_ethfractd std2_coethd_vil `controls', a(propid) cluster(kabid)
eststo ms3
areg edu_c_distance `EH_co' `controls', a(propid) cluster(kabid)
eststo ms4
areg edu_c_distance `EH_seg_co' `controls', a(propid) cluster(kabid)
eststo ms5

*High Schools
areg edu_d_distance `EH_co', a(propid) cluster(kabid)
eststo hs1
areg edu_d_distance `EH_seg_co', a(propid) cluster(kabid)
eststo hs2
areg edu_d_distance std2_ethfractd std2_coethd_vil `controls', a(propid) cluster(kabid)
eststo hs3
areg edu_d_distance `EH_co' `controls', a(propid) cluster(kabid)
eststo hs4
areg edu_d_distance `EH_seg_co' `controls', a(propid) cluster(kabid)
eststo hs5

esttab h3 h4 h2 h5 a3 a4 a2 a5 using "$output/tso_co_ha.tex", replace booktabs fragment se b(%9.3f) se(%9.3f) collabels(none) mgroups("Health Centers (km)" "Asphalt Roads", pattern(1 0 0 0 1 0 0 0) span prefix(\multicolumn{@span}{c}{) suffix(}) erepeat(\cmidrule(lr){@span})) label star(* 0.05 ** 0.01) varlabels(_cons "Constant") order(`EH_seg_co') nomtitles stats(r2 N, fmt(%9.3f %9.0g) layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}") labels(`"R-Squared"' `"Observations"' ))
esttab ms3 ms4 ms2 ms5 hs3 hs4 hs2 hs5 using "$output/tso_co_ed.tex", replace booktabs fragment se b(%9.3f) se(%9.3f) collabels(none) mgroups("Middle Schools (km)" "High Schools (km)", pattern(1 0 0 0 1 0 0 0) span prefix(\multicolumn{@span}{c}{) suffix(}) erepeat(\cmidrule(lr){@span})) label star(* 0.05 ** 0.01) varlabels(_cons "Constant") order(`EH_seg_co') nomtitles stats(r2 N, fmt(%9.3f %9.0g) layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}") labels(`"R-Squared"' `"Observations"' ))
esttab ms3 ms4 hs3 hs4 h3 h4 a3 a4 using "$output/tso_co.tex", replace booktabs fragment se b(%9.3f) se(%9.3f) collabels(none) mgroups("Health Centers (km)" "Asphalt Roads" "Middle Schools (km)" "High Schools (km)", pattern(1 0 1 0 1 0 1 0) span prefix(\multicolumn{@span}{c}{) suffix(}) erepeat(\cmidrule(lr){@span})) label star(* 0.05 ** 0.01) varlabels(_cons "Constant") order(`EH_seg_co') nomtitles stats(r2 N, fmt(%9.3f %9.0g) layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}") labels(`"R-Squared"' `"Observations"' ))


eststo clear


*Sensitivity Analysis (Oster 2014); Setting rmax = 2.2 x R2 for fully controlled regressions

xi: reg health_d_distance `EH_seg_co' `controls' i.propid
psacalc delta std2_ethseg_d , rmax(0.6974) mcontrol(`EH')

xi: reg edu_c_distance `EH_seg_co' `controls' i.propid
psacalc delta std2_ethseg_d , rmax(0.71786) mcontrol(`EH')

xi: reg edu_d_distance `EH_seg_co' `controls' i.propid
psacalc delta std2_ethseg_d , rmax(0.9119) mcontrol(`EH')

xi: reg asphalt `EH_seg_co' `controls' i.propid
psacalc delta std2_ethseg_d , rmax(0.36344) mcontrol(`EH')


*** Political controls

** Include turnout (some attrition of data)


*Health Centers
areg health_d_distance `EH', a(propid) cluster(kabid)
eststo h1
areg health_d_distance `EH_seg', a(propid) cluster(kabid)
eststo h2
areg health_d_distance std2_ethfractd `controls_to', a(propid) cluster(kabid)
eststo h3
areg health_d_distance `EH' `controls_to', a(propid) cluster(kabid)
eststo h4
areg health_d_distance `EH_seg' `controls_to', a(propid) cluster(kabid)
eststo h5

*Asphalt Roads
areg asphalt `EH' , a(propid) cluster(kabid)
eststo a1
areg asphalt `EH_seg', a(propid) cluster(kabid)
eststo a2
areg asphalt std2_ethfractd `controls_to', a(propid) cluster(kabid)
eststo a3
areg asphalt `EH' `controls_to', a(propid) cluster(kabid)
eststo a4
areg asphalt `EH_seg' `controls_to', a(propid) cluster(kabid)
eststo a5


*Middle Schools

areg edu_c_distance `EH', a(propid) cluster(kabid)
eststo ms1
areg edu_c_distance `EH_seg', a(propid) cluster(kabid)
eststo ms2
areg edu_c_distance std2_ethfractd `controls_to', a(propid) cluster(kabid)
eststo ms3
areg edu_c_distance `EH' `controls_to', a(propid) cluster(kabid)
eststo ms4
areg edu_c_distance `EH_seg' `controls_to', a(propid) cluster(kabid)
eststo ms5

*High Schools
areg edu_d_distance `EH', a(propid) cluster(kabid)
eststo hs1
areg edu_d_distance `EH_seg', a(propid) cluster(kabid)
eststo hs2
areg edu_d_distance std2_ethfractd `controls_to', a(propid) cluster(kabid)
eststo hs3
areg edu_d_distance `EH' `controls_to', a(propid) cluster(kabid)
eststo hs4
areg edu_d_distance `EH_seg' `controls_to', a(propid) cluster(kabid)
eststo hs5


esttab h3 h4 h2 h5 a3 a4 a2 a5 using "$output/tso_ha_to.tex", replace booktabs fragment se b(%9.3f) se(%9.3f) collabels(none) mgroups("Health Centers (km)" "Asphalt Roads", pattern(1 0 0 0 1 0 0 0) span prefix(\multicolumn{@span}{c}{) suffix(}) erepeat(\cmidrule(lr){@span})) label star(* 0.05 ** 0.01) varlabels(_cons "Constant") order(`EH_seg') nomtitles stats(r2 N, fmt(%9.3f %9.0g) layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}") labels(`"R-Squared"' `"Observations"' ))
esttab ms3 ms4 ms2 ms5 hs3 hs4 hs2 hs5 using "$output/tso_ed_to.tex", replace booktabs fragment se b(%9.3f) se(%9.3f) collabels(none) mgroups("Middle Schools (km)" "High Schools (km)", pattern(1 0 0 0 1 0 0 0) span prefix(\multicolumn{@span}{c}{) suffix(}) erepeat(\cmidrule(lr){@span})) label star(* 0.05 ** 0.01) varlabels(_cons "Constant") order(`EH_seg') nomtitles stats(r2 N, fmt(%9.3f %9.0g) layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}") labels(`"R-Squared"' `"Observations"' )) 


eststo clear


*Sensitivity Analysis (Oster 2014); Setting rmax = 2.2 x R2 for fully controlled regressions

xi: reg health_d_distance `EH_seg' `controls_to' i.propid
xi: psacalc delta std2_ethseg_d, rmax(0.6974) mcontrol(`EH' i.propid)

xi: reg edu_c_distance `EH_seg' `controls_to' i.propid
xi: psacalc delta std2_ethseg_d, rmax(0.6985) mcontrol(`EH' i.propid)

xi: reg edu_d_distance `EH_seg' `controls_to' i.propid
xi: psacalc delta std2_ethseg_d, rmax(0.89254) mcontrol(`EH' i.propid)

xi: reg asphalt `EH_seg' `controls_to' i.propid
xi: psacalc delta std2_ethseg_d , rmax(0.35904) mcontrol(`EH' i.propid)


**** Include turnout and Golkar as top party (some attrition due to imperfect crosswalk)

*Health Centers
areg health_d_distance `EH', a(propid) cluster(kabid)
eststo h1
areg health_d_distance `EH_seg', a(propid) cluster(kabid)
eststo h2
areg health_d_distance std2_ethfractd `controls_pol', a(propid) cluster(kabid)
eststo h3
areg health_d_distance `EH' `controls_pol', a(propid) cluster(kabid)
eststo h4
areg health_d_distance `EH_seg' `controls_pol', a(propid) cluster(kabid)
eststo h5

*Asphalt Roads
areg asphalt `EH' , a(propid) cluster(kabid)
eststo a1
areg asphalt `EH_seg', a(propid) cluster(kabid)
eststo a2
areg asphalt std2_ethfractd `controls_pol', a(propid) cluster(kabid)
eststo a3
areg asphalt `EH' `controls_pol', a(propid) cluster(kabid)
eststo a4
areg asphalt `EH_seg' `controls_pol', a(propid) cluster(kabid)
eststo a5


*Middle Schools

areg edu_c_distance `EH', a(propid) cluster(kabid)
eststo ms1
areg edu_c_distance `EH_seg', a(propid) cluster(kabid)
eststo ms2
areg edu_c_distance std2_ethfractd `controls_pol', a(propid) cluster(kabid)
eststo ms3
areg edu_c_distance `EH' `controls_pol', a(propid) cluster(kabid)
eststo ms4
areg edu_c_distance `EH_seg' `controls_pol', a(propid) cluster(kabid)
eststo ms5

*High Schools
areg edu_d_distance `EH', a(propid) cluster(kabid)
eststo hs1
areg edu_d_distance `EH_seg', a(propid) cluster(kabid)
eststo hs2
areg edu_d_distance std2_ethfractd `controls_pol', a(propid) cluster(kabid)
eststo hs3
areg edu_d_distance `EH' `controls_pol', a(propid) cluster(kabid)
eststo hs4
areg edu_d_distance `EH_seg' `controls_pol', a(propid) cluster(kabid)
eststo hs5

esttab h3 h4 h2 h5 a3 a4 a2 a5 using "$output/tso_ha_pol.tex", replace booktabs fragment se b(%9.3f) se(%9.3f) collabels(none) mgroups("Health Centers (km)" "Asphalt Roads", pattern(1 0 0 0 1 0 0 0) span prefix(\multicolumn{@span}{c}{) suffix(}) erepeat(\cmidrule(lr){@span})) label star(* 0.05 ** 0.01) varlabels(_cons "Constant") order(`EH_seg') nomtitles stats(r2 N, fmt(%9.3f %9.0g) layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}") labels(`"R-Squared"' `"Observations"' ))
esttab ms3 ms4 ms2 ms5 hs3 hs4 hs2 hs5 using "$output/tso_ed_pol.tex", replace booktabs fragment se b(%9.3f) se(%9.3f) collabels(none) mgroups("Middle Schools (km)" "High Schools (km)", pattern(1 0 0 0 1 0 0 0) span prefix(\multicolumn{@span}{c}{) suffix(}) erepeat(\cmidrule(lr){@span})) label star(* 0.05 ** 0.01) varlabels(_cons "Constant") order(`EH_seg') nomtitles stats(r2 N, fmt(%9.3f %9.0g) layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}") labels(`"R-Squared"' `"Observations"' )) 

eststo clear


*Sensitivity Analysis (Oster 2014); Setting rmax = 2.2 x R2 for fully controlled regressions

xi: reg health_d_distance `EH_seg' `controls_pol' i.propid
xi: psacalc delta std2_ethseg_d, rmax(0.67958) mcontrol(`EH' i.propid)

xi: reg edu_c_distance `EH_seg' `controls_pol' i.propid
xi: psacalc delta std2_ethseg_d, rmax(0.67452) mcontrol(`EH' i.propid)

xi: reg edu_d_distance `EH_seg' `controls_pol' i.propid
xi: psacalc delta std2_ethseg_d, rmax(0.88374) mcontrol(`EH' i.propid)

xi: reg asphalt `EH_seg' `controls_pol' i.propid
xi: psacalc delta std2_ethseg_d , rmax(0.35024) mcontrol(`EH' i.propid)

****Controls for turnout and district funds


*Health Centers
areg health_d_distance `EH', a(propid) cluster(kabid)
eststo h1
areg health_d_distance `EH_seg', a(propid) cluster(kabid)
eststo h2
areg health_d_distance std2_ethfractd `controls_fd', a(propid) cluster(kabid)
eststo h3
areg health_d_distance `EH' `controls_fd', a(propid) cluster(kabid)
eststo h4
areg health_d_distance `EH_seg' `controls_fd', a(propid) cluster(kabid)
eststo h5

*Asphalt Roads
areg asphalt `EH' , a(propid) cluster(kabid)
eststo a1
areg asphalt `EH_seg', a(propid) cluster(kabid)
eststo a2
areg asphalt std2_ethfractd `controls_fd', a(propid) cluster(kabid)
eststo a3
areg asphalt `EH' `controls_fd', a(propid) cluster(kabid)
eststo a4
areg asphalt `EH_seg' `controls_fd', a(propid) cluster(kabid)
eststo a5


*Middle Schools

areg edu_c_distance `EH', a(propid) cluster(kabid)
eststo ms1
areg edu_c_distance `EH_seg', a(propid) cluster(kabid)
eststo ms2
areg edu_c_distance std2_ethfractd `controls_fd', a(propid) cluster(kabid)
eststo ms3
areg edu_c_distance `EH' `controls_fd', a(propid) cluster(kabid)
eststo ms4
areg edu_c_distance `EH_seg' `controls_fd', a(propid) cluster(kabid)
eststo ms5

*High Schools
areg edu_d_distance `EH', a(propid) cluster(kabid)
eststo hs1
areg edu_d_distance `EH_seg', a(propid) cluster(kabid)
eststo hs2
areg edu_d_distance std2_ethfractd `controls_fd', a(propid) cluster(kabid)
eststo hs3
areg edu_d_distance `EH' `controls_fd', a(propid) cluster(kabid)
eststo hs4
areg edu_d_distance `EH_seg' `controls_fd', a(propid) cluster(kabid)
eststo hs5


esttab h3 h4 h2 h5 a3 a4 a2 a5 using "$output/tso_ha_fd.tex", replace booktabs fragment se b(%9.3f) se(%9.3f) collabels(none) mgroups("Health Centers (km)" "Asphalt Roads", pattern(1 0 0 0 1 0 0 0) span prefix(\multicolumn{@span}{c}{) suffix(}) erepeat(\cmidrule(lr){@span})) label star(* 0.05 ** 0.01) varlabels(_cons "Constant") order(`EH_seg') nomtitles stats(r2 N, fmt(%9.3f %9.0g) layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}") labels(`"R-Squared"' `"Observations"' ))
esttab ms3 ms4 ms2 ms5 hs3 hs4 hs2 hs5 using "$output/tso_ed_fd.tex", replace booktabs fragment se b(%9.3f) se(%9.3f) collabels(none) mgroups("Middle Schools (km)" "High Schools (km)", pattern(1 0 0 0 1 0 0 0) span prefix(\multicolumn{@span}{c}{) suffix(}) erepeat(\cmidrule(lr){@span})) label star(* 0.05 ** 0.01) varlabels(_cons "Constant") order(`EH_seg') nomtitles stats(r2 N, fmt(%9.3f %9.0g) layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}") labels(`"R-Squared"' `"Observations"' )) 


eststo clear


*Sensitivity Analysis (Oster 2014); Setting rmax = 2.2 x R2 for fully controlled regressions

xi: reg health_d_distance `EH_seg' `controls_fd' i.propid
xi: psacalc delta std2_ethseg_d, rmax(0.64878) mcontrol(`EH' i.propid)

xi: reg edu_c_distance `EH_seg' `controls_fd' i.propid
xi: psacalc delta std2_ethseg_d, rmax(0.66352) mcontrol(`EH' i.propid)

xi: reg edu_d_distance `EH_seg' `controls_fd' i.propid
xi: psacalc delta std2_ethseg_d, rmax(0.8481) mcontrol(`EH' i.propid)

xi: reg asphalt `EH_seg' `controls_fd' i.propid
xi: psacalc delta std2_ethseg_d , rmax(0.35156) mcontrol(`EH' i.propid)

****All controls (turnout, Golkar, and district funds)


*Health Centers
areg health_d_distance `EH', a(propid) cluster(kabid)
eststo h1
areg health_d_distance `EH_seg', a(propid) cluster(kabid)
eststo h2
areg health_d_distance std2_ethfractd `controls_all', a(propid) cluster(kabid)
eststo h3
areg health_d_distance `EH' `controls_all', a(propid) cluster(kabid)
eststo h4
areg health_d_distance `EH_seg' `controls_all', a(propid) cluster(kabid)
eststo h5

*Asphalt Roads
areg asphalt `EH' , a(propid) cluster(kabid)
eststo a1
areg asphalt `EH_seg', a(propid) cluster(kabid)
eststo a2
areg asphalt std2_ethfractd `controls_all', a(propid) cluster(kabid)
eststo a3
areg asphalt `EH' `controls_all', a(propid) cluster(kabid)
eststo a4
areg asphalt `EH_seg' `controls_all', a(propid) cluster(kabid)
eststo a5


*Middle Schools

areg edu_c_distance `EH', a(propid) cluster(kabid)
eststo ms1
areg edu_c_distance `EH_seg', a(propid) cluster(kabid)
eststo ms2
areg edu_c_distance std2_ethfractd `controls_all', a(propid) cluster(kabid)
eststo ms3
areg edu_c_distance `EH' `controls_all', a(propid) cluster(kabid)
eststo ms4
areg edu_c_distance `EH_seg' `controls_all', a(propid) cluster(kabid)
eststo ms5

*High Schools
areg edu_d_distance `EH', a(propid) cluster(kabid)
eststo hs1
areg edu_d_distance `EH_seg', a(propid) cluster(kabid)
eststo hs2
areg edu_d_distance std2_ethfractd `controls_all', a(propid) cluster(kabid)
eststo hs3
areg edu_d_distance `EH' `controls_all', a(propid) cluster(kabid)
eststo hs4
areg edu_d_distance `EH_seg' `controls_all', a(propid) cluster(kabid)
eststo hs5

esttab h3 h4 h2 h5 a3 a4 a2 a5 using "$output/tso_ha_all.tex", replace booktabs fragment se b(%9.3f) se(%9.3f) collabels(none) mgroups("Health Centers (km)" "Asphalt Roads", pattern(1 0 0 0 1 0 0 0) span prefix(\multicolumn{@span}{c}{) suffix(}) erepeat(\cmidrule(lr){@span})) label star(* 0.05 ** 0.01) varlabels(_cons "Constant") order(`EH_seg') nomtitles stats(r2 N, fmt(%9.3f %9.0g) layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}") labels(`"R-Squared"' `"Observations"' ))
esttab ms3 ms4 ms2 ms5 hs3 hs4 hs2 hs5 using "$output/tso_ed_all.tex", replace booktabs fragment se b(%9.3f) se(%9.3f) collabels(none) mgroups("Middle Schools (km)" "High Schools (km)", pattern(1 0 0 0 1 0 0 0) span prefix(\multicolumn{@span}{c}{) suffix(}) erepeat(\cmidrule(lr){@span})) label star(* 0.05 ** 0.01) varlabels(_cons "Constant") order(`EH_seg') nomtitles stats(r2 N, fmt(%9.3f %9.0g) layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}") labels(`"R-Squared"' `"Observations"' )) 


eststo clear


*Sensitivity Analysis (Oster 2014); Setting rmax = 2.2 x R2 for fully controlled regressions

xi: reg health_d_distance `EH_seg' `controls_all' i.propid
xi: psacalc delta std2_ethseg_d, rmax(0.62568) mcontrol(`EH' i.propid)

xi: reg edu_c_distance `EH_seg' `controls_all' i.propid
xi: psacalc delta std2_ethseg_d, rmax(0.62106) mcontrol(`EH' i.propid)

xi: reg edu_d_distance `EH_seg' `controls_all' i.propid
xi: psacalc delta std2_ethseg_d, rmax(0.8272) mcontrol(`EH' i.propid)

xi: reg asphalt `EH_seg' `controls_all' i.propid
xi: psacalc delta std2_ethseg_d , rmax(0.34342) mcontrol(`EH' i.propid)



**** Include interaction between district and segregation

*Health Centers
areg health_d_distance `EH', a(propid) cluster(kabid)
eststo h1
areg health_d_distance `EH_segx', a(propid) cluster(kabid)
eststo h2
areg health_d_distance std2_ethfractd `controls', a(propid) cluster(kabid)
eststo h3
areg health_d_distance `EH' `controls', a(propid) cluster(kabid)
eststo h4
areg health_d_distance `EH_segx' `controls', a(propid) cluster(kabid)
eststo h5

*Asphalt Roads
areg asphalt `EH' , a(propid) cluster(kabid)
eststo a1
areg asphalt `EH_segx', a(propid) cluster(kabid)
eststo a2
areg asphalt std2_ethfractd `controls', a(propid) cluster(kabid)
eststo a3
areg asphalt `EH' `controls', a(propid) cluster(kabid)
eststo a4
areg asphalt `EH_segx' `controls', a(propid) cluster(kabid)
eststo a5


*Middle Schools

areg edu_c_distance `EH', a(propid) cluster(kabid)
eststo ms1
areg edu_c_distance `EH_segx', a(propid) cluster(kabid)
eststo ms2
areg edu_c_distance std2_ethfractd `controls', a(propid) cluster(kabid)
eststo ms3
areg edu_c_distance `EH' `controls', a(propid) cluster(kabid)
eststo ms4
areg edu_c_distance `EH_segx' `controls', a(propid) cluster(kabid)
eststo ms5

*High Schools
areg edu_d_distance `EH', a(propid) cluster(kabid)
eststo hs1
areg edu_d_distance `EH_segx', a(propid) cluster(kabid)
eststo hs2
areg edu_d_distance std2_ethfractd `controls', a(propid) cluster(kabid)
eststo hs3
areg edu_d_distance `EH' `controls', a(propid) cluster(kabid)
eststo hs4
areg edu_d_distance `EH_segx' `controls', a(propid) cluster(kabid)
eststo hs5


esttab h3 h4 h2 h5 a3 a4 a2 a5 using "$output/tso_hax.tex", replace booktabs fragment se b(%9.3f) se(%9.3f) collabels(none) mgroups("Health Centers (km)" "Asphalt Roads", pattern(1 0 0 0 1 0 0 0) span prefix(\multicolumn{@span}{c}{) suffix(}) erepeat(\cmidrule(lr){@span})) label star(* 0.05 ** 0.01) varlabels(_cons "Constant") order(`EH_segx') nomtitles stats(r2 N, fmt(%9.3f %9.0g) layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}") labels(`"R-Squared"' `"Observations"' ))
esttab ms3 ms4 ms2 ms5 hs3 hs4 hs2 hs5 using "$output/tso_edx.tex", replace booktabs fragment se b(%9.3f) se(%9.3f) collabels(none) mgroups("Middle Schools (km)" "High Schools (km)", pattern(1 0 0 0 1 0 0 0) span prefix(\multicolumn{@span}{c}{) suffix(}) erepeat(\cmidrule(lr){@span})) label star(* 0.05 ** 0.01) varlabels(_cons "Constant") order(`EH_segx') nomtitles stats(r2 N, fmt(%9.3f %9.0g) layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}") labels(`"R-Squared"' `"Observations"' )) 

eststo clear


*Sensitivity Analysis (Oster 2014); Setting rmax = 2.2 x R2 for fully controlled regressions

xi: reg health_d_distance `EH_segx' `controls' i.propid
xi: psacalc delta std2_nc_es_area_d, rmax(0.70532) mcontrol(`EH_seg' i.propid)

xi: reg edu_c_distance `EH_segx' `controls' i.propid
xi: psacalc delta std2_nc_es_area_d, rmax(0.72886) mcontrol(`EH_seg' i.propid)

xi: reg edu_d_distance `EH_segx' `controls' i.propid
xi: psacalc delta std2_nc_es_area_d, rmax(0.92598) mcontrol(`EH_seg' i.propid)

xi: reg asphalt `EH_segx' `controls' i.propid
xi: psacalc delta std2_nc_es_area_d , rmax(0.3674) mcontrol(`EH_seg' i.propid)

***EFD only as canonical regressions

*Health Centers
areg health_d_distance std2_ethfractd, a(propid) cluster(kabid)
eststo h1
areg health_d_distance std2_ethfractd `controls', a(propid) cluster(kabid)
eststo h2

*Asphalt Roads
areg asphalt std2_ethfractd, a(propid) cluster(kabid)
eststo a1
areg asphalt std2_ethfractd `controls', a(propid) cluster(kabid)
eststo a2

*Middle Schools

areg edu_c_distance std2_ethfractd, a(propid) cluster(kabid)
eststo ms1
areg edu_c_distance std2_ethfractd `controls', a(propid) cluster(kabid)
eststo ms2

*High Schools
areg edu_d_distance std2_ethfractd, a(propid) cluster(kabid)
eststo hs1
areg edu_d_distance std2_ethfractd `controls', a(propid) cluster(kabid)
eststo hs2

esttab h1 h2 a1 a2 ms1 ms2 hs1 hs2 using "$output/tso_EFD.tex", replace booktabs fragment se b(%9.3f) se(%9.3f) collabels(none) mgroups("Health Centers (km)" "Asphalt Roads" "Middle Schools (km)" "High Schools (km)", pattern(1 0 1 0 1 0 1 0) span prefix(\multicolumn{@span}{c}{) suffix(}) erepeat(\cmidrule(lr){@span})) label star(* 0.05 ** 0.01) varlabels(_cons "Constant") order(std2_ethfractd) nomtitles stats(r2 N, fmt(%9.3f %9.0g) layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}") labels(`"R-Squared"' `"Observations"' )) 

eststo clear


****Religious Heterogeneity Analysis

*Health Centers
areg health_d_distance `RH', a(propid) cluster(kabid)
eststo h1
areg health_d_distance `RH_seg', a(propid) cluster(kabid)
eststo h2
areg health_d_distance std2_relfractd `controls', a(propid) cluster(kabid)
eststo h3
areg health_d_distance `RH' `controls', a(propid) cluster(kabid)
eststo h4
areg health_d_distance `RH_seg' `controls', a(propid) cluster(kabid)
eststo h5

*Asphalt Roads
areg asphalt `RH' , a(propid) cluster(kabid)
eststo a1
areg asphalt `RH_seg', a(propid) cluster(kabid)
eststo a2
areg asphalt std2_relfractd `controls', a(propid) cluster(kabid)
eststo a3
areg asphalt `RH' `controls', a(propid) cluster(kabid)
eststo a4
areg asphalt `RH_seg' `controls', a(propid) cluster(kabid)
eststo a5


*Middle Schools

areg edu_c_distance `RH', a(propid) cluster(kabid)
eststo ms1
areg edu_c_distance `RH_seg', a(propid) cluster(kabid)
eststo ms2
areg edu_c_distance std2_relfractd `controls', a(propid) cluster(kabid)
eststo ms3
areg edu_c_distance `RH' `controls', a(propid) cluster(kabid)
eststo ms4
areg edu_c_distance `RH_seg' `controls', a(propid) cluster(kabid)
eststo ms5

*High Schools
areg edu_d_distance `RH', a(propid) cluster(kabid)
eststo hs1
areg edu_d_distance `RH_seg', a(propid) cluster(kabid)
eststo hs2
areg edu_d_distance std2_relfractd `controls', a(propid) cluster(kabid)
eststo hs3
areg edu_d_distance `RH' `controls', a(propid) cluster(kabid)
eststo hs4
areg edu_d_distance `RH_seg' `controls', a(propid) cluster(kabid)
eststo hs5

esttab h3 h4 h2 h5 a3 a4 a2 a5 using "$output/tso_ha_rel.tex", replace booktabs fragment se b(%9.3f) se(%9.3f) collabels(none) mgroups("Health Centers (km)" "Asphalt Roads", pattern(1 0 0 0 1 0 0 0) span prefix(\multicolumn{@span}{c}{) suffix(}) erepeat(\cmidrule(lr){@span})) label star(* 0.05 ** 0.01) varlabels(_cons "Constant") order(`EH_seg') nomtitles stats(r2 N, fmt(%9.3f %9.0g) layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}") labels(`"R-Squared"' `"Observations"' )) 
esttab ms3 ms4 ms2 ms5 hs3 hs4 hs2 hs5 using "$output/tso_ed_rel.tex", replace booktabs fragment se b(%9.3f) se(%9.3f) collabels(none) mgroups("Middle Schools (km)" "High Schools (km)", pattern(1 0 0 0 1 0 0 0) span prefix(\multicolumn{@span}{c}{) suffix(}) erepeat(\cmidrule(lr){@span})) label star(* 0.05 ** 0.01) varlabels(_cons "Constant") order(`EH_seg') nomtitles stats(r2 N, fmt(%9.3f %9.0g) layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}") labels(`"R-Squared"' `"Observations"' )) 

eststo clear


restore

** Excluding Majority Javanese or Balinese Villages Outside of Java & Bali
preserve
keep if mn_lurah_d_dc!=10 & jb50_off_jb_v==0

*Health Centers
areg health_d_distance `EH', a(propid) cluster(kabid)
eststo h1
areg health_d_distance `EH_seg', a(propid) cluster(kabid)
eststo h2
areg health_d_distance std2_ethfractd `controls', a(propid) cluster(kabid)
eststo h3
areg health_d_distance `EH' `controls', a(propid) cluster(kabid)
eststo h4
areg health_d_distance `EH_seg' `controls', a(propid) cluster(kabid)
eststo h5

*Asphalt Roads
areg asphalt `EH' , a(propid) cluster(kabid)
eststo a1
areg asphalt `EH_seg', a(propid) cluster(kabid)
eststo a2
areg asphalt std2_ethfractd `controls', a(propid) cluster(kabid)
eststo a3
areg asphalt `EH' `controls', a(propid) cluster(kabid)
eststo a4
areg asphalt `EH_seg' `controls', a(propid) cluster(kabid)
eststo a5


*Middle Schools

areg edu_c_distance `EH', a(propid) cluster(kabid)
eststo ms1
areg edu_c_distance `EH_seg', a(propid) cluster(kabid)
eststo ms2
areg edu_c_distance std2_ethfractd `controls', a(propid) cluster(kabid)
eststo ms3
areg edu_c_distance `EH' `controls', a(propid) cluster(kabid)
eststo ms4
areg edu_c_distance `EH_seg' `controls', a(propid) cluster(kabid)
eststo ms5

*High Schools
areg edu_d_distance `EH', a(propid) cluster(kabid)
eststo hs1
areg edu_d_distance `EH_seg', a(propid) cluster(kabid)
eststo hs2
areg edu_d_distance std2_ethfractd `controls', a(propid) cluster(kabid)
eststo hs3
areg edu_d_distance `EH' `controls', a(propid) cluster(kabid)
eststo hs4
areg edu_d_distance `EH_seg' `controls', a(propid) cluster(kabid)
eststo hs5

esttab h3 h4 h2 h5 a3 a4 a2 a5 using "$output/tso_notm_ha.tex", replace booktabs fragment se b(%9.3f) se(%9.3f) collabels(none) mgroups("Health Centers (km)" "Asphalt Roads", pattern(1 0 0 0 1 0 0 0) span prefix(\multicolumn{@span}{c}{) suffix(}) erepeat(\cmidrule(lr){@span})) label star(* 0.05 ** 0.01) varlabels(_cons "Constant") order(`EH_seg') nomtitles stats(r2 N, fmt(%9.3f %9.0g) layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}") labels(`"R-Squared"' `"Observations"' ))
esttab ms3 ms4 ms2 ms5 hs3 hs4 hs2 hs5 using "$output/tso_notm_ed.tex", replace booktabs fragment se b(%9.3f) se(%9.3f) collabels(none) mgroups("Middle Schools (km)" "High Schools (km)", pattern(1 0 0 0 1 0 0 0) span prefix(\multicolumn{@span}{c}{) suffix(}) erepeat(\cmidrule(lr){@span})) label star(* 0.05 ** 0.01) varlabels(_cons "Constant") order(`EH_seg') nomtitles stats(r2 N, fmt(%9.3f %9.0g) layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}") labels(`"R-Squared"' `"Observations"' ))
esttab ms3 ms4 hs3 hs4 h3 h4 a3 a4 using "$output/tso_notm.tex", replace booktabs fragment se b(%9.3f) se(%9.3f) collabels(none) mgroups("Health Centers (km)" "Asphalt Roads" "Middle Schools (km)" "High Schools (km)", pattern(1 0 1 0 1 0 1 0) span prefix(\multicolumn{@span}{c}{) suffix(}) erepeat(\cmidrule(lr){@span})) label star(* 0.05 ** 0.01) varlabels(_cons "Constant") order(`EH_seg_co') nomtitles stats(r2 N, fmt(%9.3f %9.0g) layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}") labels(`"R-Squared"' `"Observations"' ))


eststo clear


*Sensitivity Analysis (Oster 2014); Setting rmax = 2.2 x R2 for fully controlled regressions

xi: reg health_d_distance `EH_seg' `controls' i.propid
psacalc delta std2_ethseg_d , rmax(0.72798) mcontrol(`EH')

xi: reg edu_c_distance `EH_seg' `controls' i.propid
psacalc delta std2_ethseg_d , rmax(0.73788) mcontrol(`EH')

xi: reg edu_d_distance `EH_seg' `controls' i.propid
psacalc delta std2_ethseg_d , rmax(0.93324) mcontrol(`EH')

xi: reg asphalt `EH_seg' `controls' i.propid
psacalc delta std2_ethseg_d , rmax(0.36322) mcontrol(`EH')

**** Excluding transmigration districts

restore
preserve

keep if mn_lurah_d_dc!=10 & trans_kab==0

*Kelurahan as measure of urbanization with Control for mn_lurah_d

*Health Centers
areg health_d_distance `EH', a(propid) cluster(kabid)
eststo h1
areg health_d_distance `EH_seg', a(propid) cluster(kabid)
eststo h2
areg health_d_distance std2_ethfractd `controls', a(propid) cluster(kabid)
eststo h3
areg health_d_distance `EH' `controls', a(propid) cluster(kabid)
eststo h4
areg health_d_distance `EH_seg' `controls', a(propid) cluster(kabid)
eststo h5

*Asphalt Roads
areg asphalt `EH' , a(propid) cluster(kabid)
eststo a1
areg asphalt `EH_seg', a(propid) cluster(kabid)
eststo a2
areg asphalt std2_ethfractd `controls', a(propid) cluster(kabid)
eststo a3
areg asphalt `EH' `controls', a(propid) cluster(kabid)
eststo a4
areg asphalt `EH_seg' `controls', a(propid) cluster(kabid)
eststo a5

*Middle Schools

areg edu_c_distance `EH', a(propid) cluster(kabid)
eststo ms1
areg edu_c_distance `EH_seg', a(propid) cluster(kabid)
eststo ms2
areg edu_c_distance std2_ethfractd `controls', a(propid) cluster(kabid)
eststo ms3
areg edu_c_distance `EH' `controls', a(propid) cluster(kabid)
eststo ms4
areg edu_c_distance `EH_seg' `controls', a(propid) cluster(kabid)
eststo ms5

*High Schools
areg edu_d_distance `EH', a(propid) cluster(kabid)
eststo hs1
areg edu_d_distance `EH_seg', a(propid) cluster(kabid)
eststo hs2
areg edu_d_distance std2_ethfractd `controls', a(propid) cluster(kabid)
eststo hs3
areg edu_d_distance `EH' `controls', a(propid) cluster(kabid)
eststo hs4
areg edu_d_distance `EH_seg' `controls', a(propid) cluster(kabid)
eststo hs5

esttab h3 h4 h5 a3 a4 a5 using "$output/tso_trkab_ha.tex", replace booktabs fragment se b(%9.3f) se(%9.3f) collabels(none) mgroups("Health Centers (km)" "Asphalt Roads", pattern(1 0 0 1 0 0) span prefix(\multicolumn{@span}{c}{) suffix(}) erepeat(\cmidrule(lr){@span})) label star(* 0.05 ** 0.01) varlabels(_cons "Constant") order(`EH_seg') nomtitles stats(r2 N, fmt(%9.3f %9.0g) layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}") labels(`"R-Squared"' `"Observations"' ))
esttab ms3 ms4 ms5 hs3 hs4 hs5 using "$output/tso_trkab_ed.tex", replace booktabs fragment se b(%9.3f) se(%9.3f) collabels(none) mgroups("Middle Schools (km)" "High Schools (km)", pattern(1 0 0 1 0 0) span prefix(\multicolumn{@span}{c}{) suffix(}) erepeat(\cmidrule(lr){@span})) label star(* 0.05 ** 0.01) varlabels(_cons "Constant") order(`EH_seg') nomtitles stats(r2 N, fmt(%9.3f %9.0g) layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}") labels(`"R-Squared"' `"Observations"' ))
esttab ms3 ms4 hs3 hs4 h3 h4 a3 a4 using "$output/tso_trkab.tex", replace booktabs fragment se b(%9.3f) se(%9.3f) collabels(none) mgroups("Health Centers (km)" "Asphalt Roads" "Middle Schools (km)" "High Schools (km)", pattern(1 0 1 0 1 0 1 0) span prefix(\multicolumn{@span}{c}{) suffix(}) erepeat(\cmidrule(lr){@span})) label star(* 0.05 ** 0.01) varlabels(_cons "Constant") order(`EH_seg_co') nomtitles stats(r2 N, fmt(%9.3f %9.0g) layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}") labels(`"R-Squared"' `"Observations"' ))



eststo clear


*Sensitivity Analysis (Oster 2014); Setting rmax = 2.2 x R2 for fully controlled regressions

xi: reg health_d_distance `EH_seg' `controls' i.propid
psacalc delta std2_ethseg_d , rmax(0.71742) mcontrol(`EH')

xi: reg edu_c_distance `EH_seg' `controls' i.propid
psacalc delta std2_ethseg_d , rmax(0.5841) mcontrol(`EH')


xi: reg edu_d_distance `EH_seg' `controls' i.propid
psacalc delta std2_ethseg_d , rmax(0.83116) mcontrol(`EH')

xi: reg asphalt `EH_seg' `controls' i.propid
psacalc delta std2_ethseg_d , rmax(0.29084) mcontrol(`EH')


restore


**Same as main analysis but using mean EFV of other villages in district instead of segregation

****EXCLUDING TOP DECILE****
preserve
keep if mn_lurah_d_dc!=10

**Kelurahan as measure of urbanization with Control for mn_lurah_d

*Health Centers
areg health_d_distance `EH', a(propid) cluster(kabid)
eststo h1
areg health_d_distance `EH_mnefv', a(propid) cluster(kabid)
eststo h2
areg health_d_distance std2_ethfractd `controls', a(propid) cluster(kabid)
eststo h3
areg health_d_distance `EH' `controls', a(propid) cluster(kabid)
eststo h4
areg health_d_distance `EH_mnefv' `controls', a(propid) cluster(kabid)
eststo h5

*Asphalt Roads
areg asphalt `EH' , a(propid) cluster(kabid)
eststo a1
areg asphalt `EH_mnefv', a(propid) cluster(kabid)
eststo a2
areg asphalt std2_ethfractd `controls', a(propid) cluster(kabid)
eststo a3
areg asphalt `EH' `controls', a(propid) cluster(kabid)
eststo a4
areg asphalt `EH_mnefv' `controls', a(propid) cluster(kabid)
eststo a5


*Middle Schools

areg edu_c_distance `EH', a(propid) cluster(kabid)
eststo ms1
areg edu_c_distance `EH_mnefv', a(propid) cluster(kabid)
eststo ms2
areg edu_c_distance std2_ethfractd `controls', a(propid) cluster(kabid)
eststo ms3
areg edu_c_distance `EH' `controls', a(propid) cluster(kabid)
eststo ms4
areg edu_c_distance `EH_mnefv' `controls', a(propid) cluster(kabid)
eststo ms5

*High Schools
areg edu_d_distance `EH', a(propid) cluster(kabid)
eststo hs1
areg edu_d_distance `EH_mnefv', a(propid) cluster(kabid)
eststo hs2
areg edu_d_distance std2_ethfractd `controls', a(propid) cluster(kabid)
eststo hs3
areg edu_d_distance `EH' `controls', a(propid) cluster(kabid)
eststo hs4
areg edu_d_distance `EH_mnefv' `controls', a(propid) cluster(kabid)
eststo hs5

esttab h3 h4 h2 h5 a3 a4 a2 a5 using "$output/tso_ha_mnefv.tex", replace booktabs fragment se b(%9.3f) se(%9.3f) collabels(none) mgroups("Health Centers (km)" "Asphalt Roads", pattern(1 0 0 0 1 0 0 0) span prefix(\multicolumn{@span}{c}{) suffix(}) erepeat(\cmidrule(lr){@span})) label star(* 0.05 ** 0.01) varlabels(_cons "Constant") order(`EH_mnefv') nomtitles stats(r2 N, fmt(%9.3f %9.0g) layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}") labels(`"R-Squared"' `"Observations"' ))
esttab ms3 ms4 ms2 ms5 hs3 hs4 hs2 hs5 using "$output/tso_ed_mnefv.tex", replace booktabs fragment se b(%9.3f) se(%9.3f) collabels(none) mgroups("Middle Schools (km)" "High Schools (km)", pattern(1 0 0 0 1 0 0 0) span prefix(\multicolumn{@span}{c}{) suffix(}) erepeat(\cmidrule(lr){@span})) label star(* 0.05 ** 0.01) varlabels(_cons "Constant") order(`EH_mnefv') nomtitles stats(r2 N, fmt(%9.3f %9.0g) layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}") labels(`"R-Squared"' `"Observations"' )) 


eststo clear





log close


