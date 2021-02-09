#!/bin/bash -e

function s3_login () {
    local_access_key=$(cred_get s3_local_admin user)
    local_secret_access_key=$(cred_get s3_local_admin password)

    plat_access_key=$(cred_get s3_admin user)
    plat_secret_access_key=$(cred_get s3_admin password)


    creds="
[envprofile] 
aws_access_key_id = $local_access_key 
aws_secret_access_key = $local_secret_access_key
region = $REGION

[platprofile] 
aws_access_key_id = $plat_access_key 
aws_secret_access_key = $plat_secret_access_key
region = $REGION
"

    echo "$creds" > ~/.aws/credetials

    config="
[default]
region=$REGION
output=json
"

    echo "$config" > ~/.aws/credentials

    aws configure
}

function s3_get () {
    aws s3 cp "${1}" "${2}"
}

function s3_get_clis () {
    s3_login

    s3_get $S3_PRODUCTS_BUCKET/clis/om-linux-5.0.0
    chmod_and_mv om-linux-5.0.0 /usr/local/bin/om

    s3_get $S3_PRODUCTS_BUCKET/clis/tkgi-linux-1.9.0
    chmod_and_mv tkgi-linux-1.9.0 /usr/local/bin/tkgi

    s3_get $S3_PRODUCTS_BUCKET/clis/bosh
    chmod_and_mv bosh /usr/local/bin/bosh

    s3_get $S3_PRODUCTS_BUCKET/clis/credhub
    chmod_and_mv credhub /usr/local/bin/credhub

    s3_get $S3_PRODUCTS_BUCKET/clis/fly
    chmod_and_mv fly /usr/local/bin/fly
}