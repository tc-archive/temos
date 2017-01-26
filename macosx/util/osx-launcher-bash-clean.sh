#!/bin/bash

# default parameters
#
CMD=$1
APP_NAME=$2

function list_apps {
    sqlite3 $(sudo find /private/var/folders -name com.apple.dock.launchpad)/db/db \
        "select * from apps;"
}

function check_app {
    _APP_NAME="$1"
    RESULT=`sqlite3 $(sudo find /private/var/folders -name com.apple.dock.launchpad)/db/db \
        "select title from apps where title='${_APP_NAME}';" \
        | tail -n 1`
    if [[ ${RESULT} == $_APP_NAME ]]; then
        echo The app ${_APP_NAME} is registered.
    else
        echo The app ${_APP_NAME} is NOT registered.
    fi
}

function remove_app {
    _APP_NAME="$1"
    sqlite3 $(sudo find /private/var/folders -name com.apple.dock.launchpad)/db/db \
        "delete from apps where title=${_APP_NAME};" && killall Dock
}

if [[ ${CMD} == "list" ]]; then
    list_apps
elif [[ ${CMD} == "check"  ]]; then
    check_app ${APP_NAME}
elif [[ ${CMD} == "remove"  ]]; then
    remove_app ${APP_NAME}
else
    echo "Usage $0 <list>|<check>|<remove> <AppName>"
fi


