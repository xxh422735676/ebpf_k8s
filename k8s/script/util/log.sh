#!/bin/bash

#Environment

LOG_FILE="$(date +'%Y-%m-%dT%H:%M:%S.%N%z').log"


# Functions

function log::error() {
  # error log
  
  local item; item="[$(date +'%Y-%m-%dT%H:%M:%S.%N%z')]: \033[31mERROR:   \033[0m$*"
  ERROR_INFO="${ERROR_INFO}${item}\n  "
  echo -e "${item}" | tee -a "$LOG_FILE"
}


function log::info() {
  # basic log
  
  printf "[%s]: \033[32mINFO:    \033[0m%s\n" "$(date +'%Y-%m-%dT%H:%M:%S.%N%z')" "$*" | tee -a "$LOG_FILE"
}


function log::warning() {
  # warning log
  
  printf "[%s]: \033[33mWARNING: \033[0m%s\n" "$(date +'%Y-%m-%dT%H:%M:%S.%N%z')" "$*" | tee -a "$LOG_FILE"
}


function log::access() {
  # access infomation log
  
  ACCESS_INFO="${ACCESS_INFO}$*\n  "
  printf "[%s]: \033[32mINFO:    \033[0m%s\n" "$(date +'%Y-%m-%dT%H:%M:%S.%N%z')" "$*" | tee -a "$LOG_FILE"
}


function log::exec() {
  # execution command log
  
  printf "[%s]: \033[34mEXEC:    \033[0m%s\n" "$(date +'%Y-%m-%dT%H:%M:%S.%N%z')" "$*" >> "$LOG_FILE"
}
