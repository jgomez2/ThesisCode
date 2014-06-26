#include "Analyzers/ForwardAnalyzer/interface/UPCTrackAnalyzer.h"

using namespace edm;

UPCTrackAnalyzer::UPCTrackAnalyzer(const edm::ParameterSet& iConfig):trackCollection(iConfig.getParameter<string>("trackCollection")){}

UPCTrackAnalyzer::~UPCTrackAnalyzer(){}

void UPCTrackAnalyzer::beginJob(){
  mFileServer->file().SetCompressionLevel(9);
  mFileServer->file().cd();

  string tName(trackCollection+"Tree");
  TrakTree = new TTree(tName.c_str(),tName.c_str());

  TrakTree->Branch("NTracks",&nTracks,"nTracks/I");
  TrakTree->Branch("ndof",&ndof,"ndof[nTracks]/I");
  TrakTree->Branch("chi2",&chi2,"chi2[nTracks]/D");
  TrakTree->Branch("pt",&pt[0],"pt[nTracks]/D");
  TrakTree->Branch("qoverp",&qoverp[0],"qoverp[nTracks]/D");
  TrakTree->Branch("lambda",&lambda[0],"lambda[nTracks]/D");
  TrakTree->Branch("phi",&phi[0],"phi[nTracks]/D");
  TrakTree->Branch("varQoverp",&varQoverp[0],"varQoverp[nTracks]/D");
  TrakTree->Branch("varLambda",&varLambda[0],"varLambda[nTracks]/D");
  TrakTree->Branch("varPhi",&varPhi[0],"varPhi[nTracks]/D");
  TrakTree->Branch("covarQoverpLambda",&covarQoverpLambda[0],"covarQoverpLambda[nTracks]/D");
  TrakTree->Branch("covarQoverpPhi",&covarQoverpPhi[0],"covarQoverpPhi[nTracks]/D");
  TrakTree->Branch("covarLambdaPhi",&covarLambdaPhi[0],"covarLambdaPhi[nTracks]/D");
  TrakTree->Branch("x",&x[0],"x[nTracks]/D");
  TrakTree->Branch("y",&y[0],"y[nTracks]/D");
  TrakTree->Branch("z",&z[0],"z[nTracks]/D");
  TrakTree->Branch("eta",&eta[0],"eta[nTracks]/D");
}

void UPCTrackAnalyzer::analyze(const edm::Event& iEvent, const edm::EventSetup& iSetup){
  Handle<TrackCollection> hiTrax;
  iEvent.getByLabel(trackCollection.c_str(),hiTrax);

  edm::Handle<reco::VertexCollection> vertex;
  iEvent.getByLabel("hiSelectedVertex", vertex);

  chi2.clear(); ndof.clear();
  x.clear(); y.clear(); z.clear();
  pt.clear(); qoverp.clear(); lambda.clear(); phi.clear();
  varQoverp.clear(); varLambda.clear(); varPhi.clear();
  covarQoverpLambda.clear();covarQoverpPhi.clear();covarLambdaPhi.clear();eta.clear();

  chi2_=36.;
  dzerr_=10.;

  if(!hiTrax.failedToGet()){getTracks(hiTrax,vertex,ndof,chi2,x,y,z,pt,qoverp,lambda,phi,varQoverp,varLambda,varPhi,
                                      covarQoverpLambda,covarQoverpPhi,covarLambdaPhi,eta,dzerr_,chi2_);}

  nTracks=x.size();

  TrakTree->SetBranchAddress("NTracks",&nTracks);
  TrakTree->SetBranchAddress("ndof",&ndof[0]);
  TrakTree->SetBranchAddress("chi2",&chi2[0]);
  TrakTree->SetBranchAddress("pt",&pt[0]);
  TrakTree->SetBranchAddress("qoverp",&qoverp[0]);
  TrakTree->SetBranchAddress("lambda",&lambda[0]);
  TrakTree->SetBranchAddress("phi",&phi[0]);
  TrakTree->SetBranchAddress("varQoverp",&varQoverp[0]);
  TrakTree->SetBranchAddress("varLambda",&varLambda[0]);
  TrakTree->SetBranchAddress("varPhi",&varPhi[0]);
  TrakTree->SetBranchAddress("covarQoverpLambda",&covarQoverpLambda[0]);
  TrakTree->SetBranchAddress("covarQoverpPhi",&covarQoverpPhi[0]);
  TrakTree->SetBranchAddress("covarLambdaPhi",&covarLambdaPhi[0]);
  TrakTree->SetBranchAddress("x",&x[0]);
  TrakTree->SetBranchAddress("y",&y[0]);
  TrakTree->SetBranchAddress("z",&z[0]);
  TrakTree->SetBranchAddress("eta",&eta[0]);


  TrakTree->Fill();
}

