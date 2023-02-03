#!/bin/bash
###################################################################
#Script Name    : kub_init.sh
#Description    : Install kubernetes cluster using kubeadm.
#Author         : xxh422735676
#Email          : 422735676@qq.com
###################################################################

set -x
set -e

set -o errtrace         # Make sure any error trap is inherited
set -o nounset          # Disallow expansion of unset variables
set -o pipefail         # Use last non-zero exit code in a pipeline

# Enviroment Configuration

SSHPASS="Scott0205"




function kub::check() {
    # pre-flight check
    if [[ "$OSTYPE" != "linux-gnu"* ]]; then
        log::error "check" "OSTYPE is $OSTYPE"
    else
        log::info "check" "OSTYPE is $OSTYPE"
    fi

}

function kub::install() {
    # install 

    tools::install

    docker::install


}