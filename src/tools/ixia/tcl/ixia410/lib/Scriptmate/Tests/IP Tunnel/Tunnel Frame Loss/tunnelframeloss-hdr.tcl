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
set dummyHeader(Tunnel_tunnelFrameLoss) 1;

##################################################################################

global testCats;
set testCats(Tunnel) "IP Tunnel";

global Tunnel;
set Tunnel(tunnelFrameLoss) "Tunnel Frame Loss";

global automap;
set automap(Tunnel_tunnelFrameLoss) {Automatic};


set directions(Tunnel_tunnelFrameLoss) {Unidirectional};

global learnFrequencyValidValues;
set learnFrequencyValidValues(Tunnel_tunnelFrameLoss) {oncePerTest oncePerFramesize onTrial never};

global gTestCommand;
set gTestCommand(tunnelFrameLoss) tunnel;

global protocolsSupportedByTest;
set protocolsSupportedByTest(Tunnel_tunnelFrameLoss) {ip ipv6};

global supportResultsCsv
global supportAggResultsCsv
global supportIterationCsv
set supportResultsCsv(Tunnel_tunnelFrameLoss) true
set supportAggResultsCsv(Tunnel_tunnelFrameLoss) true
set supportIterationCsv(Tunnel_tunnelFrameLoss) true

##################################
# COMMAND: tunnel
##################################
proc scriptmateCommands::init_zz_tunnel {} \
{
    defineTest registerCommand tunnel

    # Generic Tunnel parameters.
    defineTest registerParameter \
    -command tunnel \
    -parameter testName \
    -type string \
    -defaultValue "Tunnel Test";

    defineTest registerParameter \
    -command tunnel \
    -parameter tunnelConfiguration \
    -type string \
    -defaultValue "manual" \
    -validValues {manual automatic};

    defineTest registerParameter \
    -command tunnel \
    -parameter encapsulation \
    -type string \
    -defaultValue "egress" \
    -validValues {egress ingress};

    defineTest registerParameter \
    -command tunnel \
    -parameter payloadProtocol \
    -type string \
    -defaultValue "ipV6" \
    -validValues {ipV6 ip};

    defineTest registerParameter \
    -command tunnel \
    -parameter tunnelProtocol \
        -type string \
    -defaultValue "ip" \
    -validValues {ipV6 ip};
  
    defineTest registerParameter \
    -command tunnel \
    -parameter prefixLength \
    -type integer \
    -defaultValue "16" \
    -validRange {1 128};

    defineTest registerParameter \
    -command tunnel \
    -parameter addressType \
    -type string \
    -defaultValue "ipV4Compatible" \
    -validValues {ipV4Compatible 6to4 isatap};

    defineTest registerParameter \
    -command tunnel \
    -parameter prefixType \
    -type string \
    -defaultValue "Global Unicast" \
    -validValues {"Global Unicast" "Link Local Unicast" "Site Local Unicast" "User Defined"}
                                                                                   
    # Results reported
    defineTest registerParameter \
    -command tunnel \
    -parameter enableLatency \
    -type boolean \
    -defaultValue true;

    defineTest registerParameter \
    -command tunnel \
    -parameter enableSequenceTotal \
    -type boolean \
    -defaultValue true;

    defineTest registerParameter \
    -command tunnel \
    -parameter enableSequenceDetail \
    -type boolean \
    -defaultValue false;

    defineTest registerParameter \
    -command tunnel \
    -parameter enableDataIntegrity \
    -type boolean \
    -defaultValue true;

    # Tput Parameters.                                                              
    defineTest registerParameter \
    -command tunnel \
    -parameter minimumFPS \
    -type integer \
    -defaultValue 10 \
    -validRange {1 36864000};

    defineTest registerParameter \
    -command tunnel \
    -parameter percentMaxRate \
    -type double \
    -defaultValue 100 \
    -validRange {0.001 100};

    defineTest registerParameter \
    -command tunnel \
    -parameter tolerance \
    -type double \
    -defaultValue 0 \
    -validRange {0 100};

    defineTest registerParameter \
    -command tunnel \
    -parameter linearBinarySearch \
    -type boolean \
    -defaultValue false;
                                                                                    
    # Floss Parameters.                                                             
    defineTest registerParameter \
    -command tunnel \
    -parameter numFrames \
    -type integer \
    -defaultValue 100000 \
    -validRange {1 2000000000};

    defineTest registerParameter \
    -command tunnel \
    -parameter grain \
    -type string \
    -defaultValue coarse \
    -validValues {fine coarse};

    # Capacity Parameters.                                                          
    defineTest registerParameter \
    -command tunnel \
    -parameter minimumTunnels \
    -type integer \
    -defaultValue 1 \
    -validRange {1 65534};

    defineTest registerParameter \
    -command tunnel \
    -parameter maximumTunnels \
    -type integer \
    -defaultValue 1 \
    -validRange {1 65534};

    defineTest registerParameter \
    -command tunnel \
    -parameter tunnelStep \
    -type integer \
    -defaultValue 1 \
    -validRange {1 65534};

    defineTest    registerTest   tunnel {tput floss capacity}
    defineCommand registerMethod tunnel registerResultVars {tput floss capacity}

}         

