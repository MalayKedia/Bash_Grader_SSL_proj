import sys
import os
arguments = sys.argv[1:]

# Define the path to the main CSV file containing student data
directory = os.getcwd()
filename = os.path.join(directory, "main.csv")

if not os.path.isfile(filename):
    print("main.csv does not exist.")
    print("Run the command 'bash submission.sh combine' first")
    sys.exit(1)

# Define the default output directory for generated report cards
if not os.path.exists("Reports"):
    os.makedirs("Reports")
    print("Directory 'Reports' created successfully")

output_dir = os.path.join(directory, "Reports")

# Interpret the provided flags and arguments
if "-o" in arguments:
    output_file_name = arguments[arguments.index("-o") + 1]
    output_file = os.path.join(output_dir, output_file_name)
    del arguments[arguments.index("-o") + 1]
    del arguments[arguments.index("-o")]

if "--grades_file" in arguments:
    grades_file = os.path.join(directory, arguments[arguments.index("--grades_file") + 1])
    del arguments[arguments.index("--grades_file") + 1]
    del arguments[arguments.index("--grades_file")]

if len(arguments) != 1:
    print("Invalid number of arguments")
    sys.exit(1)

# If output file name is not provided, set the file name as 'report_<roll_no>'
roll_no=arguments[0]
if not locals().get("output_file"):
    output_file = os.path.join(output_dir, "report_{}".format(roll_no))        

import numpy as np
import matplotlib.pyplot as plt

dataset = np.genfromtxt(filename, delimiter=',', dtype=str)
name_list = dataset[1:, 1]
roll_list = dataset[1:, 0]
marks_list = dataset[1:, 2:]
marks_header=dataset[0, 2:]

# remove the total column if it exists
if marks_header[-1] == "total":
    total_marks = marks_list[:, -1]
    marks_header = marks_header[:-1]
    marks_list = np.delete(marks_list, -1, axis=1)

if not roll_no in roll_list:
    print("Roll number not found")
    sys.exit(1)

name=name_list[np.where(roll_list == roll_no)][0]
marks_student=marks_list[np.where(roll_list == roll_no)][0]

if locals().get("grades_file"):
    if not os.path.isfile(grades_file):
        print("Grades file does not exist.")
        sys.exit(1)
    
    grades_data_all=np.genfromtxt(grades_file, delimiter=',', dtype=str)
    grades_roll=grades_data_all[1:, 0]
    grades_data=grades_data_all[1:, 3]
    grade=grades_data[np.where(grades_roll == roll_no)][0]
    
    rank=np.sum(grades_data>grade)+1
    percentile=rank/len(grades_data)*100

max_marks=[]
avg_marks=[]
student_marks=marks_list[np.where(roll_list == roll_no)][0]
student_marks=[0 if i=='a' else float(i) for i in student_marks]

for exam in marks_header:
    exam_marks=marks_list[:, np.where(marks_header == exam)[0][0]]
    exam_marks=[0 if i=='a' else float(i) for i in exam_marks]

    max_marks.append(max(exam_marks))
    avg_marks.append(np.mean(exam_marks))
    
# Plot the performance of the student in each exam and save the plot as a PNG file 
plt.plot(marks_header, student_marks, label='Marks of '+roll_no)
plt.plot(marks_header, max_marks, label='Class Maximum')
plt.plot(marks_header, avg_marks, label='Average')
plt.legend()
plt.grid(axis='y')
plt.xlabel('Exams')
plt.ylabel('Marks')
plt.ylim(bottom=min(0,np.min(exam_marks)))
plt.title('Performance in Exams')
plt.savefig(os.path.join(output_dir, 'tempPerf.png'))

# Generate the LaTeX content for the report card
latex_content = r"""
\documentclass[12pt]{article}
\usepackage{geometry}
\usepackage{graphicx}
\geometry{a4paper, margin=1in}
\begin{document}

\title{Report Card}
\author{}
\date{}
\maketitle
\section{Student Details}

\begin{tabular}{lcl}
"""
latex_content+=r"""
Roll No & : & {} \\
Name & : & {} \\""".format(roll_no, name)

latex_content+=r"""
\end{tabular}

\section{Marks}
\begin{center}
    \begin{tabular}{|p{4cm}|p{4cm}|p{4cm}|}
        \hline  
        Exam & Student Marks & Max Marks obtained \\
        \hline
"""

for exam, mark in zip(marks_header, marks_student):
    latex_content+="        {} & {} & {} \\\ \n".format(exam, mark, max_marks[np.where(marks_header == exam)[0][0]])

latex_content+=r"""
        \hline
    \end{tabular}    
\end{center}

\begin{figure}[h]
    \centering
"""

latex_content+=r"""
    \includegraphics[width=0.6\textwidth]{"""+"tempPerf.png"+"""}
\end{figure}
"""

if grade:
    latex_content+=r"""
    \section{Performance}
    \begin{center}
        \begin{tabular}{lcl}
    """
    
    latex_content+="""
    Percentile & : & {:.2f} \% \\\\""".format(percentile)
    latex_content+="""
    Rank & : & {} \\\\""".format(rank)
    latex_content+="""
    Grade & : & {} \\\\""".format(grade)
    
    latex_content+=r"""
        \end{tabular}
    \end{center}
    """

latex_content+=r"""
\end{document}
"""

# Write the LaTeX content to a .tex file
output_tex_file = "{}.tex".format(output_file)
with open(output_tex_file, "w") as tex_file:
    tex_file.write(latex_content)

# Compile the .tex file to generate the PDF report card
os.system("pdflatex -output-directory=Reports {} > /dev/null 2>&1".format(output_tex_file))

# Remove the temporary files generated during the compilation process
os.system("rm {}".format(output_tex_file))
os.system("rm Reports/tempPerf.png")
os.system("rm {}.log".format(output_file))
os.system("rm {}.aux".format(output_file))

print("Report card generated successfully: {}".format(output_file_name+".pdf"))
