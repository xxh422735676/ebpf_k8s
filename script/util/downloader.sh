#!/bin/bash
# dedicated file to download file

# USAGE: download::file [URL] [FILENAME]

function download::file() {
    #download file using wget
    log::info "downloading file"
    if [ $#<1 ] 
    then
        log:error "download argc error!"
        exit
    fi
    if [ $#==2 ]
    then
        log::exec "wget '$1' --tries=2 -nc -O $2"
    fi
    if [ $#==1 ]
    then 
        log::exec "wget '$1' --tries=2 -nc"
    fi
}
