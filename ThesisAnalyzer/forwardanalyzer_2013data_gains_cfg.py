import FWCore.ParameterSet.Config as cms
import sys

#if len(sys.argv) > 2:
#    file=open(sys.argv[2])
#    outfile=sys.argv[3]

process = cms.Process("Forward")

process.load("FWCore.MessageService.MessageLogger_cfi")
process.load("Configuration.StandardSequences.FrontierConditions_GlobalTag_cff")
process.load('Configuration/StandardSequences/Reconstruction_cff')
process.load("RecoLocalCalo.HcalRecProducers.HcalHitReconstructor_hf_cfi")
process.load("RecoLocalCalo.HcalRecProducers.HcalHitReconstructor_zdc_cfi")
process.load("EventFilter.CastorRawToDigi.CastorRawToDigi_cfi")
process.load("RecoLocalCalo.CastorReco.CastorSimpleReconstructor_cfi")
process.load("CondCore.DBCommon.CondDBSetup_cfi")


process.maxEvents = cms.untracked.PSet( input = cms.untracked.int32(-1) )

process.MessageLogger.cerr.FwkReport.reportEvery = 1

#process.source = cms.Source("PoolSource",
#                           fileNames = cms.untracked.vstring(file.readlines()))

process.source = cms.Source("PoolSource",
                            fileNames = cms.untracked.vstring('file:/home/jgomez2/EAFE4330-EB64-E211-896F-BCAEC5329719.root')
                           # fileNames = cms.untracked.vstring('file:/home/jgomez2/CMSSW_5_3_8_HI_patch2/src/Analyzers/ForwardAnalyzer/2011run182398_10_1_6Lr.root')
                            )

process.TFileService = cms.Service("TFileService",
                                   #  fileName = cms.string(outfile)
                                   fileName = cms.string('ZDCTree_Calib_fC_test.root')
                                   )

process.ZDCEventContent = cms.PSet(
    outputCommands = cms.untracked.vstring(
        'drop *',
        'keep ZDC*_*_*_*'
    )
)
process.output = cms.OutputModule(
    "PoolOutputModule",
    splitLevel = cms.untracked.int32(0),
    outputCommands = process.ZDCEventContent.outputCommands,
    fileName = cms.untracked.string('ZDCReco_Calib_fC_test.root'),
    dataset = cms.untracked.PSet(
        dataTier = cms.untracked.string('RECO'),
        filterName = cms.untracked.string('')
    )
                                   )



#process.GlobalTag.globaltag = 'GR_R_44_V10::All'
process.GlobalTag.globaltag = 'GR_R_53_V19::All'

## begin comment this out if you are Jaime
##-- Customized conditions
from CondCore.DBCommon.CondDBSetup_cfi import *

#----------------------------------------------------- replaing conditions
process.es_ascii = cms.ESSource("HcalTextCalibrations",
                                    input = cms.VPSet(
             cms.PSet(
                 object = cms.string('Gains'),
                              file =
                 cms.FileInPath('data/Gains_Run210498_211831.txt')
                          ),
                      cms.PSet(
                 object = cms.string('LongRecoParams'),
                              file =
                 cms.FileInPath('data/LongRecoParams_Runs210737_211831.txt')
                          ),
                      cms.PSet(
                 object = cms.string('MCParams'),
                              file =
                 cms.FileInPath('data/DumpMCParams_Run211831.txt')
                          )
                 )
                                )

process.es_prefer = cms.ESPrefer('HcalTextCalibrations','es_ascii')
# end comment this out if you are Jaime

process.HeavyIonGlobalParameters=cms.PSet(centralityVariable= cms.string("PixelHits"),#HFhits"),#"PixelHits"),
                                          centralitySrc = cms.InputTag("hiCentrality")
                                          )

process.hltbitanalysis = cms.EDAnalyzer("HLTBitAnalyzer",
                                        ### Trigger objects
                                        l1GctHFBitCounts                = cms.InputTag("gctDigis"),
                                        l1GctHFRingSums                 = cms.InputTag("gctDigis"),
                                        l1GtObjectMapRecord             = cms.InputTag("hltL1GtObjectMap::HLT"),
                                        l1GtReadoutRecord               = cms.InputTag("gtDigis::RECO"),
                                        
                                        l1extramc                       = cms.string('l1extraParticles'),
                                        l1extramu                       = cms.string('l1extraParticles'),
                                        hltresults                      = cms.InputTag("TriggerResults::HLT"),
                                        HLTProcessName                  = cms.string("HLT"),
                                        UseTFileService                 = cms.untracked.bool(True),
                                        
                                        ### Run parameters
                                        RunParameters = cms.PSet(
    HistogramFile = cms.untracked.string('ZDCTree_Calib_fC_test.root')
    )
                                        )##end of HLT


process.fwdana = cms.EDAnalyzer('ForwardAnalyzer')

process.upcvertexana = cms.EDAnalyzer('UPCVertexAnalyzer',
                                      vertexCollection=cms.string("offlinePrimaryVerticesWithBS")
                                      )
process.upcgeneraltrackana = cms.EDAnalyzer('UPCTrackAnalyzer',
                                            trackCollection=cms.string("generalTracks")
                                            )

process.upcpixeltrackana = cms.EDAnalyzer('UPCTrackAnalyzer',
                                          trackCollection=cms.string("pixelTracks")
                                          )
process.upccentralityana = cms.EDAnalyzer('UPCCentralityAnalyzer',
                                          centralityVariable=process.HeavyIonGlobalParameters.centralityVariable
                                          )
process.zdcreco.lowGainFrac = 8.6

process.trackSequence = cms.Sequence(process.upcgeneraltrackana+process.upcpixeltrackana+process.upcvertexana)
process.forwardSequence = cms.Sequence(process.fwdana)
process.triggerSequence = cms.Sequence(process.hltbitanalysis)
process.centralitySequence = cms.Sequence(process.upccentralityana)

# process.path = cms.Path(process.zdcreco+process.trackSequence+
#                         process.forwardSequence+
#                         process.triggerSequence
#                         )
process.out_step = cms.EndPath(process.output)

process.path = cms.Path(process.zdcreco+process.trackSequence+
                         process.forwardSequence+
                         process.triggerSequence
                         )
cms.Schedule(process.path,process.out_step)
                        
                        
