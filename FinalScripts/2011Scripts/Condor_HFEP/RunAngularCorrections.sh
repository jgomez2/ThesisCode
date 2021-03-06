#!/bin/sh

########################################################################
#                                                                      #
#  The meaning of the inputs is as follows:                            #
#  ${1} = Run Number Start                                             #
########################################################################


#Fixing the event indexing 
#firstevent=`expr $1 \\* 1000 + 1` #changes the run number to match the first event of each event#
#echo "$firstevent"
#echo "First event of job "${1}" is $firstevent"

#Make the CFG File
#FIX WORKING DIRECTORY
cd /home/jgomez2/V1Analysis/2011Analysis/CMSSW_5_3_16/src/2011Scripts/Condor_HFEP
./MakeAngularCorrections.sh ${1}

#setup the cmssw environment
export SCRAM_ARCH=slc5_amd64_gcc462
cd /home/jgomez2/V1Analysis/2011Analysis/CMSSW_5_3_16/src/
eval `scramv1 runtime -sh`  #This is actaully what cmsenv is short for


cd /data/users/jgomez2/EPMacroRunningSpace


#make an exectuable directory
/bin/rm -rf condor_run${1}
/bin/mkdir condor_run_${1}
cd condor_run_${1}

#move the run file to the current directory
#/bin/mv /home/jgomez2/Summer2012_ZDCSimulation/Condor_2012/PyConfig_${firstevent}.py .
/bin/mv /home/jgomez2/V1Analysis/2011Analysis/CMSSW_5_3_16/src/2011Scripts/Condor_HFEP/HFV1AngularCorrections_${1}.C .

#execute
#cmsRun PyConfig_${firstevent}.py >& ZDC_PG_N_1380GeV_1000events_${firstevent}.txt   
root -l -b -q HFV1AngularCorrections_${1}.C

#Remove old data files
#/bin/rm -rf /data/users/jgomez2/ZDCscratchstorage/ParticleGun_run_${1}

#Make Directory to store the data
#mkdir /data/users/jgomez2/TwoParticleCorrelationFiles/

#Move the important output files to the new directory
cp HFEP_AngularCorrections_${1}.root /data/users/jgomez2/V1EPFiles/2011/HFEP/AngularCorrections/

#clean up after oneself
cd ..
/bin/rm -rf condor_run_${1}



