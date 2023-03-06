## Simon Task (PYTHON):  Code module for TTest across multiple participants
import os, glob
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from statistics import mean
from scipy.stats import ttest_rel

logdir = "/home/kw/Documents/MATLAB/Simon_Task/Datafiles"      # Declare the working directory where we will store data
os.chdir(logdir)                            # change to the working directory, necessary so that data extraction below works without using dir name every time.
logfiles = glob.glob(logdir + "/*.txt")     # assign list of txt files in CURRENT folder to var logfiles NOT IN ORDER.
num_files = len(logfiles)                   # holds number of datafiles, for use in FOR loop below

# Initialise two empty lists, the first for average response times (congruent) and the second for average response times (incongruent) for all participants.
# These lists are later converted to numpy arrays before being used to calculate Simon Effect, and ttest of significance.
group_congruents = []
group_incongruents = []

# Loop through the datafiles in working folder, extract data, calculate avg response times for congruent and incongruent, and store the data in the two vectors initialised above,
for i in range(num_files):
    data = pd.read_csv(logfiles[i],sep="\s+", header=None)     # Extract the data from a datafile into a dataframe.  "\s+" means data is separated by any number of spaces
    # create three boolean vectors for: correct,congruent,incongruent trials.  These will be used for filtering array rows for analysis.
    correct = data[1] == 1
    congruent  = data[2] == "congruent"                         # create boolean vector of congruent trials (used for filtering array rows for analysis)
    incongruent = data[2] == "incongruent"
    # Calculage avg response times for Congruent/Incongruent trials
    mean_congruent = mean(data[0][congruent & correct])         # data[0] column contains Response Times from first column of datafiles.
    mean_incongruent = mean(data[0][incongruent & correct])
    # add current participant response times to group vectors
    group_congruents.append(mean_congruent)
    group_incongruents.append(mean_incongruent)

# Convert lists to numpy arrays in order to use mean command from statistics module.
group_congruents = np.asarray(group_congruents)
group_incongruents = np.asarray(group_incongruents)

# Calculate average Simon Effect across participants in time, and by percent change.
avg_simon = mean(group_incongruents - group_congruents)
avg_simon_percent = avg_simon/mean(group_congruents)*100

# Run paired ttest on the 2 vectors.  Using PAIRED ttest because for each row the congruent and incongruent values come from same participant.
#  Would be ttest_ind() for independent ttest
result = ttest_rel(group_incongruents, group_congruents)                    # returns t statistic and pval for ttest

# Plotting
#Plot all response times on single plot, blue for congruent, red for incongruent, plot means, and plot line between representing simon effect.
# plot e.g. mean accuracy, mean reaction times, simple comparison e.g. t-test or correlation)
fig, ax = plt.subplots()
#fig.tight_layout()
ax.plot(np.ones(len(group_congruents)),group_congruents, 'bo')              # plot the congruent average reaction times
ax.plot(np.ones(len(group_incongruents))*2, group_incongruents,'ro')        # plot the incongruent average reaction times
ax.plot([1,2],[mean(group_congruents),mean(group_incongruents)],'k-o')       # plot difference of means line
ax.set_title("Simon Task Results")
ax.set(xlim=(0, 4))
ax.set_xticks([1,2], labels=["Congruent","Incongruent"])
ax.set_ylabel("Average Reaction Times")
# Print the Simon Effect and tStatistic as text directly on the plot, draw a box around text.
ax.text(2.5,0.5,"Simon Effect: " + str(round(avg_simon,2)) + f" ({round(avg_simon_percent)}%)" + "\nt-Stat: " + str(round(result[0],2)) +
        "\nP-value: " + str(round(result[1],2)) + "\nDF: " + str(round(result.df,2)), color='white',bbox=dict(facecolor='grey')) 
plt.show()
