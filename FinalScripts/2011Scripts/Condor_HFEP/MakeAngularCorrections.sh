#!/bin/sh
 

b=$(sed -ne "${1}{p;q;}" files.txt)

cat > HFV1AngularCorrections_${1}.C << +EOF

#include<TH1F>
#include<TProfile>
#include<iostream>
#include<iomanip>
#include"TFile.h"
#include"TTree.h"
#include"TLeaf.h"
#include"TChain.h"
#include "TComplex.h"

void Initialize();
void FillPTStats();
void AngularCorrections();


//Files and chains
TChain* chain;//= new TChain("CaloTowerTree");
TChain* chain2;//= new TChain("hiGoodTightMergedTracksTree");
TChain* chain3;
TChain* chain4;


//When I parrallelize this, I need to make sure that I do not fill <pT> and <pT*pT>
//Also, this only works because I do not need have any overlapping centrality classes. When I calculate_trodd+=cos(phi)*(pT-(pt2avmid[c]/ptavmid[c])) this would be a problem if i had overlapping classes

/////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////
////////////           GLOBAL VARIABLES            //////////////////
/////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////
Float_t pi=TMath::Pi();
Int_t vterm=1;//Set which order harmonic that this code is meant to measure
Int_t jMax=10;////Set out to which order correction we would like to apply
Int_t NumberOfEvents=0;
//NumberOfEvents=1;
//NumberOfEvents=2;
//NumberOfEvents=10;
//NumberOfEvents=10000;
Int_t Centrality=0;
Float_t Zposition=0.;
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

////////////////////////////////////////////////
//Angular Correction Folders
TDirectory *angularcorrectionplots;
//Psi1 Odd Corrections
TDirectory *angcorr1odd;
TDirectory *hfoddcorrs;
TDirectory *hfpoddcorrs;
TDirectory *hfnoddcorrs;
TDirectory *midtrackeroddcorrs;
/////////////////////////////////
//Psi1 Even Corrections
TDirectory *angcorr1even;
TDirectory *hfevencorrs;
TDirectory *hfpevencorrs;
TDirectory *hfnevencorrs;
TDirectory *midtrackerevencorrs;
/////////////////////////////////

//Looping Variables
//v1 even
Float_t X_hfeven=0.,Y_hfeven=0.;
TComplex Q_HFEven;

//v1 odd
Float_t X_hfodd=0.,Y_hfodd=0.;
TComplex Q_HFOdd;

///Looping Variables
//v1 even
Float_t EPhfeven=0.;
Float_t AngularCorrectionHFEven=0.,EPfinalhfeven=0.;

//v1 odd
Float_t EPhfodd=0.;
Float_t AngularCorrectionHFOdd=0.,EPfinalhfodd=0.;

//PosHFEven
Float_t X_poseven=0.,Y_poseven=0.;
TComplex Q_PosHFEven;
Float_t EP_poseven=0.,EP_finalposeven=0.;
Float_t AngularCorrectionHFPEven=0.;
//PosHFOdd
Float_t X_posodd=0.,Y_posodd=0.;
TComplex Q_PosHFOdd;
Float_t EP_posodd=0.,EP_finalposodd=0.;
Float_t AngularCorrectionHFPOdd=0.;
//NegHFEven
Float_t X_negeven=0.,Y_negeven=0.;
TComplex Q_NegHFEven;
Float_t EP_negeven=0.,EP_finalnegeven=0.;
Float_t AngularCorrectionHFNEven=0.;
//NegHFOdd
Float_t X_negodd=0.,Y_negodd=0.;
TComplex Q_NegHFOdd;
Float_t EP_negodd=0.,EP_finalnegodd=0.;
Float_t AngularCorrectionHFNOdd=0.;

