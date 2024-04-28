import sys
import os
arguments = sys.argv[1:]

# checking of flags and arguments
if "--baskets" in arguments:
    baskets = list(arguments[arguments.index("--baskets") + 1].split(","))
    del arguments[arguments.index("--baskets") + 1]
    del arguments[arguments.index("--baskets")]
else:
    baskets=['AA', 'AB', 'BB', 'BC', 'CC', 'CD', 'DD', 'FF']

if "--clustering" in arguments:
    type_grading="clustering"
    del arguments[arguments.index("--clustering")]

if "--relative" in arguments:
    type_grading="relative"
    del arguments[arguments.index("--relative")]
    
if "--absolute" in arguments:
    type_grading="absolute"
    del arguments[arguments.index("--absolute")]
    
    if "--boundaries" in arguments:
        boundaries = list(arguments[arguments.index("--boundaries") + 1].split(","))
        boundaries = [float(boundary) for boundary in boundaries]
        if len(boundaries) != len(baskets) - 1:
            print("The number of boundaries should be one less than the number of baskets.")
            sys.exit(1)
        del arguments[arguments.index("--boundaries") + 1]
        del arguments[arguments.index("--boundaries")]
    else:
        boundaries = None

if "--criteria" in arguments:
    criteria = arguments[arguments.index("--criteria") + 1]
    del arguments[arguments.index("--criteria") + 1]
    del arguments[arguments.index("--criteria")]

import numpy as np
from scipy.stats import norm
from sklearn.cluster import KMeans

directory = os.getcwd()

# if criteria flag is present, it is used as the marks for assigning grades
# else, total is used, and if total is not present, the script exits
if locals().get("criteria"):
    filename = os.path.join(directory, criteria + ".csv")
    if not os.path.isfile(filename):
        print("The file " + arguments[0] + ".csv does not exist.")
        sys.exit(1)
    data = np.genfromtxt(filename, delimiter=",", dtype=str)[1:,:]
    marks= np.array([0 if entry == 'a' else float(entry) for entry in data[:, 2]])
    
else:
    filename = os.path.join(directory, "main.csv")
    if not os.path.isfile(filename):
        print("main.csv does not exist.")
        print("Run the command 'bash submission.sh combine' first")
        sys.exit(1)
    data = np.genfromtxt(filename, delimiter=",", dtype=str)[1:,:]
    header = np.genfromtxt(filename, delimiter=",", dtype=str)[0]
    
    if header[-1]!="total":
        print("Use the flag '--criteria' or run the command 'bash submission.sh total' first")
        exit(1)
    marks= np.array([0 if entry == 'a' else float(entry) for entry in data[:, -1]])

if len(arguments) != 1:
    print("Specify the output file name")
    sys.exit(1)
else:
    output_file = os.path.join(directory, arguments[0])

def grade_absolute(scores, baskets, boundaries):
    # for absolute grading, the grades are assigned by dividing marks range between max and min scores into appropriate number of baskets
    
    if not boundaries:
        score_min=scores.min()
        score_max=scores.max()
        boundaries = np.linspace(score_max, score_min, len(baskets)+1)
    
    grades = []
    for score in scores:
        for i, boundary in enumerate(boundaries[:]):
            if score > boundary:
                grades.append(baskets[i-1])
                break
        else:
            grades.append(baskets[-1])
    return grades
    
def grade_relative(scores, baskets):
    # for relative grading, the grades are assigned based on the percentile of the score in the list of scores 
    
    mean_score = np.mean(scores)
    std_dev = np.std(scores)
    
    z_scores = (scores - mean_score) / std_dev
    percentiles = norm.cdf(z_scores) * 100
    
    grade_boundaries = np.linspace(100, 0, len(baskets)+1)
    
    grades = []
    for percentile in percentiles:
        for i, boundary in enumerate(grade_boundaries[:]):
            if percentile > boundary:
                grades.append(baskets[i-1])
                break
        else:
            grades.append(baskets[-1])
    return grades

def grade_clustering(marks, baskets):
    # for clustering based grading, the marks are clustered into number of baskets and the clusters are assigned the grades

    kmeans = KMeans(n_clusters=len(baskets))
    kmeans.fit(np.array(marks).reshape(-1, 1))

    cluster_centers = kmeans.cluster_centers_.flatten()
    sorted_centers_indices = np.argsort(cluster_centers)[::-1]
    
    sorted_grades = np.empty_like(baskets)
    for i, index in enumerate(sorted_centers_indices):
        sorted_grades[index] = baskets[i]

    cluster_grade_mapping = {cluster_label: grade for cluster_label, grade in zip(range(len(baskets)), sorted_grades)}
    sorted_grades_assigned = [cluster_grade_mapping[label] for label in kmeans.labels_]
    
    return sorted_grades_assigned

if locals().get("type_grading"):
    if type_grading=="clustering":
        grades = grade_clustering(marks, baskets)
    elif type_grading=="relative":
        grades = grade_relative(marks, baskets)
    elif type_grading=="absolute":
        grades = grade_absolute(marks, baskets, boundaries)

else:
    print("No type was specified, so the default type of grading, i.e. clustering based grading will be used.")
    grades=grade_clustering(marks, baskets)

# the grades are written to the output file in format Roll No., Name, Marks, Grade
with open(output_file, "w") as f:
    f.write("Roll No.,Name,Marks,Grade\n")
    for i, marks in enumerate(marks):
        f.write(data[i][0]+","+data[i][1]+","+str(marks)+","+ grades[i]+"\n")