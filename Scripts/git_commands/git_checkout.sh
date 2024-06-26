#!/bin/bash
source Scripts/git_commands/additional_functions.sh

# Function to checkout a commit by hash value
# if the hash value exists, it copies all files in it to the current directory
# note that it does not delete any files, and hence, any files in the current directory not in the commit folder are not affected
checkout_by_hash() {
    path_to_remote_repo=$1
    hash_value=$2

    path_of_commit=$(find_folder_by_hash $path_to_remote_repo $hash_value)
    return_code=$?
    full_hash_value=$(basename $path_of_commit)

    if [ $return_code -eq 0 ]; then
        cp $path_of_commit/* .
        echo "Commit $full_hash_value checked out"
    elif [ $return_code -eq 1 ]; then
        echo "Multiple commits found with hash $hash_value"
        echo "Please use the full hash value"
        exit 1
    elif [ $return_code -eq 2 ]; then
        echo "Commit with hash $hash_value not found"
        exit 1
    fi
}


check_if_git_init_run_before
if [ $? -eq 1 ]; then
    exit 1
fi

path_to_remote_repo=$(readlink -f ./.my_git)


if [ $# -eq 1 ]; then
    # If the first argument is 'HEAD'
    if [ "$1" = 'HEAD' ]; then
        latest_hash=$(return_hash_HEADn $path_to_remote_repo 0)
        checkout_by_hash $path_to_remote_repo $latest_hash

    # If the first argument is 'HEAD~[0-n]'
    elif [[ $1 =~ ^HEAD~[0-9]+$ ]]; then
        number=$(echo $1 | cut -d '~' -f 2)
        hash=$(return_hash_HEADn $path_to_remote_repo $number)
        if [ -n "$hash" ]; then
            checkout_by_hash $path_to_remote_repo $hash
        else
            echo "Invalid argument, commit not found"
            exit 1
        fi

    # If the first argument is a hash value
    elif [[ $1 =~ [0-9]{1,16} ]]; then
        hash=$1
        checkout_by_hash $path_to_remote_repo $hash
    
    else
        echo "Invalid argument"
        exit 1
    fi

elif [ "$1" = '-m' ]; then
    # This allows the user to checkout a commit by message
    message=$2
    path_of_commit=$(find_folder_by_message "$path_to_remote_repo" "$message")
    return_code=$?

    if [ $return_code -eq 0 ]; then
        cp $path_of_commit/* .
        echo "Commit with message '$message' checked out"
    elif [ $return_code -eq 1 ]; then
        echo "Multiple commits found with message '$message'"
        echo "Please use hash value"
        exit 1
    elif [ $return_code -eq 2 ]; then
        echo "Commit with message '$message' not found"
        exit 1
    else 
        echo "Error"
        exit 1
    fi
else
    echo "Invalid arguments"
    exit 1
fi