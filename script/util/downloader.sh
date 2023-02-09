#!/bin/bash
# dedicated file to download file


function download::file() {
    #download file using wget
    log::info "downloading file"
    if [ $#<2 ] 
    then
        log:error "download argc error!"
        exit
    fi
    log::exec "wget '$1' --tries=2 -nc -O $2"
}
