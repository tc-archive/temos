#!/bin/bash

# *** WEB SERVERS *********************************************************************************
#

startWebServer() {
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

alias ws='startWebServer'
