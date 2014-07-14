{

  TFile f("AngularCorrections_MHEP.root");
  Plots.cd();
  AngularCorrections.cd();
  FirstOrderCorrections.cd();

  ofstream myout;
  myout.open("CosAndSinValues.txt"); 


   //First Order Whole HF first
  myout<<"//FirstOrder"<<endl;
  myout<<"//Whole HF"<<endl;


  for (Int_t k=1;k<=10;k++)
    {
      myout<<"avcoshf[0]["<<k-1<<"]="<<CosValues_CombinedHF_0to10->GetBinContent(k)<<";"<<endl;
      myout<<"avcoshf[1]["<<k-1<<"]="<<CosValues_CombinedHF_10to20->GetBinContent(k)<<";"<<endl;
      myout<<"avcoshf[2]["<<k-1<<"]="<<CosValues_CombinedHF_20to30->GetBinContent(k)<<";"<<endl;
      myout<<"avcoshf[3]["<<k-1<<"]="<<CosValues_CombinedHF_30to40->GetBinContent(k)<<";"<<endl;
      myout<<"avcoshf[4]["<<k-1<<"]="<<CosValues_CombinedHF_40to50->GetBinContent(k)<<";"<<endl;
      myout<<" "<<endl;
      myout<<"avsinhf[0]["<<k-1<<"]="<<SinValues_CombinedHF_0to10->GetBinContent(k)<<";"<<endl;
      myout<<"avsinhf[1]["<<k-1<<"]="<<SinValues_CombinedHF_10to20->GetBinContent(k)<<";"<<endl;
      myout<<"avsinhf[2]["<<k-1<<"]="<<SinValues_CombinedHF_20to30->GetBinContent(k)<<";"<<endl;
      myout<<"avsinhf[3]["<<k-1<<"]="<<SinValues_CombinedHF_30to40->GetBinContent(k)<<";"<<endl;
      myout<<"avsinhf[4]["<<k-1<<"]="<<SinValues_CombinedHF_40to50->GetBinContent(k)<<";"<<endl;
      myout<<" "<<endl;      
    }//end of loop over k


   //First Order Positive HF
   myout<<"//Positive HF"<<endl;


  for (Int_t k=1;k<=10;k++)
    {
      myout<<"avcoshfp[0]["<<k-1<<"]="<<CosValues_PositiveHF_0to10->GetBinContent(k)<<";"<<endl;
      myout<<"avcoshfp[1]["<<k-1<<"]="<<CosValues_PositiveHF_10to20->GetBinContent(k)<<";"<<endl;
      myout<<"avcoshfp[2]["<<k-1<<"]="<<CosValues_PositiveHF_20to30->GetBinContent(k)<<";"<<endl;
      myout<<"avcoshfp[3]["<<k-1<<"]="<<CosValues_PositiveHF_30to40->GetBinContent(k)<<";"<<endl;
      myout<<"avcoshfp[4]["<<k-1<<"]="<<CosValues_PositiveHF_40to50->GetBinContent(k)<<";"<<endl;
      myout<<" "<<endl;
      myout<<"avsinhfp[0]["<<k-1<<"]="<<SinValues_PositiveHF_0to10->GetBinContent(k)<<";"<<endl;
      myout<<"avsinhfp[1]["<<k-1<<"]="<<SinValues_PositiveHF_10to20->GetBinContent(k)<<";"<<endl;
      myout<<"avsinhfp[2]["<<k-1<<"]="<<SinValues_PositiveHF_20to30->GetBinContent(k)<<";"<<endl;
      myout<<"avsinhfp[3]["<<k-1<<"]="<<SinValues_PositiveHF_30to40->GetBinContent(k)<<";"<<endl;
      myout<<"avsinhfp[4]["<<k-1<<"]="<<SinValues_PositiveHF_40to50->GetBinContent(k)<<";"<<endl;
      myout<<" "<<endl;      
    }//end of loop over k


   //First Order Negative HF
   myout<<"//Negative HF"<<endl;


  for (Int_t k=1;k<=10;k++)
    {
      myout<<"avcoshfn[0]["<<k-1<<"]="<<CosValues_NegativeHF_0to10->GetBinContent(k)<<";"<<endl;
      myout<<"avcoshfn[1]["<<k-1<<"]="<<CosValues_NegativeHF_10to20->GetBinContent(k)<<";"<<endl;
      myout<<"avcoshfn[2]["<<k-1<<"]="<<CosValues_NegativeHF_20to30->GetBinContent(k)<<";"<<endl;
      myout<<"avcoshfn[3]["<<k-1<<"]="<<CosValues_NegativeHF_30to40->GetBinContent(k)<<";"<<endl;
      myout<<"avcoshfn[4]["<<k-1<<"]="<<CosValues_NegativeHF_40to50->GetBinContent(k)<<";"<<endl;
      myout<<" "<<endl;
      myout<<"avsinhfn[0]["<<k-1<<"]="<<SinValues_NegativeHF_0to10->GetBinContent(k)<<";"<<endl;
      myout<<"avsinhfn[1]["<<k-1<<"]="<<SinValues_NegativeHF_10to20->GetBinContent(k)<<";"<<endl;
      myout<<"avsinhfn[2]["<<k-1<<"]="<<SinValues_NegativeHF_20to30->GetBinContent(k)<<";"<<endl;
      myout<<"avsinhfn[3]["<<k-1<<"]="<<SinValues_NegativeHF_30to40->GetBinContent(k)<<";"<<endl;
      myout<<"avsinhfn[4]["<<k-1<<"]="<<SinValues_NegativeHF_40to50->GetBinContent(k)<<";"<<endl;
      myout<<" "<<endl;      
    }//end of loop over k


  //Second Order Corrections
  f.cd();
  Plots.cd();
  AngularCorrections.cd();
  SecondOrderCorrections.cd();

  myout<<" "<<endl;
  myout<<"//Second Order Positive HF"<<endl;
  for (Int_t k=1;k<=10;k++)
    {
      myout<<"avcoshf2p[0]["<<k-1<<"]="<<CosValues_PositiveHF2_0to10->GetBinContent(k)<<";"<<endl;
      myout<<"avcoshf2p[1]["<<k-1<<"]="<<CosValues_PositiveHF2_10to20->GetBinContent(k)<<";"<<endl;
      myout<<"avcoshf2p[2]["<<k-1<<"]="<<CosValues_PositiveHF2_20to30->GetBinContent(k)<<";"<<endl;
      myout<<"avcoshf2p[3]["<<k-1<<"]="<<CosValues_PositiveHF2_30to40->GetBinContent(k)<<";"<<endl;
      myout<<"avcoshf2p[4]["<<k-1<<"]="<<CosValues_PositiveHF2_40to50->GetBinContent(k)<<";"<<endl;
      myout<<" "<<endl;
      myout<<"avsinhf2p[0]["<<k-1<<"]="<<SinValues_PositiveHF2_0to10->GetBinContent(k)<<";"<<endl;
      myout<<"avsinhf2p[1]["<<k-1<<"]="<<SinValues_PositiveHF2_10to20->GetBinContent(k)<<";"<<endl;
      myout<<"avsinhf2p[2]["<<k-1<<"]="<<SinValues_PositiveHF2_20to30->GetBinContent(k)<<";"<<endl;
      myout<<"avsinhf2p[3]["<<k-1<<"]="<<SinValues_PositiveHF2_30to40->GetBinContent(k)<<";"<<endl;
      myout<<"avsinhf2p[4]["<<k-1<<"]="<<SinValues_PositiveHF2_40to50->GetBinContent(k)<<";"<<endl;
      myout<<" "<<endl;      
    }//end of loop over k

  //Second Order Negative HF
  myout<<"//Second Order Negative HF"<<endl;
  for (Int_t k=1;k<=10;k++)
    {
      myout<<"avcoshf2n[0]["<<k-1<<"]="<<CosValues_NegativeHF2_0to10->GetBinContent(k)<<";"<<endl;
      myout<<"avcoshf2n[1]["<<k-1<<"]="<<CosValues_NegativeHF2_10to20->GetBinContent(k)<<";"<<endl;
      myout<<"avcoshf2n[2]["<<k-1<<"]="<<CosValues_NegativeHF2_20to30->GetBinContent(k)<<";"<<endl;
      myout<<"avcoshf2n[3]["<<k-1<<"]="<<CosValues_NegativeHF2_30to40->GetBinContent(k)<<";"<<endl;
      myout<<"avcoshf2n[4]["<<k-1<<"]="<<CosValues_NegativeHF2_40to50->GetBinContent(k)<<";"<<endl;
      myout<<" "<<endl;
      myout<<"avsinhf2n[0]["<<k-1<<"]="<<SinValues_NegativeHF2_0to10->GetBinContent(k)<<";"<<endl;
      myout<<"avsinhf2n[1]["<<k-1<<"]="<<SinValues_NegativeHF2_10to20->GetBinContent(k)<<";"<<endl;
      myout<<"avsinhf2n[2]["<<k-1<<"]="<<SinValues_NegativeHF2_20to30->GetBinContent(k)<<";"<<endl;
      myout<<"avsinhf2n[3]["<<k-1<<"]="<<SinValues_NegativeHF2_30to40->GetBinContent(k)<<";"<<endl;
      myout<<"avsinhf2n[4]["<<k-1<<"]="<<SinValues_NegativeHF2_40to50->GetBinContent(k)<<";"<<endl;
      myout<<" "<<endl;      
    }//end of loop over k


  //Second Order Tracker
  myout<<"//Second Order Tracker"<<endl;
  for (Int_t k=1;k<=10;k++)
    {
      myout<<"avcostr2[0]["<<k-1<<"]="<<CosValues_TR2_0to10->GetBinContent(k)<<";"<<endl;
      myout<<"avcostr2[1]["<<k-1<<"]="<<CosValues_TR2_10to20->GetBinContent(k)<<";"<<endl;
      myout<<"avcostr2[2]["<<k-1<<"]="<<CosValues_TR2_20to30->GetBinContent(k)<<";"<<endl;
      myout<<"avcostr2[3]["<<k-1<<"]="<<CosValues_TR2_30to40->GetBinContent(k)<<";"<<endl;
      myout<<"avcostr2[4]["<<k-1<<"]="<<CosValues_TR2_40to50->GetBinContent(k)<<";"<<endl;
      myout<<" "<<endl;
      myout<<"avsintr2[0]["<<k-1<<"]="<<SinValues_TR2_0to10->GetBinContent(k)<<";"<<endl;
      myout<<"avsintr2[1]["<<k-1<<"]="<<SinValues_TR2_10to20->GetBinContent(k)<<";"<<endl;
      myout<<"avsintr2[2]["<<k-1<<"]="<<SinValues_TR2_20to30->GetBinContent(k)<<";"<<endl;
      myout<<"avsintr2[3]["<<k-1<<"]="<<SinValues_TR2_30to40->GetBinContent(k)<<";"<<endl;
      myout<<"avsintr2[4]["<<k-1<<"]="<<SinValues_TR2_40to50->GetBinContent(k)<<";"<<endl;
      myout<<" "<<endl;      
    }//end of loop over k



  myout.close();
}
