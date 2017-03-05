#!/bin/bash

alias temos-tty-fn-names="declare -F"
alias temos-tty-fn-display-all="declare -f"
function _temos_tty_fn_display() {
    local _fn_name=$1
    if [[ ! -z ${_fn_name} ]]; then
        declare -f ${_fn_name}
    fi
}
alias temos-tty-fn-display="_temos_tty_fn_display"
function _temos_tty_fn_delete() {
    local _fn_name=$1
    if [[ ! -z ${_fn_name} ]]; then
        unset -f ${_fn_name}
    fi
}
alias temos-tty-fn-delete="_temos_tty_fn_delete"

alias temos-tty-fn-names="declare -F"
alias temos-tty-refresh="source ~/.bash_profile"
alias temos-refresh="source ~/.bash_profile"
alias temos-tty-refresh-clear="source ~/.bash_profile && clear"

alias ls="ls -l"
