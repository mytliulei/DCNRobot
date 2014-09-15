############################################################################################
#
#   Copyright © 1997 - 2004 by IXIA.
#   All Rights Reserved.
#
# Description: This file contains the script for running OSPF route convergence test
#
#               For performing this test you need 3 ixia ports, one tx and 2 rx
#               1) Confogure the ospf routers, interface, route range on rx ports
#                   One of the routes with lower metric is preferred route. 
#                   (Both routers advertise the same route range)
#               2) Configure the stream
#               3) Start OSPF Server and confirm ospf neighbors are in full state.
#               4) Transmit data 
#               5) After (duration/2) seconds, the link of preferred route goes down. 
#               6) In the remaining transmit duration, the back up router should receive 
#                   data
#               7) Stop transmit data 
#               8) Stop OSPF server and collect the stats  
#               9) Number of packet loss determines the time that router was not available for 
#                  forwarding the packets 
#
############################################################################################

namespace eval ospfSuite {
}

set routeConvergence::xmdDef {
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
         <Source scope="results.csv" entity_name="ospfSuiteRouteConvergence" format_id=""/>
         <Source scope="info.csv" entity_name="ospfSuiteRouteConvergence_Info" format_id=""/>
      </Sources>
   </XMD>
}

proc routeConvergence::registerResultVars {} \
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
# routeConvergence::statList
# 
# DESCRIPTION:
# This table contains a list of collected metrics to be displayed in
# the Real Time Graphs and written to RealTime.csv file.
#  
###
set routeConvergence::statList \
   [list [list framesSent     [getTxPorts one2manyArray] "Tx Frames per second" "Tx Frames" 1e0]\
	     [list framesReceived [getRxPorts one2manyArray] "Rx Frames per second" "Rx Frames" 1e0]\
	     [list bitsSent       [getTxPorts one2manyArray] "Tx Kbps"              "Tx Kb"     1e3]\
	     [list bitsReceived   [getRxPorts one2manyArray] "Rx Kbps"              "Rx Kb"     1e3]\
	    ]



