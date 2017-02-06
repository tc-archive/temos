#!/bin/bash

#---------------------------------------------------------------------------------------------------

# repository paths
#
SPINNAKER_INSTALL_PATH=./spinnaker-dev

# docker run -p 6379:6379 --name spinnaker-redis -d redis

# Front50 - Interface to persistent storage, such as Amazon S3 or Google Cloud Storage.
#
FRONT50_REPO='{"url": "https://github.com/spinnaker", "name": "front50", "run_cmd": "./gradlew bootRun > front50.log"}'
FRONT50_PORT=8080

# Rosco - Machine image bakery. A machine image is a static view of the state and disk of a machine 
# that can be 'deployed' into a running instance. Representation varies by cloud provider.

ROSCO_REPO='{"url": "https://github.com/spinnaker", "name": "rosco", "run_cmd": "./gradlew bootRun > rosco.log"}'
ROSCO_PORT=8087

# Igor - Interface to Jenkins. Can both listen to and fire Jenkins jobs and collect contextual 
# job and build information.
#
IGOR_REPO='{"url": "https://github.com/spinnaker", "name": "igor", "run_cmd": "./gradlew bootRun > igor.log"}'
IGOR_PORT=8088

# Echo - Event bus for notifications and triggers. Triggers are things like git commits, Jenkins 
# jobs finishing and other Spinnaker pipelines finishing. Notifications can send emails, slack 
# notifications, SMS messages, etc.
#
ECHO_REPO='{"url": "https://github.com/spinnaker", "name": "echo", "run_cmd": "./gradlew bootRun > echo.log"}'
ECHO_PORT=8089

# Orca - Orchestration of pipelines and ad hoc operations.
#
ORCA_REPO='{"url": "https://github.com/spinnaker", "name": "orca", "run_cmd": "./gradlew bootRun > orca.log"}'
ORCA_PORT=8083

# Clouddriver -Interacts with and mutates infrastructure on underlying cloud providers.
#
CLOUDDRIVER_REPO='{"url": "https://github.com/spinnaker", "name": "clouddriver", "run_cmd": "./gradlew bootRun > clouddriver.log"}'
CLOUDDRIVER_PORT=7002

# Gate - Api gateway. All external requests to Spinnaker are directed through Gate.
#
GATE_REPO='{"url": "https://github.com/spinnaker", "name": "gate", "run_cmd": "./gradlew bootRun > gate.log"}'
GATE_PORT=8084

# Deck - User interface.
#
DECK_REPO='{"url": "https://github.com/spinnaker", "name": "deck", "run_cmd": "npm install && API_HOST=http://localhost:8084 npm start > deck.log"}'
DECK_PORT=9000

#---------------------------------------------------------------------------------------------------

# SPINNAKER_REPOS=(
#     ${FRONT50_REPO}
#     ${ROSCO_REPO}
#     ${IGOR_REPO}
#     ${ECHO_REPO}
#     ${ORCA_REPO} 
#     ${CLOUDDRIVER_REPO} 
#     ${GATE_REPO}
#     ${DECK_REPO} 
#     )

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

function list_spinnaker_repos() {
    printf "spinnaker repos\n+\n"
    local IFS=";"
    for repo in "${spinnaker_repos[@]}"
    do
        printf "|--- %s\n" ${repo}
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
    printf "--- tmux sessions ---"
    tmux list-sessions
}

list_spinnaker_repos
install_spinnaker
update_spinnaker
start_spinnaker

