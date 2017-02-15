#!/bin/bash

DEFAULT_HTTP_PROXY="http://www-proxy-ukc1.uk.oracle.com:80"
DEFAULT_FTP_PROXY=
DEFAULT_RSYNC_PROXY=

function proxy-enable() {
  export HTTPS_PROXY=${DEFAULT_HTTP_PROXY}
  export HTTP_PROXY=${DEFAULT_HTTP_PROXY}
  export http_proxy=${DEFAULT_HTTP_PROXY}
  export https_proxy=${DEFAULT_HTTP_PROXY}
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

# alias proxy-enable="source ${TEMOS_HOME}/macosx/scripts/proxy-env-set.sh"
# alias proxy-disable="source ${TEMOS_HOME}/macosx/scripts/proxy-env-unset.sh"
alias proxy-list="env | grep proxy | sort"
