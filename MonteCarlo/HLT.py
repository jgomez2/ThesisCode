# Auto generated configuration file
# using: 
# Revision: 1.381.2.28 
# Source: /local/reps/CMSSW/CMSSW/Configuration/PyReleaseValidation/python/ConfigBuilder.py,v 
# with command line options: Hydjet_Quenched_MinBias_2760GeV_cfi --conditions auto:starthi_HIon --scenario HeavyIons -n 1 --eventcontent RECODEBUG --relval 2000,5 -s DIGI,L1,DIGI2RAW,HLT,RAW2DIGI,RECO --no_exec
import FWCore.ParameterSet.Config as cms

process = cms.Process('HLT')

# import of standard configurations
process.load('Configuration.StandardSequences.Services_cff')
process.load('SimGeneral.HepPDTESSource.pythiapdt_cfi')
process.load('FWCore.MessageService.MessageLogger_cfi')
process.load('Configuration.EventContent.EventContentHeavyIons_cff')
process.load('SimGeneral.MixingModule.mixNoPU_cfi')
process.load('Configuration.StandardSequences.GeometryRecoDB_cff')
process.load('Configuration.StandardSequences.MagneticField_38T_cff')
process.load('Configuration.StandardSequences.Digi_cff')
process.load('Configuration.StandardSequences.SimL1Emulator_cff')
process.load('Configuration.StandardSequences.DigiToRaw_cff')
process.load('HLTrigger.Configuration.HLT_HIon_cff')
process.load('Configuration.StandardSequences.RawToDigi_cff')
process.load('Configuration.StandardSequences.ReconstructionHeavyIons_cff')
process.load('Configuration.StandardSequences.EndOfProcess_cff')
process.load('Configuration.StandardSequences.FrontierConditions_GlobalTag_cff')

process.maxEvents = cms.untracked.PSet(
    input = cms.untracked.int32(-1)
)

# Input source
process.source = cms.Source("PoolSource",
                            secondaryFileNames = cms.untracked.vstring(),
                            #fileNames = cms.untracked.vstring('file:Hydjet_Quenched_MinBias_2760GeV_cfi_SIM.root')
                            fileNames = cms.untracked.vstring('file:Hydjet_Quenched_MinBias_2760GeV_cfi_GEN_SIM.root')
                            )

process.options = cms.untracked.PSet(wantSummary = cms.untracked.bool(True))

# Production Info
process.configurationMetadata = cms.untracked.PSet(
    version = cms.untracked.string('$Revision: 1.381.2.28 $'),
    annotation = cms.untracked.string('Hydjet_Quenched_MinBias_2760GeV_cfi nevts:1'),
    name = cms.untracked.string('PyReleaseValidation')
    )

###########################
###JAIMES ED PRODUCER######
###########################
#process.JaimesTracks = cms.EDProducer('TestProducer')
process.load("ProdTutorial/TestProducer/testproducer_cfi")
process.new_step= cms.Path(process.jaimeTracks)


############################
######PLOT MAKER?##########
##########################
process.load("ProdTutorial/TestProducer/efficiencyanalyzer_cfi")
process.newer_step=cms.Path(process.effAna)


##########################
### MERGER ################
##########################
#process.load("jgomez2/TrackMerging/HiMultipleTrackListMerger_cff")
#process.merge_step = cms.Path(process.hiGoodMergedTracks)


#######################################################
####Track Associator###################################
#process.load("SimTracker.TrackAssociation.trackingParticleRecoTrackAsssociation_cfi")
#process.tpRecoAssochiGeneralTracks = process.trackingParticleRecoTrackAsssociation.clone()
#process.tpRecoAssochiGeneralTracks.label_tr = cms.InputTag("hiGeneralTracks")

#process.load("SimTracker.TrackAssociation.TrackAssociatorByHits_cfi")
#process.TrackAssociatorByHits.SimToRecoDenominator = cms.string('reco')

#process.associator_step=cms.Path(process.tpRecoAssochiGeneralTracks)
################################################################
###########################################################

#######################################################
####Track Associator###################################
process.load("SimTracker.TrackAssociation.trackingParticleRecoTrackAsssociation_cfi")
process.tpRecoAssochiLowPtPixelTracks = process.trackingParticleRecoTrackAsssociation.clone()
process.tpRecoAssochiLowPtPixelTracks.label_tr = cms.InputTag("hiLowPtPixelTracks")

process.load("SimTracker.TrackAssociation.TrackAssociatorByHits_cfi")
process.TrackAssociatorByHits.SimToRecoDenominator = cms.string('reco')

process.associator_step=cms.Path(process.tpRecoAssochiLowPtPixelTracks)
################################################################
########################################################### 


############################################################
########### EVENT FILTER ###################################
# Minimum bias trigger selection (later runs)
process.load("HLTrigger.HLTfilters.hltHighLevel_cfi")
process.hltMinBiasHFOrBSC = process.hltHighLevel.clone()
process.hltMinBiasHFOrBSC.HLTPaths = ["HLT_HIMinBiasHfOrBSC_v1"]



# Common offline event selection
process.load("HeavyIonsAnalysis.Configuration.collisionEventSelection_cff")
#process.path = cms.Path(process.nameOfHltSelection*process.collisionEventSelection*process.nameOfAnalysisSequence)

# Coincidence of HF towers (threshold 3)
process.load("HeavyIonsAnalysis.Configuration.hfCoincFilter_cff")
#process.filter_step = cms.Path(process.hfCoincFilter3)

