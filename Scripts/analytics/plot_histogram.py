import sys
import os
arguments = sys.argv[1:]

# checks for the flags and arguments
if "--maxmarks" in arguments:
    maxmarks = float(arguments[arguments.index("--maxmarks") + 1])
    del arguments[arguments.index("--maxmarks") + 1]
    del arguments[arguments.index("--maxmarks")]
    
if "--minmarks" in arguments:
    minmarks = float(arguments[arguments.index("--minmarks") + 1])
    del arguments[arguments.index("--minmarks") + 1]
    del arguments[arguments.index("--minmarks")]

if "-o" in arguments:
    output_file = arguments[arguments.index("-o") + 1]
    del arguments[arguments.index("-o") + 1]
    del arguments[arguments.index("-o")]

if "--bins" in arguments:
    no_of_bins = int(arguments[arguments.index("--bins") + 1])
    del arguments[arguments.index("--bins") + 1]
    del arguments[arguments.index("--bins")]
    
if not locals().get("no_of_bins"):
    no_of_bins = 10  

if len(arguments) != 1:
    print("Invalid number of arguments")
    sys.exit(1)

directory = os.getcwd()
filename = os.path.join(directory, arguments[0] + ".csv")

if not os.path.isfile(filename):
    print("The file " + arguments[0] + ".csv does not exist.")
    sys.exit(1)
    
import matplotlib.pyplot as plt
import numpy as np

data = np.genfromtxt(filename, delimiter=",", dtype=str, skip_header=1)
marks = np.array([0 if entry == 'a' else float(entry) for entry in data[:, 2]])

plt.figure(figsize=(8, 6))

if "minmarks" in locals() and "maxmarks" in locals():
    bin_range = (minmarks, maxmarks)
elif "minmarks" in locals():
    bin_range = (minmarks, max(marks))
elif "maxmarks" in locals():
    bin_range = (min(marks), maxmarks)
else:
    bin_range = (min(marks), max(marks))

plt.hist(marks, bins=no_of_bins, range=bin_range, color='skyblue', edgecolor='black', alpha=0.7)
plt.xlabel('Marks')
plt.ylabel('Frequency')
plt.title('Mark Distribution for ' + arguments[0])
plt.grid(axis='y', alpha=0.75)

if "output_file" in locals():
    plt.savefig(output_file)
else:
    plt.show()