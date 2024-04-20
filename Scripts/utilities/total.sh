#!/bin/bash
source Scripts/utilities/additional_functions.sh

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