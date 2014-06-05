//////////////////////////////////////////////////////////////////////////
///////////////////////completely ripped off from////////////////////////
//   PPPPPPP            AAAAAAAAAAAA             TTTTTTTTTTTTTTTTTTTTTTTT  
/// PP    PP            AAA      AAA             TTTTTTTTTTTTTTTTTTTTTTTT     
// PP     PP            AAA      AAA                        TTT
// PP    PPP            AAA      AAA                        TTT
// PP   PPP             AAA      AAA                        TTT
// PP  PPP              AAAAAAAAAAAA                        TTT
// PP PPP               AAAAAAAAAAAA                        TTT
// PPP                  AAA      AAA                        TTT
// PP                   AAA      AAA                        TTT
// PP                   AAA      AAA                        TTT
// PP                   AAA      AAA                        TTT
// PP                   AAA      AAA                        TTT
// PP                   AAA      AAA                        TTT
//
// from University of Kansas.
/////////////////////////////////////////////////////////////////////////

#ifndef UPCTRACKANALYZER_H
#define UPCTRACKANALYZER_H

#include <string>

#include "FWCore/Framework/interface/EDAnalyzer.h"
#include "FWCore/Framework/interface/Event.h"
#include "FWCore/Framework/interface/EventSetup.h"
#include "FWCore/Framework/interface/MakerMacros.h"
#include "FWCore/ParameterSet/interface/ParameterSet.h"
#include "DataFormats/TrackReco/interface/Track.h"
#include "DataFormats/TrackReco/interface/TrackFwd.h"
#include "DataFormats/VertexReco/interface/Vertex.h"
#include "DataFormats/VertexReco/interface/VertexFwd.h"

//TFile Service
#include "FWCore/ServiceRegistry/interface/Service.h"
#include "CommonTools/UtilAlgos/interface/TFileService.h"

//Root Classes
#include "TTree.h"
#include "TFile.h"

#include <vector>
#include "Math/Vector3D.h"
using std::vector;

using namespace reco;
using namespace std;

class UPCTrackAnalyzer : public edm::EDAnalyzer{
public:
	explicit UPCTrackAnalyzer(const edm::ParameterSet&);
	~UPCTrackAnalyzer();
private:
	virtual void beginJob();
	virtual void analyze(const edm::Event&, const edm::EventSetup&);
	virtual void getTracks(edm::Handle<TrackCollection>,edm::Handle<reco::VertexCollection>,
             vector<int>&, vector<double>&, vector<double>&, 
             vector<double>&, vector<double>&, vector<double>&, vector<double>&,
             vector<double>&, vector<double>&, vector<double>&, vector<double>&,
	     vector<double>&, vector<double>&, vector<double>&, vector<double>&, 
	     vector<double>&, double&, double&);
	
	edm::Service<TFileService> mFileServer;

	string trackCollection; 

	int nTracks;
	vector<int> ndof;
	vector<double> chi2,x, y, z, 
	   pt, qoverp, lambda, phi,
	   varQoverp, varLambda, varPhi,
	  covarQoverpLambda,covarQoverpPhi,covarLambdaPhi,eta;

	TTree* TrakTree;

	double chi2_;
	double dzerr_;

///New Vertex And track quality cuts


};
DEFINE_FWK_MODULE(UPCTrackAnalyzer);
#endif
