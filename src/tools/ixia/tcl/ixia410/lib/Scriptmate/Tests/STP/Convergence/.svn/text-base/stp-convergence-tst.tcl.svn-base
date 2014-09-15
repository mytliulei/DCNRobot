############################################################################################
#
#   Copyright © 1997 - 2004 by IXIA.
#   All Rights Reserved.                                                                                
#
#############################################################################################
 namespace eval stpSuite {}

#####################################################################
# stpConvergence::xmdDef
# 
# DESCRIPTION:
# This variable contains the XML content used by PDF Report generation.
#  
###
set stpConvergence::xmdDef  {
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
          <Source scope="results.csv" entity_name="stpConvergence" format_id=""/>
          <Source scope="info.csv" entity_name="stpConvergence_Info" format_id=""/>
          <Source scope="AggregateResults.csv" entity_name="stpConvergence_Aggregate" format_id=""/>
          <Source scope="Iteration.csv" entity_name="stpConvergence_Iteration" format_id=""/>
       </Sources>
    </XMD>
}

#####################################################################
# stpConvergence::statList
# 
# DESCRIPTION:
# This table contains a list of collected metrics to be displayed in
# the Real Time Graphs and written to RealTime.csv file.
#  
###
set map [map cget -type]
global ${map}Array

set stpConvergence::statList \
    [list [list framesSent     [getTxPorts ${map}Array] "Tx Frames per second" "Tx Frames" 1e0]\
	  [list framesReceived [getRxPorts ${map}Array] "Rx Frames per second" "Rx Frames" 1e0]\
	  [list bitsSent       [getTxPorts ${map}Array] "Tx Kbps"              "Tx Kb"     1e3]\
	  [list bitsReceived   [getRxPorts ${map}Array] "Rx Kbps"              "Rx Kb"     1e3]\
	];


########################################################################################
# Procedure: registerResultVars
#
# Description: This command registers all the local variables that are used in the
# display of the results with the Results Options Database.  This procedure must exist
# for each test.
#
########################################################################################
proc stpConvergence::registerResultVars {} {  

    results config -maxValueLength 15

        if [ results addOptionToDB totalPacketLoss          "TotalPacketLoss(Actual + MisDirected)"  12  12   iter   ] { return 1 } 
        if [ results addOptionToDB convergenceMetricLoss    "Convergence Time: Packet Loss Method(nseconds)" 12  12   iter   ] { return 1 } 
        if [ results addOptionToDB convergenceMetricTime    "Convergence Time: Timestamps Method(nseconds)" 12  12   iter   ] { return 1 } 
        if [ results addOptionToDB packetRate               "PacketRate (PPS)"                       12  12   iter   ] { return 1 }
    # configuration information stored for results
    if [results registerTestVars numTrials      numTrials     [stpSuite cget -numtrials]      test] { return $::TCL_ERROR }

    # results obtained after each iteration
    if [results registerTestVars throughput     thruputRate    0   port TX ] { return $::TCL_ERROR }
    if [results registerTestVars percentTput    percentTput    0   port TX ] { return $::TCL_ERROR }
    if [results registerTestVars dataError      integrityError 0   port RX ] { return $::TCL_ERROR }
    if [results registerTestVars totalSeqError  sequenceError  0   port RX ] { return $::TCL_ERROR }
    if [results registerTestVars throughput     convTime       0   port RX ] { return $::TCL_ERROR }

    return $::TCL_OK
}

#####################################################################
# stpConvergence::attributes
# 
# DESCRIPTION:
# This attributes table contains a list of attributes used by the
# test algorithm or other backend test engine functions.  This
# table is used to initialize these attributes for later use.
#  
###
set stpConvergence::attributes { 

    {
	{ NAME              testName }
	{ BACKEND_TYPE      string }
	{ DEFAULT_VALUE     "STP/RSTP Convergence" }
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
	{ DEFAULT_VALUE     10 }
	{ MIN               1 }
	{ MAX               100 }
	{ LABEL             "Max Rate (%): " }
	{ VARIABLE_CLASS    testCmd }
    }

    {
        { NAME              enablePassFail }	    
        { BACKEND_TYPE      integer }
        { DEFAULT_VALUE     0 }
        { VALID_VALUES      {1 0} }
        { LABEL             Enable }
        { VARIABLE          passFailEnable }
        { VARIABLE_CLASS    testConf }
        { ON_CHANGE         stpConvergence::PassFailEnable }
    }
       
    {
        { NAME              passTimeValue }
        { BACKEND_TYPE      double }
        { DEFAULT_VALUE     30 }
        { MIN               1 }
        { LABEL             "Convergence Time <= " }
        { VARIABLE_CLASS    testConf }
    }

    {
        { NAME              timeUnit }
        { BACKEND_TYPE      string }
        { DEFAULT_VALUE     "sec" }
        { VALID_VALUES      {"sec" "ms" "us" "ns"} }
        { VARIABLE_CLASS    testConf }
    }

    {
        { NAME              macPerPort }
        { BACKEND_TYPE      integer }
        { DEFAULT_VALUE     1 }
        { MIN               1 }
        { LABEL             "Number of MAC Addresses Per Port: " }
        { VARIABLE_CLASS    testCmd }
    }

    {
        { NAME              convergenceCause }
        { BACKEND_TYPE      string }
        { DEFAULT_VALUE     "Root Cost" }
        { VALID_VALUES      {"Root Cost" "No BPDU" "Link Failure"} }
        { LABEL             "Cause of Convergence: " }
        { VARIABLE_CLASS    testCmd }
        { ON_INIT           stpConvergence::OnCauseChange }
        { ON_CHANGE         stpConvergence::OnCauseChange }
    }

    {
        { NAME              bridgingProtocol }
        { BACKEND_TYPE      string }
        { DEFAULT_VALUE     "STP" }
        { VALID_VALUES      {"STP" "RSTP"} }
        { LABEL             "Bridging Protocol: " }
        { VARIABLE_CLASS    testCmd }
    }

    {
        { NAME              measurementType }
        { BACKEND_TYPE      string }
        { DEFAULT_VALUE     "First/Last Timestamps" }
        { VALID_VALUES      {"First/Last Timestamps" "Packet Loss" "Both"} }
        { LABEL             "Measurement Method " }
        { VARIABLE_CLASS    testCmd }
    }

    {
        { NAME              rootMacAddress }          
        { BACKEND_TYPE      string }
        { DEFAULT_VALUE     "00:00:00:00:00:00" } 
        { LABEL             "Root MAC Address: " }
        { VARIABLE_CLASS    testCmd }
        { ON_INIT           stpConvergence::OnRootMacAddressUpdate }
        { ON_UPDATE         stpConvergence::OnRootMacAddressUpdate }
    }

    {
        { NAME              rootPriority }
        { BACKEND_TYPE      string }
        { DEFAULT_VALUE     8192 }
        { MIN               0 }
        { VALID_VALUES      {0 4096 8192 12288 16384 20480 24576 28672 32768 36864 40960 45056 49152 53248 57344 61440} }
        { LABEL             "Root Priority: " }
        { VARIABLE_CLASS    testCmd }
    }

    {
        { NAME              helloInterval }
        { BACKEND_TYPE      integer }
        { DEFAULT_VALUE     2 }
        { MIN               1}
        { MAX               255}
        { LABEL             "Hello Interval (sec): " }
        { VARIABLE_CLASS    testCmd }
    }

    {
        { NAME              maxAge }
        { BACKEND_TYPE      integer }
        { DEFAULT_VALUE     20 }
        { MIN               1 }
        { MAX               255}
        { LABEL             "Max Age (sec): " }
        { VARIABLE_CLASS    testCmd }
    }

    {
        { NAME              forwardDelay }
        { BACKEND_TYPE      integer }
        { DEFAULT_VALUE     15 }
        { MIN               1 }
        { MAX               255}
        { LABEL             "Forward Delay (sec): " }
        { VARIABLE_CLASS    testCmd }
    }

    {
        { NAME              dutDelay }
        { BACKEND_TYPE      double }
        { DEFAULT_VALUE     10 }
        { VARIABLE_CLASS    testConf }
    }

    {
        { NAME              frameSizeWidget }	    
        { BACKEND_TYPE      null }
        { VARIABLE_CLASS    null }
    }

    {
        { NAME              trafficMapWidget } 
        { BACKEND_TYPE      null }
        { VARIABLE_CLASS    null }
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
	{ DEFAULT_VALUE     {Manual Automatic} }
	{ VARIABLE_CLASS    automap }
    }

    {
        { NAME              map }
        { BACKEND_TYPE      string }
        { DEFAULT_VALUE     one2many }
        { VARIABLE_CLASS    map }
    }

    {
        { NAME              mapDirection }
        { BACKEND_TYPE      string }
        { DEFAULT_VALUE     unidirectional }
        { VARIABLE_CLASS    testConf }
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
	{ DEFAULT_VALUE     stpSuite }
	{ VARIABLE_CLASS    gTestCommand }
    }

    {
        { NAME              productname }
        { BACKEND_TYPE      string }
        { DEFAULT_VALUE     "Your switch/router name here" }
        { VARIABLE_CLASS    user }
    }

    {
        { NAME              version }
        { BACKEND_TYPE      string }
        { DEFAULT_VALUE     "Your firmware version here" }
        { VARIABLE_CLASS    user }
    }

    {
        { NAME              "serial#" }
        { BACKEND_TYPE      string }
        { DEFAULT_VALUE     "Your switch/router serial number here" }
        { VARIABLE_CLASS    user }
    }

    {
        { NAME              username }
        { BACKEND_TYPE      string }
        { DEFAULT_VALUE     "Your name here" }
        { VARIABLE_CLASS    user }
    }

    {
        { NAME              comments }
        { BACKEND_TYPE      string }
        { DEFAULT_VALUE     "" }
        { VARIABLE_CLASS    user }
    }

    {
	{ NAME              resultFile }
	{ BACKEND_TYPE      string }
	{ DEFAULT_VALUE     stpConvergence.results }
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
	{ DEFAULT_VALUE     stpConvergence.log }
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
        { NAME              protocolName }
        { BACKEND_TYPE      string }
        { DEFAULT_VALUE     "mac" }
        { VALID_VALUES      {"mac" "ip" "ipV6" "ipx"} }
        { VARIABLE_CLASS    testConf }
    }
}

