#!/bin/tcsh


###################################################################
#          USEMENT                                                # 
#                                                                 #
#   ./SubmitLotsOfJobs.sh $1                                      #
#                                                                 #
#   submits $1 jobs each running 1000 events                      #
#   example: ./SubmitLotsOfJobs.sh 100                            #
#            submits job numbers 0 through 99                     #
###################################################################

set numjobs = $1
@ newnum = 120 + $1
#echo "numjobs is $numjobs (outside of loop)"
@ x = 1
while($x <= $numjobs)

#echo $x   
#@ x += 1
#@ numjobs = $numjobs - 1
./SubmitCondorJob.sh $x
@ x += 1
end 
   

   
