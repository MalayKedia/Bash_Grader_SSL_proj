#!/bin/bash
source Scripts/utilities/additional_functions.sh

for file in "$@"; do
    if [ -f "$file" ]; then
        rm "$file"
    else
        echo "File $file does not exist"
    fi
done