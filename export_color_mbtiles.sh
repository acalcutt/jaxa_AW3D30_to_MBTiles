#!/usr/bin/env bash


INPUT_DIR=./images/crc
OUTPUT_DIR=./output
vrtfile=${OUTPUT_DIR}/jaxa_color_relief.vrt
mbtilesfile=${OUTPUT_DIR}/jaxa_color_relief.mbtiles

[ -d "$OUTPUT_DIR" ] || mkdir -p $OUTPUT_DIR || { echo "error: $OUTPUT_DIR " 1>&2; exit 1; }

echo "Building VRT"
gdalbuildvrt -overwrite -srcnodata -9999 -vrtnodata -9999 ${vrtfile} ${INPUT_DIR}/*.tif
echo "Import VRT into MBTiles"
gdal_translate ${vrtfile} ${mbtilesfile} -of MBTILES
#echo "Backup Original MBTiles file"
#cp ${mbtilesfile} ${mbtilesfile}.orig
echo "Create MBTiles Overview"
gdaladdo ${mbtilesfile}
