#!/bin/sh

if [ "$#" -eq 0 ]; then
    # check if any container is running
    [ $(docker ps -q | wc -l) == 0 ] && exit 1 
    # scan all images
    scan_images.sh $(docker ps --format='{{.Image}}' | paste -s -d " " -)
else
    # scan given image
    scan_images.sh "$@"
fi
