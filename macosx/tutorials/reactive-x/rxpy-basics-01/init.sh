#!/bin/bash

function init_project() {
    local virtual_env_dir="venv"
    local python_path="/usr/local/bin/python"
    # create virtual environment
    virtualenv -p ${python_path} ${virtual_env_dir}
    source ./venv/bin/activate
    pip install -r requirements.txt
    printf "Activated virtualenv. Type 'deactivate' to exit.\n" 
}
init_project
unset -f init_project

