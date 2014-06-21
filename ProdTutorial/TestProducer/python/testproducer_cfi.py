import FWCore.ParameterSet.Config as cms

jaimeTracks = cms.EDProducer('TestProducer',
                      trackSrc = cms.InputTag("hiGoodMergedTracks"),
                      vertexSrc = cms.InputTag("hiSelectedVertex"),
                      tpEffSrc = cms.InputTag('mergedtruth','MergedTrackTruth'),
                      tpFakSrc = cms.InputTag('mergedtruth','MergedTrackTruth'),
                      associatorMap = cms.InputTag('tpRecoAssochiGoodMergedTracks'),
                      qualityString = cms.string("highPurity"),
                      dxyErrMax = cms.double(3.0),
                      dzErrMax = cms.double(3.0),
                      ptErrMax = cms.double(0.1),
                      vertexZMax = cms.double(10.)
                      )
