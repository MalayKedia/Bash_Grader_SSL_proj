import sys
import os
arguments = sys.argv[1:]

if "-o" in arguments:
    output_file = arguments[arguments.index("-o") + 1]
    del arguments[arguments.index("-o") + 1]
    del arguments[arguments.index("-o")]

if len(arguments) != 2:
    print("Invalid number of arguments")
    sys.exit(1)
if arguments[0] == arguments[1]:
    print("The two exams should be different")
    sys.exit(1)

directory = os.getcwd()
filename = os.path.join(directory, "main.csv")

if not os.path.isfile(filename):
    print("main.csv does not exist.")
    print("Run the command 'bash submission.sh combine' first")
    sys.exit(1)
    
import matplotlib.pyplot as plt
import numpy as np

data = np.genfromtxt(filename, delimiter=",", dtype=str)
header = data[0]

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

plt.figure(figsize=(8, 6))
plt.scatter(marks_exam1, marks_exam2, color='skyblue', alpha=0.7)
plt.xlabel("arguments[0]")
plt.ylabel("arguments[1]")
plt.title("Correlation of marks of students between " + arguments[0] + " and " + arguments[1])
plt.grid(alpha=0.75)

if "output_file" in locals():
    plt.savefig(output_file)
else:
    plt.show()