#!/bin/sh

scp run_docker.sh astra@192.168.0.64:run_docker.sh
scp import-images.sh astra@192.168.0.64:import-images.sh
cd publisher || exit
./deploy.sh
cd ../
cd hotspot || exit
./deploy.sh
cd ../
cd file_server || exit
./deploy.sh
cd ../
cd broker || exit
./deploy.sh
