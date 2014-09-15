##################################################################################
# Version 4.10	$Revision: 168 $
# $Date: 12/12/02 5:01p $
# $Author: Debby $
#
# $Workfile: ixTclSetup.tcl $ - required file for package req IxTclHal
#
#   Copyright © 1997 - 2005 by IXIA
#   All Rights Reserved.
#
#	Revision Log:
#	10-29-2002      DHG     Initial Release
#
# Description: Package initialization file.
#              This file is executed when you use "package require IxTclHal" to
#              load the IxTclHal library package. It sets up the Tcl-only variables
#              and is called by the client and server side ixTclHal.tcl files.
#
# Copyright © 1997 - 2005 by IXIA.
# All Rights Reserved.
#
#############################################################################################

set env(IXTCLHAL_LIBRARY) [file dirname [info script]]

proc PromptIxia {} {
        puts -nonewline "[pwd]> "
}

# This flag will be set when anyone calls cleanUp proc
set cleanUpDone 0

#  Not REQUIRED --- this is taken care of below..... source [file join $env(IXTCLHAL_LIBRARY) ixiarc.tcl]

set genPath [file join $env(IXTCLHAL_LIBRARY) Generic]

lappend auto_path $env(IXTCLHAL_LIBRARY)

initializeDefineCommand
initializeDefineTest

set interfaceFile [file join $genPath interface.tcl]
source $interfaceFile

set constantsFile [file join $genPath constants.tcl]
source $constantsFile


# rename the system exit with our exit so that we can clean up before calling
# system exit for Windows only
if [isWindows] {
	if {[info commands exit] != ""} {
		if {[info commands exitOld] == ""} {
			rename exit exitOld
		}
	}	
	
	# NOTE: Need to redefine this exit here, AND NOT ANYWHERE ELSE, so that the system
	# exit gets called when exitOld is called.
	proc exit {{exitStat 0}} \
	{
		cleanUp
		exitOld $exitStat
	}
	# rename the system after with our after so that we can task switch for Windows only
    if {[info commands after] != ""} {
        if {[info commands originalAfter] == ""} {
            rename after originalAfter
        }
    }
}


if {[isWindows] && [info commands tk] != ""} {
    if {![regexp -nocase scriptmate [tk appname]]} {
        console show
    }
}


############################# GLOBAL VARIABLES #################################
#### NOTE: DON'T FORGET TO ADD NEW ONES

## these are the simple ones that don't have any ptr parameters...
set ixTclHal::noArgList    { version session chassisChain chassis card qos streamRegion streamQueue streamQueueList \
                             portGroup filter filterPallette statGroup statList capture captureBuffer \
                             packetGroup dataIntegrity tcpRoundTripFlow autoDetectInstrumentation \
                             protocolServer igmpServer mii usb timeServer forcedCollisions collisionBackoff portCpu \
                             ppp pppStatus sonet sonetError sonetOverhead atmPort dcc srpUsage \
                             bert bertErrorGeneration bertUnframed xaui vsrError fecError opticalDigitalWrapper \
                             ipV6Address logFile remoteConnection licenseManagement \
							 atmStat atmFilter atmReassembly statWatch txRxPreamble \
                             flexibleTimestamp pcpuCommandService gfpOverhead streamTransmitStats xfp lasi \
                             poePoweredDevice poeSignalAcquisition poeAutoCalibration}

## these are the ones that we need simple pointers returned for other stuff...
set ixTclHal::pointerList   { port protocol arpAddressTableEntry ipAddressTableItem igmpAddressTableItem \
                              interfaceIpV4 interfaceIpV6 discoveredAddress atmHeaderCounter \
                              customOrderedSet srpMacBinding mmdRegister latencyBin \
                              ipV6Authentication ipV6Destination ipV6Routing ipV6Fragment \
                              rprTlvBandwidthPair rprTlvWeight rprTlvVendorSpecific \
                              rprTlvTotalBandwidth rprTlvNeighborAddress rprTlvStationName \
                              tableUdfColumn igmpGroupRecord dhcpV4Tlv \
							  atmOamAis atmOamRdi atmOamFaultManagementCC atmOamFaultManagementLB atmOamActDeact \
							  ipV6OptionPAD1 ipV6OptionPADN ipV6OptionJumbo ipV6OptionRouterAlert ipV6OptionBindingUpdate \
                              ipV6OptionBindingAck ipV6OptionHomeAddress ipV6OptionBindingRequest ipV6OptionMIpV6UniqueIdSub \
                              ipV6OptionMIpV6AlternativeCoaSub ipV6OptionUserDefine }