#############################################################################
# stpConvergence::TestSetup()
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
proc stpConvergence::TestSetup {} {
    variable testName
    variable usedProtocol
    variable trial
    variable framesize
    variable txPortList
    variable rxPortList
    variable txRxPorts
    variable map
    variable fileIdArray
    variable portsCosts
    variable costIndex
    variable hashCost
    global testConf

    set map         [map cget -type]

    global ${map}Array

    set status      $::TCL_OK

    set hashCost(10000) 2
    set hashCost(1000)  4
    set hashCost(100)   19
    set hashCost(16)    62
    set hashCost(10)    100
    set hashCost(4)     250

    if {[stpSuite cget -bridgingProtocol]=="STP"} {
        stpSuite config -testName "STP Convergence"
        set usedProtocol "STP"
    } else {
        stpSuite config -testName "RSTP Convergence"
        set usedProtocol "RSTP"
    }

    set testName [stpSuite cget -testName]

    set costIndex 0

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
        writeCSVHeader $fileID stpSuite [stpSuite cget -duration]
        set fileIdArray(csv) [list $fileID $csvDelimiter]
    }

    learn config -when        oncePerTest

    if [initTest stpSuite ${map}Array mac errMsg] {
        errorMsg $errMsg
        return $::TCL_ERROR
    }

    set txPortList [getTxPorts ${map}Array]
    set rxPortList [getRxPorts ${map}Array]
    set txRxPorts  [getAllPorts ${map}Array]

    createSimpleInterfaces $txRxPorts 1

    set rxMode      [expr $::portRxModeWidePacketGroup | $::portRxDataIntegrity | $::portRxFirstTimeStamp ]
    if [changePortReceiveMode rxPortList $rxMode nowrite no] {
        errorMsg "***** WARNING: Some interfaces don't support [getTxRxModeString $rxMode RX] simultaneously."
        return $::TCL_ERROR
    }

    if {[stpSuite cget -duration]<=$testConf(dutDelay)} {
        errorMsg "***** WARNING: Test duration is smaller or equal that DUT Processing Delay. Should be greater."
        return $::TCL_ERROR
    }

    return $status;
}

#############################################################################
# stpConvergence::TestCleanUp()
#
# DESCRIPTION
# This procedure resets common code elements needed at the end of a test.
#
# RETURNS:  
# status      TCL_OK     - on success
#             TCL_ERROR  - on failure
#
###
proc stpConvergence::TestCleanUp {} {
    variable status
    
    set status $::TCL_OK

    return $status;
}

#############################################################################
# stpConvergence::TrialSetup()
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
proc stpConvergence::TrialSetup {} {
    variable trial
    variable status

    set status $::TCL_OK
    
    logMsg " ******* TRIAL $trial - [stpSuite cget -testName] ***** "
    set ::stpSuite::trial $trial

    return $status;
}    

#############################################################################
# stpConvergence::AlgorithmSetup()
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
proc stpConvergence::AlgorithmSetup {} {
    variable timeHash
    variable usedProtocol
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
    global ${map}Array

    set status $::TCL_OK

    set ::stpSuite::framesize  $framesize
    stpSuite config -framesize $framesize
    set framesizeString "Framesize:$framesize"

    set timeHash(sec) 1000000000
    set timeHash(ms)     1000000
    set timeHash(us)        1000
    set timeHash(ns)           1
    set costIndex 0

    ######## set up results for this test
    setupTestResults stpSuite $map "" \
	${map}Array                           \
	$framesize                          \
	[stpSuite cget -numtrials]         \
	false                               \
        1                                   \
        stpConvergence

    if [initMaxRate ${map}Array maxRate $framesize userRate [stpSuite cget -percentMaxRate]] {
        set status $::TCL_ERROR
        return $status
    }

    if [configureStpProtocols ${map}Array] {
        errorMsg "***** Error configuring $usedProtocol protocol..."
        return $::TCL_ERROR
    }

    # write the streams
    if [writeStpConvergenceStreams ${map}Array] {
        return $::TCL_ERROR
    }

    return $status;
}

#############################################################################
# stpConvergence::AlgorithmBody()
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
proc stpConvergence::AlgorithmBody {args} {
    variable map
    global ${map}Array
    global testConf

    variable usedProtocol
    variable txPortList
    variable rxPortList
    variable txRxPorts
    variable userRate
    variable framesize
    variable trial
    variable txNumFrames
    variable txStreamFrameRate
    variable totalTxNumFrames
    variable totalRxNumFrames
    variable thruputRate
    variable resultArray
    variable maxRate
    variable fileIdArray


    set status $::TCL_OK

    # Start STP Server
    logMsg "Starting $usedProtocol..."
    if [startStpServer txRxPorts] {
        errorMsg "Error Starting $usedProtocol!"
        return $::TCL_ERROR
    }

    # Confirm peer established
    if {[confirmStpEstablished]} {
        return $::TCL_ERROR
    }

    if {[checkInitialStpStatus ${map}Array $usedProtocol]} {
        errorMsg "***Error checking $usedProtocol status.\n$usedProtocol could not reach initial desired status.\nToo high Root Priority or other configuration error."
        return $::TCL_ERROR
    }

    if {[prepareToTransmit ${map}Array]} {
        errorMsg "**** Error preparing to trasmit stream."
        return $::TCL_ERROR
    }

    set allPortList [getAllPorts ${map}Array]

    if {[ixClearTimeStamp ${map}Array] != 0} {
        errorMsg "**** Couldn't clear timestamps for [list $rxMap $txPort]"
        return $::TCL_ERROR
    }

    foreach port $allPortList {
        scan $port "%d %d %d" c l p
        if {[startPortTx $c $l $p]} {
            errorMsg "**** Error starting to trasmit stream."
            return $::TCL_ERROR
        }
    }

    set dutDelay $testConf(dutDelay)
    set duration [stpSuite cget -duration]
    set diff     [expr $duration - $dutDelay]
    logMsg "Trasmitting frames for $duration seconds.\nWaiting $dutDelay seconds to trigger convergence cause..."
    writeWaitForTransmit $dutDelay

    if {[generateStpConvergence rxPortList [stpSuite cget -convergenceCause]]} {
        errorMsg "***** Error generating cause of convergence..."
    }

    writeWaitForTransmit $diff

    foreach port $allPortList {
        scan $port "%d %d %d" c l p
        if {[stopPortTx $c $l $p]} {
            errorMsg "**** Error starting to trasmit stream."
            return $::TCL_ERROR
        }
    }

    waitForResidualFrames [stpSuite cget -waitResidual]                 

    stpConvergence::AlgorithmMeasure

    return $status
}

