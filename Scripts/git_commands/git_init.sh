#!/bin/bash
source Scripts/git_commands/additional_functions.sh

start_my_git() {
    remote_repo="$1"
    mkdir -p "$remote_repo" "$remote_repo/stage" "$remote_repo/commits"
    ln -s $remote_repo ./.my_git
    echo "Initialized remote repository at $remote_repo"
}

if [ $# -eq 0 ]; then
    echo 'Specify the path to the remote repository'
    exit 1
fi

remote_repo="$1"
if [ -h "./.my_git" ]; then
    path_to_existing_remote=$(realpath $(readlink -f ./.my_git))
    remote_repo_absolute=$(realpath $remote_repo)
    if [ "$path_to_existing_remote" != "$remote_repo_absolute" ]; then
        if [ -d $path_to_existing_remote ]; then
            echo "Remote repository already exists at $path_to_existing_remote"
            exit 1
        else
            rm ./.my_git
            start_my_git $remote_repo
        fi
    else
        if [ -d $path_to_existing_remote ]; then
            echo "Remote repository already exists at $path_to_existing_remote"
            exit 1
        else
            rm ./.my_git
            start_my_git $remote_repo
        fi
    fi
else
    start_my_git $remote_repo
fi
