#!/bin/bash

mywget()
{
	# Note: replace 'username@foo.lan' with your jaxa id and 'password' with your jaxa password
	(cd xml; curl -O -u username@foo.lan:password "$1")
}

export -f mywget
mkdir -p xml

# run wget in parallel using 8 thread/connection
xargs -P 8 -n 1 -I {} bash -c "mywget '{}'" < file_list_xml.txt