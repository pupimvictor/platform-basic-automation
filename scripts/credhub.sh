#!/bin/bash -e

export CREDHUB_CLIENT=${1:- $BOSH_CLIENT}
export CREDHUB_SECRET=${2:- $BOSH_CLIENT_SECRET}
export CREDHUB_CA_CERT=${3:- $BOSH_CA_CERT}
export CREDHUB_SERVER=${4:- "https://$BOSH_ENVIRONMENT:8844"}

function set_credhub_env () {
    CREDHUB_CLIENT=${1:- $BOSH_CLIENT}
    CREDHUB_SECRET=${2:- $BOSH_CLIENT_SECRET}
    CREDHUB_CA_CERT=${3:- $BOSH_CA_CERT}
    CREDHUB_SERVER=${4:- "https://$BOSH_ENVIRONMENT:8844"}
}    

function credhub_login () {
    set_credhub_env 
    credhub api "${CREDHUB_SERVER}"
    credhub login
}

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
    local key="${2}"
    if [ -n "$key" ]; then
        key="-k $key"
    fi
    

    credhub get -n "/concourse/$ENV_NAME-$REGION/$name" "${key}"
}