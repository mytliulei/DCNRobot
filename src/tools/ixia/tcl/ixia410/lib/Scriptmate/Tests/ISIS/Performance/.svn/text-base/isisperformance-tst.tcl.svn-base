############################################################################################
#
#   Copyright © 1997 - 2004 by IXIA.
#   All Rights Reserved.
#
# Description: This file contains the script for running ISIS performance test
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
 namespace eval isisSuite {}

#####################################################################
# isisPerformance::xmdDef
# 
# DESCRIPTION:
# This variable contains the XML content used by PDF Report generation.
#  
###
set isisPerformance::xmdDef  {
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
          <Source scope="results.csv" entity_name="isisPerformance" format_id=""/>
          <Source scope="info.csv" entity_name="isisPerformance_Info" format_id=""/>
          <Source scope="AggregateResults.csv" entity_name="isisPerformance_Aggregate" format_id=""/>
          <Source scope="Iteration.csv" entity_name="isisPerformance_Iteration" format_id=""/>
       </Sources>
    </XMD>
}

#####################################################################
# isisPerformance::statList
# 
# DESCRIPTION:
# This table contains a list of collected metrics to be displayed in
# the Real Time Graphs and written to RealTime.csv file.
#  
###
set map [map cget -type]
global ${map}Array

set isisPerformance::statList \
    [list [list framesSent     [getTxPorts ${map}Array] "Tx Frames per second" "Tx Frames" 1e0]\
	  [list framesReceived [getRxPorts ${map}Array] "Rx Frames per second" "Rx Frames" 1e0]\
	  [list bitsSent       [getTxPorts ${map}Array] "Tx Kbps"              "Tx Kb"     1e3]\
	  [list bitsReceived   [getRxPorts ${map}Array] "Rx Kbps"              "Rx Kb"     1e3]\
	];


#####################################################################
# isisPerformance::iterationFileColumnHeader
# 
# DESCRIPTION:
# This table contains a list of column headers at the top of the
# iteration.csv file.
#  
###
set isisPerformance::iterationFileColumnHeader { 
    "Trial"
    "Frame Size"
    "Iteration"
    "Tx Port"
    "Rx Port"
    "Rate (FPS)"
    "Rate (%)"
    "Tx Count"
    "Rx Count"
    "Frame Loss"
    "Frame Loss (%)"
}

########################################################################################
# Procedure: registerResultVars
#
# Description: This command registers all the local variables that are used in the
# display of the results with the Results Options Database.  This procedure must exist
# for each test.
#
########################################################################################
proc isisPerformance::registerResultVars {} {  

    results config -maxValueLength 15

    # configuration information stored for results
    if [results registerTestVars numTrials      numTrials     [isisSuite cget -numtrials]      test] { return $::TCL_ERROR }

    # results obtained after each iteration
    if [results registerTestVars throughput     thruputRate    0   port TX ] { return $::TCL_ERROR }
    if [results registerTestVars percentTput    percentTput    0   port TX ] { return $::TCL_ERROR }
    if [results registerTestVars avgLatency     avgLatency     0   port RX ] { return $::TCL_ERROR }
    if [results registerTestVars minLatency     minLatency     0   port RX ] { return $::TCL_ERROR }
    if [results registerTestVars maxLatency     maxLatency     0   port RX ] { return $::TCL_ERROR }
    if [results registerTestVars dataError      integrityError 0   port RX ] { return $::TCL_ERROR }
    if [results registerTestVars totalSeqError  sequenceError  0   port RX ] { return $::TCL_ERROR }

    return $::TCL_OK
}

#####################################################################
# isisPerformance::attributes
# 
# DESCRIPTION:
# This attributes table contains a list of attributes used by the
# test algorithm or other backend test engine functions.  This
# table is used to initialize these attributes for later use.
#  
###
set isisPerformance::attributes { 

    {
	{ NAME              testName }
	{ BACKEND_TYPE      string }
	{ DEFAULT_VALUE     "ISIS Performance" }
	{ VARIABLE_CLASS    testCmd }
    }

    { 
        { NAME              duration }
        { BACKEND_TYPE      integer }
        { DEFAULT_VALUE     20 }
        { MIN               1 }
        { MAX               NULL }
        { LABEL             Duration }
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
        { NAME              routeDelay }
        { BACKEND_TYPE      double }
        { DEFAULT_VALUE     0.0007 } 
        { MIN               0 }
        { MAX               256 }
        { LABEL             "Advertise delay per route: " }
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
        { NAME              tolerance }
        { BACKEND_TYPE      double }
        { DEFAULT_VALUE     0 }
        { MIN               0 }
        { MAX               100 }
        { LABEL             "Loss Tolerance (%): " }
        { VARIABLE_CLASS    testCmd }
    }

    {
        { NAME              linearBinarySearch }
        { BACKEND_TYPE      boolean }
        { DEFAULT_VALUE     true }
        { VALID_VALUES      {true false} }
        { VALUE_LABELS      {"Linear" "Per Port"} }
        { VARIABLE_CLASS    testCmd }
    }

    { 
        { NAME              minimumFPS }
        { BACKEND_TYPE      integer }
        { DEFAULT_VALUE     10	}
        { MIN               1 } 
        { MAX               2000000000 }
        { VARIABLE_CLASS    testCmd }
    }

    {
        { NAME              atmHeaderWidget }	    
        { BACKEND_TYPE      null }
        { VARIABLE_CLASS    null }
    }

    {
        { NAME              enablePassFail }	    
        { BACKEND_TYPE      integer }
        { DEFAULT_VALUE     0 }
        { VALID_VALUES      {1 0} }
        { LABEL             Enable }
        { VARIABLE          passFailEnable }
        { VARIABLE_CLASS    testConf }
        { ON_CHANGE         isisPerformance::PassFailEnable }
    }
       
    {
        { NAME              thresholdMode }
        { BACKEND_TYPE      string }
        { DEFAULT_VALUE     line }
        { VALID_VALUES      {line data} }
        { VALUE_LABELS      {"% Line Rate >=" "  Data Rate >="} }
        { VARIABLE          passFailMode }
        { VARIABLE_CLASS    testConf }
        { ON_CHANGE         isisPerformance::ThroughputThresholdToggle }
    }

    {
        { NAME              lineThresholdValue }
        { BACKEND_TYPE      double }
        { DEFAULT_VALUE     100 }
        { MIN               0.0001 }
        { MAX               100 }
        { VARIABLE          passFailLineValue }
        { VARIABLE_CLASS    testConf }
        { DESCRIPTION {
            "Numerical limit compared against measured values for pass criteria"
        } }
    }

    {
        { NAME              lineThresholdMode }
        { BACKEND_TYPE      string }
        { DEFAULT_VALUE     average }
        { VALID_VALUES      {average} }
        { VARIABLE          passFailLineType }
        { VARIABLE_CLASS    testConf }
        { DESCRIPTION {
            "average or maximum measurement for pass criteria"
        } }
    }

    {
        { NAME              dataThresholdValue }
        { BACKEND_TYPE      double }
        { DEFAULT_VALUE     100 }
        { MIN               0.0001 }
        { MAX               NULL }
        { VARIABLE          passFailDataValue }
        { VARIABLE_CLASS    testConf }
    }

    {
        { NAME              dataThresholdScale }
        { BACKEND_TYPE      string }
        { DEFAULT_VALUE     Mbps }
        { VALID_VALUES      {Kbps Mbps Gbps FPS} }
        { VARIABLE          passFailDataUnit }
        { VARIABLE_CLASS    testConf }
    }

    {
        { NAME              dataThresholdMode }
        { BACKEND_TYPE      string }
        { DEFAULT_VALUE     average }
        { VALID_VALUES      {average} }
        { VARIABLE          passFailDataType }
        { VARIABLE_CLASS    testConf }
    }

    {
        { NAME              latencyLabel }
        { BACKEND_TYPE      string }
        { LABEL             "Latency <=" }
        { VARIABLE          latencyThreshold }
        { VARIABLE_CLASS    null }
    }

    {
        { NAME              latencyValue }
        { BACKEND_TYPE      double }
        { DEFAULT_VALUE     1.0 }
        { MIN               0.0001 }
        { MAX               100000000 }
        { VARIABLE          passFailLatencyValue }
        { VARIABLE_CLASS    testConf }
    }

    {
        { NAME              latencyThresholdScale }
        { BACKEND_TYPE      string }
        { DEFAULT_VALUE     us }
        { VALID_VALUES      {ns us ms} }
        { VARIABLE          passFailLatencyUnit }
        { VARIABLE_CLASS    testConf }
    }

    {
        { NAME              latencyThresholdMode }
        { BACKEND_TYPE      string }
        { DEFAULT_VALUE     average }
        { VALID_VALUES      {average maximum} }
        { VALUE_LABELS      {"Average/Port" "Maximum Port"} }
        { VARIABLE          passFailLatencyType }
        { VARIABLE_CLASS    testConf }
    }

    {
        { NAME              advertiseRoutes }
        { BACKEND_TYPE      integer }
        { DEFAULT_VALUE     1 }
        { VALID_VALUES      {1 0}}
        { LABEL             "Advertise Route Range" }
        { ON_INIT           isisPerformance::enableAdvertiseRoutesCmd }
        { ON_CHANGE         isisPerformance::enableAdvertiseRoutesCmd }
        { VARIABLE_CLASS    testCmd }
    }

    {
        { NAME              emulatedRoutersPerPortNumber }
        { BACKEND_TYPE      integer }
        { DEFAULT_VALUE     1 }
        { MIN               1 }
        { MAX               NULL }
        { LABEL             "Number of emulated routers per port" }
        { ON_UPDATE         isisPerformance::emulatedRoutersUpdate }
        { VARIABLE_CLASS    testCmd }
    }

    {
	{ NAME               ipSrcIncrm }
	{ BACKEND_TYPE       string }
	{ DEFAULT_VALUE      0.0.0.1 }
	{ LABEL              "Increment By: " }
	{ VARIABLE_CLASS     testCmd }
	{ ON_INIT            isisPerformance::OnValidAddressInit }
    }

    {
        { NAME              isisOsiLevel }
        { BACKEND_TYPE      string }
        { DEFAULT_VALUE     "Level 2" }
        { VALID_VALUES      {"Level 1" "Level 2" "Level 1+2"} }
        { LABEL             "Level: " }
        { VARIABLE_CLASS    testCmd }
    }

    {
        { NAME              holdtime }
        { BACKEND_TYPE      integer }
        { DEFAULT_VALUE     30 }
        { MIN               10 }
        { MAX               NULL }
        { LABEL             "IS-IS neighbors Holdtime" }
        { VARIABLE_CLASS    testCmd }
    }

    {
        { NAME              routesPerRouterNumber }
        { BACKEND_TYPE      integer }
        { DEFAULT_VALUE     1 } 
        { MIN               1 }
        { MAX               NULL }
        { LABEL             "No. of routes per Router: " }
        { VARIABLE_CLASS    testCmd }
    }

    {
        { NAME              firstRoute }
        { BACKEND_TYPE      string }
        { DEFAULT_VALUE     "192.168.1.0" }
        { LABEL             "First Route: " }
        { VARIABLE_CLASS    testCmd }
        { ON_INIT           isisPerformance::OnValidAddressInit }
    }

    {
        { NAME              routeMaskWidth }
        { BACKEND_TYPE      integer }
        { DEFAULT_VALUE     24 }
        { MIN               0}
        { LABEL             "Route Mask: " }
        { VARIABLE_CLASS    testCmd }
        { ON_INIT           isisPerformance::OnRoutesMaskInit }
    }

    {
        { NAME              incrPerRouter }
        { BACKEND_TYPE      string }
        { DEFAULT_VALUE     "0.1.0.0" }
        { LABEL             "Increment by (per Router) " }
        { VARIABLE_CLASS    testCmd }
        { ON_INIT           isisPerformance::OnValidAddressInit }
    }

    {
        { NAME              routeOrigin }
        { BACKEND_TYPE      string }
        { DEFAULT_VALUE     "Internal" }
        { VALID_VALUES      {Internal External} }
        { LABEL             "Route Origin: " }
        { VARIABLE_CLASS    testCmd }
    }

    {
        { NAME              advertiseNetworkRange }
        { BACKEND_TYPE      integer }
        { DEFAULT_VALUE     0 }
        { VALID_VALUES      {1 0}}
        { LABEL             "Advertise Network Range" }
        { ON_INIT           isisPerformance::enableAdvertiseNetRangeCmd}
        { ON_CHANGE         isisPerformance::enableAdvertiseNetRangeCmd}
        { VARIABLE_CLASS    testCmd }
    }

    {
        { NAME              rowsNumber }
        { BACKEND_TYPE      integer }
        { DEFAULT_VALUE     1 }
        { MIN_VALUE         1 }
        { LABEL             "Number of Rows: " }
        { VARIABLE_CLASS    testCmd }
    }

    {
        { NAME              columnsNumber }
        { BACKEND_TYPE      integer }
        { DEFAULT_VALUE     1 }
        { MIN_VALUE         1 }
        { LABEL             "Number of Columns: " }
        { VARIABLE_CLASS    testCmd }
    }

    {
        { NAME              firstSubnet }
        { BACKEND_TYPE      string }
        { DEFAULT_VALUE     "192.20.20.0" }
        { LABEL             "First Subnet IP: " }
        { VARIABLE_CLASS    testCmd }
        { ON_INIT           isisPerformance::OnValidAddressInit }
    }

    {
        { NAME              subnetMaskWidth }
        { BACKEND_TYPE      integer }
        { DEFAULT_VALUE     24 }
        { MIN               0 }
        { LABEL             "Subnet Mask: " }
        { VARIABLE_CLASS    testCmd }
        { ON_INIT           isisPerformance::OnSubnetMaskInit }
    }

    {
        { NAME              linkType }
        { BACKEND_TYPE      string }
        { DEFAULT_VALUE     "Broadcast" }
        { VALID_VALUES      {Broadcast "Point to Point"} }
        { LABEL             "Link type: " }
        { VARIABLE_CLASS    testCmd }
    }

    {
        { NAME              enable802dot1qTag }
        { BACKEND_TYPE      boolean }
        { DEFAULT_VALUE     false }
        { VALID_VALUES      {true false} }
        { LABEL             "Enable 802.1q Tag" }
        { VARIABLE_CLASS    testConf }
        { ON_INIT           isisPerformance::OnEnable802dot1qTagInit }
        { ON_CHANGE         isisPerformance::OnEnable802dot1qTagChange }
    }

    {
        { NAME              firstVlanID }
        { BACKEND_TYPE      integer }
        { DEFAULT_VALUE     1 }
        { MIN               0 }
        { MAX               4095 }
        { LABEL             "First VLAN ID: " }
        { VARIABLE_CLASS    testConf }
    }

    {
        { NAME              incrementVlanID }
        { BACKEND_TYPE      boolean }
        { DEFAULT_VALUE     no }
        { VALID_VALUES      {yes no} }
        { LABEL             "Increment VLAN ID" }
        { VARIABLE_CLASS    testConf }
    }

    {
        { NAME              vlanWarningLabel1 }
        { BACKEND_TYPE      string }
        { LABEL             "NOTE 1: If the DUT strips VLAN tags,the minimum frame\
             \n             size on Ethernet should be set to 68 bytes." }
        { VARIABLE_CLASS    null }
    }

    { 
        { NAME              vlanWarningLabel2 }
        { BACKEND_TYPE      string }
        { LABEL             "NOTE 2: VLAN Parameters can be set from IP, Name & VLAN ID\
              \n             in Traffic Setup." }
        { VARIABLE_CLASS    null }
    }

    {
        { NAME              firstSrcIpAddress }
        { BACKEND_TYPE      string }
        { DEFAULT_VALUE     20.20.20.2 } 
        { VARIABLE_CLASS    testConf }
    }

    {
        { NAME              ipSrcMaskWidth }
        { BACKEND_TYPE      string }
        { DEFAULT_VALUE     24 } 
        { VARIABLE_CLASS    testConf }
    }

 

    {
        { NAME              ipSrcIncr }
        { BACKEND_TYPE      string }
        { DEFAULT_VALUE     0.0.0.1 } 
        { VARIABLE_CLASS    testConf }
    }

    {
        { NAME              firstDestDUTIpAddress }
        { BACKEND_TYPE      string }
        { DEFAULT_VALUE     20.20.20.1 }
        { VARIABLE_CLASS    testConf }

    }

    {
        { NAME              ipDestDUTMaskWidth }
        { BACKEND_TYPE      string }
        { DEFAULT_VALUE     24 } 
        { VARIABLE_CLASS    testConf }
    }

    {
        { NAME              ipDestIncr }
        { BACKEND_TYPE      string }
        { DEFAULT_VALUE     0.0.0.0 } 
        { VARIABLE_CLASS    testConf }
    }

    {
        { NAME              incrIpAddrByteNum }
        { BACKEND_TYPE      integer }
        { DEFAULT_VALUE     3 }
        { VARIABLE_CLASS    testConf }
    }

    { 
        { NAME              firstSrcIpV6Address }
        { BACKEND_TYPE      string }
        { DEFAULT_VALUE     2001::2 }
        { VARIABLE_CLASS    testConf }
    }

    {
        { NAME              ipV6SrcMaskWidth }
        { BACKEND_TYPE      string }
        { DEFAULT_VALUE     64 } 
        { VARIABLE_CLASS    testConf }
    }

    {
        { NAME              ipV6SrcIncr }
        { BACKEND_TYPE      string }
        { DEFAULT_VALUE     0:0:0:0:0:0:0:1 } 
        { VARIABLE_CLASS    testConf }
    }

    {
        { NAME              firstDestDUTIpV6Address }
        { BACKEND_TYPE      string }
        { DEFAULT_VALUE     2001::1}
        { VARIABLE_CLASS    testConf }
    }

    {
        { NAME              ipV6DstMaskWidth }
        { BACKEND_TYPE      string }
        { DEFAULT_VALUE     64 } 
        { VARIABLE_CLASS    testConf }
    }

    {
        { NAME              ipV6DstIncr }
        { BACKEND_TYPE      string }
        { DEFAULT_VALUE     0:0:0:0:0:0:0:0 } 
        { VARIABLE_CLASS    testConf }
    }

    {
        { NAME              incrIpV6AddressField }
        { BACKEND_TYPE      string }
        { DEFAULT_VALUE     interfaceId }
        { VALID_VALUES      {interfaceId subnetId siteLevelAggregationId \
        nextLevelAggregationId topLevelAggregationId } }
        { VARIABLE_CLASS    testConf }
    }

    { 
        { NAME              supportPortConfigMap }
        { BACKEND_TYPE      integer }
        { DEFAULT_VALUE     1 }
        { VARIABLE_CLASS    supportPortConfigMap }
    }

    { 
        { NAME              supportNewFrameData }
        { BACKEND_TYPE      integer }
        { DEFAULT_VALUE     1 }
        { VARIABLE_CLASS    supportNewFrameData }
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
	{ DEFAULT_VALUE     ip }
        { VALID VALUES      {ip ipV6} }
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
        { NAME              supportAutoAddressForManualMap }
        { BACKEND_TYPE      integer }
        { DEFAULT_VALUE     1 }
        { VARIABLE_CLASS    supportAutoAddressForManualMap }
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
	{ DEFAULT_VALUE     {Manual Automatic} }
	{ VARIABLE_CLASS    automap }
    }

    {
        { NAME              map }
        { BACKEND_TYPE      string }
        { DEFAULT_VALUE     many2many }
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
	{ DEFAULT_VALUE     isisSuite }
	{ VARIABLE_CLASS    gTestCommand }
    }

    {
	{ NAME              protocolsSupportedByTest }
	{ BACKEND_TYPE      string }
	{ DEFAULT_VALUE     {ip ipv6} }
	{ VARIABLE_CLASS    protocolsSupportedByTest }
    }

    {
	{ NAME              resultFile }
	{ BACKEND_TYPE      string }
	{ DEFAULT_VALUE     isisPerformance.results }
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
	{ DEFAULT_VALUE     isisPerformance.log }
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
        { DEFAULT_VALUE     true }
        { VARIABLE_CLASS    supportAggResultsCsv }
    }   

    {
        { NAME              supportIterationCsv }
        { BACKEND_TYPE      boolean }
        { DEFAULT_VALUE     true }
        { VARIABLE_CLASS    supportIterationCsv }
    }

}

