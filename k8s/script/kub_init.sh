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

# Functions

function log::error() {
  # 错误日志
  
  local item; item="[$(date +'%Y-%m-%dT%H:%M:%S.%N%z')]: \033[31mERROR:   \033[0m$*"
  ERROR_INFO="${ERROR_INFO}${item}\n  "
  echo -e "${item}" | tee -a "$LOG_FILE"
}


function log::info() {
  # 基础日志
  
  printf "[%s]: \033[32mINFO:    \033[0m%s\n" "$(date +'%Y-%m-%dT%H:%M:%S.%N%z')" "$*" | tee -a "$LOG_FILE"
}


function log::warning() {
  # 警告日志
  
  printf "[%s]: \033[33mWARNING: \033[0m%s\n" "$(date +'%Y-%m-%dT%H:%M:%S.%N%z')" "$*" | tee -a "$LOG_FILE"
}


function log::access() {
  # 访问信息
  
  ACCESS_INFO="${ACCESS_INFO}$*\n  "
  printf "[%s]: \033[32mINFO:    \033[0m%s\n" "$(date +'%Y-%m-%dT%H:%M:%S.%N%z')" "$*" | tee -a "$LOG_FILE"
}


function log::exec() {
  # 执行日志
  
  printf "[%s]: \033[34mEXEC:    \033[0m%s\n" "$(date +'%Y-%m-%dT%H:%M:%S.%N%z')" "$*" >> "$LOG_FILE"
}