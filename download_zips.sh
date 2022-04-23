#!/bin/bash

mywget()
{
	wget --user 'jaxa_account' --password 'jaxa_password' --post-data 'username=jaxa_account&password=jaxa_password' "$1"
}

export -f mywget

# run wget in parallel using 8 thread/connection
xargs -P 8 -n 1 -I {} bash -c "mywget '{}'" < file_list_zip.txt

#unzip the DSM tif files
unzip -j download/\*.zip "*_DSM.tif" -d input/