#!/bin/sh
 

b=$(sed -ne "${1}{p;q;}" files.txt)

cat > MHV1Resolution_${1}.C << +EOF

#include<TH1F>
#include<TProfile>
#include<iostream>
#include<iomanip>
#include"TFile.h"
#include"TTree.h"
#include"TLeaf.h"
#include"TChain.h"

void Initialize();
void FillAngularCorrections();
void Resolutions();


//Chains
TChain* chain; //Calo Tower Chain
TChain* chain1; //hiGoodTightMergedTracks


///File and Directories in the File
TFile *myFile;
TDirectory *myPlots;//Top Directory
//Resolution Plots
TDirectory *resolutions;
TDirectory *res1;
TDirectory *res2;


/////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////
////////////           GLOBAL VARIABLES            //////////////////
/////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////
Float_t pi=TMath::Pi();
Int_t vterm=1;//Set which order harmonic that this code is meant to measure
const Int_t jMax=10;////Set out to which order correction we would like to apply
Int_t NumberOfEvents=0;
//NumberOfEvents=1;
//NumberOfEvents=2;
//NumberOfEvents=10;
//NumberOfEvents=5000000;
Int_t Centrality=0;

///Looping Variables
Int_t NumberOfHits=0;//This will be for both tracks and Hits
Float_t pT=0.;
Float_t phi=0.;
Float_t eta=0.;
Float_t Energy=0.;

const Int_t nCent=5;//Number of Centrality classes

Float_t centlo[nCent];
Float_t centhi[nCent];
centlo[0]=0;  centhi[0]=10;
centlo[1]=10;  centhi[1]=20;
centlo[2]=20;  centhi[2]=30;
centlo[3]=30;  centhi[3]=40;
centlo[4]=40;  centhi[4]=50;


////////////////////////////////
///Psi1 Combined HF Variables///
////////////////////////////////
Float_t X_hf=0.,Y_hf=0.;//X and Y flow vectors
Float_t EP_hf=0.;//"raw" EP angle
Float_t EP_hffinal=0.;//"Final" EP angle
Float_t AngularCorrectionHF=0.;//"EP correction factor each event"
Float_t avsinhf[nCent][jMax],avcoshf[nCent][jMax];//Where I will extract the angular correction terms to
////////////////////////////////
///Psi1 Positive HF Variables///
////////////////////////////////
Float_t X_hfp=0.,Y_hfp=0.;//X and Y flow vectors
Float_t EP_hfp=0.;//"raw" EP angle
Float_t EP_hfpfinal=0.;//"Final" EP angle
Float_t AngularCorrectionHFP=0.;//"EP correction factor each event"
Float_t avsinhfp[nCent][jMax],avcoshfp[nCent][jMax];//Where I will extract the angular correction terms to
////////////////////////////////
///Psi1 Negative HF Variables///
////////////////////////////////
Float_t X_hfn=0.,Y_hfn=0.;//X and Y flow vectors
Float_t EP_hfn=0.;//"raw" EP angle
Float_t EP_hfnfinal=0.;//"Final" EP angle
Float_t AngularCorrectionHFN=0.;//"EP correction factor each event"
Float_t avsinhfn[nCent][jMax],avcoshfn[nCent][jMax];//Where I will extract the angular correction terms to
////////////////////////////////
///Psi2 Positive HF Variables///
////////////////////////////////
Float_t X_hf2p=0.,Y_hf2p=0.;//X and Y flow vectors
Float_t EP_hf2p=0.;//"raw" EP angle
Float_t EP_hf2pfinal=0.;//"Final" EP angle
Float_t AngularCorrectionHF2P=0.;//"EP correction factor each event"
Float_t avsinhf2p[nCent][jMax],avcoshf2p[nCent][jMax];//Where I will extract the angular correction terms to
////////////////////////////////
///Psi2 Negative HF Variables///
////////////////////////////////
Float_t X_hf2n=0.,Y_hf2n=0.;//X and Y flow vectors
Float_t EP_hf2n=0.;//"raw" EP angle
Float_t EP_hf2nfinal=0.;//"Final" EP angle
Float_t AngularCorrectionHF2N=0.;//"EP correction factor each event"
Float_t avsinhf2n[nCent][jMax],avcoshf2n[nCent][jMax];//Where I will extract the angular correction terms to
////////////////////////////////
///Psi2 Mid Tracker Variables///
////////////////////////////////
Float_t X_tr2=0.,Y_tr2=0.;//X and Y flow vectors
Float_t EP_tr2=0.;//"raw" EP angle
Float_t EP_tr2final=0.;//"Final" EP angle
Float_t AngularCorrectionTR2=0.;//"EP correction factor each event"
Float_t avsintr2[nCent][jMax],avcostr2[nCent][jMax];//Where I will extract the angular correction terms to


////////////////////////////////////////
///Resolution Plots and Variables///////
///////////////////////////////////////

//First Order Resolutions
TProfile *FirstOrderPositive;
TProfile *FirstOrderNegative;

//Second Order Resolutions
TProfile *HFPMinusHFM;//One of the three subevents for the second order resolution
TProfile *HFPMinusTracks;//One of the three subevents for the second order resolution
TProfile *HFMMinusTracks;//one of the three subevents for the second order resolution
Float_t Res2HFP[nCent];//This is where I will combine the three subevents into a resolution
Float_t Res2HFM[nCent];//This is where I will combine the three subevents into a resolution

//Combined Resolutions
Float_t FinalResPos[nCent];//Once I combine the second and first order resolutions this will be my factor
Float_t FinalResNeg[nCent];////Once I combine the second and first order resolutions this will be my factor

TH1F *FinalPositiveResolution;
TH1F *FinalNegativeResolution;


Int_t MHV1Resolution_${1}(){
  Initialize();
  FillAngularCorrections();
  Resolutions();
  myFile->Write();
  return 0;
}


