#!/bin/sh
 

b=$(sed -ne "${1}{p;q;}" files.txt)

cat > TRV1EPPlotting_${1}.C << +EOF

#include<TH1F>
#include<TProfile>
#include<iostream>
#include<iomanip>
#include"TFile.h"
#include"TTree.h"
#include"TLeaf.h"
#include"TChain.h"
//Functions in this macro///
void Initialize();
void FillPTStats();
void FillFlowVectors();
void FillAngularCorrections();
void FlowAnalysis();
////////////////////////////


//Files and chains
TChain* chain2;//= new TChain("hiGoodTightMergedTracksTree");


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
//NumberOfEvents=100;
//NumberOfEvents=50000;
//NumberOfEvents=100000;
//NumberOfEvents=5000000;
//  NumberOfEvents = chain->GetEntries();

const Int_t nCent=5;//Number of Centrality classes

///Looping Variables
Int_t Centrality=0; //This will be the centrality variable later
Int_t NumberOfHits=0;//This will be for both tracks and Hits
Float_t pT=0.;
Float_t phi=0.;
Float_t eta=0.;



Float_t centlo[nCent];
Float_t centhi[nCent];
centlo[0]=0;  centhi[0]=10;
centlo[1]=10;  centhi[1]=20;
centlo[2]=20;  centhi[2]=30;
centlo[3]=30;  centhi[3]=40;
centlo[4]=40;  centhi[4]=50;

//Create the output ROOT file
TFile *myFile;

//PT Bin Centers
TProfile *PTCenters[nCent];

//EP Resolution Plots

//For Resolution of V1 Even
TProfile *TRPMinusTRM[nCent];
TProfile *TRMMinusTRC[nCent];
TProfile *TRPMinusTRC[nCent];

//For Resolution of V1 Odd
TProfile *TRPMinusTRMOdd[nCent];
TProfile *TRMMinusTRCOdd[nCent];
TProfile *TRPMinusTRCOdd[nCent];


//Make Subdirectories for what will follow
TDirectory *myPlots;//the top level
TDirectory *epangles;//where i will store the ep angles
TDirectory *outerep;
TDirectory *posep;
TDirectory *negep;
TDirectory *midep;

TDirectory *resolutions;//top level for resolutions
TDirectory *psioneoddres;//where i will store standard EP resolution plots
TDirectory *psioneevenres;//where i will store psi1(even)

TDirectory *v1plots;//where i will store the v1 plots
TDirectory *v1etaoddplots;//v1(eta) [odd] plots
TDirectory *v1etaevenplots; //v1(eta)[even] plots
TDirectory *v1ptevenplots; //v1(pT)[even] plots
TDirectory *v1ptoddplots;//v1(pT)[odd] plots

TDirectory *flowvecplots;

//TProfiles to save <pT> and <pT^2> info ....All this is for Ollitrault weights
Float_t ptavwhole[nCent]={0.},pt2avwhole[nCent]={0.};
Float_t ptavpos[nCent]={0.},pt2avpos[nCent]={0.};
Float_t ptavneg[nCent]={0.},pt2avneg[nCent]={0.};
Float_t ptavmid[nCent]={0.},pt2avmid[nCent]={0.};

//Looping Variables
//v1 even
Float_t X_wholetracker[nCent]={0.},Y_wholetracker[nCent]={0.},
  X_postracker[nCent]={0.},Y_postracker[nCent]={0.},
  X_negtracker[nCent]={0.},Y_negtracker[nCent]={0.},
  X_midtracker[nCent]={0.},Y_midtracker[nCent]={0.};

//v1 odd
Float_t X_wholeoddtracker[nCent]={0.},Y_wholeoddtracker[nCent]={0.},
  X_posoddtracker[nCent]={0.},Y_posoddtracker[nCent]={0.},
  X_negoddtracker[nCent]={0.},Y_negoddtracker[nCent]={0.},
  X_midoddtracker[nCent]={0.},Y_midoddtracker[nCent]={0.};



//////////////////////////////////////
// The following variables and plots
// are for the AngularCorrections
// function
///////////////////////////////////////


//These Will store the angular correction factors
//v1 even
//Whole Tracker
Float_t CosineWholeTracker[nCent][jMax],SineWholeTracker[nCent][jMax];

//Pos Tracker
Float_t CosinePosTracker[nCent][jMax],SinePosTracker[nCent][jMax];

//Neg Tracker
Float_t CosineNegTracker[nCent][jMax],SineNegTracker[nCent][jMax];

//Mid Tracker
Float_t CosineMidTracker[nCent][jMax],SineMidTracker[nCent][jMax];

//v1 odd
//Whole Tracker
Float_t CosineWholeOddTracker[nCent][jMax],SineWholeOddTracker[nCent][jMax];

//Pos Tracker
Float_t CosinePosOddTracker[nCent][jMax],SinePosOddTracker[nCent][jMax];

//Neg Tracker
Float_t CosineNegOddTracker[nCent][jMax],SineNegOddTracker[nCent][jMax];

//Mid Tracker
Float_t CosineMidOddTracker[nCent][jMax],SineMidOddTracker[nCent][jMax];

//EP Plots
//Even
   //Whole Tracker
TH1F *PsiEvenRaw[nCent];
TH1F *PsiEvenFirst[nCent];
TH1F *PsiEvenFinal[nCent];
   //Pos Tracker
TH1F *PsiPEvenRaw[nCent];
TH1F *PsiPEvenFirst[nCent];
TH1F *PsiPEvenFinal[nCent];
   //Neg Tracker
TH1F *PsiNEvenRaw[nCent];
TH1F *PsiNEvenFirst[nCent];
TH1F *PsiNEvenFinal[nCent];
   //Mid Tracker
TH1F *PsiMEvenRaw[nCent];
TH1F *PsiMEvenFirst[nCent];
TH1F *PsiMEvenFinal[nCent];

//Odd
  //Whole Tracker 
TH1F *PsiOddRaw[nCent];
TH1F *PsiOddFirst[nCent];
TH1F *PsiOddFinal[nCent];
   //Pos Tracker
TH1F *PsiPOddRaw[nCent];
TH1F *PsiPOddFirst[nCent];
TH1F *PsiPOddFinal[nCent];
   //Neg Tracker
TH1F *PsiNOddRaw[nCent];
TH1F *PsiNOddFirst[nCent];
TH1F *PsiNOddFinal[nCent];
   //Mid Tracker
TH1F *PsiMOddRaw[nCent];
TH1F *PsiMOddFirst[nCent];
TH1F *PsiMOddFinal[nCent];

//Flow vector plot
TH1F *Xvector[nCent];
TH1F *Yvector[nCent];
/////////////////////////////////////////
/// Variables that are used in the //////
// Flow Analysis function////////////////
/////////////////////////////////////////

//RAW EP's
Float_t EPwholetracker=0.,EPpostracker=0.,EPnegtracker=0.,EPmidtracker=0.,
  EPwholeoddtracker=0.,EPposoddtracker=0.,EPnegoddtracker=0.,EPmidoddtracker=0.;

//Corrected EP's
Float_t EPcorrwholetracker=0.,EPcorrpostracker=0.,EPcorrnegtracker=0.,EPcorrmidtracker=0.,
  EPcorrwholeoddtracker=0.,EPcorrposoddtracker=0.,EPcorrnegoddtracker=0.,EPcorrmidoddtracker=0.;

//v1 even stuff
Float_t AngularCorrectionWholeTracker=0.,EPfinalwholetracker=0.,
  AngularCorrectionPosTracker=0.,EPfinalpostracker=0.,
  AngularCorrectionNegTracker=0.,EPfinalnegtracker=0.,
  AngularCorrectionMidTracker=0.,EPfinalmidtracker=0.;


//v1 odd

Float_t AngularCorrectionWholeOddTracker=0.,EPfinalwholeoddtracker=0.,
  AngularCorrectionPosOddTracker=0.,EPfinalposoddtracker=0.,
  AngularCorrectionNegOddTracker=0.,EPfinalnegoddtracker=0.,
  AngularCorrectionMidOddTracker=0.,EPfinalmidoddtracker=0.;


//v1 even
Float_t Xcorr_wholetracker=0.,Ycorr_wholetracker=0.,
  Xcorr_postracker=0.,Ycorr_postracker=0.,
  Xcorr_negtracker=0.,Ycorr_negtracker=0.,
  Xcorr_midtracker=0.,Ycorr_midtracker=0.;

//v1 odd
Float_t Xcorr_wholeoddtracker=0.,Ycorr_wholeoddtracker=0.,
  Xcorr_posoddtracker=0.,Ycorr_posoddtracker=0.,
  Xcorr_negoddtracker=0.,Ycorr_negoddtracker=0.,
  Xcorr_midoddtracker=0.,Ycorr_midoddtracker=0.;

/////////////////
///FLOW PLOTS////
////////////////
TProfile *V1EtaOdd[nCent];
TProfile *V1EtaEven[nCent];
TProfile *V1PtEven[nCent];
TProfile *V1PtOdd[nCent];


//Permanent Variables
//v1 even
Float_t Xav_wholetracker[nCent]={0.},Yav_wholetracker[nCent]={0.},
  Xav_postracker[nCent]={0.},Yav_postracker[nCent]={0.},
  Xav_negtracker[nCent]={0.},Yav_negtracker[nCent]={0.},
  Xav_midtracker[nCent]={0.},Yav_midtracker[nCent]={0.};

//v1 odd
Float_t Xav_wholeoddtracker[nCent]={0.},Yav_wholeoddtracker[nCent]={0.},
  Xav_posoddtracker[nCent]={0.},Yav_posoddtracker[nCent]={0.},
  Xav_negoddtracker[nCent]={0.},Yav_negoddtracker[nCent]={0.},
  Xav_midoddtracker[nCent]={0.},Yav_midoddtracker[nCent]={0.};

//Standard Deviations
//v1 even
Float_t Xstdev_wholetracker[nCent]={0.},Ystdev_wholetracker[nCent]={0.},
  Xstdev_postracker[nCent]={0.},Ystdev_postracker[nCent]={0.},
  Xstdev_negtracker[nCent]={0.},Ystdev_negtracker[nCent]={0.},
  Xstdev_midtracker[nCent]={0.},Ystdev_midtracker[nCent]={0.};

//v1 odd
Float_t Xstdev_wholeoddtracker[nCent]={0.},Ystdev_wholeoddtracker[nCent]={0.},
  Xstdev_posoddtracker[nCent]={0.},Ystdev_posoddtracker[nCent]={0.},
  Xstdev_negoddtracker[nCent]={0.},Ystdev_negoddtracker[nCent]={0.},
  Xstdev_midoddtracker[nCent]={0.},Ystdev_midoddtracker[nCent]={0.};

///////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////
/////////////////// END OF GLOBAL VARIABLES ///////////////////////
///////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////

//Running the Macro
Int_t TRV1EPPlotting_${1}(){//put functions in here
  Initialize();
  FillPTStats();
  FillFlowVectors();
  FillAngularCorrections();
  FlowAnalysis();
  myFile->Write();
  return 0;
}

