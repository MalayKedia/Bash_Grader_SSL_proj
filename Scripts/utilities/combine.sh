#!/bin/bash
source Scripts/utilities/additional_functions.sh

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
    tail -n +2 main.csv | sort -k1 | uniq > temp1212.csv
    header=$(head -n 1 main.csv)
    echo $header > main.csv
    cat temp1212.csv >> main.csv 
    rm temp1212.csv

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

            # if the roll number does not exist in the marks file, add a "a" for absent            
            if [ -z "$line_number_in_marks" ]; then
                sed -i "${line_number_in_main}s/$/,a/" main.csv
            else
                marks=$(head -n "$line_number_in_marks" "$file" | tail -n 1 | cut -d ',' -f 3)
                sed -i "${line_number_in_main}s/$/,${marks}/" main.csv
            fi
            
        done < main.csv
    done >> main.csv    
}


total_run_before=$(check_if_total_run_before)

if [ $# -gt 0 ]; then
    combine "$@"
else
    # If no extra arguments are provided, combine all csv files in the directory except main.csv
    files=$(ls *.csv | grep -v "main.csv")
    combine $files
fi

if [ "$total_run_before" = true ]; then
    total
fi