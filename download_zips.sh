#!/bin/bash

mywget()
{
	# Note: replace 'username@foo.lan' with your jaxa id and 'password' with your jaxa password
	(cd download; curl -O -u username@foo.lan:password "$1")
}

export -f mywget
mkdir -p download

# run wget in parallel using 8 thread/connection
xargs -P 8 -n 1 -I {} bash -c "mywget '{}'" < file_list_zip.txt

#unzip the DSM tif files
unzip -j download/\*.zip "*_DSM.tif" -d input/