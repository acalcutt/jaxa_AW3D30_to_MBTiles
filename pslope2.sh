#!/bin/bash

prun()
{

	filename="input/$1"
	
	cc=merged2/"$(basename -s .tif $filename)_CC.tif"
	oc=merged2/"$(basename -s .tif $filename)_OC.tif"
	hs=merged2/"$(basename -s .tif $filename)_HS.tif"
	hsc=merged2/"$(basename -s .tif $filename)_HSC.tif"
	cr=merged2/"$(basename -s .tif $filename)_CR.tif"
	crc=merged2/"$(basename -s .tif $filename)_CRC.tif"
	vrt=merged2/"$(basename -s .tif $filename).vrt"
	
	echo $filename
	#produce a one band grey scale file with pixels values range=[1-255]
	gdaldem hillshade $filename $hs -alpha -s 111120 -z 5 -az 315 -alt 60 -compute_edges
	# filter the color band, keep greyness of relevant shadows below limit
	gdal_calc.py -A $hs  --outfile=$cc --calc="255*(A>220) +      A*(A<=220)"
	# filter the opacity band, keep opacity of relevant shadows below limit
	gdal_calc.py -A $hs  --outfile=$oc --calc="  1*(A>220) +(256-A)*(A<=220)"
	gdalbuildvrt -separate $vrt $cc $oc
	gdal_translate -a_nodata 0 -co COMPRESS=LZW -co ALPHA=YES $vrt $hsc
	rm $vrt
	rm $cc
	rm $oc
	rm $hs
		
	#create color releif image
    gdaldem color-relief $filename -alpha shade.ramp $cr
	gdal_translate -a_nodata 0 -co COMPRESS=LZW -co ALPHA=YES $cr $crc
	rm $cr

}

export -f prun

# run in parallel using 20 thread/connection
ls input/ > filenames.txt
xargs -P 20 -n 1 -I {} bash -c "prun '{}'" < filenames.txt