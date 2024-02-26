#!/bin/bash

prun()
{
	INPUT_DIR=./input
	JSON_OUTPUT_DIR=$PWD/json_100
	SHP_OUTPUT_DIR=$PWD/json_100/shp

	[ -d "$JSON_OUTPUT_DIR" ] || mkdir -p $JSON_OUTPUT_DIR || { echo "error: $JSON_OUTPUT_DIR " 1>&2; exit 1; }
	[ -d "$SHP_OUTPUT_DIR" ] || mkdir -p $SHP_OUTPUT_DIR || { echo "error: $SHP_OUTPUT_DIR " 1>&2; exit 1; }

	filename="$INPUT_DIR/$1"
	json="$JSON_OUTPUT_DIR/$(basename -s .tif $filename)_contour.geojson"
	shp="$SHP_OUTPUT_DIR/$(basename -s .tif $filename)_contour.shp"

	echo "$filename - $json - $shp"

	#create countor shape
	#gdal_contour -a elev -i 100 -f "GeoJSON" ${filename} ${json} #note - this geojson did not work right with tippcanoe. output came out one long line.
	gdal_contour -a elev -i 100 ${filename} ${shp}
	
	#convert to geojson
	ogr2ogr -f GeoJSON ${json} ${shp}
	
	#rm= "$SHP_OUTPUT_DIR/$(basename -s .tif $filename)_contour*"
	find "$SHP_OUTPUT_DIR" -type f -name "$(basename -s .tif $filename)*" -delete
}

export -f prun

# run in parallel using 20 thread/connection
ls input/ > filenames.txt
xargs -P 20 -n 1 -I {} bash -c "prun '{}'" < filenames.txt