########################################################################################
# Procedure: confirmStpEstablished
#
# Description: This command checks if STP protocol is present
#
# Argument(s):
# TxRxArray       - map, ie. many2manyArray
# write           - flag to commit or not commit the changes
#
# Results :       0 : No error found
#                 1 : Error found
#         
########################################################################################
proc stpConvergence::confirmStpEstablished {} \
{
    variable rxPortList
    variable usedProtocol

    set retCode 0

    if {[setRootPriority rxPortList 61440]} {
        errorMsg "*** Warning: could not update root priority... "
    }
    

    if [confirmStpSessionUp rxPortList [stpSuite cget -helloInterval] $usedProtocol] {
        errorMsg "*** $usedProtocol sessions could not be established. The delay is not long enough or there is a network problem."
        stpCleanUp rxPortList no
        set retCode 1
        return $retCode
    }

    if {[setRootPriority rxPortList [stpSuite cget -rootPriority]]} {
        errorMsg "*** Error updating root priority."
        set retCode 1
        return $retCode
    }

#     set delay 5
#
#     logMsg "Waiting $delay secs for the DUT to settle down."
#     writeWaitForPause "Waiting $delay secs for the DUT to settle down." $delay

    return $retCode
}

########################################################################################
# Procedure: configureStpProtocols
#
# Description: This command Configures STP for convergence test.
#
# Argument(s):
# TxRxArray       - map, ie. many2manyArray
# write           - flag to commit or not commit the changes
#
# Results :       0 : No error found
#                 1 : Error found
#         
########################################################################################
proc stpConvergence::configureStpProtocols {TxRxArray} \
{   
    upvar $TxRxArray     txRxArray

    variable usedProtocol
    variable costIndex

    set retCode 0
    set index 0
    set costIndex 0
    set rxPortList         [getRxPorts  txRxArray]
    set txPortList         [getTxPorts  txRxArray]
    set portList           [getAllPorts txRxArray]

    # Should not happen ever
     if {[llength $txPortList]!=1} {
         errorMsg "*** This test requires one TX port!"
         set retCode 1
         return $retCode
     }

     if {[llength $rxPortList]!=2} {
         errorMsg "*** This test requires 2 RX ports!"
         set retCode 1
         return $retCode
     }

    logMsg "\n**** Framesize [stpSuite cget -framesize] ****\nConfiguring $usedProtocol protocols..."
    set index 1
    # Configuring TX port. There is only one tx port
    # Configuring RX ports. There are only 2 rx ports
    set portType 0;# this is for TX
    foreach port $portList {
            scan $port "%d %d %d" c l p  

            set portType [expr ([lsearch $txPortList $port]>=0) ? 0 : 1 ]

            if {[stpServer select $c $l $p]} {
                errorMsg "***Error $usedProtocol select on port [getPortId $c $l $p]"
                set retCode 1
                return $retCode
            }

            stpServer clearAllBridges
            stpServer clearAllLans

            set count [stpSuite cget -macPerPort]

            if {$portType==1} {
                set startMacAddress "10:00:00:00:00:0A"
            } else {
                set startMacAddress "20:00:00:00:00:0B"
            }

            if {[addStpLan true $startMacAddress $count]} {
                errorMsg "***Error adding LAN for port [getPortId $c $l $p]"
                set retCode 1
                return $retCode
            }

            # add bridge only for RX
            if {$portType==1} { 

                set description  [format "%02d:%02d ProtocolInterface - 1" $l $p]
                if {[addStpInterface true $description stpInterfacePointToPoint]} {
                    errorMsg "***Error adding STP interface on port [getPortId $c $l $p]"
                    set retCode 1
                    return $retCode
                }

                if {[stpSuite cget -bridgingProtocol]=="STP"} {
                    set bridgeMode     bridgeStp
                } else {
                    set bridgeMode     bridgeRstp
                }
                set bridgeMac      "01:00:00:00:00:0$index"
                set bridgeId       0
                set bridgePriority 32768
                set rootMac        [stpSuite cget -rootMacAddress]
                set rootId         0
                set rootPriority   [stpSuite cget -rootPriority]
                set rootCost       [getNextStpCost]                  ;# first port cost is minimum, second is maximum
                logMsg "Setting Root Cost on emulated bridge from port [getPortId $c $l $p] to $rootCost"
                set helloInterval  [expr 1000*[stpSuite cget -helloInterval]] ;# transform to ms ; the user sets them is sec
                set forwardDelay   [expr 1000*[stpSuite cget -forwardDelay]]
                set maxAge         [expr 1000*[stpSuite cget -maxAge]]

                if {[addStpBridge true $bridgeMode $bridgeMac $bridgeId \
                    $bridgePriority $rootMac $rootId $rootPriority $rootCost $helloInterval $forwardDelay $maxAge]} {

                    errorMsg "***Error adding bridge to port [getPortId $c $l $p]"
                    set retCode 1
                    return $retCode
                }           
            }

            if {[stpServer write]} {
                errorMsg "**** Error writing to hardware STP server"
                set retCode 1
                return $retCode
            }
                 
            incr index

    }

    if [enableProtocolStatistics portList enableStpStats] {
        errorMsg "***** Error enabling STP statistics..."
        set retCode 1
        return $retCode
    }

    if [enableProtocolServer portList stp noWrite] {
        errorMsg "***** Error enabling STP server..."
        set retCode 1
        return $retCode
    }

    return $retCode
}

########################################################################################
# Procedure: generateStpConvergence
#
# Description: This command generates the cause of convergence
#
# Argument(s):
# RxPortList      - RX port list
# TxPort          - TX port
# cause           - the cause of convergence
#
# Results :       0 : No error found
#                 1 : Error found
#         
########################################################################################
proc stpConvergence::generateStpConvergence {RxPortList cause} \
{
    upvar $RxPortList rxPortList

    variable map
    global ${map}Array

    set retCode       0
    set index         0

    logMsg "Cause of convergence: $cause .\n"
    foreach rxMap $rxPortList {
        scan $rxMap "%d %d %d" c l p

        switch $cause {
            "No BPDU" {
                if {$index<1} {

                     if {[stopPortTx $c $l $p]} {
                         errorMsg "**** Error stopping to trasmit stream."
                         return $::TCL_ERROR
                     }


                     if {[stpServer select $c $l $p]} {
                         set retCode 1
                         return $retCode
                     }

                     if {[stpServer getBridge bridge1]} {
                         errorMsg "**** Error getting first bridge on [getPortId $c $l $p]"
                         set retCode 1
                         return $retCode
                     }

                     stpBridge config -enable false

                     if {[stpServer setBridge bridge1]} {
                         errorMsg "**** Error updating bridge on [getPortId $c $l $p]"
                         set retCode 1
                         return $retCode
                     }


                     if {[stpServer write]} {
                         errorMsg "**** Error writing protocol server on [getPortId $c $l $p]"
                         set retCode 1
                         return $retCode
                     }

                } else {
                    if {[ixClearTimeStamp ${map}Array] != 0} {
                        errorMsg "**** Couldn't clear timestamps for [list $rxMap $txPort]"
                        return 1
                    }
                }
                
            }
            "Link Failure" {
                if {$index>0} {
                    # only for BR1. The second port must remain with same settings
                    return $retCode
                }
                if {[port get $c $l $p]} {
                    errorMsg "**** Error getting data from port [getPortId $c $l $p]"
                    set retCode 1
                    return $retCode
                }
                port config -enableSimulateCableDisconnect true
                if {[port set $c $l $p]} {
                    errorMsg "**** Error setting data on port [getPortId $c $l $p]"
                    set retCode 1
                    return $retCode
                }
                if {[port write $c $l $p]} {
                    errorMsg "**** Error writing data on port [getPortId $c $l $p]"
                    set retCode 1
                    return $retCode
                }
            }
            "Root Cost" -
            default {
                if {[stpServer select $c $l $p]} {
                    set retCode 1
                    return $retCode
                }

                if {[stpServer getFirstBridge]} {
                    set retCode 1
                    return $retCode
                }

                set rootCost [getNextStpCost 0]
                stpBridge config -rootCost $rootCost
                logMsg "Setting Root Cost on emulated bridge from port [getPortId $c $l $p] to $rootCost"
                # second Bridge will be root now, so rootCost will swap
                incr rootCost -2

                if {[stpBridge generateTopologyChange]} {
                    errorMsg "**** Error generating Topology Change on bridge from port [getPortId $c $l $p]"
                    set retCode 1
                    return $retCode
                }

                if {[stpServer updateBridgeParameters]} {
                    set retCode 1
                    return $retCode
                }
                if {[stpServer write]} {
                    set retCode 1
                    return $retCode
                }
            }

        } ;# switch

        incr index
    }

    return $retCode;
}

