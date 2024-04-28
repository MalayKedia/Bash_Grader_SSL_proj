#!/bin/bash
source Scripts/git_commands/additional_functions.sh

check_if_git_init_run_before
if [ $? -eq 1 ]; then
    exit 1
fi

path_to_remote_repo=$(readlink -f ./.my_git)

latest_hash=$(return_hash_HEADn $path_to_remote_repo 0)
path_of_commit=$(find_folder_by_hash $path_to_remote_repo $latest_hash)

added_files_in_stage=$(ls $path_to_remote_repo/stage)
deleted_files_in_stage=$(cat $path_to_remote_repo/git_files_deleted_from_stage.txt)
files_in_commit=$(ls $path_of_commit)

echo "Changes to be commited:"
for file in $added_files_in_stage; do
    if [ -e "$path_of_commit/$file" ]; then
        difference=$(diff "$path_of_commit/$file" "$path_to_remote_repo/stage/$file")
        if [ -n "$difference" ]; then
            echo -e "\tModified:\t$file"
        fi
    fi
done
for file in $added_files_in_stage; do
    if [[ ! -e "$path_of_commit/$file" ]]; then
        echo -e "\tNew file:\t$file"
    fi
done
for file in $deleted_files_in_stage; do
    if [ -e "$path_of_commit/$file" ]; then
        echo -e "\tDeleted:\t$file"
    fi
done

echo -e "\nChanges not staged for commit:"
for file in $(ls .); do
    if [ -f $path_of_commit/$file ] || [ -f $path_to_remote_repo/stage/$file ]; then
        difference=""
        if [ -f $path_to_remote_repo/stage/$file ]; then
            difference=$(diff $file $path_to_remote_repo/stage/$file)
        else
            difference=$(diff $file $path_of_commit/$file)
        fi

        if [ -n "$difference" ]; then
            echo -e "\tModified:\t$file"
        fi
    fi
done
for file in $files_in_commit; do
    if [ ! -e $file ] && [ -z $(grep "^$file$" $path_to_remote_repo/git_files_deleted_from_stage.txt) ]; then
        echo -e "\tDeleted:\t$file"
    fi
done
for file in $added_files_in_stage; do
    if [ ! -e $file ] && [ -z $(echo $files_in_commit | grep -E "[ \t]$file[ \t]") ]; then
        echo -e "\tDeleted:\t$file"
    fi
done

echo -e "\nUntracked files:"
for file in $(ls .); do
    if [ ! -f $path_of_commit/$file ] && [ ! -f $path_to_remote_repo/stage/$file ]; then
        echo -e "\t$file"
    fi
done
# A file in last commit, which is added, comes as modified, else as New file in 1st cat

# A file which was in last commit and changed, but not in stage comes in 2nd cat as modified, and which was in deleted comes as such
# A file in stage, which has been changed comes in 2nd cat as modified
# A file in stage delted comes as deleted in cat 2

# A file which was neither in last commit not in stage comes in cat 3