scriptmateCommands::init_zz_tunnel;

##################################################################################
# Begin user configuration here...
global testConf SrcIpAddress SrcIpV6Address DestDUTIpAddress DestDUTIpV6Address

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
set testConf(hdlcHeader)        ppp             ;# ppp or cisco
set testConf(PPPnegotiation)    false           ;# true enables PPP negotiation on PoS ports            
set testConf(dataScrambling)    true            ;# enable SPE data scrambling (true/false)
set testConf(useRecoveredClock) false           ;# enable useRecoveredClock (true/false)
set testConf(useMagicNumber)    false           ;# enable useMagicNumber (true/false)
set testConf(sonetTxCRC)        sonetCrc16      ;# sonetCrc16 or sonetCrc32
set testConf(sonetRxCRC)        sonetCrc16      ;# sonetCrc16 or sonetCrc32


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


# The -numFrames parameter is the total number of frames that will be transmitted during
# each trial.  The frame loss percent is calculated based on the formula:
#       ( ( TX_count - RX_count ) * 100 ) / TX_count, where
#       
#       TX_count = numFrames and RX_count = total number of received frames
# 
# NOTE: This number must be set to a value divisible by 100 so that precision is not
# lost. For example, if it is set to 122112, then it will be adjusted to 122100, an
# adjustment value of 12 frames.
#
tunnel config -numFrames            100000


# RFC2544 suggests that if there is frameloss, reduce the frame rate by 10% and re-run the
# test.  For example, if the frame size is set to 64 bytes at 100mbs, the max theoretical
# frame rate is 148810.  If there is frameloss at this rate, the frame rate will be reduced
# by 10%, (in this case, 133690, rounded up to the nearest clocktick) until 0% frameloss
# is achieved.
#
# Set the -grain parameter to 'coarse' to reduce the framerate by 10%; if the user prefers
# a finer grain search, the -grain parameter may be set to 'fine'.  This will modify the
# the frame rate reduction to 1%; for example, for a frame rate of 148810, at 1% the frame 
# rate will reduced to 147059 (rounded up to the nearest clocktick).
#
tunnel config -grain                coarse      ;# set to 'coarse' for a 10% search or 'fine' for a 1% search


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

set testConf(enable802dot1qTag)  false
set testConf(enableISLtag)       false

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

set SrcIpV6Address(1,1,2)            2000:0:0:2::100
set DestDUTIpV6Address(1,1,2)        2000:0:0:2::1

set SrcIpV6Address(1,1,3)            2000:0:0:3::100
set DestDUTIpV6Address(1,1,3)        2000:0:0:3::1
                                               
set SrcIpV6Address(1,1,4)            2000:0:0:4::100
set DestDUTIpV6Address(1,1,4)        2000:0:0:4::1


# The payload protocol's packet is encapsulated within the tunnel protocol.
# When encapsulation at the transmitting port is desired, set encapsulation
# to 'ingress', when the DUT performs the encapsulation, set encapsulation
# to 'egress'.
#
# Valid configurations are: IPv6 tunneled within IPv4
#                           IPv4 tunneled within IPv6 (currently unavailable)

# Indicates the protocol of the encapsulating packet.
tunnel config -tunnelProtocol        ip
#                                    ip
#                                    ipV6

# Indicates the protocol of the encapsulated packet.
tunnel config -payloadProtocol       ipV6
#                                    ip
#                                    ipV6

# Determines where encapsulation occurs.  If ingress, encapsulation occurs at the
#   Ixia transmitt port, if egress, the DUT performs encapsulation.
tunnel config -encapsulation         ingress
#                                    ingress
#                                    egress

# Determines whether the DUT anticipates manual or automatic tunnel configuration.
#   When automatic tunneling is used, the address for the encapsulating protocol is
#   derived from the address of the encapsulated protocol header.  When manual
#   configuration is used, the configuration of the DUT determines the tunnel routing
#   based upon the prefix of the address.
tunnel config -tunnelConfiguration   manual
#                                    manual
#                                    automatic

# When the -tunnelConfiguration is automatic, an automatic address type is
#   specified to determine the appearance of the IPv4 Compatible address.
tunnel config -addressType           ipV4Compatible
#                                    ipV4Compatible
#                                    6to4
#                                    isatap


# Defines IPv6 Prefix length, for example: 2000::1/16 (where 16 is the prefix length).
tunnel config -prefixLength          16

# Defines which values will be reported as results.
tunnel config -enableDataIntegrity   true

set testConf(protocolName)           [tunnel cget -payloadProtocol]

DummyHeaderLogFileNameSet "ipv6TunnelFrameLoss.log";

# The results will be printed in this file in the "Results" directory of the parent directory
#
results config -resultFile          "ipv6TunnelFloss.results"

# If set to true, the .csv file which has the same name with the results file will be 
# generated in the "Results" directory of the parent directory
#
results config -generateCSVFile     false



