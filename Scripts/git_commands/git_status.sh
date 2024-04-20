#!/bin/bash
source Scripts/git_commands/additional_functions.sh

echo "Changes to be commited:"
echo "Changes not staged for commit:"
echo "Untracked files:"

A file in last commit, which is added, comes as modiefied, else as New file in 1st cat
A file which was in last commit and changed, but not in stage comes in 2nd cat as modified, and which was in deleted comes as such
A file 