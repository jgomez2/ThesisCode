import FWCore.ParameterSet.Config as cms
import sys


process = cms.Process("Forward")

process.load("FWCore.MessageService.MessageLogger_cfi")
process.load("Configuration.StandardSequences.FrontierConditions_GlobalTag_cff")
process.load('Configuration/StandardSequences/Reconstruction_cff')
process.load("CondCore.DBCommon.CondDBSetup_cfi")
process.load('Configuration.EventContent.EventContentHeavyIons_cff')
process.load('Configuration.StandardSequences.EndOfProcess_cff')
process.load('Configuration.StandardSequences.GeometryRecoDB_cff')
#process.load('HeavyIonsAnalysis.Configuration.collisionEventSelection_cff')
#process.load('Configuration.StandardSequences.SkimsHeavyIons_cff')
process.load('Configuration/StandardSequences/MagneticField_AutoFromDBCurrent_cff')

process.maxEvents = cms.untracked.PSet( input = cms.untracked.int32(-1) )

process.MessageLogger.cerr.FwkReport.reportEvery = 1


process.source = cms.Source("PoolSource",
#                            fileNames = cms.untracked.vstring('file:/home/jgomez2/EAFE4330-EB64-E211-896F-BCAEC5329719.root')
                            fileNames = cms.untracked.vstring('file:RECO2.root')
                            )

process.TFileService = cms.Service("TFileService",
#                                   fileName = cms.string('blah.root')
                                   fileName = cms.string('yay3.root')
                                   )


from Configuration.AlCa.GlobalTag import GlobalTag
process.GlobalTag = GlobalTag(process.GlobalTag, 'GR_R_53_LV6::All', '')

###########################
###JAIMES ED PRODUCER######
###########################
#process.JaimesTracks = cms.EDProducer('TestProducer')
process.load("ProdTutorial/TestProducer/testproducer_cfi")
process.new_step= cms.Path(process.jaimeTracks)

##########################
### MERGER ################
##########################
process.load("jgomez2/TrackMerging/HiMultipleTrackListMerger_cff")
process.merge_step = cms.Path(process.hiGoodMergedTracks)

#######################################################
####Track Associator###################################
process.load("SimTracker.TrackAssociation.trackingParticleRecoTrackAsssociation_cfi")
process.tpRecoAssochiGoodMergedTracks = process.trackingParticleRecoTrackAsssociation.clone()
process.tpRecoAssochiGoodMergedTracks.label_tr = cms.InputTag("hiGoodMergedTracks")

process.load("SimTracker.TrackAssociation.TrackAssociatorByHits_cfi")
process.TrackAssociatorByHits.SimToRecoDenominator = cms.string('reco')

process.associator_step=cms.Path(process.tpRecoAssochiGoodMergedTracks)
################################################################
###########################################################

process.HeavyIonGlobalParameters = cms.PSet(
    centralityVariable = cms.string("HFtowers"),
    nonDefaultGlauberModel = cms.string(""),
    centralitySrc = cms.InputTag("hiCentrality")
    )


process.fwdana = cms.EDAnalyzer('ForwardAnalyzer_2011')

process.upcvertexana = cms.EDAnalyzer('UPCVertexAnalyzer',
                                      vertexCollection=cms.string("hiSelectedVertex")
                                      )

process.goodmergedtracks = cms.EDAnalyzer('UPCTrackAnalyzer',
                                          trackCollection=cms.string("hiGoodMergedTracks")
                                             )

process.faketracks = cms.EDAnalyzer('UPCTrackAnalyzer',
                                     trackCollection=cms.string("jaimeTracks")
                                     )

process.calotowerana = cms.EDAnalyzer('CaloTowerAnalyzer',
                                      towerCollection=cms.string("CaloTower")
                                      )

process.upccentralityana = cms.EDAnalyzer('UPCCentralityAnalyzer',
                                          centralityVariable=process.HeavyIonGlobalParameters.centralityVariable
                                          )

process.castorana = cms.EDAnalyzer('CastorAnalyzer')


process.analyzer_step = cms.Path(process.upcvertexana
                                 *process.goodmergedtracks
                                 *process.faketracks
                                 *process.calotowerana
                                 *process.upccentralityana
                                 )
#process.trackSequence = cms.Sequence(process.upcvertexana*process.upcselectedtrackana*process.pixeltracks)
#process.forwardSequence = cms.Sequence(process.fwdana*process.castorana)
#process.caloSequence = cms.Sequence(process.calotowerana)
#process.centralitySequence = cms.Sequence(process.upccentralityana)

#Schedule Definition
process.schedule = cms.Schedule(process.merge_step,
                                process.associator_step,
                                process.new_step,
                                process.analyzer_step)



