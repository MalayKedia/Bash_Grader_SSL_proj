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


total() {
    echo "total" > total.csv
    awk -F, 'NR>1 {for(i=3;i<=NF;i++) { if ($i == "a") $i = 0; s+=$i;} print s; s=0;}' main.csv >> total.csv
    paste -d',' main.csv total.csv > temp1212.csv
    mv temp1212.csv main.csv
    rm total.csv
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
    shift
    bash Scripts/git_commands/git_init.sh "$@"

elif [ "$1" = 'git_add' ]; then
    shift
    bash Scripts/git_commands/git_add.sh "$@"

elif [ "$1" = 'git_status' ]; then
    shift
    bash Scripts/git_commands/git_status.sh "$@"

# If the first argument is 'git_commit'
<< COMMENT
    To commit the changes to the remote repository: Usage: bash submission.sh git_commit
    To commit the changes to the remote repository with a message: Usage: bash submission.sh git_commit -m <message>
COMMENT
elif [ "$1" = 'git_commit' ]; then
    shift
    bash Scripts/git_commands/git_commit.sh "$@"


# If the first argument is 'git_log'
<< COMMENT
    To view the log of the remote repository: Usage: bash submission.sh git_log
COMMENT
elif [ "$1" = 'git_log' ]; then
    shift
    bash Scripts/git_commands/git_log.sh "$@"


# If the first argument is 'git_checkout'
<< COMMENT
    To checkout the latest commit: Usage: bash submission.sh git_checkout HEAD
    To checkout a commit by hash: Usage: bash submission.sh git_checkout <hash>
    To checkout a commit by message: Usage: bash submission.sh git_checkout -m <message>
COMMENT
elif [ "$1" = 'git_checkout' ]; then
    shift
    bash Scripts/git_commands/git_checkout.sh "$@"


elif [ "$1" = 'plot_histogram' ]; then
    max_marks=""  # Default value for maximum marks
    output_file="" # Default value for output file

    # Parsing command-line options
    while getopts ":m:o:" opt; do
        case $opt in
            m)
                max_marks="$OPTARG"
                echo "hi"
                ;;
            o)
                output_file="$OPTARG"   
                echo "bye"
                ;;
            \?)
                echo "Invalid option: -$OPTARG"
                exit 1
                ;;
            :)
                echo "Option -$OPTARG requires an argument."
                exit 1
                ;;
        esac
    done
    shift $((OPTIND -1)) # Shift to next argument after options

    filename="$1.csv"
    if [ ! -f "$filename" ]; then
        echo "File $filename does not exist"
        exit 1
    fi

    python3 - <<END
import matplotlib.pyplot as plt
import numpy as np

data = np.genfromtxt("$filename", delimiter=",", dtype=str, skip_header=1)
marks = np.array([0 if entry == 'a' else float(entry) for entry in data[:, 2]])

plt.figure(figsize=(8, 6))
plt.hist(marks, bins=20, color='skyblue', edgecolor='black', alpha=0.7)
plt.xlabel('Marks')
plt.ylabel('Frequency')
plt.title('Mark distribution for $1')
plt.grid(axis='y', alpha=0.75)

if "$max_marks" != ""; then
    plt.xlim(0, $max_marks)
fi

if "$output_file" != ""; then
    plt.savefig("$output_file")
else
    plt.show()
fi
END
elif [ "$1" = 'plot_scatter' ]; then
    exam1="$2"
    exam2="$3"
    col_no_1=$(awk -F, -v exam1="$exam1" 'NR==1 {for(i=1;i<=NF;i++) {if ($i == exam1) print i}}' main.csv)
    col_no_2=$(awk -F, -v exam2="$exam2" 'NR==1 {for(i=1;i<=NF;i++) {if ($i == exam2) print i}}' main.csv)
    python3 - <<END

import matplotlib.pyplot as plt
import numpy as np

data = np.genfromtxt("main.csv", delimiter=",", skip_header=1)
marks1 = data[:, ${col_no_1}-1]
marks2 = data[:, ${col_no_2}-1]

plt.figure(figsize=(8, 6))
plt.scatter(marks1, marks2, color='skyblue', alpha=0.7)
plt.xlabel('${exam1}')
plt.ylabel('${exam2}')
plt.title('Correlation between ${exam1} and ${exam2}')
plt.grid(alpha=0.75)
plt.show()
END

else
    echo "Invalid command"
    exit 1
fi