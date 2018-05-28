* Merge podes & Crosswalks
clear

* Set working directory depending on user. Comment out the other directory name
global working "~/Documents/working folder/Hetero Public Goods/Data & Analysis/Analysis"

* Set project directory depending on user. Comment out the other directory name
global project "~/Dropbox/Heterogeneity & Public Goods"

* Set project directory depending on user. Comment out the other directory name
global project2 "~/Dropbox/Risk Indo Data"

* Set census directory
global census_dir "~/Dropbox/Heterogeneity & Public Goods/Regressions"

* Set bpscode directory depending on user. Comment out the other directory name
global bpscode "~/Dropbox/Heterogeneity & Public Goods/Data/BPS Codes"





cd "$working"
set more off

use "$project/Data/Crosswalks/From Sam Bazzi/MFDpanelBPS98to13.dta", clear
keep id1999 id2000 id2002 id2003 nm2000
tostring id1999 id2000 id2002 id2003,replace

foreach y in 1999 2000 2002 2003 {
	gen _prop`y' = substr(id`y',1,2)	
	gen _kab`y' = substr(id`y',3,2)
	gen _kec`y' = substr(id`y',5,3)
	gen _desa`y' = substr(id`y',8,3)
}

renpfix _

destring prop* kab* kec* desa*, replace
drop if id2000=="."
duplicates drop id1999, force
sort id1999
save xwalk1999_2000_2003, replace

* PODES 2000


use "$project2/Podes/Podes2000/podes2000_rand.dta", clear
gen id1999=prop+kab+kec+desa
drop if id1999==""
drop _merge
sort id1999
save podes2000_rand, replace

* Fix split provinces (prop 19, 36, 75)
use podes2000_rand, clear
keep if prop=="16" | prop=="32" | prop=="71"
sort id1999
merge 1:1 id1999 using xwalk1999_2000_2003
keep if _merge==3
g fixed_prov=0
replace fixed_prov=1 if _merge==3
drop _merge
save temp, replace

use xwalk1999_2000_2003, clear
sort id2000
save xwalk1999_2000_2003, replace

use podes2000_rand, clear
drop if prop=="16" | prop=="32" | prop=="71"
gen id2000=id1999
append using temp
destring prop kab kec desa, replace
replace prop=prop2000 if prop2000==19 | prop2000==36 | prop2000==75
replace kab=kab2000 if prop2000==19 | prop2000==36 | prop2000==75
replace kec=kec2000 if prop2000==19 | prop2000==36 | prop2000==75
replace desa=desa2000 if prop2000==19 | prop2000==36 | prop2000==75
drop prop1999 prop2000 kab1999 kab2000 kec1999 kec2000 desa1999 desa2000

gen propid=prop
gen kabid=prop*100+kab
gen kecid=kabid*1000+kec
tostring prop kab kec desa, replace



sort id2000
save podes2000_matched, replace

* I. Village characteristics
use podes2000_matched, clear
gen pop=b4ar2a
gen area=b10a
gen major_agr=b4ar6a
destring major_agr, replace
replace major_agr=0 if major_agr~=1

gen tot_HH=b4ar2b
gen tot_poorHH=b8r5
gen tot_hcHH=b8r6
gen perc_poorHH=tot_poorHH/tot_HH
gen perc_hcHH=tot_hcHH/tot_HH

bysort kabid: egen tot_poorHH_d=total(tot_poorHH)
bysort kabid: egen tot_HH_d=total(tot_HH)
g perc_poorHH_d=tot_poorHH_d/tot_HH_d



* Status
destring b3r*, replace

g urban=drh==1
g kelurahan=b3r3==2

* Geography
g hilly=1 if b3r10==2
replace hilly=0 if b3r10==1
g coast=1 if b3r9==1
replace coast=0 if b3r9!=1
g valley_river=1 if b3r9==2
replace valley_river=0 if b3r9!=2
g hilly_int=1 if b3r9==3
replace hilly_int=0 if b3r9!=3
g flat_int=1 if b3r9==4
replace flat_int=0 if b3r9!=4

