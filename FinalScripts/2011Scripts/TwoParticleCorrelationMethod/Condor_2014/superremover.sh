#!/bin/tcsh

#Get Rid of old Logs
cd /home/jgomez2/Summer2012_ZDCSimulation/Condor_2012 

@ number=1
@ num=`expr {$number} "-" 1` #have to do this because if number was zero the while loop would fail.
while ($number<101) #gets rid of files enumerated 0-99#
    rm -v Job{$num}.log
    rm -v Job{$num}.stderr
    rm -v Job{$num}.stdout

     @ number++
     @ num++
end


#Get Rid of old Runs
cd /data/users/jgomez2/ZDCscratchstorage/

@ digit=1 
@ digital=`expr {$digit} "-" 1`
while ($digit<101)
    rm -vrf PG_N_run_{$digital}

    @ digit++
    @ digital++

end

cd ~jgomez2/Summer2012_ZDCSimulation/Condor_2012
