#!/bin/bash
for filename in input/*_DSM.tif; do
	cc=merged3/"$(basename -s .tif $filename)_CC.tif"
	oc=merged3/"$(basename -s .tif $filename)_OC.tif"
	hs=merged3/"$(basename -s .tif $filename)_HS.tif"
	hsc=merged3/"$(basename -s .tif $filename)_HSC.tif"
	gh=merged3/"$(basename -s .tif $filename)_GH.tif"
	ghc=merged3/"$(basename -s .tif $filename)_GHC.tif"
	cr=merged3/"$(basename -s .tif $filename)_CR.tif"
	crc=merged3/"$(basename -s .tif $filename)_CRC.tif"
	vrt=merged3/"$(basename -s .tif $filename).vrt"
	fin=merged3/"$(basename -s .tif $filename)_FIN.tif"
	mg=merged3/"$(basename -s .tif $filename)_MG.tif"
	mgc=merged3/"$(basename -s .tif $filename)_MGC.tif"
	
	echo $filename
	#produce a one band grey scale file with pixels values range=[1-255]
	gdaldem hillshade $filename $hs -alpha -s 111120 -z 5 -az 315 -alt 60 -compute_edges
	# filter the color band, keep greyness of relevant shadows below limit
	##gdal_calc.py -A $hs  --outfile=$cc --calc="255*(A>220) +      A*(A<=220)"
	# filter the opacity band, keep opacity of relevant shadows below limit
	##gdal_calc.py -A $hs  --outfile=$oc --calc="  1*(A>220) +(256-A)*(A<=220)"
	##gdalbuildvrt -separate $vrt $cc $oc
	##gdal_translate -a_nodata 0 -co COMPRESS=LZW -co ALPHA=YES $vrt $hsc
	#rm $vrt
	#rm $cc
	#rm $oc
	#rm $hs
		
	#create color releif image
    gdaldem color-relief $filename -alpha shade.ramp $cr
	gdal_translate -a_nodata 0 -co COMPRESS=LZW -co ALPHA=YES $cr $crc
	rm $cr
	
	#Create a gamma hillshade image
    gdal_calc.py -A $hs --outfile=$gh --calc="uint8(((A / 255.)**(1/0.5)) * 255)"
	rm $hs
	
	#Merge the gamma hillshade and color releif image
	#gdalbuildvrt $vrt $crc $hsc
	#gdal_translate -a_nodata 0 -co COMPRESS=LZW -co ALPHA=YES $vrt $fin
	
	#tiffcp -c lzw $hsc $crc $fin
	#gdalbuildvrt -separate $vrt $hsc $crc
	#gdal_translate -co COMPRESS=LZW -co ALPHA=YES $vrt $fin
    gdal_calc.py -A $gh -B $crc --allBands=B --calc="uint8(2*(A/255.)*(B/255.)*(A<128)*255 + B * (A>=128) )" --outfile=$mg
	gdal_translate -co COMPRESS=LZW -co ALPHA=YES $mg $fin
	#rm $gh
	#rm $cr
	#rm $mg
	#rm $crc

    #Merge the gamma hillshade and color releif image
    #gdal_calc.py -A $gh -B $cr --allBands=B --calc="uint8(2*(A/255.)*(B/255.)*(A<128)*255 + B * (A>=128) )" --outfile=$mg
	#rm $gh
	#rm $cr
	
	#gdalbuildvrt -addalpha -hidenodata -srcnodata "0" $vrt $mg
	#gdal_translate -co COMPRESS=LZW -co ALPHA=YES $vrt $fin
	#rm $vrt
	#rm $mg
	
	#gdal_calc.py -A $mg --outfile=$oc --calc="  1*(A>220) +(256-A)*(A<=220)"
	
	#gdalbuildvrt -addalpha -hidenodata -srcnodata "0" $vrt $mg
	#gdal_translate $vrt $fin

	#gdal_translate $vrt $fin
	#rm $vrt
	#rm $mg
	#rm $oc

	exit
done
