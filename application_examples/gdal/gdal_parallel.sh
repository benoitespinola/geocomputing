#!/bin/bash

in=$1
in_file=$(basename $in)
out=/scratch/project_2002044/geocomputing/gdal/$in_file

#Change the coordinate system to EPSG:2393, which is the old Finnish YKJ (=KKJ3)
gdalwarp $in $out -co compress=deflate -co tiled=yes -t_srs EPSG:2393
# Add overviews
gdaladdo --config COMPRESS_OVERVIEW JPEG --config PHOTOMETRIC_OVERVIEW YCBCR --config INTERLEAVE_OVERVIEW PIXEL $out 4 16 64
