#!/bin/bash

apt update ; \
apt install -y docker.io && \
mkdir /mnt/minio && \
docker run -d -p 80:9000 -p 443:9000 --name minio -e "MINIO_ACCESS_KEY=${access_key}" -e "MINIO_SECRET_KEY=${secret_key}" -v /mnt/minio:/data minio/minio server /data