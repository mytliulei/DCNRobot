############################################################################################
#
#   Copyright © 1997 - 2004 by IXIA.
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
#
#############################################################################################
namespace eval ospfSuite {}

####################################################################
# routeCapacity::xmdDef
# 
# DESCRIPTION:
# This variable contains the XML content used by PDF Report generation.
#  
###
set routeCapacity::xmdDef  {
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
          <Source scope="results.csv" entity_name="ospfSuiteRouteCapacity" format_id=""/>
          <Source scope="info.csv" entity_name="ospfSuiteRouteCapacity_Info" format_id=""/>
          <Source scope="Iteration.csv" entity_name="ospfSuiteRouteCapacity_Iteration" format_id=""/>
       </Sources>
    </XMD>
   
}

#####################################################################
# routeCapacity::statList
# 
# DESCRIPTION:
# This table contains a list of collected metrics to be displayed in
# the Real Time Graphs and written to RealTime.csv file.
#  
###
set routeCapacity::statList \
    [list [list framesSent     [getTxPorts one2oneArray] "Tx Frames per second" "Tx Frames" 1e0]\
        [list framesReceived [getRxPorts one2oneArray] "Rx Frames per second" "Rx Frames" 1e0]\
        [list bitsSent       [getTxPorts one2oneArray] "Tx Kbps"              "Tx Kb"     1e3]\
        [list bitsReceived   [getRxPorts one2oneArray] "Rx Kbps"              "Rx Kb"     1e3]\
	];
    
    
########################################################################################
# Procedure: routeCapacity::registerResultVars
#
# Description: This command registers all the local variables that are used in the
# display of the results with the Results Options Database.  This procedure must exist
# for each test.
#
# Argument(s):
# Returned result:
########################################################################################
proc routeCapacity::registerResultVars {} \
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

set routeCapacity::attributes {
    
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
	{ NAME              tolerance }
	{ BACKEND_TYPE      double }
	{ DEFAULT_VALUE     100 }
	{ MIN               0 }
	{ MAX               100 }
	{ LABEL             "Tolerance (%): " }
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
	{ ON_INIT           routeCapacity::OnInterfaceNetworkInit }
	{ ON_CHANGE         routeCapacity::OnInterfaceNetworkChange }
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
	{ LABEL             "Validate MTU Size " }
	{ VARIABLE          enableValidateMtu }
	{ ON_INIT           routeCapacity::enableValidateMtuCmd }
	{ ON_CHANGE         routeCapacity::enableValidateMtuCmd }
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
	{ ON_INIT           routeCapacity::advertiseDelayPerRouteCmd }
	{ ON_CHANGE         routeCapacity::advertiseDelayPerRouteCmd }
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
	{ ON_INIT           routeCapacity::advertiseDelayPerRouteCmd }
	{ ON_CHANGE         routeCapacity::advertiseDelayPerRouteCmd }
	{ VARIABLE_CLASS    testCmd }
    }
    
    {
	{ NAME              totalDelay }
	{ BACKEND_TYPE      string }
	{ DEFAULT_VALUE     3 }
	{ LABEL             "Max Wait Time (s):\n(# of Routes x AdvertiseDelay) " }
	{ ON_INIT           routeCapacity::totalDelayCmd }
	{ VARIABLE_CLASS    null }
    }

    {
	{ NAME              interfaceIpMask }
	{ BACKEND_TYPE      ipaddress }
	{ DEFAULT_VALUE     255.255.255.0 }
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
	{ ON_CHANGE         routeCapacity::PassFailEnable }
    }

    {
	{ NAME              minRoutesVerified }
	{ BACKEND_TYPE      integer }
	{ DEFAULT_VALUE     0 }
	{ MIN               0 }
	{ LABEL             "Min Routes Verified >= " }
	{ VARIABLE          passFailRouteCapacityValue }
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
	{ DEFAULT_VALUE     one2one }
	{ VALID_VALUES      {one2one} }
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
	{ DEFAULT_VALUE     routeCapacity.results }
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
	{ DEFAULT_VALUE     routeCapacity.log }
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
        { DEFAULT_VALUE     true }
        { VARIABLE_CLASS    supportIterationCsv }
    }

    {
	{ NAME              mapType }
	{ BACKEND_TYPE      string }
	{ DEFAULT_VALUE     one2one }
        { VALID_VALUES      {one2one one2many many2one many2many} }
	{ VARIABLE          ospfMapType }
	{ VARIABLE_LABEL    mapType }
    }
}

