#!/bin/bash
#install bcc libbpf into system

## configuration vars
# set -x
set -e

set -o errtrace         # Make sure any error trap is inherited
set -o nounset          # Disallow expansion of unset variables
set -o pipefail         # Use last non-zero exit code in a pipeline

INSTALL_SOFTWARE=""
UBUNTU_VERSION=""
LOG_FILE=$(date +'%Y-%m-%dT%H:%M:%S').log


## files inclued
source ./util/include.sh



## functions
 
function install::precheck(){
    log::info "prechecking"
    UBUNTU_VERSION=$(lsb_release -r | sed -n "/Release/p" | awk '{print $2}')
    log::info "UBUNTU_VERSION: ${UBUNTU_VERSION}" 

    return 0
}

function install::bcc(){
    INSTALL_SOFTWARE='bcc'
    log::info "installing bcc" 
    install::precheck
    if [[ $? -eq 0 ]]
    then
        log::info "precheck passed!"
    else
        log::error "precheck failed!" 
        return 1
    fi
    
    log::exec 'echo zero;echo one' 'echo two' 'echo three'
    exit

    log::exec 'cd /tmp; mkdir install_${INSTALL_SOFTWARE}; cd install_${INSTALL_SOFTWARE};'
    log::exec 'git clone https://github.com/iovisor/bcc.git; cd bcc;'
    # #for ubuntu18.04
    
    if [ $UBUNTU_VERSION == '18.04' ] 
    then
        log::exec 'git checkout v0.24.0'
    fi

    log::exec 'mkdir build; cd build; cmake ..'
    log::exec 'sudo make; sudo make install'
    log::exec 'cmake -DPYTHON_CMD=python3 ..' # build python3 binding
    log::exec 'pushd src/python/; sudo make; sudo make install; popd'

}

function install::libbpf(){
    log::info "installing libbpf"
}

for  arg in $*
do
    if [ $arg == 'bcc' ] 
    then
        install::$arg
    elif [ $arg == 'libbpf' ]
    then
        log::info $arg
    else
        log::info "not hit" $arg
    fi
    if [[ $? -ne 0 ]] 
    then
        log::error "fatal error occured!"
        exit
    fi
done