//MidTrackerOdd
Float_t X_trodd=0.,Y_trodd=0.;
TComplex Q_TROdd;
Float_t EP_trodd=0.,EP_finaltrodd=0.;
Float_t AngularCorrectionTROdd=0.;
//MidTrackerEven                                                                                  
Float_t X_treven=0.,Y_treven=0.;
TComplex Q_TREven;
Float_t EP_treven=0.,EP_finaltreven=0.;
Float_t AngularCorrectionTREven=0.;



//<pT> and <pT^2> 
Float_t ptavmid[nCent],pt2avmid[nCent];
////////////////////////////////////////////////////
//These Will store the angular correction factors
//v1 even
TProfile *Coshfeven[nCent];
TProfile *Sinhfeven[nCent];
//PosHF
TProfile *Coshfpeven[nCent];
TProfile *Sinhfpeven[nCent];
//NegHF
TProfile *Coshfneven[nCent];
TProfile *Sinhfneven[nCent];
//Mid Tracker
TProfile *Costreven[nCent];
TProfile *Sintreven[nCent];

//v1 odd
TProfile *Coshfodd[nCent];
TProfile *Sinhfodd[nCent];
//PosHF
TProfile *Coshfpodd[nCent];
TProfile *Sinhfpodd[nCent];
//NegHF
TProfile *Coshfnodd[nCent];
TProfile *Sinhfnodd[nCent];
//Mid Tracker
TProfile *Costrodd[nCent];
TProfile *Sintrodd[nCent];



//////////////////////////////////////////////////////

Int_t HFV1AngularCorrections_${1}(){
  Initialize();
  FillPTStats();
  AngularCorrections();
  return 0;
}