#################################################################################
# Procedure: writeStpConvergenceStreams
#
# Description: This command configures and writes the stream for STP convergence test
#
#################################################################################
proc stpConvergence::writeStpConvergenceStreams {TxRxArray {numFrames 0}} \
{
    variable txNumFrames
    variable txStreamFrameRate

    upvar $TxRxArray            txRxArray

    set txPorts                 [getTxPorts txRxArray]
    set rxPorts                 [getRxPorts txRxArray]
    set portList                [getAllPorts txRxArray]

    set index                   0
    set retCode                 0       
    set framesize	        [stpSuite cget -framesize]

    filterPallette              setDefault
    filter                      setDefault
    udf                         setDefault

    set packetGroupIdOffset     42 
    set packetGroupOffset       48   
    set sequenceNumberOffset    44
    set dataIntegrityOffset     48

    set genericPattern          {AA AA AA AA}
    set preambleSize            8

    if {![info exists udfList]} {
        set udfList {1 2 3 4}
    }

    disableUdfs $udfList

    stream setDefault
    stream config -framesize         $framesize
    stream config -enableTimestamp   true

    stream config -enableIbg         false
    stream config -enableIsg         false

    stream config -rateMode          usePercentRate
    stream config -gapUnit           gapNanoSeconds

    if {[protocol cget -ethernetType] == $::ethernetII} {
        stream config -frameType [advancedTestParameter cget -streamFrameType]
    }

    set streamGroup 0
    set streamID    1

    logMsg "Configuring streams..."

    # there is only one port in list...
    foreach port $portList {
        scan $port "%d %d %d" c l p

        if {[lsearch $txPorts $port]>-1} {
            set isTx 1
        } else {
            set isTx 0
        }

        if {$isTx==1} {
            set txNumFrames($c,$l,$p)         0
            set txStreamFrameRate($c,$l,$p)   0.
        } else {
            set rxStreamFrameRate($c,$l,$p)   0.
        }

        # get the mac & Ip addresses for the da/sa
        if [port get $c $l $p] {
            errorMsg "Port [getPortId $c $l $p] not configured yet!"
            set retCode 1
        }

        if {$isTx==1} {
            stream config -percentPacketRate [stpSuite cget -percentMaxRate]
            stream config -da                "10:00:00:00:00:0A"
            stream config -sa                "20:00:00:00:00:0B"
            stream config -name              "Tx->[stream cget -da]"
        } else {
            set learnPercentRate [expr double([learn cget -rate])/[calculateMaxRate $c $l $p [learn cget -framesize]]*100.]
            stream config -percentPacketRate $learnPercentRate
            stream config -da                "20:00:00:00:00:0B"
            stream config -sa                "10:00:00:00:00:0A"
            stream config -name              "LearnStream$c$l$p"
#            stream config -numSA             1
        }
        stream config -saRepeatCounter   increment
        stream config -daRepeatCounter   increment
        stream config -numSA             [stpSuite cget -macPerPort]
        stream config -numDA             [stpSuite cget -macPerPort]
#        stream config -numSA             1
        stream config -numFrames         [stpSuite cget -macPerPort]
        stream config -preambleSize      $preambleSize

        ##### Stream for generating traffic to the routes #####

        if [stream set $c $l $p $streamID] {
            errorMsg "Error setting stream $streamID for network on port [getPortId $c $l $p]"
            set retCode 1
        }

        if [stream get $c $l $p $streamID] {
            errorMsg "Error getting stream $streamID from port [getPortId $c $l $p]"
            set retCode 1
        }

        # note - we set the stream twice because we need to get the conf'd framerate for calc'ing the duration
        set framerate   [mpexpr double([mpexpr 1.*[stream cget -framerate]])]
#        logMsg "GETTING FROM STREAM .. Framerate = $framerate"
        set loopCount 1

        #calculate the duration 
        set loopCount    [mpexpr round (double ($framerate)/[stream cget -numFrames] * [stpSuite cget -duration])]

        if { $loopCount == 0} {
            set loopCount 1
        }

        if {$isTx==1} {
            set txNumFrames($c,$l,$p)       [mpexpr $loopCount*[stream cget -numFrames]]
            set txStreamFrameRate($c,$l,$p) $framerate
        } else {
            set txStreamFrameRate($c,$l,$p) 0.
            set rxStreamFrameRate($c,$l,$p) $framerate
        }

        stream config -dma          firstLoopCount
        stream config -loopCount    $loopCount

        set packetGroupIdList     {}
        set packetGroupId         1
        lappend packetGroupIdList [value2Hexlist $packetGroupId 2]

        packetGroup setDefault

        setupPacketGroup $framesize $c $l $p
        
        packetGroup config -signatureOffset	           $packetGroupOffset
        packetGroup config -groupIdOffset	           $packetGroupIdOffset  
        packetGroup config -signature	                   $genericPattern
        packetGroup config -insertSequenceSignature        $::true
        packetGroup config -sequenceNumberOffset           $sequenceNumberOffset
        packetGroup config -allocateUdf                    $::false

        if [packetGroup setTx $c $l $p $streamID] {
            errorMsg "Error setting Tx packetGroup on [getPortId $c $l $p]"
            set status $::TCL_ERROR
        }

        dataIntegrity config -signatureOffset $packetGroupOffset
        dataIntegrity config -signature       $genericPattern
        dataIntegrity config -insertSignature true
        dataIntegrity config -enableTimeStamp true

        if [dataIntegrity setTx $c $l $p $streamID] {
            errorMsg "Error setting Tx dataIntegrity on [getPortId $c $l $p]"
            set status $::TCL_ERROR
        }

        if [stream set $c $l $p $streamID] {
            errorMsg "Error setting stream $streamID for network on port [getPortId $c $l $p]"
            set retCode 1
        }
        if [stream get $c $l $p $streamID] {
            errorMsg "Error getting stream $streamID from port [getPortId $c $l $p]"
            set retCode 1
        }
    };# TX port

    logMsg "Configuring RX filters..."
    # for every rx ports (2)
    foreach rxPort $rxPorts {
        scan $rxPort "%d %d %d" rx_c rx_l rx_p

        # set up the pattern filter
        filterPallette config -pattern1		$genericPattern
        filterPallette config -patternMask1	{00 00 00 00}
        filterPallette config -patternOffset1	$packetGroupOffset

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

        setupPacketGroup $framesize $rx_c $rx_l $rx_p 0 $packetGroupIdOffset
        packetGroup config -signatureOffset             $packetGroupOffset
        packetGroup config -groupIdOffset               $packetGroupIdOffset
        packetGroup config -signature                   $genericPattern
        packetGroup config -sequenceNumberOffset        $sequenceNumberOffset

        if [packetGroup setRx $rx_c $rx_l $rx_p] {
            errorMsg "Error setting Rx packetGroup on [getPortId $rx_c $rx_l $rx_p]"
            set status $::TCL_ERROR
        }

        dataIntegrity config -signatureOffset $packetGroupOffset
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
    } ; # for RX

    if {$retCode == 0} {
        adjustOffsets txRxArray
        set retCode [writeConfigToHardware txRxArray]
    }
    return $retCode
}

