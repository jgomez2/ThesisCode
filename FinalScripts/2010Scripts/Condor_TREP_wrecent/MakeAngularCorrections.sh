#!/bin/sh
 

b=$(sed -ne "${1}{p;q;}" files.txt)

cat > TRV1AngularCorrections_${1}.C << +EOF

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
void AngularCorrections();
////////////////////////////


//Files and chains
TChain* chain2;


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
TFile *myFile;// = new TFile("blah.root","RECREATE");


//Make Subdirectories for what will follow
TDirectory *myPlots;//the top level

//Angular Correction Folders
TDirectory *angularcorrectionplots;
//Psi1 Corrections
TDirectory *angcorr1odd;
TDirectory *wholeoddtrackercorrs;
TDirectory *posoddtrackercorrs;
TDirectory *negoddtrackercorrs;
TDirectory *midoddtrackercorrs;
//Psi1 Even Corrections
TDirectory *angcorr1even;
TDirectory *wholetrackercorrs;
TDirectory *postrackercorrs;
TDirectory *negtrackercorrs;
TDirectory *midtrackercorrs;


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

///Looping Variables
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



//////////////////////////////////////
// The following variables and plots
// are for the AngularCorrections
// function
///////////////////////////////////////


//These Will store the angular correction factors
//v1 even
//Whole Tracker
TProfile *Coswholetracker[nCent];
TProfile *Sinwholetracker[nCent];

//Pos Tracker
TProfile *Cospostracker[nCent];
TProfile *Sinpostracker[nCent];

//Neg Tracker
TProfile *Cosnegtracker[nCent];
TProfile *Sinnegtracker[nCent];

//Mid Tracker
TProfile *Cosmidtracker[nCent];
TProfile *Sinmidtracker[nCent];

//v1 odd
//Whole Tracker
TProfile *Coswholeoddtracker[nCent];
TProfile *Sinwholeoddtracker[nCent];

//Pos Tracker
TProfile *Cosposoddtracker[nCent];
TProfile *Sinposoddtracker[nCent];

//Neg Tracker
TProfile *Cosnegoddtracker[nCent];
TProfile *Sinnegoddtracker[nCent];

//Mid Tracker
TProfile *Cosmidoddtracker[nCent];
TProfile *Sinmidoddtracker[nCent];

/////////////////////////////////////////
/// Variables that are used in the //////
// Flow Analysis function////////////////
/////////////////////////////////////////

//RAW EP's
Float_t EPwholetracker=0.,EPpostracker=0.,EPnegtracker=0.,EPmidtracker=0.,
  EPwholeoddtracker=0.,EPposoddtracker=0.,EPnegoddtracker=0.,EPmidoddtracker=0.;



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
Int_t TRV1AngularCorrections_${1}(){//put functions in here
  Initialize();
  FillPTStats();
  FillFlowVectors();
  AngularCorrections();
  myFile->Write();
  return 0;
}

