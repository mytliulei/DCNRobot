# OSPF/ospfConvergence
####################################################################################################################
#
#   Copyright © 1997 - 2004 by IXIA
#   All Rights Reserved.
#
# Description: This file contains the script for running OSPF V2/V3 convergence test
#
#               For performing this test you need 3 ixia ports, one tx and 2 rx
#               1) Confogure the ospf routers, interface, route range on rx ports
#                   One of the routes with lower metric is preferred route. 
#                   (Both routers advertise the same route range)
#               2) Configure the stream
#               3) Start OSPF Server and confirm ospf neighbors are in full state.
#               
#                4. TX Port sends traffic to target the advertised routes. All traffic should arrive at primary path.
#                    * Traffic is continues and we stop it at the end of test.
#                    * Each destination has a PGID. We use wide packet group to get first/last timestamps in the receive side.
#                3. Withdraw selected LSA group.
#                4. Measure the packets arriving at port 2 via secondary path. When the monitored throughput 
#                    reaches 99% of target load, stop packet group stats and read the stats.
#
#                5. Calculate Convergence delay. Average of differences between last timestamps on the 
#                    preferred port and first timestamps on the alternate port for each PGID. 
#
#                6. Start Packet group stats. 
#                7. Advertise the previously withdrawn LSA group.
#                8. Measure the packets arriving at port 2 via primary path. When the monitored throughput 
#                    reaches 99% of target load, stop packet group stats.
#
#                9. Calculate Convergence delay.
#                10. Repeat 1 to 9 for more number of withdrawals and advertisements.
#                11. Stop Tx and protocols.
#              
#
#####################################################################################################################
####### DO NOT CHANGE THE FOLL. LINE #######
package require IxTclHal
global testConf SrcIpAddress DestDUTIpAddress SrcIpV6Address DestDUTIpV6Address IPXSourceSocket 

#############################################

logOn ospfConvergence.log

logMsg "\n\nOSPF Convergence Test - OSPF V2/V3 Convergence"
logMsg "  Copyright © 1997 - 2004 by IXIA"
logMsg "  ............................................\n"

##################################################################################
# Begin user configuration here...

set testConf(hostname)              {loopbacl}
set testConf(chassisID)             {1}

set testConf(chassisSequence)       {1}
set testConf(cableLength)           cable6feet      ;# cable3feet
                                                    ;# cable6feet
                                                    ;# cable9feet
                                                    ;# cable12feet
                                                    ;# cable15feet
                                                    ;# cable18feet
                                                    ;# cable21feet
                                                    ;# cable24feet


#--> Port configuration
# Speed set options include: 10, 100, 1000, oc3, oc12, stm1c, stm4c, oc48 or stm16c
#
set testConf(TxPortSpeed)       100             ;# Speed of the Tx port
set testConf(RxPortSpeed)       100             ;# Speed of the Rx port
set testConf(duplex)            half             ;# half or full
set testConf(autonegotiate)     true             ;# true or false

# Packet over Sonet configuration, only applies to POS ports
#
set testConf(hdlcHeader)        ppp				;# ppp or cisco
set testConf(PPPnegotiation)	false			;# true enables PPP negotiation on PoS ports			
set testConf(dataScrambling)    true			;# enable SPE data scrambling (true/false)
set testConf(useRecoveredClock) false			;# enable useRecoveredClock (true/false)
set testConf(useMagicNumber)    false			;# enable useMagicNumber (true/false)
set testConf(sonetTxCRC)		sonetCrc16		;# sonetCrc16 or sonetCrc32
set testConf(sonetRxCRC)		sonetCrc16		;# sonetCrc16 or sonetCrc32


# To generate the Tx and Rx Chassis,Card,Port maps automatically, set
# autoMapGeneration to "yes".
# The auto-generataion will create a many-to-one map from one Tx port to
# a set of Rx ports.
#
# To create a customized map, set autoMapGeneration to "no" and use the map
# command below.
#
set testConf(autoMapGeneration) no
set testConf(mapFromPort)       {1 1 1}         ;# chassisID cardId portID
set testConf(mapToPort)         {1 16 4}        ;# chassisID cardId portID
set testConf(mapServerPort)     {1 1 1}         ;# chassisID cardId portID
set testConf(mapDirection)      unidirectional  ;# unidirectional only


# The ports in the "excludePorts" list will not be configured in the traffic map.
# Note that if there is a pair of ports that are transmitting and receiving, then
# include BOTH ports in this list.
# Format is as follows:     {{1 2 4} {1 3 1} {1 4 3} {1 4 4}}
#
set testConf(excludePorts)  {}


