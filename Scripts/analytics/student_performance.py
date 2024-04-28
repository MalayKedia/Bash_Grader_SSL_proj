import sys
import os
arguments = sys.argv[1:]

# Check for presence of specific flags and set corresponding flags
search_by_name=False
if "--name" in arguments:
    search_by_name = True
    del arguments[arguments.index("--name")]

close=False
if "--close" in arguments:
    close = True
    del arguments[arguments.index("--close")]

graph=False
if "--graph" in arguments:
    graph = True
    del arguments[arguments.index("--graph")]

if len(arguments) == 0:
    print("Invalid number of arguments")
    sys.exit(1)

# Define path to the main CSV file containing student data
directory = os.getcwd()
filename = os.path.join(directory, "main.csv")

if not os.path.isfile(filename):
    print("main.csv does not exist.")
    print("Run the command 'bash submission.sh combine' first")
    sys.exit(1)


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
import matplotlib.pyplot as plt


dataset = np.genfromtxt(filename, delimiter=',', dtype=str)
name_list = dataset[1:, 1]
roll_list = dataset[1:, 0]
marks_list = dataset[1:, 2:]
marks_header=dataset[0, 2:]
if marks_header[-1] == "total":
    marks_header = marks_header[:-1]
    marks_list = np.delete(marks_list, -1, axis=1)
    

if search_by_name:
    input_name = " ".join(arguments)
    
    # if close flag is set, find the closest name to the input name
    if close:
        input_name=find_closest_name(input_name, name_list)
        print("Closest name to "+input_name+" is "+input_name)  

    if not input_name in name_list:
        print("Name not found")
        sys.exit(1)
    
    roll = roll_list[np.where(name_list == input_name)][0]
    print("Roll number of "+input_name+" is "+roll)
    
    # Print marks of the student in all exams
    for exam in marks_header:
        marks=marks_list[np.where(name_list == input_name)][0][np.where(marks_header == exam)][0]
        if marks=='a':
            print("Student was absent in "+exam)
        else: 
            print("Marks in "+exam+" is "+marks)
else: # search by roll number
    if len(arguments) != 1:
        print("Invalid number of arguments")
        sys.exit(1)
    
    roll_no = arguments[0]
    
    if close:
        roll_no=find_closest_name(roll_no, roll_list)
        print("Closest roll number to "+arguments[0]+" is "+roll_no)
    
    if not roll_no in roll_list:
        print("Roll number not found")
        sys.exit(1)
    
    print("Name of the student is " + name_list[np.where(roll_list == roll_no)][0])
    
    for exam in marks_header:
        marks=marks_list[np.where(roll_list == roll_no)][0][np.where(marks_header == exam)][0]
        if marks=='a':
            print("Student was absent in "+exam)
        else: 
            print("Marks in "+exam+" is "+marks)
            
# If graph flag is set, plot the performance of the student in all exams
if graph:
    max_marks=[]
    avg_marks=[]
    student_marks=marks_list[np.where(roll_list == roll_no)][0]
    student_marks=[0 if i=='a' else float(i) for i in student_marks]
    
    for exam in marks_header:
        exam_marks=marks_list[:, np.where(marks_header == exam)[0][0]]
        exam_marks=[0 if i=='a' else float(i) for i in exam_marks]

        max_marks.append(max(exam_marks))
        avg_marks.append(np.mean(exam_marks))
    
    plt.plot(marks_header, student_marks, label='Marks of '+roll_no)
    plt.plot(marks_header, max_marks, label='Class Maximum')
    plt.plot(marks_header, avg_marks, label='Average')
    plt.legend()
    plt.grid(axis='y')
    plt.xlabel('Exams')
    plt.ylabel('Marks')
    plt.ylim(bottom=min(0,np.min(exam_marks)))
    plt.title('Performance of '+roll_no+' in Exams')
    plt.show()