#!/bin/bash

# enable git bash auto-complete
#
if [ -f ~/.git-completion.bash ]; then
    . ~/.git-completion.bash
fi

# display the list of files that will be pushed on the next push
function _temos_git_push_info() {
    local target=${1-origin/master}
    local cmd="git diff --stat --cached ${target}"
    eval "${cmd}"
}

# removes a git branch both locally and remotely
function _temos_git_remove_branch() {
    local branch_name=$1
    if [[ ! -z ${branch_name} ]]; then
        echo "git push origin --delete ${branch_name}"
        git push origin --delete ${branch_name}
        echo "git branch -d ${branch_name}"
        git branch -d ${branch_name}
    fi
}

# remove locally merged branches. can optinally filter by a simple grep epression.
function _temos_git_remove_local_merged_branches() {
    local filter=$1
    local force_level="-d"
    if [[ -z ${filter} ]]; then
        git branch | xargs git branch ${force_level}
    else:
        git branch | grep '${filter}' | xargs git branch ${force_level}
    fi
}

# git branch | grep 'trjl' | head -n 1 | xargs git branch -d

alias temos-git-push-info="_temos_git_push_info"
alias temos-git-delete-branch="_temos_git_remove_branch"


