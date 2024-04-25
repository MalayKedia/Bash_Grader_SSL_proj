import sys
import os
import numpy as np
arguments = sys.argv[1:]

directory = os.getcwd()
filename = os.path.join(directory, "main.csv")

if not os.path.isfile(filename):
    print("main.csv does not exist.")
    print("Run the command 'bash submission.sh combine' first")
    sys.exit(1)

data = np.genfromtxt(filename, delimiter=",", dtype=str)
header = data[0]

print_correlation_matrix = False
if "--matrix" in arguments:
    print_correlation_matrix = True
    del arguments[arguments.index("--matrix")]

if (len(arguments) != 2 and not print_correlation_matrix):
    print("Invalid number of arguments")
    sys.exit(1)

if not print_correlation_matrix:
    if arguments[0] == arguments[1]:
        print("The two exams should be different")
        sys.exit(1)

    col_1 = [i for i in range(len(header)) if header[i] == arguments[0]]
    col_2 = [i for i in range(len(header)) if header[i] == arguments[1]]

    if len(col_1) == 0:
        print(arguments[0] + " does not exist in main.csv")
        sys.exit(1)
    if len(col_2) == 0:
        print(arguments[1] + " does not exist in main.csv")
        sys.exit(1)
    col_1 = col_1[0]
    col_2 = col_2[0]

    marks_exam1 = np.array([0 if entry == 'a' else float(entry) for entry in data[1:, col_1]])
    marks_exam2 = np.array([0 if entry == 'a' else float(entry) for entry in data[1:, col_2]])

    correlation_coefficient = np.corrcoef(marks_exam1, marks_exam2)[0, 1]

    print("The correlation coefficient between", arguments[0], "and", arguments[1], "is",correlation_coefficient)
else:
    if len(arguments) == 0:
        arguments = header[2:]
    
    no_of_columns = len(arguments)
    for j in range(no_of_columns):
        if arguments[j] not in header:
            print(arguments[j] + " does not exist in main.csv")
            sys.exit(1)
    
    col = [None] * no_of_columns
    marks_exam = [None] * no_of_columns
    
    for j in range(no_of_columns):
        col[j] = [i for i in range(len(header)) if header[i] == arguments[j]][0]
        marks_exam[j] = np.array([0 if entry == 'a' else float(entry) for entry in data[1:, col[j]]])
                    
    correlation_matrix = np.ones((no_of_columns, no_of_columns))
    for i in range(no_of_columns):
        for j in range(no_of_columns):
            if i != j:
                correlation_matrix[i, j] = np.corrcoef(marks_exam[i], marks_exam[j])[0, 1]

    print("Order of columns:", arguments)
    print("Correlation matrix:")
    print(correlation_matrix)