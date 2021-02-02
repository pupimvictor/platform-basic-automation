#!/bin/bash -e

function uaa_login () {
  [[ -f "${__DIR}/target-bosh.sh" ]] &&  \
    source "${__DIR}/target-bosh.sh" ||  \
    echo "target-bosh.sh not found"

# todo: find right password key
  ADMIN_PASSWORD=$(om credentials \
      -p pivotal-container-service \
      -c '.properties.uaa_admin_management_password' \
      -f secret)

  uaac token client get admin -s "$ADMIN_PASSWORD"
}