#!/bin/sh
 

b=$(sed -ne "${1}{p;q;}" files.txt)

cat > MHV1AngularCorrections_${1}.C << +EOF

#include<TH1F>
#include<TProfile>
#include<iostream>
#include<iomanip>
#include"TFile.h"
#include"TTree.h"
#include"TLeaf.h"
#include"TChain.h"

void Initialize();
void AngularCorrections();


  //Chains
  TChain* chain; //Calo Tower Chain
  TChain* chain1; //hiGoodTightMergedTracks


  ///File and Directories in the File
  TFile *myFile;
  TDirectory *myPlots;//Top Directory
  //AngularCorrectionPlots
  TDirectory *angularcorrectionplots;
  TDirectory *angcorr1;
  TDirectory *angcorr2;
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
//NumberOfEvents=5000000;
Int_t Centrality=0;

///Looping Variables
Int_t NumberOfHits=0;//This will be for both tracks and Hits
Float_t pT=0.;
Float_t phi=0.;
Float_t eta=0.;
Float_t Energy=0.;

const Int_t nCent=5;//Number of Centrality classes

Float_t centlo[nCent];
Float_t centhi[nCent];
centlo[0]=0;  centhi[0]=10;
centlo[1]=10;  centhi[1]=20;
centlo[2]=20;  centhi[2]=30;
centlo[3]=30;  centhi[3]=40;
centlo[4]=40;  centhi[4]=50;


////////////////////////////////
///Psi1 Combined HF Variables///
////////////////////////////////
Float_t X_hf=0.,Y_hf=0.;//X and Y flow vectors
Float_t EP_hf=0.;//"raw" EP angle
////////////////////////////////
///Psi1 Positive HF Variables///
////////////////////////////////
Float_t X_hfp=0.,Y_hfp=0.;//X and Y flow vectors
Float_t EP_hfp=0.;//"raw" EP angle
////////////////////////////////
///Psi1 Negative HF Variables///
////////////////////////////////
Float_t X_hfn=0.,Y_hfn=0.;//X and Y flow vectors
Float_t EP_hfn=0.;//"raw" EP angle
////////////////////////////////
///Psi2 Positive HF Variables///
////////////////////////////////
Float_t X_hf2p=0.,Y_hf2p=0.;//X and Y flow vectors
Float_t EP_hf2p=0.;//"raw" EP angle
////////////////////////////////
///Psi2 Negative HF Variables///
////////////////////////////////
Float_t X_hf2n=0.,Y_hf2n=0.;//X and Y flow vectors
Float_t EP_hf2n=0.;//"raw" EP angle
////////////////////////////////
///Psi2 Mid Tracker Variables///
////////////////////////////////
Float_t X_tr2=0.,Y_tr2=0.;//X and Y flow vectors
Float_t EP_tr2=0.;//"raw" EP angle
/////////////////////////////////////
//////Angular Correction Plots///////
/////////////////////////////////////

//Combined HF
TProfile *Coshf[nCent];
TProfile *Sinhf[nCent];
//Pos HF
TProfile *Coshfp[nCent];
TProfile *Sinhfp[nCent];
//Neg HF
TProfile *Coshfn[nCent];
TProfile *Sinhfn[nCent];
//Psi2 Pos HF
TProfile *Coshf2p[nCent];
TProfile *Sinhf2p[nCent];
//Psi2 Neg HF
TProfile *Coshf2n[nCent];
TProfile *Sinhf2n[nCent];
//Psi2 Mid Tracker
TProfile *Costr2[nCent];
TProfile *Sintr2[nCent];
//////////////////////////////////////////////////////

Int_t MHV1AngularCorrections_${1}(){
  Initialize();
  AngularCorrections();
  myFile->Write();
  return 0;
}