void Initialize(){

  //  std::cout<<"Made it into initialize"<<std::endl;
  Float_t eta_bin_small[13]={-0.6,-0.5,-0.4,-0.3,-0.2,-0.1,0.0,0.1,0.2,0.3,0.4,0.5,0.6};

  Double_t pt_bin[17]={0.4,0.6,0.8,1.0,1.2,1.4,1.6,1.8,2.0,2.4,2.8,3.2,3.6,4.5,6.5,9.5,12};

/Zero the complex numbers

Q_HFOdd=TComplex(0.);
Q_HFEven=TComplex(0.);
Q_PosHFEven=TComplex(0.);
Q_PosHFOdd=TComplex(0.);
Q_NegHFOdd=TComplex(0.);
Q_NegHFEven=TComplex(0.);
Q_TROdd=TComplex(0.);
Q_TREven=TComplex(0.);


 chain= new TChain("hiGeneralAndPixelTracksTree");
  chain2=new TChain("CaloTowerTree");
  chain3=new TChain("hiSelectedVertexTree");
  chain4=new TChain("HFtowersCentralityTree");
  
  //Tracks Tree
  chain->Add("/hadoop/store/user/jgomez2/DataSkims/2011/2011MinBiasReReco/FinalTrees/$b");
  //Calo Tree
  chain2->Add("/hadoop/store/user/jgomez2/DataSkims/2011/2011MinBiasReReco/FinalTrees/$b");
   //Vertex Tree
  chain3->Add("/hadoop/store/user/jgomez2/DataSkims/2011/2011MinBiasReReco/FinalTrees/$b");
  //Centrality Tree
  chain4->Add("/hadoop/store/user/jgomez2/DataSkims/2011/2011MinBiasReReco/FinalTrees/$b");


  NumberOfEvents = chain2->GetEntries();
  //Create the output ROOT file
  myFile = new TFile("HFEP_AngularCorrections_${1}.root","recreate");

  //Make Subdirectories for what will follow
  myPlots = myFile->mkdir("Plots");
  myPlots->cd();
  //////////////////////////////////////////////////////////////////////
  //////////////////////////////////////////
  ///////////////////////////////////////////////////////////////////
  //Angular Correction Folders
  angularcorrectionplots = myPlots->mkdir("AngularCorrectionPlots");
  //Psi1 Corrections
  //Psi1 Even Corrections
  angcorr1even = angularcorrectionplots->mkdir("FirstOrderEPEvenCorrs");
  hfevencorrs = angcorr1even->mkdir("WholeHF");
  hfpevencorrs = angcorr1even->mkdir("PositiveHF");
  hfnevencorrs = angcorr1even->mkdir("NegativeHF");
  midtrackerevencorrs = angcorr1even->mkdir("Tracker");
  ///////////////////////////////////////////////////////////////////////////
  //Psi1 Corrections
  angcorr1odd = angularcorrectionplots->mkdir("FirstOrderEPOddCorrs");
  hfoddcorrs = angcorr1odd->mkdir("WholeHF");
  hfpoddcorrs = angcorr1odd->mkdir("PositiveHF");
  hfnoddcorrs = angcorr1odd->mkdir("NegativeHF");
  midtrackeroddcorrs = angcorr1odd->mkdir("Tracker");


  //<Cos>,<Sin> Psi1(even)
  //Whole HF
  char coshfevenname[128],coshfeventitle[128];
  char sinhfevenname[128],sinhfeventitle[128];
  //Pos HF
  char coshfpevenname[128],coshfpeventitle[128];
  char sinhfpevenname[128],sinhfpeventitle[128];
  //Neg HF
  char coshfnevenname[128],coshfneventitle[128];
  char sinhfnevenname[128],sinhfneventitle[128];
  //Tracker
  char costrevenname[128],costreventitle[128];
  char sintrevenname[128],sintreventitle[128];
  /////////////////////////////////////////////////
  //<Cos>,<Sin> Psi1(odd)
  char coshfoddname[128],coshfoddtitle[128];
  char sinhfoddname[128],sinhfoddtitle[128];
  //Pos HF
  char coshfpoddname[128],coshfpoddtitle[128];
  char sinhfpoddname[128],sinhfpoddtitle[128];
  //Neg HF
  char coshfnoddname[128],coshfnoddtitle[128];
  char sinhfnoddname[128],sinhfnoddtitle[128];
  //Tracker
  char costroddname[128],costroddtitle[128];
  char sintroddname[128],sintroddtitle[128];
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
      ///////////////////////////////
      ////////<cos>,<sin> plots//////
      ///////////////////////////////

      //v1 even
      //Whole HF
      hfevencorrs->cd();
      sprintf(coshfevenname,"CosValues_HFEven_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(coshfeventitle,"CosValues_HFEven_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      Coshfeven[i]= new TProfile(coshfevenname,coshfeventitle,jMax,0,jMax);
      Coshfeven[i]->GetYaxis()->SetTitle("<cos(Xbin*#Psi)>");

      sprintf(sinhfevenname,"SinValues_HFEven_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(sinhfeventitle,"SinValues_HFEven_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      Sinhfeven[i]= new TProfile(sinhfevenname,sinhfeventitle,jMax,0,jMax);
      Sinhfeven[i]->GetYaxis()->SetTitle("<sin(Xbin*#Psi)>");

      //Pos HF
      hfpevencorrs->cd();
      sprintf(coshfpevenname,"CosValues_HFPEven_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(coshfpeventitle,"CosValues_HFPEven_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      Coshfpeven[i]= new TProfile(coshfpevenname,coshfpeventitle,jMax,0,jMax);
      Coshfpeven[i]->GetYaxis()->SetTitle("<cos(Xbin*#Psi)>");

      sprintf(sinhfpevenname,"SinValues_HFPEven_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(sinhfpeventitle,"SinValues_HFPEven_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      Sinhfpeven[i]= new TProfile(sinhfpevenname,sinhfpeventitle,jMax,0,jMax);
      Sinhfpeven[i]->GetYaxis()->SetTitle("<sin(Xbin*#Psi)>");

      //Neg HF
      hfnevencorrs->cd();
      sprintf(coshfnevenname,"CosValues_HFNEven_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(coshfneventitle,"CosValues_HFNEven_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      Coshfneven[i]= new TProfile(coshfnevenname,coshfneventitle,jMax,0,jMax);
      Coshfneven[i]->GetYaxis()->SetTitle("<cos(Xbin*#Psi)>");

      sprintf(sinhfnevenname,"SinValues_HFNEven_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(sinhfneventitle,"SinValues_HFNEven_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      Sinhfneven[i]= new TProfile(sinhfnevenname,sinhfneventitle,jMax,0,jMax);
      Sinhfneven[i]->GetYaxis()->SetTitle("<sin(Xbin*#Psi)>");

      //Tracker                                                
      midtrackerevencorrs->cd();
      sprintf(costrevenname,"CosValues_TREven_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(costreventitle,"CosValues_TREven_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      Costreven[i]= new TProfile(costrevenname,costreventitle,jMax,0,jMax);
      Costreven[i]->GetYaxis()->SetTitle("<cos(Xbin*#Psi)>");

      sprintf(sintrevenname,"SinValues_TREven_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(sintreventitle,"SinValues_TREven_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      Sintreven[i]= new TProfile(sintrevenname,sintreventitle,jMax,0,jMax);
      Sintreven[i]->GetYaxis()->SetTitle("<sin(Xbin*#Psi)>");

      ////////////////////////////////////////////////////////////////////////////////////////////////
      //Psi1 Odd
      hfoddcorrs->cd();
      sprintf(coshfoddname,"CosValues_HFOdd_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(coshfoddtitle,"CosValues_HFOdd_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      Coshfodd[i]= new TProfile(coshfoddname,coshfoddtitle,jMax,0,jMax);
      Coshfodd[i]->GetYaxis()->SetTitle("<cos(Xbin*#Psi)>");

      sprintf(sinhfoddname,"SinValues_HFOdd_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(sinhfoddtitle,"SinValues_HFOdd_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      Sinhfodd[i]= new TProfile(sinhfoddname,sinhfoddtitle,jMax,0,jMax);
      Sinhfodd[i]->GetYaxis()->SetTitle("<sin(Xbin*#Psi)>");

      //Pos HF
      hfpoddcorrs->cd();
      sprintf(coshfpoddname,"CosValues_HFPOdd_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(coshfpoddtitle,"CosValues_HFPOdd_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      Coshfpodd[i]= new TProfile(coshfpoddname,coshfpoddtitle,jMax,0,jMax);
      Coshfpodd[i]->GetYaxis()->SetTitle("<cos(Xbin*#Psi)>");

      sprintf(sinhfpoddname,"SinValues_HFPOdd_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(sinhfpoddtitle,"SinValues_HFPOdd_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      Sinhfpodd[i]= new TProfile(sinhfpoddname,sinhfpoddtitle,jMax,0,jMax);
      Sinhfpodd[i]->GetYaxis()->SetTitle("<sin(Xbin*#Psi)>");

      //Neg HF
      hfnoddcorrs->cd();
      sprintf(coshfnoddname,"CosValues_HFNOdd_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(coshfnoddtitle,"CosValues_HFNOdd_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      Coshfnodd[i]= new TProfile(coshfnoddname,coshfnoddtitle,jMax,0,jMax);
      Coshfnodd[i]->GetYaxis()->SetTitle("<cos(Xbin*#Psi)>");

      sprintf(sinhfnoddname,"SinValues_HFNOdd_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(sinhfnoddtitle,"SinValues_HFNOdd_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      Sinhfnodd[i]= new TProfile(sinhfnoddname,sinhfnoddtitle,jMax,0,jMax);
      Sinhfnodd[i]->GetYaxis()->SetTitle("<sin(Xbin*#Psi)>");

      //Tracker
      midtrackeroddcorrs->cd();
      sprintf(costroddname,"CosValues_TROdd_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(costroddtitle,"CosValues_TROdd_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      Costrodd[i]= new TProfile(costroddname,costroddtitle,jMax,0,jMax);
      Costrodd[i]->GetYaxis()->SetTitle("<cos(Xbin*#Psi)>");

      sprintf(sintroddname,"SinValues_TROdd_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(sintroddtitle,"SinValues_TROdd_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      Sintrodd[i]= new TProfile(sintroddname,sintroddtitle,jMax,0,jMax);
      Sintrodd[i]->GetYaxis()->SetTitle("<sin(Xbin*#Psi)>");
     
    }//end of loop over centralities

}//end of initialize function


void FillPTStats(){
//Mid Tracker
ptavmid[0]=0.830949;
ptavmid[1]=0.836451;
ptavmid[2]=0.835466;
ptavmid[3]=0.828784;
ptavmid[4]=0.818137;
 
pt2avmid[0]=0.965405;
pt2avmid[1]=0.983187;
pt2avmid[2]=0.986779;
pt2avmid[3]=0.978199;
pt2avmid[4]=0.960408;
 

    }//end of ptstats function


void AngularCorrections(){

  for (Int_t i=0;i<NumberOfEvents;i++)
    {
      if ( !(i%10000) ) cout << " 2nd round, event # " << i << " / " << NumberOfEvents << endl;

      chain2->GetEntry(i);//grab the ith event
      chain->GetEntry(i);
      chain3->GetEntry(i);
      chain4->GetEntry(i);
 
      //Filter On Centrality
      CENTRAL= (TLeaf*) chain4->GetLeaf("Bin");
      Centrality= CENTRAL->GetValue();
      if (Centrality>19) continue;

      //Make Vertex Cuts if Necessary
      Vertex=(TLeaf*) chain3->GetLeaf("z");
      Zposition=Vertex->GetValue();
      //if(Zposition<=5) continue;

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
      
      Q_HFOdd=TComplex(0.);
Q_HFEven=TComplex(0.);
Q_PosHFEven=TComplex(0.);
Q_PosHFOdd=TComplex(0.);
Q_NegHFOdd=TComplex(0.);
Q_NegHFEven=TComplex(0.);
Q_TROdd=TComplex(0.);
Q_TREven=TComplex(0.);

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
		  Q_TROdd+=(pT-(pt2avmid[c]/ptavmid[c]))*TComplex::Exp(TComplex::I()*phi);
		  //Even
		  Q_TREven+=TComplex::Exp(TComplex::I()*phi)*(pT-(pt2avmid[c]/ptavmid[c]));
		  X_treven+=TMath::Cos(phi)*(pT-(pt2avmid[c]/ptavmid[c]));
                  Y_treven+=TMath::Sin(phi)*(pT-(pt2avmid[c]/ptavmid[c]));
		}//positive eta tracks
	      else
		{
		  //Odd   
		  Q_TROdd+=(-1.0(pT-(pt2avmid[c]/ptavmid[c])))*TComplex::Exp(TComplex::I()*phi);
                  X_trodd+=TMath::Cos(phi)*(-1.0*(pT-(pt2avmid[c]/ptavmid[c])));
                  Y_trodd+=TMath::Sin(phi)*(-1.0*(pT-(pt2avmid[c]/ptavmid[c])));
                  //Even
                  X_treven+=TMath::Cos(phi)*(pT-(pt2avmid[c]/ptavmid[c]));
                  Y_treven+=TMath::Sin(phi)*(pT-(pt2avmid[c]/ptavmid[c]));
                  Q_TREven+=TComplex::Exp(TComplex::I()*phi)*(pT-(pt2avmid[c]/ptavmid[c]));
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
              Q_HFOdd+=TComplex::Exp(TComplex::I()*phi)*(Energy);
              //Pos HF Odd
              X_posodd+=cos(phi)*(Energy);
              Y_posodd+=sin(phi)*(Energy);
              Q_PosHFOdd+=TComplex::Exp(TComplex::I()*phi)*(Energy);
              //Whole HF Even
              X_hfeven+=cos(phi)*(Energy);
              Y_hfeven+=sin(phi)*(Energy);
              Q_HFEven+=TComplex::Exp(TComplex::I()*phi)*(Energy);
              //Pos HF Even
              X_poseven+=cos(phi)*(Energy);
              Y_poseven+=sin(phi)*(Energy);
              Q_PosHFEven+=TComplex::Exp(TComplex::I()*phi)*(Energy);
            }
          else if (eta<0.0)
            {
              //Whole HF Odd
              X_hfodd+=cos(phi)*(-1.0*Energy);
              Y_hfodd+=sin(phi)*(-1.0*Energy);
              Q_HFOdd+=TComplex::Exp(TComplex::I()*phi)*(-1.0*Energy);
              //Neg HF Odd
              X_negodd+=cos(phi)*(-1.0*Energy);
              Y_negodd+=sin(phi)*(-1.0*Energy);
              Q_NegHFOdd+=TComplex::Exp(TComplex::I()*phi)*(-1.0*Energy);
              //Whole HF   Even
              X_hfeven+=cos(phi)*(Energy);
              Y_hfeven+=sin(phi)*(Energy);
              Q_HFEven+=TComplex::Exp(TComplex::I()*phi)*(Energy);
              // Neg HF Even
              X_negeven+=cos(phi)*(Energy);
              Y_negeven+=sin(phi)*(Energy);
              Q_NegHFEven+=TComplex::Exp(TComplex::I()*phi)*(Energy);
            }
        }//end of loop over Calo Hits

      for (Int_t c=0;c<nCent;c++)
        {
          if ( (Centrality*2.5) > centhi[c] ) continue;
          if ( (Centrality*2.5) < centlo[c] ) continue;
          //Time to fill the appropriate histograms, this will be <cos> <sin>

          //V1 Even
          //Whole HF
          EPhfeven=-999;
          EPhfeven=(1./1.)*atan2(Y_hfeven,X_hfeven);
          //EPhfeven=(1./1.)*atan2(Q_HFEven.Im(),Q_HFEven.Re());
          if (EPhfeven>(pi)) EPhfeven=(EPhfeven-(TMath::TwoPi()));
          if (EPhfeven<(-1.0*(pi))) EPhfeven=(EPhfeven+(TMath::TwoPi()));

          //Pos HF
          EP_poseven=-999;
          EP_poseven=(1./1.)*atan2(Y_poseven,X_poseven);
          //EP_poseven=(1./1.)*atan2(Q_PosHFEven.Im(),Q_PosHFEven.Re());
          if (EP_poseven>(pi)) EP_poseven=(EP_poseven-(TMath::TwoPi()));
          if (EP_poseven<(-1.0*(pi))) EP_poseven=(EP_poseven+(TMath::TwoPi()));

          //Neg HF
          EP_negeven=-999;
          EP_negeven=(1./1.)*atan2(Y_negeven,X_negeven);
          //EP_negeven=(1./1.)*atan2(Q_NegHFEven.Im(),Q_NegHFEven.Re());
          if (EP_negeven>(pi)) EP_negeven=(EP_negeven-(TMath::TwoPi()));
          if (EP_negeven<(-1.0*(pi))) EP_negeven=(EP_negeven+(TMath::TwoPi()));

	  //Tracker
	  EP_treven=-999;
          EP_treven=(1./1.)*atan2(Y_treven,X_treven);
          //EP_treven=(1./1.)*atan2(Q_TREven.Im(),Q_TREven.Re());
          if (EP_treven>(pi)) EP_treven=(EP_treven-(TMath::TwoPi()));
          if (EP_treven<(-1.0*(pi))) EP_treven=(EP_treven+(TMath::TwoPi()));



          //V1 odd
          //Whole HF
          EPhfodd=-999;
          EPhfodd=(1./1.)*atan2(Y_hfodd,X_hfodd);
          //EPhfodd=(1./1.)*atan2(Q_HFOdd.Im(),Q_HFOdd.Re());
          if (EPhfodd>(pi)) EPhfodd=(EPhfodd-(TMath::TwoPi()));
          if (EPhfodd<(-1.0*(pi))) EPhfodd=(EPhfodd+(TMath::TwoPi()));

          //Pos HF
          EP_posodd=-999;
          EP_posodd=(1./1.)*atan2(Y_posodd,X_posodd);
          //EP_posodd=(1./1.)*atan2(Q_PosHFOdd.Im(),Q_PosHFOdd.Re());
          if (EP_posodd>(pi)) EP_posodd=(EP_posodd-(TMath::TwoPi()));
          if (EP_posodd<(-1.0*(pi))) EP_posodd=(EP_posodd+(TMath::TwoPi()));

          //Neg HF
          EP_negodd=-999;
          EP_negodd=(1./1.)*atan2(Y_negodd,X_negodd);
          //EP_negodd=(1./1.)*atan2(Q_NegHFOdd.Im(),Q_NegHFOdd.Re());
          if (EP_negodd>(pi)) EP_negodd=(EP_negodd-(TMath::TwoPi()));
          if (EP_negodd<(-1.0*(pi))) EP_negodd=(EP_negodd+(TMath::TwoPi()));

	  //Tracker
	  EP_trodd=-999;
          EP_trodd=(1./1.)*atan2(Y_trodd,X_trodd);
          //EP_trodd=(1./1.)*atan2(Q_TROdd.Im(),Q_TROdd.Re());
          if (EP_trodd>(pi)) EP_trodd=(EP_trodd-(TMath::TwoPi()));
          if (EP_trodd<(-1.0*(pi))) EP_trodd=(EP_trodd+(TMath::TwoPi()));


          //std::cout<<EPhfodd<<std::endl;
          if((EPhfeven>-500) && (EPhfodd>-500))
            {
              for (int k=1;k<(jMax+1);k++)
                {
                  //v1 odd
                  //Whole HF
                  Coshfodd[c]->Fill(k-1,cos(k*EPhfodd));
                  // std::cout<<" K equals"<<" "<<k<<" and the value is "<<cos(k*EPhfodd)<<std::endl;
                  Sinhfodd[c]->Fill(k-1,sin(k*EPhfodd));

                  //Pos HF
                  Coshfpodd[c]->Fill(k-1,cos(k*EP_posodd));
                  Sinhfpodd[c]->Fill(k-1,sin(k*EP_posodd));

                  //Neg HF
                  Coshfnodd[c]->Fill(k-1,cos(k*EP_negodd));
                  Sinhfnodd[c]->Fill(k-1,sin(k*EP_negodd));

		  //Tracker
		  Costrodd[c]->Fill(k-1,cos(k*EP_trodd));
                  Sintrodd[c]->Fill(k-1,sin(k*EP_trodd));
                  /////////////////////////////////////////////////////////
                  //v1 even
                  //Whole HF
                  Coshfeven[c]->Fill(k-1,cos(k*EPhfeven));
                  Sinhfeven[c]->Fill(k-1,sin(k*EPhfeven));

                  //Pos HF
                  Coshfpeven[c]->Fill(k-1,cos(k*EP_poseven));
                  Sinhfpeven[c]->Fill(k-1,sin(k*EP_poseven));

                  //Neg HF
                  Coshfneven[c]->Fill(k-1,cos(k*EP_negeven));
                  Sinhfneven[c]->Fill(k-1,sin(k*EP_negeven));

		  //Tracker
		  Costreven[c]->Fill(k-1,cos(k*EP_treven));
                  Sintreven[c]->Fill(k-1,sin(k*EP_treven));
                }//end of loop over K
            }//preventing empty EP
        }//End of loop over centralities
    }//end of loop over events
  myFile->Write();
}//End of Angular Corrections Function
+EOF
