#!/usr/bin/env bash


INPUT_DIR=./input
OUTPUT_DIR=./output_cr
vrtfile=${OUTPUT_DIR}/jaxa_color_releif.vrt
vrtfile2=${OUTPUT_DIR}/jaxa_color_releif2.vrt
vrtfile3=${OUTPUT_DIR}/jaxa_color_releif3.vrt
mbtilesfile=${OUTPUT_DIR}/jaxa_color_releif.mbtiles

[ -d "$OUTPUT_DIR" ] || mkdir -p $OUTPUT_DIR || { echo "error: $OUTPUT_DIR " 1>&2; exit 1; }

echo "Builing VRT"
gdalbuildvrt -overwrite -srcnodata -9999 -vrtnodata -9999 ${vrtfile} ${INPUT_DIR}/*_DSM.tif
echo "Builing color-relief VRT"
gdaldem color-relief -of VRT ${vrtfile} -alpha shade.ramp ${vrtfile2}
echo "Builing gdalwarp VRT"
gdalwarp -r cubicspline -t_srs EPSG:3857 -dstnodata 0 -co COMPRESS=DEFLATE ${vrtfile2} ${vrtfile3}
echo "Import VRT into MBTiles"
gdal_translate ${vrtfile3} ${mbtilesfile} -of MBTILES 
#echo "Backup Origional MBTiles file"
#cp ${mbtilesfile} ${mbtilesfile}.orig
echo "Create MBTiles Overview"
gdaladdo ${mbtilesfile}
