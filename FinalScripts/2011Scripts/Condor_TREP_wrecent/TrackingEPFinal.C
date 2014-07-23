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
void FlowVectors();
void AngularCorrections();
void FlowAnalysis();
//void PrettyPlotting();
////////////////////////////


//Files and chains
TChain* chain;//= new TChain("CaloTowerTree");
TChain* chain2;//= new TChain("hiGoodTightMergedTracksTree");

//Calo Tower Tree
//chain->Add("/hadoop/store/user/jgomez2/ForwardTrees/2010/PanicTime/Forward*");
//Tracks Tree
//chain2->Add("/hadoop/store/user/jgomez2/ForwardTrees/2010/PanicTime/Forward*");


/////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////
////////////           GLOBAL VARIABLES            //////////////////
/////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////
Float_t pi=TMath::Pi();
Int_t vterm=1;//Set which order harmonic that this code is meant to measure
Int_t jMax=14;////Set out to which order correction we would like to apply
Int_t NumberOfEvents=0;
//NumberOfEvents=1;
//NumberOfEvents=2;
//NumberOfEvents=10;
//NumberOfEvents=100;
//NumberOfEvents=50000;
//NumberOfEvents=100000;
NumberOfEvents=1000000;
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
centlo[0]=0;  centhi[0]=30;
centlo[1]=10;  centhi[1]=20;
centlo[2]=10;  centhi[2]=60;
centlo[3]=30;  centhi[3]=40;
centlo[4]=30;  centhi[4]=60;

//Create the output ROOT file
TFile *myFile;// = new TFile("blah.root","RECREATE");
//TTree *myTree;

//PT Bin Centers
TProfile *PTCenters[nCent];

//EP Resolution Plots

//For Resolution of V1 Even
TProfile *TRPMinusTRM[nCent];
TProfile *TRMMinusTRC[nCent];
TProfile *TRPMinusTRC[nCent];


//Make Subdirectories for what will follow
TDirectory *myPlots;//the top level
TDirectory *epangles;//where i will store the ep angles

TDirectory *resolutions;//top level for resolutions
TDirectory *psioneres;//where i will store standard EP resolution plots
TDirectory *psioneevenres;//where i will store psi1(even)

TDirectory *v1plots;//where i will store the v1 plots
TDirectory *v1etaoddplots;//v1(eta) [odd] plots
TDirectory *v1etaevenplots; //v1(eta)[even] plots
TDirectory *v1ptevenplots; //v1(pT)[even] plots
TDirectory *v1ptoddplots;//v1(pT)[odd] plots

//Flow Vector Folders
TDirectory *flowvectors;
//Even EP
TDirectory *FirstOrderEvenEPs;
TDirectory *wholetrackerplots;
TDirectory *postrackerplots;
TDirectory *negtrackerplots;
TDirectory *midtrackerplots;

//Odd EP
TDirectory *FirstOrderOddEPs;
TDirectory *wholeoddtrackerplots;
TDirectory *posoddtrackerplots;
TDirectory *negoddtrackerplots;
TDirectory *midoddtrackerplots;

//Pt stats
TDirectory *ptstatplots;

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
TProfile *PtStatsWhole[nCent];//Both sides of the tracker
TProfile *PtStatsPos[nCent];//Positive eta tracker
TProfile *PtStatsNeg[nCent];//Negative eta tracker
TProfile *PtStatsMid[nCent];//Middle eta tracker
Float_t ptavwhole[nCent]={0.},pt2avwhole[nCent]={0.};
Float_t ptavpos[nCent]={0.},pt2avpos[nCent]={0.};
Float_t ptavneg[nCent]={0.},pt2avneg[nCent]={0.};
Float_t ptavmid[nCent]={0.},pt2avmid[nCent]={0.};

/////////////////////////
//The following variables are for the FlowVectors Function
/////////////////////////
//v1 odd vectors
TProfile *WholeOddTracker[nCent];
TProfile *PosOddTracker[nCent];
TProfile *NegOddTracker[nCent];
TProfile *MidOddTracker[nCent];
//v1even vectors
TProfile *WholeTracker[nCent];
TProfile *PosTracker[nCent];
TProfile *NegTracker[nCent];
TProfile *MidTracker[nCent];

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


//////////////////////////////////////
// The following variables and plots
// are for the AngularCorrections
// function
///////////////////////////////////////


///Looping Variables
//v1 even
Float_t Xcorr_wholetracker=0.,Ycorr_wholetracker=0.,EPwholetracker=0.,
  Xcorr_postracker=0.,Ycorr_postracker=0.,EPpostracker=0.,
  Xcorr_negtracker=0.,Ycorr_negtracker=0.,EPnegtracker=0.,
  Xcorr_midtracker=0.,Ycorr_midtracker=0.,EPmidtracker=0.;

//v1 odd
Float_t Xcorr_wholeoddtracker=0.,Ycorr_wholeoddtracker=0.,EPwholeoddtracker=0.,
  Xcorr_posoddtracker=0.,Ycorr_posoddtracker=0.,EPposoddtracker=0.,
  Xcorr_negoddtracker=0.,Ycorr_negoddtracker=0.,EPnegoddtracker=0.,
  Xcorr_midoddtracker=0.,Ycorr_midoddtracker=0.,EPmidoddtracker=0.;

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

//v1 even stuff
Float_t AngularCorrectionWholeTracker=0.,EPfinalwholetracker=0.,
  AngularCorrectionPosTracker=0.,EPfinalpostracker=0.,
  AngularCorrectionNegTracker=0.,EPfinalnegtracker=0.,
  AngularCorrectionMidTracker=0.,EPfinalmidtracker=0.,EPfinalsteveway=0.;


//v1 odd

