#!/bin/bash

DEFAULT_HTTP_PROXY="http://www-proxy-ukc1.uk.oracle.com:80"
DEFAULT_FTP_PROXY=
DEFAULT_RSYNC_PROXY=

function proxy-enable() {
  local _proxy=${DEFAULT_HTTP_PROXY}
  if [[ ! -z "$1" ]]; then 
    _proxy=$1 
  fi
  export HTTPS_PROXY=${_proxy}
  export HTTP_PROXY=${_proxy}
  export http_proxy=${_proxy}
  export https_proxy=${_proxy}
  export ftp_proxy=${DEFAULT_FTP_PROXY}
  export rsync_proxy=${DEFAULT_RSYNC_PROXY}
}

function proxy-disable() {
  unset HTTP_PROXY
  unset HTTPS_PROXY
  unset http_proxy
  unset https_proxy
  unset ftp_proxy
  unset rsync_proxy
}

alias proxy-enable="proxy-enable"
alias proxy-disable="proxy-disable"
alias proxy-list="env | grep proxy | sort"
