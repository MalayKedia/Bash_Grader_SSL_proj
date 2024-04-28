import sys
import os
arguments = sys.argv[1:]

if len(arguments) == 0:
    print("Invalid number of arguments")
    sys.exit(1)

directory = os.getcwd()
filename = os.path.join(directory, "main.csv")

if not os.path.isfile(filename):
    print("main.csv does not exist.")
    print("Run the command 'bash submission.sh combine' first")
    sys.exit(1)

#### Not written by me
def levenshtein_distance(s1, s2):
    if len(s1) < len(s2):
        return levenshtein_distance(s2, s1)

    if len(s2) == 0:
        return len(s1)

    previous_row = range(len(s2) + 1)
    for i, c1 in enumerate(s1):
        current_row = [i + 1]
        for j, c2 in enumerate(s2):
            insertions = previous_row[j + 1] + 1
            deletions = current_row[j] + 1
            substitutions = previous_row[j] + (c1 != c2)
            current_row.append(min(insertions, deletions, substitutions))
        previous_row = current_row

    return previous_row[-1]

def find_closest_name(approx_name, name_list):
    min_distance = float('inf')
    closest_name = None
    
    for name in name_list:
        distance = levenshtein_distance(approx_name.lower(), name.lower())
        if distance < min_distance:
            min_distance = distance
            closest_name = name
            
    return closest_name

import numpy as np

dataset = np.genfromtxt(filename, delimiter=',', dtype=str)
name_list = dataset[1:, 1]
roll_list = dataset[1:, 0]

input_name = " ".join(arguments)
closest_name = find_closest_name(input_name, name_list)

print("Closest name to "+input_name+" is "+closest_name)
roll = roll_list[np.where(name_list == closest_name)][0]
print("Roll number of "+closest_name+" is "+roll)


## Another possible approach from external library:
# import Levenshtein

# def find_closest_name(approx_name, name_list):
#     closest_name = None
#     min_distance = float('inf')

#     for name in name_list:
#         distance = Levenshtein.distance(approx_name.lower(), name.lower())
#         if distance < min_distance:
#             min_distance = distance
#             closest_name = name

#     return closest_name