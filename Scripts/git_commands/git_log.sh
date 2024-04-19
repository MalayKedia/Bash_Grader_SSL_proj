#!/bin/bash
source Scripts/git_commands/additional_functions.sh

check_if_git_init_run_before
if [ $? -eq 1 ]; then
    exit 1
fi

path_to_remote_repo=$(readlink -f ./.my_git)
cat $path_to_remote_repo/git_log.txt
