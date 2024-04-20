#!/bin/bash
source Scripts/utilities/additional_functions.sh

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
