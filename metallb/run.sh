#!/bin/bash

set -ex

K3S_MANIFEST_DIR=${K3S_MANIFEST_DIR:-/var/lib/rancher/k3s/server/manifests/}

getConfig() {
    local l=$1
    key=$(kairos-agent config get "${l}" | tr -d '\n')
    if [ "$key" != "null" ]; then
     echo "${key}"
    fi 
    echo   
}

# renovate: depName=metallb repoUrl=https://metallb.github.io/metallb
VERSION="0.16.1"
ADDRESS_POOL="192.168.1.10-192.168.1.20"

templ() {
    local file="$3"
    local value="$2"
    local sentinel="$1"
    sed -i "s/@${sentinel}@/${value}/g" "${file}"
}

readConfig() {
    _version=$(getConfig metallb.version)
    if [ "$_version" != "" ]; then
        VERSION=$_version
    fi
    _addresspool=$(getConfig metallb.address_pool)
    if [ "$_addresspool" != "" ]; then
        ADDRESS_POOL=$_addresspool
    fi
}

mkdir -p "${K3S_MANIFEST_DIR}"

readConfig

# Copy manifests, and template them
for FILE in assets/*; do 
  templ "VERSION" "${VERSION}" "${FILE}"
  templ "ADDRESS_POOL" "${ADDRESS_POOL}" "${FILE}"
done;

cp -rf assets/* "${K3S_MANIFEST_DIR}"
