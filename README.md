# jaxa_AW3D30_to_MBTiles
Scripts to create a mbtiles file from jaxa AW3D30 elevation images. To download jaxa data please register an account with them first.

- Download all the jaxa DEM images using `download_zips.sh`. This downloads all the zip files in `file_list_zip.txt`. **Be sure to update the `USER` and `PASSWORD` before running `download_zips.sh`**

- Build custom docker image `docker build -t terrain:latest docker/` and run container with `docker run -ti -v $PWD:$PWD -w $PWD --rm terrain:latest`

- Create a Terrain mbtiles (This will use gdal and rio rgbify to convert the jaxa dems) using ...
    - `create_terrainrgb.sh` for mapbox terrainrgb encoding.
    - `create_terrarium.sh` for terrarium encoding.

- Create a Contour mbtiles file using ...

    - `create_contour_100_parallel.sh` to create the required geojson input for the next step

    - `export_contour_100_mbtiles.sh`. This will use `tippecanoe` (https://github.com/felt/tippecanoe) to create the contour mbtiles of the geojson input.

- Create a Color Relief mbtiles file using `export_color_mbtiles_v2.sh`. This will use gdaldem color-relief to convert the jaxa dems into a color relief map.

- Create a Hillshade mbtiles file using `export_hillshade_mbtiles_v2.sh`. This will use gdaldem hillshade to convert the jaxa dems into a hillshade map.
