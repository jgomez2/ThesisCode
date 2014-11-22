#!/bin/sh
 

b=$(sed -ne "${1}{p;q;}" files.txt)

cat > TRV1AngularCorrections_${1}.C << +EOF
#include<TH1F>
#include<TProfile>
#include<iostream>
#include<iomanip>
#include"TFile.h"
#include"TComplex.h"
#include"TTree.h"
#include"TLeaf.h"
#include"TChain.h"

void Initialize();
void FillPTStats();
void AngularCorrections();


TChain* chain;
TChain* chain2;
TChain* chain3;

/////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////
////////////           GLOBAL VARIABLES            //////////////////
/////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////
Int_t vterm=1;
Int_t jMax=10;////Set out to which order correction we would like to apply
Int_t NumberOfEvents=0;
//NumberOfEvents=200;

const Int_t nCent=5;

///Looping Variables
Int_t Centrality=0; //This will be the centrality variable later
Float_t Zposition=0.;
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

//Create the Root File
TFile *myFile;

//Make Subdirectories for the plots
TDirectory *myPlots;
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
TComplex Q_wholetracker[nCent],Q_postracker[nCent],
  Q_negtracker[nCent],Q_midtracker[nCent];


//v1 odd
TComplex Q_wholeoddtracker[nCent],Q_posoddtracker[nCent],
  Q_negoddtracker[nCent],Q_midoddtracker[nCent];


//Correction Terms
TComplex QEP_wholetracker[jMax],QEP_postracker[jMax],QEP_negtracker[jMax],QEP_midtracker[jMax],
  QEP_wholeoddtracker[jMax],QEP_posoddtracker[jMax],QEP_negoddtracker[jMax],QEP_midoddtracker[jMax];

//Complex EPS
Float_t Complexwholetracker=0.,Complexpostracker=0.,Complexnegtracker=0.,Complexmidtracker=0.,
  Complexwholeoddtracker=0.,Complexposoddtracker=0.,Complexnegoddtracker=0.,Complexmidoddtracker=0.;



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



//Running the Macro
Int_t TRV1AngularCorrections_${1}(){//put functions in here
  Initialize();
  FillPTStats();
  AngularCorrections();
  return 0;
}