* Distance to Subdistrict and District Offices
g dist_sd=b3r12
g dist_d=b3r13

* II. Access to health facilities
replace b8r1b4="0" if b8r1b4~="1" & b8r1b4~="2" & b8r1b4~="3" & b8r1b4~="4" & b8r1b4~="0"
replace b8r1f4="0" if b8r1f4~="1" & b8r1f4~="2" & b8r1f4~="3" & b8r1f4~="4" & b8r1f4~="0"
replace b8r1g4="0" if b8r1g4~="1" & b8r1g4~="2" & b8r1g4~="3" & b8r1g4~="4" & b8r1g4~="0"
replace b8r1m4="0" if b8r1m4~="1" & b8r1m4~="2" & b8r1m4~="3" & b8r1m4~="4" & b8r1m4~="0"


destring b8r1*, replace
replace b8r1a4=0 if b8r1a4==.
replace b8r1b4=0 if b8r1b4==.
replace b8r1c4=0 if b8r1c4==.
replace b8r1d4=0 if b8r1d4==.
replace b8r1e4=0 if b8r1e4==.
replace b8r1f4=0 if b8r1f4==.
replace b8r1g4=0 if b8r1g4==.
replace b8r1h4=0 if b8r1h4==.
replace b8r1i4=0 if b8r1i4==.
replace b8r1j4=0 if b8r1j4==.
replace b8r1k4=0 if b8r1k4==.
replace b8r1l4=0 if b8r1l4==.
replace b8r1m4=0 if b8r1m4==.
replace b8r1n4=0 if b8r1n4==.

* Number of health facilities
gen health_a_number=b8r1a2
gen health_b_number=b8r1b2
gen health_d_number=b8r1e2
gen health_e_number=b8r1f2

* Number of health facilities in subdistrict and district
bysort prop kab kec: egen health_tot_a_sd=total(health_a_number)
bysort prop kab kec: egen health_tot_b_sd=total(health_b_number)
bysort prop kab kec: egen health_tot_d_sd=total(health_d_number)
bysort prop kab kec: egen health_tot_e_sd=total(health_e_number)

bysort prop kab: egen health_tot_a_d=total(health_a_number)
bysort prop kab: egen health_tot_b_d=total(health_b_number)
bysort prop kab: egen health_tot_d_d=total(health_d_number)
bysort prop kab: egen health_tot_e_d=total(health_e_number)

* Distance from village
gen health_a_distance=0
replace health_a_distance=b8r1a3 if b8r1a2==0
gen health_b_distance=0
replace health_b_distance=min(b8r1b3, b8r1c3) if b8r1b2==0 & b8r1c2==0
gen health_c_distance=0
replace health_c_distance=b8r1d3 if b8r1d2==0
gen health_d_distance=0
replace health_d_distance=b8r1e3 if b8r1e2==0
gen health_e_distance=0
replace health_e_distance=b8r1f3 if b8r1f2==0
gen health_f_distance=0
replace health_f_distance=b8r1h3 if b8r1h2==0
gen health_g_distance=0
replace health_g_distance=b8r1i3 if b8r1i2==0
gen health_h_distance=0
replace health_h_distance=b8r1j3 if b8r1j2==0
gen health_i_distance=0
replace health_i_distance=b8r1k3 if b8r1k2==0
gen health_j_distance=0
replace health_j_distance=b8r1l3 if b8r1l2==0
gen health_k_distance=0
replace health_k_distance=b8r1m3 if b8r1m2==0
gen health_l_distance=0
replace health_l_distance=b8r1n3 if b8r1n2==0

