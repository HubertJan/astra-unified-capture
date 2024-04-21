#!/bin/sh

docker image build --platform linux/arm/v7 -t astra-broker:v0.1 .
docker save -o astra-broker.tar astra-broker
scp astra-broker.tar hubat@192.168.0.62:astra-broker.tar
