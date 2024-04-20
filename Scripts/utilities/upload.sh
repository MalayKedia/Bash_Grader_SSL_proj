#!/bin/bash
source Scripts/utilities/additional_functions.sh

if [ $# -lt 1 ]; then
    echo 'Specify the file to be uploaded'
else
    cp "$@" .
    echo "File(s) $@ uploaded"
fi