void Initialize(){

  chain = new TChain("CaloTowerTree");
  chain1 = new TChain("hiGoodTightMergedTracksTree");
    
   //Calo Tower Tree
  chain->Add("/hadoop/store/user/jgomez2/ForwardTrees/2010/PanicTime/$b");
  //Tracks Tree
  chain1->Add("/hadoop/store/user/jgomez2/ForwardTrees/2010/PanicTime/$b");
 
   NumberOfEvents=chain1->GetEntries();


  ///This will be used once I parallelize the code
  myFile= new TFile("MHEP_AngularCorrections_${1}.root","recreate");
  
  myPlots = myFile->mkdir("Plots");
  myPlots->cd();
  //AngularCorrectionPlots
  angularcorrectionplots= myPlots->mkdir("AngularCorrections");
  angcorr1=angularcorrectionplots->mkdir("FirstOrderCorrections");
  angcorr2=angularcorrectionplots->mkdir("SecondOrderCorrections");

/////////////////////////////////////////////
///Declaration of Titles for the Plots///////
/////////////////////////////////////////////

////////////////////////////
//Angular Correction Plots//
////////////////////////////

//////First Order//////
char coshfname[128],coshftitle[128];//combined HF cosine corrections
char sinhfname[128],sinhftitle[128];//combined HF sine corrections

char coshfpname[128],coshfptitle[128];//positive HF cosine corrections
char sinhfpname[128],sinhfptitle[128];//positive HF sine corrections
 
char coshfnname[128],coshfntitle[128];//negative HF cosine corrections
char sinhfnname[128],sinhfntitle[128];//negative HF sine corrections 

//////Second Order//////
char coshf2pname[128],coshf2ptitle[128];//positive HF cosine corrections
char sinhf2pname[128],sinhf2ptitle[128];//positive HF sine corrections

char coshf2nname[128],coshf2ntitle[128];//negative HF cosine corrections
char sinhf2nname[128],sinhf2ntitle[128];//negative HF sine corrections

char costr2name[128],costr2title[128];//tracker cosine corrections
char sintr2name[128],sintr2title[128];//tracker sine corrections

/////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////
///////////////////MAKE THE PLOTS///////////////////////////
////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////
for (Int_t i=0;i<nCent;i++)
    {
	  /////////////////////////////////
	  ////Angular Correction Plots////
	  ////////////////////////////////
	  
	  ///First Order///
	  angcorr1->cd();
	  
	  //Combined HF
	  sprintf(coshfname,"CosValues_CombinedHF_%1.0lfto%1.0lf",centlo[i],centhi[i]);
	  sprintf(coshftitle,"CosValues_CombinedHF_%1.0lfto%1.0lf",centlo[i],centhi[i]);
	  Coshf[i]=new TProfile(coshfname,coshftitle,jMax,0,jMax);
	  Coshf[i]->GetYaxis()->SetTitle("<cos(Xbin*#Psi)>");
	  
	  sprintf(sinhfname,"SinValues_CombinedHF_%1.0lfto%1.0lf",centlo[i],centhi[i]);
	  sprintf(sinhftitle,"SinValues_CombinedHF_%1.0lfto%1.0lf",centlo[i],centhi[i]);
	  Sinhf[i]=new TProfile(sinhfname,sinhftitle,jMax,0,jMax);
	  Sinhf[i]->GetYaxis()->SetTitle("<sin(Xbin*#Psi)>");
	  
	  //Positive HF
	  sprintf(coshfpname,"CosValues_PositiveHF_%1.0lfto%1.0lf",centlo[i],centhi[i]);
	  sprintf(coshfptitle,"CosValues_PositiveHF_%1.0lfto%1.0lf",centlo[i],centhi[i]);
	  Coshfp[i]=new TProfile(coshfpname,coshfptitle,jMax,0,jMax);
	  Coshfp[i]->GetYaxis()->SetTitle("<cos(Xbin*#Psi)>");
	  
	  sprintf(sinhfpname,"SinValues_PositiveHF_%1.0lfto%1.0lf",centlo[i],centhi[i]);
	  sprintf(sinhfptitle,"SinValues_PositiveHF_%1.0lfto%1.0lf",centlo[i],centhi[i]);
	  Sinhfp[i]=new TProfile(sinhfpname,sinhfptitle,jMax,0,jMax);
	  Sinhfp[i]->GetYaxis()->SetTitle("<sin(Xbin*#Psi)>");
	  
	  //Negative HF
	  sprintf(coshfnname,"CosValues_NegativeHF_%1.0lfto%1.0lf",centlo[i],centhi[i]);
	  sprintf(coshfntitle,"CosValues_NegativeHF_%1.0lfto%1.0lf",centlo[i],centhi[i]);
	  Coshfn[i]=new TProfile(coshfnname,coshfntitle,jMax,0,jMax);
	  Coshfn[i]->GetYaxis()->SetTitle("<cos(Xbin*#Psi)>");
	  
	  sprintf(sinhfnname,"SinValues_NegativeHF_%1.0lfto%1.0lf",centlo[i],centhi[i]);
	  sprintf(sinhfntitle,"SinValues_NegativeHF_%1.0lfto%1.0lf",centlo[i],centhi[i]);
	  Sinhfn[i]=new TProfile(sinhfnname,sinhfntitle,jMax,0,jMax);
	  Sinhfn[i]->GetYaxis()->SetTitle("<sin(Xbin*#Psi)>");
	  
	  ////Second Order////
	  angcorr2->cd();
	  
	  //Positive HF
	  sprintf(coshf2pname,"CosValues_PositiveHF2_%1.0lfto%1.0lf",centlo[i],centhi[i]);
	  sprintf(coshf2ptitle,"CosValues_PositiveHF2_%1.0lfto%1.0lf",centlo[i],centhi[i]);
	  Coshf2p[i]=new TProfile(coshf2pname,coshf2ptitle,jMax,0,jMax);
	  Coshf2p[i]->GetYaxis()->SetTitle("<cos(Xbin*#Psi)>");
	  
	  sprintf(sinhf2pname,"SinValues_PositiveHF2_%1.0lfto%1.0lf",centlo[i],centhi[i]);
	  sprintf(sinhf2ptitle,"SinValues_PositiveHF2_%1.0lfto%1.0lf",centlo[i],centhi[i]);
	  Sinhf2p[i]=new TProfile(sinhf2pname,sinhf2ptitle,jMax,0,jMax);
	  Sinhf2p[i]->GetYaxis()->SetTitle("<sin(Xbin*#Psi)>");
	  
	  //Negative HF
	  sprintf(coshf2nname,"CosValues_NegativeHF2_%1.0lfto%1.0lf",centlo[i],centhi[i]);
	  sprintf(coshf2ntitle,"CosValues_NegativeHF2_%1.0lfto%1.0lf",centlo[i],centhi[i]);
	  Coshf2n[i]=new TProfile(coshf2nname,coshf2ntitle,jMax,0,jMax);
	  Coshf2n[i]->GetYaxis()->SetTitle("<cos(Xbin*#Psi)>");
	  
	  sprintf(sinhf2nname,"SinValues_NegativeHF2_%1.0lfto%1.0lf",centlo[i],centhi[i]);
	  sprintf(sinhf2ntitle,"SinValues_NegativeHF2_%1.0lfto%1.0lf",centlo[i],centhi[i]);
	  Sinhf2n[i]=new TProfile(sinhf2nname,sinhf2ntitle,jMax,0,jMax);
	  Sinhf2n[i]->GetYaxis()->SetTitle("<sin(Xbin*#Psi)>");
	  
	  //Tracker
	  sprintf(costr2name,"CosValues_TR2_%1.0lfto%1.0lf",centlo[i],centhi[i]);
	  sprintf(costr2title,"CosValues_TR2_%1.0lfto%1.0lf",centlo[i],centhi[i]);
	  Costr2[i]=new TProfile(costr2name,costr2title,jMax,0,jMax);
	  Costr2[i]->GetYaxis()->SetTitle("<cos(Xbin*#Psi)>");
	  
	  sprintf(sintr2name,"SinValues_TR2_%1.0lfto%1.0lf",centlo[i],centhi[i]);
	  sprintf(sintr2title,"SinValues_TR2_%1.0lfto%1.0lf",centlo[i],centhi[i]);
	  Sintr2[i]=new TProfile(sintr2name,sintr2title,jMax,0,jMax);
	  Sintr2[i]->GetYaxis()->SetTitle("<sin(Xbin*#Psi)>");
    }//end of loop over centralities
}//end of initialize function



