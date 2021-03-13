#!/bin/bash
for filename in input/*_DSM.tif; do
    echo $filename
	s=tmp2/s.tif
	cs=tmp2/cs.tif
	hs=tmp2/hs.tif
	gh=tmp2/gh.tif
	hss=tmp2/hss.tif
	mg=merged2/"$(basename -- $filename)"
	
	#Create slope
	gdaldem slope $filename $s
	
	#Colorize slope
	#gdaldem color-relief -alpha $s -co compress=deflate -co zlevel=6 color_slope.txt $cs
	gdaldem color-relief -alpha $s color-relief.txt $cs
	
	#Create Hillshade
	#gdaldem hillshade -z 1 -combined -compute_edges -alt 45 -co compress=deflate -co zlevel=6 $filename $hs
	gdaldem hillshade -az 45 -z 1.3 $filename $hs
	
	#Use Raster Calculator to combine Hillshade and the color-relief'd Slopes
	gdal_calc.py -A $cs --A_band=4 -B $hs --B_band=1 -C $cs --C_band=1 --outfile=$hss --calc="round_(((1-A/255.0)*B + (A/255.0)*C*0.5),0)" --NoDataValue="255" --type=Byte
	
	#alpha mask on the combined hillshade-slopeshade raster with gdaldem color-relief and a modified color-ramp
	gdaldem color-relief $hss -co compress=deflate -co zlevel=6 combinealpha.txt -alpha $mg
	
	
	
	exit
    rm -f $s
    rm -f $cs
    rm -f $hs
	rm -f $gh
    rm -f $hss
done