#################################################################################
#     Algorithm Procedures
#
##################################################################################

#############################################################################
# routeCapacity::TestSetup()
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
proc routeCapacity::TestSetup {} {
    
    variable iterationFileColumnHeader
    variable status
    
    global one2oneArray
    
    set iterationFileColumnHeader { "Trial"
        "Frame Size"
        "Iteration"
        "Tx Port"
        "Rx Port"
        "Tx Count"
        "Rx Count"
        "Frame Loss"
        "Frame Loss (%)"
        "Number of Routes"
        "Frame Rate (FPS)"
    }
    
    set status $::TCL_OK
    
    learn config -when        oncePerTest
		
	if [ospfSuite::setIpV4Mask one2oneArray] {
        return $::TCL_ERROR
    }
	
	if [initTest ospfSuite one2oneArray {ip} errMsg] {
        errorMsg $errMsg
        return $::TCL_ERROR
    }

    return $status;
}


#############################################################################
# routeCapacity::TestCleanUp()
#
# DESCRIPTION
# This procedure resets common code elements needed at the end of a test.
#
# RETURNS:  
# status      TCL_OK     - on success
#             TCL_ERROR  - on failure
#
###
proc routeCapacity::TestCleanUp {} {
    variable status
    
    set status $::TCL_OK

    return $status;
}


#############################################################################
# routeCapacity::TrialSetup()
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
proc routeCapacity::TrialSetup {} {
    variable status
    
    set status $::TCL_OK
    
    return $status;
}


#############################################################################
# routeCapacity::TrialCleanUp()
#
# DESCRIPTION
# This procedure resets common code elements needed at the end of a trial.
#
# RETURNS:  
# status      TCL_OK     - on success
#             TCL_ERROR  - on failure
#
###
proc routeCapacity::TrialCleanup {} {
    variable status
    
    set status $::TCL_OK

    return $status;
}


#############################################################################
# routeCapacity::AlgorithmSetup()
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
proc routeCapacity::AlgorithmSetup {} {
    variable status
    variable framesize
    
    global one2oneArray
    set status $::TCL_OK
    
    cleanUpOspfGlobals
    
    setupTestResults ospfSuite one2one "" one2oneArray $framesize [ospfSuite cget -numtrials]\
	   false 1 routeCapacity

    return $status;
}



#############################################################################
# routeCapacity::AlgorithmCleanup()
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
proc routeCapacity::AlgorithmCleanUp {} {
    variable status
    
    set status $::TCL_OK
    
    
    return $status;
}




