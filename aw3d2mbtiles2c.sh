#!/usr/bin/env bash


INPUT_DIR=./merged2
OUTPUT_DIR=./output
vrtfile=./input_merged_crc.vrt
mbtilesfile=${OUTPUT_DIR}/colorized_color_jaxa.mbtiles


[ -d "$OUTPUT_DIR" ] || mkdir -p $OUTPUT_DIR || { echo "error: $OUTPUT_DIR " 1>&2; exit 1; }

gdalbuildvrt -overwrite -srcnodata -9999 -vrtnodata -9999 ${vrtfile} ${INPUT_DIR}/*_CRC.tif
gdal_translate ${vrtfile} ${mbtilesfile} -of MBTILES 
#gdaladdo -r average ${mbtilesfile} 2 4 8 16
cp ${mbtilesfile} ${mbtilesfile}.orig
gdaladdo ${mbtilesfile} 2 4 8 16 32 64 128 256 512 1024
