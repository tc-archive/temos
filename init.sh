#!/bin/bash

MODULES_DIR=${TEMOS_HOME}/modules
MODULE_SCRIPT_EXT=".sh"

function mod_list() {
    for _file in ${MODULES_DIR}/*${MODULE_SCRIPT_EXT}
    do
	    echo `basename ${_file}` \
            | cut -d'.' -f1
    done
}

function mod_on() {
    local _name=$1
    echo "enable module: ${_name}"
    source ${MODULES_DIR}/${_name}${MODULE_SCRIPT_EXT}
}

function mod_off() {
    local _name=$1
    echo "disable module: ${_name}"
    sh_mod_fn_delete "${_name}"
}

function mod_fn_list() {
    local _name=$1
    cat ${MODULES_DIR}/${_name}${MODULE_SCRIPT_EXT}\
        | grep -v '^$\|^\s*\#' \
        | grep function \
        | cut -d' ' -f2 \
        | sed 's/()//g'
}



function sh_fn_list() {
    declare -F | grep "_temos"
}

function sh_fn_delete() {
    local _fn_name=$1
    echo "deleting $1"
    if [[ ! -z ${_fn_name} ]]; then
        echo "unsetting function: ${_fn_name}"
        unset -f ${_fn_name}
        # unset ${_fn_name}
    fi
}

function sh_mod_fn_delete() {
    local _name=$1
    for x in $(module_function_list "${_name}"); do sh_fn_delete "${x}"; done
}



function module_alias_list() {
    local _name=$1
    cat ${MODULES_DIR}/${_name}${MODULE_SCRIPT_EXT} \
        | grep -v '^$\|^\s*\#' \
        | grep alias \
        | cut -d'=' -f1 \
        | cut -d' ' -f2
}

