#!/bin/bash
source Scripts/git_commands/additional_functions.sh

# creates the required directories and files for a remote repository
start_my_git() {
    remote_repo="$1"
    mkdir -p "$remote_repo" "$remote_repo/stage" "$remote_repo/commits"
    if [[ "$(check_dir_contents_count $remote_repo 2)" = "false" ]] || [[ "$(check_dir_contents_count $remote_repo/stage 0)" = "false" ]] || [[ "$(check_dir_contents_count $remote_repo/commits 0)" = "false" ]]; then 
        echo "Directory $remote_repo already exists and is not fit to be remote repository"
        exit 1
    fi

    touch $remote_repo/git_log.txt
    touch $remote_repo/git_files_deleted_from_stage.txt
    ln -s $remote_repo ./.my_git
    echo "Initialized remote repository at $remote_repo"
}

if [ $# -eq 0 ]; then
    echo 'Specify the path to the remote repository'
    exit 1
fi

remote_repo="$1"

# if the symlink .my_git exists and points to an existing directory, it is not allowed to change the remote repository
# however, if the symlink .my_git exists and points to a non-existing directory, it is necessary to specify the remote repository again
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