set routeConvergence::attributes {
    { 
	{ NAME              duration }
	{ BACKEND_TYPE      integer }
	{ DEFAULT_VALUE     20 }
	{ MIN               1 }
	{ MAX               NULL }
	{ LABEL             Duration }
	{ VARIABLE_CLASS    testCmd }
	{ DESCRIPTION {
	    "The approximate length of time frames are transmitted for each trial is"
	    "set as a 'duration. The duration is in seconds; for example, if the"
	    "duration is set to one second on a 100mbs switch, ~148810 frames will be"
	    "transmitted.  This number must be an integer; minimum value is 1 second."
	    "duration of transmit during test, in seconds"
	} }
    }
    
    {
	{ NAME              testName }
	{ BACKEND_TYPE      string }
	{ DEFAULT_VALUE     "OPSF Route Capacity" }
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
	{ DEFAULT_VALUE     0 } 
	{ MIN               0 }
	{ MAX               NULL }
	{ LABEL             "Number of Withdrawals: " }
	{ VARIABLE_CLASS    testCmd }
    }

    {
	{ NAME              routeStep }
	{ BACKEND_TYPE      integer }
	{ DEFAULT_VALUE     1024 } 
	{ MIN               0 }
	{ MAX               2000000000 }
	{ LABEL             "Route Step: " }
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
	{ NAME              networkType }
	{ BACKEND_TYPE      string }
	{ DEFAULT_VALUE     Broadcast }
	{ VALID_VALUES      {Broadcast "Point To Point"} }
	{ LABEL             "Interface Network Type: " }
	{ VARIABLE_CLASS    null }
	{ ON_INIT           routeConvergence::OnInterfaceNetworkInit }
	{ ON_CHANGE         routeConvergence::OnInterfaceNetworkChange }
    }

    {
	{ NAME              interfaceNetworkType }
	{ BACKEND_TYPE      string }
	{ DEFAULT_VALUE     ospfPointToPoint }
	{ VALID_VALUES      {ospfBroadcast ospfPointToPoint} }
	{ VARIABLE_CLASS    testCmd }
    }

    {
	{ NAME              enableValidateMtu }	    
	{ BACKEND_TYPE      integer }
	{ DEFAULT_VALUE     0 }
	{ VALID_VALUES      {1 0} }
	{ LABEL             "Validate MTU Size  " }
	{ VARIABLE          enableValidateMtu }
	{ ON_INIT           routeConvergence::enableValidateMtuCmd }
	{ ON_CHANGE         routeConvergence::enableValidateMtuCmd }
	{ VARIABLE_CLASS    testCmd }
    }
    
    {
	{ NAME              interfaceMTUSize }
	{ BACKEND_TYPE      integer }
	{ DEFAULT_VALUE     1500 }
	{ MIN               26 }
	{ MAX               65535 }
	{ LABEL             "" }
	{ VARIABLE_CLASS    testCmd }
    }
    
    {
	{ NAME              networkIpAddress }
	{ BACKEND_TYPE      ipaddress }
	{ DEFAULT_VALUE     10.0.0.0 }
	{ LABEL             "Advertised IP Network: " }
	{ VARIABLE_CLASS    testCmd }
    }
    
    {
	{ NAME              prefixLength }
	{ BACKEND_TYPE      string }
	{ DEFAULT_VALUE     24 }
	{ VALID_VALUES      {24 16} }
	{ LABEL             "Prefix Length: " }
	{ VARIABLE_CLASS    testCmd }
    }
    
    {
	{ NAME              numberOfRoutes }
	{ BACKEND_TYPE      double }
	{ DEFAULT_VALUE     4096 } 
	{ MIN               1 }
	{ MAX               2000000000 }
	{ LABEL             "No. of Routes: " }
	{ ON_INIT           routeConvergence::advertiseDelayPerRouteCmd }
	{ ON_CHANGE         routeConvergence::advertiseDelayPerRouteCmd }
	{ VARIABLE_CLASS    testCmd }
    }
    
    {
	{ NAME              advertiseDelayPerRoute }
	{ BACKEND_TYPE      double }
	{ DEFAULT_VALUE     0.0007 }
	{ MIN               0 }
	{ MAX               NULL }
	{ LABEL             "Advertise Delay Per Route (s): " }
	{ VARIABLE_CLASS    testCmd }
	{ ON_INIT           routeConvergence::advertiseDelayPerRouteCmd }
	{ ON_CHANGE         routeConvergence::advertiseDelayPerRouteCmd }
	{ VARIABLE_CLASS    testCmd }
    }
    
    {
	{ NAME              totalDelay }
	{ BACKEND_TYPE      string }
	{ DEFAULT_VALUE     3 }
	{ LABEL             "Max Wait Time (s):\n(# of Routes x AdvertiseDelay) " }
	{ ON_INIT           routeConvergence::totalDelayCmd }
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
	{ ON_CHANGE         routeConvergence::PassFailEnable }
    }

    
    {
	{ NAME              convergenceTime }
	{ BACKEND_TYPE      double }
	{ DEFAULT_VALUE     0 }
	{ MIN               0 }
	{ LABEL             "Convergence Time (s) <= " }
	{ VARIABLE          passFailRouteConvergenceValue }
	{ VARIABLE_CLASS    testConf }
    }
    
    {
	{ NAME              convergenceType }
	{ BACKEND_TYPE      string }
	{ DEFAULT_VALUE     average }
	{ VALID_VALUES      {total average} }
	{ VALUE_LABELS      {"Total" "Average/withdrawal"} }
	{ VARIABLE          passFailRouteConvergenceType }
	{ VARIABLE_CLASS    testConf }
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
	{ VALID_VALUES      {ip} }
	{ VARIABLE_CLASS    testConf }
	{ DESCRIPTION {
	    "Select the protocol to be used to run this test."
	    "Supported protocol is IP only. NOTE: Use lowercase ip"
	    "ip   = layer 3 IP"
	} }
    }

    
    {
	{ NAME              interfaceIpMask }
	{ BACKEND_TYPE      ipaddress }
	{ DEFAULT_VALUE     255.255.255.0 }
	{ VARIABLE_CLASS    testCmd }
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
	{ DEFAULT_VALUE     yes }
	{ VALID_VALUES      {yes no} }
	{ VARIABLE_CLASS    testConf }
    }

    {
	{ NAME              automap }
	{ BACKEND_TYPE      string }
	{ DEFAULT_VALUE     {Automatic Manual} }
	{ VALID_VALUES      {Automatic Manual} }
	{ VARIABLE_CLASS    automap }
    }

    {
	{ NAME              map }
	{ BACKEND_TYPE      string }
	{ DEFAULT_VALUE     one2many}
	{ VALID_VALUES      {one2many} }
	{ VARIABLE_CLASS    map }
    }

    { 
	{ NAME              doNotSupportLearn }
	{ BACKEND_TYPE      integer }
	{ DEFAULT_VALUE     1 }
	{ VARIABLE_CLASS    doNotSupportLearn }
    }
    
    {
	{ NAME              mapDirection }
	{ BACKEND_TYPE      string }
	{ DEFAULT_VALUE     unidirectional }
	{ VALID_VALUES      {unidirectional} }
	{ VARIABLE_CLASS    testConf }
	{ DESCRIPTION {
	    "unidirectional only"
	} }
    }
    
    {
	{ NAME               directions }
	{ BACKEND_TYPE       string }
	{ DEFAULT_VALUE      {Unidirectional} }
	{ VARIABLE_CLASS     directions }
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
	{ DEFAULT_VALUE     {ip} }
	{ VALID_VALUES      {ip} }
	{ VARIABLE_CLASS    protocolsSupportedByTest }
    }
    
    { 
	{ NAME              supportMaskWidth }
	{ BACKEND_TYPE      integer }
	{ DEFAULT_VALUE     1 }
	{ VALID_VALUES      {1} }
	{ VARIABLE_CLASS    supportMaskWidth }
    }   

    {
	{ NAME              resultFile }
	{ BACKEND_TYPE      string }
	{ DEFAULT_VALUE     routeConvergence.results }
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
	{ DEFAULT_VALUE     routeConvergence.log }
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
}
##################################################################################
#     Algorithm Procedures
#
##################################################################################

#############################################################################
# routeConvergence::TestSetup()
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
proc routeConvergence::TestSetup {} {
    
    variable iterationFileColumnHeader
    variable status
    variable initialDuration

    global one2manyArray

    set initialDuration [ospfSuite cget -duration]    
       
    set status $::TCL_OK
    
    learn config -when        oncePerTest

	if [ospfSuite::setIpV4Mask one2manyArray] {
        return $::TCL_ERROR
    }
    
    if [initTest ospfSuite one2manyArray {ip} errMsg] {
        errorMsg $errMsg
        return $::TCL_ERROR
    }
       
    if {[ospfSuite cget -advertiseDelayPerRoute] == 0} {
        ospfSuite config -advertiseDelayPerRoute 0.0007
        logMsg "advertiseDelayPerRoute can not be zero. It was changed to default value"
    }
                   
    if {[ospfSuite cget -numberOfRoutes] == 0 } {
        ospfSuite config -numberOfRoutes  1
    }

    return $status;
}


#############################################################################
# routeConvergence::TestCleanUp()
#
# DESCRIPTION
# This procedure resets common code elements needed at the end of a test.
#
# RETURNS:  
# status      TCL_OK     - on success
#             TCL_ERROR  - on failure
#
###
proc routeConvergence::TestCleanUp {} {
    variable status
    variable initialDuration
    
    set status $::TCL_OK
    
    ospfSuite config -duration $initialDuration
    
    return $status;
}


#############################################################################
# routeConvergence::TrialSetup()
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
proc routeConvergence::TrialSetup {} {
    variable status
    
    set status $::TCL_OK
    
    return $status;
}


#############################################################################
# routeConvergence::TrialCleanUp()
#
# DESCRIPTION
# This procedure resets common code elements needed at the end of a trial.
#
# RETURNS:  
# status      TCL_OK     - on success
#             TCL_ERROR  - on failure
#
###
proc routeConvergence::TrialCleanup {} {
    variable status
    
    set status $::TCL_OK

    return $status;
}


#############################################################################
# routeConvergence::AlgorithmSetup()
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
proc routeConvergence::AlgorithmSetup {} {
    variable status
    variable framesize
    variable initialDuration
     
    global one2manyArray
    set status $::TCL_OK
    
    cleanUpOspfGlobals
    
    setupTestResults ospfSuite one2many "" one2manyArray $framesize [ospfSuite cget -numtrials]\
	    false 1 routeConvergence
    
    ospfSuite config -duration $initialDuration

    return $status;
}



#############################################################################
# routeConvergence::AlgorithmCleanup()
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
proc routeConvergence::AlgorithmCleanUp {} {
    variable status
    
    set status $::TCL_OK
    
    
    return $status;
}




#############################################################################
# routeConvergence::AlgorithmBody()
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
proc routeConvergence::AlgorithmBody {} {
    variable status
    variable framesize
    variable trial
    
    global one2manyArray
    
    set status $::TCL_OK
    
    set ospfPorts [getRxPorts one2manyArray]
    
    if [configureOspf one2manyArray] {
        errorMsg "***** Error configuring OSPF..."
        return $::TCL_ERROR
    }

    if [enableProtocolServer ospfPorts ospf noWrite] {
        errorMsg "***** Error enabling OSPF..."
        return $::TCL_ERROR
    }

    if [enableProtocolStatistics  ospfPorts enableOspfStats] {
        errorMsg "***** Error enabling OSPF statistics..."
        return $::TCL_ERROR
    }

    # write the streams
    if [writeOspfStreams one2manyArray txNumFrames] {
        return $::TCL_ERROR
    }

    # Start OSPF Server
    logMsg "Starting OSPF..."
    if [startOspfServer ospfPorts] {
        errorMsg "Error Starting OSPF!"
        return $::TCL_ERROR
    }

    set advertiseDelay [mpexpr  round (ceil ( [ospfSuite cget -numberOfRoutes] * [ospfSuite cget -advertiseDelayPerRoute]))]
    set advertiseDelay [expr ($advertiseDelay<35) ? 35 : $advertiseDelay]
    if [confirmFullSession ospfPorts $advertiseDelay] {
        errorMsg "Error!!Neighbor(s) are not in full state. The advertiseDelayPerRoute is not long enough \
        or there is a network problem"
        ospfCleanUp ospfPorts
        return $::TCL_ERROR
    }
    logMsg "Pausing for [ospfSuite cget -dutProcessingDelay] seconds before starting transmitting ..."
    writeWaitForPause  "Waiting for DUT to settle down.." [ospfSuite cget -dutProcessingDelay]    
    #calculating duration.
    set numWithdraw [ospfSuite cget -numberOfFlaps]
    if { $numWithdraw != 0} {
        set duration [expr ceil (double ([ospfSuite cget -duration]) / ($numWithdraw * 2))]  
    } else {
        set duration [ospfSuite cget -duration]
    }
                     
    set retCode [prepareToTransmit  one2manyArray]

    if {$retCode == 0} {
        set retCode [startTx one2manyArray]
    }

    if {$retCode == 0} {     
        if {[ospfSuite cget -duration] > 0} {
            logMsg "Transmitting frames for [ospfSuite cget -duration] seconds"
        } else {
            logMsg "Transmitting frames for < 1 second"
        }
    }        
    writeWaitForTransmit    $duration

    set preferredPort       [lindex $ospfPorts 0]
    set notPreferredPort    [lindex $ospfPorts 1]
    scan $preferredPort     "%d %d %d" prx_c prx_l prx_p
    scan $notPreferredPort  "%d %d %d" nprx_c nprx_l nprx_p

    set rxNumFrames($nprx_c,$nprx_l,$nprx_p)    0
    set rxNumFrames($prx_c,$prx_l,$prx_p)       0

    set maxNumChanges [expr (($numWithdraw -1) * 2) + 1]

    set wrongDestFrames 0
    for {set count 0} {$count < $maxNumChanges } {incr count} {
        set enableFlap      [expr round (fmod ($count,2))]
        #flap the preferred route by disabling the routeRange
        if [setEnableRouteRange  $preferredPort $enableFlap 1 1] {
            logMsg "Could not flap"
            set $retCode 1
        }
    
        collectStats [getRxPorts one2manyArray] userDefinedStat2 currentRxNumFrames          
        if { $enableFlap == 0 } { 
        
            logMsg "Withdraw the routes on preferred port:$preferredPort"
            set frameLoss [mpexpr $currentRxNumFrames($nprx_c,$nprx_l,$nprx_p) - $rxNumFrames($nprx_c,$nprx_l,$nprx_p)]               
        
        } else {
            logMsg "Readvertise the route on preferred port:$preferredPort"
            #set frameLoss [mpexpr $currentRxNumFrames($prx_c,$prx_l,$prx_p) - $rxNumFrames($prx_c,$prx_l,$prx_p)]                
        }
        if { $frameLoss > 0} {
            incr wrongDestFrames $frameLoss
            #logMsg "Number of Frames sent to the wrong destination during last flap: $frameLoss"
        }
        set rxNumFrames($nprx_c,$nprx_l,$nprx_p)    $currentRxNumFrames($nprx_c,$nprx_l,$nprx_p)
        set rxNumFrames($prx_c,$prx_l,$prx_p)       $currentRxNumFrames($prx_c,$prx_l,$prx_p)

        writeWaitForTransmit    $duration 
    }

    if [stopTx one2manyArray] {
        logMsg "Error stopping Tx on one or more ports."
        set retCode 1
    }
            
    waitForResidualFrames [ospfSuite cget -waitResidual]                 

    stats::collectTxStats [getTxPorts one2manyArray] txNumFrames txActualFrames totalTxNumFrames
    collectRxStats [getRxPorts one2manyArray] rxNumFrames totalRxNumFrames
    debugMsg "rxNumFrames :[array get rxNumFrames]"

    if {  $numWithdraw != 0 } {         
        if {[expr round (fmod ($count,2))]} {
            set frameLoss [mpexpr $rxNumFrames($prx_c,$prx_l,$prx_p) - $currentRxNumFrames($prx_c,$prx_l,$prx_p)]
        } else {
            set frameLoss [mpexpr $rxNumFrames($nprx_c,$nprx_l,$nprx_p) - $currentRxNumFrames($nprx_c,$nprx_l,$nprx_p)]
    
        }

        if { $frameLoss > 0} {
                incr wrongDestFrames $frameLoss
                #logMsg "Number of Frames sent to the wrong destination during last flap: $frameLoss"
            }  
    }   
    set prefRxNumFrames     $rxNumFrames($prx_c,$prx_l,$prx_p)      
    set notPrefRxNumFrames  $rxNumFrames($nprx_c,$nprx_l,$nprx_p)
    set actualPacketLoss    [mpexpr ($totalTxNumFrames - $totalRxNumFrames)]

    if { $wrongDestFrames > 0 } {
        set totalRxNumFrames        [mpexpr $totalRxNumFrames - $wrongDestFrames]
    }
    set totalLoss           [calculatePercentLoss $totalTxNumFrames $totalRxNumFrames]
    set totalPacketLoss     [mpexpr ($totalTxNumFrames - $totalRxNumFrames)]

    if { $notPrefRxNumFrames != 0  && $numWithdraw != 0 } {    
        set convergenceMetric           [format "%6.6f" [mpexpr  double ($totalPacketLoss ) / [stream cget -framerate ]]]
        set convergencePerWithdraw      [format "%6.6f" [expr $convergenceMetric / $maxNumChanges]]
    } else {           
        set convergenceMetric       N/A
        set convergencePerWithdraw  N/A
    }
    ospfCleanUp ospfPorts 
    set packetRate      [stream cget -framerate]
    set numberOfRoutes  [ospfSuite cget -numberOfRoutes]
    set misDirectedPackets [expr $totalPacketLoss - $actualPacketLoss]
    if { $misDirectedPackets < 0 } {
        set misDirectedPackets 0
    }
    set txDurationPerFlap $duration
    if [results save one2many $framesize $trial  \
                            txActualFrames       \
                            rxNumFrames          \
                            numWithdraw          \
                            numberOfRoutes       \
                            packetRate           \
                            txDurationPerFlap    \
                            actualPacketLoss     \
                            misDirectedPackets   \
                            totalPacketLoss      \
                            totalLoss            \
                            convergenceMetric    \
                            convergencePerWithdraw] {
        logMsg "Error saving results for Trial $trial. "
        return 1
    }
    if [results printToScreen one2many $framesize $trial] {
        set retCode 1
    }
    
    return $status;
}



#############################################################################
# routeConvergence::CleanUp()
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
proc routeConvergence::CleanuUp {} {
    variable status
    global one2manyArray
    
    set status $::TCL_OK
    
    ospfSuite config -framesizeList [list]

    if { [advancedTestParameter cget -removeStreamsAtCompletion] == "true"} {
        if [removeStreams one2manyArray] {
            errorMsg "Error removing streams."
            set status $::TCL_ERROR
        }
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
proc routeConvergence::ConfigValidate {} \
{
    set type        [map cget -type]
    global          [format "%sArray" $type] 
    
    set status $::TCL_OK
    
    
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

    if [validateUnidirectionalMap one2manyArray] {
        return $::TCL_ERROR
    }

    if [checkConvergenceMap one2manyArray] {
        errorMsg "Invalid Map for convergence test. Should be one Tx port and Two Rx ports"
        return $::TCL_ERROR 
    }
    
    

    #common validatation to all the tests
    if {![configValidation::ValidateCommon ospfSuite]} {
        return $::TCL_ERROR
    }
    
    if {[ospfSuite cget -numberOfRoutes] == 0 } {
        ospfSuite config -numberOfRoutes  1
    }
    
    if {[ospfSuite cget -advertiseDelayPerRoute] == 0} {
        ospfSuite config -advertiseDelayPerRoute 0.0007
        logMsg "advertiseDelayPerRoute can not be zero. It was changed to default value"
    }  
                  
    return $status

}



########################################################################
# Procedure: WriteResultsCSV
#
# This procedure create the CSV files used for PDF Report generation
# CSV File Format
#
########################################################################
proc routeConvergence::WriteResultsCSV {} {
   variable resultsDirectory
   variable trialsPassed;
   global resultArray testConf passFail
   global aggregateArray loggerParms

   set dirName $resultsDirectory

   if { [ospfSuite cget -framesizeList] == {} } {
       # no new result entry to write
       return
   }


   #################################
   #
   #  Create Result CSV
   #
   #################################

   catch {unset resultArray}
   catch {unset aggregateArray}
   set tmpFid [openMyFile [results cget -tempFile] r results]
   if {$tmpFid == "stdout"} {
      return $::TCL_ERROR
   }

   if [xmlXMLToTclArrayByTrial $tmpFid resultArray] {
           debugMsg "Unable to populate gxiResultValues"
           return $::TCL_ERROR
   }

   closeMyFile $tmpFid

 
   set mapArray    [format "%sArray"   [map cget -type]]
   global $mapArray

   if {[catch {set csvFid [open $dirName/results.csv w]}]} {
      logMsg "***** WARNING:  Cannot open csv file."
      return
   }

   puts $csvFid "Trial,Frame Size,Tx Port,Rx Port,Tx Count (frames),Rx Count (frames),Number of Routes,Number of withdrawals,Frame Rate (FPS),Tx Duration per Flap (sec),Convergence Metric (sec),Convergence Metric per Withdrawal (sec),Actual Frame Loss,Actual Frame Loss (%),Misdirected Frames, Total Frame Loss, Total Frame Loss (%)"
   for {set trial 1} {$trial <= [ospfSuite cget -numtrials] } {incr trial} {
      foreach fs [lsort -dictionary [ospfSuite cget -framesizeList]] {
         
         set txPort   [lindex [getTxPorts $mapArray] 0]
         set rxPort1  [lindex [getRxPorts $mapArray] 0]
         set rxPort2  [lindex [getRxPorts $mapArray] 1]
         set txCount $resultArray($trial,$fs,1,[join $txPort ,],port,TXtransmitFrames)
         set rxCount1 $resultArray($trial,$fs,1,[join $rxPort1 ,],port,RXreceiveFrames)
         set rxCount2 $resultArray($trial,$fs,1,[join $rxPort2 ,],port,RXreceiveFrames)
         set noOfRoutes $resultArray($trial,$fs,1,iter,numberOfRoutes)
         set noOfWithdrawals $resultArray($trial,$fs,1,iter,numWithdraw)
         set frameRate $resultArray($trial,$fs,1,iter,packetRate)
         set txDurationPerFlap $resultArray($trial,$fs,1,iter,txDurationPerFlap)
         set convergenceMetric $resultArray($trial,$fs,1,iter,convergenceMetric)
         set convergenceMetricPerWithdrawal $resultArray($trial,$fs,1,iter,convergencePerWithdraw)
         set actualFrameLoss $resultArray($trial,$fs,1,iter,actualPacketLoss)
         set actualFrameLossPct [mpexpr ($actualFrameLoss + 0.0) / $txCount * 100]
         set misdirectedFrames $resultArray($trial,$fs,1,iter,misDirectedPackets)
         set totalFrameLoss $resultArray($trial,$fs,1,iter,totalPacketLoss)
         set totalFrameLossPct $resultArray($trial,$fs,1,iter,percentLoss)

         puts $csvFid "$trial,$fs,[join $txPort .],[join $rxPort1 .],$txCount,$rxCount1,$noOfRoutes,$noOfWithdrawals,$frameRate,$txDurationPerFlap,$convergenceMetric,$convergenceMetricPerWithdrawal,$actualFrameLoss,$actualFrameLossPct,$misdirectedFrames,$totalFrameLoss,$totalFrameLossPct"
         puts $csvFid "$trial,$fs,[join $txPort .],[join $rxPort2 .],-,$rxCount2,-,-,-,-,-,-,-,-,-,-,-"
      }
   }

   closeMyFile $csvFid

}


########################################################################
# routeConvergence::WriteAggregateResultsCSV()
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
proc routeConvergence::WriteAggregateResultsCSV {} {
   
   #################################
   #
   #  Create Aggregate Result CSV
   #
   #################################

}


#############################################################################
# routeConvergence::MetricsPostProcess()
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
proc routeConvergence::MetricsPostProcess {} {
    variable status

    set status $::TCL_OK

    return $status

}


################################################################################
#
# routeConvergence::PassFailCriteriaEvaluate ()
#
# DESCRIPTION:
# This procedure calculates the number of trials that have executed successfully
# based upon user-specified Pass/Fail criteria.  
#
# The criteria which must be met is based upon an acceptable value of
# route capacity.
# Minimum Route Capacity is the minimum number of routes
# across any frame sizes for a given trial.
#
# MODIFIES
# trialsPassed      - namespace variable indicating number of successful trials.
#
# RETURNS
# none
#
###
proc routeConvergence::PassFailCriteriaEvaluate {} {
    variable resultsDirectory
    variable trialsPassed
    global one2manyArray
    global resultArray testConf

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

    # populate results TCL array from temporary XML file
    # using the results API
    catch {unset resultArray}
    set tmpFid [openMyFile [results cget -tempFile] r results]
    if {$tmpFid == "stdout"} {
	return $::TCL_ERROR
    }

    if [xmlXMLToTclArrayByTrial $tmpFid resultArray] {
	debugMsg "Unable to populate gxiResultValues"
	return $::TCL_ERROR
    }
    closeMyFile $tmpFid

    set trialsPassed 0
        
    for {set trial 1} {$trial <= [ospfSuite cget -numtrials] } {incr trial} {

	logMsg "*** Trial #$trial"

	set routeConvWithdrawList {}
        set routeConvMetricList {}

	foreach fs [lsort -dictionary [ospfSuite cget -framesizeList]] {
            lappend routeConvWithdrawList $resultArray($trial,$fs,1,iter,convergencePerWithdraw)
            lappend routeConvMetricList  $resultArray($trial,$fs,1,iter,convergenceMetric)
        } ;# loop over frame size

        if {[lsearch $routeConvWithdrawList "N/A"] >=0 } {
            set maxConvWithdraw "N/A"
        } else {
            # Maximum Convergence Per Withrdrawal is the maximum number of convergence per withdrawal values
            # across any frame sizes for a given trial.	
            set maxConvWithdraw [passfail::ListMax routeConvWithdrawList]
        }

        if {[lsearch $routeConvMetricList "N/A"] >=0 } {
            set maxConvMetric "N/A"
        } else {
            # Maximum Convergence Metric is the maximum number of convergence metric values
            # across any frame sizes for a given trial.	
            set maxConvMetric [passfail::ListMax routeConvMetricList]
        }

	set result [passfail::PassFailCriteriaRouteConvergenceEvaluate $maxConvMetric $maxConvWithdraw]

	if { $result == "PASS" } {
	    incr trialsPassed
	}
	logMsg "*** $result\n"

    } ;# loop over trials

    logMsg "*** # Of Trials Passed: $trialsPassed"
    logMsg "***************************************"
    
}







################################################################################
#            GUI Procedures
#
################################################################################


########################################################################################
# Procedure:    routeConvergence::OnInterfaceNetworkInit
#
# Description:  Enable/Disable LSA Withdrawal.
#
# Argument(s):  version:    V2 or V3
#               type:       "Summary", "Router", "External"
#
# Returns:      None
########################################################################################
proc routeConvergence::OnInterfaceNetworkInit {args} {
    global networkType

    switch [ospfSuite cget -interfaceNetworkType] {
         "ospfBroadcast" {
             set networkType "Broadcast"
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
# Procedure:    routeConvergence::OnInterfaceNetworkChange
#
# Description:  Enable/Disable LSA Withdrawal.
#
# Argument(s):  version:    V2 or V3
#               type:       "Summary", "Router", "External"
#
# Returns:      None
########################################################################################

proc routeConvergence::OnInterfaceNetworkChange {args} {
   global networkType interfaceNetworkType
   
   switch $networkType {
         "Broadcast" {
             set interfaceNetworkType "ospfBroadcast";
         }
         "Point To Point" {
             set interfaceNetworkType "ospfPointToPoint";
         }
         default {
             set interfaceNetworkType "ospfBroadcast"
         }
    }

    ospfSuite config -interfaceNetworkType  $interfaceNetworkType
}


########################################################################################
# Procedure:    routeConvergence::enableValidateMtuCmd
#
# Description:  Widget command for Validate MTU widget
#
# Argument(s):  None
#
# Returns:      None
########################################################################################
proc routeConvergence::enableValidateMtuCmd { args } {
    global enableValidateMtu
    set state disabled

    if {$enableValidateMtu} {
        set state enabled
    }
    
    renderEngine::WidgetListStateSet interfaceMTUSize $state
}



########################################################################################
# Procedure:    routeConvergence::totalDelayCmd
#
# Description:  Widget command for Max Wait Time widget
#
# Argument(s):  None
#
# Returns:      None
########################################################################################
proc routeConvergence::totalDelayCmd {args} {

    renderEngine::WidgetListStateSet totalDelay disabled

}

########################################################################################
# Procedure:    routeConvergence::advertiseDelayPerRouteCmd
#
# Description:  Widget command for Advertise Delay per Route widget
#
# Argument(s):  None
#
# Returns:      None
########################################################################################
proc routeConvergence::advertiseDelayPerRouteCmd {parent propName args} {

    global advertiseDelayPerRoute numberOfRoutes totalDelay
    
    
    if { [stringIsDouble $advertiseDelayPerRoute] && [stringIsInteger $numberOfRoutes] } {
        set totalDelay [mpexpr round (double ($advertiseDelayPerRoute) * $numberOfRoutes)]
        set totalDelay [expr ($totalDelay<35) ? 35 : $totalDelay]
        update idletasks
    }
}


################################################################################
#
# routeConvergence::PassFailEnable(args)
#
# DESCRIPTION:
# This procedure enables or disables OSPF Route Capacity Pass/Fail Critiera related widgets.
# This either allows the user to click on and adjust widgets or prevents this.
#
# ARGUMENTS
# args       - variable arguments
#
# RETURNS
# none
#
###
proc routeConvergence::PassFailEnable {args} {
    global passFailEnable minRoutesVerified

    set state disabled

    if {$passFailEnable} {
        set state enabled
    }
	
	renderEngine::WidgetListStateSet [list convergenceTime convergenceType] $state
}