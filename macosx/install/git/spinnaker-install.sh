#!/bin/bash

#---------------------------------------------------------------------------------------------------

# repository paths
#
SPINNAKER_INSTALL_PATH=~/spinnaker-dev

# docker run -p 6379:6379 --name spinnaker-redis -d redis

# Front50 - Interface to persistent storage, such as Amazon S3 or Google Cloud Storage.
#
FRONT50_REPO='{"url": "https://github.com/spinnaker", "name": "front50", "port": 8080, "run_cmd": "./gradlew bootRun > front50.log"}'

# Rosco - Machine image bakery. A machine image is a static view of the state and disk of a machine 
# that can be 'deployed' into a running instance. Representation varies by cloud provider.

ROSCO_REPO='{"url": "https://github.com/spinnaker", "name": "rosco", "port": 8087, "run_cmd": "./gradlew bootRun > rosco.log"}'

# Igor - Interface to Jenkins. Can both listen to and fire Jenkins jobs and collect contextual 
# job and build information.
#
IGOR_REPO='{"url": "https://github.com/spinnaker", "name": "igor", "port": 8088, "run_cmd": "./gradlew bootRun > igor.log"}'

# Echo - Event bus for notifications and triggers. Triggers are things like git commits, Jenkins 
# jobs finishing and other Spinnaker pipelines finishing. Notifications can send emails, slack 
# notifications, SMS messages, etc.
#
ECHO_REPO='{"url": "https://github.com/spinnaker", "name": "echo", "port": 8089, "run_cmd": "./gradlew bootRun > echo.log"}'

# Orca - Orchestration of pipelines and ad hoc operations.
#
ORCA_REPO='{"url": "https://github.com/spinnaker", "name": "orca", "port": 8083, "run_cmd": "./gradlew bootRun > orca.log"}'

# Clouddriver -Interacts with and mutates infrastructure on underlying cloud providers.
#
CLOUDDRIVER_REPO='{"url": "https://github.com/spinnaker", "name": "clouddriver", "port": 7002, "run_cmd": "./gradlew bootRun > clouddriver.log"}'

# Gate - Api gateway. All external requests to Spinnaker are directed through Gate.
#
GATE_REPO='{"url": "https://github.com/spinnaker", "name": "gate", "port": 8084, "run_cmd": "./gradlew bootRun > gate.log"}'

# Deck - User interface.
#
DECK_REPO='{"url": "https://github.com/spinnaker", "name": "deck", "port": 9000, "run_cmd": "npm install && API_HOST=http://localhost:8084 npm start > deck.log"}'

#---------------------------------------------------------------------------------------------------

spinnaker_repos=(
    "${FRONT50_REPO}"
    "${ROSCO_REPO}"
    "${IGOR_REPO}"
    "${ECHO_REPO}"
    "${ORCA_REPO}"
    "${CLOUDDRIVER_REPO}" 
    "${GATE_REPO}"
    "${DECK_REPO}"
    )

#---------------------------------------------------------------------------------------------------

function check_spinnaker_service_status() {
    _repo=$1
    local repo_name=`echo ${_repo} | jq -r '.name'`
    local service_port=`echo ${_repo} | jq '.port'`
    local status_rs=`curl -s http://localhost:${service_port}/health`
    if [[ ${status_rs} == "Cannot GET /health" ]]; then
        _status="API_DOWN"
    elif [[ -z  ${status_rs} ]]; then
        _status="API_DOWN"
    else
        _status=`echo ${status_rs} | jq -r '.status'`
    fi
    echo "${_status}"
}

function list_spinnaker_repos() {
    printf "spinnaker repos\n+\n"
    local IFS=";"
    for repo in "${spinnaker_repos[@]}"
    do
        local repo_name=`echo ${repo} | jq -r '.name'`
        local service_port=`echo ${repo} | jq '.port'`
        local service_status=`check_spinnaker_service_status ${repo}`
        printf "|--- %-15s [%s] : %s\n" ${repo_name} ${service_port} ${service_status}
    done
    printf "\n"
}

function install_spinnaker() {
    local IFS=";"
    for repo in ${spinnaker_repos[*]}
    do
        local repo_url=`echo ${repo} | jq -r '.url'`
        local repo_name=`echo ${repo} | jq -r '.name'`
        if [[ ! -d ${SPINNAKER_INSTALL_PATH}/${repo_name} ]]; then
            git clone \
                ${repo_url}/${repo_name}.git \
                ${SPINNAKER_INSTALL_PATH}/${repo_name}
        else
            printf "The repository '%s' is already installed.\n" ${repo_name}
        fi
    done
}

function update_spinnaker() {
    local IFS=";"
    for repo in ${spinnaker_repos[*]}
    do
        local repo_name=`echo ${repo} | jq -r '.name'`
        printf "updating '%s'..." ${repo_name}
        pushd ${SPINNAKER_INSTALL_PATH}/${repo_name} > /dev/null
        git pull
        popd > /dev/null
    done
}

function uninstall_spinnaker() {
    if [[ ! -d  ${SPINNAKER_INSTALL_PATH} ]]; then
        printf "uninstalling spinnaker: '${SPINNAKER_INSTALL_PATH}'\n" 
        rm -Rf ${SPINNAKER_INSTALL_PATH}
    fi
}

function start_spinnaker() {
    local IFS=";"
    for repo in ${spinnaker_repos[*]}
    do
        local repo_name=`echo ${repo} | jq -r '.name'`
        local run_cmd=`echo ${repo} | jq -r '.run_cmd'`
        pushd ${SPINNAKER_INSTALL_PATH}/${repo_name} > /dev/null
        printf "killing tmux session: '%s'...\n" ${repo_name}
        tmux kill-session -t ${repo_name}
        printf "starting tmux session '%s'...\n" ${repo_name}
        new_session_cmd="tmux new -d -s ${repo_name} '${run_cmd}'"
        eval "${new_session_cmd}"
        # tmux detach
        popd > /dev/null
    done
    printf "=== tmux sessions ===\n"
    tmux list-sessions
}

function stop_spinnaker() {
    local IFS=";"
    for repo in ${spinnaker_repos[*]}
    do
        local repo_name=`echo ${repo} | jq -r '.name'`
        pushd ${SPINNAKER_INSTALL_PATH}/${repo_name} > /dev/null
        printf "killing tmux session: '%s'...\n" ${repo_name}
        tmux kill-session -t ${repo_name}
        # tmux detach
        popd > /dev/null
    done
    printf "=== tmux sessions ===\n"
    tmux list-sessions
}


# install_spinnaker
# update_spinnaker
# start_spinnaker
stop_spinnaker
list_spinnaker_repos


