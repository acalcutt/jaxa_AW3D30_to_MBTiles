#!/bin/bash
for filename in input/*_DSM.tif; do
    echo $filename
	hs=tmp/hs.tif
	gh=tmp/gh.tif
	cr=tmp/cr.tif
	mg=merged/"$(basename -- $filename)"
	
	#Create Hillshade image
    gdaldem hillshade -az 45 -z 1.3 $filename $hs

	#Create a gamma hillshade image
    gdal_calc.py -A $hs --outfile=$gh --calc="uint8(((A / 255.)**(1/0.5)) * 255)"

	#create color releif image
    gdaldem color-relief $filename color-relief.txt $cr

    #Merge the gamma hillshade and color releif image
    #gdal_calc.py -A $gh -B $cr --allBands=B --calc="uint8( ( 2 * (A/255.)*(B/255.)*(A<128) + ( 1 - 2 * (1-(A/255.))*(1-(B/255.)) ) * (A>=128) ) * 255 )" --outfile=$mg
    gdal_calc.py -A $gh -B $cr --allBands=B --calc="uint8(2*(A/255.)*(B/255.)*(A<128)*255 + B * (A>=128) )" --outfile=$mg

    rm -f $hs
    rm -f $gh
    rm -f $cr
done
