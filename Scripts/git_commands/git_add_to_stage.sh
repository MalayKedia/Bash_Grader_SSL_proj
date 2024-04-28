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
        echo "Specify the files to add to the staging area"
        exit 1
    fi

    latest_hash=$(return_hash_HEADn $path_to_remote_repo 0)
    path_of_commit=$(find_folder_by_hash $path_to_remote_repo $latest_hash)

    # only files which have been deleted from working directory can be deleted from stage
    for file in "$@"; do
        if [ -f $file ]; then
            echo "File $file has not been deleted from the working directory"
            exit 1
        fi
    done

    # only files which either were present in last commit, or, have been added to the stage can be deleted from stage
    for file in "$@"; do
        if [[ ! -f $path_of_commit/$file ]] && [[ ! -f $path_to_remote_repo/stage/$file ]]; then
            echo "File $file does not exist"
            exit 1
        fi
    done

    # the names of such files are appended to the file git_files_deleted_from_stage.txt
    for file in "$@"; do
        rm $path_to_remote_repo/stage/$file 2>/dev/null
        echo "$file" >> $path_to_remote_repo/git_files_deleted_from_stage.txt
    done
    echo "Deletion of file(s) $@ added to staging area"
    
else 
    if [ $# -eq 0 ]; then
        echo "Specify the files to add to the staging area"
        exit 1
    fi

    for file in "$@"; do
        if [ ! -f $file ]; then
            echo "File $file does not exist"
            exit 1
        fi
    done

    # if you add a file to stage whose name exists in git_files_deleted_from_stage.txt, then remove the name from the file to prevent conflicts in other functionalities
    for file in "$@"; do
        if [ -n "$(grep "^$file$" $path_to_remote_repo/git_files_deleted_from_stage.txt)" ]; then
            sed -i "/^$file$/d" $path_to_remote_repo/git_files_deleted_from_stage.txt
        fi
    done
    
    # copy the added files at moment of additionn to the stage
    cp "$@" $path_to_remote_repo/stage
    echo "File(s) $@ added to staging area"
fi