#!/bin/bash

DEFAULT_HTTP_PROXY="http://www-proxy-ukc1.uk.oracle.com:80"
DEFAULT_FTP_PROXY=
DEFAULT_RSYNC_PROXY=

# enable the default or specified proxy
function proxy-on() {
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

# disable the terminal proxies
function proxy-off() {
  unset HTTP_PROXY
  unset HTTPS_PROXY
  unset http_proxy
  unset https_proxy
  unset ftp_proxy
  unset rsync_proxy
}

alias proxy-on="proxy-on"
alias proxy-off="proxy-off"
alias proxy-list="env | grep proxy | sort"
