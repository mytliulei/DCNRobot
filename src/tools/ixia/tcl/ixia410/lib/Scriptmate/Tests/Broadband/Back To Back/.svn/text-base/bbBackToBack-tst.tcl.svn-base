##################################################################################
# Copyright (c) Ixia 2004-2005
# All rights reserved
#
# DESCRIPTION:
# The test measures the maximum back to back frames without packet loss. 
# A binary search with maximum offered load will be applied.
#
##################################################################################

namespace eval bbBackToBack {}

#####################################################################
# bbBackToBack::xmdDef
# 
# DESCRIPTION:
# This variable contains the XML content used by PDF Report generation.
#  
###
set bbBackToBack::xmdDef  {
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
         <Source scope="results.csv" entity_name="bbBackToBack" format_id=""/>
         <Source scope="info.csv" entity_name="bbBackToBack_Info" format_id=""/>
         <Source scope="AggregateResults.csv" entity_name="bbBackToBack_Aggregate" format_id=""/>
         <Source scope="Iteration.csv" entity_name="bbBackToBack_Iteration" format_id=""/>
       </Sources>
     </XMD>
}

#####################################################################
# bbBackToBack::statList
# 
# DESCRIPTION:
# This table contains a list of collected metrics to be displayed in
# the Real Time Graphs and written to RealTime.csv file.
#  
###
global one2oneArray
set bbBackToBack::statList \
    [list [list framesSent  [getTxPorts one2oneArray] "Tx Frames per second" "Tx Frames" 1e0]\
     [list framesReceived [getRxPorts one2oneArray] "Rx Frames per second" "Rx Frames" 1e0]\
     [list bitsSent       [getTxPorts one2oneArray] "Tx Kbps"              "Tx Kb"     1e3]\
     [list bitsReceived   [getRxPorts one2oneArray] "Rx Kbps"              "Rx Kb"     1e3]\
    ];    


#####################################################################
# bbBackToBack::iterationFileColumnHeader
# 
# DESCRIPTION:
# This table contains a list of column headers at the top of the
# iteration.csv file.
#  
###
set bbBackToBack::iterationFileColumnHeader { 
    "Trial"
    "Frame Size"
    "Iteration"
    "Tx Port"
    "Rx Port"   
    "Tx Count"
    "Rx Count"
    "Frame Loss"
    "Frame Loss %"
    "Back To Back Frames"
}


