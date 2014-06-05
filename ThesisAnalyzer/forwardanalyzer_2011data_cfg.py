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

process.MessageLogger.cerr.FwkReport.reportEvery = 1000


process.source = cms.Source("PoolSource",
#                            fileNames = cms.untracked.vstring('file:/home/jgomez2/EAFE4330-EB64-E211-896F-BCAEC5329719.root')
                            fileNames = cms.untracked.vstring('file:hiHighPt.root')
                            )

process.TFileService = cms.Service("TFileService",
#                                   fileName = cms.string('blah.root')
                                   fileName = cms.string('yay3.root')
                                   )


from Configuration.AlCa.GlobalTag import GlobalTag
process.GlobalTag = GlobalTag(process.GlobalTag, 'GR_R_53_LV6::All', '')


process.HeavyIonGlobalParameters = cms.PSet(
    centralityVariable = cms.string("HFtowers"),
    nonDefaultGlauberModel = cms.string(""),
    centralitySrc = cms.InputTag("hiCentrality")
    )


process.fwdana = cms.EDAnalyzer('ForwardAnalyzer_2011')

process.upcvertexana = cms.EDAnalyzer('UPCVertexAnalyzer',
                                      vertexCollection=cms.string("hiSelectedVertex")
                                      )

process.upcselectedtrackana = cms.EDAnalyzer('UPCTrackAnalyzer',
                                          trackCollection=cms.string("hiGeneralTracks")
                                             )

process.pixeltracks = cms.EDAnalyzer('UPCTrackAnalyzer',
                                     trackCollection=cms.string("hiConformalPixelTracks")
                                     )

process.calotowerana = cms.EDAnalyzer('CaloTowerAnalyzer',
                                      towerCollection=cms.string("CaloTower")
                                      )

process.upccentralityana = cms.EDAnalyzer('UPCCentralityAnalyzer',
                                          centralityVariable=process.HeavyIonGlobalParameters.centralityVariable
                                          )

process.castorana = cms.EDAnalyzer('CastorAnalyzer')

process.trackSequence = cms.Sequence(process.upcvertexana*process.upcselectedtrackana*process.pixeltracks)
process.forwardSequence = cms.Sequence(process.fwdana*process.castorana)
process.caloSequence = cms.Sequence(process.calotowerana)
process.centralitySequence = cms.Sequence(process.upccentralityana)

process.path = cms.Path(process.trackSequence+
                        process.forwardSequence+
                        process.caloSequence+
                        process.centralitySequence
                        )
