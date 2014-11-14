#!/bin/sh
 

b=$(sed -ne "${1}{p;q;}" files.txt)

cat > HFV1PTStats_${1}.C << +EOF
#include<TH1F>
#include<TProfile>
#include<iostream>
#include<iomanip>
#include"TFile.h"
#include"TTree.h"
#include"TLeaf.h"
#include"TChain.h"

void Initialize();
void PTStats();
void AngularCorrections();
void EPPlotting();


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

////////////////////////////////
// pT stat plots
TDirectory *ptstatplots;



//<pT> and <pT^2> 
Float_t ptavmid[nCent],pt2avmid[nCent];


//////////////////////////////////
//////////////
/// pT Stat Plots
TProfile *PtStatsMid[nCent];//Middle eta tracker

Int_t HFV1PTStats_${1}(){
  Initialize();
  PTStats();
  return 0;
}


void Initialize(){

  //  std::cout<<"Made it into initialize"<<std::endl;
  Float_t eta_bin_small[13]={-0.6,-0.5,-0.4,-0.3,-0.2,-0.1,0.0,0.1,0.2,0.3,0.4,0.5,0.6};

  Double_t pt_bin[17]={0.4,0.6,0.8,1.0,1.2,1.4,1.6,1.8,2.0,2.4,2.8,3.2,3.6,4.5,6.5,9.5,12};


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
  myFile = new TFile("HFEP_PTStats_${1}.root","recreate");

  //Make Subdirectories for what will follow
  myPlots = myFile->mkdir("Plots");
  myPlots->cd();
  //////////////////////////////////////////////////////////////////////
  ptstatplots = myPlots->mkdir("PTStats");



  ///////////////////////////////////
  ////PT Stats
  char ptstatname[128],ptstattitle[128];

  for (Int_t i=0;i<nCent;i++)
    {
      //////////////////////////////////////////////////////
      //////// PT STAT PLots
      //Mid tracker
      ptstatplots->cd();
      sprintf(ptstatname,"PtStatsMid_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(ptstattitle,"p_{T} stats for mid-rapidity tracker %1.0lf-%1.0lf %%",centlo[i],centhi[i]);
      PtStatsMid[i]= new TProfile(ptstatname,ptstattitle,2,0,2);
      PtStatsMid[i]->GetXaxis()->SetBinLabel(1,"<p_{T}>");
      PtStatsMid[i]->GetXaxis()->SetBinLabel(2,"<p_{T}^{2}>");

    }//end of loop over centralities

}//end of initialize function


void PTStats(){
  for (Int_t i=0;i<NumberOfEvents;i++)
    {
      if ( !(i%10000) ) cout << " 1st round, event # " << i << " / " << NumberOfEvents << endl;
      chain->GetEntry(i);
      chain2->GetEntry(i);//grab the ith event
      chain3->GetEntry(i);
      chain4->GetEntry(i);
 
      //Filter On Centrality
      CENTRAL= (TLeaf*) chain4->GetLeaf("Bin");
      Centrality= CENTRAL->GetValue();
      if (Centrality>100) continue;

      //Make Vertex Cuts if Necessary
      Vertex=(TLeaf*) chain3->GetLeaf("z");
      Zposition=Vertex->GetValue();
      //if(Zposition<=5) continue;
      
      //Grab the Track Leaves
      NumTracks= (TLeaf*) chain->GetLeaf("nTracks");
      TrackMom= (TLeaf*) chain->GetLeaf("pt");
      TrackPhi= (TLeaf*) chain->GetLeaf("phi");
      TrackEta= (TLeaf*) chain->GetLeaf("eta");

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
	  for (Int_t c=0;c<nCent;c++)
            {
	      if ( (Centrality*0.5) > centhi[c] ) continue;
              if ( (Centrality*0.5) < centlo[c] ) continue;
	      PtStatsMid[c]->Fill(0,pT);
	      PtStatsMid[c]->Fill(1,pT*pT);
	    }//end of loop over centralityies
	}//end of loop over tracks
    }//end of loop over events

  for (Int_t cent_iter=0;cent_iter<nCent;cent_iter++)
    {
      ptavmid[cent_iter]=PtStatsMid[cent_iter]->GetBinContent(1);
      pt2avmid[cent_iter]=PtStatsMid[cent_iter]->GetBinContent(2);      
    }//end of loop over centralities
  myFile->Write();
}//end of ptstats function

+EOF
