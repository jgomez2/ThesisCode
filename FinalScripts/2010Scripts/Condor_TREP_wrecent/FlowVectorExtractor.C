{

  TFile f("FlowVectors_TREP.root");
  //TFile f("TREP_FlowVectors_1.root");
  Plots.cd();
  FlowVectorInformation.cd();
  EvenFlowVectors.cd();

  ofstream myout;
  myout.open("FlowVectors.txt"); 

  //Whole Even Tracker First
  for(Int_t i=1;i<=5;i++)
    {
      myout<<"Xav_wholetracker["<<i-1<<"]="<<FlowVectorsEvenWholeTracker->GetBinContent(i,1)<<";"<<endl;
      myout<<"Xstdev_wholetracker["<<i-1<<"]="<<FlowVectorsEvenWholeTracker->GetBinError(i,1)<<";"<<endl;
      myout<<"Yav_wholetracker["<<i-1<<"]="<<FlowVectorsEvenWholeTracker->GetBinContent(i,2)<<";"<<endl;
      myout<<"Ystdev_wholetracker["<<i-1<<"]="<<FlowVectorsEvenWholeTracker->GetBinError(i,2)<<";"<<endl;
    }//end of first loop over centralities

  myout<<" "<<endl;

  //Pos Tracker
  for(Int_t i=1;i<=5;i++)
    {
      myout<<"Xav_postracker["<<i-1<<"]="<<FlowVectorsEvenPosTracker->GetBinContent(i,1)<<";"<<endl;
      myout<<"Xstdev_postracker["<<i-1<<"]="<<FlowVectorsEvenPosTracker->GetBinError(i,1)<<";"<<endl;
      myout<<"Yav_postracker["<<i-1<<"]="<<FlowVectorsEvenPosTracker->GetBinContent(i,2)<<";"<<endl;
      myout<<"Ystdev_postracker["<<i-1<<"]="<<FlowVectorsEvenPosTracker->GetBinError(i,2)<<";"<<endl;
    }//end of first loop over centralities  

  myout<<" "<<endl;

  //Neg Tracker 
  for(Int_t i=1;i<=5;i++)
    {
      myout<<"Xav_negtracker["<<i-1<<"]="<<FlowVectorsEvenNegTracker->GetBinContent(i,1)<<";"<<endl;
      myout<<"Xstdev_negtracker["<<i-1<<"]="<<FlowVectorsEvenNegTracker->GetBinError(i,1)<<";"<<endl;
      myout<<"Yav_negtracker["<<i-1<<"]="<<FlowVectorsEvenNegTracker->GetBinContent(i,2)<<";"<<endl;
      myout<<"Ystdev_negtracker["<<i-1<<"]="<<FlowVectorsEvenNegTracker->GetBinError(i,2)<<";"<<endl;
    }//end of first loop over centralities

  myout<<" "<<endl;

  //Mid Tracker
  for(Int_t i=1;i<=5;i++)
    {
      myout<<"Xav_midtracker["<<i-1<<"]="<<FlowVectorsEvenMidTracker->GetBinContent(i,1)<<";"<<endl;
      myout<<"Xstdev_midtracker["<<i-1<<"]="<<FlowVectorsEvenMidTracker->GetBinError(i,1)<<";"<<endl;
      myout<<"Yav_midtracker["<<i-1<<"]="<<FlowVectorsEvenMidTracker->GetBinContent(i,2)<<";"<<endl;
      myout<<"Ystdev_midtracker["<<i-1<<"]="<<FlowVectorsEvenMidTracker->GetBinError(i,2)<<";"<<endl;
    }//end of first loop over centralities  

  myout<<" "<<endl;


///////////////NOW FOR THE ODD FLOW VECTORS////////////

  f.cd();
  Plots.cd();
  FlowVectorInformation.cd();
  OddFlowVectors.cd();

  //Whole Odd Tracker 
  for(Int_t i=1;i<=5;i++)
    {
      myout<<"Xav_wholeoddtracker["<<i-1<<"]="<<FlowVectorsWholeOddTracker->GetBinContent(i,1)<<";"<<endl;
      myout<<"Xstdev_wholeoddtracker["<<i-1<<"]="<<FlowVectorsWholeOddTracker->GetBinError(i,1)<<";"<<endl;
      myout<<"Yav_wholeoddtracker["<<i-1<<"]="<<FlowVectorsWholeOddTracker->GetBinContent(i,2)<<";"<<endl;
      myout<<"Ystdev_wholeoddtracker["<<i-1<<"]="<<FlowVectorsWholeOddTracker->GetBinError(i,2)<<";"<<endl;
    }//end of first loop over centralities

  myout<<" "<<endl;

  //Pos OddTracker
  for(Int_t i=1;i<=5;i++)
    {
      myout<<"Xav_posoddtracker["<<i-1<<"]="<<FlowVectorsPosOddTracker->GetBinContent(i,1)<<";"<<endl;
      myout<<"Xstdev_posoddtracker["<<i-1<<"]="<<FlowVectorsPosOddTracker->GetBinError(i,1)<<";"<<endl;
      myout<<"Yav_posoddtracker["<<i-1<<"]="<<FlowVectorsPosOddTracker->GetBinContent(i,2)<<";"<<endl;
      myout<<"Ystdev_posoddtracker["<<i-1<<"]="<<FlowVectorsPosOddTracker->GetBinError(i,2)<<";"<<endl;
    }//end of first loop over centralities  

  myout<<" "<<endl;

  //Neg OddTracker 
  for(Int_t i=1;i<=5;i++)
    {
      myout<<"Xav_negoddtracker["<<i-1<<"]="<<FlowVectorsNegOddTracker->GetBinContent(i,1)<<";"<<endl;
      myout<<"Xstdev_negoddtracker["<<i-1<<"]="<<FlowVectorsNegOddTracker->GetBinError(i,1)<<";"<<endl;
      myout<<"Yav_negoddtracker["<<i-1<<"]="<<FlowVectorsNegOddTracker->GetBinContent(i,2)<<";"<<endl;
      myout<<"Ystdev_negoddtracker["<<i-1<<"]="<<FlowVectorsNegOddTracker->GetBinError(i,2)<<";"<<endl;
    }//end of first loop over centralities

  myout<<" "<<endl;

  //Mid OddTracker
  for(Int_t i=1;i<=5;i++)
    {
      myout<<"Xav_midoddtracker["<<i-1<<"]="<<FlowVectorsMidOddTracker->GetBinContent(i,1)<<";"<<endl;
      myout<<"Xstdev_midoddtracker["<<i-1<<"]="<<FlowVectorsMidOddTracker->GetBinError(i,1)<<";"<<endl;
      myout<<"Yav_midoddtracker["<<i-1<<"]="<<FlowVectorsMidOddTracker->GetBinContent(i,2)<<";"<<endl;
      myout<<"Ystdev_midoddtracker["<<i-1<<"]="<<FlowVectorsMidOddTracker->GetBinError(i,2)<<";"<<endl;
    }//end of first loop over centralities  

  myout<<" "<<endl;

  myout.close();
}
