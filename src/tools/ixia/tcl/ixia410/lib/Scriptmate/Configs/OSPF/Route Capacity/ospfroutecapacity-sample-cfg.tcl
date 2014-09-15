# OSPF/routeCapacity
##################################################################################
#
#   Copyright © 1997 - 2004 by IXIA
#   All Rights Reserved.
#
# Description: This file contains the script for running OSPF route capacity test
#              1) Configure the  OSPF router, interface and route range on receive port
#              2) Configure number of routes ( For the first iteration it is number of routes)
#              3) Configure stream
#              4) start OSPF server and confirm the ospf neighbor is in full state 
#              4) Start transmit ( one packet to each route )
#              5) Stop OSPF server.
#              6) Collect the stats 
#              7) If TotalLoss is 0 or less than tolerance go to number 2 else stop the test 
#              
#
##################################################################################
####### DO NOT CHANGE THE FOLL. LINE #######
package require IxTclHal
global testConf SrcIpAddress DestDUTIpAddress IPXSourceSocket

#############################################

logOn ospfRouteCapacity.log

logMsg "\n\nOSPF Capacity Test - Route Capacity"
logMsg "  Copyright © 1997 - 2004 by IXIA"
logMsg "  ............................................\n"

##################################################################################
# Begin user configuration here...

set testConf(hostname)              {loopback}
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
# Speed set options include: 10, 100, 1000, usb, oc3, oc12, oc48, oc192, stm1c, stm4c, stm16c, or stm64c.
#
set testConf(TxPortSpeed)       1000                 ;# Speed of the Tx port
set testConf(RxPortSpeed)       1000                 ;# Speed of the Rx port
set testConf(duplex)            full                ;# half or full
set testConf(autonegotiate)     true                ;# true or false

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
set testConf(autoMapGeneration)  no
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
map new -type one2one       ;# we use both maps in this test, so get rid of any leftovers
map config -type one2one
#map config -echo true

#--> Setup transmit-receive pairs as 'chassis-card-port' format
#        --------- TX ---------     --------- RX ---------
#         chassis   card    port      chassis   card  port
#
map add     1         16      1           1       16      2



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
ospfSuite config -framesizeList   {64}

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



# Configure the base number of Routes to advertise
# The number of routes advertised is incremented by routeStep routes each time

ospfSuite config -interfaceIpMask       255.255.255.0
ospfSuite config -areaId                0
ospfSuite config -numberOfRoutes        200
ospfSuite config -routeStep             0
ospfSuite config -tolerance             0
ospfSuite config -interfaceNetworkType  ospfBroadcast ;# ospfBroadcast ospfPointToPoint
ospfSuite config -dutProcessingDelay    60
ospfSuite config -interfaceMTUSize      1500
ospfSuite config -enableValidateMtu     false      


# Prefix Length for all routes
ospfSuite config -prefixLength          24

# Seconds to wait after advertising routes to send test traffic

ospfSuite config -advertiseDelayPerRoute    0.2

# Network IP address
ospfSuite config -networkIpAddress      20.0.0.0

# Select the vlan type to use; currently this test does not support vlans
#
set testConf(enable802dot1qTag)    false
set testConf(enableISLtag)         false


# Automatic IP assignment. Use only if "autoMapGeneration" is set to "yes"
set testConf(firstSrcIpAddress)      198.18.1.2
set testConf(firstDestDUTIpAddress)  198.18.1.1
set testConf(firstMaskWidth)         24
set testConf(incrIpAddrByteNum)      3

# Manual IP address setup. Used only if "autoMapGeneration" is set to "no"
# Also, you have to know which cards are physically present. Note that the DUT
# IP address is not needed in the IP multicast frames but are entered here for
# the sake of consistency.
set SrcIpAddress(1,16,1)             100.100.31.2
set DestDUTIpAddress(1,16,1)         100.100.31.1

set SrcIpAddress(1,16,2)             100.100.32.2
set DestDUTIpAddress(1,16,2)         100.100.32.1

# The results will be printed in this file in the "Results" directory of the parent directory
#
results config -resultFile "ospfRouteCapacity.results"

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
# Supported protocols are IP ONLY
set testConf(protocolName)          ip

ospfSuite config -mapType   one2one

if [configureTest one2one ospfSuite] {
    cleanUp
    return 1
}

if [catch {ospfSuite start -routeCapacity} result] {
    logMsg "ERROR: $::errorInfo"
    cleanUp
    return 1
}

teardown
return 0

