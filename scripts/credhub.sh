#!/bin/bash -e

__DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

  [[ -f "${__DIR}/target-bosh.sh" ]] &&  \
    source "${__DIR}/target-bosh.sh" ||  \
    echo "target-bosh.sh not found"
    
function cred_find () {
    local name="${1}"

    credhub find -n "$name"
}

function cred_local_find () {
    local name="${1}"

    ch_find "/concourse/$ENV_NAME-$REGION/$name"
}

function cred_get () {
    local name="${1}"

    credhub get -n "/concourse/$ENV_NAME-$REGION/$name"
}