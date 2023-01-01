#!/usr/bin/env bash

# exit script on error
set -e
# exit on undeclared variable
set -u


## Color Constants

# Reset
Color_Off='\033[0m'       # Text Reset

# Regular Colors
Red='\033[0;31m'          # Red
Green='\033[0;32m'        # Green
Yellow='\033[0;33m'       # Yellow
Cyan='\033[0;36m'         # Cyan

#set Defaults
JAXA_DIR=/data/mapping/AW3D30
OUTPUT_DIR=/data/mapping
HIGHRES_VRT=""
RIOWORKERS=`sysctl -n kern.smp.cpus`
RGBIFY_OPTIONS=""
GDALOPTIONS=""

# print a help message
function print_usage() {
  echo "Usage: ${0} --input-dir ./ --output-dir ./ --workers 5"
  echo "  --jaxa-dir:    the directory containing the jaxa DSM tiffs defaults" 
  echo "                   to ${JAXA_DIR}"
  echo "  --highres-vrt: a vrt file containing localized high res dems, order"
  echo "                   is important, higest res of any given geo should be "
  echo "                   last in the file, defaults to ${HIGHRES_VRT:-none}"
  echo "  --output-dir:  the directory to put the resulting whole combined "
  echo "                   raster tile defaults to ${OUTPUT_DIR}."
  echo "  --workers:     the number of rgbify workers to run, defaults to the number of"
  echo "                   CPU thread's detected (${RIOWORKERS})"
  echo "  --verbose:     Turn on chattier output"
  echo "  --overwrite:   Force the creation of all files, not just the missing/new ones"
  exit
}

# print a given text entirely in a given color
function color_echo () {
    color=$1
    text=$2
    echo -e "${color}${text}${Color_Off}"
}



if [ "$#" -eq 0 ]; then
    print_usage
    exit 0
fi
echo $#

while true; do
  case "$1" in
    -i | --input-dir)
      if [ ! -n "${2-}" ]; then
        INPUT_DIR=${2}
        shift 2
      else
        shift 1
     fi
    ;;
    -o | --output-dir)
      if [ ! -n "${2-}" ]; then
        OUTPUT_DIR="${2}"
        shift 2
      else
        shift 1
      fi
    ;;
    --highres-vrt)
      if [ ! -n "${2-}" ]; then
        HIGHRES_VRT="{$2}"
        shift 2
      else
        shift 1
      fi
    ;;
    -f | --overwrite)
      OVERWRITE="true"
      GDALOPTIONS=+"--overwrite "
      shift 1
    ;;
    -v | --verbose)
      VERBOSE="true"
      RGBIFY_OPTIONS="--verbose"
      shift 1
    ;;
    -q | --quiet)
      QUIET="true"
      RGBIFY_OPTIONS="--quiet"
      shift 1
    ;;
    -h | -? | --help)
      print_usage
      break
    ;;
    -j | -w | --workers)
      if [ ! -n "${2-}" ]; then
        RIOWORKERS=${2}
        shift 2
      else
        shift 1
      fi
    ;;
    *)
       break
    ;;
  esac
done;




vrtfile=${OUTPUT_DIR}/jaxa_tilergb0-12.vrt
mbtiles=${OUTPUT_DIR}/jaxa_tilergb0-12.mbtiles
vrtfile2=${OUTPUT_DIR}/jaxa_tilergb0-12-warp.tif

[ -d "$OUTPUT_DIR" ] || mkdir -p $OUTPUT_DIR || { echo "error: $OUTPUT_DIR " 1>&2; exit 1; }


find ${JAXA_DIR} -name \*_DSM.tif > ${OUTPUT_DIR}/JAXA_DSM.list
echo ${HIGHRES_VRT} >> ${OUTPUT_DIR}/JAXA_DSM.list

# need to add detection to determine if ANY of the files contained in 
# JAXA_DSM.list are newer than the vrtfile but in the interm observe the overwrite flag

