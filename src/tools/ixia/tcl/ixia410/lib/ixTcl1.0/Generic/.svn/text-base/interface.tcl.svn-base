##################################################################################
# Version 4.10   $Revision: 478 $
# $Date: 12/12/02 2:03p $
# $Author: Dheins $
#
# $Workfile: interface.tcl $
#
#   Copyright © 1997 - 2005 by IXIA
#   All Rights Reserved.
#
# Revision Log:
# 01-23-1998    DS      Genesis
#
# Description: This is the main configuration interface file for all the commands.
# If new commands or paramters are to be added, only this file needs to be updated.
# The actual files containing the commands do not have to be touched.
# The "config" commands contain all configurable parameters, that is,
# read-write. The "cget parameters" are read-only. "cget" can be used to store
# default values which the user cannot change.
#
# Included in this file are the user config params that are generic for all tests.
#
##################################################################################


##################################################################################

# A list containing all the commands. Used to display them when "help"
# command is given
#
# **********NOTE*************
# Update this list whenever a new command is added or an old one deleted.

set allCommands {{Commands              Description} \
                 {--------              ----------------------------------------------------------------------------} \
                 {advancedTestParameter Configure advanced test parameters} \
                 {fastpath              Configure fastpath configuration parameters} \
                 {ipfastpath            Configure ipfastpath configuration parameters (deprecated)} \
                 {learn                 Configure learn frames} \
                 {logger                Configure and enable logging to files} \
                 {map                   Configure the transmit and receive Chassis.Card.Port traffic mapping} \
                 {tclClient             Configure the tclClient parameters} \
                 {testProfile           Configure test parameters} }


