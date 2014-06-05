#ifndef FORWARDANALYZER_2011_H
#define FORWARDANALYZER_2011_H

// system include files
#include <string>

// user include files
#include "FWCore/Framework/interface/EDAnalyzer.h"
#include "FWCore/Framework/interface/Event.h"
#include "FWCore/Framework/interface/MakerMacros.h"
#include "FWCore/ParameterSet/interface/ParameterSet.h"
#include "DataFormats/HcalDigi/interface/HcalDigiCollections.h"
#include "DataFormats/HcalRecHit/interface/HcalRecHitCollections.h"
#include "CalibFormats/HcalObjects/interface/HcalCoderDb.h"
#include "CalibFormats/HcalObjects/interface/HcalDbService.h"
#include "CalibFormats/HcalObjects/interface/HcalDbRecord.h"
#include "FWCore/Framework/interface/ESHandle.h"
#include "FWCore/Framework/interface/EventSetup.h"
#include "DataFormats/HcalDetId/interface/HcalZDCDetId.h"
//#include "DataFormats/HeavyIonEvent/interface/CentralityProvider.h"
#include "DataFormats/CaloRecHit/interface/CaloRecHit.h"
#include "DataFormats/HcalDetId/interface/HcalDetId.h"
#include "DataFormats/HcalRecHit/interface/HFRecHit.h"
#include "DataFormats/DetId/interface/DetId.h"
#include "DataFormats/HeavyIonEvent/interface/EvtPlane.h"
#include "DataFormats/Common/interface/Handle.h"


//TFile Service
#include "FWCore/ServiceRegistry/interface/Service.h"
#include "CommonTools/UtilAlgos/interface/TFileService.h"

// L1 bit analyzer
#include "DataFormats/Common/interface/Handle.h"
#include "DataFormats/Common/interface/TriggerResults.h"
#include "DataFormats/L1GlobalTrigger/interface/L1GlobalTriggerReadoutRecord.h"
#include "DataFormats/L1GlobalTrigger/interface/L1GlobalTriggerReadoutSetupFwd.h"
#include "FWCore/Common/interface/TriggerNames.h"
#include "CondFormats/L1TObjects/interface/L1GtTriggerMenu.h"
#include "CondFormats/L1TObjects/interface/L1GtTriggerMenuFwd.h"
#include "CondFormats/DataRecord/interface/L1GtTriggerMenuRcd.h"
#include "HLTrigger/HLTcore/interface/HLTConfigProvider.h"
#include "L1Trigger/GlobalTriggerAnalyzer/interface/L1GtUtils.h"


//Root Classes
#include "TTree.h"
#include "TFile.h"

class ForwardAnalyzer_2011 : public edm::EDAnalyzer {
public:
	explicit ForwardAnalyzer_2011(const edm::ParameterSet&);
	~ForwardAnalyzer_2011();

private:
	virtual void beginJob();
	virtual void analyze(const edm::Event&, const edm::EventSetup&);
private:
	long runBegin,lumibegin,lumiend,evtNo;
	int run, event, lumi;
	std::string startTime;
	std::string *BranchNames;
        int DigiDataADC[180];
        float DigiDatafC[180];
	int BeamData[6];
	
	int Runno;
	edm::Service<TFileService> mFileServer;
	
	TTree* ZDCDigiTree;
	TTree* BeamTree;
	
   
};
DEFINE_FWK_MODULE(ForwardAnalyzer_2011);

#endif
