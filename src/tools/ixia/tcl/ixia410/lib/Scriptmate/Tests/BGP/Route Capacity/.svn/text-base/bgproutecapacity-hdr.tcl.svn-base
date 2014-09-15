##################################################################################
#
#   Copyright © 2005 by IXIA
#   All Rights Reserved.
#
##################################################################################

# This test had NOT been converted to Plug-In format
# When converting to Plug-In format remove below dummyHeader
# lines completely.  Do NOT move to the converted test.
global dummyHeader
set dummyHeader(BGP_routeCapacity) 1;

##################################################################################

global testCats;
set testCats(BGP) "BGP";

global BGP;
set BGP(routeCapacity) "Route Capacity";

global doNotSupportLearnMacOnly;
set doNotSupportLearnMacOnly(BGP_routeCapacity) 1;

global gTestCommand;
set gTestCommand(routeCapacity) bgpSuite;

global supportMaskWidth;
set supportMaskWidth(BGP_routeCapacity) 1;

global doNotSupportLearn;
set doNotSupportLearn(BGP_routeCapacity) 1;

global protocolsSupportedByTest;
set protocolsSupportedByTest(BGP_routeCapacity) {ip};

global supportResultsCsv
global supportAggResultsCsv
global supportIterationCsv
set supportResultsCsv(BGP_routeCapacity) true
set supportAggResultsCsv(BGP_routeCapacity) false
set supportIterationCsv(BGP_routeCapacity) true

##################################
# COMMAND: bgpSuite
##################################
proc scriptmateCommands::init_zz_bgpSuite {} \
{
    defineTest registerCommand   bgpSuite
    defineTest registerParameter \
	-command bgpSuite \
	-parameter percentMaxRate \
	-type double \
	-defaultValue 100 \
	-validRange {0.001 100};

    defineTest registerParameter \
	-command bgpSuite \
	-parameter numPeers \
	-type integer \
	-defaultValue 1	\
	-validRange {1 2000000000};

    defineTest registerParameter \
	-command bgpSuite \
	-parameter routesPerPeer \
	-type integer \
	-defaultValue 4096 \
	-validRange {1 2000000000};

    defineTest registerParameter \
	-command bgpSuite \
	-parameter routeStep \
	-type integer \
	-defaultValue 1024 \
	-validRange {0 2000000000};

    defineTest registerParameter \
	-command bgpSuite \
	-parameter firstAsNumber \
	-type integer \
	-defaultValue 65001 \
	-validRange {0 65534};

    defineTest registerParameter \
	-command bgpSuite \
	-parameter advertiseDelayPerRoute \
	-type double \
	-defaultValue 0.0007 \
	-validRange {0.000001 2000000000};

    defineTest registerParameter \
	-command bgpSuite \
	-parameter burstCount \
	-type integer \
	-defaultValue 24;

    defineTest registerParameter \
	-command bgpSuite \
	-parameter delayTime \
	-type integer \
	-defaultValue 15 \
	-validRange {5 600000};

    defineTest registerParameter \
	-command bgpSuite \
	-parameter enableUserDelay \
	-type boolean \
	-defaultValue false;

    defineTest registerParameter \
	-command bgpSuite \
	-parameter downFlapTime \
	-type integer \
	-defaultValue 10;

    defineTest registerParameter \
	-command bgpSuite \
	-parameter upFlapTime \
	-type integer \
	-defaultValue 20;

    defineTest registerParameter \
	-command bgpSuite \
	-parameter prefixLength \
	-type integer \
	-defaultValue 24;

    defineTest registerParameter \
	-command bgpSuite \
	-parameter networkIPAddress \
	-type ipaddress \
	-defaultValue "10.0.0.0";

    defineTest registerParameter \
	-command bgpSuite \
	-parameter DUTAsNumber \
	-type integer \
	-defaultValue 1239;

    defineTest registerParameter \
	-command bgpSuite \
	-parameter tolerance \
	-type double \
	-defaultValue 0 \
	-validRange {0 100}  ;#in percent (percent of total number of frames sent)
 
    # for internal use only!!
    defineTest registerParameter \
	-command bgpSuite \
	-parameter mapType \
	-type string \
	-defaultValue many2many \
        -validValues {one2one one2many many2one many2many};

    defineTest registerTest      bgpSuite {routeCapacity peerCapacity routeConvergence bgpPerformance}

    defineCommand registerMethod bgpSuite registerResultVars {routeCapacity routeConvergence bgpPerformance}
}

