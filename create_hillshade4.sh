#!/bin/bash
for filename in input/*_DSM.tif; do


	hs=merged4/"$(basename -s .tif $filename)_HS.tif"
	hso=merged4/"$(basename -s .tif $filename)_HSO.tif"
	hsc=merged4/"$(basename -s .tif $filename)_HSC.tif"
	cr=merged4/"$(basename -s .tif $filename)_CR.tif"
	crc=merged4/"$(basename -s .tif $filename)_CRC.tif"
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

	#create color releif image
    gdaldem color-relief -of GTiff $filename -alpha shade.ramp $cr
	gdal_translate -a_nodata 0 -co COMPRESS=LZW -co ALPHA=YES $cr $crc
	rm $cr

	#create color releif image with hillshade
	composite -gravity Center $hsc $crc -alpha Set $mtif
	listgeo $hsc > $mgeo
	geotifcp -g $mgeo $mtif $fint
	gdal_translate -a_nodata 0 -co COMPRESS=LZW -co ALPHA=YES $fint $finc
	rm $mgeo
	rm $mtif
	rm $fint

	exit
done
