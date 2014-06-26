#include "ProdTutorial/TestProducer/interface/EfficiencyAnalyzer.h"

EfficiencyAnalyzer::EfficiencyAnalyzer(const edm::ParameterSet& iConfig):   
  vertexSrc_(iConfig.getParameter<edm::InputTag>("vertexSrc")),
  trackSrc_(iConfig.getParameter<edm::InputTag>("trackSrc")),
  tpFakSrc_(iConfig.getParameter<edm::InputTag>("tpFakSrc")),
  tpEffSrc_(iConfig.getParameter<edm::InputTag>("tpEffSrc")),
  associatorMap_(iConfig.getParameter<edm::InputTag>("associatorMap")),
  ptBins_(iConfig.getParameter<std::vector<double> >("ptBins")),
  etaBins_(iConfig.getParameter<std::vector<double> >("etaBins")),
  dxyErrMax_(iConfig.getParameter<double>("dzErrMax")),
  dzErrMax_(iConfig.getParameter<double>("dzErrMax")),
  vertexZMax_(iConfig.getParameter<double>("vertexZMax")),
  ptErrMax_(iConfig.getParameter<double>("ptErrMax")),
  qualityString_(iConfig.getParameter<std::string>("qualityString"))
{
  edm::Service<TFileService> fs;
  initHistos(fs);
}


EfficiencyAnalyzer::~EfficiencyAnalyzer()
{}


//
// member functions
//

// ------------ method called for each event  ------------
void EfficiencyAnalyzer::analyze(const edm::Event& iEvent, const edm::EventSetup& iSetup)
{


   using namespace edm;
   using namespace std;
   using namespace reco;
 
   // obtain collections of simulated particles 
   edm::Handle<TrackingParticleCollection>  TPCollectionHeff, TPCollectionHfake;
   iEvent.getByLabel(tpEffSrc_,TPCollectionHeff);
   iEvent.getByLabel(tpFakSrc_,TPCollectionHfake);

   // obtain association map between tracks and simulated particles
   reco::RecoToSimCollection recSimColl;
   reco::SimToRecoCollection simRecColl;
   edm::Handle<reco::SimToRecoCollection > simtorecoCollectionH;
   edm::Handle<reco::RecoToSimCollection > recotosimCollectionH;
   iEvent.getByLabel(associatorMap_,simtorecoCollectionH);
   simRecColl= *(simtorecoCollectionH.product());
   iEvent.getByLabel(associatorMap_,recotosimCollectionH);
   recSimColl= *(recotosimCollectionH.product());

   // obtain reconstructed tracks
   Handle<edm::View<reco::Track> > tcol;
   iEvent.getByLabel(trackSrc_, tcol);

   // obtain primary vertices
   Handle<std::vector<reco::Vertex> > vertex;
   iEvent.getByLabel(vertexSrc_, vertex);


   // sort the vertcies by number of tracks in descending order
   std::vector<reco::Vertex> vsorted = *vertex;
   std::sort( vsorted.begin(), vsorted.end(), EfficiencyAnalyzer::vtxSort );

   // skip events with no PV, this should not happen
   if( vsorted.size() == 0) return;

   // skip events failing vertex cut
   if( fabs(vsorted[0].z()) > vertexZMax_ ) return;


   // ---------------------
   // loop through reco tracks to fill fake, reco, and secondary histograms
   // ---------------------

   for(edm::View<reco::Track>::size_type i=0; i<tcol->size(); ++i){
    
     edm::RefToBase<reco::Track> track(tcol, i);
     reco::Track* tr=const_cast<reco::Track*>(track.get());
     // skip tracks that fail cuts, using vertex with most tracks as PV       
     if( ! passesTrackCuts(*tr, vsorted[0]) ) continue;

     TotalRecoTracks_->Fill(tr->eta(), tr->pt(), 1);

     // look for match to simulated particle, use first match if it exists
     std::vector<std::pair<TrackingParticleRef, double> > tp;
     const TrackingParticle *mtp=0;
     if(recSimColl.find(track) != recSimColl.end())
     {
       tp = recSimColl[track];
       mtp = tp.begin()->first.get();  
       if( mtp->status() < 0 ) 
       {
         TotalSecondaryTracks_->Fill(tr->eta(), tr->pt(), 1);     
       }
     }
     else
     {
       TotalFakeTracks_->Fill(tr->eta(), tr->pt(), 1);
     }
    
   }


   // ---------------------
   // loop through sim particles to fill matched, multiple,  and sim histograms 
   // ---------------------
   for(TrackingParticleCollection::size_type i=0; i<TPCollectionHeff->size(); i++) 
   {      
     TrackingParticleRef tpr(TPCollectionHeff, i);
     TrackingParticle* tp=const_cast<TrackingParticle*>(tpr.get());
         
     if(tp->status() < 0 || tp->charge()==0) continue; //only charged primaries

     TotalParticles_->Fill(tp->eta(),tp->pt(), 1);

     // find number of matched reco tracks that pass cuts
     std::vector<std::pair<edm::RefToBase<reco::Track>, double> > rt;
     size_t nrec=0;
     if(simRecColl.find(tpr) != simRecColl.end())
     {
       rt = (std::vector<std::pair<edm::RefToBase<reco::Track>, double> >) simRecColl[tpr];
       std::vector<std::pair<edm::RefToBase<reco::Track>, double> >::const_iterator rtit;
       for (rtit = rt.begin(); rtit != rt.end(); ++rtit)
       {
         const reco::Track* tmtr = rtit->first.get();
         if( ! passesTrackCuts(*tmtr, vsorted[0]) ) continue;
         nrec++;
       }
     }
     //if(tp->pt()<1.4) cout<<"Particle has a pT of "<<tp->pt()<<endl;
     if(nrec>0) MatchedParticles_->Fill(tp->eta(),tp->pt(), 1);
     if(nrec>1) MultiMatchedParticles_->Fill(tp->eta(),tp->pt(), 1);
   }


}


