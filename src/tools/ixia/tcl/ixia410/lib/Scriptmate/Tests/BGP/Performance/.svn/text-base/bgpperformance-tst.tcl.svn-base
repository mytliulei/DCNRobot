##################################################################################
# Copyright (c) Ixia 2004-2005
# All rights reserved
#
# DESCRIPTION:
#
#
#
##################################################################################

 namespace eval bgpPerformance {}

#####################################################################
# bgpPerformance::xmdDef
# 
# DESCRIPTION:
# This variable contains the XML content used by PDF Report generation.
#  
###
 set bgpPerformance::xmdDef  {
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
                        <Source scope="results.csv" entity_name="bgpPerformance" format_id=""/>
                        <Source scope="info.csv" entity_name="bgpPerformance_Info" format_id=""/>
                        <Source scope="AggregateResults.csv" entity_name="bgpPerformance_Aggregate" format_id=""/>
                        <Source scope="Iteration.csv" entity_name="bgpPerformance_Iteration" format_id=""/>
                     </Sources>
                  </XMD>
 }

#####################################################################
# bgpPerformance::statList
# 
# DESCRIPTION:
# This table contains a list of collected metrics to be displayed in
# the Real Time Graphs and written to RealTime.csv file.
#  
###
set map [map cget -type]
global ${map}Array

set bgpPerformance::statList \
    [list   [list framesSent     [getTxPorts ${map}Array] "Tx Frames per second" "Tx Frames" 1e0]\
            [list framesReceived [getRxPorts ${map}Array] "Rx Frames per second" "Rx Frames" 1e0]\
            [list bitsSent       [getTxPorts ${map}Array] "Tx Kbps"              "Tx Kb"     1e3]\
            [list bitsReceived   [getRxPorts ${map}Array] "Rx Kbps"              "Rx Kb"     1e3]\
    ]     


