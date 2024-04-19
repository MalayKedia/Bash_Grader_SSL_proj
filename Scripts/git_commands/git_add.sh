#!/bin/bash
source Scripts/git_commands/additional_functions.sh

check_if_git_init_run_before
if [ $? -eq 1 ]; then
    exit 1
fi

path_to_remote_repo=$(readlink -f ./.my_git)

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

cp "$@" $path_to_remote_repo/stage
echo "File(s) $@ added to staging area"