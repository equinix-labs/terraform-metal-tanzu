#!/bin/bash

curl -L https://github.com/vmware/govmomi/releases/download/v0.18.0/govc_linux_amd64.gz | gunzip > /usr/local/bin/govc
chmod +x /usr/local/bin/govc

export GOVC_INSECURE=1
export GOVC_URL=${VCVA_HOST}
export GOVC_USERNAME=${VCVA_USER}
export GOVC_PASSWORD=${VCVA_PASSWORD}
export GOVC_DATASTORE=Datastore
export GOVC_NETWORK=VM Network

govc import.ova --options=/root/nsx-manager.json /root/${NSX_MANAGER_OVA_FILE}

