#!/bin/bash

set -ex

K3S_MANIFEST_DIR=${K3S_MANIFEST_DIR:-/var/lib/rancher/k3s/server/manifests/}


getConfig() {
    local key=$1
    _value=$(kairos-agent config get "${key} | @json" | tr -d '\n')
    # Remove the quotes wrapping the value.
    _value=${_value:1:${#_value}-2}
    if [ "${_value}" != "null" ]; then
     echo "${_value}"
    fi 
    echo   
}

VALUES="{}"
# renovate: depName=kyverno repoUrl=https://kyverno.github.io/kyverno/
VERSION="3.8.2"

templ() {
    local file="$3"
    local value=$2
    local sentinel=$1
    sed -i "s/@${sentinel}@/${value}/g" "${file}"
}

readConfig() {
    _values=$(getConfig kyverno.values)
    if [ "$_values" != "" ]; then
        VALUES=$_values
    fi
    _version=$(getConfig kyverno.version)
    if [ "$_version" != "" ]; then
        VERSION=$_version
    fi
}

mkdir -p "${K3S_MANIFEST_DIR}"

readConfig

# Copy manifests, and template them
for FILE in assets/*; do 
  templ "VALUES" "${VALUES}" "${FILE}"
  templ "VERSION" "${VERSION}" "${FILE}"
done;

cp -rf assets/* "${K3S_MANIFEST_DIR}"
