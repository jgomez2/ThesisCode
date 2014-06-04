{

  //Published v2 CMS data
  Float_t v2EPdata[4]={0.090768,0.091231,0.091322,0.09063};
  Float_t v2EPerror[4]={7.4821e-05,7.2467e-05,7.293e-05,7.6235e-05};
  Float_t v2EPerrorsys[4]={0.0013615,0.0013685,0.0013698,0.0013594};

  //Eigen value method data points
  
  // <Q Q*>
  // Float_t v2Eigendata[12]={.1009,.1007,.10155,.10239,
  //		   .10237,.10337,.102415,.1028,
  //		   .10195,.10132,.1014279,.10056};
  

  // <Q Q*> - N
  /*  Float_t v2Eigendata[12]={.09035,.08956,.089844,.0903,
			   .0902,.09076,.08997,.0908,
			   .090232,.090045,.09069,.09058};*/

  //<Q Q*> -N -<Q><Q*>
  Float_t v2Eigendata[12]={.09027,.08947,.089769,.090239,
			   .0901,.090686,.08989,.0907,
			   .09015,.08996,.0905,.0905};
			   

  Float_t eta_bin[13]={-0.6,-0.5,-0.4,-0.3,-0.2,-0.1,0.0,0.1,0.2,0.3,0.4,0.5,0.6};
  

TH1F* V2Eta = new TH1F("V2Eta","V_{2}{#eta} 20%-30%",12,eta_bin);
  V2Eta->SetXTitle("#eta");
  V2Eta->SetYTitle("v_{2}");
  gStyle->SetTitleX(0.5);
  gStyle->SetTitleAlign(23);
  V2Eta->SetMarkerStyle(33);
  V2Eta->SetMarkerColor(kGreen+3);
  V2Eta->GetXaxis()->CenterTitle(1);
  V2Eta->GetYaxis()->CenterTitle(1);
  V2Eta->GetYaxis()->SetRangeUser(0.01,0.14);
  V2Eta->GetXaxis()->SetTickLength(0.02);
  V2Eta->GetYaxis()->SetTickLength(0.02);
  gStyle->SetPadTickY(1);
  gStyle->SetPadTickX(1);


  TH1F* V2EtaOfficial = new TH1F("V2Eta1","V_{2}{#eta} 20%-30%",12,eta_bin);
  V2EtaOfficial->SetXTitle("#eta");
  V2EtaOfficial->SetYTitle("v_{2}");
  gStyle->SetTitleX(0.5);
  gStyle->SetTitleAlign(23);
  V2EtaOfficial->SetMarkerStyle(20);
  V2EtaOfficial->SetMarkerColor(2);
  V2EtaOfficial->GetXaxis()->CenterTitle(1);
  V2EtaOfficial->GetYaxis()->CenterTitle(1);
  V2EtaOfficial->GetXaxis()->SetTickLength(0.02);
  V2EtaOfficial->GetYaxis()->SetTickLength(0.02);
  gStyle->SetPadTickY(1);
  gStyle->SetPadTickX(1);


  for( Int_t i=1;i<14;i++)
    {
      V2Eta->SetBinContent(i,v2Eigendata[i-1]);
    }
  
  V2EtaOfficial->SetBinContent(1,v2EPdata[0]);
  V2EtaOfficial->SetBinError(1,TMath::Sqrt((v2EPerror[0]*v2EPerror[0])+(v2EPerrorsys[0]*v2EPerrorsys[0])));

  V2EtaOfficial->SetBinContent(5,v2EPdata[1]);
  V2EtaOfficial->SetBinError(5,TMath::Sqrt((v2EPerror[1]*v2EPerror[1])+(v2EPerrorsys[1]*v2EPerrorsys[1])));


  V2EtaOfficial->SetBinContent(8,v2EPdata[2]);
  V2EtaOfficial->SetBinError(8,TMath::Sqrt((v2EPerror[2]*v2EPerror[2])+(v2EPerrorsys[2]*v2EPerrorsys[2])));


  V2EtaOfficial->SetBinContent(12,v2EPdata[3]);
  V2EtaOfficial->SetBinError(12,TMath::Sqrt((v2EPerror[3]*v2EPerror[3])+(v2EPerrorsys[3]*v2EPerrorsys[3])));


  new TCanvas;
  V2Eta->SetStats(0);
  V2Eta->SetTitle(0);
  V2Eta->Draw("P");
  V2EtaOfficial->SetStats(0);
  V2EtaOfficial->SetTitle(0);
  V2EtaOfficial->Draw("PE2same");

  
          ///Legend///
      TLegend* leg= new TLegend(0.3,0.23,0.5,0.48,"v_{2}","brNDC");
      leg->AddEntry(V2Eta->GetName(),"v_{2} (EigenValue Method)   20-30%","lp");
      leg->AddEntry(V2EtaOfficial->GetName(),"v_{2}(EP) PRC.87.014902  25-30%","lp");
      leg->SetFillColor(kWhite);
      leg->SetTextFont(43);
      leg->SetTextSize(16);
      leg->SetBorderSize(0);
      leg->Draw();
      //////////////////
      ///TLatex////
      //  texa=new TLatex(0.64,0.74,"20-30%");
      //texa->SetNDC();
      //texa->SetTextSize(18);
      //texa->SetTextFont(43);
      // texa->Draw();
  tex=new TLatex(0.52,0.80,"PbPb  #sqrt{s_{NN}}\ =\ 2.76TeV");
  tex->SetNDC();
  tex->SetTextSize(18);
  tex->SetTextFont(43);
  tex->Draw();
  tex1=new TLatex(0.18,0.82,"CMS Preliminary");
  tex1->SetNDC();
  tex1->SetTextFont(43);
  tex1->SetTextSize(16);
  tex1->SetTextColor(kRed);
  tex1->Draw(); 

}
