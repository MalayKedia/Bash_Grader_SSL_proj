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

if "-o" in arguments:
    output_file = os.path.join(output_dir, arguments[arguments.index("-o") + 1])
    del arguments[arguments.index("-o") + 1]
    del arguments[arguments.index("-o")]

if "--grades_file" in arguments:
    grades_file = os.path.join(directory, arguments[arguments.index("--grades_file") + 1])
    del arguments[arguments.index("--grades_file") + 1]
    del arguments[arguments.index("--grades_file")]

roll_no=arguments[0]
if not locals().get("output_file"):
    output_file = os.path.join(output_dir, "report_{}.pdf".format(roll_no))        

import numpy as np

dataset = np.genfromtxt(filename, delimiter=',', dtype=str)
name_list = dataset[1:, 1]
roll_list = dataset[1:, 0]
marks_list = dataset[1:, 2:]
marks_header=dataset[0, 2:]

if marks_header[-1] == "total":
    total_marks = marks_list[:, -1]
    marks_header = marks_header[:-1]
    marks_list = np.delete(marks_list, -1, axis=1)

if not roll_no in roll_list:
    print("Roll number not found")
    sys.exit(1)

name=name_list[np.where(roll_list == roll_no)][0]
marks_student=marks_list[np.where(roll_list == roll_no)][0]

grade=None
if locals().get("grades_file"):
    grades_data_all=np.genfromtxt(grades_file, delimiter=',', dtype=str)
    grades_roll=grades_data_all[1:, 0]
    grades_data=grades_data_all[1:, 3]
    grade=grades_data[np.where(grades_roll == roll_no)][0]

latex_content = r"""
\documentclass{article}
\begin{document}
\title{Report Card}
\author{}
\date{}
\maketitle
\section{Student Details}
\begin{itemize}
\item Roll Number:"""+ roll_no+r"""
\item Name: """+name+r"""
\end{itemize}
\section{Marks}
\begin{tabular}{|c|c|}
\hline
Exam & Marks \\
\hline
"""
for exam, mark in zip(marks_header, marks_student):
    latex_content=latex_content+"{} & {} \\\ \n".format(exam, mark)


latex_content+=r"""
\hline
\end{tabular}
\section{Performance}
\end{document}
"""
print(latex_content) 



# def generate_report_card(roll_no, name, marks_header, marks_student, grade, output_file):    
#     xam, mark in zip(marks_header, marks_student):
#     latex_content=latex_content+"{} & {} \\\ \n".format(exam, mark)


# latex_contmarks_text = ""
# for exam, mark in zip(marks_header, marks_student):
#     marks_text += "\\item {}: {}\n".format(exam, mark)
# # Convert marks to LaTeX format


# # Populate the LaTeX template with data
# latex_content = latex_template.format(
#     roll_no=roll_no,
#     name=name,
#     marks=marks_text,
#     grade=grade
# )

# # Write the LaTeX content to a .tex file
# output_tex_file = "{}.tex".format(output_file)
# with open(output_tex_file, "w") as tex_file:
#     tex_file.write(latex_content)

# # Compile the .tex file to generate the PDF report card
# compile_command = "pdflatex -output-directory=Reports {}".format(output_tex_file)
# os.system(compile_command)

# # Move the generated PDF file to the specified output file path
# generated_pdf_file = "{}.pdf".format(output_file)
# os.rename("Reports/{}.pdf".format(output_tex_file[:-4]), generated_pdf_file)

# print("Report card generated successfully: {}".format(generated_pdf_file))