##################################
# COMMAND: advancedTestParameter
##################################
proc initCommand_zz_advancedTestParameter {} \
{
    defineCommand registerCommand   advancedTestParameter

    defineCommand registerParameter -command advancedTestParameter -type string  -parameter   dialogState         -defaultValue normal             -validValues {normal iconic destroyedByUser}

    defineCommand registerParameter -command advancedTestParameter -type integer -parameter   maxConnectRetries   -defaultValue 3
    defineCommand registerParameter -command advancedTestParameter -type string  -parameter   streamPatternType   -defaultValue repeat             -validValues {incrByte incrWord decrByte decrWord patternTypeRandom repeat nonRepeat}
    defineCommand registerParameter -command advancedTestParameter -type string  -parameter   streamDataPattern   -defaultValue x00010203          -validValues {dataPatternRandom allOnes allZeroes xAAAA x5555 x7777 xDDDD xF0F0 x0F0F xFF00FF00 x00FF00FF xFFFF0000 x0000FFFF x00010203 x00010002 xFFFEFDFC xFFFFFFFE userpattern}
    defineCommand registerParameter -command advancedTestParameter -type integer -parameter   streamFrameType     -defaultValue {08 00}
    defineCommand registerParameter -command advancedTestParameter -type string  -parameter   streamPattern       -defaultValue {}
    defineCommand registerParameter -command advancedTestParameter -type string  -parameter   l2DataProtocol      -defaultValue {native}           -validValues {native ethernetII ip}
    
    defineCommand registerParameter -command advancedTestParameter -type string  -parameter   ipProtocol          -defaultValue udp
    defineCommand registerParameter -command advancedTestParameter -type string  -parameter   ipFragment          -defaultValue may                -validValues {may dont}
    defineCommand registerParameter -command advancedTestParameter -type string  -parameter   ipLastFragment      -defaultValue last               -validValues {last more}
    defineCommand registerParameter -command advancedTestParameter -type integer -parameter   ipFragmentOffset    -defaultValue 0   
    defineCommand registerParameter -command advancedTestParameter -type string  -parameter   ipDelay             -defaultValue normalDelay        -validValues {normalDelay lowDelay}
    defineCommand registerParameter -command advancedTestParameter -type string  -parameter   ipThroughput        -defaultValue normalThruput      -validValues {normalThruput highThruput}
    defineCommand registerParameter -command advancedTestParameter -type string  -parameter   ipReliability       -defaultValue normalReliability  -validValues {normalReliability highReliability}
    defineCommand registerParameter -command advancedTestParameter -type integer -parameter   ipIdentifier        -defaultValue 0
    defineCommand registerParameter -command advancedTestParameter -type string  -parameter   ipCost              -defaultValue normalCost         -validValues {normalCost lowCost}
    defineCommand registerParameter -command advancedTestParameter -type string  -parameter   ipOptions           -defaultValue {}
    defineCommand registerParameter -command advancedTestParameter -type integer -parameter   ipTTL               -defaultValue 10              
    
    defineCommand registerParameter -command advancedTestParameter -type integer -parameter   ipV6HopLimit        -defaultValue 255              
    defineCommand registerParameter -command advancedTestParameter -type integer -parameter   ipV6FlowLabel       -defaultValue 0              
    defineCommand registerParameter -command advancedTestParameter -type integer -parameter   ipV6TrafficClass    -defaultValue 3
    
    defineCommand registerParameter -command advancedTestParameter -type integer -parameter   udpSourcePort       -defaultValue 7
    defineCommand registerParameter -command advancedTestParameter -type integer -parameter   udpDestPort         -defaultValue 7
    
    defineCommand registerParameter -command advancedTestParameter -type integer -parameter   tcpSourcePort       -defaultValue 0     
    defineCommand registerParameter -command advancedTestParameter -type integer -parameter   tcpDestPort         -defaultValue 0

    defineCommand registerParameter -command advancedTestParameter -type string  -parameter   igmpReportMode      -defaultValue igmpReportToAllWhenQueried  -validValues {igmpReportToOneWhenQueried igmpReportToAllWhenQueried igmpReportToAllUnsolicited}
    
    defineCommand registerParameter -command advancedTestParameter -type string  -parameter   ipxPacketType           -defaultValue typeIpx
    defineCommand registerParameter -command advancedTestParameter -type string  -parameter   vlanCFI                 -defaultValue resetCFI                -validValues {resetCFI setCFI}
    defineCommand registerParameter -command advancedTestParameter -type string  -parameter   removePortOnLinkDown    -defaultValue false
    defineCommand registerParameter -command advancedTestParameter -type integer -parameter   linkStateTimeout        -defaultValue 25
    defineCommand registerParameter -command advancedTestParameter -type string  -parameter   savedTerminationOption  -defaultValue return                  -validValues {return exit}
    defineCommand registerParameter -command advancedTestParameter -type double  -parameter   percentLossFormat       -defaultValue 7.3
    defineCommand registerParameter -command advancedTestParameter -type double  -parameter   defaultFloatFormat      -defaultValue 12.3
    defineCommand registerParameter -command advancedTestParameter -type boolean -parameter   verifyAllArpReply       -defaultValue false                    -validValues {true false}
    defineCommand registerParameter -command advancedTestParameter -type boolean -parameter   useRxVlanId             -defaultValue true                    
    defineCommand registerParameter -command advancedTestParameter -type integer -parameter   dutDelay                -defaultValue 100
    defineCommand registerParameter -command advancedTestParameter -type integer -parameter   numAddressesPerPort     -defaultValue 1
    defineCommand registerParameter -command advancedTestParameter -type integer -parameter   octetToIncr             -defaultValue 4              
    defineCommand registerParameter -command advancedTestParameter -type boolean -parameter   closeAllFilesInCleanUp  -defaultValue false
    defineCommand registerParameter -command advancedTestParameter -type boolean -parameter   removeStreamsAtCompletion -defaultValue false
    defineCommand registerParameter -command advancedTestParameter -type boolean -parameter   stopProcessesOnEarlyTermination -defaultValue false

    defineCommand registerParameter -command advancedTestParameter -type boolean -parameter   primeDut                -defaultValue false
    defineCommand registerParameter -command advancedTestParameter -type integer -parameter   portWriteChunkSize      -defaultValue 0               -validRange {0 1000}
}


##################################
# COMMAND: fastpath
##################################
proc initCommand_zz_fastpath {} \
{
    defineCommand registerCommand   fastpath

    # rate is in fps
    defineCommand registerParameter -command fastpath -parameter    rate              -type integer -defaultValue 100   -validRange {1 2000000000}
    defineCommand registerParameter -command fastpath -parameter    numframes         -type integer -defaultValue 10    -validRange {1 2000000000}
    defineCommand registerParameter -command fastpath -parameter    framesize         -type integer -defaultValue 64    -validRange {12 2000000000}
    defineCommand registerParameter -command fastpath -parameter    enable            -type boolean -defaultValue false
    defineCommand registerParameter -command fastpath -parameter    calculateLatency  -type boolean -defaultValue no
    defineCommand registerParameter -command fastpath -parameter    waitTime          -type integer -defaultValue 2000  -validRange {1 2000000000}
}


##################################
# COMMAND: ipfastpath
##################################
proc initCommand_zz_ipfastpath {} \
{
    defineCommand registerCommand   ipfastpath

    # rate is in fps
    defineCommand registerParameter -command ipfastpath -parameter    rate              -type integer -defaultValue 100     -validRange {1 2000000000}
    defineCommand registerParameter -command ipfastpath -parameter    numframes         -type integer -defaultValue 10      -validRange {1 2000000000}
    defineCommand registerParameter -command ipfastpath -parameter    framesize         -type integer -defaultValue 64      -validRange {12 2000000000}
    defineCommand registerParameter -command ipfastpath -parameter    enable            -type boolean -defaultValue false
    defineCommand registerParameter -command ipfastpath -parameter    calculateLatency  -type boolean -defaultValue no
    defineCommand registerParameter -command ipfastpath -parameter    waitTime          -type integer -defaultValue 2000    -validRange {1 2000000000}
}


