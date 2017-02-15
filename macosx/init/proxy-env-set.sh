#!/bin/bash

DEFAULT_HTTP_PROXY="http://www-proxy-ukc1.uk.oracle.com:80"

export HTTPS_PROXY=${DEFAULT_HTTP_PROXY}
export HTTP_PROXY=${DEFAULT_HTTP_PROXY}
export http_proxy=${DEFAULT_HTTP_PROXY}
export https_proxy=${DEFAULT_HTTP_PROXY}
export ftp_proxy=
export rsync_proxy=
