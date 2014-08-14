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
TChain* chain2;

/////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////
////////////           GLOBAL VARIABLES            //////////////////
/////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////
Float_t pi=TMath::Pi();
Int_t NumberOfEvents=0;
//NumberOfEvents=1;
//NumberOfEvents=2;
//NumberOfEvents=20;
//NumberOfEvents=100;
  NumberOfEvents=5000;
//NumberOfEvents=100000;
//NumberOfEvents=5000000;
//  NumberOfEvents = chain->GetEntries();

const Int_t nCent=5;//Number of Centrality classes

///Looping Variables
Int_t Centrality=0; //This will be the centrality variable later
Int_t Centralityb=0;
Int_t NumberOfHits=0;//This will be for both tracks and Hits
Int_t NumberOfHitsB=0.;
Float_t pT=0.;
Float_t phi=0.;
Float_t eta=0.;
Float_t pTb=0.;
Float_t phib=0.;
Float_t etab=0.;


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


Int_t WhichBin;
Int_t WhichEvent;
bool Matches;
//Running the Macro
Int_t TwoParticleCorrelation_${1}(){//put functions in here
  Initialize();
  CorrelationAnalysis();
  myFile->Write();
  return 0;
}

void Initialize(){

  Double_t eta_bin_small[7]={-1.5,-1.0,-0.5,0.0,0.5,1.0,1.5};
 /* Double_t pt_bin[21]={0.4,0.6,0.8,1.0,
                       1.2,1.4,1.6,1.8,
                       2.0,2.4,2.8,3.2,
                       3.6,4.5,5.5,6.5,
                       7.5,8.5,9.5,10.5,
                       12};*/
Double_t pt_bin[17]={0.4,0.6,0.8,1.0,1.2,1.4,1.6,1.8,2.0,2.4,2.8,3.2,3.6,4.5,6.5,9.5,12};
/*Double_t atlas_ptvalues[86]={0.5, 0.6, 0.7, 0.8,
                           0.9, 1.0, 1.1, 1.2, 
                           1.3,1.4, 1.5, 1.6,
   1.7, 1.8, 1.9, 2.0,
   2.1, 2.2, 2.3,2.4,
   2.5, 2.6, 2.7, 2.8,
   2.9, 3.0, 3.1, 3.2,
   3.3,3.4, 3.5, 3.6, 
   3.7, 3.8, 3.9, 4.0,
   4.1, 4.2, 4.3,4.4,
   4.5, 4.6, 4.7, 4.8,
   4.9, 5.0, 5.1, 5.2,
   5.3,5.4, 5.5, 5.6,
   5.7, 5.8, 5.9, 6.0,
   6.1, 6.2, 6.3,6.4,
   6.5, 6.6, 6.7, 6.8,
   6.9, 7.0, 7.1, 7.2,
   7.3,7.4, 7.5, 7.6,
   7.7, 7.8, 7.9, 8.0,
   8.1, 8.2, 8.3,8.4,
   8.5, 8.6, 8.7, 8.8,
   8.9, 9.0 };
 */

/* Double_t pta_bins[9]={0.5,1.,1.5,2.,3.,4.,6.,8.,20.};
 Double_t ptb_bins[28]={0.5,0.6,0.8,1.0,
                      1.2,1.4,1.6,1.8,
                      2.0,2.2,2.4,2.6,
                      2.8,3.0,3.5,4.0,
                      4.5,5.0,6.0,7.0,
                      8.0,9.0,10.0,12,
                      14,16,18,20}; */
 chain= new TChain("hiGoodTightMergedTracksTree");

  chain2= new TChain("hiGoodTightMergedTracksTree");

  //Tracks Tree
  chain->Add("/hadoop/store/user/jgomez2/ForwardTrees/2010/PanicTime/$b");

  chain2->Add("/hadoop/store/user/jgomez2/ForwardTrees/2010/PanicTime/$b");
  //NumberOfEvents= chain->GetEntries();

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
      V11Pt[i]= new TProfile2D(v11ptname,v11pttitle,16,pt_bin,16,pt_bin);

      //V1(eta)[cent] plots
      sprintf(v11etaname,"V11Eta_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(v11etatitle,"v_{11}(#eta) for %1.0lf-%1.0lf %%", centlo[i],centhi[i]);
      V11Eta[i] = new TProfile2D(v11etaname,v11etatitle,6,eta_bin_small,6,eta_bin_small);

      //PT Centers
      myPlots->cd();//Find a better home for this
      sprintf(ptcentname,"pTCenter_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(ptcenttitle,"Bin Center for %1.0lf-%1.0lf %%",centlo[i],centhi[i]);
      PTCenters[i]= new TProfile(ptcentname,ptcenttitle,16,pt_bin);


    }//end of plot making


}//End of Initialize function

void CorrelationAnalysis(){
  for (Int_t i=0;i<NumberOfEvents;i++)
    {//First loop over all events
      if ( !(i%10000) ) cout << " 1st round, event # " << i << " / " << NumberOfEvents << endl;

            chain->GetEntry(i);
      
      WhichBin=-1;
      WhichEvent=-1;
      Matches=false;
      ///////////////////////////////////////////////////////////
      /////////////////GRAB Leaves///////////////////////////////
      //////////////////////////////////////////////////////////

      //Track Leaves
      NumTracks= (TLeaf*) chain->GetLeaf("nTracks");
      TrackMom= (TLeaf*) chain->GetLeaf("pt");
      TrackPhi= (TLeaf*) chain->GetLeaf("phi");
      TrackEta= (TLeaf*) chain->GetLeaf("eta");
      //Centrality Leaves
      CENTRAL= (TLeaf*) chain->GetLeaf("bin");
      Centrality=CENTRAL->GetValue();
      if (Centrality>19) continue;

      //      std::cout<<Centrality<<std::endl;


      //Determine Which Centrality Bin it is
      for (Int_t c=0;c<nCent;c++)
	{
	  if ( (Centrality*2.5)<=centhi[c] && (Centrality*2.5)>=centlo[c]) WhichBin=c;
	}

      //      std::cout<<WhichBin<<std::endl;

      for (Int_t z=i+1;z<chain2->GetEntries();z++)
	{
	  chain2->GetEntry(z);
	  //Centrality Leaves                      
	  CENTRALB= (TLeaf*) chain2->GetLeaf("bin");
	  Centralityb=CENTRALB->GetValue();
	  if(Centralityb>19) continue;
	  if( ((Centralityb*2.5)<=centhi[WhichBin]) && ((Centralityb*2.5)>=centlo[WhichBin]) ) 
	    {
	      WhichEvent=z;
	      Matches=true;
	      //    std::cout<<Centralityb<<" "<<z<<std::endl;
	      //std::cout<<centhi[WhichBin]<<" "<<centlo[WhichBin]<<std::endl;
	      break;
	      }
	}//end of second loop over events
      
      chain2->GetEntry(WhichEvent);
      //Track Leaves 
      NumTracksB= (TLeaf*) chain2->GetLeaf("nTracks");
      TrackMomB= (TLeaf*) chain2->GetLeaf("pt");
      TrackPhiB= (TLeaf*) chain2->GetLeaf("phi");
      TrackEtaB= (TLeaf*) chain2->GetLeaf("eta");



      if(Matches==false) continue;
	  
      //Loop over all of the Reconstructed Tracks
      NumberOfHits= NumTracks->GetValue();
      NumberOfHitsB = NumTracksB->GetValue();
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
          for (Int_t k=0;k<NumberOfHitsB;k++)
            {
              pTb=0.;
              phib=0.;
              etab=0.;
              pTb=TrackMomB->GetValue(k);
              phib=TrackPhiB->GetValue(k);
              etab=TrackEtaB->GetValue(k);
              for (Int_t c=0;c<nCent;c++)
                {
                  if ( (Centrality*2.5) > centhi[c] ) continue;
                  if ( (Centrality*2.5) < centlo[c] ) continue;
		  V11Eta[c]->Fill(eta,etab,cos(phib-phi));
                  if(pTb<0 || fabs(etab-eta)<2.0) continue;
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



                                                   

+EOF
