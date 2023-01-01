#!/usr/bin/env bash

# Darcy Buskermolen <darcy@dbitech.ca>

# Script to download all the changed tiles of the AW3D30 dataset
# uses both curl and wget

# TODO
# bounding box implementation needs to be completed
# investigate allowing parralell fetches
# clean up the arg handleing, make the output comandline defainable. 
# script should have some additional sanity checks, and implement a --force flag



help() {
  echo
  echo "Syntax: $0 [-h|v|bb]"
  echo "options:"
  echo "h     Print this help."
  echo "v     Verbose mode."
  echo "V     Print software version and exit."
  echo "f     Pass the filename to program."
  echo "b     BoundingBox to fetch."
  echo "         $0 -b \"-178.2,6.6,-49.0,83.3\""
  echo
}

download() {
    # I've noticed that non-existant tiles return a 302 response code.
    # We will only fetch the data that has a url returning a 200 response code.
    local filename=$1
    local url=https://www.eorc.jaxa.jp/ALOS/aw3d30/data/release_v2012/${filename}
    echo Cheking $url
    local respcode=$(curl -o /dev/null --silent -Iw '%{http_code}' $url)
    echo Response code:  $respcode
    if [ $respcode -eq 200 ]; then
        echo Downloading...
        wget --content-disposition -c -N -q --show-progress $url
    fi
    if [ ! -z "${RUNPROCESS}" ]; then
      doProcess ${filename}
    fi
}

doProcess() {
  local filename=$1
  retval=`${RUNPROCESS} ${filename}`
  return $?
}

scaleup() {
  local DIRECTION=${2}
  local VAR=(${1//./ })
  local INT=${VAR[0]}
  if [ $[INT] -lt 0 ]; then
    INT=$((INT*-1))
  fi
  if [ -z ${VAR[1]} ]; then
    INT=$((INT+1))
  fi   
  local RES=$((INT/5))
  if [ $((INT%5)) -ne 0 ]; then
    RES=$((RES+1))
  fi
  return "$((RES*5))"
}

# Northern Hemisphere
doNorth() {
  for (( lat=0; lat<=${NORTH}; lat=lat+5 )) do
    # North-East corner
    for (( lon=0; lon<=$EAST; lon=lon+5 )) do
        file="N$(printf '%03d' $lat)E$(printf '%03d' $lon)_N$(printf '%03d' $((10#$lat + 05)))E$(printf '%03d' $((10#$lon + 05))).zip"
        download $file
    done
    # North-West corner
    for (( lon=0; lon <=$WEST; lon=lon+5 )) do
        if [ $lon -eq 005 ]; then
            secondLonHem="E"
        else
            secondLonHem="W"
        fi
        file="N$(printf '%03d' $lat)W$(printf '%03d' $lon)_N$(printf '%03d' $((10#$lat + 05)))${secondLonHem}$(printf '%03d' $((10#$lon - 05))).zip"
        download $file
    done
  done
}

# Southern Hemisphere
doSouth() {
  for (( lat=5; lat<=$SOUTH; lat=lat+5 )) do
    # South-East corner
    for (( lon=000; lon<=$EAST; lon=lon+5 )) do
        if [ $lat -eq 005 ]; then
            secondLatHem="N"
        else
            secondLatHem="S"
        fi
        file="S$(printf '%03d' $lat)E$(printf '%03d' $lon)_${secondLatHem}$(printf '%03d' $((10#$lat - 05)))E$(printf '%03d' $((10#$lon + 05))).zip"
        download $file
    done
    # South-West corner
    for (( lon=5; lon<=$WEST; lon=lon+5 )) do
      if [ $lat -eq 005 ]; then
            secondLatHem="N"
        else
            secondLatHem="S"
        fi
        if [ $lon -eq 005 ]; then
            secondLonHem="E"
        else
            secondLonHem="W"
        fi
        file="S$(printf '%03d' $lat)W$(printf '%03d' $lon)_${secondLatHem}$(printf '%03d' $((10#$lat - 05)))${secondLonHem}$(printf '%03d' $((10#$lon - 05))).zip"
        download $file
    done
  done
}


WEST=180
EAST=175
SOUTH=85
NORTH=80

while getopts ":hvVb:f:" option; do
  case "${option}" in
    h)
      help
      exit;;
    v)
      VERBOSE=1;;
    V)
      echo ${VERSION}
      exit;;
    f)
      RUNPROCESS=${OPTARG};;
    b)
      #BBox has the format W,S,E,N
      BBOX=(${OPTARG//,/ })
      WESTB=${BBOX[0]}
      NORTHB=${BBOX[3]}
      EASTB=${BBOX[2]}
      SOUTHB=${BBOX[1]}

      echo "North ${NORTHB} East ${EASTB} South ${SOUTHB} West ${WESTB}"
      
      scaleup ${WESTB} W
      WEST=$?
      scaleup ${EASTB} E
      EAST=$?
      scaleup ${NORTHB} N
      NORTH=$?
      scaleup ${SOUTHB} S
      SOUTH=$?
      echo "North ${NORTH} East ${EAST} South ${SOUTH} West ${WEST}";;
    \?)
      echo "Error: Invalid option"
      exit;;
  esac
done

doNorth
doSouth
