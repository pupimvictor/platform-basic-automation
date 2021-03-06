#!/bin/bash -e

__DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source $__DIR/helpers.sh

function download_om () {
    local version="${1:-5.0.0}"
    local arch="${2:- b linux}"

    local release_url="https://github.com/pivotal-cf/om/releases/download/%s/%s"
    local bin_name="om-$arch-$version"
    
    local release_location=$(printf $release_url $version $bin_name)

    download_and_install $release_location /usr/local/bin/om
}

function download_uaa () {
    local version="${1:-0.10.0}"
    local arch="${2:-linux-amd64}"

    local release_location="https://github.com/cloudfoundry-incubator/uaa-cli/releases/download/0.10.0/uaa-$arch-$version"
    local bin_name="uaa-$arch-$version"
    
    download_and_install $release_location /usr/local/bin/uaa
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

function download_helm () {
    local version="${1:-v3.3.0}"
    local arch="${2:-linux-amd64}"

    local bin_name="helm-$version-$arch.tar.gz"

    local release_url="https://get.helm.sh/$bin_name"

    wget "$release_url" -O $bin_name
    if [[ $? != 0 ]]; then
        printErr "could find helm release at $release_url"
        return 1
    fi
    
    tar -C . -xzvf $bin_name
    if [[ $? != 0 ]]; then
        printErr "failed decrompressing $bin_name"
        return 1
    fi
    
    chmod_and_mv $arch/helm /usr/local/bin/helm

    rm -rf $bin_name
    rm -rf $arch
}

function download_pks_cli () {
    [[ -f "${__DIR}/login-pivnet.sh" ]] &&  \
        source "${__DIR}/login-pivnet.sh" ||  \
        echo "login-pivnet.sh not found"

    pivnet download-product-files --product-slug='pivotal-container-service' --release-version='1.8.1' --product-file-id=737302
    
    local bin_name="pks-linux-amd64-1.8.0-build.75"
    
    chmod_and_mv $__DIR/$bin_name /usr/local/bin/pks
}
