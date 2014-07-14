#!/bin/sh
 

b=$(sed -ne "${1}{p;q;}" files.txt)

cat > HFV1EPPlotting_${1}.C << +EOF

#include<TH1F>
#include<TProfile>
#include<iostream>
#include<iomanip>
#include"TFile.h"
#include"TTree.h"
#include"TLeaf.h"
#include"TChain.h"

void Initialize();
void FillResolutions();
void FillAngularCorrections();
void EPPlotting();

//Files and chains
TChain* chain;//= new TChain("CaloTowerTree");
TChain* chain2;//= new TChain("hiGoodTightMergedTracksTree");



//When I parrallelize this, I need to make sure that I do not fill <pT> and <pT*pT>
//Also, this only works because I do not need have any overlapping centrality classes. When I calculate_trodd+=cos(phi)*(pT-(pt2avmid[c]/ptavmid[c])) this would be a problem if i had overlapping classes

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
//NumberOfEvents=10000;
Int_t Centrality=0;
//  NumberOfEvents = chain->GetEntries();

///Looping Variables
Int_t NumberOfHits=0;//This will be for both tracks and Hits
Float_t pT=0.;
Float_t phi=0.;
Float_t eta=0.;
Float_t Energy=0.;


//Create the output ROOT file
TFile *myFile;

const Int_t nCent=5;//Number of Centrality classes

Float_t centlo[nCent];
Float_t centhi[nCent];
centlo[0]=0;  centhi[0]=10;
centlo[1]=10;  centhi[1]=20;
centlo[2]=20;  centhi[2]=30;
centlo[3]=30;  centhi[3]=40;
centlo[4]=40;  centhi[4]=50;


//Make Subdirectories for what will follow
TDirectory *myPlots;//the top level

TDirectory *epangles;//where i will store the ep angles
TDirectory *wholehfepangles;
TDirectory *poshfepangles;
TDirectory *neghfepangles;
TDirectory *midtrackerangles;
////////////////////////////////////////////////
/////////////////////////////////
//Resolutions
TDirectory *resolutions;
TDirectory *evenresolutions;
TDirectory *oddresolutions;
/////////////////////////////////
//V1
TDirectory *v1plots;//where i will store the v1 plots
TDirectory *v1etaoddplots;//v1(eta) [odd] plots
TDirectory *v1etaevenplots; //v1(eta)[even] plots
TDirectory *v1ptevenplots; //v1(pT)[even] plots
TDirectory *v1ptoddplots;//v1(pT)[odd] plots
////////////////////////////////




//Looping Variables
//v1 even
Float_t X_hfeven=0.,Y_hfeven=0.;


//v1 odd
Float_t X_hfodd=0.,Y_hfodd=0.;

///Looping Variables
//v1 even
Float_t EPhfeven=0.;
Float_t AngularCorrectionHFEven=0.,EPfinalhfeven=0.;

//v1 odd
Float_t EPhfodd=0.;
Float_t AngularCorrectionHFOdd=0.,EPfinalhfodd=0.;

//PosHFEven
Float_t X_poseven=0.,Y_poseven=0.;
Float_t EP_poseven=0.,EP_finalposeven=0.;
Float_t AngularCorrectionHFPEven=0.;
//PosHFOdd
Float_t X_posodd=0.,Y_posodd=0.;
Float_t EP_posodd=0.,EP_finalposodd=0.;
Float_t AngularCorrectionHFPOdd=0.;
//NegHFEven
Float_t X_negeven=0.,Y_negeven=0.;
Float_t EP_negeven=0.,EP_finalnegeven=0.;
Float_t AngularCorrectionHFNEven=0.;
//NegHFOdd
Float_t X_negodd=0.,Y_negodd=0.;
Float_t EP_negodd=0.,EP_finalnegodd=0.;
Float_t AngularCorrectionHFNOdd=0.;

//MidTrackerOdd
Float_t X_trodd=0.,Y_trodd=0.;
Float_t EP_trodd=0.,EP_finaltrodd=0.;
Float_t AngularCorrectionTROdd=0.;
//MidTrackerEven                                                                                  
Float_t X_treven=0.,Y_treven=0.;
Float_t EP_treven=0.,EP_finaltreven=0.;
Float_t AngularCorrectionTREven=0.;



//<pT> and <pT^2> 
Float_t ptavmid[nCent],pt2avmid[nCent];