##################################
# COMMAND: learn
##################################
proc initCommand_zz_learn {} \
{
    defineCommand registerCommand   learn

    defineCommand registerParameter -command learn -parameter when           -type string  -defaultValue oncePerFramesize -validValues {never once oncePerTest oncePerFramesize onIteration onTrial}
    defineCommand registerParameter -command learn -parameter rate           -type integer -defaultValue 100            -validRange  {1 2000000000};# fps
    defineCommand registerParameter -command learn -parameter numframes      -type integer -defaultValue 10			    -validRange  {1 2000000000}
    defineCommand registerParameter -command learn -parameter retries        -type integer -defaultValue 20
    defineCommand registerParameter -command learn -parameter type           -type string  -defaultValue default        -validValues {default mac ip ipx ipV6}
    defineCommand registerParameter -command learn -parameter numDHCPframes  -type integer -defaultValue 1
    defineCommand registerParameter -command learn -parameter framesize      -type integer -defaultValue 64             -validRange  {64 2000000000}
    defineCommand registerParameter -command learn -parameter removeOnError  -type boolean -defaultValue false
    defineCommand registerParameter -command learn -parameter snoopConfig    -type boolean -defaultValue false
    defineCommand registerParameter -command learn -parameter duration       -type integer -defaultValue 0
    defineCommand registerParameter -command learn -parameter waitTime       -type integer -defaultValue 1000           -validRange  {1 2000000000}
    defineCommand registerParameter -command learn -parameter dhcpWaitTime   -type integer -defaultValue 2              -validRange  {1 200}     ;# seconds

    # this command has been obsoleted, just around for backwards compatibility
    defineCommand registerParameter -command learn -parameter errorAction    -type string  -defaultValue deprecated     -validValues {deprecated continue remove}
}


##################################
# COMMAND: logger
# General logger parameters
##################################
proc initCommand_zz_logger {} \
{
    global LOGS_DIR

    defineCommand registerCommand   logger

    defineCommand registerParameter -command logger -parameter fileBackup  -type boolean -defaultValue false
    defineCommand registerParameter -command logger -parameter logFileName -type string  -defaultValue "defaultFile.log"
    defineCommand registerParameter -command logger -parameter directory   -type string  -defaultValue $LOGS_DIR
    defineCommand registerParameter -command logger -parameter startTime   -type string
    defineCommand registerParameter -command logger -parameter endTime     -type string
    defineCommand registerParameter -command logger -parameter fileID      -type string  -defaultValue stdout -access r
    defineCommand registerParameter -command logger -parameter ioHandle    -type string  -defaultValue stdout

    defineCommand registerMethod    logger on
    defineCommand registerMethod    logger off
    defineCommand registerMethod    logger message     priority
}


##################################
# COMMAND: map
# Traffic mapping configuration commands
##################################
proc initCommand_zz_map {} \
{
    defineCommand registerCommand   map

    defineCommand registerParameter -command map -parameter echo -type boolean -defaultValue false
    defineCommand registerParameter -command map -parameter type -type string  -defaultValue one2one                                  -validValues {one2one one2many many2one many2many}

    defineCommand registerMethod    map new    {type}
    defineCommand registerMethod    map add    {txChassis txLm txPort rxChassis rxLm rxPort}
    defineCommand registerMethod    map del    {txChassis txLm txPort rxChassis rxLm rxPort}
}


##################################
# COMMAND: tclClient
##################################
proc initCommand_zz_tclClient {} \
{
    defineCommand registerCommand   tclClient

    defineCommand registerParameter -command tclClient -parameter enableStdout  -type boolean -defaultValue false
    defineCommand registerParameter -command tclClient -parameter enableResults -type boolean -defaultValue true
}


##################################
# COMMAND: advancedTestParameter
##################################
proc initCommand_zz_testProfile {} \
{
    defineCommand registerCommand   testProfile

    defineCommand registerParameter -command testProfile -type string -parameter   chassisChain    -defaultValue {loopback}
    defineCommand registerParameter -command testProfile -type string -parameter   serverName      -defaultValue ""
    defineCommand registerParameter -command testProfile -type string -parameter   chassisID       -defaultValue {1}
    defineCommand registerParameter -command testProfile -type string -parameter   syncCableLength -defaultValue {cable3feet}
    defineCommand registerParameter -command testProfile -type string -parameter   chassisSequence -defaultValue {1}
    defineCommand registerParameter -command testProfile -type string -parameter   timeSource      -defaultValue {tsInternal}
    defineCommand registerParameter -command testProfile -type string -parameter   sntpAddress     -defaultValue ""
}
