#!/usr/bin/env bash


INPUT_DIR=./input
OUTPUT_DIR=./output
vrtfile=${OUTPUT_DIR}/jaxa_color_relief.vrt
vrtfile2=${OUTPUT_DIR}/jaxa_color_relief2.vrt
vrtfile3=${OUTPUT_DIR}/jaxa_color_relief3.vrt
mbtilesfile=${OUTPUT_DIR}/jaxa_color_relief.mbtiles

[ -d "$OUTPUT_DIR" ] || mkdir -p $OUTPUT_DIR || { echo "error: $OUTPUT_DIR " 1>&2; exit 1; }

echo "Building VRT"
gdalbuildvrt -overwrite -srcnodata -9999 -vrtnodata -9999 ${vrtfile} ${INPUT_DIR}/*_DSM.tif
echo "Building color-relief VRT"
gdaldem color-relief -of VRT ${vrtfile} -alpha shade.ramp ${vrtfile2}
echo "Building gdalwarp VRT"
gdalwarp -r cubicspline -t_srs EPSG:3857 -dstnodata 0 -co COMPRESS=DEFLATE ${vrtfile2} ${vrtfile3}
echo "Import VRT into MBTiles"
gdal_translate ${vrtfile3} ${mbtilesfile} -of MBTILES
#echo "Backup Original MBTiles file"
#cp ${mbtilesfile} ${mbtilesfile}.orig
echo "Create MBTiles Overview"
gdaladdo ${mbtilesfile}

sqlite3 ${mbtiles} 'UPDATE metadata SET value = "JAXA ALOS World 3D 30m (AW3D30) converted with gdaldem" WHERE name = "description";'
sqlite3 ${mbtiles} 'UPDATE metadata SET value = "baselayer" WHERE name = "type";'
sqlite3 ${mbtiles} 'INSERT INTO metadata (name,value) VALUES(''attribution'',''<a href="https://earth.jaxa.jp/en/data/policy/">AW3D30 (JAXA)</a>'');'

