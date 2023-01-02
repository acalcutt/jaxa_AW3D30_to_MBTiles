#!/bin/bash

INPUT_DIR=./input
OUTPUT_DIR=./output
vrtfile=${OUTPUT_DIR}/jaxa_tilergb0-12.vrt
mbtiles=${OUTPUT_DIR}/jaxa_tilergb0-12.mbtiles
vrtfile2=${OUTPUT_DIR}/jaxa_tilergb0-12_warp.vrt

[ -d "$OUTPUT_DIR" ] || mkdir -p $OUTPUT_DIR || { echo "error: $OUTPUT_DIR " 1>&2; exit 1; }

gdalbuildvrt -overwrite -srcnodata -9999 -vrtnodata -9999 ${vrtfile} ${INPUT_DIR}/*_DSM.tif
gdalwarp -r cubicspline -t_srs EPSG:3857 -dstnodata 0 -co COMPRESS=DEFLATE ${vrtfile} ${vrtfile2}

#make use of rounding see details in https://github.com/mapbox/rio-rgbify/pull/34
for n in 4 5 6 7 8 9 10 11 12 13 14 15 16; do
    zoom=$((12-$n+4))
    rio rgbify -b -10000 -i 0.1 --min-z ${zoom} --max-z ${zoom} -j 24 --round-digits ${n} --format png ${vrtfile2} ${OUTPUT_DIR}/${zoom}-tmp.mbtiles
done

cp ${OUTPUT_DIR}/0-tmp.mbtiles ${mbtiles}

for n in 1 2 3 4 5 6 7 8 9 10 11 12; do
echo "copying '${OUTPUT_DIR}/${n} into ${mbtiles}'"
sqlite3 ${mbtiles} "
ATTACH DATABASE '${OUTPUT_DIR}/${n}-tmp.mbtiles' AS r${n};
REPLACE INTO tiles SELECT * FROM r${n}.tiles;
DETACH DATABASE 'r${n}';
"
done

sqlite3 ${mbtiles} 'CREATE UNIQUE INDEX tile_index on tiles (zoom_level, tile_column, tile_row);'
sqlite3 ${mbtiles} 'UPDATE metadata SET value = "jaxa_terrainrgb_0-12" WHERE name = "name" AND value = "";'
sqlite3 ${mbtiles} 'UPDATE metadata SET value = "JAXA ALOS World 3D 30m (AW3D30) converted with gdal and rio rgbify" WHERE name = "description";'
sqlite3 ${mbtiles} 'UPDATE metadata SET value = "png" WHERE name = "format";'
sqlite3 ${mbtiles} 'UPDATE metadata SET value = "1" WHERE name = "version";'
sqlite3 ${mbtiles} 'UPDATE metadata SET value = "baselayer" WHERE name = "type";'
sqlite3 ${mbtiles} "INSERT INTO metadata (name,value) VALUES(''attribution'',''<a href=""https://earth.jaxa.jp/en/data/policy/"">AW3D30 (JAXA)</a>');"
sqlite3 ${mbtiles} 'PRAGMA journal_mode=DELETE;'