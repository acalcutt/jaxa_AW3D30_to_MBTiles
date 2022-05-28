# jaxa_AW3D30_to_MBTiles
Scripts to create a mbtiles file from jaxa AW3D30 elevation images. To download jaxa data please register an account with them first.


1.) Download all the jaxa DEM images using download_zips.sh . This downloads all the zip files in file_list_zip.txt. ** Be sure to update the 'jaxa_account' and 'jaxa_password' before running download_zips.sh **

2.) Create a TerrainRGB mbtiles file using create_terrainrgb.sh . This will use gdal and rio rgbify to convert the jaxa dems into TerrainRGB.

3.) Create a Color Relief mbtiles file using export_color_mbtiles_v2.sh. This will use gdaldem color-relief to convert the jaxa dems into a color relief map

4.) Create a Hillshade mbtiles file using export_hillshade_mbtiles_v2.sh. This will use gdaldem hillshade to convert the jaxa dems into a hillshade map.
