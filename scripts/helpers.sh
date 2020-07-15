#!/bin/bash -e


function download_and_install () {
    local release_location="${1:- Need release location}"
    local install_location="${2:- Need install location}"
    
    echo "Downloading from $release_location"
    echo "----------------------------------"
    
    wget "${release_location}"

    chmod_and_mv $bin_name $install_location
}

function chmod_and_mv () {
    local bin_name="${1:? Need binary location}"
    local dest="${2:? Need executable destination}"
    
    echo "Installing $bin_name at $dest"
    echo "----------------------------------"

    sudo chmod +x $bin_name

    sudo mv $bin_name $dest

    if [[ $? == 0 ]]; then
        echo command succeed
    fi    
}



