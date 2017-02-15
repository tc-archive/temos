#!/bin/bash

#---------------------------------------------------------------------------------------------------
# Function to return the full directory path of the bash script it is onvoked from
#
# If invoked with zero args it will set the global variable ${this_script_dir_path} and echo the 
# result to standard where it can be captured via commandline subsitution:
# 
# e.g: get_this_script_dir_path && echo "result1: ${this_script_dir_path}"
#      result2=$(get_this_script_dir_path) && echo "result2: ${result2}"

# Alternatively, it can be invoked with a single argument denoting the name of the variable to assign
# the result which is then assigned:
#
# e.g: get_this_script_dir_path result3 && echo "result3: ${result3}"
#
# see: http://stackoverflow.com/questions/59895/getting-the-source-directory-of-a-bash-script-from-within
# see: http://www.linuxjournal.com/content/return-values-bash-functions
#
function get_this_script_dir_path() {
    # NB: the callee should never pass in a result name of '__temos_callee-result_var'
	local __temos_callee_result_var=$1
    local _source="${BASH_SOURCE[0]}"
	while [ -h "$_source" ]; do 
	  local this_script_dir_path="$( cd -P "$( dirname "$_source" )" && pwd )"
	  _source="$(readlink "$_source")"
	  [[ $_source != /* ]] && _source="$this_script_dir_path/$_source"
	done
	this_script_dir_path="$( cd -P "$( dirname "$_source" )" && pwd )"
    if [[ ! -z "${__temos_callee_result_var}" ]]; then
        # named parameter invocation (prefered)
        eval ${__temos_callee_result_var}=${this_script_dir_path}
    else
        # zero parameter invocation
        echo "${this_script_dir_path}"
    fi
}

#---------------------------------------------------------------------------------------------------
# Function to return the full directory path of the bash script it is invoked from.
#
function set_temos_home() {
    _TEMOS_HOME=$(dirname $(get_this_script_dir_path))
    if [[ -z "${TEMOS_HOME}" ]]; then
        export TEMOS_HOME=${_TEMOS_HOME}
        echo "TEMOS_HOME is defined as: ${TEMOS_HOME}"
    elif [[ "${TEMOS_HOME}" != "${_TEMOS_HOME}" ]]; then
        echo "TEMOS_HOME is already defined as '${TEMOS_HOME}', but, located at '${_TEMOS_HOME}'".
    else
        echo "TEMOS_HOME is already defined as: ${TEMOS_HOME}"
    fi
}

#---------------------------------------------------------------------------------------------------
# Function to return the name of the alias if it exists; else nothing.
#
has_alias() {
	local _alias_name=$1
    _has_alias_name=alias | grep ${_alias_name} \
        | awk -F' ' '{print $2}' | awk -F'=' '{print $1}' | sed "s/ //g"
    echo "${_has_alias_name}"
}

#---------------------------------------------------------------------------------------------------

# set_temos_home
# echo "system ostype  : ${OSTYPE}" 
# echo "system uname   : `uname`"

