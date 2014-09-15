##################################################################################
# Copyright (c) Ixia 2004-2005
# All rights reserved
#
# DESCRIPTION:
#
#
#
##################################################################################

 namespace eval ospfPerformance {}

 #####################################################################
 # ospfPerformance::xmdDef
 # 
 # DESCRIPTION:
 # This variable contains the XML content used by PDF Report generation.
 #  
 ###
  set ospfPerformance::xmdDef  {
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
                         <Source scope="results.csv" entity_name="ospfPerformance" format_id=""/>
                         <Source scope="info.csv" entity_name="ospfPerformance_Info" format_id=""/>
                         <Source scope="AggregateResults.csv" entity_name="ospfPerformance_Aggregate" format_id=""/>
                         <Source scope="Iteration.csv" entity_name="ospfPerformance_Iteration" format_id=""/>
                      </Sources>
                   </XMD>
  }

 global one2oneArray
 set ospfPerformance::statList \
 [list [list framesSent     [getTxPorts one2oneArray] "Tx Frames per second" "Tx Frames" 1e0]\
       [list framesReceived [getRxPorts one2oneArray] "Rx Frames per second" "Rx Frames" 1e0]\
       [list bitsSent       [getTxPorts one2oneArray] "Tx Kbps"              "Tx Kb"     1e3]\
       [list bitsReceived   [getRxPorts one2oneArray] "Rx Kbps"              "Rx Kb"     1e3]\
 ]

