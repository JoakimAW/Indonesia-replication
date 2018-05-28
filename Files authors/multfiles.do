


/* Do separately: gab1200a gab1200b
 gab3200a gab3200b gab3200c gab3200d gab3200e gab3200f  
 gab3300a gab3300b gab3300c gab3300d  
 gab3500a gab3500b gab3500c gab3500d gab3500e gab3500f  gab3500g  gab3500h
*/

use censclean
sort censclean
save censclean, replace

local filelist "gab1300 gab1400 gab1500 gab1600 gab1700 gab1800 gab1900 gab3100 gab3400 gab3600 gab5100 gab5200 gab5300 gab6100 gab6200 gab6300 gab6400 gab7100 gab7200 gab7300a gab7400 gab7500 gab8100 gab8200 gab9400"

foreach file in `filelist' {
	use "`file'"
	do provrouter2
	drop _all

	use censclean
	append villageid using provmerged
	save censclean, replace
	drop _all
}




*save "outfiles/`file'temp", replace
