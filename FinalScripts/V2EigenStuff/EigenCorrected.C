#include "TMatrixD.h"
#include "TMatrixDEigen.h"
#include "TProfile.h"
#include "TProfile2D.h"
#include "TComplex.h"
#include "TVectorD.h"


//Functions that will be used
void Initialize();
void MatrixValues();
void EigenValues();

///////////////////////////////


Double_t eta_bin[13]={-0.6,-0.5,-0.4,-0.3,-0.2,-0.1,0.0,0.1,0.2,0.3,0.4,0.5,0.6};
Double_t eta_center[12]={-0.55,-0.45,-0.35,-0.25,-0.15,-0.05,0.05,0.15,0.25,0.35,0.45,0.55};
Double_t eta_lo[12];
Double_t eta_hi[12];
eta_lo[0]=-0.6; eta_hi[0]=-0.5;
eta_lo[1]=-0.5;eta_hi[1]=-0.4;
eta_lo[2]=-0.4;eta_hi[2]=-0.3;
eta_lo[3]=-0.3;eta_hi[3]=-0.2;
eta_lo[4]=-0.2;eta_hi[4]=-0.1;
eta_lo[5]=-0.1;eta_hi[5]=0.0;
eta_lo[6]=0.0;eta_hi[6]=0.1;
eta_lo[7]=0.1;eta_hi[7]=0.2;
eta_lo[8]=0.2;eta_hi[8]=0.3;
eta_lo[9]=0.3;eta_hi[9]=0.4;
eta_lo[10]=0.4;eta_hi[10]=0.5;
eta_lo[11]=0.5;eta_hi[11]=0.6;



Double_t pi=TMath::Pi();
Int_t nthharmonic=2;
Int_t N[12];
TComplex filler=0;
TComplex Qn[12];
TComplex Qhat[12];
TComplex Qstarhat[12];
TComplex calc=0;
Int_t Centrality=0;
TMatrixD Cnn(12,12);
Cnn.Zero();
//TVectorD eigenvalues;
//TMatrixD eigenvec;
Int_t NumberOfHits=0;
Float_t pT=0.;
Float_t phi=0.;
Float_t eta=0.;
Int_t NumberOfEvents=0;
//NumberOfEvents=10;
//NumberOfEvents=100;
//NumberOfEvents=10000;
NumberOfEvents=2000000;
TChain* chain2;

//TProfile to find average number of particles per bin
TProfile *AverageMultiplicity;

//TProfile2D to store Matrix Values
TProfile2D *MatrixElements;

////////////////////////////
/////   MAIN //////////////
////////////////////////////
Int_t EigenCorrected(){
  Initialize();
  MatrixValues();
  EigenValues();
  return 0;
}

void Initialize(){
  for (Int_t i=0;i<12;i++)  {
    N[i]=0;
    Qn[i]=TComplex(0.);
    Qhat[i]=TComplex(0.);
    Qstarhat[i]=TComplex(0.);
  }
  chain2 = new TChain("hiGoodTightMergedTracksTree");
  //  chain2->Add("Forward*.root");
  chain2->Add("/hadoop/store/user/jgomez2/ForwardTrees/2010/PanicTime/Forward*");

  //TProfile to find average number of particles per bin
  AverageMultiplicity = new TProfile("Nbar","<N>",12,eta_bin);

  //TProfile2D to store Matrix Values
  MatrixElements = new TProfile2D("CKK","C_{kk}",12,eta_bin,12,eta_bin);

}

