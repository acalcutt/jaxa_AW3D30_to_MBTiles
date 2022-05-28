#!/usr/bin/env bash


INPUT_DIR=./input
OUTPUT_DIR=./output
HSC_OUTPUT_DIR=/hs_temp
vrtfile=${OUTPUT_DIR}/jaxa_hillshade_base.vrt
vrtfile2=${OUTPUT_DIR}/jaxa_hillshade_warp.vrt
mbtilesfile=${OUTPUT_DIR}/jaxa_hillshade.mbtiles

[ -d "$OUTPUT_DIR" ] || mkdir -p $OUTPUT_DIR || { echo "error: $OUTPUT_DIR " 1>&2; exit 1; }
[ -d "$HSC_OUTPUT_DIR" ] || mkdir -p $HSC_OUTPUT_DIR || { echo "error: $HSC_OUTPUT_DIR " 1>&2; exit 1; }

for filename in ${INPUT_DIR}/*_DSM.tif; do

	hs=${HSC_OUTPUT_DIR}/"$(basename -s .tif $filename)_HS.tif"
	hso=${HSC_OUTPUT_DIR}/"$(basename -s .tif $filename)_HSO.tif"
	hsc=${HSC_OUTPUT_DIR}/"$(basename -s .tif $filename)_HSC.tif"
	
	gdaldem hillshade -of GTiff $filename $hs -alpha -s 111120 -z 5 -az 315 -alt 60 -compute_edges
	gdaldem color-relief $hs -alpha hillshade.ramp $hso
	gdal_translate -co COMPRESS=LZW -co ALPHA=YES $hso $hsc
	rm $hs
	rm $hso
done

echo "Builing VRT"
gdalbuildvrt -overwrite -srcnodata -9999 -vrtnodata -9999 ${vrtfile} ${HSC_OUTPUT_DIR}/*_HSC.tif
echo "gdalwarp VRT"
gdalwarp -r bilinear -t_srs EPSG:3857 -dstnodata 0 -co COMPRESS=DEFLATE ${vrtfile} ${vrtfile2}
echo "Import VRT into MBTiles"
gdal_translate ${vrtfile2} ${mbtilesfile} -of MBTILES 
#echo "Backup Origional MBTiles file"
#cp ${mbtilesfile} ${mbtilesfile}.orig
echo "Create MBTiles Overview"
gdaladdo -r bilinear ${mbtilesfile}

sqlite3 ${mbtiles} 'UPDATE metadata SET value = "JAXA ALOS World 3D 30m (AW3D30) converted with gdaldem" WHERE name = "description";'
sqlite3 ${mbtiles} 'INSERT INTO metadata (name,value) VALUES(''attribution'',''<a href="https://earth.jaxa.jp/en/data/policy/">AW3D30 (JAXA)</a>'');'