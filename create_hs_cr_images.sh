#!/bin/bash

OUTPUT_DIR=./images
HSC_OUTPUT_DIR=${OUTPUT_DIR}/hsc
CRC_OUTPUT_DIR=${OUTPUT_DIR}/crc
FIN_OUTPUT_DIR=${OUTPUT_DIR}/fin

[ -d "$OUTPUT_DIR" ] || mkdir -p $OUTPUT_DIR || { echo "error: $OUTPUT_DIR " 1>&2; exit 1; }
[ -d "$HSC_OUTPUT_DIR" ] || mkdir -p $HSC_OUTPUT_DIR || { echo "error: $HSC_OUTPUT_DIR " 1>&2; exit 1; }
[ -d "$CRC_OUTPUT_DIR" ] || mkdir -p $CRC_OUTPUT_DIR || { echo "error: $CRC_OUTPUT_DIR " 1>&2; exit 1; }
[ -d "$FIN_OUTPUT_DIR" ] || mkdir -p $FIN_OUTPUT_DIR || { echo "error: $FIN_OUTPUT_DIR " 1>&2; exit 1; }

for filename in input/*_DSM.tif; do


	hs=${OUTPUT_DIR}/"$(basename -s .tif $filename)_HS.tif"
	hso=${OUTPUT_DIR}/"$(basename -s .tif $filename)_HSO.tif"
	hsc=${HSC_OUTPUT_DIR}/"$(basename -s .tif $filename)_HSC.tif"
	cr=${OUTPUT_DIR}/"$(basename -s .tif $filename)_CR.tif"
	crc=${CRC_OUTPUT_DIR}/"$(basename -s .tif $filename)_CRC.tif"
	mtif=${OUTPUT_DIR}/"$(basename -s .tif $filename)_MG.tif"
	mgeo=${OUTPUT_DIR}/"$(basename -s .tif $filename)_MG.geo"
	fint=${OUTPUT_DIR}/"$(basename -s .tif $filename)_FINT.tif"
	finc=${FIN_OUTPUT_DIR}/"$(basename -s .tif $filename)_FIN.tif"
	
	echo $filename
	#produce a transparent hillshade image
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

	exit
done