#############################################################################
# isisPerformance::TestSetup()
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
proc isisPerformance::TestSetup {} {
    variable testName;
    variable trial
    variable framesize
    variable txPortList
    variable rxPortList
    variable txRxPorts
    variable map
    variable fileIdArray
    variable atmOnlyPortList
    variable nonAtmPortList
    variable learnproc;

    set map [map cget -type]

    global ${map}Array

    set status $::TCL_OK

    isisSuite config -testName "ISIS Performance - [getBinarySearchString isisSuite]"

    set testName [isisSuite cget -testName]

    #  Open Result files
    array set fileIdArray {}
    set defaultDelimiter    "  "
    set csvDelimiter        ","

    set fileID [openResultFile]
    set fileIdArray(default) [list $fileID $defaultDelimiter]
    if {$fileID != "stdout"} {
        writeTextResultsFileHeader $fileID
        writeTextResultsFilePortConfig $fileID 
    }

    if {[results cget -generateCSVFile] == "true" | [results cget -generateCSVFile] == $::true} {
        set fileID [openCSVResultFile]
        writeCSVHeader $fileID isisSuite [isisSuite cget -duration]
        set fileIdArray(csv) [list $fileID $csvDelimiter]
    }

    set txPortList [getTxPorts ${map}Array]
    set rxPortList [getRxPorts ${map}Array]
    set txRxPorts  [getAllPorts ${map}Array]
    array set txRxArray [array get ${map}Array]

    set protocolName    [getProtocolName [protocol cget -name]]

    ### vpiStep and vciStep will be implemented in the future
    atmTestParameter config -vpiStep    0
    atmTestParameter config -vciStep    0

    if {[atmUtils::configureAtmPorts ${map}Array atmOnlyPortList nonAtmPortList] == $::TCL_ERROR} {
        errorMsg "***** ERROR:  failed to configure ATM ports.  Test aborted."
        return $::TCL_ERROR;
    }
    ### ATM doesn't support VLAN at this time
    foreach portMap $atmOnlyPortList {
        scan $portMap "%d %d %d" c l p
        if {[isPortTagged $c $l $p] && [protocol cget -enable802dot1qTag]} {
            logMsg "***** Error: VLANs are configured on ATM port - [getPortId $c $l $p].  ATM port does not support VLAN.  Please re-configure."
            return  $::TCL_ERROR;
        }
    }

    if {[llength $atmOnlyPortList] && ($protocolName == "ipx")} {
        errorMsg "***** ERROR:  IPX protocol is not supported on ATM ports. Please re-configure."
        return $::TCL_ERROR;
    }

    if {[atmUtils::setAtmHeader $atmOnlyPortList]} {
        errorMsg "Error in setting ATM header on one or more ports: $atmOnlyPortList"
        return $::TCL_ERROR;
    }

    if [initTest isisSuite ${map}Array {ip ipV6} errMsg] {
        errorMsg $errMsg
        return $::TCL_ERROR
    }

    createMultipleInterfaces $txRxPorts [isisSuite cget -emulatedRoutersPerPortNumber]

    # if the sum of emulated routers on RX ports for every TX port is greater than 256 then ERROR
    set enableRoutes [isisSuite cget -advertiseRoutes]
    set enableRange  [isisSuite cget -advertiseNetworkRange]

    if {($enableRoutes==0 && $enableRange==0)} {
        logMsg "*** No route advertising and no network range advertising. No streams to set."
        set retCode 1
        return $retCode
    }

    set numberModifier [expr {($enableRoutes==1 && $enableRange==1) ? 2 : 1}]
    foreach txPort [lsort [array names txRxArray]] {
        scan $txPort "%d,%d,%d" tx_c tx_l tx_p
        set numRxPorts [llength  $txRxArray($txPort)]
        set sum [mpexpr $numRxPorts*[isisSuite cget -emulatedRoutersPerPortNumber]*$numberModifier]
        if {$sum>256} {
            errorMsg "\n*** WARNING: The number of emulated routers on RX ports for TX port [getPortId $tx_c $tx_l $tx_p] is $sum, greater than 256!"
            set status $::TCL_ERROR
            return $status
        }
    }

    return $status;
}

#############################################################################
# isisPerformance::TestCleanUp()
#
# DESCRIPTION
# This procedure resets common code elements needed at the end of a test.
#
# RETURNS:  
# status      TCL_OK     - on success
#             TCL_ERROR  - on failure
#
###
proc isisPerformance::TestCleanUp {} {
    variable status
    
    set status $::TCL_OK

    return $status;
}

#############################################################################
# isisPerformance::TrialSetup()
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
proc isisPerformance::TrialSetup {} {
    variable trial
    variable status

    set status $::TCL_OK
    
    logMsg " ******* TRIAL $trial - [isisSuite cget -testName] ***** "
    set ::isisSuite::trial $trial

    return $status;
}    

#############################################################################
# isisPerformance::AlgorithmSetup()
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
proc isisPerformance::AlgorithmSetup {} {
    variable map
    variable txPortList
    variable rxPortList
    variable txRxPorts
    variable framesize
    variable trial
    variable percentRateArray
    variable maxRate
    variable userRate
    variable txNumFrames
    variable atmOnlyPortList
    global ${map}Array

    set status $::TCL_OK

    set rxMode      [expr $::portRxDataIntegrity | $::portPacketGroup]
    if [changePortReceiveMode rxPortList $rxMode nowrite yes] {
            logMsg "***** WARNING: Some interfaces don't support [getTxRxModeString $rxMode RX] simultaneously."
            set status $::TCL_ERROR
            return $status
    }

    foreach atmPort $atmOnlyPortList {
        scan $atmPort "%d %d %d" c l p

        stat config -mode statModeDataIntegrity
        if {[stat set $c $l $p]} {
            errorMsg "Could not set data integrity mode statistics on port $c $l $p!"
        }
    }

    set ::isisSuite::framesize  $framesize
    isisSuite config -framesize $framesize
    set framesizeString "Framesize:$framesize"

    ######## set up results for this test
    setupTestResults isisSuite $map "" \
	${map}Array                           \
	$framesize                          \
	[isisSuite cget -numtrials]         \
	false                               \
        1                                   \
        isisPerformance

    cleanUpIsisGlobals

    if [initMaxRate ${map}Array maxRate $framesize userRate [isisSuite cget -percentMaxRate]] {
        set status $::TCL_ERROR
        return $status
    }

    if [configureIsisProtocols ${map}Array] {
        errorMsg "***** Error configuring ISIS protocols..."
        return $::TCL_ERROR
    }

    # write the streams
    if [writeIsisPerformanceStreams ${map}Array txNumFrames [isisSuite cget -routesPerRouterNumber]] {
        return $::TCL_ERROR
    }

    return $status;
}

#############################################################################
# isisPerformance::AlgorithmBody()
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
proc isisPerformance::AlgorithmBody {args} {
    variable map
    global ${map}Array

    variable txPortList
    variable rxPortList
    variable neighborIpAddressArray
    variable dutIpAddressArray
    variable userRate
    variable framesize
    variable trial
    variable txNumFrames
    variable totalTxNumFrames
    variable totalRxNumFrames
    variable thruputRate;
    variable resultArray


    set status $::TCL_OK

    # Start ISIS Server
    logMsg "Starting ISIS..."
    
    if [startIsisServer rxPortList] {
        errorMsg "Error Starting ISIS!"
        return $::TCL_ERROR
    }

    # Confirm peer established
    if [confirmIsisSessionUp rxPortList 1000] {
        errorMsg "*** Isis sessions could not be established. The delay is not long enough or there is a network problem."
        isisCleanUp rxPortList no
        return $::TCL_ERROR
    }

    # Waiting for all routes to be advertised...
    set rangeRoutes    [getNetRangeCount [isisSuite cget -rowsNumber] [isisSuite cget -columnsNumber]]
    if {[isisSuite cget -advertiseRoutes]==1 && [isisSuite cget -advertiseNetworkRange]==1} {

        set advertiseDelay [estimateAdvertiseDelay [expr $rangeRoutes+[isisSuite cget -routesPerRouterNumber]]]

    } elseif {[isisSuite cget -advertiseNetworkRange]==1} {

        set advertiseDelay [estimateAdvertiseDelay $rangeRoutes]

    } elseif {[isisSuite cget -advertiseRoutes]==1} {

        set advertiseDelay [estimateAdvertiseDelay [isisSuite cget -routesPerRouterNumber]]

    }
    logMsg "Waiting $advertiseDelay seconds for all routes to be advertised..."

    writeWaitForPause  "Waiting for routes to be advertised ..." $advertiseDelay

    logMsg "Pausing for 30 seconds before starting transmitting ..."          
    writeWaitForPause "Pause before transmitting.." 30

    set status [isisPerformance::doBinarySearch isisSuite ${map}Array userRate \
                 thruputRate txNumFrames totalTxNumFrames rxNumFrames \
                 totalRxNumFrames percentTputRateArray];

    foreach txMap $txPortList {
        scan $txMap "%d %d %d" tx_c tx_l tx_p
        set resultArray($trial,$framesize,1,$tx_c,$tx_l,$tx_p,TXtransmitFrames) $txNumFrames($tx_c,$tx_l,$tx_p)
    }

    set status [expr [isisPerformance::AlgorithmMeasure] && $status]

    return $status
}

########################################################################################
# Procedure: configureIsisProtocols
#
# Description: This command Configures ISIS for performance test.
#
# Argument(s):
# TxRxArray       - map, ie. many2manyArray
# write           - flag to commit or not commit the changes
#
# Results :       0 : No error found
#                 1 : Error found
#         
########################################################################################
proc isisPerformance::configureIsisProtocols {TxRxArray} \
{   
    upvar $TxRxArray     txRxArray

    set retCode 0
    set index 0
#    set portList         [getRxPorts txRxArray]
    set portList         [getAllPorts txRxArray]

    logMsg "Configuring ISIS protocols..."
    foreach rxPort $portList {
            scan $rxPort "%d %d %d" c l p  
#            logMsg "Initializing isis on port $c $l $p\n"
            initializeIsis $c $l $p
            cleanUpIsisGlobals

            if [ip get $c $l $p] {
                errorMsg "Error getting ip on port [getPortId $tx_c $tx_l $tx_p]"
                set retCode 1
            }

            if {[string tolower [testConfig::getTestConfItem protocolName]] == "ipv6"} {
                set ipType "addressTypeIpV6"
            } else {
                set ipType "addressTypeIpV4"
            }

            # for every emulated router
            for {set router 1} {$router <= [isisSuite cget -emulatedRoutersPerPortNumber]} {incr router} {

                set description  [format "%02d:%02d ProtocolInterface - $router" $l $p]
                isisInterface setDefault
                isisInterface config -protocolInterfaceDescription $description
#                isisInterface config -metric    [expr 20 * ([lsearch $portList $rxPort]+1)]	
                # Level
                switch [isisSuite cget -isisOsiLevel] {
                    "Level 1" {
                        set pIsisLevel isisLevel1
                    }
                    "Level 1+2" {
                        set pIsisLevel isisLevel1Level2
                    }
                    default {
                        set pIsisLevel isisLevel2
                    }
                }

                switch [isisSuite cget -linkType] {
                    "Point to Point" {
                        set pNetworkType isisPointToPoint
                    }
 
                    "Broadcast" {
                        set pNetworkType isisBroadcast
                        if {[atmUtils::isAtmPort $c $l $p]} {
                            set pNetworkType isisPointToPoint
                        }
                    }
                }

                # add interface
                if {[addIsisInterfaceItem true true $pIsisLevel [isisSuite cget -holdtime] $pNetworkType]} {
                    errorMsg "*** Error Adding connected interface."
                    set retCode 1
                } 

                # advertise routes
                set enableAdvertiseRoutes [isisSuite cget -advertiseRoutes]
                if {$enableAdvertiseRoutes == 1} {
#                    logMsg "Port $c.$l.$p: advertising Route Range for $c $l $p..."

                    set networkIpAddress      [isisSuite cget -firstRoute]
                    set routesPerRouterNumber [isisSuite cget -routesPerRouterNumber]
                    set prefix                [isisSuite cget -routeMaskWidth]
                    set routeOrigin           [isisSuite cget -routeOrigin]
                    set byteNumber            [expr $prefix/8]
                    if {[protocol cget -name] == $::ip} {
                        set networkIpAddress [num2ip [mpexpr [ip2num $networkIpAddress]+[ip2num [isisSuite cget -incrPerRouter]]*$index]]
                    } else {
#                        set networkIpAddress  [incrIpV6Field $networkIpAddress $prefix $index]
                        set networkIpAddress [ipv6::convertBytesToIpv6Address [value2Hexlist [mpexpr [hexlist2Value \
                                   [ipv6::host2addr $networkIpAddress]] +[hexlist2Value [ipv6::host2addr [isisSuite cget -incrPerRouter]]]*$index] 16]]
                    }

                    logMsg "Port $c.$l.$p: adding $routesPerRouterNumber route items starting at $networkIpAddress"
                    # add route item
                    if {[addIsisRouteItem $::true $routesPerRouterNumber $prefix $networkIpAddress $ipType $routeOrigin]} {
                        errorMsg "*** Error adding routeItem for routeRange"
                        set retCode 1
                    }
                }

                # advertise network range
                set enableAdvertiseNetRange [isisSuite cget -advertiseNetworkRange]
                if {$enableAdvertiseNetRange == 1} {
#                    logMsg "Port $c.$l.$p: advertising Network Range for $c $l $p..."
                    
                    set numRows    [isisSuite cget -rowsNumber]
                    set numColumns [isisSuite cget -columnsNumber]

                    set firstSubnet [isisSuite cget -firstSubnet]
                    set subnetMask  [isisSuite cget -subnetMaskWidth]
                    set byteNumber  [expr $subnetMask/8]
                    set incrNet     [expr [getNetRangeCount $numRows $numColumns]*$index]
                    if {[protocol cget -name] == $::ip} {
                        set firstSubnet [incrIpField $firstSubnet $byteNumber $incrNet]
                        scan $firstSubnet "%d.%d.%d.%d" ip1 ip2 ip3 ip4

                        set byte3 [value2Hexlist $ip1 1]
                        set byte4 [value2Hexlist $ip2 1]
                        set byte5 [value2Hexlist $ip3 1]
                        set byte6 [value2Hexlist $ip4 1]

                        set rid "00 $byte3 $byte4 $byte5 $byte6 00"
                    } else {
                        set firstSubnet [ipV6Utils::incrIpV6Field $firstSubnet $subnetMask $incrNet]
                        set byte3 [value2Hexlist $c 1]
                        set byte4 [value2Hexlist $l 1]
                        set byte5 [value2Hexlist $p 1]
                        set byte6 [value2Hexlist $index 1]

                        set rid "00 $byte3 $byte4 $byte5 $byte6 00"
                    }

                    logMsg "Port $c.$l.$p: adding internode route $firstSubnet"
                    if {[addIsisGridInternodeRoute $firstSubnet $subnetMask $ipType]} {
                        errorMsg "*** Error adding internode route for grid."
                        set retCode 1
                    }

                    logMsg "Port $c.$l.$p: adding grid item $rid with $numRows rows and $numColumns columns."
                    if {[addIsisGridItem $numRows $numColumns $rid]} {
                        errorMsg "*** Error adding grid to router."
                        set retCode 1
                    }
                }

                # add router to isisServer
                set byte2 [value2Hexlist $l 1]
                set byte3 [value2Hexlist $p 1]
                set byte4 [value2Hexlist $router 1]
                set rid "00 $byte2 $byte3 $byte4 00 00"

                logMsg "Port $c.$l.$p: adding router, RID $rid"
                if {[addIsisRouter $rid]} {
                    errorMsg "*** Error adding router to isisServer."
                    set retCode 1
                }

                if [isisServer write] {
                    errorMsg "*** Error writing isisServer"
                    set retCode 1
                }
                incr index
            }
    }

    if [enableProtocolStatistics portList enableIsisStats] {
        errorMsg "***** Error enabling ISIS statistics..."
        set retCode 1
        return $retCode
    }

    if [enableProtocolServer portList isis noWrite] {
        errorMsg "***** Error enabling ISIS server..."
        set retCode 1
        return $retCode
    }

    return $retCode
}

