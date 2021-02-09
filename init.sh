#!/bin/bash -e

WORKSAPCE="$HOME/git/platform-basic-automation"
echo WORKSPACE: $WORKSAPCE
source $WORKSAPCE/scripts/helpers.sh
source $WORKSAPCE/scripts/tkgi.sh
source $WORKSAPCE/scripts/s3.sh
source $WORKSAPCE/scripts/uaa.sh
source $WORKSAPCE/scripts/credhub.sh
source $WORKSAPCE/scripts/pivnet.sh
source $WORKSAPCE/scripts/concourse.sh

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