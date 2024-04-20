#!/bin/bash

# combine3() {
#     touch main.csv
#     echo -n "Roll_Number,Name" > main.csv

#     # Check if all extra arguments are csv files
#     for file in "$@"; do
#         if [ ! -f "$file" ]; then
#             echo "File $file does not exist"
#             exit 1
#         elif [[ ! "$file" == *.csv ]]; then
#             echo "File $file is not a CSV file"
#             exit 1
#         fi
#     done

#     # Create the header
#     for file in "$@"; do
#         echo -n ",$(basename "$file" .csv )" >> main.csv
#     done
#     echo "" >> main.csv

#     # Put the names and roll numbers
#     for file in "$@"; do
#         awk -F ',' 'NR > 1 {print $1 "," $2}' "$file"
#     done >> main.csv

#     # Remove duplicates based on roll numbers and sort
#     tail -n +2 main.csv | sort -t ',' -k1 | uniq > temp.csv
#     header=$(head -n 1 main.csv)
#     echo "$header" > main.csv
#     cat temp.csv >> main.csv 
#     rm temp.csv

#     # Put the marks
#     for file in "$@"; do
#         awk -F ',' -v file="$file" 'NR > 1 { 
#             marks=$(grep -m 1 "^$1," file | awk -F"," "{print \$3}")
#             if (marks == "") {
#                 marks="a"
#             }
#             print $0 "," marks
#         }' main.csv > temp.csv
#         mv temp.csv main.csv
#     done
# }


# combine2() {
#     touch main.csv
#     echo -n "Roll_Number,Name" > main.csv

#     # Check if all extra arguments are csv files
#     for file in "$@"; do
#         if [ -f "$file" ]; then
#             if [[ ! "$file" == *.csv ]]; then
#                 echo "File $file is not a CSV file"
#                 exit 1
#             fi
#         else
#             echo "File $file does not exist"
#             exit 1
#         fi
#     done
#     # Create the header
#     for file in "$@"; do
#         echo -n ",$(basename "$file" .csv )" >> main.csv
#     done
#     echo "" >> main.csv
#     # put the names and roll numbers
#     declare -A name
#     for file in "$@"; do
#         while IFS=',' read -r roll_no name marks; do
#             name["$roll_no"]=$name
#         done < "$file"
#     done
#     unset name["Roll_Number"]
#     # unset name[""]

#     for roll_no in ${!name[@]}; do
#         echo "$roll_no,${name[$roll_no]}" >> main.csv
#     done
#     # put the marks
#     for file in "$@"; do
#         line_number_in_main=0
#         while read -r line || [ -n "$line" ]; do
#             ((line_number_in_main++))
#             if [ $line_number_in_main -eq 1 ]; then
#                 continue  # Skip processing the header
#             fi
            
#             roll_no="$(echo "$line" | cut -d ',' -f 1)"
            
#             line_number_in_marks=$(cut -d ',' -f 1 "$file" | grep -n -m 1 "^$roll_no" | cut -d ':' -f 1)
            
#             if [ -z "$line_number_in_marks" ]; then
#                 sed -i "${line_number_in_main}s/$/,a/" main.csv
#             else
#                 marks=$(head -n "$line_number_in_marks" "$file" | tail -n 1 | cut -d ',' -f 3)
#                 sed -i "${line_number_in_main}s/$/,${marks}/" main.csv
#             fi
            
#         done < main.csv
#     done >> main.csv    
# }

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

total() {
    echo "total" > total.csv
    awk -F, 'NR>1 {for(i=3;i<=NF;i++) { if ($i == "a") $i = 0; s+=$i;} print s; s=0;}' main.csv >> total.csv
    paste -d',' main.csv total.csv > temp1212.csv
    mv temp1212.csv main.csv
    rm total.csv
}