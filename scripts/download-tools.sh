#!/bin/bash -e

__DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo __DIR

source $__DIR/helpers.sh

function download_om () {
    local version="${1:-5.0.0}"
    local arch="${2:-linux}"

    local release_url="https://github.com/pivotal-cf/om/releases/download/%s/%s"
    local bin_name="om-$arch-$version"
    
    local release_location=$(printf $release_url $version $bin_name)

    download_and_install $release_location /usr/local/bin/om
}

function download_jq () {
    local version="${1:-1.6}"
    local arch="${2:-linux64}"

    local bin_name="jq-$arch"

    local release_url="https://github.com/stedolan/jq/releases/download/jq-$version/$bin_name"

    local release_location=$(printf $release_url $version $bin_name)

    download_and_install $release_location /usr/local/bin/jq
}


function download_pivnet_cli () {
    local version="${1:-1.0.4}"
    local arch="${2:-linux-amd64}"

    local bin_name="pivnet-$arch-$version"

    local release_url="https://github.com/pivotal-cf/pivnet-cli/releases/download/v$version/$bin_name"

    local release_location=$(printf $release_url $version $bin_name)

    download_and_install $release_location /usr/local/bin/pivnet
}
