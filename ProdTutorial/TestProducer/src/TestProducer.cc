#include "ProdTutorial/TestProducer/interface/TestProducer.h"

//
// constants, enums and typedefs
//


//
// static data member definitions
//

//
// constructors and destructor
//
TestProducer::TestProducer(const edm::ParameterSet& iConfig):
 vertexSrc_(iConfig.getParameter<edm::InputTag>("vertexSrc")),
  trackSrc_(iConfig.getParameter<edm::InputTag>("trackSrc")),
  tpFakSrc_(iConfig.getParameter<edm::InputTag>("tpFakSrc")),
  tpEffSrc_(iConfig.getParameter<edm::InputTag>("tpEffSrc")),
  associatorMap_(iConfig.getParameter<edm::InputTag>("associatorMap")),
 //  ptBins_(iConfig.getParameter<std::vector<double> >("ptBins")),
 //etaBins_(iConfig.getParameter<std::vector<double> >("etaBins")),
  dxyErrMax_(iConfig.getParameter<double>("dzErrMax")),
  dzErrMax_(iConfig.getParameter<double>("dzErrMax")),
  ptErrMax_(iConfig.getParameter<double>("ptErrMax")),
  vertexZMax_(iConfig.getParameter<double>("vertexZMax")),
  qualityString_(iConfig.getParameter<std::string>("qualityString"))
{
  
  //Make My Reco Track Collection
  produces<reco::TrackCollection>();
  
  
  
}


TestProducer::~TestProducer()
{
 
   // do anything here that needs to be done at desctruction time
   // (e.g. close files, deallocate resources etc.)

}


//
// member functions
//

// ------------ method called to produce the data  ------------
void
TestProducer::produce(edm::Event& iEvent, const edm::EventSetup& iSetup)
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
   std::sort( vsorted.begin(), vsorted.end(), TestProducer::vtxSort );

   // skip events with no PV, this should not happen
   if( vsorted.size() == 0) return;

   // skip events failing vertex cut
   if( fabs(vsorted[0].z()) > vertexZMax_ ) return;

   //Output
   /*std::auto_ptr<JaimesTrackCollection> pt(new JaimesTrackCollection);
   std::auto_ptr<JaimesTrackCollection> eta(new JaimesTrackCollection);
   std::auto_ptr<JaimesTrackCollection> phi(new JaimesTrackCollection);
   */
   std::auto_ptr<reco::TrackCollection> tracksOut(new reco::TrackCollection);
   

   

   for(edm::View<reco::Track>::size_type i=0; i<tcol->size(); ++i)
     {
       
       edm::RefToBase<reco::Track> track(tcol, i);
       reco::Track* tr=const_cast<reco::Track*>(track.get());
       if( ! passesTrackCuts(*tr, vsorted[0]) ) continue;
       // look for match to simulated particle, use first match if it exists                                 
       std::vector<std::pair<TrackingParticleRef, double> > tp;
       const TrackingParticle *mtp=0;
       if(recSimColl.find(track) != recSimColl.end())
	 {
	 }
       else
	 {
	   const reco::Track & theTrack = * tr;
	   tracksOut->push_back(reco::Track(theTrack));
	 }
     }//end of loop over tracks
   
   iEvent.put(tracksOut);

 
}

// ------------ method called once each job just before starting event loop  ------------
void TestProducer::beginJob()
{}

// ------------ method called once each job just after ending the event loop  ------------
void TestProducer::endJob() {}


bool TestProducer::passesTrackCuts(const reco::Track & track, const reco::Vertex & vertex)
{
  //if ( ! applyTrackCuts_ ) return true;

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
  //  if(fabs(dxy/dxysigma) > dxyErrMax_) return false;
  if(fabs(dz/dzsigma) > dzErrMax_) return false;
  if(track.ptError() / track.pt() > ptErrMax_) return false;

  return true;
}

bool TestProducer::vtxSort( const reco::Vertex &  a, const reco::Vertex & b )
{
  if( a.tracksSize() != b.tracksSize() )
    return  a.tracksSize() > b.tracksSize() ? true : false ;
  else
    return  a.chi2() < b.chi2() ? true : false ;  
}

