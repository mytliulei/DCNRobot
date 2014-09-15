############################################################################################
#
#   Copyright © 1997 - 2004 by IXIA.
#   All Rights Reserved.
#
# Description: This file contains the script for running OSPF V2/V3 convergence test
#
#               For performing this test you need 3 ixia ports, one tx and 2 rx
#               1) Configure the ospf routers, interface, route range on rx ports
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
#############################################################################################
 namespace eval ospfSuite {}

#####################################################################
# ospfConvergence::xmdDef
# 
# DESCRIPTION:
# This variable contains the XML content used by PDF Report generation.
#  
###
set ospfConvergence::xmdDef  {
    <XMD>
       <Sources>
          <Source scope="Global" entity_name="" format_id="Default">
             <Fields>
                <Field>
                   <Name>AppName</Name>
                   <Value>ixScriptMate</Value>
                </Field>
                <Field>
                   <Name>AppVersion</Name>
                   <Value>2.1.2.3</Value>
                </Field>
             </Fields>
          </Source>
          <Source scope="results.csv" entity_name="ospfSuiteOspfConvergence" format_id=""/>
          <Source scope="info.csv" entity_name="ospfSuiteOspfConvergence_Info" format_id=""/>
       </Sources>
    </XMD>
}

#####################################################################
# ospfConvergence::statList
# 
# DESCRIPTION:
# This table contains a list of collected metrics to be displayed in
# the Real Time Graphs and written to RealTime.csv file.
#  
###
set ospfConvergence::statList \
    [list [list framesSent     [getTxPorts ospfConvergence::txRxArray] "Tx Frames per second" "Tx Frames" 1e0]\
	 [list framesReceived [getRxPorts ospfConvergence::txRxArray] "Rx Frames per second" "Rx Frames" 1e0]\
	 [list bitsSent       [getTxPorts ospfConvergence::txRxArray] "Tx Kbps"              "Tx Kb"     1e3]\
	 [list bitsReceived   [getRxPorts ospfConvergence::txRxArray] "Rx Kbps"              "Rx Kb"     1e3]\
	];
