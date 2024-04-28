# This function updates already existing main.csv file with the new data, keeping order of columns same as before (new columns are not added)
update_mains() {
    header=$(head -n 1 main.csv | cut -d ',' --output-delimiter " " -f 3- | sed 's/ total$//')
    
    filenames=""
    for i in $header; do
        if [ -f "$i.csv" ]; then
            filenames="${filenames} $i.csv"
        fi
    done    
    bash submission.sh combine $filenames
}

# This function returns true if main.csv exists and has a 'total' column at the end, else returns false
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

# This function calculates the total marks of each student and appends it as last column of main.csv file
total() {
    echo "total" > total.csv
    awk -F, 'NR>1 {for(i=3;i<=NF;i++) { if ($i == "a") $i = 0; s+=$i;} print s; s=0;}' main.csv >> total.csv
    paste -d',' main.csv total.csv > temp1212.csv
    mv temp1212.csv main.csv
    rm total.csv
}