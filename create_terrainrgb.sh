#!/bin/bash

#custom version of rio rgbify which adds speed improvements is reccomended https://github.com/acalcutt/rio-rgbify

INPUT_DIR=./input
OUTPUT_DIR=./output
MINZOOM=0
MAXZOOM=11
vrtfile=${OUTPUT_DIR}/jaxa_terrainrgb_${MINZOOM}-${MAXZOOM}.vrt
mbtiles=${OUTPUT_DIR}/jaxa_terrainrgb_${MINZOOM}-${MAXZOOM}.mbtiles
vrtfile2=${OUTPUT_DIR}/jaxa_terrainrgb_${MINZOOM}-${MAXZOOM}_warp.vrt

[ -d "$OUTPUT_DIR" ] || mkdir -p $OUTPUT_DIR || { echo "error: $OUTPUT_DIR " 1>&2; exit 1; }

#rm rio/*
gdalbuildvrt -overwrite -srcnodata -9999 -vrtnodata -9999 ${vrtfile} ${INPUT_DIR}/*_DSM.tif
gdalwarp -r cubicspline -t_srs EPSG:3857 -dstnodata 0 -co COMPRESS=DEFLATE ${vrtfile} ${vrtfile2}
rio rgbify -b -10000 -i 0.1 --min-z $MINZOOM --max-z $MAXZOOM -j 12 --format png ${vrtfile2} ${mbtiles}

sqlite3 ${mbtiles} 'CREATE UNIQUE INDEX tile_index on tiles (zoom_level, tile_column, tile_row);'
sqlite3 ${mbtiles} 'UPDATE metadata SET value = "jaxa_terrainrgb_'${MINZOOM}'-'${MAXZOOM}'" WHERE name = "name" AND value = "";'
sqlite3 ${mbtiles} 'UPDATE metadata SET value = "JAXA ALOS World 3D 30m (AW3D30 v4.0) converted with rio rgbify" WHERE name = "description";'
sqlite3 ${mbtiles} 'UPDATE metadata SET value = "png" WHERE name = "format";'
sqlite3 ${mbtiles} 'UPDATE metadata SET value = "1" WHERE name = "version";'
sqlite3 ${mbtiles} 'UPDATE metadata SET value = "baselayer" WHERE name = "type";'
sqlite3 ${mbtiles} "INSERT INTO metadata (name,value) VALUES('attribution','<a href=""https://earth.jaxa.jp/en/data/policy/"">AW3D30 (JAXA)</a>');"
sqlite3 ${mbtiles} 'PRAGMA journal_mode=DELETE;'