#############################################################################
# stpConvergence::TrialCleanUp()
#
# DESCRIPTION
# This procedure resets common code elements needed at the end of a trial.
#
# RETURNS:  
# status      TCL_OK     - on success
#             TCL_ERROR  - on failure
#
###
proc stpConvergence::TrialCleanUp {} {
    variable status
    variable map
    variable rxPortList
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
# stpConvergence::AlgorithmCleanup()
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
proc stpConvergence::AlgorithmCleanUp {} {
    variable status
    variable map
    variable rxPortList
    global ${map}Array

    set status $::TCL_OK
     
    if { [protocolCleanUp ${map}Array stp yes verbose stpSuite] } {
        errorMsg "Error cleaning up the protocols."
        set status $::TCL_ERROR
    }

    if {[stpSuite cget -convergenceCause]=="Link Failure"} {
        set rxPort1 [lindex $rxPortList 0]
        scan $rxPort1 "%d %d %d" c l p

        if {[port get $c $l $p]} {
            errorMsg "**** Error getting data from port [getPortId $c $l $p]"
            set status $::TCL_ERROR
        }

        set portStatus [port cget -enableSimulateCableDisconnect]

        if {$portStatus==1} {
            port config -enableSimulateCableDisconnect false
            if {[port set $c $l $p]} {
                errorMsg "**** Error setting data on port [getPortId $c $l $p]"
                set status $::TCL_ERROR
            }
            if {[port write $c $l $p]} {
                errorMsg "**** Error writing data on port [getPortId $c $l $p]"
                set status $::TCL_ERROR
            }
        }
    }

    cleanUpStpGlobals

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
proc stpConvergence::ConfigValidate {} \
{
    variable txRxArray
    variable stpPorts
    set status $::TCL_OK
    set testCmd stpSuite

    set type        [map cget -type]
    global          [format "%sArray" $type] 
    copyPortList    [format "%sArray" $type] txRxArray

    #repeated frame sizes are eliminated from the list if there are any
    configValidation::RemoveDuplicatesFromFramesizeList stpSuite
    
    #validate framesizeList
    if { ![configValidation::ValidateFrameSizeList  stpSuite]} {
        return $::TCL_ERROR
    }

    if {[validateFramesizeList [stpSuite cget -framesizeList]]} {
        logMsg "** ERROR: Some frame sizes are incompatible with selected protocols"
        return -code error 
    }

    #validate initial rate
    if { ![configValidation::ValidateInitialRate stpSuite]} {
        set status $::TCL_ERROR
         return $status
    }

    #common validatation to all the tests
    if {![configValidation::ValidateCommon stpSuite]} {
       set status $::TCL_ERROR
         return $status
    }

    if { [isMacAddressValid [stpSuite cget -rootMacAddress]] == $::TCL_ERROR } {
        errorMsg "**** WARNING: Root MAC Address is not a valid MAC address."
        return $::TCL_ERROR
    }

    set stpPorts    [getAllPorts txRxArray]

    if {[validateFeatureSet $stpPorts] == $::TCL_ERROR} {
        return $::TCL_ERROR 
    }

    return $status

}

########################################################################################
# Procedure:    stpConvergence::validateFeatureSet
#
# Description:  Verifies that the given ports possess the needed features.
#
# Argument(s):  portList
#
# Results :     TCL_OK or TCL_ERROR
#   
########################################################################################
proc stpConvergence::validateFeatureSet {portList {verbose true}} \
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
    }

    return $status
}