void Initialize(){

  float eta_bin_small[13]={-0.6,-0.5,-0.4,-0.3,-0.2,-0.1,0.0,0.1,0.2,0.3,0.4,0.5,0.6};

  double pt_bin[17]={0.4,0.6,0.8,1.0,1.2,1.4,1.6,1.8,2.0,2.4,2.8,3.2,3.6,4.5,6.5,9.5,12};

  chain2= new TChain("hiGoodTightMergedTracksTree");

  //Tracks Tree
  chain2->Add("/hadoop/store/user/jgomez2/ForwardTrees/2010/PanicTime/$b");
  //chain2->Add("/home/jgomez2/Desktop/Forward*");

  NumberOfEvents= chain2->GetEntries();
  //Create the output ROOT file
  myFile = new TFile("TREP_AngularCorrections_${1}.root","recreate");

  //Make Subdirectories for what will follow
  myPlots = myFile->mkdir("Plots");
  myPlots->cd();

  //Angular Correction Folders
  angularcorrectionplots = myPlots->mkdir("AngularCorrectionPlots");
  //Psi1 Corrections
  //Psi1 Even Corrections
  angcorr1even = angularcorrectionplots->mkdir("FirstOrderEPEvenCorrs");
  wholetrackercorrs = angcorr1even->mkdir("WholeTracker");
  postrackercorrs= angcorr1even->mkdir("PosTracker");
  negtrackercorrs= angcorr1even->mkdir("NegTracker");
  midtrackercorrs = angcorr1even->mkdir("MidTracker");

  //Psi1 Corrections
  angcorr1odd = angularcorrectionplots->mkdir("FirstOrderEPOddCorrs");
  wholeoddtrackercorrs = angcorr1odd->mkdir("WholeOddTracker");
  posoddtrackercorrs= angcorr1odd->mkdir("PosOddTracker");
  negoddtrackercorrs= angcorr1odd->mkdir("NegOddTracker");
  midoddtrackercorrs = angcorr1odd->mkdir("MidOddTracker");



  // <Cos> <Sin> plots

  //v1 even
  char coswholetrackername[128],coswholetrackertitle[128];
  char cospostrackername[128],cospostrackertitle[128];
  char cosnegtrackername[128],cosnegtrackertitle[128];
  char cosmidtrackername[128],cosmidtrackertitle[128];

  char sinwholetrackername[128],sinwholetrackertitle[128];
  char sinpostrackername[128],sinpostrackertitle[128];
  char sinnegtrackername[128],sinnegtrackertitle[128];
  char sinmidtrackername[128],sinmidtrackertitle[128];

  //v1 odd
  char coswholeoddtrackername[128],coswholeoddtrackertitle[128];
  char cosposoddtrackername[128],cosposoddtrackertitle[128];
  char cosnegoddtrackername[128],cosnegoddtrackertitle[128];
  char cosmidoddtrackername[128],cosmidoddtrackertitle[128];

  char sinwholeoddtrackername[128],sinwholeoddtrackertitle[128];
  char sinposoddtrackername[128],sinposoddtrackertitle[128];
  char sinnegoddtrackername[128],sinnegoddtrackertitle[128];
  char sinmidoddtrackername[128],sinmidoddtrackertitle[128];

  for (int i=0;i<nCent;i++)
    {


      ///////////////////////////////
      ////////<cos>,<sin> plots//////
      ///////////////////////////////

      //v1 even
      //Whole tracker
      wholetrackercorrs->cd();
      sprintf(coswholetrackername,"CosValues_WholeTracker_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(coswholetrackertitle,"CosValues_WholeTracker_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      Coswholetracker[i] = new TProfile(coswholetrackername,coswholetrackertitle,jMax,0,jMax);
      Coswholetracker[i]->GetYaxis()->SetTitle("<cos(Xbin*Psi)>");


      sprintf(sinwholetrackername,"SinValues_WholeTracker_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(sinwholetrackertitle,"SinValues_WholeTracker_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      Sinwholetracker[i] = new TProfile(sinwholetrackername,sinwholetrackertitle,jMax,0,jMax);
      Sinwholetracker[i]->GetYaxis()->SetTitle("<sin(Xbin*Psi)>");

      //Pos Tracker
      postrackercorrs->cd();
      sprintf(cospostrackername,"CosValues_PosTracker_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(cospostrackertitle,"CosValues_PosTracker_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      Cospostracker[i] = new TProfile(cospostrackername,cospostrackertitle,jMax,0,jMax);
      Cospostracker[i]->GetYaxis()->SetTitle("<cos(Xbin*Psi)>");


      sprintf(sinpostrackername,"SinValues_PosTracker_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(sinpostrackertitle,"SinValues_PosTracker_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      Sinpostracker[i] = new TProfile(sinpostrackername,sinpostrackertitle,jMax,0,jMax);
      Sinpostracker[i]->GetYaxis()->SetTitle("<sin(Xbin*Psi)>");

      //Neg Tracker
      negtrackercorrs->cd();
      sprintf(cosnegtrackername,"CosValues_NegTracker_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(cosnegtrackertitle,"CosValues_NegTracker_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      Cosnegtracker[i] = new TProfile(cosnegtrackername,cosnegtrackertitle,jMax,0,jMax);
      Cosnegtracker[i]->GetYaxis()->SetTitle("<cos(Xbin*Psi)>");


      sprintf(sinnegtrackername,"SinValues_NegTracker_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(sinnegtrackertitle,"SinValues_NegTracker_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      Sinnegtracker[i] = new TProfile(sinnegtrackername,sinnegtrackertitle,jMax,0,jMax);
      Sinnegtracker[i]->GetYaxis()->SetTitle("<sin(Xbin*Psi)>");

      //Mid Tracker
      midtrackercorrs->cd();
      sprintf(cosmidtrackername,"CosValues_MidTracker_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(cosmidtrackertitle,"CosValues_MidTracker_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      Cosmidtracker[i] = new TProfile(cosmidtrackername,cosmidtrackertitle,jMax,0,jMax);
      Cosmidtracker[i]->GetYaxis()->SetTitle("<cos(Xbin*Psi)>");


      sprintf(sinmidtrackername,"SinValues_MidTracker_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(sinmidtrackertitle,"SinValues_MidTracker_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      Sinmidtracker[i] = new TProfile(sinmidtrackername,sinmidtrackertitle,jMax,0,jMax);
      Sinmidtracker[i]->GetYaxis()->SetTitle("<sin(Xbin*Psi)>");


      //v1 odd
      //Whole tracker
      wholeoddtrackercorrs->cd();
      sprintf(coswholeoddtrackername,"CosValues_WholeOddTracker_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(coswholeoddtrackertitle,"CosValues_WholeOddTracker_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      Coswholeoddtracker[i] = new TProfile(coswholeoddtrackername,coswholeoddtrackertitle,jMax,0,jMax);
      Coswholeoddtracker[i]->GetYaxis()->SetTitle("<cos(Xbin*Psi)>");


      sprintf(sinwholeoddtrackername,"SinValues_WholeOddTracker_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(sinwholeoddtrackertitle,"SinValues_WholeOddTracker_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      Sinwholeoddtracker[i] = new TProfile(sinwholeoddtrackername,sinwholeoddtrackertitle,jMax,0,jMax);
      Sinwholeoddtracker[i]->GetYaxis()->SetTitle("<sin(Xbin*Psi)>");

      //Pos Tracker
      posoddtrackercorrs->cd();
      sprintf(cosposoddtrackername,"CosValues_PosOddTracker_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(cosposoddtrackertitle,"CosValues_PosOddTracker_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      Cosposoddtracker[i] = new TProfile(cosposoddtrackername,cosposoddtrackertitle,jMax,0,jMax);
      Cosposoddtracker[i]->GetYaxis()->SetTitle("<cos(Xbin*Psi)>");


      sprintf(sinposoddtrackername,"SinValues_PosOddTracker_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(sinposoddtrackertitle,"SinValues_PosOddTracker_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      Sinposoddtracker[i] = new TProfile(sinposoddtrackername,sinposoddtrackertitle,jMax,0,jMax);
      Sinposoddtracker[i]->GetYaxis()->SetTitle("<sin(Xbin*Psi)>");

      //Neg Tracker
      negoddtrackercorrs->cd();
      sprintf(cosnegoddtrackername,"CosValues_NegOddTracker_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(cosnegoddtrackertitle,"CosValues_NegOddTracker_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      Cosnegoddtracker[i] = new TProfile(cosnegoddtrackername,cosnegoddtrackertitle,jMax,0,jMax);
      Cosnegoddtracker[i]->GetYaxis()->SetTitle("<cos(Xbin*Psi)>");


      sprintf(sinnegoddtrackername,"SinValues_NegOddTracker_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(sinnegoddtrackertitle,"SinValues_NegOddTracker_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      Sinnegoddtracker[i] = new TProfile(sinnegoddtrackername,sinnegoddtrackertitle,jMax,0,jMax);
      Sinnegoddtracker[i]->GetYaxis()->SetTitle("<sin(Xbin*Psi)>");

      //Mid Tracker
      midoddtrackercorrs->cd();
      sprintf(cosmidoddtrackername,"CosValues_MidOddTracker_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(cosmidoddtrackertitle,"CosValues_MidOddTracker_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      Cosmidoddtracker[i] = new TProfile(cosmidoddtrackername,cosmidoddtrackertitle,jMax,0,jMax);
      Cosmidoddtracker[i]->GetYaxis()->SetTitle("<cos(Xbin*Psi)>");


      sprintf(sinmidoddtrackername,"SinValues_MidOddTracker_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(sinmidoddtrackertitle,"SinValues_MidOddTracker_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      Sinmidoddtracker[i] = new TProfile(sinmidoddtrackername,sinmidoddtrackertitle,jMax,0,jMax);
      Sinmidoddtracker[i]->GetYaxis()->SetTitle("<sin(Xbin*Psi)>");
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
 

 
 

}//end of ptstats function


void AngularCorrections(){

  for (Int_t i=0;i<NumberOfEvents;i++)
    {
      if ( !(i%10000) ) cout << " 2nd round, event # " << i << " / " << NumberOfEvents << endl;

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

      //Zero the Looping Variables
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

          //v1 Odd
          X_wholeoddtracker[q]=0.;
          Y_wholeoddtracker[q]=0.;
          X_posoddtracker[q]=0.;
          Y_posoddtracker[q]=0.;
          X_negoddtracker[q]=0.;
          Y_negoddtracker[q]=0.;
          X_midoddtracker[q]=0.;
          Y_midoddtracker[q]=0.;
        }


      //v1 even
      Xcorr_wholetracker=0.;Ycorr_wholetracker=0.;
      Xcorr_postracker=0.;Ycorr_postracker=0.;
      Xcorr_negtracker=0.;Ycorr_negtracker=0.;
      Xcorr_midtracker=0.;Ycorr_midtracker=0.;
      //v1 odd
      Xcorr_wholeoddtracker=0.;Ycorr_wholeoddtracker=0.;
      Xcorr_posoddtracker=0.;Ycorr_posoddtracker=0.;
      Xcorr_negoddtracker=0.;Ycorr_negoddtracker=0.;
      Xcorr_midoddtracker=0.;Ycorr_midoddtracker=0.;

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
                  //X_wholeoddtracker[c]+=cos(phi)*(pT);
                  Y_wholeoddtracker[c]+=sin(phi)*(pT-(pt2avwhole[c]/ptavwhole[c]));
                  //Y_wholeoddtracker[c]+=sin(phi)*(pT);
                  X_posoddtracker[c]+=cos(phi)*(pT-(pt2avpos[c]/ptavpos[c]));
                  //X_posoddtracker[c]+=cos(phi)*(pT);
                  Y_posoddtracker[c]+=sin(phi)*(pT-(pt2avpos[c]/ptavpos[c]));
                  //Y_posoddtracker[c]+=sin(phi)*(pT);
                }
              else if(eta<=-1.4)
                {
                  X_wholetracker[c]+=cos(phi)*(pT-(pt2avwhole[c]/ptavwhole[c]));
                  Y_wholetracker[c]+=sin(phi)*(pT-(pt2avwhole[c]/ptavwhole[c]));
                  X_negtracker[c]+=cos(phi)*(pT-(pt2avneg[c]/ptavneg[c]));
                  Y_negtracker[c]+=sin(phi)*(pT-(pt2avneg[c]/ptavneg[c]));
                  //v1 odd
                  X_wholeoddtracker[c]+=cos(phi)*(-1.0*(pT-(pt2avwhole[c]/ptavwhole[c])));
                  //X_wholeoddtracker[c]+=cos(phi)*(-1.0*pT);
                  Y_wholeoddtracker[c]+=sin(phi)*(-1.0*(pT-(pt2avwhole[c]/ptavwhole[c])));
                  //Y_wholeoddtracker[c]+=sin(phi)*(-1.0*pT);
                  X_negoddtracker[c]+=cos(phi)*(-1.0*(pT-(pt2avneg[c]/ptavneg[c])));
                  //X_negoddtracker[c]+=cos(phi)*(-1.0*pT);
                  Y_negoddtracker[c]+=sin(phi)*(-1.0*(pT-(pt2avneg[c]/ptavneg[c])));
                  //Y_negoddtracker[c]+=sin(phi)*(-1.0*pT);
                }
              else if(eta<=0.6 && eta>0)
                {
                  X_midtracker[c]+=cos(phi)*(pT-(pt2avmid[c]/ptavmid[c]));
                  Y_midtracker[c]+=sin(phi)*(pT-(pt2avmid[c]/ptavmid[c]));
                  //v1 odd
                  X_midoddtracker[c]+=cos(phi)*(pT-(pt2avmid[c]/ptavmid[c]));
                  //X_midoddtracker[c]+=cos(phi)*(pT);
                  Y_midoddtracker[c]+=sin(phi)*(pT-(pt2avmid[c]/ptavmid[c]));
                  //Y_midoddtracker[c]+=sin(phi)*(pT);
                }
              else if(eta>=-0.6 && eta<0)
                {
                  X_midtracker[c]+=cos(phi)*(pT-(pt2avmid[c]/ptavmid[c]));
                  Y_midtracker[c]+=sin(phi)*(pT-(pt2avmid[c]/ptavmid[c]));
                  //v1 odd
                  X_midoddtracker[c]+=cos(phi)*(-1.0*(pT-(pt2avmid[c]/ptavmid[c])));
                  //X_midoddtracker[c]+=cos(phi)*(-1.0*pT);
                  Y_midoddtracker[c]+=sin(phi)*(-1.0*(pT-(pt2avmid[c]/ptavmid[c])));
                  //Y_midoddtracker[c]+=sin(phi)*(-1.0*pT);
                }
            }//end of loop over centrality classes
        }//end of loop over tracks


      //Time to fill the appropriate histograms, this will be <cos> <sin>
      for (Int_t c=0;c<nCent;c++)
        {
          if ( (Centrality*2.5) > centhi[c] ) continue;
          if ( (Centrality*2.5) < centlo[c] ) continue;
          //V1 even
          //Whole Tracker
          Xcorr_wholetracker=(X_wholetracker[c]-Xav_wholetracker[c])/Xstdev_wholetracker[c];
          Ycorr_wholetracker=(Y_wholetracker[c]-Yav_wholetracker[c])/Ystdev_wholetracker[c];
          EPwholetracker=(1./1.)*atan2(Ycorr_wholetracker,Xcorr_wholetracker);
          if (EPwholetracker>(pi)) EPwholetracker=(EPwholetracker-(TMath::TwoPi()));
          if (EPwholetracker<(-1.0*(pi))) EPwholetracker=(EPwholetracker+(TMath::TwoPi()));

          //Pos Tracker
          Xcorr_postracker=(X_postracker[c]-Xav_postracker[c])/Xstdev_postracker[c];
          Ycorr_postracker=(Y_postracker[c]-Yav_postracker[c])/Ystdev_postracker[c];
          EPpostracker=(1./1.)*atan2(Ycorr_postracker,Xcorr_postracker);
          if (EPpostracker>(pi)) EPpostracker=(EPpostracker-(TMath::TwoPi()));
          if (EPpostracker<(-1.0*(pi))) EPpostracker=(EPpostracker+(TMath::TwoPi()));

          //neg Tracker
          Xcorr_negtracker=(X_negtracker[c]-Xav_negtracker[c])/Xstdev_negtracker[c];
          Ycorr_negtracker=(Y_negtracker[c]-Yav_negtracker[c])/Ystdev_negtracker[c];
          EPnegtracker=(1./1.)*atan2(Ycorr_negtracker,Xcorr_negtracker);
          // if (c==2) std::cout<<Xcorr_negtracker<<" "<<Ycorr_negtracker<<" "<<EPnegtracker<<std::endl;
          if (EPnegtracker>(pi)) EPnegtracker=(EPnegtracker-(TMath::TwoPi()));
          if (EPnegtracker<(-1.0*(pi))) EPnegtracker=(EPnegtracker+(TMath::TwoPi()));

          //mid Tracker
          Xcorr_midtracker=(X_midtracker[c]-Xav_midtracker[c])/Xstdev_midtracker[c];
          Ycorr_midtracker=(Y_midtracker[c]-Yav_midtracker[c])/Ystdev_midtracker[c];
          EPmidtracker=(1./1.)*atan2(Ycorr_midtracker,Xcorr_midtracker);
          if (EPmidtracker>(pi)) EPmidtracker=(EPmidtracker-(TMath::TwoPi()));
          if (EPmidtracker<(-1.0*(pi))) EPmidtracker=(EPmidtracker+(TMath::TwoPi()));

          //V1 Odd
          //Whole Tracker
          Xcorr_wholeoddtracker=(X_wholeoddtracker[c]-Xav_wholeoddtracker[c])/Xstdev_wholeoddtracker[c];
          Ycorr_wholeoddtracker=(Y_wholeoddtracker[c]-Yav_wholeoddtracker[c])/Ystdev_wholeoddtracker[c];
          EPwholeoddtracker=(1./1.)*atan2(Ycorr_wholeoddtracker,Xcorr_wholeoddtracker);
          if (EPwholeoddtracker>(pi)) EPwholeoddtracker=(EPwholeoddtracker-(TMath::TwoPi()));
          if (EPwholeoddtracker<(-1.0*(pi))) EPwholeoddtracker=(EPwholeoddtracker+(TMath::TwoPi()));

          //Pos Tracker
          Xcorr_posoddtracker=(X_posoddtracker[c]-Xav_posoddtracker[c])/Xstdev_posoddtracker[c];
          Ycorr_posoddtracker=(Y_posoddtracker[c]-Yav_posoddtracker[c])/Ystdev_posoddtracker[c];
          EPposoddtracker=(1./1.)*atan2(Ycorr_posoddtracker,Xcorr_posoddtracker);
          if (EPposoddtracker>(pi)) EPposoddtracker=(EPposoddtracker-(TMath::TwoPi()));
          if (EPposoddtracker<(-1.0*(pi))) EPposoddtracker=(EPposoddtracker+(TMath::TwoPi()));

          //neg Tracker
          Xcorr_negoddtracker=(X_negoddtracker[c]-Xav_negoddtracker[c])/Xstdev_negoddtracker[c];
          Ycorr_negoddtracker=(Y_negoddtracker[c]-Yav_negoddtracker[c])/Ystdev_negoddtracker[c];
          EPnegoddtracker=(1./1.)*atan2(Ycorr_negoddtracker,Xcorr_negoddtracker);
          // if (c==2) std::cout<<Xcorr_negtracker<<" "<<Ycorr_negtracker<<" "<<EPnegtracker<<std::endl;
          if (EPnegoddtracker>(pi)) EPnegoddtracker=(EPnegoddtracker-(TMath::TwoPi()));
          if (EPnegoddtracker<(-1.0*(pi))) EPnegoddtracker=(EPnegoddtracker+(TMath::TwoPi()));

          //mid Tracker
          Xcorr_midoddtracker=(X_midoddtracker[c]-Xav_midoddtracker[c])/Xstdev_midoddtracker[c];
          Ycorr_midoddtracker=(Y_midoddtracker[c]-Yav_midoddtracker[c])/Ystdev_midoddtracker[c];
          EPmidoddtracker=(1./1.)*atan2(Ycorr_midoddtracker,Xcorr_midoddtracker);
          if (EPmidoddtracker>(pi)) EPmidoddtracker=(EPmidoddtracker-(TMath::TwoPi()));
          if (EPmidoddtracker<(-1.0*(pi))) EPmidoddtracker=(EPmidoddtracker+(TMath::TwoPi()));



          for (int k=1;k<(jMax+1);k++)
            {
              //v1 odd
              //Whole Tracker
              Coswholeoddtracker[c]->Fill(k-1,cos(k*EPwholeoddtracker));
              Sinwholeoddtracker[c]->Fill(k-1,sin(k*EPwholeoddtracker));

              //Pos Tracker
              Cosposoddtracker[c]->Fill(k-1,cos(k*EPposoddtracker));
              Sinposoddtracker[c]->Fill(k-1,sin(k*EPposoddtracker));

              //Neg Tracker
              Cosnegoddtracker[c]->Fill(k-1,cos(k*EPnegoddtracker));
              Sinnegoddtracker[c]->Fill(k-1,sin(k*EPnegoddtracker));

              //Mid Tracker
              Cosmidoddtracker[c]->Fill(k-1,cos(k*EPmidoddtracker));
              Sinmidoddtracker[c]->Fill(k-1,sin(k*EPmidoddtracker));

              //v1 even
              //Whole Tracker
              Coswholetracker[c]->Fill(k-1,cos(k*EPwholetracker));
              Sinwholetracker[c]->Fill(k-1,sin(k*EPwholetracker));

              //Pos Tracker
              Cospostracker[c]->Fill(k-1,cos(k*EPpostracker));
              Sinpostracker[c]->Fill(k-1,sin(k*EPpostracker));

              //Neg Tracker
              Cosnegtracker[c]->Fill(k-1,cos(k*EPnegtracker));
              Sinnegtracker[c]->Fill(k-1,sin(k*EPnegtracker));

              //Mid Tracker
              Cosmidtracker[c]->Fill(k-1,cos(k*EPmidtracker));
              Sinmidtracker[c]->Fill(k-1,sin(k*EPmidtracker));
            }//end of loop over K
        }//end of loop over centrality clases
    }//end of loop over events
}//End of Angular Corrections Function

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
 

}//End of fillflowvectors function
+EOF
