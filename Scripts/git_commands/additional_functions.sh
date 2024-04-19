#!/bin/bash

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

generate_hash() {
   local random_number=""

   for ((i=0; i<16; i++)); do
       local random_digit=$(( RANDOM % 10 ))
       random_number="${random_number}${random_digit}"
   done
   echo "$random_number"
}

find_folder_by_hash() {
   remote_repo="$1"
   hash="$2"

   count=$(find $remote_repo/commits -maxdepth 1 -type d -name "$hash*" | wc -l)

   if [ $count -eq 1 ]; then
       echo $(find $remote_repo/commits -maxdepth 1 -type d -name "$hash*")
       return 0
   elif [ $count -gt 1 ]; then
       return 1
   else
       return 2
   fi
}

find_folder_by_message() {
   remote_repo="$1"
   message="$2"

   count_of_matching_lines=$(grep -c -E "^[0-9]{16} : [0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2} : $message$" $path_to_remote_repo/git_log.txt)

   if [ $count_of_matching_lines -eq 1 ]; then
       hash=$(grep -E "^[0-9]{16} : [0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2} : $message$" $path_to_remote_repo/git_log.txt | cut -d ':' -f 1 | sed 's/[ \t]*$//')
       echo $(find_folder_by_hash $remote_repo $hash)
       return 0
   elif [ $count_of_matching_lines -gt 1 ]; then
       return 1
   else
       return 2
   fi
}

find_changed_files_between_commits() {
   local hash1="$1"
   local hash2="$2"
  
   local remote_repo=$(realpath $(readlink -f ./.my_git))
  
   local path1=$(find_folder_by_hash $remote_repo $hash1)
   local path2=$(find_folder_by_hash $remote_repo $hash2)
 
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

clear_stage() {
    remote_repo=$(readlink -f ./.my_git)
    rm -rf $remote_repo/stage/*
}