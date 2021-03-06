


// system include files
#include <memory>

// user include files
#include "FWCore/Framework/interface/Frameworkfwd.h"
#include "FWCore/Framework/interface/EDAnalyzer.h"

#include "FWCore/Framework/interface/Event.h"
#include "FWCore/Framework/interface/MakerMacros.h"

#include "FWCore/ParameterSet/interface/ParameterSet.h"
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

#include "TH2F.h"
//
// class declaration
//

class EfficiencyAnalyzer : public edm::EDAnalyzer {
   public:
      explicit EfficiencyAnalyzer(const edm::ParameterSet&);
      ~EfficiencyAnalyzer();

      static bool vtxSort( const reco::Vertex &  a, const reco::Vertex & b );

   private:
      virtual void beginJob() ;
      virtual void analyze(const edm::Event&, const edm::EventSetup&);
      bool passesTrackCuts(const reco::Track & track, const reco::Vertex & vertex);
      void initHistos(const edm::Service<TFileService> & fs);
      // ----------member data ---------------------------
  edm::InputTag vertexSrc_;
  edm::InputTag trackSrc_;
  edm::InputTag tpFakSrc_;
  edm::InputTag tpEffSrc_;
  edm::InputTag associatorMap_;

  std::vector<double> ptBins_;
  std::vector<double> etaBins_;
  bool isPixel;
  double vertexZMax_;
  std::string qualityString_;
  double dxyErrMax_;
  double dzErrMax_;
  double ptErrMax_;
  double chi2Max_;
  //For Fake Rate
  TH2F *TotalRecoTracks_;
  TH2F *TotalSecondaryTracks_;
  TH2F *TotalFakeTracks_;
  
  //For Efficiency
  TH2F *TotalParticles_;
  TH2F *MatchedParticles_;
  TH2F *MultiMatchedParticles_;

};
