#!/bin/bash
source Scripts/git_commands/additional_functions.sh

check_if_git_init_run_before
if [ $? -eq 1 ]; then
    exit 1
fi

path_to_remote_repo=$(readlink -f ./.my_git)

file_list="$(ls -1 "$path_to_remote_repo/stage/")$(cat "$path_to_remote_repo/git_files_deleted_from_stage.txt")"
if [ -z "$file_list" ]; then
    echo "No files to commit"
    exit 1
fi

current_datetime=$(date +"%Y-%m-%d %H:%M:%S")
hash_value=$(generate_hash)

message=""
if [ $# -eq 0 ]; then
    read -p "Enter the commit message: " message
elif [ "$1" = '-m' ]; then
    message=$2
else
    echo "Invalid arguments"
    exit 1
fi

echo "$hash_value : $current_datetime : $message" >> $path_to_remote_repo/git_log.txt

mkdir $path_to_remote_repo/commits/$hash_value

if [ $(wc -l < "$path_to_remote_repo/git_log.txt") -gt 1 ]; then
    latest_hash=$(return_hash_HEADn $path_to_remote_repo 1)
    path_of_commit=$(find_folder_by_hash $path_to_remote_repo $latest_hash)
    for file in $(ls $path_of_commit); do
        if [ -z $(grep "^$file$" $path_to_remote_repo/git_files_deleted_from_stage.txt) ]; then
            cp $path_of_commit/$file $path_to_remote_repo/commits/$hash_value/.
        fi
    done
fi

cp $path_to_remote_repo/stage/* $path_to_remote_repo/commits/$hash_value 2>/dev/null

file_list="$(ls -1 "$path_to_remote_repo/stage/") $(cat "$path_to_remote_repo/git_files_deleted_from_stage.txt")"
echo "Files $(echo $file_list | tr '\n' ' ')committed to remote repository"
if [ $(wc -l < "$path_to_remote_repo/git_log.txt") -gt 1 ]; then
    second_last_hash=$(tail -n 2 $path_to_remote_repo/git_log.txt | head -n 1 | cut -d ':' -f 1 | sed 's/^[ \t]*//;s/[ \t]*$//')
    echo ""
    echo "Changed files between commits $second_last_hash and $hash_value:"
    find_changed_files_between_commits $second_last_hash $hash_value
fi

clear_stage