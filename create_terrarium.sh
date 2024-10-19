#!/bin/bash

#Requires custom version of rio rgbify which adds terrarium encoding support ( https://github.com/acalcutt/rio-rgbify/ )

INPUT_DIR=./input
OUTPUT_DIR=./output

[[ $THREADS ]] || THREADS=12
[[ $VERSION ]] || VERSION=v4.0
[[ $MINZOOM ]] || MINZOOM=0
[[ $MAXZOOM ]] || MAXZOOM=11
[[ $FORMAT ]] || FORMAT=png

BASENAME=jaxa_terrarium_${MINZOOM}-${MAXZOOM}_${FORMAT}
vrtfile=${OUTPUT_DIR}/${BASENAME}.vrt
mbtiles=${OUTPUT_DIR}/${BASENAME}.mbtiles
vrtfile2=${OUTPUT_DIR}/${BASENAME}_warp.vrt

[ -d "$OUTPUT_DIR" ] || mkdir -p $OUTPUT_DIR || { echo "error: $OUTPUT_DIR " 1>&2; exit 1; }

#rm rio/*
gdalbuildvrt -overwrite -srcnodata -9999 -vrtnodata -9999 ${vrtfile} ${INPUT_DIR}/*_DSM.tif
gdalwarp -r cubicspline -t_srs EPSG:3857 -dstnodata 0 -co COMPRESS=DEFLATE ${vrtfile} ${vrtfile2}
rio rgbify -e terrarium --min-z $MINZOOM --max-z $MAXZOOM -j $THREADS --format $FORMAT ${vrtfile2} ${mbtiles}

#sqlite3 ${mbtiles} 'CREATE UNIQUE INDEX tile_index on tiles (zoom_level, tile_column, tile_row);' #not neeeded with my custom rio rgbify
#sqlite3 ${mbtiles} 'PRAGMA journal_mode=DELETE;' #not neeeded with my custom rio rgbify
sqlite3 ${mbtiles} 'UPDATE metadata SET value = "'${BASENAME}'" WHERE name = "name" AND value = "";'
sqlite3 ${mbtiles} 'UPDATE metadata SET value = "JAXA ALOS World 3D 30m (AW3D30 '${VERSION}') converted with rio rgbify" WHERE name = "description";'
sqlite3 ${mbtiles} 'UPDATE metadata SET value = "'${FORMAT}'" WHERE name = "format";'
sqlite3 ${mbtiles} 'UPDATE metadata SET value = "1" WHERE name = "version";'
sqlite3 ${mbtiles} 'UPDATE metadata SET value = "baselayer" WHERE name = "type";'
sqlite3 ${mbtiles} "INSERT INTO metadata (name,value) VALUES('attribution','<a href=""https://earth.jaxa.jp/en/data/policy/"">AW3D30 (JAXA)</a>');"
qlite3 ${mbtiles} "INSERT INTO metadata (name,value) VALUES('attribution','<a href=""https://earth.jaxa.jp/en/data/policy/"">AW3D30 (JAXA)</a>');"
sqlite3 ${mbtiles} "INSERT INTO metadata (name,value) VALUES('minzoom','${MINZOOM}');"
sqlite3 ${mbtiles} "INSERT INTO metadata (name,value) VALUES('maxzoom','${MAXZOOM}');"
sqlite3 ${mbtiles} "INSERT INTO metadata (name,value) VALUES('bounds','-180,-90,180,90');"
sqlite3 ${mbtiles} "INSERT INTO metadata (name,value) VALUES('center','0,0,5');"




