#!/bin/bash

prun()
{

    echo $1
	infile="input/$1"
	hs="tmp/hs_$1"
	gh="tmp/gh_$1"
	cr="tmp/cr_$1"
	mg=merged/"$(basename -- $infile)"
	
	#Create Hillshade image
    gdaldem hillshade -az 45 -z 1.3 $infile $hs

	#Create a gamma hillshade image
    gdal_calc.py -A $hs --outfile=$gh --calc="uint8(((A / 255.)**(1/0.5)) * 255)"

	#create color releif image
    gdaldem color-relief $infile color-relief.txt $cr

    #Merge the gamma hillshade and color releif image
    #gdal_calc.py -A $gh -B $cr --allBands=B --calc="uint8( ( 2 * (A/255.)*(B/255.)*(A<128) + ( 1 - 2 * (1-(A/255.))*(1-(B/255.)) ) * (A>=128) ) * 255 )" --outfile=$mg
    gdal_calc.py -A $gh -B $cr --allBands=B --calc="uint8(2*(A/255.)*(B/255.)*(A<128)*255 + B * (A>=128) )" --outfile=$mg

    rm -f $hs
    rm -f $gh
    rm -f $cr
}

export -f prun

# run in parallel using 20 thread/connection
ls input/ > filenames.txt
xargs -P 20 -n 1 -I {} bash -c "prun '{}'" < filenames.txt