import FWCore.ParameterSet.Config as cms

trackana = cms.EDAnalyzer('UPCTrackAnalyzer',
                          trackCollection=cms.string("hiLowPtPixelTracks"),
                          qualityString = cms.string("highPurity"),
                          dzErrMax = cms.double(10.0),
                          chi2Max = cms.double(36.0)
                          )
