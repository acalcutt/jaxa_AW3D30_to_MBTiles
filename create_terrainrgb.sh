#!/bin/bash

INPUT_DIR=./input
OUTPUT_DIR=./output
vrtfile=${OUTPUT_DIR}/jaxa_tilergb0-12.vrt
mbtiles=${OUTPUT_DIR}/jaxa_tilergb0-12.mbtiles
vrtfile2=${OUTPUT_DIR}/jaxa_tilergb0-12_warp.vrt

[ -d "$OUTPUT_DIR" ] || mkdir -p $OUTPUT_DIR || { echo "error: $OUTPUT_DIR " 1>&2; exit 1; }

#rm rio/*
gdalbuildvrt -overwrite -srcnodata -9999 -vrtnodata -9999 ${vrtfile} ${INPUT_DIR}/*_DSM.tif
gdalwarp -r cubicspline -t_srs EPSG:3857 -dstnodata 0 -co COMPRESS=DEFLATE ${vrtfile} ${vrtfile2}

for n in 4 5 6 7 8 9 10 11 12 13 14 16; do
    zoom=$((12-$n+4))
    rio rgbify -b -10000 -i 0.1 --min-z ${zoom} --max-z ${zoom} -j 24 --round-digits ${n} --format png ${vrtfile2} ${zoom}-tmp.mbtile
 done

cp ${zoom}-tmp.mbtile ${mbtiles}
sqlite3 ${mbtiles} "
ATTACH DATABASE '0-tmp.mbtiles' AS r0;
ATTACH DATABASE '1-tmp.mbtiles' AS r1;
ATTACH DATABASE '2-tmp.mbtiles' AS r2;
ATTACH DATABASE '3-tmp.mbtiles' AS r3;
ATTACH DATABASE '4-tmp.mbtiles' AS r4;
ATTACH DATABASE '5-tmp.mbtiles' AS r5;
ATTACH DATABASE '6-tmp.mbtiles' AS r6;
ATTACH DATABASE '7-tmp.mbtiles' AS r7;
ATTACH DATABASE '8-tmp.mbtiles' AS r8;
ATTACH DATABASE '9-tmp.mbtiles' AS r9;
ATTACH DATABASE '10-tmp.mbtiles' AS r10;
ATTACH DATABASE '11-tmp.mbtiles' AS r11;
REPLACE INTO tiles SELECT * FROM r0.tiles;
REPLACE INTO tiles SELECT * FROM r1.tiles;
REPLACE INTO tiles SELECT * FROM r2.tiles;
REPLACE INTO tiles SELECT * FROM r3.tiles;
REPLACE INTO tiles SELECT * FROM r4.tiles;
REPLACE INTO tiles SELECT * FROM r5.tiles;
REPLACE INTO tiles SELECT * FROM r6.tiles;
REPLACE INTO tiles SELECT * FROM r7.tiles;
REPLACE INTO tiles SELECT * FROM r8.tiles;
REPLACE INTO tiles SELECT * FROM r9.tiles;
REPLACE INTO tiles SELECT * FROM r10.tiles;
REPLACE INTO tiles SELECT * FROM r11.tiles;
CREATE UNIQUE INDEX tile_index on tiles (zoom_level, tile_column, tile_row);
UPDATE metadata SET value = "jaxa_terrainrgb_0-12" WHERE name = "name" AND value = "";
UPDATE metadata SET value = "JAXA ALOS World 3D 30m (AW3D30) converted with rio rgbify" WHERE name = "description";
UPDATE metadata SET value = "png" WHERE name = "format";
UPDATE metadata SET value = "1" WHERE name = "version";
UPDATE metadata SET value = "baselayer" WHERE name = "type";
INSERT INTO metadata (name,value) VALUES(''attribution'',''<a href="https://earth.jaxa.jp/en/data/policy/">AW3D30 (JAXA)</a>'');
PRAGMA journal_mode=DELETE;
"