gdalbuildvrt ${GDALOPTIONS} -resolution highest -srcnodata -9999 -vrtnodata -9999 -input_file_list ${OUTPUT_DIR}/JAXA_DSM.list ${vrtfile}

if [ ${OVERWRITE} -eq "true" ] || [ ${vrtfile} -nt ${vrtfile2} ]; then
  gdalwarp ${GDALOPTIONS} -r cubicspline -t_srs EPSG:3857 -dstnodata 0 -multi -co NUM_THREADS=ALL_CPUS -wo NUM_THREADS=ALL_CPUS --config GDAL_CACHEMAX 50% -co COMPRESS=DEFLATE -co BIGTIFF=YES ${vrtfile} ${vrtfile2}
fi

#make use of rounding see details in https://github.com/mapbox/rio-rgbify/pull/34
for n in 12 11 10 9 8 7 6 5 4; do
  zoom=$((12-$n+4))
  if [[ ${vrtfile2} -nt ${zoom}-tmp.mbtiles ]]; then
    echo  ${vrtfile2} is newer than ${zoom}-tmp.mbtiles Generating
    rio rgbify ${RGBIFY_OPTIONS} --base-val -10000 --interval 0.1 --min-z ${zoom} --max-z ${zoom} --workers ${RIOWORKERS} --round-digits ${n} --format png ${vrtfile2} ${zoom}-tmp.mbtiles
  fi
done

#
#
#cp ${zoom}-tmp.mbtile ${mbtiles}
#sqlite3 ${mbtiles} "
#ATTACH DATABASE '1-tmp.mbtiles' AS r1;
#ATTACH DATABASE '2-tmp.mbtiles' AS r2;
#ATTACH DATABASE '3-tmp.mbtiles' AS r3;
#ATTACH DATABASE '4-tmp.mbtiles' AS r4;
#ATTACH DATABASE '5-tmp.mbtiles' AS r5;
#ATTACH DATABASE '6-tmp.mbtiles' AS r6;
#ATTACH DATABASE '7-tmp.mbtiles' AS r7;
#ATTACH DATABASE '8-tmp.mbtiles' AS r8;
#ATTACH DATABASE '9-tmp.mbtiles' AS r9;
#ATTACH DATABASE '10-tmp.mbtiles' AS r10;
#ATTACH DATABASE '11-tmp.mbtiles' AS r11;
#ATTACH DATABASE '12-tmp.mbtiles' AS r12;
#REPLACE INTO tiles SELECT * FROM r1.tiles;
#REPLACE INTO tiles SELECT * FROM r2.tiles;
#REPLACE INTO tiles SELECT * FROM r3.tiles;
#REPLACE INTO tiles SELECT * FROM r4.tiles;
#REPLACE INTO tiles SELECT * FROM r5.tiles;
#REPLACE INTO tiles SELECT * FROM r6.tiles;
#REPLACE INTO tiles SELECT * FROM r7.tiles;
#REPLACE INTO tiles SELECT * FROM r8.tiles;
#REPLACE INTO tiles SELECT * FROM r9.tiles;
#REPLACE INTO tiles SELECT * FROM r10.tiles;
#REPLACE INTO tiles SELECT * FROM r11.tiles;
#REPLACE INTO tiles SELECT * FROM r12.tiles;
#CREATE UNIQUE INDEX tile_index on tiles (zoom_level, tile_column, tile_row);
#UPDATE metadata SET value = 'jaxa_terrainrgb_0-12' WHERE name = 'name' AND value = '';
#UPDATE metadata SET value = 'JAXA ALOS World 3D 30m (AW3D30) converted with rio rgbify' WHERE name = 'description';
#UPDATE metadata SET value = 'png' WHERE name = 'format';
#UPDATE metadata SET value = '1' WHERE name = 'version';
#UPDATE metadata SET value = 'baselayer' WHERE name = 'type';
#INSERT INTO metadata (name,value) VALUES(''attribution'',''<a href="https://earth.jaxa.jp/en/data/policy/">AW3D30 (JAXA)</a>'');
#PRAGMA journal_mode=DELETE;
#"