void AngularCorrections(){
    for (Int_t i=0;i<NumberOfEvents;i++)
        {
           if ( !(i%10000) ) cout << " 1st round, event # " << i << " / " << NumberOfEvents << endl;
        
           chain->GetEntry(i);
           chain1->GetEntry(i);
           
           //Centrality Filter
           CENTRAL=(TLeaf*)chain1->GetLeaf("bin");
           Centrality=CENTRAL->GetValue();
           if (Centrality>19) continue;//dont need events over 60% centrality
           
           //Calo Tower Tree
           CaloHits= (TLeaf*) chain->GetLeaf("Calo_NumberOfHits");
           CaloEN= (TLeaf*) chain->GetLeaf("Et");
           CaloPhi= (TLeaf*) chain->GetLeaf("Phi");
           CaloEta= (TLeaf*) chain->GetLeaf("Eta");
           
           //Tracks Tree
           NumTracks= (TLeaf*) chain1->GetLeaf("nTracks");
           TrackMom= (TLeaf*) chain1->GetLeaf("pt");
           TrackPhi= (TLeaf*) chain1->GetLeaf("phi");
           TrackEta= (TLeaf*) chain1->GetLeaf("eta");
           
           //Zero the EP variables
            //First order combined HF         
           X_hf=0.;
           Y_hf=0.;
           EP_hf=0.;
            //First order positive hf
           X_hfp=0.;
           Y_hfp=0.;
           EP_hfp=0.;
           //First order negative hf
           X_hfn=0.;
           Y_hfn=0.;
           EP_hfn=0.;
           //Second order positive hf
           X_hf2p=0.;
           Y_hf2p=0.;
           EP_hf2p=0.;
           //Second order negative hf
           X_hf2n=0.;
           Y_hf2n=0.;
           EP_hf2n=0.;
           //Second order tracker
           X_tr2=0.;
           Y_tr2=0.;
           EP_tr2=0.;
		   //Loop over calo hits first
		   NumberOfHits=CaloHits->GetValue();
		   for (Int_t ii=0;ii<NumberOfHits;ii++)
		       {
		       Energy=0.;
		       phi=0.;
		       eta=0.;
		       Energy=CaloEN->GetValue(ii);
               phi=CaloPhi->GetValue(ii);
               eta=CaloEta->GetValue(ii);
		       if (Energy<0) continue;
		       if (eta>0)
		       {
		       //First Order Combined
		       X_hf+=TMath::Cos(phi)*Energy;
		       Y_hf+=TMath::Sin(phi)*Energy;
		       //First Order Positive HF
		       X_hfp+=TMath::Cos(phi)*Energy;
		       Y_hfp+=TMath::Sin(phi)*Energy;
		       //Second Order Positive HF
		       X_hf2p+=TMath::Cos(2.0*phi)*Energy;
		       Y_hf2p+=TMath::Sin(2.0*phi)*Energy;
		       }//end of positive eta gate
		       else if(eta<0)
		       {
		       //First Order Combined
		       X_hf+=TMath::Cos(phi)*(-1.0*Energy);
		       Y_hf+=TMath::Sin(phi)*(-1.0*Energy);
		       //First Order Negative HF
		       X_hfn+=TMath::Cos(phi)*(-1.0*Energy);
		       Y_hfn+=TMath::Sin(phi)*(-1.0*Energy);
		       //Second Order Negative HF
		       X_hf2n+=TMath::Cos(2.0*phi)*Energy;
		       Y_hf2n+=TMath::Sin(2.0*phi)*Energy;
		       }//end of negative eta gate
		       }//End of loop over calo hits
           
               //Now loop over tracks
                NumberOfHits=NumTracks->GetValue();
                 for (int ii=0;ii<NumberOfHits;ii++)
                           {
                             pT=0.;
                             phi=0.;
					          eta=0.;
					          pT=TrackMom->GetValue(ii);
					          phi=TrackPhi->GetValue(ii);
					          eta=TrackEta->GetValue(ii);
					           if(pT<0) continue;
					           else if(fabs(eta)<=1.0)
							   {
							   X_tr2+=TMath::Cos(2.0*phi)*pT;
							   Y_tr2+=TMath::Sin(2.0*phi)*pT;
							   }
                             }//end of loop over tracks

            /////////////////////////
			////Make Event Planes////
			/////////////////////////
			  //First order combined HF         
           EP_hf=(1./1.)*TMath::ATan2(Y_hf,X_hf);
		   if(EP_hf > pi) EP_hf=(EP_hf-(TMath::TwoPi()));
		   if(EP_hf < (-1.0*pi)) EP_hf=(EP_hf+(TMath::TwoPi()));
            //First order positive hf
             EP_hfp=(1./1.)*TMath::ATan2(Y_hfp,X_hfp);
		   if(EP_hfp > pi) EP_hfp=(EP_hfp-(TMath::TwoPi()));
		   if(EP_hfp < (-1.0*pi)) EP_hfp=(EP_hfp+(TMath::TwoPi()));
           //First order negative hf
             EP_hfn=(1./1.)*TMath::ATan2(Y_hfn,X_hfn);
		   if(EP_hfn > pi) EP_hfn=(EP_hfn-(TMath::TwoPi()));
		   if(EP_hfn < (-1.0*pi)) EP_hfn=(EP_hfn+(TMath::TwoPi()));
           //Second order positive hf
		   EP_hf2p=(1./2.)*TMath::ATan2(Y_hf2p,X_hf2p);
		   if(EP_hf2p > (pi/2)) EP_hf2p=(EP_hf2p-(pi));
		   if(EP_hf2p < (-1.0*(pi/2))) EP_hf2p=(EP_hf2p+(pi));
           //Second order negative hf
		   EP_hf2n=(1./2.)*TMath::ATan2(Y_hf2n,X_hf2n);
		   if(EP_hf2n > (pi/2)) EP_hf2n=(EP_hf2n-(pi));
		   if(EP_hf2n < (-1.0*(pi/2))) EP_hf2n=(EP_hf2n+(pi));
           //Second order tracker
	        EP_tr2=(1./2.)*TMath::ATan2(Y_tr2,X_tr2);
		   if(EP_tr2 > (pi/2)) EP_tr2=(EP_tr2-(pi));
		   if(EP_tr2 < (-1.0*(pi/2))) EP_tr2=(EP_tr2+(pi)); 

             
			 /////////////////////////////////
			 ///Store Info In AngCorr Plots///
		     /////////////////////////////////
			       for (Int_t c=0;c<nCent;c++)
                        {  
                         if ( (Centrality*2.5) > centhi[c] ) continue;
                         if ( (Centrality*2.5) < centlo[c] ) continue;
						 for (int k=1;k<(jMax+1);k++)
                             {
			                  //Combined HF
						      Coshf[c]->Fill(k-1,TMath::Cos(k*EP_hf));
                              Sinhf[c]->Fill(k-1,TMath::Sin(k*EP_hf));
                              //First Order Pos HF
                               Coshfp[c]->Fill(k-1,TMath::Cos(k*EP_hfp));
								Sinhfp[c]->Fill(k-1,TMath::Sin(k*EP_hfp));
								//First Order Neg HF
								Coshfn[c]->Fill(k-1,TMath::Cos(k*EP_hfn));
								Sinhfn[c]->Fill(k-1,TMath::Sin(k*EP_hfn));
								//Psi2 Pos HF
								Coshf2p[c]->Fill(k-1,TMath::Cos(k*2*EP_hf2p));
								Sinhf2p[c]->Fill(k-1,TMath::Sin(k*2*EP_hf2p));
								//Psi2 Neg HF
								Coshf2n[c]->Fill(k-1,TMath::Cos(k*2*EP_hf2n));
							    Sinhf2n[c]->Fill(k-1,TMath::Sin(k*2*EP_hf2n));
								//Psi2 Mid Tracker
								Costr2[c]->Fill(k-1,TMath::Cos(k*2*EP_tr2));
								Sintr2[c]->Fill(k-1,TMath::Sin(k*2*EP_tr2));
							}//End Of loop over K correction orders
						}//End of Loop over centrality classes
        }//End of loop over events

 }//end of Angular Corrections Function

+EOF
