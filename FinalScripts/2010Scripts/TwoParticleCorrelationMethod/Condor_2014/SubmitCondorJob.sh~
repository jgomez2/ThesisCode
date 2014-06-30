#!/bin/sh

#########################################################################
#
#  The meaning of the inputs is as follows:
#  ${1} = Run Number Assigned
#
#########################################################################


#echo " submitting: macro " ${1} " into the condor queue executing " submit_cmssw.csh



dir="/home/jgomez2/EventPlane/January2014/2010DataAnalysis/Condor_2014"
ldir="/home/jgomez2/EventPlane/January2014/2010DataAnalysis/Condor_2014"


cat >  JobCondor_${1} << +EOF



universe     = vanilla
Executable   = RunMacro.sh
should_transfer_files = NO
Arguments   = ${1}
Requirements = regexp("R510",machine,"i") == True 
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

