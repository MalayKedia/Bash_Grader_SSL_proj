#!/bin/bash
source Scripts/git_commands/additional_functions.sh

check_if_git_init_run_before
if [ $? -eq 1 ]; then
    exit 1
fi

path_to_remote_repo=$(readlink -f ./.my_git)

if [ $1 = "--delete" ]; then
    shift
    if [ $# -eq 0 ]; then
        echo "Specify the files to remove from the staging area"
        exit 1
    fi

    latest_hash=$(return_hash_HEADn $path_to_remote_repo 0)
    path_of_commit=$(find_folder_by_hash $path_to_remote_repo $latest_hash)

    # if the specified files dont exist in git_files_deleted_from_stage.txt, then they have not been staged for deletion, and hence, cant be removed from the staging area
    for file in "$@"; do
        if [ -z $(grep "^$file$" $path_to_remote_repo/git_files_deleted_from_stage.txt) ]; then
            echo "Deletion of $file has not been staged"
            exit 1
        fi
    done

    # to remove from stage, the names of such files are removed from git_files_deleted_from_stage.txt
    for file in "$@"; do
        sed -i "/^$file$/d" $path_to_remote_repo/git_files_deleted_from_stage.txt
    done
    echo "Deletion of file(s) $@ removed from staging area"
else 
    if [ $# -eq 0 ]; then
        echo "Specify the files to remove from the staging area"
        exit 1
    fi

    for file in "$@"; do
        if [ ! -f $path_to_remote_repo/stage/$file ]; then
            echo "File $file is not present in the staging area"
            exit 1
        fi
    done

    # to remove from stage, the files are removed from the staging area
    for file in "$@"; do
        rm $path_to_remote_repo/stage/$file
    done
    echo "File(s) $@ removed from staging area"
fi