import sys
import os
arguments = sys.argv[1:]

if len(arguments) == 0:
    current_directory = os.getcwd()
    files = os.listdir(current_directory)
    csv_files = [file for file in files if file.endswith('.csv') and file!='main.csv']
    file_names_without_extension = [file.replace('.csv', '') for file in csv_files]
    arguments=file_names_without_extension

for arg in arguments:
    directory = os.getcwd()
    filename = os.path.join(directory, arg + ".csv")

    if not os.path.isfile(filename):
        print("The file " + arg + ".csv does not exist.")
        sys.exit(1)

import numpy as np

def mode(scores):
    unique_elements, counts = np.unique(scores, return_counts=True)
    max_count_index = np.argmax(counts)
    return unique_elements[max_count_index]

data = np.genfromtxt(filename, delimiter=",", dtype=str, skip_header=1)
marks = np.array([float(entry) for entry in data[:, 2]])

print("Statistics for " + arg + ":")
print("The total number of students present:" , len(marks))
print("Mean:" , np.mean(marks))
print("Std Deviation:" , np.std(marks))
print("Median:" , np.median(marks))
print("Mode:" , mode(marks))
print("")