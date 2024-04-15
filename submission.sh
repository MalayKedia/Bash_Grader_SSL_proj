#!/bin/bash

# Exit if there is no command 0
if [ $# -eq 0 ]; then
    echo 'Usage: bash submission.sh <command> <any other extra arguments(if needed)>'
    exit 1
fi

# If the first argument is 'combine'
: '
    Combine all csv files in the directory
    To combine all csv files in current directory: Usage: bash submission.sh combine
    To combine all csv files in a given directory: Usage: bash submission.sh combine <directory>
    To combine given csv files (more than 1):      Usage: bash submission.sh combine <file1.csv> <file2.csv> <file3.csv> ...
'
if [ "$1" = 'combine' ]; then
    total_run_before=false
    if [ -f "main.csv" ]; then
        total_exists=$(head -n 1 main.csv | grep "total")
        if [ -n "$total_exists" ]; then
            total_run_before=true
        fi
    fi
    touch main.csv
    echo -n "Roll_Number,Name" > main.csv
    if [ $# -gt 2 ]; then
        # Check if all extra arguments are csv files
        for file in "${@:2}"; do
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
        for file in "${@:2}"; do
            echo -n ",$(basename "$file" .csv )" >> main.csv
        done
        echo "" >> main.csv
        # put the names and roll numbers
        for file in "${@:2}"; do
            awk -F, 'NR>1 {print $1","$2}' "$file" >> main.csv   
        done >> main.csv
        tail -n +2 main.csv | sort -k1 | uniq > temp.csv
        header=$(head -n 1 main.csv)
        echo $header > main.csv
        cat temp.csv >> main.csv 
        rm temp.csv

        # put the marks
        for file in "${@:2}"; do
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

        if [ "$total_run_before" = true ]; then
            bash submission.sh total
        fi
    elif [ $# -eq 2 ]; then
        # If only one extra argument is provided, assume it to be a directory and combine all csv files in the directory
        filenames=$(ls $2/*.csv)
        bash submission.sh combine $filenames
    elif [ $# -eq 1 ]; then
        # If no extra arguments are provided, combine all csv files in the directory
        bash submission.sh combine .
    fi
fi

# If the first argument is 'upload'
: '
    `upload` command is used to copy the file to the given directory
    To copy the file to the current directory: Usage: bash submission.sh upload <file>
'
if [ "$1" = 'upload' ]; then
    if [ $# -eq 3 ]; then
        if [ -d "$3" ]; then
            cp $2 $3
        else
            echo "{$3} is not a directory"
            exit 1
        fi
   
    elif [ $# -eq 2 ]; then
        cp $2 .
    fi
fi

# If the first argument is 'total'
if [ "$1" = 'total' ]; then
    if [ -f "main.csv" ]; then
        total_exists=$(head -n 1 main.csv | grep "total")
        if [ -n "$total_exists" ]; then
            echo "Total has already been run"
        else
            echo "total" > total.csv
            awk -F, 'NR>1 {for(i=3;i<=NF;i++) { if ($i == "a") $i = 0; s+=$i;} print s; s=0;}' main.csv >> total.csv
            paste -d',' main.csv total.csv > temp.csv
            mv temp.csv main.csv
            rm total.csv
        fi
    else
        echo "main.csv does not exist"
        echo "Run the command 'bash submission.sh combine' first"
        exit 1  
    fi
fi
if [ "$1" = 'update' ]; then
    echo "Roll No. of student to be updated: "
    read roll_no
    echo "Enter exam name: "
    read exam_name
    echo "Enter new marks: "
    read new_marks
    if [ -f "main.csv" ]; then
        echo "yo"
    else
        echo "main.csv does not exist"
        echo "Run the command 'bash submission.sh combine' first"
        exit 1  
    fi
fi

# If the first argument is 'clean'
if [ "$1" = 'clean' ]; then
    rm main.csv
fi

if [ "$1" != 'combine' ] && [ "$1" != 'upload' ] && [ "$1" != 'total' ] && [ "$1" != 'clean' ]; then
    echo "Invalid command"
    exit 1
fi
