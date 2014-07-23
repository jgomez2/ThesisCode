#!/bin/sh

#########################################################################
#
#  The meaning of the inputs is as follows:
#  ${1} = Run Number Assigned
#
#########################################################################


echo " submitting: macro " ${1} " into the condor queue executing " submit_cmssw.csh



dir="/home/jgomez2/V1Analysis/2011Analysis/CMSSW_5_3_16/src/2011Scripts/Condor_TREP_wrecent"
ldir="/home/jgomez2/V1Analysis/2011Analysis/CMSSW_5_3_16/src/2011Scripts/Condor_TREP_wrecent"


cat >  JobCondor_${1} << +EOF



universe     = vanilla
Executable   = RunPTStats.sh
#Executable = RunFlowVector.sh
#Executable   = RunAngularCorrections.sh
#Executable = RunEPPlotting.sh
should_transfer_files = NO
Arguments   = ${1}
Requirements = (ARCH=="INTEL" || ARCH=="X86_64")
GetEnv       = True
InitialDir   = $dir
Input        = /dev/null
#Output       = /dev/null
#Error        = /dev/null
#Log          = /dev/null
Output       = $ldir/Job${1}.stdout
Error        = $ldir/Job${1}.stderr
Log          = $ldir/Job${1}.log
notification = never

Queue
+EOF

condor_submit JobCondor_${1} 


rm JobCondor_${1}

