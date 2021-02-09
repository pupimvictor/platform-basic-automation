#!/bin/bash -e

__DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source $__DIR/helpers.sh
source $__DIR/tkgi.sh
source $__DIR/target-bosh.sh
source $__DIR/s3.sh
source $__DIR/uaa.sh
source $__DIR/credhub.sh
source $__DIR/pivnet.sh
source $__DIR/concourse.sh

function whereami () {
    printHeader Kubernetes
    kubectx
    kubens

    printHeader OpsManager
    echo $OM_TARGET
    echo $OM_USERNAME

    printHeader Bosh
    bosh env

    printHeader Concourse
    fly status

    printHeader Credhub
    credhub api

    printHeader uaac
    uaac target
}