#####################################################################
# bgpPerformance::iterationFileColumnHeader
# 
# DESCRIPTION:
# This table contains a list of column headers at the top of the
# iteration.csv file.
#  
###
set bgpPerformance::iterationFileColumnHeader { 
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

#####################################################################
# bgpPerformance::attributes
# 
# DESCRIPTION:
# This attributes table contains a list of attributes used by the
# test algorithm or other backend test engine functions.  This
# table is used to initialize these attributes for later use.
#  
###
set bgpPerformance::attributes {
    {
	{ NAME              testName }
	{ BACKEND_TYPE      string }
	{ DEFAULT_VALUE     "BGP Performance" }
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
	{ NAME              percentMaxRate }
	{ BACKEND_TYPE      double }
	{ DEFAULT_VALUE     100 }
	{ MIN               0.001 }
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
        { NAME              delayTime }
        { BACKEND_TYPE      integer }
        { DEFAULT_VALUE     30 } 
        { MIN               0 }
        { MAX               65536 }
        { LABEL             "BGP sessions delay (sec): " }
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
	{ NAME              bgpType }
	{ BACKEND_TYPE      string }
	{ DEFAULT_VALUE     External }
	{ VALID_VALUES      {Internal External} }
	{ LABEL             "BGP Type: " }
	{ VARIABLE_CLASS    testCmd }
    }


    {
	{ NAME              firstAsNumber }
	{ BACKEND_TYPE      integer }
	{ DEFAULT_VALUE     0 } 
	{ MIN               0 }
	{ MAX               65535 }
	{ LABEL             "Local AS Number: " }
	{ VARIABLE_CLASS    testCmd }
    }

    {
	{ NAME              numPeers }
	{ BACKEND_TYPE      integer }
	{ DEFAULT_VALUE     5 } 
	{ MIN               1 }
	{ MAX               1500 }
	{ LABEL             "Number of peers per port: " }
	{ ON_UPDATE         bgpPerformance::OnNumPeersUpdate }
	{ VARIABLE_CLASS    testCmd }
    }

    {
	{ NAME               ipSrcIncrm }
	{ BACKEND_TYPE       string }
	{ DEFAULT_VALUE      0.0.0.1 }
	{ LABEL              "Increment By: " }
	{ VARIABLE_CLASS     testCmd }
	{ ON_INIT            bgpPerformance::OnValidAddressInit }
    }

    {
	{ NAME              routesPerPeer }
	{ BACKEND_TYPE      integer }
	{ DEFAULT_VALUE     1000 } 
	{ MIN               1 }
	{ MAX               2000000 }
	{ LABEL             "Number of routes per peer: " }
	{ VARIABLE_CLASS    testCmd }
    }

    {
	{ NAME               firstRoute }
	{ BACKEND_TYPE       string }
	{ DEFAULT_VALUE      194.20.0.1 }
	{ LABEL              "First Route: " }
	{ VARIABLE_CLASS     testCmd }
	{ ON_INIT            bgpPerformance::OnValidAddressInit }
    }

    {
	{ NAME               incrByRouters }
	{ BACKEND_TYPE       string }
	{ DEFAULT_VALUE      0.1.0.0 }
	{ LABEL              "Increment Across Routers: " }
	{ VARIABLE_CLASS     testCmd }
	{ ON_INIT            bgpPerformance::OnValidAddressInit }
    }

    {
	{ NAME               incrByRoutes }
	{ BACKEND_TYPE       integer }
	{ DEFAULT_VALUE      24 }
	{ MIN                0 }
 	{ LABEL              "Subnet Mask: " }
	{ VARIABLE_CLASS     testCmd }
	{ ON_INIT            bgpPerformance::OnIncrByRoutesInit }
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
	{ NAME              atmHeaderWidget }	    
	{ BACKEND_TYPE      null }
	{ VARIABLE_CLASS    null }
    }

    {
	{ NAME              userInfoWidget }        
	{ BACKEND_TYPE      null }
	{ VARIABLE_CLASS    null }
    }

    {
	{ NAME              autoMapGeneration }
	{ BACKEND_TYPE      boolean }
	{ DEFAULT_VALUE     no }
	{ VALID_VALUES      {yes no} }
	{ VARIABLE_CLASS    testConf }
    }

    {
	{ NAME              mapFromPort }
	{ BACKEND_TYPE      integerList } 
	{ DEFAULT_VALUE     {1 1 1} }
	{ VARIABLE_CLASS    testConf }
    }

    {
	{ NAME              mapToPort }
	{ BACKEND_TYPE      integerList }
	{ DEFAULT_VALUE     {1 16 4} }
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
	{ DESCRIPTION {
	    "Set up the map manually. Used only if autoMapGeneration set to \"no\"."
	    "Note that IP addresses MUST also be set up manually."
	    "get rid of any existing map"
	} }
    }

    {
	{ NAME              portmap }
	{ BACKEND_TYPE      string }
	{ DEFAULT_VALUE     {"Peer To Peer" "Partially Meshed" "Fully Meshed"} }
	{ VARIABLE_CLASS    portmap }
    }

    {
	{ NAME              directions }
	{ BACKEND_TYPE      string }
	{ DEFAULT_VALUE     {Bidirectional Unidirectional} }
	{ VARIABLE_CLASS    directions }
    }

    {
	{ NAME              enable802dot1qTag }
	{ BACKEND_TYPE      boolean }
	{ DEFAULT_VALUE     false }
	{ VALID_VALUES      {true false} }
	{ LABEL             "Enable 802.1q Tag" }
	{ VARIABLE_CLASS    testConf }
	{ ON_INIT           bgpPerformance::OnEnable802dot1qTagInit }
	{ ON_CHANGE         bgpPerformance::OnEnable802dot1qTagChange }
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
	{ DEFAULT_VALUE     yes }
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
	{ NAME              supportAutoAddressForManualMap }
	{ BACKEND_TYPE      integer }
	{ DEFAULT_VALUE     1 }
	{ VARIABLE_CLASS    supportAutoAddressForManualMap }
    }

    { 
	{ NAME              doNotSupportFastPath }
	{ BACKEND_TYPE      integer }
	{ DEFAULT_VALUE     1 }
	{ VARIABLE_CLASS    doNotSupportFastPath }
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
	{ DEFAULT_VALUE     bgpSuite }
	{ VARIABLE_CLASS    gTestCommand }
    }

    {
	{ NAME              protocolsSupportedByTest }
	{ BACKEND_TYPE      string }
	{ DEFAULT_VALUE     {ip ipv6} }
	{ VARIABLE_CLASS    protocolsSupportedByTest }
    }

    {
	{ NAME              protocolName }
	{ BACKEND_TYPE      string }
	{ DEFAULT_VALUE     ip }
	{ VALID_VALUES      {ip ipV6} }
	{ VARIABLE_CLASS    testConf }
	{ DESCRIPTION {
	    "Select the protocol to be used to run this test."
	    "Supported protocols are IP,IPv6. NOTE: Use lowercase ip,ipv6"
	    "ip   = layer 3 IP"
	    "ipV6 = layer 3 IP Version 6"
	} }
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
	{ NAME              enablePassFail }	    
	{ BACKEND_TYPE      integer }
	{ DEFAULT_VALUE     0 }
	{ VALID_VALUES      {1 0} }
	{ LABEL             Enable }
	{ VARIABLE          passFailEnable }
	{ VARIABLE_CLASS    testConf }
	{ ON_CHANGE         bgpPerformance::PassFailEnable }
    }

    {
	{ NAME              thresholdMode }
	{ BACKEND_TYPE      string }
	{ DEFAULT_VALUE     line }
	{ VALID_VALUES      {line data} }
	{ VALUE_LABELS      {"% Line Rate >=" "  Data Rate >="} }
	{ VARIABLE          passFailMode }
	{ VARIABLE_CLASS    testConf }
	{ ON_CHANGE         bgpPerformance::ThroughputThresholdToggle }
    }

    {
	{ NAME              lineThresholdValue }
	{ BACKEND_TYPE      double }
	{ DEFAULT_VALUE     100 }
	{ MIN               0.0001 }
	{ MAX               100 }
	{ VARIABLE          passFailLineValue }
	{ VARIABLE_CLASS    testConf }
    }
    
    {
	{ NAME              lineThresholdMode }
	{ BACKEND_TYPE      string }
	{ DEFAULT_VALUE     average }
	{ VALID_VALUES      {average} }
	{ VARIABLE          passFailLineType }
	{ VARIABLE_CLASS    testConf }
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
	{ NAME              resultFile }
	{ BACKEND_TYPE      string }
	{ DEFAULT_VALUE     bgpPerformance.results }
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
	{ DEFAULT_VALUE     bgpPerformance.log }
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

########################################################################################
# Procedure: registerResultVars
#
# Description: This command registers all the local variables that are used in the
# display of the results with the Results Options Database.  This procedure must exist
# for each test.
#
########################################################################################
proc bgpPerformance::registerResultVars {} {  

    results config -maxValueLength 15

    # configuration information stored for results
    if [results registerTestVars numTrials      numTrials     [bgpSuite cget -numtrials]      test] { return $::TCL_ERROR }

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

#############################################################################
# bgpPerformance::TestSetup()
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
proc bgpPerformance::TestSetup {} {
    variable testName 
    variable trial
    variable framesize
    variable txPortList
    variable rxPortList
    variable txRxPorts
    variable map
    variable fileIdArray
    variable txRxArray
    variable atmOnlyPortList
    variable nonAtmPortList
    variable learnProc

    set map [map cget -type]
    global ${map}Array

    copyPortList ${map}Array txRxArray

    set status $::TCL_OK

    bgpSuite config -testName "BGP Performance - [getBinarySearchString bgpSuite]"
    set testName [bgpSuite cget -testName]

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

    if {[results cget -generateCSVFile] == "true" | \
            [results cget -generateCSVFile] == $::true} {
        set fileID [openCSVResultFile]
        writeCSVHeader $fileID bgpSuite [bgpSuite cget -duration]
        set fileIdArray(csv) [list $fileID $csvDelimiter]
    }

    set txPortList [getTxPorts txRxArray]
    set rxPortList [getRxPorts txRxArray]
    set txRxPorts  [getAllPorts txRxArray]

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

    learn config -when oncePerTest

    if {[atmUtils::setAtmHeader $atmOnlyPortList]} {
        errorMsg "Error in setting ATM header on one or more ports: $atmOnlyPortList"
        return $::TCL_ERROR;
    }

    if [initTest bgpSuite txRxArray {ip ipV6} errMsg] {
        errorMsg $errMsg
        return $::TCL_ERROR
    }

    createMultipleInterfaces $txRxPorts [bgpSuite cget -numPeers]

    # if the sum of emulated routers on RX ports for every TX port is greater than 256 then ERROR
    set enableRoutes [bgpSuite cget -routesPerPeer]    

    if {($enableRoutes==0)} {
         logMsg "*** No route advertising and no network range advertising. No streams to set."
         set status 1
         return $status
    }

    foreach txPort [lsort [array names txRxArray]] {
         scan $txPort "%d,%d,%d" tx_c tx_l tx_p
         set numRxPorts [llength  $txRxArray($txPort)]
         set sum [mpexpr $numRxPorts*[bgpSuite cget -numPeers]]
         if {$sum>=256} {
             errorMsg "\n*** WARNING: The number of emulated routers on RX ports for TX port [getPortId $tx_c $tx_l $tx_p] is $sum, but it shouldn't be greater than 255 ! \n Decrease the number of emulated routers or the number of Rx ports in the map."
             set status $::TCL_ERROR
             return $status
         }
    }


    return $status 
}

#############################################################################
# bgpPerformance::TestCleanUp()
#
# DESCRIPTION
# This procedure resets common code elements needed at the end of a test.
#
# RETURNS:  
# status      TCL_OK     - on success
#             TCL_ERROR  - on failure
#
###
proc bgpPerformance::TestCleanUp {} {

    set status $::TCL_OK

    return $status 
}

#############################################################################
# bgpPerformance::TrialSetup()
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
proc bgpPerformance::TrialSetup {} {
    variable trial 
    
    set status $::TCL_OK

    logMsg "\n******* TRIAL $trial - [bgpSuite cget -testName] *******"

    set ::bgpSuite::trial $trial

    return $status 
}

#############################################################################
# bgpPerformance::AlgorithmSetup()
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
proc bgpPerformance::AlgorithmSetup {} {
    variable txPortList
    variable rxPortList
    variable txRxPorts
    variable framesize
    variable trial
    variable neighborIpAddressArray
    variable dutIpAddressArray
    variable percentRateArray
    variable maxRate
    variable userRate
    variable txNumFrames
    variable trial
    variable txRxArray
    variable atmOnlyPortList

    set status $::TCL_OK

    set ::bgpSuite::framesize $framesize

    logMsg "\n******* Framesize $framesize, trial $trial - [bgpSuite cget -testName] *******\n"

    set rxMode      [expr $::portRxDataIntegrity | $::portPacketGroup]
    if [changePortReceiveMode rxPortList $rxMode nowrite yes] {
        logMsg "***** WARNING: Some interfaces don't support [getTxRxModeString $rxMode RX] simultaneously."
        set status $::TCL_ERROR
        return $status
        return $::TCL_ERROR
    }

    foreach atmPort $atmOnlyPortList {
        scan $atmPort "%d %d %d" c l p

        stat config -mode statModeDataIntegrity
        if {[stat set $c $l $p]} {
            errorMsg "Could not set data integrity mode statistics on port $c $l $p!"
        }
    }

    bgpSuite config -framesize $framesize

    ######## set up results for this test
    setupTestResults bgpSuite [map cget -type] ""  \
	    txRxArray                    \
	    $framesize                     \
	    [bgpSuite cget -numtrials]     \
        false                          \
        1                              \
        bgpPerformance

    if [initMaxRate txRxArray maxRate $framesize userRate [bgpSuite cget -percentMaxRate]] {
         set status $::TCL_ERROR
         return $status
    }

    

    if {[configureBgp $txRxPorts]} {
        errorMsg "***** Error configuring BGP protocol ..."
        set status $::TCL_ERROR
        return $status
    }

    # write the streams
    if [writeBgpPerformanceStreams txRxArray txNumFrames [bgpSuite cget -routesPerPeer]] {
        return $::TCL_ERROR
    }

    return $status
}

#############################################################################
# bgpPerformance::AlgorithmBody()
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
proc bgpPerformance::AlgorithmBody {args} {
    variable txRxArray
    variable txPortList
    variable rxPortList
    variable txRxPorts
    variable neighborIpAddressArray
    variable dutIpAddressArray
    variable userRate
    variable framesize
    variable trial
    variable txNumFrames
    variable totalTxNumFrames
    variable totalRxNumFrames
    variable thruputRate 
    variable resultArray
    

    set status $::TCL_OK

    # Start BGP Server
    logMsg "Starting BGP4..."
    if [startBgp4Server txRxPorts] {
        errorMsg "Error Starting BGP!"
        return $::TCL_ERROR
    }

    # Confirm peer established
    if [confirmPeerEstablished txRxPorts] {
        errorMsg "Error!! Peers could not be established. The delay is not long enough or there is a network problem."
        errorMsg "Please make sure the AS number is correct."
		bgp4CleanUp txRxPorts no
        return $::TCL_ERROR
    }

    # Waiting for all routes to be advertised...
    set advertiseDelay [mpexpr [estimateAdvertiseDelay [bgpSuite cget -routesPerPeer]]*[bgpSuite cget -numPeers]]
    logMsg "Waiting $advertiseDelay seconds for all routes to be advertised..."

    writeWaitForPause  "Waiting for routes to be advertised ..." $advertiseDelay

    if [configureBgp4statsQuery neighborIpAddressArray dutIpAddressArray $txRxPorts ] {
        logMsg " Error in configuring bgp4StatsQuery"
        return $::TCL_ERROR
    }

    # Confirm all all routes have been advertised ...
    logMsg "Confirming all routes have been advertised ..."
    if { [confirmAllRoutesAdvertised neighborIpAddressArray dutIpAddressArray $txRxPorts [bgpSuite cget -routesPerPeer] extraTime] } {
       logMsg "Warning: All routes have not been advertised yet."
       bgp4CleanUp bgpPorts
       return $::TCL_ERROR
    }
            
    logMsg "Pausing for 15 seconds before starting transmitting ..."          
    writeWaitForPause  "Pause before transmitting.." 15 

    set status [doBinarySearch bgpSuite txRxArray userRate \
                thruputRate txNumFrames totalTxNumFrames rxNumFrames \
                totalRxNumFrames percentTputRateArray] 

    foreach txMap $txPortList {
        scan $txMap "%d %d %d" tx_c tx_l tx_p
        set resultArray($trial,$framesize,1,$tx_c,$tx_l,$tx_p,TXtransmitFrames) $txNumFrames($tx_c,$tx_l,$tx_p)
    }

    set status [expr [bgpPerformance::AlgorithmMeasure] && $status]

    return $status
}

#############################################################################
# bgpPerformance::AlgorithmMeasure()
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
proc bgpPerformance::AlgorithmMeasure {} {
    variable trial
    variable framesize
    variable thruputRate 
    variable txNumFrames 
    variable totalTxNumFrames
    variable totalRxNumFrames
    variable maxRate
    variable rxPortList
    variable resultArray
    variable fileIdArray
    variable groupIdList
    variable txRxArray

    copyPortList txRxArray txRxArray

    set status $::TCL_OK 

    set totalLoss           [calculatePercentLoss $totalTxNumFrames	$totalRxNumFrames]
    set totalTput           0
    set totalPercentTput    0

    #  Collect Data Integrity Stats
    collectDataIntegrityStats $rxPortList integrityError integrityFrame

    foreach txMap [lsort [array names txRxArray]] {
        scan $txMap "%d,%d,%d" tx_c tx_l tx_p
        set percentTput($tx_c,$tx_l,$tx_p) [calculatePercentThroughput $thruputRate($tx_c,$tx_l,$tx_p) $maxRate($tx_c,$tx_l,$tx_p)]
        if [catch {mpexpr ($thruputRate($tx_c,$tx_l,$tx_p)*100.)/$maxRate($tx_c,$tx_l,$tx_p)} percentTput($tx_c,$tx_l,$tx_p)] {
            set percentTput($tx_c,$tx_l,$tx_p)    0.
        }
        set percentTput($tx_c,$tx_l,$tx_p) [format "%6.4f" $percentTput($tx_c,$tx_l,$tx_p)]
        mpincr totalTput $thruputRate($tx_c,$tx_l,$tx_p)
        mpincr totalPercentTput $percentTput($tx_c,$tx_l,$tx_p)
    }

    # Packet Group Statistics collected
    set pgStatistics {totalFrames averageLatency minLatency maxLatency}

    foreach rxMap $rxPortList {
        scan [join $rxMap] "%d %d %d" rx_c rx_l rx_p
        set groupIdList($rx_c,$rx_l,$rx_p) {}
    }

    set streamGroup 0
    foreach txMap [lnumsort [array names txRxArray]] {

        foreach rxPort [lnumsort $txRxArray($txMap)] {
            scan [join $rxPort] "%d %d %d" rx_c rx_l rx_p

            set count [lsearch [getAllPorts txRxArray] $rxPort]
            for {set router 0} {$router < [bgpSuite cget -numPeers]} {incr router} {
                set stepToIncrement [mpexpr $count*[bgpSuite cget -numPeers]+$router]
                lappend groupIdList($rx_c,$rx_l,$rx_p) [mpexpr ($streamGroup << 8) | $stepToIncrement]
            }
        }
        incr streamGroup
    }

    foreach rxMap $rxPortList {
        scan [join $rxMap] "%d %d %d" rx_c rx_l rx_p
    }

    # Collect Packet Group Stats
    if {[collectPacketGroupStats rxPortList groupIdList $pgStatistics]} {
         errorMsg "Error: Unable to collect packet group statistics"
         set status $::TCL_ERROR
         set retCode $::TCL_ERROR
    }

    if {[startPacketGroups rxPortList]} {
       errorMsg "Error starting packetGroupStats"
    }
    logMsg "Saving results for Trial $trial Framesize $framesize..."

    foreach rxMap $rxPortList {
        scan $rxMap "%d %d %d" rx_c rx_l rx_p
        foreach groupId $groupIdList($rx_c,$rx_l,$rx_p) {
           set resultArray($trial,$framesize,1,$groupId,[join $rxMap ,],RXavgLatency)   $averageLatency($rx_c,$rx_l,$rx_p,$groupId)
           set resultArray($trial,$framesize,1,$groupId,[join $rxMap ,],RXmaxLatency)   $maxLatency($rx_c,$rx_l,$rx_p,$groupId)
           set resultArray($trial,$framesize,1,$groupId,[join $rxMap ,],RXminLatency)   $minLatency($rx_c,$rx_l,$rx_p,$groupId)
           set resultArray($trial,$framesize,1,$groupId,[join $rxMap ,],RXreceiveFrames) $totalFrames($rx_c,$rx_l,$rx_p,$groupId)
        }
        set resultArray($trial,$framesize,1,$rx_c,$rx_l,$rx_p,RXdataError) $integrityError($rx_c,$rx_l,$rx_p)
    }

    foreach txMap [lnumsort [array names txRxArray]] {
        scan $txMap "%d,%d,%d" tx_c tx_l tx_p 
        set resultArray($trial,$framesize,1,$txMap,TXpercentTput) $percentTput($txMap)
        set resultArray($trial,$framesize,1,$txMap,TXthroughput)  $thruputRate($txMap)
    }

    printResults txRxArray fileIdArray $trial $framesize

    return $status 
}

#############################################################################
# bgpPerformance::printResults()
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
proc bgpPerformance::printResults { TxRxArray FileIdArray trial framesize} {

    variable txRxArray
    variable txPortList
    variable rxPortList
    variable resultArray

    upvar $TxRxArray            txRxArray
    upvar $FileIdArray          fileIdArray

    set defaultDelimiter    "  "

    set framesizeRateString "Frame Size: [bgpSuite cget -framesize]"

    foreach fileType [array names fileIdArray] {
        foreach {fileID delimiter} $fileIdArray($fileType) {}
    }

    set title [format "%-10s%s%-10s%s%-10s%s%-10s%s%-10s%s%-10s%s%-10s%s%-15s%s%-15s%s%-15s%s%-10s" \
            "Tx Port"	        $delimiter \
            "Rx Port"		    $delimiter \
            "Tx Count"		    $delimiter \
            "Tput(%)"	        $delimiter \
            "Tput(fps)"         $delimiter \
            "BGP ID"		    $delimiter \
            "Rx Count"	        $delimiter \
            "AvgLatency(ns)"    $delimiter \
            "MinLatency(ns)"    $delimiter \
            "MaxLatency(ns)"    $delimiter \
            "Data Errors" ]

    foreach fileType [array names fileIdArray] {
        foreach {fileID delimiter} $fileIdArray($fileType) {}
        puts $fileID "******* TRIAL $trial, framesize: $framesize - BGP Performance *******\n\n"
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

                for {set router 1} {$router <= [bgpSuite cget -numPeers]} {incr router} {
                    set routerGroup [mpexpr $count*[bgpSuite cget -numPeers]+$router-1]
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

                    puts $fileID [format "%-10s%s%-10s%s%-10s%s%-10s%s%-10s%s%-10s%s%-10s%s%-15s%s%-15s%s%-15s%s%-10s" \
                        $txPort                                   $delimiter \
                        $rxPort                                   $delimiter \
                        $txCount                                  $delimiter \
                        $percentTput                              $delimiter \
                        $tput                                     $delimiter \
                        $rx_l.$rx_p.0.$router                     $delimiter \
                        $rxCount                                  $delimiter \
                        $avgLatency                               $delimiter \
                        $minLatency                               $delimiter \
                        $maxLatency                               $delimiter \
                        $dataErrors  ]

                }
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

            for {set router 1} {$router <= [bgpSuite cget -numPeers]} {incr router} {
                set routerGroup [mpexpr $count*[bgpSuite cget -numPeers]+$router-1]
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
                logMsg [format "%-10s%s%-10s%s%-10s%s%-10s%s%-10s%s%-10s%s%-10s%s%-15s%s%-15s%s%-15s%s%-10s" \
                        $txPort                                   $delimiter \
                        $rxPort                                   $delimiter \
                        $txCount                                  $delimiter \
                        $percentTput                              $delimiter \
                        $tput                                     $delimiter \
                        $rx_l.$rx_p.0.$router                     $delimiter \
                        $rxCount                                  $delimiter \
                        $avgLatency                               $delimiter \
                        $minLatency                               $delimiter \
                        $maxLatency                               $delimiter \
                        $dataErrors  ]
            }
        }
        incr streamGroup
    }
    logMsg "[stringRepeat "*" [expr [string length $title] + 10]]\n"

    foreach fileType [array names fileIdArray] {
        foreach {fileID delimiter} $fileIdArray($fileType) {}
        puts $fileID [stringRepeat "*" [expr [string length $title] + 10]]
        puts $fileID "\n"
    }

}

############################################################################
# bgpPerformance::AlgorithmCleanUp()
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
proc bgpPerformance::AlgorithmCleanUp {} {
    variable txRxPorts

    set status $::TCL_OK

    protocolCleanUp txRxPorts bgp4 no verbose

    # Small delay for better performance before starting the protocols for a new trial
    after 2000

    return $status

}

#############################################################################
# bgpPerformance::TrialCleanUp()
#
# DESCRIPTION
# This procedure resets common code elements upon completion of namespace
# procedures.
#
# RETURNS:  
# status      TCL_OK     - on success
#             TCL_ERROR  - on failure
#
###
proc bgpPerformance::TrialCleanUp {} {
    variable txRxArray

    variable status 
    
    set status $::TCL_OK

    if { [advancedTestParameter cget -removeStreamsAtCompletion] == "true"} {
        if [removeStreams txRxArray] {
            errorMsg "Error removing streams."
            set status $::TCL_ERROR
        }
    }

    return $status 
}

#############################################################################
# bgpPerformance::MetricsPostProcess()
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
proc bgpPerformance::MetricsPostProcess {} {
    variable resultsDirectory 
    variable resultArray
    variable rxPortList
    variable txPortList
    variable groupIdList
    global testConf 

    set trialsPassed  0

    for {set trial 1} {$trial <= [bgpSuite cget -numtrials] } {incr trial} {

	set percentLineRateList {} 
	set frameRateList {} 
	set dataRateList {} 
	set avgLatencyList {} 
	set maxLatencyList {} 

	foreach fs [lsort -dictionary [bgpSuite cget -framesizeList]] {

		foreach txMap $txPortList {
		    scan $txMap "%d %d %d" tx_c tx_l tx_p

		    lappend percentLineRateList \
			$resultArray($trial,$fs,1,$tx_c,$tx_l,$tx_p,TXpercentTput) 

		    set frameRate $resultArray($trial,$fs,1,$tx_c,$tx_l,$tx_p,TXthroughput) 

		    lappend frameRateList $frameRate 

		    set dataRate  [mpexpr 8 * $fs * $frameRate] 

		    lappend dataRateList $dataRate 
		} ;# loop over txPort list

		foreach rxMap $rxPortList {
		    scan $rxMap "%d %d %d" rx_c rx_l rx_p
		    foreach groupId $groupIdList($rx_c,$rx_l,$rx_p) {
			lappend avgLatencyList \
			    $resultArray($trial,$fs,1,$groupId,$rx_c,$rx_l,$rx_p,RXavgLatency) 
			
			lappend maxLatencyList \
			    $resultArray($trial,$fs,1,$groupId,$rx_c,$rx_l,$rx_p,RXmaxLatency) 
		    }
		} ;# loop over rxPort list
	} ;# loop over frame size

	# Minimum % Line Rate is the smallest throughput percentage of any port pair 
	# across any frame sizes for a given trial.
	set resultArray($trial,minPercentLineRate) [passfail::ListMin percentLineRateList] 

	# Average % Line Rate is an average throughput percentage across any frame 
	# sizes and all ports for a given trial
	set resultArray($trial,avgPercentLineRate) [passfail::ListMean percentLineRateList] 

	# Minimum Data Rate is the smallest absolute bit rate of any port pair across any 
	# frame sizes for a given trial. Data Rate is computed in bits/sec
	set resultArray($trial,minDataRate) [passfail::ListMin dataRateList] 

	# Average Data Rate is an average absolute bit rate across any frame sizes and 
	# all ports for a given trial
	set resultArray($trial,avgDataRate) [passfail::ListMean dataRateList] 

	# Minimum Frame Rate is the smallest frame rate of any port pair across any 
	# frame sizes for a given trial. Data Rate is computed in bits/sec
	set resultArray($trial,minFrameRate) [passfail::ListMin frameRateList] 

	# Average Frame Rate is an average frame rate across any frame sizes and 
	# all ports for a given trial
	set resultArray($trial,avgFrameRate) [passfail::ListMean dataRateList]

	if {[lsearch $avgLatencyList "notCalculated"] >= 0} {
	    set resultArray($trial,avgLatency) "notCalculated" 
	    set resultArray($trial,maxLatency) "notCalculated" 
	} else {
	    # Maximum Latency is the largest latency of any port pair
	    # across any frame sizes for a given trial
	    set resultArray($trial,maxLatency) [passfail::ListMax maxLatencyList] 
	    
	    # Average Latency is the average latency of any port pair
	    # across any frame sizes for a given trial
	    set resultArray($trial,avgLatency) [passfail::ListMean avgLatencyList] 
	}
	
    } ;# loop over trials

}

################################################################################
#
# bgpPerformance::PassFailCriteriaEvaluate()
#
# DESCRIPTION:
# This procedure calculates the number of trials that have executed successfully
# based upon user-specified Pass/Fail criteria.  
# 
# The first criteria for this test is based upon either an acceptable percentage of 
# line rate or an acceptable data rate.  These two general criteria are further 
# divided as noted below.
# Average % Line Rate is an average throughput percentage across any frame 
# sizes and all ports for a given trial
# Minimum % Line Rate is the smallest throughput percentage of any port pair 
# across any frame sizes for a given trial.
# Average Data Rate is an average absolute bit rate across any frame sizes and 
# all ports for a given trial
# Minimum Data Rate is the smallest absolute bit rate of any port pair across any 
# frame sizes for a given trial.
#
# The second criteria which must be met is based upon an acceptable value of 
# Latency.
# Average Latency is the average latency of any port pair across any frame sizes 
# for a given trial
# Maximum Latency is the largest latency of any port pair across any frame sizes 
# for a given trial
#
# MODIFIES
# trialsPassed      - namespace variable indicating number of successful trials.
#
# RETURNS
# none
#
###
proc bgpPerformance::PassFailCriteriaEvaluate {} {
    variable trialsPassed 
    variable resultArray
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

    set trialsPassed 0 

    for {set trial 1} {$trial <= [bgpSuite cget -numtrials] } {incr trial} {
        logMsg "*** Trial #$trial" 
        set avgPercentLineRate $resultArray($trial,avgPercentLineRate) 
        set minPercentLineRate $resultArray($trial,minPercentLineRate) 
        set avgDataRate $resultArray($trial,avgDataRate) 
        set minDataRate $resultArray($trial,minDataRate) 
        set avgFrameRate $resultArray($trial,avgFrameRate) 
        set minFrameRate $resultArray($trial,minFrameRate) 

        # Pass/Fail Criteria is based on the logical AND of two criteria
        set throughputResult [passfail::PassFailCriteriaThroughputEvaluate \
                              $avgPercentLineRate $minPercentLineRate \
                              $avgDataRate $minDataRate "N/A" \
                              $avgFrameRate $minFrameRate] 

        set avgLatency $resultArray($trial,avgLatency) 
        set maxLatency $resultArray($trial,maxLatency) 

        set latencyResult [passfail::PassFailCriteriaLatencyEvaluate \
                          $avgLatency $maxLatency] 

        if { ($throughputResult == "PASS") && ($latencyResult == "PASS")} {
            set result "PASS"
        } else {
            set result "FAIL" 
        }

        if { $result == "PASS" } {
            incr trialsPassed
        }

        logMsg "*** $result\n" 
    } ;# loop over trials

    logMsg "*** # Of Trials Passed: $trialsPassed" 
    logMsg "***************************************"
}

########################################################################
# Procedure: bgpPerformance::writeIterationData2CSVFile
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
proc bgpPerformance::writeIterationData2CSVFile { iteration testCmd TxRxArray Framerate TputRateArray \
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
# bgpPerformance::WriteResultsCSV()
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
proc bgpPerformance::WriteResultsCSV {} {
    variable resultsDirectory
    variable trialsPassed
    variable txPortList
    variable rxPortList
    variable resultArray
    global testConf passFail
    variable txRxArray

    set dirName $resultsDirectory

    if { [bgpSuite cget -framesizeList] == {} } {
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

    puts $csvFid "Trial,Frame Size (bytes),Tx Port,Rx Port,Tx Count,No Drop Rate (% Line rate),Tput (fps),BGP ID,Rx Count,Avg Latency (ns),Min Latency (ns),Max Latency (ns),Data Errors"

    for {set trial 1} {$trial <= [bgpSuite cget -numtrials] } {incr trial} {
        foreach framesize [lsort -dictionary [bgpSuite cget -framesizeList]] {
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

                    set count [lsearch [getAllPorts txRxArray] $rxMap]

                    for {set router 1} {$router <= [bgpSuite cget -numPeers]} {incr router} {
                        set routerGroup [mpexpr $count*[bgpSuite cget -numPeers]+$router-1]

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

                        puts $csvFid "$trial,$framesize,$txPort,$rxPort,$txCount,$percentTput,$tput,$rx_l.$rx_p.0.$router ,\
                                      $rxCount,$avgLatency,$minLatency,$maxLatency,$dataErrors"
                    }
                }
                incr streamGroup
            }
        }
   }

   closeMyFile $csvFid
}

########################################################################
# bgpPerformance::WriteAggregateResultsCSV()
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
proc bgpPerformance::WriteAggregateResultsCSV {} {
    variable resultsDirectory 
    variable txPortList
    variable rxPortList
    variable resultArray
    global testConf passFail
    variable txRxArray

    set dirName $resultsDirectory 

    
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

    foreach framesize [lsort -dictionary [bgpSuite cget -framesizeList]] {
	    for {set trial 1} {$trial <= [bgpSuite cget -numtrials] } {incr trial} {
		    set fpsList {} 
		    set rateList {} 
            set txCountList {} 
            set rxCountList {} 
		    set aggMinLatencyList {} 
		    set aggMaxLatencyList {} 
		    set aggAvgLatencyList {} 
		    set aggDataErrorList {} 
		    set streamGroup 0
		
		    foreach txPort [lnumsort [array names txRxArray]] {
			    scan $txPort "%d,%d,%d" tx_c tx_l tx_p 

                lappend txCountList $resultArray($trial,$framesize,1,$tx_c,$tx_l,$tx_p,TXtransmitFrames) 
			    lappend fpsList $resultArray($trial,$framesize,1,$txPort,TXthroughput)
		        lappend rateList $resultArray($trial,$framesize,1,$txPort,TXpercentTput)


			    foreach rxMap [lnumsort $txRxArray($txPort)] {
				    scan [join $rxMap] "%d %d %d" rx_c rx_l rx_p

				    set count [lsearch [getAllPorts txRxArray] $rxMap]

                    for {set router 1} {$router <= [bgpSuite cget -numPeers]} {incr router} {
                        set routerGroup [mpexpr $count*[bgpSuite cget -numPeers]+$router-1]

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

		    set aggFps [passfail::ListSum fpsList]  
            set aggTxCount [passfail::ListSum txCountList] 
            set aggRxCount [passfail::ListSum rxCountList]
		    set aggRate [passfail::ListMean rateList] 
		    if {[lsearch $aggAvgLatencyList "notCalculated"] >= 0} {
		        set aggMinLatency "notCalculated" 
		        set aggMaxLatency "notCalculated" 
		        set aggAvgLatency "notCalculated" 
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
# bgpPerformance::PassFailEnable(args)
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
proc bgpPerformance::PassFailEnable {args} {
    global passFailEnable 

    set state disabled 
    set latencyState disabled 

    if {$passFailEnable} {
	   bgpPerformance::ThroughputThresholdToggle 

	   set state enabled 
       set latencyState enabled

       set attributeList {
	    thresholdMode
	    }
	   renderEngine::WidgetListStateSet $attributeList $state 

    } else {
	    set attributeList {
	    thresholdMode 
	    lineThresholdValue 
	    lineThresholdMode 
	    dataThresholdValue
	    dataThresholdScale
	    dataThresholdMode
	     }
	    renderEngine::WidgetListStateSet $attributeList $state 
    }

    set latencyAttributeList {
	latencyLabel
	latencyValue
	latencyThresholdScale
	latencyThresholdMode
    }

    renderEngine::WidgetListStateSet $latencyAttributeList $latencyState 
}

################################################################################
#
# bgpPerformance::ThroughputThresholdToggle(args)
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
proc bgpPerformance::ThroughputThresholdToggle {args} {
    global passFailMode 

    if {$passFailMode == "data"} {
	set lineState disabled 
	set dataState enabled 
    } else {
	set lineState enabled 
	set dataState disabled 
    }

    set lineAttributeList {
	lineThresholdValue
	lineThresholdMode
    }
    renderEngine::WidgetListStateSet $lineAttributeList $lineState 

    set dataAttributeList {
	dataThresholdValue
	dataThresholdScale
	dataThresholdMode
    }
    renderEngine::WidgetListStateSet $dataAttributeList $dataState 
}

################################################################################
#
# bgpPerformance::PassFailLatencyEnable(args)
#
# DESCRIPTION:
# This procedure enables or disables Latency Pass/Fail Critiera related widgets.
# In this particular case the enable/disable is tied to a NON Pass/Fail widget
# indicating the overal display choice of whether latency is included.
#
# ARGUMENTS
# args       - variable arguments
#
# RETURNS
# none
#
###
proc bgpPerformance::PassFailLatencyEnable {args} {
    global passFailEnable

    set state disabled 

    if {$passFailEnable} {
	    set state enabled 
    }

    set attributeList {
	latencyLabel 
	latencyValue 
	latencyThresholdScale 
	latencyThresholdMode
    } 
    
    renderEngine::WidgetListStateSet $attributeList $state 
}
 
###########################################################################
# Procedure: bgpPerformance::ConfigValidate 
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
proc bgpPerformance::ConfigValidate {} {

    set map [map cget -type]
    variable txRxArray

    set status $::TCL_OK

    #repeated frame sizes are eliminated from the list if there are any
    configValidation::RemoveDuplicatesFromFramesizeList bgpSuite

    #validate framesizeList
    if { ![configValidation::ValidateFrameSizeList  bgpSuite]} {
       set status $::TCL_ERROR
       return $status
    }

    #validate initial rate
    if { ![configValidation::ValidateInitialRate  bgpSuite]} {
        set status $::TCL_ERROR
         return $status
    }

    #common validatation to all the tests
    if {![configValidation::ValidateCommon bgpSuite]} {
       set status $::TCL_ERROR
         return $status
    }

    return $status

}

################################################################################
#
# bgpPerformance::OnEnable802dot1qTagChange(args)
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
proc bgpPerformance::OnEnable802dot1qTagInit {args} {
    global enable802dot1qTag 

    set enable802dot1qTag [testConfig::getTestConfItem enable802dot1qTag]

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
		set attributeEnabledList {} 
	}
    }

    renderEngine::WidgetListStateSet $attributeDisabledList disabled 
    renderEngine::WidgetListStateSet $attributeEnabledList  enabled 

}


################################################################################
#
# bgpPerformance::OnEnable802dot1qTagChange(args)
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
proc bgpPerformance::OnEnable802dot1qTagChange {args} {
    global enable802dot1qTag 
    global enableISLtag 
    
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
		set attributeEnabledList {} 
	}
    }
    set ::testConf(enable802dot1qTag) $enable802dot1qTag
    renderEngine::WidgetListStateSet $attributeDisabledList disabled 
    renderEngine::WidgetListStateSet $attributeEnabledList  enabled 

}

################################################################################
#
# bgpPerformance::OnTrafficMapSet(protocol)
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
proc bgpPerformance::OnTrafficMapSet {map} {
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

    renderEngine::WidgetListStateSet $attributeDisabledList disabled 
    renderEngine::WidgetListStateSet $attributeEnabledList  enabled 

    smProtocol::setenableGTWIPIncrement
    smProtocol::setenableGTWIPv6Increment
}

################################################################################
#
# bgpPerformance::OnProtocolSet(protocol)
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
proc bgpPerformance::OnProtocolSet {protocol} {

    global firstRoute
    global incrByRouters
    global incrByRoutes
    global invisibleBgpParamsFrameName
    global ipSrcIncrm
    global testConf
    
    foreach propName {firstRoute incrByRouters ipSrcIncrm} {
        switch $propName {
            "firstRoute" -
            default
                {
                set ipAddress "194.20.0.1"
                set ipV6Address "2000:0:0:1::0"
                }
            "incrByRouters"
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
                 if {$propName == "incrByRouters" || $propName == "ipSrcIncrm"} {
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
        bgpSuite config -$propName [set $propName]

        set entryBox [$invisibleBgpParamsFrameName.$propName subwidget entry] 

                 if {[string tolower [testConfig::getTestConfItem protocolName]] == "ipv6"} {
                    set width 20
                    if { $propName == "ipSrcIncrm" } {
                         bind $entryBox <FocusOut>   {
                              checkIpAddress %W 0 ipV6 unicast
                              bgpPerformance::OnIncrmChange %W "ipV6"
                              } 
                         bind $entryBox <KeyRelease> {
                              checkIpAddress %W 0 ipV6 unicast
                              bgpPerformance::OnIncrmChange %W "ipV6"
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
                              bgpPerformance::OnIncrmChange %W "ipV4"
                         }
                         bind $entryBox <KeyRelease> {
                              checkIpAddress %W 0 ipV4 unicast
                              bgpPerformance::OnIncrmChange %W "ipV4"
                         } 
                     } else {
                              bind $entryBox <FocusOut>   {
                                  checkIpAddress %W 0 ipV4 unicast
                              }
                              bind $entryBox <KeyRelease> { checkIpAddress %W 0 ipV4 unicast} 
                     }
                 }

        $entryBox config -width $width

    }

    if {[string tolower [testConfig::getTestConfItem protocolName]] == "ipv6"} {
        $invisibleBgpParamsFrameName.incrByRoutes config -max 128 
    } else {
        $invisibleBgpParamsFrameName.incrByRoutes config -max 32
        if {[$invisibleBgpParamsFrameName.incrByRoutes cget -value] > 32} {
           $invisibleBgpParamsFrameName.incrByRoutes config -value 24
        }
    }
}

################################################################################
# bgpPerformance::OnValidAddressInit(parent propName args)
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
proc bgpPerformance::OnValidAddressInit {parent propName args} {
    global testConf testCmd
    set entryBox [$parent.$propName subwidget entry] 

    switch $propName {
        "firstRoute" -
        default
        {
            set ipAddress "194.20.0.1"
            set ipV6Address "2000:0:0:1::0"
        }
        "incrByRouters"
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
		if {[ipv6::isValidAddress [$entryBox get]] == 0} {
			set validAddress $ipV6Address
		} else {
			set validAddress [$entryBox get]
		}
	} else {
          if { $propName == "ipSrcIncrm" || $propName == "incrByRouters"} {
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
                 bgpPerformance::OnIncrmChange %W "ipV6"
                 } 
	    bind $entryBox <KeyRelease> {
                 checkIpAddress %W 0 ipV6 unicast
                 bgpPerformance::OnIncrmChange %W "ipV6"
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
                 bgpPerformance::OnIncrmChange %W "ipV4"
            }
            bind $entryBox <KeyRelease> {
                 checkIpAddress %W 0 ipV4 unicast
                 bgpPerformance::OnIncrmChange %W "ipV4"
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
# bgpPerformance::OnIncrByRoutesInit(parent propName args)
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
proc bgpPerformance::OnIncrByRoutesInit {parent propName args} {

    if {[string tolower [testConfig::getTestConfItem protocolName]] == "ipv6"} {
        $parent.$propName config -max 128 
    } else {
        $parent.$propName config -max 32
        if {[$parent.incrByRoutes cget -value] > 32} {
           $parent.incrByRoutes config -value 24
        }
    }
    
}
################################################################################
# bgpPerformance::OnNumPeersUpdate(parent propName args)
#
# DESCRIPTION:
# This ON_UPDATE procedure sets the number of vlans per port depending on the
# number of routers emulated per port
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
proc bgpPerformance::OnNumPeersUpdate {parent propName args} {
    global numPeers  testConf

    testConfig::setTestConfItem vlansPerPort $numPeers
    
}

################################################################################
# bgpPerformance::OnIncrmChange(val protocol args)
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
proc bgpPerformance::OnIncrmChange {val protocol args} {
    global testConf
    set x [$val get]

    if { [string tolower $protocol] == "ipv4" } {
       set testConf(ipSrcIncr) $x
    } else {
       set testConf(ipV6SrcIncr) $x
    }

}
