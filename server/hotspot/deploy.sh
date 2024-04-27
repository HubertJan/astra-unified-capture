#!/bin/sh

docker image build --platform linux/arm/v7 -t astra-hotspot:v0.1 .
docker save -o astra-hotspot.tar astra-hotspot
scp astra-hotspot.tar astra@192.168.0.64:astra-hotspot.tar
