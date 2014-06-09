#include "FWCore/PluginManager/interface/ModuleDef.h"

#include "FWCore/Framework/interface/MakerMacros.h"
#include "FWCore/Framework/interface/ModuleFactory.h"
#include "FWCore/Framework/interface/ESProducer.h"

#include "jgomez2/TrackMerging/interface/HiTrackListMerger.h"


using cms::HiTrackListMerger;



DEFINE_FWK_MODULE(HiTrackListMerger);