//<Cos> <Sin>
                  //v1 even
                  //Whole HF
                  Float_t Sinhfeven[nCent][jMax],Coshfeven[nCent][jMax];
                  //Pos HF
                  Float_t Sinhfpeven[nCent][jMax],Coshfpeven[nCent][jMax];
                  //Neg HF
                  Float_t Sinhfneven[nCent][jMax],Coshfneven[nCent][jMax];
                  //Tracker
                  Float_t Sintreven[nCent][jMax],Costreven[nCent][jMax];
                  
                  //v1 odd
                  //Whole HF
                  Float_t Sinhfodd[nCent][jMax],Coshfodd[nCent][jMax];
                  //Pos HF
                  Float_t Sinhfpodd[nCent][jMax],Coshfpodd[nCent][jMax];
                  //Neg HF
                  Float_t Sinhfnodd[nCent][jMax],Coshfnodd[nCent][jMax];
                  //Tracker
                  Float_t Sintrodd[nCent][jMax],Costrodd[nCent][jMax];

//////////////////////////////////////////////////////

////////////////////////////////////////////
//Final EP Plots
//Psi1Even
//Whole HF
TH1F *PsiEvenRaw[nCent];
TH1F *PsiEvenFinal[nCent];
//PosHF
TH1F *PsiPEvenRaw[nCent];
TH1F *PsiPEvenFinal[nCent];
//NegHF
TH1F *PsiNEvenRaw[nCent];
TH1F *PsiNEvenFinal[nCent];
//Mid Tracker
TH1F *PsiTREvenRaw[nCent];
TH1F *PsiTREvenFinal[nCent];
//////////////////////////////////////////////
//Psi1 Odd
//Whole HF
TH1F *PsiOddRaw[nCent];
TH1F *PsiOddFinal[nCent];
//PosHF
TH1F *PsiPOddRaw[nCent];
TH1F *PsiPOddFinal[nCent];
//NegHF
TH1F *PsiNOddRaw[nCent];
TH1F *PsiNOddFinal[nCent];
//Mid Tracker               
TH1F *PsiTROddRaw[nCent];
TH1F *PsiTROddFinal[nCent];
///////////////////////////////////////////////

//Average Corrections
TProfile *PsiOddCorrs[nCent];
TProfile *PsiEvenCorrs[nCent];


////////////////////////////////
//Resolution Plots
//Even
TProfile *HFPMinusHFMEven;
TProfile *HFPMinusTREven;
TProfile *HFMMinusTREven;
//Odd
TProfile *HFPMinusHFMOdd;
TProfile *HFPMinusTROdd;
TProfile *HFMMinusTROdd;
/////////////////////////////////

//V1 Plots
//V1 Plots
TProfile *V1EtaOdd[nCent];
TProfile *V1EtaEven[nCent];
TProfile *V1PtEven[nCent];
TProfile *V1PtOdd[nCent];
//Single Side HF v 1
TProfile *V1OddHFP[nCent];
TProfile *V1OddHFM[nCent];
TProfile *V1EvenHFP[nCent];
TProfile *V1EvenHFM[nCent];

//PT Bin Centers
TProfile *PTCenters[nCent];
//////////////////////////////////

Int_t HFV1EPPlotting_${1}(){
  Initialize();
  FillAngularCorrections();
  FillResolutions();
  EPPlotting();
  return 0;
}


