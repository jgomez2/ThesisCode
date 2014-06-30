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
TH1F *PsiEvenFinal[nCent];
   //Pos Tracker
TH1F *PsiPEvenRaw[nCent];
TH1F *PsiPEvenFinal[nCent];
   //Neg Tracker
TH1F *PsiNEvenRaw[nCent];
TH1F *PsiNEvenFinal[nCent];
   //Mid Tracker
TH1F *PsiMEvenRaw[nCent];
TH1F *PsiMEvenFinal[nCent];

//Odd
  //Whole Tracker 
TH1F *PsiOddRaw[nCent];
TH1F *PsiOddFinal[nCent];
   //Pos Tracker
TH1F *PsiPOddRaw[nCent];
TH1F *PsiPOddFinal[nCent];
   //Neg Tracker
TH1F *PsiNOddRaw[nCent];
TH1F *PsiNOddFinal[nCent];
   //Mid Tracker
TH1F *PsiMOddRaw[nCent];
TH1F *PsiMOddFinal[nCent];
/////////////////////////////////////////
/// Variables that are used in the //////
// Flow Analysis function////////////////
/////////////////////////////////////////

//RAW EP's
Float_t EPwholetracker=0.,EPpostracker=0.,EPnegtracker=0.,EPmidtracker=0.,
  EPwholeoddtracker=0.,EPposoddtracker=0.,EPnegoddtracker=0.,EPmidoddtracker=0.;


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


/////////////////
///FLOW PLOTS////
////////////////
TProfile *V1EtaOdd[nCent];
TProfile *V1EtaEven[nCent];
TProfile *V1PtEven[nCent];
TProfile *V1PtOdd[nCent];

///////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////
/////////////////// END OF GLOBAL VARIABLES ///////////////////////
///////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////

//Running the Macro
Int_t TRV1EPPlotting_${1}(){//put functions in here
  Initialize();
  FillPTStats();
  FillAngularCorrections();
  FlowAnalysis();
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
  char epevenfinalname[128],epevenfinaltitle[128];
  //Pos Tracker
  char pevenrawname[128],pevenrawtitle[128];
  char pevenfinalname[128],pevenfinaltitle[128];
  //Neg Tracker
  char nevenrawname[128],nevenrawtitle[128];
  char nevenfinalname[128],nevenfinaltitle[128];
  //Mid Tracker
  char mevenrawname[128],mevenrawtitle[128];
  char mevenfinalname[128],mevenfinaltitle[128];

  //Psi1(odd)
  //Whole Tracker
  char epoddrawname[128],epoddrawtitle[128];
  char epoddfinalname[128],epoddfinaltitle[128];
  //Pos Tracker
  char poddrawname[128],poddrawtitle[128];
  char poddfinalname[128],poddfinaltitle[128];
  //Neg Tracker
  char noddrawname[128],noddrawtitle[128];
  char noddfinalname[128],noddfinaltitle[128];
  //Mid Tracker
  char moddrawname[128],moddrawtitle[128];
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



     }//end of centrality loop
}//end of initialize function

void FillPTStats(){

//Whole Tracker
ptavwhole[0]=0.941351;
ptavwhole[1]=0.951032;
ptavwhole[2]=0.95263;
ptavwhole[3]=0.947478;
ptavwhole[4]=0.937569;
 
pt2avwhole[0]=1.19736;
pt2avwhole[1]=1.22518;
pt2avwhole[2]=1.23526;
pt2avwhole[3]=1.23014;
pt2avwhole[4]=1.21337;
 
//Positive Tracker
ptavpos[0]=0.948274;
ptavpos[1]=0.958461;
ptavpos[2]=0.960167;
ptavpos[3]=0.954984;
ptavpos[4]=0.944996;
 
pt2avpos[0]=1.21445;
pt2avpos[1]=1.24371;
pt2avpos[2]=1.25415;
pt2avpos[3]=1.24917;
pt2avpos[4]=1.23214;
 
//Negative Tracker
ptavneg[0]=0.934988;
ptavneg[1]=0.944227;
ptavneg[2]=0.945735;
ptavneg[3]=0.940621;
ptavneg[4]=0.930783;
 
pt2avneg[0]=1.18166;
pt2avneg[1]=1.20821;
pt2avneg[2]=1.21797;
pt2avneg[3]=1.21275;
pt2avneg[4]=1.19621;
 
//Mid Tracker
ptavmid[0]=0.777191;
ptavmid[1]=0.781748;
ptavmid[2]=0.780175;
ptavmid[3]=0.773304;
ptavmid[4]=0.762743;
 
pt2avmid[0]=0.866207;
pt2avmid[1]=0.881687;
pt2avmid[2]=0.883832;
pt2avmid[3]=0.874966;
pt2avmid[4]=0.857524;
 

 

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
          EPfinalwholetracker=EPwholetracker+AngularCorrectionWholeTracker;
          if (EPfinalwholetracker>(pi)) EPfinalwholetracker=(EPfinalwholetracker-(TMath::TwoPi()));
          if (EPfinalwholetracker<(-1.0*(pi))) EPfinalwholetracker=(EPfinalwholetracker+(TMath::TwoPi()));
          PsiEvenFinal[c]->Fill(EPfinalwholetracker);

          //Pos Tracker
          EPfinalpostracker=EPpostracker+AngularCorrectionPosTracker;
          if (EPfinalpostracker>(pi)) EPfinalpostracker=(EPfinalpostracker-(TMath::TwoPi()));
          if (EPfinalpostracker<(-1.0*(pi))) EPfinalpostracker=(EPfinalpostracker+(TMath::TwoPi()));
          PsiPEvenFinal[c]->Fill(EPfinalpostracker);

          //Neg Tracker
          EPfinalnegtracker=EPnegtracker+AngularCorrectionNegTracker;
          //if(c==2) std::cout<<EPfinalnegtracker<<std::endl;
          if (EPfinalnegtracker>(pi)) EPfinalnegtracker=(EPfinalnegtracker-(TMath::TwoPi()));
          if (EPfinalnegtracker<(-1.0*(pi))) EPfinalnegtracker=(EPfinalnegtracker+(TMath::TwoPi()));
          PsiNEvenFinal[c]->Fill(EPfinalnegtracker);


          //Mid Tracker
          EPfinalmidtracker=EPmidtracker+AngularCorrectionMidTracker;
          if (EPfinalmidtracker>(pi)) EPfinalmidtracker=(EPfinalmidtracker-(TMath::TwoPi()));
          if (EPfinalmidtracker<(-1.0*(pi))) EPfinalmidtracker=(EPfinalmidtracker+(TMath::TwoPi()));
          PsiMEvenFinal[c]->Fill(EPfinalmidtracker);

          //v1 odd
          //Whole Tracker
          EPfinalwholeoddtracker=EPwholeoddtracker+AngularCorrectionWholeOddTracker;
          if (EPfinalwholeoddtracker>(pi)) EPfinalwholeoddtracker=(EPfinalwholeoddtracker-(TMath::TwoPi()));
          if (EPfinalwholeoddtracker<(-1.0*(pi))) EPfinalwholeoddtracker=(EPfinalwholeoddtracker+(TMath::TwoPi()));
          PsiOddFinal[c]->Fill(EPfinalwholeoddtracker);

          //Pos Tracker
          EPfinalposoddtracker=EPposoddtracker+AngularCorrectionPosOddTracker;
          if (EPfinalposoddtracker>(pi)) EPfinalposoddtracker=(EPfinalposoddtracker-(TMath::TwoPi()));
          if (EPfinalposoddtracker<(-1.0*(pi))) EPfinalposoddtracker=(EPfinalposoddtracker+(TMath::TwoPi()));
          PsiPOddFinal[c]->Fill(EPfinalposoddtracker);


          //Neg Tracker
          EPfinalnegoddtracker=EPnegoddtracker+AngularCorrectionNegOddTracker;
          //if(c==2) std::cout<<EPfinalnegtracker<<std::endl;
          if (EPfinalnegoddtracker>(pi)) EPfinalnegoddtracker=(EPfinalnegoddtracker-(TMath::TwoPi()));
          if (EPfinalnegoddtracker<(-1.0*(pi))) EPfinalnegoddtracker=(EPfinalnegoddtracker+(TMath::TwoPi()));
          PsiNOddFinal[c]->Fill(EPfinalnegoddtracker);


          //Mid Tracker
          EPfinalmidoddtracker=EPmidoddtracker+AngularCorrectionMidOddTracker;
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
  myFile->Write();
}//End of Flow Analysis Function

