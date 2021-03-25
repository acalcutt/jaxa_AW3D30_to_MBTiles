#!/usr/bin/env bash


INPUT_DIR=./images/fin
OUTPUT_DIR=./output
vrtfile=${OUTPUT_DIR}/jaxa_color_releif.vrt
mbtilesfile=${OUTPUT_DIR}/jaxa_color_releif.mbtiles

[ -d "$OUTPUT_DIR" ] || mkdir -p $OUTPUT_DIR || { echo "error: $OUTPUT_DIR " 1>&2; exit 1; }

echo "Builing VRT"
gdalbuildvrt -overwrite -srcnodata -9999 -vrtnodata -9999 ${vrtfile} ${INPUT_DIR}/*.tif
echo "Import VRT into MBTiles"
gdal_translate ${vrtfile} ${mbtilesfile} -of MBTILES 
#echo "Backup Origional MBTiles file"
#cp ${mbtilesfile} ${mbtilesfile}.orig
echo "Create MBTiles Overview"
gdaladdo ${mbtilesfile}