void Initialize(){

  chain = new TChain("CaloTowerTree");
  chain1 = new TChain("hiGoodTightMergedTracksTree");

  //Calo Tower Tree
  chain->Add("/hadoop/store/user/jgomez2/ForwardTrees/2010/PanicTime/$b");
  //Tracks Tree
  chain1->Add("/hadoop/store/user/jgomez2/ForwardTrees/2010/PanicTime/$b");


  ///This will be used once I parallelize the code
  myFile= new TFile("MHEP_Resolution_${1}.root","recreate");

  NumberOfEvents=chain1->GetEntries();

  myPlots = myFile->mkdir("Plots");
  myPlots->cd();
  //Resolution Plots
  resolutions=myPlots->mkdir("Resolutions");
  res1=resolutions->mkdir("FirstOrderResolutionCorrections");
  res2=resolutions->mkdir("SecondOrderResolutionCorrections");


  /////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////
  ///////////////////MAKE THE PLOTS///////////////////////////
  ////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////

  /////////////////////////////////
  ////////Resolution Plots////////
  ////////////////////////////////
  res1->cd();
  FirstOrderPositive= new TProfile("FirstOrderResolutionForPositiveEtaParticles","FirstOrderResolutionForPositiveEtaParticles",nCent,0,nCent);
  FirstOrderPositive->GetYaxis()->SetTitle("<cos(#Psi_{1a} + #Psi_{1b} - 2#Psi_{2HF(-)})>");
  FirstOrderNegative= new TProfile("FirstOrderResolutionForNegativeEtaParticles","FirstOrderResolutionForNegativeEtaParticles",nCent,0,nCent);
  FirstOrderNegative->GetYaxis()->SetTitle("<cos(#Psi_{1a} + #Psi_{1b} - 2#Psi_{2HF(+)})>");

  res2->cd();
  //Second Order Resolutions
  HFPMinusHFM= new TProfile("SecondOrderHFPMinusHFM","SecondOrderHFPMinusHFM",nCent,0,nCent);
  HFPMinusHFM->GetYaxis()->SetTitle("<cos(#Psi_{2HF+} - #Psi_{2HF-})>");
  HFPMinusTracks=new TProfile("SecondOrderHFPMinusTracks","SecondOrderHFPMinusTracks",nCent,0,nCent);
  HFPMinusTracks->GetYaxis()->SetTitle("<cos(#Psi_{2HF+} - #Psi_{2MidTracks})>");
  HFMMinusTracks=new TProfile("SecondOrderHFMMinusTracks","SecondOrderHFMMinusTracks",nCent,0,nCent);
  HFMMinusTracks->GetYaxis()->SetTitle("<cos(#Psi_{2HF-} - #Psi_{2MidTracks})>");

  //Final resolutions
  resolutions->cd();
  FinalPositiveResolution= new TH1F("NegativeEtaRFactor","Resolution for particles in -#eta",nCent,0,nCent);
  FinalPositiveResolution->GetYaxis()->SetTitle("#sqrt{<cos(#Psi_{1}^{HF+}+ #Psi_{1}^{HF-} + (2*#Psi_{2}^{HF-}))> Res(HF-)}");
  FinalPositiveResolution->GetYaxis()->SetTitleSize(0.04);
  FinalPositiveResolution->GetYaxis()->SetTitleOffset(1.7);
  FinalPositiveResolution->GetXaxis()->SetBinLabel(1,"0-10%");
  FinalPositiveResolution->GetXaxis()->SetBinLabel(1,"10-20%");
  FinalPositiveResolution->GetXaxis()->SetBinLabel(1,"20-30%");
  FinalPositiveResolution->GetXaxis()->SetBinLabel(1,"30-40%");
  FinalPositiveResolution->GetXaxis()->SetBinLabel(1,"40-50%");

  FinalNegativeResolution=new TH1F("PositiveEtaRFactor","Resolution for particles in +#eta",nCent,0,nCent);
  FinalNegativeResolution->GetYaxis()->SetTitle("#sqrt{<cos(#Psi_{1}^{HF+}+ #Psi_{1}^{HF-} + (2*#Psi_{2}^{HF+}))> Res(HF+)}");
  FinalNegativeResolution->GetYaxis()->SetTitleSize(0.04);
  FinalNegativeResolution->GetYaxis()->SetTitleOffset(1.7);
  FinalNegativeResolution->GetXaxis()->SetBinLabel(1,"0-10%");
  FinalNegativeResolution->GetXaxis()->SetBinLabel(1,"10-20%");
  FinalNegativeResolution->GetXaxis()->SetBinLabel(1,"20-30%");
  FinalNegativeResolution->GetXaxis()->SetBinLabel(1,"30-40%");
  FinalNegativeResolution->GetXaxis()->SetBinLabel(1,"40-50%");
}//End Of initialize function

