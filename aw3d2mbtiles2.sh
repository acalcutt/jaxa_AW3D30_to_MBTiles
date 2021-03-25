#!/usr/bin/env bash


INPUT_DIR=/opt/aw3d30_srtmhgt/merged4/hsc
OUTPUT_DIR=/opt/aw3d30_srtmhgt/output
vrtfile=${OUTPUT_DIR}/jaxa_hillshade.vrt
mbtilesfile=${OUTPUT_DIR}/jaxa_hillshade.mbtiles
#tiffile=${OUTPUT_DIR}/input_merged_hsc.tif

[ -d "$OUTPUT_DIR" ] || mkdir -p $OUTPUT_DIR || { echo "error: $OUTPUT_DIR " 1>&2; exit 1; }

echo "Builing VRT"
gdalbuildvrt -overwrite -srcnodata -9999 -vrtnodata -9999 ${vrtfile} ${INPUT_DIR}/*.tif
echo "Import VRT into MBTiles"
gdal_translate ${vrtfile} ${mbtilesfile} -of MBTILES 
#gdaladdo -r average ${mbtilesfile} 2 4 8 16
#rm ${mbtilesfile}
#gdal2mbtiles -v --min-resolution 1 --max-resolution 12 --png8 4 --name "JAXA Hillshade" ${vrtfile} ${mbtilesfile}
#gdal_translate ${vrtfile} ${tiffile} -of GTiff -co BIGTIFF=IF_SAFER -co NUM_THREADS=ALL_CPUS --config GDAL_CACHEMAX 1024 -co COMPRESS=LZW -co PREDICTOR=2
#gdal2mbtiles -v --min-resolution 1 --max-resolution 12 --png8 4 --name "JAXA Hillshade" ${tiffile} ${mbtilesfile}
echo "Backup Origional MBTiles file"
cp ${mbtilesfile} ${mbtilesfile}.orig
echo "Create MBTiles Overview"
gdaladdo ${mbtilesfile}