void MatrixValues(){

  for (Int_t i=0;i<NumberOfEvents;i++)
    {
      if ( !(i%10000) ) cout << " 1st round, event # " << i << " / " << NumberOfEvents << endl;

      chain2->GetEntry(i);

      //Grab the Track Leaves
      NumTracks= (TLeaf*) chain2->GetLeaf("nTracks");
      TrackMom= (TLeaf*) chain2->GetLeaf("pt");
      TrackPhi= (TLeaf*) chain2->GetLeaf("phi");
      TrackEta= (TLeaf*) chain2->GetLeaf("eta");

      //Grab the Centrality Leaves
      CENTRAL= (TLeaf*) chain2->GetLeaf("bin");
      Centrality=0;
      Centrality=CENTRAL->GetValue();
      if (Centrality<8 || Centrality>11) continue;


      //Zero the multiplicity
      for (Int_t zeroer=0;zeroer<12;zeroer++)
        {
          N[zeroer]=0;
          Qn[zeroer]=TComplex(0.);
        }

      NumberOfHits=NumTracks->GetValue();
      for (Int_t track_iter=0;track_iter<NumberOfHits;track_iter++)
        {
          pT=0.;
          phi=0.;
          eta=0.;
          pT=TrackMom->GetValue(track_iter);
          phi=TrackPhi->GetValue(track_iter);
          eta=TrackEta->GetValue(track_iter);
	  if(fabs(eta)>0.6) continue;

	  for(Int_t bin_iter=0;bin_iter<12;bin_iter++) {
	    if((eta<eta_hi[bin_iter]) && (eta>eta_lo[bin_iter]))
	      {
	    	N[bin_iter]+=1;
	    	Qn[bin_iter]+=TComplex::Exp(TComplex::I()*nthharmonic*phi);
		Qhat[bin_iter]+=TComplex::Exp(TComplex::I()*nthharmonic*phi);
		Qstarhat[bin_iter]+=TComplex::Exp(-TComplex::I()*nthharmonic*phi);
	      }//if it falls in the eta bin
	  }
        }//end of loop over tracks

      //Fill Multiplicity Plot
      for (Int_t bin_iter=0;bin_iter<12;bin_iter++)
        {
          AverageMultiplicity->Fill(eta_center[bin_iter],N[bin_iter]);
        }//end of Filling Multiplicity Plots


      for (Int_t row_iter=0;row_iter<12;row_iter++)
	{
	  for (Int_t col_iter=0;col_iter<12;col_iter++)
	    {
	      filler=TComplex(0.);
	      filler=Qn[row_iter]*TComplex::Conjugate(Qn[col_iter]);
	      if(row_iter!=col_iter)
		{
		  MatrixElements->Fill(eta_center[row_iter],eta_center[col_iter],filler.Re());
//MatrixElements->Fill(eta_center[row_iter],eta_center[col_iter],N[row_iter]);
		}//off diagonal terms
	      else if(row_iter==col_iter)
		{
//MatrixElements->Fill(eta_center[row_iter],eta_center[col_iter],N[row_iter]);
//MatrixElements->Fill(eta_center[row_iter],eta_center[col_iter],filler.Re());
		  MatrixElements->Fill(eta_center[row_iter],eta_center[col_iter],(filler.Re()-N[row_iter]));
		}//diagonal terms
	    }//end of loop over columns
	}//end of loop over rows
      
    }//end of loop over events

}//end of MatrixValues Function

void EigenValues(){

  //Actually fill the matrix
  for (Int_t row_iter=0;row_iter<12;row_iter++)
    {
      calc=TComplex(0.);
      calc= (Qhat[row_iter]/NumberOfEvents)*(Qstarhat[row_iter]/NumberOfEvents);
      for (Int_t col_iter=0;col_iter<12;col_iter++)
	{
	  Cnn[row_iter][col_iter]=(MatrixElements->GetBinContent(MatrixElements->FindBin(eta_center[row_iter],eta_center[col_iter])))-calc.Re();
	}//end of loop over columns
    }//end of loop over rows

  //Find EigenValues of the Matrix
  TMatrixDEigen me(Cnn);
  TVectorD eigenvalues=me.GetEigenValues();
  TMatrixD eigenvec=me.GetEigenVectors();
  
  std::cout<<"EigenValues are "<<std::endl;
  eigenvalues.Print();

  std::cout<<" "<<std::endl;
  std::cout<<"EigenVectors are "<<std::endl;
  eigenvec.Print();

}//End of EigenValues Function