* Ease of access
gen health_a_easy=0
replace health_a_easy=b8r1a4 if b8r1a2==0
gen health_b_easy=0
replace health_b_distance=min(b8r1b4, b8r1c4) if b8r1b2==0 & b8r1c2==0
gen health_c_easy=0
replace health_c_easy=b8r1d4 if b8r1d2==0
gen health_d_easy=0
replace health_d_easy=b8r1e4 if b8r1e2==0
gen health_e_easy=0
replace health_e_easy=b8r1f4 if b8r1f2==0
gen health_f_easy=0
replace health_f_easy=b8r1h4 if b8r1h2==0
gen health_g_easy=0
replace health_g_easy=b8r1i4 if b8r1i2==0
gen health_h_easy=0
replace health_h_easy=b8r1j4 if b8r1j2==0
gen health_i_easy=0
replace health_i_easy=b8r1k4 if b8r1k2==0
gen health_j_easy=0
replace health_j_easy=b8r1l4 if b8r1l2==0
gen health_k_easy=0
replace health_k_easy=b8r1m4 if b8r1m2==0
gen health_l_easy=0
replace health_l_easy=b8r1n4 if b8r1n2==0



* III. Education
* Number of school, state-owned and private
gen edu_a_number_state=b5r1a2
gen edu_b_number_state=b5r1b2
gen edu_c_number_state=b5r1c2
gen edu_d_number_state=b5r1d2
gen edu_e_number_state=b5r1e2
gen edu_f_number_state=b5r1f2

gen edu_a_number_priv=b5r1a3
gen edu_b_number_priv=b5r1b3
gen edu_c_number_priv=b5r1c3
gen edu_d_number_priv=b5r1d3
gen edu_e_number_priv=b5r1e3
gen edu_f_number_priv=b5r1f3
gen edu_g_number_priv=b5r1g3
gen edu_h_number_priv=b5r1h3
gen edu_i_number_priv=b5r1i3

* Distance (km) to school
gen edu_a_distance=b5r1a4
gen edu_b_distance=b5r1b4
gen edu_c_distance=b5r1c4
gen edu_d_distance=b5r1d4
gen edu_e_distance=.

replace edu_a_distance=0 if edu_a_number_state>0 | edu_a_number_priv>0
replace edu_b_distance=0 if edu_b_number_state>0 | edu_b_number_priv>0
replace edu_c_distance=0 if edu_c_number_state>0 | edu_c_number_priv>0
replace edu_d_distance=0 if edu_d_number_state>0 | edu_d_number_priv>0
replace edu_e_distance=0 if edu_e_number_state>0 | edu_e_number_priv>0

* Availability of skilled educational institution
destring b5r2*, replace
gen edu_skill_inst=1 if b5r2a==1 | b5r2b==3 | b5r2c==5 | b5r2d==7 | b5r2e==1 | b5r2f==3 | b5r2g==5 | b5r2h==7 | b5r2i==1 | b5r2j==3 | b5r2k==5 | b5r2l==7
replace edu_skill_inst=0 if edu_skill_inst==.

* Number of schools in subdistrict and district
bysort prop kab kec: egen edu_tot_ps_sd=total(edu_b_number_state)
bysort prop kab kec: egen edu_tot_ms_sd=total(edu_c_number_state)
bysort prop kab kec: egen edu_tot_hs_sd=total(edu_d_number_state)
bysort prop kab: egen edu_tot_ps_d=total(edu_b_number_state)
bysort prop kab: egen edu_tot_ms_d=total(edu_c_number_state)
bysort prop kab: egen edu_tot_hs_d=total(edu_d_number_state)

bysort prop kab kec: egen edu_tot_priv_ps_sd=total(edu_b_number_priv)
bysort prop kab kec: egen edu_tot_priv_ms_sd=total(edu_c_number_priv)
bysort prop kab kec: egen edu_tot_priv_hs_sd=total(edu_d_number_priv)
bysort prop kab: egen edu_tot_priv_ps_d=total(edu_b_number_priv)
bysort prop kab: egen edu_tot_priv_ms_d=total(edu_c_number_priv)
bysort prop kab: egen edu_tot_priv_hs_d=total(edu_d_number_priv)


