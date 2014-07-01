#!/bin/sh
 

b=$(sed -ne "${1}{p;q;}" files.txt)

cat > TwoParticleCorrelation_${1}.C << +EOF

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
void CorrelationAnalysis();
void PlotFitting();
////////////////////////////


//****************************************************//
//***************************************************//
// This macro will have to be updated after I speak //
// with Ollitrault. Plot fitting is a function meant//
// to fit the conservation of momentum term and also//
// create the final plots. I will try now to foresee//
// what possible declarations I will need later.//
// These include: TProfiles (for eta dist), TH1Fs//
// for final v1, chars and other things to make the plots//
// I will refrain from declaring them now though//
// Also figure out how to find the center of the pT bins//
// When I finalize my centrality bins, make sure to //
// add a big filter right after the event loop starts//
// because dont want to loop over tracks if we dont //
//have to                                           //
////////////////////////////////////////////////////////
//**************************************************//





//Files and chains
TChain* chain;
TChain* chain3;
TChain* chain4;

/////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////
////////////           GLOBAL VARIABLES            //////////////////
/////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////
Float_t pi=TMath::Pi();
Int_t NumberOfEvents=0;
//NumberOfEvents=1;
//NumberOfEvents=2;
//NumberOfEvents=10;
//NumberOfEvents=100;
//  NumberOfEvents=50000;
//NumberOfEvents=300000;
//NumberOfEvents=5000000;
//  NumberOfEvents = chain->GetEntries();

const Int_t nCent=5;//Number of Centrality classes

///Looping Variables
Int_t Centrality=0; //This will be the centrality variable later
Int_t NumberOfHits=0;//This will be for both tracks and Hits
Float_t pT=0.;
Float_t phi=0.;
Float_t eta=0.;
Float_t pTb=0.;
Float_t phib=0.;
Float_t etab=0.;
Float_t Zposition=0.;


Float_t centlo[nCent];
Float_t centhi[nCent];
centlo[0]=0;  centhi[0]=10;
centlo[1]=10;  centhi[1]=20;
centlo[2]=20;  centhi[2]=30;
centlo[3]=30;  centhi[3]=40;
centlo[4]=40;  centhi[4]=50;

//Create the output ROOT file
TFile *myFile;

//Make Subdirectories for what will follow
TDirectory *myPlots;//the top level
TDirectory *v11plots;//where i will store the v11 plots
//TDirectory *v1plots;//where I will store the v1 plots after the fit

//2 Particle Correlation plots
TProfile2D *V11Pt[nCent];//This is where I declare the v11(pT) plots
TProfile2D *V11Eta[nCent];//This is where I declare the v11(eta) plots
//PT Bin Centers
TProfile *PTCenters[nCent];
///////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////
/////////////////// END OF GLOBAL VARIABLES ///////////////////////
///////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////


//Running the Macro
Int_t TwoParticleCorrelation_${1}(){//put functions in here
  Initialize();
  CorrelationAnalysis();
  PlotFitting();
  //Analyze();
  return 0;
}