void Initialize(){

 chain = new TChain("CaloTowerTree");
  chain1 = new TChain("hiGoodTightMergedTracksTree");

  //Calo Tower Tree
  chain->Add("/hadoop/store/user/jgomez2/ForwardTrees/2010/PanicTime/Forward*");
  //Tracks Tree
  chain1->Add("/hadoop/store/user/jgomez2/ForwardTrees/2010/PanicTime/Forward*");

  Float_t eta_bin[7]={-1.5,-1.0,-0.5,0.0,0.5,1.0,1.5};
  Float_t pt_bin[17]={0.4,0.6,0.8,1.0,
                      1.2,1.4,1.6,1.8,
                      2.0,2.4,2.8,3.2,
                      3.6,4.5,6.5,9.5,
                      12};

  ///This will be used once I parallelize the code
  myFile= new TFile("MixedHarmonic2010Analysis.root","recreate");

  myPlots = myFile->mkdir("Plots");
  myPlots->cd();
  //Event Plane Plots
  epangles=myPlots->mkdir("EventPlanes");
  ep1=epangles->mkdir("FirstOrderEventPlanes");
  ep2=epangles->mkdir("SecondOrderEventPlanes");
  //Flow Plots
  v1plots=myPlots->mkdir("V1Results");


  /////////////////////////////////////////////
  ///Declaration of Titles for the Plots///////
  /////////////////////////////////////////////


  ///////Magnitude Plots///////
  char psi1corrsname[128],psi1corrstitle[128];
  char psi2corrsname[128],psi2corrstitle[128];

  /////////////////////////////
  /////Event Plane Plots///////
  ////////////////////////////

  ///First Order///
  char psi1hfrawname[128],psi1hfrawtitle[128];//Combined HF Raw
  char psi1hffinalname[128],psi1hffinaltitle[128];//Combined HF Final

  char psi1hfprawname[128],psi1hfprawtitle[128];//Positive HF Raw
  char psi1hfpfinalname[128],psi1hfpfinaltitle[128];//Positive HF Final

  char psi1hfnrawname[128],psi1hfnrawtitle[128];//Negative HF Raw
  char psi1hfnfinalname[128],psi1hfnfinaltitle[128];//Negative HF Final

  ///Second Order///
  char psi2hfprawname[128],psi2hfprawtitle[128];//Positive HF Raw
  char psi2hfpfinalname[128],psi2hfpfinaltitle[128];//Positive HF Final

  char psi2hfnrawname[128],psi2hfnrawtitle[128];//Negative HF Raw
  char psi2hfnfinalname[128],psi2hfnfinaltitle[128];//Negative HF Final

  char psi2trrawname[128],psi2trrawtitle[128];//Tracker Raw
  char psi2trfinalname[128],psi2trfinaltitle[128];//Tracker Final

  /////////////////////////////
  //// Directed Flow Plots/////
  ////////////////////////////
  char v1etaname[128],v1etatitle[128];
  char v1ptname[128],v1pttitle[128];

  //PTCenter Plots
  char ptcentername[128],ptcentertitle[128];



  /////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////
  ///////////////////MAKE THE PLOTS///////////////////////////
  ////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////
  for (Int_t i=0;i<nCent;i++)
    {

      //Magnitude Plots//
      angularcorrectionplots->cd();
      sprintf(psi1corrsname,"MagnitudeOfCorrectionFactors_Psi1_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(psi1corrstitle,"MagnitudeOfCorrectionFactors_Psi1_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      Psi1Corrs[i]=new TProfile(psi1corrsname,psi1corrstitle,jMax,0,jMax);
      Psi1Corrs[i]->GetYaxis()->SetTitle("<sin(Xbin*#Psi)>");

      sprintf(psi2corrsname,"MagnitudeOfCorrectionFactors_Psi2_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(psi2corrstitle,"MagnitudeOfCorrectionFactors_Psi2_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      Psi2Corrs[i]=new TProfile(psi2corrsname,psi2corrstitle,jMax,0,jMax);
      Psi2Corrs[i]->GetYaxis()->SetTitle("<sin(Xbin*#Psi)>");
      ///////////////////////////////////////////////////////////////////////////////////////////

      /////////////////////////////////
      ////////Event Plane Plots////////
      ////////////////////////////////

      /////First Order//////
      ep1->cd();
      //Combined HF//
      sprintf(psi1hfrawname,"RawEP_CombinedHF_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(psi1hfrawtitle,"RawEP_CombinedHF_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      Psi1HFRaw[i]=new TH1F(psi1hfrawname,psi1hfrawtitle,180,-pi-.19,pi+.19);
      Psi1HFRaw[i]->GetXaxis()->SetTitle("#Psi_{1}^{HF}");
      Psi1HFRaw[i]->GetYaxis()->SetTitle("Counts");

      sprintf(psi1hffinalname,"FinalEP_CombinedHF_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(psi1hffinaltitle,"FinalEP_CombinedHF_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      Psi1HFFinal[i]=new TH1F(psi1hffinalname,psi1hffinaltitle,180,-pi-.19,pi+.19);
      Psi1HFFinal[i]->GetXaxis()->SetTitle("#Psi_{1}^{HF}");
      Psi1HFFinal[i]->GetYaxis()->SetTitle("Counts");
      
      //Positive HF//
      sprintf(psi1hfprawname,"RawEP_HFP_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(psi1hfprawtitle,"RawEP_HFP_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      Psi1HFPRaw[i]=new TH1F(psi1hfprawname,psi1hfprawtitle,180,-pi-.19,pi+.19);
      Psi1HFPRaw[i]->GetXaxis()->SetTitle("#Psi_{1}^{HF+}");
      Psi1HFPRaw[i]->GetYaxis()->SetTitle("Counts");

      sprintf(psi1hfpfinalname,"FinalEP_HFP_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(psi1hfpfinaltitle,"FinalEP_HFP_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      Psi1HFPFinal[i]=new TH1F(psi1hfpfinalname,psi1hfpfinaltitle,180,-pi-.19,pi+.19);
      Psi1HFPFinal[i]->GetXaxis()->SetTitle("#Psi_{1}^{HF+}");
      Psi1HFPFinal[i]->GetYaxis()->SetTitle("Counts");

      //Negative HF//
      sprintf(psi1hfnrawname,"RawEP_HFN_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(psi1hfnrawtitle,"RawEP_HFN_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      Psi1HFNRaw[i]=new TH1F(psi1hfnrawname,psi1hfnrawtitle,180,-pi-.19,pi+.19);
      Psi1HFNRaw[i]->GetXaxis()->SetTitle("#Psi_{1}^{HF-}");
      Psi1HFNRaw[i]->GetYaxis()->SetTitle("Counts");

      sprintf(psi1hfnfinalname,"FinalEP_HFN_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(psi1hfnfinaltitle,"FinalEP_HFN_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      Psi1HFNFinal[i]=new TH1F(psi1hfnfinalname,psi1hfnfinaltitle,180,-pi-.19,pi+.19);
      Psi1HFNFinal[i]->GetXaxis()->SetTitle("#Psi_{1}^{HF-}");
      Psi1HFNFinal[i]->GetYaxis()->SetTitle("Counts");
      
      ///Second Order///
      ep2->cd();
      //Positive HF//
      sprintf(psi2hfprawname,"RawEP_HFP2_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(psi2hfprawtitle,"RawEP_HFP2_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      Psi2HFPRaw[i]=new TH1F(psi2hfprawname,psi2hfprawtitle,180,(-pi/2)-.19,(pi/2)+.19);
      Psi2HFPRaw[i]->GetXaxis()->SetTitle("#Psi_{2}^{HF+}");
      Psi2HFPRaw[i]->GetYaxis()->SetTitle("Counts");

      sprintf(psi2hfpfinalname,"FinalEP_HFP2_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(psi2hfpfinaltitle,"FinalEP_HFP2_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      Psi2HFPFinal[i]=new TH1F(psi2hfpfinalname,psi2hfpfinaltitle,180,(-pi/2)-.19,(pi/2)+.19);
      Psi2HFPFinal[i]->GetXaxis()->SetTitle("#Psi_{2}^{HF+}");
      Psi2HFPFinal[i]->GetYaxis()->SetTitle("Counts");

      //Negative HF//
      sprintf(psi2hfnrawname,"RawEP_HFN2_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(psi2hfnrawtitle,"RawEP_HFN2_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      Psi2HFNRaw[i]=new TH1F(psi2hfnrawname,psi2hfnrawtitle,180,(-pi/2)-.19,(pi/2)+.19);
      Psi2HFNRaw[i]->GetXaxis()->SetTitle("#Psi_{2}^{HF-}");
      Psi2HFNRaw[i]->GetYaxis()->SetTitle("Counts");

      sprintf(psi2hfnfinalname,"FinalEP_HFN2_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(psi2hfnfinaltitle,"FinalEP_HFN2_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      Psi2HFNFinal[i]=new TH1F(psi2hfnfinalname,psi2hfnfinaltitle,180,(-pi/2)-.19,(pi/2)+.19);
      Psi2HFNFinal[i]->GetXaxis()->SetTitle("#Psi_{2}^{HF-}");
      Psi2HFNFinal[i]->GetYaxis()->SetTitle("Counts");

 
      //MidTracker//
      sprintf(psi2trrawname,"RawEP_TR2_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(psi2trrawtitle,"RawEP_TR2_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      Psi2TRRaw[i]=new TH1F(psi2trrawname,psi2trrawtitle,180,(-pi/2)-.19,(pi/2)+.19);
      Psi2TRRaw[i]->GetXaxis()->SetTitle("#Psi_{2}^{TR}");
      Psi2TRRaw[i]->GetYaxis()->SetTitle("Counts");

      sprintf(psi2trfinalname,"FinalEP_TR2_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(psi2trfinaltitle,"FinalEP_TR2_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      Psi2TRFinal[i]=new TH1F(psi2trfinalname,psi2trfinaltitle,180,(-pi/2)-.19,(pi/2)+.19);
      Psi2TRFinal[i]->GetXaxis()->SetTitle("#Psi_{2}^{TR}");
      Psi2TRFinal[i]->GetYaxis()->SetTitle("Counts");


      /////////////////////////////
      //// Directed Flow Plots/////
      ////////////////////////////
      v1plots->cd();
      //V1 Eta//
      sprintf(v1etaname,"V1Eta_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(v1etatitle,"V1Eta_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      V1Eta[i]=new TProfile(v1etaname,v1etatitle,6,eta_bin);
      V1Eta[i]->GetYaxis()->SetTitle("v_{1}");
      V1Eta[i]->GetXaxis()->SetTitle("#eta");

      //V1 Pt//
      sprintf(v1ptname,"V1Pt_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(v1pttitle,"V1Pt_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      V1Pt[i]=new TProfile(v1ptname,v1pttitle,16,pt_bin);
      V1Pt[i]->GetYaxis()->SetTitle("v_{1}");
      V1Pt[i]->GetXaxis()->SetTitle("p_{T} (GeV/c)");

      myPlots->cd();
      sprintf(ptcentername,"PtCenters_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(ptcentertitle,"PtCenters_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      PTCenters[i]=new TProfile(ptcentername,ptcentertitle,16,pt_bin);
    }//End of Plot Making Loop



}//end of initialize function

void FillResolutions(){}//End of fill resolutions function

void EPPlotting(){

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


      for (Int_t c=0;c<nCent;c++)
        {
          if ( (Centrality*2.5) > centhi[c] ) continue;
          if ( (Centrality*2.5) < centlo[c] ) continue;

      /////////////////////////
      ////Make Event Planes////
      /////////////////////////
      //First order combined HF
      EP_hf=(1./1.)*TMath::ATan2(Y_hf,X_hf);
      if(EP_hf > pi) EP_hf=(EP_hf-(TMath::TwoPi()));
      if(EP_hf < (-1.0*pi)) EP_hf=(EP_hf+(TMath::TwoPi()));
      Psi1HFRaw[c]->Fill(EP_hf);
      //First order positive hf
      EP_hfp=(1./1.)*TMath::ATan2(Y_hfp,X_hfp);
      if(EP_hfp > pi) EP_hfp=(EP_hfp-(TMath::TwoPi()));
      if(EP_hfp < (-1.0*pi)) EP_hfp=(EP_hfp+(TMath::TwoPi()));
      Psi1HFPRaw[c]->Fill(EP_hfp);
      //First order negative hf
      EP_hfn=(1./1.)*TMath::ATan2(Y_hfn,X_hfn);
      if(EP_hfn > pi) EP_hfn=(EP_hfn-(TMath::TwoPi()));
      if(EP_hfn < (-1.0*pi)) EP_hfn=(EP_hfn+(TMath::TwoPi()));
      Psi1HFNRaw[c]->Fill(EP_hfn);
      //Second order positive hf
      EP_hf2p=(1./2.)*TMath::ATan2(Y_hf2p,X_hf2p);
      if(EP_hf2p > (pi/2)) EP_hf2p=(EP_hf2p-(pi));
      if(EP_hf2p < (-1.0*(pi/2))) EP_hf2p=(EP_hf2p+(pi));
      Psi2HFPRaw[c]->Fill(EP_hf2p);
      //Second order negative hf
      EP_hf2n=(1./2.)*TMath::ATan2(Y_hf2n,X_hf2n);
      if(EP_hf2n > (pi/2)) EP_hf2n=(EP_hf2n-(pi));
      if(EP_hf2n < (-1.0*(pi/2))) EP_hf2n=(EP_hf2n+(pi));
      Psi2HFNRaw[c]->Fill(EP_hf2n);
      //Second order tracker
      EP_tr2=(1./2.)*TMath::ATan2(Y_tr2,X_tr2);
      if(EP_tr2 > (pi/2)) EP_tr2=(EP_tr2-(pi));
      if(EP_tr2 < (-1.0*(pi/2))) EP_tr2=(EP_tr2+(pi));
      Psi2TRRaw[c]->Fill(EP_tr2);


      //////////////////////////////////
      ///Angular Corrections To EP's///
      //////////////////////////////////
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
              Psi1Corrs[c]->Fill(k-1,fabs((2./k)*((-avsinhf[c][k-1]*TMath::Cos(k*EP_hf))+(avcoshf[c][k-1]*TMath::Sin(k*EP_hf)))));

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
              Psi2Corrs[c]->Fill(k-1,fabs((1./k)*((-avsintr2[c][k-1]*TMath::Cos(k*2*EP_tr2))+(avcostr2[c][k-1]*TMath::Sin(k*2*EP_tr2)))));
            }//end of loop over correction orders

          //Combined HF
          EP_hffinal=EP_hf+AngularCorrectionHF;
          if(EP_hffinal > pi) EP_hffinal=(EP_hffinal-(TMath::TwoPi()));
          if(EP_hffinal < (-1.0*pi)) EP_hffinal=(EP_hffinal+(TMath::TwoPi()));
          Psi1HFFinal[c]->Fill(EP_hffinal);
          //First Order Positive HF
          EP_hfpfinal=EP_hfp+AngularCorrectionHFP;
          if(EP_hfpfinal > pi) EP_hfpfinal=(EP_hfpfinal-(TMath::TwoPi()));
          if(EP_hfpfinal < (-1.0*pi)) EP_hfpfinal=(EP_hfpfinal+(TMath::TwoPi()));
          Psi1HFPFinal[c]->Fill(EP_hfpfinal);

          //First Order Negative HF
          EP_hfnfinal=EP_hfn+AngularCorrectionHFN;
          if(EP_hfnfinal > pi) EP_hfnfinal=(EP_hfnfinal-(TMath::TwoPi()));
          if(EP_hfnfinal < (-1.0*pi)) EP_hfnfinal=(EP_hfnfinal+(TMath::TwoPi()));
          Psi1HFNFinal[c]->Fill(EP_hfnfinal);
          //Second Order Positive HF
          EP_hf2pfinal=EP_hf2p+AngularCorrectionHF2P;
          if(EP_hf2pfinal > (pi/2)) EP_hf2pfinal=(EP_hf2pfinal-(pi));
          if(EP_hf2pfinal < (-1.0*(pi/2))) EP_hf2pfinal=(EP_hf2pfinal+(pi));
          Psi2HFPFinal[c]->Fill(EP_hf2pfinal);
          //Second Order Negative HF
          EP_hf2nfinal=EP_hf2n+AngularCorrectionHF2N;
          if(EP_hf2nfinal > (pi/2)) EP_hf2nfinal=(EP_hf2nfinal-(pi));
          if(EP_hf2nfinal < (-1.0*(pi/2))) EP_hf2nfinal=(EP_hf2nfinal+(pi));
          Psi2HFNFinal[c]->Fill(EP_hf2nfinal);
          //Second Order Tracker
          EP_tr2final=EP_tr2+AngularCorrectionTR2;
          if(EP_tr2final > (pi/2)) EP_tr2final=(EP_tr2final-(pi));
          if(EP_tr2final < (-1.0*(pi/2))) EP_tr2final=(EP_tr2final+(pi));
          Psi2TRFinal[c]->Fill(EP_tr2final);

          //Now loop over tracks to get V1
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
              if(fabs(eta)<=1.5)
                {
                  PTCenters[c]->Fill(pT,pT);
                  if(eta>0)
                    {
                      V1Eta[c]->Fill(eta,TMath::Cos(phi+EP_hffinal-(2.0*EP_tr2final))/FinalResNeg[c]);
                      V1Pt[c]->Fill(pT,TMath::Cos(phi+EP_hffinal-(2.0*EP_tr2final))/FinalResNeg[c]);
                    }//postive eta gate
                  else if(eta<0)
                    {
                      V1Eta[c]->Fill(eta,TMath::Cos(phi+EP_hffinal-(2.0*EP_tr2final))/FinalResPos[c]);
                      V1Pt[c]->Fill(pT,TMath::Cos(phi+EP_hffinal-(2.0*EP_tr2final))/FinalResPos[c]);
                    }//negative eta gate
                }//eta less than 1.5 gate
            }//end of loop over tracks

        }//end of loop over centralities
    }//End of loop over events
  //  myFile->Write();
}//End of EPplotting function

}//end of ep plotting


void FillAngularCorrections(){

}//End of Angular Corrections Function

+EOF