Float_t AngularCorrectionWholeOddTracker=0.,EPfinalwholeoddtracker=0.,
  AngularCorrectionPosOddTracker=0.,EPfinalposoddtracker=0.,
  AngularCorrectionNegOddTracker=0.,EPfinalnegoddtracker=0.,
  AngularCorrectionMidOddTracker=0.,EPfinalmidoddtracker=0.;


/////////////////
///FLOW PLOTS////
////////////////
TProfile *V1EtaOdd[nCent];
TProfile *V1EtaEven[nCent];
TProfile *V1PtEven[nCent];
TProfile *V1PtOdd[nCent];

///////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////
/////////////////// END OF GLOBAL VARIABLES ///////////////////////
///////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////

//Running the Macro
Int_t TrackingEPFinal(){//put functions in here
  Initialize();
  PTStats();
  FlowVectors();
  AngularCorrections();
  FlowAnalysis();
  //PrettyPlotting();
  //Analyze();
  return 0;
}

void Initialize(){

  float eta_bin_small[13]={-0.6,-0.5,-0.4,-0.3,-0.2,-0.1,0.0,0.1,0.2,0.3,0.4,0.5,0.6};

  double pt_bin[17]={0.4,0.6,0.8,1.0,1.2,1.4,1.6,1.8,2.0,2.4,2.8,3.2,3.6,4.5,6.5,9.5,12};

  chain2= new TChain("hiGoodTightMergedTracksTree");

  //Tracks Tree
  chain2->Add("/hadoop/store/user/jgomez2/ForwardTrees/2010/PanicTime/Forward*");


  //Create the output ROOT file
  myFile = new TFile("TrackerEventPlaneAnalysis.root","recreate");

  //Make Subdirectories for what will follow
  myPlots = myFile->mkdir("Plots");
  myPlots->cd();

  //Directory for the EP angles
  epangles = myPlots->mkdir("EventPlanes");

  //Directory for Resolution Plots
  resolutions = myPlots->mkdir("EventPlaneResolutions");
  psioneevenres = resolutions->mkdir("PsiOneEvenResolution");


  //Directory For Final v1 plots
  v1plots = myPlots->mkdir("V1Results");
  v1etaoddplots = v1plots->mkdir("V1EtaOdd");
  v1etaevenplots = v1plots->mkdir("V1EtaEven");
  v1ptevenplots = v1plots->mkdir("V1pTEven");
  v1ptoddplots = v1plots->mkdir("V1pTOdd");
  //Make a Directory for the flow vectors
  flowvectors = myPlots->mkdir("FlowVectors");
  //Even EP
  FirstOrderEvenEPs = flowvectors->mkdir("FirstOrderEvenEPs");
  wholetrackerplots = FirstOrderEvenEPs->mkdir("WholeTracker");
  postrackerplots = FirstOrderEvenEPs->mkdir("PosTracker");
  negtrackerplots = FirstOrderEvenEPs->mkdir("NegTracker");
  midtrackerplots = FirstOrderEvenEPs->mkdir("MidTracker");
  //Odd EP
  FirstOrderOddEPs = flowvectors->mkdir("FirstOrderOddEPs");
  wholeoddtrackerplots = FirstOrderOddEPs->mkdir("WholeTracker");
  posoddtrackerplots = FirstOrderOddEPs->mkdir("PosTracker");
  negoddtrackerplots = FirstOrderOddEPs->mkdir("NegTracker");
  midoddtrackerplots = FirstOrderOddEPs->mkdir("MidTracker");
  //Pt stats
  ptstatplots = flowvectors->mkdir("PtStats");

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



  char ptcentname[128];
  char ptcenttitle[128];

  char res4name[128],res4title[128];
  char res5name[128],res5title[128];
  char res6name[128],res6title[128];

  char ptwholename[128];
  char ptwholetitle[128];

  char ptposname[128];
  char ptpostitle[128];

  char ptnegname[128];
  char ptnegtitle[128];

  char ptmidname[128];
  char ptmidtitle[128];

  //Vector Plots
  //v1 even
  char wholetrackername[128],wholetrackertitle[128];
  char postrackername[128],postrackertitle[128];
  char negtrackername[128],negtrackertitle[128];
  char midtrackername[128],midtrackertitle[128];

  //v1 odd
  char wholeoddtrackername[128],wholeoddtrackertitle[128];
  char posoddtrackername[128],posoddtrackertitle[128];
  char negoddtrackername[128],negoddtrackertitle[128];
  char midoddtrackername[128],midoddtrackertitle[128];

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

  //V1 Plots
  char v1etaoddname[128],v1etaoddtitle[128];
  char v1etaevenname[128],v1etaeventitle[128];
  char v1ptoddname[128],v1ptoddtitle[128];
  char v1ptevenname[128],v1pteventitle[128];

  for (int i=0;i<nCent;i++)
    {
      //V1 odd eta
      v1etaoddplots->cd();
      sprintf(v1etaoddname,"V1EtaOdd_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(v1etaoddtitle,"v_{1}^{odd}(#eta) for %1.0lf-%1.0lf %%",centlo[i],centhi[i]);
      V1EtaOdd[i]= new TProfile(v1etaoddname,v1etaoddtitle,12,eta_bin_small);

      //v1 even eta
      v1etaevenplots->cd();
      sprintf(v1etaevenname,"V1EtaEven_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(v1etaeventitle,"v_{1}^{even}(#eta) for %1.0lf-%1.0lf %%",centlo[i],centhi[i]);
      V1EtaEven[i]= new TProfile(v1etaevenname,v1etaeventitle,12,eta_bin_small);

      //v1 pt even
      v1ptevenplots->cd();
      sprintf(v1ptevenname,"V1PtEven_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(v1pteventitle,"v_{1}^{even}(p_{T}) for %1.0lf-%1.0lf %%",centlo[i],centhi[i]);
      V1PtEven[i]= new TProfile(v1ptevenname,v1pteventitle,16,pt_bin);


      //v1 pt odd
      v1ptoddplots->cd();
      sprintf(v1ptoddname,"V1PtOdd_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(v1ptoddtitle,"v_{1}^{odd}(p_{T}) for %1.0lf-%1.0lf %%",centlo[i],centhi[i]);
      V1PtOdd[i]= new TProfile(v1ptoddname,v1ptoddtitle,16,pt_bin);

      v1plots->cd();
      sprintf(ptcentname,"pTcenter_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(ptcenttitle,"Bin Center for %1.0lf-%1.0lf %%",centlo[i],centhi[i]);
      PTCenters[i]= new TProfile(ptcentname,ptcenttitle,16,pt_bin); //or can make a TH1f and fill a specific range

      //For Resolution of V1 Even
      psioneevenres->cd();
      sprintf(res4name,"TRPMinusTRM_EPResolution_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(res4title,"First Order EP resolution TRPMinusTRM %1.0lf-%1.0lf %%",centlo[i],centhi[i]);
      TRPMinusTRM[i]= new TProfile(res4name,res4title,1,0,1);

      sprintf(res5name,"TRMMinusTRC_EPResolution_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(res5title,"First Order EP resolution TRMMinusTRC %1.0lf-%1.0lf %%",centlo[i],centhi[i]);
      TRMMinusTRC[i]= new TProfile(res5name,res5title,1,0,1);

      sprintf(res6name,"TRPMinusTRC_EPResolution_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(res6title,"First Order EP resolution TRPMinusTRC %1.0lf-%1.0lf %%",centlo[i],centhi[i]);
      TRPMinusTRC[i]= new TProfile(res6name,res6title,1,0,1);


      //PT stats plots

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


      //////////////////////
      ////// X,Y Vectors////
      //////////////////////

      //v1 even
      //Whole Tracker
      wholetrackerplots->cd();
      sprintf(wholetrackername,"VecInfo_FirstOrderWholeTracker_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(wholetrackertitle,"VecInfo_WholeTracker_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      WholeTracker[i] = new TProfile(wholetrackername,wholetrackertitle,2,0,2);
      WholeTracker[i]->GetXaxis()->SetBinLabel(1,"<X>");
      WholeTracker[i]->GetXaxis()->SetBinLabel(1,"<Y>");

      //Pos Tracker
      postrackerplots->cd();
      sprintf(postrackername,"VecInfo_FirstOrderPosTracker_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(postrackertitle,"VecInfo_FirstOrderPosTracker_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      PosTracker[i] = new TProfile(postrackername,postrackertitle,2,0,2);
      PosTracker[i]->GetXaxis()->SetBinLabel(1,"<X>");
      PosTracker[i]->GetXaxis()->SetBinLabel(1,"<Y>");

      //Neg Tracker
      negtrackerplots->cd();
      sprintf(negtrackername,"VecInfo_FirstOrderNegTracker_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(negtrackertitle,"VecInfo_FirstOrderNegTracker_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      NegTracker[i] = new TProfile(negtrackername,negtrackertitle,2,0,2);
      NegTracker[i]->GetXaxis()->SetBinLabel(1,"<X>");
      NegTracker[i]->GetXaxis()->SetBinLabel(1,"<Y>");

      //MidTracker
      midtrackerplots->cd();
      sprintf(midtrackername,"VecInfo_FirstOrderMidTracker_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(midtrackertitle,"VecInfo_FirstOrderMidTracker_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      MidTracker[i] = new TProfile(midtrackername,midtrackertitle,2,0,2);
      MidTracker[i]->GetXaxis()->SetBinLabel(1,"<X>");
      MidTracker[i]->GetXaxis()->SetBinLabel(1,"<Y>");


      //v1 odd
      //Whole Tracker
      wholeoddtrackerplots->cd();
      sprintf(wholeoddtrackername,"VecInfo_FirstOrderWholeOddTracker_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(wholeoddtrackertitle,"VecInfo_WholeOddTracker_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      WholeOddTracker[i] = new TProfile(wholeoddtrackername,wholeoddtrackertitle,2,0,2);
      WholeOddTracker[i]->GetXaxis()->SetBinLabel(1,"<X>");
      WholeOddTracker[i]->GetXaxis()->SetBinLabel(1,"<Y>");

      //Pos Tracker
      posoddtrackerplots->cd();
      sprintf(posoddtrackername,"VecInfo_FirstOrderPosOddTracker_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(posoddtrackertitle,"VecInfo_FirstOrderPosOddTracker_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      PosOddTracker[i] = new TProfile(posoddtrackername,posoddtrackertitle,2,0,2);
      PosOddTracker[i]->GetXaxis()->SetBinLabel(1,"<X>");
      PosOddTracker[i]->GetXaxis()->SetBinLabel(1,"<Y>");

      //Neg Tracker
      negoddtrackerplots->cd();
      sprintf(negoddtrackername,"VecInfo_FirstOrderNegOddTracker_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(negoddtrackertitle,"VecInfo_FirstOrderNegOddTracker_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      NegOddTracker[i] = new TProfile(negoddtrackername,negoddtrackertitle,2,0,2);
      NegOddTracker[i]->GetXaxis()->SetBinLabel(1,"<X>");
      NegOddTracker[i]->GetXaxis()->SetBinLabel(1,"<Y>");

      //MidTracker
      midoddtrackerplots->cd();
      sprintf(midoddtrackername,"VecInfo_FirstOrderMidOddTracker_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(midoddtrackertitle,"VecInfo_FirstOrderMidOddTracker_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      MidOddTracker[i] = new TProfile(midoddtrackername,midoddtrackertitle,2,0,2);
      MidOddTracker[i]->GetXaxis()->SetBinLabel(1,"<X>");
      MidOddTracker[i]->GetXaxis()->SetBinLabel(1,"<Y>");
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

void PTStats(){
  for (int i=0;i<NumberOfEvents;i++)
    {
      if ( !(i%100000) ) cout << " 1st round, event # " << i << " / " << NumberOfEvents << endl;

      chain2->GetEntry(i);//grab the ith event

      //Grab the Track Leaves
      NumTracks= (TLeaf*) chain2->GetLeaf("nTracks");
      TrackMom= (TLeaf*) chain2->GetLeaf("pt");
      TrackPhi= (TLeaf*) chain2->GetLeaf("phi");
      TrackEta= (TLeaf*) chain2->GetLeaf("eta");

      //Grab the Centrality Leaves
      CENTRAL= (TLeaf*) chain2->GetLeaf("bin");
      Centrality= CENTRAL->GetValue();
      //std::cout<<Centrality<<std::endl;
      if (Centrality>23) continue; //we dont care about any centrality greater than 60%

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
              if ( (Centrality*2.5) > centhi[c] ) continue;
              if ( (Centrality*2.5) < centlo[c] ) continue;
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


  for (Int_t cent_iter=0;cent_iter<nCent;cent_iter++)
    {
      //Whole Tracker
      ptavwhole[cent_iter]=PtStatsWhole[cent_iter]->GetBinContent(1);
      pt2avwhole[cent_iter]=PtStatsWhole[cent_iter]->GetBinContent(2);

      //Positive Eta Tracker
      ptavpos[cent_iter]=PtStatsPos[cent_iter]->GetBinContent(1);
      pt2avpos[cent_iter]=PtStatsPos[cent_iter]->GetBinContent(2);

      //Negative Eta Tracker
      ptavneg[cent_iter]=PtStatsNeg[cent_iter]->GetBinContent(1);
      pt2avneg[cent_iter]=PtStatsNeg[cent_iter]->GetBinContent(2);

      //Mid-rapidity Tracker
      ptavmid[cent_iter]=PtStatsMid[cent_iter]->GetBinContent(1);
      pt2avmid[cent_iter]=PtStatsMid[cent_iter]->GetBinContent(2);
    }//end of loop over centralities

  //  myFile->Write();
  // delete myFile;
}//end of ptstats function

void FlowVectors(){
  for (Int_t i=0;i<NumberOfEvents;i++)
    {
      if ( !(i%100000) ) cout << " 2nd round, event # " << i << " / " << NumberOfEvents << endl;

      chain2->GetEntry(i);//grab the ith event

      //Grab the Track Leaves
      NumTracks= (TLeaf*) chain2->GetLeaf("nTracks");
      TrackMom= (TLeaf*) chain2->GetLeaf("pt");
      TrackPhi= (TLeaf*) chain2->GetLeaf("phi");
      TrackEta= (TLeaf*) chain2->GetLeaf("eta");

      //Grab the Centrality Leaves
      CENTRAL= (TLeaf*) chain2->GetLeaf("bin");
      Centrality= CENTRAL->GetValue();
      if (Centrality>23) continue; //we dont care about any centrality greater than 60%
      //std::cout<<Centrality<<std::endl;
      //Zero the Looping Variables
      //v1 even/odd
      for (int q=0;q<nCent;q++)
        {
          X_wholetracker[q]=0.;Y_wholetracker[q]=0.;
          X_postracker[q]=0.;Y_postracker[q]=0.;
          X_negtracker[q]=0.;Y_negtracker[q]=0.;
          X_midtracker[q]=0.;Y_midtracker[q]=0.;
          X_wholeoddtracker[q]=0.;Y_wholeoddtracker[q]=0.;
          X_posoddtracker[q]=0.;Y_posoddtracker[q]=0.;
          X_negoddtracker[q]=0.;Y_negoddtracker[q]=0.;
          X_midoddtracker[q]=0.;Y_midoddtracker[q]=0.;
        }

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
                  X_wholeoddtracker[c]+=cos(phi)*(pT);
                  Y_wholeoddtracker[c]+=sin(phi)*(pT);
                  X_posoddtracker[c]+=cos(phi)*(pT);
                  Y_posoddtracker[c]+=sin(phi)*(pT);
                }
              else if(eta<=-1.4)
                {
                  X_wholetracker[c]+=cos(phi)*(pT-(pt2avwhole[c]/ptavwhole[c]));
                  Y_wholetracker[c]+=sin(phi)*(pT-(pt2avwhole[c]/ptavwhole[c]));
                  X_negtracker[c]+=cos(phi)*(pT-(pt2avneg[c]/ptavneg[c]));
                  Y_negtracker[c]+=sin(phi)*(pT-(pt2avneg[c]/ptavneg[c]));
                  //v1 odd
                  X_wholeoddtracker[c]+=cos(phi)*(-1.0*(pT));
                  Y_wholeoddtracker[c]+=sin(phi)*(-1.0*(pT));
                  X_negoddtracker[c]+=cos(phi)*(-1.0*(pT));
                  Y_negoddtracker[c]+=sin(phi)*(-1.0*(pT));
                }
              else if(eta<=0.6 && eta>0)
                {
                  X_midtracker[c]+=cos(phi)*(pT-(pt2avmid[c]/ptavmid[c]));
                  Y_midtracker[c]+=sin(phi)*(pT-(pt2avmid[c]/ptavmid[c]));
                  //v1 odd
                  X_midoddtracker[c]+=cos(phi)*(pT);
                  Y_midoddtracker[c]+=sin(phi)*(pT);
                }
              else if(eta>=-0.6 && eta<0)
                {
                  X_midtracker[c]+=cos(phi)*(pT-(pt2avmid[c]/ptavmid[c]));
                  Y_midtracker[c]+=sin(phi)*(pT-(pt2avmid[c]/ptavmid[c]));
                  //v1 odd
                  X_midoddtracker[c]+=cos(phi)*(-1.0*(pT));
                  Y_midoddtracker[c]+=sin(phi)*(-1.0*(pT));
                }
            }//end of loop over centrality classes
        }//end of loop over tracks
      //Time to fill the appropriate histograms, this will be <X> <Y>
      for (Int_t c=0;c<nCent;c++)
        {
          if ( (Centrality*2.5) > centhi[c] ) continue;
          if ( (Centrality*2.5) < centlo[c] ) continue;

          //v1even vectors
          //whole tracker
          WholeTracker[c]->Fill(0,X_wholetracker[c]);
          WholeTracker[c]->Fill(1,Y_wholetracker[c]);

          //Pos Tracker
          PosTracker[c]->Fill(0,X_postracker[c]);
          PosTracker[c]->Fill(1,Y_postracker[c]);

          //Neg tracker
          // if(c==2) std::cout<<"The Xvector was "<<X_negtracker[c]<<std::endl;
          NegTracker[c]->Fill(0,X_negtracker[c]);
          NegTracker[c]->Fill(1,Y_negtracker[c]);

          //Mid Tracker
          MidTracker[c]->Fill(0,X_midtracker[c]);
          MidTracker[c]->Fill(1,Y_midtracker[c]);

          //v1 odd vectors
          WholeOddTracker[c]->Fill(0,X_wholeoddtracker[c]);
          WholeOddTracker[c]->Fill(1,Y_wholeoddtracker[c]);

          //Pos Tracker
          PosOddTracker[c]->Fill(0,X_posoddtracker[c]);
          PosOddTracker[c]->Fill(1,Y_posoddtracker[c]);

          //Neg tracker
          // if(c==2) std::cout<<"The Xvector was "<<X_negtracker[c]<<std::endl;
          NegOddTracker[c]->Fill(0,X_negoddtracker[c]);
          NegOddTracker[c]->Fill(1,Y_negoddtracker[c]);

          //Mid Tracker
          MidOddTracker[c]->Fill(0,X_midoddtracker[c]);
          MidOddTracker[c]->Fill(1,Y_midoddtracker[c]);

        }//end of loop over centrality clases
    }//end of loop over events

  ////////////////////////////////////////////
  //Extract the values and assign them to the global variables
  //////////////////////////////////////////////////
  for (int cc=0;cc<nCent;cc++)
    {
      ///////////////////
      //Vector Averages/
      ///////////////////

      //V1 even
      //Whole Tracker
      Xav_wholetracker[cc]= WholeTracker[cc]->GetBinContent(1);
      Xstdev_wholetracker[cc]= WholeTracker[cc]->GetBinError(1)*TMath::Sqrt(WholeTracker[cc]->GetBinEntries(1));
      Yav_wholetracker[cc]= WholeTracker[cc]->GetBinContent(2);
      Ystdev_wholetracker[cc]= WholeTracker[cc]->GetBinError(2)*TMath::Sqrt(WholeTracker[cc]->GetBinEntries(2));

      //Pos Tracker
      Xav_postracker[cc]= PosTracker[cc]->GetBinContent(1);
      Xstdev_postracker[cc]= PosTracker[cc]->GetBinError(1)*TMath::Sqrt(PosTracker[cc]->GetBinEntries(1));
      Yav_postracker[cc]= PosTracker[cc]->GetBinContent(2);
      Ystdev_postracker[cc]= PosTracker[cc]->GetBinError(2)*TMath::Sqrt(PosTracker[cc]->GetBinEntries(2));

      //Neg Tracker
      Xav_negtracker[cc]= NegTracker[cc]->GetBinContent(1);
      Xstdev_negtracker[cc]= NegTracker[cc]->GetBinError(1)*TMath::Sqrt(NegTracker[cc]->GetBinEntries(1));
      Yav_negtracker[cc]= NegTracker[cc]->GetBinContent(2);
      Ystdev_negtracker[cc]= NegTracker[cc]->GetBinError(2)*TMath::Sqrt(NegTracker[cc]->GetBinEntries(2));

      //Mid Tracker
      Xav_midtracker[cc]= MidTracker[cc]->GetBinContent(1);
      Xstdev_midtracker[cc]= MidTracker[cc]->GetBinError(1)*TMath::Sqrt(MidTracker[cc]->GetBinEntries(1));
      Yav_midtracker[cc]= MidTracker[cc]->GetBinContent(2);
      Ystdev_midtracker[cc]= MidTracker[cc]->GetBinError(2)*TMath::Sqrt(MidTracker[cc]->GetBinEntries(2));

      //V1 odd
      //Whole Tracker
      Xav_wholeoddtracker[cc]= WholeOddTracker[cc]->GetBinContent(1);
      Xstdev_wholeoddtracker[cc]= WholeOddTracker[cc]->GetBinError(1)*TMath::Sqrt(WholeOddTracker[cc]->GetBinEntries(1));
      Yav_wholeoddtracker[cc]= WholeOddTracker[cc]->GetBinContent(2);
      Ystdev_wholetracker[cc]= WholeOddTracker[cc]->GetBinError(2)*TMath::Sqrt(WholeOddTracker[cc]->GetBinEntries(2));

      //Pos Tracker
      Xav_posoddtracker[cc]= PosOddTracker[cc]->GetBinContent(1);
      Xstdev_posoddtracker[cc]= PosOddTracker[cc]->GetBinError(1)*TMath::Sqrt(PosOddTracker[cc]->GetBinEntries(1));
      Yav_posoddtracker[cc]= PosOddTracker[cc]->GetBinContent(2);
      Ystdev_posoddtracker[cc]= PosOddTracker[cc]->GetBinError(2)*TMath::Sqrt(PosOddTracker[cc]->GetBinEntries(2));

      //Neg Tracker
      Xav_negoddtracker[cc]= NegOddTracker[cc]->GetBinContent(1);
      Xstdev_negoddtracker[cc]= NegOddTracker[cc]->GetBinError(1)*TMath::Sqrt(NegOddTracker[cc]->GetBinEntries(1));
      Yav_negoddtracker[cc]= NegOddTracker[cc]->GetBinContent(2);
      Ystdev_negoddtracker[cc]= NegOddTracker[cc]->GetBinError(2)*TMath::Sqrt(NegOddTracker[cc]->GetBinEntries(2));

      //Mid Tracker
      Xav_midoddtracker[cc]= MidOddTracker[cc]->GetBinContent(1);
      Xstdev_midoddtracker[cc]= MidOddTracker[cc]->GetBinError(1)*TMath::Sqrt(MidOddTracker[cc]->GetBinEntries(1));
      Yav_midoddtracker[cc]= MidOddTracker[cc]->GetBinContent(2);
      Ystdev_midoddtracker[cc]= MidOddTracker[cc]->GetBinError(2)*TMath::Sqrt(MidOddTracker[cc]->GetBinEntries(2));

    }//end of loop over centrality classes
}//end of flow vectors function

void AngularCorrections(){

  for (Int_t i=0;i<NumberOfEvents;i++)
    {
      if ( !(i%100000) ) cout << " 3rd round, event # " << i << " / " << NumberOfEvents << endl;

      chain2->GetEntry(i);//grab the ith event

      //Grab the Track Leaves
      NumTracks= (TLeaf*) chain2->GetLeaf("nTracks");
      TrackMom= (TLeaf*) chain2->GetLeaf("pt");
      TrackPhi= (TLeaf*) chain2->GetLeaf("phi");
      TrackEta= (TLeaf*) chain2->GetLeaf("eta");

      //Grab the Centrality Leaves
      CENTRAL= (TLeaf*) chain2->GetLeaf("bin");
      Centrality= CENTRAL->GetValue();
      if (Centrality>23) continue; //we dont care about any centrality greater than 60%

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
                  X_wholeoddtracker[c]+=cos(phi)*(pT);
                  Y_wholeoddtracker[c]+=sin(phi)*(pT);
                  X_posoddtracker[c]+=cos(phi)*(pT);
                  Y_posoddtracker[c]+=sin(phi)*(pT);
                }
              else if(eta<=-1.4)
                {
                  X_wholetracker[c]+=cos(phi)*(pT-(pt2avwhole[c]/ptavwhole[c]));
                  Y_wholetracker[c]+=sin(phi)*(pT-(pt2avwhole[c]/ptavwhole[c]));
                  X_negtracker[c]+=cos(phi)*(pT-(pt2avneg[c]/ptavneg[c]));
                  Y_negtracker[c]+=sin(phi)*(pT-(pt2avneg[c]/ptavneg[c]));
                  //v1 odd
                  X_wholeoddtracker[c]+=cos(phi)*(-1.0*(pT));
                  Y_wholeoddtracker[c]+=sin(phi)*(-1.0*(pT));
                  X_negoddtracker[c]+=cos(phi)*(-1.0*(pT));
                  Y_negoddtracker[c]+=sin(phi)*(-1.0*(pT));
                }
              else if(eta<=0.6 && eta>0)
                {
                  X_midtracker[c]+=cos(phi)*(pT-(pt2avmid[c]/ptavmid[c]));
                  Y_midtracker[c]+=sin(phi)*(pT-(pt2avmid[c]/ptavmid[c]));
                  //v1 odd
                  X_midoddtracker[c]+=cos(phi)*(pT);
                  Y_midoddtracker[c]+=sin(phi)*(pT);
                }
              else if(eta>=-0.6 && eta<0)
                {
                  X_midtracker[c]+=cos(phi)*(pT-(pt2avmid[c]/ptavmid[c]));
                  Y_midtracker[c]+=sin(phi)*(pT-(pt2avmid[c]/ptavmid[c]));
                  //v1 odd
                  X_midoddtracker[c]+=cos(phi)*(-1.0*(pT));
                  Y_midoddtracker[c]+=sin(phi)*(-1.0*(pT));
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


void FlowAnalysis(){
  for (Int_t i=0;i<NumberOfEvents;i++)
    {
      if ( !(i%10000) ) cout << " 4th round, event # " << i << " / " << NumberOfEvents << endl;

      chain2->GetEntry(i);//grab the ith event

      //Grab the Track Leaves
      NumTracks= (TLeaf*) chain2->GetLeaf("nTracks");
      TrackMom= (TLeaf*) chain2->GetLeaf("pt");
      TrackPhi= (TLeaf*) chain2->GetLeaf("phi");
      TrackEta= (TLeaf*) chain2->GetLeaf("eta");

      //Grab the Centrality Leaves
      CENTRAL= (TLeaf*) chain2->GetLeaf("bin");
      Centrality= CENTRAL->GetValue();
      if (Centrality>23) continue; //we dont care about any centrality greater than 60%


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

          //v1 odd
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
                  X_wholeoddtracker[c]+=cos(phi)*(pT);
                  Y_wholeoddtracker[c]+=sin(phi)*(pT);
                  X_posoddtracker[c]+=cos(phi)*(pT);
                  Y_posoddtracker[c]+=sin(phi)*(pT);
                }
              else if(eta<=-1.4)
                {
                  X_wholetracker[c]+=cos(phi)*(pT-(pt2avwhole[c]/ptavwhole[c]));
                  Y_wholetracker[c]+=sin(phi)*(pT-(pt2avwhole[c]/ptavwhole[c]));
                  X_negtracker[c]+=cos(phi)*(pT-(pt2avneg[c]/ptavneg[c]));
                  Y_negtracker[c]+=sin(phi)*(pT-(pt2avneg[c]/ptavneg[c]));
                  //v1 odd
                  X_wholeoddtracker[c]+=cos(phi)*(-1.0*(pT));
                  Y_wholeoddtracker[c]+=sin(phi)*(-1.0*(pT));
                  X_negoddtracker[c]+=cos(phi)*(-1.0*(pT));
                  Y_negoddtracker[c]+=sin(phi)*(-1.0*(pT));
                }
              else if(eta<=0.6 && eta>0)
                {
                  X_midtracker[c]+=cos(phi)*(pT-(pt2avmid[c]/ptavmid[c]));
                  Y_midtracker[c]+=sin(phi)*(pT-(pt2avmid[c]/ptavmid[c]));
                  //v1 odd
                  X_midoddtracker[c]+=cos(phi)*(pT);
                  Y_midoddtracker[c]+=sin(phi)*(pT);
                }
              else if(eta>=-0.6 && eta<0)
                {
                  X_midtracker[c]+=cos(phi)*(pT-(pt2avmid[c]/ptavmid[c]));
                  Y_midtracker[c]+=sin(phi)*(pT-(pt2avmid[c]/ptavmid[c]));
                  //v1 odd
                  X_midoddtracker[c]+=cos(phi)*(-1.0*(pT));
                  Y_midoddtracker[c]+=sin(phi)*(-1.0*(pT));
                }
            }//end of loop over centrality classes
        }//end of loop over tracks


      //Time to fill the appropriate histograms, this will be <X> <Y>
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
          if (EPnegtracker>(pi)) EPnegtracker=(EPnegtracker-(TMath::TwoPi()));
          if (EPnegtracker<(-1.0*(pi))) EPnegtracker=(EPnegtracker+(TMath::TwoPi()));

          //mid Tracker
          Xcorr_midtracker=(X_midtracker[c]-Xav_midtracker[c])/Xstdev_midtracker[c];
          Ycorr_midtracker=(Y_midtracker[c]-Yav_midtracker[c])/Ystdev_midtracker[c];
          EPmidtracker=(1./1.)*atan2(Ycorr_midtracker,Xcorr_midtracker);
          if (EPmidtracker>(pi)) EPmidtracker=(EPmidtracker-(TMath::TwoPi()));
          if (EPmidtracker<(-1.0*(pi))) EPmidtracker=(EPmidtracker+(TMath::TwoPi()));


          //V1 odd
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
          if (EPnegoddtracker>(pi)) EPnegoddtracker=(EPnegoddtracker-(TMath::TwoPi()));
          if (EPnegoddtracker<(-1.0*(pi))) EPnegoddtracker=(EPnegoddtracker+(TMath::TwoPi()));

          //mid Tracker
          Xcorr_midoddtracker=(X_midoddtracker[c]-Xav_midoddtracker[c])/Xstdev_midoddtracker[c];
          Ycorr_midoddtracker=(Y_midoddtracker[c]-Yav_midoddtracker[c])/Ystdev_midoddtracker[c];
          EPmidoddtracker=(1./1.)*atan2(Ycorr_midoddtracker,Xcorr_midoddtracker);
          if (EPmidoddtracker>(pi)) EPmidoddtracker=(EPmidoddtracker-(TMath::TwoPi()));
          if (EPmidoddtracker<(-1.0*(pi))) EPmidoddtracker=(EPmidoddtracker+(TMath::TwoPi()));


          //Zero the angular correction variables

          //v1 even stuff
          AngularCorrectionWholeTracker=0.;EPfinalwholetracker=0.;
          AngularCorrectionPosTracker=0.;EPfinalpostracker=0.;
          AngularCorrectionNegTracker=0.;EPfinalnegtracker=0.;
          AngularCorrectionMidTracker=0.;EPfinalmidtracker=0.;

          //v1 odd stuff
          AngularCorrectionWholeOddTracker=0.;EPfinalwholeoddtracker=0.;
          AngularCorrectionPosOddTracker=0.;EPfinalposoddtracker=0.;
          AngularCorrectionNegOddTracker=0.;EPfinalnegoddtracker=0.;
          AngularCorrectionMidOddTracker=0.;EPfinalmidoddtracker=0.;

          //Compute Angular Corrections
          for (Int_t k=1;k<(jMax+1);k++)
            {
              //v1 even
              //Whole Tracker
              AngularCorrectionWholeTracker+=((2./k)*(((-Sinwholetracker[c]->GetBinContent(k))*(cos(k*EPwholetracker)))+((Coswholetracker[c]->GetBinContent(k))*(sin(k*EPwholetracker)))));

              //Pos Tracker
              AngularCorrectionPosTracker+=((2./k)*(((-Sinpostracker[c]->GetBinContent(k))*(cos(k*EPpostracker)))+((Cospostracker[c]->GetBinContent(k))*(sin(k*EPpostracker)))));


              //Neg Tracker
              AngularCorrectionNegTracker+=((2./k)*(((-Sinnegtracker[c]->GetBinContent(k))*(cos(k*EPnegtracker)))+((Cosnegtracker[c]->GetBinContent(k))*(sin(k*EPnegtracker)))));

              //Mid Tracker
              AngularCorrectionMidTracker+=((2./k)*(((-Sinmidtracker[c]->GetBinContent(k))*(cos(k*EPmidtracker)))+((Cosmidtracker[c]->GetBinContent(k))*(sin(k*EPmidtracker)))));

              //v1 odd
              //Whole Tracker
              AngularCorrectionWholeOddTracker+=((2./k)*(((-Sinwholeoddtracker[c]->GetBinContent(k))*(cos(k*EPwholeoddtracker)))+((Coswholeoddtracker[c]->GetBinContent(k))*(sin(k*EPwholeoddtracker)))));

              //Pos Tracker
              AngularCorrectionPosOddTracker+=((2./k)*(((-Sinposoddtracker[c]->GetBinContent(k))*(cos(k*EPposoddtracker)))+((Cosposoddtracker[c]->GetBinContent(k))*(sin(k*EPposoddtracker)))));


              //Neg Tracker
              AngularCorrectionNegOddTracker+=((2./k)*(((-Sinnegoddtracker[c]->GetBinContent(k))*(cos(k*EPnegoddtracker)))+((Cosnegoddtracker[c]->GetBinContent(k))*(sin(k*EPnegoddtracker)))));

              //Mid Tracker
              AngularCorrectionMidOddTracker+=((2./k)*(((-Sinmidoddtracker[c]->GetBinContent(k))*(cos(k*EPmidoddtracker)))+((Cosmidoddtracker[c]->GetBinContent(k))*(sin(k*EPmidoddtracker)))));


            }//end of angular correction calculation


          //Add the final Corrections to the Event Plane
          //and store it and do the flow measurement with it


          //Tracker

          //v1 even
          //Whole Tracker
          EPfinalwholetracker=EPwholetracker+AngularCorrectionWholeTracker;
          if (EPfinalwholetracker>(pi)) EPfinalwholetracker=(EPfinalwholetracker-(TMath::TwoPi()));
          if (EPfinalwholetracker<(-1.0*(pi))) EPfinalwholetracker=(EPfinalwholetracker+(TMath::TwoPi()));

          //Pos Tracker
          EPfinalpostracker=EPpostracker+AngularCorrectionPosTracker;
          if (EPfinalpostracker>(pi)) EPfinalpostracker=(EPfinalpostracker-(TMath::TwoPi()));
          if (EPfinalpostracker<(-1.0*(pi))) EPfinalpostracker=(EPfinalpostracker+(TMath::TwoPi()));

          //Neg Tracker
          EPfinalnegtracker=EPnegtracker+AngularCorrectionNegTracker;
          //if(c==2) std::cout<<EPfinalnegtracker<<std::endl;
          if (EPfinalnegtracker>(pi)) EPfinalnegtracker=(EPfinalnegtracker-(TMath::TwoPi()));
          if (EPfinalnegtracker<(-1.0*(pi))) EPfinalnegtracker=(EPfinalnegtracker+(TMath::TwoPi()));

          //Mid Tracker
          EPfinalmidtracker=EPmidtracker+AngularCorrectionMidTracker;
          if (EPfinalmidtracker>(pi)) EPfinalmidtracker=(EPfinalmidtracker-(TMath::TwoPi()));
          if (EPfinalmidtracker<(-1.0*(pi))) EPfinalmidtracker=(EPfinalmidtracker+(TMath::TwoPi()));


          //v1 odd
          //Whole Tracker
          EPfinalwholeoddtracker=EPwholeoddtracker+AngularCorrectionWholeOddTracker;
          if (EPfinalwholeoddtracker>(pi)) EPfinalwholeoddtracker=(EPfinalwholeoddtracker-(TMath::TwoPi()));
          if (EPfinalwholeoddtracker<(-1.0*(pi))) EPfinalwholeoddtracker=(EPfinalwholeoddtracker+(TMath::TwoPi()));

          //Pos Tracker
          EPfinalposoddtracker=EPposoddtracker+AngularCorrectionPosOddTracker;
          if (EPfinalposoddtracker>(pi)) EPfinalposoddtracker=(EPfinalposoddtracker-(TMath::TwoPi()));
          if (EPfinalposoddtracker<(-1.0*(pi))) EPfinalposoddtracker=(EPfinalposoddtracker+(TMath::TwoPi()));

          //Neg Tracker
          EPfinalnegoddtracker=EPnegoddtracker+AngularCorrectionNegOddTracker;
          //if(c==2) std::cout<<EPfinalnegtracker<<std::endl;
          if (EPfinalnegoddtracker>(pi)) EPfinalnegoddtracker=(EPfinalnegoddtracker-(TMath::TwoPi()));
          if (EPfinalnegoddtracker<(-1.0*(pi))) EPfinalnegoddtracker=(EPfinalnegoddtracker+(TMath::TwoPi()));

          //Mid Tracker
          EPfinalmidoddtracker=EPmidoddtracker+AngularCorrectionMidOddTracker;
          if (EPfinalmidoddtracker>(pi)) EPfinalmidoddtracker=(EPfinalmidoddtracker-(TMath::TwoPi()));
          if (EPfinalmidoddtracker<(-1.0*(pi))) EPfinalmidoddtracker=(EPfinalmidoddtracker+(TMath::TwoPi()));



          //Resolutions
          //Even v1
          TRPMinusTRM[c]->Fill(0,cos(EPfinalpostracker-EPfinalnegtracker));
          TRMMinusTRC[c]->Fill(0,cos(EPfinalnegtracker-EPfinalmidtracker));
          TRPMinusTRC[c]->Fill(0,cos(EPfinalpostracker-EPfinalmidtracker));


          //Loop again over tracks to find the flow
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
              //              std::cout<<pT<<" "<<eta<<" "<<phi<<std::endl;
              if(fabs(eta)<0.6)
                {
                  V1EtaOdd[c]->Fill(eta,cos(phi-EPfinalwholeoddtracker));
                  V1EtaEven[c]->Fill(eta,cos(phi-EPfinalwholetracker));
                  V1PtOdd[c]->Fill(pT,cos(phi-EPfinalwholeoddtracker));
                  PTCenters[c]->Fill(pT,pT);
                  V1PtEven[c]->Fill(pT,cos(phi-EPfinalwholetracker));
                }
            }//end of loop over tracks
          //    }
        }//End of loop over centralities
    }//End of loop over events
  myFile->Write();
  // delete myFile;
}//End of Flow Analysis Function

