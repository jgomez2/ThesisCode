#ifndef TESTPRODUCER_H
#define TESTPRODUCER_H

// system include files
#include <memory>

// user include files
#include "FWCore/Framework/interface/Frameworkfwd.h"
#include "FWCore/Framework/interface/EDProducer.h"

#include "FWCore/Framework/interface/Event.h"
#include "FWCore/Framework/interface/MakerMacros.h"

#include "FWCore/ParameterSet/interface/ParameterSet.h"

#include "DataFormats/TrackReco/interface/Track.h"
#include "DataFormats/TrackReco/interface/TrackFwd.h"
#include <vector>
#include "Math/Vector3D.h"

#include "FWCore/Framework/interface/MakerMacros.h"
#include "FWCore/ServiceRegistry/interface/Service.h"
#include "CommonTools/UtilAlgos/interface/TFileService.h"
//#include "DataFormats/HeavyIonEvent/interface/CentralityProvider.h"
#include <DataFormats/VertexReco/interface/Vertex.h>
#include <DataFormats/VertexReco/interface/VertexFwd.h>
#include <DataFormats/TrackReco/interface/Track.h>
#include <DataFormats/TrackReco/interface/TrackFwd.h>
#include "SimDataFormats/TrackingAnalysis/interface/TrackingParticle.h"
#include "SimDataFormats/TrackingAnalysis/interface/TrackingParticleFwd.h"
#include "SimTracker/Records/interface/TrackAssociatorRecord.h"
#include "DataFormats/RecoCandidate/interface/TrackAssociation.h"
#include "SimTracker/TrackAssociation/interface/TrackAssociatorByHits.h"



//
// class declaration
//

class TestProducer : public edm::EDProducer {
public:
  explicit TestProducer(const edm::ParameterSet&);
  ~TestProducer();
  static bool vtxSort( const reco::Vertex &  a, const reco::Vertex & b );
  
private:
  virtual void beginJob() ;
  virtual void produce(edm::Event&, const edm::EventSetup&);
  virtual void endJob() ;
  bool passesTrackCuts(const reco::Track & track, const reco::Vertex & vertex);
  
  // ----------member data ---------------------------
  //typedef std::vector<float> JaimesTrackCollection;
  
  edm::InputTag vertexSrc_;
  edm::InputTag trackSrc_;
  edm::InputTag tpFakSrc_;
  edm::InputTag tpEffSrc_;
  edm::InputTag associatorMap_;

  double vertexZMax_;
  std::string qualityString_;
  double dxyErrMax_;
  double dzErrMax_;
  double ptErrMax_;

};

#endif
