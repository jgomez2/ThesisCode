{


  TChain* chain1; //hiGoodTightMergedTracks
  chain1 = new TChain("hiGoodTightMergedTracksTree");

  //Tracks Tree
  chain1->Add("/hadoop/store/user/jgomez2/ForwardTrees/2010/PanicTime/Forward*");


  Float_t pi=TMath::Pi();
  Int_t NumberOfEvents=0;
  //NumberOfEvents=1;
  //NumberOfEvents=2;
  //NumberOfEvents=10;
  NumberOfEvents=100000;


  ///Looping Variables
  Int_t NumberOfHits=0;//This will be for both tracks and Hits
  Float_t pT=0.;
  Float_t phi=0.;
  Float_t eta=0.;



  Float_t X_tr2=0.,Y_tr2=0.;//X and Y flow vectors
  Float_t EP_tr2=0.;//"raw" EP angle
  Float_t EP_tr2final=0.;//"Final" EP angle

  TH1F *Psi2TRRaw=new TH1F("blah","blah",100,-TMath::PiOver2(),TMath::PiOver2());



  for (Int_t i=0;i<2;i++)
    {
      if ( !(i%10000) ) cout << " 1st round, event # " << i << " / " << NumberOfEvents << endl;

      chain1->GetEntry(i);

      //Tracks Tree
      NumTracks= (TLeaf*) chain1->GetLeaf("nTracks");
      TrackMom= (TLeaf*) chain1->GetLeaf("pt");
      TrackPhi= (TLeaf*) chain1->GetLeaf("phi");
      TrackEta= (TLeaf*) chain1->GetLeaf("eta");

      //Second order tracker
      X_tr2=0.;
      Y_tr2=0.;
      EP_tr2=0.;


      //Now loop over tracks
      NumberOfHits=NumTracks->GetValue();
      for (int ii=0;ii<NumberOfHits;ii++)
        {
          pT=0.;
          phi=0.;
          eta=0.;
          pT=TrackMom->GetValue(ii);
          phi=TrackPhi->GetValue(ii);
          eta=TrackEta->GetValue(ii);
          if(pT<0) continue;
          else if(fabs(eta)<=1.0)
            {
              X_tr2+=TMath::Cos(2.0*phi)*pT;
              Y_tr2+=TMath::Sin(2.0*phi)*pT;
            }
        }//end of loop over tracks
      std::cout<<X_tr2<<std::endl;
      std::cout<<Y_tr2<<std::endl;
      /////////////////////////
      ////Make Event Planes////
      /////////////////////////

      //Second order tracker
      EP_tr2=(1./2.)*atan2(Y_tr2,X_tr2);
      if(EP_tr2 > (TMath::PiOver2())) EP_tr2=(EP_tr2-(TMath::Pi()));
      if(EP_tr2 < (-1.0*(TMath::PiOver2()))) EP_tr2=(EP_tr2+(TMath::Pi()));

      Psi2TRRaw->Fill(EP_tr2);

    }//End of loop over events

  new TCanvas;
  Psi2TRRaw->Draw();

}
