#!/bin/tcsh


@ number=1
#echo "$number"
@ num=`expr {$number} "-" 1`
#echo "$num"
while ($number<101)
    if ( "$number" == "1" ) then 
	cd /data/users/jgomez2/ZDCscratchstorage/PG_N_run_{$num}
        mv -v N_1380GeV_fullphi_ZDC_1.root /data/users/jgomez2/ZDCdataholder/      #moves run 0#
else
    cd /data/users/jgomez2/ZDCscratchstorage/PG_JPsi_run_{$num}
    mv -v N_1380GeV_fullphi_ZDC_{$num}001.root /data/users/jgomez2/ZDCdataholder #moves the rest of the files#
 endif    
   
   @ number++
   @ num++
end 

    cd ~jgomez2/Summer2012_ZDCSimulation/Condor_2012
