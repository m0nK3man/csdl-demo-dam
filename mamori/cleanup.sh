#!/bin/bash

FOUND_CONTAINER=`docker ps -a -f "name=mamori-[0-9]+" -q 2> /dev/null`
if [[ $FOUND_CONTAINER == "" ]]; then
    echo "No old mamori containers found"
else
    echo Found old Mamori containers: $FOUND_CONTAINER
    docker rm $FOUND_CONTAINER
fi

FOUND_IMAGE=`docker images -f "reference=mamori-[0-9]*" -q 2> /dev/null`
echo $FOUND_IMAGE
if [[ $FOUND_IMAGE == "" ]]; then
    echo "No old mamori images found"
else
    echo Found old Mamori images: $FOUND_IMAGE
    docker image rm -f $FOUND_IMAGE
fi