########################################################################################
# Procedure: registerResultVars
#
# Description: This command registers all the local variables that are used in the
# display of the results with the Results Options Database.  This procedure must exist
# for each test.
#
########################################################################################
proc ospfPerformance::registerResultVars {} {
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
    if [ results registerTestVars transmitFrames        txActualFrames      0                               port TX ] { return 1 }
    if [ results registerTestVars receiveFrames         rxNumFrames         0                               port RX ] { return 1 }

    return 0
}

 set ospfPerformance::attributes {
    {
	{ NAME              testName }
	{ BACKEND_TYPE      string }
	{ DEFAULT_VALUE     "OSPF Performance" }
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
        { NAME              routeDelay }
        { BACKEND_TYPE      double }
        { DEFAULT_VALUE     0.0007 } 
        { MIN               0 }
        { MAX               256 }
        { LABEL             "Advertise delay per route: " }
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
	{ NAME              incrStep }
	{ BACKEND_TYPE      double }
	{ DEFAULT_VALUE     5 }
	{ LABEL             "Increment (%): " }
	{ VARIABLE_CLASS    testCmd }
    }

    {
	{ NAME              numIterations }
	{ BACKEND_TYPE      integer }
	{ DEFAULT_VALUE     5	}
	{ MIN               1 }
	{ MAX               100 }
	{ LABEL             "No. of Steps: " }
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
	{ NAME              enable802dot1qTag }
	{ BACKEND_TYPE      boolean }
	{ DEFAULT_VALUE     false }
	{ VALID_VALUES      {true false} }
	{ LABEL             "Enable 802.1q Tag" }
	{ VARIABLE_CLASS    testConf }
	{ ON_INIT           ospfPerformance::OnEnable802dot1qTagInit }
	{ ON_CHANGE         ospfPerformance::OnEnable802dot1qTagChange }
    }

    { 
	{ NAME              adjustForTags }
	{ BACKEND_TYPE      boolean }
	{ DEFAULT_VALUE     false }
	{ VALID_VALUES      {true false} }
	{ LABEL             "Adjust for Tags" }
	{ VARIABLE_CLASS    null }
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
	{ LABEL             "NOTE 1: If the DUT strips VLAN tags,the minimum frame size on\
             \n             Ethernet should be set to 68 bytes." }
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
	{ NAME              frameDataWidget }	    
	{ BACKEND_TYPE      null }
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
        { NAME              supportPortConfigMap }
        { BACKEND_TYPE      integer }
        { DEFAULT_VALUE     1 }
        { VARIABLE_CLASS    supportPortConfigMap }
    } 

    {
	{ NAME              protocolName }
	{ BACKEND_TYPE      string }
	{ VALID_VALUES      {ip ipV6} }
        { DEFAULT_VALUE     ip }
	{ VARIABLE_CLASS    testConf }	
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
	{ DEFAULT_VALUE     {Automatic Manual} }
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
 	              } 
        }
     }

    {
	{ NAME              directions }
	{ BACKEND_TYPE      string }
	{ DEFAULT_VALUE     {Unidirectional Bidirectional} }
	{ VARIABLE_CLASS    directions }
    }

    {
	{ NAME              map }
	{ BACKEND_TYPE      string }
	{ DEFAULT_VALUE     one2one }
	{ VARIABLE_CLASS    map }
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
	{ DEFAULT_VALUE     ospfPerformance }
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
	{ ON_CHANGE         ospfPerformance::PassFailEnable }
    }

    {
	{ NAME              thresholdMode }
	{ BACKEND_TYPE      string }
	{ DEFAULT_VALUE     line }
	{ VALID_VALUES      {line data} }
	{ VALUE_LABELS      {"% Line Rate >=" "  Data Rate >="} }
	{ VARIABLE          passFailMode }
	{ VARIABLE_CLASS    testConf }
	{ ON_CHANGE         ospfPerformance::ThroughputThresholdToggle }
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
	{ DEFAULT_VALUE     ospfPerformance.results }
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
	{ DEFAULT_VALUE     ospfPerformance.log }
	{ VARIABLE_CLASS    logger }
    }

    { 
        { NAME              ospfAreaID }
        { BACKEND_TYPE      integer }
        { DEFAULT_VALUE     0 }
        { MIN               0 }        
        { LABEL             "OSPF Area ID: " }
        { VARIABLE_CLASS    testCmd }
    }  

    { 
        { NAME              numPeers }
        { BACKEND_TYPE      integer }
        { DEFAULT_VALUE     5 }
        { MIN               1 }
        { MAX               1500 }
        { LABEL             "No. of Emulated Routers Per Port: " }	
        { VARIABLE_CLASS    testCmd }
        { ON_UPDATE         ospfPerformance::OnNumPeersUpdate }
        { ON_CHANGE         ospfPerformance::OnNumPeersChange }
    }

    {
	{ NAME               ipSrcIncrm }
	{ BACKEND_TYPE       string }
	{ DEFAULT_VALUE      0.0.0.1 }
	{ LABEL              "Increment By: " }
	{ VARIABLE_CLASS     testCmd }
	{ ON_INIT            ospfPerformance::IPValidAddressInit }
    }
    
    { 
        { NAME              routesPerRouter }
        { BACKEND_TYPE      integer }
        { DEFAULT_VALUE     1000 }
        { MIN               0 }
        { MAX               2000000 }
        { LABEL             "No. of Routes Per Emulated Router: " }
        { VARIABLE_CLASS    testCmd }
    }

    { 
        { NAME              firstRoute }
        { BACKEND_TYPE      string }
        { DEFAULT_VALUE     "194.20.0.1" }        
        { LABEL             "First Route: " }
        { VARIABLE_CLASS    testCmd }
        { ON_INIT           ospfPerformance::IPValidAddressInit }
        { ON_CHANGE         ospfPerformance::IPValidAddressChange }
    }
    
    { 
        { NAME              incrByRouters }
        { BACKEND_TYPE      string }
        { DEFAULT_VALUE     "0.1.0.0" }        
        { LABEL             "Increment By (across routers): " }
        { VARIABLE_CLASS    testCmd }
        { ON_INIT           ospfPerformance::IPValidAddressInit }
        { ON_CHANGE         ospfPerformance::IPValidAddressChange }
    }

    { 
        { NAME              incrSameRouter }
        { BACKEND_TYPE      integer }
        { DEFAULT_VALUE     24 }
        { MIN                0 }
        { LABEL             "Subnet mask: " }
        { VARIABLE_CLASS    testCmd }
        { ON_INIT           ospfPerformance::OnIncrSameRouterInit }        
    }

    {
        { NAME              routeOrigin }
        { BACKEND_TYPE      string }
        { DEFAULT_VALUE     "Another Area" }
        { VALID_VALUES      {"Another Area" "External 1" "External 2"} }
        { LABEL             "Route Origin: " }
        { VARIABLE_CLASS    testCmd }
        { ON_INIT           ospfPerformance::OnRouteOriginInit }
        { ON_CHANGE         ospfPerformance::OnRouteOriginChange }
    }

    {
        { NAME              routeNetworkOrigin }
        { BACKEND_TYPE      string }
        { DEFAULT_VALUE     ospfRouteOriginArea }
        { VALID_VALUES      {ospfRouteOriginArea ospfRouteOriginExternal ospfRouteOriginExternalType2 ospfV3RouteOriginArea ospfV3RouteOriginExternalType1 ospfV3RouteOriginExternalType2} }
        { VARIABLE_CLASS    testCmd }        
    }


    { 
        { NAME              routeMetric }
        { BACKEND_TYPE      integer }
        { DEFAULT_VALUE     0 }
        { MIN               0 }        
        { LABEL             "Route Metric: " }
        { VARIABLE_CLASS    testCmd }
    }

    {
        { NAME             interfaceType }
        { BACKEND_TYPE     string }
        { DEFAULT_VALUE    Broadcast }
        { VALID_VALUES     {Broadcast "Point To Point"} }
        { LABEL            "Interface Network Type: " }
        { VARIABLE_CLASS   testCmd }
        { ON_INIT          ospfPerformance::OnInterfaceNetworkInit } 
        { ON_CHANGE        ospfPerformance::OnInterfaceNetworkChange }
    }

    {
        { NAME             interfaceNetworkType }
        { BACKEND_TYPE     string }
        { DEFAULT_VALUE    ospfBroadcast }
        { VALID_VALUES     {ospfBroadcast ospfPointToPoint} }        
        { VARIABLE_CLASS   testCmd }        
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

###########################################################################
# ospfPerformance::ConfigValidate 
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
proc ospfPerformance::ConfigValidate {} {   

    set status $::TCL_OK

    #repeated frame sizes are eliminated from the list if there are any
    configValidation::RemoveDuplicatesFromFramesizeList ospfSuite

    #validate framesizeList
    if { ![configValidation::ValidateFrameSizeList  ospfSuite]} {
          set status $::TCL_ERROR
           return $status
    }
    
    #validate initial rate
    if { ![configValidation::ValidateInitialRate  ospfSuite]} {
        set status $::TCL_ERROR
         return $status
    }

    #common validatation to all the tests
    if {![configValidation::ValidateCommon ospfSuite]} {
       set status $::TCL_ERROR
         return $status
    }

    return $status
}

#####################################################################
# ospfPerformance::iterationFileColumnHeader
# 
# DESCRIPTION:
# This table contains a list of column headers at the top of the
# iteration.csv file.
#  
###
set ospfPerformance::iterationFileColumnHeader { 
    "Trial"
    "Frame Size"
    "Iteration"
    "Tx Port"
    "Rx Port"
    "Tput (fps)"
    "Rate (%)"
    "Tx Count"
    "Rx Count"
    "Frame Loss"
    "Frame Loss (%)"

}

#############################################################################
# ospfPerformance::MetricsPostProcess()
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
proc ospfPerformance::MetricsPostProcess {} {
    variable resultsDirectory
    variable resultArray
    variable rxPortList
    variable txPortList
    variable groupIdList
    global testConf

    set trialsPassed  0

    for {set trial 1} {$trial <= [ospfSuite cget -numtrials] } {incr trial} {

	set percentLineRateList {}
	set frameRateList {}
	set dataRateList {}
	set avgLatencyList {}
	set maxLatencyList {}

	foreach fs [lsort -dictionary [ospfSuite cget -framesizeList]] {

		foreach txMap $txPortList {
		    scan $txMap "%d %d %d" tx_c tx_l tx_p

		    lappend percentLineRateList \
			$resultArray($trial,$fs,1,$tx_c,$tx_l,$tx_p,TXpercentTput)

		    set frameRate $resultArray($trial,$fs,1,$tx_c,$tx_l,$tx_p,TXthroughput)

		    lappend frameRateList $frameRate

		    set dataRate  [mpexpr 8 * $fs * $frameRate]

		    lappend dataRateList $dataRate
		};# loop over txPort list

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
	    set resultArray($trial,avgLatency) "notCalculated";
	    set resultArray($trial,maxLatency) "notCalculated";
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

#############################################################################
# ospfPerformance::TestSetup()
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
proc ospfPerformance::TestSetup {} {
    variable testName;
    variable trial
    variable framesize    
    variable fileIdArray   
    variable map
    variable txPortList
    variable rxPortList
    variable atmOnlyPortList
    variable nonAtmPortList

    set map [map cget -type]
    global ${map}Array
    #global one2oneArray

    set status $::TCL_OK

    ospfSuite config -testName "OSPF Performance - Linear Binary Search"
    set testName [ospfSuite cget -testName]

    fconfigure [logger cget -ioHandle] -buffering line

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
       writeCSVHeader $fileID ospfSuite [ospfSuite cget -duration]
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

    learn config -when oncePerTest

    if [initTest ospfSuite ${map}Array {ip ipV6} errMsg] {
        errorMsg $errMsg
        return $::TCL_ERROR
    }

    #logMsg "\n===== [ospfSuite cget -testName] ====="
    #createMultipleInterfaces $rxPortList [ospfSuite cget -numPeers]
    createMultipleInterfaces $txRxPorts [ospfSuite cget -numPeers]

    # if the sum of emulated routers on RX ports for every TX port is greater than 256 then ERROR
    set enableRoutes [ospfSuite cget -routesPerRouter]    

    if {($enableRoutes==0)} {
         logMsg "*** No route advertising and no network range advertising. No streams to set."
         set status 1
         return $status
    }
    
    foreach txPort [lsort [array names txRxArray]] {
         scan $txPort "%d,%d,%d" tx_c tx_l tx_p
         set numRxPorts [llength  $txRxArray($txPort)]
         set sum [mpexpr $numRxPorts*[ospfSuite cget -numPeers]]
         if {$sum>=256} {
             errorMsg "\n*** WARNING: The number of emulated routers on RX ports for TX port [getPortId $tx_c $tx_l $tx_p] is $sum, but it shouldn't be greater than 255 ! \n Decrease the number of emulated routers or the number of Rx ports in the map."
             set status $::TCL_ERROR
             return $status
         }
    }

    return $status;
}

#############################################################################
# ospfPerformance::TestCleanUp()
#
# DESCRIPTION
# This procedure resets common code elements needed at the end of a test.
#
# RETURNS:  
# status      TCL_OK     - on success
#             TCL_ERROR  - on failure
#
###
proc ospfPerformance::TestCleanUp {} {
    #variable status;

    set status $::TCL_OK

    return $status;
}

#############################################################################
# ospfPerformance::TrialSetup()
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
proc ospfPerformance::TrialSetup {} {
    variable trial;
    #variable status;
    
    set status $::TCL_OK

    logMsg "\n******* TRIAL $trial - [ospfSuite cget -testName] *******"
    set ::ospfSuite::trial $trial
    
    return $status;
}

#############################################################################
# ospfPerformance::AlgorithmSetup()
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
proc ospfPerformance::AlgorithmSetup {} {
    
    variable ospfPorts
    variable protocolList
    variable protcolStatList        
    variable framesize;
    variable status;
    variable map
    variable rxPortList
    variable userRate
    variable maxRate
    variable trial
    variable atmOnlyPortList
    
    set status $::TCL_OK
    set map [map cget -type]
    global ${map}Array

    set ::ospfSuite::framesize $framesize
    ospfSuite config -framesize  $framesize
    set framesizeString "Framesize:$framesize"

    #logMsg "\n******* Framesize $framesize, trial $trial - [ospfSuite cget -testName] *******\n"

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

    ######## set up results for this test
    setupTestResults ospfSuite $map ""  \
	${map}Array                       \
	$framesize                          \
	[ospfSuite cget -numtrials]       \
	false                                \
	1   \
        ospfPerformance

    if [initMaxRate ${map}Array maxRate $framesize userRate [ospfSuite cget -percentMaxRate]] {
         set status $::TCL_ERROR
         return $status
    }

    cleanUpOspfGlobals
    #set ospfPorts [getRxPorts ${map}Array ]
    set ospfPorts [getAllPorts ${map}Array ]

set protocolList {}
set protcolStatList {}

    if {[protocol cget -name]==$::ip} {          
            lappend protocolList ospf
            lappend protcolStatList enableOspfStats
    } else {        
            lappend protocolList ospfV3
            lappend protcolStatList enableOspfV3Stats
    }     

     if [enableProtocolServer ospfPorts $protocolList noWrite] {
        errorMsg "***** Error enabling OSPF..."
        return $::TCL_ERROR
     }

     if [enableProtocolStatistics ospfPorts $protcolStatList] {
        errorMsg "***** Error enabling OSPF statistics..."
        return $::TCL_ERROR
     }

     #     if [ospfSuite::configureOspfProtocols ${map}Array] {
#        errorMsg "***** Error configuring OSPF..."
#        return $::TCL_ERROR
#     }

    return $status
}

########################################################################################
# Procedure: ospfPerformance::configureOspf
#
# Description: This command added a routeRange to the router.
#
# Argument(s):
# TxRxArray       - map, ie. one2oneArray
# enable          - enabling the route item and interface item
# write           - flag to commit or not commit the changes
# testCmd         - name of test command, ie. ospfPerformance
#
# Results :       0 : No error found
#                 1 : Error found
#         
########################################################################################
proc ospfPerformance::configureOspf {TxRxArray {write nowrite} {enableConnectDut true} {enableRouteRange true} {testCmd ospfSuite}} \
{   

    upvar $TxRxArray    txRxArray

    set retCode 0

    #set rxPortList      [getRxPorts txRxArray]
    set rxPortList [getAllPorts txRxArray]

    logMsg "Configuring OSPF ..."
    set firstRouteAddress [$testCmd cget -firstRoute]
    set stepToIncrement 0
    foreach rxPort $rxPortList {
        scan $rxPort "%d %d %d" tx_c tx_l tx_p

        initializeOspf $tx_c $tx_l $tx_p
      
        if [ip get $tx_c $tx_l $tx_p] {
            errorMsg "Error getting ip on port [getPortId $tx_c $tx_l $tx_p]"
            set retCode 1
        }
        cleanUpOspfGlobals
        set noRouters 1
        
        set firstRouteAddress [$testCmd cget -firstRoute]
        while { $noRouters <= [ospfSuite cget -numPeers] } {
            set fRoute [num2ip [mpexpr [ip2num $firstRouteAddress]+[ip2num [ospfSuite cget -incrByRouters]]*$stepToIncrement]]
            if {[addRouteItem_ospfPerformance true osfpSuite [ospfSuite cget -routeNetworkOrigin] $fRoute]} {
                errorMsg "*** Error Adding routeItem for routeRange"
                set retCode 1
            }            
            ospfInterface config -protocolInterfaceDescription [format "%02d:%02d ProtocolInterface - $noRouters" $tx_l $tx_p]
            if {[addInterfaceItem_ospfPerformance $enableConnectDut]} {
                errorMsg "*** Error Adding Interface"
                set retCode 1
            } 
                                               
            ospfRouter  config  -routerId  $tx_l.$tx_p.$noRouters.0
            ospfRouter  config  -enable     1
            ospfRouter  config  -enableDiscardLearnedLsas   true
            
            set routerName   router[getNextRouter]
                                                  
            if [ospfServer addRouter $routerName] {
                errorMsg "Error in adding router $routerName"
                set retCode 1
            }
            incr noRouters
            incr stepToIncrement
        }
        if {$write == "write"} {
            if [ospfServer write] {
                errorMsg "*** Error writing ospfServer"
                set retCode 1
            }
        }
    }

    return $retCode
}

########################################################################################
# Procedure: ospfPerformance::configureOspfv3
#
# Description: This command added a routeRange to the router.
#
# Argument(s):
# TxRxArray       - map, ie. one2oneArray
# enable          - enabling the route item and interface item
# write           - flag to commit or not commit the changes
# testCmd         - name of test command, ie. ospfPerformance
#
# Results :       0 : No error found
#                 1 : Error found
#         
########################################################################################
proc ospfPerformance::configureOspfv3 {TxRxArray {write nowrite} {enableConnectDut true} {enableRouteRange true} {testCmd ospfSuite}} \
{   

    upvar $TxRxArray    txRxArray

    set retCode 0

    #set rxPortList      [getRxPorts txRxArray]
    set rxPortList      [getAllPorts txRxArray]
    #set networkIPAddress [ospfSuite cget -firstRoute]

    logMsg "Configuring OSPF ..."
    set firstRouteAddress [$testCmd cget -firstRoute]
    foreach rxPort $rxPortList {
        scan $rxPort "%d %d %d" tx_c tx_l tx_p

        initializeOspfV3 $tx_c $tx_l $tx_p
      
        if [ip get $tx_c $tx_l $tx_p] {
            errorMsg "Error getting ip on port [getPortId $tx_c $tx_l $tx_p]"
            set retCode 1
        }
        cleanUpOspfGlobals
        set noRouters 1
        set stepToIncrement 0
        while { $noRouters <= [ospfSuite cget -numPeers] } {
            
             if {[addRouteItem_ospfPerformance true osfpSuite [ospfSuite cget -routeNetworkOrigin] $firstRouteAddress]} {
                 errorMsg "*** Error Adding routeItem for routeRange"
                 set retCode 1
             }
              set firstRouteAddress [ipv6::convertBytesToIpv6Address [value2Hexlist [mpexpr [hexlist2Value \
                        [ipv6::host2addr $firstRouteAddress]] +[hexlist2Value [ipv6::host2addr [ospfSuite cget -incrByRouters]]]] 16]]
             ospfV3Interface config -protocolInterfaceDescription [format "%02d:%02d ProtocolInterface - $noRouters" $tx_l $tx_p]
             
             if {[addInterfaceItem_ospfPerformance $enableConnectDut]} {
                 errorMsg "*** Error Adding Interface"
                 set retCode 1
             }
            ospfV3Router                 setDefault                                   
            ospfV3Router  config  -routerId  $tx_l.$tx_p.$noRouters.0
            ospfV3Router  config  -enable     1
            ospfRouter  config  -enableDiscardLearnedLsas   true
            
            set routerName   router[getNextRouter]

             if [ospfV3Server addRouter $routerName] {
                 errorMsg "Error in adding router $routerName"
                 set retCode 1
             }
            incr noRouters
            incr stepToIncrement
        }
        if {$write == "write"} {
            if [ospfV3Server write] {
                errorMsg "*** Error writing ospfServer"
                set retCode 1
            }
        }
    }
#     if {$retCode == 0} {
#         set retCode [writeConfigToHardware txRxArray]
#         }
    return $retCode
}

########################################################################################
# Procedure: addRouteItem
#
# Description: This command added a routeRange to the router.
#
# Argument(s):
# enable :
# metric :
# routeRangeName :

# Results :       0 : No error found
#                 1 : Error found
#  
########################################################################################
proc addRouteItem_ospfPerformance {enable {testCmd ospfSuite} {routeOrigin ospfRouteOriginArea} {firstRoute "194.20.0.1"} } \
{
    set retCode 0

    if {[protocol cget -name] == $::ip} {
        ospfRouteRange setDefault

        ospfRouteRange config -enable              $enable       
        ospfRouteRange config -routeOrigin         $routeOrigin
        ospfRouteRange config -metric              [ospfSuite cget -routeMetric]
        ospfRouteRange config -numberOfNetworks    [ospfSuite cget -routesPerRouter] 
        ospfRouteRange config -prefix              [ospfSuite cget -incrSameRouter]     
        ospfRouteRange config -networkIpAddress    $firstRoute

    } else {
        ospfV3RouteRange setDefault

        ospfV3RouteRange config -enable              $enable       
        ospfV3RouteRange config -routeOrigin         $routeOrigin
        ospfV3RouteRange config -metric              [ospfSuite cget -routeMetric]
        ospfV3RouteRange config -numRoutes           [ospfSuite cget -routesPerRouter] 
        ospfV3RouteRange config -maskWidth           [ospfSuite cget -incrSameRouter]     
        ospfV3RouteRange config -networkIpAddress    $firstRoute

    }    

    set routeRangeName  routeRange[getNextRouteRange]

        if {[protocol cget -name] == $::ip} {
            set p ""
        } else {
            set p "V3"
        }    

    if {[ospf${p}Router addRouteRange $routeRangeName ]} {
        errorMsg "*** Error Adding RouteRange item $routeRangeName [ospfSuite cget -networkIpAddress]"
        set retCode 1
    }
    return $retCode
} 

########################################################################################
# Procedure: addInterfaceItem
#
# Description: This command added an interface to the router
#
# Argument(s):
# isConnectToDut :
# interfaceName :
#
# Results :       0 : No error found
#                 1 : Error found
#   
########################################################################################
proc addInterfaceItem_ospfPerformance {isConnectToDut {enable true} {testCmd ospfSuite}} \
{
    set retCode 0

        if {[protocol cget -name] == $::ip} {
             ospfInterface config -enable            $enable
             ospfInterface config -connectToDut      $isConnectToDut
             ospfInterface config -areaId            [$testCmd cget -ospfAreaID]
             ospfInterface config -networkType       [$testCmd cget -interfaceNetworkType]
             #ospfInterface config -networkType ospfBroadcast
             ospfInterface config -metric            [$testCmd cget -routeMetric]
        } else {
             ospfV3Interface config -enable          $enable             
             ospfV3Interface config -areaId          [$testCmd cget -ospfAreaID]
             ospfV3Interface config -type            [$testCmd cget -interfaceNetworkType]
             #ospfInterface config -networkType ospfBroadcast
             #ospfV3Interface config -metric          [$testCmd cget -routeMetric]
        }     
        
    set interfaceName interface[getNextInterface]

        if {[protocol cget -name] == $::ip} {
            set p ""
        } else {
            set p "V3"
        }
       
    if {[ospf${p}Router addInterface $interfaceName] } {        
        errorMsg "*** Error Adding Interface item $interfaceName"
        set retCode 1
    }
    return $retCode
}  

#################################################################################
# Procedure: writeOspfStreams
#
# Description: This command configures and writes the stream for ospf
#               
#
#################################################################################
proc writeOspfStreams_ospfPerformance {TxRxArray {TxNumFrames ""} {numFrames 0} {testCmd ospfSuite}} \
{
    upvar $TxRxArray    txRxArray
    upvar $TxNumFrames  txNumFrames

    variable atmOnlyPortList
    variable nonAtmPortList

    set framesize	[ospfSuite cget -framesize]
    set initialDuration [$testCmd cget -duration]

    filterPallette setDefault
    filter setDefault
    udf             setDefault

    if {![info exists udfList]} {
        set udfList {1 2 3 4}
    }

    disableUdfs $udfList

    
    set genericPattern        {AA AA AA AA}
    set adjustVlanOffset        0

    
    set retCode 0

    set preambleSize    8

    stream setDefault
    stream config -daRepeatCounter   daArp
    stream config -framesize         [$testCmd cget -framesize]
    stream config -enableTimestamp   true

    stream config -enableIbg         false
    stream config -enableIsg         false

    stream config -rateMode          usePercentRate
    stream config -percentPacketRate [$testCmd cget -percentMaxRate]
    stream config -gapUnit           gapNanoSeconds

    set firstRouteAddress [$testCmd cget -firstRoute]

    set streamGroup 0
    foreach txPort [lsort [array names txRxArray]] {
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
	    set destIpOffset       [expr $destIpOffset+4]
	}


        set pppTxOffset 0
 	if {[detectPPP $tx_c $tx_l $tx_p]} {
 	    set pppTxOffset 10
 	}

        set atmTxOffset 0
        if {[atmUtils::isAtmPort $tx_c $tx_l $tx_p]} {
            set atmTxOffset 10
        }

        set streamID    1
        set txNumFrames($tx_c,$tx_l,$tx_p)   0

        # get the mac & Ip addresses for the da/sa
        if [port get $tx_c $tx_l $tx_p] {
            errorMsg "Port [getPortId $tx_c $tx_l $tx_p] not configured yet!"
            set retCode 1
        }

        set numRxPorts [llength  $txRxArray($txPort)]
        foreach rxPort [lsort $txRxArray($txPort)] {
            scan [join $rxPort] "%d %d %d" rx_c rx_l rx_p

            #set count [lsearch [getRxPorts txRxArray] $rxPort]
            set count [lsearch [getAllPorts txRxArray] $rxPort]

            stream config -sa   [port cget -MacAddress]

            for {set router 0} {$router < [ospfSuite cget -numPeers]} {incr router} {

                set stepToIncrement [mpexpr $count*[ospfSuite cget -numPeers]+$router]

                if { $numFrames == 0 } {
                    stream config -numFrames    [ospfSuite cget -routesPerRouter]
                } else {
                    stream config -numFrames    $numFrames
                }
                stream config -preambleSize     $preambleSize

                if {[protocol cget -name] == $::ip} {

                    set networkIPAddress [num2ip [mpexpr [ip2num $firstRouteAddress]+[ip2num [ospfSuite cget -incrByRouters]]*$stepToIncrement]]

                    #   Use UDF 3 for Destination Ip Address
                    udf setDefault
                    udf config -enable          $::true
                    udf config -offset          [expr $destIpOffset-$pppTxOffset+$atmTxOffset]
                    udf config -countertype     $::c32
                    udf config -initval         [host2addr $networkIPAddress]
                    udf config -repeat          [ospfSuite cget -routesPerRouter]
                    udf config -step            [mpexpr 2<<[expr 31 -  [ospfSuite cget -incrSameRouter]]]

                    if {[udf set 3]} {
                        errorMsg "Error setting udf 3."
                        set status 1
                    }

                } else {

                    set networkIPAddress [ipv6::convertBytesToIpv6Address [value2Hexlist [mpexpr [hexlist2Value \
                               [ipv6::host2addr $firstRouteAddress]] +[hexlist2Value [ipv6::host2addr [ospfSuite cget -incrByRouters]]]*$stepToIncrement] 16]]

                    if [ipV6 get $tx_c $tx_l $tx_p] {
                        errorMsg "Error getting ip on port [getPortId $tx_c $tx_l $tx_p]"
                        set retCode 1
                    }

                    ipV6   config -destAddr       $networkIPAddress
                    ipV6   config -destMask       [ospfSuite cget -incrSameRouter]
                    ipV6   config -destAddrMode   ipV6IncrNetwork
                    ipV6   config -destAddrRepeatCount   [ospfSuite cget -routesPerRouter]

                    if [ipV6 set $tx_c $tx_l $tx_p] {
                        errorMsg "Error setting ip on port [getPortId $tx_c $tx_l $tx_p]"
                        set retCode 1
                    }   

                }

                ##### Stream for generating traffic to the routes #####
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
                        set retCode 1
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
                set loopCount    [mpexpr round (double ($framerate)/[stream cget -numFrames]/[ospfSuite cget -numPeers]/$numRxPorts * $initialDuration)]
                if { $loopCount == 0} {
                    set loopCount 1
                    set newDuration [mpexpr round(1.0 * $loopCount * [stream cget -numFrames] * [ospfSuite cget -numPeers] * $numRxPorts / $framerate)]
 		    if {[$testCmd cget -duration] < $newDuration} {
			$testCmd config -duration $newDuration
 		    }
                }

                set txNumFrames($tx_c,$tx_l,$tx_p)  [mpexpr $txNumFrames($tx_c,$tx_l,$tx_p)+($loopCount* [stream cget -numFrames])]

                if {$streamID < [mpexpr [llength $txRxArray($txPort)]*[ospfSuite cget -numPeers]] } {
                    stream config -dma   3
                } else {
                    stream config -dma   firstLoopCount
                    stream config -loopCount    $loopCount
                }
                
                set  packetGroupId [mpexpr ($streamGroup << 8) | $stepToIncrement]

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

                packetGroup config -signatureOffset	       [expr $packetGroupOffset-$pppTxOffset+$atmTxOffset]
                packetGroup config -groupIdOffset	       [expr $packetGroupIdOffset-$pppTxOffset+$atmTxOffset]  
                packetGroup config -signature	           $genericPattern
                packetGroup config -insertSequenceSignature $::true
                packetGroup config -sequenceNumberOffset    [expr $sequenceNumberOffset-$pppTxOffset+$atmTxOffset]
                packetGroup config -allocateUdf             $::false

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
            }   

            set pppRxOffset 0
             if {[detectPPP $rx_c $rx_l $rx_p]} {
                 set pppRxOffset 10
             }

            set atmRxOffset 0
            if {[atmUtils::isAtmPort $rx_c $rx_l $rx_p]} {
                set atmRxOffset 10
            }

            # set up the pattern filter
            filterPallette config -pattern1		    $genericPattern
            filterPallette config -patternMask1		{00 00 00 00}
            filterPallette config -patternOffset1	[expr $packetGroupOffset-$pppRxOffset+$atmRxOffset + [adjustSignatureUdfForVlan $txPort $rxPort]]

            if [filterPallette set $rx_c $rx_l $rx_p] {
                errorMsg "Error setting filter pallette for [getPortId $rx_c $rx_l $rx_p]"
                set status $::TCL_ERROR
            }

            # set the filter parameters on the receive port
            filter setDefault
            filter config -captureFilterEnable	        true
            filter config -captureTriggerEnable	        true            
            filter config -userDefinedStat2Enable  true
            filter config -userDefinedStat2Pattern pattern1

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
            
        }
        incr streamGroup

    }

    if {[$testCmd cget -duration] != $initialDuration} {
	logMsg "WARNING: The configured duration was changed to [$testCmd cget -duration] in order to test all advertised routes."
	foreach txPort [lsort [array names txRxArray]] {
	    scan $txPort "%d,%d,%d" tx_c tx_l tx_p

	    set txNumFrames($tx_c,$tx_l,$tx_p)   0

	    set numRxPorts [llength  $txRxArray($txPort)]
	    set numStreams [mpexpr $numRxPorts *[bgpSuite cget -numPeers]]
	    if [stream get $tx_c $tx_l $tx_p $numStreams] {
		errorMsg "Error getting stream $numStreams from port [getPortId $tx_c $tx_l $tx_p]"
		set retCode 1
	    }

	    # note - we set the stream twice because we need to get the conf'd framerate for calc'ing the duration
	    set framerate   [stream cget -framerate]
	    set loopCount 1

	    #calculate the duration 
	    set loopCount    [mpexpr round (double ($framerate)/[stream cget -numFrames]/$numStreams * [$testCmd cget -duration])]
	    stream config -loopCount    $loopCount
	    set txNumFrames($tx_c,$tx_l,$tx_p)  [mpexpr $txNumFrames($tx_c,$tx_l,$tx_p)+($loopCount* [stream cget -numFrames]*$numStreams)]
	    if [stream set $tx_c $tx_l $tx_p $numStreams] {
		errorMsg "Error setting stream $numStreams for network on port [getPortId $tx_c $tx_l $tx_p]"
		set retCode 1
	    }
	}
    }

    if {$retCode == 0} {
       # adjustOffsets txRxArray
        set retCode [writeConfigToHardware txRxArray]
    }
    return $retCode
}

#############################################################################
# ospfPerformance::AlgorithmBody()
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
proc ospfPerformance::AlgorithmBody {args} {
    variable status
    variable framesize
    variable trial
    variable map
    variable txPortList
    variable rxPortList
    variable txNumFrames
    variable totalTxNumFrames
    variable totalRxNumFrames
    variable userRate
    variable thruputRate
    variable resultArray

    set map [map cget -type]
    global ${map}Array
    
    set status $::TCL_OK
    
    set done 1
    set count 1
    set totalRoutes         [ospfSuite cget -routesPerRouter]
    set currRoutesPerPeer   [ospfSuite cget -routesPerRouter]
    set framesizeString "Framesize:$framesize"

    #set ospfPorts    [getRxPorts ${map}Array]
    set ospfPorts    [getAllPorts ${map}Array]
    set beginNumberRoutes   [ospfSuite cget -routesPerRouter]        

        #set advertiseDelay [mpexpr  round ( $currRoutesPerPeer * [ospfSuite cget -advertiseDelayPerRoute])]
        
        logMsg "####### Iteration: $count, $framesizeString, Number of Routes: $currRoutesPerPeer"                    

        if {[string tolower [testConfig::getTestConfItem protocolName]] == "ipv6"} {
            set str "v3"
        } else {
            set str ""
        }

        if [ospfPerformance::configureOspf${str} ${map}Array] {
             errorMsg "***** Error configuring OSPF..."
             return $::TCL_ERROR
        }

#          if [enableProtocolServer ospfPorts ospf noWrite] {
#              errorMsg "***** Error enabling OSPF..."
#              return $::TCL_ERROR
#          }
#
#          if [enableProtocolStatistics ospfPorts enableOspfStats] {
#              errorMsg "***** Error enabling OSPF statistics..."
#              return $::TCL_ERROR
#          }

# write the streams
        if [writeOspfStreams_ospfPerformance ${map}Array txNumFrames $currRoutesPerPeer] {
            return $::TCL_ERROR
        }

        if {[string tolower [testConfig::getTestConfItem protocolName]] == "ipv6"} {
                set str "OspfV3"
                set str1 "V3"
            } else {
                set str ""
                set str1 ""
            }

        # Start OSPF Server
        logMsg "Starting OSPF..."
        if [startOspf${str1}Server ospfPorts] {
            errorMsg "Error Starting OSPF!"
            return $::TCL_ERROR
        }

        #set advertiseDelay [mpexpr  round (ceil ( [ospfSuite cget -routesPerRouter] * [ospfSuite cget -advertiseDelayPerRoute]))]        
       	set advertiseDelay [ospfPerformance::estimateAdvertiseDelay [ospfSuite cget -routesPerRouter]]    
        #set advertiseDelay 60
        if [confirm${str}FullSession ospfPorts $advertiseDelay] {
              errorMsg "Error!!Neighbor(s) are not in full state. The advertiseDelayPerRoute is not long enough \
              or there is a network problem"
              ospf${str1}CleanUp ospfPorts
              return $::TCL_ERROR
        }

        #set advertiseDelay [ospfPerformance::estimateAdvertiseDelay [ospfSuite cget -routesPerRouter]]
        logMsg "Pausing for 30 seconds before starting transmitting ..."          
        writeWaitForPause "Pause before transmitting.." 30 

        set status [ospfPerformance::doBinarySearch ospfSuite ${map}Array userRate \
                thruputRate txNumFrames totalTxNumFrames rxNumFrames \
                totalRxNumFrames percentTputRateArray]

        foreach txMap $txPortList {
            scan $txMap "%d %d %d" tx_c tx_l tx_p
            set resultArray($trial,$framesize,1,$tx_c,$tx_l,$tx_p,TXtransmitFrames) $txNumFrames($tx_c,$tx_l,$tx_p)
        }  

#end stats - measure #################################################################

#         logMsg "Withdrawing the routes before stopping the OSPF..."
#         set ospf_Port       [lindex $ospfPorts 0]
#         scan $ospf_Port     "%d %d %d" c l p
#
#         if [setEnableRouteRange  $ospf_Port false 1 1] {
#             logMsg "Error in disabling the route"
#             set status 1
#         }
#
#         set withdrawPause [ospfSuite cget -dutProcessingDelay]
#         if {[info exists userWithdrawPause]} {
#             set withdrawPause   $userWithdrawPause
#         }
#         writeWaitForPause  "Waiting for Processing Route Withdrawal .." $withdrawPause

        ####################################################################

#         ospf${str1}CleanUp ospfPorts
#
#         writeWaitForPause  "Waiting for tear down .." [ospfSuite cget -dutProcessingDelay]

        set status [expr [ospfPerformance::AlgorithmMeasure] && $status]
    
    return $status;
}

#############################################################################
# ospfPerformance::AlgorithmMeasure()
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
proc ospfPerformance::AlgorithmMeasure {} {
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
    set map [map cget -type]
    global ${map}Array

    copyPortList ${map}Array txRxArray

    set status $::TCL_OK

    set totalLoss           [calculatePercentLoss $totalTxNumFrames	$totalRxNumFrames]
    set totalTput           0
    set totalPercentTput    0

#stats - measure
        
#     if [clearStatsAndTransmit ${map}Array [ospfSuite cget -duration] [ospfSuite cget -staggeredStart]] {
#         return $::TCL_ERROR
#     }
#
#     #waitForResidualFrames [ospfSuite cget -waitResidual]
#
#     puts "collecting Tx:"
#     # Poll the Tx counters until all frames are sent
#     stats::collectTxStats [getTxPorts ${map}Array] txNumFrames txActualFrames totalTxNumFrames
#     puts "collecting Rx:"
#     collectRxStats [getRxPorts ${map}Array] rxNumFrames totalRxNumFrames
#     debugMsg "rxNumFrames :[array get rxNumFrames]"
# ###
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

            #set count [lsearch [getRxPorts ${map}Array] $rxPort]
            set count [lsearch [getAllPorts ${map}Array] $rxPort]
            for {set router 0} {$router < [ospfSuite cget -numPeers]} {incr router} {
                set stepToIncrement [mpexpr $count*[ospfSuite cget -numPeers]+$router]
                lappend groupIdList($rx_c,$rx_l,$rx_p) [mpexpr ($streamGroup << 8) | $stepToIncrement]
            }
        }
        incr streamGroup
    }
    foreach rxMap $rxPortList {
        scan [join $rxMap] "%d %d %d" rx_c rx_l rx_p
    }
##MM   groupIdList
    #foreach var [array names groupIdList] {
	#logMsg "groupIdList($var) = $groupIdList($var)"
    #}
##MM
# Collect Packet Group Stats:

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

    printResults ${map}Array fileIdArray $trial $framesize

    return $status
}

###########################################################################
# ospfPerformance::AlgorithmCleanUp()
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
proc ospfPerformance::AlgorithmCleanUp {} {
    
    #variable txPortList
    variable rxPortList    

         variable map
         set map [map cget -type]
         global ${map}Array

    set status $::TCL_OK

        set rxPorts [getAllPorts ${map}Array]
        protocolCleanUp rxPorts ospf no verbose

        # Small delay for better performance before starting the protocols for a new trial
        after 2000    

    return $status
}

#############################################################################
# ospfPerformance::TrialCleanUp()
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
proc ospfPerformance::TrialCleanUp {} { 
    variable map
    set map [map cget -type]
    global ${map}Array

    variable status
    
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
# ospfPerformance::printResults()
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
proc ospfPerformance::printResults { TxRxArray FileIdArray trial framesize} {
    variable map
    set map [map cget -type]
    global ${map}Array
    variable txPortList
    variable rxPortList
    variable resultArray

    upvar $TxRxArray            txRxArray
    upvar $FileIdArray          fileIdArray

    set defaultDelimiter    "  "

    set framesizeRateString "Frame Size: [ospfSuite cget -framesize]"

    foreach fileType [array names fileIdArray] {
        foreach {fileID delimiter} $fileIdArray($fileType) {}
    }

    set title [format "%-10s%s%-10s%s%-10s%s%-10s%s%-10s%s%-10s%s%-10s%s%-15s%s%-15s%s%-15s%s%-10s" \
            "Tx Port"	        $delimiter \
            "Rx Port"		$delimiter \
            "Tx Count"		$delimiter \
            "Tput(%)"	        $delimiter \
            "Tput(fps)"         $delimiter \
            "Router ID"		$delimiter \
            "Rx Count"	        $delimiter \
            "AvgLatency(ns)"    $delimiter \
            "MinLatency(ns)"    $delimiter \
            "MaxLatency(ns)"    $delimiter \
            "Data Errors" ]

    foreach fileType [array names fileIdArray] {
        foreach {fileID delimiter} $fileIdArray($fileType) {}
        puts $fileID "******* TRIAL $trial, framesize: $framesize - OSPF Performance *******\n\n"
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

                #set count [lsearch [getRxPorts txRxArray] $rxPort]
                set count [lsearch [getAllPorts txRxArray] $rxPort]

                for {set router 1} {$router <= [ospfSuite cget -numPeers]} {incr router} {
                    set routerGroup [mpexpr $count*[ospfSuite cget -numPeers]+$router-1]
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
                        $rx_l.$rx_p.$router.0                     $delimiter \
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

            #set count [lsearch [getRxPorts txRxArray] $rxPort]
            set count [lsearch [getAllPorts txRxArray] $rxPort]

            for {set router 1} {$router <= [ospfSuite cget -numPeers]} {incr router} {
                set routerGroup [mpexpr $count*[ospfSuite cget -numPeers]+$router-1]
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
                        $rx_l.$rx_p.$router.0                     $delimiter \
                        $rxCount                                  $delimiter \
                        $avgLatency                               $delimiter \
                        $minLatency                               $delimiter \
                        $maxLatency                               $delimiter \
                        $dataErrors  ]
            }
        }
        incr streamGroup
    }

    logMsg "[stringRepeat "*" [expr [string length $title] + 10]]"

    foreach fileType [array names fileIdArray] {
        foreach {fileID delimiter} $fileIdArray($fileType) {}
        puts $fileID [stringRepeat "*" [expr [string length $title] + 10]]
        #logMsg "[stringRepeat "*" [expr [string length $title] + 10]]"
        puts $fileID "\n"
    }
}

################################################################################
#
# ospfPerformance::PassFailCriteriaEvaluate()
#
# DESCRIPTION:
# This procedure calculates the number of trials that have executed successfully
# based upon user-specified Pass/Fail criteria.
###
proc ospfPerformance::PassFailCriteriaEvaluate {} {
    variable trialsPassed
    variable resultArray
    global testConf

    #logMsg "***************************************";
    logMsg "*** PASS Criteria Evaluation\n"
    if {[info exists testConf(passFailEnable)] == 0} {
    # maintain backwards compatiblity with scripts without pass/fail
        set trialsPassed "N/A";
        logMsg "*** # Of Trials Passed: $trialsPassed"
        logMsg "***************************************"
        return;
    }

    if {!$testConf(passFailEnable)} {
        # Pass/Fail Criteria disabled implies N/A
        set trialsPassed "N/A"
        logMsg "*** # Of Trials Passed: $trialsPassed"
        logMsg "***************************************"
        return
    } 

    set trialsPassed 0

    for {set trial 1} {$trial <= [ospfSuite cget -numtrials] } {incr trial} {
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
# ospfPerformance::writeIterationData2CSVFile
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
proc ospfPerformance::writeIterationData2CSVFile { iteration testCmd TxRxArray Framerate TputRateArray \
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

#######################################################################
# ospfPerformance::WriteResultsCSV()
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
proc ospfPerformance::WriteResultsCSV {} {
    variable resultsDirectory
    variable trialsPassed
    variable txPortList
    variable rxPortList
    variable resultArray
    global testConf passFail
    variable map
    set map [map cget -type]
    global ${map}Array

    copyPortList ${map}Array txRxArray

    set dirName $resultsDirectory
    if { [ospfSuite cget -framesizeList] == {} } {
        # no new result entry to write
        return
    }

    if {[catch {set csvFid [open $dirName/results.csv w]}]} {
        logMsg "***** WARNING:  Cannot open csv file."
        return
    }

    puts $csvFid "Trial,Frame Size (bytes),Tx Port,Rx Port,Tx Count,No Drop Rate (% Line rate),Tput (fps),Router ID,Rx Count,Avg Latency (ns),Min Latency (ns),Max Latency (ns),Data Errors"
        for {set trial 1} {$trial <= [ospfSuite cget -numtrials] } {incr trial} {
            foreach framesize [lsort -dictionary [ospfSuite cget -framesizeList]] {
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

                        #set count [lsearch [getRxPorts ${map}Array] $rxMap]
                        set count [lsearch [getAllPorts txRxArray] $rxMap]

                        for {set router 1} {$router <= [ospfSuite cget -numPeers]} {incr router} {
                            set routerGroup [mpexpr $count*[ospfSuite cget -numPeers]+$router-1]

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
# ospfPerformance::WriteAggregateResultsCSV()
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
proc ospfPerformance::WriteAggregateResultsCSV {} {
    variable resultsDirectory 
    variable resultArray   
    global passFail
    variable map
    set map [map cget -type]
    global ${map}Array

    copyPortList ${map}Array txRxArray
    
    set dirName $resultsDirectory    

    if {[catch {set csvFid [open $dirName/AggregateResults.csv w]}]} {
        logMsg "***** WARNING:  Cannot open AggregateResults.csv file."
        return
    }
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
        foreach framesize [lsort -dictionary [ospfSuite cget -framesizeList]] {
                for {set trial 1} {$trial <= [ospfSuite cget -numtrials] } {incr trial} {
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
                                        #set count [lsearch [getRxPorts ${map}Array] $rxMap]
                                        set count [lsearch [getAllPorts txRxArray] $rxMap]

                                        for {set router 1} {$router <= [ospfSuite cget -numPeers]} {incr router} {
                                            set routerGroup [mpexpr $count*[ospfSuite cget -numPeers]+$router-1]
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

##########################################
# ospfPerformance::WriteRealTimeCSV
#
#  Create Real Time Chart CSV
#
##########################################
proc ospfPerformance::WriteRealTimeCSV {} {
    csvUtils::writeRealTimeCsv ospfPerformance "OSPF: Performance ";
}

################################################################################
#
# ospfPerformance::PassFailEnable(args)
#
# DESCRIPTION:
# This procedure enables or disables Throughput Pass/Fail Criteria related widgets.
# This either allows the user to click on and adjust widgets or prevents this.
#
# ARGUMENTS
# args       - variable arguments
#
# RETURNS
# none
#
###
proc ospfPerformance::PassFailEnable {args} {
    global passFailEnable

    set state disabled
    set latencyState disabled

    if {$passFailEnable} {
	   ospfPerformance::ThroughputThresholdToggle

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
# ospfPerformance::ThroughputThresholdToggle(args)
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
proc ospfPerformance::ThroughputThresholdToggle {args} {
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
# ospfPerformance::PassFailLatencyEnable(args)
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
proc ospfPerformance::PassFailLatencyEnable {args} {
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

################################################################################
#
# ospfPerformance::OnEnable802dot1qTagInit(args)
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
proc ospfPerformance::OnEnable802dot1qTagInit {args} {
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
# ospfPerformance::OnTrafficMapSet(protocol)
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
proc ospfPerformance::OnTrafficMapSet {map} {
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
# ospfPerformance::OnEnable802dot1qTagChange(args)
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
proc ospfPerformance::OnEnable802dot1qTagChange {args} {
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
# ospfPerformance::tagCmd(args)
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
proc ospfPerformance::tagCmd {args} {
    set state disabled;

    if {[advancedTestParameter cget -useServerConfig] == "no"} {
	    set state enabled;
    }

    set attributeList {
	txTag 
    rxTag
    };
    
    renderEngine::WidgetListStateSet $attributeList $state;
}

######################################################################
# ospfPerformance::makeTempFileName 
#
# Description: creates the temporary file where the original tx ports   
#              configuration will be saved 
#                
#
# Argument(s):  
#     	 fname   - the name of temporary file
#
# Return Values:
#        tmpPath - the entire path of the temporary file
#            
#
#########################################################################
proc ospfPerformance::makeTempFileName {fname} {
   global env

   if {[isUNIX]} {
      set tmpDir /tmp
   } else {
      if {[info exists env(tmp)]} {
         set tmpDir $env(tmp)
      } elseif {[info exists env(temp)]} {
         set tmpDir $env(temp)
      } else {
         set tmpDir [file dirname [info script]]
      }
      regsub -all {\\} $tmpDir / tmpDir
   }
   set tmpPath "$tmpDir/$fname"
   return $tmpPath
}

########################################################################################
# Procedure:    ospfPerformance::OnInterfaceNetworkInit
#
# Description:  Initialize the value for Interface Network (values: Broadcast/Point To Point)
#
# Argument(s):  #
# Returns:      None
########################################################################################
proc ospfPerformance::OnInterfaceNetworkInit {args} {
        global interfaceType
        global incrByRouters 
        global numPeers
        global invisibleOspfParamsFrameName

        switch [ospfSuite cget -interfaceNetworkType] {
             "ospfBroadcast" {
                 set interfaceType "Broadcast";
                 ospfSuite config -interfaceType "Broadcast"
                 $invisibleOspfParamsFrameName.numPeers config -max 1500
             }
             "ospfPointToPoint" {                 
                 set interfaceType "Point To Point"
                 ospfSuite config -interfaceType "Point To Point"
                 $invisibleOspfParamsFrameName.numPeers config -value 1
                 $invisibleOspfParamsFrameName.numPeers config -max 1
             }
             default {
                 set interfaceType "Broadcast"
                 ospfSuite config -interfaceType "Broadcast"
             }
        }
     }

########################################################################################
# Procedure:    ospfPerformance::OnInterfaceNetworkChange
#
# Description:  Called when the value for Interface Network changes.
#
# Argument(s):  ##
#
# Returns:      None
########################################################################################
 proc ospfPerformance::OnInterfaceNetworkChange {args} {
    global interfaceType
    global interfaceNetworkType
    global incrByRouters      
    global numPeers
    global invisibleOspfParamsFrameName

    switch $interfaceType {
         "Broadcast" {             
             ospfSuite config -interfaceType "Broadcast"
             ospfSuite config -interfaceNetworkType "ospfBroadcast"
             set interfaceNetworkType "ospfBroadcast"
             $invisibleOspfParamsFrameName.numPeers config -max 1500
         }
         "Point To Point" {                      
             ospfSuite config -interfaceType "Point To Point"
             ospfSuite config -interfaceNetworkType "ospfPointToPoint"
             set interfaceNetworkType "ospfPointToPoint"
             $invisibleOspfParamsFrameName.numPeers config -value 1
             $invisibleOspfParamsFrameName.numPeers config -max 1
         }

         default {             
             ospfSuite config -interfaceType "Broadcast"
             ospfSuite config -interfaceNetworkType "ospfBroadcast"
             set interfaceNetworkType "ospfBroadcast"
         }
    }
 }

########################################################################################
# Procedure:    ospfPerformance::OnRouteOriginInit
#
# Description:  Initialize the value for Route Origin (values: Another Area/External 1/External 2)
#
# Argument(s):  #
#
# Returns:      None
########################################################################################
proc ospfPerformance::OnRouteOriginInit {args} {
        global routeOrigin

        switch [ospfSuite cget -routeNetworkOrigin] {
             "ospfRouteOriginArea" -
             "ospfV3RouteOriginArea" {
                 set routeOrigin "Another Area";
                 ospfSuite config -routeOrigin "Another Area"
             }
             "ospfRouteOriginExternal" -
             "ospfV3RouteOriginExternalType1" {
                 set routeOrigin "External 1"
                 ospfSuite config -routeOrigin "External 1"
             }
             "ospfRouteOriginExternalType2" -
             "ospfV3RouteOriginExternalType2" {
                 set routeOrigin "External 2"
                 ospfSuite config -routeOrigin "External 2"
             }
             default {
                 set routeOrigin "Another Area"
                 ospfSuite config -routeOrigin "Another Area"
             }
        }
     }

########################################################################################
# Procedure:    ospfPerformance::OnRouteOriginChange
#
# Description:  Called when the value for Route Origin changes.
#
# Argument(s):  #
#
# Returns:      None
########################################################################################
 proc ospfPerformance::OnRouteOriginChange {args} {
    global routeOrigin
    global routeNetworkOrigin    
    switch $routeOrigin {
         "Another Area" {
             ospfSuite config -routeOrigin "Another Area"
             if {[string tolower [testConfig::getTestConfItem protocolName]] == "ip"} {
                 ospfSuite config -routeNetworkOrigin "ospfRouteOriginArea"
                 set routeNetworkOrigin "ospfRouteOriginArea"
             } else {
                 ospfSuite config -routeNetworkOrigin "ospfV3RouteOriginArea"
                 set routeNetworkOrigin "ospfV3RouteOriginArea"
             }             
         }
         "External 1" {
             ospfSuite config -routeOrigin "External 1"
             if {[string tolower [testConfig::getTestConfItem protocolName]] == "ip"} {
                 ospfSuite config -routeNetworkOrigin "ospfRouteOriginExternal"
                 set routeNetworkOrigin "ospfRouteOriginExternal"
             } else {
                 ospfSuite config -routeNetworkOrigin "ospfV3RouteOriginExternalType1"
                 set routeNetworkOrigin "ospfV3RouteOriginExternalType1"
             }             
         }
         "External 2" {
             ospfSuite config -routeOrigin "External 2"
             if {[string tolower [testConfig::getTestConfItem protocolName]] == "ip"} {
                 ospfSuite config -routeNetworkOrigin "ospfRouteOriginExternalType2"
                 set routeNetworkOrigin "ospfRouteOriginExternalType2"
             } else {
                 ospfSuite config -routeNetworkOrigin "ospfV3RouteOriginExternalType2"
                 set routeNetworkOrigin "ospfV3RouteOriginExternalType2"
             }             
         }
         default {
             ospfSuite config -routeOrigin "Another Area"
             if {[string tolower [testConfig::getTestConfItem protocolName]] == "ip"} {
                 ospfSuite config -routeNetworkOrigin "ospfRouteOriginArea"
                 set routeNetworkOrigin "ospfRouteOriginArea"
             } else {
                 ospfSuite config -routeNetworkOrigin "ospfV3RouteOriginArea"
                 set routeNetworkOrigin "ospfV3RouteOriginArea"
             }            
         }
    }
 }

 ################################################################################
# ospfPerformance::OnIncrSameRouterInit(parent propName args)
#
# DESCRIPTION:
# This ON_INIT procedure makes sure a valid IP multicast address
# is diplayed for IPV4 or IPV6
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
proc ospfPerformance::OnIncrSameRouterInit {parent propName args} {

    if {[string tolower [testConfig::getTestConfItem protocolName]] == "ipv6"} {
        $parent.$propName config -max 128 
        if {[$parent.incrSameRouter cget -value] > 128} {
           $parent.incrSameRouter config -value 64
        }        

    } else {
        $parent.$propName config -max 32
        if {[$parent.incrSameRouter cget -value] > 32} {
           $parent.incrSameRouter config -value 24
        }
    }
}

################################################################################
# ospfPerformance::IPValidAddressChange(parent propName args)
#
# DESCRIPTION:
# This ON_CHANGE procedure makes sure a valid IP multicast address
# is diplayed for IPV4 or IPV6
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
proc ospfPerformance::IPValidAddressChange {parent propName args} {

    set entryBox [$parent.$propName subwidget entry];

    if {[string tolower [testConfig::getTestConfItem protocolName]] == "ipv6"} {
	    #set width 30;
	    bind $entryBox <FocusOut>   { checkIpAddress %W 0 ipV6};
	    bind $entryBox <KeyRelease> { checkIpAddress %W 0 ipV6};
    } else {
	    #set width 14;
	    bind $entryBox <FocusOut>   { checkIpAddress %W 0 ipV4};
	    bind $entryBox <KeyRelease> { checkIpAddress %W 0 ipV4};
    }

    #$entryBox config -width $width;
}

 ################################################################################
# ospfPerformance::IPValidAddressInit(parent propName args)
#
# DESCRIPTION:
# This ON_INIT procedure makes sure a valid IP multicast address
# is diplayed for IPV4 or IPV6
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
proc ospfPerformance::IPValidAddressInit {parent propName args} {

    set entryBox [$parent.$propName subwidget entry];

    if {[string tolower [testConfig::getTestConfItem protocolName]] == "ipv6"} {          
        if {[ipv6::isValidAddress [$entryBox get]] == 0} {
            switch $propName {
                "firstRoute" {
                    set validAddress "2000:0:0:1::0"
                }
                "incrByRouters" {
                    set validAddress "0:0:1:0:0:0:0:0"
                }
                "incrSameRouter" {
                    set validAddress "0:0:0:1:0:0:0:0"
                }
               "ipSrcIncrm" {
                 set validAddress "0:0:0:0:0:0:0:1"
                }
            }			
        } else {
            set validAddress [$entryBox get]
        }
    } else {        
        if {[dataValidation::isValidUnicastIp [$entryBox get]] == 0 && $propName =="firstRoute"} {
                    set validAddress "194.20.0.1" 
        } else {
                set validAddress [$entryBox get]
        }
        if {$propName != "firstRoute" && [isIpAddressValid [$entryBox get]] == 0} {
            switch $propName {
                "incrByRouters" {
                    set validAddress "0.1.0.0" 
                }
                "incrSameRouter" {
                    set validAddress "0.0.1.0"    
                }
                "ipSrcIncrm" {
                 set validAddress "0.0.0.1"
                }
            }			
        } else {
                set validAddress [$entryBox get]
        }

    }

    $entryBox delete 0 end
    $entryBox insert 0 $validAddress

    if {[string tolower [testConfig::getTestConfItem protocolName]] == "ipv6"} {
       if { $propName == "ipSrcIncrm" } {
	    bind $entryBox <FocusOut>   {
                 checkIpAddress %W 0 ipV6 unicast
                 ospfPerformance::OnIncrmChange %W "ipV6"
                 } 
	    bind $entryBox <KeyRelease> {
                 checkIpAddress %W 0 ipV6 unicast
                 ospfPerformance::OnIncrmChange %W "ipV6"
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
                 ospfPerformance::OnIncrmChange %W "ipV4"
            }
            bind $entryBox <KeyRelease> {
                 checkIpAddress %W 0 ipV4 unicast
                 ospfPerformance::OnIncrmChange %W "ipV4"
            } 
        } else {
                 bind $entryBox <FocusOut>   {
                     checkIpAddress %W 0 ipV4 unicast
                 }
                 bind $entryBox <KeyRelease> { checkIpAddress %W 0 ipV4 unicast} 
        }
    }

    #$entryBox config -width $width;
}

#################################################################################
# Procedure: ospfPerformance::estimateAdvertiseDelay
#
# Description: This command estimate AdvertiseDelay base on number of routes.
# Arguments :
# numRoutes : Number of routes to be advertised. 
#         
# Returned Value :   advertisDelay
#
#################################################################################
proc ospfPerformance::estimateAdvertiseDelay {numRoutes} {   
    set map [map cget -type]

    global ${map}Array

    #The numbers come from "Max update size" and this fact that each update message is 3 packets.
    #It also included number of ACKs.
    set rate    20
    set numPrefixeInPacket 675
    set numPackets 3

    #set numRxPorts [llength  [getRxPorts ${map}Array]]
    set numRxPorts [llength  [getAllPorts ${map}Array]]
    set numRouters [ospfSuite cget -numPeers]
    
    #set estimatedAdvertiseDelay [expr double ( (($numRoutes*$numRxPorts*$numRouters*100/$numPrefixeInPacket)*$numPackets * 2)/$rate ) ]
    set estimatedAdvertiseDelay [expr double ( $numRoutes*$numRxPorts*$numRouters*[ospfSuite cget -routeDelay] ) ]
    #Add a fudge factor to estimated delay. (%20 of it)  
    set estimatedAdvertiseDelay [expr $estimatedAdvertiseDelay + ceil (0.2 * $estimatedAdvertiseDelay)]
    
    return [expr ($estimatedAdvertiseDelay<35) ? 35 : round($estimatedAdvertiseDelay)]
    #return [expr round( $estimatedAdvertiseDelay )]

}

###############################################################################
#
# ospfPerformance::OnProtocolSet(protocol)
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
proc ospfPerformance::OnProtocolSet {protocol} {

    global firstRoute
    global incrByRouters
    global incrSameRouter
    global numPeers
    global invisibleOspfParamsFrameName
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
        ospfSuite config -$propName [set $propName]

        set entryBox [$invisibleOspfParamsFrameName.$propName subwidget entry] 

                 if {[string tolower [testConfig::getTestConfItem protocolName]] == "ipv6"} {
                    set width 20
                    if { $propName == "ipSrcIncrm" } {
                         bind $entryBox <FocusOut>   {
                              checkIpAddress %W 0 ipV6 unicast
                              ospfPerformance::OnIncrmChange %W "ipV6"
                              } 
                         bind $entryBox <KeyRelease> {
                              checkIpAddress %W 0 ipV6 unicast
                              ospfPerformance::OnIncrmChange %W "ipV6"
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
                              ospfPerformance::OnIncrmChange %W "ipV4"
                         }
                         bind $entryBox <KeyRelease> {
                              checkIpAddress %W 0 ipV4 unicast
                              ospfPerformance::OnIncrmChange %W "ipV4"
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
        $invisibleOspfParamsFrameName.incrSameRouter config -max 128
        $invisibleOspfParamsFrameName.incrSameRouter config -value 64
    } else {
        $invisibleOspfParamsFrameName.incrSameRouter config -max 32
        if {[$invisibleOspfParamsFrameName.incrSameRouter cget -value] > 32} {
           $invisibleOspfParamsFrameName.incrSameRouter config -value 24
        }
    }
    
    if {[ospfSuite cget -interfaceNetworkType]=="ospfPointToPoint"} {
        puts "proc OnProtocolSet PPP"
        $invisibleOspfParamsFrameName.numPeers config -value 1
        $invisibleOspfParamsFrameName.numPeers config -max 1
    }
    
}

###############################################################################
# ospfPerformance::OnNumPeersUpdate(parent propName args)
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
proc ospfPerformance::OnNumPeersUpdate {parent propName args} {
    global numPeers
    testConfig::setTestConfItem vlansPerPort $numPeers
}

##############################################################################
# ospfPerformance::OnNumPeersChange(parent propName args)
#
# DESCRIPTION:
# This ON_CHANGE procedure sets the number of routers depending on the
# selected value for Interface Network Type (if Point-To-Point, set to 1)
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
proc ospfPerformance::OnNumPeersChange {parent propName args} {
    if {[ospfSuite cget -interfaceNetworkType]=="ospfPointToPoint"} {            
            $parent.$propName config -max 1                
    } else {
            $parent.$propName config -max 1500            
    }
                     
}

################################################################################
# ospfPerformance::OnIncrmChange(val protocol args)
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
proc ospfPerformance::OnIncrmChange {val protocol args} {
    global testConf
    set x [$val get]

    if { [string tolower $protocol] == "ipv4" } {
       set testConf(ipSrcIncr) $x
    } else {
       set testConf(ipV6SrcIncr) $x
    }

}