#############################################################################
# routeCapacity::AlgorithmBody()
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
proc routeCapacity::AlgorithmBody {} {
    variable status
    variable framesize
    variable trial
    
    global one2oneArray
    
    set status $::TCL_OK
    
    set done 1
    set count 1
    set totalRoutes         [ospfSuite cget -numberOfRoutes]
    set currRoutesPerPeer   [ospfSuite cget -numberOfRoutes]
    set framesizeString "Framesize:$framesize"
    set ospfPorts    [getRxPorts one2oneArray]
    set beginNumberRoutes   [ospfSuite cget -numberOfRoutes]
    
    while { $done && $status == 0 } {

        set advertiseDelay [mpexpr  round ( $currRoutesPerPeer * [ospfSuite cget -advertiseDelayPerRoute])]
        
        logMsg "####### Iteration: $count, $framesizeString, Number of Routes: $currRoutesPerPeer, Advertise delay: $advertiseDelay #######"            

        if [configureOspf one2oneArray] {
            errorMsg "***** Error configuring OSPF..."
            return $::TCL_ERROR
        }

        if [enableProtocolServer ospfPorts ospf noWrite] {
            errorMsg "***** Error enabling OSPF..."
            return $::TCL_ERROR
        }

        if [enableProtocolStatistics    ospfPorts enableOspfStats] {
            errorMsg "***** Error enabling OSPF statistics..."
            return $::TCL_ERROR
        }         

        # write the streams
        if [writeOspfStreams one2oneArray txNumFrames $currRoutesPerPeer] {
            return $::TCL_ERROR
        }

        # Start OSPF Server
        logMsg "Starting OSPF..."
        if [startOspfServer ospfPorts] {
            errorMsg "Error Starting OSPF!"
            return $::TCL_ERROR
        }

        set advertiseDelay [mpexpr  round (ceil ( [ospfSuite cget -numberOfRoutes] * [ospfSuite cget -advertiseDelayPerRoute]))]
        if [confirmFullSession ospfPorts $advertiseDelay] {
            errorMsg "Error!!Neighbor(s) are not in full state. The advertiseDelayPerRoute is not long enough \
            or there is a network problem"
            ospfCleanUp ospfPorts
            return $::TCL_ERROR
        }
        logMsg "Pausing for [ospfSuite cget -dutProcessingDelay] seconds before starting transmitting ..." 
        writeWaitForPause  "Waiting for DUT to settle down .." [ospfSuite cget -dutProcessingDelay]  
        
        if [clearStatsAndTransmit one2oneArray [ospfSuite cget -duration] [ospfSuite cget -staggeredStart]] {
            return $::TCL_ERROR
        }

        waitForResidualFrames [ospfSuite cget -waitResidual]  
                      
        # Poll the Tx counters until all frames are sent
        stats::collectTxStats [getTxPorts one2oneArray] txNumFrames txActualFrames totalTxNumFrames
        collectRxStats [getRxPorts one2oneArray] rxNumFrames totalRxNumFrames
        debugMsg "rxNumFrames :[array get rxNumFrames]" 

        ##################################################################
        logMsg "Withdrawing the routes before stopping the OSPF..."
        set ospf_Port       [lindex $ospfPorts 0]
        scan $ospf_Port     "%d %d %d" c l p

        if [setEnableRouteRange  $ospf_Port false 1 1] {
            logMsg "Error in disabling the route"
            set status 1
        }

        set withdrawPause [ospfSuite cget -dutProcessingDelay]
        if {[info exists userWithdrawPause]} {
            set withdrawPause	$userWithdrawPause
        } 
        writeWaitForPause  "Waiting for Processing Route Withdrawal .." $withdrawPause

        ####################################################################

        ospfCleanUp ospfPorts

        writeWaitForPause  "Waiting for tear down .." [ospfSuite cget -dutProcessingDelay] 

        set totalLoss          [calculatePercentLoss $totalTxNumFrames $totalRxNumFrames]
        set tolerance          [ospfSuite cget -tolerance]
        
        
        #  Write in Iteration.CSV 
        csvUtils::writeIterationCSVFile routeCapacity [list $count \
                   [join [lindex [getTxPorts one2oneArray] 0] .] \
                   [join [lindex [getRxPorts one2oneArray] 0] .] \
                   $totalTxNumFrames \
                   $totalRxNumFrames \
                    [mpexpr $totalTxNumFrames - $totalRxNumFrames] \
                   $totalLoss \
                   [ospfSuite cget -numberOfRoutes] \
                                           [stream cget -framerate]]


        if { ($totalLoss <= [ospfSuite cget -tolerance] ) && ( $status ==0 ) && ([ospfSuite cget -routeStep] != 0) } {
            catch {unset savedTxActualFrames }
            array set savedTxActualFrames [array get txActualFrames]
            catch {unset savedRxNumFrames }
            array set savedRxNumFrames [array get rxNumFrames]
            set savedTotalLoss $totalLoss

            set totalRoutes $currRoutesPerPeer
            logMsg " Continue to increase number of Routes. Number of routes up to now is $currRoutesPerPeer "
            mpincr currRoutesPerPeer          [ospfSuite cget -routeStep]
            ospfSuite config -numberOfRoutes    $currRoutesPerPeer
            incr count
        } else {
            set done 0
            if {$count == 1} {
                set totalRoutes $totalRxNumFrames
            }
            ospfSuite config -numberOfRoutes   $beginNumberRoutes
            logMsg " Done "
        }
    }
    
    set packetRate      [stream cget -framerate]
    set routeStep       [ospfSuite cget -routeStep]
    set numberOfRoutes  $beginNumberRoutes

    if {[info exists savedTotalLoss]} {
        catch {unset txActualFrames}
        array set txActualFrames [array get savedTxActualFrames]
        catch {unset rxNumFrames}
        array set rxNumFrames [array get savedRxNumFrames]
        set totalLoss $savedTotalLoss 
    }

    if [results save one2one $framesize $trial \
                            txActualFrames   \
                            rxNumFrames      \
                            numberOfRoutes   \
                            routeStep        \
                            packetRate       \
                            tolerance        \
                            totalLoss        \
                            totalRoutes  ] {
        logMsg "Error saving results for Trial $trial. "
        return 1
    }
    
    if [results printToScreen one2one $framesize $trial] {
        set status 1
    }
    
    return $status;
}