## these are basically all the protocols that require a portPtr parameter for instantiation
set ixTclHal::protocolList { ip udp tcp ipx icmp arp dhcp gre \
                             srpArp srpIps frameRelay hdlc isl pauseControl weightedRandomFramesize \
                             rprArp rprProtection rprFairness rprOam cdlPreamble}

## this initial list is all the complicated ones
set ixTclHal::commandList  { stat stream udf mplsLabel mpls rip ripRoute  ipAddressTable igmpAddressTable arpServer\
                             interfaceTable interfaceEntry discoveredList discoveredNeighbor discoveredAddress  \
							 packetGroupStats tableUdf igmp atmOam atmOamTrace vlan stackedVlan \
							 ipV6 ipV6HopByHop rprRingControl rprTopology rprTlvIndividualBandwidth protocolOffset \
                             miiae mmd srpHeader srpDiscovery atmHeader ixUtils linkFaultSignaling gfp	\
							 dhcpV4Properties dhcpV4DiscoveredInfo dhcpV6Properties dhcpV6DiscoveredInfo }
ixTclHal::update ::halCommands

## We need to append dhcpV6Tlv to halCommands, since it is instantiated as an TCLDhcpV4Tlv and can't be added to ixTclHal::pointerList
lappend ::halCommands	dhcpV6Tlv

set halFuncs     { enableEvents clearAllMyOwnership }

set globalArrays { ixgTrialArray ixgTrialCongArray ixgTrialUncongArray \
                   one2oneArray one2manyArray many2oneArray many2manyArray }

set ixProtocolList {ip udp tcp ipx igmp icmp arp vlan dhcp mpls mplsLabel qos rip ripRoute isl frameRelay ipV6}

set ixStopTest      0
set ixStopAction    0

############################ TCL FILES/DIR INITIALIZATION ##########################

if [info exists env(IXIA_RESULTS_DIR)] {
    #set RESULTS_DIR [file join $env(IXIA_RESULTS_DIR) Results]
    set RESULTS_DIR $env(IXIA_RESULTS_DIR)
} else {
    set RESULTS_DIR [file join [file dirname [file dirname $env(IXTCLHAL_LIBRARY)]] Results]
    set env(IXIA_RESULTS_DIR) $RESULTS_DIR
}
if {![file exists $RESULTS_DIR]} {
        file mkdir $RESULTS_DIR
}

if [info exists env(IXIA_LOGS_DIR)] {
    #set LOGS_DIR [file join $env(IXIA_LOGS_DIR) Logs]
    set LOGS_DIR $env(IXIA_LOGS_DIR)
} else {
    set LOGS_DIR [file join [file dirname [file dirname $env(IXTCLHAL_LIBRARY)]] Logs]
    set env(IXIA_LOGS_DIR) $LOGS_DIR
}
if {![file exists $LOGS_DIR]} {
        file mkdir $LOGS_DIR
}

if {![info exists env(IXIA_SAMPLES_DIR)]} {
    set env(IXIA_SAMPLES_DIR) [file dirname [file dirname $env(IXTCLHAL_LIBRARY)]]
}

foreach initProc [info commands initCommand_zz_*] {
    # puts $initProc
    ${initProc}
}

# Create dummy calls to the commands that were moved to the scriptmate package.  This is for
# backwards compatibility but it not guaranteed to work unless the Scriptmate package is installed.
scriptmateBackwardsCompatibility::createAllCommands

############### sample script environment initialization ############################
global ixgJitterIndex 
set ixgJitterIndex(averageLatency)     0
set ixgJitterIndex(standardDeviation)  1
set ixgJitterIndex(averageDeviation)   2
set ixgJitterIndex(minLatency)         3
set ixgJitterIndex(maxLatency)         4