#################################################################################
# Procedure: writeIsisPerformanceStreams
#
# Description: This command configures and writes the stream for isis performance test
#
#################################################################################
proc isisPerformance::writeIsisPerformanceStreams {TxRxArray {TxNumFrames ""} {numFrames 0} {testCmd isisSuite}} \
{
    upvar $TxRxArray    txRxArray
    upvar $TxNumFrames  txNumFrames

    variable atmOnlyPortList
    variable nonAtmPortList

    set index 0
    set framesize	[isisSuite cget -framesize]

    filterPallette              setDefault
    filter                      setDefault
    set genericPattern          {AC CA DA AD}
    set adjustVlanOffset        0
    set retCode                 0
    set preambleSize            8
    udf                         setDefault
    if {![info exists udfList]} {
        set udfList {1 2 3 4}
    }
    disableUdfs $udfList

    stream setDefault
    stream config -daRepeatCounter   daArp
    stream config -framesize         [$testCmd cget -framesize]
    stream config -enableTimestamp   true

    stream config -enableIbg         false
    stream config -enableIsg         false

    stream config -rateMode          usePercentRate
    stream config -percentPacketRate [$testCmd cget -percentMaxRate]
    stream config -gapUnit           gapNanoSeconds

    set firstRouteAddress  [$testCmd cget -firstRoute]
    set firstSubnetAddress [$testCmd cget -firstSubnet]

    set streamGroup 0

    set enableRoutes [isisSuite cget -advertiseRoutes]
    set enableRange  [isisSuite cget -advertiseNetworkRange]

    if {($enableRoutes==0 && $enableRange==0)} {
        logMsg "*** No route advertising and no network range advertising. No streams to set."
        return 1
    }

    if {($enableRoutes==1 && $enableRange==1)} {
        set numFrames [expr max( [isisSuite cget -routesPerRouterNumber] , [getNetRangeCount [isisSuite cget -rowsNumber] [isisSuite cget -columnsNumber]] )]
    } elseif {$enableRoutes==1} {
        set numFrames [isisSuite cget -routesPerRouterNumber]
    } else {
        set numFrames [getNetRangeCount [isisSuite cget -rowsNumber] [isisSuite cget -columnsNumber]]
    }

    set numberModifier [expr {($enableRoutes==1 && $enableRange==1) ? 2 : 1}]

    logMsg "\n"

    foreach txPort [lsort [array names txRxArray]] {
        logMsg ""
        scan $txPort "%d,%d,%d" tx_c tx_l tx_p

        if {[protocol cget -name] == $::ip} {
            set packetGroupIdOffset     42 
            set packetGroupOffset       48   
            set sequenceNumberOffset    44
            set dataIntegrityOffset     48
            set destIpOffset            30
#             if {[atmUtils::isAtmPort $tx_c $tx_l $tx_p]} {
#                  set packetGroupIdOffset     52
#                  set packetGroupOffset       58
#                  set sequenceNumberOffset    54
#                  set dataIntegrityOffset     58
#                  set destIpOffset            40
#             }
        } else {
            set packetGroupIdOffset     62 
            set packetGroupOffset       68   
            set sequenceNumberOffset    72
            set dataIntegrityOffset     64
            set destIpOffset            38
#             if {[atmUtils::isAtmPort $tx_c $tx_l $tx_p]} {
#                 set packetGroupIdOffset     72
#                 set packetGroupOffset       78
#                 set sequenceNumberOffset    82
#                 set dataIntegrityOffset     74
#                 set destIpOffset            38
#             }
        }

        if {[protocol cget -enable802dot1qTag]} {
            set adjustVlanOffset        4
            if {[protocol cget -name] == $::ip} {
                set destIpOffset       [expr $destIpOffset+4]
            }
        }

        set pppTxOffset 0
        if {[detectPPP $tx_c $tx_l $tx_p]} {
            set pppTxOffset 10
        }

        set atmTxOffset 0
        if {[atmUtils::isAtmPort $tx_c $tx_l $tx_p]} {
            set atmTxOffset 10
        }

        set streamID                         1
        set txNumFrames($tx_c,$tx_l,$tx_p)   0

        # get the mac & Ip addresses for the da/sa
        if [port get $tx_c $tx_l $tx_p] {
            errorMsg "Port [getPortId $tx_c $tx_l $tx_p] not configured yet!"
            set retCode 1
        }

        set numRxPorts [llength  $txRxArray($txPort)]

        foreach rxPort [lsort $txRxArray($txPort)] {
            scan [join $rxPort] "%d %d %d" rx_c rx_l rx_p

	    set pppRxOffset 0
	    if {[detectPPP $rx_c $rx_l $rx_p]} {
		set pppRxOffset 10
	    }
            set atmRxOffset 0
            if {[atmUtils::isAtmPort $rx_c $rx_l $rx_p]} {
                set atmRxOffset 10
            }

            set count [lsearch [getAllPorts txRxArray] $rxPort]

            stream config -sa   [port cget -MacAddress]

            # advertise routes #################################################################################
            if {$enableRoutes == 1} {

                for {set router 0} {$router < [isisSuite cget -emulatedRoutersPerPortNumber]} {incr router} {

                    set stepToIncrement [mpexpr $count*[isisSuite cget -emulatedRoutersPerPortNumber]+$router]

                    stream config -numFrames        $numFrames
                    stream config -preambleSize     $preambleSize

                    if {[protocol cget -name] == $::ip} {

                        set networkIpAddress [num2ip [mpexpr [ip2num $firstRouteAddress]+[ip2num [isisSuite cget -incrPerRouter]]*$stepToIncrement]]

                        logMsg "Tx $tx_c.$tx_l.$tx_p Rx $rx_c.$rx_l.$rx_p: Setting stream $streamID for route range with destination IP $networkIpAddress"
                        #   Use UDF 1 for Destination Ip Address
                        udf setDefault
                        udf config -enable          $::true
                        udf config -offset          [expr $destIpOffset-$pppTxOffset+$atmTxOffset]
                        udf config -countertype     $::c32
                        udf config -initval         [host2addr $networkIpAddress]
                        udf config -repeat          [isisSuite cget -routesPerRouterNumber]
                        udf config -step            [mpexpr 2<<[expr 31 -  [isisSuite cget -routeMaskWidth]]]

                        if {[udf set 1]} {
                            errorMsg "Error setting udf 1."
                            set status 1
                        }

                    } else {

                        set networkIpAddress [ipv6::convertBytesToIpv6Address [value2Hexlist [mpexpr [hexlist2Value \
                               [ipv6::host2addr $firstRouteAddress]] +[hexlist2Value [ipv6::host2addr [isisSuite cget -incrPerRouter]]]*$stepToIncrement] 16]]

                        if [ipV6 get $tx_c $tx_l $tx_p] {
                            errorMsg "Error getting ip on port [getPortId $tx_c $tx_l $tx_p]"
                            set retCode 1
                        }

                        ipV6   config -destAddr       $networkIpAddress
                        ipV6   config -destMask       [isisSuite cget -routeMaskWidth]
                        ipV6   config -destAddrMode   ipV6IncrNetwork
                        ipV6   config -destAddrRepeatCount [isisSuite cget -routesPerRouterNumber]
                        ipV6   config -destStepSize   1

                        if [ipV6 set $tx_c $tx_l $tx_p] {
                            errorMsg "Error setting ip on port [getPortId $tx_c $tx_l $tx_p]"
                            set retCode 1
                        }   
                        logMsg "Tx $tx_c.$tx_l.$tx_p Rx $rx_c.$rx_l.$rx_p: Setting stream $streamID for route range with destination IPv6 $networkIpAddress"

                    }
              
                    ##### Stream for generating traffic to the routes #####
                    stream config -name         "Tx->$networkIpAddress"

                    if {[atmUtils::isAtmPort $tx_c $tx_l $tx_p]} {
                        if {[atmUtils::buildAtmParams  $tx_c $tx_l $tx_p]} {
                            errorMsg "Error building ATM parameters."
                            set retCode $::TCL_ERROR
                        }
                    }

                    if [streamUtils::streamSet $tx_c $tx_l $tx_p $streamID] {
                        errorMsg "Error setting stream $streamID on port [getPortId $tx_c $tx_l $tx_p]"
                        set retCode $::TCL_ERROR
                    }

                    # note - we set the stream twice because we need to get the conf'd framerate for calc'ing the duration
                    if {[port isActiveFeature $tx_c $tx_l $tx_p $::portFeatureAtm]} {
                        if {[streamQueue get $tx_c $tx_l $tx_p 1]} {
                            errorMsg "Error getting streamQueue on [getPortId $tx_c $tx_l $tx_p] for queue 1"
                        }
                        set framerate    [mpexpr round ([streamQueue cget -aal5FrameRate])]
                    } else {
                        if [stream get $tx_c $tx_l $tx_p $streamID] {
                            errorMsg "Error getting stream $streamID from port [getPortId $tx_c $tx_l $tx_p]"
                            set retCode 1
                        }
                        set framerate    [stream cget -framerate]
                    }
                    
                    set loopCount 1

                    #calculate the duration 
                    set loopCount    [mpexpr round (double ($framerate)/[stream cget -numFrames]/[isisSuite cget -emulatedRoutersPerPortNumber]/$numRxPorts/$numberModifier * [$testCmd cget -duration])]
                    if { $loopCount == 0} {
                        set loopCount 1
                    }

                    set txNumFrames($tx_c,$tx_l,$tx_p)  [mpexpr $txNumFrames($tx_c,$tx_l,$tx_p)+($loopCount* [stream cget -numFrames])]

                    if {$streamID < [mpexpr [llength $txRxArray($txPort)]*[isisSuite cget -emulatedRoutersPerPortNumber]*$numberModifier] } {
                        stream config -dma   3
                    } else {
                        stream config -dma          firstLoopCount
                        stream config -loopCount    $loopCount
                    }

                    set packetGroupId [mpexpr ($streamGroup << 8) | $stepToIncrement]

                    #   Use UDF 2 for packet Group Id
		     udf setDefault
		     udf config -enable          $::true
		     udf config -offset          [expr $packetGroupIdOffset-$pppTxOffset+$atmTxOffset]
		     udf config -initval         [value2Hexlist $packetGroupId 2]
		     udf config -countertype     $::c16
		     udf config -continuousCount $::false
		     udf config -repeat          1
		     udf config -step            1
    
		     if {[udf set 2]} {
			 errorMsg "Error setting udf 2."
			 set status 1
		     }

                    packetGroup setDefault

                    setupPacketGroup $framesize $tx_c $tx_l $tx_p
        
                    packetGroup config -signatureOffset	           [expr $packetGroupOffset-$pppTxOffset+$atmTxOffset]
                    packetGroup config -groupIdOffset	           [expr $packetGroupIdOffset-$pppTxOffset+$atmTxOffset]  
                    packetGroup config -signature	           $genericPattern
                    packetGroup config -insertSequenceSignature    $::true
                    packetGroup config -sequenceNumberOffset       [expr $sequenceNumberOffset-$pppTxOffset+$atmTxOffset]
                    packetGroup config -allocateUdf                $::false

                    if {[atmUtils::isAtmPort $tx_c $tx_l $tx_p]} { 
                        if {[packetGroup setQueueTx $tx_c $tx_l $tx_p 1 $streamID]} {
                            errorMsg "Error setting packetGroup setQueueTx on [getPortId $tx_c $tx_l $tx_p] 1 $streamID"
                            set retCode $::TCL_ERROR
                        }
                    } else {
                        if {[packetGroup setTx $tx_c $tx_l $tx_p $streamID]} {
                            errorMsg "Error setting packetGroup setTx on [getPortId $tx_c $tx_l $tx_p] $streamID"
                            set retCode $::TCL_ERROR
                        }
                    }

                    dataIntegrity config -signatureOffset [expr $packetGroupOffset-$pppTxOffset+$atmTxOffset]
                    dataIntegrity config -signature       $genericPattern
                    dataIntegrity config -insertSignature true
                    dataIntegrity config -enableTimeStamp true


                    if {[atmUtils::isAtmPort $tx_c $tx_l $tx_p]} { 
                        if {[dataIntegrity setQueueTx $tx_c $tx_l $tx_p 1 $streamID]} {
                            errorMsg "Error setting packetGroup setQueueTx on [getPortId $tx_c $tx_l $tx_p] 1 $streamID"
                            set retCode $::TCL_ERROR
                        }
                    } else {
                        if {[dataIntegrity setTx $tx_c $tx_l $tx_p $streamID]} {
                            errorMsg "Error setting packetGroup setTx on [getPortId $tx_c $tx_l $tx_p] $streamID"
                            set retCode $::TCL_ERROR
                        }
                    }

                    if {[atmUtils::isAtmPort $tx_c $tx_l $tx_p]} {
                        if {[atmUtils::buildAtmParams  $tx_c $tx_l $tx_p]} {
                            errorMsg "Error building ATM parameters."
                            set retCode $::TCL_ERROR
                        }
                    }

                    if [streamUtils::streamSet $tx_c $tx_l $tx_p $streamID] {
                        errorMsg "Error setting stream $streamID on port [getPortId $tx_c $tx_l $tx_p]"
                        set retCode $::TCL_ERROR
                    }

                    incr streamID
                }   ; # for each emulated router

                # set up the pattern filter
                filterPallette config -pattern1		$genericPattern
                filterPallette config -patternMask1	{00 00 00 00}
                filterPallette config -patternOffset1	[expr $packetGroupOffset-$pppRxOffset+$atmRxOffset + [adjustSignatureUdfForVlan $txPort $rxPort]]

                if [filterPallette set $rx_c $rx_l $rx_p] {
                    errorMsg "Error setting filter pallette for [getPortId $rx_c $rx_l $rx_p]"
                    set status $::TCL_ERROR
                }

                # set the filter parameters on the receive port
                filter setDefault
                filter config -captureFilterEnable	        true
                filter config -captureTriggerEnable	        true            
                filter config -userDefinedStat2Enable           true
                filter config -userDefinedStat2Pattern          pattern1

                if [filter set $rx_c $rx_l $rx_p] {
                    errorMsg "Error setting filters on [getPortId $rx_c $rx_l $rx_p]"
                }

                setupPacketGroup $framesize $rx_c $rx_l $rx_p 0 [expr $packetGroupIdOffset-$pppRxOffset+$atmRxOffset]
                packetGroup config -signatureOffset        [expr $packetGroupOffset-$pppRxOffset+$atmRxOffset + [adjustSignatureUdfForVlan $txPort $rxPort]]
                packetGroup config -groupIdOffset          [expr $packetGroupIdOffset-$pppRxOffset+$atmRxOffset + [adjustSignatureUdfForVlan $txPort $rxPort]]
                packetGroup config -signature              $genericPattern
                packetGroup config -sequenceNumberOffset   [expr $sequenceNumberOffset-$pppRxOffset+$atmRxOffset + [adjustSignatureUdfForVlan $txPort $rxPort]]

                if {[packetGroup setRx $rx_c $rx_l $rx_p]} {
                    errorMsg "Error setting packetGroup setRx on [getPortId $rx_c $rx_l $rx_p]"
                    set retCode $::TCL_ERROR
                }

                dataIntegrity config -signatureOffset [expr $packetGroupOffset-$pppRxOffset+$atmRxOffset + [adjustSignatureUdfForVlan $txPort $rxPort]]
                dataIntegrity config -signature       $genericPattern

                if {[dataIntegrity setRx $rx_c $rx_l $rx_p]} {
                    errorMsg "Error setting packetGroup setRx on [getPortId $rx_c $rx_l $rx_p]"
                    set retCode $::TCL_ERROR
                }

                if [filter set $rx_c $rx_l $rx_p] {
                    errorMsg "Error setting filters on port [getPortId $rx_c $tx_l $rx_p]"
                    set retCode 1
                }

                if [filterPallette set $rx_c $rx_l $rx_p] {
                    errorMsg "Error setting filterPallette on port [getPortId $rx_c $rx_l $rx_p]"
                    set retCode 1
                }
            }

            # network Range ######################################################################################################
            if {$enableRange == 1} {

                set repeat [getNetRangeCount [isisSuite cget -rowsNumber] [isisSuite cget -columnsNumber]]
                if {![info exists stepToIncrement]} {
                    set stepToIncrement 0
                }
                set stepBase $stepToIncrement

                for {set router 0} {$router < [isisSuite cget -emulatedRoutersPerPortNumber]} {incr router} {

                    set stepToIncrement [mpexpr $count*[isisSuite cget -emulatedRoutersPerPortNumber]+$router]
                    
                    stream config -numFrames        $numFrames
                    stream config -preambleSize     $preambleSize

                    if {[protocol cget -name] == $::ip} {

                        scan $firstSubnetAddress "%d.%d.%d.%d" a b c d
                        set firstByte [mpexpr $stepToIncrement*$repeat + $a]
                        if {$firstByte>=254} {
                            errorMsg "**** Increment step for First Subnet IP is too big.\nOne must decrease number of emulated routers per port or rows/columns for network range."
                            set status 1
                            return $status
                        }

                        set networkIPAddress [num2ip \
                                                [mpexpr \
                                                    [ip2num $firstSubnetAddress]+ \
                                                    [mpexpr $stepToIncrement*$repeat*[mpexpr 2<< [expr 31- [isisSuite cget -subnetMaskWidth]]]] \
                                                ] \
                                             ]

                        logMsg "Tx $tx_c.$tx_l.$tx_p Rx $rx_c.$rx_l.$rx_p: Setting stream $streamID for network range with destination IP $networkIPAddress"
                        #   Use UDF 1 for Destination Ip Address
                        udf setDefault
                        udf config -enable          $::true
                        udf config -offset          [expr $destIpOffset-$pppTxOffset+$atmTxOffset]
                        udf config -countertype     $::c32
                        udf config -initval         [host2addr $networkIPAddress]
                        udf config -repeat          $repeat
                        udf config -step            [mpexpr 2<<[expr 31 -  [isisSuite cget -subnetMaskWidth]]]

                        if {[udf set 1]} {
                            errorMsg "Error setting udf 1."
                            set status 1
                        }

                    } else {

                        set networkIPAddress [ipv6::convertBytesToIpv6Address \
                                                [value2Hexlist \
                                                    [mpexpr \
                                                        [hexlist2Value \
                                                            [ipv6::host2addr $firstSubnetAddress] \
                                                        ] + \
                                                        [mpexpr 2<< [expr 127-[isisSuite cget -subnetMaskWidth]]]*$repeat*$stepToIncrement \
                                                    ] 16 \
                                                ] \
                                             ]

                        if [ipV6 get $tx_c $tx_l $tx_p] {
                            errorMsg "Error getting ip on port [getPortId $tx_c $tx_l $tx_p]"
                            set retCode 1
                        }

                        ipV6   config -destAddr       $networkIPAddress
                        ipV6   config -destMask       [isisSuite cget -subnetMaskWidth]
                        ipV6   config -destAddrMode   ipV6IncrNetwork
                        ipV6   config -destAddrRepeatCount $repeat
                        ipV6   config -destStepSize   1

                        if [ipV6 set $tx_c $tx_l $tx_p] {
                            errorMsg "Error setting ip on port [getPortId $tx_c $tx_l $tx_p]"
                            set retCode 1
                        }   
                        logMsg "Tx $tx_c.$tx_l.$tx_p Rx $rx_c.$rx_l.$rx_p: Setting stream $streamID for network range with destination IPv6 $networkIPAddress"

                    }

                    ##### Stream for generating traffic to the network range #####
                    stream config -name         "Tx->$networkIPAddress"

                    if {[atmUtils::isAtmPort $tx_c $tx_l $tx_p]} {
                        if {[atmUtils::buildAtmParams  $tx_c $tx_l $tx_p]} {
                            errorMsg "Error building ATM parameters."
                            set retCode $::TCL_ERROR
                        }
                    }

                    if [streamUtils::streamSet $tx_c $tx_l $tx_p $streamID] {
                        errorMsg "Error setting stream $streamID on port [getPortId $tx_c $tx_l $tx_p]"
                        set retCode $::TCL_ERROR
                    }

                    # note - we set the stream twice because we need to get the conf'd framerate for calc'ing the duration
                    if {[port isActiveFeature $tx_c $tx_l $tx_p $::portFeatureAtm]} {
                        if {[streamQueue get $tx_c $tx_l $tx_p 1]} {
                            errorMsg "Error getting streamQueue on [getPortId $tx_c $tx_l $tx_p] for queue 1"
                        }
                        set framerate    [mpexpr round ([streamQueue cget -aal5FrameRate])]
                    } else {
                        if [stream get $tx_c $tx_l $tx_p $streamID] {
                            errorMsg "Error getting stream $streamID from port [getPortId $tx_c $tx_l $tx_p]"
                            set retCode 1
                        }
                        set framerate    [stream cget -framerate]
                    }

                    set loopCount 1

                    #calculate the duration 
                    set loopCount    [mpexpr round (double ($framerate)/[stream cget -numFrames]/[isisSuite cget -emulatedRoutersPerPortNumber]/$numRxPorts/$numberModifier * [$testCmd cget -duration])]
                    if { $loopCount == 0} {
                        set loopCount 1
                    }

                    set txNumFrames($tx_c,$tx_l,$tx_p)  [mpexpr $txNumFrames($tx_c,$tx_l,$tx_p)+($loopCount* [stream cget -numFrames])]

                    if {$streamID < [mpexpr [llength $txRxArray($txPort)]*[isisSuite cget -emulatedRoutersPerPortNumber]*$numberModifier] } {
                        stream config -dma   3
                    } else {
                        stream config -dma          firstLoopCount
#                        stream config -returnToId   [mpexpr [llength $txRxArray($txPort)]*[isisSuite cget -emulatedRoutersPerPortNumber]*($numberModifier-1)]
                        stream config -loopCount    $loopCount
                    }

                    set packetGroupId [mpexpr ($streamGroup << 8) | $stepToIncrement]

                    #   Use UDF 2 for packet Group Id
		     udf setDefault
		     udf config -enable          $::true
		     udf config -offset          [expr $packetGroupIdOffset-$pppTxOffset+$atmTxOffset]
		     udf config -initval         [value2Hexlist $packetGroupId 2]
		     udf config -countertype     $::c16
		     udf config -continuousCount $::false
		     udf config -repeat          1
		     udf config -step            1
    
		     if {[udf set 2]} {
			 errorMsg "Error setting udf 2."
			 set status 1
		     }

                    packetGroup setDefault

                    setupPacketGroup $framesize $tx_c $tx_l $tx_p

                    packetGroup config -signatureOffset	           [expr $packetGroupOffset-$pppTxOffset+$atmTxOffset]
                    packetGroup config -groupIdOffset	           [expr $packetGroupIdOffset-$pppTxOffset+$atmTxOffset]  
                    packetGroup config -signature	           $genericPattern
                    packetGroup config -insertSequenceSignature    $::true
                    packetGroup config -sequenceNumberOffset       [expr $sequenceNumberOffset-$pppTxOffset+$atmTxOffset]
                    packetGroup config -allocateUdf                $::false

                    if {[atmUtils::isAtmPort $tx_c $tx_l $tx_p]} { 
                        if {[packetGroup setQueueTx $tx_c $tx_l $tx_p 1 $streamID]} {
                            errorMsg "Error setting packetGroup setQueueTx on [getPortId $tx_c $tx_l $tx_p] 1 $streamID"
                            set retCode $::TCL_ERROR
                        }
                    } else {
                        if {[packetGroup setTx $tx_c $tx_l $tx_p $streamID]} {
                            errorMsg "Error setting packetGroup setTx on [getPortId $tx_c $tx_l $tx_p] $streamID"
                            set retCode $::TCL_ERROR
                        }
                    }

                    dataIntegrity config -signatureOffset [expr $packetGroupOffset-$pppTxOffset+$atmTxOffset]
                    dataIntegrity config -signature       $genericPattern
                    dataIntegrity config -insertSignature true
                    dataIntegrity config -enableTimeStamp true

                    if {[atmUtils::isAtmPort $tx_c $tx_l $tx_p]} { 
                        if {[dataIntegrity setQueueTx $tx_c $tx_l $tx_p 1 $streamID]} {
                            errorMsg "Error setting packetGroup setQueueTx on [getPortId $tx_c $tx_l $tx_p] 1 $streamID"
                            set retCode $::TCL_ERROR
                        }
                    } else {
                        if {[dataIntegrity setTx $tx_c $tx_l $tx_p $streamID]} {
                            errorMsg "Error setting packetGroup setTx on [getPortId $tx_c $tx_l $tx_p] $streamID"
                            set retCode $::TCL_ERROR
                        }
                    }

                    if {[atmUtils::isAtmPort $tx_c $tx_l $tx_p]} {
                        if {[atmUtils::buildAtmParams  $tx_c $tx_l $tx_p]} {
                            errorMsg "Error building ATM parameters."
                            set retCode $::TCL_ERROR
                        }
                    }

                    if [streamUtils::streamSet $tx_c $tx_l $tx_p $streamID] {
                        errorMsg "Error setting stream $streamID on port [getPortId $tx_c $tx_l $tx_p]"
                        set retCode $::TCL_ERROR
                    }

                    incr streamID
                    incr index
                }   

                # set up the pattern filter
                filterPallette config -pattern1		$genericPattern
                filterPallette config -patternMask1	{00 00 00 00}
                filterPallette config -patternOffset1	[expr $packetGroupOffset-$pppRxOffset+$atmRxOffset + [adjustSignatureUdfForVlan $txPort $rxPort]]

                if [filterPallette set $rx_c $rx_l $rx_p] {
                    errorMsg "Error setting filter pallette for [getPortId $rx_c $rx_l $rx_p]"
                    set status $::TCL_ERROR
                }

                # set the filter parameters on the receive port
                filter setDefault
                filter config -captureFilterEnable	    true
                filter config -captureTriggerEnable	    true            
                filter config -userDefinedStat2Enable       true
                filter config -userDefinedStat2Pattern      pattern1

                if [filter set $rx_c $rx_l $rx_p] {
                    errorMsg "Error setting filters on [getPortId $rx_c $rx_l $rx_p]"
                }

                setupPacketGroup $framesize $rx_c $rx_l $rx_p 0 [expr $packetGroupIdOffset-$pppRxOffset+$atmRxOffset]
                packetGroup config -signatureOffset        [expr $packetGroupOffset-$pppRxOffset+$atmRxOffset + [adjustSignatureUdfForVlan $txPort $rxPort]]
                packetGroup config -groupIdOffset          [expr $packetGroupIdOffset-$pppRxOffset+$atmRxOffset + [adjustSignatureUdfForVlan $txPort $rxPort]]
                packetGroup config -signature              $genericPattern
                packetGroup config -sequenceNumberOffset   [expr $sequenceNumberOffset-$pppRxOffset+$atmRxOffset + [adjustSignatureUdfForVlan $txPort $rxPort]]

                if [packetGroup setRx $rx_c $rx_l $rx_p] {
                    errorMsg "Error setting Rx packetGroup on [getPortId $rx_c $rx_l $rx_p]"
                    set status $::TCL_ERROR
                }

                dataIntegrity config -signatureOffset [expr $packetGroupOffset-$pppRxOffset+$atmRxOffset + [adjustSignatureUdfForVlan $txPort $rxPort]]
                dataIntegrity config -signature       $genericPattern

                if [dataIntegrity setRx $rx_c $rx_l $rx_p] {
                    errorMsg "Error setting Tx dataIntegrity on [getPortId $rx_c $rx_l $rx_p]"
                    set status $::TCL_ERROR
                }

                if [filter set $rx_c $rx_l $rx_p] {
                    errorMsg "Error setting filters on port [getPortId $rx_c $tx_l $rx_p]"
                    set retCode 1
                }

                if [filterPallette set $rx_c $rx_l $rx_p] {
                    errorMsg "Error setting filterPallette on port [getPortId $rx_c $rx_l $rx_p]"
                    set retCode 1
                }

            }   ; # if net range

        } ; # for RX
            incr streamGroup
    } ; # for TX

    if {$retCode == 0} {
       # adjustOffsets txRxArray
        set retCode [writeConfigToHardware txRxArray]
    }
    return $retCode
}