void Resolutions(){
  for (Int_t i=0;i<NumberOfEvents;i++)
    {
      if ( !(i%10000) ) cout << " 2nd round, event # " << i << " / " << NumberOfEvents << endl;

      chain->GetEntry(i);
      chain1->GetEntry(i);

      //Centrality Filter
      CENTRAL=(TLeaf*)chain1->GetLeaf("bin");
      Centrality=CENTRAL->GetValue();
      if (Centrality>19) continue;//dont need events over 60% centrality

      //Calo Tower Tree
      CaloHits= (TLeaf*) chain->GetLeaf("Calo_NumberOfHits");
      CaloEN= (TLeaf*) chain->GetLeaf("Et");
      CaloPhi= (TLeaf*) chain->GetLeaf("Phi");
      CaloEta= (TLeaf*) chain->GetLeaf("Eta");

      //Tracks Tree
      NumTracks= (TLeaf*) chain1->GetLeaf("nTracks");
      TrackMom= (TLeaf*) chain1->GetLeaf("pt");
      TrackPhi= (TLeaf*) chain1->GetLeaf("phi");
      TrackEta= (TLeaf*) chain1->GetLeaf("eta");

      //Zero the EP variables
      //First order combined HF
      X_hf=0.;
      Y_hf=0.;
      EP_hf=0.;
      EP_hffinal=0.;
      AngularCorrectionHF=0.;
      //First order positive hf
      X_hfp=0.;
      Y_hfp=0.;
      EP_hfp=0.;
      EP_hfpfinal=0.;
      AngularCorrectionHFP=0.;
      //First order negative hf
      X_hfn=0.;
      Y_hfn=0.;
      EP_hfn=0.;
      EP_hfnfinal=0.;
      AngularCorrectionHFN=0.;
      //Second order positive hf
      X_hf2p=0.;
      Y_hf2p=0.;
      EP_hf2p=0.;
      EP_hf2pfinal=0.;
      AngularCorrectionHF2P=0.;
      //Second order negative hf
      X_hf2n=0.;
      Y_hf2n=0.;
      EP_hf2n=0.;
      EP_hf2nfinal=0.;
      AngularCorrectionHF2N=0.;
      //Second order tracker
      X_tr2=0.;
      Y_tr2=0.;
      EP_tr2=0.;
      EP_tr2final=0.;
      AngularCorrectionTR2=0.;
      //Loop over calo hits first
      NumberOfHits=CaloHits->GetValue();
      for (Int_t ii=0;ii<NumberOfHits;ii++)
        {
          Energy=0.;
          phi=0.;
          eta=0.;
          Energy=CaloEN->GetValue(ii);
          phi=CaloPhi->GetValue(ii);
          eta=CaloEta->GetValue(ii);
          if (Energy<0) continue;
          if (eta>0)
            {
              //First Order Combined
              X_hf+=TMath::Cos(phi)*Energy;
              Y_hf+=TMath::Sin(phi)*Energy;
              //First Order Positive HF
              X_hfp+=TMath::Cos(phi)*Energy;
              Y_hfp+=TMath::Sin(phi)*Energy;
              //Second Order Positive HF
              X_hf2p+=TMath::Cos(2.0*phi)*Energy;
              Y_hf2p+=TMath::Sin(2.0*phi)*Energy;
            }//end of positive eta gate
          else if(eta<0)
            {
              //First Order Combined
              X_hf+=TMath::Cos(phi)*(-1.0*Energy);
              Y_hf+=TMath::Sin(phi)*(-1.0*Energy);
              //First Order Negative HF
              X_hfn+=TMath::Cos(phi)*(-1.0*Energy);
              Y_hfn+=TMath::Sin(phi)*(-1.0*Energy);
              //Second Order Negative HF
              X_hf2n+=TMath::Cos(2.0*phi)*Energy;
              Y_hf2n+=TMath::Sin(2.0*phi)*Energy;
            }//end of negative eta gate
        }//End of loop over calo hits

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

      /////////////////////////
      ////Make Event Planes////
      /////////////////////////
      //First order combined HF
      EP_hf=(1./1.)*TMath::ATan2(Y_hf,X_hf);
      if(EP_hf > pi) EP_hf=(EP_hf-(TMath::TwoPi()));
      if(EP_hf < (-1.0*pi)) EP_hf=(EP_hf+(TMath::TwoPi()));
      //First order positive hf
      EP_hfp=(1./1.)*TMath::ATan2(Y_hfp,X_hfp);
      if(EP_hfp > pi) EP_hfp=(EP_hfp-(TMath::TwoPi()));
      if(EP_hfp < (-1.0*pi)) EP_hfp=(EP_hfp+(TMath::TwoPi()));
      //First order negative hf
      EP_hfn=(1./1.)*TMath::ATan2(Y_hfn,X_hfn);
      if(EP_hfn > pi) EP_hfn=(EP_hfn-(TMath::TwoPi()));
      if(EP_hfn < (-1.0*pi)) EP_hfn=(EP_hfn+(TMath::TwoPi()));
      //Second order positive hf
      EP_hf2p=(1./2.)*TMath::ATan2(Y_hf2p,X_hf2p);
      if(EP_hf2p > (pi/2)) EP_hf2p=(EP_hf2p-(pi));
      if(EP_hf2p < (-1.0*(pi/2))) EP_hf2p=(EP_hf2p+(pi));
      //Second order negative hf
      EP_hf2n=(1./2.)*TMath::ATan2(Y_hf2n,X_hf2n);
      if(EP_hf2n > (pi/2)) EP_hf2n=(EP_hf2n-(pi));
      if(EP_hf2n < (-1.0*(pi/2))) EP_hf2n=(EP_hf2n+(pi));
      //Second order tracker
      EP_tr2=(1./2.)*TMath::ATan2(Y_tr2,X_tr2);
      if(EP_tr2 > (pi/2)) EP_tr2=(EP_tr2-(pi));
      if(EP_tr2 < (-1.0*(pi/2))) EP_tr2=(EP_tr2+(pi));


      //////////////////////////////////
      ///Angular Corrections To EP's///
      //////////////////////////////////
      for (Int_t c=0;c<nCent;c++)
        {
          if ( (Centrality*2.5) > centhi[c] ) continue;
          if ( (Centrality*2.5) < centlo[c] ) continue;
          //Compute Angular Corrections
          AngularCorrectionHF=0.;
          AngularCorrectionHFP=0.;
          AngularCorrectionHFN=0.;
          AngularCorrectionHF2P=0.;
          AngularCorrectionHF2N=0.;
          AngularCorrectionTR2=0.;

          for (Int_t k=1;k<(jMax+1);k++)
            {
              //Combined HF
              AngularCorrectionHF+=(2./k)*((-avsinhf[c][k-1]*TMath::Cos(k*EP_hf))+(avcoshf[c][k-1]*TMath::Sin(k*EP_hf)));
 
              //First Order Positive HF
              AngularCorrectionHFP+=(2./k)*((-avsinhfp[c][k-1]*TMath::Cos(k*EP_hfp))+(avcoshfp[c][k-1]*TMath::Sin(k*EP_hfp)));

              //First Order Negative HF
              AngularCorrectionHFN+=(2./k)*((-avsinhfn[c][k-1]*TMath::Cos(k*EP_hfn))+(avcoshfn[c][k-1]*TMath::Sin(k*EP_hfn)));

              //Second Order Positive HF
              AngularCorrectionHF2P+=(1./k)*((-avsinhf2p[c][k-1]*TMath::Cos(k*2*EP_hf2p))+(avcoshf2p[c][k-1]*TMath::Sin(k*2*EP_hf2p)));

              //Second Order Negative HF
              AngularCorrectionHF2N+=(1./k)*((-avsinhf2n[c][k-1]*TMath::Cos(k*2*EP_hf2n))+(avcoshf2n[c][k-1]*TMath::Sin(k*2*EP_hf2n)));

              //Second Order Tracker
              AngularCorrectionTR2+=(1./k)*((-avsintr2[c][k-1]*TMath::Cos(k*2*EP_tr2))+(avcostr2[c][k-1]*TMath::Sin(k*2*EP_tr2)));
            }//end of loop over correction orders

          //Combined HF
          EP_hffinal=EP_hf+AngularCorrectionHF;
          if(EP_hffinal > pi) EP_hffinal=(EP_hffinal-(TMath::TwoPi()));
          if(EP_hffinal < (-1.0*pi)) EP_hffinal=(EP_hffinal+(TMath::TwoPi()));

          //First Order Positive HF
          EP_hfpfinal=EP_hfp+AngularCorrectionHFP;
          if(EP_hfpfinal > pi) EP_hfpfinal=(EP_hfpfinal-(TMath::TwoPi()));
          if(EP_hfpfinal < (-1.0*pi)) EP_hfpfinal=(EP_hfpfinal+(TMath::TwoPi()));
          //First Order Negative HF
          EP_hfnfinal=EP_hfn+AngularCorrectionHFN;
          if(EP_hfnfinal > pi) EP_hfnfinal=(EP_hfnfinal-(TMath::TwoPi()));
          if(EP_hfnfinal < (-1.0*pi)) EP_hfnfinal=(EP_hfnfinal+(TMath::TwoPi()));
          //Second Order Positive HF
          EP_hf2pfinal=EP_hf2p+AngularCorrectionHF2P;
          if(EP_hf2pfinal > (pi/2)) EP_hf2pfinal=(EP_hf2pfinal-(pi));
          if(EP_hf2pfinal < (-1.0*(pi/2))) EP_hf2pfinal=(EP_hf2pfinal+(pi));
          //Second Order Negative HF
          EP_hf2nfinal=EP_hf2n+AngularCorrectionHF2N;
          if(EP_hf2nfinal > (pi/2)) EP_hf2nfinal=(EP_hf2nfinal-(pi));
          if(EP_hf2nfinal < (-1.0*(pi/2))) EP_hf2nfinal=(EP_hf2nfinal+(pi));
          //Second Order Tracker
          EP_tr2final=EP_tr2+AngularCorrectionTR2;
          if(EP_tr2final > (pi/2)) EP_tr2final=(EP_tr2final-(pi));
          if(EP_tr2final < (-1.0*(pi/2))) EP_tr2final=(EP_tr2final+(pi));


          //////////////////////////////////////////////////////
          //////////////FILL THE RESOLUTION HISTOS//////////////
          //////////////////////////////////////////////////////
          //First Order Resolutions
          FirstOrderPositive->Fill(c,TMath::Cos(EP_hfp+EP_hfn+(2.0*EP_hf2n)));
          FirstOrderNegative->Fill(c,TMath::Cos(EP_hfp+EP_hfn+(2.0*EP_hf2p)));

          //Second Order Resolutions
          HFPMinusHFM->Fill(c,TMath::Cos(2*(EP_hf2p-EP_hf2n)));
          HFPMinusTracks->Fill(c,TMath::Cos(2*(EP_hf2p-EP_tr2)));
          HFMMinusTracks->Fill(c,TMath::Cos(2*(EP_hf2n-EP_tr2)));
        }//End of Loop over Centralities
    }//End of loop over events


  ////////////Store the resolution factors in variables that can more easily be accessed
  for (Int_t c=0;c<nCent;c++)
    {
      //Res2HFP is the resolution which will be used for particles that are in negative psuedorapidity
      //Res2HFM is the resolution which will be used for particles that are in positive pseudorapidity
      if(HFMMinusTracks->GetBinContent(c+1)!=0)
        {
         Res2HFM[c]=TMath::Sqrt((fabs((HFPMinusHFM->GetBinContent(c+1))*(HFPMinusTracks->GetBinContent(c+1))))/(fabs(HFMMinusTracks->GetBinContent(c+1))));
         }
       else Res2HFM[c]=0.;
       if(HFPMinusTracks->GetBinContent(c+1)!=0)
         {
       Res2HFP[c]=TMath::Sqrt((fabs((HFPMinusHFM->GetBinContent(c+1))*(HFMMinusTracks->GetBinContent(c+1))))/(fabs(HFPMinusTracks->GetBinContent(c+1))));
         }
      else Res2HFP[c]=0.;

      //The same +/- convention used here
      FinalResPos[c]=TMath::Sqrt(fabs(FirstOrderPositive->GetBinContent(c+1)))*Res2HFP[c];
      FinalPositiveResolution->SetBinContent(c+1,FinalResPos[c]);
      FinalResNeg[c]=TMath::Sqrt(fabs(FirstOrderNegative->GetBinContent(c+1)))*Res2HFM[c];      
      FinalNegativeResolution->SetBinContent(c+1,FinalResNeg[c]);
    }//end of loop over centralities
}//end of Resolutions Function