// ------------ method called once each job just before starting event loop  ------------
void EfficiencyAnalyzer::beginJob()
{}

void EfficiencyAnalyzer::initHistos(const edm::Service<TFileService> & fs)
{
  //Fake Rate Plots
  TotalRecoTracks_ = fs->make<TH2F>("TotalChargedTrackingParticles","TotalChargedTrackingParticles",etaBins_.size()-1, &etaBins_[0],ptBins_.size()-1, &ptBins_[0]);
  TotalSecondaryTracks_ =fs->make<TH2F>("TotalMatchedParticles","TotalMatchedParticles",etaBins_.size()-1,&etaBins_[0],ptBins_.size()-1, &ptBins_[0]);
  TotalFakeTracks_ =fs->make<TH2F>("TotalMultiMatchedParticles","TotalMultiMatchedParticles",etaBins_.size()-1, &etaBins_[0],ptBins_.size()-1, &ptBins_[0]);
  
  
  //Efficiency Plots
  TotalParticles_ = fs->make<TH2F>("TotalChargedTrackingParticles","TotalChargedTrackingParticles",etaBins_.size()-1, &etaBins_[0],ptBins_.size()-1, &ptBins_[0]);
  MatchedParticles_ =fs->make<TH2F>("TotalMatchedParticles","TotalMatchedParticles",etaBins_.size()-1, &etaBins_[0],ptBins_.size()-1, &ptBins_[0]);
  MultiMatchedParticles_ =fs->make<TH2F>("TotalMultiMatchedParticles","TotalMultiMatchedParticles",etaBins_.size()-1, &etaBins_[0],ptBins_.size()-1, &ptBins_[0]);

}//end of making histos


bool EfficiencyAnalyzer::passesTrackCuts(const reco::Track & track, const reco::Vertex & vertex)
{
  // if ( ! applyTrackCuts_ ) return true;

  math::XYZPoint vtxPoint(0.0,0.0,0.0);
  double vzErr =0.0, vxErr=0.0, vyErr=0.0;
  vtxPoint=vertex.position();
  vzErr=vertex.zError();
  vxErr=vertex.xError();
  vyErr=vertex.yError();

  double dxy=0.0, dz=0.0, dxysigma=0.0, dzsigma=0.0;
  dxy = track.dxy(vtxPoint);
  dz = track.dz(vtxPoint);
  dxysigma = sqrt(track.d0Error()*track.d0Error()+vxErr*vyErr);
  dzsigma = sqrt(track.dzError()*track.dzError()+vzErr*vzErr);
 
  if(track.quality(reco::TrackBase::qualityByName(qualityString_)) != 1)
    return false;
  //if(fabs(dxy/dxysigma) > dxyErrMax_) return false;
  if(fabs(dz/dzsigma) > dzErrMax_) return false;
  if(track.ptError() / track.pt() > ptErrMax_) return false;

  return true;
}

bool EfficiencyAnalyzer::vtxSort( const reco::Vertex &  a, const reco::Vertex & b )
{
  if( a.tracksSize() != b.tracksSize() )
    return  a.tracksSize() > b.tracksSize() ? true : false ;
  else
    return  a.chi2() < b.chi2() ? true : false ;  
}//end of vtx sort function




