#!/bin/bash

check_if_total_run_before() {
    if [ -f "main.csv" ]; then
        total_exists=$(head -n 1 main.csv | awk -F',' '{print $NF}' | grep "^total$")
        if [ -n "$total_exists" ]; then
            total_run_before=true
        else
            total_run_before=false
        fi
    else
        total_run_before=false
    fi
    echo "$total_run_before"
}

combine() {
    touch main.csv
    echo -n "Roll_Number,Name" > main.csv

    # Check if all extra arguments are csv files
    for file in "$@"; do
        if [ -f "$file" ]; then
            if [[ ! "$file" == *.csv ]]; then
                echo "File $file is not a CSV file"
                exit 1
            fi
        else
            echo "File $file does not exist"
            exit 1
        fi
    done
    # Create the header
    for file in "$@"; do
        echo -n ",$(basename "$file" .csv )" >> main.csv
    done
    echo "" >> main.csv
    # put the names and roll numbers
    for file in "$@"; do
        awk -F, 'NR>1 {print $1","$2}' "$file" >> main.csv   
    done >> main.csv
    tail -n +2 main.csv | sort -k1 | uniq > temp.csv
    header=$(head -n 1 main.csv)
    echo $header > main.csv
    cat temp.csv >> main.csv 
    rm temp.csv

    # put the marks
    for file in "$@"; do
        line_number_in_main=0
        while read -r line || [ -n "$line" ]; do
            ((line_number_in_main++))
            if [ $line_number_in_main -eq 1 ]; then
                continue  # Skip processing the header
            fi
            
            roll_no="$(echo "$line" | cut -d ',' -f 1)"
            
            line_number_in_marks=$(cut -d ',' -f 1 "$file" | grep -n -m 1 "^$roll_no" | cut -d ':' -f 1)
            
            if [ -z "$line_number_in_marks" ]; then
                sed -i "${line_number_in_main}s/$/,a/" main.csv
            else
                marks=$(head -n "$line_number_in_marks" "$file" | tail -n 1 | cut -d ',' -f 3)
                sed -i "${line_number_in_main}s/$/,${marks}/" main.csv
            fi
            
        done < main.csv
    done >> main.csv    

}