void FillAngularCorrections(){
//FirstOrder
//Whole HF
avcoshf[0][0]=0.241358;
avcoshf[1][0]=0.203332;
avcoshf[2][0]=0.169672;
avcoshf[3][0]=0.138333;
avcoshf[4][0]=0.112338;
 
avsinhf[0][0]=0.117904;
avsinhf[1][0]=0.0998105;
avsinhf[2][0]=0.0821577;
avsinhf[3][0]=0.0666861;
avsinhf[4][0]=0.0540927;
 
avcoshf[0][1]=0.0278259;
avcoshf[1][1]=0.0190862;
avcoshf[2][1]=0.0135941;
avcoshf[3][1]=0.00881665;
avcoshf[4][1]=0.00593949;
 
avsinhf[0][1]=0.0340036;
avsinhf[1][1]=0.0252613;
avsinhf[2][1]=0.0162446;
avsinhf[3][1]=0.0106913;
avsinhf[4][1]=0.00620601;
 
avcoshf[0][2]=0.00261522;
avcoshf[1][2]=0.00108467;
avcoshf[2][2]=-0.000236671;
avcoshf[3][2]=0.000979191;
avcoshf[4][2]=0.000171692;
 
avsinhf[0][2]=0.00527823;
avsinhf[1][2]=0.00440598;
avsinhf[2][2]=0.002198;
avsinhf[3][2]=0.00097893;
avsinhf[4][2]=0.000643096;
 
avcoshf[0][3]=0.000305953;
avcoshf[1][3]=0.000348561;
avcoshf[2][3]=-0.000994616;
avcoshf[3][3]=-0.000332396;
avcoshf[4][3]=-0.000734793;
 
avsinhf[0][3]=0.00113914;
avsinhf[1][3]=-0.000100696;
avsinhf[2][3]=0.000624146;
avsinhf[3][3]=0.00038035;
avsinhf[4][3]=0.000518083;
 
avcoshf[0][4]=0.000543687;
avcoshf[1][4]=0.000153836;
avcoshf[2][4]=-0.000322314;
avcoshf[3][4]=-0.000152443;
avcoshf[4][4]=0.00100856;
 
avsinhf[0][4]=0.000788454;
avsinhf[1][4]=0.000304809;
avsinhf[2][4]=-0.000854481;
avsinhf[3][4]=-4.67324e-05;
avsinhf[4][4]=-0.000997324;
 
avcoshf[0][5]=0.000272746;
avcoshf[1][5]=-3.28095e-05;
avcoshf[2][5]=-3.24298e-05;
avcoshf[3][5]=0.000112958;
avcoshf[4][5]=0.000302729;
 
avsinhf[0][5]=0.00057117;
avsinhf[1][5]=3.79494e-05;
avsinhf[2][5]=-0.000259527;
avsinhf[3][5]=-0.00115908;
avsinhf[4][5]=-0.000250075;
 
avcoshf[0][6]=0.000655511;
avcoshf[1][6]=-5.35309e-05;
avcoshf[2][6]=0.000320241;
avcoshf[3][6]=-0.000674697;
avcoshf[4][6]=-0.000434284;
 
avsinhf[0][6]=0.000521078;
avsinhf[1][6]=0.000569606;
avsinhf[2][6]=-0.00026661;
avsinhf[3][6]=-2.99831e-05;
avsinhf[4][6]=0.000536625;
 
avcoshf[0][7]=-0.000601099;
avcoshf[1][7]=-0.000152116;
avcoshf[2][7]=-3.77066e-05;
avcoshf[3][7]=0.000304096;
avcoshf[4][7]=-6.11627e-05;
 
avsinhf[0][7]=0.000267841;
avsinhf[1][7]=0.000689778;
avsinhf[2][7]=0.000726481;
avsinhf[3][7]=-5.46477e-05;
avsinhf[4][7]=0.00163345;
 
avcoshf[0][8]=0.000355067;
avcoshf[1][8]=0.000361545;
avcoshf[2][8]=8.784e-05;
avcoshf[3][8]=0.00107012;
avcoshf[4][8]=0.000177254;
 
avsinhf[0][8]=-0.00064307;
avsinhf[1][8]=0.000544993;
avsinhf[2][8]=0.000466165;
avsinhf[3][8]=0.00073351;
avsinhf[4][8]=0.000553717;
 
avcoshf[0][9]=0.000590213;
avcoshf[1][9]=0.000123503;
avcoshf[2][9]=0.000204519;
avcoshf[3][9]=-2.17251e-05;
avcoshf[4][9]=0.000647249;
 
avsinhf[0][9]=0.000258999;
avsinhf[1][9]=-0.00016461;
avsinhf[2][9]=0.000262721;
avsinhf[3][9]=-0.000873681;
avsinhf[4][9]=0.000596251;
 
//Positive HF
avcoshfp[0][0]=0.211773;
avcoshfp[1][0]=0.175442;
avcoshfp[2][0]=0.144926;
avcoshfp[3][0]=0.116019;
avcoshfp[4][0]=0.0933076;
 
avsinhfp[0][0]=0.18617;
avsinhfp[1][0]=0.162965;
avsinhfp[2][0]=0.140631;
avsinhfp[3][0]=0.119668;
avsinhfp[4][0]=0.102134;
 
avcoshfp[0][1]=0.00832748;
avcoshfp[1][1]=0.00331422;
avcoshfp[2][1]=0.0016121;
avcoshfp[3][1]=-0.000693271;
avcoshfp[4][1]=-0.00108848;
 
avsinhfp[0][1]=0.0484226;
avsinhfp[1][1]=0.036094;
avsinhfp[2][1]=0.0254469;
avsinhfp[3][1]=0.0157868;
avsinhfp[4][1]=0.0104192;
 
avcoshfp[0][2]=-0.00248047;
avcoshfp[1][2]=-0.00197499;
avcoshfp[2][2]=-0.000768072;
avcoshfp[3][2]=0.000183059;
avcoshfp[4][2]=0.000478493;
 
avsinhfp[0][2]=0.00586492;
avsinhfp[1][2]=0.0038198;
avsinhfp[2][2]=0.00243328;
avsinhfp[3][2]=0.000430096;
avsinhfp[4][2]=0.000490039;
 
avcoshfp[0][3]=-0.0011044;
avcoshfp[1][3]=-0.000626961;
avcoshfp[2][3]=-0.000451245;
avcoshfp[3][3]=-0.000403795;
avcoshfp[4][3]=-0.000378189;
 
avsinhfp[0][3]=0.000442892;
avsinhfp[1][3]=-0.000613247;
avsinhfp[2][3]=-0.000187147;
avsinhfp[3][3]=-0.000427303;
avsinhfp[4][3]=-3.12938e-05;
 
avcoshfp[0][4]=-0.000941818;
avcoshfp[1][4]=-3.31044e-05;
avcoshfp[2][4]=-0.000416422;
avcoshfp[3][4]=0.000216491;
avcoshfp[4][4]=0.000616515;
 
avsinhfp[0][4]=0.000366099;
avsinhfp[1][4]=-5.5593e-05;
avsinhfp[2][4]=-0.000272835;
avsinhfp[3][4]=-0.000512665;
avsinhfp[4][4]=-0.000171686;
 
avcoshfp[0][5]=-0.000131862;
avcoshfp[1][5]=9.11697e-06;
avcoshfp[2][5]=-0.000519371;
avcoshfp[3][5]=9.5388e-05;
avcoshfp[4][5]=0.000124678;
 
avsinhfp[0][5]=0.00017936;
avsinhfp[1][5]=-0.00120226;
avsinhfp[2][5]=-0.00126474;
avsinhfp[3][5]=-0.00091131;
avsinhfp[4][5]=0.000113416;
 
avcoshfp[0][6]=-2.23402e-05;
avcoshfp[1][6]=0.000370826;
avcoshfp[2][6]=9.41827e-05;
avcoshfp[3][6]=0.000421602;
avcoshfp[4][6]=0.000769933;
 
avsinhfp[0][6]=0.000364724;
avsinhfp[1][6]=-0.000603025;
avsinhfp[2][6]=-0.000642751;
avsinhfp[3][6]=-0.000605326;
avsinhfp[4][6]=0.000224423;
 
avcoshfp[0][7]=0.000217021;
avcoshfp[1][7]=0.000306864;
avcoshfp[2][7]=0.000600897;
avcoshfp[3][7]=6.25777e-05;
avcoshfp[4][7]=-6.51235e-05;
 
avsinhfp[0][7]=-0.00021446;
avsinhfp[1][7]=8.90418e-05;
avsinhfp[2][7]=-6.20895e-06;
avsinhfp[3][7]=-0.000408382;
avsinhfp[4][7]=-0.000524585;
 
avcoshfp[0][8]=0.000131185;
avcoshfp[1][8]=0.000149817;
avcoshfp[2][8]=-0.000136383;
avcoshfp[3][8]=0.000484789;
avcoshfp[4][8]=0.000820728;
 
avsinhfp[0][8]=-2.24006e-05;
avsinhfp[1][8]=0.000364304;
avsinhfp[2][8]=0.000174475;
avsinhfp[3][8]=-0.000600088;
avsinhfp[4][8]=0.000150203;
 
avcoshfp[0][9]=-0.00025087;
avcoshfp[1][9]=-0.0002386;
avcoshfp[2][9]=-0.000271819;
avcoshfp[3][9]=-0.000419117;
avcoshfp[4][9]=-3.94618e-05;
 
avsinhfp[0][9]=-2.35956e-05;
avsinhfp[1][9]=-0.000379191;
avsinhfp[2][9]=-0.000270555;
avsinhfp[3][9]=-0.000862229;
avsinhfp[4][9]=2.38095e-05;
 
//Negative HF
avcoshfn[0][0]=0.142053;
avcoshfn[1][0]=0.122684;
avcoshfn[2][0]=0.103932;
avcoshfn[3][0]=0.0863377;
avcoshfn[4][0]=0.0705408;
 
avsinhfn[0][0]=-0.0151816;
avsinhfn[1][0]=-0.0189694;
avsinhfn[2][0]=-0.0215608;
avsinhfn[3][0]=-0.0231592;
avsinhfn[4][0]=-0.0240417;
 
avcoshfn[0][1]=0.0115751;
avcoshfn[1][1]=0.00801504;
avcoshfn[2][1]=0.00599936;
avcoshfn[3][1]=0.00384164;
avcoshfn[4][1]=0.00109664;
 
avsinhfn[0][1]=-0.00479726;
avsinhfn[1][1]=-0.00435138;
avsinhfn[2][1]=-0.00410947;
avsinhfn[3][1]=-0.00271904;
avsinhfn[4][1]=-0.00308043;
 
avcoshfn[0][2]=0.000482573;
avcoshfn[1][2]=0.000468018;
avcoshfn[2][2]=0.000514416;
avcoshfn[3][2]=0.000564757;
avcoshfn[4][2]=0.00033716;
 
avsinhfn[0][2]=-0.0011609;
avsinhfn[1][2]=-0.00104551;
avsinhfn[2][2]=-0.00141255;
avsinhfn[3][2]=-0.000359748;
avsinhfn[4][2]=0.000368175;
 
avcoshfn[0][3]=0.000312999;
avcoshfn[1][3]=0.000485248;
avcoshfn[2][3]=-0.000446548;
avcoshfn[3][3]=-0.000228986;
avcoshfn[4][3]=0.000105989;
 
avsinhfn[0][3]=7.13265e-05;
avsinhfn[1][3]=-0.000428604;
avsinhfn[2][3]=-0.000569136;
avsinhfn[3][3]=1.74324e-05;
avsinhfn[4][3]=-0.000175939;
 
avcoshfn[0][4]=-0.00050293;
avcoshfn[1][4]=-0.000148505;
avcoshfn[2][4]=-0.000241436;
avcoshfn[3][4]=-9.75343e-05;
avcoshfn[4][4]=0.000777549;
 
avsinhfn[0][4]=-9.11601e-05;
avsinhfn[1][4]=0.000935192;
avsinhfn[2][4]=0.000672585;
avsinhfn[3][4]=0.00114805;
avsinhfn[4][4]=-0.000226028;
 
avcoshfn[0][5]=-0.000418174;
avcoshfn[1][5]=-0.000444401;
avcoshfn[2][5]=-0.00078176;
avcoshfn[3][5]=-0.000148256;
avcoshfn[4][5]=-9.1097e-07;
 
avsinhfn[0][5]=0.000376287;
avsinhfn[1][5]=0.00177265;
avsinhfn[2][5]=0.000413236;
avsinhfn[3][5]=9.60308e-05;
avsinhfn[4][5]=0.000186734;
 
avcoshfn[0][6]=-0.00102588;
avcoshfn[1][6]=-0.000224793;
avcoshfn[2][6]=-0.000431063;
avcoshfn[3][6]=0.000564632;
avcoshfn[4][6]=0.000535278;
 
avsinhfn[0][6]=-1.19047e-05;
avsinhfn[1][6]=-0.000535155;
avsinhfn[2][6]=-0.000694036;
avsinhfn[3][6]=-0.000276575;
avsinhfn[4][6]=0.000367302;
 
avcoshfn[0][7]=-0.000594774;
avcoshfn[1][7]=-6.64752e-06;
avcoshfn[2][7]=0.000204079;
avcoshfn[3][7]=-1.76846e-07;
avcoshfn[4][7]=-0.000467464;
 
avsinhfn[0][7]=-0.000460843;
avsinhfn[1][7]=-0.000175636;
avsinhfn[2][7]=0.000344731;
avsinhfn[3][7]=0.000203351;
avsinhfn[4][7]=0.000196254;
 
avcoshfn[0][8]=-0.000467617;
avcoshfn[1][8]=-0.000225708;
avcoshfn[2][8]=0.000205206;
avcoshfn[3][8]=0.000346911;
avcoshfn[4][8]=-0.000302372;
 
avsinhfn[0][8]=0.000156688;
avsinhfn[1][8]=0.000531075;
avsinhfn[2][8]=0.000287865;
avsinhfn[3][8]=-0.000523805;
avsinhfn[4][8]=9.64681e-05;
 
avcoshfn[0][9]=-5.27982e-05;
avcoshfn[1][9]=5.16132e-05;
avcoshfn[2][9]=0.00027072;
avcoshfn[3][9]=-0.000913485;
avcoshfn[4][9]=-0.00060228;
 
avsinhfn[0][9]=-0.000294008;
avsinhfn[1][9]=0.00108399;
avsinhfn[2][9]=-0.000107535;
avsinhfn[3][9]=0.000406129;
avsinhfn[4][9]=0.00104661;
 
 
//Second Order Positive HF
avcoshf2p[0][0]=-0.00345886;
avcoshf2p[1][0]=-0.000938836;
avcoshf2p[2][0]=-0.000142717;
avcoshf2p[3][0]=0.00051143;
avcoshf2p[4][0]=-4.68245e-05;
 
avsinhf2p[0][0]=-0.0174223;
avsinhf2p[1][0]=-0.00878685;
avsinhf2p[2][0]=-0.00693761;
avsinhf2p[3][0]=-0.00482428;
avsinhf2p[4][0]=-0.00295601;
 
avcoshf2p[0][1]=0.000261323;
avcoshf2p[1][1]=-0.000515772;
avcoshf2p[2][1]=-0.00127981;
avcoshf2p[3][1]=-0.00226174;
avcoshf2p[4][1]=-0.00127901;
 
avsinhf2p[0][1]=-0.00182983;
avsinhf2p[1][1]=-0.00233632;
avsinhf2p[2][1]=-0.00208729;
avsinhf2p[3][1]=-0.00389437;
avsinhf2p[4][1]=-0.00320341;
 
avcoshf2p[0][2]=-0.00113164;
avcoshf2p[1][2]=0.000210054;
avcoshf2p[2][2]=-0.000471308;
avcoshf2p[3][2]=0.000253574;
avcoshf2p[4][2]=0.000319389;
 
avsinhf2p[0][2]=0.000124433;
avsinhf2p[1][2]=-0.000137378;
avsinhf2p[2][2]=-6.66552e-05;
avsinhf2p[3][2]=0.000525569;
avsinhf2p[4][2]=0.000966433;
 
avcoshf2p[0][3]=2.16699e-05;
avcoshf2p[1][3]=0.000164134;
avcoshf2p[2][3]=0.000160856;
avcoshf2p[3][3]=-0.000712164;
avcoshf2p[4][3]=-2.61689e-07;
 
avsinhf2p[0][3]=-0.000715407;
avsinhf2p[1][3]=-0.000267545;
avsinhf2p[2][3]=0.000857959;
avsinhf2p[3][3]=0.000513361;
avsinhf2p[4][3]=0.000624576;
 
avcoshf2p[0][4]=7.20611e-05;
avcoshf2p[1][4]=0.000152271;
avcoshf2p[2][4]=3.44727e-06;
avcoshf2p[3][4]=-0.000726585;
avcoshf2p[4][4]=0.000537201;
 
avsinhf2p[0][4]=0.000215828;
avsinhf2p[1][4]=-0.000807744;
avsinhf2p[2][4]=-0.000856462;
avsinhf2p[3][4]=-0.000614297;
avsinhf2p[4][4]=-2.30453e-05;
 
avcoshf2p[0][5]=0.000769965;
avcoshf2p[1][5]=-0.000526186;
avcoshf2p[2][5]=-0.00037177;
avcoshf2p[3][5]=0.00126886;
avcoshf2p[4][5]=0.000694751;
 
avsinhf2p[0][5]=0.000143081;
avsinhf2p[1][5]=-0.000333191;
avsinhf2p[2][5]=-0.000813384;
avsinhf2p[3][5]=-0.000531837;
avsinhf2p[4][5]=0.000568574;
 
avcoshf2p[0][6]=-0.00021541;
avcoshf2p[1][6]=-0.000539448;
avcoshf2p[2][6]=-5.93024e-05;
avcoshf2p[3][6]=0.000551495;
avcoshf2p[4][6]=0.000374005;
 
avsinhf2p[0][6]=-0.00011505;
avsinhf2p[1][6]=0.000352329;
avsinhf2p[2][6]=0.000303474;
avsinhf2p[3][6]=0.00113766;
avsinhf2p[4][6]=-0.000202781;
 
avcoshf2p[0][7]=-0.000395683;
avcoshf2p[1][7]=-3.39329e-05;
avcoshf2p[2][7]=0.000392726;
avcoshf2p[3][7]=-0.000190894;
avcoshf2p[4][7]=0.000353237;
 
avsinhf2p[0][7]=-0.000402416;
avsinhf2p[1][7]=0.000207433;
avsinhf2p[2][7]=9.42202e-05;
avsinhf2p[3][7]=-0.000490262;
avsinhf2p[4][7]=0.000166675;
 
avcoshf2p[0][8]=-0.000197321;
avcoshf2p[1][8]=6.78288e-05;
avcoshf2p[2][8]=-0.00036266;
avcoshf2p[3][8]=0.000859895;
avcoshf2p[4][8]=0.000616952;
 
avsinhf2p[0][8]=-0.000437209;
avsinhf2p[1][8]=-0.00034205;
avsinhf2p[2][8]=0.000696505;
avsinhf2p[3][8]=-0.00114331;
avsinhf2p[4][8]=4.44219e-05;
 
avcoshf2p[0][9]=0.000587473;
avcoshf2p[1][9]=-0.000135961;
avcoshf2p[2][9]=7.72956e-05;
avcoshf2p[3][9]=0.000458329;
avcoshf2p[4][9]=-0.00101668;
 
avsinhf2p[0][9]=9.61275e-05;
avsinhf2p[1][9]=0.000329921;
avsinhf2p[2][9]=0.000622672;
avsinhf2p[3][9]=0.000189671;
avsinhf2p[4][9]=-0.000822757;
 
//Second Order Negative HF
avcoshf2n[0][0]=-0.0191027;
avcoshf2n[1][0]=-0.0106104;
avcoshf2n[2][0]=-0.00840251;
avcoshf2n[3][0]=-0.0075905;
avcoshf2n[4][0]=-0.00721494;
 
avsinhf2n[0][0]=-0.00850509;
avsinhf2n[1][0]=-0.00286958;
avsinhf2n[2][0]=-0.000708895;
avsinhf2n[3][0]=0.00162712;
avsinhf2n[4][0]=0.00261613;
 
avcoshf2n[0][1]=-2.59975e-05;
avcoshf2n[1][1]=-0.000484854;
avcoshf2n[2][1]=-0.000541949;
avcoshf2n[3][1]=-0.000847324;
avcoshf2n[4][1]=0.00048231;
 
avsinhf2n[0][1]=0.000448648;
avsinhf2n[1][1]=-0.000421886;
avsinhf2n[2][1]=-0.000396909;
avsinhf2n[3][1]=-0.00132175;
avsinhf2n[4][1]=-0.0014084;
 
avcoshf2n[0][2]=-0.000341492;
avcoshf2n[1][2]=0.000379508;
avcoshf2n[2][2]=0.000100937;
avcoshf2n[3][2]=0.000728425;
avcoshf2n[4][2]=0.00103627;
 
avsinhf2n[0][2]=0.000271042;
avsinhf2n[1][2]=-0.000173643;
avsinhf2n[2][2]=-0.000587693;
avsinhf2n[3][2]=-0.000959733;
avsinhf2n[4][2]=-0.000951431;
 
avcoshf2n[0][3]=0.000762509;
avcoshf2n[1][3]=0.000524445;
avcoshf2n[2][3]=9.85635e-05;
avcoshf2n[3][3]=0.000613808;
avcoshf2n[4][3]=-0.000666135;
 
avsinhf2n[0][3]=-0.000154681;
avsinhf2n[1][3]=0.000871322;
avsinhf2n[2][3]=0.000419098;
avsinhf2n[3][3]=-0.000217683;
avsinhf2n[4][3]=-0.00054179;
 
avcoshf2n[0][4]=-0.000471317;
avcoshf2n[1][4]=3.74389e-05;
avcoshf2n[2][4]=-0.000313199;
avcoshf2n[3][4]=7.60983e-05;
avcoshf2n[4][4]=0.000470397;
 
avsinhf2n[0][4]=7.56714e-05;
avsinhf2n[1][4]=-0.000489587;
avsinhf2n[2][4]=0.000989359;
avsinhf2n[3][4]=6.39956e-05;
avsinhf2n[4][4]=0.000388173;
 
avcoshf2n[0][5]=0.000506328;
avcoshf2n[1][5]=-0.000507916;
avcoshf2n[2][5]=0.000259343;
avcoshf2n[3][5]=0.000451823;
avcoshf2n[4][5]=0.00102271;
 
avsinhf2n[0][5]=0.000434962;
avsinhf2n[1][5]=0.000686707;
avsinhf2n[2][5]=0.000614787;
avsinhf2n[3][5]=0.000230762;
avsinhf2n[4][5]=-0.000701309;
 
avcoshf2n[0][6]=0.000228016;
avcoshf2n[1][6]=-0.000295497;
avcoshf2n[2][6]=0.000197196;
avcoshf2n[3][6]=-0.00026628;
avcoshf2n[4][6]=-0.000758986;
 
avsinhf2n[0][6]=0.000846691;
avsinhf2n[1][6]=-0.000879442;
avsinhf2n[2][6]=6.39654e-05;
avsinhf2n[3][6]=-0.000919154;
avsinhf2n[4][6]=-0.000303208;
 
avcoshf2n[0][7]=0.000927575;
avcoshf2n[1][7]=0.000867151;
avcoshf2n[2][7]=0.000611986;
avcoshf2n[3][7]=-0.000681929;
avcoshf2n[4][7]=0.000484648;
 
avsinhf2n[0][7]=5.17316e-05;
avsinhf2n[1][7]=-0.000273857;
avsinhf2n[2][7]=-0.000103555;
avsinhf2n[3][7]=-0.000565751;
avsinhf2n[4][7]=-0.00124322;
 
avcoshf2n[0][8]=-8.36708e-05;
avcoshf2n[1][8]=-0.000685721;
avcoshf2n[2][8]=5.01435e-05;
avcoshf2n[3][8]=0.000392827;
avcoshf2n[4][8]=-0.000319762;
 
avsinhf2n[0][8]=-0.000462206;
avsinhf2n[1][8]=0.000242815;
avsinhf2n[2][8]=0.000402857;
avsinhf2n[3][8]=0.000289243;
avsinhf2n[4][8]=-0.00045233;
 
avcoshf2n[0][9]=7.13179e-06;
avcoshf2n[1][9]=7.66092e-05;
avcoshf2n[2][9]=-0.000336144;
avcoshf2n[3][9]=-0.000776175;
avcoshf2n[4][9]=-0.00019618;
 
avsinhf2n[0][9]=-0.000196742;
avsinhf2n[1][9]=6.92429e-05;
avsinhf2n[2][9]=-0.000662824;
avsinhf2n[3][9]=-0.000554784;
avsinhf2n[4][9]=0.00135716;
 
//Second Order Tracker
avcostr2[0][0]=0.141992;
avcostr2[1][0]=0.0822777;
avcostr2[2][0]=0.0631518;
avcostr2[3][0]=0.0579758;
avcostr2[4][0]=0.0552918;
 
avsintr2[0][0]=-0.0186762;
avsintr2[1][0]=-0.0100764;
avsintr2[2][0]=-0.00793477;
avsintr2[3][0]=-0.00681533;
avsintr2[4][0]=-0.0076709;
 
avcostr2[0][1]=0.00533521;
avcostr2[1][1]=-0.0098113;
avcostr2[2][1]=-0.0120248;
avcostr2[3][1]=-0.0124445;
avcostr2[4][1]=-0.0106392;
 
avsintr2[0][1]=0.00163771;
avsintr2[1][1]=-0.000430473;
avsintr2[2][1]=-0.000537605;
avsintr2[3][1]=-0.000745109;
avsintr2[4][1]=-0.000632822;
 
avcostr2[0][2]=-0.000295303;
avcostr2[1][2]=-0.00217216;
avcostr2[2][2]=-0.00209834;
avcostr2[3][2]=-0.00195873;
avcostr2[4][2]=-0.00267139;
 
avsintr2[0][2]=0.000349911;
avsintr2[1][2]=6.1587e-05;
avsintr2[2][2]=0.0013689;
avsintr2[3][2]=0.00181877;
avsintr2[4][2]=0.00125957;
 
avcostr2[0][3]=-0.000821898;
avcostr2[1][3]=0.000164067;
avcostr2[2][3]=8.92539e-05;
avcostr2[3][3]=-0.000742696;
avcostr2[4][3]=-0.000734053;
 
avsintr2[0][3]=-0.000150918;
avsintr2[1][3]=-0.000311496;
avsintr2[2][3]=0.00061353;
avsintr2[3][3]=0.000142268;
avsintr2[4][3]=0.00149597;
 
avcostr2[0][4]=0.00096275;
avcostr2[1][4]=-6.05165e-05;
avcostr2[2][4]=0.000192387;
avcostr2[3][4]=0.00045425;
avcostr2[4][4]=0.00044261;
 
avsintr2[0][4]=0.000234047;
avsintr2[1][4]=0.000350696;
avsintr2[2][4]=0.000745809;
avsintr2[3][4]=0.000170303;
avsintr2[4][4]=8.0301e-05;
 
avcostr2[0][5]=0.000260596;
avcostr2[1][5]=-0.000304046;
avcostr2[2][5]=-0.000663198;
avcostr2[3][5]=0.000937206;
avcostr2[4][5]=0.000447806;
 
avsintr2[0][5]=0.000578735;
avsintr2[1][5]=0.00040293;
avsintr2[2][5]=-0.000107361;
avsintr2[3][5]=-6.9393e-05;
avsintr2[4][5]=0.000431259;
 
avcostr2[0][6]=-0.00117765;
avcostr2[1][6]=-0.000476139;
avcostr2[2][6]=-0.000832403;
avcostr2[3][6]=0.000301927;
avcostr2[4][6]=0.000398984;
 
avsintr2[0][6]=0.000259664;
avsintr2[1][6]=-4.50232e-05;
avsintr2[2][6]=-0.000580816;
avsintr2[3][6]=-8.11893e-05;
avsintr2[4][6]=0.00028673;
 
avcostr2[0][7]=-0.00037806;
avcostr2[1][7]=6.0473e-05;
avcostr2[2][7]=0.000852771;
avcostr2[3][7]=0.00012677;
avcostr2[4][7]=0.000690909;
 
avsintr2[0][7]=-0.00032068;
avsintr2[1][7]=-0.000391373;
avsintr2[2][7]=-0.000102162;
avsintr2[3][7]=-0.000366452;
avsintr2[4][7]=-0.000338996;
 
avcostr2[0][8]=-0.000430606;
avcostr2[1][8]=-4.91898e-06;
avcostr2[2][8]=0.00092408;
avcostr2[3][8]=-5.07722e-05;
avcostr2[4][8]=-0.000279919;
 
avsintr2[0][8]=0.000246859;
avsintr2[1][8]=0.000732096;
avsintr2[2][8]=0.00119766;
avsintr2[3][8]=0.000161825;
avsintr2[4][8]=0.000105652;
 
avcostr2[0][9]=0.000384667;
avcostr2[1][9]=0.000169357;
avcostr2[2][9]=0.00038628;
avcostr2[3][9]=0.000122493;
avcostr2[4][9]=0.000334249;
 
avsintr2[0][9]=-0.0006623;
avsintr2[1][9]=6.45771e-05;
avsintr2[2][9]=-0.000102216;
avsintr2[3][9]=-0.000370557;
avsintr2[4][9]=0.000354695;
 

}//end of fill angular corrections
+EOF