void Initialize(){

  float eta_bin_small[13]={-0.6,-0.5,-0.4,-0.3,-0.2,-0.1,0.0,0.1,0.2,0.3,0.4,0.5,0.6};

  double pt_bin[17]={0.4,0.6,0.8,1.0,1.2,1.4,1.6,1.8,2.0,2.4,2.8,3.2,3.6,4.5,6.5,9.5,12};



  chain= new TChain("hiGeneralAndPixelTracksTree");
  chain2=new TChain("hiSelectedVertexTree");
  chain3=new TChain("HFtowersCentralityTree");

  //Tracks Tree
  chain->Add("/hadoop/store/user/jgomez2/DataSkims/2011/2011MinBiasReReco/FinalTrees/$b");
  //Vertex Tree
  chain2->Add("/hadoop/store/user/jgomez2/DataSkims/2011/2011MinBiasReReco/FinalTrees/$b");
  //Centrality Tree
  chain3->Add("/hadoop/store/user/jgomez2/DataSkims/2011/2011MinBiasReReco/FinalTrees/$b");

 NumberOfEvents= chain->GetEntries();


  //Create the output root file
  myFile = new TFile("TREP_AngularCorrections_${1}.root","recreate");

  //Make Subdirectories for what will follow
  myPlots = myFile->mkdir("Plots");
  myPlots->cd();






  //Angular Correction Folders
  angularcorrectionplots = myPlots->mkdir("AngularCorrectionPlots");
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

void AngularCorrections(){

  for(Int_t i=0;i<NumberOfEvents;i++)
    {

      // std::cout<<"Event number "<<i<<std::endl;

      chain->GetEntry(i);
      chain2->GetEntry(i);
      chain3->GetEntry(i);

      //Track Info
      NumTracks= (TLeaf*) chain->GetLeaf("nTracks");
      TrackMom= (TLeaf*) chain->GetLeaf("pt");
      TrackPhi= (TLeaf*) chain->GetLeaf("phi");
      TrackEta= (TLeaf*) chain->GetLeaf("eta");

      //Centrality Info
      CENTRAL= (TLeaf*) chain3->GetLeaf("Bin");
      Centrality= CENTRAL->GetValue();
      if (Centrality>100) continue;


      //Vertex Info
      Vertex=(TLeaf*) chain2->GetLeaf("z");
      Zposition=Vertex->GetValue();
      //if(Zposition<=5) continue;


      Complexwholetracker=0.;
      Complexpostracker=0.;
      Complexnegtracker=0.;
      Complexmidtracker=0.;
      Complexwholeoddtracker=0.;
      Complexposoddtracker=0.;
      Complexnegoddtracker=0.;
      Complexmidoddtracker=0.;


      for (int b=0;b<jMax;b++)
        {
          QEP_wholetracker[b]=TComplex(0.);
          QEP_postracker[b]=TComplex(0.);
          QEP_negtracker[b]=TComplex(0.);
          QEP_midtracker[b]=TComplex(0.);
          QEP_wholeoddtracker[b]=TComplex(0.);
          QEP_posoddtracker[b]=TComplex(0.);
          QEP_negoddtracker[b]=TComplex(0.);
          QEP_midoddtracker[b]=TComplex(0.);
        }

      //Zero the looping variables
      for (int q=0;q<nCent;q++)
        {
          Q_wholetracker[q]=TComplex(0.);
          Q_postracker[q]=TComplex(0.);
          Q_negtracker[q]=TComplex(0.);
          Q_midtracker[q]=TComplex(0.);
          Q_wholeoddtracker[q]=TComplex(0.);
          Q_posoddtracker[q]=TComplex(0.);
          Q_negoddtracker[q]=TComplex(0.);
          Q_midoddtracker[q]=TComplex(0.);
	}
          


      for(Int_t ii=0;ii<NumTracks->GetValue();ii++)
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

              if (fabs(eta)>=1.4)
                {
                  if (eta>0)
                    {
                      //Outer Tracker
                      //Even
                      Q_wholetracker[c]+=TComplex::Exp(TComplex::I()*phi)*(pT-(pt2avwhole[c]/ptavwhole[c]));
		      //Pos Only
                      Q_postracker[c]+=TComplex::Exp(TComplex::I()*phi)*(pT-(pt2avpos[c]/ptavpos[c]));
		      //Odd
                      Q_wholeoddtracker[c]+=TComplex::Exp(TComplex::I()*phi)*(pT-(pt2avwhole[c]/ptavwhole[c]));
		      //Pos Odd Only
                      Q_posoddtracker[c]+=TComplex::Exp(TComplex::I()*phi)*(pT-(pt2avpos[c]/ptavpos[c]));
		    }//Positive outer tracker
                  else if (eta<0)
                    {
                      //Outer Tracker
                      //Even
                      Q_wholetracker[c]+=TComplex::Exp(TComplex::I()*phi)*(pT-(pt2avwhole[c]/ptavwhole[c]));
		      //Neg Only
                      Q_negtracker[c]+=TComplex::Exp(TComplex::I()*phi)*(pT-(pt2avneg[c]/ptavneg[c]));
		      //Odd
                      Q_wholeoddtracker[c]+=TComplex::Exp(TComplex::I()*phi)*(-1.0*(pT-(pt2avwhole[c]/ptavwhole[c])));
		      //Neg Odd Only
                      Q_negoddtracker[c]+=TComplex::Exp(TComplex::I()*phi)*(-1.0*(pT-(pt2avneg[c]/ptavneg[c])));
		    }//end of negative outer tracks
                }//End of outer tracks statement
              else if (fabs(eta)<=0.6)
                {
                  if(eta>0.0)
                    {
                      //even
                      Q_midtracker[c]+=TComplex::Exp(TComplex::I()*phi)*(pT-(pt2avmid[c]/ptavmid[c]));
		      //odd
                      Q_midoddtracker[c]+=TComplex::Exp(TComplex::I()*phi)*(pT-(pt2avmid[c]/ptavmid[c]));
		    }//positive center tracker
                  else if (eta<0)
                    {
                      //even
                      Q_midtracker[c]+=TComplex::Exp(TComplex::I()*phi)*(pT-(pt2avmid[c]/ptavmid[c]));
		      //odd
                      Q_midoddtracker[c]+=TComplex::Exp(TComplex::I()*phi)*(-1.0*(pT-(pt2avmid[c]/ptavmid[c])));
		    }//negative center tracker
                }//end of middle tracks statement
            }//End of loop over centralities
        }//End of loop over tracks


      
      /////////////////////////////////////////////////////////////////////
      ///////////////////////////////////////////////////////////////////
      //////////////////////////////////////////////////////////////////
      //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      // I WAS HERE, finish adding complex stuff//
      /////////////////////////////////////////////////////////////////////////////


      for (Int_t c=0;c<nCent;c++)
	{

	  if ( (Centrality*0.5) > centhi[c] ) continue; 
	  if ( (Centrality*0.5) < centlo[c] ) continue; 

	  //V1 Even
	  //Whole Tracker
	  Complexwholetracker=(1./1.)*TMath::ATan2(Q_wholetracker[c].Im(),Q_wholetracker[c].Re());
	  if (Complexwholetracker>(TMath::Pi())) Complexwholetracker=(Complexwholetracker-(TMath::TwoPi()));
          if (Complexwholetracker<(-1.0*TMath::Pi())) Complexwholetracker=(Complexwholetracker+(TMath::TwoPi()));


	  //Pos Tracker
	  Complexpostracker=(1./1.)*TMath::ATan2(Q_postracker[c].Im(),Q_postracker[c].Re());
	  if (Complexpostracker>(TMath::Pi())) Complexpostracker=(Complexpostracker-(TMath::TwoPi()));
          if (Complexpostracker<(-1.0*TMath::Pi())) Complexpostracker=(Complexpostracker+(TMath::TwoPi()));

	  	  
	  //Neg Tracker
	  Complexnegtracker=(1./1.)*TMath::ATan2(Q_negtracker[c].Im(),Q_negtracker[c].Re());
	  if (Complexnegtracker>(TMath::Pi())) Complexnegtracker=(Complexnegtracker-(TMath::TwoPi()));
          if (Complexnegtracker<(-1.0*TMath::Pi())) Complexnegtracker=(Complexnegtracker+(TMath::TwoPi()));


	  //Mid Tracker
	  Complexmidtracker=(1./1.)*TMath::ATan2(Q_midtracker[c].Im(),Q_midtracker[c].Re());
	  if (Complexmidtracker>(TMath::Pi())) Complexmidtracker=(Complexmidtracker-(TMath::TwoPi()));
          if (Complexmidtracker<(-1.0*TMath::Pi())) Complexmidtracker=(Complexmidtracker+(TMath::TwoPi()));
	  

	  //V1 Odd
	  //Whole Tracker                                                                    
	  Complexwholeoddtracker=(1./1.)*TMath::ATan2(Q_wholeoddtracker[c].Im(),Q_wholeoddtracker[c].Re());
	  if (Complexwholeoddtracker>(TMath::Pi())) Complexwholeoddtracker=(Complexwholeoddtracker-(TMath::TwoPi()));
	  if (Complexwholeoddtracker<(-1.0*TMath::Pi())) Complexwholeoddtracker=(Complexwholeoddtracker+(TMath::TwoPi()));
	  
          //Posodd Tracker                                                               
	  Complexposoddtracker=(1./1.)*TMath::ATan2(Q_posoddtracker[c].Im(),Q_posoddtracker[c].Re());
	  if (Complexposoddtracker>(TMath::Pi())) Complexposoddtracker=(Complexposoddtracker-(TMath::TwoPi()));
          if (Complexposoddtracker<(-1.0*TMath::Pi())) Complexposoddtracker=(Complexposoddtracker+(TMath::TwoPi()));

	  

          //Neg Tracker                                                                       
	  Complexnegoddtracker=(1./1.)*TMath::ATan2(Q_negoddtracker[c].Im(),Q_negoddtracker[c].Re());
	  if (Complexnegoddtracker>(TMath::Pi())) Complexnegoddtracker=(Complexnegoddtracker-(TMath::TwoPi()));
          if (Complexnegoddtracker<(-1.0*TMath::Pi())) Complexnegoddtracker=(Complexnegoddtracker+(TMath::TwoPi()));


          //Mid Tracker                                                                       
	  Complexmidoddtracker=(1./1.)*TMath::ATan2(Q_midoddtracker[c].Im(),Q_midoddtracker[c].Re());
	  if (Complexmidoddtracker>(TMath::Pi())) Complexmidoddtracker=(Complexmidoddtracker-(TMath::TwoPi()));
          if (Complexmidoddtracker<(-1.0*TMath::Pi())) Complexmidoddtracker=(Complexmidoddtracker+(TMath::TwoPi()));
	  

	  for (Int_t k=1;k<(jMax+1);k++)
	    {
	      QEP_wholetracker[k-1]=TComplex::Exp(TComplex::I()*k*Complexwholetracker);
	      QEP_postracker[k-1]=TComplex::Exp(TComplex::I()*k*Complexpostracker);
	      QEP_negtracker[k-1]=TComplex::Exp(TComplex::I()*k*Complexnegtracker);
	      QEP_midtracker[k-1]=TComplex::Exp(TComplex::I()*k*Complexmidtracker);
	      QEP_wholeoddtracker[k-1]=TComplex::Exp(TComplex::I()*k*Complexwholeoddtracker);
	      QEP_posoddtracker[k-1]=TComplex::Exp(TComplex::I()*k*Complexposoddtracker);
	      QEP_negoddtracker[k-1]=TComplex::Exp(TComplex::I()*k*Complexnegoddtracker);
	      QEP_midoddtracker[k-1]=TComplex::Exp(TComplex::I()*k*Complexmidoddtracker);

	      
	      //V1 odd
	      //Whole tracker
	      //Coswholeoddtracker[c]->Fill(k-1,TMath::Cos(k*EPwholeoddtracker));
	      Coswholeoddtracker[c]->Fill(k-1,QEP_wholeoddtracker[k-1].Re());
	      //Sinwholeoddtracker[c]->Fill(k-1,TMath::Sin(k*EPwholeoddtracker));
	      Sinwholeoddtracker[c]->Fill(k-1,QEP_wholeoddtracker[k-1].Im());
	      //ComplexCosFactors[c]->Fill(k-1,QEP_wholetracker[k-1].Re());
	      //ComplexSinFactors[c]->Fill(k-1,QEP_wholetracker[k-1].Im());
	      
	      //Pos tracker
	      //Cosposoddtracker[c]->Fill(k-1,TMath::Cos(k*EPposoddtracker));
	      //Sinposoddtracker[c]->Fill(k-1,TMath::Sin(k*EPposoddtracker));
	      Cosposoddtracker[c]->Fill(k-1,QEP_posoddtracker[k-1].Re());
              Sinposoddtracker[c]->Fill(k-1,QEP_posoddtracker[k-1].Im());


	      //Neg Tracker
	      //Cosnegoddtracker[c]->Fill(k-1,TMath::Cos(k*EPnegoddtracker));
	      //Sinnegoddtracker[c]->Fill(k-1,TMath::Sin(k*EPnegoddtracker));
	      Cosnegoddtracker[c]->Fill(k-1,QEP_negoddtracker[k-1].Re());
              Sinnegoddtracker[c]->Fill(k-1,QEP_negoddtracker[k-1].Im());

	      
	      //Mid tracker
	      //Cosmidoddtracker[c]->Fill(k-1,TMath::Cos(k*EPmidoddtracker));
	      //Sinmidoddtracker[c]->Fill(k-1,TMath::Sin(k*EPmidoddtracker));
	      Cosmidoddtracker[c]->Fill(k-1,QEP_midoddtracker[k-1].Re());
              Sinmidoddtracker[c]->Fill(k-1,QEP_midoddtracker[k-1].Im());


	      //V1 Even                                                     
	      //Whole tracker
              //Coswholetracker[c]->Fill(k-1,TMath::Cos(k*EPwholetracker));
              //Sinwholetracker[c]->Fill(k-1,TMath::Sin(k*EPwholetracker));
	      Coswholetracker[c]->Fill(k-1,QEP_wholetracker[k-1].Re());
              Sinwholetracker[c]->Fill(k-1,QEP_wholetracker[k-1].Im());


	      //Pos tracker                                
	      //Cospostracker[c]->Fill(k-1,TMath::Cos(k*EPpostracker));
	      //Sinpostracker[c]->Fill(k-1,TMath::Sin(k*EPpostracker));
	      Cospostracker[c]->Fill(k-1,QEP_postracker[k-1].Re());
              Sinpostracker[c]->Fill(k-1,QEP_postracker[k-1].Im());
	      

	      //Neg Tracker                                                                   
	      //Cosnegtracker[c]->Fill(k-1,TMath::Cos(k*EPnegtracker));
	      //Sinnegtracker[c]->Fill(k-1,TMath::Sin(k*EPnegtracker));
	      Cosnegtracker[c]->Fill(k-1,QEP_negtracker[k-1].Re());
              Sinnegtracker[c]->Fill(k-1,QEP_negtracker[k-1].Im());

	      //Mid tracker
	      Cosmidtracker[c]->Fill(k-1,QEP_midtracker[k-1].Re());
	      Sinmidtracker[c]->Fill(k-1,QEP_midtracker[k-1].Im());
	    }//end of loop over nth order flattening params
	}//End of loop over centrality classes
    }//End of loop over events
  myFile->Write();
}//End of angular corrections function

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


}//end of pt stats function


+EOF
