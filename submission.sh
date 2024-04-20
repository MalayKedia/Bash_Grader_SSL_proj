#!/bin/bash

# Exit if there is no command 0
if [ $# -eq 0 ]; then
    echo 'Usage: bash submission.sh <command> <any other extra arguments(if needed)>'
    exit 1
fi

present_dir=$(pwd)
path_of_script=$(realpath $(dirname "$0"))
if [ "$present_dir" != "$path_of_script" ]; then
    echo "Please run the script from the directory where it is located"
    exit 1
fi

# If the first argument is 'combine'
<< COMMENT
    To combine all csv files in current directory: Usage: bash submission.sh combine
    To combine given csv files:                    Usage: bash submission.sh combine <file1.csv> <file2.csv> <file3.csv> ...
COMMENT
if [ "$1" = 'combine' ]; then
    shift
    bash Scripts/utilities/combine.sh "$@"

# If the first argument is 'upload'
<< COMMENT
    To copy the file to the current directory: Usage: bash submission.sh upload <file>
COMMENT
elif [ "$1" = 'upload' ]; then
    shift
    bash Scripts/utilities/upload.sh "$@"

# If the first argument is 'clean'
<< COMMENT
    To remove any file: Usage: bash submission.sh clean <file1> <file2> <file3> ...
COMMENT
elif [ "$1" = 'clean' ]; then
    shift
    bash Scripts/utilities/clean.sh "$@"

# If the first argument is 'total'
<< COMMENT
    To calculate the total marks of each student: Usage: bash submission.sh total
COMMENT
elif [ "$1" = 'total' ]; then
    shift
    bash Scripts/utilities/total.sh "$@"    

# If the first argument is 'update'
<< COMMENT
    To update the marks of a student: Usage: bash submission.sh update
COMMENT
elif [ "$1" = 'update' ]; then
    shift
    bash Scripts/utilities/update.sh "$@"

# If the first argument is 'git_init'
<< COMMENT
    To initialize a remote repository: Usage: bash submission.sh git_init <path_to_remote_repo>
COMMENT
elif [ "$1" = 'git_init' ]; then
    shift
    bash Scripts/git_commands/git_init.sh "$@"

elif [ "$1" = 'git_add_to_stage' ]; then
    shift
    bash Scripts/git_commands/git_add_to_stage.sh "$@"

elif [ "$1" = 'git_remove_from_stage' ]; then
    shift
    bash Scripts/git_commands/git_remove_from_stage.sh "$@"

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