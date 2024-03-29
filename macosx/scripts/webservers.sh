#!/bin/bash

# *** WEB SERVERS *********************************************************************************
function _temos_start_web_server() {
    SERVER_TYPE=$1
    PORT=$2
    # default port
    if [[ -z $PORT ]]; then
        PORT=8080
    fi

    if [[ $SERVER_TYPE == 'python' ]]; then
        eval 'python -m SimpleHTTPServer $PORT'
    elif [[ $SERVER_TYPE == 'node' ]]; then
        # npm install http-server -g
        eval 'http-server -p $PORT'
    else
        echo 'Usage: webserver [python|node] [PORT]'
    fi
}
alias temos-ws-start='_temos_start_web_server'

