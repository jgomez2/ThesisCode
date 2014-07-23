#!/usr/bin/env python

##############################################
# Usage:                                     #
#                                            #
#  python -r jeffHADD.py                     #
##############################################

import os,sys,string

# Set your base directory, containing all root files to be hadd'ed
#basedir="/data/users/jgomez2/TwoParticleCorrelationFiles/"
basedir ="/data/users/jgomez2/V1EPFiles/Recenter/AngularCorrections/"
# Set up start of hadd command, along with output file name
#hadd="hadd TwoParticleCorrelation_1to100_corrected.root "
hadd="hadd AngularCorrections_TREP.root "

# Loop through all files in base directory
for f in os.listdir(basedir):
    # If listed object doesn't end in .root, skip it
    if not f.endswith(".root"):
        continue
    # Combine base dir + f to get full file name
    temp=os.path.join(basedir,f)
    # If full name isn't a file (it could be a directory, for instance), skip it
    if not os.path.isfile(temp):
        continue
    # Add file to hadd command
    hadd=hadd+"%s "%temp
    #break

# Print command
print hadd
# execute command
os.system(hadd)
