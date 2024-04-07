#!/bin/sh
sudo docker run --rm --network=host --privileged -d astra-hotspot:v0.1 &&
    sudo docker run --rm -d -p 1883:1883 -p 9001:9001 -d astra-broker:v0.1 &&
    sudo docker run --rm --network=host --device /dev/gpiomem astra-publisher:v0.1 &&
    sudo docker run --rm -d -p 8000:8000 -d --mount type=bind,src=/images,target=/fileserver astra-file-server:v0.1
