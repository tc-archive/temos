#!/bin/bash

# enable git bash auto-complete
#
if [ -f ~/.git-completion.bash ]; then
    . ~/.git-completion.bash
fi

# display the list of files that will be pushed on the next push
function git-push-info() {
    local _target=${1-origin/master}
    local _cmd="git diff --stat --cached ${_target}"
    eval "${_cmd}"
}


alias git-push-info="git-push-info"