scriptmateCommands::init_zz_bgpSuite;

##################################################################################
# Begin user configuration here...
global testConf SrcIpAddress DestDUTIpAddress IPXSourceSocket

set testConf(hostname)              {loopback}
set testConf(chassisID)             {1}

set testConf(chassisSequence)       {1}
set testConf(cableLength)           cable6feet   ;# cable3feet
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
set testConf(TxPortSpeed)       100              ;# Speed of the Tx port
set testConf(RxPortSpeed)       100              ;# Speed of the Rx port
set testConf(duplex)            full             ;# half or full
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


#--> Setup transmit-receive pairs as 'chassis-card-port' format
#        --------- TX ---------     --------- RX ---------
#         chassis   card    port      chassis   card  port
#
map add     1         11      1           1       11      2



#--> User/Report Titles - may be left blank
#
user config -productname "Your switch/router name here"
user config -version     "Your firmware version here"
user config -serial#     "Your switch/router serial number here"
user config -username    "Your name here"


#--> Test Configuration
# framesizeList - this is a list of frame sizes to run the test on. The
#                 frame sizes recommended in RFCs are: 64, 128, 256, 512, 1024,
#                 1280, & 1518.  Valid frame size range is from 64->1518 bytes, 
#                 including CRC.  The test may be run with one or more valid
#                 frame sizes.
#
bgpSuite config -framesizeList   {64 128 256 512 1024 1280 1518}


# Enter the percentage of Maximum Frame rate to use for running the test.
bgpSuite config -percentMaxRate      1

## One frame size test is called a trial. The user may choose to run one or more
# trials; the average result of each trial will be presented in the result file.
#
bgpSuite config -numtrials           1      ;# total number of trials per frame size


# The approximate length of time frames are transmitted for each trial is set as a 'duration.
# The duration is in seconds; for example, if the duration is set to one second on a 100mbs
# switch, ~148810 frames will be transmitted.  This number must be an integer; minimum
# value is 1 second.
#
bgpSuite config -duration            60     ;# duration of transmit during test, in seconds


# Staggered start; if set to true, transmit start will be staggered; if
# set to false, transmit will start on all ports at the same time. 
#
bgpSuite config -staggeredStart      false


# Configure AS Number for External Peer

bgpSuite config -firstAsNumber 346

# Configure the Number of Peers. For Route Capacity we use one peer.

bgpSuite config -numPeers 1

# Configure the base number of Routes to advertise
# The number of routes advertised is incremented by routeStep routes each time

bgpSuite config -routesPerPeer 2048
bgpSuite config -routeStep 0
bgpSuite config -tolerance 0
bgpSuite config -delayTime 15
bgpSuite config -enableUserDelay       false

# Prefix Length for all routes
bgpSuite config -prefixLength 24

# Seconds to wait after advertising routes to send test traffic

bgpSuite config -advertiseDelayPerRoute    0.009

# Network IP address
bgpSuite config -networkIPAddress 20.0.0.0

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
set SrcIpAddress(1,11,1)             100.100.25.2
set DestDUTIpAddress(1,11,1)         100.100.25.1

set SrcIpAddress(1,11,3)             100.100.27.2
set DestDUTIpAddress(1,11,3)         100.100.27.1

DummyHeaderLogFileNameSet "bgpRouteCapacity.log";

# The results will be printed in this file in the "Results" directory of the parent directory
#
results config -resultFile "bgpRouteCapacity.results"

# If set to true, the .csv file which has the same name with the results file will be 
# generated in the "Results" directory of the parent directory
#
results config -generateCSVFile   false