void FillAngularCorrections(){

//V1 Even
//Whole Tracker
CosineWholeTracker[0][0]=-0.195941;
CosineWholeTracker[1][0]=-0.171279;
CosineWholeTracker[2][0]=-0.148333;
CosineWholeTracker[3][0]=-0.125194;
CosineWholeTracker[4][0]=-0.106322;
 
SineWholeTracker[0][0]=-0.630792;
SineWholeTracker[1][0]=-0.544405;
SineWholeTracker[2][0]=-0.466305;
SineWholeTracker[3][0]=-0.392479;
SineWholeTracker[4][0]=-0.329348;
 
CosineWholeTracker[0][1]=-0.265566;
CosineWholeTracker[1][1]=-0.190818;
CosineWholeTracker[2][1]=-0.137362;
CosineWholeTracker[3][1]=-0.0945397;
CosineWholeTracker[4][1]=-0.0649855;
 
SineWholeTracker[0][1]=0.168478;
SineWholeTracker[1][1]=0.119549;
SineWholeTracker[2][1]=0.0823017;
SineWholeTracker[3][1]=0.0547704;
SineWholeTracker[4][1]=0.0338766;
 
CosineWholeTracker[0][2]=0.0875491;
CosineWholeTracker[1][2]=0.0485458;
CosineWholeTracker[2][2]=0.0262575;
CosineWholeTracker[3][2]=0.0141028;
CosineWholeTracker[4][2]=0.00487534;
 
SineWholeTracker[0][2]=0.0871112;
SineWholeTracker[1][2]=0.0523689;
SineWholeTracker[2][2]=0.0320211;
SineWholeTracker[3][2]=0.0179344;
SineWholeTracker[4][2]=0.0102986;
 
CosineWholeTracker[0][3]=0.0230571;
CosineWholeTracker[1][3]=0.0124118;
CosineWholeTracker[2][3]=0.00666628;
CosineWholeTracker[3][3]=0.00243791;
CosineWholeTracker[4][3]=0.00156609;
 
SineWholeTracker[0][3]=-0.0352143;
SineWholeTracker[1][3]=-0.015333;
SineWholeTracker[2][3]=-0.00818739;
SineWholeTracker[3][3]=-0.00370561;
SineWholeTracker[4][3]=-0.000271682;
 
CosineWholeTracker[0][4]=-0.012151;
CosineWholeTracker[1][4]=-0.00361651;
CosineWholeTracker[2][4]=-0.0020993;
CosineWholeTracker[3][4]=-0.00144744;
CosineWholeTracker[4][4]=1.2991e-05;
 
SineWholeTracker[0][4]=-0.00497256;
SineWholeTracker[1][4]=-0.00306506;
SineWholeTracker[2][4]=-0.00142067;
SineWholeTracker[3][4]=0.000529658;
SineWholeTracker[4][4]=-0.000616212;
 
CosineWholeTracker[0][5]=-0.000871303;
CosineWholeTracker[1][5]=-4.74776e-05;
CosineWholeTracker[2][5]=-0.000957648;
CosineWholeTracker[3][5]=0.0013046;
CosineWholeTracker[4][5]=0.00018418;
 
SineWholeTracker[0][5]=0.00353394;
SineWholeTracker[1][5]=0.000791011;
SineWholeTracker[2][5]=0.00153441;
SineWholeTracker[3][5]=0.00114204;
SineWholeTracker[4][5]=-0.000258077;
 
CosineWholeTracker[0][6]=9.47015e-05;
CosineWholeTracker[1][6]=0.000305828;
CosineWholeTracker[2][6]=0.000634953;
CosineWholeTracker[3][6]=-0.000338346;
CosineWholeTracker[4][6]=0.000352359;
 
SineWholeTracker[0][6]=0.000648469;
SineWholeTracker[1][6]=-0.000125999;
SineWholeTracker[2][6]=0.00122232;
SineWholeTracker[3][6]=-0.000302539;
SineWholeTracker[4][6]=0.000145864;
 
CosineWholeTracker[0][7]=0.000811753;
CosineWholeTracker[1][7]=0.000280072;
CosineWholeTracker[2][7]=0.000999285;
CosineWholeTracker[3][7]=-0.000361783;
CosineWholeTracker[4][7]=-0.000206017;
 
SineWholeTracker[0][7]=0.000441856;
SineWholeTracker[1][7]=-0.000559209;
SineWholeTracker[2][7]=0.000260947;
SineWholeTracker[3][7]=3.67652e-05;
SineWholeTracker[4][7]=-0.000548012;
 
CosineWholeTracker[0][8]=0.00113407;
CosineWholeTracker[1][8]=-0.000190817;
CosineWholeTracker[2][8]=-5.50128e-05;
CosineWholeTracker[3][8]=0.000716251;
CosineWholeTracker[4][8]=3.18928e-05;
 
SineWholeTracker[0][8]=-0.00104123;
SineWholeTracker[1][8]=-0.00068816;
SineWholeTracker[2][8]=0.000905244;
SineWholeTracker[3][8]=0.000724437;
SineWholeTracker[4][8]=-0.00115814;
 
CosineWholeTracker[0][9]=-0.00030115;
CosineWholeTracker[1][9]=-8.44081e-05;
CosineWholeTracker[2][9]=-0.000775693;
CosineWholeTracker[3][9]=-0.000422202;
CosineWholeTracker[4][9]=2.47649e-05;
 
SineWholeTracker[0][9]=0.000254103;
SineWholeTracker[1][9]=5.04088e-05;
SineWholeTracker[2][9]=-0.000245153;
SineWholeTracker[3][9]=-0.000867952;
SineWholeTracker[4][9]=-0.000385594;
 
 
//Pos Tracker
CosinePosTracker[0][0]=-0.0398215;
CosinePosTracker[1][0]=-0.0349319;
CosinePosTracker[2][0]=-0.0298639;
CosinePosTracker[3][0]=-0.022839;
CosinePosTracker[4][0]=-0.0179032;
 
SinePosTracker[0][0]=-0.485246;
SinePosTracker[1][0]=-0.408552;
SinePosTracker[2][0]=-0.343188;
SinePosTracker[3][0]=-0.2854;
SinePosTracker[4][0]=-0.236337;
 
CosinePosTracker[0][1]=-0.167139;
CosinePosTracker[1][1]=-0.117062;
CosinePosTracker[2][1]=-0.0829112;
CosinePosTracker[3][1]=-0.0557497;
CosinePosTracker[4][1]=-0.0363794;
 
SinePosTracker[0][1]=0.0178996;
SinePosTracker[1][1]=0.00974576;
SinePosTracker[2][1]=0.00259923;
SinePosTracker[3][1]=-0.0013623;
SinePosTracker[4][1]=-0.00691617;
 
CosinePosTracker[0][2]=0.00774682;
CosinePosTracker[1][2]=0.00460031;
CosinePosTracker[2][2]=0.0022934;
CosinePosTracker[3][2]=0.00164511;
CosinePosTracker[4][2]=0.00216667;
 
SinePosTracker[0][2]=0.0510249;
SinePosTracker[1][2]=0.0296263;
SinePosTracker[2][2]=0.0186649;
SinePosTracker[3][2]=0.0102255;
SinePosTracker[4][2]=0.00652982;
 
CosinePosTracker[0][3]=0.0183942;
CosinePosTracker[1][3]=0.0112754;
CosinePosTracker[2][3]=0.00730525;
CosinePosTracker[3][3]=0.00602307;
CosinePosTracker[4][3]=0.0069952;
 
SinePosTracker[0][3]=0.000611972;
SinePosTracker[1][3]=0.00143888;
SinePosTracker[2][3]=3.60821e-05;
SinePosTracker[3][3]=0.0010772;
SinePosTracker[4][3]=0.00062934;
 
CosinePosTracker[0][4]=0.0039763;
CosinePosTracker[1][4]=0.00431541;
CosinePosTracker[2][4]=0.00397681;
CosinePosTracker[3][4]=0.00559089;
CosinePosTracker[4][4]=0.00712582;
 
SinePosTracker[0][4]=-0.00349598;
SinePosTracker[1][4]=-0.00223598;
SinePosTracker[2][4]=0.000276193;
SinePosTracker[3][4]=-0.000833386;
SinePosTracker[4][4]=0.000558858;
 
CosinePosTracker[0][5]=0.00234829;
CosinePosTracker[1][5]=0.00327496;
CosinePosTracker[2][5]=0.00559834;
CosinePosTracker[3][5]=0.00542212;
CosinePosTracker[4][5]=0.00515854;
 
SinePosTracker[0][5]=-0.000221433;
SinePosTracker[1][5]=0.000518143;
SinePosTracker[2][5]=0.000155616;
SinePosTracker[3][5]=-0.000280267;
SinePosTracker[4][5]=-0.000411774;
 
CosinePosTracker[0][6]=0.00317348;
CosinePosTracker[1][6]=0.0038314;
CosinePosTracker[2][6]=0.00349934;
CosinePosTracker[3][6]=0.00397844;
CosinePosTracker[4][6]=0.00705096;
 
SinePosTracker[0][6]=-0.000203035;
SinePosTracker[1][6]=0.00131883;
SinePosTracker[2][6]=0.00103539;
SinePosTracker[3][6]=0.000281867;
SinePosTracker[4][6]=0.000895861;
 
CosinePosTracker[0][7]=0.0033397;
CosinePosTracker[1][7]=0.00407045;
CosinePosTracker[2][7]=0.00421101;
CosinePosTracker[3][7]=0.00567335;
CosinePosTracker[4][7]=0.00649266;
 
SinePosTracker[0][7]=0.00096407;
SinePosTracker[1][7]=0.000844719;
SinePosTracker[2][7]=0.000880371;
SinePosTracker[3][7]=0.000127695;
SinePosTracker[4][7]=0.000523497;
 
CosinePosTracker[0][8]=0.00482005;
CosinePosTracker[1][8]=0.00512121;
CosinePosTracker[2][8]=0.00440174;
CosinePosTracker[3][8]=0.00567008;
CosinePosTracker[4][8]=0.00673237;
 
SinePosTracker[0][8]=0.000689846;
SinePosTracker[1][8]=-0.00098503;
SinePosTracker[2][8]=-0.000803084;
SinePosTracker[3][8]=-0.000752918;
SinePosTracker[4][8]=0.000654109;
 
CosinePosTracker[0][9]=0.00298277;
CosinePosTracker[1][9]=0.00475637;
CosinePosTracker[2][9]=0.00456898;
CosinePosTracker[3][9]=0.00451652;
CosinePosTracker[4][9]=0.00601516;
 
SinePosTracker[0][9]=-0.0011317;
SinePosTracker[1][9]=-0.00213401;
SinePosTracker[2][9]=-0.000464412;
SinePosTracker[3][9]=-0.000356904;
SinePosTracker[4][9]=-0.00125827;
 
 
//Neg Tracker
CosineNegTracker[0][0]=-0.239325;
CosineNegTracker[1][0]=-0.202809;
CosineNegTracker[2][0]=-0.171591;
CosineNegTracker[3][0]=-0.143371;
CosineNegTracker[4][0]=-0.119261;
 
SineNegTracker[0][0]=-0.53019;
SineNegTracker[1][0]=-0.447365;
SineNegTracker[2][0]=-0.376908;
SineNegTracker[3][0]=-0.313272;
SineNegTracker[4][0]=-0.26154;
 
CosineNegTracker[0][1]=-0.161431;
CosineNegTracker[1][1]=-0.112876;
CosineNegTracker[2][1]=-0.0786555;
CosineNegTracker[3][1]=-0.0540163;
CosineNegTracker[4][1]=-0.0367873;
 
SineNegTracker[0][1]=0.167193;
SineNegTracker[1][1]=0.112157;
SineNegTracker[2][1]=0.0732496;
SineNegTracker[3][1]=0.0455069;
SineNegTracker[4][1]=0.0260987;
 
CosineNegTracker[0][2]=0.0683369;
CosineNegTracker[1][2]=0.0362407;
CosineNegTracker[2][2]=0.0192858;
CosineNegTracker[3][2]=0.00904395;
CosineNegTracker[4][2]=0.0046841;
 
SineNegTracker[0][2]=0.033;
SineNegTracker[1][2]=0.022301;
SineNegTracker[2][2]=0.0132847;
SineNegTracker[3][2]=0.0106847;
SineNegTracker[4][2]=0.00796904;
 
CosineNegTracker[0][3]=0.00631441;
CosineNegTracker[1][3]=0.00635547;
CosineNegTracker[2][3]=0.00447883;
CosineNegTracker[3][3]=0.00409467;
CosineNegTracker[4][3]=0.00490156;
 
SineNegTracker[0][3]=-0.019948;
SineNegTracker[1][3]=-0.00945651;
SineNegTracker[2][3]=-0.00368587;
SineNegTracker[3][3]=-0.00183958;
SineNegTracker[4][3]=-0.00226005;
 
CosineNegTracker[0][4]=-0.00333114;
CosineNegTracker[1][4]=-0.000637433;
CosineNegTracker[2][4]=0.000623038;
CosineNegTracker[3][4]=0.00199228;
CosineNegTracker[4][4]=0.00166081;
 
SineNegTracker[0][4]=-0.000900817;
SineNegTracker[1][4]=-0.00128323;
SineNegTracker[2][4]=-0.000548345;
SineNegTracker[3][4]=0.000174611;
SineNegTracker[4][4]=-0.000700627;
 
CosineNegTracker[0][5]=0.000661505;
CosineNegTracker[1][5]=0.000818077;
CosineNegTracker[2][5]=0.00103643;
CosineNegTracker[3][5]=0.00168424;
CosineNegTracker[4][5]=0.00198791;
 
SineNegTracker[0][5]=0.00141307;
SineNegTracker[1][5]=-0.000655186;
SineNegTracker[2][5]=8.72254e-06;
SineNegTracker[3][5]=0.000419957;
SineNegTracker[4][5]=-0.000414695;
 
CosineNegTracker[0][6]=0.002442;
CosineNegTracker[1][6]=0.00145413;
CosineNegTracker[2][6]=0.001626;
CosineNegTracker[3][6]=0.00267304;
CosineNegTracker[4][6]=0.00334206;
 
SineNegTracker[0][6]=0.000540816;
SineNegTracker[1][6]=0.000948851;
SineNegTracker[2][6]=0.00101692;
SineNegTracker[3][6]=0.000453756;
SineNegTracker[4][6]=0.00019232;
 
CosineNegTracker[0][7]=0.00119561;
CosineNegTracker[1][7]=0.00186693;
CosineNegTracker[2][7]=0.00360472;
CosineNegTracker[3][7]=0.00233888;
CosineNegTracker[4][7]=0.00361355;
 
SineNegTracker[0][7]=-0.000517177;
SineNegTracker[1][7]=-0.00027005;
SineNegTracker[2][7]=-0.000390363;
SineNegTracker[3][7]=-0.00114677;
SineNegTracker[4][7]=-0.000505865;
 
CosineNegTracker[0][8]=0.00160947;
CosineNegTracker[1][8]=0.00191729;
CosineNegTracker[2][8]=0.000718786;
CosineNegTracker[3][8]=0.00112398;
CosineNegTracker[4][8]=0.00252956;
 
SineNegTracker[0][8]=0.000671305;
SineNegTracker[1][8]=0.000397114;
SineNegTracker[2][8]=-0.0012654;
SineNegTracker[3][8]=-0.0010097;
SineNegTracker[4][8]=-0.000631645;
 
CosineNegTracker[0][9]=0.00132918;
CosineNegTracker[1][9]=0.00129043;
CosineNegTracker[2][9]=0.00133495;
CosineNegTracker[3][9]=0.00152053;
CosineNegTracker[4][9]=0.00203854;
 
SineNegTracker[0][9]=-0.000266922;
SineNegTracker[1][9]=-0.000790028;
SineNegTracker[2][9]=0.00157291;
SineNegTracker[3][9]=0.00115661;
SineNegTracker[4][9]=-0.000119587;
 
 
//Mid Tracker
CosineMidTracker[0][0]=-0.187501;
CosineMidTracker[1][0]=-0.158209;
CosineMidTracker[2][0]=-0.134317;
CosineMidTracker[3][0]=-0.113126;
CosineMidTracker[4][0]=-0.0938056;
 
SineMidTracker[0][0]=-0.121532;
SineMidTracker[1][0]=-0.103291;
SineMidTracker[2][0]=-0.0891802;
SineMidTracker[3][0]=-0.0760329;
SineMidTracker[4][0]=-0.0645615;
 
CosineMidTracker[0][1]=-0.00646966;
CosineMidTracker[1][1]=-0.00300738;
CosineMidTracker[2][1]=0.000662653;
CosineMidTracker[3][1]=0.00313171;
CosineMidTracker[4][1]=0.00505862;
 
SineMidTracker[0][1]=0.00593189;
SineMidTracker[1][1]=0.00303974;
SineMidTracker[2][1]=0.00245723;
SineMidTracker[3][1]=0.00249491;
SineMidTracker[4][1]=0.000907074;
 
CosineMidTracker[0][2]=-0.00455435;
CosineMidTracker[1][2]=-0.00406463;
CosineMidTracker[2][2]=-0.00337345;
CosineMidTracker[3][2]=-0.0020084;
CosineMidTracker[4][2]=-0.00250104;
 
SineMidTracker[0][2]=0.00763389;
SineMidTracker[1][2]=0.00430876;
SineMidTracker[2][2]=0.00185169;
SineMidTracker[3][2]=0.000342102;
SineMidTracker[4][2]=-0.0018992;
 
CosineMidTracker[0][3]=0.00104016;
CosineMidTracker[1][3]=0.00132979;
CosineMidTracker[2][3]=0.000684886;
CosineMidTracker[3][3]=-0.000874323;
CosineMidTracker[4][3]=-0.00108338;
 
SineMidTracker[0][3]=0.000386144;
SineMidTracker[1][3]=-0.00071523;
SineMidTracker[2][3]=2.18739e-06;
SineMidTracker[3][3]=0.000299382;
SineMidTracker[4][3]=-9.88475e-05;
 
CosineMidTracker[0][4]=0.000195841;
CosineMidTracker[1][4]=-0.000585418;
CosineMidTracker[2][4]=0.000701064;
CosineMidTracker[3][4]=0.000250392;
CosineMidTracker[4][4]=0.00138263;
 
SineMidTracker[0][4]=-0.00136351;
SineMidTracker[1][4]=-0.000495577;
SineMidTracker[2][4]=0.00078155;
SineMidTracker[3][4]=0.000646108;
SineMidTracker[4][4]=0.000928006;
 
CosineMidTracker[0][5]=-0.000518586;
CosineMidTracker[1][5]=0.000525125;
CosineMidTracker[2][5]=-0.000190015;
CosineMidTracker[3][5]=0.000358656;
CosineMidTracker[4][5]=-0.000106851;
 
SineMidTracker[0][5]=0.000719306;
SineMidTracker[1][5]=-0.000107575;
SineMidTracker[2][5]=-0.000315828;
SineMidTracker[3][5]=-0.000596578;
SineMidTracker[4][5]=-0.000708034;
 
CosineMidTracker[0][6]=0.00120319;
CosineMidTracker[1][6]=0.000192318;
CosineMidTracker[2][6]=0.000851156;
CosineMidTracker[3][6]=0.000119825;
CosineMidTracker[4][6]=3.26976e-05;
 
SineMidTracker[0][6]=0.000905241;
SineMidTracker[1][6]=0.0010633;
SineMidTracker[2][6]=0.000364542;
SineMidTracker[3][6]=-0.000562037;
SineMidTracker[4][6]=-0.000410295;
 
CosineMidTracker[0][7]=-0.00105881;
CosineMidTracker[1][7]=-0.000407897;
CosineMidTracker[2][7]=8.4415e-05;
CosineMidTracker[3][7]=-3.84e-05;
CosineMidTracker[4][7]=-0.000784748;
 
SineMidTracker[0][7]=-0.000719737;
SineMidTracker[1][7]=-1.31108e-05;
SineMidTracker[2][7]=-0.000646048;
SineMidTracker[3][7]=-0.0012558;
SineMidTracker[4][7]=8.18111e-05;
 
CosineMidTracker[0][8]=0.000415797;
CosineMidTracker[1][8]=0.000280777;
CosineMidTracker[2][8]=0.000265765;
CosineMidTracker[3][8]=-0.000492035;
CosineMidTracker[4][8]=-0.000769529;
 
SineMidTracker[0][8]=0.000390841;
SineMidTracker[1][8]=-0.000452651;
SineMidTracker[2][8]=-0.000428856;
SineMidTracker[3][8]=0.000614577;
SineMidTracker[4][8]=0.000251665;
 
CosineMidTracker[0][9]=0.000219123;
CosineMidTracker[1][9]=-0.00131498;
CosineMidTracker[2][9]=-0.000177736;
CosineMidTracker[3][9]=-0.00075314;
CosineMidTracker[4][9]=-0.000562775;
 
SineMidTracker[0][9]=-0.00156218;
SineMidTracker[1][9]=-0.000445244;
SineMidTracker[2][9]=-0.000645504;
SineMidTracker[3][9]=0.000427797;
SineMidTracker[4][9]=0.000272501;
 
//V1 Odd
//Whole Tracker
CosineWholeOddTracker[0][0]=0.15806;
CosineWholeOddTracker[1][0]=0.126823;
CosineWholeOddTracker[2][0]=0.102853;
CosineWholeOddTracker[3][0]=0.0842253;
CosineWholeOddTracker[4][0]=0.0691404;
 
SineWholeOddTracker[0][0]=0.0595637;
SineWholeOddTracker[1][0]=0.0466828;
SineWholeOddTracker[2][0]=0.0369296;
SineWholeOddTracker[3][0]=0.0276027;
SineWholeOddTracker[4][0]=0.0239414;
 
CosineWholeOddTracker[0][1]=0.00290949;
CosineWholeOddTracker[1][1]=0.000971943;
CosineWholeOddTracker[2][1]=0.00165516;
CosineWholeOddTracker[3][1]=0.00191335;
CosineWholeOddTracker[4][1]=0.00235087;
 
SineWholeOddTracker[0][1]=0.0248952;
SineWholeOddTracker[1][1]=0.0129185;
SineWholeOddTracker[2][1]=0.00495711;
SineWholeOddTracker[3][1]=-0.000822848;
SineWholeOddTracker[4][1]=-0.00464092;
 
CosineWholeOddTracker[0][2]=-0.00441012;
CosineWholeOddTracker[1][2]=-0.00166838;
CosineWholeOddTracker[2][2]=-0.00166455;
CosineWholeOddTracker[3][2]=-0.00132747;
CosineWholeOddTracker[4][2]=-0.00069031;
 
SineWholeOddTracker[0][2]=0.00194565;
SineWholeOddTracker[1][2]=0.00125001;
SineWholeOddTracker[2][2]=0.000501251;
SineWholeOddTracker[3][2]=-0.000356387;
SineWholeOddTracker[4][2]=-0.000409144;
 
CosineWholeOddTracker[0][3]=-0.000390934;
CosineWholeOddTracker[1][3]=-0.000168587;
CosineWholeOddTracker[2][3]=0.00044056;
CosineWholeOddTracker[3][3]=-3.16249e-05;
CosineWholeOddTracker[4][3]=-0.00136333;
 
SineWholeOddTracker[0][3]=-0.000725971;
SineWholeOddTracker[1][3]=-0.00166831;
SineWholeOddTracker[2][3]=-0.0013459;
SineWholeOddTracker[3][3]=-3.89342e-05;
SineWholeOddTracker[4][3]=0.000812004;
 
CosineWholeOddTracker[0][4]=-0.00084753;
CosineWholeOddTracker[1][4]=-0.000151308;
CosineWholeOddTracker[2][4]=0.00137895;
CosineWholeOddTracker[3][4]=0.000784515;
CosineWholeOddTracker[4][4]=0.00144787;
 
SineWholeOddTracker[0][4]=0.000956053;
SineWholeOddTracker[1][4]=7.08253e-05;
SineWholeOddTracker[2][4]=0.00100203;
SineWholeOddTracker[3][4]=0.00130416;
SineWholeOddTracker[4][4]=0.000723068;
 
CosineWholeOddTracker[0][5]=-0.000151382;
CosineWholeOddTracker[1][5]=-0.000195281;
CosineWholeOddTracker[2][5]=-0.000179868;
CosineWholeOddTracker[3][5]=-0.0016916;
CosineWholeOddTracker[4][5]=-0.000141671;
 
SineWholeOddTracker[0][5]=0.00018475;
SineWholeOddTracker[1][5]=-0.000171267;
SineWholeOddTracker[2][5]=0.000413747;
SineWholeOddTracker[3][5]=0.000783305;
SineWholeOddTracker[4][5]=0.000962956;
 
CosineWholeOddTracker[0][6]=-9.30683e-05;
CosineWholeOddTracker[1][6]=8.79887e-06;
CosineWholeOddTracker[2][6]=0.000191189;
CosineWholeOddTracker[3][6]=-0.000218991;
CosineWholeOddTracker[4][6]=-0.000102812;
 
SineWholeOddTracker[0][6]=-0.000608247;
SineWholeOddTracker[1][6]=-0.00012031;
SineWholeOddTracker[2][6]=5.44215e-05;
SineWholeOddTracker[3][6]=0.000817724;
SineWholeOddTracker[4][6]=0.000734971;
 
CosineWholeOddTracker[0][7]=0.00142409;
CosineWholeOddTracker[1][7]=0.000256923;
CosineWholeOddTracker[2][7]=0.000297206;
CosineWholeOddTracker[3][7]=0.000796456;
CosineWholeOddTracker[4][7]=0.000245186;
 
SineWholeOddTracker[0][7]=0.000338384;
SineWholeOddTracker[1][7]=0.000514094;
SineWholeOddTracker[2][7]=0.000188764;
SineWholeOddTracker[3][7]=0.000146167;
SineWholeOddTracker[4][7]=-0.000168939;
 
CosineWholeOddTracker[0][8]=-3.70731e-05;
CosineWholeOddTracker[1][8]=-0.000245853;
CosineWholeOddTracker[2][8]=0.000504688;
CosineWholeOddTracker[3][8]=0.000460317;
CosineWholeOddTracker[4][8]=0.000909222;
 
SineWholeOddTracker[0][8]=6.67173e-05;
SineWholeOddTracker[1][8]=0.00117206;
SineWholeOddTracker[2][8]=-0.000615478;
SineWholeOddTracker[3][8]=0.000230533;
SineWholeOddTracker[4][8]=-0.000911665;
 
CosineWholeOddTracker[0][9]=-1.51115e-05;
CosineWholeOddTracker[1][9]=0.000262572;
CosineWholeOddTracker[2][9]=0.00102025;
CosineWholeOddTracker[3][9]=0.000160882;
CosineWholeOddTracker[4][9]=-0.0001661;
 
SineWholeOddTracker[0][9]=0.000406614;
SineWholeOddTracker[1][9]=-4.98789e-05;
SineWholeOddTracker[2][9]=-0.000983213;
SineWholeOddTracker[3][9]=-0.00048581;
SineWholeOddTracker[4][9]=-0.000788275;
 
 
//Pos Tracker
CosinePosOddTracker[0][0]=-0.0398215;
CosinePosOddTracker[1][0]=-0.0349319;
CosinePosOddTracker[2][0]=-0.0298639;
CosinePosOddTracker[3][0]=-0.022839;
CosinePosOddTracker[4][0]=-0.0179032;
 
SinePosOddTracker[0][0]=-0.485246;
SinePosOddTracker[1][0]=-0.408552;
SinePosOddTracker[2][0]=-0.343188;
SinePosOddTracker[3][0]=-0.2854;
SinePosOddTracker[4][0]=-0.236337;
 
CosinePosOddTracker[0][1]=-0.167139;
CosinePosOddTracker[1][1]=-0.117062;
CosinePosOddTracker[2][1]=-0.0829112;
CosinePosOddTracker[3][1]=-0.0557497;
CosinePosOddTracker[4][1]=-0.0363794;
 
SinePosOddTracker[0][1]=0.0178996;
SinePosOddTracker[1][1]=0.00974576;
SinePosOddTracker[2][1]=0.00259923;
SinePosOddTracker[3][1]=-0.0013623;
SinePosOddTracker[4][1]=-0.00691617;
 
CosinePosOddTracker[0][2]=0.00774682;
CosinePosOddTracker[1][2]=0.00460031;
CosinePosOddTracker[2][2]=0.0022934;
CosinePosOddTracker[3][2]=0.00164511;
CosinePosOddTracker[4][2]=0.00216667;
 
SinePosOddTracker[0][2]=0.0510249;
SinePosOddTracker[1][2]=0.0296263;
SinePosOddTracker[2][2]=0.0186649;
SinePosOddTracker[3][2]=0.0102255;
SinePosOddTracker[4][2]=0.00652982;
 
CosinePosOddTracker[0][3]=0.0183942;
CosinePosOddTracker[1][3]=0.0112754;
CosinePosOddTracker[2][3]=0.00730525;
CosinePosOddTracker[3][3]=0.00602307;
CosinePosOddTracker[4][3]=0.0069952;
 
SinePosOddTracker[0][3]=0.000611972;
SinePosOddTracker[1][3]=0.00143888;
SinePosOddTracker[2][3]=3.60821e-05;
SinePosOddTracker[3][3]=0.0010772;
SinePosOddTracker[4][3]=0.00062934;
 
CosinePosOddTracker[0][4]=0.0039763;
CosinePosOddTracker[1][4]=0.00431541;
CosinePosOddTracker[2][4]=0.00397681;
CosinePosOddTracker[3][4]=0.00559089;
CosinePosOddTracker[4][4]=0.00712582;
 
SinePosOddTracker[0][4]=-0.00349598;
SinePosOddTracker[1][4]=-0.00223598;
SinePosOddTracker[2][4]=0.000276193;
SinePosOddTracker[3][4]=-0.000833386;
SinePosOddTracker[4][4]=0.000558858;
 
CosinePosOddTracker[0][5]=0.00234829;
CosinePosOddTracker[1][5]=0.00327496;
CosinePosOddTracker[2][5]=0.00559834;
CosinePosOddTracker[3][5]=0.00542212;
CosinePosOddTracker[4][5]=0.00515854;
 
SinePosOddTracker[0][5]=-0.000221433;
SinePosOddTracker[1][5]=0.000518143;
SinePosOddTracker[2][5]=0.000155616;
SinePosOddTracker[3][5]=-0.000280267;
SinePosOddTracker[4][5]=-0.000411774;
 
CosinePosOddTracker[0][6]=0.00317348;
CosinePosOddTracker[1][6]=0.0038314;
CosinePosOddTracker[2][6]=0.00349934;
CosinePosOddTracker[3][6]=0.00397844;
CosinePosOddTracker[4][6]=0.00705096;
 
SinePosOddTracker[0][6]=-0.000203035;
SinePosOddTracker[1][6]=0.00131883;
SinePosOddTracker[2][6]=0.00103539;
SinePosOddTracker[3][6]=0.000281867;
SinePosOddTracker[4][6]=0.000895861;
 
CosinePosOddTracker[0][7]=0.0033397;
CosinePosOddTracker[1][7]=0.00407045;
CosinePosOddTracker[2][7]=0.00421101;
CosinePosOddTracker[3][7]=0.00567335;
CosinePosOddTracker[4][7]=0.00649266;
 
SinePosOddTracker[0][7]=0.00096407;
SinePosOddTracker[1][7]=0.000844719;
SinePosOddTracker[2][7]=0.000880371;
SinePosOddTracker[3][7]=0.000127695;
SinePosOddTracker[4][7]=0.000523497;
 
CosinePosOddTracker[0][8]=0.00482005;
CosinePosOddTracker[1][8]=0.00512121;
CosinePosOddTracker[2][8]=0.00440174;
CosinePosOddTracker[3][8]=0.00567008;
CosinePosOddTracker[4][8]=0.00673237;
 
SinePosOddTracker[0][8]=0.000689846;
SinePosOddTracker[1][8]=-0.00098503;
SinePosOddTracker[2][8]=-0.000803084;
SinePosOddTracker[3][8]=-0.000752918;
SinePosOddTracker[4][8]=0.000654109;
 
CosinePosOddTracker[0][9]=0.00298277;
CosinePosOddTracker[1][9]=0.00475637;
CosinePosOddTracker[2][9]=0.00456898;
CosinePosOddTracker[3][9]=0.00451652;
CosinePosOddTracker[4][9]=0.00601516;
 
SinePosOddTracker[0][9]=-0.0011317;
SinePosOddTracker[1][9]=-0.00213401;
SinePosOddTracker[2][9]=-0.000464412;
SinePosOddTracker[3][9]=-0.000356904;
SinePosOddTracker[4][9]=-0.00125827;
 
 
//Neg Tracker
CosineNegOddTracker[0][0]=0.241991;
CosineNegOddTracker[1][0]=0.205783;
CosineNegOddTracker[2][0]=0.174969;
CosineNegOddTracker[3][0]=0.14722;
CosineNegOddTracker[4][0]=0.124029;
 
SineNegOddTracker[0][0]=0.53019;
SineNegOddTracker[1][0]=0.447365;
SineNegOddTracker[2][0]=0.376908;
SineNegOddTracker[3][0]=0.313272;
SineNegOddTracker[4][0]=0.26154;
 
CosineNegOddTracker[0][1]=-0.161431;
CosineNegOddTracker[1][1]=-0.112876;
CosineNegOddTracker[2][1]=-0.0786555;
CosineNegOddTracker[3][1]=-0.0540163;
CosineNegOddTracker[4][1]=-0.0367873;
 
SineNegOddTracker[0][1]=0.167193;
SineNegOddTracker[1][1]=0.112157;
SineNegOddTracker[2][1]=0.0732496;
SineNegOddTracker[3][1]=0.0455069;
SineNegOddTracker[4][1]=0.0260987;
 
CosineNegOddTracker[0][2]=-0.0656708;
CosineNegOddTracker[1][2]=-0.033267;
CosineNegOddTracker[2][2]=-0.0159076;
CosineNegOddTracker[3][2]=-0.00519521;
CosineNegOddTracker[4][2]=8.47415e-05;
 
SineNegOddTracker[0][2]=-0.033;
SineNegOddTracker[1][2]=-0.022301;
SineNegOddTracker[2][2]=-0.0132847;
SineNegOddTracker[3][2]=-0.0106847;
SineNegOddTracker[4][2]=-0.00796904;
 
CosineNegOddTracker[0][3]=0.00631441;
CosineNegOddTracker[1][3]=0.00635547;
CosineNegOddTracker[2][3]=0.00447883;
CosineNegOddTracker[3][3]=0.00409467;
CosineNegOddTracker[4][3]=0.00490156;
 
SineNegOddTracker[0][3]=-0.019948;
SineNegOddTracker[1][3]=-0.00945651;
SineNegOddTracker[2][3]=-0.00368587;
SineNegOddTracker[3][3]=-0.00183958;
SineNegOddTracker[4][3]=-0.00226005;
 
CosineNegOddTracker[0][4]=0.00599723;
CosineNegOddTracker[1][4]=0.00361113;
CosineNegOddTracker[2][4]=0.00275516;
CosineNegOddTracker[3][4]=0.00185646;
CosineNegOddTracker[4][4]=0.00310804;
 
SineNegOddTracker[0][4]=0.000900817;
SineNegOddTracker[1][4]=0.00128323;
SineNegOddTracker[2][4]=0.000548345;
SineNegOddTracker[3][4]=-0.000174612;
SineNegOddTracker[4][4]=0.000700626;
 
CosineNegOddTracker[0][5]=0.000661505;
CosineNegOddTracker[1][5]=0.000818077;
CosineNegOddTracker[2][5]=0.00103643;
CosineNegOddTracker[3][5]=0.00168424;
CosineNegOddTracker[4][5]=0.00198791;
 
SineNegOddTracker[0][5]=0.00141307;
SineNegOddTracker[1][5]=-0.000655186;
SineNegOddTracker[2][5]=8.72261e-06;
SineNegOddTracker[3][5]=0.000419957;
SineNegOddTracker[4][5]=-0.000414695;
 
CosineNegOddTracker[0][6]=0.000224093;
CosineNegOddTracker[1][6]=0.00151957;
CosineNegOddTracker[2][6]=0.00175219;
CosineNegOddTracker[3][6]=0.00117571;
CosineNegOddTracker[4][6]=0.00142679;
 
SineNegOddTracker[0][6]=-0.000540816;
SineNegOddTracker[1][6]=-0.00094885;
SineNegOddTracker[2][6]=-0.00101692;
SineNegOddTracker[3][6]=-0.000453756;
SineNegOddTracker[4][6]=-0.00019232;
 
CosineNegOddTracker[0][7]=0.00119561;
CosineNegOddTracker[1][7]=0.00186693;
CosineNegOddTracker[2][7]=0.00360472;
CosineNegOddTracker[3][7]=0.00233888;
CosineNegOddTracker[4][7]=0.00361355;
 
SineNegOddTracker[0][7]=-0.000517177;
SineNegOddTracker[1][7]=-0.00027005;
SineNegOddTracker[2][7]=-0.000390362;
SineNegOddTracker[3][7]=-0.00114677;
SineNegOddTracker[4][7]=-0.000505865;
 
CosineNegOddTracker[0][8]=0.00105662;
CosineNegOddTracker[1][8]=0.00105641;
CosineNegOddTracker[2][8]=0.00265941;
CosineNegOddTracker[3][8]=0.00272477;
CosineNegOddTracker[4][8]=0.00223928;
 
SineNegOddTracker[0][8]=-0.000671305;
SineNegOddTracker[1][8]=-0.000397113;
SineNegOddTracker[2][8]=0.0012654;
SineNegOddTracker[3][8]=0.0010097;
SineNegOddTracker[4][8]=0.000631645;
 
CosineNegOddTracker[0][9]=0.00132918;
CosineNegOddTracker[1][9]=0.00129043;
CosineNegOddTracker[2][9]=0.00133495;
CosineNegOddTracker[3][9]=0.00152053;
CosineNegOddTracker[4][9]=0.00203855;
 
SineNegOddTracker[0][9]=-0.000266922;
SineNegOddTracker[1][9]=-0.000790028;
SineNegOddTracker[2][9]=0.00157291;
SineNegOddTracker[3][9]=0.00115661;
SineNegOddTracker[4][9]=-0.000119587;
 
 
//Mid Tracker
CosineMidOddTracker[0][0]=-0.000314758;
CosineMidOddTracker[1][0]=0.00152793;
CosineMidOddTracker[2][0]=0.0013678;
CosineMidOddTracker[3][0]=0.0021595;
CosineMidOddTracker[4][0]=0.00135744;
 
SineMidOddTracker[0][0]=-0.0834719;
SineMidOddTracker[1][0]=-0.0707103;
SineMidOddTracker[2][0]=-0.0580385;
SineMidOddTracker[3][0]=-0.0475433;
SineMidOddTracker[4][0]=-0.0379939;
 
CosineMidOddTracker[0][1]=-0.00759744;
CosineMidOddTracker[1][1]=-0.0031641;
CosineMidOddTracker[2][1]=-0.000604761;
CosineMidOddTracker[3][1]=0.00237498;
CosineMidOddTracker[4][1]=0.00443265;
 
SineMidOddTracker[0][1]=-0.0195564;
SineMidOddTracker[1][1]=-0.0147192;
SineMidOddTracker[2][1]=-0.0121746;
SineMidOddTracker[3][1]=-0.00799804;
SineMidOddTracker[4][1]=-0.00612083;
 
CosineMidOddTracker[0][2]=-0.00528138;
CosineMidOddTracker[1][2]=-0.00431062;
CosineMidOddTracker[2][2]=-0.00232156;
CosineMidOddTracker[3][2]=-0.000965605;
CosineMidOddTracker[4][2]=7.24744e-05;
 
SineMidOddTracker[0][2]=-0.00163167;
SineMidOddTracker[1][2]=-0.00138149;
SineMidOddTracker[2][2]=-0.00159203;
SineMidOddTracker[3][2]=-0.00076595;
SineMidOddTracker[4][2]=-0.00124241;
 
CosineMidOddTracker[0][3]=-0.000679333;
CosineMidOddTracker[1][3]=-0.000951078;
CosineMidOddTracker[2][3]=-0.00118405;
CosineMidOddTracker[3][3]=-0.00110499;
CosineMidOddTracker[4][3]=-0.000602819;
 
SineMidOddTracker[0][3]=0.00131691;
SineMidOddTracker[1][3]=0.000448529;
SineMidOddTracker[2][3]=-0.00087084;
SineMidOddTracker[3][3]=0.000290961;
SineMidOddTracker[4][3]=-0.00148175;
 
CosineMidOddTracker[0][4]=-0.00126869;
CosineMidOddTracker[1][4]=-0.000655479;
CosineMidOddTracker[2][4]=0.000415491;
CosineMidOddTracker[3][4]=0.000298544;
CosineMidOddTracker[4][4]=-0.00022731;
 
SineMidOddTracker[0][4]=9.70169e-05;
SineMidOddTracker[1][4]=7.26195e-06;
SineMidOddTracker[2][4]=-0.000319463;
SineMidOddTracker[3][4]=-0.000289038;
SineMidOddTracker[4][4]=0.000101891;
 
CosineMidOddTracker[0][5]=-0.000893702;
CosineMidOddTracker[1][5]=-0.000477342;
CosineMidOddTracker[2][5]=-0.000374928;
CosineMidOddTracker[3][5]=0.000171255;
CosineMidOddTracker[4][5]=0.000872083;
 
SineMidOddTracker[0][5]=0.00127768;
SineMidOddTracker[1][5]=0.00114653;
SineMidOddTracker[2][5]=0.000327425;
SineMidOddTracker[3][5]=0.000619222;
SineMidOddTracker[4][5]=-0.000789576;
 
CosineMidOddTracker[0][6]=-0.000210247;
CosineMidOddTracker[1][6]=-0.00131121;
CosineMidOddTracker[2][6]=-0.00186777;
CosineMidOddTracker[3][6]=0.000156581;
CosineMidOddTracker[4][6]=0.0007707;
 
SineMidOddTracker[0][6]=-0.000134074;
SineMidOddTracker[1][6]=0.000426017;
SineMidOddTracker[2][6]=5.65561e-06;
SineMidOddTracker[3][6]=-0.000796553;
SineMidOddTracker[4][6]=0.000178488;
 
CosineMidOddTracker[0][7]=5.97637e-05;
CosineMidOddTracker[1][7]=3.55043e-05;
CosineMidOddTracker[2][7]=-0.000282728;
CosineMidOddTracker[3][7]=-0.000249834;
CosineMidOddTracker[4][7]=-0.000138428;
 
SineMidOddTracker[0][7]=-0.00113353;
SineMidOddTracker[1][7]=-0.000742229;
SineMidOddTracker[2][7]=-0.0013655;
SineMidOddTracker[3][7]=-0.000799944;
SineMidOddTracker[4][7]=-1.09473e-05;
 
CosineMidOddTracker[0][8]=7.09595e-05;
CosineMidOddTracker[1][8]=0.000122096;
CosineMidOddTracker[2][8]=0.00195979;
CosineMidOddTracker[3][8]=0.000210846;
CosineMidOddTracker[4][8]=0.000193964;
 
SineMidOddTracker[0][8]=4.25694e-05;
SineMidOddTracker[1][8]=0.000338122;
SineMidOddTracker[2][8]=0.000241407;
SineMidOddTracker[3][8]=-0.000286411;
SineMidOddTracker[4][8]=-0.000377563;
 
CosineMidOddTracker[0][9]=-2.68495e-05;
CosineMidOddTracker[1][9]=-0.000338878;
CosineMidOddTracker[2][9]=0.000141452;
CosineMidOddTracker[3][9]=0.000262522;
CosineMidOddTracker[4][9]=-0.000383444;
 
SineMidOddTracker[0][9]=0.000168853;
SineMidOddTracker[1][9]=0.000714454;
SineMidOddTracker[2][9]=-0.00199151;
SineMidOddTracker[3][9]=-0.000634935;
SineMidOddTracker[4][9]=-0.00211069;
 

}//End of Fill Angular Corrections Function

+EOF
