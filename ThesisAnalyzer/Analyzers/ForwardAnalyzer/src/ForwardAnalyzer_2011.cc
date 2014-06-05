// -*- C++ -*-
//
// Package:    ForwardAnalyzer
// Class:      ForwardAnalyzer
//
/**\class ForwardAnalyzer ForwardAnalyzer.cc Analyzers/ForwardAnalyzer/src/ForwardAnalyzer.cc

Description: A simple analyzer which can read in Reco or RAW data and makes trees with Reco information and Digi information as well for all of the forward detectors.

90% of this was shamelessly stolen from Pat Kenny's (Kansas) Analyzer

Implementation:
This can be run out of the box with the test cfg or can be installed into a crab.cfg
*/
//
// Original Author: Jaime Arturo Gomez (University of Maryland)
//         Created:  Wed Jan  9 14:43:26 EST 2013
// $Id: ForwardAnalyzer.cc,v 1.14 2013/04/09 19:48:01 jgomez2 Exp $
//
//
#include "Analyzers/ForwardAnalyzer/interface/ForwardAnalyzer_2011.h"
#include "DataFormats/HeavyIonEvent/interface/CentralityBins.h"
#include "DataFormats/HeavyIonEvent/interface/Centrality.h"
#include <iostream>

//static const float HFQIEConst = 4.0;
//static const float HFQIEConst = 2.6;
//static const float EMGain  = 0.025514;
//static const float HADGain = 0.782828;

using namespace edm;
using namespace std;

ForwardAnalyzer_2011::ForwardAnalyzer_2011(const ParameterSet& iConfig)
{
  runBegin = -1;
  evtNo = 0;
  lumibegin = 0;
  lumiend = 0;
  startTime = "Not Avaliable";
}

ForwardAnalyzer_2011::~ForwardAnalyzer_2011(){}

void ForwardAnalyzer_2011::analyze(const Event& iEvent, const EventSetup& iSetup)
{
  using namespace edm;
  using namespace reco;
  using namespace std;
  ++evtNo;
  time_t a = (iEvent.time().value()) >> 32; // store event info
  event = iEvent.id().event();
  run = iEvent.id().run();
  lumi = iEvent.luminosityBlock();



  if (runBegin < 0) {         // parameters for the first event
    startTime = ctime(&a);
    lumibegin = lumiend = lumi;
    runBegin = iEvent.id().run();
    Runno=iEvent.id().run();
  }
  if (lumi < lumibegin)lumibegin = lumi;
  if (lumi > lumiend)lumiend = lumi;

  BeamData[0]=iEvent.bunchCrossing();
  BeamData[1]=lumi;
  BeamData[2]=run;
  BeamData[3]=event;


  BeamTree->Fill();

  for (int z=0;z<180;z++)
    {
      DigiDatafC[z]=-999;
      DigiDataADC[z]=-999;
    }



  Handle<ZDCDigiCollection> zdc_digi_h;
  ESHandle<HcalDbService> conditions;
  iEvent.getByType(zdc_digi_h);


  const ZDCDigiCollection *zdc_digi = zdc_digi_h.failedToGet()? 0 : &*zdc_digi_h;

  iSetup.get<HcalDbRecord>().get(conditions);

  if(zdc_digi){
    for(int i=0; i<180; i++){DigiDatafC[i]=0;DigiDataADC[i]=0;}

    for (ZDCDigiCollection::const_iterator j=zdc_digi->begin();j!=zdc_digi->end();j++){
      const ZDCDataFrame digi = (const ZDCDataFrame)(*j);
      int iSide      = digi.id().zside();
      int iSection   = digi.id().section();
      int iChannel   = digi.id().channel();
      int chid = (iSection-1)*5+(iSide+1)/2*9+(iChannel-1);

      const HcalQIEShape* qieshape=conditions->getHcalShape();
      const HcalQIECoder* qiecoder=conditions->getHcalCoder(digi.id());
      CaloSamples caldigi;
      HcalCoderDb coder(*qiecoder,*qieshape);

      coder.adc2fC(digi,caldigi);

      int fTS = digi.size();
      for (int i = 0; i < fTS; ++i) {
        DigiDatafC[i+chid*10] = caldigi[i];
        DigiDataADC[i+chid*10] = digi[i].adc();
      }
    }

    ZDCDigiTree->Fill();
  }

}//end of Analyze


void ForwardAnalyzer_2011::beginJob(){
  mFileServer->file().SetCompressionLevel(9);
  mFileServer->file().cd();

  string bnames[] = {"negEM1","negEM2","negEM3","negEM4","negEM5",
                     "negHD1","negHD2","negHD3","negHD4",
                     "posEM1","posEM2","posEM3","posEM4","posEM5",
                     "posHD1","posHD2","posHD3","posHD4"};
  BranchNames=bnames;
  ZDCDigiTree = new TTree("ZDCDigiTree","ZDC Digi Tree");

  BeamTree = new TTree("BeamTree","Beam Tree");

  for(int i=0; i<18; i++){
    ZDCDigiTree->Branch((bnames[i]+"fC").c_str(),&DigiDatafC[i*10],(bnames[i]+"cFtsz[10]/F").c_str());
    ZDCDigiTree->Branch((bnames[i]+"ADC").c_str(),&DigiDataADC[i*10],(bnames[i]+"ADCtsz[10]/I").c_str());
  }


  BeamTree->Branch("BunchXing",&BeamData[0],"BunchXing/I");
  BeamTree->Branch("LumiBlock",&BeamData[1],"LumiBlock/I");
  BeamTree->Branch("Run",&BeamData[2],"Run/I");
  BeamTree->Branch("Event",&BeamData[3],"Event/I");

}
