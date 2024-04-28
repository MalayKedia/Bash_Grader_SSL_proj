#!/bin/bash
source Scripts/utilities/additional_functions.sh

# this function takes as arguments exam name and roll number and updates the marks of the student in corresponding exam file
update_marks() {
    exam_name=$1
    roll_no=$2
    read -p "Enter the marks obtained by the student: " marks
    awk -v roll_no="$roll_no" -v marks="$marks" '
        BEGIN{FS=OFS=","} 
        $1 == roll_no {$3 = marks} 
        {print}' $exam_name.csv > temp1212.csv
    mv temp1212.csv $exam_name.csv

    echo "Marks updated successfully"
}

# this function only works when main.csv exists, and updates the marks of the student in main.csv as well as the exam file
# it can update the marks of multiple students one exam in a single run
if [ -f "main.csv" ]; then
    read -p "Enter the exam name: " exam_name

    if [ -f "$exam_name.csv" ]; then
        while true; do
            read -p "Enter the roll no. of the student: " roll_no

            # it allows adding a student if the roll number does not exist in the database
            if [ -z "$(cut -d ',' -f 1 main.csv | grep "^$roll_no$")" ]; then
                read -p "This roll number does not exist in the database. Would you like to add this student? (y/n)" choice
                if [ $choice = 'y' ]; then
                    read -p "Enter the name of the student: " name
                    echo "$roll_no,$name," >> $exam_name.csv
                    echo "Student added successfully"
                    update_marks $exam_name $roll_no
                else
                    echo "Please try again"
                fi
            else
                name=$(awk -v roll_no="$roll_no" 'BEGIN{FS=","} $1 == roll_no {print $2}' main.csv)
                read -p "The name of the student with roll no. $roll_no is $name. Do you accept? (y/n)" choice
                if [ $choice = 'y' ]; then
                    update_marks $exam_name $roll_no
                else
                    echo "Please try again"
                fi
            fi

            read -p "Do you want to update marks for another student? (y/n)" choice
            if [ ! $choice = 'y' ]; then
                break
            fi
        done
        if [ -f "main.csv" ]; then
            update_mains
        fi
    else
        echo "Exam not found, please try again"
    fi
else
    echo "Run 'bash submission.sh combine' first"
fi