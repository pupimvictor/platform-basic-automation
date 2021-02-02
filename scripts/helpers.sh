#!/bin/bash -e


function download_and_install () {
    local release_location="${1:- Need release location}"
    local install_location="${2:- Need install location}"
    local install_location="${2:- Need install location}"
    
    printHeader "Downloading from $release_location"
    
    wget "${release_location}"

    chmod_and_mv $bin_name $install_location
}

function chmod_and_mv () {
    local bin_name="${1:? Need binary location}"
    local dest="${2:? Need executable destination}"
    
    printHeader "Installing $bin_name at $dest"
    
    sudo chmod +x $bin_name

    sudo mv $bin_name $dest

    if [[ $? == 0 ]]; then
        echo command succeed
    fi    
}

function checkExecutable() {
    local executable=$(command -v $1)
    echo $?
    echo $executable
    if ! [ -x $executable ]; then
        echo "$1 CLI not found in PATH. Check README for installation guide"
        return 1
    fi
}

function printStatusMsg {
  echo ""
  echo "============= $* ============="
  echo ""
}

function printHeader () {
  echo ""
  echo ">>>>>>>>>>>>> $* <<<<<<<<<<<<<"
  echo ""
}

function printInfo {
  echo "[INFO]: $*"
  echo ""
}

function printErr {
  >&2 echo "[ERROR]: $*"
}


