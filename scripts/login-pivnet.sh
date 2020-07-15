#!/bin/bash -e

function pivnet_login () {
    local pivnet_host

    if [ -z "$PIVNET_TOKEN" ]; then
        echo "Pivnet api token required. export env var PIVNET_TOKEN to proceed"
        exit 1
    fi

    if [ -n "${1}" ]; then
        pivnet_host="--host=${1}"
    fi
    
    echo "Pivnet Login..."
    pivnet login --api-token=$PIVNET_TOKEN $pivnet_host
}