########################################################################
# Procedure: doBinarySearch
#
# This command performs a binary search for ISIS Performance test.  
#
# Arguments(s):
#   testCmd             - name of test command
#   TxRxArray           - map, ie. one2oneArray
#   Framerate           - array containing the framerates, per port
#   TputRateArray       - array containing the binary search results
#   TxNumFrames         - array containing the number of frames to Tx 
#   TotalTxNumFrames    - total number of frames transmitted
#   RxNumFrames         - array containing the number of frames recv'd
#   TotalRxNumFrames    - total number of frames recv'd
#   PercentMaxRate      - array containing the percent max rate per stream
#   multiTxStream       - (optional) flag; if yes then there is more than one stream created per tx port
#   LossPercent         - (optional) percent rate at which loss occurred
#   AvgLatency          - (optional) 
#   StdDeviation        - (optional)
#   NumAddressesPerStream   - (optional)
#
########################################################################
proc isisPerformance::doBinarySearch { \
        testCmd TxRxArray Framerate TputRateArray \
        TxNumFrames TotalTxNumFrames RxNumFrames TotalRxNumFrames PercentMaxRate \
        {multiTxStream no} {LossPercent ""} {AvgLatency "" } {StdDeviation "" } {NumAddressesPerStream ""}} \
{
    global ixgJitterIndex
    
    upvar $TxRxArray        txRxArray
    upvar $TputRateArray    tputRateArray
    upvar $TxNumFrames      txNumFrames
    upvar $TotalTxNumFrames totalTxNumFrames
    upvar $RxNumFrames      rxNumFrames
    upvar $TotalRxNumFrames totalRxNumFrames
    upvar $LossPercent      lossPercent
    upvar $AvgLatency       avgLatency
    upvar $StdDeviation     stdDeviation
    upvar $NumAddressesPerStream numAddressesPerStream
    upvar $Framerate localFramerate
    upvar $PercentMaxRate localPercentMaxRate

    # This is needed to prevent the value of frameRate 
    # from being changed in this function
    array set framerate [array get localFramerate]

    set txPortList [getTxPorts txRxArray]

    if {[info exists ${testCmd}::trial]} {
       set trialStr " trial [set ${testCmd}::trial],"
    } else {
       set trialStr ""
    }


    # This is needed to prevent the value of percentMaxRate 
    # from being changed in this function
    if {![array exists localPercentMaxRate]} {
        foreach txMap $txPortList {
            scan $txMap "%d %d %d" tx_c tx_l tx_p
            set percentMaxRate($tx_c,$tx_l,$tx_p)   [$testCmd cget -percentMaxRate]
        }
    } else {
        array set percentMaxRate [array get localPercentMaxRate]
    }
    set retCode $::TCL_OK
    
    set enable802dot1qTag   [protocol cget -enable802dot1qTag]
    set framesize           [$testCmd cget -framesize]
    set latencyOffset       [min 1500 [expr [getUdfOffset $framesize] - 4]]

    if {[catch {$testCmd cget -linearBinarySearch} linearBinarySearch]} {
        set linearBinarySearch false 
    }

    set preambleSize  8

    if {[catch {format %d $lossPercent}]} {
        set lossPercent 0
    }

    if {[catch {$testCmd cget -tolerance} tolerance]} {
        set tolerance   0
    }
     
    set numRxPortsPerStream 1 

    # make txRxArray list of rx-->tx so that we can count the total sent tx-->rx
    isisPerformance::countTxRxFrames txRxArray txNumFrames txRxFrames

    # set the high and low indices for binary search algorithm
    foreach txMap $txPortList {
        scan $txMap "%d %d %d" tx_c tx_l tx_p
   
        set best($tx_c,$tx_l,$tx_p)         0
        set bestTxNumFrames($tx_c,$tx_l,$tx_p) 0
        
        set high($tx_c,$tx_l,$tx_p)             $percentMaxRate($tx_c,$tx_l,$tx_p)
        set low($tx_c,$tx_l,$tx_p)              $lossPercent
    }

    foreach rxMap [getRxPorts txRxArray] {
        scan $rxMap "%d %d %d" rx_c rx_l rx_p
        set txStart($rx_c,$rx_l,$rx_p)      $txRxFrames($rx_c,$rx_l,$rx_p)
        set bestRxNumFrames($rx_c,$rx_l,$rx_p) 0
    }

    set initialDuration [$testCmd cget -duration]
    set doneList    [getTxPorts txRxArray]

    set iteration 1
    # start binary search
    while {[llength $doneList] > 0} {

        set totalRate 0
        foreach txMap [getTxPorts txRxArray] {
            scan $txMap "%d %d %d" tx_c tx_l tx_p
            set totalRate [mpexpr $totalRate+$percentMaxRate($tx_c,$tx_l,$tx_p)]
        }
        set totalRate [format "%3.2f" [mpexpr $totalRate/[llength [getTxPorts txRxArray]]]]

        # setup for transmitting
        logMsg "\n---> BINARY ITERATION $iteration,transmit rate: $totalRate %,$trialStr framesize: $framesize, [$testCmd cget -testName]" 
        debugMsg "\n---> BINARY ITERATION $iteration,transmit rate: $totalRate %,$trialStr framesize: $framesize, [$testCmd cget -testName]" 

        set txRateBelowLimit 0

        if {$linearBinarySearch == "false"} {
            set portList    $doneList

            foreach txMap $portList {
                scan $txMap "%d %d %d" tx_c tx_l tx_p

                if {$framerate($tx_c,$tx_l,$tx_p) < [$testCmd cget -minimumFPS]} {
                    logMsg "\n***> Throughput has fallen below [$testCmd cget -minimumFPS]fps on [getPortId $tx_c $tx_l $tx_p] ***<"
                    set tputRateArray($tx_c,$tx_l,$tx_p) $framerate($tx_c,$tx_l,$tx_p)
                    set indx [lsearch $doneList [list $tx_c $tx_l $tx_p]]
                    if {$indx != -1} {
                        set doneList [lreplace $doneList $indx $indx]
                    }
                }
            }
        } else {
            set portList    [getTxPorts txRxArray]

            foreach txMap $portList {
                scan $txMap "%d %d %d" tx_c tx_l tx_p
                set  flag 0
                if {$framerate($tx_c,$tx_l,$tx_p) < [$testCmd cget -minimumFPS]} {
                    set flag 1
                    break
                }
            }

            if {$flag} {
                logMsg "\n***> Throughput has fallen below [$testCmd cget -minimumFPS]fps on at least one port ***<"
                foreach txMap $portList {
                    scan $txMap "%d %d %d" tx_c tx_l tx_p
                    set tputRateArray($tx_c,$tx_l,$tx_p) $framerate($tx_c,$tx_l,$tx_p)
                    set doneList {}                             
                }
            }

        }

        if {[clearStatsAndTransmit txRxArray [$testCmd cget -duration] "" yes avgRunningRate]} {
            return $::TCL_ERROR
        }

        waitForResidualFrames [$testCmd cget -waitResidual]

        # Poll the Tx counters until all frames are sent
        stats::collectTxStats [getTxPorts txRxArray] txNumFrames txActualFrames totalTxNumFrames
        collectRxStats [getRxPorts txRxArray]  rxNumFrames totalRxNumFrames 
        

#         logMsg "totalRxNumFrames:$totalRxNumFrames"
#
#         foreach item [array names txNumFrames] {
#             logMsg "txNumFrames($item)=$txNumFrames($item)"
#             logMsg "rxNumFrames($item)=$rxNumFrames($item)"
#             if {[mpexpr $txNumFrames($item)-$rxNumFrames($item)]<0} {
#                 logMsg "\nHOPA!"
#                 exit;
#             }
#         }

        ### diplay the result according to the rateSelect option of the testCmd
        array set OLoadArray [array get framerate]
        set OLoadHeaderString OLoad(fps)

        # here display TX rate after each iteration
        logMsg "\nConfigured Transmit Rates used for iteration $iteration"
        logMsg "* Note: DUT Flow Control or Collisions may cause actual TX rate to be lower than Offered Rate"
        set ititle [format "%-12s\t%-12s\t%-10s\t%-10s\t%-10s\t%-10s\t%-12s" "TX" "RX" $OLoadHeaderString "%MaxTxRate" "AvgTxRunRate" "AvgRxRunRate" "%Loss"]
        logMsg $ititle
        logMsg "********************************************************************************************************"

        set oldRxPort " "
        set oldTxPort " "

        foreach txPort [getTxPorts txRxArray] {
            scan $txPort "%d %d %d" tx_c tx_l tx_p

            foreach rxPort $txRxArray($tx_c,$tx_l,$tx_p) {
                scan $rxPort "%d %d %d" rx_c rx_l rx_p          

                set txPortString [getPortString $tx_c $tx_l $tx_p]
                set rxPortString [getPortString $rx_c $rx_l $rx_p]
                set OLoadString $OLoadArray($tx_c,$tx_l,$tx_p)
                set pctPktRateArray [format "%8.4f" $percentMaxRate($tx_c,$tx_l,$tx_p)]
                set txAvgRateString $avgRunningRate(TX,$tx_c,$tx_l,$tx_p)
                set rxAvgRateString $avgRunningRate(RX,$rx_c,$rx_l,$rx_p)
                set percentLoss   [format "%2.2f" [calculatePercentLossExact $txRxFrames($rx_c,$rx_l,$rx_p) $rxNumFrames($rx_c,$rx_l,$rx_p)]]
#                set percentLoss   "$percentLoss TxNum=$txNumFrames($tx_c,$tx_l,$tx_p) TxRxNum=$txRxFrames($rx_c,$rx_l,$rx_p) rxNUM=$rxNumFrames($rx_c,$rx_l,$rx_p)"

                if {$rxPort == $oldRxPort} {
                    set rxPortString " "
                    set rxAvgRateString " "
                } else {
                    set oldRxPort $rxPort           
                }
        
                if {$txPort == $oldTxPort} {
                    set txPortString " "
                    set OLoadString " "
                    set pctPktRateArray " "
                    set txAvgRateString " "
                } else {
                    set oldTxPort $txPort           
                } 

                logMsg [format "%-12s\t%-12s\t%-10s\t%-10s\t%-10s\t%-10s\t%-12s" \
                    $txPortString \
                    $rxPortString \
                    $OLoadString \
                    $pctPktRateArray \
                    $txAvgRateString \
                    $rxAvgRateString \
                    $percentLoss]
           }
        }

        # if one port received zero frames and binayrsearch is linear,to save the iterations data
        # for the csv files we force by setting txRateBelowLimit , because it is the last iteration anyway

        if {$linearBinarySearch == "true"} {
            foreach txMap $portList {
                scan $txMap "%d %d %d" tx_c tx_l tx_p
                foreach rxMap $txRxArray($tx_c,$tx_l,$tx_p) {
                    scan $rxMap "%d %d %d" rx_c rx_l rx_p
                    if {$rxNumFrames($rx_c,$rx_l,$rx_p) == 0} {
                        debugMsg "\nPort $rx_c,$rx_l,$rx_p received zero"
                        set txRateBelowLimit 1
                        break
                    } 
                }
                if { $txRateBelowLimit == 1 } {
                    break
                }
            } ;# for txMap
        }

        isisPerformance::writeIterationData2CSVFile $iteration $testCmd txRxArray framerate tputRateArray \
                                                 txRxFrames totalTxNumFrames rxNumFrames totalRxNumFrames \
                                                 OLoadArray txRateBelowLimit

        logMsg "********************************************************************************************************"

        set settleDown 3
        logMsg "\nWaiting $settleDown sec for the DUT streams to settle down..."
        after [expr $settleDown*1000]



        set warnings ""

        getTransmitTime txRxArray [$testCmd cget -duration] durationArray warnings

        if {$linearBinarySearch == "false"} {
            foreach txMap $portList {
                scan $txMap "%d %d %d" tx_c tx_l tx_p

                set numRxPort [llength $txRxArray($tx_c,$tx_l,$tx_p)]

                if {[port get $tx_c $tx_l $tx_p]} {
                    logMsg "writeIsisPerformanceStreams: port [getPortId $tx_c $tx_l $tx_p] not configured yet!"
                    set retCode $::TCL_ERROR
                }

                set txMode    [port cget -transmitMode]

                set doneFlag($tx_c,$tx_l,$tx_p) done
                foreach rxMap $txRxArray($tx_c,$tx_l,$tx_p) {
                    scan $rxMap "%d %d %d" rx_c rx_l rx_p

                    debugMsg " ********* rxNumFrames($rx_c,$rx_l,$rx_p):$rxNumFrames($rx_c,$rx_l,$rx_p),txRxFrames($rx_c,$rx_l,$rx_p):$txRxFrames($rx_c,$rx_l,$rx_p)"

                    set percentLoss   [calculatePercentLossExact $txRxFrames($rx_c,$rx_l,$rx_p) $rxNumFrames($rx_c,$rx_l,$rx_p)]

                    if {$rxNumFrames($rx_c,$rx_l,$rx_p) == 0} {
                        set status($rx_c,$rx_l,$rx_p)    zero
                        set doneFlag($tx_c,$tx_l,$tx_p)  zero
                        break
                    } elseif {$rxNumFrames($rx_c,$rx_l,$rx_p) == $txStart($rx_c,$rx_l,$rx_p)} {
                        set status($rx_c,$rx_l,$rx_p)    done
                    } elseif {$rxNumFrames($rx_c,$rx_l,$rx_p) != $txRxFrames($rx_c,$rx_l,$rx_p) && ($percentLoss > $tolerance)} {
                        set status($rx_c,$rx_l,$rx_p)    notequal
                        set doneFlag($tx_c,$tx_l,$tx_p)  notequal
                    } else {
                        set status($rx_c,$rx_l,$rx_p)    equal
                        if {$numRxPort == 1} {
                            set doneFlag($tx_c,$tx_l,$tx_p)  equal
                        } elseif {$doneFlag($tx_c,$tx_l,$tx_p) != "notequal"} {
                            set doneFlag($tx_c,$tx_l,$tx_p)  equal
                        }
                    }
                    debugMsg "status($rx_c,$rx_l,$rx_p):$status($rx_c,$rx_l,$rx_p)"
                }
                debugMsg "doneFlag($tx_c,$tx_l,$tx_p): $doneFlag($tx_c,$tx_l,$tx_p)"

                switch $doneFlag($tx_c,$tx_l,$tx_p) {
                    zero {
                        set tputRateArray($tx_c,$tx_l,$tx_p) $framerate($tx_c,$tx_l,$tx_p)
                        set indx [lsearch $doneList [list $tx_c $tx_l $tx_p]]
                        if {$indx != -1} {
                            set doneList [lreplace $doneList $indx $indx]
                        }
                        continue
                    }
                    done {
                        if {$warnings != ""} {
                            logMsg $warnings
                            set warnings ""
                        }
                        set best($tx_c,$tx_l,$tx_p)          $framerate($tx_c,$tx_l,$tx_p)
                        set tputRateArray($tx_c,$tx_l,$tx_p) $framerate($tx_c,$tx_l,$tx_p)

                        set indx [lsearch $doneList [list $tx_c $tx_l $tx_p]]
                        if {$indx != -1} {
                            set doneList [lreplace $doneList $indx $indx]
                        }
                        debugMsg "done: best($tx_c,$tx_l,$tx_p):$best($tx_c,$tx_l,$tx_p), doneList:$doneList"
                    }
                    equal {
                        # up the framerate & normalize it
                        set best($tx_c,$tx_l,$tx_p)           $framerate($tx_c,$tx_l,$tx_p)
                        set low($tx_c,$tx_l,$tx_p)            $percentMaxRate($tx_c,$tx_l,$tx_p)
                        set percentMaxRate($tx_c,$tx_l,$tx_p) [mpexpr ($high($tx_c,$tx_l,$tx_p) + $low($tx_c,$tx_l,$tx_p))/2.00]
                        debugMsg "equal: best($tx_c,$tx_l,$tx_p):$best($tx_c,$tx_l,$tx_p), durationArray($tx_c,$tx_l,$tx_p):$durationArray($tx_c,$tx_l,$tx_p)"
                    }
                    notequal {
                        # lower framerate
                        set high($tx_c,$tx_l,$tx_p)           $percentMaxRate($tx_c,$tx_l,$tx_p)
                        set percentMaxRate($tx_c,$tx_l,$tx_p) [mpexpr ($high($tx_c,$tx_l,$tx_p) + $low($tx_c,$tx_l,$tx_p))/2.00]
                    }
                }
            }
        } else {
            # we need to see totally if there is any port fail, and decide the overalStatus         
            set equalCount      0
            set notequalCount   0
            set overalStatus    done

            foreach txMap $portList {
                scan $txMap "%d %d %d" tx_c tx_l tx_p

                if {[port get $tx_c $tx_l $tx_p]} {
                    logMsg "writeImixTpndrStreams: port [getPortId $tx_c $tx_l $tx_p] not configured yet!"
                    set retCode $::TCL_ERROR
                }

                foreach rxMap $txRxArray($tx_c,$tx_l,$tx_p) {
                    scan $rxMap "%d %d %d" rx_c rx_l rx_p
                    debugMsg ">>>>>> txRxFrames($rx_c,$rx_l,$rx_p):$txRxFrames($rx_c,$rx_l,$rx_p),rxNumFrames($rx_c,$rx_l,$rx_p):$rxNumFrames($rx_c,$rx_l,$rx_p)"
                    set percentLoss   [calculatePercentLossExact $txRxFrames($rx_c,$rx_l,$rx_p) $rxNumFrames($rx_c,$rx_l,$rx_p)]

                    if {$rxNumFrames($rx_c,$rx_l,$rx_p) == 0} {
                        debugMsg ">>>>>> rxNumFrames($rx_c,$rx_l,$rx_p) == 0 "
                        set overalStatus zero
                        break
                    } elseif {$rxNumFrames($rx_c,$rx_l,$rx_p) == $txStart($rx_c,$rx_l,$rx_p)} {
                        debugMsg ">>>>>> rxNumFrames($rx_c,$rx_l,$rx_p) == txStart($rx_c,$rx_l,$rx_p) "
                        # do nothing
                    } elseif {$rxNumFrames($rx_c,$rx_l,$rx_p) != $txRxFrames($rx_c,$rx_l,$rx_p) && ($percentLoss > $tolerance)} {
                        debugMsg ">>>>>> rxNumFrames($rx_c,$rx_l,$rx_p) != txRxFrames($rx_c,$rx_l,$rx_p) && ($percentLoss > $tolerance)) "
                        incr notequalCount
                    } else {
                        debugMsg ">>>>>> equalCount :$equalCount) "
                        incr equalCount
                    }
                }
            }

            if {$overalStatus == "zero"} {
                set doneList {}
            } elseif {$notequalCount > 0} {
                set overalStatus notequal
            } elseif {$equalCount > 0} {
                set overalStatus equal
            } else {
                set overalStatus done
                set doneList {}
            }

            foreach txMap $portList {
                scan $txMap "%d %d %d" tx_c tx_l tx_p

                switch $overalStatus {
                    zero {
                        set tputRateArray($tx_c,$tx_l,$tx_p)    $framerate($tx_c,$tx_l,$tx_p)
                    }
                    done {
                        set best($tx_c,$tx_l,$tx_p)          $framerate($tx_c,$tx_l,$tx_p)
                        set bestTxNumFrames($tx_c,$tx_l,$tx_p) $txActualFrames($tx_c,$tx_l,$tx_p)
                        set bestRxNumFrames($rx_c,$rx_l,$rx_p) $rxNumFrames($rx_c,$rx_l,$rx_p)
                        
                        set tputRateArray($tx_c,$tx_l,$tx_p) $framerate($tx_c,$tx_l,$tx_p)
                    }
                    equal {
                        set best($tx_c,$tx_l,$tx_p)           $framerate($tx_c,$tx_l,$tx_p)
                        set bestTxNumFrames($tx_c,$tx_l,$tx_p) $txActualFrames($tx_c,$tx_l,$tx_p)
                        set bestRxNumFrames($rx_c,$rx_l,$rx_p) $rxNumFrames($rx_c,$rx_l,$rx_p)
                        
                        set low($tx_c,$tx_l,$tx_p)            $percentMaxRate($tx_c,$tx_l,$tx_p)
                        set percentMaxRate($tx_c,$tx_l,$tx_p) [mpexpr ($high($tx_c,$tx_l,$tx_p) + $low($tx_c,$tx_l,$tx_p))/2.]
                    }
                    notequal {
                        # lower framerate
                        set high($tx_c,$tx_l,$tx_p)           $percentMaxRate($tx_c,$tx_l,$tx_p)
                        set percentMaxRate($tx_c,$tx_l,$tx_p) [mpexpr ($high($tx_c,$tx_l,$tx_p) + $low($tx_c,$tx_l,$tx_p))/2.]
                    }
                }
            }
        }
      
        set numberModifier [expr {([isisSuite cget -advertiseRoutes]==1 && [isisSuite cget -advertiseNetworkRange]==1) ? 2 : 1}]

        foreach txMap $doneList {
            scan $txMap "%d %d %d" tx_c tx_l tx_p
            debugMsg "txMap:$txMap"

            set numRxPorts [llength $txRxArray($tx_c,$tx_l,$tx_p)]

            set numStreams [mpexpr $numRxPorts*[isisSuite cget -emulatedRoutersPerPortNumber]*$numberModifier]

            if {[streamUtils::streamGet $tx_c $tx_l $tx_p $numStreams]} {
                errorMsg "Error getting stream [getPortId $tx_c $tx_l $tx_p] $numStreams"
                set retCode $::TCL_ERROR
                continue
            }
    
            # we need to calculate the 'real' percent
            stream config -rateMode           usePercentRate
            stream config -percentPacketRate  $percentMaxRate($tx_c,$tx_l,$tx_p)
               
            if {[streamUtils::streamSet $tx_c $tx_l $tx_p $numStreams]} {
                errorMsg "Error setting stream [getPortId $tx_c $tx_l $tx_p] $numStreams"
                set retCode $::TCL_ERROR
                continue
            }
            set percentMaxRate($tx_c,$tx_l,$tx_p) [stream cget -percentPacketRate]
            set newFramerate($tx_c,$tx_l,$tx_p)   [streamUtils::getStreamFrameRate $tx_c $tx_l $tx_p]

            debugMsg "*** percentMaxRate($tx_c,$tx_l,$tx_p) = $percentMaxRate($tx_c,$tx_l,$tx_p)  newFramerate($tx_c,$tx_l,$tx_p) = $newFramerate($tx_c,$tx_l,$tx_p)"

            set numframes  [stream cget -numFrames]
	    $testCmd config -duration $initialDuration
            set loopcount [mpexpr round (1.*$newFramerate($tx_c,$tx_l,$tx_p) / $numframes / $numStreams * [$testCmd cget -duration])]
            if {$loopcount==0} {
                set loopcount 1
		$testCmd config -duration [mpexpr round(1.0 * $loopcount * $numframes * $numStreams / $newFramerate($tx_c,$tx_l,$tx_p))]
            }

            if {    ($newFramerate($tx_c,$tx_l,$tx_p)   <= $best($tx_c,$tx_l,$tx_p))      || \
                    ($newFramerate($tx_c,$tx_l,$tx_p)   == $framerate($tx_c,$tx_l,$tx_p)) || \
                    ($percentMaxRate($tx_c,$tx_l,$tx_p) >= $high($tx_c,$tx_l,$tx_p))} {
                set tputRateArray($tx_c,$tx_l,$tx_p) $best($tx_c,$tx_l,$tx_p)
                set txActualFrames($tx_c,$tx_l,$tx_p) $bestTxNumFrames($tx_c,$tx_l,$tx_p)
                set rxNumFrames($rx_c,$rx_l,$rx_p) $bestRxNumFrames($rx_c,$rx_l,$rx_p)
                
                set indx [lsearch $doneList [list $tx_c $tx_l $tx_p]]
                if {$indx != -1} {
                    set doneList [lreplace $doneList $indx $indx]
                }
                debugMsg "DONE $tx_c,$tx_l,$tx_p, tputRateArray = $tputRateArray($tx_c,$tx_l,$tx_p)"
                continue
            }

            set framerate($tx_c,$tx_l,$tx_p) $newFramerate($tx_c,$tx_l,$tx_p) 
                     
            set lastStream  0
            set totalNumFrames 0
            #cycle through all the streams & change their gaps
            for {set i 1} {($i <= $numStreams) && (!$lastStream)} {incr i} {
                if {[streamUtils::streamGet $tx_c $tx_l $tx_p $i]} {
                    set lastStream 1
                    continue
                }
                stream config -rateMode          usePercentRate

                stream config -percentPacketRate $percentMaxRate($tx_c,$tx_l,$tx_p)

                stream config -loopCount $loopcount 
                stream config -numFrames $numframes

                #####################################
                ##############
#                 udf get 5
#                 logMsg "STREAM ID $i on TX([getPortId $tx_c $tx_l $tx_p]):"
#                 logMsg "\tudf offset=[udf cget -offset] firstIP=[num2ip [hexlist2Value [udf cget -initval]]] repeat=[udf cget -repeat] step=[udf cget -step]\n"
#                     udf setDefault
#                     udf config -enable          $::true
#                     udf config -offset          $destIpOffset
#                     udf config -countertype     $::c32
#                     udf config -initval         [host2addr $networkIpAddress]
#                     udf config -repeat          [isisSuite cget -routesPerRouterNumber]
#                     udf config -step            [mpexpr 2<<[expr 31 -  [isisSuite cget -routeMaskWidth]]]
                ##############
                #####################################
                
                if {[streamUtils::streamSet $tx_c $tx_l $tx_p $i]} {
                    errorMsg "Error setting stream [getPortId $tx_c $tx_l $tx_p] $i"
                    set retCode $::TCL_ERROR
                    continue
                }
            }
            
            set txNumFrames($tx_c,$tx_l,$tx_p)  [mpexpr $loopcount * $numframes * $numStreams]
            debugMsg "txNumFrames($tx_c,$tx_l,$tx_p):$txNumFrames($tx_c,$tx_l,$tx_p), numframes:$numframes , numStreams:$numStreams"

        }

        if {[llength $doneList] > 0} {
            isisPerformance::countTxRxFrames txRxArray txNumFrames txRxFrames
            if { [writeConfigToHardware txRxArray -noProtocolServer] } {
                errorMsg "Error witting the configuration to the hardware"
                set retCode $::TCL_ERROR
            }

            debugMsg "framerate:   [array get framerate]"
            debugMsg "txNumFrames: [array get txNumFrames]"
            debugMsg "txRxFrames:  [array get txRxFrames]"
        }

        incr iteration
        protocol config -enable802dot1qTag $enable802dot1qTag 
   }

   copyPortList txActualFrames txNumFrames 

    return $retCode
}

