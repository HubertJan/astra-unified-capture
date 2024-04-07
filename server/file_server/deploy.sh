#!/bin/sh

sudo docker image build --platform linux/arm/v7 -t astra-file-server:v0.1 .
docker save -o astra-file-server.tar astra-file-server
scp astra-file-server.tar hubat@192.168.0.62:astra-file-server.tar
