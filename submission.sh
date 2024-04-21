#!/bin/bash

# Exit if there is no command 0
if [ $# -eq 0 ]; then
    echo 'Usage: bash submission.sh <command> <any other extra arguments(if needed)>'
    exit 1
fi

# Check if the script is run from the directory where it is located
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
    To copy the files to the current directory: Usage: bash submission.sh upload <file1> <file2> <file3> ...
COMMENT
elif [ "$1" = 'upload' ]; then
    shift
    bash Scripts/utilities/upload.sh "$@"

# If the first argument is 'clean'
<< COMMENT
    To remove any files from current directory: Usage: bash submission.sh clean <file1> <file2> <file3> ...
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

# If the first argument is 'git_add_to_stage'
<< COMMENT
    To add new/modified files to the staging area: Usage: bash submission.sh git_add_to_stage <file1> <file2> ...
    To add deletion of a file to the staging area: Usage: bash submission.sh git_add_to_stage --delete <file1> <file2> ...
COMMENT
elif [ "$1" = 'git_add_to_stage' ]; then
    shift
    bash Scripts/git_commands/git_add_to_stage.sh "$@"

# If the first argument is 'git_remove_from_stage'
<< COMMENT
    To remove new/modified files from the staging area: Usage: bash submission.sh git_remove_from_stage <file1> <file2> ...
    To remove deletion of a file from the staging area: Usage: bash submission.sh git_remove_from_stage --delete <file1> <file2> ...
COMMENT
elif [ "$1" = 'git_remove_from_stage' ]; then
    shift
    bash Scripts/git_commands/git_remove_from_stage.sh "$@"

# If the first argument is 'git_status'
<< COMMENT
    To view the status of the current repository wrt the stage: Usage: bash submission.sh git_status
COMMENT
elif [ "$1" = 'git_status' ]; then
    shift
    bash Scripts/git_commands/git_status.sh "$@"

# If the first argument is 'git_commit'
<< COMMENT
    To commit the stage to the remote repository: Usage: bash submission.sh git_commit
    To commit the stage to the remote repository with a message: Usage: bash submission.sh git_commit -m <message>
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
    To checkout the commit n commits before HEAD: Usage: bash submission.sh git_checkout HEAD[~n]
    To checkout a commit by hash: Usage: bash submission.sh git_checkout <hash>
    To checkout a commit by message: Usage: bash submission.sh git_checkout -m <message>
COMMENT
elif [ "$1" = 'git_checkout' ]; then
    shift
    bash Scripts/git_commands/git_checkout.sh "$@"

# If the first argument is 'plot_histogram'
<<COMMENT
    To plot a histogram of marks of an exam: Usage: bash submission.sh plot_histogram [options] examname
Options:
  --maxmarks <value>   Set the maximum value for the marks
  --minmarks <value>   Set the minimum value for the marks
  -o <output_file>     Specify the output file for the generated plot
  --bins <value>       Set the number of bins in the histogram (default: 10)
COMMENT
elif [ "$1" = 'plot_histogram' ]; then
    shift
    python3 Scripts/analytics/plot_histogram.py "$@"

# If the first argument is 'plot_scatter'
<<COMMENT
    To plot a scatter plot of marks of two exams: Usage: bash submission.sh plot_scatter [options] exam1 exam2
Options:
    -o <output_file>     Specify the output file for the generated plot
COMMENT
elif [ "$1" = 'plot_scatter' ]; then
    shift
    python3 Scripts/analytics/plot_scatter.py "$@"

# Return an error if invalid command is given
else
    echo "Invalid command"
    exit 1
fi