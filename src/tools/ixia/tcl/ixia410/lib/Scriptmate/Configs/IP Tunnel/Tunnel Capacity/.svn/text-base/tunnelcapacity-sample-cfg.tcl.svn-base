# Tunnel/tunnelCapacity
##################################################################################
# Version   3.70	$Revision   $
# $Date: 12/12/02 2:24p $
# $Author: Dheins $
#
# $Workfile: testTunnelCapacity.tcl $ - Sample user script for running the capacity test
#                    over IP/IPv6 tunnels.
#
#   Copyright © 1997 - 2004 by IXIA
#   All Rights Reserved.
#
#   Revision Log:
#   10-14-2002  DHG Initial Release
#
# Description: 
#   This test determines the number of frames that the DUT (Device Under Test)
#   loses at different tunnel loads.  Frames are initially sent at a user-specified 
#   for an initial number of tunnels. The tunnel load is increased by the
#   tunnel increment defined by the user, until frame loss occurs (outside the loss
#   tolerance).
#
#   This test is configured with a one-to-one traffic mapping. 
#
#   Results from the tunnel capacity test will be written to the file 
#   'ipv6TunnelCapacity.results'. This is an ascii text-based file that may be viewed 
#   via Notepad or your favorite editor, or it may be printed out as a formal report.
#
###################################################################################

####### DO NOT CHANGE THE FOLL. LINE #######
package require IxTclHal
global testConf SrcIpAddress SrcIpV6Address DestDUTIpAddress DestDUTIpV6Address

logOn ipv6TunnelCapacity.log

logMsg "\n\n  IPv6 Tunnel Capacity test"
logMsg "  Copyright © 1997 - 2004 by IXIA"
logMsg "  All Rights Reserved."
logMsg "  ............................................\n"

##################################################################################
# Begin user configuration here...

#--> Chassis configuration
# - "hostname" is a list of all chassis'. Enter names or IP addresses of all chassis
#   in the chain. Example, {loopback1 loopback2}
# - "chassisID" is the unique ID for chassis in chain. This list should correspond to
#   hostname list. Example, {1 2}
# - There can only be one master chassis in a chain of chassis.
# - "chassisSequence" is the sequence numbers of the chassis in the chain. The master
#   has a sequence number of 1 and other chassis should be incrementing. Example, {1 2}
#
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


# Speed set options include: 10, 100, 1000, usb, oc3, oc12, oc48, oc192, stm1c, stm4c, stm16c, or stm64c.
#
set testConf(TxPortSpeed)       100                 ;# Speed of the Tx port
set testConf(RxPortSpeed)       100                 ;# Speed of the Rx port
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
# The auto-generataion will create a map from port 1 to 2 and 3 to 4 on the same
# card. Example,
# (1,1,1) <---> (1,1,2)     #\ bidirectional map
# (1,1,3) <---> (1,1,4)     #/
#
# (1,2,1) ---> (1,2,2)      #\ unidirectional map
# (1,2,3) ---> (1,2,4)      #/
#
# To create a customized map, set autoMapGeneration to "no" and use the map
# command below.
#
set testConf(autoMapGeneration) yes
set testConf(mapFromPort)       {1 1 1}          ;# chassisID cardId portID
set testConf(mapToPort)         {1 16 4}         ;# chassisID cardId portID
set testConf(mapDirection)      unidirectional   ;# unidirectional


# The ports in the "excludePorts" list will not be configured in the traffic map.
# Note that if there is a pair of ports that are transmitting and receiving, then
# include BOTH ports in this list.
# Format is as follows:     {{1 1 1} {1 1 1} {1 4 3} {1 4 4}}
#
set testConf(excludePorts)  {}


# Set up the map manually. Used only if autoMapGeneration set to "no". Note that
# if running IP or IPv6 test, the IP addresses MUST also be set up
# manually.
#
map new -type       one2one       ;# get rid of any existing map
map config -type    one2one


