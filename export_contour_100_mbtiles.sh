#!/usr/bin/env bash

tippecanoe \
    `# Set min zoom to 11` \
    -Z7 \
    `# Set max zoom to 13` \
    -z13 \
    `# Read features in parallel; only works with GeoJSONSeq input` \
    -P \
    `# Keep only the ele_ft attribute` \
    -y elev \
    `# Put contours into layer named 'contour_100m'` \
    -l contour_100m \
    `# Export to contour_250m.mbtiles` \
    -o contour_100m.mbtiles \
    --no-feature-limit --no-tile-size-limit \
    json_100/*.geojson