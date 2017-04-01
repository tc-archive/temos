#! /bin/bash

# Find ports in use on OSX
#
# PORTS=8080,8081
# lsof -n -i4TCP:$PORTS | grep LISTEN
# lsof -n -iTCP:$PORTS | grep LISTEN
# lsof -n -i:$PORTS | grep LISTEN
#
function _temos_ports_find() {
    _ports=$1
    lsof -n -i:${_ports} | grep LISTEN
}
alias ports-find="_temos_ports_find"

# Find ports in use on Linux
#
# netstat -pntl | grep $PORTS
# fuser -n tcp $PORTS
#
