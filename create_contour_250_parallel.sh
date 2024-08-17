#!/bin/bash

OUTPUT_DIR=./input

CON_OUTPUT_DIR=/opt/jaxa_AW3D30_to_MBTiles/con
JSON_OUTPUT_DIR=/opt/jaxa_AW3D30_to_MBTiles/json

[ -d "$OUTPUT_DIR" ] || mkdir -p $OUTPUT_DIR || { echo "error: $OUTPUT_DIR " 1>&2; exit 1; }
[ -d "$CON_OUTPUT_DIR" ] || mkdir -p $CON_OUTPUT_DIR || { echo "error: $CON_OUTPUT_DIR " 1>&2; exit 1; }
[ -d "$JSON_OUTPUT_DIR" ] || mkdir -p $JSON_OUTPUT_DIR || { echo "error: $JSON_OUTPUT_DIR " 1>&2; exit 1; }


prun()
{

	filename="input/$1"
	

	shp=/opt/jaxa_AW3D30_to_MBTiles/con/"$(basename -s .tif $filename)_CON.shp"
	json=/opt/jaxa_AW3D30_to_MBTiles/json/"$(basename -s .tif $filename)_CON.geojson"
	
	echo $filename
	echo $shp

	#create countor shape
	gdal_contour -a elev -i 250 ${filename} ${shp}
	
	#convert to geojson
	ogr2ogr -f GeoJSON ${json} ${shp}
	
	rm=/opt/jaxa_AW3D30_to_MBTiles/con/"$(basename -s .tif $filename)_CON.*"
	
	echo $rm
	
	rm $rm

}

export -f prun

# run in parallel using 20 thread/connection
ls input/ > filenames.txt
xargs -P 20 -n 1 -I {} bash -c "prun '{}'" < filenames.txt