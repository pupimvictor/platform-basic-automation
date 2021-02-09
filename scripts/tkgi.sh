#!/bin/bash -e

__DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

function tkgi_admin_login () {
  if [ -z "${TKGI_DOMAIN_NAME}" ]; then
    echo "Enter domain: (e.g., pez.pivotal.io)"
    read -r TKGI_DOMAIN_NAME
  fi

  if [ -z "${TKGI_SUBDOMAIN_NAME}" ]; then
    echo "Enter subdomain: (e.g., haas-420)"
    read -r TKGI_SUBDOMAIN_NAME
  fi

  ADMIN_PASSWORD=$(om credentials \
      -p pivotal-container-service \
      -c '.properties.uaa_admin_password' \
      -f secret)

  printf "\n\nAdmin password: %s\n\n" "${ADMIN_PASSWORD}"

  tkgi login -a \
      "https://${TKGI_SUBDOMAIN_NAME}.${TKGI_DOMAIN_NAME}" \
      --skip-ssl-validation \
      -u admin \
      -p "${ADMIN_PASSWORD}" -k
}

function cluster_admin_access () {
  local CLUSTER_NAME
  if [ -z "${1}" ]; then
    tkgi clusters
    echo "..."
    echo "Enter cluster name: (e.g., cf-nexus-dev)"
    read -r CLUSTER_NAME
  elif [ -n "${1}" ]; then
    CLUSTER_NAME="${1}"
  fi

  tkgi_login

  tkgi get-credentials "${CLUSTER_NAME}"

  kubectl get all
}

function tkgi_login () {
  if [ -z "${TKGI_DOMAIN_NAME}" ]; then
    echo "Enter domain: (e.g., pez.pivotal.io)"
    read -r TKGI_DOMAIN_NAME
  fi

  if [ -z "${TKGI_SUBDOMAIN_NAME}" ]; then
    echo "Enter subdomain: (e.g., haas-420)"
    read -r TKGI_SUBDOMAIN_NAME
  fi

  if [ -z "$LDAP_USER_ID" ]; then
    echo "Enter user id: (e.g. sa-bdade)"
    read -r LDAP_USER_ID
  fi

  echo "Enter password for $LDAP_USER_ID:"
  read -r PASSWORD

  tkgi login -a \
      "https://${TKGI_SUBDOMAIN_NAME}.${TKGI_DOMAIN_NAME}" \
      --skip-ssl-validation \
      -u "${LDAP_USER_ID}" \
      -p "${PASSWORD}" -k

  tkgi clusters
}

function cluster_access () {
  local CLUSTER_NAME
  if [ -z "${1}" ]; then
    tkgi clusters
    echo "..."
    echo "Enter cluster name: (e.g., cf-nexus-dev)"
    read -r CLUSTER_NAME
  elif [ -n "${1}" ]; then
    CLUSTER_NAME="${1}"
  fi

  if [ -z "$LDAP_USER_ID" ]; then
    echo "Enter user id: (e.g. sa-bdade)"
    read -r LDAP_USER_ID
  fi

  echo "Enter password for $LDAP_USER_ID:"
  read -r PASSWORD

  tkgi get-kubeconfig -a \
      "https://${TKGI_SUBDOMAIN_NAME}.${TKGI_DOMAIN_NAME}" \
      --skip-ssl-validation \
      -u "${LDAP_USER_ID}" \
      -p "${PASSWORD}" -k

  kubectl config get-contexts
}