#--> Setup transmit-receive pairs as 'chassis-card-port' format
#        --------- TX ---------     --------- RX ---------
#         chassis   card    port      chassis   card  port
#
map add     1         1      1           1       1      2
map add     1         1      3           1       1      4


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
tunnel config -framesizeList        {128 256 512 1024 1280 1518}

# The approximate length of time frames are transmitted for each trial is set as
# a 'duration. The duration is in seconds; for example, if the duration is set to
# one second on a 100mbs switch, ~148810 frames will be transmitted.  This number
# must be an integer; minimum value is 1 second.
#
tunnel config -duration			    20


# Enter the percentage of Maximum Frame rate to use for running the test.
#
tunnel config -percentMaxRate       100


# One frame size/frame rate test is called a trial. The user may choose to run one or more
# trials; the average result of each trial will be presented in the result file.
#                             
tunnel config -numtrials            1


# Staggered start; if set to true, transmit start will be staggered; if
# set to false, transmit will start on all ports at the same time. 
#
tunnel config -staggeredStart       false

# Percentage of total packets sent to allow to be lost before declaring packet loss 
#
tunnel config -tolerance			0

# Select the protocol to be used to run this test.
# Supported protocols are IP and IPv6, this refers the protocol that is encapsulated by a tunnel.
#
set testConf(protocolName)          ipV6    ;# ip   = layer 3 IP
                                            ;# ipV6 = layer 3 IPv6


# Configure ethernetType to ethernetII and set the frameType to "08 00", Note that this value
#   is automatically set to 0x86dd when the protocol is IPv6.
#
set testConf(ethernetType)          ethernetII


# Configure how many and WHEN to send learn frames
#
learn config -when oncePerTest  ;# oncePerTest        = Send only once at the beginning of the test
                                ;# oncePerFramesize   = Send only in the beginning of a framesize
                                ;# onTrial            = Send at beginning of each trial of a framesize
                                ;# never              = Never send learn frames

learn config -numframes   10    ;# number of learning frames to send (
learn config -rate        100   ;# rate of learn frames Tx in fps (N/A for IPv6)
learn config -waitTime    1000  ;# time to wait between ports after sending learn frames, in milliseconds


# If you need the fastpath set up, set this to 'true'
#
fastpath config -enable         false


#--> IP/IPv6 port configuration
# IP/IPv6 addresses can be generated automatically with the any one byte (or address field
# in the case of IPv6) of the IP/IPv6 addressess incrementing for every port. This will be 
# done only if the map has been generated automatically.
#
# These setting also affects the address incrementation of the tunnel's payload packet.
#
set testConf(firstSrcIpAddress)         198.18.1.100
set testConf(firstDestDUTIpAddress)     198.18.1.1
set testConf(incrIpAddrByteNum)         3
#                                       1
#                                       2
#                                       3
#                                       4

set testConf(firstSrcIpV6Address)       2000:0:0:1::100
set testConf(firstDestDUTIpV6Address)   2000:0:0:1::1
set testConf(incrIpV6AddressField)      siteLevelAggregationId
#                                       interfaceId
#                                       subnetId
#                                       siteLevelAggregationId
#                                       nextLevelAggregationId
#                                       topLevelAggregationId



# Manual IP address setup. Used only if "autoMapGeneration" is set to "no"
# Also, you have to know which cards are physically present.
#
set SrcIpAddress(1,1,1)             198.18.1.100
set DestDUTIpAddress(1,1,1)         198.18.1.1

set SrcIpAddress(1,1,2)             198.18.2.100
set DestDUTIpAddress(1,1,2)         198.18.2.1

set SrcIpAddress(1,1,3)             198.18.3.100
set DestDUTIpAddress(1,1,3)         198.18.3.1

set SrcIpAddress(1,1,4)             198.18.4.100
set DestDUTIpAddress(1,1,4)         198.18.4.1

set SrcIpAddress(1,5,1)             198.18.5.100
set DestDUTIpAddress(1,5,1)         198.18.5.1

