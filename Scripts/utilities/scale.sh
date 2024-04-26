# #!/bin/bash
source Scripts/utilities/additional_functions.sh

scale_marks() {
    examname=$1
    maxmarks_orig=$2
    maxmarks_final=$3
    awk -v examname="$examname" -v maxmarks_orig="$maxmarks_orig" -v maxmarks_final="$maxmarks_final" '
        BEGIN {FS=OFS=","}
        NR == 1 {print;}
        NR > 1 {
                final_marks = sprintf("%.2f", ($3 / maxmarks_orig) * maxmarks_final);
                printf "%s,%s,%.2f\n", $1, $2, final_marks;
            }
    ' $filename > tmp.csv && mv tmp.csv $filename   
}

if [ $# -ne 3 ]; then
    echo "Usage: bash scale.sh <examname> <maxmarks_orig> <maxmarks_final>"
    exit 1
fi

examname=$1
filename=$examname.csv
maxmarks_orig=$2
maxmarks_final=$3

scale_marks $examname $maxmarks_orig $maxmarks_final

total_run_before=$(check_if_total_run_before)

if [ -f "main.csv" ]; then
    update_mains
fi