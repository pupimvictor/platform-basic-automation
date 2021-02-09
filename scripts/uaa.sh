#!/bin/bash -e

function uaa_login () {
# todo: find right password key
  ADMIN_PASSWORD=$(om credentials \
      -p pivotal-container-service \
      -c '.properties.uaa_admin_management_password' \
      -f secret)

  uaa_target "$TKGI_SUBDOMAIN_NAME.$TKGI_DOMAIN_NAME:8443"    

  uaac token client get admin -s "$ADMIN_PASSWORD"
}

function uaa_target () {
  uaac target "${1}"
}