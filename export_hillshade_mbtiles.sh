#!/usr/bin/env bash


INPUT_DIR=/opt/aw3d30_srtmhgt/merged4/hsc
OUTPUT_DIR=/opt/aw3d30_srtmhgt/output
vrtfile=${OUTPUT_DIR}/jaxa_hillshade.vrt
mbtilesfile=${OUTPUT_DIR}/jaxa_hillshade.mbtiles

[ -d "$OUTPUT_DIR" ] || mkdir -p $OUTPUT_DIR || { echo "error: $OUTPUT_DIR " 1>&2; exit 1; }

echo "Builing VRT"
gdalbuildvrt -overwrite -srcnodata -9999 -vrtnodata -9999 ${vrtfile} ${INPUT_DIR}/*.tif
echo "Import VRT into MBTiles"
gdal_translate ${vrtfile} ${mbtilesfile} -of MBTILES 
#echo "Backup Origional MBTiles file"
#cp ${mbtilesfile} ${mbtilesfile}.orig
echo "Create MBTiles Overview"
gdaladdo ${mbtilesfile}
