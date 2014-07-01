//
//
//  This code reads in vnn(pT, pT) 2D histogram. fit pT factorization function
//
//
//
//


#include <TF1.h>
#include <TF2.h>
#include <TH1.h>
#include <TH2.h>
#include <TFile.h>
#include <TStyle.h>
#include <TGraphErrors.h>
#include <TMultiGraph.h>
#include <TLegend.h>
#include <TLatex.h>
#include <TCanvas.h>
#include <TLine.h>
#include <TVirtualFitter.h>
#include <TProfile2D.h>
#include <TMath.h>
#include <TLegend.h>
#include <TLine.h>


#include <iomanip>


int FitType = 4; //.. 0 - only v2, 1 - v2+non-low, 2 - v2 - non-flow, 3 vn + non-flow - nonflow, 4 v1*v1 + c*pt1*pt2, it will be reassigned in main function parameter

int HistType = 0;//.. 0 - All-All pT range, 1 - No-(low-low) pT range, 2 - High-High pT range

int Nparams=16;//18;//15;//9;//14;
int pTmin=0;

/*const int pTbins = 16;//19;//16;//10;//15;
  float pT[pTbins] =
  {0.15,0.2,0.4,0.6,0.8,1.0,1.2,1.4,1.6,1.8,2.0,2.4,2.8,3.2,3.6,4.5};   // 16

  const int NoCent = 9;
  float pTcenter[NoCent][pTbins-1] = {{0.17,0.302,0.49,0.689,0.890,1.09,1.291,1.491,1.691,1.892,2.168,2.571,2.974,3.372,3.941}};
*/

const int pTbins=17;
Double_t pT[pTbins]={0.4,0.6,0.8,1.0,1.2,1.4,1.6,1.8,2.0,2.4,2.8,3.2,3.6,4.5,6.5,9.5,12};
const int NoCent=1;
Double_t pTcenter[NoCent][pTbins-1] = {0.5,0.7,0.9,1.1,1.3,1.5,1.7,1.9,2.2,2.6,3.0,3.4,3.7,5.5,8.0,10.75};





const int nFitPlot = Nparams+1; // pT = ref and points on the diagonal as the [0]

Double_t v_nn_fun(Double_t *x, Double_t *par){



  int binRef , binInt;

  binRef = (int)x[0];
  binInt = (int)x[1];
  if(HistType == 2) {binRef = (int) (x[0]-pTmin); binInt = (int)(x[1]-pTmin); }
  if(binRef <0 || binInt <0) return 0;



  //.. Parameters [0-Nparams-1] - vn,[Nparams -2*Nparams-1]- vn'
  //.. [2*Nparams -3*2*Nparams-1] - delta_n,[3*2*Nparams -3*Nparams-1]- delta n'

  int iVn = binInt;
  int iVnRef = binRef;
  int iDeltan = Nparams+binInt;
  int iDeltanRef = Nparams+binRef;
  int iDeltanNeg = 2*Nparams+binInt;
  int iDeltanRefNeg = 2*Nparams+binRef;


  if(FitType==0) return par[iVn]*par[iVnRef];
  else if(FitType==1) return  par[iVn]*par[iVnRef] + par[iDeltan]*par[iDeltanRef];
  else if(FitType==2) return  par[iVn]*par[iVnRef] - par[iDeltan]*par[iDeltanRef];
  else if(FitType==3) return par[iVn]*par[iVnRef] + par[iDeltan]*par[iDeltanRef] - par[iDeltanNeg]*par[iDeltanRefNeg];
  else if(FitType==4) return par[iVn]*par[iVnRef] - par[Nparams]*(pT[(int)x[0]]+pT[(int)x[0]+1])/2.*(pT[(int)x[1]]+pT[(int)x[1]+1])/2.;     // v1(pt1)*v1(pt2) - c*pt1*pt2
  else return 0;

}