void Initialize(){

  Double_t eta_bin_small[7]={-1.5,-1.0,-0.5,0.0,0.5,1.0,1.5};
  Double_t pt_bin[21]={0.4,0.6,0.8,1.0,
                       1.2,1.4,1.6,1.8,
                       2.0,2.4,2.8,3.2,
                       3.6,4.5,5.5,6.5,
                       7.5,8.5,9.5,10.5,
                       12};

 
  //Tracks Tree
  chain= new TChain("hiLowPtPixelTracksTree");
  chain3=new TChain("hiSelectedVertexTree");
  chain4=new TChain("HFtowersCentralityTree");

  //Tracks Tree
  chain->Add("/hadoop/store/user/jgomez2/ForwardTrees/2011/$b");
  //Vertex Tree
  chain3->Add("/hadoop/store/user/jgomez2/ForwardTrees/2011/$b");
  //Centrality Tree
  chain4->Add("/hadoop/store/user/jgomez2/ForwardTrees/2011/$b");

  NumberOfEvents= chain->GetEntries();

  //Create the output ROOT file
  myFile = new TFile("TwoParticleCorrelationAnalysis_${1}.root","recreate");

  //Make Subdirectories for what will follow
  myPlots = myFile->mkdir("Plots");
  myPlots->cd();

  //Directory For Final v1 plots
  //v1plots = myPlots->mkdir("V1Results");
  v11plots = myPlots->mkdir("V11Results");


  //Creating Characters so that I can make plot names and titles
  char v11ptname[128],v11pttitle[128];
  char v11etaname[128],v11etatitle[128];
  char ptcentname[128],ptcenttitle[128];

  ///Being Actually making the plots
  for (int i=0;i<nCent;i++)
    {
      //V11(PT)[cent] plots
      v11plots->cd();
      sprintf(v11ptname,"V11PT_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(v11pttitle,"v_{11}(p_{T}) for %1.0lf-%1.0lf %%",centlo[i],centhi[i]);
      V11Pt[i]= new TProfile2D(v11ptname,v11pttitle,20,pt_bin,20,pt_bin);

      //V1(eta)[cent] plots
      sprintf(v11etaname,"V11Eta_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(v11etatitle,"v_{11}(#eta) for %1.0lf-%1.0lf %%", centlo[i],centhi[i]);
      V11Eta[i] = new TProfile2D(v11etaname,v11etatitle,6,eta_bin_small,6,eta_bin_small);

      //PT Centers
      myPlots->cd();//Find a better home for this
      sprintf(ptcentname,"pTCenter_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(ptcenttitle,"Bin Center for %1.0lf-%1.0lf %%",centlo[i],centhi[i]);
      PTCenters[i]= new TProfile(ptcentname,ptcenttitle,20,pt_bin);


    }//end of plot making


}//End of Initialize function

void CorrelationAnalysis(){
  for (Int_t i=0;i<NumberOfEvents;i++)
    {//First loop over all events
      if ( !(i%10000) ) cout << " 1st round, event # " << i << " / " << NumberOfEvents << endl;

      chain->GetEntry(i);
      chain3->GetEntry(i);
      chain4->GetEntry(i); 

      ///////////////////////////////////////////////////////////
      /////////////////GRAB Leaves///////////////////////////////
      //////////////////////////////////////////////////////////

      //Track Leaves
      NumTracks= (TLeaf*) chain->GetLeaf("nTracks");
      TrackMom= (TLeaf*) chain->GetLeaf("pt");
      TrackPhi= (TLeaf*) chain->GetLeaf("phi");
      TrackEta= (TLeaf*) chain->GetLeaf("eta");
   
      //Filter On Centrality      
      CENTRAL= (TLeaf*) chain4->GetLeaf("Bin");                                                         
      Centrality= CENTRAL->GetValue();                                                                 
      if (Centrality>19) continue;                                                                      

      //Make Vertex Cuts if Necessary                                                                   
      Vertex=(TLeaf*) chain3->GetLeaf("z");                                                             
      Zposition=Vertex->GetValue();                                                                     
      //if(Zposition<=5) continue;


      //Loop over all of the Reconstructed Tracks
      NumberOfHits= NumTracks->GetValue();
      for (Int_t j=0;j<NumberOfHits;j++)
        {
          pT=0.;
          phi=0.;
          eta=0.;
          pT=TrackMom->GetValue(j);
          phi=TrackPhi->GetValue(j);
          eta=TrackEta->GetValue(j);
          if(pT<0)
            {
              continue;
            }
          for (Int_t k=0;k<NumberOfHits;k++)
            {
              pTb=0.;
              phib=0.;
              etab=0.;
              pTb=TrackMom->GetValue(k);
              phib=TrackPhi->GetValue(k);
              etab=TrackEta->GetValue(k);
              for (Int_t c=0;c<nCent;c++)
                {
                  if ( (Centrality*2.5) > centhi[c] ) continue;
                  if ( (Centrality*2.5) < centlo[c] ) continue;
		  V11Eta[c]->Fill(eta,etab,cos(phib-phi));
                  if(pTb<0 || fabs(etab-eta)<0.7) continue;
		      else
		      {
                  V11Pt[c]->Fill(pT,pTb,cos(phib-phi));
                  PTCenters[c]->Fill(pTb,pTb);
                     } // make sure there is an eta gap between correlated particles
                }//end of loop over centralities
            }//end of loop over particle b
        }//loop over tracks
  }//end of first loop over events
}//end of Correlation Analysis function


void PlotFitting(){
  myFile->Write();
}//End of Plot Fitting Function

void Analyze(){
  myFile->Write();
}//end of analyze function
                                                   

+EOF
