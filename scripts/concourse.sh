#!/bin/bash -e

function fly_login () {
  if [ -z "${CONCOURSE_URL}" ]; then
    echo "Enter concourse url: (e.g., concourse.carefirst.com)"
    read -r CONCOURSE_URL
  fi

  if [ -z "${CONCOURSE_TARGET}" ]; then
    echo "Enter concourse target: (e.g., np)"
    read -r CONCOURSE_TARGET
  fi

  if [ -z "${CONCOURSE_TEAM}" ]; then
    echo "Enter concourse team: (e.g., nonprod-useast1)"
    read -r CONCOURSE_TEAM
  fi
  
  fly -t "$CONCOURSE_TARGET" login -t "https://$CONCOURSE_URL" \
      -u "${CONCOURSE_USERNAME}" \
      -p "${CONCOURSE_PASSWORD}" \
      -n "${CONCOURSE_TEAM}" \
      -k 
}

function fly_target () {
  fly -t "$1" login -t "https://$CONCOURSE_URL" \
      -u "${CONCOURSE_USERNAME}" \
      -p "${CONCOURSE_PASSWORD}" \
      -k 
}