total() {
    echo "total" > total.csv
    awk -F, 'NR>1 {for(i=3;i<=NF;i++) { if ($i == "a") $i = 0; s+=$i;} print s; s=0;}' main.csv >> total.csv
    paste -d',' main.csv total.csv > temp1212.csv
    mv temp1212.csv main.csv
    rm total.csv
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
    count=$(find $remote_repo -maxdepth 1 -type d -name "$hash*" | wc -l)
    
    if [ $count -eq 1 ]; then
        echo $(find $remote_repo -maxdepth 1 -type d -name "$hash*")
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
    count_of_matching_lines=$(grep -c -E "^[0-9]{16} : $message$" $path_to_remote_repo/.git_log.txt)

    if [ $count_of_matching_lines -eq 1 ]; then
        hash=$(grep -E "^[0-9]{16} : $message" $path_to_remote_repo/.git_log.txt | cut -d ':' -f 1)
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

check_if_git_init_run_before() {
    if [ -d "./.my_git" ]; then
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

# Exit if there is no command 0
if [ $# -eq 0 ]; then
    echo 'Usage: bash submission.sh <command> <any other extra arguments(if needed)>'
    exit 1
fi

# If the first argument is 'combine'
<< COMMENT
    To combine all csv files in current directory: Usage: bash submission.sh combine
    To combine given csv files:                    Usage: bash submission.sh combine <file1.csv> <file2.csv> <file3.csv> ...
COMMENT
if [ "$1" = 'combine' ]; then
    total_run_before=$(check_if_total_run_before)

    if [ $# -gt 1 ]; then
        combine ${@:2}
    else
        # If no extra arguments are provided, combine all csv files in the directory
        files=$(ls *.csv | grep -v "main.csv")
        combine $files
    fi

    if [ "$total_run_before" = true ]; then
        total
    fi


# If the first argument is 'upload'
<< COMMENT
    To copy the file to the current directory: Usage: bash submission.sh upload <file>
COMMENT
elif [ "$1" = 'upload' ]; then
    if [ $# -lt 2 ]; then
        echo 'Specify the file to be uploaded'
    else
        cp ${@:2} .
    fi


# If the first argument is 'total'
<< COMMENT
    To calculate the total marks of each student: Usage: bash submission.sh total
COMMENT
elif [ "$1" = 'total' ]; then
    total_run_before=$(check_if_total_run_before)
    if [ -f "main.csv" ]; then
        if [ "$total_run_before" = true ]; then
            echo "Total has already been run"
        else
            total
        fi
    else
        echo "main.csv does not exist"
        echo "Run the command 'bash submission.sh combine' first"
        exit 1  
    fi

# If the first argument is 'update'
<< COMMENT
    To update the marks of a student: Usage: bash submission.sh update
COMMENT
elif [ "$1" = 'update' ]; then
    if [ -f "main.csv" ]; then
        echo "Enter the roll no. of the student:"
        read roll_no
        if [ -n $(cut -d ',' -f 1 main.csv | grep $roll_no) ]; then
            echo "Invalid Roll Number, please try again"
        else
            echo "The name of the student with roll no. $roll_no is $(awk '$1 == "$roll_no" {print $2}' main.csv)"
            echo "Enter the name of exam to be updated"
            read exam_name
            if [ -f "$exam_name.csv" ]; then
                echo "yo"
            fi
        fi
    else
        echo 'Run "bash submission.sh combine" first'
    fi


# If the first argument is 'clean'
<< COMMENT
    To remove the main.csv file: Usage: bash submission.sh clean
COMMENT
elif [ "$1" = 'clean' ]; then
    rm main.csv

# If the first argument is 'git_init'
<< COMMENT
    To initialize a remote repository: Usage: bash submission.sh git_init <path_to_remote_repo>
COMMENT
elif [ "$1" = 'git_init' ]; then
    if [ $# -eq 1 ]; then
        echo 'Specify the path to the remote repository'
        exit 1
    fi

    remote_repo="$2"
    if [ -d "./.my_git" ]; then
        path_to_existing_remote=$(realpath $(readlink -f ./.my_git))
        remote_repo_absolute=$(realpath $remote_repo)
        if [ "$path_to_existing_remote" != "$remote_repo_absolute" ]; then
            if [ -d $path_to_existing_remote ]; then
                echo "Remote repository already exists at $path_to_existing_remote"
                exit 1
            else 
                mkdir -p "$remote_repo"
                rm -r ./.my_git
                ln -s $remote_repo ./.my_git
                echo "Initialized remote repository at $remote_repo"
            fi
        else 
            if [ -d $path_to_existing_remote ]; then
                echo "Remote repository already exists at $path_to_existing_remote"
                exit 1
            else 
                mkdir -p "$remote_repo"
                rm -r ./.my_git
                ln -s $remote_repo ./.my_git
                echo "Initialized remote repository at $remote_repo"
            fi
        fi
    else
        mkdir -p "$remote_repo"
        ln -s $remote_repo ./.my_git
        echo "Initialized remote repository at $remote_repo"
    fi

# If the first argument is 'git_commit'
<< COMMENT
    To commit the changes to the remote repository: Usage: bash submission.sh git_commit
    To commit the changes to the remote repository with a message: Usage: bash submission.sh git_commit -m <message>
COMMENT
elif [ "$1" = 'git_commit' ]; then
    check_if_git_init_run_before
    if [ $? -eq 1 ]; then
        exit 1
    fi
    
    hash_value=$(generate_hash)
    path_to_remote_repo=$(readlink -f ./.my_git)
    message=""

    if [ "$2" = '-m' ]; then
        message=$3
    else
        echo "Enter the commit message: "
        read message
    fi
    echo "$hash_value : $message" >> $path_to_remote_repo/.git_log.txt
    
    mkdir $path_to_remote_repo/$hash_value
    cp *.csv $path_to_remote_repo/$hash_value
    echo "All csv files committed to remote repository"

    second_last_hash=$(tail -n 2 $path_to_remote_repo/.git_log.txt | cut -d ':' -f 1)
    if [ -n "$second_last_hash" ]; then
        find_changed_files_between_commits $second_last_hash $hash_value      
    fi

# If the first argument is 'git_log'
<< COMMENT
    To view the log of the remote repository: Usage: bash submission.sh git_log
COMMENT
elif [ "$1" = 'git_log' ]; then
    check_if_git_init_run_before
    if [ $? -eq 1 ]; then
        exit 1
    fi

    path_to_remote_repo=$(readlink -f ./.my_git)
    cat $path_to_remote_repo/.git_log.txt
    
# If the first argument is 'git_checkout'
<< COMMENT
    To checkout the latest commit: Usage: bash submission.sh git_checkout HEAD
    To checkout a commit by hash: Usage: bash submission.sh git_checkout <hash>
    To checkout a commit by message: Usage: bash submission.sh git_checkout -m <message>
COMMENT
elif [ "$1" = 'git_checkout' ]; then
    check_if_git_init_run_before
    if [ $? -eq 1 ]; then
        exit 1
    fi

    path_to_remote_repo=$(readlink -f ./.my_git)
    
    if [ "$2" = 'HEAD' ]; then
        latest_hash=$(tail -n 1 $path_to_remote_repo/.git_log.txt | cut -d ':' -f 1)
        bash submission.sh git_checkout $latest_hash
    
    elif [ "$2" = '-m' ]; then
        message=$3
        path_of_commit=$(find_folder_by_message "$path_to_remote_repo" "$message")
        return_code=$?
        if [ $return_code -eq 0 ]; then
            rm *.csv
            cp $path_of_commit/*.csv .
            echo "Commit with message '$message' checked out"
        elif [ $return_code -eq 1 ]; then
            echo "Multiple commits found with message '$message'"
            echo "Please use hash value"
            exit 1
        else
            echo "Commit with message '$message' not found"
            exit 1
        fi

    else
        hash_value=$2
        path_of_commit=$(find_folder_by_hash $path_to_remote_repo $hash_value)
        return_code=$?
        if [ $return_code -eq 0 ]; then
            rm *.csv
            cp $path_of_commit/*.csv .
            echo "Commit $hash_value checked out"
        elif [ $return_code -eq 1 ]; then
            echo "Multiple commits found with hash $hash_value"
            echo "Please use the full hash value"
            exit 1
        else
            echo "Commit with hash $hash_value not found"
            exit 1
        fi
    fi      

else
    echo "Invalid command"
    exit 1
fi