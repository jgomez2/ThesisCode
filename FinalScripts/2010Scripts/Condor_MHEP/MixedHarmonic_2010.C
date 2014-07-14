#include<TH1F>
#include<TProfile>
#include<iostream>
#include<iomanip>
#include"TFile.h"
#include"TTree.h"
#include"TLeaf.h"
#include"TChain.h"

void Initialize();
void AngularCorrections();
void Resolutions();
void EPPlotting();

//Chains
TChain* chain; //Calo Tower Chain
TChain* chain1; //hiGoodTightMergedTracks


///File and Directories in the File
TFile *myFile;
TDirectory *myPlots;//Top Directory
//AngularCorrectionPlots
TDirectory *angularcorrectionplots;
TDirectory *angcorr1;
TDirectory *angcorr2;
//Event Plane Plots
TDirectory *epangles;
TDirectory *ep1;
TDirectory *ep2;
//Resolution Plots
TDirectory *resolutions;
TDirectory *res1;
TDirectory *res2;
//Flow Plots
TDirectory *v1plots;


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
NumberOfEvents=100000;
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
/////////////////////////////////////
//////Angular Correction Plots///////
/////////////////////////////////////

//Combined HF
TProfile *Coshf[nCent];
TProfile *Sinhf[nCent];
//Pos HF
TProfile *Coshfp[nCent];
TProfile *Sinhfp[nCent];
//Neg HF
TProfile *Coshfn[nCent];
TProfile *Sinhfn[nCent];
//Psi2 Pos HF
TProfile *Coshf2p[nCent];
TProfile *Sinhf2p[nCent];
//Psi2 Neg HF
TProfile *Coshf2n[nCent];
TProfile *Sinhf2n[nCent];
//Psi2 Mid Tracker
TProfile *Costr2[nCent];
TProfile *Sintr2[nCent];


/////////////////////////
////Event Plane Plots////
/////////////////////////

//First order Combined HF
TH1F *Psi1HFRaw[nCent];
TH1F *Psi1HFFinal[nCent];
//First order Positive HF
TH1F *Psi1HFPRaw[nCent];
TH1F *Psi1HFPFinal[nCent];
//First order Negative HF
TH1F *Psi1HFNRaw[nCent];
TH1F *Psi1HFNFinal[nCent];
//Second order Positive HF
TH1F *Psi2HFPRaw[nCent];
TH1F *Psi2HFPFinal[nCent];
//Second order Negative HF
TH1F *Psi2HFNRaw[nCent];
TH1F *Psi2HFNFinal[nCent];
//Second Mid Tracker
TH1F *Psi2TRRaw[nCent];
TH1F *Psi2TRFinal[nCent];

/////////////////////////
///Average Corrections///
/////////////////////////
TProfile *Psi1Corrs[nCent];
TProfile *Psi2Corrs[nCent];

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

/////////////////////////////
//// Directed Flow Plots/////
////////////////////////////
TProfile *V1Eta[nCent];
TProfile *V1Pt[nCent];


//PTCenter Plots
TProfile *PTCenters[nCent];

