#!/bin/sh

sudo docker image build --platform linux/arm/v7 -t astra-hotspot:v0.1 .
docker save -o astra-hotspot.tar astra-hotspot
scp astra-hotspot.tar hubat@192.168.0.62:astra-hotspot.tar