########################################################################
# stpConvergence::WriteResultsCSV()
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
proc stpConvergence::WriteResultsCSV {} {
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

    if { [stpSuite cget -framesizeList] == {} } {
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

    puts $csvFid "Trial,Frame Size (bytes),Tx Port,Rx Port,Tx Count,Rx Count,Tx Tput (fps),Tx Tput (%),\
    Conv Time: Packet Loss Method (nsec),Conv Time: Timestamps Method (nsec),Conv Frame Loss,Conv Frame Loss (%)"

    for {set trial 1} {$trial <= [stpSuite cget -numtrials] } {incr trial} {
        foreach framesize [lsort -dictionary [stpSuite cget -framesizeList]] {
             foreach txPort $txPortList {
                 set txFlag([join $txPort ,]) 0
             }

             foreach txMap [lnumsort [array names txRxArray]] {
                scan $txMap "%d,%d,%d" tx_c tx_l tx_p 

                foreach rxPort $rxPortList {
                    set rxFlag([join $rxPort ,]) 0
                }

                foreach rxMap [lnumsort $txRxArray($txMap)] {
                    scan [join $rxMap] "%d %d %d" rx_c rx_l rx_p

                    set count [lsearch [getAllPorts ${map}Array] $rxMap]

                        if {$txFlag($tx_c,$tx_l,$tx_p) == 0} {
                            set txPort         [getPortString $tx_c $tx_l $tx_p]

                            set txCount        $resultArray($trial,$framesize,1,$tx_c,$tx_l,$tx_p,TXtransmitFrames)
                            set percentTput    $resultArray($trial,$framesize,1,$tx_c,$tx_l,$tx_p,TXpercentTput)
                            set tput           $resultArray($trial,$framesize,1,$tx_c,$tx_l,$tx_p,TXthroughput)
                            set convTimeLoss   $resultArray($trial,$framesize,1,$tx_c,$tx_l,$tx_p,ConvergenceMetricLoss)
                            set convTimeTime   $resultArray($trial,$framesize,1,$tx_c,$tx_l,$tx_p,ConvergenceMetricTime)

                            set totalFrameLoss $resultArray($trial,$framesize,1,$rx_c,$rx_l,$rx_p,totalFrameLoss)
                            set percentLoss    $resultArray($trial,$framesize,1,$rx_c,$rx_l,$rx_p,percentLoss)

                            set txFlag($tx_c,$tx_l,$tx_p) 1
                        } else {
                            set totalFrameLoss ""
                            set percentLoss    ""
                            set convTimeLoss   ""
                            set convTimeTime   ""
                            set txPort         ""
                            set txCount        ""
                            set percentTput    ""
                            set tput           ""
                        }

                        set rxCount        $resultArray($trial,$framesize,1,$rx_c,$rx_l,$rx_p,RXreceiveFrames)
                        set rxPort         [getPortString $rx_c $rx_l $rx_p]

                        puts $csvFid "$trial,$framesize,$txPort,$rxPort,$txCount,$rxCount,$tput,$percentTput,$convTimeLoss,\
                                      $convTimeTime,$totalFrameLoss,$percentLoss"
                }
            } ;# foreach tx
        }
   }

   closeMyFile $csvFid
}

#############################################################################
# stpConvergence::AlgorithmMeasure()
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
proc stpConvergence::AlgorithmMeasure {} {
    variable trial
    variable framesize
    variable thruputRate;
    variable txNumFrames;
    variable totalTxNumFrames
    variable totalRxNumFrames
    variable maxRate
    variable txPortList
    variable rxPortList
    variable resultArray
    variable fileIdArray
    variable txStreamFrameRate

    variable map
    global ${map}Array
    global testConf

    copyPortList ${map}Array txRxArray

    set status $::TCL_OK;

    set preferredPort       [lindex $rxPortList 0]
    set notPreferredPort    [lindex $rxPortList 1]
    set txPort              [lindex $txPortList 0]
    scan $preferredPort     "%d %d %d" prx_c  prx_l  prx_p
    scan $notPreferredPort  "%d %d %d" nprx_c nprx_l nprx_p
    scan $txPort            "%d %d %d" tx_c   tx_l   tx_p

    set rxNumFrames($nprx_c,$nprx_l,$nprx_p)    0
    set rxNumFrames($prx_c,$prx_l,$prx_p)       0

    logMsg "Saving results for Trial $trial Framesize $framesize Measurement type [stpSuite cget -measurementType]..."

    stats::collectTxStats [getTxPorts ${map}Array] txNumFrames txActualFrames totalTxNumFrames
    collectRxStats        [getRxPorts ${map}Array] rxNumFrames totalRxNumFrames

    set resultByPacketLoss 0
    set resultByTimestamp  0

    if {$rxNumFrames($prx_c,$prx_l,$prx_p) > 0} {

        set dutDelay $testConf(dutDelay)
        set duration [stpSuite cget -duration]
        set diff     [expr $duration - $dutDelay]

        set txPortSpeed [mpexpr [getThePortSpeed $tx_c $tx_l $tx_p] * 1000 * 1000]
        set frameBits   [expr   ($framesize+20) * 8]
        set fps         [mpexpr double(1.*$txPortSpeed / $frameBits)]
        set pTput       [mpexpr double(1.*[stpSuite cget -percentMaxRate]/100)]

        #logMsg "txPortSpeed=$txPortSpeed frameBits=$frameBits fps=$fps pTput=$pTput"
        set teorethicTxFrameRate [mpexpr round($fps*$pTput)]
        set teorethicTxFrames    [mpexpr $teorethicTxFrameRate*$duration]

        set pPortSpeed  [mpexpr [getThePortSpeed $prx_c $prx_l $prx_p] * 1000 * 1000] ;#bits
        if {$pPortSpeed>$txPortSpeed} {
            set pPortSpeed      $txPortSpeed
        }
        set frameBits   [expr   ($framesize+20) * 8]
        set fps         [mpexpr double(1.*$pPortSpeed / $frameBits)]
        set pTput       [mpexpr double(1.*[stpSuite cget -percentMaxRate]/100)]

        #logMsg " pPortSpeed=$pPortSpeed frameBits=$frameBits fps=$fps pTput=$pTput"
        set teorethicRxFrameRate($prx_c,$prx_l,$prx_p)    [mpexpr round($fps*$pTput)]
        set teorethicRxFrames($prx_c,$prx_l,$prx_p)       [mpexpr $teorethicRxFrameRate($prx_c,$prx_l,$prx_p)*$dutDelay]

        set npPortSpeed [mpexpr [getThePortSpeed $nprx_c $nprx_l $nprx_p] * 1000 * 1000]
        if {$npPortSpeed>$txPortSpeed} {
            set npPortSpeed      $txPortSpeed
        }
        set frameBits   [expr   ($framesize+20) * 8]
        set fps         [mpexpr double(1.*$npPortSpeed / $frameBits)]
        set pTput       [mpexpr double(1.*[stpSuite cget -percentMaxRate]/100)]

        #logMsg "npPortSpeed=$npPortSpeed frameBits=$frameBits fps=$fps pTput=$pTput"
        set teorethicRxFrameRate($nprx_c,$nprx_l,$nprx_p) [mpexpr round($fps*$pTput)]
        set teorethicRxFrames($nprx_c,$nprx_l,$nprx_p)    [mpexpr $teorethicRxFrameRate($nprx_c,$nprx_l,$nprx_p)*$diff]

        #logMsg "T RxFR($prx_c,$prx_l,$prx_p) = $teorethicRxFrameRate($prx_c,$prx_l,$prx_p)"
        #logMsg "T RxFR($nprx_c,$nprx_l,$nprx_p) = $teorethicRxFrameRate($nprx_c,$nprx_l,$nprx_p)"
        #logMsg "T F = $teorethicRxFrames($prx_c,$prx_l,$prx_p) actual = $rxNumFrames($prx_c,$prx_l,$prx_p)"
        #logMsg "T F = $teorethicRxFrames($nprx_c,$nprx_l,$nprx_p) actual = $rxNumFrames($nprx_c,$nprx_l,$nprx_p)"
        #logMsg "teorethicTxFrameRate=$teorethicTxFrameRate actualTxFrameRate=$txStreamFrameRate($tx_c,$tx_l,$tx_p)"
        #logMsg "teorethicTxFrames=$teorethicTxFrames actualTotalTxFrames=$totalTxNumFrames"

        set nano               1000000000
        if {[stpSuite cget -convergenceCause]=="No BPDU"} {
            set wrongDestFrames     [mpexpr $rxNumFrames($prx_c,$prx_l,$prx_p) - $teorethicRxFrames($prx_c,$prx_l,$prx_p)]
            if {$wrongDestFrames<0} {
                logMsg "\n**** WARNING !!! There is packet loss. Results are not accurate!"
                logMsg "There should be at least $teorethicRxFrames($prx_c,$prx_l,$prx_p) frames received on port [getPortId $prx_c $prx_l $prx_p]."
                logMsg "Lower the throughput rate for better results."
                set wrongDestFrames 0
            }
        } else {
            set wrongDestFrames     0
        }

        set convLostFrames     [mpexpr $totalTxNumFrames - $totalRxNumFrames + $wrongDestFrames]
        set resultByPacketLoss [mpexpr round([mpexpr $convLostFrames*$nano/$txStreamFrameRate($tx_c,$tx_l,$tx_p)])]
        #logMsg "teorethicRxFrames($nprx_c,$nprx_l,$nprx_p)=$teorethicRxFrames($nprx_c,$nprx_l,$nprx_p) wrongDestFrames=$wrongDestFrames convLostFrames=$convLostFrames\nresultByPacketLoss=$resultByPacketLoss\n"

        set lastTimeStamp1          [getTimeStamp $prx_c $prx_l $prx_p  lastTimeStamp]
        set firstTimeStamp1         [getTimeStamp $prx_c $prx_l $prx_p firstTimeStamp]
        set lastTimeStamp2          [getTimeStamp $nprx_c $nprx_l $nprx_p  lastTimeStamp]
        set firstTimeStamp2         [getTimeStamp $nprx_c $nprx_l $nprx_p firstTimeStamp]
        set wrongFramesTime         [mpexpr round($wrongDestFrames*$nano/$teorethicRxFrameRate($prx_c,$prx_l,$prx_p))]
        if {[stpSuite cget -convergenceCause]=="Link Failure"} {
            set resultByTimestamp       [mpexpr $firstTimeStamp2 - $dutDelay*$nano] 
        } else {
            set resultByTimestamp       [mpexpr $firstTimeStamp2 - $lastTimeStamp1 + $wrongFramesTime] 
        }

        #logMsg "FIRST TIME STAMP 1  = $firstTimeStamp1 ns."
        #logMsg "LAST  TIME STAMP 1  = $lastTimeStamp1 ns."
        #logMsg "FIRST TIME STAMP 2  = $firstTimeStamp2 ns."
        #logMsg "LAST  TIME STAMP 2  = $lastTimeStamp2 ns."
        #logMsg "\nWRONG DEST TIME     = $wrongFramesTime ns.\n\nresultByTimeStamp=$resultByTimestamp"
        
        set realLostFrames          [mpexpr $totalTxNumFrames - $totalRxNumFrames]
        set lostFrames              [mpexpr $realLostFrames + $wrongDestFrames]
        set percentLoss             [format "%6.4f" [mpexpr 1.*$lostFrames*100/$totalTxNumFrames]]

        if {[stpSuite cget -measurementType]=="First/Last Timestamps"} {
            set resultByPacketLoss "N/A"
        }

        if {[stpSuite cget -measurementType]=="Packet Loss"} {
            set resultByTimestamp  "N/A"
        }
    } else {
            set lostFrames          "N/A"
            set percentLoss         "N/A"
            set resultByPacketLoss  "N/A"
            set resultByTimestamp   "N/A"
    }



        foreach txMap $txPortList {
            scan $txMap "%d %d %d" tx_c tx_l tx_p
            set percentTput($tx_c,$tx_l,$tx_p) [format "%6.4f" [mpexpr 1.*$txStreamFrameRate($tx_c,$tx_l,$tx_p)*100/$maxRate($tx_c,$tx_l,$tx_p)]]
            set resultArray($trial,$framesize,1,$tx_c,$tx_l,$tx_p,TXpercentTput)      $percentTput($tx_c,$tx_l,$tx_p)
            set resultArray($trial,$framesize,1,$tx_c,$tx_l,$tx_p,TXthroughput)       $txStreamFrameRate($tx_c,$tx_l,$tx_p)
            set resultArray($trial,$framesize,1,$tx_c,$tx_l,$tx_p,TXtransmitFrames)   $totalTxNumFrames

            if {$rxNumFrames($nprx_c,$nprx_l,$nprx_p) < 1} {
                set resultByPacketLoss "N/A"
                set resultByTimestamp  "N/A"
            }

            set resultArray($trial,$framesize,1,$tx_c,$tx_l,$tx_p,ConvergenceMetricLoss)  $resultByPacketLoss
            set resultArray($trial,$framesize,1,$tx_c,$tx_l,$tx_p,ConvergenceMetricTime)  $resultByTimestamp
        }

        foreach rxMap $rxPortList {
            scan $rxMap "%d %d %d" rx_c rx_l rx_p
            set resultArray($trial,$framesize,1,$rx_c,$rx_l,$rx_p,totalFrameLoss)     $lostFrames
            set resultArray($trial,$framesize,1,$rx_c,$rx_l,$rx_p,percentLoss)        $percentLoss
            set resultArray($trial,$framesize,1,$rx_c,$rx_l,$rx_p,RXreceiveFrames)    $rxNumFrames($rx_c,$rx_l,$rx_p)
        }

        printResults ${map}Array fileIdArray $trial $framesize

    return $status;
}

#############################################################################
# stpConvergence::printResults()
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
proc stpConvergence::printResults { TxRxArray FileIdArray trial framesize} {

    variable map
    variable usedProtocol
    global ${map}Array
    variable txPortList
    variable rxPortList
    variable resultArray

    upvar $TxRxArray            txRxArray
    upvar $FileIdArray          fileIdArray

    set defaultDelimiter    "  "

    set framesizeRateString "Frame Size: [stpSuite cget -framesize]"

    foreach fileType [array names fileIdArray] {
        foreach {fileID delimiter} $fileIdArray($fileType) {}
    }

    set title [format "%-10s%s%-10s%s%-10s%s%-10s%s%-10s%s%-10s%s%-36s%s%-36s%s%-15s%s%-19s" \
            "Tx Port"	          $delimiter \
            "Rx Port"		  $delimiter \
            "Tx Count"		  $delimiter \
            "Rx Count"            $delimiter \
            "Tput (fps)"	  $delimiter \
            "Tput (%)"            $delimiter \
            "Conv Time: Packet Loss Method (nsec)"	  $delimiter \
            "Conv Time: Timestamps Method (nsec)"	  $delimiter \
            "Conv Frame Loss"     $delimiter \
            "Conv Frame Loss (%)"  ]

    foreach fileType [array names fileIdArray] {
        foreach {fileID delimiter} $fileIdArray($fileType) {}
        puts $fileID "******* TRIAL $trial, framesize: $framesize - $usedProtocol Convergence *******\n\n"
        puts $fileID $title
        puts $fileID [stringRepeat "*" [expr [string length $title] + 10]]
    }

    logMsg "\n$title"
    logMsg "[stringRepeat "*" [expr [string length $title]]]"

    foreach txPort $txPortList {
        set txFlag([join $txPort ,]) 0
    }
    foreach fileType [array names fileIdArray] {
        foreach {fileID delimiter} $fileIdArray($fileType) {}
        foreach txPort [lnumsort [array names txRxArray]] {
            scan $txPort "%d,%d,%d" tx_c tx_l tx_p 

            foreach rxPort $rxPortList {
                set rxFlag([join $rxPort ,]) 0
            }

            foreach rxPort [lnumsort $txRxArray($txPort)] {
                scan $rxPort "%d %d %d" rx_c rx_l rx_p

                set count [lsearch [getAllPorts txRxArray] $rxPort]

                    if {$txFlag($tx_c,$tx_l,$tx_p) == 0} {
                        set txPort         [getPortString $tx_c $tx_l $tx_p]

                        set txCount        $resultArray($trial,$framesize,1,$tx_c,$tx_l,$tx_p,TXtransmitFrames)
                        set percentTput    $resultArray($trial,$framesize,1,$tx_c,$tx_l,$tx_p,TXpercentTput)
                        set tput           $resultArray($trial,$framesize,1,$tx_c,$tx_l,$tx_p,TXthroughput)
                        set convTimeLoss   $resultArray($trial,$framesize,1,$tx_c,$tx_l,$tx_p,ConvergenceMetricLoss)
                        set convTimeTime   $resultArray($trial,$framesize,1,$tx_c,$tx_l,$tx_p,ConvergenceMetricTime)

                        set totalFrameLoss $resultArray($trial,$framesize,1,$rx_c,$rx_l,$rx_p,totalFrameLoss)
                        set percentLoss    $resultArray($trial,$framesize,1,$rx_c,$rx_l,$rx_p,percentLoss)

                        set txFlag($tx_c,$tx_l,$tx_p) 1
                    } else {
                        set totalFrameLoss ""
                        set percentLoss    ""
                        set convTimeLoss   ""
                        set convTimeTime   ""
                        set txPort         ""
                        set txCount        ""
                        set percentTput    ""
                        set tput           ""
                    }

                    set rxCount        $resultArray($trial,$framesize,1,$rx_c,$rx_l,$rx_p,RXreceiveFrames)
                    set rxPort         [getPortString $rx_c $rx_l $rx_p]

                    puts $fileID [format "%-10s%s%-10s%s%-10s%s%-10s%s%-10s%s%-10s%s%-36s%s%-36s%s%-15s%s%-19s" \
                        $txPort                                   $delimiter \
                        $rxPort                                   $delimiter \
                        $txCount                                  $delimiter \
                        $rxCount                                  $delimiter \
                        $tput                                     $delimiter \
                        $percentTput                              $delimiter \
                        $convTimeLoss                             $delimiter \
                        $convTimeTime                             $delimiter \
                        $totalFrameLoss                           $delimiter \
                        $percentLoss                              ]

            }
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

                if {$txFlag($tx_c,$tx_l,$tx_p) == 0} {
                    set txPort         [getPortString $tx_c $tx_l $tx_p]

                    set txCount        $resultArray($trial,$framesize,1,$tx_c,$tx_l,$tx_p,TXtransmitFrames)
                    set percentTput    $resultArray($trial,$framesize,1,$tx_c,$tx_l,$tx_p,TXpercentTput)
                    set tput           $resultArray($trial,$framesize,1,$tx_c,$tx_l,$tx_p,TXthroughput)
                    set convTimeLoss   $resultArray($trial,$framesize,1,$tx_c,$tx_l,$tx_p,ConvergenceMetricLoss)
                    set convTimeTime   $resultArray($trial,$framesize,1,$tx_c,$tx_l,$tx_p,ConvergenceMetricTime)

                    set totalFrameLoss $resultArray($trial,$framesize,1,$rx_c,$rx_l,$rx_p,totalFrameLoss)
                    set percentLoss    $resultArray($trial,$framesize,1,$rx_c,$rx_l,$rx_p,percentLoss)

                    set txFlag($tx_c,$tx_l,$tx_p) 1
                } else {
                    set txPort         ""
                    set txCount        ""
                    set percentTput    ""
                    set tput           ""
                    set totalFrameLoss ""
                    set percentLoss    ""
                    set convTimeLoss   ""
                    set convTimeTime   ""
                }

                set rxCount            $resultArray($trial,$framesize,1,$rx_c,$rx_l,$rx_p,RXreceiveFrames)
                set rxPort             [getPortString $rx_c $rx_l $rx_p]

                logMsg [format "%-10s%s%-10s%s%-10s%s%-10s%s%-10s%s%-10s%s%-36s%s%-36s%s%-15s%s%-19s" \
                        $txPort                                   $delimiter \
                        $rxPort                                   $delimiter \
                        $txCount                                  $delimiter \
                        $rxCount                                  $delimiter \
                        $tput                                     $delimiter \
                        $percentTput                              $delimiter \
                        $convTimeLoss                             $delimiter \
                        $convTimeTime                             $delimiter \
                        $totalFrameLoss                           $delimiter \
                        $percentLoss                              ]
        }
    }

    logMsg "[stringRepeat "*" [expr [string length $title]]]\n"

    foreach fileType [array names fileIdArray] {
        foreach {fileID delimiter} $fileIdArray($fileType) {}
        puts $fileID [stringRepeat "*" [expr [string length $title] + 10]]
        puts $fileID "\n"
    }

}
#############################################################################
# stpConvergence::MetricsPostProcess()
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
proc stpConvergence::MetricsPostProcess {} {
    variable resultsDirectory;
    variable resultArray
    variable rxPortList
    variable txPortList
    variable groupIdList
    global testConf;

    set trialsPassed  0

    for {set trial 1} {$trial <= [stpSuite cget -numtrials] } {incr trial} {

	set percentLineRateList {};
	set frameRateList {};
	set dataRateList {};
        set convTimeLossList {};
        set convTimeTimeList {};

	foreach fs [lsort -dictionary [stpSuite cget -framesizeList]] {

		foreach txMap $txPortList {
		    scan $txMap "%d %d %d" tx_c tx_l tx_p

		    lappend percentLineRateList \
			$resultArray($trial,$fs,1,$tx_c,$tx_l,$tx_p,TXpercentTput);

		    set frameRate $resultArray($trial,$fs,1,$tx_c,$tx_l,$tx_p,TXthroughput);

		    lappend frameRateList $frameRate;

		    set dataRate  [mpexpr 8 * $fs * $frameRate];

		    lappend dataRateList $dataRate;

                    set convTimeLoss  $resultArray($trial,$fs,1,$tx_c,$tx_l,$tx_p,ConvergenceMetricLoss);
                    set convTimeTime  $resultArray($trial,$fs,1,$tx_c,$tx_l,$tx_p,ConvergenceMetricTime);

                    lappend convTimeLossList $convTimeLoss;
                    lappend convTimeTimeList $convTimeTime;
		};# loop over txPort list

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

        set resultArray($trial,maxConvergenceTimeLoss) [passfail::ListMax convTimeLossList]
        set resultArray($trial,maxConvergenceTimeTime) [passfail::ListMax convTimeTimeList]

    } ;# loop over trials
}

########################################################################
# Procedure: stpConvergence::countTxRxFrames
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
proc stpConvergence::countTxRxFrames {TxRxArray TxNumFrames TxRxNumFrames} {
    upvar $TxRxArray        txRxArray
    upvar $TxNumFrames      txNumFrames
    upvar $TxRxNumFrames    txRxNumFrames

    set status $::TCL_OK

    if [info exists txRxNumFrames] {
        unset txRxNumFrames
    }

    set numberModifier [expr {([stpSuite cget -advertiseRoutes]==1 && [stpSuite cget -advertiseNetworkRange]==1) ? 2 : 1}]

    foreach txMap [array names txRxArray] {
        scan $txMap "%d,%d,%d" tx_c tx_l tx_p

        set numRxPorts  [llength $txRxArray($tx_c,$tx_l,$tx_p)]
        set numStreams  [mpexpr $numRxPorts*[stpSuite cget -emulatedRoutersPerPortNumber]*$numberModifier]

        if {[stream get $tx_c $tx_l $tx_p $numStreams]} {
            errorMsg "Error getting stream $numStreams on [getPortId $tx_c $tx_l $tx_p]"
            set status 1
        }

        set loopcount   [stream cget -loopCount]
        set streamID 1

        foreach rxMap $txRxArray($tx_c,$tx_l,$tx_p) {
            scan [join $rxMap] "%d %d %d" rx_c rx_l rx_p

            for {set count 1} {$count <= [mpexpr [stpSuite cget -emulatedRoutersPerPortNumber]*$numberModifier] } {incr count} {
                if {[stream get $tx_c $tx_l $tx_p $streamID]} {
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

            }
        }

    }
    return $status
}

################################################################################
#
# stpConvergence::PassFailCriteriaEvaluateConvergence()
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
proc stpConvergence::PassFailCriteriaEvaluate {} {
    variable timeHash
    variable trialsPassed
    variable resultArray
    global testConf

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

    for {set trial 1} {$trial <= [stpSuite cget -numtrials] } {incr trial} {
        logMsg "*** Trial #$trial";

        set convTimeLoss $resultArray($trial,maxConvergenceTimeLoss); 
        set convTimeTime $resultArray($trial,maxConvergenceTimeTime); 

        set mType [stpSuite cget -measurementType]
        switch $mType {
            "Both" {
                if {$convTimeLoss>$convTimeTime} { #; choosing the max between them
                    set convTime $convTimeLoss
                } else {
                    set convTime $convTimeTime
                }
            }
            "Packet Loss" {
                set convTime $convTimeLoss
            }
            default {
                set convTime $convTimeTime
            }
        }

        set othertext ""
        if {$convTime!="N/A"} {
            if {[mpexpr $convTime <= [mpexpr $timeHash($testConf(timeUnit))*$testConf(passTimeValue)]]} {
                set result "PASS"
                set othertext "Convergence time = $convTime ns < PASS/FAIL time = $testConf(passTimeValue) $testConf(timeUnit)"
            } else {
                set result "FAIL"
                set othertext "Convergence time = $convTime ns > PASS/FAIL time = $testConf(passTimeValue) $testConf(timeUnit)";
            }
        } else {
            set result "FAIL"
        }

        if { $result == "PASS" } {
            incr trialsPassed
        }

        logMsg "*** $result\n$othertext\n";
    } ;# loop over trials

    logMsg "*** # Of Trials Passed: $trialsPassed";
    logMsg "***************************************"
}

################################################################################
#
# stpConvergence::OnCauseChange(args)
#
# DESCRIPTION:
# This procedure enables or disables certain measurement types for the selected
# cause of convergence
#
# ARGUMENTS
# args       - variable arguments
#
# RETURNS
# none
#
###
proc stpConvergence::OnCauseChange {parent propName args} {
    global convergenceCause
    global measurementType
    global stpParamsInvisibleFrameName

    if {$convergenceCause=="Link Failure"} {
        [$stpParamsInvisibleFrameName.measurementType subwidget listbox] delete 0 end
        $stpParamsInvisibleFrameName.measurementType insert end "Packet Loss"
        set measurementType "Packet Loss"
    } else {

        [$stpParamsInvisibleFrameName.measurementType subwidget listbox] delete 0 end
        foreach item {"First/Last Timestamps" "Packet Loss" "Both"} {
            $stpParamsInvisibleFrameName.measurementType insert end $item
        }
    }
}

################################################################################
#
# stpConvergence::PassFailEnable(args)
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
proc stpConvergence::PassFailEnable {args} {
    global passFailEnable;

    set state disabled;

    if {$passFailEnable} {

	set state enabled;
	set attributeList { passTimeValue timeUnit }

	renderEngine::WidgetListStateSet $attributeList $state;

    } else {
	set attributeList { passTimeValue timeUnit }
	renderEngine::WidgetListStateSet $attributeList $state;
    }
}

################################################################################
# stpConvergence::OnRootMacAddressUpdate (parent propName args)
#
# DESCRIPTION:
# This ON_INIT/ON_UPDATE procedure makes sure a valid MAC address is diplayed
# for 
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
proc stpConvergence::OnRootMacAddressUpdate {parent propName args} {

    set entryBox [$parent.$propName subwidget entry] 

    set macAddress "00:00:00:00:00:00"

    if {[stpConvergence::isMacAddressValid [$entryBox get]] == $::TCL_ERROR} {
        set validAddress $macAddress
    } else {
        set validAddress [$entryBox get]
    }

    $entryBox delete 0 end
    $entryBox insert 0 $validAddress

    bind $entryBox <FocusOut>   { stpConvergence::checkMacAddress %W 0 } 
    bind $entryBox <KeyRelease> { stpConvergence::checkMacAddress %W 0 } 
}

###############################################################################
# Procedure: checkMacAddress
#
# Description: Verify that the MAC address in the given entry field is valid.
#              If it is not, change the foreground text to red to signify
#              invalid.  Otherwise, make the foreground black.
#
# Arguments:
#    entry - the widget that holds the value to be checked.
#    isEmptyAllowed - A 0/1 value.  1 says that an empty value is allowed,
#                     0 says it is not.  0 is the default.
#   
###############################################################################
proc stpConvergence::checkMacAddress {entry {isEmptyAllowed 0} {args ""} } {

    set macAddress [$entry get]

    $entry configure -fg black

    if {$isEmptyAllowed && ($macAddress == "")} {
        # Acceptable, do nothing
    } else {
            if {[stpConvergence::isMacAddressValid $macAddress]==$::TCL_ERROR} {
                $entry configure -fg red
            }
    } 
}

###############################################################################
# Procedure:    isMacAddressValid
#
# Description:  Verify that the mac address is valid.
#
# Input:        macAddress:    address to validate
#
# Output:       TCL_OK if address is valid, else
#               TCL_ERROR
#
###############################################################################
proc stpConvergence::isMacAddressValid {macAddress} \
{
    set retCode $::TCL_ERROR

    if {[string length $macAddress]!=17} {
        set retCode $::TCL_ERROR
    } else {
    regsub -all { |:} $macAddress " " macAddress
    if {[llength $macAddress] == 6} {

    	set retCode $::TCL_OK
        foreach value $macAddress {
            if {[string length $value] == 2} {
                if {[regexp {[xdigit]} $value match]} {
                    set retCode $::TCL_ERROR
                    break
                }
            } else {
                set retCode $::TCL_ERROR
                break
            }
        }
    }
    }

    return $retCode
}

###############################################################################
# Procedure:    getNextStpCost
#
# Description:  Verify that the mac address is valid.
#
# Input:        macAddress:    address to validate
#
# Output:       TCL_OK if address is valid, else
#               TCL_ERROR
#
###############################################################################
proc stpConvergence::getNextStpCost {{where 1}} \
{
    variable costIndex
    variable rxPortList
    variable hashCost

    set index           0
    set min             100000000

    foreach rxPort $rxPortList {
        scan $rxPort "%d %d %d" c l p

        set speed [getThePortSpeed $c $l $p]

        if {[info exists hashCost($speed)]} {
            set cost $hashCost($speed)
        } else {
            set cost 2     ; # presume that link is 10G if don't know what it is
        }

        set ixCost($index) $cost

        if {$min>$cost} {
            set min $cost
        }
        incr index
    }

    if {$where==1} {
        if {$costIndex==0} {
            set value $min
        } else {
            set value [expr $min + $ixCost(0) - 1 ]
        }

        incr costIndex

        if {$costIndex>1} {
            set costIndex 1
        }
    } else {
        if {$costIndex==0} {
            set value $min
        } else {
            set value [expr $min + $ixCost(1) - 1 ]
        }

        incr costIndex -1

        if {$costIndex<0} {
            set costIndex 0
        }
    }

    return $value
}

###############################################################################
# Procedure:    getThePortSpeed
#
# Description:  Returns the speed of the port
#
# Input:
#
# c      chassis
# l      card
# p      port
#
# Output:       speed of port
#
###############################################################################
proc getThePortSpeed {c l p} {

        if {[port get $c $l $p]} {
            errorMsg "Can't read data from port [getPortId $c $l $p]"
            return 0
        }
        set speed [port cget -speed]

        return $speed
}
################################################################################
#
################################################################################
proc stpConvergence::WriteAggregateResultsCSV {args} {
}
