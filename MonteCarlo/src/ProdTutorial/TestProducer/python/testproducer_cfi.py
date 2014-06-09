import FWCore.ParameterSet.Config as cms

jaimeTracks = cms.EDProducer('TestProducer',
                             trackSrc = cms.InputTag("hiGoodMergedTracks"),
                             vertexSrc = cms.InputTag("hiSelectedVertex"),
                             tpEffSrc = cms.InputTag('mergedtruth','MergedTrackTruth'),
                             tpFakSrc = cms.InputTag('mergedtruth','MergedTrackTruth'),
                             associatorMap = cms.InputTag('tpRecoAssochiGoodMergedTracks')
                             )