* Population of subdistrict and district surveyed in PODES
bysort prop kab kec: egen pop_sd=total(pop)
bysort prop kab: egen pop_d=total(pop)

* Roads

g asphalt=b9ar1b1=="1"
g asph_stone=b9ar1b1=="1"|b9ar1b1=="2"

* Water Sources
replace b8r8a="0" if b8r8a~="1" & b8r8a~="2" & b8r8a~="3" & b8r8a~="4" & b8r8a~="0"
destring b8r8a, replace
g dev_water_drink=0
replace dev_water_drink=1 if b8r8a<=4

g water_service=0
replace water_service=1 if b8r8a==1

* Informal collective action
g gotong=b6r2b2k2=="1"
g arisan=b6r2b1k2=="1"

* District Average Public Goods
bysort kabid: egen mn_dhc_d=mean(health_d_distance)
bysort kabid: egen mn_dms_d=mean(edu_c_distance)
bysort kabid: egen mn_dhs_d=mean(edu_d_distance)
bysort kabid: egen mn_asp_d=mean(asphalt)
bysort kabid: egen mn_urb_d=mean(urban)
bysort kabid: egen mn_lurah_d=mean(kelurahan)

bysort kabid: egen tot_area_d=total(area)
replace tot_area_d=tot_area_d/1000
g pop_dens_d=pop_d/tot_area_d




*keep perm* health_* pop* area major_agr edu* urban kelurahan hilly coast valley_river hilly_int flat_int dist_sd dist_d gotong arisan tot* perc*
save podes2000_temp, replace


* Heterogeneity
use "$census_dir/censclean2.dta", clear
ren villageid id2000

gen logvillpop=log(popv)
gen logsdpop=log(popsd)
gen logdpop=log(popd)
*Segregation

***District Segregation Measures
g wethseg_vil=popv/popd*(1-ethfractvil/ethfractd)

* District ethnic segregation measure
bysort kabid: egen ethseg_d=total(wethseg_vil)

* Weighted religious segregation inside summation to be used for district segregation measure
g wrelseg_vil=popv/popd*(1-relfractvil/relfractd)

* District religious segregation measure
bysort kabid: egen relseg_d=total(wrelseg_vil)


**Interdependence measure

g popvefv=popv*ethfractvil/popd
bysort kabid: egen popvefv_tot=total(popvefv)
g mn_efv_other=popvefv_tot-popvefv

g popvefvsd=popv*ethfractvil/popsd
bysort kecid: egen popvefv_totsd=total(popvefvsd)
g mn_efv_othersd=popvefv_totsd-popvefvsd


***Subdistrict Segregation Measures
* Weighted ethnic segregation inside summation to be used for subdistrict segregation measure
g wethseg_sdv=popv/popsd*(1-ethfractvil/ethfractsd)

* Subdistrict ethnic segregation measure
bysort kecid: egen ethseg_sd=total(wethseg_sdv)

* Weighted religious segregation inside summation to be used for subdistrict segregation measure
g wrelseg_sdv=popv/popsd*(1-relfractvil/relfractsd)

* Subdistrict religious segregation measure
bysort kecid: egen relseg_sd=total(wrelseg_sdv)


preserve

***District measures of subdistrict segregation 
bysort kecid: keep if _n==1

* Weighted subdistrict ethnic segregation inside summation to be used for district segregation measure
g wethseg_dsd=popsd/popd*(1-ethfractsd/ethfractd)

*District ethnic subdistrict segregation measure
bysort kabid: egen ethseg_sdd=total(wethseg_dsd)

* Weighted subdistrict ethnic segregation inside summation to be used for district segregation measure
g wrelseg_dsd=popsd/popd*(1-relfractsd/relfractd)

