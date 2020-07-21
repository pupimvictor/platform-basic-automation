#!/bin/bash -e

__DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $__DIR/helpers.sh

function pivnet_login () {
    local pivnet_host

    checkExecutable "pivnet"
    if [ $? != 0 ]; then
        echo "pivnet CLI not found in PATH. Use download-tools.sh if you don't have it installed."
        return 1
    fi

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

pivnet_login