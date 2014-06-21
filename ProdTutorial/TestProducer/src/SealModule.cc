#include "FWCore/PluginManager/interface/ModuleDef.h"

#include "FWCore/Framework/interface/MakerMacros.h"
#include "FWCore/Framework/interface/ModuleFactory.h"
#include "FWCore/Framework/interface/ESProducer.h"

#include "ProdTutorial/TestProducer/interface/TestProducer.h"
#include "ProdTutorial/TestProducer/interface/EfficiencyAnalyzer.h"


DEFINE_FWK_MODULE(TestProducer);
DEFINE_FWK_MODULE(EfficiencyAnalyzer);
