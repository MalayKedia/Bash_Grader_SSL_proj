#!/bin/bash
source Scripts/git_commands/additional_functions.sh

check_if_git_init_run_before
if [ $? -eq 1 ]; then
    exit 1
fi

path_to_remote_repo=$(readlink -f ./.my_git)

# If there are no files in the staging area (additions+deletions), then there are no files to commit
file_list="$(ls -1 "$path_to_remote_repo/stage/") $(cat "$path_to_remote_repo/git_files_deleted_from_stage.txt")"
file_list_single_line=$(echo $file_list | tr '\n' ' ')

if [ -z "$file_list_single_line" ]; then
    echo "No files to commit"
    exit 1
fi

current_datetime=$(date +"%Y-%m-%d %H:%M:%S")
hash_value=$(generate_hash)

# If no message is provided, prompt the user to enter the message
message=""
if [ $# -eq 0 ]; then
    read -p "Enter the commit message: " message
elif [ "$1" = '-m' ]; then
    message=$2
else
    echo "Invalid arguments"
    exit 1
fi

# Append the commit details to the git_log.txt file
echo "$hash_value : $current_datetime : $message" >> $path_to_remote_repo/git_log.txt

# Create a folder with the hash value in the commits directory
mkdir $path_to_remote_repo/commits/$hash_value

# To commit, all files in the last commit, except those whose names are present in git_files_deleted_from_stage.txt are initially copied to the new commit folder
# All files in the stage folder are copied to the new commit folder, overwriting the files from the last commit if they exist in the stage folder
# Hence, this way, a file whose modification has not been staged still remains the same in the new commit folder
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

# The changes made from the last commit to this one are displayed
echo "Files $(file_list_single_line)committed to remote repository"
if [ $(wc -l < "$path_to_remote_repo/git_log.txt") -gt 1 ]; then
    second_last_hash=$(tail -n 2 $path_to_remote_repo/git_log.txt | head -n 1 | cut -d ':' -f 1 | sed 's/^[ \t]*//;s/[ \t]*$//')
    echo ""
    echo "Changed files between commits $second_last_hash and $hash_value:"
    find_changed_files_between_commits $second_last_hash $hash_value
fi

# The stage folder and the git_files_deleted_from_stage.txt file are cleared
clear_stage