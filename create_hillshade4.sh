#!/bin/bash
for filename in input/*_DSM.tif; do

	s=merged4/"$(basename -s .tif $filename)_S.tif"
	st=merged4/"$(basename -s .tif $filename)_ST.tif"
	sc=merged4/"$(basename -s .tif $filename)_SC.tif"
	cc=merged4/"$(basename -s .tif $filename)_CC.tif"
	oc=merged4/"$(basename -s .tif $filename)_OC.tif"
	hs=merged4/"$(basename -s .tif $filename)_HS.tif"
	hso=merged4/"$(basename -s .tif $filename)_HSO.tif"
	hsc=merged4/"$(basename -s .tif $filename)_HSC.tif"
	cr=merged4/"$(basename -s .tif $filename)_CR.tif"
	crc=merged4/"$(basename -s .tif $filename)_CRC.tif"
	vrt=merged4/"$(basename -s .tif $filename).vrt"
	mvrt=merged4/"$(basename -s .tif $filename)_MG.vrt"
	mtif=merged4/"$(basename -s .tif $filename)_MG.tif"
	mgeo=merged4/"$(basename -s .tif $filename)_MG.geo"
	fint=merged4/"$(basename -s .tif $filename)_FINT.tif"
	finc=merged4/"$(basename -s .tif $filename)_FIN.tif"
	
	echo $filename
	#produce a one band grey scale file with pixels values range=[1-255]
	gdaldem hillshade -of GTiff $filename $hs -alpha -s 111120 -z 5 -az 315 -alt 60 -compute_edges
	gdaldem color-relief $hs -alpha hillshade.ramp $hso
	gdal_translate -co COMPRESS=LZW -co ALPHA=YES $hso $hsc
	rm $hs
	rm $hso
	
	
	
	
	# filter the color band, keep greyness of relevant shadows below limit
	#gdal_calc.py -A $hs  --outfile=$cc --calc="255*(A>220) +      A*(A<=220)"
	# filter the opacity band, keep opacity of relevant shadows below limit
	#gdal_calc.py -A $hs  --outfile=$oc --calc="  1*(A>220) +(256-A)*(A<=220)"
	#gdalbuildvrt -separate $vrt $cc $oc
	#gdal_translate -a_nodata 0 -b 1 -b 1 -b 1 -b 2 -co ALPHA=YES -colorinterp red,green,blue,alpha $vrt $hsc
	#rm $vrt
	#rm $cc
	#rm $oc
	#rm $hs
		
	#create color releif image
    gdaldem color-relief -of GTiff $filename -alpha shade.ramp $cr
	gdal_translate -a_nodata 0 -co COMPRESS=LZW -co ALPHA=YES $cr $crc
	rm $cr

	#create color slope
	#gdaldem slope -of GTiff -b 1 -s 1.0 -compute_edges $filename $s
	#gdaldem color-relief -alpha $s -co compress=deflate -co zlevel=6 color_slope.txt $st
	#gdal_calc.py -A $st --A_band=4 -B $hsc --allBands=B -C $st --C_band=1 --outfile=$sc --calc="round_(((1-A/255.0)*B + (A/255.0)*0.5*C),0)" --NoDataValue="255" --type=Byte
	#gdal_calc.py -A $st --A_band=4 -B $hsc --allBands=B -C $st --C_band=1 --outfile=$sc --calc="round_(((1-A/255.0)*B + (A/255.0)*0.5*C),0)" --NoDataValue="255" --type=Byte
	#gdal_merge.py -n 255 -a_nodata 0 -o $sc $cr $hso
	
	#gdalbuildvrt $mvrt $cr $hso
	#gdal_translate -a_nodata 0 -co ALPHA=YES $mvrt $mtif
	composite -gravity Center $hsc $crc -alpha Set $mtif
	listgeo $hsc > $mgeo
	geotifcp -g $mgeo $mtif $fint
	gdal_translate -a_nodata 0 -co COMPRESS=LZW -co ALPHA=YES $fint $finc
	rm $mgeo
	rm $mtif
	rm $fint
	
	#gdalwarp --config GDAL_CACHEMAX 2000 -wm 2000 -multi -overwrite -srcnodata 0 -dstnodata 0
	
	
	#rm $s
	#exit
done
