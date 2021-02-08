#!/bin/bash -e

__DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $__DIR/helpers.sh


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

  [[ -f "${__DIR}/target-bosh.sh" ]] &&  \
    source "${__DIR}/target-bosh.sh" ||  \
    echo "target-bosh.sh not found"

  
  fly -t "$CONCOURSE_TARGET" login -t "https://$CONCOURSE_URL" \
      -u "${CONCOURSE_USERNAME}" \
      -p "${CONCOURSE_PASSWORD}" \
      -n "${CONCOURSE_TEAM}" \
      -k 
}