#################################################################################
# Procedure: estimateAdvertiseDelay
#
# Description: This command estimate AdvertiseDelay base on number of routes.
# Arguments :
# numRoutes : Number of routes to be advertised. 
#         
# Returned Value :   advertisDelay
#
#################################################################################
proc estimateAdvertiseDelay {numRoutes} \
{   
    set map [map cget -type]

    global ${map}Array

    #The numbers come from "Max update size" and this fact that each update message is 3 packets.
    #It also included number of ACKs.
    set rate    20
    set numPrefixeInPacket 675
    set numPackets 3

    set numRxPorts [llength  [getAllPorts ${map}Array]]
    set numRouters [isisSuite cget -emulatedRoutersPerPortNumber]
    
    set estimatedAdvertiseDelay [expr double ( $numRoutes*$numRxPorts*$numRouters*[isisSuite cget -routeDelay] ) ]
    #Add a fudge factor to estimated delay. (%20 of it)  
    set estimatedAdvertiseDelay [expr $estimatedAdvertiseDelay + ceil (0.2 * $estimatedAdvertiseDelay)]

    return [expr round( $estimatedAdvertiseDelay )]
}

#############################################################################
# isisPerformance::TrialCleanUp()
#
# DESCRIPTION
# This procedure resets common code elements needed at the end of a trial.
#
# RETURNS:  
# status      TCL_OK     - on success
#             TCL_ERROR  - on failure
#
###
proc isisPerformance::TrialCleanUp {} {
    variable status
    variable map
    global ${map}Array

    set status $::TCL_OK

    if { [advancedTestParameter cget -removeStreamsAtCompletion] == "true"} {
        if [removeStreams ${map}Array] {
            errorMsg "Error removing streams."
            set status $::TCL_ERROR
        }
    }
   
    return $status
}