Int_t MixedHarmonic_2010(){
  Initialize();
  AngularCorrections();
  Resolutions();
  EPPlotting();
  myFile->Write();
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
  //AngularCorrectionPlots
  angularcorrectionplots= myPlots->mkdir("AngularCorrections");
  angcorr1=angularcorrectionplots->mkdir("FirstOrderCorrections");
  angcorr2=angularcorrectionplots->mkdir("SecondOrderCorrections");
  //Event Plane Plots
  epangles=myPlots->mkdir("EventPlanes");
  ep1=epangles->mkdir("FirstOrderEventPlanes");
  ep2=epangles->mkdir("SecondOrderEventPlanes");
  //Resolution Plots
  resolutions=myPlots->mkdir("Resolutions");
  res1=resolutions->mkdir("FirstOrderResolutionCorrections");
  res2=resolutions->mkdir("SecondOrderResolutionCorrections");
  //Flow Plots
  v1plots=myPlots->mkdir("V1Results");


  /////////////////////////////////////////////
  ///Declaration of Titles for the Plots///////
  /////////////////////////////////////////////

  ////////////////////////////
  //Angular Correction Plots//
  ////////////////////////////

  //////First Order//////
  char coshfname[128],coshftitle[128];//combined HF cosine corrections
  char sinhfname[128],sinhftitle[128];//combined HF sine corrections

  char coshfpname[128],coshfptitle[128];//positive HF cosine corrections
  char sinhfpname[128],sinhfptitle[128];//positive HF sine corrections

  char coshfnname[128],coshfntitle[128];//negative HF cosine corrections
  char sinhfnname[128],sinhfntitle[128];//negative HF sine corrections

  //////Second Order//////
  char coshf2pname[128],coshf2ptitle[128];//positive HF cosine corrections
  char sinhf2pname[128],sinhf2ptitle[128];//positive HF sine corrections

  char coshf2nname[128],coshf2ntitle[128];//negative HF cosine corrections
  char sinhf2nname[128],sinhf2ntitle[128];//negative HF sine corrections

  char costr2name[128],costr2title[128];//tracker cosine corrections
  char sintr2name[128],sintr2title[128];//tracker sine corrections

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
      /////////////////////////////////
      ////Angular Correction Plots////
      ////////////////////////////////

      ///First Order///
      angcorr1->cd();

      //Combined HF
      sprintf(coshfname,"CosValues_CombinedHF_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(coshftitle,"CosValues_CombinedHF_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      Coshf[i]=new TProfile(coshfname,coshftitle,jMax,0,jMax);
      Coshf[i]->GetYaxis()->SetTitle("<cos(Xbin*#Psi)>");

      sprintf(sinhfname,"SinValues_CombinedHF_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(sinhftitle,"SinValues_CombinedHF_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      Sinhf[i]=new TProfile(sinhfname,sinhftitle,jMax,0,jMax);
      Sinhf[i]->GetYaxis()->SetTitle("<sin(Xbin*#Psi)>");

      //Positive HF
      sprintf(coshfpname,"CosValues_PositiveHF_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(coshfptitle,"CosValues_PositiveHF_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      Coshfp[i]=new TProfile(coshfpname,coshfptitle,jMax,0,jMax);
      Coshfp[i]->GetYaxis()->SetTitle("<cos(Xbin*#Psi)>");

      sprintf(sinhfpname,"SinValues_PositiveHF_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(sinhfptitle,"SinValues_PositiveHF_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      Sinhfp[i]=new TProfile(sinhfpname,sinhfptitle,jMax,0,jMax);
      Sinhfp[i]->GetYaxis()->SetTitle("<sin(Xbin*#Psi)>");

      //Negative HF
      sprintf(coshfnname,"CosValues_NegativeHF_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(coshfntitle,"CosValues_NegativeHF_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      Coshfn[i]=new TProfile(coshfnname,coshfntitle,jMax,0,jMax);
      Coshfn[i]->GetYaxis()->SetTitle("<cos(Xbin*#Psi)>");

      sprintf(sinhfnname,"SinValues_NegativeHF_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(sinhfntitle,"SinValues_NegativeHF_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      Sinhfn[i]=new TProfile(sinhfnname,sinhfntitle,jMax,0,jMax);
      Sinhfn[i]->GetYaxis()->SetTitle("<sin(Xbin*#Psi)>");

      ////Second Order////
      angcorr2->cd();

      //Positive HF
      sprintf(coshf2pname,"CosValues_PositiveHF2_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(coshf2ptitle,"CosValues_PositiveHF2_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      Coshf2p[i]=new TProfile(coshf2pname,coshf2ptitle,jMax,0,jMax);
      Coshf2p[i]->GetYaxis()->SetTitle("<cos(Xbin*#Psi)>");

      sprintf(sinhf2pname,"SinValues_PositiveHF2_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(sinhf2ptitle,"SinValues_PositiveHF2_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      Sinhf2p[i]=new TProfile(sinhf2pname,sinhf2ptitle,jMax,0,jMax);
      Sinhf2p[i]->GetYaxis()->SetTitle("<sin(Xbin*#Psi)>");

      //Negative HF
      sprintf(coshf2nname,"CosValues_NegativeHF2_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(coshf2ntitle,"CosValues_NegativeHF2_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      Coshf2n[i]=new TProfile(coshf2nname,coshf2ntitle,jMax,0,jMax);
      Coshf2n[i]->GetYaxis()->SetTitle("<cos(Xbin*#Psi)>");

      sprintf(sinhf2nname,"SinValues_NegativeHF2_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(sinhf2ntitle,"SinValues_NegativeHF2_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      Sinhf2n[i]=new TProfile(sinhf2nname,sinhf2ntitle,jMax,0,jMax);
      Sinhf2n[i]->GetYaxis()->SetTitle("<sin(Xbin*#Psi)>");

      //Tracker
      sprintf(costr2name,"CosValues_TR2_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(costr2title,"CosValues_TR2_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      Costr2[i]=new TProfile(costr2name,costr2title,jMax,0,jMax);
      Costr2[i]->GetYaxis()->SetTitle("<cos(Xbin*#Psi)>");

      sprintf(sintr2name,"SinValues_TR2_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(sintr2title,"SinValues_TR2_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      Sintr2[i]=new TProfile(sintr2name,sintr2title,jMax,0,jMax);
      Sintr2[i]->GetYaxis()->SetTitle("<sin(Xbin*#Psi)>");


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

void AngularCorrections(){
  for (Int_t i=0;i<NumberOfEvents;i++)
    {
      if ( !(i%10000) ) cout << " 1st round, event # " << i << " / " << NumberOfEvents << endl;

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
      //First order positive hf
      X_hfp=0.;
      Y_hfp=0.;
      EP_hfp=0.;
      //First order negative hf
      X_hfn=0.;
      Y_hfn=0.;
      EP_hfn=0.;
      //Second order positive hf
      X_hf2p=0.;
      Y_hf2p=0.;
      EP_hf2p=0.;
      //Second order negative hf
      X_hf2n=0.;
      Y_hf2n=0.;
      EP_hf2n=0.;
      //Second order tracker
      X_tr2=0.;
      Y_tr2=0.;
      EP_tr2=0.;
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


      /////////////////////////////////
      ///Store Info In AngCorr Plots///
      /////////////////////////////////
      for (Int_t c=0;c<nCent;c++)
        {
          if ( (Centrality*2.5) > centhi[c] ) continue;
          if ( (Centrality*2.5) < centlo[c] ) continue;
          for (int k=1;k<(jMax+1);k++)
            {
              //Combined HF
              Coshf[c]->Fill(k-1,TMath::Cos(k*EP_hf));
              Sinhf[c]->Fill(k-1,TMath::Sin(k*EP_hf));
              //First Order Pos HF
              Coshfp[c]->Fill(k-1,TMath::Cos(k*EP_hfp));
              Sinhfp[c]->Fill(k-1,TMath::Sin(k*EP_hfp));
              //First Order Neg HF
              Coshfn[c]->Fill(k-1,TMath::Cos(k*EP_hfn));
              Sinhfn[c]->Fill(k-1,TMath::Sin(k*EP_hfn));
              //Psi2 Pos HF
              Coshf2p[c]->Fill(k-1,TMath::Cos(k*2*EP_hf2p));
              Sinhf2p[c]->Fill(k-1,TMath::Sin(k*2*EP_hf2p));
              //Psi2 Neg HF
              Coshf2n[c]->Fill(k-1,TMath::Cos(k*2*EP_hf2n));
              Sinhf2n[c]->Fill(k-1,TMath::Sin(k*2*EP_hf2n));
              //Psi2 Mid Tracker
              Costr2[c]->Fill(k-1,TMath::Cos(k*2*EP_tr2));
              Sintr2[c]->Fill(k-1,TMath::Sin(k*2*EP_tr2));
            }//End Of loop over K correction orders
        }//End of Loop over centrality classes
    }//End of loop over events

  ///////////////////////////////////////////////////
  //Grab the Angular Corrections for easy use later//
  ///////////////////////////////////////////////////
  for (Int_t c=0;c<nCent;c++)
    {
      for (int k=1;k<(jMax+1);k++)
        {
          //Combined HF variables
          avsinhf[c][k-1]=Sinhf[c]->GetBinContent(k);
          avcoshf[c][k-1]=Coshf[c]->GetBinContent(k);
          //First Order Pos HF variables
          avsinhfp[c][k-1]=Sinhfp[c]->GetBinContent(k);
          avcoshfp[c][k-1]=Coshfp[c]->GetBinContent(k);
          //First Order Neg HF variables
          avsinhfn[c][k-1]=Sinhfn[c]->GetBinContent(k);
          avcoshfn[c][k-1]=Coshfn[c]->GetBinContent(k);
          //Psi2 Pos HF variables
          avsinhf2p[c][k-1]=Sinhf2p[c]->GetBinContent(k);
          avcoshf2p[c][k-1]=Coshf2p[c]->GetBinContent(k);
          //Psi2 Neg HF variables
          avsinhf2n[c][k-1]=Sinhf2n[c]->GetBinContent(k);
          avcoshf2n[c][k-1]=Coshf2n[c]->GetBinContent(k);
          //Psi2 Tracker variables
          avsintr2[c][k-1]=Sintr2[c]->GetBinContent(k);
          avcostr2[c][k-1]=Costr2[c]->GetBinContent(k);

        }//end of loop over the correction orders
    }//End of Loop over Centralities
}//end of Angular Corrections Function

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
      Res2HFM[c]=TMath::Sqrt(((HFPMinusHFM->GetBinContent(c+1))*(HFPMinusTracks->GetBinContent(c+1)))/(HFMMinusTracks->GetBinContent(c+1)));
      Res2HFP[c]=TMath::Sqrt(((HFPMinusHFM->GetBinContent(c+1))*(HFMMinusTracks->GetBinContent(c+1)))/(HFPMinusTracks->GetBinContent(c+1)));

      //The same +/- convention used here
      FinalResPos[c]=(TMath::Sqrt(FirstOrderPositive->GetBinContent(c+1)))*(Res2HFP[c]);
      FinalPositiveResolution->SetBinContent(c+1,FinalResPos[c]);
      FinalResNeg[c]=(TMath::Sqrt(FirstOrderNegative->GetBinContent(c+1)))*(Res2HFM[c]);
      FinalNegativeResolution->SetBinContent(c+1,FinalResNeg[c]);
    }//end of loop over centralities
}//end of Resolutions Function

void EPPlotting(){
  for (Int_t i=0;i<NumberOfEvents;i++)
    {
      if ( !(i%10000) ) cout << " 3rd round, event # " << i << " / " << NumberOfEvents << endl;

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