set SrcIpAddress(1,5,2)             198.18.6.100
set DestDUTIpAddress(1,5,2)         198.18.6.1

set SrcIpAddress(1,5,3)             198.18.7.100
set DestDUTIpAddress(1,5,3)         198.18.7.1

set SrcIpAddress(1,5,4)             198.18.8.100
set DestDUTIpAddress(1,5,4)         198.18.8.1


# Manual IPv6 address setup. Used only if "autoMapGeneration" is set to "no"
# Also, you have to know which cards are physically present.
#
set SrcIpV6Address(1,1,1)            2000:0:0:1::1:100
set DestDUTIpV6Address(1,1,1)        2000:0:0:1::1:1

set SrcIpV6Address(1,1,2)            2001:0:0:1::100
set DestDUTIpV6Address(1,1,2)        2001:0:0:1::1
                                               
set SrcIpV6Address(1,1,3)            2002:0:0:1::100
set DestDUTIpV6Address(1,1,3)        2002:0:0:1::1
                                               
set SrcIpV6Address(1,1,4)            2003:0:0:1::100
set DestDUTIpV6Address(1,1,4)        2003:0:0:1::1


# The payload protocol's packet is encapsulated within the tunnel protocol.
# When encapsulation at the transmitting port is desired, set encapsulation
# to 'ingress', when the DUT performs the encapsulation, set encapsulation
# to 'egress'.
#
# Valid configurations are: IPv6 tunneled within IPv4
#                           IPv4 tunneled within IPv6

# The encapsulating protocol.
tunnel config -tunnelProtocol        ip
#                                    ip
#                                    ipV6

# The encapsulated protocol.
tunnel config -payloadProtocol       ipV6
#                                    ip
#                                    ipV6

# Defines when the encapsulation occurs: if ingress, the transmitting port (Ixia)
#   peforms the encasulation, if egress, the DUT performs the encapsulation.
tunnel config -encapsulation         ingress
#                                    ingress
#                                    egress

# When manually configured, the IPv4 tunnel endpoint address is determined
#   by configuration information on the encapsulating node.  When automatically
#   configured, the IPv4 tunnel endpoint address is determined from the
#   IPv4 address embedded within the IPv4-Compatible destination address of the
#   IPv6 packet being tunneled.  Applies only to IPv6.
tunnel config -tunnelConfiguration   manual
#                                    manual
#                                    automatic

# When the -tunnelConfiguration is automatic, an automatic address type is
#   specified to determine the appearance of the IPv4 Compatible address.
tunnel config -addressType           ipV4Compatible
#                                    ipV4Compatible
#                                    6to4
#                                    isatap

# Length of the tunnel prefix as defined by the DUT.
tunnel config -prefixLength          16

# Defines the minimum or maximum # of tunnels (Capacity test)
tunnel config -minimumTunnels        1 
tunnel config -maximumTunnels        1  
#                                    57344  ;Maximum # of tunnels allowed


# Defines tunnel increment (Capacity test)
tunnel config -tunnelStep            1

set testConf(protocolName)           [tunnel cget -payloadProtocol]


# Defines which values will be reported as results.
tunnel config -enableLatency         false
tunnel config -enableSequenceTotal   true
tunnel config -enableSequenceDetail  false
tunnel config -enableDataIntegrity   true

# The results will be printed in this file in the "Results" directory of the parent directory
#
results config -resultFile          "ipv6TunnelCapacity.results"

# If set to true, the .csv file which has the same name with the results file will be 
# generated in the "Results" directory of the parent directory
#
results config -generateCSVFile         false



##################################################################################
##################################################################################
#   DON'T CHANGE ANYTHING BELOW HERE!!
##################################################################################
##################################################################################

if [configureTest one2one] {
    cleanUp
    return 1
}


if [catch {tunnel start -capacity} result] {
    logMsg "ERROR: $::errorInfo\n"
    cleanUp
    return
}


teardown
return












