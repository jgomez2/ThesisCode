#!/bin/sh
 

b=$(sed -ne "${1}{p;q;}" files.txt)

cat > TRV1PTStats_${1}.C << +EOF

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
void PTStats();
////////////////////////////


//Files and chains
//Files and chains
TChain* chain2;
TChain* chain3;
TChain* chain4;


////////////////////////////////////////////////////////
//Simply Need to Add psi(pos/neg/mid) Raw/Final plots///
////////////////////////////////////////////////////////

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
Float_t Zposition=0.;


Float_t centlo[nCent];
Float_t centhi[nCent];
centlo[0]=0;  centhi[0]=10;
centlo[1]=10;  centhi[1]=20;
centlo[2]=20;  centhi[2]=30;
centlo[3]=30;  centhi[3]=40;
centlo[4]=40;  centhi[4]=50;

//Create the output ROOT file
TFile *myFile;// = new TFile("TREP_PTStats_${1}.root","RECREATE");
//TTree *myTree;

TDirectory *myPlots;
//Pt stats
TDirectory *ptstatplots;

//TProfiles to save <pT> and <pT^2> info ....All this is for Ollitrault weights
TProfile *PtStatsWhole[nCent];//Both sides of the tracker
TProfile *PtStatsPos[nCent];//Positive eta tracker
TProfile *PtStatsNeg[nCent];//Negative eta tracker
TProfile *PtStatsMid[nCent];//Middle eta tracker
Float_t ptavwhole[nCent]={0.},pt2avwhole[nCent]={0.};
Float_t ptavpos[nCent]={0.},pt2avpos[nCent]={0.};
Float_t ptavneg[nCent]={0.},pt2avneg[nCent]={0.};
Float_t ptavmid[nCent]={0.},pt2avmid[nCent]={0.};

///////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////
/////////////////// END OF GLOBAL VARIABLES ///////////////////////
///////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////

//Running the Macro
Int_t TRV1PTStats_${1}(){//put functions in here
  Initialize();
  PTStats();
  return 0;
}

