#!/usr/bin/env bash


INPUT_DIR=./merged
OUTPUT_DIR=./output
vrtfile=./input_merged.vrt
mbtilesfile=${OUTPUT_DIR}/colorized_jaxa.mbtiles


[ -d "$OUTPUT_DIR" ] || mkdir -p $OUTPUT_DIR || { echo "error: $OUTPUT_DIR " 1>&2; exit 1; }

gdalbuildvrt -overwrite -srcnodata -9999 -vrtnodata -9999 ${vrtfile} ${INPUT_DIR}/*_DSM.tif
gdal_translate ${vrtfile} ${mbtilesfile} -of MBTILES 
#gdaladdo -r average ${mbtilesfile} 2 4 8 16
cp ${mbtilesfile} ${mbtilesfile}.orig
gdaladdo ${mbtilesfile} 2 4 8 16 32 64 128 256 512 1024
#for filename in input/*_DSM.tif; do
#    echo $filename
#	s=merged2/"$(basename -s .tif $filename)_S.tif"
#	cr=merged2/"$(basename -s .tif $filename)_CR.tif"
#	hs=merged2/"$(basename -s .tif $filename)_HS.tif"
#	hsg=merged2/"$(basename -s .tif $filename)_HSG.tif"
	
#	gdaldem slope $filename $s
	
	#Create Hillshade image
#    gdaldem hillshade -az 45 -z 1.3 $filename $hs
#	gdal_calc.py -A $hs --outfile=$hsg --calc="uint8(((A / 255.)**(1/0.5)) * 255)"
#	rm $hs

	#create color releif image
#    gdaldem color-relief $filename color-relief.txt $cr
#done