void fitNonFlowRealData( int centralityClass = 0, int dEtaGap = 0,  int whatToFit = 4, int whathist = 0, int vn = 1, char *dEtaGapname = "-1<#eta<-0.35, 0.35 <#eta'<1, |#Delta#eta| > 0.7",  const char* inFileName = "TwoParticleCorrelation_1to100_corrected.root", const char* dir = ""){


  for(int i = 1; i<NoCent ; i++) {
    for(int j = 0; j<pTbins-1; j++) {
      pTcenter[i][j] = pTcenter[0][j];
    }
  }
  cout<<"reading file "<<inFileName<<endl;

  if(whathist == 2) Nparams = 8;

  FitType = whatToFit;
  HistType = whathist;


  gStyle->SetPalette(1, 0);

  pTmin = 5;
  if(HistType == 0) pTmin = 0;
  int pTmax;
  if(HistType == 0 || HistType == 2) pTmax =  Nparams + pTmin;  //.. the X and Y axis contain the pT bin no. so the range is the number of bins
  if(HistType == 1) pTmax = Nparams;




  char buf[200];
  char bufcent[9][10] = {"70-80%","60-70%","50-60%","40-50%","30-40%","20-30%","10-20%","5-10%","0-5%"};


  /*
    The one "hNtrack_cent%d_eta%d_pfx" is track vs pt TProfile.

    centrality is from 0-8

    X-axis is pt1 number.
    Y-axis is pt2 number.

    "hM2_2_cent%d_eta%d_pyx" is two particles moment TProfile2D.

    centrality is from 0-8

    X-axis is pt number.

  */



  TFile* fin = new TFile(Form("%s%s",dir,inFileName));
  if(fin->IsZombie()) { cout<<"cannot open "<<inFileName<<endl; exit(1);}

  char v22_name[100];
  char dNpT_name_neg_eta[100];
  char dNpT_name_pos_eta[100];
  char outFileName[100];


  sprintf(v22_name,"Plots/V11Results/V11PT_30to40");

  //    sprintf(outFileName,"FlowAndNonFlowFitRes_v%d_cent%d_eta%d_NonFlowType%d_FitRangeType%d.root",vn,centralityClass,dEtaGap,FitType,HistType);
  sprintf(outFileName,"JaimeTest.root");
  cout << v22_name << endl;

  //.. v22_hist, dNpT_forward and dNpT_backward are already normalized
  //TH2D* v22_hist_orig = (TH2D*)fin->Get(v22_name);
  //if(!v22_hist_orig) { cout<<"cannot read "<<v22_name<<endl; exit(1);}
  TProfile2D* v22_hist_orig= (TProfile2D*)fin->Get(v22_name);
  if(!v22_hist_orig) { cout<<"cannot read "<<v22_name<<endl; exit(1);}



  //.. print v_{n,n} bin content in order to check if there are any negative entries
  for(int i = 1;i<= pTmax;i++){
    for(int j = 1;j<= pTmax;j++)
      cout <<  setprecision(2) << v22_hist_orig->GetBinContent(i,j) << "+-" << v22_hist_orig->GetBinError(i,j) << "\t";
    cout << endl;
  }

  const int nbins = pTmax;
  //.. the v_{n,n} matrix is symmetric if SameEta==1 and fitting to full distribution will underestimate chi^2/ndf
  TH2D* v22_hist = new TH2D(Form("v%d%d_hist",vn,vn),Form("v%d%d_hist",vn,vn),nbins,0,nbins,nbins,0,nbins);
  for(int i = 1;i<= pTmax;i++){
    if(HistType == 1 || HistType == 2) {if(i<pTmin+1) continue;}
    //          for(int j = 1;j<= pTmax;j++){
    for(int j = 1;j<i;j++) {
      //                        if(SameEta==1 && j>i) continue;         // v_{n,n} will be symmetric
      if(HistType == 2) {if(j<pTmin+1) continue;}
      double vij = v22_hist_orig->GetBinContent(i,j), vji = v22_hist_orig->GetBinContent(j,i);
      double evij = v22_hist_orig->GetBinError(i,j), evji = v22_hist_orig->GetBinError(j,i);
      if(evij>0 && evji>0) {              // nonzero
        v22_hist->SetBinContent(i,j,(vij+vji)*0.5);
        v22_hist->SetBinError(i,j,sqrt(pow(evij,2)+pow(evji,2))*0.5);
      }
      if(evij>0 && evji<=0) {
        v22_hist->SetBinContent(i,j,vij);
        v22_hist->SetBinError(i,j,evij);
      }
      if(evij<=0 && evji>0) {
        v22_hist->SetBinContent(i,j,vji);
        v22_hist->SetBinError(i,j,evji);
      }
    }
    // for points on diagonal
    v22_hist->SetBinContent(i,i,v22_hist_orig->GetBinContent(i,i));
    v22_hist->SetBinError(i,i,v22_hist_orig->GetBinError(i,i));
  }
  //.. print v_{n,n} bin content to check if new matrix was reduced ok
  cout << endl << "v_nn after reduction" << endl;
  for(int i = 1;i<= pTmax;i++){
    for(int j = 1;j<= pTmax;j++)
      cout <<  setprecision(2) << v22_hist->GetBinContent(i,j) << "+-" << v22_hist->GetBinError(i,j) << "\t";
    cout << endl;
  }
  
  
  
  cout << "max pT range: " <<pTmax<<" bin, "<< pT[pTmax] << endl;
  cout << "min pT range: " <<pTmin<<" bin, "<< pT[pTmin] << endl;
  
  TF2* vNN_global_fit =  NULL;
  int xmin = 0;
  int xmax = pTmax;
  int ymin = 0;
  int ymax = pTmax;
  
  if(HistType == 1) { xmin = pTmin; }
  if(HistType == 2) { xmin = pTmin; ymin = pTmin; }
  
  if(FitType==0)
    vNN_global_fit = new TF2("vNN_global_fit",v_nn_fun,xmin,xmax,ymin,ymax,Nparams);
  //            vNN_global_fit = new TF2("vNN_global_fit",v_nn_fun,0,Nparams,0,Nparams,Nparams);
  else if(FitType==1 || FitType==2)
    vNN_global_fit = new TF2("vNN_global_fit",v_nn_fun,xmin,xmax,ymin,ymax,2*Nparams);
  //    vNN_global_fit = new TF2("vNN_global_fit",v_nn_fun,0,Nparams,0,Nparams,2*Nparams);
  else if(FitType==3)
    vNN_global_fit = new TF2("vNN_global_fit",v_nn_fun,xmin,xmax,ymin,ymax,3*Nparams);
  //    vNN_global_fit = new TF2("vNN_global_fit",v_nn_fun,0,Nparams,0,Nparams,3*Nparams);
  else if(FitType==4)
    vNN_global_fit = new TF2("vNN_global_fit",v_nn_fun,xmin,xmax,ymin,ymax,Nparams+1);
  else {
    printf("ERROR: wrong FitType!\n");
    exit(1);
  }
  
  
  
  //.. set some initial values of parameters;
  //.. Parameters [0-Nparams-1] - vn,[Nparams -2*Nparams-1]- vn'
  //.. [2*Nparams -3*2*Nparams-1] - delta_n,[3*2*Nparams -3*Nparams-1]- delta n'
  //.. vn = 0.1*pT, vni = 0.1*pT, delta_n = 0.05*pT, delta_n' = 0.05*pT,
  //    double v2_coef = 0.15;
  double v2_coef = 0.01;
  double nonflow_coef = 0.01;
  //    double cpar = 0.0006;      //v1*v1+cpar*pt1*pt2
  //double cpar = 0.001;      //v1*v1+cpar*pt1*pt2
  double cpar = 0.0;
  double vpar[18] = {-0.01,-0.01,-0.01,-0.01,-0.01,0.006,0.025,0.04,0.06,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1}; // cent6
  //  double vpar[18] = {-0.1,-0.1,-0.1,-0.1,0.0,0.1,0.025,0.04,0.06,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1};
  
  if(HistType == 0 || HistType == 1) {
    for(int i = 0;i< Nparams;i++){
      //                float pT_tmp = 0.5*(pT[i]+pT[i+1]);
      float pT_tmp = pTcenter[centralityClass][i];
      //                vNN_global_fit->SetParameter(i,v2_coef*pT_tmp);
      vNN_global_fit->SetParameter(i,vpar[i]);
      //                vNN_global_fit->SetParLimits(i,-1,10);          // v1 will go to negative at small pT
      vNN_global_fit->SetParLimits(i,-1,1);             // v1 will go to negative at small pT

      if(FitType>0&&FitType<4){
        vNN_global_fit->SetParameter(Nparams+i,nonflow_coef*pT_tmp);
        vNN_global_fit->SetParLimits(Nparams+i,0,10);
      }

      if(FitType==3){
        vNN_global_fit->SetParameter(2*Nparams+i,nonflow_coef*pT_tmp);
        vNN_global_fit->SetParLimits(2*Nparams+i,0,10);
      }

    }
  }

  if(HistType == 2) {
    for(int i = 0;i< Nparams;i++){
      //                float pT_tmp = 0.5*(pT[pTmin+i]+pT[pTmin+i+1]);
      float pT_tmp = pTcenter[centralityClass][pTmin+i+1];
      vNN_global_fit->SetParameter(i,v2_coef*pT_tmp);
      vNN_global_fit->SetParLimits(i,-1,10);

      if(FitType>0&&FitType<4){
        vNN_global_fit->SetParameter(Nparams+i,nonflow_coef*pT_tmp);
        vNN_global_fit->SetParLimits(Nparams+i,0,10);
      }

      if(FitType==3){
        vNN_global_fit->SetParameter(2*Nparams+i,nonflow_coef*pT_tmp);
        vNN_global_fit->SetParLimits(2*Nparams+i,0,10);
      }
    }
  }
  
  if(FitType==4) {
    vNN_global_fit->SetParameter(Nparams,cpar);
    vNN_global_fit->SetParLimits(Nparams,0,1);
  }

  cout << "ready to start fitting"
       << endl;
  TCanvas* cVFit = new  TCanvas;
  
  TVirtualFitter::SetMaxIterations(5000000);
  //ROOT::Math::MinimizerOptions::SetDefaultMinimizer("GSLMultiMin", "conjugatepr");
  v22_hist->Fit(vNN_global_fit,"R");


  TGraphErrors* grFlow = new TGraphErrors();
  grFlow->SetMarkerColor(kRed);
  grFlow->SetMarkerStyle(kFullCircle);

  TGraphErrors* grFlowRef = new TGraphErrors();
  grFlowRef->SetMarkerColor(kBlue);
  grFlowRef->SetMarkerStyle(kFullCircle);

  TGraphErrors* grNonflow = new TGraphErrors();
  grNonflow->SetMarkerStyle(kFullCircle);

  TGraphErrors* grNonflowRef = new TGraphErrors();
  grNonflowRef->SetMarkerStyle(kFullCircle);
  grNonflowRef->SetMarkerColor(kGreen);

  TGraphErrors* grNonflowRefNeg = new TGraphErrors();
  grNonflowRefNeg->SetMarkerStyle(kFullCircle);
  grNonflowRefNeg->SetMarkerColor(kBlue);

  TGraphErrors* grVnnRealData[nFitPlot];
  for(int i = 0; i<nFitPlot ; i++) {
    grVnnRealData[i] = new TGraphErrors();
    grVnnRealData[i]->SetMarkerStyle(kFullCircle);
    grVnnRealData[i]->SetMarkerColor(kBlue);
  }

  TGraphErrors* grVnnFitResults[nFitPlot];
  for(int i = 0; i<nFitPlot ; i++) {
    grVnnFitResults[i]  = new TGraphErrors();
    //  grVnnFitResults->SetMarkerStyle(kFullCircle);
    grVnnFitResults[i]->SetMarkerStyle(4);
    grVnnFitResults[i]->SetMarkerColor(kRed);
    grVnnFitResults[i]->SetLineColor(kRed);
    grVnnFitResults[i]->SetLineWidth(2);
  }

  TGraphErrors* grVnnRealdFit[nFitPlot];
  for(int i = 0; i<nFitPlot ; i++) {
    grVnnRealdFit[i] = new TGraphErrors();
    grVnnRealdFit[i]->SetMarkerStyle(kFullCircle);
    grVnnRealdFit[i]->SetMarkerColor(kBlue);
  }

  TGraphErrors* grNonflowFitResults[nFitPlot];
  for(int i = 0; i<nFitPlot ; i++) {
    grNonflowFitResults[i] = new TGraphErrors();
    grNonflowFitResults[i]->SetMarkerStyle(kFullCircle);
    grNonflowFitResults[i]->SetMarkerColor(kGreen);
    grNonflowFitResults[i]->SetLineColor(kGreen);
    grNonflowFitResults[i]->SetLineStyle(7);
    grNonflowFitResults[i]->SetLineWidth(2);
  }



  float chi2 = 0;
  int jpoint = 0;
  grVnnRealData[0]->SetTitle(Form("v%d%d p_{T}^{t}=p_{T}^{a}",vn,vn));
  grVnnFitResults[0]->SetTitle(Form("v%d%d fit p_{T}^{t}=p_{T}^{a}",vn,vn));
  grVnnRealdFit[0]->SetTitle(Form("v%d%d/fit p_{T}^{t}=p_{T}^{a}",vn,vn));
  grNonflowFitResults[0]->SetTitle(Form("nonflow fit p_{T}^{t}=p_{T}^{a}",vn,vn));
  for(int i = pTmin;i< pTmax;i++){
    //          float pT_tmp = 0.5*(pT[i]+pT[i+1]);
    float pT_tmp = pTcenter[centralityClass][i];
    grVnnRealData[0]->SetPoint(jpoint,pT_tmp,v22_hist->GetBinContent(i+1,i+1)); // for grVnnRealData[0] & grVnnFitResults[0]: draw the points on the dialogy
    grVnnRealData[0]->SetPointError(jpoint,0,v22_hist->GetBinError(i+1,i+1));
    //          float x = v22_hist->GetXaxis()->GetBinCenter(i+1);
    //          grVnnFitResults[0]->SetPoint(jpoint,pT_tmp,vNN_global_fit->Eval(x,x));
    grVnnFitResults[0]->SetPoint(jpoint,pT_tmp,vNN_global_fit->Eval(i,i));
    if(FitType==1) {
      grNonflowFitResults[0]->SetPoint(jpoint,pT_tmp,TMath::Power(vNN_global_fit->GetParameter(Nparams+i-pTmin),2));
    }
    else if(FitType==2) {
      grNonflowFitResults[0]->SetPoint(jpoint,pT_tmp,-TMath::Power(vNN_global_fit->GetParameter(Nparams+i-pTmin),2));
    }
    else if(FitType==3) {
      grNonflowFitResults[0]->SetPoint(jpoint,pT_tmp,TMath::Power(vNN_global_fit->GetParameter(Nparams+i-pTmin),2)-TMath::Power(vNN_global_fit->GetParameter(2*Nparams+i-pTmin),2));
    }
    else if(FitType==4) {
      grNonflowFitResults[0]->SetPoint(jpoint,pT_tmp,-pT_tmp*pT_tmp*vNN_global_fit->GetParameter(Nparams));
    }
    //          if(vNN_global_fit->Eval(x,x)) {
    //                  grVnnRealdFit[0]->SetPoint(jpoint,pT_tmp,v22_hist->GetBinContent(i+1,i+1)/vNN_global_fit->Eval(x,x));
    //                  grVnnRealdFit[0]->SetPointError(jpoint,0,v22_hist->GetBinError(i+1,i+1)/vNN_global_fit->Eval(x,x));

    //          if(vNN_global_fit->Eval(i,i)) {

    //                  grVnnRealdFit[0]->SetPoint(jpoint,pT_tmp,v22_hist->GetBinContent(i+1,i+1)/vNN_global_fit->Eval(i,i));
    //                  grVnnRealdFit[0]->SetPointError(jpoint,0,v22_hist->GetBinError(i+1,i+1)/vNN_global_fit->Eval(i,i));

    //        if(v22_hist->GetBinError(i+1,i+1)!=0) {
    //                  grVnnRealdFit[0]->SetPoint(jpoint,pT_tmp,TMath::Power((v22_hist->GetBinContent(i+1,i+1)-vNN_global_fit->Eval(i,i))/v22_hist->GetBinError(i+1,i+1),2));
    grVnnRealdFit[0]->SetPoint(jpoint,pT_tmp,(v22_hist->GetBinContent(i+1,i+1)-vNN_global_fit->Eval(i,i)));
    grVnnRealdFit[0]->SetPointError(jpoint,0,v22_hist->GetBinError(i+1,i+1));
    //          }

    jpoint++;
  }
  jpoint = 0;
  int flag = 0; // need to flip the sign for v(pt) ? v(pt1,pt2) ~ v(pt1)*v(pt2), the positive root at high pt should be in favor.
  double tmpsum = 0;
  for(int i = (pTmin+pTmax)/2; i<pTmax; i++) {
    tmpsum+=vNN_global_fit->GetParameter(i);
  }
  if(tmpsum<0) { printf("need flip sign for v(pt)\n"); flag = 1; }  // when pt = 3 GeV/c, v(pt) is negative, need flip sign
  else { flag = 0;}

  if(HistType == 0 || HistType == 1) {
    for(int i = 0; i<pTmax; i++) {
      //                float pT_tmp = 0.5*(pT[i]+pT[i+1]);
      float pT_tmp = pTcenter[centralityClass][i];
      if(FitType>0&&FitType<4){
        grNonflow->SetPoint(jpoint,pT_tmp,vNN_global_fit->GetParameter(Nparams+jpoint));
        grNonflow->SetPointError(jpoint,0,vNN_global_fit->GetParError(Nparams+jpoint));
      }
      if(FitType==3){
        grNonflowRefNeg->SetPoint(jpoint,pT_tmp,vNN_global_fit->GetParameter(2*Nparams+jpoint));
        grNonflowRefNeg->SetPointError(jpoint,0,vNN_global_fit->GetParError(2*Nparams+jpoint));
      }

      if(flag==1) {
        grFlow->SetPoint(jpoint,pT_tmp,-vNN_global_fit->GetParameter(jpoint));
        grFlow->SetPointError(jpoint,0,-vNN_global_fit->GetParError(jpoint));
      }
      else {
        grFlow->SetPoint(jpoint,pT_tmp,vNN_global_fit->GetParameter(jpoint));
        grFlow->SetPointError(jpoint,0,vNN_global_fit->GetParError(jpoint));
      }

      jpoint++;
    }
  }
  jpoint = 0;
  if(HistType == 2) {
    for(int i = pTmin; i<pTmax; i++) {
      //                float pT_tmp = 0.5*(pT[i]+pT[i+1]);
      float pT_tmp = pTcenter[centralityClass][i];
      if(FitType>0&&FitType<4){
        grNonflow->SetPoint(jpoint,pT_tmp,vNN_global_fit->GetParameter(Nparams+jpoint));
        grNonflow->SetPointError(jpoint,0,vNN_global_fit->GetParError(Nparams+jpoint));
      }
      if(FitType==3){
        grNonflowRefNeg->SetPoint(jpoint,pT_tmp,vNN_global_fit->GetParameter(2*Nparams+jpoint));
        grNonflowRefNeg->SetPointError(jpoint,0,vNN_global_fit->GetParError(2*Nparams+jpoint));
      }

      if(flag==1) {
        grFlow->SetPoint(jpoint,pT_tmp,-vNN_global_fit->GetParameter(jpoint));
        grFlow->SetPointError(jpoint,0,-vNN_global_fit->GetParError(jpoint));
      }
      else {
        grFlow->SetPoint(jpoint,pT_tmp,vNN_global_fit->GetParameter(jpoint));
        grFlow->SetPointError(jpoint,0,vNN_global_fit->GetParError(jpoint));
      }

      jpoint++;
    }
  }

  if(HistType == 0 || HistType == 1) {
    for(int iplot = 1; iplot<nFitPlot ; iplot++) {
      grVnnRealData[iplot]->SetTitle(Form("v%d%d p_{T}^{t}:%g-%g GeV/c",vn,vn,pT[iplot-1],pT[iplot]));
      grVnnFitResults[iplot]->SetTitle(Form("v%d%d fit p_{T}^{t}:%g-%g",vn,vn,pT[iplot-1],pT[iplot]));
      grVnnRealdFit[iplot]->SetTitle(Form("v%d%d/fit",vn,vn));
      grNonflowFitResults[iplot]->SetTitle(Form("nonflow fit p_{T}^{t}:%g-%g",vn,vn,pT[iplot-1],pT[iplot]));
      //        cout<<endl<<endl;
      //        cout<<iplot<<" plot: "<<plotrefpt[iplot-1]<<endl;
      jpoint = 0;
      for(int i = 0 ; i<pTmax ; i++) {
        //      float pT_tmp = 0.5*(pT[i]+pT[i+1]);
        float pT_tmp = pTcenter[centralityClass][i];
        //      grVnnRealData[iplot] ->SetPoint(jpoint, pT_tmp, v22_hist_orig->GetBinContent(iplot,i+1)); // for grVnnRealData[1,2,...] & grVnnFitResults[1,2,...]: draw the points (x,y) from the requested ref pt and ipt, iplot begins with 1
        //      grVnnRealData[iplot] ->SetPointError(jpoint,0,v22_hist_orig->GetBinError(iplot,i+1));
        grVnnRealData[iplot] ->SetPoint(jpoint, pT_tmp, v22_hist->GetBinContent(TMath::Max(iplot,i+1), TMath::Min(iplot,i+1))); // for grVnnRealData[1,2,...] & grVnnFitResults[1,2,...]: draw the points (x,y) from the requested ref pt and ipt, iplot begins with 1
        grVnnRealData[iplot] ->SetPointError(jpoint,0,v22_hist->GetBinError(TMath::Max(iplot,i+1),TMath::Min(iplot,i+1)));

        //      float x = v22_hist_orig->GetXaxis()->GetBinCenter(iplot); // iplot begins with 1, because the first plot is pt = pt_ref
        //      float y = v22_hist_orig->GetXaxis()->GetBinCenter(i+1);

        //      grVnnFitResults[iplot] ->SetPoint(jpoint,pT_tmp,vNN_global_fit->Eval(x,y));
        grVnnFitResults[iplot] ->SetPoint(jpoint,pT_tmp,vNN_global_fit->Eval(iplot-1,i));

        if(FitType==1) {
          grNonflowFitResults[iplot]->SetPoint(jpoint,pT_tmp,vNN_global_fit->GetParameter(Nparams+iplot-1)*vNN_global_fit->GetParameter(Nparams+i));
        }
        else if(FitType==2) {
          grNonflowFitResults[iplot]->SetPoint(jpoint,pT_tmp,-vNN_global_fit->GetParameter(Nparams+iplot-1)*vNN_global_fit->GetParameter(Nparams+i));
        }
        else if(FitType==3) {
          grNonflowFitResults[iplot]->SetPoint(jpoint,pT_tmp,vNN_global_fit->GetParameter(Nparams+iplot-1)*vNN_global_fit->GetParameter(Nparams+i)-vNN_global_fit->GetParameter(2*Nparams+iplot-1)*vNN_global_fit->GetParameter(2*Nparams+i));
        }
        else if(FitType==4) {
          grNonflowFitResults[iplot]->SetPoint(jpoint,pT_tmp,-pT[iplot-1]*pT_tmp*vNN_global_fit->GetParameter(Nparams));
        }

        //      if(vNN_global_fit->Eval(x,y)) {
        //                      grVnnRealdFit[iplot]->SetPoint(jpoint,pT_tmp,v22_hist_orig->GetBinContent(iplot,i+1)/vNN_global_fit->Eval(x,y));
        //                      grVnnRealdFit[iplot]->SetPointError(jpoint,0,v22_hist_orig->GetBinError(iplot,i+1)/vNN_global_fit->Eval(x,y));
        //      if(vNN_global_fit->Eval(iplot-1,i)) {
        //                      grVnnRealdFit[iplot]->SetPoint(jpoint,pT_tmp,v22_hist_orig->GetBinContent(iplot,i+1)/vNN_global_fit->Eval(iplot-1,i));
        //                      grVnnRealdFit[iplot]->SetPointError(jpoint,0,v22_hist_orig->GetBinError(iplot,i+1)/vNN_global_fit->Eval(iplot-1,i));
        //    if(v22_hist_orig->GetBinError(iplot,i+1)) {
        //                      grVnnRealdFit[iplot]->SetPoint(jpoint,pT_tmp,TMath::Power((v22_hist_orig->GetBinContent(iplot,i+1)-vNN_global_fit->Eval(iplot-1,i))/v22_hist_orig->GetBinError(iplot,i+1),2));
        grVnnRealdFit[iplot]->SetPoint(jpoint,pT_tmp,(v22_hist_orig->GetBinContent(iplot,i+1)-vNN_global_fit->Eval(iplot-1,i)));
        grVnnRealdFit[iplot]->SetPointError(jpoint,0,v22_hist_orig->GetBinError(iplot,i+1));
        //      }


        //      cout<<i<<"\t"<<x<<","<<y<<"\t"<<vNN_global_fit->Eval(x,y)<<","<<v22_hist_orig->GetBinContent(plotrefpt[iplot-1]+1,i+1)<<"\n";

        jpoint++;
      }
      //        cout<<endl;
    }
  }

  if(HistType == 2) {
    for(int iplot = 1; iplot<nFitPlot ; iplot++) {
      grVnnRealData[iplot]->SetTitle(Form("v%d%d p_{T}^{t}:%g-%g GeV/c",vn,vn,pT[iplot-1],pT[iplot]));
      grVnnFitResults[iplot]->SetTitle(Form("v%d%d fit p_{T}^{t}:%g-%g",vn,vn,pT[iplot-1],pT[iplot]));
      grVnnRealdFit[iplot]->SetTitle(Form("v%d%d/fit",vn,vn));
      grNonflowFitResults[iplot]->SetTitle(Form("nonflow fit p_{T}^{t}:%g-%g",vn,vn,pT[iplot-1],pT[iplot]));
      //        cout<<iplot<<" plot:";
      if(iplot-1>pTmin){
        jpoint = 0;
        for(int i = pTmin ; i<pTmax ; i++) {
          //    float pT_tmp = 0.5*(pT[i]+pT[i+1]);
          float pT_tmp = pTcenter[centralityClass][i];
          grVnnRealData[iplot] ->SetPoint(jpoint, pT_tmp, v22_hist_orig->GetBinContent(iplot,i+1)); // for grVnnRealData[1,2,...] & grVnnFitResults[1,2,...]: draw the points (x,y) from the requested ref pt and ipt
          grVnnRealData[iplot] ->SetPointError(jpoint,0,v22_hist_orig->GetBinError(iplot,i+1));

          //    float x = v22_hist_orig->GetXaxis()->GetBinCenter(iplot);
          //    float y = v22_hist_orig->GetXaxis()->GetBinCenter(i+1);

          //    grVnnFitResults[iplot] ->SetPoint(jpoint,pT_tmp,vNN_global_fit->Eval(x,y));
          grVnnFitResults[iplot] ->SetPoint(jpoint,pT_tmp,vNN_global_fit->Eval(iplot-1,i));
          //    cout<<vNN_global_fit->Eval(x,y)<<","<<v22_hist_orig->GetBinContent(plotrefpt[iplot-1]+1,i+1)<<"\t";

          if(FitType==1) {
            grNonflowFitResults[iplot]->SetPoint(jpoint,pT_tmp,vNN_global_fit->GetParameter(Nparams+iplot-1-pTmin)*vNN_global_fit->GetParameter(Nparams+i-pTmin));
          }
          else if(FitType==2) {
            grNonflowFitResults[iplot]->SetPoint(jpoint,pT_tmp,-vNN_global_fit->GetParameter(Nparams+iplot-1-pTmin)*vNN_global_fit->GetParameter(Nparams+i-pTmin));
          }
          else if(FitType==3) {
            grNonflowFitResults[iplot]->SetPoint(jpoint,pT_tmp,vNN_global_fit->GetParameter(Nparams+iplot-1-pTmin)*vNN_global_fit->GetParameter(Nparams+i-pTmin)-vNN_global_fit->GetParameter(2*Nparams+iplot-1-pTmin)*vNN_global_fit->GetParameter(2*Nparams+i-pTmin));
          }
          else if(FitType==4) {
            grNonflowFitResults[iplot]->SetPoint(jpoint,pT_tmp,-pT[iplot-1]*pT_tmp*vNN_global_fit->GetParameter(Nparams));
          }

          //    if(vNN_global_fit->Eval(iplot-1,i)) {
          //                    grVnnRealdFit[iplot]->SetPoint(jpoint,pT_tmp,v22_hist_orig->GetBinContent(iplot,i+1)/vNN_global_fit->Eval(iplot-1,i));
          //                    grVnnRealdFit[iplot]->SetPointError(jpoint,0,v22_hist_orig->GetBinError(iplot,i+1)/vNN_global_fit->Eval(iplot-1,i));
          grVnnRealdFit[iplot]->SetPoint(jpoint,pT_tmp,v22_hist_orig->GetBinContent(iplot,i+1)-vNN_global_fit->Eval(iplot-1,i));
          grVnnRealdFit[iplot]->SetPointError(jpoint,0,v22_hist_orig->GetBinError(iplot,i+1));
          //    if(v22_hist_orig->GetBinError(iplot,i+1)) {
          //                    grVnnRealdFit[iplot]->SetPoint(jpoint,pT_tmp,TMath::Power((v22_hist_orig->GetBinContent(iplot,i+1)-vNN_global_fit->Eval(iplot-1,i)))/v22_hist_orig->GetBinError(iplot,i+1));
          //    }

          //    if(vNN_global_fit->Eval(x,y)) {
          //                    grVnnRealdFit[iplot]->SetPoint(jpoint,pT_tmp,v22_hist_orig->GetBinContent(iplot,i+1)/vNN_global_fit->Eval(x,y));
          //                    grVnnRealdFit[iplot]->SetPointError(jpoint,0,v22_hist_orig->GetBinError(iplot,i+1)/vNN_global_fit->Eval(x,y));
          //    }

          jpoint++;
        }
      }
      //        cout<<endl;
    }
  }

  /*    cout<<"\ndata:"<<endl;
        for(int i = 0; i<pTmax; i++) {
        for(int j = 0; j<pTmax; j++)
        cout<<setprecision(2) <<v22_hist->GetBinContent(i+1,j+1)<<"\t";
        cout<<endl;
        }

        cout<<"hist ij:"<<endl;
        for(int i = 0; i<pTmax; i++) {
        for(int j = 0; j<pTmax; j++)
        cout<<setprecision(2) <<vNN_global_fit->Eval(i,j)<<"\t";
        cout<<endl;
        }

  */

  // calculate chi-square
  for(int i = 0;i< pTmax;i++){
    if(HistType == 1||HistType == 2) {if(i<pTmin) continue;}
    for(int jj = 0;jj<=i;jj++){
      if(HistType == 2) {if(jj<pTmin) continue;}
      float x = v22_hist->GetXaxis()->GetBinCenter(i+1);
      float y = v22_hist->GetXaxis()->GetBinCenter(jj+1);

      //                     chi2 += TMath::Power((v22_hist->GetBinContent(i+1,j+1) - vNN_global_fit->Eval(x,y))/v22_hist->GetBinError(i+1,j+1),2);
      //                         cout<<"("<<i<<","<<j<<")="<<v22_hist->GetBinContent(i+1,j+1)<<","<<vNN_global_fit->Eval(x,y)<<"\t";
      if(v22_hist->GetBinError(i+1,jj+1)) {
        chi2 += TMath::Power((v22_hist->GetBinContent(i+1,jj+1) - vNN_global_fit->Eval(i,jj))/v22_hist->GetBinError(i+1,jj+1),2);
      }
    }                // v(pt1,pt2) should be correlated with v(pt2,pt1).
    //         cout<<endl;
  }


  grFlow->SetName("vn");
  grNonflow->SetName("delta_n");
  grNonflowRefNeg->SetName("delta_n_neg");

  cout << "chi_2: " << vNN_global_fit->GetChisquare()<< endl;
  cout << "my chi_2: " << chi2 << endl;
  cout << "NDF: " << vNN_global_fit->GetNDF()<< endl;
  cout << "chi_2/NDF: " << vNN_global_fit->GetChisquare()/vNN_global_fit->GetNDF()<< endl;
  cout << "my chi_2/NDF: " << chi2/vNN_global_fit->GetNDF()<< endl;

  TCanvas* cRes = new  TCanvas;

  cRes->SetFillColor(10);
  cRes->SetFrameFillColor(10);
  cRes->SetBorderMode(0);
  cRes->SetBorderSize(0);
  cRes->SetFrameBorderMode(0);
  cRes->SetFrameBorderSize(0);

  TMultiGraph* results = new TMultiGraph();
  results->Add(grFlow);
  if(FitType>0&&FitType<4)
    results->Add(grNonflow);
  if(FitType==3)
    results->Add(grNonflowRefNeg);

  results->Draw("ap");
  results->GetXaxis()->SetTitle("p_{T} [GeV]");
  results->GetYaxis()->SetTitle(Form("v_{%d}  (#delta_{2} )",vn));

  TLine *l = new TLine(0,0,0.5*(pT[pTbins-2]+pT[pTbins-1])+0.5,0);
  l->SetLineStyle(6);
  l->Draw("same");

  TLegend* leg2 = new TLegend(0.12,0.72,0.34,0.83);
  leg2->SetFillColor(0);
  leg2->AddEntry(grFlow,Form("v_{%d}",vn),"p");
  if(FitType==1)
    leg2->AddEntry(grNonflow,Form("'+' #delta_{%d}",vn),"p");
  if(FitType==2)
    leg2->AddEntry(grNonflow,Form("'-' #delta_{%d}",vn),"p");
  if(FitType==3){
    leg2->AddEntry(grNonflow,Form("'+' #delta_{%d}",vn),"p");
    leg2->AddEntry(grNonflowRefNeg,Form("'-' #delta_{%d}",vn),"p");
  }
  leg2->Draw("same");

  sprintf(buf,"%s, %s",dEtaGapname,bufcent[centralityClass]);
  TLatex *latTitle = new TLatex(0.4,0.91,buf);
  latTitle->SetNDC();
  latTitle->Draw("same");


  TLatex *lat;
  sprintf(buf,"#chi^2/NDF = %.1f/%d",vNN_global_fit->GetChisquare(),vNN_global_fit->GetNDF());
  lat = new TLatex(0.6,0.14,buf);
  lat->SetNDC();
  lat->SetTextSize(0.04);
  lat->Draw("same");

  sprintf(buf,"vdelta_%s_cent%d_Deta%d_v%d.gif",inFileName,centralityClass,dEtaGap,vn);
  cRes->Print(buf);



  //    TCanvas* cVnnFitRes[nFitPlot];
  //    TLegend *leg[nFitPlot];
  //
  //    for(int iplot = 0; iplot<nFitPlot; iplot++) {
  //    cVnnFitRes[iplot]  = new  TCanvas;
  //    cVnnFitRes[iplot]->SetFillColor(10);
  //        cVnnFitRes[iplot]->SetFrameFillColor(10);
  //        cVnnFitRes[iplot]->SetBorderMode(0);
  //        cVnnFitRes[iplot]->SetBorderSize(0);
  //        cVnnFitRes[iplot]->SetFrameBorderMode(0);
  //        cVnnFitRes[iplot]->SetFrameBorderSize(0);
  //
  //    if(iplot == 0 ||HistType == 0 || HistType == 1 || (HistType == 2 && iplot>0 && plotrefpt[iplot-1]>=pTmin)) {
  //    grVnnRealData[iplot]->Draw("ap");
  //    grVnnFitResults[iplot]->Draw("p");
  //    grVnnRealData[iplot]->GetXaxis()->SetTitle("p_{T} [GeV]");
  //    grVnnRealData[iplot]->GetYaxis()->SetTitle("v_{2,2} ");
  //
  //    leg[iplot] = new TLegend(0.12,0.67,0.44,0.83);
  //    leg[iplot]->SetFillColor(0);
  //    if(iplot == 0) leg[iplot]->AddEntry(grVnnRealData[iplot],"v_{2,2}(p_{T},p_{T}^{Ref} = p_{T})","p");
  //    else {sprintf(buf, "v_{2,2}(p_{T},p_{T}^{Ref} = %g-%g)", pT[plotrefpt[iplot-1]],pT[plotrefpt[iplot-1]+1]); leg[iplot]->AddEntry(grVnnRealData[iplot],buf,"p");}
  //    leg[iplot]->AddEntry(grVnnFitResults[iplot],"fit","p");
  //    leg[iplot]->Draw("same");
  //
  //    lat->Draw("same");
  //
  //    latTitle->Draw("same");
  //    sprintf(buf,"vfit_%s_cent%d_Deta%d_v%d_ref%d.gif",inFileName,centralityClass,dEtaGap,vn,iplot);
  //    cVnnFitRes[iplot]->Print(buf);
  //
  //    }
  //    }


  //----------------------------- fit matrix ---------------------------------

  TCanvas *cfitmatrix[nFitPlot];
  TPad *p_up[nFitPlot];
  TPad *p_dn[nFitPlot];
  //    TLine *line = new TLine(0,1,(pT[nFitPlot-1]+pT[nFitPlot-2])/2,1);
  //    TLine *line = new TLine(0,1,8.8,1);
  TLine *line = new TLine(0,0,8.8,0);
  line->SetLineStyle(2);
  TLatex *titlefitmat = new TLatex;
  TLatex *ratiotitle = new TLatex;
  TLegend *fitreallegend = new TLegend(0.7,0.7,0.85,0.89);
  TText *texttitle = new TText;
  fitreallegend->SetFillColor(0);
  fitreallegend->SetBorderSize(0);
  fitreallegend->AddEntry(grVnnRealData[0],"data","p");
  fitreallegend->AddEntry(grVnnFitResults[0],"fit","l");
  if(FitType>0) {
    fitreallegend->AddEntry(grNonflowFitResults[0],"-c*pt1*pt2","l");
  }


  titlefitmat->SetNDC();
  ratiotitle->SetNDC();
  ratiotitle->SetTextSize(0.08);


  for(int ipl = 0; ipl < nFitPlot ; ipl++) {
    cfitmatrix[ipl] = new TCanvas(Form("cfitmatrix%d",ipl),Form("cfitmatrix%d",ipl),600,500);
    gStyle->SetOptTitle(0);
    cfitmatrix[ipl]->SetFillColor(10);
    cfitmatrix[ipl]->cd();

    p_up[ipl] = new TPad(Form("p_up%d",ipl),Form("p_up%d",ipl),0.,0.3,1,1);     // up panel
    p_up[ipl]->SetFillColor(10);
    p_up[ipl]->SetTopMargin(0.1);
    p_up[ipl]->SetBottomMargin(0);
    p_up[ipl]->SetLeftMargin(0.1);
    p_up[ipl]->SetRightMargin(0.1);
    p_up[ipl]->SetGridx(0);
    p_up[ipl]->SetGridy(0);
    p_up[ipl]->SetBorderMode(0);
    p_up[ipl]->SetFrameFillColor(0);
    p_up[ipl]->SetFrameLineWidth(2);
    p_up[ipl]->Draw();
    p_up[ipl]->cd();

    //  grVnnRealData[ipl]->SetMaximum(0.009);
    //  grVnnRealData[ipl]->SetMinimum(-0.046);
    grVnnRealData[ipl]->GetYaxis()->SetLabelSize(0.05);
    grVnnRealData[ipl]->GetXaxis()->SetNdivisions(406);
    grVnnRealData[ipl]->GetYaxis()->SetNdivisions(5);
    grVnnRealData[ipl]->Draw("epa");
    grVnnFitResults[ipl]->Draw("c");
    grNonflowFitResults[ipl]->Draw("c");

    line->Draw("same");

    if(ipl==0) {
      titlefitmat->DrawLatex(0.1,0.94,Form("v_{%d%d} p_{T}^{t}= p_{T}^{a}",vn,vn));
    }
    else {
      titlefitmat->DrawLatex(0.1,0.94,Form("v_{%d%d} p_{T}^{t}:%g-%g GeV/c",vn,vn,pT[ipl-1],pT[ipl]));
    }

    latTitle->DrawLatex(0.4,0.94,Form("%s, %s",dEtaGapname,bufcent[centralityClass]));

    fitreallegend->Draw("same");

    cfitmatrix[ipl]->cd();

    p_dn[ipl] = new TPad(Form("p_dn%d",ipl),Form("p_dn%d",ipl),0,0,1,0.3);      // dn panel
    p_dn[ipl]->SetFillColor(10);
    p_dn[ipl]->SetTopMargin(0);
    p_dn[ipl]->SetBottomMargin(0.25);
    p_dn[ipl]->SetLeftMargin(0.1);
    p_dn[ipl]->SetRightMargin(0.1);
    p_dn[ipl]->SetGridx(0);
    p_dn[ipl]->SetGridy(0);
    p_dn[ipl]->SetBorderMode(0);
    p_dn[ipl]->SetFrameFillColor(0);
    p_dn[ipl]->SetFrameLineWidth(2);
    p_dn[ipl]->Draw();
    p_dn[ipl]->cd();

    grVnnRealdFit[ipl]->GetXaxis()->SetTitle("p_{T} [GeV]");
    grVnnRealdFit[ipl]->GetXaxis()->SetLabelSize(0.15);
    grVnnRealdFit[ipl]->GetYaxis()->SetLabelSize(0.1);
    grVnnRealdFit[ipl]->GetXaxis()->SetNdivisions(406);
    grVnnRealdFit[ipl]->GetYaxis()->SetNdivisions(5);
    grVnnRealdFit[ipl]->GetXaxis()->SetTitleSize(0.1);
    //  grVnnRealdFit[ipl]->SetMaximum(1.7);
    //  grVnnRealdFit[ipl]->SetMinimum(0.3);
    grVnnRealdFit[ipl]->SetMaximum(0.0015);
    grVnnRealdFit[ipl]->SetMinimum(-0.0015);
    grVnnRealdFit[ipl]->Draw("ap");


    ratiotitle->SetTextSize(0.1);
    //  ratiotitle->SetTextAngle(90);
    //  ratiotitle->DrawLatex(0.02,0.65,Form("#frac{v%d%d}{fit}",vn,vn));
    //  ratiotitle->DrawLatex(0.05,0.5,Form("(#frac{v_{%d%d}-fit}{err})^{2}",vn,vn));
    ratiotitle->DrawLatex(0.015,0.5,Form("v_{%d%d}-fit",vn,vn));

    //    double liney = 0;
    //    double *yvnnrealdfit = grVnnRealdFit[ipl]->GetY();
    //    for(int i =0;i<grVnnRealdFit[ipl]->GetN();i++) {
    //        liney+=*(yvnnrealdfit+i);
    //    }
    //    liney=liney/grVnnRealdFit[ipl]->GetN();
    //    line->DrawLine(0,liney,8.8,liney);
    line->Draw("same");
    //    texttitle->SetTextSize(0.1);
    //    texttitle->DrawText(8.88,liney-0.1,"<--mean");

    cfitmatrix[ipl]->SaveAs(Form("v%dcent%ddeta%dfit%dhist%dpt%d_%s.gif",vn,centralityClass,dEtaGap,whatToFit,whathist,ipl,inFileName));

  }




  TFile* f = new TFile(outFileName,"recreate");
  f->cd();
  cRes->Write();
  grFlow->Write();
  grNonflow->Write();
  grNonflowRefNeg->Write();
  f->Close();

  sprintf(buf,"vfit_%s_cent%d_Deta%d_v%d.txt",inFileName,centralityClass,dEtaGap,vn);
  FILE *outtxt = fopen(buf,"w");
  if(outtxt==NULL) {cout<<"write txt fail"<<endl;return;}
  fprintf(outtxt,"centrality %s v%d\n",bufcent[centralityClass],vn);
  fprintf(outtxt,"pT bins set :\n");
  for(int i = 0; i<pTbins ; i++ ) {
    fprintf(outtxt,"%.2f ",pT[i]);
  }
  fprintf(outtxt,"\n\nv_nn(pt1,pt2) matrix:\n");
  if(HistType == 0 ||HistType == 1) {
    for(int i = 1;i<= Nparams;i++){
      for(int jj = 1;jj<= Nparams;jj++)
        fprintf(outtxt,"%1.4f \t", v22_hist->GetBinContent(i,jj));
      fprintf(outtxt,"\n");
    }
  }
  if(HistType ==2) {
    for(int i = 1;i<= pTmax;i++){
      for(int j = 1;j<= pTmax;j++)
        fprintf(outtxt,"%1.4f \t", v22_hist->GetBinContent(i,j));
      fprintf(outtxt,"\n");
    }
  }

  fprintf(outtxt,"\nfit function:\n");
  fprintf(outtxt,"v%d%d(pt1,pt2) = v%d(pt1)*v%d(pt2)",vn,vn,vn,vn);
  if(FitType==1) fprintf(outtxt," + delta%d(pt1)*delta%d(pt2)",vn,vn);
  if(FitType==2) fprintf(outtxt," - delta%d(pt1)*delta%d(pt2)",vn,vn);
  if(FitType==3) fprintf(outtxt," + delta%d(pt1)*delta%d(pt2) -  delta'%d(pt1)*delta'%d(pt2)",vn,vn,vn,vn);
  if(FitType==4) fprintf(outtxt," - c*pt1*pt2");
  fprintf(outtxt,"\n");

  fprintf(outtxt,"\nfit parameters:\n");
  for(int i = 0; i<Nparams ; i++ ) {
    fprintf(outtxt,"v_nn_fun%d\t%f +- %f\n", i,vNN_global_fit->GetParameter(i),vNN_global_fit->GetParError(i));
  }
  if(FitType==1) {
    for(int i = Nparams;i<2*Nparams;i++) {
      fprintf(outtxt,"+deta_nn_fun%d\t%f +- %f\n",i, vNN_global_fit->GetParameter(i),vNN_global_fit->GetParError(i));
    }
  }
  if(FitType==2) {
    for(int i = Nparams;i<2*Nparams;i++) {
      fprintf(outtxt,"-deta_nn_fun%d\t%f +- %f\n",i, vNN_global_fit->GetParameter(i),vNN_global_fit->GetParError(i));
    }
  }
  if(FitType==3) {
    for(int i = Nparams;i<2*Nparams;i++) {
      fprintf(outtxt,"+deta_nn_fun%d\t%f +- %f\n",i, vNN_global_fit->GetParameter(i),vNN_global_fit->GetParError(i));
    }
    for(int i = 2*Nparams;i<3*Nparams;i++) {
      fprintf(outtxt,"-deta_nn_fun%d\t%f +- %f\n",i, vNN_global_fit->GetParameter(i),vNN_global_fit->GetParError(i));
    }
  }
  if(FitType==4) {
    fprintf(outtxt,"+cpar\t%f +- %f\n",vNN_global_fit->GetParameter(Nparams),vNN_global_fit->GetParError(Nparams));
  }

  fprintf(outtxt,"\nchi_2: %f\n",vNN_global_fit->GetChisquare());
  fprintf(outtxt,"NDF: %f\n",vNN_global_fit->GetNDF());
  fprintf(outtxt,"chi_2/NDF: %f" , vNN_global_fit->GetChisquare()/vNN_global_fit->GetNDF());

  fclose(outtxt);

  return;

}
