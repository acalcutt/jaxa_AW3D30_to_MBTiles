#!/bin/bash

prun()
{

	filename="input/$1"
	
	hs=merged4/"$(basename -s .tif $filename)_HS.tif"
	hso=merged4/"$(basename -s .tif $filename)_HSO.tif"
	hsc=merged4/hsc/"$(basename -s .tif $filename)_HSC.tif"
	cr=merged4/"$(basename -s .tif $filename)_CR.tif"
	crc=merged4/crc/"$(basename -s .tif $filename)_CRC.tif"
	mtif=merged4/"$(basename -s .tif $filename)_MG.tif"
	mgeo=merged4/"$(basename -s .tif $filename)_MG.geo"
	fint=merged4/"$(basename -s .tif $filename)_FINT.tif"
	finc=merged4/fin/"$(basename -s .tif $filename)_FIN.tif"
	
	echo $filename
	#produce a one band grey scale file with pixels values range=[1-255]
	gdaldem hillshade -of GTiff $filename $hs -alpha -s 111120 -z 5 -az 315 -alt 60 -compute_edges
	gdaldem color-relief $hs -alpha hillshade.ramp $hso
	gdal_translate -co COMPRESS=LZW -co ALPHA=YES $hso $hsc
	rm $hs
	

	#create color releif image
    gdaldem color-relief -of GTiff $filename -alpha shade.ramp $cr
	gdal_translate -a_nodata 0 -co COMPRESS=LZW -co ALPHA=YES $cr $crc
	

	#create color releif image with hillshade
	composite -gravity Center $hsc $crc -alpha Set $mtif
	listgeo $filename > $mgeo #Dump geotiff metadata from a file that has it.
	geotifcp -g $mgeo $mtif $fint #merge the metadata into the composite image
	gdal_translate -a_nodata 0 -co COMPRESS=LZW -co ALPHA=YES $fint $finc #compress the file
	rm $mgeo
	rm $mtif
	rm $fint
	rm $cr
	rm $hso
}

export -f prun

# run in parallel using 20 thread/connection
ls input/ > filenames.txt
xargs -P 20 -n 1 -I {} bash -c "prun '{}'" < filenames.txt