#############################################################################
# routeCapacity::CleanUp()
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
proc routeCapacity::CleanuUp {} {
    variable status
    global one2oneArray
    
    set status $::TCL_OK
    
    ospfSuite config -framesizeList  [list]

    if { [advancedTestParameter cget -removeStreamsAtCompletion] == "true"} {
        if [removeStreams one2oneArray] {
            errorMsg "Error removing streams."
            set status 1
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
proc routeCapacity::ConfigValidate {} \
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

    if [validateUnidirectionalMap one2oneArray] {
        return $::TCL_ERROR
    }

    if [checkCapacityMap one2oneArray] {
        errorMsg "Invalid Map for capacity test. Should be one Tx port and one Rx port"
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
proc routeCapacity::WriteResultsCSV {} {
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
   set portList {}
   set pList [results cget -mapList]
   while {[llength $pList]} {
      regsub -all , [lindex $pList 0] " " txPort
      set rxPort [join [lindex $pList 1]]
      lappend portList [list $txPort $rxPort]
      set pList [lrange $pList 2 end]
   }
   set portList [lsort -dictionary $portList]
   if {[catch {set csvFid [open $dirName/results.csv w]}]} {
      logMsg "***** WARNING:  Cannot open csv file."
      return
   }

   puts $csvFid "Trial,Frame Size,Tx Port,Rx Port,Tx Count,Rx Count,Frame Loss,Frame Loss (%),Number of Routes,Frame Rate (FPS),Max Routes Verified"
   for {set trial 1} {$trial <= [ospfSuite cget -numtrials] } {incr trial} {
      foreach fs [lsort -dictionary [ospfSuite cget -framesizeList]] {
         foreach pair $portList {
            set txPort  [lindex $pair 0]
            set rxPort  [lindex $pair 1]
            set txCount $resultArray($trial,$fs,1,[join $txPort ,],port,TXtransmitFrames)
            set rxCount $resultArray($trial,$fs,1,[join $rxPort ,],port,RXreceiveFrames)
            set frameLoss [mpexpr $txCount - $rxCount]
            set frameLossPct [mpexpr ($frameLoss + 0.0) / $txCount * 100]
            set noRoutes $resultArray($trial,$fs,1,iter,numberOfRoutes)
            set frameRate $resultArray($trial,$fs,1,iter,packetRate)
            set maxRoutesVerified $resultArray($trial,$fs,1,iter,totalRoutes)
            puts $csvFid "$trial,$fs,[join $txPort .],[join $rxPort .],$txCount,$rxCount,$frameLoss,$frameLossPct,$noRoutes,$frameRate,$maxRoutesVerified"
         }
      }
   }

   closeMyFile $csvFid
  
}


########################################################################
# routeCapacity::WriteAggregateResultsCSV()
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
proc routeCapacity::WriteAggregateResultsCSV {} {
   
   #################################
   #
   #  Create Aggregate Result CSV
   #
   #################################

}


#############################################################################
# routeCapacity::MetricsPostProcess()
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
proc routeCapacity::MetricsPostProcess {} {
    variable status

    set status $::TCL_OK

    return $status

}


################################################################################
#
# routeCapacity::PassFailCriteriaEvaluate ()
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
proc routeCapacity::PassFailCriteriaEvaluate {} {
    variable resultsDirectory
    variable trialsPassed
    global one2oneArray
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

	set routeCapacityList {}

	foreach fs [lsort -dictionary [ospfSuite cget -framesizeList]] {

	    lappend routeCapacityList $resultArray($trial,$fs,1,iter,totalRoutes)
	    
	} ;# loop over frame size

	# Minimum Route Capacity is the minimum number of routes
	# across any frame sizes for a given trial.	
	set minRouteCapacity [passfail::ListMin routeCapacityList]

	set result [passfail::PassFailCriteriaRouteCapacityEvaluate $minRouteCapacity]

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
# Procedure:    routeCapacity::OnInterfaceNetworkInit
#
# Description:  Enable/Disable LSA Withdrawal.
#
# Argument(s):  version:    V2 or V3
#               type:       "Summary", "Router", "External"
#
# Returns:      None
########################################################################################
proc routeCapacity::OnInterfaceNetworkInit {args} {
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
# Procedure:    routeCapacity::OnInterfaceNetworkChange
#
# Description:  Enable/Disable LSA Withdrawal.
#
# Argument(s):  version:    V2 or V3
#               type:       "Summary", "Router", "External"
#
# Returns:      None
########################################################################################

proc routeCapacity::OnInterfaceNetworkChange {args} {
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
# Procedure:    routeCapacity::enableValidateMtuCmd
#
# Description:  Widget command for Validate MTU widget
#
# Argument(s):  None
#
# Returns:      None
########################################################################################
proc routeCapacity::enableValidateMtuCmd { args } {
    global enableValidateMtu
    set state disabled

    if {$enableValidateMtu} {
        set state enabled
    }
    
    renderEngine::WidgetListStateSet interfaceMTUSize $state
}



########################################################################################
# Procedure:    routeCapacity::totalDelayCmd
#
# Description:  Widget command for Max Wait Time widget
#
# Argument(s):  None
#
# Returns:      None
########################################################################################
proc routeCapacity::totalDelayCmd {args} {

    renderEngine::WidgetListStateSet totalDelay disabled

    #set totalDelay [ospfSuite cget -totalDelay]
    #set entry [$parent.totalDelay subwidget entry];
    #$entry delete 0 end;
    #$entry insert end $totalDelay;
}

########################################################################################
# Procedure:    routeCapacity::advertiseDelayPerRouteCmd
#
# Description:  Widget command for Advertise Delay per Route widget
#
# Argument(s):  None
#
# Returns:      None
########################################################################################
proc routeCapacity::advertiseDelayPerRouteCmd {parent propName args} {

    global advertiseDelayPerRoute numberOfRoutes totalDelay
    
    
    #if { ([string length $advertiseDelayPerRoute] == 0) || ([string length $numberOfRoutes] == 0) } {
    #    return
    #}

    if { [stringIsDouble $advertiseDelayPerRoute] && [stringIsInteger $numberOfRoutes] } {
        set totalDelay [mpexpr round (double ($advertiseDelayPerRoute) * $numberOfRoutes)]
        update idletasks
    }
}


################################################################################
#
# routeCapacity::PassFailEnable(args)
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
proc routeCapacity::PassFailEnable {args} {
    global passFailEnable minRoutesVerified

    set state disabled

    if {$passFailEnable} {
        set state enabled
    }
	
	renderEngine::WidgetListStateSet minRoutesVerified $state
}