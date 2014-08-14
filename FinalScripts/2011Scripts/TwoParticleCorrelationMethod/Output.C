{

  TFile f("TwoParticleCorrelation_2010_atlasbins.root");
  Plots.cd();
  V11Results.cd();
  
  Float_t pt_bin[17]={0.4,0.6,0.8,1.0,1.2,1.4,1.6,1.8,2.0,2.4,2.8,3.2,3.6,4.5,6.5,9.5,12};

  ofstream myout;
  myout.open("V11Values_cms_etagapof2_atlasbins.txt");

  TMatrixD C10to20(8,27);
  TMatrixD C20to30(8,27);  
  TMatrixD C30to40(8,27);  
  TMatrixD C40to50(8,27);

   myout<<"Matrix with the following pT bins"<<endl;
  myout<<endl;
  myout<<"Double_t pta_bins[9]={0.5,1.,1.5,2.,3.,4.,6.,8.,20.};"<<endl;
  myout<<endl;
  myout<<"  Double_t ptb_bins[28]={0.5,0.6,0.8,1.0,1.2,1.4,1.6,1.8,2.0,2.2,2.4,2.6,2.8,3.0,3.5,4.0,4.5,5.0,6.0,7.0,8.0,9.0,10.0,12,14,16,18,20};"<<endl; 
  myout<<endl;

  myout<<"+++++++++++++++++++++++++++++++++++++++++++++++++++++"<<endl;
  myout<<"+++++++++++++++++++ 10-20% ++++++++++++++++++++++++++"<<endl;
  myout<<"+++++++++++++++++++++++++++++++++++++++++++++++++++++"<<endl;
  myout<<endl;
  for (Int_t row=1;row<9;row++)
    {
      for (Int_t column=1;column<28;column++)
	{
	  C10to20[row-1][column-1]=V11PT_10to20->GetBinContent(row,column);
          C20to30[row-1][column-1]=V11PT_20to30->GetBinContent(row,column);
	  C30to40[row-1][column-1]=V11PT_30to40->GetBinContent(row,column);
          C40to50[row-1][column-1]=V11PT_40to50->GetBinContent(row,column);
	}
    }
  
  //myout<<C10to20.Print()<<endl;
  



}