*District ethnic subdistrict segregation measure
bysort kabid: egen relseg_sdd=total(wrelseg_dsd)

* Average EFV in District (use as segregation alternative)
bysort kabid: egen mn_efv_d=mean(ethfractvil)
bysort kabid: egen tot_efv=total(ethfractvil)
bysort kabid: g tot_vil_d=_N
drop if tot_vil_d==1
g mn_evf_otherv_d=(tot_efv-ethfractvil)/(tot_vil_d-1)

sort kecid
save temp_sd_seg, replace

restore

sort kecid
merge m:1 kecid using temp_sd_seg

sort id2000

drop kddesa kecid kabid prop
drop _merge
merge 1:1 id2000 using podes2000_temp
drop _merge
ren id2003 id2003_mg

sort id2000
merge 1:m id2000 using xwalk1999_2000_2003

replace area=area/1000

* Regroup health facilities based on Yuhki's email (July 10, 2015)
* (A)Hospitals
* a. Rumah Sakit (hospital)
* b. Rumah Sakit Bersalin / Rumak Bersalin (maternity hospital, maternity clinic)
* 
* (B) General Clinic (I'm not sure if this is public or private)
* c. poliklinik / balai pengobatan (policlinic, health post)
* 
* (C) Community Health Facility (State run--operated by the subdistrict branch of the health agency) 
* d. Puskesmas (health clinic) : Subdistrict-level (each subdistrict has at least one)
* e. Puskesmas pembantu (supporting health clinic): Below Subdistrict (not in every village, but at the village level)
* 
* (D) Private facilities
* f. tempat praktek dokter (private practice)
* g. tempat praktek bidan (midwife practice)
* j. apotik (pharmacy) 
* 
* (E) Village health facility (Under the initiative/responsibility of the village head with support from subdistrict Puskesmas)
* h. posyandu (health post)
* i. polindes - pondok bersalin desa (village maternity clinic)
* 
* (F) Informal facilities (Not really public goods)
* 
* k. pos obat desa (village medication)
* l. toko khusus obat/jamu (traditional drug store)

gen health_distance_A=min(health_a_distance, health_b_distance)
gen health_distance_B=health_c_distance
gen health_distance_C=min(health_d_distance, health_e_distance)
gen health_distance_D=min(health_f_distance, health_g_distance, health_j_distance)
gen health_distance_E=min(health_h_distance, health_i_distance)
gen health_distance_F=min(health_k_distance, health_l_distance)

gen health_easy_A=min(health_a_easy, health_b_easy)
gen health_easy_B=health_c_easy
gen health_easy_C=min(health_d_easy, health_e_easy)
gen health_easy_D=min(health_f_easy, health_g_easy, health_j_easy)
gen health_easy_E=min(health_h_easy, health_i_easy)
gen health_easy_F=min(health_k_easy, health_l_easy)

* Regroup education
* (A) 
* a. kindergarten
* b. elementary
* (B)
* c. junior high
* d. senior high
* e. vocational
* (C)
* f. higher
* (D)
* g. special school
* h. islamic boarding school
* i. islamic school
* j. seminary

gen edu_number_state_A=edu_a_number_state+edu_b_number_state
gen edu_number_state_B=edu_c_number_state+edu_d_number_state+edu_e_number_state
gen edu_number_state_C=edu_f_number_state

gen edu_number_priv_A=edu_a_number_priv+edu_b_number_priv
gen edu_number_priv_B=edu_c_number_priv+edu_d_number_priv+edu_e_number_priv
gen edu_number_priv_C=edu_f_number_priv
gen edu_number_priv_D=edu_g_number_priv+edu_h_number_priv+edu_i_number_priv

gen edu_distance_A=min(edu_a_distance, edu_b_distance)
gen edu_distance_B=min(edu_c_distance, edu_d_distance, edu_e_distance)

* Generate schools per population DVs at village, subdistrict, and district levels

gen edu_ps_pop_v=edu_b_number_state/pop
gen edu_ps_pop_sd=edu_tot_ps_sd/pop_sd
gen edu_ps_pop_d=edu_tot_ps_d/pop_d
gen edu_ms_pop_sd=edu_tot_ms_sd/pop_sd
gen edu_ms_pop_d=edu_tot_ms_d/pop_d
gen edu_hs_pop_sd=edu_tot_hs_sd/pop_sd
gen edu_hs_pop_d=edu_tot_hs_d/pop_d



* Generate binary dependent variables for schools

g edu_b_state=0 if edu_b_number_state==0
replace edu_b_state=1 if edu_b_number_state>0
g edu_c_state=0 if edu_c_number_state==0
replace edu_c_state=1 if edu_c_number_state>0
g edu_d_state=0 if edu_d_number_state==0
replace edu_d_state=1 if edu_d_number_state>0

* Village head characteristics

g vhage=b13r1

g vhyrsoffice=b13r4
destring b13r3, replace

* Village head at least high school
g vhhs=b13r3>4 if b13r3!=.

* Village head tertiary schooling
g vhter=b13r3>5 if b13r3!=.

* Who determines if HH is poor status
destring b8r9, replace
g vhpoorstatus=b8r9==3 if b8r9!=.

* Voter turnout

g reg_voters=b4ar7a+b4ar7b
g tot_voters= b4ar9a+ b4ar9b
g turnout=tot_voters/reg_voters



* Interaction between Segregation and District Area
g es_area_d=ethseg_d*tot_area_d




destring id2000, generate(vil_id)
drop _merge
sort prop kab
save master2000_temp, replace



*** Add budget data ***

clear
import excel "$project/Data/Budget Data/2000/Budget2000_to_Stata.xls", sheet("apbd_2000") firstrow
gen budget_id_prop = substr(KodeDaerah,1,2)
gen prop=""

replace prop="11" if budget_id_prop=="01"
replace prop="12" if budget_id_prop=="02"
replace prop="13" if budget_id_prop=="03"
replace prop="14" if budget_id_prop=="04"
replace prop="15" if budget_id_prop=="05"
replace prop="16" if budget_id_prop=="06"
replace prop="17" if budget_id_prop=="07"
replace prop="18" if budget_id_prop=="08"

replace prop="31" if budget_id_prop=="09"
replace prop="32" if budget_id_prop=="10"
replace prop="33" if budget_id_prop=="11"
replace prop="34" if budget_id_prop=="12"
replace prop="35" if budget_id_prop=="13"

replace prop="61" if budget_id_prop=="14"
replace prop="62" if budget_id_prop=="15"
replace prop="63" if budget_id_prop=="16"
replace prop="64" if budget_id_prop=="17"

replace prop="71" if budget_id_prop=="18"
replace prop="72" if budget_id_prop=="19"
replace prop="73" if budget_id_prop=="20"

replace prop="51" if budget_id_prop=="22"
replace prop="52" if budget_id_prop=="23"
replace prop="53" if budget_id_prop=="24"
replace prop="81" if budget_id_prop=="25" 

drop if budget_id_prop=="26"
drop if prop==""
gen budget_id_kab2000 = substr(KodeDaerah,4,2)
drop if budget_id_kab2000=="00"
destring prop budget_id_kab2000, replace

destring SektorPendidikanKebudayaanNa, replace
destring SektorKesehatanKesejahteraan, replace

g total_funds=JUMLAHPENDAPATAN
g development_funds=JUMLAHPENGELUARANPEMBANGUNAN
g transport_funds=SektorTransportasi
g education_funds=SektorPendidikanKebudayaanNa
g health_funds=SektorKesehatanKesejahteraan
g police_funds=SektorAparaturPemerintahDanP

g total_health_edu=health_funds+education_funds
g total_pg_narrow=health_funds+education_funds+transport_funds
g total_pg_broad=health_funds+education_funds+transport_funds+police_funds+development_funds

g perc_dev=development_funds/total_funds
g perc_transport=transport_funds/total_funds
g perc_edu=education_funds/total_funds
g perc_health=health_funds/total_funds
g perc_police=police_funds/total_funds

g perc_health_edu=total_health_edu/total_funds
g perc_pg_narrow=total_pg_narrow/total_funds
g perc_pg_broad=total_pg_broad/total_funds


sort prop budget_id_kab2000
save temp, replace

clear
import excel "$project/Data/Budget Data/2000/District List.xlsx", sheet("From Budget 2000") firstrow
ren perm_prop2000 prop
drop if prop==.
sort prop budget_id_kab2000
merge 1:1 prop budget_id_kab2000 using temp
keep if _merge==3
drop _merge prop budget_id_kab2000
drop if distid2000==.
tostring distid2000, replace
gen prop = substr(distid,1,2)
gen kab = substr(distid,3,2)
destring prop kab, replace
sort prop kab
tostring prop kab, replace
merge 1:m prop kab using master2000_temp
drop _merge



save master2000_desa_rand, replace


****Merge Javanese Data****
drop if id2000==""
destring prop kabid kecid, replace
sort id2000
merge m:1 id2000 using "$census_dir/master_java_bali"
keep if _merge==3
drop _merge

g off_java=0
replace off_java=1 if prop<31 | prop>50

g javanese50_off_java_v=0
replace javanese50_off_java_v=1 if off_java==1 & javapc_v>=.5

g javanese30_off_java_v=0
replace javanese30_off_java_v=1 if off_java==1 & javapc_v>=.3

g off_jb=0
replace off_jb=1 if prop<31 | prop>51

g jb50=0
replace jb50=1 if javapc_v>=.5 | balipc_v>=.5
g jb50_off_jb_v=0
replace jb50_off_jb_v=1 if off_jb==1 & jb50==1

g jb30=0
replace jb30=1 if javapc_v>=.3 | balipc_v>=.3
g jb30_off_jb_v=0
replace jb30_off_jb_v=1 if off_jb==1 & jb30==1

* Identify if Kabupaten has Transmigrants
bysort kabid: egen tot_java_off_kab=total(javanese50_off_java)
g trans_kab=tot_java_off_kab!=0



****Merge Kota Data here****
ren kabid kabid_old
ren propid propid_old

g kabid=int(vil_id/1000000)
g propid=int(vil_id/100000000)

sort kabid
merge m:1 kabid using "$bpscode/district_kota2000"

drop _merge
sort id2003
destring id1999 id2000 id2002 id2003, replace
save master2000_desa_rand3, replace


use "$project/Data/Podes & Census Merged/podes03census_labelled12.dta", clear
keep id2002 id2003 golkar1 golkarany3 bpd
destring id2002 id2003, replace
sort id2003
save podes03_politics, replace


* Merging via id2000 instead
use xwalk1999_2000_2003, clear
destring id1999 id2000 id2002 id2003, replace
sort id2003
merge m:1 id2003 using podes03_politics
sort id2000
drop _merge
save podes03_politics_xw, replace
use master2000_desa_rand3, clear
merge m:m id2000 using podes03_politics_xw
save master2000_desa_rand4a, replace


* Yuhki's crosswalk instead

use master2000_desa_rand3
destring id1999 id2000 id2002 id2003, replace
save master2000_desa_rand3, replace
use "$project/Data/Crosswalks/cross9802d", clear
sort id2000
merge m:m id2000 using master2000_desa_rand3
drop _merge
sort id2002
save master2000_desa_rand3_temp, replace

use "$working/podes03_politics", clear
sort id2002
merge m:m id2002 using master2000_desa_rand3_temp
save master2000_desa_rand4b, replace
