# jaxa_AW3D30_to_MBTiles
Scripts to create a mbtiles file from jaxa AW3D30 elevation images. To download jaxa data please register an account with them first.


Steps
1.) Download JAXA XML files which contain zip urls. Extract the urls from the XML file and place them into file_list_zip.txt. (ex. I used 'download_xml.sh', merged the xml files into one big file, then put the text into a website thate would strip out the urls)

2.) Download all the JAXA zip files (ex. download_zips.sh). Extract all the *_DSM.tif files and place them into a 'input' folder in this scipts directory

3.) Generate Transparent Hillshade, Color Releif, and Merged Files (ex. 'create_hs_cr_images.sh' or 'create_hs_cr_images_parallel.sh')

4.) Create a mbtiles tileset (ex. 'export_hillshade_mbtiles.sh' or 'export_color_mbtiles.sh', or 'export_combined_mbtiles.sh')
