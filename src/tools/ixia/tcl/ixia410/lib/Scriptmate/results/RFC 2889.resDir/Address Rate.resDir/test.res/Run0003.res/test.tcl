# rfc2889/addrRate
###################################################
# File: test.tcl
#
# ixos 4.10.250.4 EA
# Ix Router 4.10.3.83
# IxScriptMate 5.20.GA
#
# Copyright © 1997 - 2004 by IXIA
# All Rights Reserved.
#
###################################################

wm withdraw .
tk appname IxScriptMate
package require IxTclHal

logger config -directory "C:/Program Files/Ixia/TclScripts/lib/Scriptmate/Logs"
logger config -fileBackup true
results config -directory "C:/Program Files/Ixia/TclScripts/lib/Scriptmate/Results"
results config -fileBackup true
results config -logDutConfig true

global testConf SrcIpAddress DestDUTIpAddress SrcIpV6Address DestDUTIpV6Address IPXSourceSocket VlanID NumVlans


logOn "addrRate.log"

logMsg "\n\n  RFC2889 Address Rate test"  
logMsg "  Copyright © 1997 - 2005 by IXIA"  
logMsg "  All Rights Reserved."  
logMsg "  ............................................\n"

results config -resultFile "addrRate.results"
results config -generateCSVFile false


user config -productname  "Your switch/router name here"
user config -version      "Your firmware version here"
user config -serial#      "Your switch/router serial number here"
user config -username     "Your name here"
user config -comments     ""


set testConf(hostname)                      172.16.1.251
set testConf(chassisID)                     1
set testConf(chassisSequence)               1
set testConf(cableLength)                   cable3feet


set testConf(speed)                         {{100 10100} {Copper1000 10100Gigabit}}
set testConf(autonegotiate)                 {{true 10100} {true 10100Gigabit}}
set testConf(duplex)                        {{full 10100} {full 10100Gigabit}}
set testConf(hdlcHeader)                    ppp
set testConf(PPPnegotiation)                true
set testConf(dataScrambling)                true
set testConf(useRecoveredClock)             true
set testConf(enableIp)                      true
set testConf(enableIpv6)                    true
set testConf(enableOsi)                     true
set testConf(enableMpls)                    true
set testConf(useMagicNumber)                true
set testConf(enableAccmNegotiation)         false
set testConf(sonetTxCRC)                    sonetCrc32
set testConf(sonetRxCRC)                    sonetCrc32
set testConf(C2byteTransmit)                22
set testConf(C2byteExpected)                22
set testConf(atmInterfaceType)              atmInterfaceUni
set testConf(atmFillerCell)                 atmIdleCell
set testConf(atmEnableCoset)                true
set testConf(atmReassemblyTimeout)          10

#
# This part contains the configuration of chassis level. This information
# may not be needed to run test. But it is important to restore the display
# of IxScriptMate.
#

#
# This part contains the configuration of card and port levels.
#


addr config -numtrials      1
addr config -numframes      10
addr config -percentMaxRate 100
addr config -tablesize      16383
addr config -age            30
addr config -waitResidual   2
addr config -staggeredStart notStaggeredStart

learn config -snoopConfig false

set testConf(firstVlanID)                   1
set testConf(incrementVlanID)               yes
set testConf(enable802dot1qTag)             false


#######################
#    Pass Criteria    #
#######################
set testConf(passFailEnable)                0
set testConf(passFailValue)                 100000


# End - Pass Criteria #

set testConf(protocolName)                  mac
set testConf(ethernetType)                  ethernetII
advancedTestParameter config -l2DataProtocol native

fastpath config -enable false


set VlanID(1,1,1)                           1100
set VlanID(1,1,2)                           1200
set VlanID(1,1,3)                           1300
set VlanID(1,1,4)                           1400
set VlanID(1,7,1)                           1231
set VlanID(1,7,2)                           1232
set VlanID(1,7,3)                           1233
set VlanID(1,7,4)                           1234
set testConf(autoMapGeneration)             no
set testConf(autoAddressForManual)          no
set testConf(mapDirection)                  unidirectional
set testConf(mapFromPort)                   {1 1 1}
set testConf(mapToPort)                     {1 1 4}
set testConf(excludePorts)                  {}
set testConf(portMap)                       {}


set testConf(mapTransmitPort)               {1 1 1}

set testConf(extendedDirections)            0
set testConf(mapServerPort)                 {}
map new    -type one2many
map config -type one2many
map add   1 12 1   1 12 2
map add   1 12 1   1 12 3
map add   1 12 1   1 12 4
map config -echo false

addr config -framesizeList {64 128 256 512 1024 1280 1518}


learn config -when            onIteration
learn config -type            default
learn config -numframes       1
learn config -retries         1
learn config -rate            100
learn config -waitTime        1000
learn config -framesize       64

set testConf(generatePdfEnable) false
global tputMultipleVlans
set tputMultipleVlans 0
set testConf(vlansPerPort) 1
set testConf(displayResults) true
set testConf(displayAggResults) true
set testConf(displayIterations) true

##########################
#    DUT Configuration   #
##########################
# The command executed at the beginning of the test 
# ]
set testConf(dutConfTestSetupCmd) {}

# The arguments passed to the command
# ]
set testConf(dutConfTestSetupArgs) {}

# The command executed at the end of the test 
# ]
set testConf(dutConfTestCleanupCmd) {}

# The arguments passed to the command
# ]
set testConf(dutConfTestCleanupArgs) {}

# The command executed at the beginning of the trial 
# ]
set testConf(dutConfTrialSetupCmd) {}

# The arguments passed to the command
# ]
set testConf(dutConfTrialSetupArgs) {}

# The command executed at the end of the trial 
# ]
set testConf(dutConfTrialCleanupCmd) {}

# The arguments passed to the command
# ]
set testConf(dutConfTrialCleanupArgs) {}

# The first arguments passed to each command
# ]
set testConf(dutConfGlobalArgs) {}

# Enable/Disable DUT Configuration
# ]
set testConf(dutConfEnabled) 0

# End - DUT Configuration #



##################################################################################
##################################################################################
#   DON'T CHANGE ANYTHING BELOW HERE!!
##################################################################################
##################################################################################

if [configureTest one2many] {
    
    exit 1
}

if [catch {addr start -rate} result] {
    logMsg "ERROR: $::errorInfo"
    
    exit 1
}


teardownAddrRate
exit 0

