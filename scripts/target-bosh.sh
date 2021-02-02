#!/bin/bash -e

__DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

CREDS=$(om -t $OM_TARGET --skip-ssl-validation curl --silent \
     -p /api/v0/deployed/director/credentials/bosh_commandline_credentials | \
  jq -r .credential | sed 's/bosh //g')

echo "${CREDS}"

# this will set BOSH_CLIENT, BOSH_ENVIRONMENT, BOSH_CLIENT_SECRET, and BOSH_CA_CERT
# however, BOSH_CA_CERT will be a path that is only valid on the OM VM
array=($CREDS)
for VAR in "${array[@]}"; do
  export $VAR
done

OM_RSA_KEY=${OM_KEY:-~/.ssh/opsmanrsa}
export BOSH_ALL_PROXY="ssh+socks5://ubuntu@$OM_TARGET:22?private-key=$OM_RSA_KEY"

export BOSH_CA_CERT="$(om -t $OM_TARGET --skip-ssl-validation certificate-authorities -f json | \
    jq -r '.[] | select(.active==true) | .cert_pem')"

echo BOSH_CA_CERT
echo "${BOSH_CA_CERT}"

export CREDHUB_CLIENT=$BOSH_CLIENT
export CREDHUB_SECRET=$BOSH_CLIENT_SECRET
export CREDHUB_CA_CERT=$BOSH_CA_CERT
export CREDHUB_SERVER="https://$BOSH_ENVIRONMENT:8844"
