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

# If the first argument is 'scale'
<< COMMENT
    To scale the marks of each student: Usage: bash submission.sh scale <examname> <maxmarks_orig> <maxmarks_final>
COMMENT
elif [ "$1" = 'scale' ]; then
    shift
    bash Scripts/utilities/scale.sh "$@"

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

# If the first argument is 'closest_name'
<< COMMENT
    To find the closest name to a given name: Usage: bash submission.sh closest_name <name>
COMMENT
elif [ "$1" = 'closest_name' ]; then
    shift
    python3 Scripts/analytics/closest_name.py "$@"

# If the first argument is 'student_performance'
<< COMMENT
    To print the marks of a student from roll no.: Usage: bash submission.sh student_performance <student_roll_no>
    To print the marks of a student from name:     Usage: bash submission.sh student_performance --name <student_name>
Options:
    --close: Specify to print the marks of the closest name/ roll_no to the given name
    --graph: Specify to plot the marks of the student relative to the class
COMMENT
elif [ "$1" = 'student_performance' ]; then
    shift
    python3 Scripts/analytics/student_performance.py "$@"

# If the first argument is 'calc_stats'
<< COMMENT
    To calculate the statistics of the marks: Usage: bash submission.sh calc_stats <examname1>  <examname2> ... (total is a valid examname)
    (By default, it calculates stats for all exams)
COMMENT
elif [ "$1" = 'calc_stats' ]; then
    shift
    python3 Scripts/analytics/calc_stats.py "$@"

# If the first argument is 'calc_correlation'
<< COMMENT
    To calculate the correlation between the marks of two exams: Usage: bash submission.sh calc_correlation <exam1> <exam2>
Options:
  --matrix: Print correlation matrix for multiple columns:    Usage: bash submission.sh calc_correlation --matrix <exam1> <exam2> ...
COMMENT
elif [ "$1" = 'calc_correlation' ]; then
    shift
    python3 Scripts/analytics/calc_correlation.py "$@"

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

# If the first argument is 'grade'
<< COMMENT
    To grade the students: Usage: bash submission.sh grade <output_file> [options]
Options:
    --baskets: Specify custom grade baskets in descending order. Default is ['AA', 'AB', 'BB', 'BC', 'CC', 'CD', 'DD', 'FF'].
    --clustering: Use clustering-based grading.
    --relative: Use relative grading based on mean and standard deviation.
    --absolute: Use absolute grading with custom grade boundaries.
    --boundaries: Specify custom grade boundaries when using absolute grading.
    --criteria: Specify the criteria for grading(Default is total)
COMMENT
elif [ "$1" = 'grade' ]; then
    shift
    python3 Scripts/analytics/grade.py "$@"

# If the first argument is 'report_card'
<< COMMENT
    To generate the report card of a student: Usage: bash submission.sh report_card <student_roll_no>
    # To generate the report card of a student: Usage: bash submission.sh report_card --name <student_name>
    All report cards are saved in the "Reports" directory
Options:
    -o <output_file>: Specify the output file for the generated report card (default: report_{roll_no}.pdf)
    --grades_file <file>: Specify the file containing the grades of the students
COMMENT
elif [ "$1" = 'report_card' ]; then
    shift
    python3 Scripts/analytics/report_card.py "$@"

# Return an error if invalid command is given
else
    echo "Invalid command"
    exit 1
fi