#############################################################################
# isisPerformance::AlgorithmCleanup()
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
proc isisPerformance::AlgorithmCleanUp {} {
    variable status
    variable map
    global ${map}Array

    set status $::TCL_OK
     
    if { [protocolCleanUp ${map}Array isis yes verbose isisSuite] } {
        errorMsg "Error cleaning up the protocols."
        set status $::TCL_ERROR
    }

    return $status;
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
proc isisPerformance::ConfigValidate {} \
{
    variable txRxArray
    variable isisPorts
    set status $::TCL_OK
    set testCmd isisSuite

    set type        [map cget -type]
    global          [format "%sArray" $type] 
    copyPortList    [format "%sArray" $type] txRxArray

    #repeated frame sizes are eliminated from the list if there are any
    configValidation::RemoveDuplicatesFromFramesizeList isisSuite
    
    #validate framesizeList
    if { ![configValidation::ValidateFrameSizeList  isisSuite]} {
        return $::TCL_ERROR
    }

    if {[validateFramesizeList [isisSuite cget -framesizeList]]} {
        logMsg "** ERROR: Some frame sizes are incompatible with selected protocols"
        return -code error 
    }

    #validate initial rate
    if { ![configValidation::ValidateInitialRate isisSuite]} {
        set status $::TCL_ERROR
         return $status
    }

    #common validatation to all the tests
    if {![configValidation::ValidateCommon isisSuite]} {
       set status $::TCL_ERROR
         return $status
    }

    set isisPorts    [getAllPorts txRxArray]

    if {[validateFeatureSet $isisPorts] == $::TCL_ERROR} {
        return $::TCL_ERROR 
    }

    return $status

}

########################################################################################
# Procedure:    isisPerformance::validateFeatureSet
#
# Description:  Verifies that the given ports possess the needed features.
#
# Argument(s):  portList
#
# Results :     TCL_OK or TCL_ERROR
#   
########################################################################################
proc isisPerformance::validateFeatureSet {portList {verbose true}} \
{
    set status $::TCL_OK

    foreach portId $portList {
        scan $portId "%d %d %d" c l p

        if {![port isValidFeature $c $l $p portFeatureRoutingProtocols]} {
            errorMsg [format "Port %s: %s is not valid for interface: %s" \
                     [getPortId $c $l $p] \
                     "Routing Protocols" \
                     [port cget -typeName]]
            set status $::TCL_ERROR
        }

        if {![port isValidFeature $c $l $p portFeatureProtocolISISv6]} {
                errorMsg [format "Port %s: %s is not valid for interface: %s" \
                         [getPortId $c $l $p] \
                         "ISISv6" \
                         [port cget -typeName]]
                set status $::TCL_ERROR
        }
    }

    return $status
}

########################################################################
# Procedure: isisPerformace::writeIterationData2CSVFile
#
# This function calls csvUtils::writeIterationData2CSVFile to write the test 
# iteration data to the result CSV file. 
#
# Arguments(s):
#   iteration           - iteration in which this write to CSV is called
#   testCmd             - name of test command
#   arrayName           - used to distinguish between meshMany2One and meshOne2Many tests, 
#                         which currently share the same namespace
#   TxRxArray           - map, ie. ???
#   Framerate           - array containing the framerates, per port
#   TputRateArray       - array containing the binary search results
#   TxNumFrames         - array containing the number of frames to Tx 
#   TotalTxNumFrames    - total number of frames transmitted
#   RxNumFrames         - array containing the number of frames recv'd
#   TotalRxNumFrames    - total number of frames recv'd
#   OLoadArray          - array of offered load
#   TxRateBelowLimit    - indicate whether TX rate is below limit
#
# Returns:
#     None
#
########################################################################
proc isisPerformance::writeIterationData2CSVFile { iteration testCmd TxRxArray Framerate TputRateArray \
							   TxNumFrames TotalTxNumFrames RxNumFrames TotalRxNumFrames \
							   OLoadArray TxRateBelowLimit } {
     upvar $TxRxArray        txRxArray
     upvar $Framerate        framerate
     upvar $TputRateArray    tputRateArray
     upvar $TxNumFrames      txNumFrames
     upvar $TotalTxNumFrames totalTxNumFrames
     upvar $RxNumFrames      rxNumFrames
     upvar $TotalRxNumFrames totalRxNumFrames
     upvar $OLoadArray       oLoadArray
     upvar $TxRateBelowLimit txRateBelowLimit

     #csvUtils::writeIterationData2CSVFile $iteration $testCmd txRxArray framerate tputRateArray \
        #txNumFrames totalTxNumFrames rxNumFrames totalRxNumFrames oLoadArray txRateBelowLimit
     
     set framesize   [$testCmd cget -framesize]
     if {[catch {$testCmd cget -tolerance} tolerance]} {
         set tolerance   0
     }

     foreach txMap [getTxPorts txRxArray] {
         scan $txMap "%d %d %d" tx_c tx_l tx_p

         set percentPacketRate [getPercentPacketRate $tx_c $tx_l $tx_p]
         if { ($txRateBelowLimit == 0) && ($framerate($tx_c,$tx_l,$tx_p) < [$testCmd cget -minimumFPS])} {
             set txRateBelowLimit 1
         }

         foreach rxMap $txRxArray($tx_c,$tx_l,$tx_p) {
             scan $rxMap "%d %d %d" rx_c rx_l rx_p			

             csvUtils::writeIterationCSVFile $testCmd [list $iteration                       \
                                                           [getPortString $tx_c $tx_l $tx_p] \
                                                           [getPortString $rx_c $rx_l $rx_p] \
                                                           $oLoadArray($tx_c,$tx_l,$tx_p)    \
                                                           $percentPacketRate                \
                                                           $txNumFrames($rx_c,$rx_l,$rx_p)   \
                                                           $rxNumFrames($rx_c,$rx_l,$rx_p)   \
                                                           [mpexpr ($txNumFrames($rx_c,$rx_l,$rx_p) - $rxNumFrames($rx_c,$rx_l,$rx_p))] \
                                                           [mpexpr (($txNumFrames($rx_c,$rx_l,$rx_p) - $rxNumFrames($rx_c,$rx_l,$rx_p)) * 100.0) / $txNumFrames($rx_c,$rx_l,$rx_p)] ]
         }
     }

}

########################################################################
# isisPerformance::WriteResultsCSV()
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
####
proc isisPerformance::WriteResultsCSV {} {
    variable resultsDirectory
    variable trialsPassed
    variable txPortList
    variable rxPortList
    variable resultArray
    global testConf passFail
    variable map
    global ${map}Array

    copyPortList ${map}Array txRxArray

    set dirName $resultsDirectory

    if { [isisSuite cget -framesizeList] == {} } {
        # no new result entry to write
        return
    }

    #################################
    #
    #  Create Result CSV
    #
    #################################

    if {[catch {set csvFid [open $dirName/results.csv w]}]} {
        logMsg "***** WARNING:  Cannot open csv file."
        return
    }

    puts $csvFid "Trial,Frame Size (bytes),Tx Port,Rx Port,Tx Count,No Drop Rate (% Line rate),Tput (fps),System ID,Rx Count,Avg Latency (ns),Min Latency (ns),Max Latency (ns),Data Errors"

    for {set trial 1} {$trial <= [isisSuite cget -numtrials] } {incr trial} {
        foreach framesize [lsort -dictionary [isisSuite cget -framesizeList]] {
             foreach txPort $txPortList {
                 set txFlag([join $txPort ,]) 0
             }
             set streamGroup 0

             foreach txMap [lnumsort [array names txRxArray]] {
                scan $txMap "%d,%d,%d" tx_c tx_l tx_p 

                foreach rxPort $rxPortList {
                    set rxFlag([join $rxPort ,]) 0
                }

                foreach rxMap [lnumsort $txRxArray($txMap)] {
                    scan [join $rxMap] "%d %d %d" rx_c rx_l rx_p

                    set count [lsearch [getAllPorts ${map}Array] $rxMap]

                    for {set router 1} {$router <= [isisSuite cget -emulatedRoutersPerPortNumber]} {incr router} {
                        set byte2 [value2Hexlist $rx_l 1]
                        set byte3 [value2Hexlist $rx_p 1]
                        set byte4 [value2Hexlist $router 1]
                        set rid "00 $byte2 $byte3 $byte4 00 00"
                        set routerGroup [mpexpr $count*[isisSuite cget -emulatedRoutersPerPortNumber]+$router-1]

                        if {$txFlag($tx_c,$tx_l,$tx_p) == 0} {
                            set txPort      [getPortString $tx_c $tx_l $tx_p]
                            set txCount     $resultArray($trial,$framesize,1,$tx_c,$tx_l,$tx_p,TXtransmitFrames)
                            set percentTput $resultArray($trial,$framesize,1,$tx_c,$tx_l,$tx_p,TXpercentTput)
                            set tput        $resultArray($trial,$framesize,1,$tx_c,$tx_l,$tx_p,TXthroughput)
                            set txFlag($tx_c,$tx_l,$tx_p) 1
                        } else {
                            set txPort      "-"
                            set txCount     "-"
                            set percentTput "-"
                            set tput        "-"
                        }

                        if {$rxFlag($rx_c,$rx_l,$rx_p) == 0} {
                            set rxPort     [getPortString $rx_c $rx_l $rx_p]
                            set dataErrors $resultArray($trial,$framesize,1,$rx_c,$rx_l,$rx_p,RXdataError)
                            set rxFlag($rx_c,$rx_l,$rx_p) 1
                        } else {
                            set rxPort     "-"
                            set dataErrors "-"
                        }

                        set groupId [mpexpr ($streamGroup << 8) | $routerGroup]
                        set rxCount     $resultArray($trial,$framesize,1,$groupId,$rx_c,$rx_l,$rx_p,RXreceiveFrames)
                        set minLatency  $resultArray($trial,$framesize,1,$groupId,$rx_c,$rx_l,$rx_p,RXminLatency)
                        set maxLatency  $resultArray($trial,$framesize,1,$groupId,$rx_c,$rx_l,$rx_p,RXmaxLatency)
                        set avgLatency  $resultArray($trial,$framesize,1,$groupId,$rx_c,$rx_l,$rx_p,RXavgLatency)

                        puts $csvFid "$trial,$framesize,$txPort,$rxPort,$txCount,$percentTput,$tput,$rid ,\
                                      $rxCount,$avgLatency,$minLatency,$maxLatency,$dataErrors"
                    }
                }
                incr streamGroup
            }
        }
   }

   closeMyFile $csvFid
}

#############################################################################
# isisPerformance::AlgorithmMeasure()
#
# DESCRIPTION
# This procedure creates and executes streams and other elements needed to 
# measure key traffic metrics through the DUT.
#
# RETURNS:  
# status      TCL_OK     - on success
#             TCL_ERROR  - on failure
#
###
proc isisPerformance::AlgorithmMeasure {} {
    variable trial
    variable framesize
    variable thruputRate;
    variable txNumFrames;
    variable totalTxNumFrames
    variable totalRxNumFrames
    variable maxRate
    variable rxPortList
    variable resultArray
    variable fileIdArray
    variable groupIdList

    variable map
    global ${map}Array

    copyPortList ${map}Array txRxArray

    set status $::TCL_OK;

    set totalLoss           [calculatePercentLoss $totalTxNumFrames	$totalRxNumFrames]
    set totalTput           0
    set totalPercentTput    0

    collectDataIntegrityStats $rxPortList integrityError integrityFrame

    foreach txMap [lsort [array names txRxArray]] {
        scan $txMap "%d,%d,%d" tx_c tx_l tx_p
        set percentTput($tx_c,$tx_l,$tx_p) [format "%6.4f" [mpexpr 1.*$thruputRate($tx_c,$tx_l,$tx_p)*100/$maxRate($tx_c,$tx_l,$tx_p)]]
        mpincr totalTput $thruputRate($tx_c,$tx_l,$tx_p)
        mpincr totalPercentTput $percentTput($tx_c,$tx_l,$tx_p)
    }

    # Packet Group Statistics collected.
    set pgStatistics {totalFrames averageLatency minLatency maxLatency}

    foreach rxMap $rxPortList {
        scan [join $rxMap] "%d %d %d" rx_c rx_l rx_p
        set groupIdList($rx_c,$rx_l,$rx_p) {}
    }

    set streamGroup 0
    foreach txMap [lnumsort [array names txRxArray]] {

        foreach rxPort [lnumsort $txRxArray($txMap)] {
            scan [join $rxPort] "%d %d %d" rx_c rx_l rx_p

            set count [lsearch [getAllPorts ${map}Array] $rxPort]
            for {set router 0} {$router < [isisSuite cget -emulatedRoutersPerPortNumber]} {incr router} {
                set stepToIncrement [mpexpr $count*[isisSuite cget -emulatedRoutersPerPortNumber]+$router]
                lappend groupIdList($rx_c,$rx_l,$rx_p) [mpexpr ($streamGroup << 8) | $stepToIncrement]
            }
        }
        incr streamGroup
    }

    # Collect Packet Group Stats.
    if {[collectPacketGroupStats rxPortList groupIdList $pgStatistics]} {
         errorMsg "Error: Unable to collect packet group statistics"
         set status  $::TCL_ERROR
    }

    if {[startPacketGroups rxPortList]} {
       errorMsg "Error starting packetGroupStats"
    }
    logMsg "Saving results for Trial $trial Framesize $framesize..."

    foreach rxMap $rxPortList {
        scan $rxMap "%d %d %d" rx_c rx_l rx_p
        foreach groupId $groupIdList($rx_c,$rx_l,$rx_p) {
           set resultArray($trial,$framesize,1,$groupId,[join $rxMap ,],RXavgLatency)    $averageLatency($rx_c,$rx_l,$rx_p,$groupId)
           set resultArray($trial,$framesize,1,$groupId,[join $rxMap ,],RXmaxLatency)    $maxLatency($rx_c,$rx_l,$rx_p,$groupId)
           set resultArray($trial,$framesize,1,$groupId,[join $rxMap ,],RXminLatency)    $minLatency($rx_c,$rx_l,$rx_p,$groupId)
           set resultArray($trial,$framesize,1,$groupId,[join $rxMap ,],RXreceiveFrames) $totalFrames($rx_c,$rx_l,$rx_p,$groupId)
        }
        set resultArray($trial,$framesize,1,$rx_c,$rx_l,$rx_p,RXdataError) $integrityError($rx_c,$rx_l,$rx_p)
    }

    foreach txMap [lnumsort [array names txRxArray]] {
        scan $txMap "%d,%d,%d" tx_c tx_l tx_p 
        set resultArray($trial,$framesize,1,$txMap,TXpercentTput) $percentTput($txMap)
        set resultArray($trial,$framesize,1,$txMap,TXthroughput)  $thruputRate($txMap)
    }

    printResults ${map}Array fileIdArray $trial $framesize

    return $status;
}

#############################################################################
# isisPerformance::printResults()
#
# DESCRIPTION
# This procedure serves to codify the major steps/methods that are common 
# to all algorithms.  Further patterns have been identified and collapsed into
# common functions used by appropriate levels within a test when needed.
# It is hoped that this mini-engine can be extracted for use by all algorithms
# in order to enforce identified patterns.
#
# RETURNS:  
# status      TCL_OK     - on success
#             TCL_ERROR  - on failure
###
proc isisPerformance::printResults { TxRxArray FileIdArray trial framesize} {

    variable map
    global ${map}Array
    variable txPortList
    variable rxPortList
    variable resultArray

    upvar $TxRxArray            txRxArray
    upvar $FileIdArray          fileIdArray

    set defaultDelimiter    "  "

    set framesizeRateString "Frame Size: [isisSuite cget -framesize]"

    foreach fileType [array names fileIdArray] {
        foreach {fileID delimiter} $fileIdArray($fileType) {}
    }

    set title [format "%-10s%s%-10s%s%-10s%s%-10s%s%-10s%s%-18s%s%-10s%s%-15s%s%-15s%s%-15s%s%-10s" \
            "Tx Port"	        $delimiter \
            "Rx Port"		$delimiter \
            "Tx Count"		$delimiter \
            "Tput(%)"	        $delimiter \
            "Tput(fps)"         $delimiter \
            "System ID"		$delimiter \
            "Rx Count"	        $delimiter \
            "AvgLatency(ns)"    $delimiter \
            "MinLatency(ns)"    $delimiter \
            "MaxLatency(ns)"    $delimiter \
            "Data Errors" ]

    foreach fileType [array names fileIdArray] {
        foreach {fileID delimiter} $fileIdArray($fileType) {}
        puts $fileID "******* TRIAL $trial, framesize: $framesize - ISIS Performance *******\n\n"
        puts $fileID $title
        puts $fileID [stringRepeat "*" [expr [string length $title] + 10]]
    }

    logMsg "\n$title"
    logMsg "[stringRepeat "*" [expr [string length $title] + 10]]"

    foreach txPort $txPortList {
        set txFlag([join $txPort ,]) 0
    }
    foreach fileType [array names fileIdArray] {
        foreach {fileID delimiter} $fileIdArray($fileType) {}
        set streamGroup 0
        foreach txPort [lnumsort [array names txRxArray]] {
            scan $txPort "%d,%d,%d" tx_c tx_l tx_p 

            foreach rxPort $rxPortList {
                set rxFlag([join $rxPort ,]) 0
            }

            foreach rxPort [lnumsort $txRxArray($txPort)] {
                scan $rxPort "%d %d %d" rx_c rx_l rx_p

                set count [lsearch [getAllPorts txRxArray] $rxPort]

                for {set router 1} {$router <= [isisSuite cget -emulatedRoutersPerPortNumber]} {incr router} {

                    set byte2 [value2Hexlist $rx_l 1]
                    set byte3 [value2Hexlist $rx_p 1]
                    set byte4 [value2Hexlist $router 1]
                    set rid "00 $byte2 $byte3 $byte4 00 00"

                    set routerGroup [mpexpr $count*[isisSuite cget -emulatedRoutersPerPortNumber]+$router-1]
                    if {$txFlag($tx_c,$tx_l,$tx_p) == 0} {
                        set txPort      [getPortString $tx_c $tx_l $tx_p]
                        set txCount     $resultArray($trial,$framesize,1,$tx_c,$tx_l,$tx_p,TXtransmitFrames)
                        set percentTput $resultArray($trial,$framesize,1,$tx_c,$tx_l,$tx_p,TXpercentTput)
                        set tput        $resultArray($trial,$framesize,1,$tx_c,$tx_l,$tx_p,TXthroughput)
                        set txFlag($tx_c,$tx_l,$tx_p) 1
                    } else {
                        set txPort      ""
                        set txCount     ""
                        set percentTput ""
                        set tput        ""
                    }

                    if {$rxFlag($rx_c,$rx_l,$rx_p) == 0} {
                        set rxPort     [getPortString $rx_c $rx_l $rx_p]
                        set dataErrors $resultArray($trial,$framesize,1,$rx_c,$rx_l,$rx_p,RXdataError)
                        set rxFlag($rx_c,$rx_l,$rx_p) 1
                    } else {
                        set rxPort     ""
                        set dataErrors ""
                    }

                    set  groupId [mpexpr ($streamGroup << 8) | $routerGroup]
                    set rxCount     $resultArray($trial,$framesize,1,$groupId,$rx_c,$rx_l,$rx_p,RXreceiveFrames)
                    set minLatency  $resultArray($trial,$framesize,1,$groupId,$rx_c,$rx_l,$rx_p,RXminLatency)
                    set maxLatency  $resultArray($trial,$framesize,1,$groupId,$rx_c,$rx_l,$rx_p,RXmaxLatency)
                    set avgLatency  $resultArray($trial,$framesize,1,$groupId,$rx_c,$rx_l,$rx_p,RXavgLatency)

                    puts $fileID [format "%-10s%s%-10s%s%-10s%s%-10s%s%-10s%s%-18s%s%-10s%s%-15s%s%-15s%s%-15s%s%-10s" \
                        $txPort                                   $delimiter \
                        $rxPort                                   $delimiter \
                        $txCount                                  $delimiter \
                        $percentTput                              $delimiter \
                        $tput                                     $delimiter \
                        $rid                                      $delimiter \
                        $rxCount                                  $delimiter \
                        $avgLatency                               $delimiter \
                        $minLatency                               $delimiter \
                        $maxLatency                               $delimiter \
                        $dataErrors  ]

                } ;# for router
            }
            incr streamGroup
        }
     }


    foreach txPort $txPortList {
        set txFlag([join $txPort ,]) 0
    }
    set streamGroup 0
    foreach txPort [lnumsort [array names txRxArray]] {
        scan $txPort "%d,%d,%d" tx_c tx_l tx_p 
                
        foreach rxPort $rxPortList {
            set rxFlag([join $rxPort ,]) 0
        }

        foreach rxPort [lnumsort $txRxArray($txPort)] {
            scan $rxPort "%d %d %d" rx_c rx_l rx_p

            set count [lsearch [getAllPorts txRxArray] $rxPort]

            for {set router 1} {$router <= [isisSuite cget -emulatedRoutersPerPortNumber]} {incr router} {
                set byte2 [value2Hexlist $rx_l 1]
                set byte3 [value2Hexlist $rx_p 1]
                set byte4 [value2Hexlist $router 1]
                set rid "00 $byte2 $byte3 $byte4 00 00"

                set routerGroup [mpexpr $count*[isisSuite cget -emulatedRoutersPerPortNumber]+$router-1]
                if {$txFlag($tx_c,$tx_l,$tx_p) == 0} {
                    set txPort      [getPortString $tx_c $tx_l $tx_p]
                    set txCount     $resultArray($trial,$framesize,1,$tx_c,$tx_l,$tx_p,TXtransmitFrames)
                    set percentTput $resultArray($trial,$framesize,1,$tx_c,$tx_l,$tx_p,TXpercentTput)
                    set tput        $resultArray($trial,$framesize,1,$tx_c,$tx_l,$tx_p,TXthroughput)
                    set txFlag($tx_c,$tx_l,$tx_p) 1
                } else {
                    set txPort      ""
                    set txCount     ""
                    set percentTput ""
                    set tput        ""
                }

                if {$rxFlag($rx_c,$rx_l,$rx_p) == 0} {
                    set rxPort     [getPortString $rx_c $rx_l $rx_p]
                    set dataErrors $resultArray($trial,$framesize,1,$rx_c,$rx_l,$rx_p,RXdataError)
                    set rxFlag($rx_c,$rx_l,$rx_p) 1
                } else {
                    set rxPort     ""
                    set dataErrors ""
                }

                set groupId     [mpexpr ($streamGroup << 8) | $routerGroup]
                set rxCount     $resultArray($trial,$framesize,1,$groupId,$rx_c,$rx_l,$rx_p,RXreceiveFrames)
                set minLatency  $resultArray($trial,$framesize,1,$groupId,$rx_c,$rx_l,$rx_p,RXminLatency)
                set maxLatency  $resultArray($trial,$framesize,1,$groupId,$rx_c,$rx_l,$rx_p,RXmaxLatency)
                set avgLatency  $resultArray($trial,$framesize,1,$groupId,$rx_c,$rx_l,$rx_p,RXavgLatency)
                logMsg [format "%-10s%s%-10s%s%-10s%s%-10s%s%-10s%s%-18s%s%-10s%s%-15s%s%-15s%s%-15s%s%-10s" \
                        $txPort                                   $delimiter \
                        $rxPort                                   $delimiter \
                        $txCount                                  $delimiter \
                        $percentTput                              $delimiter \
                        $tput                                     $delimiter \
                        $rid                                      $delimiter \
                        $rxCount                                  $delimiter \
                        $avgLatency                               $delimiter \
                        $minLatency                               $delimiter \
                        $maxLatency                               $delimiter \
                        $dataErrors  ]
            }
        }
        incr streamGroup
    }

    foreach fileType [array names fileIdArray] {
        foreach {fileID delimiter} $fileIdArray($fileType) {}
        puts $fileID [stringRepeat "*" [expr [string length $title] + 10]]
        puts $fileID "\n"
    }

}
#############################################################################
# isisPerformance::MetricsPostProcess()
#
# DESCRIPTION:
# This procedure walks moves data from XML file (created by results API) to
# the resultArray which can be used by all interested methods such as 
# Pass/Fail, CSV, etc.  This method will also calculate second order metrics
# like averages and maximums if not calculated within the algorithm body itself.
# All metrics should be stored in the resultArray so there is consistent usage
# of metrics by all other methods that follow. 
#
# ARGS:
# none
#
# RETURNS:
# status      TCL_OK     - on success
#             TCL_ERROR  - on failure
#
###
proc isisPerformance::MetricsPostProcess {} {
    variable resultsDirectory;
    variable resultArray
    variable rxPortList
    variable txPortList
    variable groupIdList
    global testConf;

    set trialsPassed  0

    for {set trial 1} {$trial <= [isisSuite cget -numtrials] } {incr trial} {

	set percentLineRateList {};
	set frameRateList {};
	set dataRateList {};
	set avgLatencyList {};
	set maxLatencyList {};

	foreach fs [lsort -dictionary [isisSuite cget -framesizeList]] {

		foreach txMap $txPortList {
		    scan $txMap "%d %d %d" tx_c tx_l tx_p

		    lappend percentLineRateList \
			$resultArray($trial,$fs,1,$tx_c,$tx_l,$tx_p,TXpercentTput);

		    set frameRate $resultArray($trial,$fs,1,$tx_c,$tx_l,$tx_p,TXthroughput);

		    lappend frameRateList $frameRate;

		    set dataRate  [mpexpr 8 * $fs * $frameRate];

		    lappend dataRateList $dataRate;
		};# loop over txPort list

		foreach rxMap $rxPortList {
		    scan $rxMap "%d %d %d" rx_c rx_l rx_p
		    foreach groupId $groupIdList($rx_c,$rx_l,$rx_p) {
			lappend avgLatencyList \
			    $resultArray($trial,$fs,1,$groupId,$rx_c,$rx_l,$rx_p,RXavgLatency);
			
			lappend maxLatencyList \
			    $resultArray($trial,$fs,1,$groupId,$rx_c,$rx_l,$rx_p,RXmaxLatency);
		    }
		} ;# loop over rxPort list
	} ;# loop over frame size

	# Minimum % Line Rate is the smallest throughput percentage of any port pair 
	# across any frame sizes for a given trial.
	set resultArray($trial,minPercentLineRate) [passfail::ListMin percentLineRateList];

	# Average % Line Rate is an average throughput percentage across any frame 
	# sizes and all ports for a given trial
	set resultArray($trial,avgPercentLineRate) [passfail::ListMean percentLineRateList];

	# Minimum Data Rate is the smallest absolute bit rate of any port pair across any 
	# frame sizes for a given trial. Data Rate is computed in bits/sec
	set resultArray($trial,minDataRate) [passfail::ListMin dataRateList];

	# Average Data Rate is an average absolute bit rate across any frame sizes and 
	# all ports for a given trial
	set resultArray($trial,avgDataRate) [passfail::ListMean dataRateList];

	# Minimum Frame Rate is the smallest frame rate of any port pair across any 
	# frame sizes for a given trial. Data Rate is computed in bits/sec
	set resultArray($trial,minFrameRate) [passfail::ListMin frameRateList];

	# Average Frame Rate is an average frame rate across any frame sizes and 
	# all ports for a given trial
	set resultArray($trial,avgFrameRate) [passfail::ListMean dataRateList]

	if {[lsearch $avgLatencyList "notCalculated"] >= 0} {
	    set resultArray($trial,avgLatency) "notCalculated";
	    set resultArray($trial,maxLatency) "notCalculated";
	} else {
	    # Maximum Latency is the largest latency of any port pair
	    # across any frame sizes for a given trial
	    set resultArray($trial,maxLatency) [passfail::ListMax maxLatencyList];
	    
	    # Average Latency is the average latency of any port pair
	    # across any frame sizes for a given trial
	    set resultArray($trial,avgLatency) [passfail::ListMean avgLatencyList];
	}
	
    } ;# loop over trials
}

########################################################################
# Procedure: isisPerformance::countTxRxFrames
#
# This command returns an array w/containing total frames transmitted 
# to each rx port
#
# Argument(s):
#       RxTxArray      -list of ports, ie, one2oneArray, one2manyArray etc
#       TxNumFrames    -array of frames to transmit from tx ports
#       TxRxNumFrames  -array of total frames transmitted to this rx port
#
########################################################################
proc isisPerformance::countTxRxFrames {TxRxArray TxNumFrames TxRxNumFrames} {
    upvar $TxRxArray        txRxArray
    upvar $TxNumFrames      txNumFrames
    upvar $TxRxNumFrames    txRxNumFrames

    set status $::TCL_OK

    if [info exists txRxNumFrames] {
        unset txRxNumFrames
    }

    set numberModifier [expr {([isisSuite cget -advertiseRoutes]==1 && [isisSuite cget -advertiseNetworkRange]==1) ? 2 : 1}]

    foreach txMap [array names txRxArray] {
        scan $txMap "%d,%d,%d" tx_c tx_l tx_p

        set numRxPorts  [llength $txRxArray($tx_c,$tx_l,$tx_p)]
        set numStreams  [mpexpr $numRxPorts*[isisSuite cget -emulatedRoutersPerPortNumber]*$numberModifier]

        if {[streamUtils::streamGet $tx_c $tx_l $tx_p $numStreams]} {
            errorMsg "Error getting stream $numStreams on [getPortId $tx_c $tx_l $tx_p]"
            set status 1
        }

        set loopcount   [stream cget -loopCount]
        set streamID 1

        foreach rxMap $txRxArray($tx_c,$tx_l,$tx_p) {
            scan [join $rxMap] "%d %d %d" rx_c rx_l rx_p

            for {set count 1} {$count <= [mpexpr [isisSuite cget -emulatedRoutersPerPortNumber]*$numberModifier] } {incr count} {
                if {[streamUtils::streamGet $tx_c $tx_l $tx_p $streamID]} {
                    errorMsg "Error getting stream $streamID on [getPortId $tx_c $tx_l $tx_p]"
                    set status 1
                }

                incr streamID
                set numFrames   [stream cget -numFrames]
                if {[info exists txRxNumFrames($rx_c,$rx_l,$rx_p)]} {
                    set txRxNumFrames($rx_c,$rx_l,$rx_p)  [mpexpr $txRxNumFrames($rx_c,$rx_l,$rx_p)+($loopcount*$numFrames)]
                } else {
                    set txRxNumFrames($rx_c,$rx_l,$rx_p)  [mpexpr $loopcount*$numFrames]
                }
#                logMsg "txRxNumFrames($rx_c,$rx_l,$rx_p)=$txRxNumFrames($rx_c,$rx_l,$rx_p) loop=$loopcount numFrames=$numFrames streamID=$streamID"
            }
        }

    }
    return $status
}

########################################################################
# isisPerformance::WriteAggregateResultsCSV()
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
proc isisPerformance::WriteAggregateResultsCSV {} {
    variable resultsDirectory;
    variable txPortList
    variable rxPortList
    variable resultArray
    global testConf passFail
    variable map
    global ${map}Array

    copyPortList ${map}Array txRxArray
    set dirName $resultsDirectory;

    
    #################################
    #
    #  Create Aggregate Result CSV
    #
    #################################

    if {[catch {set csvFid [open $dirName/AggregateResults.csv w]}]} {
	logMsg "***** WARNING:  Cannot open AggregateResults.csv file."
	return
    }

    set numIteraions 1

    set colHeads   {  "Trial"                    
	    "Frame Size"     
            "Agg Tx Count"
            "Agg Rx Count"
	    "Agg Tput (fps)"
	    "Agg Tput Rate (%)"
	    "Agg Average Latency (ns)"
	    "Agg Min Latency (ns)"
	    "Agg Max Latency (ns)"
	    "Agg Data Error"
    }
    
    puts $csvFid [join $colHeads ,]

    foreach framesize [lsort -dictionary [isisSuite cget -framesizeList]] {
	    for {set trial 1} {$trial <= [isisSuite cget -numtrials] } {incr trial} {
	        set fpsList {};
		set rateList {};
                set txCountList {};
                set rxCountList {};
		set aggMinLatencyList {};
		set aggMaxLatencyList {};
		set aggAvgLatencyList {};
		set aggDataErrorList {};
		set streamGroup 0
		
		foreach txPort [lnumsort [array names txRxArray]] {
		    scan $txPort "%d,%d,%d" tx_c tx_l tx_p 

                    lappend txCountList $resultArray($trial,$framesize,1,$tx_c,$tx_l,$tx_p,TXtransmitFrames) 
		    lappend fpsList $resultArray($trial,$framesize,1,$txPort,TXthroughput)
		    lappend rateList $resultArray($trial,$framesize,1,$txPort,TXpercentTput)


			    foreach rxMap [lnumsort $txRxArray($txPort)] {
				    scan [join $rxMap] "%d %d %d" rx_c rx_l rx_p

				    set count [lsearch [getAllPorts ${map}Array] $rxMap]

                    for {set router 1} {$router <= [isisSuite cget -emulatedRoutersPerPortNumber]} {incr router} {
                        set routerGroup [mpexpr $count*[isisSuite cget -emulatedRoutersPerPortNumber]+$router-1]

			set groupId [mpexpr ($streamGroup << 8) | $routerGroup]

                        lappend rxCountList $resultArray($trial,$framesize,1,$groupId,$rx_c,$rx_l,$rx_p,RXreceiveFrames)
			lappend aggMinLatencyList $resultArray($trial,$framesize,1,$groupId,$rx_c,$rx_l,$rx_p,RXminLatency) 
			lappend aggMaxLatencyList $resultArray($trial,$framesize,1,$groupId,$rx_c,$rx_l,$rx_p,RXmaxLatency)
			lappend aggAvgLatencyList $resultArray($trial,$framesize,1,$groupId,$rx_c,$rx_l,$rx_p,RXavgLatency) 
			lappend aggDataErrorList $resultArray($trial,$framesize,1,$rx_c,$rx_l,$rx_p,RXdataError)

		    }
	        }
	        incr streamGroup
	    }

	    set aggFps [passfail::ListSum fpsList]; 
            set aggTxCount [passfail::ListSum txCountList];
            set aggRxCount [passfail::ListSum rxCountList]
	    set aggRate [passfail::ListMean rateList];
		    if {[lsearch $aggAvgLatencyList "notCalculated"] >= 0} {
		        set aggMinLatency "notCalculated";
		        set aggMaxLatency "notCalculated";
		        set aggAvgLatency "notCalculated";
		    } else {
		        set aggMinLatency [passfail::ListMin aggMinLatencyList]
		        set aggMaxLatency [passfail::ListMax aggMaxLatencyList]
		        set aggAvgLatency [passfail::ListMean aggAvgLatencyList]
		    }

		    set aggDataError [passfail::ListSum aggDataErrorList]    
		    puts $csvFid "$trial,$framesize,$aggTxCount,$aggRxCount,$aggFps,$aggRate,$aggAvgLatency,$aggMinLatency,$aggMaxLatency,$aggDataError"	
		}	
    }

    close $csvFid
}

################################################################################
#
# isisPerformance::PassFailCriteriaEvaluateConvergence()
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
proc isisPerformance::PassFailCriteriaEvaluate {} {
    variable trialsPassed;
    variable resultArray
    global testConf;

    logMsg "***************************************";
    logMsg "*** PASS Criteria Evaluation\n";
    if {[info exists testConf(passFailEnable)] == 0} {
    # maintain backwards compatiblity with scripts without pass/fail
        set trialsPassed "N/A";
        logMsg "*** # Of Trials Passed: $trialsPassed";
        logMsg "***************************************";
        return;
    }

    if {!$testConf(passFailEnable)} {
        # Pass/Fail Criteria disabled implies N/A
        set trialsPassed "N/A";
        logMsg "*** # Of Trials Passed: $trialsPassed";
        logMsg "***************************************";
        return;
    } 

    set trialsPassed 0;

    for {set trial 1} {$trial <= [isisSuite cget -numtrials] } {incr trial} {
        logMsg "*** Trial #$trial";
        set avgPercentLineRate $resultArray($trial,avgPercentLineRate);
        set minPercentLineRate $resultArray($trial,minPercentLineRate);
        set avgDataRate $resultArray($trial,avgDataRate);
        set minDataRate $resultArray($trial,minDataRate);
        set avgFrameRate $resultArray($trial,avgFrameRate);
        set minFrameRate $resultArray($trial,minFrameRate);

        # Pass/Fail Criteria is based on the logical AND of two criteria
        set throughputResult [passfail::PassFailCriteriaThroughputEvaluate \
                              $avgPercentLineRate $minPercentLineRate \
                              $avgDataRate $minDataRate "N/A" \
                              $avgFrameRate $minFrameRate];

        set avgLatency $resultArray($trial,avgLatency);
        set maxLatency $resultArray($trial,maxLatency);

        set latencyResult [passfail::PassFailCriteriaLatencyEvaluate \
                          $avgLatency $maxLatency];

        if { ($throughputResult == "PASS") && ($latencyResult == "PASS")} {
            set result "PASS"
        } else {
            set result "FAIL";
        }

        if { $result == "PASS" } {
            incr trialsPassed
        }

        logMsg "*** $result\n";
    } ;# loop over trials

    logMsg "*** # Of Trials Passed: $trialsPassed";
    logMsg "***************************************"
}

################################################################################
# isisPerformance::getNetRangeCount
#
# This command returns a value equals with the number of routes advertised by
# the ISIS network range mode on the DUT.
#
# Argument(s):
#       rows      -the number of the rows in the matrix
#       columns   -the number of the columns in the matrix
#
########################################################################
proc isisPerformance::getNetRangeCount {x y} {
    return [expr ($x!=1 && $y!=1) ? [expr 2*$x*$y-$x-$y+1] : [expr  $x*$y]]
}

################################################################################
#
# isisPerformance::ThroughputThresholdToggle(args)
#
# DESCRIPTION:
# This procedure Disables and enables the widgets for data / line criteria 
# depending of the state of the radio button 
#
# ARGUMENTS
# args       - variable arguments
#
# RETURNS
# none
#
###
proc isisPerformance::ThroughputThresholdToggle {args} {
    global passFailMode;

    if {$passFailMode == "data"} {
	set lineState disabled;
	set dataState enabled;
    } else {
	set lineState enabled;
	set dataState disabled;
    }

    set lineAttributeList {
	lineThresholdValue
	lineThresholdMode
    }
    renderEngine::WidgetListStateSet $lineAttributeList $lineState;

    set dataAttributeList {
	dataThresholdValue
	dataThresholdScale
	dataThresholdMode
    }
    renderEngine::WidgetListStateSet $dataAttributeList $dataState;
}

########################################################################################
# Procedure:    isisPerformance::OnEnable802dot1qTagChangeCmd
#
# Description:  Widget command for enable 802dot1qTag
#
# Argument(s):  None
#
# Returns:      None
########################################################################################
proc isisPerformance::OnEnable802dot1qTagChange {parent propName args} {
    global enable802dot1qTag

    set state disabled;

    if {$enable802dot1qTag} {
        set state enabled;          
        set attributeList {firstVlanID incrementVlanID}
        renderEngine::WidgetListStateSet $attributeList $state;
    } else {
        set attributeList {firstVlanID incrementVlanID}
        renderEngine::WidgetListStateSet $attributeList $state;
    }

}

########################################################################################
# Procedure:    isisPerformance::emulatedRoutersUpdate
#
# Description:  Widget command for Emulated Routers Number Update
#
# Argument(s):  None
#
# Returns:      None
########################################################################################
proc isisPerformance::emulatedRoutersUpdate {parent propName args} {
    global emulatedRoutersPerPortNumber

    set emulatedRoutersPerPortNumber [[$parent.emulatedRoutersPerPortNumber subwidget entry] get]
    testConfig::setTestConfItem vlansPerPort $emulatedRoutersPerPortNumber
}

########################################################################################
# Procedure:    isisPerformance::enableAdvertiseRoutesCmd
#
# Description:  Widget command for Advertise Routes
#
# Argument(s):  None
#
# Returns:      None
########################################################################################
proc isisPerformance::enableAdvertiseRoutesCmd {parent propName args} {
     global advertiseRoutes
     set state disabled;

     if {$advertiseRoutes} {
         set state enabled;
         set attributeList {routesPerRouterNumber firstRoute routeMaskWidth incrPerRouter routeOrigin}
         renderEngine::WidgetListStateSet $attributeList $state;
     } else {
         set attributeList {routesPerRouterNumber firstRoute routeMaskWidth incrPerRouter routeOrigin}
         renderEngine::WidgetListStateSet $attributeList $state;
     }

}

########################################################################################
# Procedure:    isisPerformance::enableAdvertiseNetRangeCmd
#
# Description:  Widget command for Advertise Network Range
#
# Argument(s):  None
#
# Returns:      None
########################################################################################
proc isisPerformance::enableAdvertiseNetRangeCmd {parent propName args} {
     global advertiseNetworkRange

     set state disabled;

     if {$advertiseNetworkRange} {
         set state enabled;
         set attributeList {rowsNumber columnsNumber firstSubnet subnetMaskWidth}
         renderEngine::WidgetListStateSet $attributeList $state;
     } else {
         set attributeList {rowsNumber columnsNumber firstSubnet subnetMaskWidth}
         renderEngine::WidgetListStateSet $attributeList $state;
     }

}

########################################################################################
# Procedure:    isisPerformance::enableValidateMtuCmd
#
# Description:  Widget command for Validate MTU widget
#
# Argument(s):  None
#
# Returns:      None
########################################################################################
proc isisPerformance::enableValidateMtuCmd {parent propName args} {
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

################################################################################
#
# isisPerformance::PassFailEnable(args)
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
proc isisPerformance::PassFailEnable {args} {
    global passFailEnable;
    global passFailMode;

    set state disabled;

    if {$passFailEnable} {

	set state enabled;
	set attributeList {
            thresholdMode
            latencyLabel
            latencyValue
            latencyThresholdScale
            latencyThresholdMode
	}
        if {$passFailMode == "data"} {
            lappend attributeList dataThresholdValue
            lappend attributeList dataThresholdScale
            lappend attributeList dataThresholdMode
        } else {
            lappend attributeList lineThresholdValue
            lappend attributeList lineThresholdMode
        }

	renderEngine::WidgetListStateSet $attributeList $state;

    } else {
	set attributeList {
            thresholdMode
            lineThresholdValue
            lineThresholdMode
            dataThresholdValue
            dataThresholdScale
            dataThresholdMode
            latencyLabel
            latencyValue
            latencyThresholdScale
            latencyThresholdMode
	}
	renderEngine::WidgetListStateSet $attributeList $state;
    }
}

################################################################################
#
# isisPerformance::OnEnable802dot1qTagInit(args)
#
# DESCRIPTION:
# This procedure Disables and enables the widgets for the Tags, VlanId and
# IncrementVlanID depending of the state of Enable802.1q checkbox
#
# ARGUMENTS
# args       - variable arguments
#
# RETURNS
# none
#
###
proc isisPerformance::OnEnable802dot1qTagInit {args} {
    global enable802dot1qTag;

    set enable802dot1qTag [testConfig::getTestConfItem enable802dot1qTag]

    switch $enable802dot1qTag {
	"true" {
        if {[testConfig::getTestConfItem autoMapGeneration] == "no"} {
            set attributeDisabledList {
	            firstVlanID
	            incrementVlanID
	    }
            set attributeEnabledList {
                vlanWarningLabel2
                vlanWarningLabel1
	    }
        } else {
	        set attributeEnabledList {
		    firstVlanID
		    incrementVlanID
                    vlanWarningLabel1
	        }
                set attributeDisabledList {
                    vlanWarningLabel2
                }
            }
	}
	"false" {
		set attributeDisabledList {
		    firstVlanID
		    incrementVlanID
                    vlanWarningLabel2
                    vlanWarningLabel1
		}
		set attributeEnabledList {};
	}
    }

    renderEngine::WidgetListStateSet $attributeDisabledList disabled;
    renderEngine::WidgetListStateSet $attributeEnabledList  enabled;

}


################################################################################
#
# isisPerformance::OnEnable802dot1qTagChange(args)
#
# DESCRIPTION:
# This procedure Disables and enables the widgets for the Tags, VlanId and
# IncrementVlanID depending of the state of Enable802.1q checkbox
#
# ARGUMENTS
# args       - variable arguments
#
# RETURNS
# none
#
###
proc isisPerformance::OnEnable802dot1qTagChange {args} {
    global enable802dot1qTag;
    global enableISLtag;
    
    switch $enable802dot1qTag {
	"true" {
        if {[testConfig::getTestConfItem autoMapGeneration] == "no"} {
            set attributeDisabledList {}	            	        
            set attributeEnabledList {
                firstVlanID
	        incrementVlanID
                vlanWarningLabel2
                vlanWarningLabel1
	        }
        } else {
	        set attributeEnabledList {
		    firstVlanID
		    incrementVlanID
                    vlanWarningLabel1
	        }
                set attributeDisabledList {
                    vlanWarningLabel2
                }
            }
	}
	"false" {
		set attributeDisabledList {
		    firstVlanID
		    incrementVlanID
            vlanWarningLabel2
            vlanWarningLabel1
		}
		set attributeEnabledList {};
	}
    }
    set ::testConf(enable802dot1qTag) $enable802dot1qTag
    renderEngine::WidgetListStateSet $attributeDisabledList disabled;
    renderEngine::WidgetListStateSet $attributeEnabledList  enabled;

}

################################################################################
#
# isisPerformance::OnTrafficMapSet(protocol)
#
# DESCRIPTION:
# This procedure enables/disables the First VLAN and Increment VLAN in VLAN portion 
# of test tab based on change in map type in traffic map portion of traffic tab
#
# ARGUMENTS
# map     -  map type selected in map widget
#
# RETURNS
# none
#
###
proc isisPerformance::OnTrafficMapSet {map} {
    global enable802dot1qTag

    set enable802dot1qTag [testConfig::getTestConfItem enable802dot1qTag]

    if {$map == "Automatic" && $enable802dot1qTag == "true"} {
            set attributeEnabledList {
	            firstVlanID
		        incrementVlanID
                vlanWarningLabel1
	        }
            set attributeDisabledList {
                vlanWarningLabel2
            }
    } elseif {$map == "Manual" && $enable802dot1qTag == "true"} {
		set attributeDisabledList {}		    	
		set attributeEnabledList {
                    firstVlanID
		    incrementVlanID
                    vlanWarningLabel2
                    vlanWarningLabel1
                }
	} else {
        set attributeDisabledList {
	            firstVlanID
		        incrementVlanID
                vlanWarningLabel2
                vlanWarningLabel1
	        }
        set attributeEnabledList {}
    }

    renderEngine::WidgetListStateSet $attributeDisabledList disabled;
    renderEngine::WidgetListStateSet $attributeEnabledList  enabled;

    smProtocol::setenableGTWIPIncrement
    smProtocol::setenableGTWIPv6Increment
}

################################################################################
#
# isisPerformance::OnProtocolSet(protocol)
#
# DESCRIPTION:
# This procedure updates the first route address and increment by field for routers and route
# based on change in protocol version in frame data portion of traffic tab
#
# ARGUMENTS
# protocol     -  protocol selected in frame data widget
#
# RETURNS
# none
#
###
proc isisPerformance::OnProtocolSet {protocol} {

    global firstRoute
    global firstSubnet
    global incrPerRouter
    global isisParamsInvisibleFrameName
    global testConf
    global ipSrcIncrm

    foreach propName {firstRoute firstSubnet incrPerRouter ipSrcIncrm} {
        switch $propName {
            "firstRoute" -
            default
            {
                set ipAddress "192.168.1.0"
                set ipV6Address "2000::0"
            }
            "firstSubnet"
            {
                set ipAddress   "192.20.20.0"
                set ipV6Address "2001::0"
            }
            "incrPerRouter"
            {
                set ipAddress "0.1.0.0"
                set ipV6Address "0:0:1:0:0:0:0:0"
            }
            "ipSrcIncrm"
            {
                set ipAddress "0.0.0.1"
                set ipV6Address "0:0:0:0:0:0:0:1"
            }

        }

        if {[string tolower [testConfig::getTestConfItem protocolName]] == "ipv6"} {
                 if {$propName == "ipSrcIncrm"} {
                     set $propName $testConf(ipV6SrcIncr)
                 }
        } else {
                 if {$propName == "ipSrcIncrm"} {
                     set $propName $testConf(ipSrcIncr)
                 }
        }

        if {[string tolower [testConfig::getTestConfItem protocolName]] == "ipv6"} {  
	        if {[ipv6::isValidAddress [set $propName]] == 0} {
	            set validAddress $ipV6Address
	        } else {
	            set validAddress [set $propName]
	        }
	    } else {
                 if {$propName == "incrPerRouter" || $propName == "ipSrcIncrm"} {
                    if {[isIpAddressValid [set $propName]] == 0} {
                       set validAddress $ipAddress
                    } else {
                       set validAddress [set $propName]
                    }
                 } else {
                    if {[dataValidation::isValidUnicastIp [set $propName]] == 0} {
                       set validAddress $ipAddress
                    } else {
                       set validAddress [set $propName]
                    }
                 }
	    }

        set $propName $validAddress
        isisSuite config -$propName [set $propName]

        set entryBox [$isisParamsInvisibleFrameName.$propName subwidget entry];

                 if {[string tolower [testConfig::getTestConfItem protocolName]] == "ipv6"} {
                    set width 20
                    if { $propName == "ipSrcIncrm" } {
                         bind $entryBox <FocusOut>   {
                              checkIpAddress %W 0 ipV6 unicast
                              isisPerformance::OnIncrmChange %W "ipV6"
                              } 
                         bind $entryBox <KeyRelease> {
                              checkIpAddress %W 0 ipV6 unicast
                              isisPerformance::OnIncrmChange %W "ipV6"
                         }
                    } else {
                         bind $entryBox <FocusOut>   {
                              checkIpAddress %W 0 ipV6 unicast
                              } 
                         bind $entryBox <KeyRelease> {
                              checkIpAddress %W 0 ipV6 unicast
                         }                 
                    }
                 } else {
                    set width 14
                    if { $propName == "ipSrcIncrm" } {
                         bind $entryBox <FocusOut>   {
                              checkIpAddress %W 0 ipV4 unicast
                              isisPerformance::OnIncrmChange %W "ipV4"
                         }
                         bind $entryBox <KeyRelease> {
                              checkIpAddress %W 0 ipV4 unicast
                              isisPerformance::OnIncrmChange %W "ipV4"
                         } 
                     } else {
                              bind $entryBox <FocusOut>   {
                                  checkIpAddress %W 0 ipV4 unicast
                              }
                              bind $entryBox <KeyRelease> { checkIpAddress %W 0 ipV4 unicast} 
                     }
                 }
        $entryBox config -width $width
    }  ; # foreach

    if {[string tolower [testConfig::getTestConfItem protocolName]] == "ipv6"} {
        $isisParamsInvisibleFrameName.routeMaskWidth  config -max 128 
        $isisParamsInvisibleFrameName.subnetMaskWidth config -max 128 
        if {[$isisParamsInvisibleFrameName.routeMaskWidth cget -value] < 64} {
            $isisParamsInvisibleFrameName.routeMaskWidth config -value 64
        }
        if {[$isisParamsInvisibleFrameName.subnetMaskWidth cget -value] < 64} {
            $isisParamsInvisibleFrameName.subnetMaskWidth config -value 64
        }
    } else {
        $isisParamsInvisibleFrameName.routeMaskWidth  config -max 32
        $isisParamsInvisibleFrameName.subnetMaskWidth config -max 32 
        if {[$isisParamsInvisibleFrameName.routeMaskWidth cget -value] > 32} {
           $isisParamsInvisibleFrameName.routeMaskWidth config -value 24
        }
        if {[$isisParamsInvisibleFrameName.subnetMaskWidth cget -value] > 32} {
           $isisParamsInvisibleFrameName.subnetMaskWidth config -value 24
        }
    }
}

################################################################################
# isisPerformance::OnValidAddressInit(parent propName args)
#
# DESCRIPTION:
# This ON_INIT procedure makes sure a valid IP address is diplayed for 
# IPV4 or IPV6 for First Route,Increment Across Routers and Increment Across Routes
#
# ARGUMENTS
# parent   -   parent of this widget
# propName -   name of this widget
# args     -   variable arguments
#
# RETURNS
# none
#
###
proc isisPerformance::OnValidAddressInit {parent propName args} {
    global testConf testCmd
    set entryBox [$parent.$propName subwidget entry];

    switch $propName {
        "firstRoute" -
        default
        {
            set ipAddress   "192.168.1.0"
            set ipV6Address "2000::0"
        }
        "firstSubnet"
        {
            set ipAddress   "192.20.20.0"
            set ipV6Address "2001::0"
        }
        "incrPerRouter"
        {
            set ipAddress   "0.1.0.0"
            set ipV6Address "0:0:1:0:0:0:0:0"
        }
	"ipSrcIncrm"
        {
                 set ipAddress "0.0.0.1"
                 set ipV6Address "0:0:0:0:0:0:0:1"
        }
    }

    if {[string tolower [testConfig::getTestConfItem protocolName]] == "ipv6"} {  
		if {[ipv6::isValidAddress [$entryBox get]] == 0} {
			set validAddress $ipV6Address
		} else {
			set validAddress [$entryBox get]
		}
	} else {
           if { $propName == "ipSrcIncrm" || $propName == "incrPerRouter"} {
		if {[isIpAddressValid [$entryBox get]] == 0} {
			set validAddress $ipAddress
		} else {
			set validAddress [$entryBox get]
		}
           } else {
		if {[dataValidation::isValidUnicastIp [$entryBox get]] == 0} {
			set validAddress $ipAddress
		} else {
			set validAddress [$entryBox get]
		}
           }
	}

    $entryBox delete 0 end
    $entryBox insert 0 $validAddress

    if {[string tolower [testConfig::getTestConfItem protocolName]] == "ipv6"} {
       if { $propName == "ipSrcIncrm" } {
	    bind $entryBox <FocusOut>   {
                 checkIpAddress %W 0 ipV6 unicast
                 isisPerformance::OnIncrmChange %W "ipV6"
                 } 
	    bind $entryBox <KeyRelease> {
                 checkIpAddress %W 0 ipV6 unicast
                 isisPerformance::OnIncrmChange %W "ipV6"
            }
       } else {
	    bind $entryBox <FocusOut>   {
                 checkIpAddress %W 0 ipV6 unicast
                 } 
	    bind $entryBox <KeyRelease> {
                 checkIpAddress %W 0 ipV6 unicast
            }                 
       }
    } else {
       if { $propName == "ipSrcIncrm" } {
	    bind $entryBox <FocusOut>   {
                 checkIpAddress %W 0 ipV4 unicast
                 isisPerformance::OnIncrmChange %W "ipV4"
            }
            bind $entryBox <KeyRelease> {
                 checkIpAddress %W 0 ipV4 unicast
                 isisPerformance::OnIncrmChange %W "ipV4"
            } 
        } else {
                 bind $entryBox <FocusOut>   {
                     checkIpAddress %W 0 ipV4 unicast
                 }
                 bind $entryBox <KeyRelease> { checkIpAddress %W 0 ipV4 unicast} 
        }
    }
}

################################################################################
# isisPerformance::OnRoutesMaskInit(parent propName args)
#
# DESCRIPTION:
# This ON_INIT procedure makes sure a correct max value is set for 
# IPV4 or IPV6 for Increment Across Routes
#
# ARGUMENTS
# parent   -   parent of this widget
# propName -   name of this widget
# args     -   variable arguments
#
# RETURNS
# none
#
###
proc isisPerformance::OnRoutesMaskInit {parent propName args} {

    if {[string tolower [testConfig::getTestConfItem protocolName]] == "ipv6"} {
        $parent.$propName config -max 128 
        if {[$parent.routeMaskWidth cget -value] < 64} {
            $parent.routeMaskWidth config -value 64
        }
    } else {
        $parent.$propName config -max 32
        if {[$parent.routeMaskWidth cget -value] > 32} {
           $parent.routeMaskWidth config -value 24
        }
    }
    
}

################################################################################
# isisPerformance::OnSubnetMaskInit(parent propName args)
#
# DESCRIPTION:
# This ON_INIT procedure makes sure a correct max value is set for 
# IPV4 or IPV6 for Increment Across Routes
#
# ARGUMENTS
# parent   -   parent of this widget
# propName -   name of this widget
# args     -   variable arguments
#
# RETURNS
# none
#
###
proc isisPerformance::OnSubnetMaskInit {parent propName args} {

    if {[string tolower [testConfig::getTestConfItem protocolName]] == "ipv6"} {
        $parent.$propName config -max 128 
        if {[$parent.subnetMaskWidth cget -value] < 64} {
            $parent.subnetMaskWidth config -value 64
        }
    } else {
        $parent.$propName config -max 32
        if {[$parent.subnetMaskWidth cget -value] > 32} {
           $parent.subnetMaskWidth config -value 24
        }
    }
    
}

################################################################################
# isisPerformance::OnIncrmChange(val protocol args)
#
# DESCRIPTION:
# This procedure sets the value of ipSrcIncr to the value selected by the user
# in the Test Setup tab - Increment By entry
#
# ARGUMENTS
# val   -   this widget
# protocol - current protocol
# args - ...
#
# RETURNS
# none
#
###
proc isisPerformance::OnIncrmChange {val protocol args} {
    global testConf
    set x [$val get]

    if { [string tolower $protocol] == "ipv4" } {
       set testConf(ipSrcIncr) $x
    } else {
       set testConf(ipV6SrcIncr) $x
    }

}