########################################################################################
# Procedure: ospfConvergence::registerResultVars
#
# Description: This command registers all the local variables that are used in the
# display of the results with the Results Options Database.  This procedure must exist
# for each test.
#
# Argument(s):
# Returned result:
########################################################################################
proc ospfConvergence::registerResultVars {} \
{
    if [ results addOptionToDB totalPacketLoss          "TotalPacketLoss(Actual + MisDirected)"  12  12   iter   ] { return 1 } 
    if [ results addOptionToDB convergenceMetric        "ConvergenceMetric(seconds)"             12  12   iter   ] { return 1 } 
    if [ results addOptionToDB totalRoutes              "MaxRoutesVerified"                      12  12   iter   ] { return 1 }
    if [ results addOptionToDB tolerance                "Tolerance(%)    "                       12  12   iter   ] { return 1 }
    if [ results addOptionToDB actualPacketLoss         "ActualPacketLoss"                       12  12   iter   ] { return 1 }
    if [ results addOptionToDB convergencePerWithdraw   "ConvergenceMetricPerWithdrawal(sec)"    12  12   iter   ] { return 1 }
    if [ results addOptionToDB numWithdraw              "Number of Withdrawals"                  12  12   iter   ] { return 1 }
    if [ results addOptionToDB numberOfRoutes           "NumberOfRoutes  "                       12  12   iter   ] { return 1 }
    if [ results addOptionToDB packetRate               "PacketRate (PPS)"                       12  12   iter   ] { return 1 }
    if [ results addOptionToDB routeStep                "RouteStep       "                       12  12   iter   ] { return 1 }
    if [ results addOptionToDB misDirectedPackets       "MisDirectedPackets"                     12  12   iter   ] { return 1 }
    if [ results addOptionToDB txDurationPerFlap        "Tx Duration Per Flap (sec)"             12  12   iter   ] { return 1 }
                                                        
    # configuration information stored for results      
    if [ results registerTestVars testName              testName            [ospfSuite cget -testName]  test ] { return 1 }
    if [ results registerTestVars protocol              protocolName        [string toupper [getProtocolName [protocol cget -name]]] \
                                                                                    test ] { return 1 }
    if [ results registerTestVars chassisName           chassisName         [chassis cget -name]            test ] { return 1 }
    if [ results registerTestVars chassisID             chassisID           [chassis cget -id]              test ] { return 1 }
    if [ results registerTestVars productName           productName         [user cget -productname]        test ] { return 1 }
    if [ results registerTestVars versionNumber         versionNumber       [user cget -version]            test ] { return 1 }
    if [ results registerTestVars serialNumber          serialNumber        [user cget -serial#]            test ] { return 1 }
    if [ results registerTestVars userName              userName            [user cget -username]           test ] { return 1 }
    if [ results registerTestVars percentMaxRate        percentMaxRate      [ospfSuite cget -percentMaxRate] test ] { return 1 }
    if [ results registerTestVars numTrials             numTrials           [ospfSuite cget -numtrials]      test ] { return 1 }
    if [ results registerTestVars duration              duration            [ospfSuite cget -duration]       test ] { return 1 }
                                                        
    # results obtained after each iteration             
    if [ results registerTestVars transmitFrames        txActualFrames      0                               port TX ] { return 1 }
    if [ results registerTestVars receiveFrames         rxNumFrames         0                               port RX ] { return 1 }
    if [ results registerTestVars totalTxFrames         totalTxNumFrames    0                               iter    ] { return 1 }     
    if [ results registerTestVars totalRxFrames         totalRxNumFrames    0                               iter    ] { return 1 }
    if [ results registerTestVars percentLoss           totalLoss           0                               iter    ] { return 1 }
    if [ results registerTestVars totalPacketLoss       totalPacketLoss     0                               iter    ] { return 1 }
    if [ results registerTestVars convergenceMetric     convergenceMetric   0                               iter    ] { return 1 }
    if [ results registerTestVars totalRoutes           totalRoutes         0                               iter    ] { return 1 }
    if [ results registerTestVars tolerance             tolerance           0                               iter    ] { return 1 }
    if [ results registerTestVars actualPacketLoss      actualPacketLoss    0                               iter    ] { return 1 }
    if [ results registerTestVars convergencePerWithdraw convergencePerWithdraw  0                          iter    ] { return 1 }
    if [ results registerTestVars numWithdraw           numWithdraw         0                               iter    ] { return 1 }
    if [ results registerTestVars numberOfRoutes        numberOfRoutes      0                               iter    ] { return 1 }
    if [ results registerTestVars packetRate            packetRate          0                               iter    ] { return 1 }
    if [ results registerTestVars routeStep             routeStep           0                               iter    ] { return 1 }
    if [ results registerTestVars misDirectedPackets    misDirectedPackets  0                               iter    ] { return 1 }
    if [ results registerTestVars txDurationPerFlap     txDurationPerFlap   0                               iter    ] { return 1 }

    return 0
}

#####################################################################
# ospfConvergence::attributes
# 
# DESCRIPTION:
# This attributes table contains a list of attributes used by the
# test algorithm or other backend test engine functions.  This
# table is used to initialize these attributes for later use.
#  
###
set ospfConvergence::attributes { 

    {
	{ NAME              testName }
	{ BACKEND_TYPE      string }
	{ DEFAULT_VALUE     "OPSF Convergence" }
	{ VARIABLE_CLASS    testCmd }
    }

    {
	{ NAME              numtrials }
	{ BACKEND_TYPE      integer }
	{ DEFAULT_VALUE     1 } 
	{ MIN               1 }
	{ MAX               NULL }
	{ LABEL             "No. of Trials: " }
	{ VARIABLE_CLASS    testCmd }
    }

    {
	{ NAME              percentMaxRate }
	{ BACKEND_TYPE      double }
	{ DEFAULT_VALUE     100 }
	{ MIN               1 }
	{ MAX               100 }
	{ LABEL             "Max Rate (%): " }
	{ VARIABLE_CLASS    testCmd }
    }

    {
	{ NAME              areaId }
	{ BACKEND_TYPE      integer }
	{ DEFAULT_VALUE     0 } 
	{ MIN               0 }
	{ MAX               NULL }
	{ LABEL             "Area ID: " }
	{ VARIABLE_CLASS    testCmd }
    }

    {
	{ NAME              numberOfFlaps }
	{ BACKEND_TYPE      integer }
	{ DEFAULT_VALUE     1 } 
	{ MIN               0 }
	{ MAX               NULL }
	{ LABEL             "No. of Withdrawals: " }
	{ VARIABLE_CLASS    testCmd }
    }

    { 
	{ NAME              transmitDurationBetweenFlaps }
	{ BACKEND_TYPE      double }
	{ DEFAULT_VALUE     20 }
	{ MIN               20 }
	{ MAX               NULL }
	{ LABEL             "Transmit Duration Between Flaps (s): " }
	{ VARIABLE_CLASS    testCmd }
    }   

    {
	{ NAME              dutProcessingDelay }
	{ BACKEND_TYPE      double }
	{ DEFAULT_VALUE     30 }
	{ MIN               10 }
	{ MAX               NULL }
	{ LABEL             "DUT Processing Delay:" }
	{ VARIABLE_CLASS    testCmd }
    }

    {
	{ NAME              transmitTimeout }
	{ BACKEND_TYPE      double }
	{ DEFAULT_VALUE     60 }
	{ MIN               10 }
	{ MAX               NULL }
	{ LABEL             "Transmit Timeout (s): " }
	{ VARIABLE_CLASS    testCmd }
    }

    {
	{ NAME              networkType }
	{ BACKEND_TYPE      string }
	{ DEFAULT_VALUE     Broadcast }
	{ VALID_VALUES      {Broadcast "Point To Point"} }
	{ LABEL             "Interface Network Type: " }
	{ VARIABLE_CLASS    null }
	{ ON_INIT           ospfConvergence::OnInterfaceNetworkInit }
	{ ON_CHANGE         ospfConvergence::OnInterfaceNetworkChange }
    }

    {
	{ NAME              interfaceNetworkType }
	{ BACKEND_TYPE      string }
	{ DEFAULT_VALUE     ospfBroadcast }
	{ VALID_VALUES      {ospfBroadcast ospfPointToPoint} }
	{ VARIABLE_CLASS    testCmd }
    }

    {
	{ NAME              enableValidateMtu }	    
	{ BACKEND_TYPE      integer }
	{ DEFAULT_VALUE     0 }
	{ VALID_VALUES      {1 0} }
	{ LABEL             "Validate MTU Size " }
	{ VARIABLE          enableValidateMtu }
	{ ON_INIT           ospfConvergence::enableValidateMtuCmd }
	{ ON_CHANGE         ospfConvergence::enableValidateMtuCmd }
	{ VARIABLE_CLASS    testCmd }
    }

    {
	{ NAME              enableOspfV2 }	    
	{ BACKEND_TYPE      boolean }
	{ DEFAULT_VALUE     false }
	{ VALID_VALUES      {true false} }
	{ VARIABLE          enableOspfV2 }
	{ VARIABLE_CLASS    testCmd }
    }

    {
	{ NAME              enableOspfV3 }	    
	{ BACKEND_TYPE      boolean }
	{ DEFAULT_VALUE     false }
	{ VALID_VALUES      {true false} }
	{ VARIABLE          enableOspfV3 }
	{ VARIABLE_CLASS    testCmd }
    }

    {
	{ NAME              interfaceMTUSize }
	{ BACKEND_TYPE      integer }
	{ DEFAULT_VALUE     1500 }
	{ MIN               26 }
	{ MAX               65535 }
	{ LABEL             "Transmit Timeout (s): " }
	{ VARIABLE_CLASS    testCmd }
    }

    {
	{ NAME              enableOspfV2SummaryLsa }	    
	{ BACKEND_TYPE      boolean }
	{ DEFAULT_VALUE     true }
	{ VALID_VALUES      {true false} }
	{ LABEL             "OspfV2 Advertise Summary LSA " }
	{ VARIABLE          enableOspfV2SummaryLsa }
	{ ON_INIT           ospfConvergence::enableOspfLsaCmd }
	{ ON_CHANGE         ospfConvergence::enableOspfLsaCmd }
	{ VARIABLE_CLASS    testCmd }
    }

    {
	{ NAME              numOspfV2SummaryLsa }
	{ BACKEND_TYPE      integer }
	{ DEFAULT_VALUE     4096 } 
	{ MIN               1 }
	{ MAX               131072 }
	{ LABEL             "Number LSA: " }
	{ ON_INIT           ospfConvergence::numOspfLsaCmd }
	{ ON_CHANGE         ospfConvergence::numOspfLsaCmd }
	{ VARIABLE_CLASS    testCmd }
    }

    {
	{ NAME              flapOspfV2SummaryLsa }	    
	{ BACKEND_TYPE      boolean }
	{ DEFAULT_VALUE     true }
	{ VALID_VALUES      {true false} }
	{ LABEL             "Withdraw Summary LSA " }
	{ VARIABLE          flapOspfV2SummaryLsa }
	{ ON_INIT           ospfConvergence::withdrawOspfLsaCmd }
	{ ON_CHANGE         ospfConvergence::withdrawOspfLsaCmd }
	{ VARIABLE_CLASS    testCmd }
    }

    {
	{ NAME              enableOspfV2ExternalLsa }	    
	{ BACKEND_TYPE      boolean }
	{ DEFAULT_VALUE     false }
	{ VALID_VALUES      {true false} }
	{ LABEL             "OspfV2 Advertise External LSA " }
	{ VARIABLE          enableOspfV2ExternalLsa }
	{ ON_INIT           ospfConvergence::enableOspfLsaCmd }
	{ ON_CHANGE         ospfConvergence::enableOspfLsaCmd }
	{ VARIABLE_CLASS    testCmd }
    }

    {
	{ NAME              numOspfV2ExternalLsa }
	{ BACKEND_TYPE      integer }
	{ DEFAULT_VALUE     100 } 
	{ MIN               1 }
	{ MAX               131072 }
	{ LABEL             "Number LSA: " }
	{ ON_INIT           ospfConvergence::numOspfLsaCmd }
	{ ON_CHANGE         ospfConvergence::numOspfLsaCmd }
	{ VARIABLE_CLASS    testCmd }
    }

    {
	{ NAME              flapOspfV2ExternalLsa }	    
	{ BACKEND_TYPE      boolean }
	{ DEFAULT_VALUE     false }
	{ VALID_VALUES      {true false} }
	{ LABEL             "Withdraw External LSA " }
	{ VARIABLE          flapOspfV2ExternalLsa }
	{ ON_INIT           ospfConvergence::withdrawOspfLsaCmd }
	{ ON_CHANGE         ospfConvergence::withdrawOspfLsaCmd }
	{ VARIABLE_CLASS    testCmd }
    }

    {
	{ NAME              enableOspfV2RouterLsa }	    
	{ BACKEND_TYPE      boolean }
	{ DEFAULT_VALUE     false }
	{ VALID_VALUES      {true false} }
	{ LABEL             "OspfV2 Advertise Router LSA " }
	{ VARIABLE          enableOspfV2RouterLsa }
	{ ON_INIT           ospfConvergence::enableOspfLsaCmd }
	{ ON_CHANGE         ospfConvergence::enableOspfLsaCmd }
	{ VARIABLE_CLASS    testCmd }
    }

    {
	{ NAME              numOspfV2RouterLsa }
	{ BACKEND_TYPE      integer }
	{ DEFAULT_VALUE     100 } 
	{ MIN               1 }
	{ MAX               40000 }
	{ LABEL             "Number LSA: " }
	{ ON_INIT           ospfConvergence::numOspfLsaCmd }
	{ ON_CHANGE         ospfConvergence::numOspfLsaCmd }
	{ VARIABLE_CLASS    testCmd }
    }

    {
	{ NAME              flapOspfV2RouterLsa }	    
	{ BACKEND_TYPE      boolean }
	{ DEFAULT_VALUE     false }
	{ VALID_VALUES      {true false} }
	{ LABEL             "Withdraw Router LSA " }
	{ VARIABLE          flapOspfV2RouterLsa }
	{ ON_INIT           ospfConvergence::withdrawOspfLsaCmd }
	{ ON_CHANGE         ospfConvergence::withdrawOspfLsaCmd }
	{ VARIABLE_CLASS    testCmd }
    }

    {
	{ NAME              enableOspfV3InterAreaPrefixLsa }	    
	{ BACKEND_TYPE      boolean }
	{ DEFAULT_VALUE     false }
	{ VALID_VALUES      {true false} }
	{ LABEL             "OspfV3 Advertise Summary LSA " }
	{ VARIABLE          enableOspfV3InterAreaPrefixLsa }
	{ ON_INIT           ospfConvergence::enableOspfLsaCmd }
	{ ON_CHANGE         ospfConvergence::enableOspfLsaCmd }
	{ VARIABLE_CLASS    testCmd }
    }

    {
	{ NAME              numOspfV3InterAreaPrefixLsa }
	{ BACKEND_TYPE      integer }
	{ DEFAULT_VALUE     100 } 
	{ MIN               1 }
	{ MAX               131072 }
	{ LABEL             "Number LSA: " }
	{ ON_INIT           ospfConvergence::numOspfLsaCmd }
	{ ON_CHANGE         ospfConvergence::numOspfLsaCmd }
	{ VARIABLE_CLASS    testCmd }
    }

    {
	{ NAME              flapOspfV3InterAreaPrefixLsa }	    
	{ BACKEND_TYPE      boolean }
	{ DEFAULT_VALUE     false }
	{ VALID_VALUES      {true false} }
	{ LABEL             "Withdraw Summary LSA " }
	{ VARIABLE          flapOspfV3InterAreaPrefixLsa }
	{ ON_INIT           ospfConvergence::withdrawOspfLsaCmd }
	{ ON_CHANGE         ospfConvergence::withdrawOspfLsaCmd }
	{ VARIABLE_CLASS    testCmd }
    }

    {
	{ NAME              enableOspfV3ExternalLsa }	    
	{ BACKEND_TYPE      boolean }
	{ DEFAULT_VALUE     false }
	{ VALID_VALUES      {true false} }
	{ LABEL             "OspfV3 Advertise External LSA " }
	{ VARIABLE          enableOspfV3ExternalLsa }
	{ ON_INIT           ospfConvergence::enableOspfLsaCmd }
	{ ON_CHANGE         ospfConvergence::enableOspfLsaCmd }
	{ VARIABLE_CLASS    testCmd }
    }

    {
	{ NAME              numOspfV3ExternalLsa }
	{ BACKEND_TYPE      integer }
	{ DEFAULT_VALUE     100 } 
	{ MIN               1 }
	{ MAX               131072 }
	{ LABEL             "Number LSA: " }
	{ ON_INIT           ospfConvergence::numOspfLsaCmd }
	{ ON_CHANGE         ospfConvergence::numOspfLsaCmd }
	{ VARIABLE_CLASS    testCmd }
    }

    {
	{ NAME              flapOspfV3ExternalLsa }	    
	{ BACKEND_TYPE      boolean }
	{ DEFAULT_VALUE     false }
	{ VALID_VALUES      {true false} }
	{ LABEL             "Withdraw External LSA " }
	{ VARIABLE          flapOspfV3ExternalLsa }
	{ ON_INIT           ospfConvergence::withdrawOspfLsaCmd }
	{ ON_CHANGE         ospfConvergence::withdrawOspfLsaCmd }
	{ VARIABLE_CLASS    testCmd }
    }

    {
	{ NAME              enableOspfV3RouterLsa }	    
	{ BACKEND_TYPE      boolean }
	{ DEFAULT_VALUE     false }
	{ VALID_VALUES      {true false} }
	{ LABEL             "OspfV3 Advertise Router LSA " }
	{ VARIABLE          enableOspfV3RouterLsa }
	{ ON_INIT           ospfConvergence::enableOspfLsaCmd }
	{ ON_CHANGE         ospfConvergence::enableOspfLsaCmd }
	{ VARIABLE_CLASS    testCmd }
    }

    {
	{ NAME              numOspfV3RouterLsa }
	{ BACKEND_TYPE      integer }
	{ DEFAULT_VALUE     100 } 
	{ MIN               1 }
	{ MAX               20000 }
	{ LABEL             "Number LSA: " }
	{ ON_INIT           ospfConvergence::numOspfLsaCmd }
	{ ON_CHANGE         ospfConvergence::numOspfLsaCmd }
	{ VARIABLE_CLASS    testCmd }
    }

    {
	{ NAME              flapOspfV3RouterLsa }	    
	{ BACKEND_TYPE      boolean }
	{ DEFAULT_VALUE     false }
	{ VALID_VALUES      {true false} }
	{ LABEL             "Withdraw Router LSA " }
	{ VARIABLE          flapOspfV3RouterLsa }
	{ ON_INIT           ospfConvergence::withdrawOspfLsaCmd }
	{ ON_CHANGE         ospfConvergence::withdrawOspfLsaCmd }
	{ VARIABLE_CLASS    testCmd }
    }

    {
	{ NAME              advertiseDelayPerRoute }
	{ BACKEND_TYPE      double }
	{ DEFAULT_VALUE     0.0007 }
	{ MIN               0 }
	{ MAX               NULL }
	{ LABEL             "Advertise Delay Per LSA (s): " }
	{ VARIABLE_CLASS    testCmd }
	{ ON_INIT           ospfConvergence::advertiseDelayPerRouteCmd }
	{ ON_CHANGE         ospfConvergence::advertiseDelayPerRouteCmd }
	{ VARIABLE_CLASS    testCmd }
    }

    {
	{ NAME              totalDelay }
	{ BACKEND_TYPE      string }
	{ DEFAULT_VALUE     3 }
	{ LABEL             "Max Wait Time (s):\n    (# of LSAs x AdvertiseDelay) " }
	{ ON_INIT           ospfConvergence::totalDelayCmd }
	{ VARIABLE_CLASS    testCmd }
    }

    {
	{ NAME              interfaceIpMask }
	{ BACKEND_TYPE      ipaddress }
	{ DEFAULT_VALUE     255.255.255.0 }
	{ VARIABLE_CLASS    testCmd }
    }

    {
	{ NAME              frameSizeWidget }	    
	{ BACKEND_TYPE      null }
	{ VARIABLE_CLASS    null }
    }

    {
	{ NAME              frameDataWidget }	    
	{ BACKEND_TYPE      null }
	{ VARIABLE_CLASS    null }
    }

    {
	{ NAME              trafficMapWidget } 
	{ BACKEND_TYPE      null }
	{ VARIABLE_CLASS    null }
    }

    {
	{ NAME              userInfoWidget }        
	{ BACKEND_TYPE      null }
	{ VARIABLE_CLASS    null }
    }

    {
	{ NAME              protocolName }
	{ BACKEND_TYPE      string }
	{ DEFAULT_VALUE     ip/ipV6 }
	{ VARIABLE_CLASS    testConf }
	{ DESCRIPTION {
	    "Select the protocol to be used to run this test."
	    "Supported protocols are IP and IPV6. NOTE: Use lowercase ip or ipV6"
	    "ip   = layer 3 IP"
	    "ipV6 = layer 3 IP Version 6"
	    "ip/ipV6 = both IP and IPv6"
	} }
    }

    {
	{ NAME              ethernetType }
	{ BACKEND_TYPE      string }
	{ DEFAULT_VALUE     ethernetII }
	{ VARIABLE_CLASS    testConf }
	{ DESCRIPTION {
	    "Configure ethernetType to ethernetII and set the frameType to \"08 00\"."
	    "Note: Used only if protocol is set to mac."
	} }
    }
    {
	{ NAME              framesizeList }
	{ BACKEND_TYPE      string }
	{ DEFAULT_VALUE     {64 128 256 512 1024 1280 1518} }               
	{ VARIABLE_CLASS    testCmd }
    }

    {
	{ NAME              autoMapGeneration }
	{ BACKEND_TYPE      boolean }
	{ DEFAULT_VALUE     no }
	{ VALID_VALUES      {no} }
	{ VARIABLE_CLASS    testConf }
    }

    {
	{ NAME              automap }
	{ BACKEND_TYPE      string }
	{ DEFAULT_VALUE     {Manual} }
	{ VARIABLE_CLASS    automap }
    }

    {
	{ NAME              map }
	{ BACKEND_TYPE      string }
	{ DEFAULT_VALUE     one2many }
	{ VARIABLE_CLASS    map }
    }

    { 
	{ NAME              doNotSupportLearn }
	{ BACKEND_TYPE      integer }
	{ DEFAULT_VALUE     1 }
	{ VARIABLE_CLASS    doNotSupportLearn }
    }


    {     
	{ NAME              gTestCommand }
	{ BACKEND_TYPE      string }
	{ DEFAULT_VALUE     ospfSuite }
	{ VARIABLE_CLASS    gTestCommand }
    }

    {
	{ NAME              protocolsSupportedByTest }
	{ BACKEND_TYPE      string }
	{ DEFAULT_VALUE     {ip ipv6} }
	{ VARIABLE_CLASS    protocolsSupportedByTest }
    }

    {
	{ NAME              enablePassFail }	    
	{ BACKEND_TYPE      integer }
	{ DEFAULT_VALUE     0 }
	{ VALID_VALUES      {1 0} }
	{ LABEL             Enable }
	{ VARIABLE          passFailEnable }
	{ VARIABLE_CLASS    testConf }
	{ ON_CHANGE         ospfConvergence::PassFailEnable }
    }

    {
	{ NAME              advertiseThresholdValue }
	{ BACKEND_TYPE      double }
	{ DEFAULT_VALUE     100 }
	{ MIN               0.00 }
	{ LABEL             "Avg Advertise Convergence Time (s) <= " }
	{ VARIABLE          passFailConvergenceAdvertiseValue }
	{ VARIABLE_CLASS    testConf }
    }
    
    {
	{ NAME              withdrawThresholdValue }
	{ BACKEND_TYPE      double }
	{ DEFAULT_VALUE     100 }
	{ MIN               0.00 }
	{ LABEL             "Avg Withdraw Convergence Time (s) <= " }
	{ VARIABLE          passFailConvergenceWithdrawValue }
	{ VARIABLE_CLASS    testConf }
    }

    {
	{ NAME              resultFile }
	{ BACKEND_TYPE      string }
	{ DEFAULT_VALUE     ospfConvergence.results }
	{ VARIABLE_CLASS    results }
    }

    {
	{ NAME              generateCSVFile }
	{ BACKEND_TYPE      boolean }
	{ DEFAULT_VALUE     false }
	{ VALID_VALUES      {true false} }
	{ VARIABLE_CLASS    results }
    }

    {
	{ NAME              logFileName }
	{ BACKEND_TYPE      string }
	{ DEFAULT_VALUE     ospfConvergence.log }
	{ VARIABLE_CLASS    logger }
    }
    
    {
        { NAME              supportResultsCsv }
        { BACKEND_TYPE      boolean }
        { DEFAULT_VALUE     true }
        { VARIABLE_CLASS    supportResultsCsv }
    }

    {
        { NAME              supportAggResultsCsv }  
        { BACKEND_TYPE      boolean }
        { DEFAULT_VALUE     false }
        { VARIABLE_CLASS    supportAggResultsCsv }
    }   

    {
        { NAME              supportIterationCsv }
        { BACKEND_TYPE      boolean }
        { DEFAULT_VALUE     false }
        { VARIABLE_CLASS    supportIterationCsv }
    }

    {
	{ NAME              mapType }
	{ BACKEND_TYPE      string }
	{ DEFAULT_VALUE     one2many }
        { VALID_VALUES      {one2one one2many many2one many2many} }
	{ VARIABLE          ospfMapType }
	{ VARIABLE_LABEL    mapType }
    }

    {
	{ NAME              networkIpAddress }
	{ BACKEND_TYPE      ipaddress }
	{ DEFAULT_VALUE     10.0.0.0 }
	{ VALID_VALUES       { 10.0.0.0 } }
	{ VARIABLE_CLASS    testCmd }
    { DESCRIPTION {
        "This value is hard-coded in the test. DO NOT change it!"
    } }
    }

    {
	{ NAME              ospfV2RouterLsaRouterId }
	{ BACKEND_TYPE      ipaddress }
	{ DEFAULT_VALUE     25.0.0.1 }
	{ VALID_VALUES       { 25.0.0.1 } }
	{ VARIABLE_CLASS    testCmd }
    { DESCRIPTION {
        "This value is hard-coded in the test. DO NOT change it!"
    } }
    }

    {
	{ NAME              ospfV2RouterLsaSubnet }
	{ BACKEND_TYPE      ipaddress }
	{ DEFAULT_VALUE     17.0.0.0 }
	{ VALID_VALUES       {  17.0.0.0  } }
	{ VARIABLE_CLASS    testCmd }
    { DESCRIPTION {
        "This value is hard-coded in the test. DO NOT change it!"
    } }
    }


    {
	{ NAME              ospfV2ExternalLsaSubnet }
	{ BACKEND_TYPE      ipaddress }
	{ DEFAULT_VALUE     192.1.0.0 }
	{ VALID_VALUES       { 192.1.0.0 } }
	{ VARIABLE_CLASS    testCmd }
    { DESCRIPTION {
        "This value is hard-coded in the test. DO NOT change it!"
    } }
    }

    {
	{ NAME              ospfV3RouterLsaRouterId }
	{ BACKEND_TYPE      ipaddress }
	{ DEFAULT_VALUE     50.0.0.1 }
	{ VALID_VALUES       {50.0.0.1 } }
	{ VARIABLE_CLASS    testCmd }
    { DESCRIPTION {
        "This value is hard-coded in the test. DO NOT change it!"
    } }
    }

    {
	{ NAME              ospfV3RouterLsaSubnet }
	{ BACKEND_TYPE      string }
	{ DEFAULT_VALUE     "2003:EEAA::0" }
	{ VALID_VALUES       { "2003:EEAA::0" } }
	{ VARIABLE_CLASS    testCmd }
    { DESCRIPTION {
        "This value is hard-coded in the test. DO NOT change it!"
    } }
    }

    {
    { NAME              ospfV3ExternalLsaSubnet }
    { BACKEND_TYPE      string }
    { DEFAULT_VALUE     "2004:1240::0" }
    { VALID_VALUES       { "2004:1240::0" } }
    { VARIABLE_CLASS    testCmd }
    { DESCRIPTION {
        "This value is hard-coded in the test. DO NOT change it!"
    } }
    }

    {
    { NAME              ospfV3InterAreaPrefixLsaSubnet }
    { BACKEND_TYPE      string }
    { DEFAULT_VALUE     "2005:1002::0" }
    { VALID_VALUES       { "2005:1002::0" } }
    { VARIABLE_CLASS    testCmd }
    { DESCRIPTION {
        "This value is hard-coded in the test. DO NOT change it!"
    } }
    }

    {
    { NAME              ospfV3PrefixLength }
    { BACKEND_TYPE      integer }
    { DEFAULT_VALUE     64}
    { VALID_VALUES       { 64} }
    { VARIABLE_CLASS    testCmd }
    { DESCRIPTION {
        "This value is hard-coded in the test. DO NOT change it!"
    } }
    }

    {
    { NAME              prefixLength }
    { BACKEND_TYPE      string }
    { DEFAULT_VALUE     24 }
    { VALID_VALUES       { 24 } }
    { VARIABLE_CLASS    testCmd }
    { DESCRIPTION {
        "This value is hard-coded in the test. DO NOT change it!"
    } }
    }

}

#############################################################################
# ospfConvergence::TestSetup()
#
# DESCRIPTION
# This procedure initializes common code elements needed at the beginning of a 
# test.
#
# RETURNS:  
# status      TCL_OK     - on success
#             TCL_ERROR  - on failure
#
###
proc ospfConvergence::TestSetup {} {
    variable txRxArray
    variable ospfPorts
    variable totalFlapLsa
    variable resultArray
    variable averageConvergenceArray
    variable protocolList
    variable protcolStatList
    variable protocolNameList
    variable flapOspfV2SummaryLsa
    variable flapOspfV2ExternalLsa
    variable flapOspfV2RouterLsa
    variable flapOspfV3ExternalLsa
    variable flapOspfV3RouterLsa
    variable flapOspfV3InterAreaPrefixLsa
    variable percentMaxRate
    variable trial;
    variable framesize;
    variable frameSizeList;
    variable status;

    set status $::TCL_OK

    set totalFlapLsa    [ospfSuite::getTotalWithdrawnLsas]

    ospfSuite::clearResultArray resultArray
    catch {unset averageConvergenceArray}

    ospfSuite config -testName "OSPF Convergence Test"
    learn config -when        oncePerTest
    
    set protocolList     {}
    set protcolStatList  {}
    set protocolNameList {}

    if {[ospfSuite cget -enableOspfV2] == "true"} {
       lappend protocolList ospf
       lappend protcolStatList enableOspfStats
       lappend protocolNameList ip
    }

    if {[ospfSuite cget -enableOspfV3] == "true"} {
       lappend protocolList ospfV3
       lappend protcolStatList enableOspfV3Stats
       lappend protocolNameList ipV6
    }

    if {[llength $protocolList] == 0} {
       errorMsg "Please select a protocol."
       return $::TCL_ERROR
    }
    advancedTestParameter config -protocolName [join $protocolNameList /]
    

    if [initTest ospfSuite txRxArray {ip ipV6} errMsg] {
       errorMsg $errMsg
return $::TCL_ERROR
    }

    if [changePortReceiveMode ospfPorts $::portRxModeWidePacketGroup nowrite no] {
       logMsg "***** WARNING: Some interfaces don't support [getTxRxModeString $rxMode RX] simultaneously."
       return $::TCL_ERROR
    }

    if [changePortTransmitMode [getTxPorts txRxArray] $::portTxModeAdvancedScheduler] {
       logMsg "***** WARNING: Some interfaces don't support AdvancedScheduler."
       return $::TCL_ERROR
    } 

    set  flapOspfV2SummaryLsa           [ospfSuite cget -flapOspfV2SummaryLsa]
    set  flapOspfV2ExternalLsa          [ospfSuite cget -flapOspfV2ExternalLsa]
    set  flapOspfV2RouterLsa            [ospfSuite cget -flapOspfV2RouterLsa]
    set  flapOspfV3ExternalLsa          [ospfSuite cget -flapOspfV3ExternalLsa]
    set  flapOspfV3RouterLsa            [ospfSuite cget -flapOspfV3RouterLsa]
    set  flapOspfV3InterAreaPrefixLsa   [ospfSuite cget -flapOspfV3InterAreaPrefixLsa]

    set  percentMaxRate                 [ospfSuite cget -percentMaxRate]

    return $status;
}

#############################################################################
# ospfConvergence::TestCleanUp()
#
# DESCRIPTION
# This procedure resets common code elements needed at the end of a test.
#
# RETURNS:  
# status      TCL_OK     - on success
#             TCL_ERROR  - on failure
#
###
proc ospfConvergence::TestCleanUp {} {
    variable status
    
    set status $::TCL_OK

    ospfSuite::writeResultsFile

    return $status;
}

#############################################################################
# ospfConvergence::TrialSetup()
#
# DESCRIPTION
# This procedure initializes common code elements needed at the beginning of a 
# trial.
#
# RETURNS:  
# status      TCL_OK     - on success
#             TCL_ERROR  - on failure
#
###
proc ospfConvergence::TrialSetup {} {
    variable framesize
    variable trial
    variable status

    set status $::TCL_OK
    
    logMsg " ******* TRIAL $trial - [ospfSuite cget -testName] ***** "

    return $status;
}    

#############################################################################
# ospfConvergence::AlgorithmSetup()
#
# DESCRIPTION
# This procedure initializes streams an other elements needed by the core
# test algorithm.
#
# RETURNS:  
# status      TCL_OK     - on success
#             TCL_ERROR  - on failure
#
###
proc ospfConvergence::AlgorithmSetup {} {
    variable txRxArray
    variable ospfPorts
    variable protocolList
    variable protcolStatList
    variable protocolNameList
    variable trial;
    variable framesize;
    variable status;

    set status $::TCL_OK

    ospfSuite config -framesize  $framesize
    set framesizeString "Framesize:$framesize"

    ######## set up results for this test
    setupTestResults ospfSuite one2many ""                                \
	txRxArray                       \
	$framesize                          \
	[ipmulticast cget -numtrials]       \
	true                                \
	[ipmulticast cget -numIterations]   \
	ospfConvergence

    cleanUpOspfGlobals

   ospfSuite config -numberOfRoutes [ospfSuite cget -numOspfV2SummaryLsa]
   if [enableProtocolServer ospfPorts $protocolList  noWrite] {
       errorMsg "***** Error enabling OSPF..."
       return $::TCL_ERROR
   }

   if [enableProtocolStatistics  ospfPorts $protcolStatList] {
       errorMsg "***** Error enabling OSPF statistics..."
       return $::TCL_ERROR
   }

   if [ospfSuite::configureOspfProtocols txRxArray] {
       errorMsg "***** Error configuring OSPF..."
       return $::TCL_ERROR
   }

    return $status;
}

#############################################################################
# ospfConvergence::AlgorithmBody()
#
# DESCRIPTION
# This procedure wraps the details of the search and mesurment components of
# the Algorithm.  This may include binary searching, linear searching,
# measurement during search, measurement after search, etc.
#
# ARGS:
# none
#  
# RETURNS:  
# status      TCL_OK     - on success
#             TCL_ERROR  - on failure
#
###
proc ospfConvergence::AlgorithmBody {} {
    variable txRxArray
    variable ospfPorts
    variable totalFlapLsa
    variable resultArray
    variable averageConvergenceArray
    variable protocolList
    variable protcolStatList
    variable protocolNameList
    variable flapOspfV2SummaryLsa
    variable flapOspfV2ExternalLsa
    variable flapOspfV2RouterLsa
    variable flapOspfV3ExternalLsa
    variable flapOspfV3RouterLsa
    variable flapOspfV3InterAreaPrefixLsa
    variable percentMaxRate
    variable trial;
    variable numTrials;
    variable testName;
    variable framesize;
    variable frameSizeList;
    variable status;

    
    set status $::TCL_OK

    # write the streams
   if {[ospfSuite::writeOspfV2V3Streams txRxArray txNumFrames]} {
       return $::TCL_ERROR
   }

   ospfSuite::metricSave $trial $framesize txTputPercent  $percentMaxRate
   ospfSuite::metricSave $trial $framesize txTputFps      [stream cget -framerate]

   after 5000
   if {[ospfSuite cget -enableOspfV2] == "true"} {
       # Start OSPF Server
       logMsg "Starting OSPF..."
       if [startOspfServer ospfPorts] {
           errorMsg "Error Starting OSPF!"
           return $::TCL_ERROR
       }
   }

   if {[ospfSuite cget -enableOspfV3] == "true"} {
       # Start OSPFV3 Server
       logMsg "Starting OSPFV3..."
       if [startOspfV3Server ospfPorts] {
           errorMsg "Error Starting OSPF!"
           return $::TCL_ERROR
       }
   }
   set advertiseTimeout    [expr [ospfSuite::getTotalLsas] * [ospfSuite cget -advertiseDelayPerRoute]]
   set recommendedDelayForTxAllFrames  [expr round (5*[ospfSuite::getTotalLsas]/[stream cget -framerate])]
   set delayForTxAllFrames             [ospfSuite cget -transmitDurationBetweenFlaps]

   if {$delayForTxAllFrames < $recommendedDelayForTxAllFrames} {
       logMsg "The configured transmit duration between flaps is less than recommended, resetting to recommended value."
       set delayForTxAllFrames $recommendedDelayForTxAllFrames
   }

   if {$advertiseTimeout < [ospfSuite cget -dutProcessingDelay]} {
       logMsg "Calculated Advertise Timeout is less than DUT Processing delay. It is set to [ospfSuite cget -dutProcessingDelay] seconds."
       set advertiseTimeout [ospfSuite cget -dutProcessingDelay]
   } 

   if {[ospfSuite cget -enableOspfV2] == "true"} {
       if [confirmFullSession ospfPorts $advertiseTimeout] {
           errorMsg "Error!!Neighbor(s) are not in full state. The advertiseDelayPerRoute is not long enough \
           or there is a network problem"
           ospfCleanUp ospfPorts   no
           if {[ospfSuite cget -enableOspfV3] == "true"} {
               ospfV3CleanUp ospfPorts no
           }
           return $::TCL_ERROR
       }
   }

   if {[ospfSuite cget -enableOspfV3] == "true"} {
       if [confirmOspfV3FullSession ospfPorts $advertiseTimeout] {
           errorMsg "Error!!OspfV3 Neighbor(s) are not in full state. The advertiseDelayPerRoute is not long enough \
           or there is a network problem"
           ospfV3CleanUp ospfPorts no
           if {[ospfSuite cget -enableOspfV2] == "true"} {
               ospfCleanUp ospfPorts   no
           }
           return $::TCL_ERROR
       }
   }

   logMsg "Pausing for [ospfSuite cget -dutProcessingDelay] seconds before starting transmitting ..."
   writeWaitForPause  "Waiting for DUT to settle down.." [ospfSuite cget -dutProcessingDelay]    
   #calculating duration.
   set numWithdraw [ospfSuite cget -numberOfFlaps]

   set statArrayList {firstTimeStamp lastTimeStamp}

   if {[prepareToTransmit txRxArray]} {
       errorMsg "Error in prepareToTransmit"
       set status $::TCL_ERROR
   }

   if {[startPacketGroups ospfPorts]} {
       errorMsg "Error starting packetGroupStats"
   }		

   if {[startTx txRxArray]} {
       errorMsg "***** Error in starting transmit."
       return -code error 
   }    

   createGroupIdArray groupIdArray $ospfPorts 
   set preferredPort       [list [lindex $ospfPorts 0]]
   set notPreferredPort    [list [lindex $ospfPorts 1]]

   set maxNumChanges [expr $numWithdraw* 2 ]
   set desiredRate   [stream cget -framerate]

   for {set count 0} {$count < $maxNumChanges } {incr count} {

       set enableFlap      [expr round (fmod ($count,2))]
       # Check the rate, when it reaches the desired rate, collect statistics.

       logMsg "Transmit ..."
       writeWaitForTransmit $delayForTxAllFrames 

       set watchPortList [list [expr $enableFlap==$::true?$preferredPort:$notPreferredPort]]
       set transmitTimeout [ospfSuite cget -transmitTimeout]
       if {$enableFlap == 0} {
           set desiredRate [expr ([stream cget -framerate]/double([ospfSuite::getTotalLsas])) * [ospfSuite::getTotalWithdrawnLsas]] 

           set stopPort   $preferredPort 
           logMsg "Performing Flap for Withdraw LSAs...."
       } else {
           set desiredRate [stream cget -framerate]
           set stopPort $notPreferredPort
           logMsg "Performing Flap for Advertised LSAs...."
       }
       #flap the preferred route by disabling the item
       if {[ospfSuite::performFlap $preferredPort $enableFlap write]} {
           errorMsg "***** Error in flapping."
           return -code error 
       }  

       if {[stopPacketGroups stopPort]} {
           errorMsg "Error starting packetGroupStats"
       }
       logMsg "Transmit ..."
       writeWaitForTransmit $delayForTxAllFrames

       logMsg "\nWaiting maximum $transmitTimeout seconds for throughput to achieve desired rate..."

       if {[statWatchUtils::watchRate $watchPortList [expr $desiredRate - 0.01*$desiredRate] $transmitTimeout]} {
           logMsg "\n***** ERROR:  Thoughput has not reached desired rate after a period of $transmitTimeout seconds."
           set status $::TCL_ERROR
           break
       }
       after 5000
       logMsg "Collecting packet Group Stats. It may take a few minutes."
       if [collectPacketGroupStats  ospfPorts groupIdArray $statArrayList stop verbose] {
           logMsg "Error collecting packetGroupStats"
       }

       set metricName          [expr $enableFlap==$::true?\"avgAdvertiseConvergenceTime\":\"avgWithdrawConvergenceTime\"]
       set avgConvergenceTime  [calculateConvergenceTime groupIdArray $ospfPorts statArrayList $totalFlapLsa $enableFlap]
       set averageConvergenceArray($trial,$framesize,$metricName,$count) $avgConvergenceTime
       logMsg "Avg Convergence time  = $avgConvergenceTime ns"

       if {[startPacketGroups ospfPorts]} {
           errorMsg "Error starting packetGroupStats"
       }
   }

   if [stopTx txRxArray] {
       logMsg "Error stopping Tx on one or more ports."
       set status 1
   }

   waitForResidualFrames [ospfSuite cget -waitResidual]                 

   stats::collectTxStats [getTxPorts txRxArray] txNumFrames txActualFrames totalTxNumFrames false false
   collectRxStats [getRxPorts txRxArray] rxNumFrames totalRxNumFrames
   debugMsg "rxNumFrames :[array get rxNumFrames]"


   set totalLoss           [calculatePercentLoss $totalTxNumFrames $totalRxNumFrames]
   set totalPacketLoss     [mpexpr ($totalTxNumFrames - $totalRxNumFrames)]
   set percentPacketLoss   [calculatePercentLoss $totalTxNumFrames $totalRxNumFrames]

   ospfSuite::metricSave $trial $framesize totalPacketLoss $percentPacketLoss
   ospfSuite::metricSave $trial $framesize totalTxPackets $totalTxNumFrames
   ospfSuite::metricSave $trial $framesize totalRxPackets $totalRxNumFrames

   set rxPort1  [lindex [getRxPorts txRxArray] 0]
   set rxPort2  [lindex [getRxPorts txRxArray] 1]

   ospfSuite::metricSave $trial $framesize rx1NumFrames $rxNumFrames([join $rxPort1 ,])
   ospfSuite::metricSave $trial $framesize rx2NumFrames $rxNumFrames([join $rxPort2 ,])
   ospfSuite::metricSave $trial $framesize noOfWithdrawals $numWithdraw
   ospfSuite::metricSave $trial $framesize noOfLSAs [ospfSuite::getTotalLsas]


   if {$status == $::TCL_ERROR} {
       ospfSuite::metricSave $trial $framesize avgAdvertiseConvergenceTime "N/A"
       ospfSuite::metricSave $trial $framesize avgWithdrawConvergenceTime  "N/A"
   } else {
       ospfSuite::metricSave $trial $framesize avgAdvertiseConvergenceTime \
           [calculateAvgConvergenceTimeOfAllFlaps $trial $framesize avgAdvertiseConvergenceTime] 
       ospfSuite::metricSave $trial $framesize avgWithdrawConvergenceTime  \
           [calculateAvgConvergenceTimeOfAllFlaps $trial $framesize avgWithdrawConvergenceTime]
   }

   #Withdraw the LSA before stopping the ospf servers
   ospfSuite config -flapOspfV2SummaryLsa          true
   ospfSuite config -flapOspfV2ExternalLsa         true
   ospfSuite config -flapOspfV2RouterLsa           true
   ospfSuite config -flapOspfV3ExternalLsa         true
   ospfSuite config -flapOspfV3RouterLsa           true
   ospfSuite config -flapOspfV3InterAreaPrefixLsa  true


   if {[ospfSuite::performFlap $ospfPorts 0 write]} {
       errorMsg "***** Error in flapping."
       return -code error 
   }

   #Set them back for the next trial
   ospfSuite config -flapOspfV2SummaryLsa          $flapOspfV2SummaryLsa
   ospfSuite config -flapOspfV2ExternalLsa         $flapOspfV2ExternalLsa
   ospfSuite config -flapOspfV2RouterLsa           $flapOspfV2RouterLsa
   ospfSuite config -flapOspfV3ExternalLsa         $flapOspfV3ExternalLsa
   ospfSuite config -flapOspfV3RouterLsa           $flapOspfV3RouterLsa
   ospfSuite config -flapOspfV3InterAreaPrefixLsa  $flapOspfV3InterAreaPrefixLsa

   writeWaitForPause  "Preparing for stopping.." [ospfSuite cget -dutProcessingDelay]    

   if {[ospfSuite cget -enableOspfV2] == "true"} {
       ospfCleanUp ospfPorts 
   }                                    

   if {[ospfSuite cget -enableOspfV3] == "true"} {
       ospfV3CleanUp ospfPorts 
   }

   set packetRate      [stream cget -framerate]
   set numberOfRoutes  [ospfSuite cget -numberOfRoutes]


    return $status;
}

#############################################################################
# ospfConvergence::TrialCleanUp()
#
# DESCRIPTION
# This procedure resets common code elements needed at the end of a trial.
#
# RETURNS:  
# status      TCL_OK     - on success
#             TCL_ERROR  - on failure
#
###
proc ospfConvergence::TrialCleanUp {} {
    variable status

    set status $::TCL_OK

    return $status
}

#############################################################################
# ospfConvergence::AlgorithmCleanup()
#
# DESCRIPTION
# This procedure removes any measurement stream options that are no longer
# in use.
#
# RETURNS:  
# status      TCL_OK     - on success
#             TCL_ERROR  - on failure
#
###
proc ospfConvergence::AlgorithmCleanUp {} {
    variable status

    set status $::TCL_OK
     
    return $status;
}
        
########################################################################################
# Procedure: ospfConvergence::calculateConvergenceTime
#
# Description: Helper method to calculate convergence time.
#
# Argument(s):
#			portList
#			StatArrayList
# Results :  avgConvergenceTime
#   
########################################################################################
proc ospfConvergence::calculateConvergenceTime { GroupIdArray portList StatArrayList totalLsa enableFlap} \
{
    upvar $StatArrayList	statArrayList
    upvar $GroupIdArray     groupIdArray

    foreach arrayItem $statArrayList {
        set temp $arrayItem
        upvar $temp $arrayItem
    }

    set preferredPort       [lindex $portList 0]
    set notPreferredPort    [lindex $portList 1]
    scan $preferredPort     "%d %d %d" prx_c prx_l prx_p
    scan $notPreferredPort  "%d %d %d" nprx_c nprx_l nprx_p

    set convergenceTimePerRoute  0.0
    set avgConvergenceTime       0.0

    foreach groupId $groupIdArray($prx_c,$prx_l,$prx_p) {
        if {$enableFlap == 0} {
            set convergenceTimePerRoute [mpexpr $convergenceTimePerRoute + \
                                        ($firstTimeStamp($nprx_c,$nprx_l,$nprx_p,$groupId) - \
                                        $lastTimeStamp($prx_c,$prx_l,$prx_p,$groupId))]
        } else {
            set convergenceTimePerRoute [mpexpr $convergenceTimePerRoute + \
                                        ($firstTimeStamp($prx_c,$prx_l,$prx_p,$groupId) - \
                                        $lastTimeStamp($nprx_c,$nprx_l,$nprx_p,$groupId))]
        }
    }
    
    if {$totalLsa != 0} {
        set avgConvergenceTime [mpexpr $convergenceTimePerRoute/ $totalLsa]
    }
    
    return $avgConvergenceTime     
    
}

########################################################################################
# Procedure:    ospfConvergence::calculateAvgConvergenceTimeOfAllFlaps
#
# Description:  Calculates the average convergence time of all flaps for a given 
#               framesize in a given trial.  Note that LSAs are not withdrawn on the 
#               final flap, therefore, the withdrawal has one less flap.
#
# Argument(s):  trial:
#               framesize:
#               type:   advertise or withdrawal
#
# Results:      overall average convergence time
#   
########################################################################################
proc ospfConvergence::calculateAvgConvergenceTimeOfAllFlaps {trial framesize type} \
{
    variable averageConvergenceArray

    set numberOfFlaps [ospfSuite cget -numberOfFlaps]
    switch $type {
        avgAdvertiseConvergenceTime {
            set minimum 1
            set maximum [expr ($numberOfFlaps - 1) * 2 + 1] 
        }
        avgWithdrawConvergenceTime {
            set minimum 0
            set maximum [expr ($numberOfFlaps - 1) * 2] 
        }
        default {
            set minimum 0
            set maximum 0
        }
    }

    set avgConvergenceTime  [expr double(0)]
    set counter 0

    for {set i $minimum} {$i <= $maximum } {incr i 2} {


        if {[info exists averageConvergenceArray($trial,$framesize,$type,$i)]} {
            set value $averageConvergenceArray($trial,$framesize,$type,$i)
            if {$value >= 0} {
                set avgConvergenceTime \
                    [mpincr avgConvergenceTime $value]
                incr counter
            }
        }

    }

    set counter [expr $counter > 0?$counter:1]
    set avgConvergenceTime \
        [expr $avgConvergenceTime / $counter]

    return $avgConvergenceTime     
    
}
 
########################################################################################
# Procedure:    ospfConvergence::createGroupIdArray
#
# Description:  Creates GroupId array for packetGroup stats.
#
# Argument(s):
#
# Results :     TCL_OK or TCL_ERROR
#   
########################################################################################
proc ospfConvergence::createGroupIdArray {GroupIdArray ospfPorts} \
{   
    upvar $GroupIdArray groupIdArray
    set groupId 1

     foreach item $ospfPorts {
        scan $item "%d %d %d" c l p
        set groupIdArray($c,$l,$p) {}
     }

    #Please don't change the order.
    if {[ospfSuite cget -enableOspfV2] == "true"} {
        
        if {[ospfSuite cget -enableOspfV2SummaryLsa] == "true"} {
            if {[ospfSuite cget -flapOspfV2SummaryLsa] == "true" } {
                foreach item $ospfPorts {
                    scan $item "%d %d %d" c l p
                    for {set id $groupId} {$id < [expr $groupId + [ospfSuite cget -numberOfRoutes]]} {incr id} {
                        lappend groupIdArray($c,$l,$p) $id
                    }
                }
                set groupId $id
            } else {
                incr groupId [ospfSuite cget -numOspfV2RouterLsa]
            }

        }

        if {[ospfSuite cget -enableOspfV2RouterLsa] == "true"} {
            if {[ospfSuite cget -flapOspfV2RouterLsa] == "true" } {
                foreach item $ospfPorts {
                    scan $item "%d %d %d" c l p
                    for {set id $groupId} {$id < [expr $groupId + [ospfSuite cget -numOspfV2RouterLsa]]} {incr id} {
                        lappend groupIdArray($c,$l,$p) $id
                    }
                }
                set groupId $id 
            } else {
                incr groupId [ospfSuite cget -numOspfV2RouterLsa]
            }
        }

        if {[ospfSuite cget -enableOspfV2ExternalLsa] == "true"} {
            if {[ospfSuite cget -flapOspfV2ExternalLsa] == "true" } {
                 foreach item $ospfPorts {
                    scan $item "%d %d %d" c l p
                    for {set id $groupId} {$id < [expr $groupId + [ospfSuite cget -numOspfV2ExternalLsa]]} {incr id} {
                        lappend groupIdArray($c,$l,$p) $id
                    }
                }
                set groupId $id 
            } else {
                incr groupId [ospfSuite cget -numOspfV2ExternalLsa]
            }
        }

    }
        
    if {[ospfSuite cget -enableOspfV3] == "true"} {
        if {[ospfSuite cget -enableOspfV3InterAreaPrefixLsa] == "true"} {
            if {[ospfSuite cget -flapOspfV3InterAreaPrefixLsa] == "true" } {
                foreach item $ospfPorts {
                    scan $item "%d %d %d" c l p
                    for {set id $groupId} {$id < [expr $groupId + [ospfSuite cget -numOspfV3InterAreaPrefixLsa]]} {incr id} {
                        lappend groupIdArray($c,$l,$p) $id
                    }
                }
                set groupId $id
             } else {
                incr groupId [ospfSuite cget -numOspfV3InterAreaPrefixLsa]
             }  
        }
        if {[ospfSuite cget -enableOspfV3RouterLsa] == "true"} {
            if {[ospfSuite cget -flapOspfV3RouterLsa] == "true" } {
                foreach item $ospfPorts {
                    scan $item "%d %d %d" c l p
                    for {set id $groupId} {$id < [expr $groupId + [ospfSuite cget -numOspfV3RouterLsa]]} {incr id} {
                        lappend groupIdArray($c,$l,$p) $id
                    }
                }
                set groupId $id
             } else {
                incr groupId [ospfSuite cget -numOspfV3RouterLsa]
             }   
        }

        if {[ospfSuite cget -enableOspfV3ExternalLsa] == "true"} {
            if {[ospfSuite cget -flapOspfV3ExternalLsa] == "true" } {
                foreach item $ospfPorts {
                    scan $item "%d %d %d" c l p
                    for {set id $groupId} {$id < [expr $groupId + [ospfSuite cget -numOspfV3ExternalLsa]]} {incr id} {
                        lappend groupIdArray($c,$l,$p) $id
                    }
                }
            } 
        }
    }
}

###########################################################################
# Procedure: ConfigValidate 
#
# Description: It's the validation procedure called before the algorithm  
#              actually starts running. 
#              It's included in the test namespace. 
#              In this procedure are called all the other validation procedures.
#
# Argument(s): no arguments
#     	    
# # Return values:
#    TCL_OK -  There were no errors or the errors are fixed
#    TCL_ERROR -  Errors were found and the test should not continue
#        
###########################################################################
proc ospfConvergence::ConfigValidate {} \
{
    variable txRxArray
    variable ospfPorts
    set status $::TCL_OK
    set testCmd ospfSuite

        set type        [ospfSuite cget -mapType]
        global          [format "%sArray" $type] 
        copyPortList    [format "%sArray" $type] txRxArray

    #repeated frame sizes are eliminated from the list if there are any
    configValidation::RemoveDuplicatesFromFramesizeList ospfSuite
    
    #validate framesizeList
    if { ![configValidation::ValidateFrameSizeList  ospfSuite]} {
        return $::TCL_ERROR
    }

    if {[validateFramesizeList [ospfSuite cget -framesizeList]]} {
        logMsg "** ERROR: Some frame sizes are incompatible with selected protocols"
        return -code error 
    }

    if [validateUnidirectionalMap txRxArray] {
        return $::TCL_ERROR 
    }

    if [checkConvergenceMap txRxArray] {
        errorMsg "Invalid Map for convergence test. Should be one Tx port and Two Rx ports"
        return $::TCL_ERROR 
    }    
    set ospfPorts    [getRxPorts txRxArray]

    if {[validateFeatureSet $ospfPorts]} {
        return $::TCL_ERROR 
    }

    # check the frame size compatibility with the ospfV3
    if {[ospfSuite cget -enableOspfV3] == "true"} {
        set fsList [ospfSuite cget -framesizeList]
        foreach fs $fsList {
            if {$fs < 74} {
                errorMsg "Cannot run ospfV3 with the frame size value less than 74. Please adjust the frame size list."
                return $::TCL_ERROR
            }
        }
    }

    #common validatation to all the tests
    if {![configValidation::ValidateCommon ospfSuite]} {
        return $::TCL_ERROR
    }

    return $status

}

########################################################################################
# Procedure:    ospfConvergence::validateFeatureSet
#
# Description:  Verifies that the given ports possess the needed features.
#
# Argument(s):  portList
#
# Results :     TCL_OK or TCL_ERROR
#   
########################################################################################
proc ospfConvergence::validateFeatureSet {portList {verbose true}} \
{
    set status $::TCL_OK
    foreach portId $portList {
        scan $portId "%d %d %d" c l p

        if {[ospfSuite cget -enableOspfV3] == "true"} {
            if {![port isValidFeature $c $l $p portFeatureProtocolOSPFv3]} {
                errorMsg [format "Port %s: %s is not valid for interface: %s" \
                         [getPortId $c $l $p] \
                         "OSPFv3" \
                         [port cget -typeName]]
                set status $::TCL_ERROR
            }
        }
        if {![port isValidFeature $c $l $p portFeatureRxWidePacketGroups]} {
            errorMsg [format "Port %s: %s is not valid for interface: %s" \
                     [getPortId $c $l $p] \
                     "Wide Packet Groups" \
                     [port cget -typeName]]
            set status $::TCL_ERROR
        }
    }
    if {[ospfSuite cget -enableOspfV3] == "true"} {
        if {[catch {ospfV3NetworkRange cget -this}]} {
            errorMsg "OSPFv3 Network Range is not available in current version of IxOs."
            set status $::TCL_ERROR
        }
    }

    return $status
}

#######################################################################
# ospfConvergence::WriteResultsCSV()
#
# DESCRIPTION:
# This procedure creates the results.csv file used for PDF Report generation
# CSV File Format
#
# ARGS:
# none
# 
# RETURNS:
# status      TCL_OK     - on success
#             TCL_ERROR  - on failure
# 
###
proc ospfConvergence::WriteResultsCSV {} {  
   variable resultsDirectory
   variable trialsPassed;
   variable resultArray
   global testConf passFail
   global aggregateArray loggerParms

   set dirName $resultsDirectory

   array set resultArray [array get ospfSuite::resultArray]

   if { [ospfSuite cget -framesizeList] == {} } {
       # no new result entry to write
       return
   }

   #################################
   #
   #  Create Result CSV
   #
   #################################

      
   set mapArray    [format "%sArray"   [ospfSuite cget -mapType]]
   global $mapArray

   if {[catch {set csvFid [open $dirName/results.csv w]}]} {
      logMsg "***** WARNING:  Cannot open csv file."
      return
   }

   puts $csvFid "Trial,Frame Size,Tx Port,Rx Port,Tx Count (frames),Rx Count (frames),Number of LSAs,Number of withdrawals,Tx Tput (fps),Tx Tput (%),Avg Advertise Convergence Time (ns),Avg Withdraw Convergence Time (ns),Total Frame Loss, Total Frame Loss (%)"
   for {set trial 1} {$trial <= [ospfSuite cget -numtrials] } {incr trial} {
      foreach fs [lsort -dictionary [ospfSuite cget -framesizeList]] {
         
         set txPort   [lindex [getTxPorts $mapArray] 0]
         set rxPort1  [lindex [getRxPorts $mapArray] 0]
         set rxPort2  [lindex [getRxPorts $mapArray] 1]
         set txCount $resultArray($trial,$fs,totalTxPackets)
         set rxCount1 $resultArray($trial,$fs,rx1NumFrames)
         set rxCount2 $resultArray($trial,$fs,rx2NumFrames)
         set noOfLSAs $resultArray($trial,$fs,noOfLSAs)
         set noOfWithdrawals $resultArray($trial,$fs,noOfWithdrawals)
         set txTputFPS $resultArray($trial,$fs,txTputFps)
         set txTputPct $resultArray($trial,$fs,txTputPercent)
         set avgAdvConvTime $resultArray($trial,$fs,avgAdvertiseConvergenceTime)
         set avgWithdrawConvTime $resultArray($trial,$fs,avgWithdrawConvergenceTime)
         set totalFrameLoss [mpexpr $txCount - ($rxCount1 + $rxCount2)]
         set totalFrameLossPct $resultArray($trial,$fs,totalPacketLoss)

         puts $csvFid "$trial,$fs,[join $txPort .],[join $rxPort1 .],$txCount,$rxCount1,$noOfLSAs,$noOfWithdrawals,$txTputFPS,$txTputPct,$avgAdvConvTime,$avgWithdrawConvTime,$totalFrameLoss,$totalFrameLossPct"
         puts $csvFid "$trial,$fs,[join $txPort .],[join $rxPort2 .],-,$rxCount2,-,-,-,-,-,-,-,-"
      }
   }

   closeMyFile $csvFid

}
########################################################################
# ospfConvergence::WriteAggregateResultsCSV()
#
# DESCRIPTION:
# This procedure creates the AggregateResults.csv used for PDF Report generation
# CSV File Format
#
# ARGS:
# none
#
# RETURNS:
# status      TCL_OK     - on success
#             TCL_ERROR  - on failure
#
###
proc ospfConvergence::WriteAggregateResultsCSV {} {
   
   #################################
   #
   #  Create Aggregate Result CSV
   #
   #################################

}

################################################################################
#
# ospfConvergence::PassFailCriteriaEvaluateConvergence()
#
# DESCRIPTION:
# This procedure calculates the number of trials that have executed successfully
# based upon user-specified Pass/Fail criteria.  
#
# The criteria which must be met is based upon an acceptable value of
# convergence time.
# Advertise Convergence Time is the maximum advertise convergence time value 
# across any frame sizes for a given trial.
# Withdraw Convergence Time is the maximum withdraw convergence time value 
# across any frame sizes for a given trial.
#
# MODIFIES
# trialsPassed      - namespace variable indicating number of successful trials.
#
# RETURNS
# none
#
###
proc ospfConvergence::PassFailCriteriaEvaluate {} {
    variable resultsDirectory
    variable trialsPassed
    variable resultArray
    global one2manyArray
    global testConf

    logMsg "***************************************"
    logMsg "*** PASS Criteria Evaluation\n"

    if {[info exists testConf(passFailEnable)] == 0} {
	# maintain backwards compatiblity with scripts without pass/fail
	set trialsPassed "N/A"
	logMsg "*** # Of Trials Passed: $trialsPassed"
	logMsg "***************************************"
	return
    }

    if {!$testConf(passFailEnable)} {
	# Pass/Fail Criteria disabled implies N/A
	set trialsPassed "N/A"
	logMsg "*** # Of Trials Passed: $trialsPassed"
	logMsg "***************************************"
	return
    } 

    array set resultArray [array get ospfSuite::resultArray]
    set trialsPassed 0
        
    for {set trial 1} {$trial <= [ospfSuite cget -numtrials] } {incr trial} {

	logMsg "*** Trial #$trial"

	set avgAdvertiseConvList {}
        set avgWithdrawConvList {}

	foreach fs [lsort -dictionary [ospfSuite cget -framesizeList]] {
	    # convert values to seconds for criteria evaluation.
	    set avgAdvertiseConvergenceTime [mpexpr $resultArray($trial,$fs,avgAdvertiseConvergenceTime) / 1e9];
	    lappend avgAdvertiseConvList $avgAdvertiseConvergenceTime
	    set avgWithdrawConvergenceTime [mpexpr $resultArray($trial,$fs,avgWithdrawConvergenceTime) / 1e9];
            lappend avgWithdrawConvList $avgWithdrawConvergenceTime;
        } ;# loop over frame size

        if {[lsearch $avgAdvertiseConvList "N/A"] >=0 } {
            set maxAdvertiseConv "N/A"
        } else {
            # Maximum Advertise Convergence Time is the maximum advertise convergence time value
            # across any frame sizes for a given trial.	
            set maxAdvertiseConv [passfail::ListMax avgAdvertiseConvList]
        }

        if {[lsearch $avgWithdrawConvList "N/A"] >=0 } {
            set maxWithdrawConv "N/A"
        } else {
            # Maximum Withdraw Convergence Time is the maximum withdraw convergence time value
            # across any frame sizes for a given trial.	
            set maxWithdrawConv [passfail::ListMax avgWithdrawConvList]
        }

	set result [passfail::PassFailCriteriaConvergenceEvaluate $maxAdvertiseConv $maxWithdrawConv]

	if { $result == "PASS" } {
	    incr trialsPassed
	}
	logMsg "*** $result\n"

    } ;# loop over trials

    logMsg "*** # Of Trials Passed: $trialsPassed"
    logMsg "***************************************"
    
}

#############################################################################
# ospfConvergence::MetricsPostProcess()
#
# DESCRIPTION:
# This procedure walks moves data from XML file (created by results API) to
# the resultArray which can be used by all interested methods such as 
# Pass/Fail, CSV, etc.  This method will also calculate second order metrics
# like averages and maximums if not calculated within the algorithm body itself.
# All metrics should be stored in the resultArray so there is consistent usage
# of metrics by all other methods that follow. 
#
# <PHASE_2_SHOULD_GENERATE_IMPLEMENTATION> 
#
# ARGS:
# none
#
# RETURNS:
# status      TCL_OK     - on success
#             TCL_ERROR  - on failure
#
###
proc ospfConvergence::MetricsPostProcess {} {
    variable status

    set status $::TCL_OK

    return $status

    }

########################################################################################
# Procedure:    ospfConvergence::advertiseDelayPerRouteCmd
#
# Description:  Widget command for Validate MTU widget
#
# Argument(s):  None
#
# Returns:      None
########################################################################################
proc ospfConvergence::advertiseDelayPerRouteCmd {parent propName args} {

    global advertiseDelayPerRoute
    global advertiseDelay

    set numberOfRoutes [getTotalNumberLSA]
    set advertiseDelay $advertiseDelayPerRoute
        if { ([string length $advertiseDelay] > 0) && \
              ([string length $numberOfRoutes] > 0) } {

             if { [stringIsDouble $advertiseDelay] && [stringIsInteger $numberOfRoutes] } {

                 set totalDelay [mpexpr round (double ($advertiseDelay) * $numberOfRoutes)]
                 set totalDelay [expr $totalDelay > 0?$totalDelay:1]

                 ospfSuite config -totalDelay $totalDelay

                 set attributeList {
                         totalDelay
                 }

                 renderEngine::WidgetListStateSet $attributeList enabled

                 set entry [$parent.totalDelay subwidget entry];
                 $entry delete 0 end;
                 $entry insert end $totalDelay;

                 renderEngine::WidgetListStateSet $attributeList disabled
             }
         }
}

########################################################################################
# Procedure:    ospfConvergence::totalDelayCmd
#
# Description:  Widget command for Validate MTU widget
#
# Argument(s):  None
#
# Returns:      None
########################################################################################
proc ospfConvergence::totalDelayCmd {parent propName args} {

    set attributeList {
        totalDelay
    }

    renderEngine::WidgetListStateSet $attributeList enabled

    set totalDelay [ospfSuite cget -totalDelay]
    set entry [$parent.totalDelay subwidget entry];
    $entry delete 0 end;
    $entry insert end $totalDelay;

    renderEngine::WidgetListStateSet $attributeList disabled

}

########################################################################################
# Procedure:    ospfConvergence::enableValidateMtuCmd
#
# Description:  Widget command for Validate MTU widget
#
# Argument(s):  None
#
# Returns:      None
########################################################################################
proc ospfConvergence::enableValidateMtuCmd {parent propName args} {
    global enableValidateMtu
    set state disabled;

    if {$enableValidateMtu} {

    set state enabled;
    set attributeList {
        interfaceMTUSize
    }
    renderEngine::WidgetListStateSet $attributeList $state;

    } else {
    set attributeList {
        interfaceMTUSize
    }
    renderEngine::WidgetListStateSet $attributeList $state;
    }

}

########################################################################################
# Procedure:    ospfConvergence::enableOspfVersion
#
# Description:  Enable/Disable Ospf Version
#
# Argument(s):  version: V2 or V3
#               enable:  true or false
#
# Returns:      None
########################################################################################
proc ospfConvergence::enableOspfVersion {version} {
    global enableOspfV$version 

     if {$version == 2} {
         set lsaList {"SummaryLsa" "ExternalLsa" "RouterLsa"}
     } else {
         set lsaList {"InterAreaPrefixLsa" "ExternalLsa" "RouterLsa"}
     }
     foreach lsaType $lsaList {
        global enableOspfV$version$lsaType

        if {[catch {set enabled [set enableOspfV$version$lsaType]}]} {
            continue
        }
        if {$enabled == "true"} {
            set enableOspfV$version true
            return
        } else {
            set enableOspfV$version false
            
        }
        
     }
     ospfSuite config -enableOspfV$version [set enableOspfV$version]
}

########################################################################################
# Procedure:    ospfConvergence::enableOspfLsaCmd
#
# Description:  Enable/Disable LSA Advertisement.
#
# Argument(s):  frame:      Parent frame
#               version:    V2 or V3
#               type:       "Summary", "Router", "External"
#
# Returns:      None
########################################################################################
proc ospfConvergence::enableOspfLsaCmd {parent propName args} \
{
    global advertiseDelay
    global $propName
    
    scan $propName "enableOspfV%d%s" version type

    set state disabled;
    if {[set $propName] == "true"} {

        set state enabled;
        lappend attributeList numOspfV$version$type
        lappend attributeList flapOspfV$version$type
        renderEngine::WidgetListStateSet $attributeList $state;

        } else {
        lappend attributeList numOspfV$version$type
        lappend attributeList flapOspfV$version$type
        renderEngine::WidgetListStateSet $attributeList $state;
    }
    if {![info exist advertiseDelay]} {
        set advertiseDelay [ospfSuite cget -advertiseDelayPerRoute]
    }
    set numberOfRoutes [getTotalNumberLSA]

    if { ([string length $advertiseDelay] > 0) && \
              ([string length $numberOfRoutes] > 0) } {

        if { [stringIsDouble $advertiseDelay] && [stringIsInteger $numberOfRoutes] } {

           set totalDelay [mpexpr round (double ($advertiseDelay) * $numberOfRoutes)]
           set totalDelay [expr $totalDelay > 0?$totalDelay:1]

           ospfSuite config -totalDelay $totalDelay 

           set attributeList {
                totalDelay
           }

           renderEngine::WidgetListStateSet $attributeList enabled

           regsub "trafficPatternFrame.border.frame" $parent "delayFrame" delayFrameParent
		   global delayFrameInvisibleFrameName
           set entry [$delayFrameInvisibleFrameName.totalDelay subwidget entry];
           $entry delete 0 end;
           $entry insert end $totalDelay;

           renderEngine::WidgetListStateSet $attributeList disabled
        }
    }

    
    global testConf
    set testConf(protocolName) "ip/ipV6"

    enableOspfVersion $version

}

###############################################################################
# Procedure:    ospfConvergence::getTotalNumberLSA
#
# Description:  Returns the total number of LSAs for all versions and types.
#
# Arguments:    None
#
# Returns:      # of LSAs
###############################################################################
proc ospfConvergence::getTotalNumberLSA {} \
{
    set totalLsa 0


    foreach version {2 3} {
        if {$version ==2} {
            set lsaList {"SummaryLsa" "ExternalLsa" "RouterLsa"}
        } else {
            set lsaList {"InterAreaPrefix" "ExternalLsa" "RouterLsa"}
        }
        foreach lsaType $lsaList {
            global enableOspfV$version$lsaType
            global flapOspfV$version$lsaType
            global numOspfV$version$lsaType

           
        if {[catch {set enabled [set enableOspfV$version$lsaType]}]} {
            continue
        }
        if {$enabled == "true"} {
           if {[set flapOspfV$version$lsaType ]== "true"} {
                    incr totalLsa [set numOspfV$version$lsaType]
           }
        }
        }
    }
        
    return $totalLsa
}
########################################################################################
# Procedure:    ospfConvergence::numOspfLsaCmd
#
# Description:  Enable/Disable LSA Withdrawal.
#
# Argument(s):  version:    V2 or V3
#               type:       "Summary", "Router", "External"
#               value:      From GUI
#
# Returns:      None
########################################################################################
proc ospfConvergence::numOspfLsaCmd {parent propName args} \
{
    global advertiseDelay
    scan $propName "numOspfV%d%s" version type

    if {![info exist advertiseDelay]} {
         set advertiseDelay [ospfSuite cget -advertiseDelayPerRoute]
    }
    set numberOfRoutes [getTotalNumberLSA]

    if { ([string length $advertiseDelay] > 0) && \
              ([string length $numberOfRoutes] > 0) } {

       if { [stringIsDouble $advertiseDelay] && [stringIsInteger $numberOfRoutes] } {

                 set totalDelay [mpexpr round (double ($advertiseDelay) * $numberOfRoutes)]
                 set totalDelay [expr $totalDelay > 0?$totalDelay:1]

                 ospfSuite config -totalDelay $totalDelay 

                 set attributeList {
                          totalDelay
                 }

                 renderEngine::WidgetListStateSet $attributeList enabled
                 regsub "trafficPatternFrame.border.frame" $parent "delayFrame" delayFrameParent

		 global delayFrameInvisibleFrameName
                 set entry [$delayFrameInvisibleFrameName.totalDelay subwidget entry];
                 $entry delete 0 end;
                 $entry insert end $totalDelay;

                 renderEngine::WidgetListStateSet $attributeList disabled
        }
    }
}

########################################################################################
# Procedure:    ospfConvergence::withdrawOspfLsaCmd
#
# Description:  Enable/Disable LSA Withdrawal.
#
# Argument(s):  version:    V2 or V3
#               type:       "Summary", "Router", "External"
#
# Returns:      None
########################################################################################
proc ospfConvergence::withdrawOspfLsaCmd {parent propName args} \
{
    global advertiseDelay
    if {![info exist advertiseDelay]} {
         set advertiseDelay [ospfSuite cget -advertiseDelayPerRoute]
     }
     set numberOfRoutes [getTotalNumberLSA]
    if { ([string length $advertiseDelay] > 0) && \
                  ([string length $numberOfRoutes] > 0) } {

                 if { [stringIsDouble $advertiseDelay] && [stringIsInteger $numberOfRoutes] } {

                     set totalDelay [mpexpr round (double ($advertiseDelay) * $numberOfRoutes)]

                     set totalDelay [expr $totalDelay > 0?$totalDelay:1]
                     ospfSuite config -totalDelay $totalDelay 

                     set attributeList {
                              totalDelay
                      }

                      renderEngine::WidgetListStateSet $attributeList enabled

                      regsub "trafficPatternFrame.border.frame" $parent "delayFrame" delayFrameParent

		     global delayFrameInvisibleFrameName
                     set entry [$delayFrameInvisibleFrameName.totalDelay subwidget entry];
                     $entry delete 0 end;
                     $entry insert end $totalDelay;

                     renderEngine::WidgetListStateSet $attributeList disabled
                 }
             }

}

################################################################################
#
# ospfConvergence::PassFailEnable(args)
#
# DESCRIPTION:
# This procedure enables or disables Throughput Pass/Fail Critiera related widgets.
# This either allows the user to click on and adjust widgets or prevents this.
#
# ARGUMENTS
# args       - variable arguments
#
# RETURNS
# none
#
###
proc ospfConvergence::PassFailEnable {args} {
    global passFailEnable;

    set state disabled;

    if {$passFailEnable} {

	set state enabled;
	set attributeList {
	    advertiseThresholdValue
	    withdrawThresholdValue
	}
	renderEngine::WidgetListStateSet $attributeList $state;

    } else {
	set attributeList {
	    advertiseThresholdValue
	    withdrawThresholdValue
	}
	renderEngine::WidgetListStateSet $attributeList $state;
    }
}

########################################################################################
# Procedure:    ospfConvergence::OnInterfaceNetworkInit
#
# Description:  Enable/Disable LSA Withdrawal.
#
# Argument(s):  version:    V2 or V3
#               type:       "Summary", "Router", "External"
#
# Returns:      None
########################################################################################
proc ospfConvergence::OnInterfaceNetworkInit {args} {
        global networkType;

        switch [ospfSuite cget -interfaceNetworkType] {
             "ospfBroadcast" {
                 set networkType "Broadcast";
             }
             "ospfPointToPoint" {
                 set networkType "Point To Point"
             }
             default {
                 set networkType "Broadcast"
             }
        }
     }
########################################################################################
# Procedure:    ospfConvergence::OnInterfaceNetworkChange
#
# Description:  Enable/Disable LSA Withdrawal.
#
# Argument(s):  version:    V2 or V3
#               type:       "Summary", "Router", "External"
#
# Returns:      None
########################################################################################

     proc ospfConvergence::OnInterfaceNetworkChange {args} {
        global networkType interfaceNetworkType;
        switch $networkType {
             "Broadcast" {
                 ospfSuite config -interfaceNetworkType "ospfBroadcast";
             }
             "Point To Point" {
                 ospfSuite config -interfaceNetworkType "ospfPointToPoint";
             }
             default {
                 ospfSuite config -interfaceNetworkType "ospfBroadcast"
             }
        }

        set interfaceNetworkType [ospfSuite cget -interfaceNetworkType]
     }