void UPCTrackAnalyzer::getTracks(Handle<TrackCollection> TrackCol,edm::Handle<reco::VertexCollection> vertex, vector<int> &ndof, vector<double> &chi2,
                                 vector<double> &x, vector<double> &y, vector<double> &z,
                                 vector<double> &pt, vector<double> &qoverp, vector<double> &lambda, vector<double> &phi,
                                 vector<double> &varqoverp, vector<double> &varlambda, vector<double> &varphi,
                                 vector<double> &covarqoverplambda, vector<double> &covarqoverpphi,
                                 vector<double> &covarlambdaphi, vector<double> &eta,double &dzerr_,double &chi2_){
  for(TrackCollection::const_iterator trax=(&*TrackCol)->begin();
      trax!=(&*TrackCol)->end();trax++){

    // find the vertex point and error

    math::XYZPoint vtxPoint(0.0,0.0,0.0);
    double vzErr =0.0, vxErr=0.0, vyErr=0.0;
    if(vertex->size()>0) {
      vtxPoint=vertex->begin()->position();
      vzErr=vertex->begin()->zError();
      vxErr=vertex->begin()->xError();
      vyErr=vertex->begin()->yError();
    }

    bool accepted = true;
    bool isPixel = false;

    // determine if the track is a pixel track
    if ( trax->numberOfValidHits() < 7 ) isPixel = true;

    // determine the vertex significance
    double d0=0.0, dz=0.0, d0sigma=0.0, dzsigma=0.0;
    d0 = -1.*trax->dxy(vtxPoint);
    dz = trax->dz(vtxPoint);
    d0sigma = sqrt(trax->d0Error()*trax->d0Error()+vxErr*vyErr);
    dzsigma = sqrt(trax->dzError()*trax->dzError()+vzErr*vzErr);

    // cuts for pixel tracks
    if( isPixel )
      {
        // dz significance cut
        if ( fabs(dz/dzsigma) > dzerr_ ) accepted = false;

        // chi2/ndof cut
        if ( trax->normalizedChi2() > chi2_ ) accepted = false;
      }

    // cuts for full tracks
    if ( ! isPixel)
      {
        // dz and d0 significance cuts
        if ( fabs(dz/dzsigma) > 10 ) accepted = false;
        //if ( fabs(d0/d0sigma) > 3 ) accepted = false;

        // pt resolution cut
        if ( trax->ptError()/trax->pt() > 0.01 ) accepted = false;

        // number of valid hits cut
        //if ( trax->numberOfValidHits() < 12 ) accepted = false;
      }

    if( accepted ){
      //cout<<"MADE IT"<<endl;
      x.push_back(trax->vx());
      y.push_back(trax->vy());
      z.push_back(trax->vz());
      pt.push_back(trax->pt());
      qoverp.push_back(trax->qoverp());
      lambda.push_back(trax->lambda());
      phi.push_back(trax->phi());
      varqoverp.push_back(trax->covariance(0,0));
      varlambda.push_back(trax->covariance(1,1));
      varphi.push_back(trax->covariance(2,2));
      covarqoverplambda.push_back(trax->covariance(0,1));
      covarqoverpphi.push_back(trax->covariance(0,2));
      covarlambdaphi.push_back(trax->covariance(1,2));
      chi2.push_back(trax->chi2());
      ndof.push_back(trax->ndof());
      eta.push_back(trax->eta());
    }//end of "accepted"
    // else cout<<"Didnt make it :("<<endl;
  }
}