# selection of non-fake vertex (i.e. at least one pixel track)
process.primaryVertexFilter = cms.EDFilter("VertexSelector",
                                           src = cms.InputTag("hiSelectedVertex"),
                                           cut = cms.string("!isFake && abs(z) <= 10 && position.Rho <= 2"),
                                           filter = cms.bool(True),   # otherwise it won't filter the events, instead making an empty vertex collection
                                           )

# Cluster-shape filter re-run offline
process.load("HLTrigger.special.hltPixelClusterShapeFilter_cfi")
process.hltPixelClusterShapeFilter.inputTag = "siPixelRecHits"
#process.filter_step = cms.Path(process.hfCoincFilter3*process.siPixelRecHits*process.hltPixelClusterShapeFilter)


# Reject BSC beam halo L1 technical bits
process.load("L1TriggerConfig.L1GtConfigProducers.L1GtTriggerMaskTechTrigConfig_cff")
process.load("HLTrigger.HLTfilters.hltLevel1GTSeed_cfi")
process.noBSChalo = process.hltLevel1GTSeed.clone(
    L1TechTriggerSeeding = cms.bool(True),
    L1SeedsLogicalExpression = cms.string('NOT (36 OR 37 OR 38 OR 39)')
    )

process.filter_step = cms.Path(process.hltMinBiasHFOrBSC*process.hfCoincFilter3*process.siPixelRecHits*process.hltPixelClusterShapeFilter*process.noBSChalo*process.primaryVertexFilter)

process.track_step= cms.Path(process.hiConformalPixelTracks*process.hiPixelOnlyStepSelector*process.hiHighPtStepSelector*process.hiLowPtPixelTracks)
###############################################################
###############################################################

###SO I CAN GET EFFICIECNY PLOTS
process.TFileService = cms.Service("TFileService",
                                   fileName = cms.string('trackefficiency.root')
                                   )

# Output definition

process.RECODEBUGoutput = cms.OutputModule("PoolOutputModule",
                                           splitLevel = cms.untracked.int32(0),
                                           eventAutoFlushCompressedSize = cms.untracked.int32(5242880),
                                           outputCommands = process.RECODEBUGEventContent.outputCommands,
                                           fileName = cms.untracked.string('WithHisto.root'),
                                           #SelectEvents = cms.untracked.PSet(SelectEvents = cms.vstring('filter_step')),
                                           dataset = cms.untracked.PSet(
    filterName = cms.untracked.string(''),
    dataTier = cms.untracked.string('')
    )
                                           )


###SO I CAN GET EFFICIECNY PLOTS
process.TFileService = cms.Service("TFileService",
                                   fileName = cms.string('trackefficiency.root')
                                   )

# Additional output definition

# Other statements
from Configuration.AlCa.GlobalTag import GlobalTag
process.GlobalTag = GlobalTag(process.GlobalTag, 'auto:starthi_HIon', '')

# Path and EndPath definitions
process.digitisation_step = cms.Path(process.pdigi)
process.L1simulation_step = cms.Path(process.SimL1Emulator)
process.digi2raw_step = cms.Path(process.DigiToRaw)
process.raw2digi_step = cms.Path(process.RawToDigi)
process.reconstruction_step = cms.Path(process.reconstructionHeavyIons)
process.endjob_step = cms.EndPath(process.endOfProcess)
process.RECODEBUGoutput_step = cms.EndPath(process.RECODEBUGoutput)

# Schedule definition
process.schedule = cms.Schedule(process.digitisation_step,
                                process.L1simulation_step,
				process.digi2raw_step)
process.schedule.extend(process.HLTSchedule)
process.schedule.extend([process.raw2digi_step,
                         process.reconstruction_step,
                         #process.filter_step,
                         #process.pixel_step,
                         #process.merge_step,
                         process.track_step,
                         process.associator_step,
                         process.newer_step,
                         process.new_step,
                         process.endjob_step,
                         process.RECODEBUGoutput_step])

# customisation of the process.

# Automatic addition of the customisation function from HLTrigger.Configuration.customizeHLTforMC
from HLTrigger.Configuration.customizeHLTforMC import customizeHLTforMC 

#call to customisation function customizeHLTforMC imported from HLTrigger.Configuration.customizeHLTforMC
process = customizeHLTforMC(process)

# End of customisation functions

#Drop everything
process.RECODEBUGoutput.outputCommands = ['drop *_*_*_*']

##Keeping tracks and pixel tracks
#process.RECODEBUGoutput.outputCommands += ['keep *_hiGeneralTracks_*_*']
#process.RECODEBUGoutput.outputCommands += ['keep *_hiConformalPixelTracks_*_*']
#process.RECODEBUGoutput.outputCommands +=['keep *_hiGoodMergedTracks_*_*']
process.RECODEBUGoutput.outputCommands +=['keep *_jaimeTracks_*_*']
##Keep Vertex Info
process.RECODEBUGoutput.outputCommands += ['keep *_hiSelectedVertex_*_*']
##Keep CaloTowers
process.RECODEBUGoutput.outputCommands += ['keep *_towerMaker_*_*']
##Keep ZDC Digis
#process.RECODEBUGoutput.outputCommands += ['keep *_hcalDigis_*_*']
##Keep Castor RecHits
#process.RECODEBUGoutput.outputCommands += ['keep *_castorreco_*_*']
##Keep Centrality
process.RECODEBUGoutput.outputCommands += ['keep *_hiCentrality_*_*']
##Associated Tracks
#process.RECODEBUGoutput.outputCommands += ['keep *_tpRecoAssochiGoodMergedTracks_*_*']

process.RECODEBUGoutput.outputCommands += ['keep *_hiLowPtPixelTracks_*_*']
