import FWCore.ParameterSet.Config as cms

jaimeTracks = cms.EDProducer('TestProducer',
                      trackSrc = cms.InputTag("hiLowPtPixelTracks"),
                      vertexSrc = cms.InputTag("hiSelectedVertex"),
                      tpEffSrc = cms.InputTag('mergedtruth','MergedTrackTruth'),
                      tpFakSrc = cms.InputTag('mergedtruth','MergedTrackTruth'),
                      associatorMap = cms.InputTag('tpRecoAssochiLowPtPixelTracks'),
                      qualityString = cms.string("highPurity"),
                      dxyErrMax = cms.double(3.0),
                      dzErrMax = cms.double(10.0),
                      ptErrMax = cms.double(0.1),
                      vertexZMax = cms.double(10.),
                      chi2Max = cms.double(36.)
                      )