void Initialize(){

 

  chain2= new TChain("hiLowPtPixelTracksTree");
    chain3=new TChain("hiSelectedVertexTree");
  chain4=new TChain("HFtowersCentralityTree");
  
    //Tracks Tree                                                 
    chain2->Add("/data/users/jgomez2/BetterTrees/$b");                                 
   //Vertex Tree                                                                                     
   chain3->Add("/data/users/jgomez2/BetterTrees/$b");                                     
  //Centrality Tree                                                                                     
  chain4->Add("/data/users/jgomez2/BetterTrees/$b"); 

   NumberOfEvents= chain2->GetEntries();
  //Create the output ROOT file
  myFile = new TFile("TREP_PTStats_${1}.root","recreate");

  //Make Subdirectories for what will follow
  myPlots = myFile->mkdir("Plots");
  myPlots->cd();

  //Pt stats
  ptstatplots = myPlots->mkdir("PtStats");


  char ptwholename[128];
  char ptwholetitle[128];

  char ptposname[128];
  char ptpostitle[128];

  char ptnegname[128];
  char ptnegtitle[128];

  char ptmidname[128];
  char ptmidtitle[128];
  

  for (int i=0;i<nCent;i++)
    {

      //whole tracker
      ptstatplots->cd();
      sprintf(ptwholename,"PtStatsWhole_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(ptwholetitle,"p_{T} stats for whole tracker %1.0lf-%1.0lf %%",centlo[i],centhi[i]);
      PtStatsWhole[i]= new TProfile(ptwholename,ptwholetitle,2,0,2);
      PtStatsWhole[i]->GetXaxis()->SetBinLabel(1,"<p_{T}>");
      PtStatsWhole[i]->GetXaxis()->SetBinLabel(2,"<p_{T}^{2}>");

      //Pos tracker
      sprintf(ptposname,"PtStatsPos_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(ptpostitle,"p_{T} stats for positive #eta tracker %1.0lf-%1.0lf %%",centlo[i],centhi[i]);
      PtStatsPos[i]= new TProfile(ptposname,ptpostitle,2,0,2);
      PtStatsPos[i]->GetXaxis()->SetBinLabel(1,"<p_{T}>");
      PtStatsPos[i]->GetXaxis()->SetBinLabel(2,"<p_{T}^{2}>");

      //Neg tracker
      sprintf(ptnegname,"PtStatsNeg_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(ptnegtitle,"p_{T} stats for negative #eta tracker %1.0lf-%1.0lf %%",centlo[i],centhi[i]);
      PtStatsNeg[i]= new TProfile(ptnegname,ptnegtitle,2,0,2);
      PtStatsNeg[i]->GetXaxis()->SetBinLabel(1,"<p_{T}>");
      PtStatsNeg[i]->GetXaxis()->SetBinLabel(2,"<p_{T}^{2}>");

      //Mid tracker
      sprintf(ptmidname,"PtStatsMid_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(ptmidtitle,"p_{T} stats for mid-rapidity tracker %1.0lf-%1.0lf %%",centlo[i],centhi[i]);
      PtStatsMid[i]= new TProfile(ptmidname,ptmidtitle,2,0,2);
      PtStatsMid[i]->GetXaxis()->SetBinLabel(1,"<p_{T}>");
      PtStatsMid[i]->GetXaxis()->SetBinLabel(2,"<p_{T}^{2}>");
    }//end of centrality loop
}//end of initialize function

void PTStats(){
  for (int i=0;i<NumberOfEvents;i++)
    {
      if ( !(i%10000) ) cout << " 1st round, event # " << i << " / " << NumberOfEvents << endl;

      chain2->GetEntry(i);//grab the ith event
      chain3->GetEntry(i);
      chain4->GetEntry(i);
  
      //Grab the Track Leaves
      NumTracks= (TLeaf*) chain2->GetLeaf("nTracks");
      TrackMom= (TLeaf*) chain2->GetLeaf("pt");
      TrackPhi= (TLeaf*) chain2->GetLeaf("phi");
      TrackEta= (TLeaf*) chain2->GetLeaf("eta");

       //Filter On Centrality
      CENTRAL= (TLeaf*) chain4->GetLeaf("Bin");
      Centrality= CENTRAL->GetValue();
      if (Centrality>100) continue;

      //Make Vertex Cuts if Necessary
      Vertex=(TLeaf*) chain3->GetLeaf("z");
      Zposition=Vertex->GetValue();
      //if(Zposition<=5) continue;

      //Loop over all of the Reconstructed Tracks
      NumberOfHits= NumTracks->GetValue();
      for (int ii=0;ii<NumberOfHits;ii++)
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
          //  std::cout<<pT<< " and "<<eta<<std::endl;
          for (Int_t c=0;c<nCent;c++)
            {
              myPlots->cd();
              if ( (Centrality*0.5) > centhi[c] ) continue;
              if ( (Centrality*0.5) < centlo[c] ) continue;
              if (eta>=1.4)
                {
                  PtStatsWhole[c]->Fill(0,pT);
                  PtStatsWhole[c]->Fill(1,pT*pT);
                  PtStatsPos[c]->Fill(0,pT);
                  PtStatsPos[c]->Fill(1,pT*pT);
                }
              else if (eta<=-1.4)
                {
                  PtStatsWhole[c]->Fill(0,pT);
                  PtStatsWhole[c]->Fill(1,pT*pT);
                  PtStatsNeg[c]->Fill(0,pT);
                  PtStatsNeg[c]->Fill(1,pT*pT);
                }
              else if (fabs(eta)<=0.6)
                {
                  PtStatsMid[c]->Fill(0,pT);
                  PtStatsMid[c]->Fill(1,pT*pT);
                }
            }//end of looping over centralities
        }//end of loop over tracks
    }//end of loop over events
    myFile->Write();
}//end of ptstats function

+EOF