void Initialize(){

  float eta_bin_small[13]={-0.6,-0.5,-0.4,-0.3,-0.2,-0.1,0.0,0.1,0.2,0.3,0.4,0.5,0.6};

  double pt_bin[17]={0.4,0.6,0.8,1.0,1.2,1.4,1.6,1.8,2.0,2.4,2.8,3.2,3.6,4.5,6.5,9.5,12};

  chain2= new TChain("hiGoodTightMergedTracksTree");

  //Tracks Tree
  chain2->Add("/hadoop/store/user/jgomez2/ForwardTrees/2010/PanicTime/$b");

    NumberOfEvents= chain2->GetEntries();
  //Create the output ROOT file
  myFile = new TFile("TREP_EPPlotting_${1}.root","recreate");

  //Make Subdirectories for what will follow
  myPlots = myFile->mkdir("Plots");
  myPlots->cd();

  flowvecplots=myPlots->mkdir("FlowVectors");


  //Directory for the EP angles
  epangles = myPlots->mkdir("EventPlanes");
  //Outer Tracker
  outerep = epangles->mkdir("WholeTracker");
  //Pos Tracker
  posep = epangles->mkdir("PositiveTracker");
  //Negative Tracker
  negep = epangles->mkdir("NegativeTracker");
  //Mid Tracker
  midep = epangles->mkdir("CentralTracker");

  //Directory for Resolution Plots
  resolutions = myPlots->mkdir("EventPlaneResolutions");
  psioneevenres = resolutions->mkdir("PsiOneEvenResolution");
  psioneoddres = resolutions->mkdir("PsiOneOddResolution");


  //Directory For Final v1 plots
  v1plots = myPlots->mkdir("V1Results");
  v1etaoddplots = v1plots->mkdir("V1EtaOdd");
  v1etaevenplots = v1plots->mkdir("V1EtaEven");
  v1ptevenplots = v1plots->mkdir("V1pTEven");
  v1ptoddplots = v1plots->mkdir("V1pTOdd");




  char ptcentname[128];
  char ptcenttitle[128];

  char res4name[128],res4title[128];
  char res5name[128],res5title[128];
  char res6name[128],res6title[128];

  //Psi1 Raw, Psi1 Final
  //Psi1(even)
  //Whole Tracker
  char epevenrawname[128],epevenrawtitle[128];
  char epevenfirstname[128],epevenfirsttitle[128];
  char epevenfinalname[128],epevenfinaltitle[128];
  //Pos Tracker
  char pevenrawname[128],pevenrawtitle[128];
  char pevenfirstname[128],pevenfirsttitle[128];
  char pevenfinalname[128],pevenfinaltitle[128];
  //Neg Tracker
  char nevenrawname[128],nevenrawtitle[128];
  char nevenfirstname[128],nevenfirsttitle[128];
  char nevenfinalname[128],nevenfinaltitle[128];
  //Mid Tracker
  char mevenrawname[128],mevenrawtitle[128];
  char mevenfirstname[128],mevenfirsttitle[128];
  char mevenfinalname[128],mevenfinaltitle[128];

  //Psi1(odd)
  //Whole Tracker
  char epoddrawname[128],epoddrawtitle[128];
  char epoddfirstname[128],epoddfirsttitle[128];
  char epoddfinalname[128],epoddfinaltitle[128];
  //Pos Tracker
  char poddrawname[128],poddrawtitle[128];
  char poddfirstname[128],poddfirsttitle[128];
  char poddfinalname[128],poddfinaltitle[128];
  //Neg Tracker
  char noddrawname[128],noddrawtitle[128];
  char noddfirstname[128],noddfirsttitle[128];
  char noddfinalname[128],noddfinaltitle[128];
  //Mid Tracker
  char moddrawname[128],moddrawtitle[128];
  char moddfirstname[128],moddfirsttitle[128];
  char moddfinalname[128],moddfinaltitle[128];


  //V1 Plots
  char v1etaoddname[128],v1etaoddtitle[128];
  char v1etaevenname[128],v1etaeventitle[128];
  char v1ptoddname[128],v1ptoddtitle[128];
  char v1ptevenname[128],v1pteventitle[128];


  //V1 odd resolutions
  char v1oddres1name[128],v1oddres1title[128];
  char v1oddres2name[128],v1oddres2title[128];
  char v1oddres3name[128],v1oddres3title[128];

  char xvecname[128],xvectitle[128];
  char yvecname[128],yvectitle[128];

  for (int i=0;i<nCent;i++)
    {
      //V1 odd eta
      v1etaoddplots->cd();
      sprintf(v1etaoddname,"V1EtaOdd_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(v1etaoddtitle,"v_{1}^{odd}(#eta) for %1.0lf-%1.0lf %%",centlo[i],centhi[i]);
      V1EtaOdd[i]= new TProfile(v1etaoddname,v1etaoddtitle,12,eta_bin_small);

      //v1 even eta
      v1etaevenplots->cd();
      sprintf(v1etaevenname,"V1EtaEven_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(v1etaeventitle,"v_{1}^{even}(#eta) for %1.0lf-%1.0lf %%",centlo[i],centhi[i]);
      V1EtaEven[i]= new TProfile(v1etaevenname,v1etaeventitle,12,eta_bin_small);

      //v1 pt even
      v1ptevenplots->cd();
      sprintf(v1ptevenname,"V1PtEven_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(v1pteventitle,"v_{1}^{even}(p_{T}) for %1.0lf-%1.0lf %%",centlo[i],centhi[i]);
      V1PtEven[i]= new TProfile(v1ptevenname,v1pteventitle,16,pt_bin);


      //v1 pt odd
      v1ptoddplots->cd();
      sprintf(v1ptoddname,"V1PtOdd_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(v1ptoddtitle,"v_{1}^{odd}(p_{T}) for %1.0lf-%1.0lf %%",centlo[i],centhi[i]);
      V1PtOdd[i]= new TProfile(v1ptoddname,v1ptoddtitle,16,pt_bin);

      v1plots->cd();
      sprintf(ptcentname,"pTcenter_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(ptcenttitle,"Bin Center for %1.0lf-%1.0lf %%",centlo[i],centhi[i]);
      PTCenters[i]= new TProfile(ptcentname,ptcenttitle,16,pt_bin); //or can make a TH1f and fill a specific range
/////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////
      //Event Plane Plots
      outerep->cd();
      //Psi1Even
      //Whole Tracker
      //Raw
      sprintf(epevenrawname,"Psi1EvenRaw_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(epevenrawtitle,"#Psi_{1}^{even} Raw %1.0lfto%1.0lf",centlo[i],centhi[i]);
      PsiEvenRaw[i] = new TH1F(epevenrawname,epevenrawtitle,100,-TMath::Pi()-.392699,TMath::Pi()+.392699);
      PsiEvenRaw[i]->GetXaxis()->SetTitle("EP Angle (radians)");

      //First
      sprintf(epevenfirstname,"Psi1EvenFirst_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(epevenfirsttitle,"#Psi_{1}^{even} First %1.0lfto%1.0lf",centlo[i],centhi[i]);
      PsiEvenFirst[i] = new TH1F(epevenfirstname,epevenfirsttitle,100,-TMath::Pi()-.392699,TMath::Pi()+.392699);
      PsiEvenFirst[i]->GetXaxis()->SetTitle("EP Angle (radians)");
      
      //Final
      sprintf(epevenfinalname,"Psi1EvenFinal_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(epevenfinaltitle,"#Psi_{1}^{even} Final %1.0lfto%1.0lf",centlo[i],centhi[i]);
      PsiEvenFinal[i] = new TH1F(epevenfinalname,epevenfinaltitle,100,-TMath::Pi()-.392699,TMath::Pi()+.392699);
      PsiEvenFinal[i]->GetXaxis()->SetTitle("EP Angle (radians)");


     //Pos Tracker
      posep->cd();
      //Raw
      sprintf(pevenrawname,"Psi1PEvenRaw_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(pevenrawtitle,"#Psi_{1}^{even}(TR^{+}) Raw %1.0lfto%1.0lf",centlo[i],centhi[i]);
      PsiPEvenRaw[i] = new TH1F(pevenrawname,pevenrawtitle,100,-TMath::Pi()-.392699,TMath::Pi()+.392699);
      PsiPEvenRaw[i]->GetXaxis()->SetTitle("EP Angle (radians)");
      //First
      sprintf(pevenfirstname,"Psi1PEvenFirst_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(pevenfirsttitle,"#Psi_{1}^{even}(TR^{+}) First %1.0lfto%1.0lf",centlo[i],centhi[i]);
      PsiPEvenFirst[i] = new TH1F(pevenfirstname,pevenfirsttitle,100,-TMath::Pi()-.392699,TMath::Pi()+.392699);
      PsiPEvenFirst[i]->GetXaxis()->SetTitle("EP Angle (radians)");

      //Final
      sprintf(pevenfinalname,"Psi1PEvenFinal_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(pevenfinaltitle,"#Psi_{1}^{even}(TR^{+}) Final %1.0lfto%1.0lf",centlo[i],centhi[i]);
      PsiPEvenFinal[i] = new TH1F(pevenfinalname,pevenfinaltitle,100,-TMath::Pi()-.392699,TMath::Pi()+.392699);
      PsiPEvenFinal[i]->GetXaxis()->SetTitle("EP Angle (radians)");

     //Neg Tracker
      negep->cd();
      //Raw
      sprintf(nevenrawname,"Psi1NEvenRaw_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(nevenrawtitle,"#Psi_{1}^{even}(TR^{-}) Raw %1.0lfto%1.0lf",centlo[i],centhi[i]);
      PsiNEvenRaw[i] = new TH1F(nevenrawname,nevenrawtitle,100,-TMath::Pi()-.392699,TMath::Pi()+.392699);
      PsiNEvenRaw[i]->GetXaxis()->SetTitle("EP Angle (radians)");
      //First
      sprintf(nevenfirstname,"Psi1NEvenFirst_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(nevenfirsttitle,"#Psi_{1}^{even}(TR^{-}) First %1.0lfto%1.0lf",centlo[i],centhi[i]);
      PsiNEvenFirst[i] = new TH1F(nevenfirstname,nevenfirsttitle,100,-TMath::Pi()-.392699,TMath::Pi()+.392699);
      PsiNEvenFirst[i]->GetXaxis()->SetTitle("EP Angle (radians)");
      //Final
      sprintf(nevenfinalname,"Psi1NEvenFinal_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(nevenfinaltitle,"#Psi_{1}^{even}(TR^{-}) Final %1.0lfto%1.0lf",centlo[i],centhi[i]);
      PsiNEvenFinal[i] = new TH1F(nevenfinalname,nevenfinaltitle,100,-TMath::Pi()-.392699,TMath::Pi()+.392699);
      PsiNEvenFinal[i]->GetXaxis()->SetTitle("EP Angle (radians)");

     //Mid Tracker
      midep->cd();
      //Raw
      sprintf(mevenrawname,"Psi1MEvenRaw_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(mevenrawtitle,"#Psi_{1}^{even}(TR^{mid}) Raw %1.0lfto%1.0lf",centlo[i],centhi[i]);
      PsiMEvenRaw[i] = new TH1F(mevenrawname,mevenrawtitle,100,-TMath::Pi()-.392699,TMath::Pi()+.392699);
      PsiMEvenRaw[i]->GetXaxis()->SetTitle("EP Angle (radians)");
      //First
      sprintf(mevenfirstname,"Psi1MEvenFirst_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(mevenfirsttitle,"#Psi_{1}^{even}(TR^{mid}) First %1.0lfto%1.0lf",centlo[i],centhi[i]);
      PsiMEvenFirst[i] = new TH1F(mevenfirstname,mevenfirsttitle,100,-TMath::Pi()-.392699,TMath::Pi()+.392699);
      PsiMEvenFirst[i]->GetXaxis()->SetTitle("EP Angle (radians)");
      //Final
      sprintf(mevenfinalname,"Psi1MEvenFinal_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(mevenfinaltitle,"#Psi_{1}^{even}(TR^{mid}) Final %1.0lfto%1.0lf",centlo[i],centhi[i]);
      PsiMEvenFinal[i] = new TH1F(mevenfinalname,mevenfinaltitle,100,-TMath::Pi()-.392699,TMath::Pi()+.392699);
      PsiMEvenFinal[i]->GetXaxis()->SetTitle("EP Angle (radians)");
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
      //Psi1Odd
      outerep->cd();
      //WholeTracker
      //Raw
      sprintf(epoddrawname,"Psi1OddRaw_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(epoddrawtitle,"#Psi_{1}^{odd} Raw %1.0lfto%1.0lf",centlo[i],centhi[i]);
      PsiOddRaw[i] = new TH1F(epoddrawname,epoddrawtitle,100,-TMath::Pi()-.392699,TMath::Pi()+.392699);
      PsiOddRaw[i]->GetXaxis()->SetTitle("EP Angle (radians)");
      //First
      sprintf(epoddfirstname,"Psi1OddFirst_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(epoddfirsttitle,"#Psi_{1}^{odd} First %1.0lfto%1.0lf",centlo[i],centhi[i]);
      PsiOddFirst[i] = new TH1F(epoddfirstname,epoddfirsttitle,100,-TMath::Pi()-.392699,TMath::Pi()+.392699);
      PsiOddFirst[i]->GetXaxis()->SetTitle("EP Angle (radians)");


      //Final
      sprintf(epoddfinalname,"Psi1OddFinal_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(epoddfinaltitle,"#Psi_{1}^{odd} Final %1.0lfto%1.0lf",centlo[i],centhi[i]);
      PsiOddFinal[i] = new TH1F(epoddfinalname,epoddfinaltitle,100,-TMath::Pi()-.392699,TMath::Pi()+.392699);
      PsiOddFinal[i]->GetXaxis()->SetTitle("EP Angle (radians)");

     //Pos Tracker
      posep->cd();
      //Raw
      sprintf(poddrawname,"Psi1POddRaw_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(poddrawtitle,"#Psi_{1}^{odd}(TR^{+}) Raw %1.0lfto%1.0lf",centlo[i],centhi[i]);
      PsiPOddRaw[i] = new TH1F(poddrawname,poddrawtitle,100,-TMath::Pi()-.392699,TMath::Pi()+.392699);
      PsiPOddRaw[i]->GetXaxis()->SetTitle("EP Angle (radians)");
      //First
      sprintf(poddfirstname,"Psi1POddFirst_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(poddfirsttitle,"#Psi_{1}^{odd}(TR^{+}) First %1.0lfto%1.0lf",centlo[i],centhi[i]);
      PsiPOddFirst[i] = new TH1F(poddfirstname,poddfirsttitle,100,-TMath::Pi()-.392699,TMath::Pi()+.392699);
      PsiPOddFirst[i]->GetXaxis()->SetTitle("EP Angle (radians)");
      //Final
      sprintf(poddfinalname,"Psi1POddFinal_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(poddfinaltitle,"#Psi_{1}^{odd}(TR^{+}) Final %1.0lfto%1.0lf",centlo[i],centhi[i]);
      PsiPOddFinal[i] = new TH1F(poddfinalname,poddfinaltitle,100,-TMath::Pi()-.392699,TMath::Pi()+.392699);
      PsiPOddFinal[i]->GetXaxis()->SetTitle("EP Angle (radians)");

     //Neg Tracker
      negep->cd();
      //Raw
      sprintf(noddrawname,"Psi1NOddRaw_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(noddrawtitle,"#Psi_{1}^{odd}(TR^{-}) Raw %1.0lfto%1.0lf",centlo[i],centhi[i]);
      PsiNOddRaw[i] = new TH1F(noddrawname,noddrawtitle,100,-TMath::Pi()-.392699,TMath::Pi()+.392699);
      PsiNOddRaw[i]->GetXaxis()->SetTitle("EP Angle (radians)");
      //First
      sprintf(noddfirstname,"Psi1NOddFirst_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(noddfirsttitle,"#Psi_{1}^{odd}(TR^{-}) First %1.0lfto%1.0lf",centlo[i],centhi[i]);
      PsiNOddFirst[i] = new TH1F(noddfirstname,noddfirsttitle,100,-TMath::Pi()-.392699,TMath::Pi()+.392699);
      PsiNOddFirst[i]->GetXaxis()->SetTitle("EP Angle (radians)");
      //Final
      sprintf(noddfinalname,"Psi1NOddFinal_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(noddfinaltitle,"#Psi_{1}^{odd}(TR^{-}) Final %1.0lfto%1.0lf",centlo[i],centhi[i]);
      PsiNOddFinal[i] = new TH1F(noddfinalname,noddfinaltitle,100,-TMath::Pi()-.392699,TMath::Pi()+.392699);
      PsiNOddFinal[i]->GetXaxis()->SetTitle("EP Angle (radians)");

     //Mid Tracker
      midep->cd();
      //Raw
      sprintf(moddrawname,"Psi1MOddRaw_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(moddrawtitle,"#Psi_{1}^{odd}(TR^{mid}) Raw %1.0lfto%1.0lf",centlo[i],centhi[i]);
      PsiMOddRaw[i] = new TH1F(moddrawname,moddrawtitle,100,-TMath::Pi()-.392699,TMath::Pi()+.392699);
      PsiMOddRaw[i]->GetXaxis()->SetTitle("EP Angle (radians)");

      //First
      sprintf(moddfirstname,"Psi1MOddFirst_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(moddfirsttitle,"#Psi_{1}^{odd}(TR^{mid}) First %1.0lfto%1.0lf",centlo[i],centhi[i]);
      PsiMOddFirst[i] = new TH1F(moddfirstname,moddfirsttitle,100,-TMath::Pi()-.392699,TMath::Pi()+.392699);
      PsiMOddFirst[i]->GetXaxis()->SetTitle("EP Angle (radians)");
      //Final
      sprintf(moddfinalname,"Psi1MOddFinal_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(moddfinaltitle,"#Psi_{1}^{odd}(TR^{mid}) Final %1.0lfto%1.0lf",centlo[i],centhi[i]);
      PsiMOddFinal[i] = new TH1F(moddfinalname,moddfinaltitle,100,-TMath::Pi()-.392699,TMath::Pi()+.392699);
      PsiMOddFinal[i]->GetXaxis()->SetTitle("EP Angle (radians)");


/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////
      //For Resolution of V1 Even
      psioneevenres->cd();
      sprintf(res4name,"TRPMinusTRM_EPResolution_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(res4title,"First Order EP resolution TRPMinusTRM %1.0lf-%1.0lf %%",centlo[i],centhi[i]);
      TRPMinusTRM[i]= new TProfile(res4name,res4title,1,0,1);

      sprintf(res5name,"TRMMinusTRC_EPResolution_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(res5title,"First Order EP resolution TRMMinusTRC %1.0lf-%1.0lf %%",centlo[i],centhi[i]);
      TRMMinusTRC[i]= new TProfile(res5name,res5title,1,0,1);

      sprintf(res6name,"TRPMinusTRC_EPResolution_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(res6title,"First Order EP resolution TRPMinusTRC %1.0lf-%1.0lf %%",centlo[i],centhi[i]);
      TRPMinusTRC[i]= new TProfile(res6name,res6title,1,0,1);


      //For Resolution of V1 Odd
      psioneoddres->cd();
      sprintf(v1oddres1name,"TRPMinusTRMOdd_EPResolution_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(v1oddres1title,"First Order EP resolution TRPMinusTRMOdd %1.0lf-%1.0lf %%",centlo[i],centhi[i]);
      TRPMinusTRMOdd[i]= new TProfile(v1oddres1name,v1oddres1title,1,0,1);

      sprintf(v1oddres2name,"TRMMinusTRCOdd_EPResolution_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(v1oddres2title,"First Order EP resolution TRMMinusTRCOdd %1.0lf-%1.0lf %%",centlo[i],centhi[i]);
      TRMMinusTRCOdd[i]= new TProfile(v1oddres2name,v1oddres2title,1,0,1);

      sprintf(v1oddres3name,"TRPMinusTRCOdd_EPResolution_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(v1oddres3title,"First Order EP resolution TRPMinusTRCOdd %1.0lf-%1.0lf %%",centlo[i],centhi[i]);
      TRPMinusTRCOdd[i]= new TProfile(v1oddres3name,v1oddres3title,1,0,1);

     flowvecplots->cd();
      sprintf(xvecname,"XvectorEven_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(xvectitle,"XvectorEven_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      Xvector[i]= new TH1F(xvecname,xvectitle,100,-TMath::Pi()-.392699,TMath::Pi()+.392699);      
      Xvector[i]->GetXaxis()->SetTitle("X angle (GeV*radians)");
         
      sprintf(yvecname,"YvectorEven_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(yvectitle,"YvectorEven_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      Yvector[i]= new TH1F(yvecname,yvectitle,100,-TMath::Pi()-.392699,TMath::Pi()+.392699);      
      Yvector[i]->GetXaxis()->SetTitle("Y angle (GeV*radians)");


     }//end of centrality loop
}//end of initialize function

void FillPTStats(){

 //Whole Tracker
ptavwhole[0]=0.941464;
ptavwhole[1]=0.95117;
ptavwhole[2]=0.952798;
ptavwhole[3]=0.947588;
ptavwhole[4]=0.937624;
 
pt2avwhole[0]=1.19755;
pt2avwhole[1]=1.22546;
pt2avwhole[2]=1.23552;
pt2avwhole[3]=1.23042;
pt2avwhole[4]=1.21347;
 
//Positive Tracker
ptavpos[0]=0.94767;
ptavpos[1]=0.957841;
ptavpos[2]=0.95949;
ptavpos[3]=0.954261;
ptavpos[4]=0.944176;
 
pt2avpos[0]=1.21299;
pt2avpos[1]=1.24224;
pt2avpos[2]=1.25235;
pt2avpos[3]=1.24749;
pt2avpos[4]=1.23002;
 
//Negative Tracker
ptavneg[0]=0.9357;
ptavneg[1]=0.944994;
ptavneg[2]=0.946605;
ptavneg[3]=0.941421;
ptavneg[4]=0.93157;
 
pt2avneg[0]=1.18322;
pt2avneg[1]=1.20991;
pt2avneg[2]=1.21995;
pt2avneg[3]=1.21465;
pt2avneg[4]=1.19817;
 
//Mid Tracker
ptavmid[0]=0.777141;
ptavmid[1]=0.781723;
ptavmid[2]=0.78016;
ptavmid[3]=0.773262;
ptavmid[4]=0.76271;
 
pt2avmid[0]=0.866104;
pt2avmid[1]=0.881623;
pt2avmid[2]=0.883752;
pt2avmid[3]=0.874852;
pt2avmid[4]=0.857406;
 


  }//end of fillptstats function



void FlowAnalysis(){
  for (Int_t i=0;i<NumberOfEvents;i++)
    {
      if ( !(i%10000) ) cout << " 1st round, event # " << i << " / " << NumberOfEvents << endl;

      chain2->GetEntry(i);//grab the ith event

      //Grab the Track Leaves
      NumTracks= (TLeaf*) chain2->GetLeaf("nTracks");
      TrackMom= (TLeaf*) chain2->GetLeaf("pt");
      TrackPhi= (TLeaf*) chain2->GetLeaf("phi");
      TrackEta= (TLeaf*) chain2->GetLeaf("eta");

      //Grab the Centrality Leaves
      CENTRAL= (TLeaf*) chain2->GetLeaf("bin");
      Centrality= CENTRAL->GetValue();
      if (Centrality>19) continue; //we dont care about any centrality greater than 60%


      for (int q=0;q<nCent;q++)
        {
          //v1 Even
          X_wholetracker[q]=0.;
          Y_wholetracker[q]=0.;
          X_postracker[q]=0.;
          Y_postracker[q]=0.;
          X_negtracker[q]=0.;
          Y_negtracker[q]=0.;
          X_midtracker[q]=0.;
          Y_midtracker[q]=0.;

          //v1 odd
          X_wholeoddtracker[q]=0.;
          Y_wholeoddtracker[q]=0.;
          X_posoddtracker[q]=0.;
          Y_posoddtracker[q]=0.;
          X_negoddtracker[q]=0.;
          Y_negoddtracker[q]=0.;
          X_midoddtracker[q]=0.;
          Y_midoddtracker[q]=0.;
        }

      NumberOfHits= NumTracks->GetValue();
      for (Int_t ii=0;ii<NumberOfHits;ii++)
        {
          pT=0.;
          phi=0.;
          eta=0.;
          pT=TrackMom->GetValue(ii);
          phi=TrackPhi->GetValue(ii);
          eta=TrackEta->GetValue(ii);
          if(pT<0)
            {
              continue;
            }
          for (Int_t c=0;c<nCent;c++)
            {
              if ( (Centrality*2.5) > centhi[c] ) continue;
              if ( (Centrality*2.5) < centlo[c] ) continue;
              if(eta>=1.4)
                {
                  X_wholetracker[c]+=cos(phi)*(pT-(pt2avwhole[c]/ptavwhole[c]));
                  Y_wholetracker[c]+=sin(phi)*(pT-(pt2avwhole[c]/ptavwhole[c]));
                  X_postracker[c]+=cos(phi)*(pT-(pt2avpos[c]/ptavpos[c]));
                  Y_postracker[c]+=sin(phi)*(pT-(pt2avpos[c]/ptavpos[c]));
                  //v1 odd
                  X_wholeoddtracker[c]+=cos(phi)*(pT-(pt2avwhole[c]/ptavwhole[c]));
                  Y_wholeoddtracker[c]+=sin(phi)*(pT-(pt2avwhole[c]/ptavwhole[c]));
                  X_posoddtracker[c]+=cos(phi)*(pT-(pt2avpos[c]/ptavpos[c]));
                  Y_posoddtracker[c]+=sin(phi)*(pT-(pt2avpos[c]/ptavpos[c]));
                }
              else if(eta<=-1.4)
                {
                  X_wholetracker[c]+=cos(phi)*(pT-(pt2avwhole[c]/ptavwhole[c]));
                  Y_wholetracker[c]+=sin(phi)*(pT-(pt2avwhole[c]/ptavwhole[c]));
                  X_negtracker[c]+=cos(phi)*(pT-(pt2avneg[c]/ptavneg[c]));
                  Y_negtracker[c]+=sin(phi)*(pT-(pt2avneg[c]/ptavneg[c]));
                  //v1 odd
                  X_wholeoddtracker[c]+=cos(phi)*(-1.0*(pT-(pt2avwhole[c]/ptavwhole[c])));
                  Y_wholeoddtracker[c]+=sin(phi)*(-1.0*(pT-(pt2avwhole[c]/ptavwhole[c])));
                  X_negoddtracker[c]+=cos(phi)*(-1.0*(pT-(pt2avneg[c]/ptavneg[c])));
                  Y_negoddtracker[c]+=sin(phi)*(-1.0*(pT-(pt2avneg[c]/ptavneg[c])));
                }
              else if(eta<=0.6 && eta>0)
                {
                  X_midtracker[c]+=cos(phi)*(pT-(pt2avmid[c]/ptavmid[c]));
                  Y_midtracker[c]+=sin(phi)*(pT-(pt2avmid[c]/ptavmid[c]));
                  //v1 odd
                  X_midoddtracker[c]+=cos(phi)*(pT-(pt2avmid[c]/ptavmid[c]));
                  Y_midoddtracker[c]+=sin(phi)*(pT-(pt2avmid[c]/ptavmid[c]));
                }
              else if(eta>=-0.6 && eta<0)
                {
                  X_midtracker[c]+=cos(phi)*(pT-(pt2avmid[c]/ptavmid[c]));
                  Y_midtracker[c]+=sin(phi)*(pT-(pt2avmid[c]/ptavmid[c]));
                  //v1 odd
                  X_midoddtracker[c]+=cos(phi)*(-1.0*(pT-(pt2avmid[c]/ptavmid[c])));
                  Y_midoddtracker[c]+=sin(phi)*(-1.0*(pT-(pt2avmid[c]/ptavmid[c])));
                }
            }//end of loop over centrality classes
        }//end of loop over tracks


      //Time to fill the appropriate histograms, this will be <X> <Y>
      for (Int_t c=0;c<nCent;c++)
        {
          if ( (Centrality*2.5) > centhi[c] ) continue;
          if ( (Centrality*2.5) < centlo[c] ) continue;

//////////////////////////////////
//FIRST FILL THE RAW HISTOS//////
////////////////////////////////////

          //V1 even
          //Whole Tracker
          EPwholetracker=(1./1.)*atan2(Y_wholetracker[c],X_wholetracker[c]);
	  if (EPwholetracker>(pi)) EPwholetracker=(EPwholetracker-(TMath::TwoPi()));
          if (EPwholetracker<(-1.0*(pi))) EPwholetracker=(EPwholetracker+(TMath::TwoPi()));
          PsiEvenRaw[c]->Fill(EPwholetracker);


          //Pos Tracker
          EPpostracker=(1./1.)*atan2(Y_postracker[c],X_postracker[c]);
          if (EPpostracker>(pi)) EPpostracker=(EPpostracker-(TMath::TwoPi()));
          if (EPpostracker<(-1.0*(pi))) EPpostracker=(EPpostracker+(TMath::TwoPi()));
          PsiPEvenRaw[c]->Fill(EPpostracker);

          //neg Tracker
          EPnegtracker=(1./1.)*atan2(Y_negtracker[c],X_negtracker[c]);
          if (EPnegtracker>(pi)) EPnegtracker=(EPnegtracker-(TMath::TwoPi()));
          if (EPnegtracker<(-1.0*(pi))) EPnegtracker=(EPnegtracker+(TMath::TwoPi()));
          PsiNEvenRaw[c]->Fill(EPnegtracker);


          //mid Tracker
          EPmidtracker=(1./1.)*atan2(Y_midtracker[c],X_midtracker[c]);
          if (EPmidtracker>(pi)) EPmidtracker=(EPmidtracker-(TMath::TwoPi()));
          if (EPmidtracker<(-1.0*(pi))) EPmidtracker=(EPmidtracker+(TMath::TwoPi()));
          PsiMEvenRaw[c]->Fill(EPmidtracker);

          //V1 odd
          //Whole Tracker
          EPwholeoddtracker=(1./1.)*atan2(Y_wholeoddtracker[c],X_wholeoddtracker[c]);
          if (EPwholeoddtracker>(pi)) EPwholeoddtracker=(EPwholeoddtracker-(TMath::TwoPi()));
          if (EPwholeoddtracker<(-1.0*(pi))) EPwholeoddtracker=(EPwholeoddtracker+(TMath::TwoPi()));
          PsiOddRaw[c]->Fill(EPwholeoddtracker);


          //Pos Tracker
          EPposoddtracker=(1./1.)*atan2(Y_posoddtracker[c],X_posoddtracker[c]);
          if (EPposoddtracker>(pi)) EPposoddtracker=(EPposoddtracker-(TMath::TwoPi()));
          if (EPposoddtracker<(-1.0*(pi))) EPposoddtracker=(EPposoddtracker+(TMath::TwoPi()));
          PsiPOddRaw[c]->Fill(EPposoddtracker);

          //neg Tracker
          EPnegoddtracker=(1./1.)*atan2(Y_negoddtracker[c],X_negoddtracker[c]);
          if (EPnegoddtracker>(pi)) EPnegoddtracker=(EPnegoddtracker-(TMath::TwoPi()));
          if (EPnegoddtracker<(-1.0*(pi))) EPnegoddtracker=(EPnegoddtracker+(TMath::TwoPi()));
          PsiNOddRaw[c]->Fill(EPnegoddtracker);


          //mid Tracker
          EPmidoddtracker=(1./1.)*atan2(Y_midoddtracker[c],X_midoddtracker[c]);
          if (EPmidoddtracker>(pi)) EPmidoddtracker=(EPmidoddtracker-(TMath::TwoPi()));
          if (EPmidoddtracker<(-1.0*(pi))) EPmidoddtracker=(EPmidoddtracker+(TMath::TwoPi()));
          PsiMOddRaw[c]->Fill(EPmidoddtracker);
//////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////

          //V1 even
          //Whole Tracker
          Xcorr_wholetracker=(X_wholetracker[c]-Xav_wholetracker[c])/Xstdev_wholetracker[c];
          Ycorr_wholetracker=(Y_wholetracker[c]-Yav_wholetracker[c])/Ystdev_wholetracker[c];
	  Xvector[c]->Fill(Xcorr_wholetracker[c]);
          Yvector[c]->Fill(Ycorr_wholetracker[c]);
	  EPcorrwholetracker=(1./1.)*atan2(Ycorr_wholetracker,Xcorr_wholetracker);
          if (EPcorrwholetracker>(pi)) EPcorrwholetracker=(EPcorrwholetracker-(TMath::TwoPi()));
          if (EPcorrwholetracker<(-1.0*(pi))) EPcorrwholetracker=(EPcorrwholetracker+(TMath::TwoPi()));
          PsiEvenFirst[c]->Fill(EPcorrwholetracker);     

          //Pos Tracker
          Xcorr_postracker=(X_postracker[c]-Xav_postracker[c])/Xstdev_postracker[c];
          Ycorr_postracker=(Y_postracker[c]-Yav_postracker[c])/Ystdev_postracker[c];
          EPcorrpostracker=(1./1.)*atan2(Ycorr_postracker,Xcorr_postracker);
          if (EPcorrpostracker>(pi)) EPcorrpostracker=(EPcorrpostracker-(TMath::TwoPi()));
          if (EPcorrpostracker<(-1.0*(pi))) EPcorrpostracker=(EPcorrpostracker+(TMath::TwoPi()));
          PsiPEvenFirst[c]->Fill(EPcorrpostracker);
          

          //neg Tracker
          Xcorr_negtracker=(X_negtracker[c]-Xav_negtracker[c])/Xstdev_negtracker[c];
          Ycorr_negtracker=(Y_negtracker[c]-Yav_negtracker[c])/Ystdev_negtracker[c];
          EPcorrnegtracker=(1./1.)*atan2(Ycorr_negtracker,Xcorr_negtracker);
          // if (c==2) std::cout<<Xcorr_negtracker<<" "<<Ycorr_negtracker<<" "<<EPnegtracker<<std::endl;
          if (EPcorrnegtracker>(pi)) EPcorrnegtracker=(EPcorrnegtracker-(TMath::TwoPi()));
          if (EPcorrnegtracker<(-1.0*(pi))) EPcorrnegtracker=(EPcorrnegtracker+(TMath::TwoPi()));
          PsiNEvenFirst[c]->Fill(EPcorrnegtracker);


          //mid Tracker
          Xcorr_midtracker=(X_midtracker[c]-Xav_midtracker[c])/Xstdev_midtracker[c];
          Ycorr_midtracker=(Y_midtracker[c]-Yav_midtracker[c])/Ystdev_midtracker[c];
          EPcorrmidtracker=(1./1.)*atan2(Ycorr_midtracker,Xcorr_midtracker);
          if (EPcorrmidtracker>(pi)) EPcorrmidtracker=(EPcorrmidtracker-(TMath::TwoPi()));
          if (EPcorrmidtracker<(-1.0*(pi))) EPcorrmidtracker=(EPcorrmidtracker+(TMath::TwoPi()));
          PsiMEvenFirst[c]->Fill(EPcorrmidtracker);          

          //V1 Odd
          //Whole Tracker
          Xcorr_wholeoddtracker=(X_wholeoddtracker[c]-Xav_wholeoddtracker[c])/Xstdev_wholeoddtracker[c];
          Ycorr_wholeoddtracker=(Y_wholeoddtracker[c]-Yav_wholeoddtracker[c])/Ystdev_wholeoddtracker[c];
          EPcorrwholeoddtracker=(1./1.)*atan2(Ycorr_wholeoddtracker,Xcorr_wholeoddtracker);
          if (EPcorrwholeoddtracker>(pi)) EPcorrwholeoddtracker=(EPcorrwholeoddtracker-(TMath::TwoPi()));
          if (EPcorrwholeoddtracker<(-1.0*(pi))) EPcorrwholeoddtracker=(EPcorrwholeoddtracker+(TMath::TwoPi()));
          PsiOddFirst[c]->Fill(EPcorrwholeoddtracker);

          //Pos Tracker
          Xcorr_posoddtracker=(X_posoddtracker[c]-Xav_posoddtracker[c])/Xstdev_posoddtracker[c];
          Ycorr_posoddtracker=(Y_posoddtracker[c]-Yav_posoddtracker[c])/Ystdev_posoddtracker[c];
          EPcorrposoddtracker=(1./1.)*atan2(Ycorr_posoddtracker,Xcorr_posoddtracker);
          if (EPcorrposoddtracker>(pi)) EPcorrposoddtracker=(EPcorrposoddtracker-(TMath::TwoPi()));
          if (EPcorrposoddtracker<(-1.0*(pi))) EPcorrposoddtracker=(EPcorrposoddtracker+(TMath::TwoPi()));
          PsiPOddFirst[c]->Fill(EPcorrposoddtracker);


          //neg Tracker
          Xcorr_negoddtracker=(X_negoddtracker[c]-Xav_negoddtracker[c])/Xstdev_negoddtracker[c];
          Ycorr_negoddtracker=(Y_negoddtracker[c]-Yav_negoddtracker[c])/Ystdev_negoddtracker[c];
          EPcorrnegoddtracker=(1./1.)*atan2(Ycorr_negoddtracker,Xcorr_negoddtracker);
          // if (c==2) std::cout<<Xcorr_negtracker<<" "<<Ycorr_negtracker<<" "<<EPnegtracker<<std::endl;
          if (EPcorrnegoddtracker>(pi)) EPcorrnegoddtracker=(EPcorrnegoddtracker-(TMath::TwoPi()));
          if (EPcorrnegoddtracker<(-1.0*(pi))) EPcorrnegoddtracker=(EPcorrnegoddtracker+(TMath::TwoPi()));
          PsiNOddFirst[c]->Fill(EPcorrnegoddtracker);


          //mid Tracker
          Xcorr_midoddtracker=(X_midoddtracker[c]-Xav_midoddtracker[c])/Xstdev_midoddtracker[c];
          Ycorr_midoddtracker=(Y_midoddtracker[c]-Yav_midoddtracker[c])/Ystdev_midoddtracker[c];
          EPcorrmidoddtracker=(1./1.)*atan2(Ycorr_midoddtracker,Xcorr_midoddtracker);
          if (EPcorrmidoddtracker>(pi)) EPcorrmidoddtracker=(EPcorrmidoddtracker-(TMath::TwoPi()));
          if (EPcorrmidoddtracker<(-1.0*(pi))) EPcorrmidoddtracker=(EPcorrmidoddtracker+(TMath::TwoPi()));
          PsiMOddFirst[c]->Fill(EPcorrmidoddtracker);


          //Zero the angular correction variables

          //v1 even stuff
          AngularCorrectionWholeTracker=0.;EPfinalwholetracker=0.;
          AngularCorrectionPosTracker=0.;EPfinalpostracker=0.;
          AngularCorrectionNegTracker=0.;EPfinalnegtracker=0.;
          AngularCorrectionMidTracker=0.;EPfinalmidtracker=0.;

          //v1 odd stuff
          AngularCorrectionWholeOddTracker=0.;EPfinalwholeoddtracker=0.;
          AngularCorrectionPosOddTracker=0.;EPfinalposoddtracker=0.;
          AngularCorrectionNegOddTracker=0.;EPfinalnegoddtracker=0.;
          AngularCorrectionMidOddTracker=0.;EPfinalmidoddtracker=0.;

          //Compute Angular Corrections
          for (Int_t k=1;k<(jMax+1);k++)
            {
              //v1 even
              //Whole Tracker
              AngularCorrectionWholeTracker+=((2./k)*(((-SineWholeTracker[c][k-1])*(cos(k*EPwholetracker)))+((CosineWholeTracker[c][k-1])*(sin(k*EPwholetracker)))));

              //Pos Tracker
              AngularCorrectionPosTracker+=((2./k)*(((-SinePosTracker[c][k-1])*(cos(k*EPpostracker)))+((CosinePosTracker[c][k-1])*(sin(k*EPpostracker)))));


              //Neg Tracker
              AngularCorrectionNegTracker+=((2./k)*(((-SineNegTracker[c][k-1])*(cos(k*EPnegtracker)))+((CosineNegTracker[c][k-1])*(sin(k*EPnegtracker)))));

              //Mid Tracker
              AngularCorrectionMidTracker+=((2./k)*(((-SineMidTracker[c][k-1])*(cos(k*EPmidtracker)))+((CosineMidTracker[c][k-1])*(sin(k*EPmidtracker)))));

              //v1 odd
              //Whole Tracker
              AngularCorrectionWholeOddTracker+=((2./k)*(((-SineWholeOddTracker[c][k-1])*(cos(k*EPwholeoddtracker)))+((CosineWholeOddTracker[c][k-1])*(sin(k*EPwholeoddtracker)))));

              //Pos Tracker
              AngularCorrectionPosOddTracker+=((2./k)*(((-SinePosOddTracker[c][k-1])*(cos(k*EPposoddtracker)))+((CosinePosOddTracker[c][k-1])*(sin(k*EPposoddtracker)))));


              //Neg Tracker
              AngularCorrectionNegOddTracker+=((2./k)*(((-SineNegOddTracker[c][k-1])*(cos(k*EPnegoddtracker)))+((CosineNegOddTracker[c][k-1])*(sin(k*EPnegoddtracker)))));

              //Mid Tracker
              AngularCorrectionMidOddTracker+=((2./k)*(((-SineMidOddTracker[c][k-1])*(cos(k*EPmidoddtracker)))+((CosineMidOddTracker[c][k-1])*(sin(k*EPmidoddtracker)))));


            }//end of angular correction calculation


          //Add the final Corrections to the Event Plane
          //and store it and do the flow measurement with it


          //Tracker

          //v1 even
          //Whole Tracker
          EPfinalwholetracker=EPcorrwholetracker+AngularCorrectionWholeTracker;
          if (EPfinalwholetracker>(pi)) EPfinalwholetracker=(EPfinalwholetracker-(TMath::TwoPi()));
          if (EPfinalwholetracker<(-1.0*(pi))) EPfinalwholetracker=(EPfinalwholetracker+(TMath::TwoPi()));
          PsiEvenFinal[c]->Fill(EPfinalwholetracker);

          //Pos Tracker
          EPfinalpostracker=EPcorrpostracker+AngularCorrectionPosTracker;
          if (EPfinalpostracker>(pi)) EPfinalpostracker=(EPfinalpostracker-(TMath::TwoPi()));
          if (EPfinalpostracker<(-1.0*(pi))) EPfinalpostracker=(EPfinalpostracker+(TMath::TwoPi()));
          PsiPEvenFinal[c]->Fill(EPfinalpostracker);

          //Neg Tracker
          EPfinalnegtracker=EPcorrnegtracker+AngularCorrectionNegTracker;
          //if(c==2) std::cout<<EPfinalnegtracker<<std::endl;
          if (EPfinalnegtracker>(pi)) EPfinalnegtracker=(EPfinalnegtracker-(TMath::TwoPi()));
          if (EPfinalnegtracker<(-1.0*(pi))) EPfinalnegtracker=(EPfinalnegtracker+(TMath::TwoPi()));
          PsiNEvenFinal[c]->Fill(EPfinalnegtracker);


          //Mid Tracker
          EPfinalmidtracker=EPcorrmidtracker+AngularCorrectionMidTracker;
          if (EPfinalmidtracker>(pi)) EPfinalmidtracker=(EPfinalmidtracker-(TMath::TwoPi()));
          if (EPfinalmidtracker<(-1.0*(pi))) EPfinalmidtracker=(EPfinalmidtracker+(TMath::TwoPi()));
          PsiMEvenFinal[c]->Fill(EPfinalmidtracker);

          //v1 odd
          //Whole Tracker
          EPfinalwholeoddtracker=EPcorrwholeoddtracker+AngularCorrectionWholeOddTracker;
          if (EPfinalwholeoddtracker>(pi)) EPfinalwholeoddtracker=(EPfinalwholeoddtracker-(TMath::TwoPi()));
          if (EPfinalwholeoddtracker<(-1.0*(pi))) EPfinalwholeoddtracker=(EPfinalwholeoddtracker+(TMath::TwoPi()));
          PsiOddFinal[c]->Fill(EPfinalwholeoddtracker);

          //Pos Tracker
          EPfinalposoddtracker=EPcorrposoddtracker+AngularCorrectionPosOddTracker;
          if (EPfinalposoddtracker>(pi)) EPfinalposoddtracker=(EPfinalposoddtracker-(TMath::TwoPi()));
          if (EPfinalposoddtracker<(-1.0*(pi))) EPfinalposoddtracker=(EPfinalposoddtracker+(TMath::TwoPi()));
          PsiPOddFinal[c]->Fill(EPfinalposoddtracker);


          //Neg Tracker
          EPfinalnegoddtracker=EPcorrnegoddtracker+AngularCorrectionNegOddTracker;
          //if(c==2) std::cout<<EPfinalnegtracker<<std::endl;
          if (EPfinalnegoddtracker>(pi)) EPfinalnegoddtracker=(EPfinalnegoddtracker-(TMath::TwoPi()));
          if (EPfinalnegoddtracker<(-1.0*(pi))) EPfinalnegoddtracker=(EPfinalnegoddtracker+(TMath::TwoPi()));
          PsiNOddFinal[c]->Fill(EPfinalnegoddtracker);


          //Mid Tracker
          EPfinalmidoddtracker=EPcorrmidoddtracker+AngularCorrectionMidOddTracker;
          if (EPfinalmidoddtracker>(pi)) EPfinalmidoddtracker=(EPfinalmidoddtracker-(TMath::TwoPi()));
          if (EPfinalmidoddtracker<(-1.0*(pi))) EPfinalmidoddtracker=(EPfinalmidoddtracker+(TMath::TwoPi()));
          PsiMOddFinal[c]->Fill(EPfinalmidoddtracker);


          //Resolutions
          //Even v1
          TRPMinusTRM[c]->Fill(0,cos(EPfinalpostracker-EPfinalnegtracker));
          TRMMinusTRC[c]->Fill(0,cos(EPfinalnegtracker-EPfinalmidtracker));
          TRPMinusTRC[c]->Fill(0,cos(EPfinalpostracker-EPfinalmidtracker));
          //Odd V1
          TRPMinusTRMOdd[c]->Fill(0,cos(EPfinalposoddtracker-EPfinalnegoddtracker));
          TRMMinusTRCOdd[c]->Fill(0,cos(EPfinalnegoddtracker-EPfinalmidoddtracker));
          TRPMinusTRCOdd[c]->Fill(0,cos(EPfinalposoddtracker-EPfinalmidoddtracker));



          //Loop again over tracks to find the flow
          NumberOfHits= NumTracks->GetValue();
          for (Int_t ii=0;ii<NumberOfHits;ii++)
            {
              pT=0.;
              phi=0.;
              eta=0.;
              pT=TrackMom->GetValue(ii);
              phi=TrackPhi->GetValue(ii);
              eta=TrackEta->GetValue(ii);
              if(pT<0)
                {
                  continue;
                }
              //              std::cout<<pT<<" "<<eta<<" "<<phi<<std::endl;
              if(fabs(eta)<0.6 && pT>0.4)
                {
                  V1EtaOdd[c]->Fill(eta,cos(phi-EPfinalwholeoddtracker));
                  if(pT<=3.5) V1EtaEven[c]->Fill(eta,cos(phi-EPfinalwholetracker));
                  V1PtOdd[c]->Fill(pT,cos(phi-EPfinalwholeoddtracker));
                  PTCenters[c]->Fill(pT,pT);
                  V1PtEven[c]->Fill(pT,cos(phi-EPfinalwholetracker));
                }
            }//end of loop over tracks
        }//End of loop over centralities
    }//End of loop over events
}//End of Flow Analysis Function

void FillAngularCorrections(){
//V1 Even
//Whole Tracker
CosineWholeTracker[0][0]=0.00368513;
CosineWholeTracker[1][0]=0.00311249;
CosineWholeTracker[2][0]=0.00309212;
CosineWholeTracker[3][0]=0.00358776;
CosineWholeTracker[4][0]=0.00297163;
 
SineWholeTracker[0][0]=0.00967925;
SineWholeTracker[1][0]=0.00695368;
SineWholeTracker[2][0]=0.00634233;
SineWholeTracker[3][0]=0.00661488;
SineWholeTracker[4][0]=0.00537812;
 
CosineWholeTracker[0][1]=0.000161419;
CosineWholeTracker[1][1]=0.000573046;
CosineWholeTracker[2][1]=-7.21673e-05;
CosineWholeTracker[3][1]=0.000242772;
CosineWholeTracker[4][1]=-0.000243534;
 
SineWholeTracker[0][1]=-0.00786637;
SineWholeTracker[1][1]=-0.0095932;
SineWholeTracker[2][1]=-0.010753;
SineWholeTracker[3][1]=-0.0097862;
SineWholeTracker[4][1]=-0.0114054;
 
CosineWholeTracker[0][2]=3.86326e-05;
CosineWholeTracker[1][2]=6.47824e-05;
CosineWholeTracker[2][2]=0.000440201;
CosineWholeTracker[3][2]=0.000636638;
CosineWholeTracker[4][2]=0.000240091;
 
SineWholeTracker[0][2]=-0.000320578;
SineWholeTracker[1][2]=0.000199713;
SineWholeTracker[2][2]=-0.00048119;
SineWholeTracker[3][2]=1.4004e-05;
SineWholeTracker[4][2]=-0.000892992;
 
CosineWholeTracker[0][3]=-0.000487613;
CosineWholeTracker[1][3]=-0.000111798;
CosineWholeTracker[2][3]=0.000200984;
CosineWholeTracker[3][3]=-0.000852145;
CosineWholeTracker[4][3]=-0.000863215;
 
SineWholeTracker[0][3]=0.00101064;
SineWholeTracker[1][3]=-0.000690573;
SineWholeTracker[2][3]=-0.000345404;
SineWholeTracker[3][3]=-0.000510146;
SineWholeTracker[4][3]=-0.000854095;
 
CosineWholeTracker[0][4]=-0.000102392;
CosineWholeTracker[1][4]=-0.000253869;
CosineWholeTracker[2][4]=0.000165599;
CosineWholeTracker[3][4]=-0.000289487;
CosineWholeTracker[4][4]=0.000590543;
 
SineWholeTracker[0][4]=0.000175238;
SineWholeTracker[1][4]=-0.000576659;
SineWholeTracker[2][4]=0.00023966;
SineWholeTracker[3][4]=-0.000357129;
SineWholeTracker[4][4]=0.000728888;
 
CosineWholeTracker[0][5]=0.000237844;
CosineWholeTracker[1][5]=0.000633188;
CosineWholeTracker[2][5]=2.47269e-05;
CosineWholeTracker[3][5]=0.000779502;
CosineWholeTracker[4][5]=0.000132332;
 
SineWholeTracker[0][5]=-0.000831104;
SineWholeTracker[1][5]=-0.000736311;
SineWholeTracker[2][5]=4.30209e-05;
SineWholeTracker[3][5]=0.000617466;
SineWholeTracker[4][5]=-0.000539054;
 
CosineWholeTracker[0][6]=0.0005858;
CosineWholeTracker[1][6]=0.000628666;
CosineWholeTracker[2][6]=-0.000892102;
CosineWholeTracker[3][6]=-0.000606995;
CosineWholeTracker[4][6]=-9.33032e-05;
 
SineWholeTracker[0][6]=0.000182755;
SineWholeTracker[1][6]=-0.000927404;
SineWholeTracker[2][6]=-0.000282707;
SineWholeTracker[3][6]=-0.000764574;
SineWholeTracker[4][6]=0.000745735;
 
CosineWholeTracker[0][7]=4.74327e-05;
CosineWholeTracker[1][7]=-0.000626889;
CosineWholeTracker[2][7]=-0.000435512;
CosineWholeTracker[3][7]=-0.000305587;
CosineWholeTracker[4][7]=0.00018029;
 
SineWholeTracker[0][7]=-0.000101229;
SineWholeTracker[1][7]=-0.000258774;
SineWholeTracker[2][7]=-0.000622642;
SineWholeTracker[3][7]=0.000328506;
SineWholeTracker[4][7]=-0.000563782;
 
CosineWholeTracker[0][8]=-0.00134593;
CosineWholeTracker[1][8]=0.000244704;
CosineWholeTracker[2][8]=2.99178e-05;
CosineWholeTracker[3][8]=-0.000776506;
CosineWholeTracker[4][8]=0.000716123;
 
SineWholeTracker[0][8]=-0.000670976;
SineWholeTracker[1][8]=4.71252e-05;
SineWholeTracker[2][8]=0.000363203;
SineWholeTracker[3][8]=-0.000180384;
SineWholeTracker[4][8]=0.00150892;
 
CosineWholeTracker[0][9]=0.000648601;
CosineWholeTracker[1][9]=0.000143703;
CosineWholeTracker[2][9]=0.00101288;
CosineWholeTracker[3][9]=0.000393827;
CosineWholeTracker[4][9]=0.000273592;
 
SineWholeTracker[0][9]=-0.000830326;
SineWholeTracker[1][9]=0.00108286;
SineWholeTracker[2][9]=-0.000248305;
SineWholeTracker[3][9]=-7.93709e-05;
SineWholeTracker[4][9]=-0.00029075;
 
 
//Pos Tracker
CosinePosTracker[0][0]=0.0160943;
CosinePosTracker[1][0]=0.0154606;
CosinePosTracker[2][0]=0.0143733;
CosinePosTracker[3][0]=0.0138361;
CosinePosTracker[4][0]=0.0128847;
 
SinePosTracker[0][0]=0.0578821;
SinePosTracker[1][0]=0.0532183;
SinePosTracker[2][0]=0.0485035;
SinePosTracker[3][0]=0.0450244;
SinePosTracker[4][0]=0.0400582;
 
CosinePosTracker[0][1]=-0.031401;
CosinePosTracker[1][1]=-0.0276336;
CosinePosTracker[2][1]=-0.0259318;
CosinePosTracker[3][1]=-0.0230095;
CosinePosTracker[4][1]=-0.0211234;
 
SinePosTracker[0][1]=0.00904823;
SinePosTracker[1][1]=0.00559912;
SinePosTracker[2][1]=0.00135111;
SinePosTracker[3][1]=-0.00124751;
SinePosTracker[4][1]=-0.00530219;
 
CosinePosTracker[0][2]=-0.00806684;
CosinePosTracker[1][2]=-0.00673434;
CosinePosTracker[2][2]=-0.0052156;
CosinePosTracker[3][2]=-0.00472835;
CosinePosTracker[4][2]=-0.00333447;
 
SinePosTracker[0][2]=-0.0220548;
SinePosTracker[1][2]=-0.0200743;
SinePosTracker[2][2]=-0.0191896;
SinePosTracker[3][2]=-0.0168445;
SinePosTracker[4][2]=-0.014783;
 
CosinePosTracker[0][3]=0.011835;
CosinePosTracker[1][3]=0.0121191;
CosinePosTracker[2][3]=0.00991162;
CosinePosTracker[3][3]=0.00906256;
CosinePosTracker[4][3]=0.00828092;
 
SinePosTracker[0][3]=-0.00705599;
SinePosTracker[1][3]=-0.00686899;
SinePosTracker[2][3]=-0.00655301;
SinePosTracker[3][3]=-0.0054811;
SinePosTracker[4][3]=-0.00523684;
 
CosinePosTracker[0][4]=0.00664127;
CosinePosTracker[1][4]=0.0057956;
CosinePosTracker[2][4]=0.00556986;
CosinePosTracker[3][4]=0.00521562;
CosinePosTracker[4][4]=0.00414737;
 
SinePosTracker[0][4]=0.00956338;
SinePosTracker[1][4]=0.00791105;
SinePosTracker[2][4]=0.00794448;
SinePosTracker[3][4]=0.00638204;
SinePosTracker[4][4]=0.00622257;
 
CosinePosTracker[0][5]=-0.00716435;
CosinePosTracker[1][5]=-0.00589047;
CosinePosTracker[2][5]=-0.00581225;
CosinePosTracker[3][5]=-0.00484255;
CosinePosTracker[4][5]=-0.00601997;
 
SinePosTracker[0][5]=0.00549115;
SinePosTracker[1][5]=0.00514194;
SinePosTracker[2][5]=0.00474016;
SinePosTracker[3][5]=0.00388054;
SinePosTracker[4][5]=0.00380661;
 
CosinePosTracker[0][6]=-0.00650554;
CosinePosTracker[1][6]=-0.00559974;
CosinePosTracker[2][6]=-0.00464765;
CosinePosTracker[3][6]=-0.00526531;
CosinePosTracker[4][6]=-0.00552459;
 
SinePosTracker[0][6]=-0.0069679;
SinePosTracker[1][6]=-0.00469327;
SinePosTracker[2][6]=-0.00471731;
SinePosTracker[3][6]=-0.00400287;
SinePosTracker[4][6]=-0.00528176;
 
CosinePosTracker[0][7]=0.00412235;
CosinePosTracker[1][7]=0.00406269;
CosinePosTracker[2][7]=0.00316323;
CosinePosTracker[3][7]=0.00379395;
CosinePosTracker[4][7]=0.00440964;
 
SinePosTracker[0][7]=-0.00640713;
SinePosTracker[1][7]=-0.00436908;
SinePosTracker[2][7]=-0.00530457;
SinePosTracker[3][7]=-0.00508229;
SinePosTracker[4][7]=-0.00503048;
 
CosinePosTracker[0][8]=0.00487097;
CosinePosTracker[1][8]=0.00594413;
CosinePosTracker[2][8]=0.00487161;
CosinePosTracker[3][8]=0.00564624;
CosinePosTracker[4][8]=0.00598143;
 
SinePosTracker[0][8]=0.00445291;
SinePosTracker[1][8]=0.00357782;
SinePosTracker[2][8]=0.00201567;
SinePosTracker[3][8]=0.00307046;
SinePosTracker[4][8]=0.00309013;
 
CosinePosTracker[0][9]=-0.00302757;
CosinePosTracker[1][9]=-0.00232862;
CosinePosTracker[2][9]=-0.00183014;
CosinePosTracker[3][9]=-0.0028956;
CosinePosTracker[4][9]=-0.00097146;
 
SinePosTracker[0][9]=0.00629914;
SinePosTracker[1][9]=0.00510929;
SinePosTracker[2][9]=0.00506154;
SinePosTracker[3][9]=0.00536389;
SinePosTracker[4][9]=0.00626016;
 
 
//Neg Tracker
CosineNegTracker[0][0]=0.0300799;
CosineNegTracker[1][0]=0.0261944;
CosineNegTracker[2][0]=0.0230385;
CosineNegTracker[3][0]=0.0203864;
CosineNegTracker[4][0]=0.0181889;
 
SineNegTracker[0][0]=0.0294814;
SineNegTracker[1][0]=0.0253334;
SineNegTracker[2][0]=0.0229896;
SineNegTracker[3][0]=0.0216825;
SineNegTracker[4][0]=0.0187246;
 
CosineNegTracker[0][1]=-0.0119142;
CosineNegTracker[1][1]=-0.0108232;
CosineNegTracker[2][1]=-0.00955851;
CosineNegTracker[3][1]=-0.0092481;
CosineNegTracker[4][1]=-0.0087971;
 
SineNegTracker[0][1]=0.0152306;
SineNegTracker[1][1]=0.00617064;
SineNegTracker[2][1]=0.00190065;
SineNegTracker[3][1]=-0.00209357;
SineNegTracker[4][1]=-0.00589313;
 
CosineNegTracker[0][2]=-0.0120569;
CosineNegTracker[1][2]=-0.00966479;
CosineNegTracker[2][2]=-0.00655566;
CosineNegTracker[3][2]=-0.00601145;
CosineNegTracker[4][2]=-0.00540839;
 
SineNegTracker[0][2]=-0.00401355;
SineNegTracker[1][2]=-0.00373293;
SineNegTracker[2][2]=-0.00377929;
SineNegTracker[3][2]=-0.00274034;
SineNegTracker[4][2]=-0.00193836;
 
CosineNegTracker[0][3]=-0.00116352;
CosineNegTracker[1][3]=-0.00101978;
CosineNegTracker[2][3]=-0.000842247;
CosineNegTracker[3][3]=-0.00162206;
CosineNegTracker[4][3]=-0.00122679;
 
SineNegTracker[0][3]=-0.00774209;
SineNegTracker[1][3]=-0.00664275;
SineNegTracker[2][3]=-0.00529261;
SineNegTracker[3][3]=-0.00474571;
SineNegTracker[4][3]=-0.00422987;
 
CosineNegTracker[0][4]=0.00464394;
CosineNegTracker[1][4]=0.00431199;
CosineNegTracker[2][4]=0.00393866;
CosineNegTracker[3][4]=0.00224447;
CosineNegTracker[4][4]=0.0037537;
 
SineNegTracker[0][4]=-0.00414643;
SineNegTracker[1][4]=-0.00199316;
SineNegTracker[2][4]=-0.00345705;
SineNegTracker[3][4]=-0.0036654;
SineNegTracker[4][4]=-0.00216099;
 
CosineNegTracker[0][5]=0.00442997;
CosineNegTracker[1][5]=0.00461311;
CosineNegTracker[2][5]=0.00221998;
CosineNegTracker[3][5]=0.00321169;
CosineNegTracker[4][5]=0.00267972;
 
SineNegTracker[0][5]=0.00215008;
SineNegTracker[1][5]=0.0017534;
SineNegTracker[2][5]=0.00070897;
SineNegTracker[3][5]=0.00200095;
SineNegTracker[4][5]=0.00146044;
 
CosineNegTracker[0][6]=-0.000401858;
CosineNegTracker[1][6]=0.000340786;
CosineNegTracker[2][6]=3.504e-05;
CosineNegTracker[3][6]=0.000639677;
CosineNegTracker[4][6]=0.000308785;
 
SineNegTracker[0][6]=0.00300298;
SineNegTracker[1][6]=0.00315681;
SineNegTracker[2][6]=0.00348086;
SineNegTracker[3][6]=0.00321096;
SineNegTracker[4][6]=0.00496406;
 
CosineNegTracker[0][7]=-0.00316793;
CosineNegTracker[1][7]=-0.00234405;
CosineNegTracker[2][7]=-0.00235887;
CosineNegTracker[3][7]=-0.00279832;
CosineNegTracker[4][7]=-0.00256873;
 
SineNegTracker[0][7]=0.00153713;
SineNegTracker[1][7]=0.00196094;
SineNegTracker[2][7]=0.00115732;
SineNegTracker[3][7]=0.00160312;
SineNegTracker[4][7]=0.00183112;
 
CosineNegTracker[0][8]=-0.00211554;
CosineNegTracker[1][8]=-0.00202481;
CosineNegTracker[2][8]=-0.00203893;
CosineNegTracker[3][8]=-0.00232388;
CosineNegTracker[4][8]=-0.00169507;
 
SineNegTracker[0][8]=-0.0015237;
SineNegTracker[1][8]=-0.002183;
SineNegTracker[2][8]=-0.00163614;
SineNegTracker[3][8]=-0.00119981;
SineNegTracker[4][8]=-0.000836207;
 
CosineNegTracker[0][9]=0.00127192;
CosineNegTracker[1][9]=0.000553524;
CosineNegTracker[2][9]=0.000904482;
CosineNegTracker[3][9]=-0.00013776;
CosineNegTracker[4][9]=8.22576e-05;
 
SineNegTracker[0][9]=-0.00258992;
SineNegTracker[1][9]=-0.00314189;
SineNegTracker[2][9]=-0.00179472;
SineNegTracker[3][9]=-0.00202992;
SineNegTracker[4][9]=-0.00338904;
 
 
//Mid Tracker
CosineMidTracker[0][0]=-0.000988093;
CosineMidTracker[1][0]=0.000503663;
CosineMidTracker[2][0]=0.00142632;
CosineMidTracker[3][0]=0.00217325;
CosineMidTracker[4][0]=0.00266441;
 
SineMidTracker[0][0]=0.00363543;
SineMidTracker[1][0]=0.00152163;
SineMidTracker[2][0]=0.00059572;
SineMidTracker[3][0]=0.000136845;
SineMidTracker[4][0]=-0.000377304;
 
CosineMidTracker[0][1]=-0.0009817;
CosineMidTracker[1][1]=-0.000610607;
CosineMidTracker[2][1]=3.58691e-05;
CosineMidTracker[3][1]=0.000350124;
CosineMidTracker[4][1]=0.000468648;
 
SineMidTracker[0][1]=-0.0234363;
SineMidTracker[1][1]=-0.0182478;
SineMidTracker[2][1]=-0.0124167;
SineMidTracker[3][1]=-0.00894157;
SineMidTracker[4][1]=-0.00630973;
 
CosineMidTracker[0][2]=-0.00743676;
CosineMidTracker[1][2]=-0.00432112;
CosineMidTracker[2][2]=-0.00185867;
CosineMidTracker[3][2]=-0.000692118;
CosineMidTracker[4][2]=-0.00108771;
 
SineMidTracker[0][2]=0.00100488;
SineMidTracker[1][2]=0.000476943;
SineMidTracker[2][2]=-0.000615909;
SineMidTracker[3][2]=7.23562e-05;
SineMidTracker[4][2]=-0.00233495;
 
CosineMidTracker[0][3]=-0.00140576;
CosineMidTracker[1][3]=-0.000625429;
CosineMidTracker[2][3]=-0.000957225;
CosineMidTracker[3][3]=-0.000743345;
CosineMidTracker[4][3]=-0.000904986;
 
SineMidTracker[0][3]=0.000803462;
SineMidTracker[1][3]=6.34684e-05;
SineMidTracker[2][3]=-0.000420194;
SineMidTracker[3][3]=-0.000656942;
SineMidTracker[4][3]=-0.000777449;
 
CosineMidTracker[0][4]=0.000447181;
CosineMidTracker[1][4]=-0.000109973;
CosineMidTracker[2][4]=0.000403974;
CosineMidTracker[3][4]=0.000350506;
CosineMidTracker[4][4]=0.000172403;
 
SineMidTracker[0][4]=-0.000869201;
SineMidTracker[1][4]=-0.000455315;
SineMidTracker[2][4]=0.000476609;
SineMidTracker[3][4]=0.000889831;
SineMidTracker[4][4]=0.00030109;
 
CosineMidTracker[0][5]=-0.000816397;
CosineMidTracker[1][5]=0.000455318;
CosineMidTracker[2][5]=0.000295699;
CosineMidTracker[3][5]=0.00073956;
CosineMidTracker[4][5]=0.00110386;
 
SineMidTracker[0][5]=-0.000536827;
SineMidTracker[1][5]=-0.000323429;
SineMidTracker[2][5]=0.000997492;
SineMidTracker[3][5]=0.00068668;
SineMidTracker[4][5]=0.000505359;
 
CosineMidTracker[0][6]=0.000664477;
CosineMidTracker[1][6]=0.000755382;
CosineMidTracker[2][6]=8.3885e-05;
CosineMidTracker[3][6]=0.000663378;
CosineMidTracker[4][6]=0.000533113;
 
SineMidTracker[0][6]=-0.000284955;
SineMidTracker[1][6]=-6.63425e-05;
SineMidTracker[2][6]=1.93089e-05;
SineMidTracker[3][6]=0.000191147;
SineMidTracker[4][6]=-0.000594791;
 
CosineMidTracker[0][7]=-0.000162072;
CosineMidTracker[1][7]=-0.00044538;
CosineMidTracker[2][7]=0.000667156;
CosineMidTracker[3][7]=-7.87594e-06;
CosineMidTracker[4][7]=2.5855e-05;
 
SineMidTracker[0][7]=-0.000564365;
SineMidTracker[1][7]=0.000990515;
SineMidTracker[2][7]=6.77349e-05;
SineMidTracker[3][7]=-0.000672185;
SineMidTracker[4][7]=-0.000239822;
 
CosineMidTracker[0][8]=-0.000330968;
CosineMidTracker[1][8]=0.00020799;
CosineMidTracker[2][8]=0.00060348;
CosineMidTracker[3][8]=-2.44021e-05;
CosineMidTracker[4][8]=-5.70201e-05;
 
SineMidTracker[0][8]=0.000558239;
SineMidTracker[1][8]=-0.000897451;
SineMidTracker[2][8]=-0.000704914;
SineMidTracker[3][8]=-0.000273321;
SineMidTracker[4][8]=0.000527541;
 
CosineMidTracker[0][9]=0.000412662;
CosineMidTracker[1][9]=0.000782744;
CosineMidTracker[2][9]=-0.000289259;
CosineMidTracker[3][9]=-9.06162e-05;
CosineMidTracker[4][9]=0.000217481;
 
SineMidTracker[0][9]=-0.000658307;
SineMidTracker[1][9]=-0.000996598;
SineMidTracker[2][9]=4.35891e-05;
SineMidTracker[3][9]=-0.000254833;
SineMidTracker[4][9]=0.000213204;
 
//V1 Odd
//Whole Tracker
CosineWholeOddTracker[0][0]=-0.00391247;
CosineWholeOddTracker[1][0]=-0.00250959;
CosineWholeOddTracker[2][0]=-0.00230958;
CosineWholeOddTracker[3][0]=-0.00198868;
CosineWholeOddTracker[4][0]=-0.000714969;
 
SineWholeOddTracker[0][0]=-0.00335952;
SineWholeOddTracker[1][0]=-0.00225463;
SineWholeOddTracker[2][0]=-0.00136495;
SineWholeOddTracker[3][0]=-0.00165104;
SineWholeOddTracker[4][0]=-0.000478847;
 
CosineWholeOddTracker[0][1]=6.78084e-05;
CosineWholeOddTracker[1][1]=-0.000686532;
CosineWholeOddTracker[2][1]=-0.000521956;
CosineWholeOddTracker[3][1]=6.9547e-05;
CosineWholeOddTracker[4][1]=-5.49838e-05;
 
SineWholeOddTracker[0][1]=0.0136654;
SineWholeOddTracker[1][1]=0.00594571;
SineWholeOddTracker[2][1]=0.00116656;
SineWholeOddTracker[3][1]=-0.00301501;
SineWholeOddTracker[4][1]=-0.0062414;
 
CosineWholeOddTracker[0][2]=-0.000888251;
CosineWholeOddTracker[1][2]=-1.40626e-05;
CosineWholeOddTracker[2][2]=-0.000883008;
CosineWholeOddTracker[3][2]=-0.000369057;
CosineWholeOddTracker[4][2]=-0.000610204;
 
SineWholeOddTracker[0][2]=-0.00102234;
SineWholeOddTracker[1][2]=-1.32877e-05;
SineWholeOddTracker[2][2]=-0.000120584;
SineWholeOddTracker[3][2]=-0.00039484;
SineWholeOddTracker[4][2]=0.00079931;
 
CosineWholeOddTracker[0][3]=-0.000477159;
CosineWholeOddTracker[1][3]=-8.80763e-05;
CosineWholeOddTracker[2][3]=0.000503691;
CosineWholeOddTracker[3][3]=0.000380361;
CosineWholeOddTracker[4][3]=-0.00121558;
 
SineWholeOddTracker[0][3]=0.000746401;
SineWholeOddTracker[1][3]=-0.00124409;
SineWholeOddTracker[2][3]=-0.0012855;
SineWholeOddTracker[3][3]=0.000115988;
SineWholeOddTracker[4][3]=0.00151104;
 
CosineWholeOddTracker[0][4]=-0.00020614;
CosineWholeOddTracker[1][4]=-0.000578862;
CosineWholeOddTracker[2][4]=0.000371627;
CosineWholeOddTracker[3][4]=1.98921e-05;
CosineWholeOddTracker[4][4]=0.0011107;
 
SineWholeOddTracker[0][4]=0.000734518;
SineWholeOddTracker[1][4]=0.000372701;
SineWholeOddTracker[2][4]=0.000120108;
SineWholeOddTracker[3][4]=0.000473661;
SineWholeOddTracker[4][4]=-5.62621e-05;
 
CosineWholeOddTracker[0][5]=0.000472394;
CosineWholeOddTracker[1][5]=-0.000900159;
CosineWholeOddTracker[2][5]=-0.000525748;
CosineWholeOddTracker[3][5]=-0.00157222;
CosineWholeOddTracker[4][5]=-0.00108766;
 
SineWholeOddTracker[0][5]=-0.000403427;
SineWholeOddTracker[1][5]=6.78917e-05;
SineWholeOddTracker[2][5]=7.29916e-05;
SineWholeOddTracker[3][5]=0.000126206;
SineWholeOddTracker[4][5]=0.000393133;
 
CosineWholeOddTracker[0][6]=0.000248074;
CosineWholeOddTracker[1][6]=0.000583228;
CosineWholeOddTracker[2][6]=0.000547297;
CosineWholeOddTracker[3][6]=0.000705528;
CosineWholeOddTracker[4][6]=0.000897867;
 
SineWholeOddTracker[0][6]=0.000141978;
SineWholeOddTracker[1][6]=-3.51262e-05;
SineWholeOddTracker[2][6]=-0.000358963;
SineWholeOddTracker[3][6]=0.000911211;
SineWholeOddTracker[4][6]=-0.000578815;
 
CosineWholeOddTracker[0][7]=0.000713074;
CosineWholeOddTracker[1][7]=0.000431772;
CosineWholeOddTracker[2][7]=0.000466035;
CosineWholeOddTracker[3][7]=0.000700343;
CosineWholeOddTracker[4][7]=0.000885758;
 
SineWholeOddTracker[0][7]=3.2134e-05;
SineWholeOddTracker[1][7]=0.000228298;
SineWholeOddTracker[2][7]=-0.00100437;
SineWholeOddTracker[3][7]=-0.000482863;
SineWholeOddTracker[4][7]=-0.00109161;
 
CosineWholeOddTracker[0][8]=-0.00025306;
CosineWholeOddTracker[1][8]=-0.000565103;
CosineWholeOddTracker[2][8]=0.000670152;
CosineWholeOddTracker[3][8]=8.66986e-05;
CosineWholeOddTracker[4][8]=0.000337049;
 
SineWholeOddTracker[0][8]=-0.000563216;
SineWholeOddTracker[1][8]=-0.000437299;
SineWholeOddTracker[2][8]=-0.000899118;
SineWholeOddTracker[3][8]=-0.000685609;
SineWholeOddTracker[4][8]=-0.000795762;
 
CosineWholeOddTracker[0][9]=0.000208671;
CosineWholeOddTracker[1][9]=-0.000314491;
CosineWholeOddTracker[2][9]=0.000805772;
CosineWholeOddTracker[3][9]=0.000625486;
CosineWholeOddTracker[4][9]=0.000464529;
 
SineWholeOddTracker[0][9]=0.00102822;
SineWholeOddTracker[1][9]=-8.65189e-05;
SineWholeOddTracker[2][9]=-0.000406718;
SineWholeOddTracker[3][9]=-0.00125009;
SineWholeOddTracker[4][9]=-0.00079516;
 
 
//Pos Tracker
CosinePosOddTracker[0][0]=0.0160943;
CosinePosOddTracker[1][0]=0.0154606;
CosinePosOddTracker[2][0]=0.0143733;
CosinePosOddTracker[3][0]=0.0138361;
CosinePosOddTracker[4][0]=0.0128847;
 
SinePosOddTracker[0][0]=0.0578821;
SinePosOddTracker[1][0]=0.0532183;
SinePosOddTracker[2][0]=0.0485035;
SinePosOddTracker[3][0]=0.0450244;
SinePosOddTracker[4][0]=0.0400582;
 
CosinePosOddTracker[0][1]=-0.031401;
CosinePosOddTracker[1][1]=-0.0276336;
CosinePosOddTracker[2][1]=-0.0259318;
CosinePosOddTracker[3][1]=-0.0230095;
CosinePosOddTracker[4][1]=-0.0211234;
 
SinePosOddTracker[0][1]=0.00904823;
SinePosOddTracker[1][1]=0.00559912;
SinePosOddTracker[2][1]=0.00135111;
SinePosOddTracker[3][1]=-0.00124751;
SinePosOddTracker[4][1]=-0.00530219;
 
CosinePosOddTracker[0][2]=-0.00806684;
CosinePosOddTracker[1][2]=-0.00673434;
CosinePosOddTracker[2][2]=-0.0052156;
CosinePosOddTracker[3][2]=-0.00472835;
CosinePosOddTracker[4][2]=-0.00333447;
 
SinePosOddTracker[0][2]=-0.0220548;
SinePosOddTracker[1][2]=-0.0200743;
SinePosOddTracker[2][2]=-0.0191896;
SinePosOddTracker[3][2]=-0.0168445;
SinePosOddTracker[4][2]=-0.014783;
 
CosinePosOddTracker[0][3]=0.011835;
CosinePosOddTracker[1][3]=0.0121191;
CosinePosOddTracker[2][3]=0.00991162;
CosinePosOddTracker[3][3]=0.00906256;
CosinePosOddTracker[4][3]=0.00828092;
 
SinePosOddTracker[0][3]=-0.00705599;
SinePosOddTracker[1][3]=-0.00686899;
SinePosOddTracker[2][3]=-0.00655301;
SinePosOddTracker[3][3]=-0.0054811;
SinePosOddTracker[4][3]=-0.00523684;
 
CosinePosOddTracker[0][4]=0.00664127;
CosinePosOddTracker[1][4]=0.0057956;
CosinePosOddTracker[2][4]=0.00556986;
CosinePosOddTracker[3][4]=0.00521562;
CosinePosOddTracker[4][4]=0.00414737;
 
SinePosOddTracker[0][4]=0.00956338;
SinePosOddTracker[1][4]=0.00791105;
SinePosOddTracker[2][4]=0.00794448;
SinePosOddTracker[3][4]=0.00638204;
SinePosOddTracker[4][4]=0.00622257;
 
CosinePosOddTracker[0][5]=-0.00716435;
CosinePosOddTracker[1][5]=-0.00589047;
CosinePosOddTracker[2][5]=-0.00581225;
CosinePosOddTracker[3][5]=-0.00484255;
CosinePosOddTracker[4][5]=-0.00601997;
 
SinePosOddTracker[0][5]=0.00549115;
SinePosOddTracker[1][5]=0.00514194;
SinePosOddTracker[2][5]=0.00474016;
SinePosOddTracker[3][5]=0.00388054;
SinePosOddTracker[4][5]=0.00380661;
 
CosinePosOddTracker[0][6]=-0.00650554;
CosinePosOddTracker[1][6]=-0.00559974;
CosinePosOddTracker[2][6]=-0.00464765;
CosinePosOddTracker[3][6]=-0.00526531;
CosinePosOddTracker[4][6]=-0.00552459;
 
SinePosOddTracker[0][6]=-0.0069679;
SinePosOddTracker[1][6]=-0.00469327;
SinePosOddTracker[2][6]=-0.00471731;
SinePosOddTracker[3][6]=-0.00400287;
SinePosOddTracker[4][6]=-0.00528176;
 
CosinePosOddTracker[0][7]=0.00412235;
CosinePosOddTracker[1][7]=0.00406269;
CosinePosOddTracker[2][7]=0.00316323;
CosinePosOddTracker[3][7]=0.00379395;
CosinePosOddTracker[4][7]=0.00440964;
 
SinePosOddTracker[0][7]=-0.00640713;
SinePosOddTracker[1][7]=-0.00436908;
SinePosOddTracker[2][7]=-0.00530457;
SinePosOddTracker[3][7]=-0.00508229;
SinePosOddTracker[4][7]=-0.00503048;
 
CosinePosOddTracker[0][8]=0.00487097;
CosinePosOddTracker[1][8]=0.00594413;
CosinePosOddTracker[2][8]=0.00487161;
CosinePosOddTracker[3][8]=0.00564624;
CosinePosOddTracker[4][8]=0.00598143;
 
SinePosOddTracker[0][8]=0.00445291;
SinePosOddTracker[1][8]=0.00357782;
SinePosOddTracker[2][8]=0.00201567;
SinePosOddTracker[3][8]=0.00307046;
SinePosOddTracker[4][8]=0.00309013;
 
CosinePosOddTracker[0][9]=-0.00302757;
CosinePosOddTracker[1][9]=-0.00232862;
CosinePosOddTracker[2][9]=-0.00183014;
CosinePosOddTracker[3][9]=-0.0028956;
CosinePosOddTracker[4][9]=-0.00097146;
 
SinePosOddTracker[0][9]=0.00629914;
SinePosOddTracker[1][9]=0.00510929;
SinePosOddTracker[2][9]=0.00506154;
SinePosOddTracker[3][9]=0.00536389;
SinePosOddTracker[4][9]=0.00626016;
 
 
//Neg Tracker
CosineNegOddTracker[0][0]=-0.0300799;
CosineNegOddTracker[1][0]=-0.0261944;
CosineNegOddTracker[2][0]=-0.0230385;
CosineNegOddTracker[3][0]=-0.0203864;
CosineNegOddTracker[4][0]=-0.0181889;
 
SineNegOddTracker[0][0]=-0.0294814;
SineNegOddTracker[1][0]=-0.0253334;
SineNegOddTracker[2][0]=-0.0229896;
SineNegOddTracker[3][0]=-0.0216825;
SineNegOddTracker[4][0]=-0.0187246;
 
CosineNegOddTracker[0][1]=-0.0119142;
CosineNegOddTracker[1][1]=-0.0108232;
CosineNegOddTracker[2][1]=-0.0095585;
CosineNegOddTracker[3][1]=-0.0092481;
CosineNegOddTracker[4][1]=-0.0087971;
 
SineNegOddTracker[0][1]=0.0152306;
SineNegOddTracker[1][1]=0.00617064;
SineNegOddTracker[2][1]=0.00190065;
SineNegOddTracker[3][1]=-0.00209357;
SineNegOddTracker[4][1]=-0.00589313;
 
CosineNegOddTracker[0][2]=0.0120569;
CosineNegOddTracker[1][2]=0.00966479;
CosineNegOddTracker[2][2]=0.00655566;
CosineNegOddTracker[3][2]=0.00601145;
CosineNegOddTracker[4][2]=0.00540839;
 
SineNegOddTracker[0][2]=0.00401355;
SineNegOddTracker[1][2]=0.00373293;
SineNegOddTracker[2][2]=0.00377929;
SineNegOddTracker[3][2]=0.00274034;
SineNegOddTracker[4][2]=0.00193836;
 
CosineNegOddTracker[0][3]=-0.00116352;
CosineNegOddTracker[1][3]=-0.00101978;
CosineNegOddTracker[2][3]=-0.000842247;
CosineNegOddTracker[3][3]=-0.00162206;
CosineNegOddTracker[4][3]=-0.00122679;
 
SineNegOddTracker[0][3]=-0.00774209;
SineNegOddTracker[1][3]=-0.00664275;
SineNegOddTracker[2][3]=-0.00529261;
SineNegOddTracker[3][3]=-0.00474571;
SineNegOddTracker[4][3]=-0.00422987;
 
CosineNegOddTracker[0][4]=-0.00464394;
CosineNegOddTracker[1][4]=-0.00431199;
CosineNegOddTracker[2][4]=-0.00393866;
CosineNegOddTracker[3][4]=-0.00224447;
CosineNegOddTracker[4][4]=-0.0037537;
 
SineNegOddTracker[0][4]=0.00414643;
SineNegOddTracker[1][4]=0.00199316;
SineNegOddTracker[2][4]=0.00345705;
SineNegOddTracker[3][4]=0.0036654;
SineNegOddTracker[4][4]=0.00216099;
 
CosineNegOddTracker[0][5]=0.00442997;
CosineNegOddTracker[1][5]=0.00461311;
CosineNegOddTracker[2][5]=0.00221998;
CosineNegOddTracker[3][5]=0.00321169;
CosineNegOddTracker[4][5]=0.00267972;
 
SineNegOddTracker[0][5]=0.00215008;
SineNegOddTracker[1][5]=0.0017534;
SineNegOddTracker[2][5]=0.000708969;
SineNegOddTracker[3][5]=0.00200095;
SineNegOddTracker[4][5]=0.00146044;
 
CosineNegOddTracker[0][6]=0.000401858;
CosineNegOddTracker[1][6]=-0.000340786;
CosineNegOddTracker[2][6]=-3.50411e-05;
CosineNegOddTracker[3][6]=-0.000639679;
CosineNegOddTracker[4][6]=-0.000308786;
 
SineNegOddTracker[0][6]=-0.00300298;
SineNegOddTracker[1][6]=-0.00315681;
SineNegOddTracker[2][6]=-0.00348086;
SineNegOddTracker[3][6]=-0.00321096;
SineNegOddTracker[4][6]=-0.00496406;
 
CosineNegOddTracker[0][7]=-0.00316793;
CosineNegOddTracker[1][7]=-0.00234405;
CosineNegOddTracker[2][7]=-0.00235887;
CosineNegOddTracker[3][7]=-0.00279832;
CosineNegOddTracker[4][7]=-0.00256873;
 
SineNegOddTracker[0][7]=0.00153713;
SineNegOddTracker[1][7]=0.00196094;
SineNegOddTracker[2][7]=0.00115732;
SineNegOddTracker[3][7]=0.00160312;
SineNegOddTracker[4][7]=0.00183112;
 
CosineNegOddTracker[0][8]=0.00211554;
CosineNegOddTracker[1][8]=0.00202481;
CosineNegOddTracker[2][8]=0.00203893;
CosineNegOddTracker[3][8]=0.00232388;
CosineNegOddTracker[4][8]=0.00169507;
 
SineNegOddTracker[0][8]=0.0015237;
SineNegOddTracker[1][8]=0.002183;
SineNegOddTracker[2][8]=0.00163614;
SineNegOddTracker[3][8]=0.00119981;
SineNegOddTracker[4][8]=0.000836204;
 
CosineNegOddTracker[0][9]=0.00127192;
CosineNegOddTracker[1][9]=0.000553525;
CosineNegOddTracker[2][9]=0.00090448;
CosineNegOddTracker[3][9]=-0.000137761;
CosineNegOddTracker[4][9]=8.22555e-05;
 
SineNegOddTracker[0][9]=-0.00258992;
SineNegOddTracker[1][9]=-0.00314189;
SineNegOddTracker[2][9]=-0.00179472;
SineNegOddTracker[3][9]=-0.00202992;
SineNegOddTracker[4][9]=-0.00338904;
 
 
//Mid Tracker
CosineMidOddTracker[0][0]=-0.00136032;
CosineMidOddTracker[1][0]=-0.000514703;
CosineMidOddTracker[2][0]=0.000102162;
CosineMidOddTracker[3][0]=0.000176417;
CosineMidOddTracker[4][0]=5.23564e-05;
 
SineMidOddTracker[0][0]=0.0035174;
SineMidOddTracker[1][0]=0.00265014;
SineMidOddTracker[2][0]=0.0018923;
SineMidOddTracker[3][0]=0.00109103;
SineMidOddTracker[4][0]=0.000771608;
 
CosineMidOddTracker[0][1]=0.00055188;
CosineMidOddTracker[1][1]=0.000319214;
CosineMidOddTracker[2][1]=-5.02272e-05;
CosineMidOddTracker[3][1]=-0.000101436;
CosineMidOddTracker[4][1]=0.000428996;
 
SineMidOddTracker[0][1]=-0.0200424;
SineMidOddTracker[1][1]=-0.0145322;
SineMidOddTracker[2][1]=-0.0117249;
SineMidOddTracker[3][1]=-0.00831379;
SineMidOddTracker[4][1]=-0.00601192;
 
CosineMidOddTracker[0][2]=-0.00246468;
CosineMidOddTracker[1][2]=-0.00167515;
CosineMidOddTracker[2][2]=-0.000787238;
CosineMidOddTracker[3][2]=-0.000698699;
CosineMidOddTracker[4][2]=0.00108482;
 
SineMidOddTracker[0][2]=-0.00225415;
SineMidOddTracker[1][2]=-0.000956813;
SineMidOddTracker[2][2]=-0.00166045;
SineMidOddTracker[3][2]=-0.00021813;
SineMidOddTracker[4][2]=-0.000542667;
 
CosineMidOddTracker[0][3]=-0.000520468;
CosineMidOddTracker[1][3]=-0.000662795;
CosineMidOddTracker[2][3]=-0.000515938;
CosineMidOddTracker[3][3]=-0.00058376;
CosineMidOddTracker[4][3]=4.62272e-06;
 
SineMidOddTracker[0][3]=6.69212e-05;
SineMidOddTracker[1][3]=-0.000496131;
SineMidOddTracker[2][3]=-0.000968207;
SineMidOddTracker[3][3]=1.94964e-05;
SineMidOddTracker[4][3]=-0.000810049;
 
CosineMidOddTracker[0][4]=-0.000899947;
CosineMidOddTracker[1][4]=-0.000896362;
CosineMidOddTracker[2][4]=-3.67849e-05;
CosineMidOddTracker[3][4]=3.31412e-05;
CosineMidOddTracker[4][4]=-0.000593361;
 
SineMidOddTracker[0][4]=-0.00060541;
SineMidOddTracker[1][4]=-0.000313512;
SineMidOddTracker[2][4]=-0.000593868;
SineMidOddTracker[3][4]=6.45297e-05;
SineMidOddTracker[4][4]=-0.000355131;
 
CosineMidOddTracker[0][5]=-0.000245561;
CosineMidOddTracker[1][5]=-0.000362155;
CosineMidOddTracker[2][5]=-0.000238101;
CosineMidOddTracker[3][5]=0.00022737;
CosineMidOddTracker[4][5]=0.000700072;
 
SineMidOddTracker[0][5]=0.000534766;
SineMidOddTracker[1][5]=0.00138395;
SineMidOddTracker[2][5]=0.000769449;
SineMidOddTracker[3][5]=0.000638932;
SineMidOddTracker[4][5]=6.89581e-05;
 
CosineMidOddTracker[0][6]=-0.000646651;
CosineMidOddTracker[1][6]=-0.0011919;
CosineMidOddTracker[2][6]=-0.00149603;
CosineMidOddTracker[3][6]=-2.50902e-05;
CosineMidOddTracker[4][6]=0.000782738;
 
SineMidOddTracker[0][6]=-0.00099125;
SineMidOddTracker[1][6]=-9.3071e-05;
SineMidOddTracker[2][6]=3.0278e-05;
SineMidOddTracker[3][6]=-0.000247781;
SineMidOddTracker[4][6]=-0.000359497;
 
CosineMidOddTracker[0][7]=-0.000321788;
CosineMidOddTracker[1][7]=0.000239633;
CosineMidOddTracker[2][7]=0.000517251;
CosineMidOddTracker[3][7]=0.000135396;
CosineMidOddTracker[4][7]=-0.000359287;
 
SineMidOddTracker[0][7]=-0.00106;
SineMidOddTracker[1][7]=-0.0014412;
SineMidOddTracker[2][7]=-0.000760035;
SineMidOddTracker[3][7]=-0.00037818;
SineMidOddTracker[4][7]=0.000360976;
 
CosineMidOddTracker[0][8]=0.000827264;
CosineMidOddTracker[1][8]=0.000643238;
CosineMidOddTracker[2][8]=0.00123341;
CosineMidOddTracker[3][8]=9.97776e-05;
CosineMidOddTracker[4][8]=0.000599215;
 
SineMidOddTracker[0][8]=0.00068514;
SineMidOddTracker[1][8]=0.000452909;
SineMidOddTracker[2][8]=0.000654714;
SineMidOddTracker[3][8]=-0.000350454;
SineMidOddTracker[4][8]=-0.000529315;
 
CosineMidOddTracker[0][9]=2.25616e-05;
CosineMidOddTracker[1][9]=7.55278e-05;
CosineMidOddTracker[2][9]=-0.000151891;
CosineMidOddTracker[3][9]=2.28064e-05;
CosineMidOddTracker[4][9]=0.00010001;
 
SineMidOddTracker[0][9]=0.000115492;
SineMidOddTracker[1][9]=-0.000425988;
SineMidOddTracker[2][9]=-0.000178649;
SineMidOddTracker[3][9]=-0.000131162;
SineMidOddTracker[4][9]=-0.00102708;
 

}//End of Fill Angular Corrections Function

void FillFlowVectors(){
Xav_wholetracker[0]=-4.84487;
Xstdev_wholetracker[0]=13.1063;
Yav_wholetracker[0]=-16.0371;
Ystdev_wholetracker[0]=13.6161;
Xav_wholetracker[1]=-3.2999;
Xstdev_wholetracker[1]=10.8185;
Yav_wholetracker[1]=-10.6992;
Ystdev_wholetracker[1]=11.0679;
Xav_wholetracker[2]=-2.23426;
Xstdev_wholetracker[2]=8.82419;
Yav_wholetracker[2]=-7.15104;
Ystdev_wholetracker[2]=8.96783;
Xav_wholetracker[3]=-1.45951;
Xstdev_wholetracker[3]=7.03465;
Yav_wholetracker[3]=-4.62467;
Ystdev_wholetracker[3]=7.10329;
Xav_wholetracker[4]=-0.958501;
Xstdev_wholetracker[4]=5.60661;
Yav_wholetracker[4]=-3.01343;
Ystdev_wholetracker[4]=5.62808;
 
Xav_postracker[0]=-0.761711;
Xstdev_postracker[0]=8.94647;
Yav_postracker[0]=-7.52428;
Ystdev_postracker[0]=9.4351;
Xav_postracker[1]=-0.555788;
Xstdev_postracker[1]=7.4081;
Yav_postracker[1]=-5.05865;
Ystdev_postracker[1]=7.66367;
Xav_postracker[2]=-0.392311;
Xstdev_postracker[2]=6.06921;
Yav_postracker[2]=-3.39664;
Ystdev_postracker[2]=6.19938;
Xav_postracker[3]=-0.263004;
Xstdev_postracker[3]=4.85936;
Yav_postracker[3]=-2.20618;
Ystdev_postracker[3]=4.91679;
Xav_postracker[4]=-0.177176;
Xstdev_postracker[4]=3.88732;
Yav_postracker[4]=-1.43562;
Ystdev_postracker[4]=3.90829;
 
Xav_negtracker[0]=-3.98673;
Xstdev_negtracker[0]=9.31358;
Yav_negtracker[0]=-8.47699;
Ystdev_negtracker[0]=9.3987;
Xav_negtracker[1]=-2.67571;
Xstdev_negtracker[1]=7.66964;
Yav_negtracker[1]=-5.61605;
Ystdev_negtracker[1]=7.7044;
Xav_negtracker[2]=-1.79725;
Xstdev_negtracker[2]=6.26766;
Yav_negtracker[2]=-3.73901;
Ystdev_negtracker[2]=6.28452;
Xav_negtracker[3]=-1.16729;
Xstdev_negtracker[3]=4.99986;
Yav_negtracker[3]=-2.40886;
Ystdev_negtracker[3]=5.00801;
Xav_negtracker[4]=-0.763317;
Xstdev_negtracker[4]=3.99492;
Yav_negtracker[4]=-1.57188;
Ystdev_negtracker[4]=3.99258;
 
Xav_midtracker[0]=-4.73353;
Xstdev_midtracker[0]=15.7552;
Yav_midtracker[0]=-3.15126;
Ystdev_midtracker[0]=16.3682;
Xav_midtracker[1]=-3.29285;
Xstdev_midtracker[1]=12.9857;
Yav_midtracker[1]=-2.12195;
Ystdev_midtracker[1]=13.3005;
Xav_midtracker[2]=-2.27055;
Xstdev_midtracker[2]=10.5592;
Yav_midtracker[2]=-1.46524;
Ystdev_midtracker[2]=10.6775;
Xav_midtracker[3]=-1.49621;
Xstdev_midtracker[3]=8.34597;
Yav_midtracker[3]=-0.959611;
Ystdev_midtracker[3]=8.36222;
Xav_midtracker[4]=-0.985219;
Xstdev_midtracker[4]=6.59827;
Yav_midtracker[4]=-0.635531;
Ystdev_midtracker[4]=6.57007;
 
Xav_wholeoddtracker[0]=3.2692;
Xstdev_wholeoddtracker[0]=12.7244;
Yav_wholeoddtracker[0]=1.24616;
Ystdev_wholeoddtracker[0]=13.0033;
Xav_wholeoddtracker[1]=2.15257;
Xstdev_wholeoddtracker[1]=10.5092;
Yav_wholeoddtracker[1]=0.769366;
Ystdev_wholeoddtracker[1]=10.6573;
Xav_wholeoddtracker[2]=1.42732;
Xstdev_wholeoddtracker[2]=8.6265;
Yav_wholeoddtracker[2]=0.483193;
Ystdev_wholeoddtracker[2]=8.68304;
Xav_wholeoddtracker[3]=0.919759;
Xstdev_wholeoddtracker[3]=6.91107;
Yav_wholeoddtracker[3]=0.296287;
Ystdev_wholeoddtracker[3]=6.93163;
Xav_wholeoddtracker[4]=0.596165;
Xstdev_wholeoddtracker[4]=5.54264;
Yav_wholeoddtracker[4]=0.195088;
Ystdev_wholeoddtracker[4]=5.54589;
 
Xav_posoddtracker[0]=-0.761711;
Xstdev_posoddtracker[0]=8.94647;
Yav_posoddtracker[0]=-7.52428;
Ystdev_posoddtracker[0]=9.4351;
Xav_posoddtracker[1]=-0.555788;
Xstdev_posoddtracker[1]=7.4081;
Yav_posoddtracker[1]=-5.05865;
Ystdev_posoddtracker[1]=7.66367;
Xav_posoddtracker[2]=-0.392311;
Xstdev_posoddtracker[2]=6.06921;
Yav_posoddtracker[2]=-3.39664;
Ystdev_posoddtracker[2]=6.19938;
Xav_posoddtracker[3]=-0.263004;
Xstdev_posoddtracker[3]=4.85936;
Yav_posoddtracker[3]=-2.20618;
Ystdev_posoddtracker[3]=4.91679;
Xav_posoddtracker[4]=-0.177176;
Xstdev_posoddtracker[4]=3.88732;
Yav_posoddtracker[4]=-1.43562;
Ystdev_posoddtracker[4]=3.90829;
 
Xav_negoddtracker[0]=3.98673;
Xstdev_negoddtracker[0]=9.31358;
Yav_negoddtracker[0]=8.47699;
Ystdev_negoddtracker[0]=9.3987;
Xav_negoddtracker[1]=2.67571;
Xstdev_negoddtracker[1]=7.66964;
Yav_negoddtracker[1]=5.61605;
Ystdev_negoddtracker[1]=7.7044;
Xav_negoddtracker[2]=1.79725;
Xstdev_negoddtracker[2]=6.26766;
Yav_negoddtracker[2]=3.73901;
Ystdev_negoddtracker[2]=6.28452;
Xav_negoddtracker[3]=1.16729;
Xstdev_negoddtracker[3]=4.99986;
Yav_negoddtracker[3]=2.40886;
Ystdev_negoddtracker[3]=5.00801;
Xav_negoddtracker[4]=0.763317;
Xstdev_negoddtracker[4]=3.99492;
Yav_negoddtracker[4]=1.57188;
Ystdev_negoddtracker[4]=3.99258;
 
Xav_midoddtracker[0]=0.0287916;
Xstdev_midoddtracker[0]=14.3937;
Yav_midoddtracker[0]=-1.98145;
Ystdev_midoddtracker[0]=14.4796;
Xav_midoddtracker[1]=0.0345146;
Xstdev_midoddtracker[1]=11.9206;
Yav_midoddtracker[1]=-1.37251;
Ystdev_midoddtracker[1]=11.9139;
Xav_midoddtracker[2]=0.02813;
Xstdev_midoddtracker[2]=9.75759;
Yav_midoddtracker[2]=-0.912018;
Ystdev_midoddtracker[2]=9.71482;
Xav_midoddtracker[3]=0.0250889;
Xstdev_midoddtracker[3]=7.79503;
Yav_midoddtracker[3]=-0.585506;
Ystdev_midoddtracker[3]=7.73546;
Xav_midoddtracker[4]=0.0165479;
Xstdev_midoddtracker[4]=6.23363;
Yav_midoddtracker[4]=-0.367136;
Ystdev_midoddtracker[4]=6.17135;
 

}//End of fill flowvectors function

+EOF