#####################################################################
# bbBackToBack::attributes
# 
# DESCRIPTION:
# This attributes table contains a list of attributes used by the
# test algorithm or other backend test engine functions.  This
# table is used to initialize these attributes for later use.
#  
###
set bbBackToBack::attributes {
    {
    { NAME              testName }
    { BACKEND_TYPE      string }
    { DEFAULT_VALUE     "Broadband Back To Back" }
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
    { DESCRIPTION {
        "One frame size test is called a trial. The user may choose to run one or more"
        "trials; the average result of each trial will be presented in the result file."
        "total number of trials per frame size"
    } }
    }          

    {
    { NAME              dhcpDone }
    { BACKEND_TYPE      boolean }
    { DEFAULT_VALUE     no }
    { VALID_VALUES      {yes no} }
    { VARIABLE_CLASS    testCmd }    
    }

    {
    { NAME              enableServerDHCP }
    { BACKEND_TYPE      boolean }
    { DEFAULT_VALUE     false }
    { VALID_VALUES      {true false} }
    { VARIABLE_CLASS    testCmd }    
    }

    {
    { NAME              enableClientDHCP }
    { BACKEND_TYPE      boolean }
    { DEFAULT_VALUE     false }
    { VALID_VALUES      {true false} }
    { VARIABLE_CLASS    testCmd }    
    }

    {
    { NAME              enableServerVLAN }
    { BACKEND_TYPE      boolean }
    { DEFAULT_VALUE     false }
    { VALID_VALUES      {true false} }
    { VARIABLE_CLASS    testCmd }       
    }

    {
    { NAME              enableClientVLAN }
    { BACKEND_TYPE      boolean }
    { DEFAULT_VALUE     false }
    { VALID_VALUES      {true false} }
    { VARIABLE_CLASS    testCmd }        
    }

    {
    { NAME              staggeredStart }
    { BACKEND_TYPE      boolean }
    { DEFAULT_VALUE     false }
    { VALID_VALUES      {staggeredStart notStaggeredStart true false} }
    { LABEL             "Staggered Transmit" }
    { VARIABLE          staggeredStart }
    { VARIABLE_CLASS    testCmd }
    { DESCRIPTION {
        "Staggered start; if set to true, transmit start will be staggered; if"
        "set to false, transmit will start on all ports at the same time." 
    } }
    }

    {
    { NAME              framesizeList }
    { BACKEND_TYPE      integerList }
    { DEFAULT_VALUE     {64 128 256 512 1024 1280 1518} }               
    { VARIABLE_CLASS    testCmd }
    }

    {
    { NAME              framesizeWanList }
    { BACKEND_TYPE      integerList }
    { DEFAULT_VALUE     {64 128 256 512 1024 1280 1518} }               
    { VARIABLE_CLASS    testCmd }
    }

    {
    { NAME              framesizeBroadBandList }
    { BACKEND_TYPE      integerList }
    { DEFAULT_VALUE     {64 128 256 512 1024 1280 1518} }               
    { VARIABLE_CLASS    testCmd }
    }

  
    {
    { NAME              minimumFPS }
    { BACKEND_TYPE      integer }
    { DEFAULT_VALUE     10 }
    { MIN               1 }
    { MAX               2000000000 }
    { VARIABLE_CLASS    testCmd }
    }             
    
    {
    { NAME              tolerance }
    { BACKEND_TYPE      double }
    { DEFAULT_VALUE     0 }
    { MIN               0 } 
    { MAX               100 }
    { LABEL             "  Loss Tolerance (%):" }
    { VARIABLE_CLASS    testCmd }
    }    

    {
    { NAME              loadRateBroadBandWidget }        
    { BACKEND_TYPE      null }
    { VARIABLE_CLASS    null }
    }

    {
    { NAME              percentMaxRate }
    { BACKEND_TYPE      double }
    { DEFAULT_VALUE     100 }
    { MIN               0.001 }
    { MAX               100 }
    { VARIABLE_CLASS    testCmd }
    { DESCRIPTION {
        "Enter the percentage of Maximum Frame rate to use for running the test."
    } }
    }

    {
    { NAME              percentMaxWanRate }
    { BACKEND_TYPE      double }
    { DEFAULT_VALUE     100 }
    { MIN               0.001 }
    { MAX               100 }    
    { VARIABLE_CLASS    testCmd }
    { DESCRIPTION {
        "Enter the percentage of Maximum Frame rate to use for running the test."
    } }
    }

    {
    { NAME              percentMaxBroadBandRate }
    { BACKEND_TYPE      double }
    { DEFAULT_VALUE     100 }
    { MIN               0.001 }
    { MAX               100 }    
    { VARIABLE_CLASS    testCmd }
    { DESCRIPTION {
        "Enter the percentage of Maximum Frame rate to use for running the test."
    } }
    }

    {
    { NAME              kbpsRate }
    { BACKEND_TYPE      double }
    { DEFAULT_VALUE     64 }
    { MIN               1 }    
    { LABEL             "" }
    { VARIABLE_CLASS    testCmd }
    }

    {
    { NAME              kbpsWanRate }
    { BACKEND_TYPE      double }
    { DEFAULT_VALUE     64 }
    { MIN               1 }    
    { LABEL             "" }
    { VARIABLE_CLASS    testCmd }
    }

        
    {
    { NAME              kbpsBroadBandRate }
    { BACKEND_TYPE      double }
    { DEFAULT_VALUE     64 }
    { MIN               1 }    
    { LABEL             "" }
    { VARIABLE_CLASS    testCmd }
    }

    {
    { NAME              fpsBroadBandRate }
    { BACKEND_TYPE      double }
    { DEFAULT_VALUE     1000 }
    { MIN               11 }     
    { LABEL             "" }
    { VARIABLE_CLASS    testCmd }
    }          

    {
    { NAME              fpsWanRate }
    { BACKEND_TYPE      double }
    { DEFAULT_VALUE     100 }
    { MIN               0 } 
    { MAX               100 }
    { LABEL             "" }
    { VARIABLE_CLASS    testCmd }
    }

    {
    { NAME              fpsRate }
    { BACKEND_TYPE      double }
    { DEFAULT_VALUE     100 }
    { MIN               0 } 
    { LABEL             "" }
    { VARIABLE_CLASS    testCmd }
    }

    {
    { NAME              binarySearchDirection }
    { BACKEND_TYPE      boolean }
    { DEFAULT_VALUE     false }
    { VALID_VALUES      {true false} }
    { VALUE_LABELS      {Upstream Downstream} }
    { VARIABLE_CLASS    testCmd }
    { DESCRIPTION {
        "Select binary search direction."
        "false = do downstream search"
        "true = do upstream search"
    } }
    }

   
   {
   { NAME              selectRateType }
   { BACKEND_TYPE      string }
   { DEFAULT_VALUE     maxrate }
   { VALID_VALUES      {payload maxrate frames} }
   { VALUE_LABELS      {"Payload Kbps:    " "Max Rate (%):    " "Frames/Second:" } }
   { VARIABLE_CLASS    testCmd }
   { DESCRIPTION {
       "Select binary search type."
       "false = do per port binary search"
       "true = do linear binary search"
   } }
   }

    { 
    { NAME              duration }
    { BACKEND_TYPE      integer }
    { DEFAULT_VALUE     20 }
    { MIN               1 }
    { MAX               NULL }
    { LABEL             Duration }
    { VARIABLE_CLASS    testCmd }
    { DESCRIPTION {
        "The approximate length of time frames are transmitted for each trial is set"
        "as a 'duration. The duration is in seconds; for example, if the duration is"
        "set to one second on a 100mbs switch, ~148810 frames will be transmitted."
        "This number must be an integer; minimum value is 1 second."
        "duration of transmit during test, in seconds"
    } }
    }

    { 
    { NAME              numAddressesPerPort }
    { BACKEND_TYPE      integer }
    { DEFAULT_VALUE     1 }
    { MIN               1 }
    { MAX               NULL }
    { LABEL             "Addresses per WAN Port:" }
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
    { ON_CHANGE         bbBackToBack::PassFailEnable }   \
    }

    {
    { NAME              thresholdMode }
    { BACKEND_TYPE      string }
    { DEFAULT_VALUE     line }
    { VALID_VALUES      {duration backToBackFrames} }
    { VALUE_LABELS      {"Minimum Duration >=" "Min BackToBack Frames >="} }
    { VARIABLE          passFailMode }
    { VARIABLE_CLASS    testConf }
    { ON_CHANGE         bbBackToBack::ThroughputThresholdToggle }
    }

    { 
    { NAME              passFailMinDuration }
    { BACKEND_TYPE      integer }
    { DEFAULT_VALUE     10 }
    { MIN               0.0001 }
    { MAX               NULL }    
    { VARIABLE_CLASS    testConf }
    }
    
    {
    { NAME              dataThresholdScale }
    { BACKEND_TYPE      string }
    { DEFAULT_VALUE     sec }
    { VALID_VALUES      {sec ms us} }
    { VARIABLE          passFailDataUnit }
    { VARIABLE_CLASS    testConf }
    }

    { 
    { NAME              passFailBackToBackFrames }
    { BACKEND_TYPE      integer }
    { DEFAULT_VALUE     10 }
    { MIN               1 }
    { MAX               NULL }    
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
    { NAME              learnFramesWidget }     
    { BACKEND_TYPE      null }
    { VARIABLE_CLASS    null }
    }

    {
    { NAME              trafficMapWidget }      
    { BACKEND_TYPE      null }
    { VARIABLE_CLASS    null }
    }

    {
    { NAME              enable }
    { BACKEND_TYPE      boolean }
    { DEFAULT_VALUE     false }
    { VALID_VALUES      {true false} }
    { VARIABLE_CLASS    fastpath }
    { DESCRIPTION {
        "If you need the fastpath set up, set this to 'true'"
    } }
    }

    {
    { NAME              map }
    { BACKEND_TYPE      string }
    { DEFAULT_VALUE     one2many }
    { VALID_VALUES      {one2many} }
    { VARIABLE_CLASS    map }
    { DESCRIPTION {
        "Set up the map manually. Used only if autoMapGeneration set to \"no\"."
        "Note that if running IP or IPX test, the IP addresses or IPX sockets MUST"
        "also be set up manually."
        "get rid of any existing map"
    } }
    }

    {
    { NAME              resultFile }
    { BACKEND_TYPE      string }
    { DEFAULT_VALUE     bbBackToBack.results }
    { VARIABLE_CLASS    results }
    { DESCRIPTION {
        "The results will be printed in this file in the \"Results\" directory"
        "of the parent directory"
    } }
    }

    {
    { NAME              generateCSVFile }
    { BACKEND_TYPE      boolean }
    { DEFAULT_VALUE     false }
    { VALID_VALUES      {true false} }
    { VARIABLE_CLASS    results }
    { DESCRIPTION {
        "If set to true, the .csv file which has the same name with the results file"
        "will be generated in the \"Results\" directory of the parent directory"
    } }
    }

    { 
    { NAME              when }
    { BACKEND_TYPE      string }
    { DEFAULT_VALUE     oncePerTest }
    { VALID_VALUES      {oncePerTest oncePerFramesize onTrial never} }
    { VARIABLE_CLASS    learn }
    { DESCRIPTION {
        "configure how many and WHEN to send learn frames"
        "oncePerTest        = Send only once at the beginning of the test"
        "oncePerFramesize   = Send only in the beginning of a framesize"
        "onTrial            = Send at beginning of each trial of a framesize"
        "never              = Never send learn frames"
    } }
    }
    
    { 
    { NAME              numframes }
    { BACKEND_TYPE      integer }
    { DEFAULT_VALUE     10 }
    { VARIABLE_CLASS    learn }
    { DESCRIPTION {
        "number of learning frames to send"
    } }
    } 

    {
    { NAME              rate }
    { BACKEND_TYPE      integer }
    { DEFAULT_VALUE     100 }
    { VARIABLE_CLASS    learn }
    { DESCRIPTION {
        "rate of learn frames Tx in fps"
    } }
    }

    {
    { NAME              waitTime }
    { BACKEND_TYPE      integer }
    { DEFAULT_VALUE     1000 }
    { VARIABLE_CLASS    learn }
    { DESCRIPTION {
        "time to wait between ports after sending learn frames, in milliseconds"
    } }
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
    { NAME             comments }
    { BACKEND_TYPE     string }
    { DEFAULT_VALUE    "" }
    { VARIABLE_CLASS   user }
    }

    {
    { NAME              autoMapGeneration }
    { BACKEND_TYPE      boolean }
    { DEFAULT_VALUE     yes }
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
    { NAME              mapDirection }
    { BACKEND_TYPE      string }
    { DEFAULT_VALUE     bidirectional }
    { VALID_VALUES      {unidirectional bidirectional} }
    { VARIABLE_CLASS    testConf }
    { DESCRIPTION {
        "unidirectional or bidirectional"
    } }
    }

    {
    { NAME              extendedDirections }
    { BACKEND_TYPE      integer }
    { DEFAULT_VALUE     1 }    
    { VARIABLE_CLASS    testConf }
    { DESCRIPTION {
        "Used for enable upstream/downstream" 
    } }
    }

    {
    { NAME              protocolName }
    { BACKEND_TYPE      string }
    { DEFAULT_VALUE     mac }
    { VALID_VALUES      {mac ip} }
    { VARIABLE_CLASS    testConf }
    { DESCRIPTION {
        "Select the protocol to be used to run this test."
        "Supported protocols are MAC, IP and IPX."
        "NOTE: MAC layer not valid for OC-n interfaces"
        "mac = layer 2 MAC"
        "ip  = layer 3 IP"        
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
    { NAME              firstSrcIpAddress }
    { BACKEND_TYPE      string }
    { DEFAULT_VALUE     198.18.1.100 } 
    { VARIABLE_CLASS    testConf }
    { DESCRIPTION {
        "--> IP port configuration"
        "NOTE:  if protocol is set to \"mac\" or \"ipx\", these params are ignored"
        "IP addresses can be generated automatically with the any one byte of the"
        "IP addressess incrementing for every port. This will be done only if the"
        "map has been generated automatically."
    } }
    }

    {
    { NAME              firstDestDUTIpAddress }
    { BACKEND_TYPE      string }
    { DEFAULT_VALUE     198.18.1.1 }
    { VARIABLE_CLASS    testConf }
    }

    {
    { NAME              incrIpAddrByteNum }
    { BACKEND_TYPE      integer }
    { DEFAULT_VALUE     3 }
    { VARIABLE_CLASS    testConf }
    }
    
    {
    { NAME              firstSrcIpxSocket }
    { BACKEND_TYPE      string }
    { DEFAULT_VALUE     0x4011 }
    { VARIABLE_CLASS    testConf }
    { DESCRIPTION {
        "--> IPX port configuration"
        "NOTE:  if protocol is set to \"mac\" or \"ip\", these params are ignored"
        "The IPX source socket cen be generated automatically."
    } }
    }

    {
    { NAME              automap }
    { BACKEND_TYPE      string }
    { DEFAULT_VALUE     {Automatic Manual} }
    { VARIABLE_CLASS    automap }
    }
    
    {
    { NAME              directions }
    { BACKEND_TYPE      string }
    { DEFAULT_VALUE     {downstream bidirectional upstream} }
    { VARIABLE_CLASS    directions }
    }

    {
    { NAME              gTestCommand }
    { BACKEND_TYPE      string }
    { DEFAULT_VALUE     bbBackToBack }
    { VARIABLE_CLASS    gTestCommand }
    }

    {
    { NAME              protocolsSupportedByTest }
    { BACKEND_TYPE      string }
    { DEFAULT_VALUE     {mac ip} }
    { VARIABLE_CLASS    protocolsSupportedByTest }
    }

    {
    { NAME              logFileName }
    { BACKEND_TYPE      string }
    { DEFAULT_VALUE     bbBackToBack.log }
    { VARIABLE_CLASS    logger }
    }

    {
    { NAME               supportVlan }
    { BACKEND_TYPE       integer }
    { DEFAULT_VALUE      1 }
    { VARIABLE_CLASS     supportVlan }
    }

    {
    { NAME               supportVlanTag }
    { BACKEND_TYPE       integer }
    { DEFAULT_VALUE      1 }
    { VARIABLE_CLASS     supportVlanTag}
    }

    {
    { NAME               supportMultipleVlan }
    { BACKEND_TYPE       integer }
    { DEFAULT_VALUE      1 }
    { VARIABLE_CLASS     supportMultipleVlan }
    }        


    {
    { NAME              calculateLatency }      
    { BACKEND_TYPE      boolean }
    { DEFAULT_VALUE     no }
    { VALID_VALUES      {yes no} }
    { LABEL             "Calculate Latency" }
    { VARIABLE          calcLatency }
    { VARIABLE_LABEL    calculateLatency }
    { VARIABLE_CLASS    testCmd }
    { ON_CHANGE         bbThroughput::LatencyCheckBoxSelected }
    { DESCRIPTION {
        "Set calculateLatency to \"yes\" if latency is to be calculated along with"
        "throughput"
    } }
    }


    {
    { NAME              calculateJitter }      
    { BACKEND_TYPE      boolean }
    { DEFAULT_VALUE     no }
    { VALID_VALUES      {yes no} }
    { LABEL             "Calculate Inter-Arrival" }
    { VARIABLE          calcJitter }
    { VARIABLE_LABEL    calculateJitter }
    { VARIABLE_CLASS    testCmd }
    { ON_CHANGE         bbThroughput::JitterCheckBoxSelected }
    { DESCRIPTION {
        "Set calculateLatency to \"yes\" if latency is to be calculated along with"
        "throughput"
    } }
    }

    {
    { NAME              calculateDataIntegrity }      
    { BACKEND_TYPE      boolean }
    { DEFAULT_VALUE     yes }
    { VALID_VALUES      {yes no} }
    { LABEL             "Measure Sequence Error &\n Data Integrity" }
    { VARIABLE          calcDataIntegrity }
    { VARIABLE_LABEL    calculateDataIntegrity }
    { VARIABLE_CLASS    testCmd }
    { ON_CHANGE         bbThroughput::DataIntegrityCheckBoxSelected }
    { DESCRIPTION {
        "Set Data Integrity to \"yes\" if Data Integrity is to be calculated along with"
        "throughput"
    } }
    }

    {
    { NAME              latencyTypes }
    { BACKEND_TYPE      string }
    { DEFAULT_VALUE     cutThrough }
    { VALID_VALUES      {cutThrough storeAndForward} }
    { LABEL             "Latency Types: " }
    { VARIABLE          latencyTypes }        
    { VARIABLE_CLASS    testCmd }
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
# bbBackToBack::registerResultVars()
#
# DESCRIPTION: 
# This procedure registers all the local variables that are used in the
# display of the results with the Results Options Database.  
# This procedure must exist for each test.
#
###
proc bbBackToBack::registerResultVars {} \
{
    # configuration information stored for results
    if [ results registerTestVars numTrials            numTrials      [bbBackToBack cget -numtrials]      test ] { return 1 }

    # results obtained after each iteration
    if [ results registerTestVars throughput           thruputRate         0                                port TX ] { return 1 }
    if [ results registerTestVars percentTput          percentTput         0                                port TX ] { return 1 }    

    return 0
}



proc bbBackToBack::start {} {
    debugPuts "Start BroadBand Throughput Test"
    variable trial;
    variable numTrials;
    variable testName;
    variable framesizeWan
    variable framesizeBroadBand 
    variable frameSizeList;
    variable status
    variable trialsPassed
    variable directions

    set status $::TCL_OK;

    set testCmd [namespace current]

   # $testCmd config -duration 4
    $testCmd config -calculateDataIntegrity yes

    set testName [[namespace current] cget -testName];
    set numTrials [[namespace current] cget -numtrials];

    
    $testCmd config -testName "Broadband Back To Back - Linear Binary Search"
    
#    if {[[namespace current]::ConfigValidate]} {
#        logMsg "***** ERROR:  Config Validation failed.  Test aborted."
#        return $::TCL_ERROR
#    }


    set colHeads { "Trial"
        "Frame Size"
        "Iteration"
        "Tx Port"
        "Rx Port"
        "Tx Tput (fps)"
        "Rate (%)"
        "Tx Count"
        "Rx Count"
        "Frame Loss"
        "Frame Loss (%)"
    }


    [namespace current]::ResultsDirectoryCreate;
    #  [namespace current]::CreateIterationFile;

    if {[csvUtils::createIterationCSVFile $testCmd $colHeads]} {
       return $::TCL_ERROR                
    }

    realTimeGraphs::InitRealTimeStat \
    [list [list framesSent     [getTxPorts one2manyArray] "Tx Frames per second" "Tx Frames" 1e0]\
         [list framesReceived [getRxPorts one2manyArray] "Rx Frames per second" "Rx Frames" 1e0]\
         [list bitsSent       [getTxPorts one2manyArray] "Tx Kbps"              "Tx Kb"     1e3]\
         [list bitsReceived   [getRxPorts one2manyArray] "Rx Kbps"              "Rx Kb"     1e3]\
        ];


    fconfigure [logger cget -ioHandle] -buffering line

    if {[dutConfig::DutConfigure]} {
        logMsg "***** ERROR:  DUT Configuration failed.  Test aborted."
        return $::TCL_ERROR
    }

    if {[[namespace current]::TestSetup]} {
        logMsg "***** ERROR:  Test Setup failed.  Test aborted."
        return $::TCL_ERROR
    }

    #setting the framesize lists
    set frameSizeWanList [[namespace current] cget -framesizeWanList];
    set frameSizeBroadBandList [[namespace current] cget -framesizeBroadBandList];

    if {$directions=="downstream"} {
         set frameSizeBroadBandList 64
    }

    if {$directions=="upstream"} {
        set frameSizeWanList   64
    }

  #  [namespace current]::RealTimeStatsStart; 

    set oldFpsWanRate [$testCmd cget -fpsWanRate]
    set oldKbpsWanRate [$testCmd cget -kbpsWanRate]

    set oldFpsBroadBandRate  [$testCmd cget -fpsBroadBandRate]
    set oldKbpsBroadBandRate [$testCmd cget -kbpsBroadBandRate]

    realTimeGraphs::StartRealTimeStat;
    scriptMateGuiCommand openProgressMeter

    for {set trial 1} {$trial <= $numTrials} {incr trial} {

        if {[dutConfig::DutConfigure TrialSetup]} {
            logMsg "***** ERROR:  DUT Configuration failed.  Test aborted."
            return $::TCL_ERROR
        }


        if {[[namespace current]::TrialSetup]} {
                logMsg "***** ERROR:  Trial Setup failed.  Test aborted."
                return $::TCL_ERROR
        }

        foreach  framesizeWan $frameSizeWanList {
            foreach framesizeBroadBand $frameSizeBroadBandList {

                realTimeGraphs::SaveRealTimeMarker "-- Trial:$trial FS Downstream:$framesizeWan FS Upstream:$framesizeBroadBand--";

                $testCmd config -fpsRate $oldFpsWanRate
                $testCmd config -kbpsRate $oldKbpsWanRate
                $testCmd config -fpsRate $oldFpsBroadBandRate
                $testCmd config -kbpsRate $oldKbpsBroadBandRate

                $testCmd config -framesize $framesizeWan
               # [namespace current]::RealTimeMarkerSave

                set status [[namespace current]::Algorithm]

                if {$status} {
                    logMsg "***** ERROR:  Algorithm failed.  Test aborted."
                    return $::TCL_ERROR
                }                        
            }; # loop over frame size Wan
         } ;# loop over frame size BroadBand

        #  [namespace current]::TrialCleanUp;
        if {[dutConfig::DutConfigure TrialCleanup]} {
            logMsg "***** ERROR:  DUT Configuration failed.  Test aborted."
            return $::TCL_ERROR
        }

    } ;# loop over trial;



    if {[dutConfig::DutConfigure TestCleanup]} {
        logMsg "***** ERROR:  DUT Configuration failed.  Test aborted."
        return $::TCL_ERROR
    }

    #realTimeGraphs::StopRealTimeStat;
    #scriptMateGuiCommand closeProgressMeter

    
    [namespace current]::MetricsPostProcess
    [namespace current]::PassFailCriteriaEvaluate
    [namespace current]::WriteResultsCSV
    [namespace current]::WriteIterationCSV    
    [namespace current]::WriteAggregateResultsCSV
    [namespace current]::RealTimeStatsStop
    [namespace current]::WriteRealTimeCSV
    [namespace current]::WriteInfoCSV
    [namespace current]::GeneratePDFReportFromCLI
    [namespace current]::TestCleanUp;


    return $status

    debugPuts "Leave BroadBand Throughput Test"
    return 0
}


#############################################################################
# bbBackToBack::TestSetup()
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
proc bbBackToBack::TestSetup {} {  
debugPuts "Start TestSetup"

  global one2manyArray 
  global testConf

  variable s_many2oneArray
  variable wanPorts
  variable broadBandPorts
  variable groupIdArray
  variable groupWanIdArray
  variable groupBroadBandIdArray
  variable fullMapArray
  variable txPortList
  variable rxPortList 
  variable directions 
  variable portPgId

  set directions $testConf(mapDirection)                      
  set testCmd [namespace current]

  set ::currContext(testCat)    "broadband"

  $testCmd config -calculateLatency no
  $testCmd config -calculateJitter  no

  set wanVlan [expr {![string compare [$testCmd cget -enableServerVLAN] true]}]
  set broadbandVlan [expr {![string compare [$testCmd cget -enableClientVLAN] true]}]

  if {$wanVlan || $broadbandVlan} {
      set ::testConf(enable802dot1qTag) true
      protocol config -enable802dot1qTag 1
  } else {
      set ::testConf(enable802dot1qTag) false
      protocol config -enable802dot1qTag 0
  } 

  $testCmd config -dhcpDone no

  set status $::TCL_OK  

  # Move from generic values (set by GUI) to wan 
  [namespace current] config -fpsWanRate        [[namespace current] cget -fpsRate]
  [namespace current] config -kbpsWanRate       [[namespace current] cget -kbpsRate]
  [namespace current] config -percentMaxWanRate [[namespace current] cget -percentMaxRate]
  [namespace current] config -framesizeWanList  [[namespace current] cget -framesizeList] 
  
  swapPortList one2manyArray s_many2oneArray

  catch {unset fullMapArray}

  switch  $directions {
    bidirectional {
            array set fullMapArray  [array get one2manyArray]
            array set fullMapArray  [array get s_many2oneArray]
    }
    downstream {
            array set fullMapArray  [array get one2manyArray]
    }
    upstream {
            array set fullMapArray  [array get s_many2oneArray]
    }
  }
 
  set wanPorts       [getTxPorts one2manyArray]
  set broadBandPorts [getRxPorts one2manyArray]
    
  set txPortList [getTxPorts fullMapArray]
  set rxPortList [getRxPorts fullMapArray]  
  

  set ::tputMultipleVlans [expr $wanVlan | $broadbandVlan]

  emptyUntaggedPortList

  if {$wanVlan == 0} {
      setUntagged $wanPorts
  }

  if {$broadBandPorts == 0} {
      setUntagged $broadBandPorts
  }

  #SETTING THE RX PORTS TO WIDE PACKET GROUP
  set learnproc [switchLearn::getLearnProc]
  debugPuts "learnproc - $learnproc"

  if {[broadbandLearn "oncePerTest" bbBackToBack]} {            
          errorMsg "Error sending learn frames"
          set retCode $::TCL_ERROR
  }        
  
  set widePacketGroupPortList {}
       
  #creating rxPortList for ports supporting WidePacketGroup 
  foreach rxMap $rxPortList {
     scan $rxMap "%d %d %d" rx_c rx_l rx_p        
     if {[port isValidFeature $rx_c $rx_l $rx_p portFeatureRxWidePacketGroups]} {
        set widePacketGroupPortList [lappend packetGroupPortList [list $rx_c $rx_l $rx_p]]
     } else {
        logMsg "Error! Port $rx_c $rx_l $rx_p doesn't support WidePacketGroup"
        return $::TCL_ERROR
     }
  }

  # doesn't make any sense the next commnand
  if {[llength $widePacketGroupPortList] == 0} {
     errorMsg "Error: could not find ports which support Packet Groups"
     return $::TCL_ERROR 
  }
  if {[applyPacketGroupMode $widePacketGroupPortList bbBackToBack] == $::TCL_ERROR} {
        return $::TCL_ERROR 
  }
  #assign groupId per TX port
  assignTxPortPGID fullMapArray groupIdArray $txPortList portPgId

  set fileID [openResultFile]

  if {$fileID != "stdout"} {
        writeTextResultsFileHeader $fileID
        writeTextResultsFilePortConfig $fileID 
        closeMyFile $fileID       
  }

  debugPuts "Leave TestSetup"
  return $status;
}





#############################################################################
# bbBackToBack::TestCleanUp()
#
# DESCRIPTION
# This procedure resets common code elements needed at the end of a test.
#
# RETURNS:  
# status      TCL_OK     - on success
#             TCL_ERROR  - on failure
#
###
proc bbBackToBack::TestCleanUp {} { 
    debugPuts "Start TestCleanUp"

    set status $::TCL_OK;    

    debugPuts "Leave TestCleanUp"
    return $status;
}

#############################################################################
# bbBackToBack::TrialSetup()
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
proc bbBackToBack::TrialSetup {} {    
     debugPuts "Start TrialSetup"
     variable trial

     set status $::TCL_OK;     
     set learnproc [switchLearn::getLearnProc]

     if {[learn cget -when] == "onTrial"} {
           if [$learnproc one2manyArray] {
               errorMsg "Error sending learn frames"
               set retCode $::TCL_ERROR;
           }
     }
###
     logMsg "\n******* TRIAL $trial - [[namespace current] cget -testName] *******"
     set ::[namespace current]::trial $trial
###
     debugPuts "Leave TrialSetup"
     return $status;
 }

#############################################################################
# bbBackToBack::AlgorithmSetup()
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
proc bbBackToBack::AlgorithmSetup {} {
    debugPuts "Start AlgorithmSetup"

    set status $::TCL_OK;
    variable framesizeWan
    variable framesizeBroadBand
    variable trial
    variable xmdDef
    variable maxFrameRateWanArray
    variable userFrameRateWanArray
    variable userPercentRateWanArray  
    variable maxFrameRateBroadBandArray
    variable userFrameRateBroadBandArray
    variable userPercentRateBroadBandArray 
    variable directions

    variable nonAtmPortList
    variable thruputRate
    variable s_many2oneArray

    global one2manyArray

    set testCmd [namespace current]

    set status $::TCL_OK

    $testCmd config -framesize  $framesizeWan

    if {[broadbandLearn "oncePerFramesize" bbBackToBack]} {            
            errorMsg "Error sending learn frames"
            set retCode $::TCL_ERROR
    }        

    ######## set up results for this test

    #setupTestResults  one2many "" one2manyArray   $framesizeWan
    #setupTestResults $testCmd many2one "" s_many2oneArray $framesizeBroadBand

    # fix for multiline output in logs   BJL
    #results config -printRxRowValues  allRows


    #initialise the initial rates for WAN stream 
    $testCmd config -framesize  $framesizeWan
    if [rateConversionUtils::initMaxRate one2manyArray maxFrameRateWanArray $framesizeWan \
        userFrameRateWanArray userPercentRateWanArray $testCmd] {
        return $::TCL_ERROR
    }          

    #initialise the initial rates for Broadband streams
    $testCmd config -framesize  $framesizeBroadBand
    if [rateConversionUtils::initMaxRate s_many2oneArray maxFrameRateBroadBandArray $framesizeBroadBand \
        userFrameRateBroadBandArray userPercentRateBroadBandArray $testCmd] {
        return $::TCL_ERROR
    }          


    if {$directions == "downstream"} {
        setupTestResults bbBackToBack one2many "" one2manyArray $framesizeWan [$testCmd cget -numtrials]
        realTimeGraphs::SaveRealTimeMarker "-- Trial:$trial FS WAN:$framesizeWan --";
    } else {
        setupTestResults bbBackToBack many2one "" s_many2oneArray $framesizeBroadBand [$testCmd cget -numtrials]
        realTimeGraphs::SaveRealTimeMarker "-- Trial:$trial FS BroadBand:$framesizeBroadBand --";
    }

    if {[info exists thruputRate]} {
        catch {unset thruputRate}
    }

    debugPuts "Leave AlgorithmSetup"
    return $status;

}

#############################################################################
# bbBackToBack::AlgorithmBody()
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
proc bbBackToBack::AlgorithmBody {} {    
    debugPuts "Start AlgorithmBody"

    set status  1
    set testCmd [namespace current]        
            
    set status [expr [${testCmd}::BinarySearchAlgorithm] && $status]
    
    debugPuts "Leave AlgorithmBody"
    return $status;
}


#############################################################################

proc bbBackToBack::BinarySearchAlgorithm {} \
{
    variable fullMapArray
    variable framesizeWan
    variable framesizeBroadBand
    #variable userFrameRateArray
    #variable userPercentRateArray  
    variable maxFrameRateWanArray 
    variable maxFrameRateBroadBandArray
    variable groupIdArray
    #variable totalLoss
    variable trial
    
    variable iteration
    variable thruputRate;
    variable txNumFrames;
    variable rxNumFrames
    variable totalTxNumFrames
    variable totalRxNumFrames
    variable percentTput
    variable txActualFrames
    variable s_many2oneArray
    variable txBroadBandNumFrames
    variable rxBroadBandNumFrames
    variable txBroadBandActualFrames
    variable totalBroadBandTxNumFrames
    variable totalBroadBandRxNumFrames    
    variable txWanNumFrames
    variable rxWanNumFrames
    variable txWanActualFrames
    variable totalWanTxNumFrames
    variable totalWanRxNumFrames
    variable fResultArray

    global one2manyArray
    variable directions 

    set status $::TCL_OK

    set testCmd [namespace current]   

    set rateSelect      [$testCmd cget -rateSelect]
    set duration        [$testCmd cget -duration]
    set binarySearchDirection [$testCmd cget -binarySearchDirection]
    
    set rxWanPortList       [getRxPorts one2manyArray]
    set rxBroadBandPortList [getRxPorts s_many2oneArray]

    set rateType [lindex [split $rateSelect R] 0]

    set currWanPercent [$testCmd cget -${rateType}WanRate]
    set currBroadBandPercent [$testCmd cget -${rateType}BroadBandRate]

    set origWanPercent       $currWanPercent
    set origBroadBandPercent $currBroadBandPercent   

    logMsg "=====> Binary Search, Trial $trial, framesize Wan: $framesizeWan, framesize BroadBand:$framesizeBroadBand [$testCmd cget -testName]"

    switch  $directions {
        bidirectional {
            set fs "$framesizeWan-$framesizeBroadBand"    
        }
        downstream {
            set fs "$framesizeWan"    
        }
        upstream {
            set fs "$framesizeBroadBand"    
        }
    }

    set oldLatency [$testCmd cget -calculateLatency]
    set oldJitter  [$testCmd cget -calculateJitter]

    $testCmd config -calculateLatency   no
    $testCmd config -calculateJitter    no

    set binaryDirection none
    set linearDirection none

    set binarySearchDirection [$testCmd cget -binarySearchDirection] 
    # 1 - up

    if {$directions=="downstream" || (($directions=="bidirectional")&&(!$binarySearchDirection))} {
        set binaryDirection downstream
    }

    if {$directions=="upstream" || (($directions=="bidirectional")&&($binarySearchDirection))} {
        set binaryDirection upstream
    }

    if {(($directions=="bidirectional")&&(!$binarySearchDirection))} {
        set linearDirection upstream
        set linearTputPercent $currBroadBandPercent
    }

    if {(($directions=="bidirectional")&&($binarySearchDirection))} {
        set linearDirection downstream
        set linearTputPercent $currWanPercent             
    }

# logMsg "directions=$directions / binarySearchDirection=$binarySearchDirection / linearDirection=$linearDirection / binaryDirection=$binaryDirection"

    if {($binaryDirection=="upstream") || ($linearDirection=="upstream")} {
        #initialise the initial rates for Broadband streams
        $testCmd config -framesize  $framesizeBroadBand
        $testCmd config -${rateSelect} $currBroadBandPercent

        if [rateConversionUtils::initMaxRate s_many2oneArray maxFrameRateBroadBandArray $framesizeBroadBand \
            userFrameRateBroadBandArray userPercentRateBroadBandArray $testCmd] {
            return $::TCL_ERROR
        }                     

        $testCmd config -framesize  $framesizeBroadBand

        if [writeTputStreams s_many2oneArray userFrameRateBroadBandArray txBroadBandNumFrames $testCmd userPercentRateBroadBandArray]  {
            return $::TCL_ERROR
        }

        # Check and adjust for VLAN tag.
        if {[string tolower [learn cget -snoopConfig]] == "true"} {
            if {[snoopConfig s_many2oneArray]} {
                return $::TCL_ERROR
            }
        }

        $testCmd config -calculateLatency   $oldLatency
        $testCmd config -calculateJitter    $oldJitter

        if [PacketGroupStreamBuild $testCmd s_many2oneArray txBroadBandNumFrames $framesizeBroadBand userPercentRateBroadBandArray] {
                errorMsg $errMsg
                return $::TCL_ERROR
        }
        array set txNumFrames [array get txBroadBandNumFrames]            
        array set rxNumFrames [array get rxBroadBandNumFrames]

    }

   if {($binaryDirection=="downstream") || ($linearDirection=="downstream")} {
        #initialise the initial rates for WAN stream 
        $testCmd config -framesize  $framesizeWan
        $testCmd config -${rateSelect} $currWanPercent     

        if [rateConversionUtils::initMaxRate one2manyArray maxFrameRateWanArray $framesizeWan \
            userFrameRateWanArray userPercentRateWanArray $testCmd] {
            return $::TCL_ERROR
        }  
        $testCmd config -framesize  $framesizeWan
        
        if [writeTputStreams one2manyArray userFrameRateWanArray txWanNumFrames $testCmd userPercentRateWanArray]  {
            return $::TCL_ERROR
        }


        # Check and adjust for VLAN tag.
        if {[string tolower [learn cget -snoopConfig]] == "true"} {
            if {[snoopConfig one2manyArray]} {
                return $::TCL_ERROR
            }
        }

        $testCmd config -calculateLatency   $oldLatency
        $testCmd config -calculateJitter    $oldJitter

        if [PacketGroupStreamBuild $testCmd one2manyArray txWanNumFrames $framesizeWan userPercentRateWanArray] {
                errorMsg $errMsg
                return $::TCL_ERROR
        }

        foreach txMap  [array names one2manyArray] {
            scan $txMap "%d,%d,%d" tx_c tx_l tx_p
            set txWanNumFrames($txMap) [mpexpr [llength $one2manyArray($txMap)] * $txWanNumFrames($txMap)]

        }

        array set txNumFrames [array get txWanNumFrames]
        array set rxNumFrames [array get rxWanNumFrames]    
   }       


   if {$binaryDirection=="downstream"} {
       
       if {$linearDirection=="upstream"} {
           set status [expr [doBinarySearchBackToBack one2manyArray fullMapArray txNumFrames \
                      userFrameRateWanArray b2bResult fResultArray $trial] && $status]

       } else {
           set status [expr [doBinarySearchBackToBack one2manyArray one2manyArray txNumFrames \
                        userFrameRateWanArray b2bResult fResultArray $trial] && $status]

       }
               #return $status
   } else { ;# binary direction=="upstream"
       if {$linearDirection=="downstream"} {
          set status [expr [doBinarySearchBackToBack s_many2oneArray fullMapArray txNumFrames \
                        userFrameRateBroadBandArray b2bResult fResultArray $trial] && $status]

       } else {
           set status [expr [doBinarySearchBackToBack s_many2oneArray s_many2oneArray txNumFrames \
                        userFrameRateBroadBandArray b2bResult fResultArray $trial] && $status]
       }
   }



   if {$binaryDirection=="downstream"} {
       array set binTxRxArray [array get one2manyArray]
       set binaryCurrPercent [$testCmd cget -${rateType}WanRate]       
   } else {
       array set binTxRxArray [array get s_many2oneArray]
       set binaryCurrPercent [$testCmd cget -${rateType}BroadBandRate]       
   }   


   if {$linearDirection=="downstream"} {
       array set linearTxRxArray [array get one2manyArray]
       set linearCurrPercent [$testCmd cget -${rateType}WanRate] 
   } else {
       array set linearTxRxArray [array get s_many2oneArray]
       set linearCurrPercent [$testCmd cget -${rateType}BroadBandRate]
   }   

    set fileID  [openResultFile a]

    set strToPrint "\n\nResults for Trial $trial ...\n"
    writeResult $fileID $strToPrint

    set strToPrint [format "\nBinary Search Direction:%s " $binaryDirection]
    writeResult $fileID $strToPrint

    if {$binaryDirection == "downstream"} {
        set strToPrint [format "%-15s\t%-15s\t%-10s" "Wan Port" "Broadband Port" "B2bFrames" ]
    } else {
        set strToPrint [format "%-15s\t%-15s\t%-10s" "Broadband Port" "Wan Port" "B2bFrames" ]
    }

    
    writeResult $fileID $strToPrint
    set strToPrint "****************************************"
    writeResult $fileID $strToPrint

    set totalb2bFrames 0
    set oldTxMap ""

    foreach txMap [array names binTxRxArray]  {
        scan $txMap "%d,%d,%d" tx_c tx_l tx_p
        
        set fResultArray($trial,$fs,1,$txMap,backToBackFrames) $b2bResult($tx_c,$tx_l,$tx_p)
        foreach rxMap $binTxRxArray($txMap) {
            scan $rxMap "%d %d %d" rx_c rx_l rx_p
            if {$oldTxMap == $txMap} {
                set strToPrint [format "%-15s\t%-15s\t%-10s" [getPortId $tx_c $tx_l $tx_p]  [getPortId $rx_c $rx_l $rx_p] "-"]                  
                writeResult $fileID $strToPrint
            } else {
                set strToPrint [format "%-15s\t%-15s\t%-10s" [getPortId $tx_c $tx_l $tx_p]  [getPortId $rx_c $rx_l $rx_p] $b2bResult($tx_c,$tx_l,$tx_p)]  
                writeResult $fileID $strToPrint
                set totalb2bFrames [mpexpr { $totalb2bFrames + $b2bResult($tx_c,$tx_l,$tx_p) }]
                set oldTxMap $txMap
            }
        }
    }


    

    set strToPrint "****************************************"
    writeResult $fileID $strToPrint

    switch $rateSelect {
        kbpsRate  {            
            set strToPrint [format "KbpsMaxRate      = %d"  $binaryCurrPercent]
        }
        percentMaxRate {
            set strToPrint [format "%%MaxRate         = %5.2f" $binaryCurrPercent]
        }
        fpsRate {           
           set strToPrint [format "FPSMaxRate       = %5.2f" $binaryCurrPercent]
        }
    }

    writeResult $fileID $strToPrint

    set strToPrint [format "Total Back2back  = %d" $totalb2bFrames]
    writeResult $fileID $strToPrint
    set strToPrint [format "Tolerance(%%)     = %5.2f" [$testCmd cget -tolerance]]
    writeResult $fileID $strToPrint
    set strToPrint  "****************************************"
    writeResult $fileID $strToPrint

    if { $linearDirection != "none" } {
        set bestIteration $fResultArray($trial,$fs,bestIteration)

        set strToPrint [format "\nTransmiting Direction:%s " $linearDirection]
        writeResult $fileID $strToPrint
        if {$linearDirection == "downstream"} {
            set strToPrint [format "%-15s\t%-15s\t%-10s" "Wan Port" "Broadband Port" "B2bFrames" ]
        } else {
            set strToPrint [format "%-15s\t%-15s\t%-10s" "Broadband Port" "Wan Port" "B2bFrames" ]
        }
        writeResult $fileID $strToPrint
        set strToPrint "****************************************"
        writeResult $fileID $strToPrint

        set totalb2bFrames 0

        foreach txMap [array names linearTxRxArray]  {
            scan $txMap "%d,%d,%d" tx_c tx_l tx_p

            foreach rxMap $linearTxRxArray($txMap) {
                scan $rxMap "%d %d %d" rx_c rx_l rx_p                
                if {$oldTxMap == $txMap} {
                    set strToPrint [format "%-12s\t%-12s\t%-10s" [getPortId $tx_c $tx_l $tx_p]  [getPortId $rx_c $rx_l $rx_p] "-"]                  
                    writeResult $fileID $strToPrint
                } else {
                    set strToPrint [format "%-12s\t%-12s\t%-10s" [getPortId $tx_c $tx_l $tx_p]  [getPortId $rx_c $rx_l $rx_p] $fResultArray($trial,$fs,$bestIteration,$tx_c,$tx_l,$tx_p,txNumFrames)]  
                    writeResult $fileID $strToPrint
                    set totalb2bFrames [mpexpr { $totalb2bFrames + $fResultArray($trial,$fs,$bestIteration,$tx_c,$tx_l,$tx_p,txNumFrames) }]
                    set oldTxMap $txMap
                }
            }
        }

        set strToPrint "****************************************"
        writeResult $fileID $strToPrint

        switch $rateSelect {
            kbpsRate  {                            
                set strToPrint [format "KbpsMaxRate      = %d" $linearCurrPercent]
            }
            percentMaxRate {
                set strToPrint [format "%%TputPercent     = %5.2f" $linearCurrPercent]
            }
            fpsRate {                          
               set strToPrint [format "FPSMaxRate       = %5.2f" $linearCurrPercent]
            }
        }
        
        writeResult $fileID $strToPrint
        set strToPrint [format "Total Tx Frames  = %d" $totalb2bFrames]
        writeResult $fileID $strToPrint        
        set strToPrint  "****************************************"
        writeResult $fileID $strToPrint

    }
#parray fResultArray

    if {$fileID != "stdout"} {
         closeMyFile $fileID
    }

    return $status
}

#############################################################################
# bbBackToBack::AlgorithmCleanup()
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
proc bbBackToBack::AlgorithmCleanUp {} {
    debugPuts "Start AlgorithmCleanUp"

    set status $::TCL_OK;

    debugPuts "Leave AlgorithmCleanUp"
    return $status;
}

#############################################################################
# bbBackToBack::MetricsPostProcess()
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
proc bbBackToBack::MetricsPostProcess {} {
    debugPuts "Start MetricsPostProcess"
    set status $::TCL_OK;


    global one2manyArray
    global testConf

    variable resultsDirectory
    variable trialsPassed    
    variable fullMapArray
    variable portPgId
    variable fResultArray
    variable framesizeWan
    variable framesizeBandBroand

    variable directions

    variable minBackToBackFrames
    variable minDuration
    variable avgLatency
    variable maxLatency
    variable s_many2oneArray

#parray fResultArray

    set testCmd [namespace current]

    logMsg "\n***************************************";
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

    set testCmd [namespace current]
    set binarySearch        1
    set calculateLatency    [expr {[$testCmd cget -calculateLatency] == "yes"}]
    set calculateJitter     [expr {[$testCmd cget -calculateJitter] == "yes"}]    
    set imixMode            0
    set linearSearch        0

    set frameSizeWanList [[namespace current] cget -framesizeWanList];
    set frameSizeBroadBandList [[namespace current] cget -framesizeBroadBandList];
  
  
    if {$directions=="downstream"} {
         set frameSizeBroadBandList 64
    }

    if {$directions=="upstream"} {
        set frameSizeWanList   64
    }
   
    debugPuts [$testCmd cget -numtrials]
    

    set binarySearchDirection [$testCmd cget -binarySearchDirection] 
    set binaryDirection upstream
 
    if {$directions=="downstream" || (($directions=="bidirectional")&&(!$binarySearchDirection))} {
      set binaryDirection downstream
    } 
    
    if {$binaryDirection=="downstream" } {
        array set txRxArray [array get one2manyArray]
    } else {
        array set txRxArray [array get s_many2oneArray]
    }
    
    for {set trial 1} {$trial <= [$testCmd cget -numtrials] } {incr trial} {

        set percentLineRateList {};
        set frameRateList {};
        set dataRateList {};
        set avgLatencyList {};
        set maxLatencyList {};
        set avgStdDeviationList {}

        if {$linearSearch} {
            lappend colHeads "Iteration"
            set numIterations [$testCmd cget -numIterations]
        } else {
            set numIterations 1
        }
        
        foreach framesizeWan $frameSizeWanList {
            foreach framesizeBroadBand $frameSizeBroadBandList {        
                set durationList {};
                set backToBackFramesList {};
                set aggMinLatencyList {};
                set aggMaxLatencyList {};
                set aggAvgLatencyList {};

                
                switch  $directions {
                    bidirectional {
                        set fs "$framesizeWan-$framesizeBroadBand"    
                    }
                    downstream {
                        set fs "$framesizeWan"    
                    }
                    upstream {
                        set fs "$framesizeBroadBand"    
                    }
                }
                
                for {set iteration 1} {$iteration <= $numIterations } {incr iteration} {
                    if {$linearSearch} {
                        set lstr "iter,$iteration,"
                        set istr "$iteration"
                    } else {
                        set lstr ""
                        set istr ""
                    }

                    foreach txMap [lsort [array names txRxArray]] {
                        scan $txMap "%d,%d,%d" tx_c tx_l tx_p 

                        set txPacketGroupId $portPgId($txMap)                                
                        set first 1

                        set txPort [join "$tx_c $tx_l $tx_p" .]

                        if {[lsearch [array names one2manyArray] $txMap] != -1} {
                            set isWanPort 1                            
                        } else {
                            set isWanPort 0                     
                        }

                        if {[info exists fResultArray($trial,$fs,$iteration,$txMap,backToBackFrames)]} {
                            set backToBackFrames  $fResultArray($trial,$fs,$iteration,$txMap,backToBackFrames)
                        } else {
                            set backToBackFrames  0
                        }

                        if {[info exists fResultArray($trial,$fs,$iteration,$txMap,duration)]} {
                            set duration  $fResultArray($trial,$fs,$iteration,$txMap,duration)
                        } else {
                            set duration  0
                        }

                        lappend backToBackFramesList $backToBackFrames
                        
                        lappend durationList $duration                        

                        foreach rxMap $txRxArray($txMap) {          
                            scan $rxMap "%d %d %d" rx_c rx_l rx_p
                            set rxPort [join "$rx_c $rx_l $rx_p" .]

                            if {$calculateLatency || $calculateJitter} {
                                  
                                  if {[info exists fResultArray($trial,$fs,$iteration,[join "$rx_c $rx_l $rx_p" ,],$txPacketGroupId,maxLatency)]} {
                                    lappend maxLatencyList $fResultArray($trial,$fs,$iteration,[join "$rx_c $rx_l $rx_p" ,],$txPacketGroupId,maxLatency)
                                  } else {
                                    lappend maxLatencyList 0
                                  } 
                                  if {[info exists fResultArray($trial,$fs,$iteration,[join "$rx_c $rx_l $rx_p" ,],$txPacketGroupId,avgLatency)]} {
                                    lappend avgLatencyList $fResultArray($trial,$fs,$iteration,[join "$rx_c $rx_l $rx_p" ,],$txPacketGroupId,avgLatency)
                                  } else {
                                    lappend avgLatencyList 0
                                  }                                   
                            }                         
                        } ;#loop rx                    
                    };#loop tx                
                } ;# loop iteration
            };# loop framesizeBroadBand
        } ;# loop framesizeWan
    
        
        # Minimum Back To Back  is the smallest back to back frames sent of any port pair 
        # across any frame sizes for a given trial.
        set minBackToBackFrames($trial) [passfail::ListMin backToBackFramesList];
    
        # Average % Line Rate is an average throughput percentage across any frame 
        # sizes and all ports for a given trial
        set minDuration($trial) [passfail::ListMin durationList];
            
        if {$calculateLatency || $calculateJitter} {
            # captureType - Buffer/ Latency - yes / Jitter - no
            if {[lsearch $avgLatencyList "notCalculated"] >= 0} {
                set avgLatency($trial) "notCalculated";
                set maxLatency($trial) "notCalculated"
            } else {
                # Maximum Latency is the largest latency of any port pair
                # across any frame sizes for a given trial
                set maxLatency($trial) [passfail::ListMax avgLatencyList];
    
                # Average Latency is the average latency of any port pair
                # across any frame sizes for a given trial
                set avgLatency($trial) [passfail::ListMean avgLatencyList];
            }
        }       

    } ;# loop over trials

    debugPuts "Leave MetricsPostProcess"
    return $status;
}
################################################################################
#
# bbBackToBack::PassFailCriteriaEvaluate()
#
# DESCRIPTION:
# 
#
# RETURNS
# none
#
###
proc bbBackToBack::PassFailCriteriaEvaluate {} {
   
    debugPuts "Start PassFailCriteriaEvaluate"
    set status $::TCL_OK; 

    variable avgLatency
    variable maxLatency
    variable minBackToBackFrames
    variable minDuration  
    variable trialsPassed

    global testConf

    if {[info exists testConf(passFailEnable)] == 0} {
        return;
    }

    if {!$testConf(passFailEnable)} {
        return;
    } 
    set testCmd [namespace current]

    set calculateLatency    [expr {[$testCmd cget -calculateLatency] == "yes"}]
    set calculateJitter     [expr {[$testCmd cget -calculateJitter] == "yes"}]
   
    set trialsPassed  0

    for {set trial 1} {$trial <= [$testCmd cget -numtrials] } {incr trial} {
        logMsg "*** Trial #$trial";
    
        # Pass/Fail Criteria is based on the logical AND of two criteria
        set backToBackResult [passfail::PassFailCriteriaBackToBackEvaluate $minDuration($trial) $minBackToBackFrames($trial) ]

        if {$calculateLatency} {
            set latencyResult [passfail::PassFailCriteriaLatencyEvaluate \
                       $avgLatency($trial) $maxLatency($trial)];
            
            if { ($backToBackResult == "PASS") && ($latencyResult == "PASS")} {
                set result "PASS"
            } else {
                set result "FAIL";
            }
        } elseif {$calculateJitter} {  
                #don't care about latency 
                set jitterResult [passfail::PassFailCriteriaJitterEvaluate \
                                     $avgLatency($trial) $maxLatency($trial)];
    
                if { ($backToBackResult == "PASS") && ($jitterResult == "PASS") } {
                        set result "PASS"
                    } else {
                        set result "FAIL";
                }
            } else {
                set result $backToBackResult
            }
    
        if { $result == "PASS" } {
            incr trialsPassed
        }
        logMsg "*** $result\n"
    }


    logMsg "*** # Of Trials Passed: $trialsPassed";
    logMsg "***************************************"
    debugPuts "Leave PassFailCriteriaEvaluate"
    return $status;
}


########################################################################
# bbBackToBack::WriteResultsCSV()
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
proc bbBackToBack::WriteResultsCSV {} {  
    variable fResultArray
    global   one2manyArray
    variable fullMapArray
    variable portPgId
    variable resultsDirectory
    variable directions
    
    # imix
    variable groupIdWanArray
    variable groupIdBroadBandArray
    variable groupIdArray

    set dirName $resultsDirectory
    debugPuts "Start WriteResultsCSV"
    set status $::TCL_OK

#    parray fResultArray

    set testCmd [namespace current]
    
    set calculateLatency    [expr {[$testCmd cget -calculateLatency] == "yes"}]
    set calculateJitter     [expr {[$testCmd cget -calculateJitter] == "yes"}]    
    set calculateDataIntegrity [expr {![string compare [$testCmd cget -calculateDataIntegrity] yes]}]
    
    set testCmd [namespace current]

    if {[catch {set csvFid [open $dirName/results.csv w]}]} {
        logMsg "***** WARNING:  Cannot open csv file."
        return
    }

# Standard (not Imix mode)

    set colHeads {"Trial" "Frame Size (bytes)"  "Directions" "Tx Port" "Rx Port" "Tx Frames" "Rx Frames" "Back To Back Frames"}

    if {$calculateDataIntegrity} {
        lappend colHeads "Data Integrity Errors"
    }

    puts $csvFid [join $colHeads ,]

    set frameSizeWanList [[namespace current] cget -framesizeWanList];
    set frameSizeBroadBandList [[namespace current] cget -framesizeBroadBandList];

    if {$directions=="downstream"} {
         set frameSizeBroadBandList 64
    }

    if {$directions=="upstream"} {
        set frameSizeWanList   64
    }

    for {set trial 1 } {$trial <= [$testCmd cget -numtrials]} {incr trial} {
        foreach framesizeWan $frameSizeWanList {
            foreach framesizeBroadBand $frameSizeBroadBandList {
               switch  $directions {
                    bidirectional {
                        set fs "$framesizeWan-$framesizeBroadBand"    
                    }
                    downstream {
                        set fs "$framesizeWan"    
                    }
                    upstream {
                        set fs "$framesizeBroadBand"    
                    }
                }                
                
                set iteration $fResultArray($trial,$fs,bestIteration)
                foreach txMap [lsort [array names fullMapArray]] {
                    scan $txMap "%d,%d,%d" tx_c tx_l tx_p 

                    set txPacketGroupId $portPgId($txMap)                                
                    set first 1

                    set txPort [join "$tx_c $tx_l $tx_p" .]    

                    if {[lsearch [array names one2manyArray] $txMap] != -1} {
                        set isWanPort "- D -"                            
                    } else {
                        set isWanPort "- U -"                  
                    }


                    if {[info exists fResultArray($trial,$fs,$iteration,$txMap,txNumFrames)]} {
                        set txFrames [mpexpr {$fResultArray($trial,$fs,$iteration,$txMap,txNumFrames)}]                            
                    } else {
                        set txFrames 0;
                    }            

                    
                    if {[info exists fResultArray($trial,$fs,$iteration,$txMap,framesReceivedPerTx)]} {
                        set backToBackFrames [mpexpr {$fResultArray($trial,$fs,$iteration,$txMap,framesReceivedPerTx)}]                            
                    } else {
                        set backToBackFrames 0;
                    }            

                    set firstRx 1

                    foreach rxMap $fullMapArray($txMap) {          
                        scan $rxMap "%d %d %d" rx_c rx_l rx_p
                        set rxPort [join "$rx_c $rx_l $rx_p" .]                            

                        if {[info exists fResultArray($trial,$fs,$iteration,[join "$rx_c $rx_l $rx_p" ,],$txPacketGroupId,rxNumFrames)]} {
                           set rxFrames $fResultArray($trial,$fs,$iteration,[join "$rx_c $rx_l $rx_p" ,],$txPacketGroupId,rxNumFrames)
                        } else {
                           set rxFrames  0;
                        } 

                        if {$firstRx} {                        
                            set resList [list $trial $fs $isWanPort $txPort $rxPort $txFrames $rxFrames $backToBackFrames]
                        } else {
                            set resList [list $trial $fs $isWanPort $txPort $rxPort "-" $rxFrames "-"]
                        }

                        if {$calculateDataIntegrity} {
                          if {[info exists fResultArray($trial,$fs,$iteration,[join "$rx_c $rx_l $rx_p" ,],dataIntegrityErrors)]} {
                            set dataIntegrityErrors $fResultArray($trial,$fs,$iteration,[join "$rx_c $rx_l $rx_p" ,],dataIntegrityErrors)
                          } else {
                            set dataIntegrityErrors 0
                          } 

                          if {$firstRx == 0} {
                            set dataIntegrityErrors "-" 
                          }
                          lappend resList $dataIntegrityErrors 
                        }

                        if {$firstRx} {
                            set firstRx 0
                        }

                        regsub ",," [join $resList ,] "," lista
                        puts $csvFid $lista

                    } ;#loop rx
                };#loop tx

            } ;# loop fs broadband
        } ;# loop framesize wan
    } ;# loop trial

    close $csvFid

    debugPuts "Leave WriteResultsCSV"
    return $status;
}

########################################################################
# [namespace current]::WriteAggregateResultsCSV()
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
proc bbBackToBack::WriteAggregateResultsCSV {} {
  debugPuts "Start WriteAggregateResultsCSV"

    variable fResultArray
    global   one2manyArray
    variable portPgId
    variable resultsDirectory
    variable directions

    # imix
    variable groupIdWanArray
    variable groupIdBroadBandArray
    variable fullMapArray
    variable groupIdArray

#parray fResultArray

    set dirName $resultsDirectory

    set status $::TCL_OK

    set testCmd [namespace current]

    set calculateLatency    [expr {[$testCmd cget -calculateLatency] == "yes"}]
    set calculateJitter     [expr {[$testCmd cget -calculateJitter] == "yes"}]    
    set calculateDataIntegrity [expr {![string compare [$testCmd cget -calculateDataIntegrity] yes]}]
    
    if {[catch {set csvFid [open $dirName/AggregateResults.csv w]}]} {
        logMsg "***** WARNING:  Cannot open AggregateResults.csv file."
        return
    }

    set colHeads {"Trial" "Frame Size (bytes)" "Agg Tx Frames" "Agg Rx Frames" "Agg Back To Back Frames"} 

    if {$calculateDataIntegrity} {
        lappend colHeads "Agg Data Integrity Errors" 
    }
    
    puts $csvFid [join $colHeads ,]  

    set frameSizeWanList [[namespace current] cget -framesizeWanList];
    set frameSizeBroadBandList [[namespace current] cget -framesizeBroadBandList];
   
    if {$directions=="downstream"} {
         set frameSizeBroadBandList 64
    }

    if {$directions=="upstream"} {
        set frameSizeWanList   64
    }

    #puts "[$testCmd cget -numtrials]/[$testCmd cget -framesizeWanList]/[$testCmd cget -framesizeBroadBandList]"
    for {set trial 1 } {$trial <= [$testCmd cget -numtrials]} {incr trial} {
       foreach framesizeWan $frameSizeWanList {
            foreach framesizeBroadBand $frameSizeBroadBandList {      
               switch  $directions {
                    bidirectional {
                        set fs "$framesizeWan-$framesizeBroadBand"    
                    }
                    downstream {
                        set fs "$framesizeWan"    
                    }
                    upstream {
                        set fs "$framesizeBroadBand"    
                    }
                }

                set iteration $fResultArray($trial,$fs,bestIteration)
                
                set backToBackFramesList {}                
                set aggTxFramesList {}
                set aggRxFramesList {}
                set dataIntegrityErrorsList {}
                
                
                foreach txMap [lsort [array names fullMapArray]] {                        
                    scan $txMap "%d,%d,%d" tx_c tx_l tx_p 
                    
                    set txPacketGroupId $portPgId($txMap)                                
                    set first 1

                    set txPort [join "$tx_c $tx_l $tx_p" .]                       

                    if {[lsearch [array names one2manyArray] $txMap] != -1} {
                        set isWanPort 1                            
                    } else {
                        set isWanPort 0                     
                    }

                    if {[info exists fResultArray($trial,$fs,1,$txMap,backToBackFrames)]} {
                        lappend backToBackFramesList  $fResultArray($trial,$fs,1,$txMap,backToBackFrames)
                    } else {
                        lappend backToBackFramesList 0
                    }

                    lappend aggTxFramesList $fResultArray($trial,$fs,$iteration,$txMap,txNumFrames)
                    lappend aggRxFramesList $fResultArray($trial,$fs,$iteration,$txMap,framesReceivedPerTx)

                    set firstRx 1

                    foreach rxMap $fullMapArray($txMap) {          
                        scan $rxMap "%d %d %d" rx_c rx_l rx_p
                        set rxPort [join "$rx_c $rx_l $rx_p" .]

                        if {$calculateDataIntegrity} {
                          if {[info exists fResultArray($trial,$fs,$iteration,[join "$rx_c $rx_l $rx_p" ,],dataIntegrityErrors)]} {
                            set dataIntegrityErrors $fResultArray($trial,$fs,$iteration,[join "$rx_c $rx_l $rx_p" ,],dataIntegrityErrors)
                          } else {
                            set dataIntegrityErrors 0
                          } 

                          if {$firstRx == 1} {
                            set firstRx 0
                            lappend  dataIntegrityErrorsList $dataIntegrityErrors  
                          }
                          
                        }
                    } ;#loop rx
                };#loop tx
                set aggBackToBackFrames [passfail::ListSum backToBackFramesList]
                set aggTxFrames [passfail::ListSum aggTxFramesList]
                set aggRxFrames [passfail::ListSum aggRxFramesList]

                set resList [list $trial $fs $aggTxFrames $aggRxFrames $aggBackToBackFrames]

                if {$calculateDataIntegrity} {
                    set aggDataIntegrityErrors [passfail::ListSum dataIntegrityErrorsList]                   

                    lappend resList $aggDataIntegrityErrors 
                }

                regsub ",," [join $resList ,] "," lista
                puts $csvFid $lista
                
            } ;# loop fs broadband
        } ;# loop framesize wan
    } ;# loop trial

    close $csvFid

    debugPuts "Leave WriteAggregateResultsCSV"
    return $status;
}



proc bbBackToBack::WriteInfoCSV {} {
    variable trialsPassed

    set testCmd [namespace current]

    set ${testCmd}::trialsPassed $trialsPassed
    csvUtils::writeInfoCsv $testCmd
}

proc bbBackToBack::WriteIterationCSV {} {  
    variable fResultArray
    global   one2manyArray
    variable fullMapArray
    variable portPgId
    variable resultsDirectory
    variable directions

    # imix
    variable groupIdWanArray
    variable groupIdBroadBandArray
    variable groupIdArray

    set dirName $resultsDirectory
    debugPuts "Start WriteResultsCSV"
    set status $::TCL_OK
          
    set testCmd [namespace current]
    set binarySearch        1
    set calculateLatency    [expr {[$testCmd cget -calculateLatency] == "yes"}]
    set calculateJitter     [expr {[$testCmd cget -calculateJitter] == "yes"}]    
    set calculateDataIntegrity  [expr {[$testCmd cget -calculateDataIntegrity] == "yes"}]
    set imixMode            0
    set linearSearch        0

    set testCmd [namespace current]
    
    if {$binarySearch==0} {
        return $status
    }

    if {[catch {set csvFid [open $dirName/iteration.csv w]}]} {
        logMsg "***** WARNING:  Cannot open csv file."
        return
    }

    set colHeads {"Trial" "Frame Size (bytes)"  "Iteration"  "Directions" "Tx Port" "Rx Port" "Tx Frames" "Rx Frames" "Loss (Frames)" "Loss (%)" "Back To Back Frames"}

    if {$calculateDataIntegrity} {
        lappend colHeads "Data Integrity Errors"
    }

    puts $csvFid [join $colHeads ,]

    set frameSizeWanList [[namespace current] cget -framesizeWanList];
    set frameSizeBroadBandList [[namespace current] cget -framesizeBroadBandList];


    if {$directions=="downstream"} {
         set frameSizeBroadBandList 64
    }

    if {$directions=="upstream"} {
        set frameSizeWanList   64
    }

    
    for {set trial 1 } {$trial <= [$testCmd cget -numtrials]} {incr trial} {
        foreach framesizeWan $frameSizeWanList {
            foreach framesizeBroadBand $frameSizeBroadBandList {
                switch  $directions {
                    bidirectional {
                        set fs "$framesizeWan-$framesizeBroadBand"    
                    }
                    downstream {
                        set fs "$framesizeWan"    
                    }
                    upstream {
                        set fs "$framesizeBroadBand"    
                    }
                }
                set numIterations $fResultArray($trial,$fs,numIterations)

                for {set iteration 1} {$iteration <= $numIterations } {incr iteration} {
                    foreach txMap [lsort [array names fullMapArray]] {
                        scan $txMap "%d,%d,%d" tx_c tx_l tx_p 
                        
                        set txPacketGroupId $portPgId($txMap)                                
                        set first 1

                        set txPort [join "$tx_c $tx_l $tx_p" .]    

                        if {[lsearch [array names one2manyArray] $txMap] != -1} {
                            set isWanPort "- D -"                            
                        } else {
                            set isWanPort "- U -"                  
                        }

 
                        if {[info exists fResultArray($trial,$fs,$iteration,$txMap,txNumFrames)]} {
                            set txFrames [mpexpr {$fResultArray($trial,$fs,$iteration,$txMap,txNumFrames)}]                            
                        } else {
                            set txFrames 0;
                        }            

                        if {[info exists fResultArray($trial,$fs,$iteration,$txMap,framesReceivedPerTx)]} {
                            set backToBackFrames [mpexpr {$fResultArray($trial,$fs,$iteration,$txMap,framesReceivedPerTx)}]                            
                        } else {
                            set backToBackFrames 0;
                        }            

                        set firstRx 1

                        set txFramesPerStream [mpexpr round($txFrames/[llength $fullMapArray($txMap)])]

                        set firstGroup 1

                        foreach rxMap $fullMapArray($txMap) {          
                            scan $rxMap "%d %d %d" rx_c rx_l rx_p
                            set rxPort [join "$rx_c $rx_l $rx_p" .]                            
                            
                            if {[info exists fResultArray($trial,$fs,$iteration,[join "$rx_c $rx_l $rx_p" ,],$txPacketGroupId,rxNumFrames)]} {
                               set rxFrames $fResultArray($trial,$fs,$iteration,[join "$rx_c $rx_l $rx_p" ,],$txPacketGroupId,rxNumFrames)
                            } else {
                               set rxFrames  0;
                            } 

                            set frameLoss     [mpexpr {$txFramesPerStream-$rxFrames}]
                            set percentLoss   [format "%5.2f" [calculatePercentLossExact $txFramesPerStream $rxFrames]]

                            if {$firstRx} {
                                set firstRx 0
                                set resList [list $trial $fs $iteration $isWanPort $txPort $rxPort $txFrames $rxFrames $frameLoss $percentLoss $backToBackFrames]
                            } else {
                                set resList [list $trial $fs $iteration $isWanPort $txPort $rxPort "-" $rxFrames $frameLoss $percentLoss  "-"]
                            }

                            if { $calculateDataIntegrity} {
                                if {$firstGroup} {
                                    set firstGroup 0
                                    lappend resList $fResultArray($trial,$fs,$iteration,$rx_c,$rx_l,$rx_p,dataIntegrityErrors)
                                } else {
                                    lappend resList "-"
                                }                                
                             }
                            regsub ",," [join $resList ,] "," lista
                            puts $csvFid $lista
                        } ;#loop rx
                    };#loop tx
                } ;# loop iteration
            } ;# loop fs broadband
        } ;# loop framesize wan
    } ;# loop trial

    close $csvFid

    debugPuts "Leave WriteResultsCSV"
    return $status;
}



#############################################################################
# bbBackToBack::ConfigValidate()
#
# DESCRIPTION
# This procedure verifies configuration values specified by the user.
#
# RETURNS:  
# status      TCL_OK     - on success
#             TCL_ERROR  - on failure
#
###
proc bbBackToBack::ConfigValidate {} {
    debugPuts "Start ConfigValidate"

    set status $::TCL_OK;
    set name [namespace current]

    #repeated frame sizes are eliminated from the list if there are any
    configValidation::RemoveDuplicatesFromFramesizeList $name

    #validate framesizeList
    if { ![configValidation::ValidateFrameSizeList  $name]} {
          set status $::TCL_ERROR
           return $status
    }

    #validate initial rate
    if { ![configValidation::ValidateInitialRate  $name]} {
        set status $::TCL_ERROR
         return $status
    }

    #common validatation to all the tests
    if {![configValidation::ValidateCommon $name]} {
       set status $::TCL_ERROR
         return $status
    }


    debugPuts "Leave ConfigValidate"
    return $status;
}

########################################################################
# Procedure: writeIterationData2CSVFile
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
proc bbBackToBack::writeIterationData2CSVFile { iteration testCmd TxRxArray Framerate TputRateArray \
                               TxNumFrames TotalTxNumFrames RxNumFrames TotalRxNumFrames \
                               OLoadArray TxRateBelowLimit } {
   debugPuts "Start writeIterationData2CSVFile"

   set status $::TCL_OK;

   debugPuts "Leave writeIterationData2CSVFile"
   return $status;
}

################################################################################
#
# bbBackToBack::PassFailEnable(args)
#
# DESCRIPTION:
# This procedure enables or disables bbBackToBack Pass/Fail Critiera related widgets.
# This either allows the user to click on and adjust widgets or prevents this.
#
# ARGUMENTS
# args       - variable arguments
#
# RETURNS
# none
#
###
proc bbBackToBack::PassFailEnable {args} {
    global passFailEnable

     set state disabled;

     if {$passFailEnable} {
         set state enabled  
         #cmBachToBack::ThroughputThresholdToggle
     }

     set attributeList {
         numDuration
         dataThresholdScale
         numBack2BackFrames
         thresholdMode
     }

     renderEngine::WidgetListStateSet $attributeList $state;
}

#######################################################################################
#
#
#
#
#
###################################
proc bbBackToBack::updateNextIterationRate { TxRxArray PercentMaxRate TxNumFrames Framerate {testCmd bbThroughput}} {     
    upvar $TxRxArray        txRxArray
    upvar $PercentMaxRate   percentMaxRate
    upvar $TxNumFrames      txNumFrames
    upvar $Framerate        framerate

   catch {unset framerate}

   foreach txMap [array names txRxArray] {
      scan $txMap "%d,%d,%d" tx_c tx_l tx_p      

      set numRxPorts [llength $txRxArray($tx_c,$tx_l,$tx_p)]

      if {[streamUtils::streamGet $tx_c $tx_l $tx_p 1]} {
                errorMsg "Error getting stream [getPortId $tx_c $tx_l $tx_p] 1"
                set retCode $::TCL_ERROR
                continue
      }

      set framesize [stream cget -framesize]      
      set framerate($tx_c,$tx_l,$tx_p)   [mpexpr {$percentMaxRate($tx_c,$tx_l,$tx_p) * [calculateMaxRate $tx_c $tx_l $tx_p $framesize]} ]      
   }

   $testCmd config -framesize  $framesize

   if [writeTputStreams txRxArray framerate txNumFrames $testCmd percentMaxRate]  {
        return $::TCL_ERROR
   }
    
    # Check and adjust for VLAN tag.
   if {[string tolower [learn cget -snoopConfig]] == "true"} {
        if {[snoopConfig one2manyArray]} {
            return $::TCL_ERROR
        }
   }
    
   if [PacketGroupStreamBuild $testCmd txRxArray txNumFrames $framesize percentMaxRate] {
            errorMsg $errMsg
            return $::TCL_ERROR
   }
    
}


################################################################################
#
# bbBackToBack::ThroughputThresholdToggle(args)
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
proc bbBackToBack::ThroughputThresholdToggle {args} {
    global passFailMode

    if {$passFailMode == "duration"} {
        set b2bState disabled
        set durationState enabled
    } else {   ; #b2b
        set b2bState enabled
        set durationState disabled
    }

    set durationAttributeList {
        numDuration
        dataThresholdScale
    }
    renderEngine::WidgetListStateSet $durationAttributeList $durationState

    set b2bAttributeList {
        numBack2BackFrames
    }
    renderEngine::WidgetListStateSet $b2bAttributeList $b2bState
}


#######################################################################
#
#
#
#
##########################################################################
proc bbBackToBack::ComputeBinaryIterationResults {TxActualFrames TotalTxNumFrames RxNumFrames TotalRxNumFrames PercentMaxRate iteration SentFrames ReceivedFrames} {
    variable durationArray
    variable thruputRate
    variable maxFrameRateWanArray 
    variable maxFrameRateBroadBandArray
    variable userFrameRateArray; 
    variable userPercentRateArray
    variable percentTput
    variable latencyTime
    variable groupIdArray
    variable portPgId

    #for Imix only
    variable framesizeWan
    variable framesizeBroadBand    
    variable s_many2oneArray
        
  
    #for Standard
    variable txNumFrames
    variable rxNumFrames
    variable txActualFrames
    variable totalTxNumFrames
    variable totalRxNumFrames

    #common
    variable directions     
    variable trial
    variable fResultArray
    variable avgLatency
    variable minLatency
    variable maxLatency   
    variable fullMapArray
    global   one2manyArray 
    global   testConf

    set status $::TCL_OK

    set testCmd [namespace current]

    
    catch {unset txActualFrames}
    catch {unset rxNumFrames}

    upvar $RxNumFrames     tempRxNumFrames
    upvar $TxActualFrames  tempTxActualFrames    
    upvar $PercentMaxRate  percentMaxRate
    upvar $SentFrames      sentFrames
    upvar $ReceivedFrames  receivedFrames
 

    set totalTxNumFrames $TotalTxNumFrames
    set totalRxNumFrames $TotalRxNumFrames

    array set txActualFrames [array get tempTxActualFrames]
    array set rxNumFrames    [array get tempRxNumFrames]

    switch  $directions {   
          bidirectional {
             set fs "$framesizeWan-$framesizeBroadBand"    
          }
          downstream {
             set fs "$framesizeWan"
          }
          upstream {
             set fs "$framesizeBroadBand"
          }
    }

    #set iteration 1
    #catch {unset fResultArray}
    
    GetLatencyJitter $iteration     

    foreach txMap [lsort [array names fullMapArray]] {
        scan $txMap "%d,%d,%d" tx_c tx_l tx_p
        set sentFrames($txMap) $fResultArray($trial,$fs,$iteration,$txMap,txNumFrames) 
        set receivedFrames($txMap) $fResultArray($trial,$fs,$iteration,$txMap,framesReceivedPerTx)
    }

    return $status     
}


########################################################################
#
#
#
#
##########################################################################
proc bbBackToBack::GetLatencyJitter {{iteration trial}} {
    variable durationArray
    variable rxNumFrames
    variable txNumFrames
    variable thruputRate
    variable maxFrameRateWanArray 
    variable maxFrameRateBroadBandArray
    variable userFrameRateArray; 
    variable userPercentRateArray
    variable percentTput
    variable latencyTime
    variable groupIdArray
    variable portPgId

    #for Imix only
    variable framesizeWan
    variable framesizeBroadBand    
    variable s_many2oneArray
    variable fullMapArray
    
  
    #for Standard
    variable txNumFrames
    variable rxNumFrames
    variable txActualFrames
    variable totalTxNumFrames
    variable totalRxNumFrames

    #common
    variable directions 
    variable directions
    variable trial
    variable fResultArray
    variable avgLatency
    variable minLatency
    variable maxLatency     
    global   one2manyArray 
    global   testConf

    set status $::TCL_OK

    set testCmd [namespace current]

    set duration [$testCmd cget -duration]

    set calculateJitter         [expr {![string compare [$testCmd cget -calculateJitter] yes]}]     
    set calculateLatency        [expr {![string compare [$testCmd cget -calculateLatency] yes]}]
    set binarySearch            1
    
    set linearSearch            0
    set calculateDataIntegrity  [expr {[$testCmd cget -calculateDataIntegrity] == "yes"}]

      switch  $directions {
          bidirectional {
             set fs "$framesizeWan-$framesizeBroadBand"
          }
          downstream {
             set fs "$framesizeWan"
          }
          upstream {
             set fs "$framesizeBroadBand"
          }
       }
    
       if {($directions=="bidirectional") || ($directions=="downstream")} {
            #build the values for getting packet group values
            catch {unset groupWanIdArray}
            foreach rxMap [getRxPorts one2manyArray] {
                scan $rxMap "%d %d %d" c l p
                set groupWanIdArray($c,$l,$p) $groupIdArray($c,$l,$p)
            }
           foreach element [array names one2manyArray]  {
                set maxFrameRateArray($element) $maxFrameRateWanArray($element)
           }
        }
    
        if {($directions=="bidirectional") || ($directions=="upstream")} {
            #build the values for getting packet group values
             catch {unset groupBroadBandIdArray}
             foreach rxMap [getRxPorts s_many2oneArray] {
                 scan $rxMap "%d %d %d" c l p
                 set groupBroadBandIdArray($c,$l,$p) $groupIdArray($c,$l,$p)
             }
             foreach element [array names s_many2oneArray]  {
                  set maxFrameRateArray($element) $maxFrameRateBroadBandArray($element)
             }
        }
    
    
        set fResultArray($trial,$fs,$iteration,totalTxNumFrames) $totalTxNumFrames
        set fResultArray($trial,$fs,$iteration,totalRxNumFrames) $totalRxNumFrames    
     
        set rxPortList [getRxPorts fullMapArray] 
    
        getTransmitTime fullMapArray $duration durationArray warnings
    
        array set pgStatistics {
            averageLatency       avgLatency
            minLatency           minLatency
            maxLatency           maxLatency
            totalFrames          rxNumFrames  
        }
            
        set pgStatisticsList [array names pgStatistics];
    
        if {($directions=="bidirectional") || ($directions=="downstream")} {
               if {[::collectPacketGroupStats one2manyArray groupWanIdArray $pgStatisticsList stop verbose]} {
                    errorMsg "Error: Unable to collect packet group statistics"
                    set status $::TCL_ERROR
                 }              
        }
    
        if {($directions=="bidirectional") || ($directions=="upstream")} {
                 if {[::collectPacketGroupStats s_many2oneArray groupBroadBandIdArray $pgStatisticsList stop verbose]} {
                      errorMsg "Error: Unable to collect packet group statistics"
                      set status $::TCL_ERROR
                 }    
        }
    
        foreach {PgStat PgStatArray} [array get pgStatistics] {
           foreach element [array names $PgStat] {
                        #puts "${PgStat}($element) = [set ${PgStat}($element)]"               
                  set fResultArray($trial,$fs,$iteration,$element,${PgStatArray}) [set ${PgStat}($element)]
           }
        }
    
        foreach txMap [lsort [array names fullMapArray]] {
            scan $txMap "%d,%d,%d" tx_c tx_l tx_p
    
            set fResultArray($trial,$fs,$iteration,$txMap,txNumFrames) $txActualFrames($txMap)            
    
            set txFrames $txActualFrames($txMap) 
    
            set txPacketGroupId $portPgId($txMap) 
            set rxFrames 0
            set numRxPorts [llength  $fullMapArray($txMap)]
    
            set fResultArray($trial,$fs,$iteration,$txMap,txThroughput)  [mpexpr round($txFrames/$durationArray($tx_c,$tx_l,$tx_p))]
            set fResultArray($trial,$fs,$iteration,$txMap,txTputPercent) [calculatePercentThroughput [mpexpr {$fResultArray($trial,$fs,$iteration,$txMap,txThroughput)/$numRxPorts}] $maxFrameRateArray($tx_c,$tx_l,$tx_p)]
    
            foreach rxMap $fullMapArray($txMap) {            
                scan $rxMap "%d %d %d" rx_c rx_l rx_p                
                if {[lsearch [array names one2manyArray] $txMap] != -1} {
                    set rxGrpNumFrames $rxNumFrames($rx_c,$rx_l,$rx_p)  
                } else {
                    set rxGrpNumFrames $fResultArray($trial,$fs,$iteration,[join $rxMap ,],$txPacketGroupId,rxNumFrames)
                }
                set rxFrames [mpexpr {$rxGrpNumFrames + $rxFrames}]
    
                set fResultArray($trial,$fs,$iteration,[join $rxMap ,],$txPacketGroupId,txThroughput)  [mpexpr ($fResultArray($trial,$fs,$iteration,$txMap,txThroughput)/$numRxPorts)]           
                set fResultArray($trial,$fs,$iteration,[join $rxMap ,],$txPacketGroupId,txTputPercent) [mpexpr ($fResultArray($trial,$fs,$iteration,$txMap,txTputPercent)/$numRxPorts)]          
                set fResultArray($trial,$fs,$iteration,[join $rxMap ,],$txPacketGroupId,txNumFrames)  [mpexpr ($fResultArray($trial,$fs,$iteration,$txMap,txNumFrames)/$numRxPorts)]           
                
            }
            set fResultArray($trial,$fs,$iteration,$txMap,framesReceivedPerTx) $rxFrames      
            set fResultArray($trial,$fs,$iteration,$txMap,Throughput)       [mpexpr round($rxFrames/$durationArray($tx_c,$tx_l,$tx_p))]
            set fResultArray($trial,$fs,$iteration,$txMap,TputPercent)      [calculatePercentThroughput $fResultArray($trial,$fs,$iteration,$txMap,Throughput) $maxFrameRateArray($tx_c,$tx_l,$tx_p)]
            set fResultArray($trial,$fs,$iteration,$txMap,frameLoss)        [mpexpr {$txFrames-$rxFrames}]
            set fResultArray($trial,$fs,$iteration,$txMap,frameLossPercent) [mpexpr {($txFrames-$rxFrames)*100.0/$txFrames}]
    }
  
    if {$calculateDataIntegrity} {
       foreach rxPort $rxPortList  {        
            scan $rxPort "%d %d %d" rx_c rx_l rx_p                
            stat get allStats $rx_c $rx_l $rx_p
            set fResultArray($trial,$fs,$iteration,$rx_c,$rx_l,$rx_p,dataIntegrityFrames) [stat cget -dataIntegrityFrames]
            set fResultArray($trial,$fs,$iteration,$rx_c,$rx_l,$rx_p,dataIntegrityErrors) [stat cget -dataIntegrityErrors]    
        }
    }

    return $status     
}




#****************************************************************************************************
#****************************************************************************************************
#****************************************************************************************************
#****************************************************************************************************
#****************************************************************************************************
#****************************************************************************************************
#****************************************************************************************************
#****************************************************************************************************
#****************************************************************************************************
#****************************************************************************************************
#****************************************************************************************************
#****************************************************************************************************
#****************************************************************************************************
#****************************************************************************************************
#****************************************************************************************************
#****************************************************************************************************

# GLOBALS PROC
# Only for Developement 

global scriptmateDebug
set scriptmateDebug(debugLevel) 0

##################################################
#
#
# 
#
#
##################################################

proc traceProc {varName index operation} {
    upvar $varName var
    set lvl [info level]
    incr lvl -1;
    puts "Variable $varName is being modified in: [info level $lvl]"
    if {$lvl > 1} {
        incr lvl -1;
        puts "Which was invoked from: [info level $lvl]"
    }
    puts "The current value of $varName is: $var\n"
}




########################################################################################
# Procedure: doBinarySearchBackToBack
# Input: - testCmd  
#        - TxRxArray   - map array 
#        - UserRate    - frame rate in FPS for each port
#        - TxNumFrames - number of frames to sent for each Tx
#        - B2bResult   - number of frames sent on tx which pass the DUT in tolerance
#        - FResultArray  - result Array
#
# Output: TCL_OK on succes, TCL_ERROR on fail
#
# Do the binary search as in RFC 2544/BackToBack keeping the same speed and modifying 
#     the number of frames sent 
#
#
# Used by bbBackToBack test
#
##########################################################################################

proc doBinarySearchBackToBack {TxRxArray FullMapArray TxNumFrames UserRate B2bResult FResultArray trial {testCmd bbBackToBack}} \
{
    upvar $TxRxArray     txRxArray
    upvar $FullMapArray  fullMapArray
    upvar $TxNumFrames   txNumFrames
    upvar $UserRate      userRate    
    upvar $B2bResult     b2bResult
    upvar $FResultArray  fResultArray

    global testConf
    set directions $testConf(mapDirection)

    set framesizeWan       [set ${testCmd}::framesizeWan]
    set framesizeBroadBand [set ${testCmd}::framesizeBroadBand] 
    
    set txPortList [getTxPorts txRxArray]
    set bestIteration   0

    set retCode $::TCL_OK

    switch  $directions {
        bidirectional {
            set fs "$framesizeWan-$framesizeBroadBand"    
        }
        downstream {
            set fs "$framesizeWan"    
        }
        upstream {
            set fs "$framesizeBroadBand"    
        }
    }

    if [info exists b2bResult] {
        unset b2bResult
    }

    if {[catch {$testCmd cget -tolerance} tolerance]} {
        set tolerance   0
    }

    # initialize the vars
    set lossPercent 0
    set doneList {}

    foreach txMap $txPortList {
        scan $txMap "%d %d %d" tx_c tx_l tx_p
    
        set b2bResult($tx_c,$tx_l,$tx_p)    0
        set numRxPorts [llength $txRxArray($tx_c,$tx_l,$tx_p)]
    
        # set the high and low indices for binary search algorithm
        set best($tx_c,$tx_l,$tx_p) 0    ;# best rate so far
        set high($tx_c,$tx_l,$tx_p) $txNumFrames($tx_c,$tx_l,$tx_p)
        set low($tx_c,$tx_l,$tx_p)  $lossPercent
        set doneList [lappend doneList [list $tx_c $tx_l $tx_p]]
        set oldTxNumFrames($tx_c,$tx_l,$tx_p) $txNumFrames($tx_c,$tx_l,$tx_p)         
        set fResultArray($trial,$fs,1,$tx_c,$tx_l,$tx_p,duration)   [mpexpr {$txNumFrames($tx_c,$tx_l,$tx_p) / ($userRate($tx_c,$tx_l,$tx_p) * $numRxPorts)}]
    }

    set duration  [$testCmd cget -duration]

    # start binary search
    set iteration 1
    while {[llength $doneList] > 0} {
    
        logMsg "\n---> ITERATION $iteration, [$testCmd cget -testName]" 

        # learn if it needs
        if {[broadbandLearn "onIteration" bbBackToBack]} {
            errorMsg "Error sending learn frames"
            return $::TCL_ERROR
        }
    
        #set enable802dot1qTag   [protocol cget -enable802dot1qTag]    
    
        if [clearStatsAndTransmit fullMapArray $duration [$testCmd cget -staggeredStart]] {
            return $::TCL_ERROR
        }
    
        waitForResidualFrames [$testCmd cget -waitResidual]
    
        # Poll the Tx counters until all frames are sent
        stats::collectTxStats [getTxPorts fullMapArray] txNumFrames txActualFrames totalTxNumFrames
        collectRxStats [getRxPorts fullMapArray]  rxNumFrames totalRxNumFrames 

        array set tempRxNumFrames [array get rxNumFrames]

        # compute and store the iteration values 
        ${testCmd}::ComputeBinaryIterationResults  txActualFrames $totalTxNumFrames tempRxNumFrames $totalRxNumFrames percentMaxRate $iteration sentFrames receivedFrames

        # print the iteration values
        ShowIterationResults $testCmd fResultArray 0 $iteration

        # loop for withdrawing the succeding/failed ports 
        foreach txMap $txPortList {
            scan $txMap "%d %d %d" tx_c tx_l tx_p

            set oldTxNumFrames($tx_c,$tx_l,$tx_p) $txNumFrames($tx_c,$tx_l,$tx_p) 
            set percentLoss [calculatePercentLossExact $sentFrames($tx_c,$tx_l,$tx_p) $receivedFrames($tx_c,$tx_l,$tx_p)]

#logMsg "percentLoss=$percentLoss receivedFrames($tx_c,$tx_l,$tx_p)=$receivedFrames($tx_c,$tx_l,$tx_p) sentFrames($tx_c,$tx_l,$tx_p)=$sentFrames($tx_c,$tx_l,$tx_p) best($tx_c,$tx_l,$tx_p)=$best($tx_c,$tx_l,$tx_p) high($tx_c,$tx_l,$tx_p)=$high($tx_c,$tx_l,$tx_p) low($tx_c,$tx_l,$tx_p)=$low($tx_c,$tx_l,$tx_p)"

            # if no frames received, there must be a connection error... dump out
            if {$receivedFrames($tx_c,$tx_l,$tx_p) == 0} {
                set b2bResult($tx_c,$tx_l,$tx_p)    0
                set indx [lsearch $doneList [list $tx_c $tx_l $tx_p]]
                if {$indx != -1} {
                  set doneList [lreplace $doneList $indx $indx]
                }
                set bestIteration $iteration 
                continue
            }
    
            # get the b2bResult            
            # first, if it's what we're looking for, we're done so don't bother going any farther
            if {$receivedFrames($tx_c,$tx_l,$tx_p) == $high($tx_c,$tx_l,$tx_p)} {
                # port is done
                set b2bResult($tx_c,$tx_l,$tx_p)    $receivedFrames($tx_c,$tx_l,$tx_p)
                set indx [lsearch $doneList [list $tx_c $tx_l $tx_p]]
                if {$indx != -1} {
                  set doneList [lreplace $doneList $indx $indx]
                }    
                set bestIteration $iteration 
                continue
            }

            # if there is a frame loss within tolerance, we're done
            if {($receivedFrames($tx_c,$tx_l,$tx_p) < $sentFrames($tx_c,$tx_l,$tx_p)) && ($percentLoss < $tolerance)} {                    
                set b2bResult($tx_c,$tx_l,$tx_p) $receivedFrames($tx_c,$tx_l,$tx_p)
                set indx [lsearch $doneList [list $tx_c $tx_l $tx_p]]
                if {$indx != -1} {
                     set doneList [lreplace $doneList $indx $indx]
                }
                set bestIteration $iteration 
                continue
            }
    
            if {$receivedFrames($tx_c,$tx_l,$tx_p) < $sentFrames($tx_c,$tx_l,$tx_p) } {
                if {$best($tx_c,$tx_l,$tx_p) >= $sentFrames($tx_c,$tx_l,$tx_p) } {
                    # port is done
                    set b2bResult($tx_c,$tx_l,$tx_p) $best($tx_c,$tx_l,$tx_p)
                    set indx [lsearch $doneList [list $tx_c $tx_l $tx_p]]
                    if {$indx != -1} {
                        set doneList [lreplace $doneList $indx $indx]
                    }
                     set bestIteration $iteration 
                } else {
                    set high($tx_c,$tx_l,$tx_p)     $sentFrames($tx_c,$tx_l,$tx_p)
                    set txNumFrames($tx_c,$tx_l,$tx_p)  [mpexpr ($high($tx_c,$tx_l,$tx_p) + $low($tx_c,$tx_l,$tx_p))/2]
                }
            } else {
                if {$receivedFrames($tx_c,$tx_l,$tx_p) > $best($tx_c,$tx_l,$tx_p)} {
                    set best($tx_c,$tx_l,$tx_p)     $receivedFrames($tx_c,$tx_l,$tx_p)
                    set low($tx_c,$tx_l,$tx_p)      $sentFrames($tx_c,$tx_l,$tx_p)
                    set txNumFrames($tx_c,$tx_l,$tx_p)  [mpexpr ($high($tx_c,$tx_l,$tx_p) + $low($tx_c,$tx_l,$tx_p))/2]
                } else {                  
                # port is done
                    set bestIteration $iteration 
                    set b2bResult($tx_c,$tx_l,$tx_p)    $receivedFrames($tx_c,$tx_l,$tx_p)
                    set indx [lsearch $doneList [list $tx_c $tx_l $tx_p]]
                    if {$indx != -1} {
                        set doneList [lreplace $doneList $indx $indx]
                    }
                }
            }
        
   #     csvUtils::writeIterationCSVFile $testCmd [list $iteration\
   #                            [getPortString $tx_c $tx_l $tx_p]\
   #                            $sentFrames($tx_c,$tx_l,$tx_p) \
   #                            $receivedFrames($tx_c,$tx_l,$tx_p)]
        }

        if {[llength $doneList] > 0} {
            foreach txMap [array names txRxArray] {
                scan $txMap "%d,%d,%d" tx_c tx_l tx_p

                # compute the rate from the old and new number of frames and use it for each stream
                set rateNumFrames   [mpexpr {$txNumFrames($tx_c,$tx_l,$tx_p)*1.0/$oldTxNumFrames($tx_c,$tx_l,$tx_p)}]

                set txNumFrames($tx_c,$tx_l,$tx_p)  0
                set numStreams [llength $txRxArray($tx_c,$tx_l,$tx_p)]
                for {set streamId 1} {$streamId <= $numStreams} {incr streamId} {                
                    if [streamUtils::streamGet $tx_c $tx_l $tx_p $streamId] {
                        errorMsg "Error getting stream [getPortId $tx_c $tx_l $tx_p] $streamId."
                        set retCode $::TCL_ERROR
                    }

                    # the new numFrame value
                    set numFrames [mpexpr [stream cget -numFrames]*[stream cget -loopCount]*$rateNumFrames]
                    set loopcount 1
                   # adjustStreamNumFramesAndLoopCount numFrames loopcount

                    set numFrames [mpexpr {round($numFrames)}]
                    
                    # update the txNumFrames array with adjusted numFrames and loopcount variables
                    set txNumFrames($tx_c,$tx_l,$tx_p) [mpexpr {($numFrames * $loopcount) + $txNumFrames($tx_c,$tx_l,$tx_p)}]
                    # set the number of frames to transmit
                    if {$loopcount == 1} {
                 #       stream config -dma stopStream
                    } else  {
                #       stream config -dma firstLoopCount
                    }
    
                    stream config -numFrames    $numFrames
                    stream config -loopCount    $loopcount

#puts   "$tx_c $tx_l $tx_p $streamId $numFrames * $loopcount = txNumFrames($tx_c,$tx_l,$tx_p)"

                    if [streamUtils::streamSet $tx_c $tx_l $tx_p $streamId] {
                        errorMsg "Error setting stream [getPortId $tx_c $tx_l $tx_p] $streamId."
                        set retCode $::TCL_ERROR
                    }

                    set numRxPorts [llength $txRxArray($tx_c,$tx_l,$tx_p)]
                    set duration [expr {round([calculateDuration $txNumFrames($tx_c,$tx_l,$tx_p) $userRate($tx_c,$tx_l,$tx_p)])}]
                    set fResultArray($trial,$fs,1,$tx_c,$tx_l,$tx_p,duration)   [mpexpr {$txNumFrames($tx_c,$tx_l,$tx_p) / ($userRate($tx_c,$tx_l,$tx_p) * $numRxPorts)}]                    

                }
            }
            if {$retCode == $::TCL_OK} {
                writeConfigToHardware txPortList
            }
        }
        
#        protocol config -enable802dot1qTag $enable802dot1qTag  
        incr iteration
    }

   
    set totalb2bFrames  0

    foreach txMap [array names txRxArray] {
        mpincr totalb2bFrames $b2bResult($txMap)
    }

    
#puts "bestiteration - $bestIteration"
    set fResultArray($trial,$fs,bestIteration) $bestIteration

    return $retCode
    
}



########################################################################################
# Procedure: ShowIterationResults
# Input: - testCmd  
#        - FResultArray
#        - showThroughput (Default 1) - print the TxTput (fps) and (%). 0 - for back To Back
#        - iteration (Default: trial}
#
# Output: TCL_OK on succes, TCL_ERROR on fail
#
# Do: Print the iterations values for standard frames (not Imix) linear and binary search
#
#
# Used by bbThroughput and bbBackToBack
#
##########################################################################################

proc ShowIterationResults {testCmd FResultArray {showThroughput 1} {iteration trial}} {
    upvar $FResultArray  fResultArray  
    global   one2manyArray

    set framesizeWan        [set ${testCmd}::framesizeWan]
    set framesizeBroadBand  [set ${testCmd}::framesizeBroadBand]
    set directions          [set ${testCmd}::directions]
    set trial               [set ${testCmd}::trial ]
    array set s_many2oneArray [array get ${testCmd}::s_many2oneArray]
    array set portPgId        [array get ${testCmd}::portPgId]

    debugPuts "Start ShowIterationResults"
    set status $::TCL_OK;            


    if {[catch {[$testCmd cget -calculateJitter]} calculateJitter]} {
        set calculateJitter no
    }

    if {[catch {[$testCmd cget -calculateLatency]} calculateLatency]} {
        set calculateLatency no
    }

    if {[catch {[$testCmd cget -searchType]} searchType]} {
        set searchType binary
    }

    if {[catch {[$testCmd cget -linearSearch]} linearSearch]} {
        set linearSearch no
    }

    if {[catch {[$testCmd cget -imixMode]} imixMode]} {
        set imixMode no
    }

    set calculateJitter  [expr {![string compare $calculateJitter yes]}]     
    set calculateLatency [expr {![string compare $calculateLatency yes] }]
    set searchType       [expr {![string compare $searchType  "linear"] }]
    set imixMode         [expr {![string compare $imixMode yes] }]


    if {$imixMode} {
        return $status

    } else {

        set tableHeaderDown [format "%10s %14s %10s %10s" "WAN Port" "BroadBand Port" "TxFrames" "RxFrames"]

        set tableHeaderUp [format "%14s %10s %10s %10s"   "BroadBand Port" "WAN Port" "TxFrames" "RxFrames"]

        if {$showThroughput} {
           set tableHeaderUp   [format "%s %14s %10s %10s %10s" $tableHeaderUp   "TxTput(fps)" "%TxTput" "Loss(frames)" "Loss(%)"]
           set tableHeaderDown [format "%s %14s %10s %10s %10s" $tableHeaderDown "TxTput(fps)" "%TxTput" "Loss(frames)" "Loss(%)"]
        } else {
           set tableHeaderDown [format "%s %10s %10s" $tableHeaderDown "Loss(frames)" "Loss(%)"]
           set tableHeaderUp   [format "%s %10s %10s" $tableHeaderUp   "Loss(frames)" "Loss(%)"]
        }

        if { $calculateJitter } { 
            set tableHeaderUp   [format "%s %10s %10s %10s" $tableHeaderUp   "MinInterArrival(ns)" "MaxInterArrival(ns)" "AvgInterArrival(ns)"]
            set tableHeaderDown [format "%s %10s %10s %10s" $tableHeaderDown "MinInterArrival(ns)" "MaxInterArrival(ns)" "AvgInterArrival(ns)"]
        } elseif {$calculateLatency} { 
            set tableHeaderUp   [format "%s %10s %10s %10s" $tableHeaderUp   "MinLatency(ns)" "MaxLatency(ns)" "AvgLatency(ns)"]
            set tableHeaderDown [format "%s %10s %10s %10s" $tableHeaderDown "MinLatency(ns)" "MaxLatency(ns)" "AvgLatency(ns)"]
        }


        #NOT IMIX MODE 
        if {$linearSearch} {

            # Linear SEARCH, Standard Framesizes

              set separator {}

              for {set i 0} {$i<[string length $tableHeaderDown]} {incr i} {
                    append separator "*"
              }

              switch  $directions {
                bidirectional {
                    set fs "$framesizeWan-$framesizeBroadBand"
                }
                downstream {
                    set fs "$framesizeWan"
                }
                upstream {
                    set fs "$framesizeBroadBand"
                }
              }
                  
              set fResultArray($trial,$fs,numIterations) $iteration

              set rateSelect [$testCmd cget -rateSelect]
              set rateType [lindex [split $rateSelect R] 0]

              if {($directions=="bidirectional") || ($directions=="downstream") } {
              
                  logMsg "\nDownstream"
                  logMsg $tableHeaderDown
                  logMsg $separator

                   #calculating values for WAN 
                  set totalTxFrames 0
                  set totalRxFrames 0
                  foreach txMap [lsort [array names one2manyArray]] {
                        scan $txMap "%d,%d,%d" tx_c tx_l tx_p                                                                                   

                        set txPacketGroupId $portPgId($txMap)                                
                        set first 1

                        foreach rxMap $one2manyArray($txMap) {          
                            scan $rxMap "%d %d %d" rx_c rx_l rx_p
                            set line {}                                                  
                            if {$first} {
                                append line [format "%10s" [join [split $txMap ,] .]]                            
                            } else {
                                append line [format "%10s" -]   
                            }
                            append line [format "%14s" [join $rxMap .]]

                            if {$first} {
                                append line [format "%12s" $fResultArray($trial,$fs,$iteration,$txMap,txNumFrames)]                                
                            } else {
                                append line [format "%12s" -]
                            }

                            append line [format "%12s" $fResultArray($trial,$fs,$iteration,[join $rxMap ,],$txPacketGroupId,rxNumFrames)]

                            set txFrames $fResultArray($trial,$fs,$iteration,[join $rxMap ,],$txPacketGroupId,txNumFrames)
                            set rxFrames $fResultArray($trial,$fs,$iteration,[join $rxMap ,],$txPacketGroupId,rxNumFrames)
                            set frameLoss [mpexpr {$txFrames-$rxFrames}]
                            set frameLossPct [mpexpr {($txFrames-$rxFrames)*100.0/$txFrames}]

                            if {$showThroughput} {
                                if {$first} {
                                    append line [format "%12s" $fResultArray($trial,$fs,$iteration,$txMap,txThroughput)]
                                    append line [format "%12s" $fResultArray($trial,$fs,$iteration,$txMap,txTputPercent)]
                                    set first   0
                                } else {
                                    append line [format "%12s" -]
                                    append line [format "%12s" -]
                                }
                            }
                            append line [format "%12s %10.2f" $frameLoss $frameLossPct]

                            if { $calculateJitter || $calculateLatency } {                
                                append line [format "%12s" $fResultArray($trial,$fs,$iteration,[join $rxMap ,],$txPacketGroupId,minLatency)]
                                append line [format "%12s" $fResultArray($trial,$fs,$iteration,[join $rxMap ,],$txPacketGroupId,maxLatency)]
                                append line [format "%12s" $fResultArray($trial,$fs,$iteration,[join $rxMap ,],$txPacketGroupId,avgLatency)]
                            }
                            logMsg $line                            
                        }
                        incr  totalTxFrames $fResultArray($trial,$fs,$iteration,$txMap,txNumFrames)   
                        incr  totalRxFrames $fResultArray($trial,$fs,$iteration,$txMap,framesReceivedPerTx)

                  }
                  logMsg $separator

                  set line [format "%14s = %d" "[string toupper [string range $rateSelect 0 0]][string range $rateSelect 1 end]" [$testCmd cget -${rateType}WanRate] ]                  
                  logMsg $line
                  set line [format "TotalTxFrames  = %d" $totalTxFrames]
                  logMsg $line
                  set line [format "TotalRxFrames  = %d" $totalRxFrames]
                  logMsg $line                  
                  set line "TotalLoss(%)   = [calculatePercentLoss $totalTxFrames $totalRxFrames]"
                  logMsg $line
              }

              if {($directions=="bidirectional") || ($directions=="upstream") } {
                 #print BroadBand
                  logMsg "\nUpstream"
                  
                  set totalTxFrames 0
                  set totalRxFrames 0                
                  
                  logMsg $tableHeaderUp
                  logMsg $separator

                  foreach txMap [lsort [array names s_many2oneArray]] {
                        scan $txMap "%d,%d,%d" tx_c tx_l tx_p  

                        set txPacketGroupId $portPgId($txMap)                                
                        set first 1

                        foreach rxMap $s_many2oneArray($txMap) {          
                            scan $rxMap "%d %d %d" rx_c rx_l rx_p

                            set line {}                                                  
                            if {$first} {
                                append line [format "%10s" [join [split $txMap ,] .]]                            
                            } else {
                                append line [format "%10s" -]   
                            }
                            append line [format "%14s" [join $rxMap .]]

                            if {$first} {
                                append line [format "%12s" $fResultArray($trial,$fs,$iteration,$txMap,txNumFrames)]                                
                            } else {
                                append line [format "%12s" -]
                            }

                            append line [format "%12s" $fResultArray($trial,$fs,$iteration,[join $rxMap ,],$txPacketGroupId,rxNumFrames)]

                            set txFrames $fResultArray($trial,$fs,$iteration,[join $rxMap ,],$txPacketGroupId,txNumFrames)
                            set rxFrames $fResultArray($trial,$fs,$iteration,[join $rxMap ,],$txPacketGroupId,rxNumFrames)
                            set frameLoss [mpexpr {$txFrames-$rxFrames}]
                            set frameLossPct [mpexpr {($txFrames-$rxFrames)*100.0/$txFrames}]

                            if {$showThroughput} {
                                if {$first} {
                                    append line [format "%12s" $fResultArray($trial,$fs,$iteration,$txMap,txThroughput)]
                                    append line [format "%12s" $fResultArray($trial,$fs,$iteration,$txMap,txTputPercent)]
                                    set first   0
                                } else {
                                    append line [format "%12s" -]
                                    append line [format "%12s" -]
                                }
                            }
                            append line [format "%12s %10.2f" $frameLoss $frameLossPct]

                            if { $calculateJitter || $calculateLatency } { 
                                append line [format "%12s" $fResultArray($trial,$fs,$iteration,[join $rxMap ,],$txPacketGroupId,minLatency)]
                                append line [format "%12s" $fResultArray($trial,$fs,$iteration,[join $rxMap ,],$txPacketGroupId,maxLatency)]
                                append line [format "%12s" $fResultArray($trial,$fs,$iteration,[join $rxMap ,],$txPacketGroupId,avgLatency)]
                            }
                            logMsg $line                            
                        }
                        incr  totalTxFrames $fResultArray($trial,$fs,$iteration,$txMap,txNumFrames)   
                        incr  totalRxFrames $fResultArray($trial,$fs,$iteration,$txMap,framesReceivedPerTx)
                  }
                  logMsg $separator                    

                  set rateSelect [$testCmd cget -rateSelect]
                  set line [format "%14s = %d" "[string toupper [string range $rateSelect 0 0]][string range $rateSelect 1 end]" [$testCmd cget -${rateType}BroadBandRate] ]                  
                  logMsg $line
                  set line [format "TotalTxFrames  = %d" $totalTxFrames]
                  logMsg $line
                  set line [format "TotalRxFrames  = %d" $totalRxFrames]
                  logMsg $line                  
                  set line "TotalLoss(%)   = [calculatePercentLoss $totalTxFrames $totalRxFrames]"
                  logMsg $line

                  logMsg "\n"
              }
          
        } else {
# BINARY SEARCH

            logMsg "\nConfigured Transmit Rates used for iteration $iteration"
            logMsg "* Note: DUT Flow Control or Collisions may cause actual TX rate to be lower than Offered Rate"

              set separator {}

              for {set i 0} {$i<[string length $tableHeaderDown]} {incr i} {
                    append separator "*"
              }

              switch  $directions {
                bidirectional {
                    set fs "$framesizeWan-$framesizeBroadBand"    
                }  
                downstream {
                    set fs "$framesizeWan"
                }
                upstream {
                    set fs "$framesizeBroadBand"
                }
              }

              set fResultArray($trial,$fs,numIterations) $iteration                  

              set rateSelect [$testCmd cget -rateSelect]
              set rateType [lindex [split $rateSelect R] 0]

              if {$directions=="downstream" || $directions=="bidirectional"} {
              
                  logMsg "\nDownstream"
                  logMsg $tableHeaderDown
                  logMsg $separator

                   #calculating values for WAN 
                  set totalTxFrames 0
                  set totalRxFrames 0
                  foreach txMap [lsort [array names one2manyArray]] {
                        scan $txMap "%d,%d,%d" tx_c tx_l tx_p                                                                                   

                        set txPacketGroupId $portPgId($txMap)                                
                        set firstItem 1

                        foreach rxMap $one2manyArray($txMap) {          
                            scan $rxMap "%d %d %d" rx_c rx_l rx_p
                            set line {}                                                  
                            if {$firstItem} {
                                append line [format "%10s" [join [split $txMap ,] .]]                            
                            } else {
                                append line [format "%10s" -]   
                            }
                            append line [format "%14s" [join $rxMap .]]

                            if {$firstItem} {
                                append line [format "%12s" $fResultArray($trial,$fs,$iteration,$txMap,txNumFrames)]                                
                            } else {
                                append line [format "%12s" -]
                            }

                            append line [format "%12s" $fResultArray($trial,$fs,$iteration,[join $rxMap ,],$txPacketGroupId,rxNumFrames)]

                            set txFrames $fResultArray($trial,$fs,$iteration,[join $rxMap ,],$txPacketGroupId,txNumFrames)
                            set rxFrames $fResultArray($trial,$fs,$iteration,[join $rxMap ,],$txPacketGroupId,rxNumFrames)
                            set frameLoss [mpexpr {$txFrames-$rxFrames}]
                            set frameLossPct [mpexpr {($txFrames-$rxFrames)*100.0/$txFrames}]                           

                            if {$showThroughput} {
                                if {$firstItem} {
                                    append line [format "%12s" $fResultArray($trial,$fs,$iteration,$txMap,txThroughput)]
                                    append line [format "%12s" $fResultArray($trial,$fs,$iteration,$txMap,txTputPercent)]                            
                                } else {
                                    append line [format "%12s" -]
                                    append line [format "%12s" -]
                                }
                            }

                            if {$firstItem} {
                                set firstItem   0
                            }

                            append line [format "%12s %10.2f" $frameLoss $frameLossPct]

                            if { $calculateJitter || $calculateLatency } {                
                                append line [format "%12s" $fResultArray($trial,$fs,$iteration,[join $rxMap ,],$txPacketGroupId,minLatency)]
                                append line [format "%12s" $fResultArray($trial,$fs,$iteration,[join $rxMap ,],$txPacketGroupId,maxLatency)]
                                append line [format "%12s" $fResultArray($trial,$fs,$iteration,[join $rxMap ,],$txPacketGroupId,avgLatency)]
                            }
                            logMsg $line                            
                        }
                        incr  totalTxFrames $fResultArray($trial,$fs,$iteration,$txMap,txNumFrames)   
                        incr  totalRxFrames $fResultArray($trial,$fs,$iteration,$txMap,framesReceivedPerTx)

                  }
                  logMsg $separator

                  set line [format "TotalTxFrames  = %d" $totalTxFrames]
                  logMsg $line
                  set line [format "TotalRxFrames  = %d" $totalRxFrames]
                  logMsg $line                  
                  set line "TotalLoss(%)   = [calculatePercentLoss $totalTxFrames $totalRxFrames]"
                  logMsg $line
              }

              if { $directions=="upstream" || $directions=="bidirectional" } {
                 #print BroadBand
                  logMsg "\nUpstream"
                  
                  set totalTxFrames 0
                  set totalRxFrames 0                
                  
                  logMsg $tableHeaderUp
                  logMsg $separator

                  foreach txMap [lsort [array names s_many2oneArray]] {
                        scan $txMap "%d,%d,%d" tx_c tx_l tx_p  

                        set txPacketGroupId $portPgId($txMap)                                
                        set first 1

                        foreach rxMap $s_many2oneArray($txMap) {          
                            scan $rxMap "%d %d %d" rx_c rx_l rx_p

                            set line {}                                                  
                            if {$first} {
                                append line [format "%10s" [join [split $txMap ,] .]]                            
                            } else {
                                append line [format "%10s" -]   
                            }
                            append line [format "%14s" [join $rxMap .]]

                            if {$first} {
                                append line [format "%12s" $fResultArray($trial,$fs,$iteration,$txMap,txNumFrames)]                                
                            } else {
                                append line [format "%12s" -]
                            }

                            append line [format "%12s" $fResultArray($trial,$fs,$iteration,[join $rxMap ,],$txPacketGroupId,rxNumFrames)]

                            set txFrames $fResultArray($trial,$fs,$iteration,[join $rxMap ,],$txPacketGroupId,txNumFrames)
                            set rxFrames $fResultArray($trial,$fs,$iteration,[join $rxMap ,],$txPacketGroupId,rxNumFrames)
                            set frameLoss [mpexpr {$txFrames-$rxFrames}]
                            set frameLossPct [mpexpr {($txFrames-$rxFrames)*100.0/$txFrames}]

                            if {$showThroughput} {
                                if {$first} {
                                    append line [format "%12s" $fResultArray($trial,$fs,$iteration,$txMap,txThroughput)]
                                    append line [format "%12s" $fResultArray($trial,$fs,$iteration,$txMap,txTputPercent)]
                                    set first   0
                                } else {
                                    append line [format "%12s" -]
                                    append line [format "%12s" -]
                                }
                            }

                            append line [format "%12s %10.2f" $frameLoss $frameLossPct]

                            if { $calculateJitter || $calculateLatency } { 
                                append line [format "%12s" $fResultArray($trial,$fs,$iteration,[join $rxMap ,],$txPacketGroupId,minLatency)]
                                append line [format "%12s" $fResultArray($trial,$fs,$iteration,[join $rxMap ,],$txPacketGroupId,maxLatency)]
                                append line [format "%12s" $fResultArray($trial,$fs,$iteration,[join $rxMap ,],$txPacketGroupId,avgLatency)]
                            }
                            logMsg $line                            
                        }
                        incr  totalTxFrames $fResultArray($trial,$fs,$iteration,$txMap,txNumFrames)   
                        incr  totalRxFrames $fResultArray($trial,$fs,$iteration,$txMap,framesReceivedPerTx)
                  }
                  logMsg $separator                    

                  set line [format "TotalTxFrames  = %d" $totalTxFrames]
                  logMsg $line
                  set line [format "TotalRxFrames  = %d" $totalRxFrames]
                  logMsg $line                  
                  set line "TotalLoss(%)   = [calculatePercentLoss $totalTxFrames $totalRxFrames]"
                  logMsg $line

                  logMsg "\n"
              }

        }
    }

    set status $::TCL_OK;    

    debugPuts "Leave ShowIterationResults"
    return $status;
}


proc bbBackToBack::GUIBidirectionalTrafficMap {{direction bidirectional}} { 
  global leftFrameName
  global invisibleBinarySearchFrameName
 
  if {$direction=="bidirectional"} {
      $invisibleBinarySearchFrameName.invisibleTestParms.binarySearchDirection.true  config -state normal
      $invisibleBinarySearchFrameName.invisibleTestParms.binarySearchDirection.false config -state normal
      $invisibleBinarySearchFrameName.invisibleTestParms.binarySearchDirection.true  config -bg gray83     
      $invisibleBinarySearchFrameName.invisibleTestParms.binarySearchDirection.false config -bg gray83       
      $leftFrameName.invisibleBinarySearch.label config -foreground black   
  } else {
      $invisibleBinarySearchFrameName.invisibleTestParms.binarySearchDirection.true  config -state disabled       
      $invisibleBinarySearchFrameName.invisibleTestParms.binarySearchDirection.false config -state disabled       
      $invisibleBinarySearchFrameName.invisibleTestParms.binarySearchDirection.true  config -bg gray      
      $invisibleBinarySearchFrameName.invisibleTestParms.binarySearchDirection.false config -bg gray       
      $leftFrameName.invisibleBinarySearch.label config -foreground gray40   
  }

}
