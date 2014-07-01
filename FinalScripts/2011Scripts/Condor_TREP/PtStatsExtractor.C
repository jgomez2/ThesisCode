{

  TFile f("PTStats_TREP.root");
  Plots.cd();
  PtStats.cd();

  ofstream myout;
  myout.open("PtStats.txt"); 

      //Whole Tracker  
      myout<<"//Whole Tracker"<<endl;
      myout<<"ptavwhole[0]="<<PtStatsWhole_0to10->GetBinContent(1)<<";"<<endl;
      myout<<"ptavwhole[1]="<<PtStatsWhole_10to20->GetBinContent(1)<<";"<<endl;
      myout<<"ptavwhole[2]="<<PtStatsWhole_20to30->GetBinContent(1)<<";"<<endl;
      myout<<"ptavwhole[3]="<<PtStatsWhole_30to40->GetBinContent(1)<<";"<<endl;
      myout<<"ptavwhole[4]="<<PtStatsWhole_40to50->GetBinContent(1)<<";"<<endl;
      myout<<" "<<endl;
      
      myout<<"pt2avwhole[0]="<<PtStatsWhole_0to10->GetBinContent(2)<<";"<<endl;
      myout<<"pt2avwhole[1]="<<PtStatsWhole_10to20->GetBinContent(2)<<";"<<endl;
      myout<<"pt2avwhole[2]="<<PtStatsWhole_20to30->GetBinContent(2)<<";"<<endl;
      myout<<"pt2avwhole[3]="<<PtStatsWhole_30to40->GetBinContent(2)<<";"<<endl;
      myout<<"pt2avwhole[4]="<<PtStatsWhole_40to50->GetBinContent(2)<<";"<<endl;
      myout<<" "<<endl;

      //Positive Tracker
      myout<<"//Positive Tracker"<<endl;
      myout<<"ptavpos[0]="<<PtStatsPos_0to10->GetBinContent(1)<<";"<<endl;
      myout<<"ptavpos[1]="<<PtStatsPos_10to20->GetBinContent(1)<<";"<<endl;
      myout<<"ptavpos[2]="<<PtStatsPos_20to30->GetBinContent(1)<<";"<<endl;
      myout<<"ptavpos[3]="<<PtStatsPos_30to40->GetBinContent(1)<<";"<<endl;
      myout<<"ptavpos[4]="<<PtStatsPos_40to50->GetBinContent(1)<<";"<<endl;
      myout<<" "<<endl;

      myout<<"pt2avpos[0]="<<PtStatsPos_0to10->GetBinContent(2)<<";"<<endl;
      myout<<"pt2avpos[1]="<<PtStatsPos_10to20->GetBinContent(2)<<";"<<endl;
      myout<<"pt2avpos[2]="<<PtStatsPos_20to30->GetBinContent(2)<<";"<<endl;
      myout<<"pt2avpos[3]="<<PtStatsPos_30to40->GetBinContent(2)<<";"<<endl;
      myout<<"pt2avpos[4]="<<PtStatsPos_40to50->GetBinContent(2)<<";"<<endl;
      myout<<" "<<endl;

      //Negative Tracker
      myout<<"//Negative Tracker"<<endl;
      myout<<"ptavneg[0]="<<PtStatsNeg_0to10->GetBinContent(1)<<";"<<endl;
      myout<<"ptavneg[1]="<<PtStatsNeg_10to20->GetBinContent(1)<<";"<<endl;
      myout<<"ptavneg[2]="<<PtStatsNeg_20to30->GetBinContent(1)<<";"<<endl;
      myout<<"ptavneg[3]="<<PtStatsNeg_30to40->GetBinContent(1)<<";"<<endl;
      myout<<"ptavneg[4]="<<PtStatsNeg_40to50->GetBinContent(1)<<";"<<endl;
      myout<<" "<<endl;

      myout<<"pt2avneg[0]="<<PtStatsNeg_0to10->GetBinContent(2)<<";"<<endl;
      myout<<"pt2avneg[1]="<<PtStatsNeg_10to20->GetBinContent(2)<<";"<<endl;
      myout<<"pt2avneg[2]="<<PtStatsNeg_20to30->GetBinContent(2)<<";"<<endl;
      myout<<"pt2avneg[3]="<<PtStatsNeg_30to40->GetBinContent(2)<<";"<<endl;
      myout<<"pt2avneg[4]="<<PtStatsNeg_40to50->GetBinContent(2)<<";"<<endl;
      myout<<" "<<endl;

      //Mid Tracker
      myout<<"//Mid Tracker"<<endl;
      myout<<"ptavmid[0]="<<PtStatsMid_0to10->GetBinContent(1)<<";"<<endl;
      myout<<"ptavmid[1]="<<PtStatsMid_10to20->GetBinContent(1)<<";"<<endl;
      myout<<"ptavmid[2]="<<PtStatsMid_20to30->GetBinContent(1)<<";"<<endl;
      myout<<"ptavmid[3]="<<PtStatsMid_30to40->GetBinContent(1)<<";"<<endl;
      myout<<"ptavmid[4]="<<PtStatsMid_40to50->GetBinContent(1)<<";"<<endl;
      myout<<" "<<endl;

      myout<<"pt2avmid[0]="<<PtStatsMid_0to10->GetBinContent(2)<<";"<<endl;
      myout<<"pt2avmid[1]="<<PtStatsMid_10to20->GetBinContent(2)<<";"<<endl;
      myout<<"pt2avmid[2]="<<PtStatsMid_20to30->GetBinContent(2)<<";"<<endl;
      myout<<"pt2avmid[3]="<<PtStatsMid_30to40->GetBinContent(2)<<";"<<endl;
      myout<<"pt2avmid[4]="<<PtStatsMid_40to50->GetBinContent(2)<<";"<<endl;
      myout<<" "<<endl;


  myout.close();
}
