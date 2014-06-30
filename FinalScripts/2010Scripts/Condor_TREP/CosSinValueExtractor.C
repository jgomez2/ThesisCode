{

  TFile f("AngularCorrections_TREP.root");
  Plots.cd();
  AngularCorrectionPlots.cd();
  FirstOrderEPEvenCorrs.cd();
  WholeTracker.cd();

  ofstream myout;
  myout.open("CosAndSinValues.txt"); 


  //grab the outer tracker EP stuff
  myout<<"//V1 Even"<<endl;
  myout<<"//Whole Tracker"<<endl;
  //myout<< "Float_t CosineWholeTracker[5][10];"<<endl;
  //myout<< "Float_t SineWholeTracker[5][10];"<<endl;
  
  for (Int_t k=1;k<=10;k++)
    {
      myout<<"CosineWholeTracker[0]["<<k-1<<"]="<<CosValues_WholeTracker_0to10->GetBinContent(k)<<";"<<endl;
      myout<<"CosineWholeTracker[1]["<<k-1<<"]="<<CosValues_WholeTracker_10to20->GetBinContent(k)<<";"<<endl;
      myout<<"CosineWholeTracker[2]["<<k-1<<"]="<<CosValues_WholeTracker_20to30->GetBinContent(k)<<";"<<endl;
      myout<<"CosineWholeTracker[3]["<<k-1<<"]="<<CosValues_WholeTracker_30to40->GetBinContent(k)<<";"<<endl;
      myout<<"CosineWholeTracker[4]["<<k-1<<"]="<<CosValues_WholeTracker_40to50->GetBinContent(k)<<";"<<endl;
      myout<<" "<<endl;
      myout<<"SineWholeTracker[0]["<<k-1<<"]="<<SinValues_WholeTracker_0to10->GetBinContent(k)<<";"<<endl;
      myout<<"SineWholeTracker[1]["<<k-1<<"]="<<SinValues_WholeTracker_10to20->GetBinContent(k)<<";"<<endl;
      myout<<"SineWholeTracker[2]["<<k-1<<"]="<<SinValues_WholeTracker_20to30->GetBinContent(k)<<";"<<endl;
      myout<<"SineWholeTracker[3]["<<k-1<<"]="<<SinValues_WholeTracker_30to40->GetBinContent(k)<<";"<<endl;
      myout<<"SineWholeTracker[4]["<<k-1<<"]="<<SinValues_WholeTracker_40to50->GetBinContent(k)<<";"<<endl;
      myout<<" "<<endl;      
    }//end of loop over k


  //now grab the pos tracker
  f.cd();
  Plots.cd();
  AngularCorrectionPlots.cd();
  FirstOrderEPEvenCorrs.cd();
  PosTracker.cd();
  
  myout<<" "<<endl;
  myout<<"//Pos Tracker"<<endl;
  //myout<< "Float_t CosinePosTracker[5][10];"<<endl;
  //myout<< "Float_t SinePosTracker[5][10];"<<endl;

  for (Int_t k=1;k<=10;k++)
    {
      myout<<"CosinePosTracker[0]["<<k-1<<"]="<<CosValues_PosTracker_0to10->GetBinContent(k)<<";"<<endl;
      myout<<"CosinePosTracker[1]["<<k-1<<"]="<<CosValues_PosTracker_10to20->GetBinContent(k)<<";"<<endl;
      myout<<"CosinePosTracker[2]["<<k-1<<"]="<<CosValues_PosTracker_20to30->GetBinContent(k)<<";"<<endl;
      myout<<"CosinePosTracker[3]["<<k-1<<"]="<<CosValues_PosTracker_30to40->GetBinContent(k)<<";"<<endl;
      myout<<"CosinePosTracker[4]["<<k-1<<"]="<<CosValues_PosTracker_40to50->GetBinContent(k)<<";"<<endl;
      myout<<" "<<endl;
      myout<<"SinePosTracker[0]["<<k-1<<"]="<<SinValues_PosTracker_0to10->GetBinContent(k)<<";"<<endl;
      myout<<"SinePosTracker[1]["<<k-1<<"]="<<SinValues_PosTracker_10to20->GetBinContent(k)<<";"<<endl;
      myout<<"SinePosTracker[2]["<<k-1<<"]="<<SinValues_PosTracker_20to30->GetBinContent(k)<<";"<<endl;
      myout<<"SinePosTracker[3]["<<k-1<<"]="<<SinValues_PosTracker_30to40->GetBinContent(k)<<";"<<endl;
      myout<<"SinePosTracker[4]["<<k-1<<"]="<<SinValues_PosTracker_40to50->GetBinContent(k)<<";"<<endl;
      myout<<" "<<endl;
    }//end of loop over k  


  //Now grab the neg tracker
  f.cd();
  Plots.cd();
  AngularCorrectionPlots.cd();
  FirstOrderEPEvenCorrs.cd();
  NegTracker.cd();

  myout<<" "<<endl;
  myout<<"//Neg Tracker"<<endl;
  //myout<< "Float_t CosineNegTracker[5][10];"<<endl;
  //myout<< "Float_t SineNegTracker[5][10];"<<endl;

  for (Int_t k=1;k<=10;k++)
    {
      myout<<"CosineNegTracker[0]["<<k-1<<"]="<<CosValues_NegTracker_0to10->GetBinContent(k)<<";"<<endl;
      myout<<"CosineNegTracker[1]["<<k-1<<"]="<<CosValues_NegTracker_10to20->GetBinContent(k)<<";"<<endl;
      myout<<"CosineNegTracker[2]["<<k-1<<"]="<<CosValues_NegTracker_20to30->GetBinContent(k)<<";"<<endl;
      myout<<"CosineNegTracker[3]["<<k-1<<"]="<<CosValues_NegTracker_30to40->GetBinContent(k)<<";"<<endl;
      myout<<"CosineNegTracker[4]["<<k-1<<"]="<<CosValues_NegTracker_40to50->GetBinContent(k)<<";"<<endl;
      myout<<" "<<endl;
      myout<<"SineNegTracker[0]["<<k-1<<"]="<<SinValues_NegTracker_0to10->GetBinContent(k)<<";"<<endl;
      myout<<"SineNegTracker[1]["<<k-1<<"]="<<SinValues_NegTracker_10to20->GetBinContent(k)<<";"<<endl;
      myout<<"SineNegTracker[2]["<<k-1<<"]="<<SinValues_NegTracker_20to30->GetBinContent(k)<<";"<<endl;
      myout<<"SineNegTracker[3]["<<k-1<<"]="<<SinValues_NegTracker_30to40->GetBinContent(k)<<";"<<endl;
      myout<<"SineNegTracker[4]["<<k-1<<"]="<<SinValues_NegTracker_40to50->GetBinContent(k)<<";"<<endl;
      myout<<" "<<endl;
    }//end of loop over k     
  


  //Now grab the mid tracker
  f.cd();
  Plots.cd();
  AngularCorrectionPlots.cd();
  FirstOrderEPEvenCorrs.cd();
  MidTracker.cd();

  myout<<" "<<endl;
  myout<<"//Mid Tracker"<<endl;
 // myout<< "Float_t CosineMidTracker[5][10];"<<endl;
 // myout<< "Float_t SineMidTracker[5][10];"<<endl;

  for (Int_t k=1;k<=10;k++)
    {
      myout<<"CosineMidTracker[0]["<<k-1<<"]="<<CosValues_MidTracker_0to10->GetBinContent(k)<<";"<<endl;
      myout<<"CosineMidTracker[1]["<<k-1<<"]="<<CosValues_MidTracker_10to20->GetBinContent(k)<<";"<<endl;
      myout<<"CosineMidTracker[2]["<<k-1<<"]="<<CosValues_MidTracker_20to30->GetBinContent(k)<<";"<<endl;
      myout<<"CosineMidTracker[3]["<<k-1<<"]="<<CosValues_MidTracker_30to40->GetBinContent(k)<<";"<<endl;
      myout<<"CosineMidTracker[4]["<<k-1<<"]="<<CosValues_MidTracker_40to50->GetBinContent(k)<<";"<<endl;
      myout<<" "<<endl;
      myout<<"SineMidTracker[0]["<<k-1<<"]="<<SinValues_MidTracker_0to10->GetBinContent(k)<<";"<<endl;
      myout<<"SineMidTracker[1]["<<k-1<<"]="<<SinValues_MidTracker_10to20->GetBinContent(k)<<";"<<endl;
      myout<<"SineMidTracker[2]["<<k-1<<"]="<<SinValues_MidTracker_20to30->GetBinContent(k)<<";"<<endl;
      myout<<"SineMidTracker[3]["<<k-1<<"]="<<SinValues_MidTracker_30to40->GetBinContent(k)<<";"<<endl;
      myout<<"SineMidTracker[4]["<<k-1<<"]="<<SinValues_MidTracker_40to50->GetBinContent(k)<<";"<<endl;
      myout<<" "<<endl;
    }//end of loop over k  



///NOW DO THE SAME FOR V1ODD
  f.cd();
  Plots.cd();
  AngularCorrectionPlots.cd();
  FirstOrderEPOddCorrs.cd();
  WholeOddTracker.cd();
  //grab the outer tracker EP stuff
  myout<<"//V1 Odd"<<endl;
  myout<<"//Whole Tracker"<<endl;
  //myout<< "Float_t CosineWholeOddTracker[5][10];"<<endl;
  //myout<< "Float_t SineWholeOddTracker[5][10];"<<endl;
  
  for (Int_t k=1;k<=10;k++)
    {
      myout<<"CosineWholeOddTracker[0]["<<k-1<<"]="<<CosValues_WholeOddTracker_0to10->GetBinContent(k)<<";"<<endl;
      myout<<"CosineWholeOddTracker[1]["<<k-1<<"]="<<CosValues_WholeOddTracker_10to20->GetBinContent(k)<<";"<<endl;
      myout<<"CosineWholeOddTracker[2]["<<k-1<<"]="<<CosValues_WholeOddTracker_20to30->GetBinContent(k)<<";"<<endl;
      myout<<"CosineWholeOddTracker[3]["<<k-1<<"]="<<CosValues_WholeOddTracker_30to40->GetBinContent(k)<<";"<<endl;
      myout<<"CosineWholeOddTracker[4]["<<k-1<<"]="<<CosValues_WholeOddTracker_40to50->GetBinContent(k)<<";"<<endl;
      myout<<" "<<endl;
      myout<<"SineWholeOddTracker[0]["<<k-1<<"]="<<SinValues_WholeOddTracker_0to10->GetBinContent(k)<<";"<<endl;
      myout<<"SineWholeOddTracker[1]["<<k-1<<"]="<<SinValues_WholeOddTracker_10to20->GetBinContent(k)<<";"<<endl;
      myout<<"SineWholeOddTracker[2]["<<k-1<<"]="<<SinValues_WholeOddTracker_20to30->GetBinContent(k)<<";"<<endl;
      myout<<"SineWholeOddTracker[3]["<<k-1<<"]="<<SinValues_WholeOddTracker_30to40->GetBinContent(k)<<";"<<endl;
      myout<<"SineWholeOddTracker[4]["<<k-1<<"]="<<SinValues_WholeOddTracker_40to50->GetBinContent(k)<<";"<<endl;
      myout<<" "<<endl;      
    }//end of loop over k


  //now grab the pos tracker
  f.cd();
  Plots.cd();
  AngularCorrectionPlots.cd();
  FirstOrderEPOddCorrs.cd();
  PosOddTracker.cd();
  
  myout<<" "<<endl;
  myout<<"//Pos Tracker"<<endl;
 // myout<< "Float_t CosinePosOddTracker[5][10];"<<endl;
 // myout<< "Float_t SinePosOddTracker[5][10];"<<endl;

  for (Int_t k=1;k<=10;k++)
    {
      myout<<"CosinePosOddTracker[0]["<<k-1<<"]="<<CosValues_PosOddTracker_0to10->GetBinContent(k)<<";"<<endl;
      myout<<"CosinePosOddTracker[1]["<<k-1<<"]="<<CosValues_PosOddTracker_10to20->GetBinContent(k)<<";"<<endl;
      myout<<"CosinePosOddTracker[2]["<<k-1<<"]="<<CosValues_PosOddTracker_20to30->GetBinContent(k)<<";"<<endl;
      myout<<"CosinePosOddTracker[3]["<<k-1<<"]="<<CosValues_PosOddTracker_30to40->GetBinContent(k)<<";"<<endl;
      myout<<"CosinePosOddTracker[4]["<<k-1<<"]="<<CosValues_PosOddTracker_40to50->GetBinContent(k)<<";"<<endl;
      myout<<" "<<endl;
      myout<<"SinePosOddTracker[0]["<<k-1<<"]="<<SinValues_PosOddTracker_0to10->GetBinContent(k)<<";"<<endl;
      myout<<"SinePosOddTracker[1]["<<k-1<<"]="<<SinValues_PosOddTracker_10to20->GetBinContent(k)<<";"<<endl;
      myout<<"SinePosOddTracker[2]["<<k-1<<"]="<<SinValues_PosOddTracker_20to30->GetBinContent(k)<<";"<<endl;
      myout<<"SinePosOddTracker[3]["<<k-1<<"]="<<SinValues_PosOddTracker_30to40->GetBinContent(k)<<";"<<endl;
      myout<<"SinePosOddTracker[4]["<<k-1<<"]="<<SinValues_PosOddTracker_40to50->GetBinContent(k)<<";"<<endl;
      myout<<" "<<endl;
    }//end of loop over k  


  //Now grab the neg tracker
  f.cd();
  Plots.cd();
  AngularCorrectionPlots.cd();
  FirstOrderEPOddCorrs.cd();
  NegOddTracker.cd();

  myout<<" "<<endl;
  myout<<"//Neg Tracker"<<endl;
  //myout<< "Float_t CosineNegOddTracker[5][10];"<<endl;
  //myout<< "Float_t SineNegOddTracker[5][10];"<<endl;

  for (Int_t k=1;k<=10;k++)
    {
      myout<<"CosineNegOddTracker[0]["<<k-1<<"]="<<CosValues_NegOddTracker_0to10->GetBinContent(k)<<";"<<endl;
      myout<<"CosineNegOddTracker[1]["<<k-1<<"]="<<CosValues_NegOddTracker_10to20->GetBinContent(k)<<";"<<endl;
      myout<<"CosineNegOddTracker[2]["<<k-1<<"]="<<CosValues_NegOddTracker_20to30->GetBinContent(k)<<";"<<endl;
      myout<<"CosineNegOddTracker[3]["<<k-1<<"]="<<CosValues_NegOddTracker_30to40->GetBinContent(k)<<";"<<endl;
      myout<<"CosineNegOddTracker[4]["<<k-1<<"]="<<CosValues_NegOddTracker_40to50->GetBinContent(k)<<";"<<endl;
      myout<<" "<<endl;
      myout<<"SineNegOddTracker[0]["<<k-1<<"]="<<SinValues_NegOddTracker_0to10->GetBinContent(k)<<";"<<endl;
      myout<<"SineNegOddTracker[1]["<<k-1<<"]="<<SinValues_NegOddTracker_10to20->GetBinContent(k)<<";"<<endl;
      myout<<"SineNegOddTracker[2]["<<k-1<<"]="<<SinValues_NegOddTracker_20to30->GetBinContent(k)<<";"<<endl;
      myout<<"SineNegOddTracker[3]["<<k-1<<"]="<<SinValues_NegOddTracker_30to40->GetBinContent(k)<<";"<<endl;
      myout<<"SineNegOddTracker[4]["<<k-1<<"]="<<SinValues_NegOddTracker_40to50->GetBinContent(k)<<";"<<endl;
      myout<<" "<<endl;
    }//end of loop over k     
  


  //Now grab the mid tracker
  f.cd();
  Plots.cd();
  AngularCorrectionPlots.cd();
  FirstOrderEPOddCorrs.cd();
  MidOddTracker.cd();

  myout<<" "<<endl;
  myout<<"//Mid Tracker"<<endl;
 // myout<< "Float_t CosineMidOddTracker[5][10];"<<endl;
  //myout<< "Float_t SineMidOddTracker[5][10];"<<endl;

  for (Int_t k=1;k<=10;k++)
    {
      myout<<"CosineMidOddTracker[0]["<<k-1<<"]="<<CosValues_MidOddTracker_0to10->GetBinContent(k)<<";"<<endl;
      myout<<"CosineMidOddTracker[1]["<<k-1<<"]="<<CosValues_MidOddTracker_10to20->GetBinContent(k)<<";"<<endl;
      myout<<"CosineMidOddTracker[2]["<<k-1<<"]="<<CosValues_MidOddTracker_20to30->GetBinContent(k)<<";"<<endl;
      myout<<"CosineMidOddTracker[3]["<<k-1<<"]="<<CosValues_MidOddTracker_30to40->GetBinContent(k)<<";"<<endl;
      myout<<"CosineMidOddTracker[4]["<<k-1<<"]="<<CosValues_MidOddTracker_40to50->GetBinContent(k)<<";"<<endl;
      myout<<" "<<endl;
      myout<<"SineMidOddTracker[0]["<<k-1<<"]="<<SinValues_MidOddTracker_0to10->GetBinContent(k)<<";"<<endl;
      myout<<"SineMidOddTracker[1]["<<k-1<<"]="<<SinValues_MidOddTracker_10to20->GetBinContent(k)<<";"<<endl;
      myout<<"SineMidOddTracker[2]["<<k-1<<"]="<<SinValues_MidOddTracker_20to30->GetBinContent(k)<<";"<<endl;
      myout<<"SineMidOddTracker[3]["<<k-1<<"]="<<SinValues_MidOddTracker_30to40->GetBinContent(k)<<";"<<endl;
      myout<<"SineMidOddTracker[4]["<<k-1<<"]="<<SinValues_MidOddTracker_40to50->GetBinContent(k)<<";"<<endl;
      myout<<" "<<endl;
    }//end of loop over k  



  myout.close();
}
