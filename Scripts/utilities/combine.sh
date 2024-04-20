#!/bin/bash
source Scripts/utilities/additional_functions.sh

total_run_before=$(check_if_total_run_before)

if [ $# -gt 0 ]; then
    combine "$@"
else
    # If no extra arguments are provided, combine all csv files in the directory
    files=$(ls *.csv | grep -v "main.csv")
    combine $files
fi

if [ "$total_run_before" = true ]; then
    total
fi