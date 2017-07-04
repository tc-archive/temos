#!/bin/bash

MODULES_DIR=${TEMOS_HOME}/modules
MODULE_SCRIPT_EXT=".sh"

function module_list() {
    for _file in ${MODULES_DIR}/*${MODULE_SCRIPT_EXT}
    do
	    echo `basename ${_file}` \
            | cut -d'.' -f1
    done
}

function module_list_enabled() {
    echo unimplemented
}

function module_on() {
    local _name=$1
    echo "eanbling module: ${_name}"
    source ${MODULES_DIR}/${_name}${MODULE_SCRIPT_EXT}
}

function module_off() {
    local _name=$1
    echo "disable module: ${_name}"
    source ${MODULES_DIR}/${_name}${MODULE_SCRIPT_EXT}
}

function module_function_list() {
    local _name=$1
    cat ${MODULES_DIR}/${_name}${MODULE_SCRIPT_EXT}\
        | grep -v '^$\|^\s*\#' \
        | grep function \
        | cut -d' ' -f2 \
        | sed 's/()//g'
}

function fn_delete() {
    local _fn_name=$1
    if [[ ! -z ${_fn_name} ]]; then
        echo "unsetting function: ${_fn_name}"
        unset -f ${_fn_name}
    fi
}

function module_function_delete() {
    local _name=$1
    echo "disable module functions"
    for fn_name in $(module_function_list $_name)
    do
        fn_delete ${fn_name}
    done
}

function module_alias_list() {
    local _name=$1
    cat ${MODULES_DIR}/${_name}${MODULE_SCRIPT_EXT} \
        | grep -v '^$\|^\s*\#' \
        | grep alias \
        | cut -d'=' -f1 \
        | cut -d' ' -f2
}


