#!/bin/bash
# log info/error to file an print to screen

function log::exec() {
  # execution command log
  
    printf "[%s]: \033[34mEXEC:    \033[0m%s\n" "$(date +'%Y-%m-%dT%H:%M:%S.%N%z')" "$*" | sed -e 's%\x1b\[34m%%g;s%\x1b\[0m%%g' | tee -a "$LOG_FILE" | sed -e 's%EXEC%\x1b\[34mEXEC:    \x1b\[0m%g'
    sleep 2
    while (( $#>0 ))   
    do
        if [[ $? -eq 0 ]]
        then
            eval $1
            shift
        else 
             log::error 'fail to execute command: ' $1
             exit
        fi
        sleep 1
    done
}

function log::error() {
  # error log
  
    local item; item="[$(date +'%Y-%m-%dT%H:%M:%S.%N%z')]: \033[31mERROR:   \033[0m$*"
    ERROR_INFO="${ERROR_INFO}${item}\n  "
    echo -e "${item}" | sed -e 's%\x1b\[31m%%g;s%\x1b\[0m%%g'| tee -a "$LOG_FILE" | sed -e 's%ERROR%\x1b\[31mERROR:   \x1b\[0m%g'
    sleep 2
}


function log::info() {
  # basic log
  
    printf "[%s]: \033[32mINFO:    \033[0m%s\n" "$(date +'%Y-%m-%dT%H:%M:%S.%N%z')" "$*"   | sed -e 's%\x1b\[32m%%g;s%\x1b\[0m%%g' | tee -a "$LOG_FILE" |  sed  -e 's%INFO%\x1b\[32mINFO:    \x1b\[0m%g'
    sleep 2

}