# Set up the map manually. Used only if autoMapGeneration set to "no". Note that
# if running IP, the IP addresses MUST also be set up manually.
#
map new -type       one2many       ;# we use both maps in this test, so get rid of any leftovers
map config -type    one2many


#--> Setup transmit-receive pairs as 'chassis-card-port' format
#        --------- TX ---------     --------- RX ---------
#         chassis   card    port      chassis   card  port
#
map add     1         1      1           1       1      2
map add     1         1      1           1       1      3


#--> User/Report Titles - may be left blank
#
user config -productname "Your switch/router name here"
user config -version     "Your firmware version here"
user config -serial#     "Your switch/router serial number here"
user config -username    "Your name here"


#--> Test Configuration
# frameSizeList - this is a list of frame sizes to run the test on. The
#                 frame sizes recommended in RFCs are: 64, 128, 256, 512, 1024,
#                 1280, & 1518.  Valid frame size range is from 64->1518 bytes, 
#                 including CRC.  The test may be run with one or more valid
#                 frame sizes.
#
#                 For ipV6 the minimum frame size is 76.
ospfSuite config -framesizeList     {76}

# Enter the percentage of Maximum Frame rate to use for running the test.
ospfSuite config -percentMaxRate      1

## One frame size test is called a trial. The user may choose to run one or more
# trials; the average result of each trial will be presented in the result file.
#
ospfSuite config -numtrials           1      ;# total number of trials per frame size



# Staggered start; if set to true, transmit start will be staggered; if
# set to false, transmit will start on all ports at the same time. 
#
ospfSuite config -staggeredStart      false

# Network IP address
ospfSuite config -networkIpAddress      20.0.0.0 

# Automatic IP assignment. Use only if "autoMapGeneration" is set to "yes"
set testConf(firstSrcIpAddress)      198.18.1.2
set testConf(firstDestDUTIpAddress)  198.18.1.1
set testConf(incrIpAddrByteNum)      3
#                                    1
#                                    2
#                                    4
set testConf(firstSrcIpV6Address)       2000:0:0:1::100
set testConf(firstDestDUTIpV6Address)   2000:0:0:1::1
set testConf(incrIpV6AddressField)      siteLevelAggregationId
#                                       interfaceId
#                                       subnetId
#                                       siteLevelAggregationId
#                                       nextLevelAggregationId
#                                       topLevelAggregationId



# Manual IP address setup. Used only if "autoMapGeneration" is set to "no"
# Also, you have to know which cards are physically present. Note that the DUT
# IP address is not needed in the IP multicast frames but are entered here for
# the sake of consistency.

set SrcIpAddress(1,1,1)             198.18.1.100
set DestDUTIpAddress(1,1,1)         198.18.1.1

set SrcIpAddress(1,1,2)             198.18.2.100
set DestDUTIpAddress(1,1,2)         198.18.2.1

set SrcIpAddress(1,1,3)             198.18.3.100
set DestDUTIpAddress(1,1,3)         198.18.3.1

set SrcIpV6Address(1,1,1)           2000:0:0:1::1:100
set DestDUTIpV6Address(1,1,1)       2000:0:0:1::1:1

set SrcIpV6Address(1,1,2)           2000:0:0:2::100
set DestDUTIpV6Address(1,1,2)       2000:0:0:2::1

set SrcIpV6Address(1,1,3)           2000:0:0:3::100
set DestDUTIpV6Address(1,1,3)       2000:0:0:3::1

# Use only with manual map generation.
set testConf(ipV4Mask,1,1,1)        255.255.255.255
set testConf(ipV4Mask,1,1,2)        255.255.255.255
set testConf(ipV4Mask,1,1,3)        255.255.255.255

# IPv6 Prefix Length, used with manual map generation.
set testConf(ipV6Mask,1,1,1)        64
set testConf(ipV6Mask,1,1,2)        64
set testConf(ipV6Mask,1,1,3)        64


# The results will be printed in this file in the "Results" directory of the parent directory
#
results config -resultFile "ospfConvergence.results"

# If set to true, the .csv file which has the same name with the results file will be 
# generated in the "Results" directory of the parent directory
#
results config -generateCSVFile   false

##################################################################################
##################################################################################
#       DON'T CHANGE ANYTHING BELOW HERE!!
##################################################################################
##################################################################################
# Do not change the protocol type
# Supported protocols are IP IPV6 
set testConf(protocolName)          ip/ipV6

ospfSuite config -mapType   one2many

if [configureTest one2many ospfSuite] {
    cleanUp
    return 1
}

if [catch {ospfSuite start -ospfConvergence} result] {
    logMsg "ERROR: $::errorInfo"
    cleanUp
    return 1
}

teardown
return 0

