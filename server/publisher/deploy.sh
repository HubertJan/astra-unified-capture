#!/bin/sh

docker image build --platform linux/arm/v7 -t astra-publisher:v0.1 .
docker save -o astra-publisher.tar astra-publisher
scp astra-publisher.tar hubat@192.168.0.62:astra-publisher.tar
