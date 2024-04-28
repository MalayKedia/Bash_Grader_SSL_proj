#!/bin/bash

# returns true if the directory has the specified number of files
check_dir_contents_count() {
    local dir="$1"
    local number="$2"
    local file_count=$(find "$dir" -mindepth 1 -maxdepth 1 | wc -l)
    if [ "$file_count" -eq "$2" ]; then 
        echo "true"
    else 
        echo "false"
    fi
}

# returns true if the symlink .my_git exists and points to an existing directory
check_if_git_init_run_before() {
   if [ -h "./.my_git" ]; then
       path_to_remote_repo=$(readlink -f ./.my_git)
       if [[ ! -d $path_to_remote_repo ]]; then
           echo "Remote repository does not exist"
           echo "Run the command 'bash submission.sh git_init <path_to_remote_repo>' first"
           exit 1
       fi
   else
       echo "Remote repository does not exist"
       echo "Run the command 'bash submission.sh git_init <path_to_remote_repo>' first"
       exit 1
   fi
}

# returns a random 16 digit number in base 10
generate_hash() {
   local random_number=""

   for ((i=0; i<16; i++)); do
       local random_digit=$(( RANDOM % 10 ))
       random_number="${random_number}${random_digit}"
   done
   echo "$random_number"
}

# returns 0 if the supplied snippet of hash uniquely identifies a single commit
# returns 1 if the supplied snippet of hash identifies multiple commits
# returns 2 if the supplied snippet of hash does not identify any commit
find_folder_by_hash() {
   path_to_remote_repo="$1"
   hash="$2"

   count=$(find $path_to_remote_repo/commits -maxdepth 1 -type d -name "$hash*" | wc -l)

   if [ $count -eq 1 ]; then
       echo $(find $path_to_remote_repo/commits -maxdepth 1 -type d -name "$hash*")
       return 0
   elif [ $count -gt 1 ]; then
       return 1
   else
       return 2
   fi
}

# returns 0 if the supplied message uniquely identifies a single commit
# returns 1 if the supplied message identifies multiple commits
# returns 2 if the supplied message does not identify any commit
find_folder_by_message() {
   path_to_remote_repo="$1"
   message="$2"

   count_of_matching_lines=$(grep -c -E "^[0-9]{16} : [0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2} : $message$" $path_to_remote_repo/git_log.txt)

   if [ $count_of_matching_lines -eq 1 ]; then
       hash=$(grep -E "^[0-9]{16} : [0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2} : $message$" $path_to_remote_repo/git_log.txt | cut -d ':' -f 1 | sed 's/[ \t]*$//')
       echo $(find_folder_by_hash $path_to_remote_repo $hash)
       return 0
   elif [ $count_of_matching_lines -gt 1 ]; then
       return 1
   else
       return 2
   fi
}

# prints the difference between the files in the two commits
find_changed_files_between_commits() {
   local hash1="$1"
   local hash2="$2"
  
   local path_to_remote_repo=$(realpath $(readlink -f ./.my_git))
  
   local path1=$(find_folder_by_hash $path_to_remote_repo $hash1)
   local path2=$(find_folder_by_hash $path_to_remote_repo $hash2)
 
   for file in $(ls $path1); do
       if [ -f $path2/$file ]; then
           difference=$(diff $path1/$file $path2/$file)
           if [ -n "$difference" ]; then
               echo "Changed: $file"
           fi
       else
           echo "Removed: $file"
       fi
   done

   for file in $(ls $path2); do
       if [ ! -f $path1/$file ]; then
           echo "Added: $file"
       fi
   done
}

# clears the stage
clear_stage() {
    path_to_remote_repo=$(readlink -f ./.my_git)
    rm -rf $path_to_remote_repo/stage/*
    echo > "$path_to_remote_repo/git_files_deleted_from_stage.txt"
}

# returns the hash of the commit n commits before HEAD
return_hash_HEADn() {
    path_to_remote_repo="$1"
    number=$(($2+1))
    hash=$(tail -n $number $path_to_remote_repo/git_log.txt | head -n 1 | cut -d ':' -f 1 |  sed 's/[ \t]*$//')
    echo $hash
}