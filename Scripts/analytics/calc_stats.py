import sys
import os
arguments = sys.argv[1:]

# if no arguments are provided, calculate statistics for all CSV files in the current directory
if len(arguments) == 0:
    current_directory = os.getcwd()
    files = os.listdir(current_directory)
    csv_files = [file for file in files if file.endswith('.csv') and file!='main.csv']
    file_names_without_extension = [file.replace('.csv', '') for file in csv_files]
    arguments=file_names_without_extension

for arg in arguments:
    # if total is provided as an argument, check if main.csv exists and if the last column is total
    if arg == "total":
        directory = os.getcwd()
        filename = os.path.join(directory, "main.csv")

        if not os.path.isfile(filename):
            print("Run the command 'bash submission.sh combine' first")
            sys.exit(1)
        else:
            with open("main.csv", "r") as file:
                headers = file.readline().strip().split(",")
            if headers[-1] != "total":
                print("Run the command 'bash submission.sh total' first")
                sys.exit(1)
    else:
    # check if the CSV file exists
        directory = os.getcwd()
        filename = os.path.join(directory, arg + ".csv")

        if not os.path.isfile(filename):
            print("The file " + arg + ".csv does not exist.")
            sys.exit(1)

import numpy as np
from scipy.stats import skew 
from scipy.stats import mode

# def mode(scores):
#     unique_elements, counts = np.unique(scores, return_counts=True)
#     max_count_index = np.argmax(counts)
#     return unique_elements[max_count_index]


#prints the statistics for the given marks
def print_stats(marks):
    print("Statistics for " + arg + ":")
    print("The total number of students present:" , len(marks))
    print("Maximum:" , np.max(marks))
    print("Minimum:" , np.min(marks))
    print("Mean:" , np.mean(marks))
    print("Std Deviation:" , np.std(marks))
    print("Skewness:" , skew(marks))
    print("First Quartile:" , np.percentile(marks, 25))
    print("Second Quartile (Median):" , np.percentile(marks, 50))
    print("Third Quartile:" , np.percentile(marks, 75))
    print("Mode:" , mode(marks).mode)
    print("")

# calculate statistics for each CSV file provided as an argument
for arg in arguments:
    if arg == "total":
        directory = os.getcwd()
        filename = os.path.join(directory, "main.csv")
        data = np.genfromtxt(filename, delimiter=",", dtype=str, skip_header=1)
        marks = np.array([float(entry) for entry in data[:, -1]])
        print_stats(marks)
    else:
        directory = os.getcwd()
        filename = os.path.join(directory, arg + ".csv")
        data = np.genfromtxt(filename, delimiter=",", dtype=str, skip_header=1)
        marks = np.array([float(entry) for entry in data[:, 2]])
        print_stats(marks)