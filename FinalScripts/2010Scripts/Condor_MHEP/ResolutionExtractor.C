{
  
  Float_t Res2HFM[5],Res2HFP[5];

  TFile f("Resolutions_MHEP.root");
  //  Plots.cd();
  //Resolutions.cd();
  //SecondOrderResolutionCorrections.cd();
  


  ofstream myout;
  myout.open("Resolutions.txt"); 


   //First Order Whole HF first
  myout<<"////FinalResPos is the resolution which will be used for particles that are in negative psuedorapidity"<<endl;
  myout<<"////FinalResNeg is the resolution which will be used for particles that are in positive pseudorapidity"<<endl;




  f.cd();
  Plots.cd();
  Resolutions.cd();

  for (Int_t c=0;c<5;c++)
    {
      //The same +/- convention used here
      myout<<"FinalResPos["<<c<<"]="<<NegativeEtaRFactor->GetBinContent(c+1)<<";"<<endl;
      myout<<"FinalResNeg["<<c<<"]="<<PositiveEtaRFactor->GetBinContent(c+1)<<";"<<endl; 
        
    }//end of loop over centralities



  myout.close();
}
