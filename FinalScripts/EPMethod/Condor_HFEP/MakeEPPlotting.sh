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
void FillPTStats();
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

//PT Bin Centers
TProfile *PTCenters[nCent];
//////////////////////////////////

Int_t HFV1EPPlotting_${1}(){
  Initialize();
  FillPTStats();
  FillAngularCorrections();
  EPPlotting();
  return 0;
}


void Initialize(){

  //  std::cout<<"Made it into initialize"<<std::endl;
  Float_t eta_bin_small[13]={-0.6,-0.5,-0.4,-0.3,-0.2,-0.1,0.0,0.1,0.2,0.3,0.4,0.5,0.6};

  Double_t pt_bin[17]={0.4,0.6,0.8,1.0,1.2,1.4,1.6,1.8,2.0,2.4,2.8,3.2,3.6,4.5,6.5,9.5,12};


  chain= new TChain("hiGoodTightMergedTracksTree");
  chain2=new TChain("CaloTowerTree");
  //Tracks Tree
  //chain2->Add("/home/jgomez2/Desktop/Forward*");
  //chain->Add("/home/jgomez2/Desktop/Forward*");

  //Calo Tower Tree
  chain->Add("/hadoop/store/user/jgomez2/ForwardTrees/2010/PanicTime/$b");
  //Tracks Tree
  chain2->Add("/hadoop/store/user/jgomez2/ForwardTrees/2010/PanicTime/$b");

  NumberOfEvents = chain2->GetEntries();
  //Create the output ROOT file
  myFile = new TFile("HFEP_EPPlottingV1_${1}.root","recreate");

  //Make Subdirectories for what will follow
  myPlots = myFile->mkdir("Plots");
  myPlots->cd();
  //////////////////////////////////////////////////////////////////////
  //////////////////////////////////////////
  //Directory for the EP angles
  epangles = myPlots->mkdir("EventPlanes");
  wholehfepangles = epangles->mkdir("CombinedHF");
  poshfepangles = epangles->mkdir("PositiveHF");
  neghfepangles= epangles->mkdir("NegativeHF");
  midtrackerangles = epangles->mkdir("TrackerEP");
  ///////////////////////////////////////////////////////////////////
  /////////////////////////////////////////////////////////////////////////
  //EP Resolutions
  resolutions = myPlots->mkdir("Resolutions");
  //Even
  evenresolutions = resolutions->mkdir("EvenResolutions");
  evenresolutions->cd();
  HFPMinusHFMEven = new TProfile("HFPMinusHFMEven","Resolution of HF^{+} and HF^{-}",nCent,0,nCent);
  HFPMinusHFMEven->GetYaxis()->SetTitle("<cos(#Psi_{1}^{HF^{+}} - #Psi_{1}^{HF^{-}})>");
  HFPMinusTREven = new TProfile("HFPMinusTREven","Resolution of HF^{+} and the Tracker",nCent,0,nCent);
  HFPMinusTREven->GetYaxis()->SetTitle("<cos(#Psi_{1}^{HF^{+}} - #Psi_{1}^{TR})>");
  HFMMinusTREven = new TProfile("HFMMinusTREven","Resolution of HF^{-} and the Tracker",nCent,0,nCent);
  HFMMinusTREven->GetYaxis()->SetTitle("<cos(#Psi_{1}^{HF^{-}} - #Psi_{1}^{TR})>");
  //Odd
  oddresolutions = resolutions->mkdir("OddResolutions");
  oddresolutions->cd();
  HFPMinusHFMOdd = new TProfile("HFPMinusHFMOdd","Resolution of HF^{+} and HF^{-}",nCent,0,nCent);
  HFPMinusHFMOdd->GetYaxis()->SetTitle("<cos(#Psi_{1}^{HF^{+}} - #Psi_{1}^{HF^{-}})>");
  HFPMinusTROdd = new TProfile("HFPMinusTROdd","Resolution of HF^{+} and the Tracker",nCent,0,nCent);
  HFPMinusTROdd->GetYaxis()->SetTitle("<cos(#Psi_{1}^{HF^{+}} - #Psi_{1}^{TR})>");
  HFMMinusTROdd = new TProfile("HFMMinusTROdd","Resolution of HF^{-} and the Tracker",nCent,0,nCent);
  HFMMinusTROdd->GetYaxis()->SetTitle("<cos(#Psi_{1}^{HF^{-}} - #Psi_{1}^{TR})>");
  ////////////////////////////////////////////////////////////////
  //Directory For Final v1 plots
  v1plots = myPlots->mkdir("V1Results");
  v1etaoddplots = v1plots->mkdir("V1EtaOdd");
  v1etaevenplots = v1plots->mkdir("V1EtaEven");
  v1ptevenplots = v1plots->mkdir("V1pTEven");
  v1ptoddplots = v1plots->mkdir("V1pTOdd");




  ////////////////////////////////////////////////////////////
  //Psi1 Raw, Psi1 Final
  //Psi1(even)
  //Whole HF
  char epevenrawname[128],epevenrawtitle[128];
  char epevenfinalname[128],epevenfinaltitle[128];
  //Pos HF
  char poshfevenrawname[128],poshfevenrawtitle[128];
  char poshfevenfinalname[128],poshfevenfinaltitle[128];
  //Neg HF
  char neghfevenrawname[128],neghfevenrawtitle[128];
  char neghfevenfinalname[128],neghfevenfinaltitle[128];
  //Tracker
  char trevenrawname[128],trevenrawtitle[128];
  char trevenfinalname[128],trevenfinaltitle[128];
  //////////////////////////////////////////////////////////////
  //Psi1(odd)
  //Whole HF
  char epoddrawname[128],epoddrawtitle[128];
  char epoddfinalname[128],epoddfinaltitle[128];
  //Pos HF
  char poshfoddrawname[128],poshfoddrawtitle[128];
  char poshfoddfinalname[128],poshfoddfinaltitle[128];
  //Neg HF
  char neghfoddrawname[128],neghfoddrawtitle[128];
  char neghfoddfinalname[128],neghfoddfinaltitle[128];
  //Tracker                                       
  char troddrawname[128],troddrawtitle[128];
  char troddfinalname[128],troddfinaltitle[128];
  //////////////////////////////////////////////////////////////

  //Visualization of Correction Factors
  //Psi1(even)
  char psi1evencorrsname[128],psi1evencorrstitle[128];
  //Psi1(odd)
  char psi1oddcorrsname[128],psi1oddcorrstitle[128];
  /////////////////////////////////////////////////////////////
  //
  //V1 Plots
  //v1(even)
  char v1etaevenname[128],v1etaeventitle[128];
  char v1ptevenname[128],v1pteventitle[128];
  //v1(odd)
  char v1etaoddname[128],v1etaoddtitle[128];
  char v1ptoddname[128],v1ptoddtitle[128];

  //PT Centers
  char ptcentername[128],ptcentertitle[128];

  for (Int_t i=0;i<nCent;i++)
    {
      ///////////////////////////////////////////////////////////////////////////////////////////
      //Event Plane Plots
      wholehfepangles->cd();
      //Psi1Even
      //Whole HF
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

      //Pos HF
      poshfepangles->cd();
      //Raw
      sprintf(poshfevenrawname,"Psi1PEvenRaw_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(poshfevenrawtitle,"#Psi_{1}^{even}(HF^{+}) Raw %1.0lfto%1.0lf",centlo[i],centhi[i]);
      PsiPEvenRaw[i] = new TH1F(poshfevenrawname,poshfevenrawtitle,100,-TMath::Pi()-.392699,TMath::Pi()+.392699);
      PsiPEvenRaw[i]->GetXaxis()->SetTitle("EP Angle (radians)");
      //Final
      sprintf(poshfevenfinalname,"Psi1PEvenFinal_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(poshfevenfinaltitle,"#Psi_{1}^{even}(HF^{+}) Final %1.0lfto%1.0lf",centlo[i],centhi[i]);
      PsiPEvenFinal[i] = new TH1F(poshfevenfinalname,poshfevenfinaltitle,100,-TMath::Pi()-.392699,TMath::Pi()+.392699);
      PsiPEvenFinal[i]->GetXaxis()->SetTitle("EP Angle (radians)");


      //Neg HF
      neghfepangles->cd();
      //Raw
      sprintf(neghfevenrawname,"Psi1NEvenRaw_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(neghfevenrawtitle,"#Psi_{1}^{even}(HF^{-}) Raw %1.0lfto%1.0lf",centlo[i],centhi[i]);
      PsiNEvenRaw[i] = new TH1F(neghfevenrawname,neghfevenrawtitle,100,-TMath::Pi()-.392699,TMath::Pi()+.392699);
      PsiNEvenRaw[i]->GetXaxis()->SetTitle("EP Angle (radians)");
      //Final
      sprintf(neghfevenfinalname,"Psi1NEvenFinal_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(neghfevenfinaltitle,"#Psi_{1}^{even}(HF^{-}) Final %1.0lfto%1.0lf",centlo[i],centhi[i]);
      PsiNEvenFinal[i] = new TH1F(neghfevenfinalname,neghfevenfinaltitle,100,-TMath::Pi()-.392699,TMath::Pi()+.392699);
      PsiNEvenFinal[i]->GetXaxis()->SetTitle("EP Angle (radians)");

      //Tracker                                                     
      midtrackerangles->cd();
      //Raw
      sprintf(trevenrawname,"Psi1TREvenRaw_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(trevenrawtitle,"#Psi_{1}^{even}(TR) Raw %1.0lfto%1.0lf",centlo[i],centhi[i]);
      PsiTREvenRaw[i] = new TH1F(trevenrawname,trevenrawtitle,100,-TMath::Pi()-.392699,TMath::Pi()+.392699);
      PsiTREvenRaw[i]->GetXaxis()->SetTitle("EP Angle (radians)");
      //Final
      sprintf(trevenfinalname,"Psi1TREvenFinal_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(trevenfinaltitle,"#Psi_{1}^{even}(TR) Final %1.0lfto%1.0lf",centlo[i],centhi[i]);
      PsiTREvenFinal[i] = new TH1F(trevenfinalname,trevenfinaltitle,100,-TMath::Pi()-.392699,TMath::Pi()+.392699);
      PsiTREvenFinal[i]->GetXaxis()->SetTitle("EP Angle (radians)");
      

      ///////////////////////////////////////////////////////////////////////////////////

      //Psi1Odd
      wholehfepangles->cd();
      //Whole HF
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

      //Pos HF
      poshfepangles->cd();
      //Raw
      sprintf(poshfoddrawname,"Psi1POddRaw_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(poshfoddrawtitle,"#Psi_{1}^{odd}(HF^{+}) Raw %1.0lfto%1.0lf",centlo[i],centhi[i]);
      PsiPOddRaw[i] = new TH1F(poshfoddrawname,poshfoddrawtitle,100,-TMath::Pi()-.392699,TMath::Pi()+.392699);
      PsiPOddRaw[i]->GetXaxis()->SetTitle("EP Angle (radians)");
      //Final
      sprintf(poshfoddfinalname,"Psi1POddFinal_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(poshfoddfinaltitle,"#Psi_{1}^{odd}(HF^{+}) Final %1.0lfto%1.0lf",centlo[i],centhi[i]);
      PsiPOddFinal[i] = new TH1F(poshfoddfinalname,poshfoddfinaltitle,100,-TMath::Pi()-.392699,TMath::Pi()+.392699);
      PsiPOddFinal[i]->GetXaxis()->SetTitle("EP Angle (radians)");


      //Neg HF
      neghfepangles->cd();
      //Raw
      sprintf(neghfoddrawname,"Psi1NOddRaw_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(neghfoddrawtitle,"#Psi_{1}^{odd}(HF^{-}) Raw %1.0lfto%1.0lf",centlo[i],centhi[i]);
      PsiNOddRaw[i] = new TH1F(neghfoddrawname,neghfoddrawtitle,100,-TMath::Pi()-.392699,TMath::Pi()+.392699);
      PsiNOddRaw[i]->GetXaxis()->SetTitle("EP Angle (radians)");
      //Final
      sprintf(neghfoddfinalname,"Psi1NOddFinal_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(neghfoddfinaltitle,"#Psi_{1}^{odd}(HF^{-}) Final %1.0lfto%1.0lf",centlo[i],centhi[i]);
      PsiNOddFinal[i] = new TH1F(neghfoddfinalname,neghfoddfinaltitle,100,-TMath::Pi()-.392699,TMath::Pi()+.392699);
      PsiNOddFinal[i]->GetXaxis()->SetTitle("EP Angle (radians)");

      //Tracker                                                     
      midtrackerangles->cd();
      //Raw 
      sprintf(troddrawname,"Psi1TROddRaw_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(troddrawtitle,"#Psi_{1}^{odd}(TR) Raw %1.0lfto%1.0lf",centlo[i],centhi[i]);
      PsiTROddRaw[i] = new TH1F(troddrawname,troddrawtitle,100,-TMath::Pi()-.392699,TMath::Pi()+.39269);
      PsiTROddRaw[i]->GetXaxis()->SetTitle("EP Angle (radians)");
      //Final 
      sprintf(troddfinalname,"Psi1TROddFinal_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(troddfinaltitle,"#Psi_{1}^{odd}(TR) Final %1.0lfto%1.0lf",centlo[i],centhi[i]);
      PsiTROddFinal[i] = new TH1F(troddfinalname,troddfinaltitle,100,-TMath::Pi()-.392699,TMath::Pi()+.392699);
      PsiTROddFinal[i]->GetXaxis()->SetTitle("EP Angle (radians)");


      ////////////////////////////////////////////////////////////////////////////
      //Magnitude of Angular Correction Plots
      //Psi1 Even
      //angcorr1even->cd();
      myPlots->cd();
      sprintf(psi1evencorrsname,"PsiEvenCorrs_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(psi1evencorrstitle,"PsiEvenCorrs_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      PsiEvenCorrs[i]= new TProfile(psi1evencorrsname,psi1evencorrstitle,jMax,0,jMax);

      //Psi1 Odd
      //angcorr1odd->cd();
      myPlots->cd();
      sprintf(psi1oddcorrsname,"PsiOddCorrs_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(psi1oddcorrstitle,"PsiOddCorrs_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      PsiOddCorrs[i]= new TProfile(psi1oddcorrsname,psi1oddcorrstitle,jMax,0,jMax);

      /////////////////////////////////////////////////
      //////V1 Plots
      //V1 Eta

      //Even
      v1etaevenplots->cd();
      sprintf(v1etaevenname,"V1Eta_Even_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(v1etaeventitle,"v_{1}^{even}(#eta) %1.0lfto%1.0lf",centlo[i],centhi[i]);
      V1EtaEven[i]= new TProfile(v1etaevenname,v1etaeventitle,12,eta_bin_small);
      
      //Odd
      v1etaoddplots->cd();
      sprintf(v1etaoddname,"V1Eta_Odd_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(v1etaoddtitle,"v_{1}^{odd}(#eta) %1.0lfto%1.0lf",centlo[i],centhi[i]);
      V1EtaOdd[i]= new TProfile(v1etaoddname,v1etaoddtitle,12,eta_bin_small);

      //V1 Pt

      //Even
      v1ptevenplots->cd();
      sprintf(v1ptevenname,"V1Pt_Even_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(v1pteventitle,"v_{1}^{even}(p_{T}) %1.0lfto%1.0lf",centlo[i],centhi[i]);
      V1PtEven[i]= new TProfile(v1ptevenname,v1pteventitle,16,pt_bin);
      //Odd
      v1ptoddplots->cd();
      sprintf(v1ptoddname,"V1Pt_Odd_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(v1ptoddtitle,"v_{1}^{odd}(p_{T}) %1.0lfto%1.0lf",centlo[i],centhi[i]);
      V1PtOdd[i]= new TProfile(v1ptoddname,v1ptoddtitle,16,pt_bin);

      //pT Centers
      v1plots->cd();
      sprintf(ptcentername,"PTCenter_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(ptcentertitle,"PTCenter_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      PTCenters[i] = new TProfile(ptcentername,ptcentertitle,16,pt_bin);

      }//end of loop over centralities

}//end of initialize function


void FillPTStats(){
//Mid Tracker
ptavmid[0]=0.83076;
ptavmid[1]=0.836272;
ptavmid[2]=0.835241;
ptavmid[3]=0.828531;
ptavmid[4]=0.817881;
 
pt2avmid[0]=0.964978;
pt2avmid[1]=0.982727;
pt2avmid[2]=0.986144;
pt2avmid[3]=0.97755;
pt2avmid[4]=0.959843;
 

}//end of ptstats function



void EPPlotting(){
  for (Int_t i=0;i<NumberOfEvents;i++)
    {
      if ( !(i%10000) ) cout << " 3rd round, event # " << i << " / " << NumberOfEvents << endl;

     chain2->GetEntry(i);//grab the ith event
      chain->GetEntry(i);

      CENTRAL= (TLeaf*) chain->GetLeaf("bin");
      Centrality= CENTRAL->GetValue();
      if (Centrality>19) continue;

      //Grab the Track Leaves
      NumTracks= (TLeaf*) chain->GetLeaf("nTracks");
      TrackMom= (TLeaf*) chain->GetLeaf("pt");
      TrackPhi= (TLeaf*) chain->GetLeaf("phi");
      TrackEta= (TLeaf*) chain->GetLeaf("eta");


      //Calo Tower Tree
      CaloHits= (TLeaf*) chain2->GetLeaf("Calo_NumberOfHits");
      CaloEN= (TLeaf*) chain2->GetLeaf("Et");
      CaloPhi= (TLeaf*) chain2->GetLeaf("Phi");
      CaloEta= (TLeaf*) chain2->GetLeaf("Eta");


      //v1 Even
      //Whole HF
      X_hfeven=0.;
      Y_hfeven=0.;
      //Pos HF
      X_poseven=0.;
      Y_poseven=0.;
      //Neg HF
      X_negeven=0.;
      Y_negeven=0.;
      //Tracker
      X_treven=0.;
      Y_treven=0.;

      //v1 Odd
      //Whole HF
      X_hfodd=0.;
      Y_hfodd=0.;
      //Pos HF
      X_posodd=0.;
      Y_posodd=0.;
      //Neg HF
      X_negodd=0.;
      Y_negodd=0.;
      //Tracker
      X_trodd=0.;
      Y_trodd=0.;

      NumberOfHits= NumTracks->GetValue();
      for (Int_t ii=0;ii<NumberOfHits;ii++)
        {
          pT=0.;
          phi=0.;
          eta=0.;
          pT=TrackMom->GetValue(ii);
          phi=TrackPhi->GetValue(ii);
          eta=TrackEta->GetValue(ii);
          if(pT<0 || fabs(eta)>0.8) continue; //prevent negative pt tracks and non central tracks
	  for (Int_t c=0;c<nCent;c++)
            {
              if ( (Centrality*2.5) > centhi[c] ) continue;
              if ( (Centrality*2.5) < centlo[c] ) continue;
	      
	      if(eta>0.0)
		{
		  //Odd
		  X_trodd+=TMath::Cos(phi)*(pT-(pt2avmid[c]/ptavmid[c]));
		  Y_trodd+=TMath::Sin(phi)*(pT-(pt2avmid[c]/ptavmid[c]));
		  //Even
		  X_treven+=TMath::Cos(phi)*(pT-(pt2avmid[c]/ptavmid[c]));
                  Y_treven+=TMath::Sin(phi)*(pT-(pt2avmid[c]/ptavmid[c]));
		}//positive eta tracks
	      else
		{
		  //Odd                                                   
                  X_trodd+=TMath::Cos(phi)*(-1.0*(pT-(pt2avmid[c]/ptavmid[c])));
                  Y_trodd+=TMath::Sin(phi)*(-1.0*(pT-(pt2avmid[c]/ptavmid[c])));
                  //Even
                  X_treven+=TMath::Cos(phi)*(pT-(pt2avmid[c]/ptavmid[c]));
                  Y_treven+=TMath::Sin(phi)*(pT-(pt2avmid[c]/ptavmid[c]));
		}//negative eta tracks
	    }//end of loop over centralities 
	}//end of loop over Tracks
      
      NumberOfHits= CaloHits->GetValue();
      for (int ii=0;ii<NumberOfHits;ii++)
        {
          Energy=0.;
          phi=0.;
          eta=0.;
          Energy=CaloEN->GetValue(ii);
          phi=CaloPhi->GetValue(ii);
          eta=CaloEta->GetValue(ii);
          if(Energy<0)
            {
              continue;
            }
          //std::cout<<"Energy was "<<Energy<<" and phi was "<<phi<<std::endl;
          if (eta>0.0)
            {
              //Whole HF Odd
              X_hfodd+=cos(phi)*(Energy);
              Y_hfodd+=sin(phi)*(Energy);
              //Pos HF Odd
              X_posodd+=cos(phi)*(Energy);
              Y_posodd+=sin(phi)*(Energy);
              //Whole HF Even
              X_hfeven+=cos(phi)*(Energy);
              Y_hfeven+=sin(phi)*(Energy);
              //Pos HF Even
              X_poseven+=cos(phi)*(Energy);
              Y_poseven+=sin(phi)*(Energy);
            }
          else if (eta<0.0)
            {
              //Whole HF Odd
              X_hfodd+=cos(phi)*(-1.0*Energy);
              Y_hfodd+=sin(phi)*(-1.0*Energy);
              //Neg HF Odd
              X_negodd+=cos(phi)*(-1.0*Energy);
              Y_negodd+=sin(phi)*(-1.0*Energy);
              //Whole HF   Even
              X_hfeven+=cos(phi)*(Energy);
              Y_hfeven+=sin(phi)*(Energy);
              // Neg HF Even
              X_negeven+=cos(phi)*(Energy);
              Y_negeven+=sin(phi)*(Energy);
            }
        }//end of loop over Calo Hits

      for (Int_t c=0;c<nCent;c++)
        {
          if ( (Centrality*2.5) > centhi[c] ) continue;
          if ( (Centrality*2.5) < centlo[c] ) continue;


          //V1 Even
          //Whole HF
          EPhfeven=-999;
          EPhfeven=(1./1.)*atan2(Y_hfeven,X_hfeven);
          if (EPhfeven>(pi)) EPhfeven=(EPhfeven-(TMath::TwoPi()));
          if (EPhfeven<(-1.0*(pi))) EPhfeven=(EPhfeven+(TMath::TwoPi()));
          PsiEvenRaw[c]->Fill(EPhfeven);

          //Pos HF
          EP_poseven=-999;
          EP_poseven=(1./1.)*atan2(Y_poseven,X_poseven);
          if (EP_poseven>(pi)) EP_poseven=(EP_poseven-(TMath::TwoPi()));
          if (EP_poseven<(-1.0*(pi))) EP_poseven=(EP_poseven+(TMath::TwoPi()));
          PsiPEvenRaw[c]->Fill(EP_poseven);

          //Neg HF
          EP_negeven=-999;
          EP_negeven=(1./1.)*atan2(Y_negeven,X_negeven);
          if (EP_negeven>(pi)) EP_negeven=(EP_negeven-(TMath::TwoPi()));
          if (EP_negeven<(-1.0*(pi))) EP_negeven=(EP_negeven+(TMath::TwoPi()));
          PsiNEvenRaw[c]->Fill(EP_negeven);

	  //Tracker
	  EP_treven=-999;
          EP_treven=(1./1.)*atan2(Y_treven,X_treven);
          if (EP_treven>(pi)) EP_treven=(EP_treven-(TMath::TwoPi()));
          if (EP_treven<(-1.0*(pi))) EP_treven=(EP_treven+(TMath::TwoPi()));
	  PsiTREvenRaw[c]->Fill(EP_treven);
          //////////////////////////////////////////////
          //V1 odd
          //Whole HF
          EPhfodd=-999;
          EPhfodd=(1./1.)*atan2(Y_hfodd,X_hfodd);
          if (EPhfodd>(pi)) EPhfodd=(EPhfodd-(TMath::TwoPi()));
          if (EPhfodd<(-1.0*(pi))) EPhfodd=(EPhfodd+(TMath::TwoPi()));
          PsiOddRaw[c]->Fill(EPhfodd);

          //Pos HF
          EP_posodd=-999;
          EP_posodd=(1./1.)*atan2(Y_posodd,X_posodd);
          if (EP_posodd>(pi)) EP_posodd=(EP_posodd-(TMath::TwoPi()));
          if (EP_posodd<(-1.0*(pi))) EP_posodd=(EP_posodd+(TMath::TwoPi()));
          PsiPOddRaw[c]->Fill(EP_posodd);

          //Neg HF
          EP_negodd=-999;
          EP_negodd=(1./1.)*atan2(Y_negodd,X_negodd);
          if (EP_negodd>(pi)) EP_negodd=(EP_negodd-(TMath::TwoPi()));
          if (EP_negodd<(-1.0*(pi))) EP_negodd=(EP_negodd+(TMath::TwoPi()));
          PsiNOddRaw[c]->Fill(EP_negodd);

	  //Tracker
	  EP_trodd=-999;
          EP_trodd=(1./1.)*atan2(Y_trodd,X_trodd);
          if (EP_trodd>(pi)) EP_trodd=(EP_trodd-(TMath::TwoPi()));
          if (EP_trodd<(-1.0*(pi))) EP_trodd=(EP_trodd+(TMath::TwoPi()));
	  PsiTROddRaw[c]->Fill(EP_trodd);
          //Zero the angular correction variables

          //v1 even stuff
          //Whole HF
          AngularCorrectionHFEven=0.;EPfinalhfeven=-999.;
          //Pos HF
          AngularCorrectionHFPEven=0.; EP_finalposeven=-999.;
          //Neg HF
          AngularCorrectionHFNEven=0.; EP_finalnegeven=-999.;
          //Tracker
          AngularCorrectionTREven=0.; EP_finaltreven=-999.;

          //v1 odd stuff
          //Whole HF
          AngularCorrectionHFOdd=0.;EPfinalhfodd=-999.;
          //Pos HF
          AngularCorrectionHFPOdd=0.; EP_finalposodd=-999.;
          //Neg HF
          AngularCorrectionHFNOdd=0.; EP_finalnegodd=-999.;
          //Tracker
          AngularCorrectionTROdd=0.; EP_finaltrodd=-999.;
          if((EPhfeven>-500) && (EPhfodd>-500))
            {
              //Compute Angular Corrections
              for (Int_t k=1;k<(jMax+1);k++)
                {
                  //v1 even
                  //Whole HF
                  AngularCorrectionHFEven+=((2./k)*(((-Sinhfeven[c][k-1])*(cos(k*EPhfeven)))+((Coshfeven[c][k-1])*(sin(k*EPhfeven)))));
                  PsiEvenCorrs[c]->Fill(k-1,fabs(((2./k)*(((-Sinhfeven[c][k-1])*(cos(k*EPhfeven)))+((Coshfeven[c][k-1])*(sin(k*EPhfeven)))))));
                  //Pos HF
                  AngularCorrectionHFPEven+=((2./k)*(((-Sinhfpeven[c][k-1])*(cos(k*EP_poseven)))+((Coshfpeven[c][k-1])*(sin(k*EP_poseven)))));
                  //Neg HF
                  AngularCorrectionHFNEven+=((2./k)*(((-Sinhfneven[c][k-1])*(cos(k*EP_negeven)))+((Coshfneven[c][k-1])*(sin(k*EP_negeven)))));
                  //Tracker
                  AngularCorrectionTREven+=((2./k)*(((-Sintreven[c][k-1])*(cos(k*EP_treven)))+((Costreven[c][k-1])*(sin(k*EP_treven)))));
                  //////////////////////////////////////////////////////
                  //v1 odd
                  //Whole HF
                  AngularCorrectionHFOdd+=((2./k)*(((-Sinhfodd[c][k-1])*(cos(k*EPhfodd)))+((Coshfodd[c][k-1])*(sin(k*EPhfodd)))));
                  PsiOddCorrs[c]->Fill(k-1,fabs(((2./k)*(((-Sinhfodd[c][k-1])*(cos(k*EPhfodd)))+((Coshfodd[c][k-1])*(sin(k*EPhfodd)))))));
                  //Pos HF
                  AngularCorrectionHFPOdd+=((2./k)*(((-Sinhfpodd[c][k-1])*(cos(k*EP_posodd)))+((Coshfpodd[c][k-1])*(sin(k*EP_posodd)))));
                  //Neg HF
                  AngularCorrectionHFNOdd+=((2./k)*(((-Sinhfnodd[c][k-1])*(cos(k*EP_negodd)))+((Coshfnodd[c][k-1])*(sin(k*EP_negodd)))));
                  //Tracker
                  AngularCorrectionTROdd+=((2./k)*(((-Sintrodd[c][k-1])*(cos(k*EP_trodd)))+((Costrodd[c][k-1])*(sin(k*EP_trodd)))));
                }//end of angular correction calculation
            }//prevent bad corrections

          //Add the final Corrections to the Event Plane
          //and store it and do the flow measurement with it


          //v1 even
          //Whole HF
          EPfinalhfeven=EPhfeven+AngularCorrectionHFEven;
          if (EPfinalhfeven>(pi)) EPfinalhfeven=(EPfinalhfeven-(TMath::TwoPi()));
          if (EPfinalhfeven<(-1.0*(pi))) EPfinalhfeven=(EPfinalhfeven+(TMath::TwoPi()));
          if(EPfinalhfeven>-500)
            {
              PsiEvenFinal[c]->Fill(EPfinalhfeven);
            }
          //Pos HF
          EP_finalposeven=EP_poseven+AngularCorrectionHFPEven;
          if (EP_finalposeven>(pi)) EP_finalposeven=(EP_finalposeven-(TMath::TwoPi()));
          if (EP_finalposeven<(-1.0*(pi))) EP_finalposeven=(EP_finalposeven+(TMath::TwoPi()));
          if(EP_finalposeven>-500)
            {
              PsiPEvenFinal[c]->Fill(EP_finalposeven);
            }
          //Neg HF
          EP_finalnegeven=EP_negeven+AngularCorrectionHFNEven;
          if (EP_finalnegeven>(pi)) EP_finalnegeven=(EP_finalnegeven-(TMath::TwoPi()));
          if (EP_finalnegeven<(-1.0*(pi))) EP_finalnegeven=(EP_finalnegeven+(TMath::TwoPi()));
          if(EP_finalnegeven>-500)
            {
              PsiNEvenFinal[c]->Fill(EP_finalnegeven);
            }
          //Tracker
          EP_finaltreven=EP_treven+AngularCorrectionTREven;
          if (EP_finaltreven>(pi)) EP_finaltreven=(EP_finaltreven-(TMath::TwoPi()));
          if (EP_finaltreven<(-1.0*(pi))) EP_finaltreven=(EP_finaltreven+(TMath::TwoPi()));
          if(EP_finaltreven>-500)
            {
              PsiTREvenFinal[c]->Fill(EP_finaltreven);
            }
          //////////////////////////////////////////////////
          //v1 odd
          //Whole HF
          EPfinalhfodd=EPhfodd+AngularCorrectionHFOdd;
          if (EPfinalhfodd>(pi)) EPfinalhfodd=(EPfinalhfodd-(TMath::TwoPi()));
          if (EPfinalhfodd<(-1.0*(pi))) EPfinalhfodd=(EPfinalhfodd+(TMath::TwoPi()));
          if(EPfinalhfodd>-500){
            PsiOddFinal[c]->Fill(EPfinalhfodd);
          }
          //Pos HF
          EP_finalposodd=EP_posodd+AngularCorrectionHFPOdd;
          if (EP_finalposodd>(pi)) EP_finalposodd=(EP_finalposodd-(TMath::TwoPi()));
          if (EP_finalposodd<(-1.0*(pi))) EP_finalposodd=(EP_finalposodd+(TMath::TwoPi()));
          if(EP_finalposodd>-500)
            {
              PsiPOddFinal[c]->Fill(EP_finalposodd);
            }
          //Neg HF
          EP_finalnegodd=EP_negodd+AngularCorrectionHFNOdd;
          if (EP_finalnegodd>(pi)) EP_finalnegodd=(EP_finalnegodd-(TMath::TwoPi()));
          if (EP_finalnegodd<(-1.0*(pi))) EP_finalnegodd=(EP_finalnegodd+(TMath::TwoPi()));
          if(EP_finalnegodd>-500)
            {
              PsiNOddFinal[c]->Fill(EP_finalnegodd);
            }
          //Tracker
          EP_finaltrodd=EP_trodd+AngularCorrectionTROdd;
          if (EP_finaltrodd>(pi)) EP_finaltrodd=(EP_finaltrodd-(TMath::TwoPi()));
          if (EP_finaltrodd<(-1.0*(pi))) EP_finaltrodd=(EP_finaltrodd+(TMath::TwoPi()));
          if(EP_finaltrodd>-500)
            {
              PsiTROddFinal[c]->Fill(EP_finaltrodd);
            }
	  
	  ///////////////////Fill Resolution Plots///////////////////
	  //Even
	  HFPMinusHFMEven->Fill(c,TMath::Cos(EP_finalposeven-EP_finalnegeven));
	  HFPMinusTREven->Fill(c,TMath::Cos(EP_finalposeven-EP_finaltreven));
	  HFMMinusTREven->Fill(c,TMath::Cos(EP_finalnegeven-EP_finaltreven));
	  //Odd
	  HFPMinusHFMOdd->Fill(c,TMath::Cos(EP_finalposodd-EP_finalnegodd));
	  HFPMinusTROdd->Fill(c,TMath::Cos(EP_finalposodd-EP_finaltrodd));
	  HFMMinusTROdd->Fill(c,TMath::Cos(EP_finalnegodd-EP_finaltrodd));
	  
	  //Fill V1 Histograms
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
              if(fabs(eta)<=0.6 && pT>0.4)
                {
                  V1EtaOdd[c]->Fill(eta,TMath::Cos(phi-EPfinalhfodd));
                  V1EtaEven[c]->Fill(eta,TMath::Cos(phi-EPfinalhfeven));
                  V1PtEven[c]->Fill(pT,TMath::Cos(phi-EPfinalhfeven));
                  PTCenters[c]->Fill(pT,pT);
                  if(eta>0) V1PtOdd[c]->Fill(pT,TMath::Cos(phi-EPfinalhfodd));//can find offset later with removing the eta gate here
                }//only central tracks
            }//end of loop over tracks

        }//End of loop over Centralities
    }//End of loop over events
  myFile->Write();
  // delete myFile;
}//end of ep plotting


void FillAngularCorrections(){
//V1 Even
//Whole HF
Coshfeven[0][0]=0.0504601;
Coshfeven[1][0]=0.0472016;
Coshfeven[2][0]=0.0433566;
Coshfeven[3][0]=0.00973836;
Coshfeven[4][0]=0.0161413;
 
Sinhfeven[0][0]=0.146745;
Sinhfeven[1][0]=0.129706;
Sinhfeven[2][0]=0.121496;
Sinhfeven[3][0]=0.123527;
Sinhfeven[4][0]=0.0948812;
 
Coshfeven[0][1]=-0.011105;
Coshfeven[1][1]=-0.00683029;
Coshfeven[2][1]=-0.00629006;
Coshfeven[3][1]=-0.00474781;
Coshfeven[4][1]=-0.0140649;
 
Sinhfeven[0][1]=0.0026002;
Sinhfeven[1][1]=0.00726952;
Sinhfeven[2][1]=0.00493712;
Sinhfeven[3][1]=0.00303686;
Sinhfeven[4][1]=-0.00759746;
 
Coshfeven[0][2]=-0.00242757;
Coshfeven[1][2]=-0.00855415;
Coshfeven[2][2]=-0.0131655;
Coshfeven[3][2]=0.00121037;
Coshfeven[4][2]=-0.00412133;
 
Sinhfeven[0][2]=-0.0147181;
Sinhfeven[1][2]=0.000225647;
Sinhfeven[2][2]=-0.00521029;
Sinhfeven[3][2]=-0.0257868;
Sinhfeven[4][2]=0.0137561;
 
Coshfeven[0][3]=0.00672356;
Coshfeven[1][3]=-0.00271555;
Coshfeven[2][3]=0.00475002;
Coshfeven[3][3]=-0.00163846;
Coshfeven[4][3]=0.0109814;
 
Sinhfeven[0][3]=-0.0130812;
Sinhfeven[1][3]=0.00262471;
Sinhfeven[2][3]=0.00473442;
Sinhfeven[3][3]=0.0121032;
Sinhfeven[4][3]=0.00326118;
 
Coshfeven[0][4]=0.0134488;
Coshfeven[1][4]=0.0131461;
Coshfeven[2][4]=0.0100114;
Coshfeven[3][4]=0.00391807;
Coshfeven[4][4]=0.00974138;
 
Sinhfeven[0][4]=-0.00780987;
Sinhfeven[1][4]=-0.00373602;
Sinhfeven[2][4]=0.00549321;
Sinhfeven[3][4]=-0.0140058;
Sinhfeven[4][4]=-0.0205709;
 
Coshfeven[0][5]=0.0107638;
Coshfeven[1][5]=-0.00401441;
Coshfeven[2][5]=-0.00380392;
Coshfeven[3][5]=0.0127897;
Coshfeven[4][5]=-0.00798498;
 
Sinhfeven[0][5]=-0.0108658;
Sinhfeven[1][5]=-0.00130874;
Sinhfeven[2][5]=0.00824447;
Sinhfeven[3][5]=-0.00963649;
Sinhfeven[4][5]=-0.00997259;
 
Coshfeven[0][6]=0.0109286;
Coshfeven[1][6]=0.00200551;
Coshfeven[2][6]=0.0143378;
Coshfeven[3][6]=0.00239896;
Coshfeven[4][6]=0.000654517;
 
Sinhfeven[0][6]=-0.00123455;
Sinhfeven[1][6]=-0.0122104;
Sinhfeven[2][6]=0.0143031;
Sinhfeven[3][6]=0.00422394;
Sinhfeven[4][6]=-0.0160473;
 
Coshfeven[0][7]=-0.00700873;
Coshfeven[1][7]=-0.000712004;
Coshfeven[2][7]=0.0163594;
Coshfeven[3][7]=-0.00187405;
Coshfeven[4][7]=-0.0129659;
 
Sinhfeven[0][7]=-0.000900815;
Sinhfeven[1][7]=-0.00730905;
Sinhfeven[2][7]=0.000207454;
Sinhfeven[3][7]=-0.00364953;
Sinhfeven[4][7]=0.000131854;
 
Coshfeven[0][8]=-0.00898922;
Coshfeven[1][8]=0.0137846;
Coshfeven[2][8]=0.0212538;
Coshfeven[3][8]=-0.0155903;
Coshfeven[4][8]=-0.0215887;
 
Sinhfeven[0][8]=-0.00625649;
Sinhfeven[1][8]=-0.00657571;
Sinhfeven[2][8]=0.00509969;
Sinhfeven[3][8]=-0.0221698;
Sinhfeven[4][8]=-0.00647917;
 
Coshfeven[0][9]=-0.00841709;
Coshfeven[1][9]=-0.00237068;
Coshfeven[2][9]=0.00451397;
Coshfeven[3][9]=0.000866737;
Coshfeven[4][9]=0.00574424;
 
Sinhfeven[0][9]=-0.00684316;
Sinhfeven[1][9]=0.00385048;
Sinhfeven[2][9]=-0.0119116;
Sinhfeven[3][9]=0.00592499;
Sinhfeven[4][9]=0.00723008;
 
 
//Pos HF
Coshfpeven[0][0]=0.192394;
Coshfpeven[1][0]=0.172024;
Coshfpeven[2][0]=0.155302;
Coshfpeven[3][0]=0.104693;
Coshfpeven[4][0]=0.108727;
 
Sinhfpeven[0][0]=0.197296;
Sinhfpeven[1][0]=0.165356;
Sinhfpeven[2][0]=0.13749;
Sinhfpeven[3][0]=0.132116;
Sinhfpeven[4][0]=0.102459;
 
Coshfpeven[0][1]=0.00574568;
Coshfpeven[1][1]=0.00589276;
Coshfpeven[2][1]=0.00644533;
Coshfpeven[3][1]=0.00173755;
Coshfpeven[4][1]=-0.0164573;
 
Sinhfpeven[0][1]=0.0308516;
Sinhfpeven[1][1]=0.0217704;
Sinhfpeven[2][1]=0.0276162;
Sinhfpeven[3][1]=0.0253944;
Sinhfpeven[4][1]=0.00996781;
 
Coshfpeven[0][2]=0.00902329;
Coshfpeven[1][2]=0.011157;
Coshfpeven[2][2]=0.00420973;
Coshfpeven[3][2]=0.000569893;
Coshfpeven[4][2]=-0.00511388;
 
Sinhfpeven[0][2]=-0.0340165;
Sinhfpeven[1][2]=0.000427765;
Sinhfpeven[2][2]=0.0153804;
Sinhfpeven[3][2]=-0.0092828;
Sinhfpeven[4][2]=-0.010588;
 
Coshfpeven[0][3]=0.0158174;
Coshfpeven[1][3]=-0.00124247;
Coshfpeven[2][3]=0.00458464;
Coshfpeven[3][3]=-0.00194145;
Coshfpeven[4][3]=-0.00680576;
 
Sinhfpeven[0][3]=-0.00534942;
Sinhfpeven[1][3]=0.00224135;
Sinhfpeven[2][3]=0.00752612;
Sinhfpeven[3][3]=-0.0031422;
Sinhfpeven[4][3]=0.00371106;
 
Coshfpeven[0][4]=0.0100973;
Coshfpeven[1][4]=-0.000909178;
Coshfpeven[2][4]=0.0137394;
Coshfpeven[3][4]=0.0101893;
Coshfpeven[4][4]=-0.00975685;
 
Sinhfpeven[0][4]=-0.00355679;
Sinhfpeven[1][4]=-0.00490041;
Sinhfpeven[2][4]=0.020299;
Sinhfpeven[3][4]=-0.00294026;
Sinhfpeven[4][4]=-0.00990481;
 
Coshfpeven[0][5]=-0.0175694;
Coshfpeven[1][5]=-0.0194091;
Coshfpeven[2][5]=-0.0185706;
Coshfpeven[3][5]=-0.0142187;
Coshfpeven[4][5]=-0.00712577;
 
Sinhfpeven[0][5]=0.00300564;
Sinhfpeven[1][5]=-0.00447009;
Sinhfpeven[2][5]=0.00716821;
Sinhfpeven[3][5]=0.0142123;
Sinhfpeven[4][5]=-0.00507431;
 
Coshfpeven[0][6]=-0.00996924;
Coshfpeven[1][6]=-0.00818871;
Coshfpeven[2][6]=-0.0142466;
Coshfpeven[3][6]=-0.0141969;
Coshfpeven[4][6]=0.00323306;
 
Sinhfpeven[0][6]=0.00269729;
Sinhfpeven[1][6]=0.00984226;
Sinhfpeven[2][6]=-0.0183614;
Sinhfpeven[3][6]=0.00676974;
Sinhfpeven[4][6]=0.00626314;
 
Coshfpeven[0][7]=0.000352128;
Coshfpeven[1][7]=0.000598467;
Coshfpeven[2][7]=-0.0202021;
Coshfpeven[3][7]=-0.0291817;
Coshfpeven[4][7]=-0.00561847;
 
Sinhfpeven[0][7]=0.00587364;
Sinhfpeven[1][7]=0.000515468;
Sinhfpeven[2][7]=-0.00438378;
Sinhfpeven[3][7]=-0.00127252;
Sinhfpeven[4][7]=0.00103465;
 
Coshfpeven[0][8]=-0.0102684;
Coshfpeven[1][8]=-0.0125813;
Coshfpeven[2][8]=-0.0256386;
Coshfpeven[3][8]=0.0120307;
Coshfpeven[4][8]=0.0162876;
 
Sinhfpeven[0][8]=0.0170016;
Sinhfpeven[1][8]=0.0277903;
Sinhfpeven[2][8]=0.0136342;
Sinhfpeven[3][8]=0.00632485;
Sinhfpeven[4][8]=-0.00784117;
 
Coshfpeven[0][9]=-0.00331922;
Coshfpeven[1][9]=-0.00757989;
Coshfpeven[2][9]=0.00257004;
Coshfpeven[3][9]=0.00601984;
Coshfpeven[4][9]=-0.00713666;
 
Sinhfpeven[0][9]=0.00139063;
Sinhfpeven[1][9]=0.021544;
Sinhfpeven[2][9]=0.0189059;
Sinhfpeven[3][9]=0.000137123;
Sinhfpeven[4][9]=0.0118193;
 
 
//Neg HF
Coshfneven[0][0]=-0.133964;
Coshfneven[1][0]=-0.126939;
Coshfneven[2][0]=-0.096345;
Coshfneven[3][0]=-0.0885086;
Coshfneven[4][0]=-0.0762884;
 
Sinhfneven[0][0]=-0.000591132;
Sinhfneven[1][0]=0.0125618;
Sinhfneven[2][0]=0.0258075;
Sinhfneven[3][0]=0.0189842;
Sinhfneven[4][0]=0.023592;
 
Coshfneven[0][1]=0.0254033;
Coshfneven[1][1]=0.00661002;
Coshfneven[2][1]=0.0089859;
Coshfneven[3][1]=0.00703614;
Coshfneven[4][1]=-0.0071202;
 
Sinhfneven[0][1]=0.0172893;
Sinhfneven[1][1]=0.0259611;
Sinhfneven[2][1]=0.0132427;
Sinhfneven[3][1]=-0.00571023;
Sinhfneven[4][1]=0.0115859;
 
Coshfneven[0][2]=-0.0166275;
Coshfneven[1][2]=0.00765222;
Coshfneven[2][2]=0.00156614;
Coshfneven[3][2]=-0.00779096;
Coshfneven[4][2]=-0.0300411;
 
Sinhfneven[0][2]=-0.0191235;
Sinhfneven[1][2]=-0.00555824;
Sinhfneven[2][2]=0.00681077;
Sinhfneven[3][2]=-0.0219432;
Sinhfneven[4][2]=-0.00687308;
 
Coshfneven[0][3]=-0.00251506;
Coshfneven[1][3]=-0.0167704;
Coshfneven[2][3]=-0.0150019;
Coshfneven[3][3]=0.011265;
Coshfneven[4][3]=0.000539046;
 
Sinhfneven[0][3]=-0.0147081;
Sinhfneven[1][3]=-0.00734449;
Sinhfneven[2][3]=-0.00445355;
Sinhfneven[3][3]=-0.00137768;
Sinhfneven[4][3]=0.00311268;
 
Coshfneven[0][4]=-0.00565514;
Coshfneven[1][4]=-0.00688952;
Coshfneven[2][4]=-0.00671866;
Coshfneven[3][4]=-0.00461493;
Coshfneven[4][4]=-0.0106478;
 
Sinhfneven[0][4]=-0.00303194;
Sinhfneven[1][4]=0.00762672;
Sinhfneven[2][4]=0.00337244;
Sinhfneven[3][4]=-0.00295136;
Sinhfneven[4][4]=-0.0131535;
 
Coshfneven[0][5]=0.00601737;
Coshfneven[1][5]=-0.00151893;
Coshfneven[2][5]=-0.00568489;
Coshfneven[3][5]=-0.0105879;
Coshfneven[4][5]=-0.00884331;
 
Sinhfneven[0][5]=0.00366042;
Sinhfneven[1][5]=0.0167148;
Sinhfneven[2][5]=-0.00368519;
Sinhfneven[3][5]=-0.00265407;
Sinhfneven[4][5]=-0.00447821;
 
Coshfneven[0][6]=0.0158124;
Coshfneven[1][6]=0.000293554;
Coshfneven[2][6]=-0.00686337;
Coshfneven[3][6]=0.0028106;
Coshfneven[4][6]=-0.00609704;
 
Sinhfneven[0][6]=-0.00154937;
Sinhfneven[1][6]=0.0144852;
Sinhfneven[2][6]=-0.00411428;
Sinhfneven[3][6]=-0.000428007;
Sinhfneven[4][6]=-0.0171798;
 
Coshfneven[0][7]=-0.010566;
Coshfneven[1][7]=-0.00526495;
Coshfneven[2][7]=0.0133472;
Coshfneven[3][7]=0.0162442;
Coshfneven[4][7]=0.00951751;
 
Sinhfneven[0][7]=0.00315046;
Sinhfneven[1][7]=0.0144943;
Sinhfneven[2][7]=-0.00930337;
Sinhfneven[3][7]=0.0230576;
Sinhfneven[4][7]=0.023653;
 
Coshfneven[0][8]=-0.000553421;
Coshfneven[1][8]=0.0120493;
Coshfneven[2][8]=-0.0109369;
Coshfneven[3][8]=0.0126564;
Coshfneven[4][8]=-0.0160574;
 
Sinhfneven[0][8]=-0.00489452;
Sinhfneven[1][8]=-0.0085746;
Sinhfneven[2][8]=0.00615833;
Sinhfneven[3][8]=-0.00476168;
Sinhfneven[4][8]=-0.0115194;
 
Coshfneven[0][9]=-0.0149984;
Coshfneven[1][9]=-0.0138669;
Coshfneven[2][9]=-0.00530945;
Coshfneven[3][9]=0.00428647;
Coshfneven[4][9]=0.00931268;
 
Sinhfneven[0][9]=0.0237564;
Sinhfneven[1][9]=0.00219445;
Sinhfneven[2][9]=0.00204829;
Sinhfneven[3][9]=-0.000526974;
Sinhfneven[4][9]=0.00981842;
 
 
//Mid Tracker
Costreven[0][0]=-0.229914;
Costreven[1][0]=-0.203564;
Costreven[2][0]=-0.150611;
Costreven[3][0]=-0.152092;
Costreven[4][0]=-0.139591;
 
Sintreven[0][0]=-0.1655;
Sintreven[1][0]=-0.153055;
Sintreven[2][0]=-0.122671;
Sintreven[3][0]=-0.113906;
Sintreven[4][0]=-0.0935194;
 
Costreven[0][1]=-0.0091618;
Costreven[1][1]=0.0178174;
Costreven[2][1]=-0.00325513;
Costreven[3][1]=-0.0253444;
Costreven[4][1]=0.00824379;
 
Sintreven[0][1]=0.0335649;
Sintreven[1][1]=0.01442;
Sintreven[2][1]=0.0156132;
Sintreven[3][1]=0.00999976;
Sintreven[4][1]=0.0279753;
 
Costreven[0][2]=-0.000393379;
Costreven[1][2]=-0.0156544;
Costreven[2][2]=-0.024917;
Costreven[3][2]=-0.0027136;
Costreven[4][2]=-0.00634765;
 
Sintreven[0][2]=0.00846484;
Sintreven[1][2]=-0.00209647;
Sintreven[2][2]=0.0193306;
Sintreven[3][2]=0.000715934;
Sintreven[4][2]=-0.0148033;
 
Costreven[0][3]=0.00677833;
Costreven[1][3]=-0.00608482;
Costreven[2][3]=0.000585094;
Costreven[3][3]=-0.0131954;
Costreven[4][3]=0.00522725;
 
Sintreven[0][3]=0.00598009;
Sintreven[1][3]=0.00158781;
Sintreven[2][3]=0.00781046;
Sintreven[3][3]=-0.00050673;
Sintreven[4][3]=-0.00543452;
 
Costreven[0][4]=0.00454013;
Costreven[1][4]=-0.0104648;
Costreven[2][4]=0.0034325;
Costreven[3][4]=0.000333277;
Costreven[4][4]=0.0221968;
 
Sintreven[0][4]=-0.0118447;
Sintreven[1][4]=-0.00110255;
Sintreven[2][4]=-0.00113235;
Sintreven[3][4]=-0.0179426;
Sintreven[4][4]=0.00109223;
 
Costreven[0][5]=0.00898476;
Costreven[1][5]=0.000691494;
Costreven[2][5]=-0.022154;
Costreven[3][5]=-0.0103354;
Costreven[4][5]=-0.0102448;
 
Sintreven[0][5]=0.00181588;
Sintreven[1][5]=0.00436675;
Sintreven[2][5]=0.0064289;
Sintreven[3][5]=0.000932195;
Sintreven[4][5]=0.0180688;
 
Costreven[0][6]=-0.0079318;
Costreven[1][6]=0.00454202;
Costreven[2][6]=-0.0106951;
Costreven[3][6]=0.000816268;
Costreven[4][6]=0.0124256;
 
Sintreven[0][6]=0.0118868;
Sintreven[1][6]=0.00674918;
Sintreven[2][6]=0.0180976;
Sintreven[3][6]=0.0136667;
Sintreven[4][6]=0.00546926;
 
Costreven[0][7]=0.00242537;
Costreven[1][7]=0.00649841;
Costreven[2][7]=0.0063109;
Costreven[3][7]=-0.00354296;
Costreven[4][7]=0.00539705;
 
Sintreven[0][7]=-0.00517766;
Sintreven[1][7]=-0.0313484;
Sintreven[2][7]=0.00276085;
Sintreven[3][7]=-0.00254177;
Sintreven[4][7]=-0.0175925;
 
Costreven[0][8]=-0.0280315;
Costreven[1][8]=-0.00860119;
Costreven[2][8]=0.0178342;
Costreven[3][8]=-0.00134717;
Costreven[4][8]=-0.00385222;
 
Sintreven[0][8]=0.0233758;
Sintreven[1][8]=0.00945239;
Sintreven[2][8]=-0.00619437;
Sintreven[3][8]=0.00498418;
Sintreven[4][8]=0.0202141;
 
Costreven[0][9]=0.0121314;
Costreven[1][9]=-0.00548258;
Costreven[2][9]=-0.00824129;
Costreven[3][9]=0.000507685;
Costreven[4][9]=-0.00322184;
 
Sintreven[0][9]=-0.0106715;
Sintreven[1][9]=-0.0120719;
Sintreven[2][9]=0.00289106;
Sintreven[3][9]=-0.00164962;
Sintreven[4][9]=-0.0116605;
 
//V1 Odd
//Whole HF
Coshfodd[0][0]=0.220979;
Coshfodd[1][0]=0.197548;
Coshfodd[2][0]=0.176838;
Coshfodd[3][0]=0.136012;
Coshfodd[4][0]=0.112904;
 
Sinhfodd[0][0]=0.128575;
Sinhfodd[1][0]=0.102133;
Sinhfodd[2][0]=0.0715433;
Sinhfodd[3][0]=0.0667778;
Sinhfodd[4][0]=0.0648855;
 
Coshfodd[0][1]=0.00139971;
Coshfodd[1][1]=0.0231363;
Coshfodd[2][1]=0.0116307;
Coshfodd[3][1]=-0.00841875;
Coshfodd[4][1]=0.00710805;
 
Sinhfodd[0][1]=0.034872;
Sinhfodd[1][1]=0.047664;
Sinhfodd[2][1]=0.0281139;
Sinhfodd[3][1]=0.010729;
Sinhfodd[4][1]=0.0199081;
 
Coshfodd[0][2]=-0.0024782;
Coshfodd[1][2]=0.000328078;
Coshfodd[2][2]=-0.00740645;
Coshfodd[3][2]=0.00447024;
Coshfodd[4][2]=0.00444873;
 
Sinhfodd[0][2]=-0.0102114;
Sinhfodd[1][2]=-0.0164798;
Sinhfodd[2][2]=0.013323;
Sinhfodd[3][2]=-0.00990728;
Sinhfodd[4][2]=-0.00491265;
 
Coshfodd[0][3]=0.00589423;
Coshfodd[1][3]=0.00362373;
Coshfodd[2][3]=0.00827149;
Coshfodd[3][3]=0.0158469;
Coshfodd[4][3]=-0.00906486;
 
Sinhfodd[0][3]=-0.00503115;
Sinhfodd[1][3]=-0.0087635;
Sinhfodd[2][3]=0.0120149;
Sinhfodd[3][3]=0.00459515;
Sinhfodd[4][3]=-0.0110745;
 
Coshfodd[0][4]=-0.000694515;
Coshfodd[1][4]=0.0129005;
Coshfodd[2][4]=-0.00542739;
Coshfodd[3][4]=-0.00386301;
Coshfodd[4][4]=-0.0152087;
 
Sinhfodd[0][4]=0.00533804;
Sinhfodd[1][4]=0.0129549;
Sinhfodd[2][4]=0.01325;
Sinhfodd[3][4]=0.0118218;
Sinhfodd[4][4]=-0.00895021;
 
Coshfodd[0][5]=0.0178279;
Coshfodd[1][5]=-0.00405927;
Coshfodd[2][5]=0.00724778;
Coshfodd[3][5]=0.00874356;
Coshfodd[4][5]=0.00242475;
 
Sinhfodd[0][5]=0.00506922;
Sinhfodd[1][5]=0.00461258;
Sinhfodd[2][5]=0.0173403;
Sinhfodd[3][5]=-0.0143111;
Sinhfodd[4][5]=-0.00249206;
 
Coshfodd[0][6]=0.0131684;
Coshfodd[1][6]=-0.00937939;
Coshfodd[2][6]=0.0142745;
Coshfodd[3][6]=0.0139554;
Coshfodd[4][6]=-0.00585791;
 
Sinhfodd[0][6]=0.0108659;
Sinhfodd[1][6]=0.000218152;
Sinhfodd[2][6]=0.00457994;
Sinhfodd[3][6]=0.0238294;
Sinhfodd[4][6]=-0.0026762;
 
Coshfodd[0][7]=-0.0015004;
Coshfodd[1][7]=-0.0129012;
Coshfodd[2][7]=-0.00940606;
Coshfodd[3][7]=-0.00763631;
Coshfodd[4][7]=-0.00649536;
 
Sinhfodd[0][7]=0.00438958;
Sinhfodd[1][7]=0.00483675;
Sinhfodd[2][7]=-0.00781342;
Sinhfodd[3][7]=0.00627546;
Sinhfodd[4][7]=0.0167657;
 
Coshfodd[0][8]=-0.00425196;
Coshfodd[1][8]=-0.00973024;
Coshfodd[2][8]=0.000443451;
Coshfodd[3][8]=0.0155866;
Coshfodd[4][8]=-0.0115663;
 
Sinhfodd[0][8]=0.0263636;
Sinhfodd[1][8]=-0.0036711;
Sinhfodd[2][8]=-0.00379309;
Sinhfodd[3][8]=-0.0164478;
Sinhfodd[4][8]=-0.0385547;
 
Coshfodd[0][9]=-0.00647625;
Coshfodd[1][9]=-0.00555334;
Coshfodd[2][9]=0.000670465;
Coshfodd[3][9]=0.0172076;
Coshfodd[4][9]=0.0103492;
 
Sinhfodd[0][9]=0.007765;
Sinhfodd[1][9]=-0.00626677;
Sinhfodd[2][9]=0.00314159;
Sinhfodd[3][9]=0.00532246;
Sinhfodd[4][9]=0.00941119;
 
 
//Pos HF
Coshfpodd[0][0]=0.192394;
Coshfpodd[1][0]=0.172024;
Coshfpodd[2][0]=0.155302;
Coshfpodd[3][0]=0.104693;
Coshfpodd[4][0]=0.108727;
 
Sinhfpodd[0][0]=0.197296;
Sinhfpodd[1][0]=0.165356;
Sinhfpodd[2][0]=0.13749;
Sinhfpodd[3][0]=0.132116;
Sinhfpodd[4][0]=0.102459;
 
Coshfpodd[0][1]=0.00574568;
Coshfpodd[1][1]=0.00589276;
Coshfpodd[2][1]=0.00644533;
Coshfpodd[3][1]=0.00173755;
Coshfpodd[4][1]=-0.0164573;
 
Sinhfpodd[0][1]=0.0308516;
Sinhfpodd[1][1]=0.0217704;
Sinhfpodd[2][1]=0.0276162;
Sinhfpodd[3][1]=0.0253944;
Sinhfpodd[4][1]=0.00996781;
 
Coshfpodd[0][2]=0.00902329;
Coshfpodd[1][2]=0.011157;
Coshfpodd[2][2]=0.00420973;
Coshfpodd[3][2]=0.000569893;
Coshfpodd[4][2]=-0.00511388;
 
Sinhfpodd[0][2]=-0.0340165;
Sinhfpodd[1][2]=0.000427765;
Sinhfpodd[2][2]=0.0153804;
Sinhfpodd[3][2]=-0.0092828;
Sinhfpodd[4][2]=-0.010588;
 
Coshfpodd[0][3]=0.0158174;
Coshfpodd[1][3]=-0.00124247;
Coshfpodd[2][3]=0.00458464;
Coshfpodd[3][3]=-0.00194145;
Coshfpodd[4][3]=-0.00680576;
 
Sinhfpodd[0][3]=-0.00534942;
Sinhfpodd[1][3]=0.00224135;
Sinhfpodd[2][3]=0.00752612;
Sinhfpodd[3][3]=-0.0031422;
Sinhfpodd[4][3]=0.00371106;
 
Coshfpodd[0][4]=0.0100973;
Coshfpodd[1][4]=-0.000909178;
Coshfpodd[2][4]=0.0137394;
Coshfpodd[3][4]=0.0101893;
Coshfpodd[4][4]=-0.00975685;
 
Sinhfpodd[0][4]=-0.00355679;
Sinhfpodd[1][4]=-0.00490041;
Sinhfpodd[2][4]=0.020299;
Sinhfpodd[3][4]=-0.00294026;
Sinhfpodd[4][4]=-0.00990481;
 
Coshfpodd[0][5]=-0.0175694;
Coshfpodd[1][5]=-0.0194091;
Coshfpodd[2][5]=-0.0185706;
Coshfpodd[3][5]=-0.0142187;
Coshfpodd[4][5]=-0.00712577;
 
Sinhfpodd[0][5]=0.00300564;
Sinhfpodd[1][5]=-0.00447009;
Sinhfpodd[2][5]=0.00716821;
Sinhfpodd[3][5]=0.0142123;
Sinhfpodd[4][5]=-0.00507431;
 
Coshfpodd[0][6]=-0.00996924;
Coshfpodd[1][6]=-0.00818871;
Coshfpodd[2][6]=-0.0142466;
Coshfpodd[3][6]=-0.0141969;
Coshfpodd[4][6]=0.00323306;
 
Sinhfpodd[0][6]=0.00269729;
Sinhfpodd[1][6]=0.00984226;
Sinhfpodd[2][6]=-0.0183614;
Sinhfpodd[3][6]=0.00676974;
Sinhfpodd[4][6]=0.00626314;
 
Coshfpodd[0][7]=0.000352128;
Coshfpodd[1][7]=0.000598467;
Coshfpodd[2][7]=-0.0202021;
Coshfpodd[3][7]=-0.0291817;
Coshfpodd[4][7]=-0.00561847;
 
Sinhfpodd[0][7]=0.00587364;
Sinhfpodd[1][7]=0.000515468;
Sinhfpodd[2][7]=-0.00438378;
Sinhfpodd[3][7]=-0.00127252;
Sinhfpodd[4][7]=0.00103465;
 
Coshfpodd[0][8]=-0.0102684;
Coshfpodd[1][8]=-0.0125813;
Coshfpodd[2][8]=-0.0256386;
Coshfpodd[3][8]=0.0120307;
Coshfpodd[4][8]=0.0162876;
 
Sinhfpodd[0][8]=0.0170016;
Sinhfpodd[1][8]=0.0277903;
Sinhfpodd[2][8]=0.0136342;
Sinhfpodd[3][8]=0.00632485;
Sinhfpodd[4][8]=-0.00784117;
 
Coshfpodd[0][9]=-0.00331922;
Coshfpodd[1][9]=-0.00757989;
Coshfpodd[2][9]=0.00257004;
Coshfpodd[3][9]=0.00601984;
Coshfpodd[4][9]=-0.00713666;
 
Sinhfpodd[0][9]=0.00139063;
Sinhfpodd[1][9]=0.021544;
Sinhfpodd[2][9]=0.0189059;
Sinhfpodd[3][9]=0.000137123;
Sinhfpodd[4][9]=0.0118193;
 
 
//Neg HF
Coshfnodd[0][0]=0.133964;
Coshfnodd[1][0]=0.126939;
Coshfnodd[2][0]=0.096345;
Coshfnodd[3][0]=0.0885086;
Coshfnodd[4][0]=0.0762884;
 
Sinhfnodd[0][0]=0.000591132;
Sinhfnodd[1][0]=-0.0125618;
Sinhfnodd[2][0]=-0.0258075;
Sinhfnodd[3][0]=-0.0189842;
Sinhfnodd[4][0]=-0.023592;
 
Coshfnodd[0][1]=0.0254033;
Coshfnodd[1][1]=0.00661002;
Coshfnodd[2][1]=0.0089859;
Coshfnodd[3][1]=0.00703614;
Coshfnodd[4][1]=-0.0071202;
 
Sinhfnodd[0][1]=0.0172893;
Sinhfnodd[1][1]=0.0259611;
Sinhfnodd[2][1]=0.0132427;
Sinhfnodd[3][1]=-0.00571023;
Sinhfnodd[4][1]=0.0115859;
 
Coshfnodd[0][2]=0.0166275;
Coshfnodd[1][2]=-0.00765222;
Coshfnodd[2][2]=-0.00156614;
Coshfnodd[3][2]=0.00779097;
Coshfnodd[4][2]=0.0300411;
 
Sinhfnodd[0][2]=0.0191235;
Sinhfnodd[1][2]=0.00555824;
Sinhfnodd[2][2]=-0.00681078;
Sinhfnodd[3][2]=0.0219432;
Sinhfnodd[4][2]=0.00687308;
 
Coshfnodd[0][3]=-0.00251507;
Coshfnodd[1][3]=-0.0167704;
Coshfnodd[2][3]=-0.0150018;
Coshfnodd[3][3]=0.011265;
Coshfnodd[4][3]=0.000539046;
 
Sinhfnodd[0][3]=-0.0147081;
Sinhfnodd[1][3]=-0.00734449;
Sinhfnodd[2][3]=-0.00445356;
Sinhfnodd[3][3]=-0.00137768;
Sinhfnodd[4][3]=0.00311269;
 
Coshfnodd[0][4]=0.00565514;
Coshfnodd[1][4]=0.00688952;
Coshfnodd[2][4]=0.00671866;
Coshfnodd[3][4]=0.00461493;
Coshfnodd[4][4]=0.0106478;
 
Sinhfnodd[0][4]=0.00303193;
Sinhfnodd[1][4]=-0.00762673;
Sinhfnodd[2][4]=-0.00337244;
Sinhfnodd[3][4]=0.00295136;
Sinhfnodd[4][4]=0.0131535;
 
Coshfnodd[0][5]=0.00601737;
Coshfnodd[1][5]=-0.00151892;
Coshfnodd[2][5]=-0.00568489;
Coshfnodd[3][5]=-0.0105879;
Coshfnodd[4][5]=-0.0088433;
 
Sinhfnodd[0][5]=0.00366042;
Sinhfnodd[1][5]=0.0167148;
Sinhfnodd[2][5]=-0.00368519;
Sinhfnodd[3][5]=-0.00265407;
Sinhfnodd[4][5]=-0.00447821;
 
Coshfnodd[0][6]=-0.0158124;
Coshfnodd[1][6]=-0.000293558;
Coshfnodd[2][6]=0.00686336;
Coshfnodd[3][6]=-0.0028106;
Coshfnodd[4][6]=0.00609705;
 
Sinhfnodd[0][6]=0.00154937;
Sinhfnodd[1][6]=-0.0144852;
Sinhfnodd[2][6]=0.00411427;
Sinhfnodd[3][6]=0.000428009;
Sinhfnodd[4][6]=0.0171798;
 
Coshfnodd[0][7]=-0.010566;
Coshfnodd[1][7]=-0.00526495;
Coshfnodd[2][7]=0.0133472;
Coshfnodd[3][7]=0.0162442;
Coshfnodd[4][7]=0.00951752;
 
Sinhfnodd[0][7]=0.00315046;
Sinhfnodd[1][7]=0.0144943;
Sinhfnodd[2][7]=-0.00930338;
Sinhfnodd[3][7]=0.0230576;
Sinhfnodd[4][7]=0.023653;
 
Coshfnodd[0][8]=0.000553412;
Coshfnodd[1][8]=-0.0120493;
Coshfnodd[2][8]=0.0109369;
Coshfnodd[3][8]=-0.0126564;
Coshfnodd[4][8]=0.0160574;
 
Sinhfnodd[0][8]=0.00489453;
Sinhfnodd[1][8]=0.0085746;
Sinhfnodd[2][8]=-0.00615834;
Sinhfnodd[3][8]=0.00476167;
Sinhfnodd[4][8]=0.0115194;
 
Coshfnodd[0][9]=-0.0149984;
Coshfnodd[1][9]=-0.0138669;
Coshfnodd[2][9]=-0.00530945;
Coshfnodd[3][9]=0.00428647;
Coshfnodd[4][9]=0.00931268;
 
Sinhfnodd[0][9]=0.0237564;
Sinhfnodd[1][9]=0.00219445;
Sinhfnodd[2][9]=0.00204829;
Sinhfnodd[3][9]=-0.00052697;
Sinhfnodd[4][9]=0.00981843;
 
 
//Mid Tracker
Costrodd[0][0]=0.00628439;
Costrodd[1][0]=0.0103488;
Costrodd[2][0]=0.0205726;
Costrodd[3][0]=0.00774722;
Costrodd[4][0]=0.00488571;
 
Sintrodd[0][0]=-0.127922;
Sintrodd[1][0]=-0.113361;
Sintrodd[2][0]=-0.101353;
Sintrodd[3][0]=-0.0697692;
Sintrodd[4][0]=-0.0605921;
 
Costrodd[0][1]=-0.0132891;
Costrodd[1][1]=0.0123143;
Costrodd[2][1]=-0.00694278;
Costrodd[3][1]=-0.0123657;
Costrodd[4][1]=0.0100762;
 
Sintrodd[0][1]=-0.0324148;
Sintrodd[1][1]=-0.0105959;
Sintrodd[2][1]=-0.00158245;
Sintrodd[3][1]=-0.0219848;
Sintrodd[4][1]=-0.00871078;
 
Costrodd[0][2]=-0.0108744;
Costrodd[1][2]=-0.00119938;
Costrodd[2][2]=0.00526462;
Costrodd[3][2]=-0.00712447;
Costrodd[4][2]=-0.0108785;
 
Sintrodd[0][2]=0.0211698;
Sintrodd[1][2]=0.00270461;
Sintrodd[2][2]=0.0208355;
Sintrodd[3][2]=-0.00346678;
Sintrodd[4][2]=-0.000256186;
 
Costrodd[0][3]=0.00476002;
Costrodd[1][3]=-0.00622223;
Costrodd[2][3]=-0.0103691;
Costrodd[3][3]=-0.0164172;
Costrodd[4][3]=-0.0119551;
 
Sintrodd[0][3]=-0.00270691;
Sintrodd[1][3]=0.0184375;
Sintrodd[2][3]=-0.0103319;
Sintrodd[3][3]=-0.00564051;
Sintrodd[4][3]=0.00788142;
 
Costrodd[0][4]=0.00429291;
Costrodd[1][4]=0.00403973;
Costrodd[2][4]=1.2541e-05;
Costrodd[3][4]=0.00396777;
Costrodd[4][4]=0.00569913;
 
Sintrodd[0][4]=0.00786603;
Sintrodd[1][4]=-0.0130453;
Sintrodd[2][4]=-0.021016;
Sintrodd[3][4]=-0.00531332;
Sintrodd[4][4]=0.0118366;
 
Costrodd[0][5]=-0.00616425;
Costrodd[1][5]=-0.0157584;
Costrodd[2][5]=-0.0068161;
Costrodd[3][5]=0.00256372;
Costrodd[4][5]=0.00506841;
 
Sintrodd[0][5]=-0.0139837;
Sintrodd[1][5]=-0.00883702;
Sintrodd[2][5]=0.0170584;
Sintrodd[3][5]=0.00144832;
Sintrodd[4][5]=0.00675701;
 
Costrodd[0][6]=0.0124207;
Costrodd[1][6]=-0.00659086;
Costrodd[2][6]=-0.00221794;
Costrodd[3][6]=-0.0103583;
Costrodd[4][6]=0.0102838;
 
Sintrodd[0][6]=0.00949602;
Sintrodd[1][6]=0.00843508;
Sintrodd[2][6]=-0.000730771;
Sintrodd[3][6]=0.000561298;
Sintrodd[4][6]=-0.0123458;
 
Costrodd[0][7]=0.00525552;
Costrodd[1][7]=-0.00797434;
Costrodd[2][7]=0.00520636;
Costrodd[3][7]=-0.00235088;
Costrodd[4][7]=-0.000363875;
 
Sintrodd[0][7]=-0.00631479;
Sintrodd[1][7]=0.0149743;
Sintrodd[2][7]=0.00777551;
Sintrodd[3][7]=-0.0052385;
Sintrodd[4][7]=0.0143835;
 
Costrodd[0][8]=-0.006539;
Costrodd[1][8]=-0.00864267;
Costrodd[2][8]=0.00608514;
Costrodd[3][8]=-0.00816287;
Costrodd[4][8]=0.000589782;
 
Sintrodd[0][8]=0.000376789;
Sintrodd[1][8]=0.0034918;
Sintrodd[2][8]=0.00645175;
Sintrodd[3][8]=0.0117355;
Sintrodd[4][8]=0.00105284;
 
Costrodd[0][9]=0.0249422;
Costrodd[1][9]=0.00381391;
Costrodd[2][9]=0.0139341;
Costrodd[3][9]=0.00377248;
Costrodd[4][9]=-0.0200481;
 
Sintrodd[0][9]=0.0104847;
Sintrodd[1][9]=-0.00311527;
Sintrodd[2][9]=-0.000250258;
Sintrodd[3][9]=0.00160998;
Sintrodd[4][9]=-0.0164656;
 

}//End of Angular Corrections Function

+EOF
