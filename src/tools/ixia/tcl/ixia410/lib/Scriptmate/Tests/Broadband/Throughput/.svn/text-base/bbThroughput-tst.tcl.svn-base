##################################################################################
# Copyright (c) Ixia 2004-2005
# All rights reserved
#
# DESCRIPTION:
# This test computes Real Time Latency at the point of No Drop Rate
# Throughput.
#
##################################################################################

namespace eval bbThroughput {
  variable att 10
}


#####################################################################
# bbThroughput::xmdDef
# 
# DESCRIPTION:
# This variable contains the XML content used by PDF Report generation.
#  
###
set bbThroughput::xmdDef  {
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
         <Source scope="results.csv" entity_name="bbThroughput" format_id=""/>
         <Source scope="info.csv" entity_name="bbThroughput_Info" format_id=""/>
         <Source scope="AggregateResults.csv" entity_name="bbThroughput_Aggregate" format_id=""/>
         <Source scope="Iteration.csv" entity_name="bbThroughput_Iteration" format_id=""/>
       </Sources>
     </XMD>
}

#####################################################################
# bbThroughput::statList
# 
# DESCRIPTION:
# This table contains a list of collected metrics to be displayed in
# the Real Time Graphs and written to RealTime.csv file.
#  
###
global one2oneArray
set bbThroughput::statList \
    [list [list framesSent  [getTxPorts one2oneArray] "Tx Frames per second" "Tx Frames" 1e0]\
     [list framesReceived [getRxPorts one2oneArray] "Rx Frames per second" "Rx Frames" 1e0]\
     [list bitsSent       [getTxPorts one2oneArray] "Tx Kbps"              "Tx Kb"     1e3]\
     [list bitsReceived   [getRxPorts one2oneArray] "Rx Kbps"              "Rx Kb"     1e3]\
    ];    


#####################################################################
# bbThroughput::iterationFileColumnHeader
# 
# DESCRIPTION:
# This table contains a list of column headers at the top of the
# iteration.csv file.
#  
###
set bbThroughput::iterationFileColumnHeader { 
    "Trial"
    "Frame Size"
    "Iteration"
    "Tx Port"
    "Rx Port"
    "Tx Tput (fps)"
    "Rate (%)"
    "Tx Count"
    "Rx Count"
    "Frame Loss"
    "Frame Loss %"
}


#####################################################################
# bbThroughput::attributes
# 
# DESCRIPTION:
# This attributes table contains a list of attributes used by the
# test algorithm or other backend test engine functions.  This
# table is used to initialize these attributes for later use.
#  
###
set bbThroughput::attributes {
    {
    { NAME              testName }
    { BACKEND_TYPE      string }
    { DEFAULT_VALUE     "Broadband Throughput" }
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
    { NAME              imixMode }
    { BACKEND_TYPE      boolean }
    { DEFAULT_VALUE     no }
    { VALID_VALUES      {yes no} }
    { VARIABLE_CLASS    testCmd }    
    }

    {
    { NAME              imixList }
    { BACKEND_TYPE      string }
    { DEFAULT_VALUE     { {{80     tcp           }         20} \
                  { 74                             20} \
                  {{570    telnet         }         20} \
                  {{128    ftp            }         20} \
                  {570                             20}} }     
    { VARIABLE_CLASS    testCmd }    
    }

    {
    { NAME              imixWanList }
    { BACKEND_TYPE      string }
    { DEFAULT_VALUE     { {{80     tcp           }         20} \
                  { 74                             20} \
                  {{570    telnet         }         20} \
                  {{128    ftp            }         20} \
                  {570                             20}} }     
    { VARIABLE_CLASS    testCmd }    
    }

    {
    { NAME              imixBroadBandList }
    { BACKEND_TYPE      string }
    { DEFAULT_VALUE     { {{80     tcp           }         20} \
                  { 74                             20} \
                  {{570    telnet         }         20} \
                  {{128    ftp            }         20} \
                  {570                             20}} }     
    { VARIABLE_CLASS    testCmd }    
    }

    {
    { NAME              protocolTable }
    { BACKEND_TYPE      string }
    { DEFAULT_VALUE    {  {telnet tcp 1056 23} {http tcp 1053 80} \
                  {test1 egp 1057 24}  {dns udp 1055 22} \
                  {test2 icmp 1058 25} {ftp tcp 1054 21} \
                  {tcp tcp 0 0} } }
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
    { DEFAULT_VALUE     no }
    { VALID_VALUES      {yes no} }
    { LABEL             "Measure Data Integrity" }
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
    { NAME              searchType }
    { BACKEND_TYPE      string }
    { DEFAULT_VALUE     binary }
    { VALID_VALUES      {linear binary} }
    { LABEL             "Search Types: " }
    { VARIABLE          searchType }    
    { ON_CHANGE         bbThroughput::SearchTypeSelected }
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
    { NAME              loadRateBroadBandWidget }        
    { BACKEND_TYPE      null }
    { VARIABLE_CLASS    null }
    }


    {
    { NAME              burstsize }
    { BACKEND_TYPE      int }
    { DEFAULT_VALUE     4 }
    { MIN               1 }
    { MAX               10 }
    { VARIABLE_CLASS    testCmd }    
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
    { NAME              fpsRate }
    { BACKEND_TYPE      double }
    { DEFAULT_VALUE     100 }
    { MIN               0 } 
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
    { NAME              fpsWanRate }
    { BACKEND_TYPE      double }
    { DEFAULT_VALUE     100 }
    { MIN               0 } 
    { MAX               100 }
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
    { NAME              numIterations }
    { BACKEND_TYPE      integer }
    { DEFAULT_VALUE     1 }
    { MIN               1 }     
    { LABEL             "No Iterations: " }
    { VARIABLE_CLASS    testCmd }
    }

    
    {
    { NAME              linearBinarySearch }
    { BACKEND_TYPE      boolean }
    { DEFAULT_VALUE     true }
    { VALID_VALUES      {true} }    
    { VARIABLE_CLASS    testCmd }
    { DESCRIPTION {
        "Select binary search type."
        "false = do per port binary search"
        "true = do linear binary search"
    } }
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
    { ON_CHANGE         bbThroughput::PassFailEnable }
    }

    {
    { NAME              thresholdMode }
    { BACKEND_TYPE      string }
    { DEFAULT_VALUE     line }
    { VALID_VALUES      {line data} }
    { VALUE_LABELS      {"% Line Rate >=" "  Data Rate >="} }
    { VARIABLE          passFailMode }
    { VARIABLE_CLASS    testConf }
    { ON_CHANGE         bbThroughput::ThroughputThresholdToggle }
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
    { VALID_VALUES      {average minimum} }
    { VALUE_LABELS      {"Average/Port" "Minimum Port"} }
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
    { VALID_VALUES      {average minimum} }
    { VALUE_LABELS      {"Average/Port" "Minimum Port"} }
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
    { NAME              jitterLabel }
    { BACKEND_TYPE      string }
    { LABEL             "Inter Arrival <=" }
    { VARIABLE          jitterThreshold }
    { VARIABLE_CLASS    null }
    }

    {
    { NAME              jitterValue }
    { BACKEND_TYPE      double }
    { DEFAULT_VALUE     1.0 }
    { MIN               0.0001 }
    { MAX               100000000 }
    { VARIABLE          passFailJitterValue }
    { VARIABLE_CLASS    testConf }
    }

    {
    { NAME              jitterThresholdScale }
    { BACKEND_TYPE      string }
    { DEFAULT_VALUE     us }
    { VALID_VALUES      {ns us ms} }
    { VARIABLE          passFailJitterUnit }
    { VARIABLE_CLASS    testConf }
    }

    {
    { NAME              jitterThresholdMode }
    { BACKEND_TYPE      string }
    { DEFAULT_VALUE     average }
    { VALID_VALUES      {average maximum} }
    { VALUE_LABELS      {"Average/Port" "Maximum Port"} }
    { VARIABLE          passFailJitterType }
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
    { NAME              userInfoWidget }        
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
    { DEFAULT_VALUE     bbThroughput.results }
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
    { VALID_VALUES      {oncePerTest oncePerFramesize\
                 onTrial never} }
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
    { NAME              enable802dot1qTag }
    { BACKEND_TYPE      boolean }
    { DEFAULT_VALUE     false }
    { VALID_VALUES      {true false} }
    { VARIABLE_CLASS    testConf }
    { DESCRIPTION {
        "Select the vlan type to use; currently this test does not support vlans"
    } }
    }

    {
    { NAME              enableISLtag }
    { BACKEND_TYPE      boolean }
    { DEFAULT_VALUE     false }
    { VALID_VALUES      {true false} }
    { VARIABLE_CLASS    testConf }
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
    { NAME              firstSrcIpV6Address }
    { BACKEND_TYPE      string }
    { DEFAULT_VALUE     2000:0:0:1::1:100 }
    { VARIABLE_CLASS    testConf }
    }

    {
    { NAME              firstDestDUTIpV6Address }
    { BACKEND_TYPE      string }
    { DEFAULT_VALUE     2000:0:0:1::1:1 }
    { VARIABLE_CLASS    testConf }
    }

    {
    { NAME              incrIpV6AddressField }
    { BACKEND_TYPE      string }
    { DEFAULT_VALUE     interfaceId }
    { VALID_VALUES      {interfaceId subnetId siteLevelAggregationId \
                 nextLevelAggregationId topLevelAggregationId } }
    { VARIABLE_CLASS    testConf }
    { DESCRIPTION {
        "interfaceId"
        "subnetId"
        "siteLevelAggregationId"
        "nextLevelAggregationId"
        "topLevelAggregationId"
    } }
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
    { DEFAULT_VALUE     bbThroughput }
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
    { DEFAULT_VALUE     bbThroughput.log }
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
    { NAME               supportImixFrameSize }
    { BACKEND_TYPE       integer }
    { DEFAULT_VALUE      1 }
    { VARIABLE_CLASS     supportImixFrameSize }
    }

    {
    { NAME               supportImixNDRFrameSize }
    { BACKEND_TYPE       integer }
    { DEFAULT_VALUE      1 }
    { VARIABLE_CLASS     supportImixNDRFrameSize }
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

    {
        { NAME              extendedDirections }
        { BACKEND_TYPE      integer }
        { DEFAULT_VALUE     1 }    
        { VARIABLE_CLASS    testConf }
        { DESCRIPTION {
            "Used for enable upstream/downstream" 
        } }
    }
}


proc bbThroughput::SearchTypeSelected {args} {
  global searchType rateSelect
  global invisibleBinarySearchFrameName
  global invisibleBinarySearch21FrameName
  global linearBinarySearchsFrameName
  global loadRateBroadBandWidgetFrameName


#  logMsg "GUIBidirectionalTrafficMap $direction $searchType"   

  set directionFrame .pane.rightPane.rightSide.executionWin.nbframe.testSetup.frame.trafficFrame.x.trafficMapWidget.border.frame.directionFrame

  if [catch {$directionFrame.bidir cget -value} direction] {
      set direction linear
  } 
  
  if {$searchType=="binary"} {
      $invisibleBinarySearchFrameName.numIterations config -state disabled
      $invisibleBinarySearchFrameName.numIterations.frame.entry config -bg gray65
      $invisibleBinarySearchFrameName.numIterations.label config -foreground gray40

      $invisibleBinarySearchFrameName.tolerance config -state normal 
      $invisibleBinarySearchFrameName.tolerance.frame.entry config -bg gray95
      $invisibleBinarySearchFrameName.tolerance.label config -foreground black

      if { $direction == "bidirectional" } {
         $invisibleBinarySearch21FrameName.binarySearchDirection.true  config -state normal
         $invisibleBinarySearch21FrameName.binarySearchDirection.false config -state normal
         $invisibleBinarySearch21FrameName.binarySearchDirection.true  config -bg gray83     
         $invisibleBinarySearch21FrameName.binarySearchDirection.false config -bg gray83       
         $linearBinarySearchsFrameName.invisibleBinarySearch21.label config -foreground black   
      }

      switch $rateSelect {
            "fpsRate" {
                $loadRateBroadBandWidgetFrameName.framesPerSecondIncr config -state disabled
                 $loadRateBroadBandWidgetFrameName.framesPerSecondIncr config -bg gray
            }
            "kbpsRate" {
                $loadRateBroadBandWidgetFrameName.kBitsPerSecondIncr  config -state disabled
                $loadRateBroadBandWidgetFrameName.kBitsPerSecondIncr  config -bg gray
            }
            "percentMaxRate" -
            default {
                $loadRateBroadBandWidgetFrameName.percentMaxRateIncr  config -state disabled
                $loadRateBroadBandWidgetFrameName.percentMaxRateIncr  config -bg gray
            }
      }

  } else {
      $invisibleBinarySearchFrameName.numIterations config -state normal
      $invisibleBinarySearchFrameName.numIterations.frame.entry config -bg gray95
      $invisibleBinarySearchFrameName.numIterations.label config -foreground black

      $invisibleBinarySearchFrameName.tolerance config -state disabled       
      $invisibleBinarySearchFrameName.tolerance.frame.entry config -bg gray65
      $invisibleBinarySearchFrameName.tolerance.label config -foreground gray40

      $invisibleBinarySearch21FrameName.binarySearchDirection.true  config -state disabled       
      $invisibleBinarySearch21FrameName.binarySearchDirection.false config -state disabled       
      $invisibleBinarySearch21FrameName.binarySearchDirection.true  config -bg gray      
      $invisibleBinarySearch21FrameName.binarySearchDirection.false config -bg gray       
      $linearBinarySearchsFrameName.invisibleBinarySearch21.label config -foreground gray40   

     $loadRateBroadBandWidgetFrameName.framesPerSecondIncr config -state normal
     $loadRateBroadBandWidgetFrameName.kBitsPerSecondIncr  config -state normal
     $loadRateBroadBandWidgetFrameName.percentMaxRateIncr  config -state normal

      switch $rateSelect {
            "fpsRate" {
                $loadRateBroadBandWidgetFrameName.framesPerSecondIncr config -state normal
                $loadRateBroadBandWidgetFrameName.framesPerSecondIncr config -bg gray95
            }
            "kbpsRate" {
                $loadRateBroadBandWidgetFrameName.kBitsPerSecondIncr  config -state normal
                $loadRateBroadBandWidgetFrameName.kBitsPerSecondIncr  config -bg gray95
            }
            "percentMaxRate" -
            default {
                $loadRateBroadBandWidgetFrameName.percentMaxRateIncr  config -state normal
                $loadRateBroadBandWidgetFrameName.percentMaxRateIncr  config -bg gray95 
            }
      }

  }

#work arround to show Traffic Setup Tab
   global executionWin
   global sizeFrame
   global testConf
   global invisibleLoadRateParamsFrameName

   if {![info exists testConf(testLoaded)]} {
       set testConf(testLoaded) 1
   } else {
       set testConf(testLoaded) 0
   }

   if {$testConf(testLoaded)} {
       $executionWin raise testSetup      
   }
   
  #linearBinarySearch

}

proc bbThroughput::FrameSizeChanged {value} {

    set testCmd [namespace current]
    switch $value {
        Standard -
        Automatic -
        Manual {
            $testCmd config -imixMode no           
        }
        Imix   {
            $testCmd config -imixMode yes        
        }
    }
    return 0
}


proc bbThroughput::JitterCheckBoxSelected {args} {
    global calcJitter 
    global passFailEnable
    global invisibleTestParmsFrameName

    if {$calcJitter == "yes"} {
        $invisibleTestParmsFrameName.calculateLatency config -state disabled
        $invisibleTestParmsFrameName.latencyTypes config -state disabled
    } else {
        $invisibleTestParmsFrameName.calculateLatency config -state normal
        $invisibleTestParmsFrameName.latencyTypes config -state normal
    }
    bbThroughput config -calculateJitter $calcJitter

    set state disabled

    if {$passFailEnable} {
        if {$calcJitter == "yes"} {
            set state enabled;
        }
    }

    set attributeList {
        jitterLabel 
        jitterValue 
        jitterThresholdScale 
        jitterThresholdMode
    }

    renderEngine::WidgetListStateSet $attributeList $state;
         #::PassFailThroughputFrameLatencyEnable    
}

proc bbThroughput::DataIntegrityCheckBoxSelected {args} {
    global calcDataIntegrity
    global passFailEnable
    global invisibleTestParmsFrameName
    
    bbThroughput config -calculateDataIntegrity $calcDataIntegrity
}

proc bbThroughput::LatencyCheckBoxSelected {args} {
    global calcLatency 
    global passFailEnable
    global invisibleTestParmsFrameName 

    if {$calcLatency == "yes"} {
        $invisibleTestParmsFrameName.calculateJitter config -state disabled        
    } else {
        $invisibleTestParmsFrameName.calculateJitter config -state normal        
    }

    bbThroughput config -calculateLatency $calcLatency  
    set state disabled;

    if {$passFailEnable} {
        if {$calcLatency == "yes"} {
            set state enabled;
        }
    }

    set attributeList {
        latencyLabel 
        latencyValue 
        latencyThresholdScale 
        latencyThresholdMode
    }

    renderEngine::WidgetListStateSet $attributeList $state;

    
}

########################################################################################
# bbThroughput::registerResultVars()
#
# DESCRIPTION: 
# This procedure registers all the local variables that are used in the
# display of the results with the Results Options Database.  
# This procedure must exist for each test.
#
###
proc bbThroughput::registerResultVars {} \
{
    # configuration information stored for results
    if [ results registerTestVars numTrials            numTrials      [bbThroughput cget -numtrials]      test ] { return 1 }

    # results obtained after each iteration
    if [ results registerTestVars throughput           thruputRate         0                                port TX ] { return 1 }
    if [ results registerTestVars percentTput          percentTput         0                                port TX ] { return 1 }
    if [ results registerTestVars avgLatency           avgLatency          0                                port RX ] { return 1 }
    if [ results registerTestVars minLatency           minLatency          0                                port RX ] { return 1 }
    if [ results registerTestVars maxLatency           maxLatency          0                                port RX ] { return 1 }

    return 0
}

global scriptmateDebug
set scriptmateDebug(debugLevel) 0

proc bbThroughput::start {} {
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

    #$testCmd config -duration 4
    
    set testName [[namespace current] cget -testName];
    set numTrials [[namespace current] cget -numtrials];
    
    if {[$testCmd cget -searchType]=="binary"} {
        $testCmd config -testName "BroadBand Throughput - [getBinarySearchString $testCmd]"
    }     

#    if {[[namespace current]::ConfigValidate]} {
#        logMsg "***** ERROR:  Config Validation failed.  Test aborted."
#        return $::TCL_ERROR
#    }

  
    if {[$testCmd cget -imixMode] == "yes" } {
        set colHeads { "Trial"
            "Iteration"
            "Tx Port"
            "Rx Port"
            "Tx Rate (%)"
            "Group"
            "Tx Count"
            "Rx Count"
            "Frame Loss"
            "Frame Loss (%)"
        }
        if {[$testCmd cget -calculateLatency] == "yes"} {
            lappend colHeads "Avg Latency (ns)" "Low Latency (ns)" "High Latency (ns)"
        }
    } else {
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
    }


    [namespace current]::ResultsDirectoryCreate;
    #  [namespace current]::CreateIterationFile;

    if {[$testCmd cget -searchType]=="binarys"} {
        if {[csvUtils::createIterationCSVFile $testCmd $colHeads]} {
            return $::TCL_ERROR
        }            
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

  
    
    if {([$testCmd cget -imixMode] == "yes") } {
        set frameSizeWanList   64
        set frameSizeBroadBandList 64
    } 

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

    [namespace current]::RealTimeStatsStop
    #realTimeGraphs::StopRealTimeStat;
    #scriptMateGuiCommand closeProgressMeter

    [namespace current]::MetricsPostProcess
    [namespace current]::PassFailCriteriaEvaluate
    [namespace current]::WriteResultsCSV

    if {[$testCmd cget -searchType]=="binary" } {  
        [namespace current]::WriteIterationCSV
    }

    [namespace current]::WriteAggregateResultsCSV
    [namespace current]::WriteRealTimeCSV
    [namespace current]::WriteInfoCSV
    [namespace current]::GeneratePDFReportFromCLI
    [namespace current]::TestCleanUp;    

    return $status




    debugPuts "Leave BroadBand Throughput Test"
    return 0
}


############################################################
#####
#
#
#
################################################################

proc bbThroughput::TestSetupImix {} { 
    debugPuts "Start TestSetup"

    global one2manyArray 
    global testConf

    variable s_many2oneArray
    variable wanPorts
    variable broadBandPorts
    variable groupIdArray
    variable groupIdWanArray
    variable groupIdBroadBandArray
    variable txGroupIdBroadBandArray
    variable bestGroupFps
    variable fullMapArray
    variable txPortList
    variable rxPortList 
    variable directions 
    variable portPgId

    set status $::TCL_OK  

    set testCmd [namespace current]
    set calculateDataIntegrity [expr {![string compare [$testCmd cget -calculateDataIntegrity] yes]}]
    
    set wanPorts       [getTxPorts one2manyArray]
    set broadBandPorts [getRxPorts one2manyArray]

    set txPortList [getTxPorts fullMapArray]
    set rxPortList [getRxPorts fullMapArray]  

    set pgid 0
    foreach txMap $txPortList {
        scan $txMap "%d %d %d" c l p
        set portPgId($c,$l,$p) $pgid
        incr pgid
    }
    
    if { $calculateDataIntegrity } {        
        set rxMode [expr $::portRxModeWidePacketGroup | $::portRxDataIntegrity | $::portRxSequenceChecking]        
    } else {
        set rxMode $::portRxModeWidePacketGroup 
    }

    ### make sure the total equals 100
    set frameSizeList {}

    if { $directions == "bidirectional" || $directions == "downstream" } {
        set totalBandwidth 0
        $testCmd config -imixList [$testCmd cget -imixWanList]
    
        for {set i 0} {$i < [llength [$testCmd cget -imixList]]} {incr i} {
            set bandwidth [lindex [lindex [$testCmd cget -imixList] $i] 1]
            incr totalBandwidth $bandwidth
        }
    
        if {$totalBandwidth != 100} {
            logMsg "***** ERROR:  The total bandwidth must be 100%.  Please adjust the imix frame size bandwidth."
            return $::TCL_ERROR
        }    
        
        $testCmd config -framesizeWanList [convertFromPercentBandwidth [$testCmd cget -imixWanList] [$testCmd cget -burstsize]]
    
        foreach txMap $txPortList {
            scan $txMap "%d %d %d" tx_c tx_l tx_p
            if {![port isValidFeature $tx_c $tx_l $tx_p portFeatureAdvancedScheduler]} {
                logMsg "\n***** WARNING: One or more ports don't support portFeatureAdvancedScheduler.\
                                    \n***** Not all addresses will be transmitted due to numAddressesPerPort > burstsize."
                break
            }
        } 

        # Need to reconfigure the framesizeList
        $testCmd config -framesizeWanList    [createFullFramesizeList [$testCmd cget -framesizeWanList]]
        set framesizeWanList   [$testCmd cget -framesizeWanList] 

        set frameSizeList $framesizeWanList
        assignGroupIds $framesizeWanList
        getGroupIds groupIdWanArray        

        foreach groupItem [array names groupIdWanArray] {
            set nextGroupId $groupIdWanArray($groupItem)
            foreach txMap [lnumsort [array names one2manyArray]] {
                foreach rxMap $one2manyArray($txMap) {
                    scan [join $rxMap] "%d %d %d" rx_c rx_l rx_p
                    set bestGroupFps($rx_c,$rx_l,$rx_p,$nextGroupId) 0
                }
            }
        }

    }


    if { $directions == "bidirectional" || $directions == "upstream" } {
        set totalBandwidth 0
        $testCmd config -imixList [$testCmd cget -imixBroadBandList]

        for {set i 0} {$i < [llength [$testCmd cget -imixList]]} {incr i} {
            set bandwidth [lindex [lindex [$testCmd cget -imixList] $i] 1]
            incr totalBandwidth $bandwidth
        }
        
        if {$totalBandwidth != 100} {
            logMsg "***** ERROR:  The total bandwidth must be 100%.  Please adjust the imix frame size bandwidth."
            return $::TCL_ERROR
        }    

        $testCmd config -framesizeBroadBandList [convertFromPercentBandwidth [$testCmd cget -imixBroadBandList] [$testCmd cget -burstsize]]

        foreach txMap $txPortList {
            scan $txMap "%d %d %d" tx_c tx_l tx_p
            if {![port isValidFeature $tx_c $tx_l $tx_p portFeatureAdvancedScheduler]} {
                logMsg "\n***** WARNING: One or more ports don't support portFeatureAdvancedScheduler.\
                                    \n***** Not all addresses will be transmitted due to numAddressesPerPort > burstsize."
                break
            }
        } 

        # Need to reconfigure the framesizeList
        $testCmd config -framesizeBroadBandList    [createFullFramesizeList [$testCmd cget -framesizeBroadBandList]]
        set framesizeBroadBandList   [$testCmd cget -framesizeBroadBandList] 

        set frameSizeList [concat $frameSizeList $framesizeBroadBandList]

        assignGroupIds $framesizeBroadBandList
        getGroupIds groupIdBroadBandArray

       
        set counter 0
        foreach txMap [lnumsort [array names s_many2oneArray]] {
            foreach groupItem [lnumsort [array names groupIdBroadBandArray]] {                
                set nextGroupId $groupIdBroadBandArray($groupItem)
                set txGroupIdBroadBandArray($txMap,$groupItem) $counter 
                incr counter
            }              
        }

        foreach groupItem [array names txGroupIdBroadBandArray] {
            set nextGroupId $txGroupIdBroadBandArray($groupItem)
            foreach txMap [lnumsort [array names s_many2oneArray]] {
                foreach rxMap $s_many2oneArray($txMap) {
                    scan [join $rxMap] "%d %d %d" rx_c rx_l rx_p
                    set bestGroupFps($rx_c,$rx_l,$rx_p,$nextGroupId) 0
                }
            }
        }

        # groupIdBroadBandArray - use for test
        # txGroupIdBroadBandArray -used for getting tx/rx values - else we got the all the values for Txs in one Rx
    }

    assignGroupIds $frameSizeList
    getGroupIds groupIdArray


    getAdvancedSchedulerArray fullMapArray advancedSchedulerArray otherArray

    if {[llength [array names advancedSchedulerArray]] > 0} {
        if [setAdvancedStreamSchedulerMode advancedSchedulerArray] {
            return $::TCL_ERROR
        }
        set advancedSchedulerFlag $::true

        if {[checkPortTransmitMode advancedSchedulerArray $::portTxModeAdvancedScheduler]} {
            errorMsg  "The ports are not in portTxModeAdvancedScheduler state"
            return $::TCL_ERROR
        }
    }

    if {[llength [array names otherArray]] > 0 } {
        errorMsg  "Some ports don't support portTxModeAdvancedScheduler state"
        return $::TCL_ERROR
        
    }

    if [checkLinkState fullMapArray] {
      return $::TCL_ERROR
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
   

#    if {[applyPacketGroupMode $widePacketGroupPortList bbThroughput] == $::TCL_ERROR} {}
#        return $::TCL_ERROR 


    if {[broadbandLearn "oncePerTest" bbThroughput]} {            
            errorMsg "Error sending learn frames"
            set retCode $::TCL_ERROR
    }        
    

    ######## set up results for this test NOTE: This test doesn't fully use results API
    # The framesize is set to 64, just for results setup
    foreach groupItem [lnumsort [array names groupIdArray]] { 
        setupTestResults $testCmd one2one "" fullMapArray $groupItem [$testCmd cget -numtrials]
    }

    set maxPercentRate          [$testCmd cget -percentMaxRate]

    if {$maxPercentRate > 100} {
        logMsg "***** WARNING: Percent frame rate cannot exceed 100%, percent set to 100."
        set maxPercentRate 100
    }

    $testCmd config -percentMaxRate $maxPercentRate


    if {[results cget -writeHeader] == "true" } {
        set resultFid [openResultFile]
        if {$resultFid == "stdout"} {
          logMsg "Cannot open file [results cget -resultFile] : $resultFid"
          logMsg "Results will be redirected to stdout."    
        } 
        writeHeader $resultFid [$testCmd cget -testName] $testCmd [$testCmd cget -duration]

        closeMyFile $resultFid
        results config -writeHeader false
    }
    return $status

}

#############################################################################
# bbThroughput::TestSetup()
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
proc bbThroughput::TestSetup {} {  
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


  set fileID [openResultFile]

  if {$fileID != "stdout"} {
        writeTextResultsFileHeader $fileID
        writeTextResultsFilePortConfig $fileID 
        closeMyFile $fileID       
  }

  if {[${testCmd} cget -imixMode] == "yes" } {
    if {[TestSetupImix]} {
        return $::TCL_ERROR
    }

  } else {
      #SETTING THE RX PORTS TO WIDE PACKET GROUP
      set learnproc [switchLearn::getLearnProc]
      debugPuts "learnproc - $learnproc"

      if {[broadbandLearn "oncePerTest" bbThroughput]} {            
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
        
      #if {[applyPacketGroupMode $widePacketGroupPortList $testCmd] == $::TCL_ERROR} { return $::TCL_ERROR }
            
      #assign groupId per TX port
      assignTxPortPGID fullMapArray groupIdArray $txPortList portPgId
    #  parray groupIdArray
  };

  debugPuts "Leave TestSetup"
  return $status;
}






#############################################################################
# throughput::ImixLinearSearchAlgorithm()
#
# DESCRIPTION
#
# RETURNS:  
# status      TCL_OK     - on success
#             TCL_ERROR  - on failure
#
##############################################################################
proc bbThroughput::ImixLinearSearchAlgorithm {} {    
    variable groupIdWanArray
    variable groupIdBroadBandArray
    variable txGroupIdBroadBandArray

    global ixgGroupIdArray

    variable bestGroupFps
    variable iterationBestGroupFps
    global   one2manyArray
    variable fullMapArray
    variable s_many2oneArray
    variable imixArray
    variable trial
    variable directions
    variable bestGroupFps
    variable fResultArray
    global ixgIteration

    set status $::TCL_OK
    set testCmd [namespace current]

    set calculateLatency    [expr {[$testCmd cget -calculateLatency] == "yes"}]
    set calculateJitter     [expr {[$testCmd cget -calculateJitter] == "yes"}]    
    set calculateDataIntegrity [expr {![string compare [$testCmd cget -calculateDataIntegrity] yes]}]

    set rateSelect          [$testCmd cget -rateSelect]
    set rateType [lindex [split $rateSelect R] 0]    

    set currentWanPercentRate [$testCmd cget -${rateType}WanRate]
    set currentBroadBandPercentRate [$testCmd cget -${rateType}BroadBandRate]

    set origWanPercentRate       $currentWanPercentRate
    set origBroadBandPercentRate $currentBroadBandPercentRate

    #set lossPercent         $currentPercentRate
    set lossPercent         0
    set incrStep            [$testCmd cget -incrStep] 
    set numIterations       [$testCmd cget -numIterations]
    set testCmd             $testCmd
    

    for {set iteration 1} {$iteration <= $numIterations} {incr iteration} {                
        
        # send learn frames on each iteration if set by user
        
        if {[broadbandLearn "onIteration" bbThroughput]} {            
                errorMsg "Error sending learn frames"
                set retCode $::TCL_ERROR
        }        

       
        if { $directions == "bidirectional" || $directions == "downstream" } {
            set downStreamString ", Wan Current rate: $currentWanPercentRate"
        } else {
            set downStreamString ""
        }

        if { $directions == "bidirectional" || $directions == "upstream" } {
            set upStreamString ", BroadBand Current rate: $currentBroadBandPercentRate"
        } else {
            set upStreamString ""
        }

        logMsg "=====>  TRIAL $trial, ITERATION $iteration, $directions $downStreamString $upStreamString [$testCmd cget -testName]"

        if { $directions == "bidirectional" || $directions == "downstream" } {

            if {$currentWanPercentRate <= 0} {
                logMsg "****** ERROR: ${rateType}WanRate rate cannot be 0. Exiting ..."
                return 0
            }

            $testCmd config -${rateSelect} $currentWanPercentRate 

            $testCmd config -imixList [$testCmd cget -imixWanList]
            $testCmd config -framesizeList [$testCmd cget -framesizeWanList]
            
            if [[namespace current]::writeMixedInterfaceStreams one2manyArray  framerateWan txWanNumFrames txWanFramesPerStream write $testCmd 8 groupIdWanArray] {
                return $::TCL_ERROR
            } 
        }

        if { $directions == "bidirectional" || $directions == "upstream" } {

            if {$currentBroadBandPercentRate <= 0} {
                logMsg "****** ERROR: ${rateType}WanRate rate cannot be 0. Exiting ..."
                return 0
            }
            $testCmd config -imixList [$testCmd cget -imixBroadBandList]
            $testCmd config -framesizeList [$testCmd cget -framesizeBroadBandList]
            $testCmd config -${rateSelect} $currentBroadBandPercentRate 

            
            if [[namespace current]::writeMixedInterfaceStreams s_many2oneArray  framerateBroadBand txBroadBandNumFrames txBroadBandFramesPerStream write $testCmd 8 txGroupIdBroadBandArray 1] {
                return $::TCL_ERROR
            }
        }

        if { $directions == "bidirectional" || $directions == "downstream" } {
            array set framerate         [array get framerateWan]
            array set txNumFrames       [array get txWanNumFrames]
            array set txFramesPerStream [array get txWanFramesPerStream]
        }

        if { $directions == "bidirectional" || $directions == "upstream" } {
            array set framerate         [array get framerateBroadBand]
            array set txNumFrames       [array get txBroadBandNumFrames]

            #array set txFramesPerStream [array get txBroadBandFramesPerStream]         

            catch {unset tempTxFramesPerStream}
            foreach txMap [array names s_many2oneArray] {
                scan $txMap  "%d,%d,%d" tx_c tx_l tx_p 
                foreach groupItem [lnumsort [array names groupIdBroadBandArray]] {
                     set txGroupId   $txGroupIdBroadBandArray($txMap,$groupItem)
                     set nextGroupId $groupIdBroadBandArray($groupItem)
                     set tempTxFramesPerStream($txMap,$nextGroupId)  $txBroadBandFramesPerStream($txMap,$txGroupId)
                }
            }

            catch {unset txBroadBandFramesPerStream}
            array set txBroadBandFramesPerStream [array get tempTxFramesPerStream]
            array set txFramesPerStream [array get tempTxFramesPerStream]         
        }

        if [startPacketGroups fullMapArray] {
            return $::TCL_ERROR
        }

        if [clearStatsAndTransmit fullMapArray [$testCmd cget -duration] [$testCmd cget -staggeredStart]] {
            return $::TCL_ERROR
        }

        waitForResidualFrames [$testCmd cget -waitResidual]

        catch {unset numGroupFrames}

        # Poll the Tx counters until all frames are sent
        if { $directions == "bidirectional" || $directions == "downstream" } {
            set ixgIteration        $iteration

            set txPortList          [getTxPorts one2manyArray]
            set rxPortList          [getRxPorts one2manyArray]
            
            stats::collectTxStats $txPortList txWanNumFrames txWanActualFrames totalWanTxNumFrames
            collectRxStats $rxPortList rxWanNumFrames totalWanRxNumFrames

            set totalPercentWanLoss   [calculatePercentLoss $totalWanTxNumFrames $totalWanRxNumFrames]
            unset ixgGroupIdArray
            copyPortList groupIdWanArray ixgGroupIdArray

            set fileID  [openResultFile a]
            
            set strToPrint  "\nTRIAL $trial, ITERATION $iteration, Downstream"  
            writeResult $fileID $strToPrint

            if {$fileID != "stdout"} {
                 closeMyFile $fileID
            }

            if { $calculateLatency || $calculateJitter } {
                if {[retrievePGStats one2manyArray numGroupFrames ${testCmd} avgLatency lowLatency highLatency bestGroupFps]} {
                    return $::TCL_ERROR
                }                 
            } else {    
                if {[retrievePGStats one2manyArray numGroupFrames ${testCmd}]} {
                     return $::TCL_ERROR
                } 
            }

           #puts "$\n Iteration:$iteration" 
           #parray groupIdWanArray
           #parray numGroupFrames

            if {$calculateDataIntegrity} {
                 foreach rxPort $rxPortList  {        
                     scan $rxPort "%d %d %d" rx_c rx_l rx_p                
                     stat get allStats $rx_c $rx_l $rx_p
                     set fResultArray($trial,$iteration,$rx_c,$rx_l,$rx_p,dataIntegrityFrames) [stat cget -dataIntegrityFrames]
                     set fResultArray($trial,$iteration,$rx_c,$rx_l,$rx_p,dataIntegrityErrors) [stat cget -dataIntegrityErrors]
                     set dataIntegrityError($rx_c,$rx_l,$rx_p) [stat cget -dataIntegrityErrors]
                 }
             }

           

           foreach txMap [array names one2manyArray] {
                scan $txMap  "%d,%d,%d" tx_c tx_l tx_p 

                set tputPercentList       {}
                set avgLatencyList        {}
                set maxLatencyList        {}
                set txTputPercentList     {}
                set txThoughputKbpsList   {}   

                set numRxPerTxPort  [llength $one2manyArray($txMap)]

                foreach rxMap $one2manyArray($txMap) {
                    scan $rxMap "%d %d %d" rx_c rx_l rx_p
                    set rxNumFramesList       {}
                    
                    foreach groupItem [lnumsort [array names groupIdWanArray]] {
                        set nextGroupId $groupIdWanArray($groupItem)
                        set fs [lindex [split $groupItem ,] 0]

                        set txFramesPerId [mpexpr {$txWanFramesPerStream($tx_c,$tx_l,$tx_p,$nextGroupId)/$numRxPerTxPort}]
                        
                        set fResultArray($trial,$iteration,$txMap,$nextGroupId,txThroughput)  [mpexpr $txFramesPerId/[$testCmd cget -duration]]
                        set fResultArray($trial,$iteration,$txMap,$nextGroupId,txTputPercent) [mpexpr {$fResultArray($trial,$iteration,$txMap,$nextGroupId,txThroughput)*100.0/[calculateMaxRate $tx_c $tx_l $tx_p $fs]}]                        

                        set fResultArray($trial,$iteration,$tx_c,$tx_l,$tx_p,$nextGroupId,txNumFrames)  $txFramesPerId
                        set fResultArray($trial,$iteration,$rx_c,$rx_l,$rx_p,$nextGroupId,rxNumFrames)  $numGroupFrames($rx_c,$rx_l,$rx_p,$nextGroupId)                   
                        set fResultArray($trial,$iteration,$tx_c,$tx_l,$tx_p,$nextGroupId,throughputRate) [mpexpr ($fResultArray($trial,$iteration,$rx_c,$rx_l,$rx_p,$nextGroupId,rxNumFrames)*1./[$testCmd cget -duration])]
                        set fResultArray($trial,$iteration,$tx_c,$tx_l,$tx_p,$nextGroupId,tputPercent) [mpexpr ($fResultArray($trial,$iteration,$tx_c,$tx_l,$tx_p,$nextGroupId,throughputRate)*100./[calculateMaxRate $tx_c $tx_l $tx_p $fs])]

                        lappend tputPercentList     $fResultArray($trial,$iteration,$tx_c,$tx_l,$tx_p,$nextGroupId,tputPercent)
                        lappend txTputPercentList   $fResultArray($trial,$iteration,$txMap,$nextGroupId,txTputPercent)
                        lappend txThoughputKbpsList [mpexpr {$fResultArray($trial,$iteration,$txMap,$nextGroupId,txThroughput)*$fs}]
                        lappend rxNumFramesList     $fResultArray($trial,$iteration,$rx_c,$rx_l,$rx_p,$nextGroupId,rxNumFrames) 

                        if { $calculateLatency || $calculateJitter} {
                            set fResultArray($trial,$iteration,$rx_c,$rx_l,$rx_p,$nextGroupId,avgLatency) $avgLatency($rx_c,$rx_l,$rx_p,$nextGroupId)
                            set fResultArray($trial,$iteration,$rx_c,$rx_l,$rx_p,$nextGroupId,minLatency) $lowLatency($rx_c,$rx_l,$rx_p,$nextGroupId) 
                            set fResultArray($trial,$iteration,$rx_c,$rx_l,$rx_p,$nextGroupId,maxLatency) $highLatency($rx_c,$rx_l,$rx_p,$nextGroupId)

                            lappend avgLatencyList $fResultArray($trial,$iteration,$rx_c,$rx_l,$rx_p,$nextGroupId,avgLatency)
                            lappend maxLatencyList $fResultArray($trial,$iteration,$rx_c,$rx_l,$rx_p,$nextGroupId,maxLatency)
                        }
                    } ;# groupitem
                    set fResultArray($trial,$iteration,$rx_c,$rx_l,$rx_p,rxNumFrames) [passfail::ListSum rxNumFramesList] 
                } ;# rxMap

                set fResultArray($trial,$iteration,$txMap,txThroughput)     [mpexpr {$txWanActualFrames($txMap)/[$testCmd cget -duration]}]

                # each port has the same speed
                set fResultArray($trial,$iteration,$txMap,txTputPercent)    [mpexpr {[passfail::ListSum txTputPercentList]/$numRxPerTxPort}]
                if { $fResultArray($trial,$iteration,$txMap,txTputPercent) > 100.0} {
                        set fResultArray($trial,$iteration,$txMap,txTputPercent) 100.0
                }
                set fResultArray($trial,$iteration,$txMap,txThroughputKbps) [mpexpr {[passfail::ListSum txThoughputKbpsList]*8}]
                set fResultArray($trial,$iteration,$txMap,tputPercent)      [mpexpr {[passfail::ListSum tputPercentList]/$numRxPerTxPort}]
                if { $fResultArray($trial,$iteration,$txMap,tputPercent) > 100.0} {
                        set fResultArray($trial,$iteration,$txMap,tputPercent) 100.0
                }
                            
                set fResultArray($trial,$iteration,$tx_c,$tx_l,$tx_p,throughputRate) [mpexpr {$fResultArray($trial,$iteration,$rx_c,$rx_l,$rx_p,rxNumFrames)*1./[$testCmd cget -duration]}]

                if {$calculateLatency || $calculateJitter} {
                    if {[lsearch $avgLatencyList "notCalculated"] >= 0} {
                        set fResultArray($trial,$iteration,$rx_c,$rx_l,$rx_p,avgLatency) "notCalculated";
                    } else {               
                        set fResultArray($trial,$iteration,$rx_c,$rx_l,$rx_p,avgLatency) [passfail::ListMean avgLatencyList]
                    }
                    if {[lsearch $maxLatencyList "notCalculated"] >= 0} {
                        set fResultArray($trial,$iteration,$rx_c,$rx_l,$rx_p,maxLatency) "notCalculated";
                    } else {                
                        set fResultArray($trial,$iteration,$rx_c,$rx_l,$rx_p,maxLatency) [passfail::ListMean maxLatencyList]
                    }
                }
                set ratePercent($txMap) [format "%5.2f" $fResultArray($trial,$iteration,$txMap,txTputPercent)]
            } ;# loop txMap
    
            ## Show the results 
            if { $calculateLatency || $calculateJitter } {
                printLog one2manyArray ratePercent txWanActualFrames txWanFramesPerStream $totalWanTxNumFrames numGroupFrames \
                    $totalWanRxNumFrames avgLatency lowLatency highLatency dataIntegrityError $testCmd

            } else {    
                printLogThroughput one2manyArray ratePercent txWanActualFrames txWanFramesPerStream $totalWanTxNumFrames numGroupFrames\
                            $totalWanRxNumFrames $testCmd "\t" 0 1 dataIntegrityError                   
            }           
            
        } 

        # Collect statistics for Upload 
        if { $directions == "bidirectional" || $directions == "upstream" } {
            set ixgIteration        $iteration

            set txPortList          [getTxPorts s_many2oneArray]
            set rxPortList          [getRxPorts s_many2oneArray]

            stats::collectTxStats $txPortList txBroadBandNumFrames txBroadBandActualFrames totalBroadBandTxNumFrames
            collectRxStats $rxPortList rxBroadBandNumFrames totalBroadBandRxNumFrames

            set totalPercentBroadBandLoss   [calculatePercentLoss $totalBroadBandTxNumFrames $totalBroadBandRxNumFrames]
            unset ixgGroupIdArray
            copyPortList txGroupIdBroadBandArray ixgGroupIdArray         

            foreach txMap [array names s_many2oneArray] {
                scan $txMap  "%d,%d,%d" tx_c tx_l tx_p 
                # one Rx per Tx Port
                set rxMap $s_many2oneArray($txMap) 

                catch {unset tempArray}
                catch {unset tempNumGroupFrames}
                catch {unset tempAvgLatency}
                catch {unset tempLowLatency}
                catch {unset tempHighLatency}
                 
                set tempArray($txMap) $rxMap
                if { $calculateLatency || $calculateJitter } {
                    if {[retrievePGStats tempArray tempNumGroupFrames ${testCmd} tempAvgLatency tempLowLatency tempHighLatency bestGroupFps]} {
                        return $::TCL_ERROR
                    }
                } else {    
                    if {[retrievePGStats tempArray tempNumGroupFrames ${testCmd}]} {
                         return $::TCL_ERROR
                    } 
                }
                set rxPort [join [join $rxMap] ,]
                foreach groupItem [lnumsort [array names groupIdBroadBandArray]] {
                     set txGroupId   $txGroupIdBroadBandArray($txMap,$groupItem)
                     set nextGroupId $groupIdBroadBandArray($groupItem)
                     set numGroupFrames($txMap,$nextGroupId)    $tempNumGroupFrames($rxPort,$txGroupId)
                     if { $calculateLatency || $calculateJitter } {
                         set avgLatency($txMap,$nextGroupId)    $tempAvgLatency($rxPort,$nextGroupId)
                         set lowLatency($txMap,$nextGroupId)    $tempLowLatency($rxPort,$nextGroupId)
                         set highLatency($txMap,$nextGroupId)   $tempHighLatency($rxPort,$nextGroupId)                           
                     } 
                }
                
            }

            if {$calculateDataIntegrity} {
                 foreach rxPort $rxPortList  {        
                     scan $rxPort "%d %d %d" rx_c rx_l rx_p                
                     stat get allStats $rx_c $rx_l $rx_p
                     set fResultArray($trial,$iteration,$rx_c,$rx_l,$rx_p,dataIntegrityFrames) [stat cget -dataIntegrityFrames]
                     set fResultArray($trial,$iteration,$rx_c,$rx_l,$rx_p,dataIntegrityErrors) [stat cget -dataIntegrityErrors]
                     set dataIntegrityError($rx_c,$rx_l,$rx_p) [stat cget -dataIntegrityErrors]
                 }
             }

            set fileID  [openResultFile a]
            
            set strToPrint  "\nTRIAL $trial, ITERATION $iteration, Upstream"  
            writeResult $fileID $strToPrint

            if {$fileID != "stdout"} {
                 closeMyFile $fileID
            }
            
       
            foreach txMap [array names s_many2oneArray] {
                scan $txMap  "%d,%d,%d" tx_c tx_l tx_p 

                set tputPercentList       {}
                set avgLatencyList        {}
                set maxLatencyList        {}
                set txTputPercentList     {}
                set txThoughputKbpsList   {}   

                set numRxPerTxPort  [llength $s_many2oneArray($txMap)]

                foreach rxMap $s_many2oneArray($txMap) {
                    scan $rxMap "%d %d %d" rx_c rx_l rx_p
                    set rxNumFramesList       {}                   

                    foreach groupItem [lnumsort [array names groupIdBroadBandArray]] {
                        
                        set nextGroupId $groupIdBroadBandArray($groupItem)
                        set fs [lindex [split $groupItem ,] 0]

                        set txFramesPerId [mpexpr {$txBroadBandFramesPerStream($tx_c,$tx_l,$tx_p,$nextGroupId)/$numRxPerTxPort}]

                        set fResultArray($trial,$iteration,$txMap,$nextGroupId,txThroughput)  [mpexpr $txFramesPerId/[$testCmd cget -duration]]
                        set fResultArray($trial,$iteration,$txMap,$nextGroupId,txTputPercent) [mpexpr {$fResultArray($trial,$iteration,$txMap,$nextGroupId,txThroughput)*100.0/[calculateMaxRate $tx_c $tx_l $tx_p $fs]}]                        

                        set fResultArray($trial,$iteration,$tx_c,$tx_l,$tx_p,$nextGroupId,txNumFrames)  $txFramesPerId
                        #set fResultArray($trial,$iteration,$rx_c,$rx_l,$rx_p,$nextGroupId,rxNumFrames)  $numGroupFrames($tx_c,$tx_l,$tx_p,$nextGroupId)                   
                        set fResultArray($trial,$iteration,$tx_c,$tx_l,$tx_p,$nextGroupId,rxNumFrames)  $numGroupFrames($tx_c,$tx_l,$tx_p,$nextGroupId)                   
                        set fResultArray($trial,$iteration,$tx_c,$tx_l,$tx_p,$nextGroupId,throughputRate) [mpexpr ($fResultArray($trial,$iteration,$tx_c,$tx_l,$tx_p,$nextGroupId,rxNumFrames)*1./[$testCmd cget -duration])]
                        set fResultArray($trial,$iteration,$tx_c,$tx_l,$tx_p,$nextGroupId,tputPercent) [mpexpr ($fResultArray($trial,$iteration,$tx_c,$tx_l,$tx_p,$nextGroupId,throughputRate)*100./[calculateMaxRate $tx_c $tx_l $tx_p $fs])]

                        lappend tputPercentList     $fResultArray($trial,$iteration,$tx_c,$tx_l,$tx_p,$nextGroupId,tputPercent)
                        lappend txTputPercentList   $fResultArray($trial,$iteration,$txMap,$nextGroupId,txTputPercent)
                        lappend txThoughputKbpsList [mpexpr {$fResultArray($trial,$iteration,$txMap,$nextGroupId,txThroughput)*$fs}]
                        lappend rxNumFramesList     $fResultArray($trial,$iteration,$tx_c,$tx_l,$tx_p,$nextGroupId,rxNumFrames) 

                        if { $calculateLatency || $calculateJitter} {
                            set fResultArray($trial,$iteration,$rx_c,$rx_l,$rx_p,$nextGroupId,avgLatency) $avgLatency($tx_c,$tx_l,$tx_p,$nextGroupId)
                            set fResultArray($trial,$iteration,$rx_c,$rx_l,$rx_p,$nextGroupId,minLatency) $lowLatency($tx_c,$tx_l,$tx_p,$nextGroupId) 
                            set fResultArray($trial,$iteration,$rx_c,$rx_l,$rx_p,$nextGroupId,maxLatency) $highLatency($tx_c,$tx_l,$tx_p,$nextGroupId)

                            lappend avgLatencyList $fResultArray($trial,$iteration,$rx_c,$rx_l,$rx_p,$nextGroupId,avgLatency)
                            lappend maxLatencyList $fResultArray($trial,$iteration,$rx_c,$rx_l,$rx_p,$nextGroupId,maxLatency)
                        }
                    } ;# groupitem
                    set fResultArray($trial,$iteration,$rx_c,$rx_l,$rx_p,rxNumFrames) [passfail::ListSum rxNumFramesList] 
                } ;# rxMap

                set fResultArray($trial,$iteration,$txMap,txThroughput)     [mpexpr {$txBroadBandActualFrames($txMap)/[$testCmd cget -duration]}]

                # each port has the same speed
                set fResultArray($trial,$iteration,$txMap,txTputPercent)    [mpexpr {[passfail::ListSum txTputPercentList]/$numRxPerTxPort}]
                if { $fResultArray($trial,$iteration,$txMap,txTputPercent) > 100.0} {
                        set fResultArray($trial,$iteration,$txMap,txTputPercent) 100.0
                }
                set fResultArray($trial,$iteration,$txMap,txThroughputKbps) [mpexpr {[passfail::ListSum txThoughputKbpsList]*8}]
                set fResultArray($trial,$iteration,$txMap,tputPercent)      [mpexpr {[passfail::ListSum tputPercentList]/$numRxPerTxPort}]
                if { $fResultArray($trial,$iteration,$txMap,tputPercent) > 100.0} {
                        set fResultArray($trial,$iteration,$txMap,tputPercent) 100.0
                }

                set fResultArray($trial,$iteration,$tx_c,$tx_l,$tx_p,throughputRate) [mpexpr {$fResultArray($trial,$iteration,$rx_c,$rx_l,$rx_p,rxNumFrames)*1./[$testCmd cget -duration]}]

                if {$calculateLatency || $calculateJitter} {
                    if {[lsearch $avgLatencyList "notCalculated"] >= 0} {
                        set fResultArray($trial,$iteration,$rx_c,$rx_l,$rx_p,avgLatency) "notCalculated";
                    } else {               
                        set fResultArray($trial,$iteration,$rx_c,$rx_l,$rx_p,avgLatency) [passfail::ListMean avgLatencyList]
                    }
                    if {[lsearch $maxLatencyList "notCalculated"] >= 0} {
                        set fResultArray($trial,$iteration,$rx_c,$rx_l,$rx_p,maxLatency) "notCalculated";
                    } else {                
                        set fResultArray($trial,$iteration,$rx_c,$rx_l,$rx_p,maxLatency) [passfail::ListMean maxLatencyList]
                    }
                }
                set ratePercent($txMap) [format "%5.2f" $fResultArray($trial,$iteration,$txMap,txTputPercent)]
            } ;# loop txMap

            ## Show the results             
            unset ixgGroupIdArray
            copyPortList groupIdBroadBandArray ixgGroupIdArray         

            if { $calculateLatency || $calculateJitter } {
                printLog s_many2oneArray ratePercent txBroadBandActualFrames txBroadBandFramesPerStream $totalBroadBandTxNumFrames numGroupFrames \
                    $totalBroadBandRxNumFrames avgLatency lowLatency highLatency dataIntegrityError $testCmd 1

            } else {    
                printLogThroughput s_many2oneArray ratePercent txBroadBandActualFrames txBroadBandFramesPerStream $totalBroadBandTxNumFrames numGroupFrames\
                            $totalBroadBandRxNumFrames $testCmd "\t"  1  1 dataIntegrityError
            }
        } 
        #parray fResultArray

        debugMsg " txNumFrames:[array get txNumFrames], txActualFrames :[array get txActualFrames]"  
#        set lossPercent $currentPercentRate 

        set currentWanPercentRate [$testCmd cget -${rateType}WanRate]
        set currentBroadBandPercentRate [$testCmd cget -${rateType}BroadBandRate]

        set origWanPercentRate       $currentWanPercentRate
        set origBroadBandPercentRate $currentBroadBandPercentRate
  
        if { $directions == "bidirectional" || $directions == "downstream" } {
            set currentWanPercentRate [mpexpr $currentWanPercentRate + [$testCmd cget -incrStep]] 
            $testCmd config -${rateType}WanRate   $currentWanPercentRate
        }

        if { $directions == "bidirectional" || $directions == "upstream" } {
            set currentBroadBandPercentRate [mpexpr $currentBroadBandPercentRate + [$testCmd cget -incrStep]] 
            $testCmd config -${rateType}BroadBandRate   $currentBroadBandPercentRate
        }        
    }
    
#    ${testCmd}::ShowIterationResults
    $testCmd config -${rateType}WanRate         $origWanPercentRate  
    $testCmd config -${rateType}BroadBandRate   $origBroadBandPercentRate  

    return $status
}

#############################################################################
# throughput::ImixBinarySearchAlgorithm()
#
# DESCRIPTION
#
# RETURNS:  
# status      TCL_OK     - on success
#             TCL_ERROR  - on failure
#
##############################################################################
proc bbThroughput::ImixBinarySearchAlgorithm {} {    
    variable groupIdWanArray
    variable groupIdBroadBandArray
    variable txGroupIdBroadBandArray

    global ixgGroupIdArray

    variable bestGroupFps
    variable iterationBestGroupFps
    global   one2manyArray
    variable fullMapArray
    variable s_many2oneArray
    variable imixArray
    variable trial
    variable directions
    variable bestGroupFps
    variable fResultArray
    variable txWanFramesPerStream
    variable txBroadBandFramesPerStream
    global ixgIteration


    set status $::TCL_OK
    set testCmd [namespace current]

    set calculateLatency    [expr {[$testCmd cget -calculateLatency] == "yes"}]
    set calculateJitter     [expr {[$testCmd cget -calculateJitter] == "yes"}]        

    set rateSelect          [$testCmd cget -rateSelect]
    set rateType [lindex [split $rateSelect R] 0]    

    set currentWanPercentRate [$testCmd cget -${rateType}WanRate]
    set currentBroadBandPercentRate [$testCmd cget -${rateType}BroadBandRate]

    set origWanPercentRate       $currentWanPercentRate
    set origBroadBandPercentRate $currentBroadBandPercentRate

    #set lossPercent         $currentPercentRate
    set lossPercent         0
    set incrStep            [$testCmd cget -incrStep] 
    set numIterations       [$testCmd cget -numIterations]
    set testCmd             $testCmd
    
    if { $directions == "bidirectional" || $directions == "downstream" } {
        set downStreamString ", Wan Current rate: $currentWanPercentRate"
    } else {
        set downStreamString ""
    }

    if { $directions == "bidirectional" || $directions == "upstream" } {
        set upStreamString ", BroadBand Current rate: $currentBroadBandPercentRate"
    } else {
        set upStreamString ""
    }

    logMsg "=====>  Trial $trial $downStreamString $upStreamString [$testCmd cget -testName]"


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
        }

        if {(($directions=="bidirectional")&&($binarySearchDirection))} {
            set linearDirection downstream     
        }       

        if {($binaryDirection=="upstream") || ($linearDirection=="upstream")} {

            if {$currentBroadBandPercentRate <= 0} {
                logMsg "****** ERROR: ${rateType}WanRate rate cannot be 0. Exiting ..."
                return 0
            }
            $testCmd config -imixList [$testCmd cget -imixBroadBandList]
            $testCmd config -framesizeList [$testCmd cget -framesizeBroadBandList]
            $testCmd config -${rateSelect} $currentBroadBandPercentRate 


            if [[namespace current]::writeMixedInterfaceStreams s_many2oneArray  framerateBroadBand txBroadBandNumFrames txBroadBandFramesPerStream write $testCmd 8 txGroupIdBroadBandArray 1] {
                return $::TCL_ERROR
            }

            array set framerate         [array get framerateBroadBand]
            array set txNumFrames       [array get txBroadBandNumFrames]

            #array set txFramesPerStream [array get txBroadBandFramesPerStream]         


            foreach element [array names groupIdBroadBandArray] {
                set fsMatrix($groupIdBroadBandArray($element))  [lindex [split $element ,] 0]
            }

            catch {unset tempTxFramesPerStream}
            foreach txMap [array names s_many2oneArray] {
                scan $txMap  "%d,%d,%d" tx_c tx_l tx_p 
                set thruputRate($txMap) 0
                foreach groupItem [lnumsort [array names groupIdBroadBandArray]] {
                     set txGroupId   $txGroupIdBroadBandArray($txMap,$groupItem)
                     set nextGroupId $groupIdBroadBandArray($groupItem)
                     set fs $fsMatrix($nextGroupId)
                     set tempTxFramesPerStream($txMap,$nextGroupId)  $txBroadBandFramesPerStream($txMap,$txGroupId)
                     set thruputRate($txMap) [mpexpr {$thruputRate($txMap)+($tempTxFramesPerStream($txMap,$nextGroupId)*100.0/[calculateMaxRate $tx_c $tx_l $tx_p $fs])}]
                }
                set thruputRate($txMap) [mpexpr {$thruputRate($txMap)/[$testCmd cget -duration]}]
                set userFrameRateBroadBandArray($txMap) [mpexpr {$txBroadBandNumFrames($txMap)/[$testCmd cget -duration]}]            
            }

            catch {unset txBroadBandFramesPerStream}
            array set txBroadBandFramesPerStream [array get tempTxFramesPerStream]
            array set txFramesPerStream [array get tempTxFramesPerStream]             
            array set txNumFrames [array get txBroadBandNumFrames]            
            array set rxNumFrames [array get rxBroadBandNumFrames]
        }


        if {($binaryDirection=="downstream") || ($linearDirection=="downstream")} {

            if {$currentWanPercentRate <= 0} {
                logMsg "****** ERROR: ${rateType}WanRate rate cannot be 0. Exiting ..."
                return 0
            }

            $testCmd config -${rateSelect} $currentWanPercentRate 

            $testCmd config -imixList [$testCmd cget -imixWanList]
            $testCmd config -framesizeList [$testCmd cget -framesizeWanList]

            if [[namespace current]::writeMixedInterfaceStreams one2manyArray  framerateWan txWanNumFrames txWanFramesPerStream write $testCmd 8 groupIdWanArray] {
                return $::TCL_ERROR
            }

            foreach element [array names groupIdWanArray] {
                set fsMatrix($groupIdWanArray($element))  [lindex [split $element ,] 0]
            }

            array set framerate         [array get framerateWan]
            array set txNumFrames       [array get txWanNumFrames]
            array set txFramesPerStream [array get txWanFramesPerStream]

            foreach txMap [array names one2manyArray] {
                set tputPercentRate($txMap) 0
            }

            foreach txMap [array names one2manyArray] {
                scan $txMap "%d,%d,%d" tx_c tx_l tx_p
                foreach groupId [array names fsMatrix] {
                   set fs $fsMatrix($groupId)
                   set tputPercentRate($txMap) [mpexpr {$tputPercentRate($txMap)+($txFramesPerStream($txMap,$groupId)*100.0/[calculateMaxRate $tx_c $tx_l $tx_p $fs])}]
                }            
                set tputPercentRate($txMap) [mpexpr {$tputPercentRate($txMap)/[$testCmd cget -duration]}]
                set userFrameRateWanArray($txMap) [mpexpr {$txWanNumFrames($txMap)/[$testCmd cget -duration]}]            
            }
            array set txNumFrames [array get txWanNumFrames]            
            array set rxNumFrames [array get rxWanNumFrames]
        }

        if {$binaryDirection=="downstream"} {

            if {$linearDirection=="upstream"} {
                set status [expr [${testCmd}::doBinarySearch $testCmd one2manyArray fullMapArray userFrameRateWanArray \
                                  thruputRate txNumFrames totalTxNumFrames rxNumFrames \
                                              totalRxNumFrames userPercentRateArray \
                                              no loss avgLatency stdDeviation "" bestIteration] && $status];

            } else {
                set status [expr [${testCmd}::doBinarySearch $testCmd one2manyArray one2manyArray userFrameRateWanArray \
                                  thruputRate txNumFrames totalTxNumFrames rxNumFrames \
                                              totalRxNumFrames userPercentRateArray \
                                              no loss avgLatency stdDeviation "" bestIteration] && $status];

            }

           set fResultArray($trial,bestIteration) $bestIteration

                    #return $status
        } else { ;# binary direction=="upstream"
            if {$linearDirection=="downstream"} {
                set status [expr [${testCmd}::doBinarySearch $testCmd s_many2oneArray fullMapArray userFrameRateBroadBandArray \
                                 thruputRate txNumFrames totalTxNumFrames rxNumFrames \
                                          totalRxNumFrames userPercentRateArray \
                                          no loss avgLatency stdDeviation "" bestIteration] && $status];
            } else {
                set status [expr [${testCmd}::doBinarySearch $testCmd s_many2oneArray s_many2oneArray userFrameRateBroadBandArray \
                                 thruputRate txNumFrames totalTxNumFrames rxNumFrames \
                                          totalRxNumFrames userPercentRateArray \
                                          no loss avgLatency stdDeviation "" bestIteration] && $status];
            }

            set fResultArray($trial,bestIteration) $bestIteration

        }

        if {$binaryDirection=="downstream"} {
            array set binTxRxArray [array get one2manyArray]
        } else {
            array set binTxRxArray [array get s_many2oneArray]
        }   

        if {$linearDirection=="downstream"} {
            array set linearTxRxArray [array get one2manyArray]
        } else {
            array set linearTxRxArray [array get s_many2oneArray]
        }   

        set fileID  [openResultFile a]

        set strToPrint "\nResults for Trial $trial, $directions"
        writeResult $fileID $strToPrint

        set strToPrint [format "\nBinary Search Direction:%s " $binaryDirection]
        writeResult $fileID $strToPrint
        set strToPrint [format "%-12s\t%-12s\t%-10s\t%-10s" "Tx Port"  "Rx Port" "TxTput(fps)" "%TxTput"]
        writeResult $fileID $strToPrint
        set strToPrint "***********************************************************************************************"
        writeResult $fileID $strToPrint

        foreach txMap [array names binTxRxArray]  {
            scan $txMap "%d,%d,%d" tx_c tx_l tx_p

            set firstTx  1
            foreach rxMap $binTxRxArray($txMap) {
                scan $rxMap "%d %d %d" rx_c rx_l rx_p
                if {$firstTx} {
                    set firstTx 0
                    set strToPrint [format "%-12s\t%-12s\t%-10s\t%-10s" [getPortId $tx_c $tx_l $tx_p]  [getPortId $rx_c $rx_l $rx_p] \
                       $thruputRate($txMap)  $userPercentRateArray($txMap) ]
                    writeResult $fileID $strToPrint

                } else {
                    set strToPrint [format "%-12s\t%-12s\t%-10s\t%-10s" "-"  [getPortId $rx_c $rx_l $rx_p] \
                       "-" "-"]   
                    writeResult $fileID $strToPrint
                }

            }
        }
        set strToPrint "***********************************************************************************************"
        writeResult $fileID $strToPrint

        if { $linearDirection != "none" } {
            set strToPrint [format "\nTransmiting Direction:%s " $linearDirection]
            writeResult $fileID $strToPrint
            set strToPrint [format "%-12s\t%-12s\t%-10s\t%-10s" "Tx Port"  "Rx Port" "TxTput(fps)" "%TxTput"]
            writeResult $fileID $strToPrint
            set strToPrint "***********************************************************************************************"
            writeResult $fileID $strToPrint

            foreach txMap [array names linearTxRxArray]  {
                scan $txMap "%d,%d,%d" tx_c tx_l tx_p

                set firstTx  1
                foreach rxMap $linearTxRxArray($txMap) {
                    scan $rxMap "%d %d %d" rx_c rx_l rx_p                
                    if {$firstTx} {
                        set firstTx 0
                        set strToPrint [format "%-12s\t%-12s\t%-10d\t%-10s" [getPortId $tx_c $tx_l $tx_p]  [getPortId $rx_c $rx_l $rx_p] $fResultArray($trial,$bestIteration,$tx_c,$tx_l,$tx_p,txThroughput) $fResultArray($trial,$bestIteration,$tx_c,$tx_l,$tx_p,tputPercent)]
                        writeResult $fileID $strToPrint
                    } else {
                        set strToPrint [format "%-12s\t%-12s\t%-10s\t%-10s" "-"  [getPortId $rx_c $rx_l $rx_p] "-" "-"]  
                        writeResult $fileID $strToPrint
                    }
                }
            }

            set strToPrint "***********************************************************************************************"
            writeResult $fileID $strToPrint
        }

        if {$fileID != "stdout"} {
          closeMyFile $fileID
        }

       debugMsg " txNumFrames:[array get txNumFrames], txActualFrames :[array get txActualFrames]"  
    #        set lossPercent $currentPercentRate 
    
             
    #    ${testCmd}::ShowIterationResults
        $testCmd config -${rateType}WanRate         $origWanPercentRate  
        $testCmd config -${rateType}BroadBandRate   $origBroadBandPercentRate  
    
        return $status
}


#############################################################################
# throughput::LinearSearchAlgorithm()
#
# DESCRIPTION
#
# RETURNS:  
# status      TCL_OK     - on success
#             TCL_ERROR  - on failure
#
##################################################
proc bbThroughput::LinearSearchAlgorithm {} {

    variable fullMapArray
    variable framesizeWan
    variable framesizeBroadBand
    #variable userFrameRateArray
    #variable userPercentRateArray  
    variable maxFrameRateWanArray 
    variable maxFrameRateBroadBandArray
    variable groupIdArray
    #variable totalLoss
    
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
    variable trial

    global one2manyArray
    variable directions 

    set testCmd [namespace current]

    set wanVlan [expr {![string compare [$testCmd cget -enableServerVLAN] true]}]
    set broadbandVlan [expr {![string compare [$testCmd cget -enableClientVLAN] true]}]

    set vlan $::testConf(enable802dot1qTag)

    set rateSelect [$testCmd cget -rateSelect]
    set duration [$testCmd cget -duration]
    
    set rxWanPortList       [getRxPorts one2manyArray]
    set rxBroadBandPortList [getRxPorts s_many2oneArray]

    set rateType [lindex [split $rateSelect R] 0]

    set currWanPercent [$testCmd cget -${rateType}WanRate]
    set currBroadBandPercent [$testCmd cget -${rateType}BroadBandRate]

    set origWanPercent       $currWanPercent
    set origBroadBandPercent $currBroadBandPercent   

    for {set iteration 1} {$iteration <= [$testCmd cget -numIterations]} {incr iteration} {
        logMsg "\n=====>  TRIAL $trial, ITERATION $iteration, $directions, framesize Wan: $framesizeWan, framesize BroadBand:$framesizeBroadBand [$testCmd cget -testName]"
    
        # send learn frames on each iteration if set by user
        if {[broadbandLearn "onIteration" bbThroughput]} {            
                errorMsg "Error sending learn frames"
                set retCode 1
        }        
        
        if {($directions=="bidirectional") || ($directions=="downstream")} {
            #initialise the initial rates for WAN stream 
            $testCmd config -framesize  $framesizeWan
            $testCmd config -${rateSelect} $currWanPercent     

            if [rateConversionUtils::initMaxRate one2manyArray maxFrameRateWanArray $framesizeWan \
                userFrameRateWanArray userPercentRateWanArray $testCmd] {
                return $::TCL_ERROR
            }  
        }

        if {($directions=="bidirectional") || ($directions=="upstream")} {
            #initialise the initial rates for Broadband streams
            $testCmd config -framesize  $framesizeBroadBand
            $testCmd config -${rateSelect} $currBroadBandPercent

            if [rateConversionUtils::initMaxRate s_many2oneArray maxFrameRateBroadBandArray $framesizeBroadBand \
                userFrameRateBroadBandArray userPercentRateBroadBandArray $testCmd] {
                return $::TCL_ERROR
            }       

        }

    
        set oldLatency [$testCmd cget -calculateLatency]
        set oldJitter  [$testCmd cget -calculateJitter]

        $testCmd config -calculateLatency   no
        $testCmd config -calculateJitter    no

        if {($directions=="bidirectional") || ($directions=="downstream")} {
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
 
            if [PacketGroupStreamBuild $testCmd one2manyArray txWanNumFrames $framesizeWan userPercentRateWanArray] {
                    errorMsg $errMsg
                    return $::TCL_ERROR
            }
            array set txNumFrames [array get txWanNumFrames]
            array set rxNumFrames [array get rxWanNumFrames]
        }
      
        if {($directions=="bidirectional") || ($directions=="upstream")} {
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

            if [PacketGroupStreamBuild $testCmd s_many2oneArray txBroadBandNumFrames $framesizeBroadBand userPercentRateBroadBandArray] {
                    errorMsg $errMsg
                    return $::TCL_ERROR
            }
            array set txNumFrames [array get txBroadBandNumFrames]            
            array set rxNumFrames [array get rxBroadBandNumFrames]
        }
     
        $testCmd config -calculateLatency   $oldLatency
        $testCmd config -calculateJitter    $oldJitter
    
        if [clearStatsAndTransmit fullMapArray $duration [$testCmd cget -staggeredStart]] {
            return $::TCL_ERROR
        }

        waitForResidualFrames [$testCmd cget -waitResidual]

        stats::collectTxStats [getTxPorts fullMapArray] txNumFrames txActualFrames totalTxNumFrames
        collectRxStats [getRxPorts fullMapArray] rxNumFrames totalRxNumFrames      
        set totalLoss  [calculatePercentLoss $totalTxNumFrames  $totalRxNumFrames]       

        ${testCmd}::GetLatencyJitter $iteration
        ${testCmd}::ShowIterationResults $iteration

        # calculate the new rate
        switch  $directions {
          bidirectional {        
              set oldWanPercent $currWanPercent
              set currWanPercent [mpexpr $currWanPercent + [$testCmd cget -incrStep]]

              set oldBroadBandPercent $currBroadBandPercent
              set currBroadBandPercent [mpexpr $currBroadBandPercent + [$testCmd cget -incrStep]]
              if {$currWanPercent < 0} {
                   set currWanPercent 0
              }

              if {$currBroadBandPercent < 0} {
                   set currBroadBandPercent 0
              }
              $testCmd config -${rateType}WanRate $currWanPercent
              $testCmd config -${rateType}BroadBandRate $currBroadBandPercent
    
          }
          downstream {
              set oldWanPercent $currWanPercent
              set currWanPercent [mpexpr $currWanPercent + [$testCmd cget -incrStep]]
              if {$currWanPercent < 0} {
                   set currWanPercent 0
              }
              $testCmd config -${rateType}WanRate $currWanPercent
    
          }
          upstream {
              set oldBroadBandPercent $currBroadBandPercent
              set currBroadBandPercent [mpexpr $currBroadBandPercent + [$testCmd cget -incrStep]]

              if {$currBroadBandPercent < 0} {
                   set currBroadBandPercent 0
              }
              $testCmd config -${rateType}BroadBandRate $currBroadBandPercent    
          }
        } ;# switch
    } ;# iterations loop

    # set the rates to the initial values 
    switch  $directions {
      bidirectional {
            $testCmd config -${rateType}WanRate $origWanPercent
            $testCmd config -${rateType}BroadBandRate $origBroadBandPercent
      }
      downstream {
            $testCmd config -${rateType}WanRate $origWanPercent
      }
      upstream {
            $testCmd config -${rateType}BroadBandRate $origBroadBandPercent
      }
    }

}


#######################################################################
#
#
#
#
##########################################################################
proc bbThroughput::ComputeBinaryIterationResults {TxActualFrames TotalTxNumFrames RxNumFrames TotalRxNumFrames PercentMaxRate iteration SentFrames ReceivedFrames} {
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

    variable binaryDirection 
    variable linearDirection

    set status $::TCL_OK

    set testCmd [namespace current]
    
    catch {unset txActualFrames}
    catch {unset rxNumFrames}

    upvar $RxNumFrames     tempRxNumFrames
    upvar $TxActualFrames  tempTxActualFrames    
    upvar $PercentMaxRate  percentMaxRate
    upvar $SentFrames      sentFrames
    upvar $ReceivedFrames  receivedFrames

    if {[$testCmd cget -imixMode] == "yes"} {
           return [${testCmd}::ComputeImixBinaryIterationResults tempTxActualFrames $TotalTxNumFrames tempRxNumFrames $TotalRxNumFrames percentMaxRate $iteration sentFrames receivedFrames]
    }  

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


#######################################################################
#
#
#
#
##########################################################################
proc bbThroughput::ComputeImixBinaryIterationResults {TxActualFrames TotalTxNumFrames RxNumFrames TotalRxNumFrames PercentMaxRate iteration SentFrames ReceivedFrames} {
    variable groupIdWanArray
    variable groupIdBroadBandArray
    variable txGroupIdBroadBandArray
    variable bestGroupFps
    variable iterationBestGroupFps   
    variable fullMapArray
    variable s_many2oneArray
    variable imixArray
    variable trial
    variable directions
    variable bestGroupFps
    variable fResultArray

    global   one2manyArray
    global ixgIteration
    global ixgGroupIdArray

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
    variable groupIdWanArray
        
  
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

    variable txWanFramesPerStream
    variable txBroadBandFramesPerStream

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

    set calculateLatency    [expr {[$testCmd cget -calculateLatency] == "yes"}]
    set calculateJitter     [expr {[$testCmd cget -calculateJitter] == "yes"}]  
    set calculateDataIntegrity  [expr {[$testCmd cget -calculateDataIntegrity] == "yes"}]

    set rateSelect          [$testCmd cget -rateSelect]
    set rateType [lindex [split $rateSelect R] 0]    

    catch {unset numGroupFrames}

    if { ($directions=="bidirectional") || ($directions == "downstream") } {
        set ixgIteration        $iteration

        set txPortList          [getTxPorts one2manyArray]
        set rxPortList          [getRxPorts one2manyArray]

        array set txWanActualFrames [array get tempTxActualFrames]
        set totalWanTxNumFrames $TotalTxNumFrames
        array set rxWanNumFrames    [array get tempRxNumFrames]
        set totalWanRxNumFrames $TotalRxNumFrames


        set totalPercentWanLoss   [calculatePercentLoss $totalWanTxNumFrames $totalWanRxNumFrames]
        unset ixgGroupIdArray
        copyPortList groupIdWanArray ixgGroupIdArray

        logMsg "\nDownstream"   
        if { $calculateLatency || $calculateJitter } {
            if {[retrievePGStats one2manyArray numGroupFrames ${testCmd} avgLatency lowLatency highLatency bestGroupFps]} {
                return $::TCL_ERROR
            }                 
        } else {    
            if {[retrievePGStats one2manyArray numGroupFrames ${testCmd}]} {
                 return $::TCL_ERROR
            } 
        }
       
       if {$calculateDataIntegrity} {
          foreach rxPort $rxPortList  {        
             scan $rxPort "%d %d %d" rx_c rx_l rx_p                
             stat get allStats $rx_c $rx_l $rx_p
             set fResultArray($trial,$iteration,$rx_c,$rx_l,$rx_p,dataIntegrityFrames) [stat cget -dataIntegrityFrames]
             set fResultArray($trial,$iteration,$rx_c,$rx_l,$rx_p,dataIntegrityErrors) [stat cget -dataIntegrityErrors]
             set dataIntegrityError($rx_c,$rx_l,$rx_p) [stat cget -dataIntegrityErrors]
          }
       }

       foreach txMap [array names one2manyArray] {
            scan $txMap  "%d,%d,%d" tx_c tx_l tx_p 

            set tputPercentList       {}            
            set txTputPercentList     {}
            set txThoughputKbpsList   {}   

            set numRxPerTxPort  [llength $one2manyArray($txMap)]
            
            set totalTxFrames 0
            set totalRxFrames 0
           
            foreach rxMap $one2manyArray($txMap) {
                scan $rxMap "%d %d %d" rx_c rx_l rx_p
                set rxNumFramesList       {}
                set avgLatencyList        {}
                set maxLatencyList        {}

                foreach groupItem [lnumsort [array names groupIdWanArray]] {
                    set nextGroupId $groupIdWanArray($groupItem)
                    set fs [lindex [split $groupItem ,] 0]

                    set txFramesPerId [mpexpr {$txWanFramesPerStream($tx_c,$tx_l,$tx_p,$nextGroupId)/$numRxPerTxPort}]

                    set fResultArray($trial,$iteration,$txMap,$nextGroupId,txThroughput)  [mpexpr $txFramesPerId/[$testCmd cget -duration]]
                    set fResultArray($trial,$iteration,$txMap,$nextGroupId,txTputPercent) [mpexpr {$fResultArray($trial,$iteration,$txMap,$nextGroupId,txThroughput)*100.0/[calculateMaxRate $tx_c $tx_l $tx_p $fs]}]                        

                    set fResultArray($trial,$iteration,$tx_c,$tx_l,$tx_p,$nextGroupId,txNumFrames)  $txFramesPerId
                    set fResultArray($trial,$iteration,$rx_c,$rx_l,$rx_p,$nextGroupId,rxNumFrames)  $numGroupFrames($rx_c,$rx_l,$rx_p,$nextGroupId)                   
                    set fResultArray($trial,$iteration,$tx_c,$tx_l,$tx_p,$nextGroupId,throughputRate) [mpexpr ($fResultArray($trial,$iteration,$rx_c,$rx_l,$rx_p,$nextGroupId,rxNumFrames)*1./[$testCmd cget -duration])]
                    set fResultArray($trial,$iteration,$tx_c,$tx_l,$tx_p,$nextGroupId,tputPercent) [mpexpr ($fResultArray($trial,$iteration,$tx_c,$tx_l,$tx_p,$nextGroupId,throughputRate)*100./[calculateMaxRate $tx_c $tx_l $tx_p $fs])]

                    lappend tputPercentList     $fResultArray($trial,$iteration,$tx_c,$tx_l,$tx_p,$nextGroupId,tputPercent)
                    lappend txTputPercentList   $fResultArray($trial,$iteration,$txMap,$nextGroupId,txTputPercent)
                    lappend txThoughputKbpsList [mpexpr {$fResultArray($trial,$iteration,$txMap,$nextGroupId,txThroughput)*$fs}]
                    lappend rxNumFramesList     $fResultArray($trial,$iteration,$rx_c,$rx_l,$rx_p,$nextGroupId,rxNumFrames) 
                    set totalTxFrames [mpexpr  {$totalTxFrames+$fResultArray($trial,$iteration,$tx_c,$tx_l,$tx_p,$nextGroupId,txNumFrames)}]

                    if { $calculateLatency || $calculateJitter} {
                        set fResultArray($trial,$iteration,$rx_c,$rx_l,$rx_p,$nextGroupId,avgLatency) $avgLatency($rx_c,$rx_l,$rx_p,$nextGroupId)
                        set fResultArray($trial,$iteration,$rx_c,$rx_l,$rx_p,$nextGroupId,minLatency) $lowLatency($rx_c,$rx_l,$rx_p,$nextGroupId) 
                        set fResultArray($trial,$iteration,$rx_c,$rx_l,$rx_p,$nextGroupId,maxLatency) $highLatency($rx_c,$rx_l,$rx_p,$nextGroupId)

                        lappend avgLatencyList $fResultArray($trial,$iteration,$rx_c,$rx_l,$rx_p,$nextGroupId,avgLatency)
                        lappend maxLatencyList $fResultArray($trial,$iteration,$rx_c,$rx_l,$rx_p,$nextGroupId,maxLatency)
                    }
                } ;# groupitem
                set fResultArray($trial,$iteration,$rx_c,$rx_l,$rx_p,rxNumFrames) [passfail::ListSum rxNumFramesList]                 
                set totalRxFrames [mpexpr {$totalRxFrames+$fResultArray($trial,$iteration,$rx_c,$rx_l,$rx_p,rxNumFrames)}]

                if {$calculateLatency || $calculateJitter} {
                    if {[lsearch $avgLatencyList "notCalculated"] >= 0} {
                        set fResultArray($trial,$iteration,$rx_c,$rx_l,$rx_p,avgLatency) "notCalculated";
                    } else {               
                        set fResultArray($trial,$iteration,$rx_c,$rx_l,$rx_p,avgLatency) [passfail::ListMean avgLatencyList]
                    }
                    if {[lsearch $maxLatencyList "notCalculated"] >= 0} {
                        set fResultArray($trial,$iteration,$rx_c,$rx_l,$rx_p,maxLatency) "notCalculated";
                    } else {                
                        set fResultArray($trial,$iteration,$rx_c,$rx_l,$rx_p,maxLatency) [passfail::ListMean maxLatencyList]
                    }
                }

            } ;# rxMap
            
            set fResultArray($trial,$iteration,$tx_c,$tx_l,$tx_p,txNumFrames) $totalTxFrames
            set fResultArray($trial,$iteration,$tx_c,$tx_l,$tx_p,rxNumFrames) $totalRxFrames

            set fResultArray($trial,$iteration,$txMap,txThroughput)     [mpexpr {$txWanActualFrames($txMap)/[$testCmd cget -duration]}]

            # each port has the same speed
            set fResultArray($trial,$iteration,$txMap,txTputPercent)    [mpexpr {[passfail::ListSum txTputPercentList]/$numRxPerTxPort}]
            if { $fResultArray($trial,$iteration,$txMap,txTputPercent) > 100.0} {
                    set fResultArray($trial,$iteration,$txMap,txTputPercent) 100.0
            }
            set fResultArray($trial,$iteration,$txMap,txThroughputKbps) [mpexpr {[passfail::ListSum txThoughputKbpsList]*8}]
            set fResultArray($trial,$iteration,$txMap,tputPercent)      [mpexpr {[passfail::ListSum tputPercentList]/$numRxPerTxPort}]
            if { $fResultArray($trial,$iteration,$txMap,tputPercent) > 100.0} {
                    set fResultArray($trial,$iteration,$txMap,tputPercent) 100.0
            }

            set fResultArray($trial,$iteration,$tx_c,$tx_l,$tx_p,throughputRate) [mpexpr {$fResultArray($trial,$iteration,$rx_c,$rx_l,$rx_p,rxNumFrames)*1./[$testCmd cget -duration]}]

            set ratePercent($txMap) [format "%5.2f" $fResultArray($trial,$iteration,$txMap,txTputPercent)]

        } ;# loop txMap

        set totalWanTxNumFrames 0
        set totalWanRxNumFrames 0

        foreach txMap [array names one2manyArray] {
            scan $txMap  "%d,%d,%d" tx_c tx_l tx_p             
            set totalWanTxNumFrames [mpexpr $totalWanTxNumFrames + $txActualFrames($tx_c,$tx_l,$tx_p)]                      
            set totalWanRxNumFrames [mpexpr $totalWanRxNumFrames + $fResultArray($trial,$iteration,$tx_c,$tx_l,$tx_p,rxNumFrames)] 
        }
    
        set totalPercentWanLoss   [calculatePercentLoss $totalWanTxNumFrames $totalWanRxNumFrames]
        
        if { $calculateLatency || $calculateJitter } {
            printLog one2manyArray ratePercent txWanActualFrames txWanFramesPerStream $totalWanTxNumFrames numGroupFrames \
                $totalWanRxNumFrames avgLatency lowLatency highLatency dataIntegrityError $testCmd 0 0 

        } else {    
            printLogThroughput one2manyArray ratePercent txWanActualFrames txWanFramesPerStream $totalWanTxNumFrames numGroupFrames\
                        $totalWanRxNumFrames $testCmd "\t" 0 0 dataIntegrityError                   
        }           

    } 
   

# Collect statistics for Upload 
    if { ($directions=="bidirectional") || ($directions == "upstream") } {
        set ixgIteration        $iteration

        set txPortList          [getTxPorts s_many2oneArray]
        set rxPortList          [getRxPorts s_many2oneArray]

        array set txBroadBandActualFrames [array get tempTxActualFrames]
        array set rxBroadBandNumFrames    [array get tempRxNumFrames]
       
        unset ixgGroupIdArray
        copyPortList txGroupIdBroadBandArray ixgGroupIdArray         

        foreach txMap [array names s_many2oneArray] {
            scan $txMap  "%d,%d,%d" tx_c tx_l tx_p 
            # one Rx per Tx Port
            set rxMap $s_many2oneArray($txMap) 

            catch {unset tempArray}
            catch {unset tempNumGroupFrames}
            catch {unset tempAvgLatency}
            catch {unset tempLowLatency}
            catch {unset tempHighLatency}

            set tempArray($txMap) $rxMap
            if { $calculateLatency || $calculateJitter } {
                if {[retrievePGStats tempArray tempNumGroupFrames ${testCmd} tempAvgLatency tempLowLatency tempHighLatency bestGroupFps]} {
                    return $::TCL_ERROR
                }
            } else {    
                if {[retrievePGStats tempArray tempNumGroupFrames ${testCmd}]} {
                     return $::TCL_ERROR
                } 
            }
            set rxPort [join [join $rxMap] ,]
            foreach groupItem [lnumsort [array names groupIdBroadBandArray]] {
                 set txGroupId   $txGroupIdBroadBandArray($txMap,$groupItem)
                 set nextGroupId $groupIdBroadBandArray($groupItem)
                 set numGroupFrames($txMap,$nextGroupId)    $tempNumGroupFrames($rxPort,$txGroupId)
                 if { $calculateLatency || $calculateJitter } {
                     set avgLatency($txMap,$nextGroupId)    $tempAvgLatency($rxPort,$nextGroupId)
                     set lowLatency($txMap,$nextGroupId)    $tempLowLatency($rxPort,$nextGroupId)
                     set highLatency($txMap,$nextGroupId)   $tempHighLatency($rxPort,$nextGroupId)                           
                 } 
            }
        }

        if {$calculateDataIntegrity} {
           foreach rxPort $rxPortList  {        
              scan $rxPort "%d %d %d" rx_c rx_l rx_p                
              stat get allStats $rx_c $rx_l $rx_p
              set fResultArray($trial,$iteration,$rx_c,$rx_l,$rx_p,dataIntegrityFrames) [stat cget -dataIntegrityFrames]
              set fResultArray($trial,$iteration,$rx_c,$rx_l,$rx_p,dataIntegrityErrors) [stat cget -dataIntegrityErrors]
              set dataIntegrityError($rx_c,$rx_l,$rx_p) [stat cget -dataIntegrityErrors]
           }
        }

        logMsg "\nUpstream"   

        foreach txMap [array names s_many2oneArray] {
            scan $txMap  "%d,%d,%d" tx_c tx_l tx_p 

            set tputPercentList       {}
            set avgLatencyList        {}
            set maxLatencyList        {}
            set txTputPercentList     {}
            set txThoughputKbpsList   {}   

            set numRxPerTxPort  [llength $s_many2oneArray($txMap)]
             
            set totalTxFrames 0
            set totalRxFrames 0

            foreach rxMap $s_many2oneArray($txMap) {
                scan $rxMap "%d %d %d" rx_c rx_l rx_p
                set rxNumFramesList       {}                   

                foreach groupItem [lnumsort [array names groupIdBroadBandArray]] {

                    set nextGroupId $groupIdBroadBandArray($groupItem)
                    set fs [lindex [split $groupItem ,] 0]

                    set txFramesPerId [mpexpr {$txBroadBandFramesPerStream($tx_c,$tx_l,$tx_p,$nextGroupId)/$numRxPerTxPort}]

                    set fResultArray($trial,$iteration,$txMap,$nextGroupId,txThroughput)  [mpexpr $txFramesPerId/[$testCmd cget -duration]]
                    set fResultArray($trial,$iteration,$txMap,$nextGroupId,txTputPercent) [mpexpr {$fResultArray($trial,$iteration,$txMap,$nextGroupId,txThroughput)*100.0/[calculateMaxRate $tx_c $tx_l $tx_p $fs]}]                        

                    set fResultArray($trial,$iteration,$tx_c,$tx_l,$tx_p,$nextGroupId,txNumFrames)  $txFramesPerId
                    set fResultArray($trial,$iteration,$tx_c,$tx_l,$tx_p,$nextGroupId,rxNumFrames)  $numGroupFrames($tx_c,$tx_l,$tx_p,$nextGroupId)                   
                    set fResultArray($trial,$iteration,$tx_c,$tx_l,$tx_p,$nextGroupId,throughputRate) [mpexpr ($fResultArray($trial,$iteration,$tx_c,$tx_l,$tx_p,$nextGroupId,rxNumFrames)*1./[$testCmd cget -duration])]
                    set fResultArray($trial,$iteration,$tx_c,$tx_l,$tx_p,$nextGroupId,tputPercent) [mpexpr ($fResultArray($trial,$iteration,$tx_c,$tx_l,$tx_p,$nextGroupId,throughputRate)*100./[calculateMaxRate $tx_c $tx_l $tx_p $fs])]

                    lappend tputPercentList     $fResultArray($trial,$iteration,$tx_c,$tx_l,$tx_p,$nextGroupId,tputPercent)
                    lappend txTputPercentList   $fResultArray($trial,$iteration,$txMap,$nextGroupId,txTputPercent)
                    lappend txThoughputKbpsList [mpexpr {$fResultArray($trial,$iteration,$txMap,$nextGroupId,txThroughput)*$fs}]
                    lappend rxNumFramesList     $fResultArray($trial,$iteration,$tx_c,$tx_l,$tx_p,$nextGroupId,rxNumFrames) 
                    set totalTxFrames [mpexpr  {$totalTxFrames+$fResultArray($trial,$iteration,$tx_c,$tx_l,$tx_p,$nextGroupId,txNumFrames)}]

                    if { $calculateLatency || $calculateJitter} {
                        set fResultArray($trial,$iteration,$rx_c,$rx_l,$rx_p,$nextGroupId,avgLatency) $avgLatency($tx_c,$tx_l,$tx_p,$nextGroupId)
                        set fResultArray($trial,$iteration,$rx_c,$rx_l,$rx_p,$nextGroupId,minLatency) $lowLatency($tx_c,$tx_l,$tx_p,$nextGroupId) 
                        set fResultArray($trial,$iteration,$rx_c,$rx_l,$rx_p,$nextGroupId,maxLatency) $highLatency($tx_c,$tx_l,$tx_p,$nextGroupId)

                        lappend avgLatencyList $fResultArray($trial,$iteration,$rx_c,$rx_l,$rx_p,$nextGroupId,avgLatency)
                        lappend maxLatencyList $fResultArray($trial,$iteration,$rx_c,$rx_l,$rx_p,$nextGroupId,maxLatency)
                    }
                } ;# groupitem
                set fResultArray($trial,$iteration,$rx_c,$rx_l,$rx_p,rxNumFrames) [passfail::ListSum rxNumFramesList] 
                set totalRxFrames [mpexpr {$totalRxFrames+$fResultArray($trial,$iteration,$rx_c,$rx_l,$rx_p,rxNumFrames)}]
            } ;# rxMap

            set fResultArray($trial,$iteration,$txMap,txThroughput)     [mpexpr {$txBroadBandActualFrames($txMap)/[$testCmd cget -duration]}]
            set fResultArray($trial,$iteration,$tx_c,$tx_l,$tx_p,txNumFrames) $totalTxFrames
            set fResultArray($trial,$iteration,$tx_c,$tx_l,$tx_p,rxNumFrames) $totalRxFrames

            # each port has the same speed
            set fResultArray($trial,$iteration,$txMap,txTputPercent)    [mpexpr {[passfail::ListSum txTputPercentList]/$numRxPerTxPort}]
            if { $fResultArray($trial,$iteration,$txMap,txTputPercent) > 100.0} {
                    set fResultArray($trial,$iteration,$txMap,txTputPercent) 100.0
            }
            set fResultArray($trial,$iteration,$txMap,txThroughputKbps) [mpexpr {[passfail::ListSum txThoughputKbpsList]*8}]
            set fResultArray($trial,$iteration,$txMap,tputPercent)      [mpexpr {[passfail::ListSum tputPercentList]/$numRxPerTxPort}]
            if { $fResultArray($trial,$iteration,$txMap,tputPercent) > 100.0} {
                    set fResultArray($trial,$iteration,$txMap,tputPercent) 100.0
            }

            set fResultArray($trial,$iteration,$tx_c,$tx_l,$tx_p,throughputRate) [mpexpr {$fResultArray($trial,$iteration,$rx_c,$rx_l,$rx_p,rxNumFrames)*1./[$testCmd cget -duration]}]

            if {$calculateLatency || $calculateJitter} {
                if {[lsearch $avgLatencyList "notCalculated"] >= 0} {
                    set fResultArray($trial,$iteration,$rx_c,$rx_l,$rx_p,avgLatency) "notCalculated";
                } else {               
                    set fResultArray($trial,$iteration,$rx_c,$rx_l,$rx_p,avgLatency) [passfail::ListMean avgLatencyList]
                }
                if {[lsearch $maxLatencyList "notCalculated"] >= 0} {
                    set fResultArray($trial,$iteration,$rx_c,$rx_l,$rx_p,maxLatency) "notCalculated";
                } else {                
                    set fResultArray($trial,$iteration,$rx_c,$rx_l,$rx_p,maxLatency) [passfail::ListMean maxLatencyList]
                }
            }
            set ratePercent($txMap) [format "%5.2f" $fResultArray($trial,$iteration,$txMap,txTputPercent)]
        } ;# loop txMap


        set totalBroadBandTxNumFrames 0
        set totalBroadBandRxNumFrames 0

        foreach txMap [array names s_many2oneArray] {
            scan $txMap  "%d,%d,%d" tx_c tx_l tx_p 
            set totalBroadBandTxNumFrames [mpexpr $totalBroadBandTxNumFrames + $fResultArray($trial,$iteration,$tx_c,$tx_l,$tx_p,txNumFrames)] 
            set totalBroadBandRxNumFrames [mpexpr $totalBroadBandRxNumFrames + $fResultArray($trial,$iteration,$tx_c,$tx_l,$tx_p,rxNumFrames)] 
        }

        set totalPercentBroadBandLoss   [calculatePercentLoss $totalBroadBandTxNumFrames $totalBroadBandRxNumFrames]
        ## Show the results             
        unset ixgGroupIdArray
        copyPortList groupIdBroadBandArray ixgGroupIdArray         

        if { $calculateLatency || $calculateJitter } {
            printLog s_many2oneArray ratePercent txBroadBandActualFrames txBroadBandFramesPerStream $totalBroadBandTxNumFrames numGroupFrames \
                $totalBroadBandRxNumFrames avgLatency lowLatency highLatency dataIntegrityError $testCmd 1 0
        } else {                
            printLogThroughput s_many2oneArray ratePercent txBroadBandActualFrames txBroadBandFramesPerStream $totalBroadBandTxNumFrames numGroupFrames\
                        $totalBroadBandRxNumFrames $testCmd "\t" 1 0 dataIntegrityError

        }       
    } 

    foreach txMap [lsort [array names fullMapArray]] {
        scan $txMap "%d,%d,%d" tx_c tx_l tx_p
        set sentFrames($txMap) $fResultArray($trial,$iteration,$txMap,txNumFrames) 
        set receivedFrames($txMap) $fResultArray($trial,$iteration,$txMap,rxNumFrames)
    }

    return $status     
}

########################################################################
#
#
#
#
##########################################################################
proc bbThroughput::GetLatencyJitter {{iteration trial}} {
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
    variable binaryDirection 
    variable linearDirection
    global   one2manyArray 
    global   testConf

    set status $::TCL_OK

    set testCmd [namespace current]
       
    set duration [$testCmd cget -duration]

    set calculateJitter         [expr {![string compare [$testCmd cget -calculateJitter] yes]}]     
    set calculateLatency        [expr {![string compare [$testCmd cget -calculateLatency] yes]}]
    set binarySearch            [expr {![string compare [$testCmd cget -searchType] binary]}]    
    set imixMode                [expr {[$testCmd cget -imixMode] == "yes"}]
    set linearSearch            [expr {[$testCmd cget -searchType] == "linear"}]
    set calculateDataIntegrity  [expr {[$testCmd cget -calculateDataIntegrity] == "yes"}]

    if {$imixMode} {
        return $status
    } else {

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

    }
#    parray fResultArray
    return $status     
}


##############################################################################
#
#
##############################################################################

proc bbThroughput::ShowIterationResults {{iteration trial}} {
    variable trial 
    variable fResultArray 
    variable framesizeWan
    variable framesizeBroadBand
    
    variable portPgId
    variable s_many2oneArray
    variable directions
    variable binaryDirection 
    variable linearDirection


    global   one2manyArray


    debugPuts "Start ShowIterationResults"
    set status $::TCL_OK;            

    set testCmd [namespace current]


    set calculateJitter  [expr {![string compare [$testCmd cget -calculateJitter] yes]}]     
    set calculateLatency [expr {![string compare [$testCmd cget -calculateLatency] yes] }]
    set linearSearch     [expr {[$testCmd cget -searchType] == "linear"}]
    set imixMode         [expr {[$testCmd cget -imixMode]=="yes"}]

    set fResultArray($trial,numIterations) $iteration

    if {$imixMode} {
        return $status

    } else {

        #NOT IMIX MODE 
        if {$linearSearch} {
            # Linear SEARCH, Standard Framesizes

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
                  
              set rateSelect [$testCmd cget -rateSelect]
              set rateType [lindex [split $rateSelect R] 0]

              if {($directions=="bidirectional") || ($directions=="downstream") } {
                  ShowIterationItem $testCmd one2manyArray downstream $iteration $fs
              }

              if {($directions=="bidirectional") || ($directions=="upstream") } {
                  ShowIterationItem $testCmd s_many2oneArray upstream $iteration $fs
              }
          
        } else {
# BINARY SEARCH
             logMsg "\nConfigured Transmit Rates used for iteration $iteration"
             logMsg "* Note: DUT Flow Control or Collisions may cause actual TX rate to be lower than Offered Rate"

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
                               

              if {$binaryDirection=="downstream"} {
                    array set binTxRxArray [array get one2manyArray]
              } else {
                    array set binTxRxArray [array get s_many2oneArray]
              }   
                
                
              if {$linearDirection=="downstream"} {
                    array set linearTxRxArray [array get one2manyArray]
              } elseif {$linearDirection=="upstream"} {
                    array set linearTxRxArray [array get s_many2oneArray]
              }   

              ShowIterationItem $testCmd binTxRxArray $binaryDirection $iteration $fs

              if {$linearDirection!="none"} {
                    ShowIterationItem $testCmd linearTxRxArray $linearDirection $iteration $fs
              }


        }
    }


    set status $::TCL_OK;    

    debugPuts "Leave ShowIterationResults"
    return $status;
}

#############################################################################
# bbThroughput::TestCleanUp()
#
# DESCRIPTION
# This procedure resets common code elements needed at the end of a test.
#
# RETURNS:  
# status      TCL_OK     - on success
#             TCL_ERROR  - on failure
#
###
proc bbThroughput::TestCleanUp {} { 
    
    debugPuts "Start TestCleanUp"

    set status $::TCL_OK;    
    
    debugPuts "Leave TestCleanUp"
    return $status;
}

#############################################################################
# bbThroughput::TrialSetup()
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
proc bbThroughput::TrialSetup {} {    
     debugPuts "Start TrialSetup"

     set status $::TCL_OK;     

     if {[broadbandLearn "onTrial" bbThroughput]} {            
             errorMsg "Error sending learn frames"
             set retCode $::TCL_ERROR
     }        

     debugPuts "Leave TrialSetup"
     return $status;
 }

#############################################################################
# bbThroughput::AlgorithmSetup()
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
proc bbThroughput::AlgorithmSetup {} {
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

  if {[$testCmd cget -imixMode] == "yes" } {
        return $status
  }

  $testCmd config -framesize  $framesizeWan

  if {[broadbandLearn "oncePerFramesize" bbThroughput]} {            
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


  realTimeGraphs::SaveRealTimeMarker "-- Trial:$trial FS WAN:$framesizeWan BroadBand:$framesizeBroadBand --";

  if {[info exists thruputRate]} {
      catch {unset thruputRate}
  }

  debugPuts "Leave AlgorithmSetup"
  return $status;

}

#############################################################################
# bbThroughput::AlgorithmBody()
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
proc bbThroughput::AlgorithmBody {} {    
    debugPuts "Start AlgorithmBody"

    set status  1
    set testCmd [namespace current]
        
    if {[$testCmd cget -imixMode] == "yes" } {
       set preamble "Imix"
    } else {
       set preamble ""
    }
    
    if { [$testCmd cget -searchType]=="binary" } {
        set status [expr [${testCmd}::${preamble}BinarySearchAlgorithm] && $status]
    } else {
        set status [expr [${testCmd}::${preamble}LinearSearchAlgorithm] && $status]
    }
    
    debugPuts "Leave AlgorithmBody"
    return $status;
}

#############################################################################
# bbThroughput::AlgorithmMeasure()
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
proc bbThroughput::AlgorithmMeasure {} {    
    debugPuts "Start AlgorithmMeasure"

    set status $::TCL_OK;    

    debugPuts "Leave AlgorithmMeasure"
    return $status;
}

#############################################################################
# bbThroughput::MeasurementStreamBuild()
#
# DESCRIPTION
# This helper procedure builds the stream that will be used to 
# measure key traffic metrics through the DUT.
#
# ARGS:
# TxRxArray       - contains Rx and Tx Maps used by this test.
# 
#
# RETURNS:  
# status      TCL_OK     - on success
#             TCL_ERROR  - on failure
#
###
proc bbThroughput::MeasurementStreamBuild {TxRxArray TxNumFrames {preambleSize 8}} \
{
    debugPuts "Start MeasurementStreamBuild"

    set status $::TCL_OK   

    debugPuts "Leave MeasurementStreamBuild"
    return $status;
}


proc bbThroughput::BinarySearchAlgorithm {} \
{
    global one2manyArray

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
    
    variable directions 
    variable binaryDirection 
    variable linearDirection

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

    logMsg "=====> Binary Search, Trial $trial, framesize Wan: $framesizeWan, framesize BroadBand:$framesizeBroadBand [$testCmd cget -testName]\n"

  
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
    }
    
    if {($binaryDirection=="downstream") || ($linearDirection=="downstream")} {
        #initialise the initial rates for WAN stream 
        $testCmd config -framesize  $framesizeWan
        $testCmd config -${rateSelect} $currWanPercent     
    
        if [rateConversionUtils::initMaxRate one2manyArray maxFrameRateWanArray $framesizeWan \
            userFrameRateWanArray userPercentRateWanArray $testCmd] {
            return $::TCL_ERROR
        }  
    }
    
    if {($binaryDirection=="upstream") || ($linearDirection=="upstream")} {
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
    
        if [PacketGroupStreamBuild $testCmd s_many2oneArray txBroadBandNumFrames $framesizeBroadBand userPercentRateBroadBandArray] {
                errorMsg $errMsg
                return $::TCL_ERROR
        }
        array set txNumFrames [array get txBroadBandNumFrames]            
        array set rxNumFrames [array get rxBroadBandNumFrames]
    }
    
    if {($binaryDirection=="downstream") || ($linearDirection=="downstream")} {
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
    
        if [PacketGroupStreamBuild $testCmd one2manyArray txWanNumFrames $framesizeWan userPercentRateWanArray] {
                errorMsg $errMsg
                return $::TCL_ERROR
        }
        array set txNumFrames [array get txWanNumFrames]
        array set rxNumFrames [array get rxWanNumFrames]
    
    }

    $testCmd config -calculateLatency   $oldLatency
    $testCmd config -calculateJitter    $oldJitter

    if {$binaryDirection=="downstream"} {

        if {$linearDirection=="upstream"} {
            set status [expr [${testCmd}::doBinarySearch $testCmd one2manyArray fullMapArray userFrameRateWanArray \
                              thruputRate txNumFrames totalTxNumFrames rxNumFrames \
                                          totalRxNumFrames userPercentRateWanArray \
                                          no loss avgLatency stdDeviation "" bestIteration] && $status];
        } else {
            set status [expr [${testCmd}::doBinarySearch $testCmd one2manyArray one2manyArray userFrameRateWanArray \
                              thruputRate txWanNumFrames totalTxNumFrames rxNumFrames \
                                          totalRxNumFrames userPercentRateWanArray \
                                          no loss avgLatency stdDeviation "" bestIteration] && $status];
        }

       set fResultArray($trial,bestIteration) $bestIteration

                #return $status
    } else { ;# binary direction=="upstream"
        if {$linearDirection=="downstream"} {
           set status [expr [${testCmd}::doBinarySearch $testCmd s_many2oneArray fullMapArray userFrameRateBroadBandArray \
                              thruputRate txNumFrames totalTxNumFrames rxNumFrames \
                                          totalRxNumFrames userPercentRateBroadBandArray \
                                          no loss avgLatency stdDeviation "" bestIteration] && $status];
        } else {
            set status [expr [${testCmd}::doBinarySearch $testCmd s_many2oneArray s_many2oneArray userFrameRateBroadBandArray \
                               thruputRate txBroadBandNumFrames totalTxNumFrames rxNumFrames \
                                           totalRxNumFrames userPercentRateBroadBandArray \
                                           no loss avgLatency stdDeviation "" bestIteration] && $status];
        }
        
        set fResultArray($trial,bestIteration) $bestIteration

    }
 

    if {$binaryDirection=="downstream"} {
        array set binTxRxArray [array get one2manyArray]
    } else {
        array set binTxRxArray [array get s_many2oneArray]
    }   


    if {$linearDirection=="downstream"} {
        array set linearTxRxArray [array get one2manyArray]
    } else {
        array set linearTxRxArray [array get s_many2oneArray]
    }   

    set fileID  [openResultFile a]

    set strToPrint "\n\nResults for Trial $trial ...\n"
    writeResult $fileID $strToPrint

    set strToPrint [format "\nBinary Search Direction:%s " $binaryDirection]
    writeResult $fileID $strToPrint
    set strToPrint [format "\n%-12s\t%-12s\t%-10s" "TX" "RX" "%TxTput" ]
    writeResult $fileID $strToPrint
    set strToPrint "****************************************"
    writeResult $fileID $strToPrint

    foreach txMap [array names binTxRxArray]  {
        scan $txMap "%d,%d,%d" tx_c tx_l tx_p

        set firstTx  1
        foreach rxMap $binTxRxArray($txMap) {
            scan $rxMap "%d %d %d" rx_c rx_l rx_p
            if {$firstTx} {
                set firstTx 0
                set bi $fResultArray($trial,bestIteration)
                set frs [format "%s-%s" $framesizeWan $framesizeBroadBand]
                set strToPrint  [format "%-12s\t%-12s\t%-10s" [getPortId $tx_c $tx_l $tx_p]  [getPortId $rx_c $rx_l $rx_p] \
                                  $fResultArray($trial,$frs,$bi,$txMap,txTputPercent)]  
                writeResult $fileID $strToPrint
            } else {
                set strToPrint  [format "%-12s\t%-12s\t%-10s" "-"  [getPortId $rx_c $rx_l $rx_p] "-"]  
                writeResult $fileID $strToPrint
            }
            
        }
    }
    set strToPrint  "****************************************"
    writeResult $fileID $strToPrint

    if { $linearDirection != "none" } {
        set strToPrint  [format "\nTransmiting Direction:%s " $linearDirection]
        writeResult $fileID $strToPrint
        set strToPrint  [format "\n%-12s\t%-12s\t%-10s" "TX" "RX" "%TxTput" ]
        writeResult $fileID $strToPrint
        set strToPrint  "****************************************"
        writeResult $fileID $strToPrint

        foreach txMap [array names linearTxRxArray]  {
            scan $txMap "%d,%d,%d" tx_c tx_l tx_p

            set firstTx  1
            foreach rxMap $linearTxRxArray($txMap) {
                scan $rxMap "%d %d %d" rx_c rx_l rx_p                
                if {$firstTx} {
                    set firstTx 0
                    set bi $fResultArray($trial,bestIteration)
                    set frs [format "%s-%s" $framesizeWan $framesizeBroadBand]
                    set strToPrint  [format "%-12s\t%-12s\t%-10s" [getPortId $tx_c $tx_l $tx_p]  [getPortId $rx_c $rx_l $rx_p] \
                                    $fResultArray($trial,$frs,$bi,$txMap,txTputPercent)]  
                    writeResult $fileID $strToPrint
                } else {
                    set strToPrint  [format "%-12s\t%-12s\t%-10s" "-"  [getPortId $rx_c $rx_l $rx_p] "-"]  
                    writeResult $fileID $strToPrint
                }
            }
        }

        set strToPrint  "****************************************"
        writeResult $fileID $strToPrint
    }

    if {$fileID != "stdout"} {
         closeMyFile $fileID
    }
    #parray fResultArray
    return $status


}

#############################################################################
# bbThroughput::AlgorithmCleanup()
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
proc bbThroughput::AlgorithmCleanUp {} {
    debugPuts "Start AlgorithmCleanUp"

    set status $::TCL_OK;

    debugPuts "Leave AlgorithmCleanUp"
    return $status;
}


#############################################################################
# bbThroughput::MetricsPostProcess()
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
proc bbThroughput::MetricsPostProcess {} {
    debugPuts "Start MetricsPostProcess"
    set status $::TCL_OK;

    variable resultsDirectory
    variable trialsPassed    
    variable fullMapArray
    variable portPgId
    variable fResultArray
    global one2manyArray
    global testConf
    variable framesizeWan
    variable framesizeBandBroand

    variable avgLatency
    variable maxLatency
    variable avgPercentLineRate
    variable minPercentLineRate
    variable avgDataRate
    variable minDataRate
    variable avgFrameRate
    variable minFrameRate
    variable directions


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
    set binarySearch        [expr {[$testCmd cget -searchType] == "binary"}]
    set calculateLatency    [expr {[$testCmd cget -calculateLatency] == "yes"}]
    set calculateJitter     [expr {[$testCmd cget -calculateJitter] == "yes"}]    
    set imixMode            [expr {[$testCmd cget -imixMode] == "yes"}]
    set linearSearch        [expr {[$testCmd cget -searchType] == "linear"}]

    set frameSizeWanList [[namespace current] cget -framesizeWanList];
    set frameSizeBroadBandList [[namespace current] cget -framesizeBroadBandList];
  
  
    if {$directions=="downstream"} {
         set frameSizeBroadBandList 64
    }

    if {$directions=="upstream"} {
        set frameSizeWanList   64
    }
   
    debugPuts [$testCmd cget -numtrials]
    

    if {$imixMode} {
        
        for {set trial 1} {$trial <= [$testCmd cget -numtrials] } {incr trial} {

            set percentLineRateList {};
            set frameRateList {};
            set dataRateList {};
            set avgLatencyList {};
            set maxLatencyList {};
            set avgStdDeviationList {}

            if {$linearSearch} {
                lappend colHeads "Iteration"
                set startIteration 1
                set numIterations [$testCmd cget -numIterations]
            } else {                
                set numIterations $fResultArray($trial,bestIteration)
                set startIteration $fResultArray($trial,bestIteration)
            }

            set frameRateList {};
            set percentLineRateList {};
            set dataRateList {}
            set aggMinLatencyList {};
            set aggMaxLatencyList {};
            set aggAvgLatencyList {};

            for {set iteration $startIteration} {$iteration <= $numIterations } {incr iteration} {
                if {$linearSearch} {
                    set lstr "iter,$iteration,"
                    set istr "$iteration"
                } else {
                    set lstr ""
                    set istr ""
                }

                foreach txMap [lsort [array names fullMapArray]] {
                    scan $txMap "%d,%d,%d" tx_c tx_l tx_p 

                    set txPacketGroupId $portPgId($txMap)                                
                    set first 1

                    set txPort [join "$tx_c $tx_l $tx_p" .]

                    if {[lsearch [array names one2manyArray] $txMap] != -1} {
                        set wanPort 1                            
                    } else {
                        set wanPort 0                     
                    }

                    if {[info exists fResultArray($trial,$iteration,$txMap,txThroughput)]} {
                        set frameRate  $fResultArray($trial,$iteration,$txMap,txThroughput)
                    } else {
                        set frameRate 0;
                    }

                    lappend frameRateList $frameRate;    

                    if {[info exists fResultArray($trial,$iteration,$txMap,txThroughputKbps)]} {
                        set dataRate  $fResultArray($trial,$iteration,$txMap,txThroughputKbps)
                    } else {
                        set dataRate 0;
                    }
                    
                    lappend dataRateList $dataRate;

                    if {$binarySearch} {
                        if {[info exists fResultArray($trial,$iteration,$txMap,txTputPercent)]} {
                            lappend percentLineRateList $fResultArray($trial,$iteration,$txMap,txTputPercent)
                        } else {
                            lappend percentLineRateList 0
                        }            
                    } else {
                        if {[info exists fResultArray($trial,$iteration,$txMap,tputPercent)]} {
                            lappend percentLineRateList $fResultArray($trial,$iteration,$txMap,tputPercent)
                        } else {
                            lappend percentLineRateList 0
                        }            
                    }

                    foreach rxMap $fullMapArray($txMap) {          
                        scan $rxMap "%d %d %d" rx_c rx_l rx_p
                        set rxPort [join "$rx_c $rx_l $rx_p" .]

                        if {$calculateJitter || $calculateLatency } {

                            if {[info exists fResultArray($trial,$iteration,[join "$rx_c $rx_l $rx_p" ,],maxLatency)]} {
                                lappend maxLatencyList $fResultArray($trial,$iteration,[join "$rx_c $rx_l $rx_p" ,],maxLatency)
                            } else {
                                lappend maxLatencyList 0
                            } 

                            if {[info exists fResultArray($trial,$iteration,[join "$rx_c $rx_l $rx_p" ,],avgLatency)]} {
                                lappend avgLatencyList $fResultArray($trial,$iteration,[join "$rx_c $rx_l $rx_p" ,],avgLatency)
                            } else {
                                lappend avgLatencyList 0
                            }                          
                        }   
                    } ;#loop rx                    
                };#loop tx                
            } ;# loop iteration


            # Minimum % Line Rate is the smallest throughput percentage of any port pair 
            # across any frame sizes for a given trial.
            set minPercentLineRate($trial) [passfail::ListMin percentLineRateList];

            # Average % Line Rate is an average throughput percentage across any frame 
            # sizes and all ports for a given trial
            set avgPercentLineRate($trial) [passfail::ListMean percentLineRateList];

            # Minimum Data Rate is the smallest absolute bit rate of any port pair across any 
            # frame sizes for a given trial. Data Rate is computed in bits/sec
            set minDataRate($trial) [passfail::ListMin dataRateList];

            # Average Data Rate is an average absolute bit rate across any frame sizes and 
            # all ports for a given trial
            set avgDataRate($trial) [passfail::ListMean dataRateList];

            # Minimum Frame Rate is the smallest frame rate of any port pair across any 
            # frame sizes for a given trial. Data Rate is computed in bits/sec
            set minFrameRate($trial) [passfail::ListMin frameRateList];

            # Average Frame Rate is an average frame rate across any frame sizes and 
            # all ports for a given trial
            set avgFrameRate($trial) [passfail::ListMean frameRateList]

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

    } else {
    
        for {set trial 1} {$trial <= [$testCmd cget -numtrials] } {incr trial} {
    
            set percentLineRateList {};
            set frameRateList {};
            set dataRateList {};
            set avgLatencyList {};
            set maxLatencyList {};
            set avgStdDeviationList {}
    
            if {$linearSearch} {
                lappend colHeads "Iteration"
                set startIteration 1
                set numIterations [$testCmd cget -numIterations]
            } else {                
                set numIterations $fResultArray($trial,bestIteration)
                set startIteration $fResultArray($trial,bestIteration)
            }

            foreach framesizeWan $frameSizeWanList {
                foreach framesizeBroadBand $frameSizeBroadBandList {        
                    set frameRateList {};
                    set percentLineRateList {};
                    set dataRateList {}
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
    
                            if {[info exists fResultArray($trial,$fs,$iteration,$txMap,txThroughput)]} {
                                set frameRate  $fResultArray($trial,$fs,$iteration,$txMap,txThroughput)
                            } else {
                                set frameRate 0;
                            }
    
                            lappend frameRateList $frameRate;    

                            if {[IsWanPort $tx_c $tx_l $tx_p]} {
                                set dataRate  [mpexpr 8 * $framesizeWan * $frameRate];    
                            } else {
                                set dataRate  [mpexpr 8 * $framesizeBroadBand * $frameRate];    
                            }
                            
                            lappend dataRateList $dataRate;
    
                            if {$binarySearch} {
                                if {[info exists fResultArray($trial,$fs,$iteration,$txMap,txTputPercent)]} {
                                    lappend percentLineRateList $fResultArray($trial,$fs,$iteration,$txMap,txTputPercent)
                                } else {
                                    lappend percentLineRateList 0
                                }            
                            } else {
                                if {[info exists fResultArray($trial,$fs,$iteration,$txMap,TputPercent)]} {
                                    lappend percentLineRateList $fResultArray($trial,$fs,$iteration,$txMap,TputPercent)
                                } else {
                                    lappend percentLineRateList 0
                                }            
                            }
    
                            foreach rxMap $fullMapArray($txMap) {          
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
        
            
            # Minimum % Line Rate is the smallest throughput percentage of any port pair 
            # across any frame sizes for a given trial.
            set minPercentLineRate($trial) [passfail::ListMin percentLineRateList];
        
            # Average % Line Rate is an average throughput percentage across any frame 
            # sizes and all ports for a given trial
            set avgPercentLineRate($trial) [passfail::ListMean percentLineRateList];
        
            # Minimum Data Rate is the smallest absolute bit rate of any port pair across any 
            # frame sizes for a given trial. Data Rate is computed in bits/sec
            set minDataRate($trial) [passfail::ListMin dataRateList];
        
            # Average Data Rate is an average absolute bit rate across any frame sizes and 
            # all ports for a given trial
            set avgDataRate($trial) [passfail::ListMean dataRateList];
        
            # Minimum Frame Rate is the smallest frame rate of any port pair across any 
            # frame sizes for a given trial. Data Rate is computed in bits/sec
            set minFrameRate($trial) [passfail::ListMin frameRateList];
        
            # Average Frame Rate is an average frame rate across any frame sizes and 
            # all ports for a given trial
            set avgFrameRate($trial) [passfail::ListMean frameRateList]
        
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
    } ;# end not imix mode
 
    debugPuts "Leave MetricsPostProcess"
    return $status;
}

################################################################################
#
# bbThroughput::PassFailCriteriaEvaluate()
#
# DESCRIPTION:
# This procedure calculates the number of trials that have executed successfully
# based upon user-specified Pass/Fail criteria.  
# 
# The first criteria for this test is based upon either an acceptable percentage of 
# line rate or an acceptable data rate.  These two general criteria are further 
# divided as noted below.
# Average % Line Rate is an average bbThroughput percentage across any frame 
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
proc bbThroughput::PassFailCriteriaEvaluate {} {
   
    debugPuts "Start PassFailCriteriaEvaluate"
    set status $::TCL_OK; 

    variable avgLatency
    variable maxLatency
    variable avgPercentLineRate
    variable minPercentLineRate
    variable avgDataRate
    variable minDataRate
    variable avgFrameRate
    variable minFrameRate

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
        set throughputResult [passfail::PassFailCriteriaThroughputEvaluate \
                      $avgPercentLineRate($trial) $minPercentLineRate($trial) \
                      $avgDataRate($trial) $minDataRate($trial) "N/A" \
                      $avgFrameRate($trial) $minFrameRate($trial)];
        
        if {$calculateLatency} {
            set latencyResult [passfail::PassFailCriteriaLatencyEvaluate \
                       $avgLatency($trial) $maxLatency($trial)];
            
            if { ($throughputResult == "PASS") && ($latencyResult == "PASS")} {
                set result "PASS"
            } else {
                set result "FAIL";
            }
        } elseif {$calculateJitter} {  
                #don't care about latency 
                set jitterResult [passfail::PassFailCriteriaJitterEvaluate \
                                     $avgLatency($trial) $maxLatency($trial)];
    
                if { ($throughputResult == "PASS") && ($jitterResult == "PASS") } {
                        set result "PASS"
                    } else {
                        set result "FAIL";
                }
            } else {
                set result $throughputResult;
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
# bbThroughput::WriteResultsCSV()
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
proc bbThroughput::WriteResultsCSV {} {  
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
    set status $::TCL_OK
           
    set testCmd [namespace current]
    set binarySearch        [expr {[$testCmd cget -searchType] == "binary"}]
    set calculateLatency    [expr {[$testCmd cget -calculateLatency] == "yes"}]
    set calculateJitter     [expr {[$testCmd cget -calculateJitter] == "yes"}]    
    set imixMode            [expr {[$testCmd cget -imixMode] == "yes"}]
    set linearSearch        [expr {[$testCmd cget -searchType] == "linear"}]
    set calculateDataIntegrity  [expr {[$testCmd cget -calculateDataIntegrity] == "yes"}]

    set testCmd [namespace current]   

    if {[catch {set csvFid [open $dirName/results.csv w]}]} {
        logMsg "***** WARNING:  Cannot open csv file."
        return
    }

    if {$imixMode} {
        # Imix mode
        
        set colHeads {"Trial" } 

        if {$linearSearch} {
            lappend colHeads "Iteration"            
        }

        lappend colHeads  "Directions" "Tx Port" "Rx Port" "Frame size" "Tx Tput (fps)" "Tx Tput (%)" "Tx Frames" "Rx Frames" "Loss (frames)" "Loss (%)"

        if {$calculateLatency} {
            lappend colHeads "Min Latency (ns)" "Max Latency (ns)" "Avg Latency (ns)"
        }

        if {$calculateJitter} {
            lappend colHeads "Min Inter-Arrival (ns)" "Max Inter-Arrival (ns)" "Avg Inter-Arrival (ns)"
        }

        if {$calculateDataIntegrity} {
            lappend colHeads "Data Integrity Errors"
        }

        puts $csvFid [join $colHeads ,]

        for {set trial 1 } {$trial <= [$testCmd cget -numtrials]} {incr trial} {
            if {$linearSearch} {
                set numIterations [$testCmd cget -numIterations]
                set startIteration 1
            } else {
                set numIterations $fResultArray($trial,bestIteration)
                set startIteration $fResultArray($trial,bestIteration)
            }
            for {set iteration $startIteration} {$iteration <= $numIterations } {incr iteration} {
                if {$linearSearch} {
                    set lstr "iter,$iteration,"
                    set istr "$iteration"
                } else {
                    set lstr ""
                    set istr ""
                }
                foreach txMap [lsort [array names fullMapArray]] {
                    scan $txMap "%d,%d,%d" tx_c tx_l tx_p 

                    set txPacketGroupId $portPgId($txMap)                                
                    set first 1

                    set txPort [join "$tx_c $tx_l $tx_p" .]    

                    if {[lsearch [array names one2manyArray] $txMap] != -1} {
                        set isWanPort "- D -"   
                        set wanPort 1
                    } else {
                        set isWanPort "- U -"                  
                        set wanPort 0
                    }

                    foreach rxMap $fullMapArray($txMap) {          
                        scan $rxMap "%d %d %d" rx_c rx_l rx_p
                        set rxPort [join "$rx_c $rx_l $rx_p" .] 
                        if {$wanPort} {
                            set groupIdName groupIdWanArray
                        } else {
                            set groupIdName groupIdBroadBandArray
                        }

                        set firstGroup 1

                        foreach groupItem [lnumsort [array names $groupIdName]] {
                             set nextGroupId [set ${groupIdName}($groupItem)]
                             set globalGroupId $groupIdArray($groupItem)

                             if {[info exists fResultArray($trial,$iteration,$txMap,$nextGroupId,txThroughput)]} {
                                 set txThroughput $fResultArray($trial,$iteration,$txMap,$nextGroupId,txThroughput)
                             } else {
                                 set txThroughput  0;
                             }

                             if {[info exists fResultArray($trial,$iteration,$txMap,$nextGroupId,txTputPercent)]} {
                                 set txTput $fResultArray($trial,$iteration,$txMap,$nextGroupId,txTputPercent)
                             } else {
                                 set txTput 0
                             }       

                             set numTxFramesPerPgID $fResultArray($trial,$iteration,[join "$tx_c $tx_l $tx_p" ,],$nextGroupId,txNumFrames)

                             #set numRxFramesPerPgID $fResultArray($trial,$iteration,[join "$rx_c $rx_l $rx_p" ,],$nextGroupId,rxNumFrames)
                             if { $wanPort } {
                                set numRxFramesPerPgID $fResultArray($trial,$iteration,[join "$rx_c $rx_l $rx_p" ,],$nextGroupId,rxNumFrames)
                             } else {                             
                                set numRxFramesPerPgID $fResultArray($trial,$iteration,[join "$tx_c $tx_l $tx_p" ,],$nextGroupId,rxNumFrames)
                             }

                             set frameLoss      [mpexpr {$numTxFramesPerPgID-$numRxFramesPerPgID}]
                             set frameLossPct   [mpexpr {($numTxFramesPerPgID-$numRxFramesPerPgID)*100.0/$numTxFramesPerPgID}]
    
                             set resList [list $trial $istr $isWanPort $txPort $rxPort [join [split $groupItem ,] -] $txThroughput $txTput  $numTxFramesPerPgID $numRxFramesPerPgID $frameLoss $frameLossPct]
     
                             if {$calculateLatency || $calculateJitter} {
                                if {[info exists fResultArray($trial,$iteration,[join "$rx_c $rx_l $rx_p" ,],$nextGroupId,minLatency)]} {
                                  set minLatency $fResultArray($trial,$iteration,[join "$rx_c $rx_l $rx_p" ,],$nextGroupId,minLatency)
                                } else {
                                  set minLatency 0
                                } 
                                if {[info exists fResultArray($trial,$iteration,[join "$rx_c $rx_l $rx_p" ,],$nextGroupId,maxLatency)]} {
                                  set maxLatency $fResultArray($trial,$iteration,[join "$rx_c $rx_l $rx_p" ,],$nextGroupId,maxLatency)
                                } else {
                                  set maxLatency 0
                                } 
                                if {[info exists fResultArray($trial,$iteration,[join "$rx_c $rx_l $rx_p" ,],$nextGroupId,avgLatency)]} {
                                  set avgLatency $fResultArray($trial,$iteration,[join "$rx_c $rx_l $rx_p" ,],$nextGroupId,avgLatency)
                                } else {
                                  set avgLatency 0
                                } 
                                lappend resList $minLatency $maxLatency $avgLatency
                             }

                             if { $calculateDataIntegrity } {
                                 if {$firstGroup} {                                 
                                   set firstGroup 0
                                   lappend resList  $fResultArray($trial,$iteration,$rx_c,$rx_l,$rx_p,dataIntegrityErrors)
                                 } else {
                                   lappend resList  "-"
                                 }
                             }

                            regsub ",," [join $resList ,] "," lista
                            puts $csvFid $lista
                       } ;# loop groupItem                     
                    } ;#loop rx
                };#loop tx
            } ;# loop iteration
        } ;# loop trial
    } else {
# Standard (not Imix mode)


        set colHeads {"Trial" "Frame Size (bytes)"} 

        if {$linearSearch} {
            lappend colHeads "Iteration"
            set numIterations [$testCmd cget -numIterations]
        } else {
            set numIterations 1
        }

        lappend colHeads  "Directions" "Tx Port" "Rx Port" "Tx Tput (fps)" "Tx Tput (%)" "Tx Frames" "Rx Frames" "Loss (frames)" "Loss (%)"

        if {$calculateLatency} {
            lappend colHeads "Min Latency (ns)" "Max Latency (ns)" "Avg Latency (ns)"
        }

        if {$calculateJitter} {
            lappend colHeads "Min Inter-Arrival (ns)" "Max Inter-Arrival (ns)" "Avg Inter-Arrival (ns)"
        }

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
                    for {set iteration 1} {$iteration <= $numIterations } {incr iteration} {
                        if {$linearSearch} {
                            set lstr "iter,$iteration,"
                            set istr "$iteration"
                        } else {
                            set lstr ""
                            set istr ""
                        }
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
    
                            if {[info exists fResultArray($trial,$fs,$iteration,$txMap,txThroughput)]} {
                                set txThroughput  $fResultArray($trial,$fs,$iteration,$txMap,txThroughput)
                            } else {
                                set txThroughput 0;
                            }
    
                            if {[info exists fResultArray($trial,$fs,$iteration,$txMap,txTputPercent)]} {
                                set txTput $fResultArray($trial,$fs,$iteration,$txMap,txTputPercent)
                            } else {
                                set txTput 0;
                            }            
                            
                            if {[info exists fResultArray($trial,$fs,$iteration,$txMap,txNumFrames)]} {
                                set txFrames [mpexpr {$fResultArray($trial,$fs,$iteration,$txMap,txNumFrames)/[llength $fullMapArray($txMap)]}]                            
                            } else {
                                set txFrames 0;
                            }            
    
                            foreach rxMap $fullMapArray($txMap) {          
                                scan $rxMap "%d %d %d" rx_c rx_l rx_p
                                set rxPort [join "$rx_c $rx_l $rx_p" .]                            
                                
                                if {[info exists fResultArray($trial,$fs,$iteration,[join "$rx_c $rx_l $rx_p" ,],$txPacketGroupId,rxNumFrames)]} {
                                   set rxFrames $fResultArray($trial,$fs,$iteration,[join "$rx_c $rx_l $rx_p" ,],$txPacketGroupId,rxNumFrames)
                                } else {
                                   set rxFrames  0;
                                } 

                                set frameLoss      [mpexpr {$txFrames-$rxFrames}]
                                set frameLossPct   [mpexpr {($txFrames-$rxFrames)*100.0/$txFrames}]

                                set resList [list $trial $fs $istr $isWanPort $txPort $rxPort $txThroughput $txTput $txFrames $rxFrames $frameLoss $frameLossPct]
    
                                if {$calculateLatency || $calculateJitter} {
                                  if {[info exists fResultArray($trial,$fs,$iteration,[join "$rx_c $rx_l $rx_p" ,],$txPacketGroupId,minLatency)]} {
                                    set minLatency $fResultArray($trial,$fs,$iteration,[join "$rx_c $rx_l $rx_p" ,],$txPacketGroupId,minLatency)
                                  } else {
                                    set minLatency 0
                                  } 
                                  if {[info exists fResultArray($trial,$fs,$iteration,[join "$rx_c $rx_l $rx_p" ,],$txPacketGroupId,maxLatency)]} {
                                    set maxLatency $fResultArray($trial,$fs,$iteration,[join "$rx_c $rx_l $rx_p" ,],$txPacketGroupId,maxLatency)
                                  } else {
                                    set maxLatency 0
                                  } 
                                  if {[info exists fResultArray($trial,$fs,$iteration,[join "$rx_c $rx_l $rx_p" ,],$txPacketGroupId,avgLatency)]} {
                                    set avgLatency $fResultArray($trial,$fs,$iteration,[join "$rx_c $rx_l $rx_p" ,],$txPacketGroupId,avgLatency)
                                  } else {
                                    set avgLatency 0
                                  } 
                                  lappend resList $minLatency $maxLatency $avgLatency
                                }

                                if { $calculateDataIntegrity } {
                                   lappend resList  $fResultArray($trial,$fs,$iteration,$rx_c,$rx_l,$rx_p,dataIntegrityErrors)
                                }

                                regsub ",," [join $resList ,] "," lista
                                puts $csvFid $lista
                            } ;#loop rx
                        };#loop tx
                    } ;# loop iteration
                } ;# loop fs broadband
            } ;# loop framesize wan
        } ;# loop trial
    } 

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
proc bbThroughput::WriteAggregateResultsCSV {} {
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


    set dirName $resultsDirectory

    set status $::TCL_OK;

    set testCmd [namespace current]

    set binarySearch        [expr {[$testCmd cget -searchType] == "binary"}]
    set calculateLatency    [expr {[$testCmd cget -calculateLatency] == "yes"}]
    set calculateJitter     [expr {[$testCmd cget -calculateJitter] == "yes"}]    
    set imixMode            [expr {[$testCmd cget -imixMode] == "yes"}]
    set linearSearch        [expr {[$testCmd cget -searchType] == "linear"}]
    set calculateDataIntegrity  [expr {[$testCmd cget -calculateDataIntegrity] == "yes"}]

    if {[catch {set csvFid [open $dirName/AggregateResults.csv w]}]} {
        logMsg "***** WARNING:  Cannot open AggregateResults.csv file."
        return
    }

    if {$imixMode} {
        set colHeads {"Trial"} 

        if {$linearSearch} {
            lappend colHeads "Iteration"
            set numIterations [$testCmd cget -numIterations]
        } else {
            set numIterations 1
        }

        lappend colHeads "Frame Size" "Agg Tx Tput (fps)" "Max Tx Tput (fps)"  "Agg Tx Tput Rate (%)"   

        if {$calculateLatency} {
            # Search Type - Binary / captureType - packet group/ Latency - yes / Jitter - no
            lappend colHeads "Agg Min Latency (ns)" "Agg Max Latency (ns)" "Agg Avg Latency (ns)" 
        }

        if {$calculateJitter} {
            lappend colHeads "Agg Min Inter-Arrival (ns)" "Agg Max Inter-Arrival (ns)" "Agg Avg Inter-Arrival (ns)"
        }

        if {$calculateDataIntegrity} {
            lappend colHeads "Agg Data Integrity Errors"
        }

        puts $csvFid [join $colHeads ,]  
       
        #puts "[$testCmd cget -numtrials]/[$testCmd cget -framesizeWanList]/[$testCmd cget -framesizeBroadBandList]"
        for {set trial 1 } {$trial <= [$testCmd cget -numtrials]} {incr trial} {
            if {$linearSearch} {
                set numIterations [$testCmd cget -numIterations]
                set startIteration 1
            } else {
                set numIterations $fResultArray($trial,bestIteration)
                set startIteration $fResultArray($trial,bestIteration)
            }

            for {set iteration $startIteration} {$iteration <= $numIterations } {incr iteration} {

                set fpsList {};
                set rateList {};

                foreach groupItem [lnumsort [array names groupIdArray]] {
                     set nextGroupId $groupIdArray($groupItem)
                     set aggMinLatency${nextGroupId}List {}
                     set aggMaxLatency${nextGroupId}List {}
                     set aggAvgLatency${nextGroupId}List {}
                     set fps${nextGroupId}List {}
                     set rate${nextGroupId}List {}
                }

    
                if {$linearSearch} {
                    set lstr "iter,$iteration,"
                    set istr "$iteration"
                } else {
                    set lstr ""
                    set istr ""
                }
    
                foreach txMap [lsort [array names fullMapArray]] {                        
                    scan $txMap "%d,%d,%d" tx_c tx_l tx_p                                                      
                        
                    set txPort [join "$tx_c $tx_l $tx_p" .]                       

                    if {[lsearch [array names one2manyArray] $txMap] != -1} {                        
                        set wanPort   1 
                    } else {                        
                        set wanPort   0
                    }    

                    foreach rxMap $fullMapArray($txMap) {          
                        scan $rxMap "%d %d %d" rx_c rx_l rx_p
                        set rxPort [join "$rx_c $rx_l $rx_p" .]
                        if {$wanPort} {
                            set groupIdName groupIdWanArray
                        } else {
                            set groupIdName groupIdBroadBandArray
                        }
                        foreach groupItem [lnumsort [array names $groupIdName]] {
                             set nextGroupId [set ${groupIdName}($groupItem)]
                             set globalGroupId $groupIdArray($groupItem)

                             if {[info exists fResultArray($trial,$iteration,$txMap,$nextGroupId,txThroughput)]} {
                                 lappend fps${globalGroupId}List  $fResultArray($trial,$iteration,$txMap,$nextGroupId,txThroughput)
                             } else {
                                 lappend fps${globalGroupId}List 0;
                             }

                             if {[info exists fResultArray($trial,$iteration,$txMap,$nextGroupId,txTputPercent)]} {
                                 lappend rate${globalGroupId}List $fResultArray($trial,$iteration,$txMap,$nextGroupId,txTputPercent)
                             } else {
                                 lappend rate${globalGroupId}List 0
                             }            

    
                             if {$calculateLatency || $calculateJitter} {
                                  if {[info exists fResultArray($trial,$iteration,[join "$rx_c $rx_l $rx_p" ,],$nextGroupId,minLatency)]} {
                                    lappend aggMinLatency${globalGroupId}List $fResultArray($trial,$iteration,[join "$rx_c $rx_l $rx_p" ,],$nextGroupId,minLatency)
                                  } else {
                                    lappend aggMinLatency${globalGroupId}List 0
                                  } 
                                  if {[info exists fResultArray($trial,$iteration,[join "$rx_c $rx_l $rx_p" ,],$nextGroupId,maxLatency)]} {
                                    lappend aggMaxLatency${globalGroupId}List $fResultArray($trial,$iteration,[join "$rx_c $rx_l $rx_p" ,],$nextGroupId,maxLatency)
                                  } else {
                                    lappend aggMaxLatency${globalGroupId}List 0
                                  } 
                                  if {[info exists fResultArray($trial,$iteration,[join "$rx_c $rx_l $rx_p" ,],$nextGroupId,avgLatency)]} {
                                    lappend aggAvgLatency${globalGroupId}List $fResultArray($trial,$iteration,[join "$rx_c $rx_l $rx_p" ,],$nextGroupId,avgLatency)
                                  } else {
                                    lappend aggAvgLatency${globalGroupId}List 0
                                  }                               
                             }
                            
                      }; # groupItem                         
                    } ;#loop rx
                };#loop tx

                foreach groupItem [lnumsort [array names groupIdArray]] {
                    set globalGroupId $groupIdArray($groupItem)

                    set aggFps  [passfail::ListSum  fps${globalGroupId}List]; 
                    set maxFps  [passfail::ListMax  fps${globalGroupId}List];
                    set aggRate [passfail::ListMean rate${globalGroupId}List];
                    set resList [list $trial $istr [join [split $groupItem ,] -] $aggFps $maxFps $aggRate]

                    if {$calculateLatency || $calculateJitter} {
                       set AggAvgLatency   [passfail::ListMean aggAvgLatency${globalGroupId}List] 
                       set AggMinLatency   [passfail::ListMin  aggMinLatency${globalGroupId}List] 
                       set AggMaxLatency   [passfail::ListMax  aggMaxLatency${globalGroupId}List] 
                       lappend resList $AggMinLatency $AggMaxLatency $AggAvgLatency
                    }
          
                    if { $calculateDataIntegrity } {
                        set dataIntegrityList {}
                        foreach rxMap [getRxPorts fullMapArray] {
                             scan $rxMap "%d %d %d" rx_c rx_l rx_p
                             lappend dataIntegrityList $fResultArray($trial,$iteration,$rx_c,$rx_l,$rx_p,dataIntegrityErrors)
                        }    
                        set aggDataIntegrity  [passfail::ListSum dataIntegrityList]
                        lappend resList $aggDataIntegrity
                    }

                    regsub ",," [join $resList ,] "," lista

                    puts $csvFid $lista
                }
            } ;# loop iteration    
        } ;# loop trial

    } else {

        set colHeads {"Trial" "Frame Size (bytes)"} 
    
        if {$linearSearch} {
            lappend colHeads "Iteration"
            set numIterations [$testCmd cget -numIterations]
        } else {
            set numIterations 1
        }
    
        lappend colHeads "Agg Tx Tput (fps)" "Max Tx Tput (fps)"  "Agg Tx Tput Rate (%)"   
        
        if {$calculateLatency} {
            # Search Type - Binary / captureType - packet group/ Latency - yes / Jitter - no
            lappend colHeads "Agg Min Latency (ns)" "Agg Max Latency (ns)" "Agg Avg Latency (ns)" 
        }
    
        if {$calculateJitter} {
            lappend colHeads "Agg Min Inter-Arrival (ns)" "Agg Max Inter-Arrival (ns)" "Agg Avg Inter-Arrival (ns)"
        }

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

                    if {$linearSearch} {
                        set numIterations [$testCmd cget -numIterations]
                        set startIteration 1
                    } else {
                        set numIterations $fResultArray($trial,bestIteration)
                        set startIteration $fResultArray($trial,bestIteration)
                    }
                    for {set iteration $startIteration} {$iteration <= $numIterations } {incr iteration} {
                        set fpsList {};
                        set rateList {};
                        set aggMinLatencyList {};
                        set aggMaxLatencyList {};
                        set aggAvgLatencyList {};
                    
                        if {$linearSearch} {
                            set lstr "iter,$iteration,"
                            set istr "$iteration"
                        } else {
                            set lstr ""
                            set istr ""
                        }
                   
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
    
                            if {[info exists fResultArray($trial,$fs,$iteration,$txMap,txThroughput)]} {
                                lappend fpsList  $fResultArray($trial,$fs,$iteration,$txMap,txThroughput)
                            } else {
                                lappend fpsList 0;
                            }
    
                            if {[info exists fResultArray($trial,$fs,$iteration,$txMap,txTputPercent)]} {
                                lappend rateList $fResultArray($trial,$fs,$iteration,$txMap,txTputPercent)
                            } else {
                                lappend rateList 0
                            }            
    
                            foreach rxMap $fullMapArray($txMap) {          
                                scan $rxMap "%d %d %d" rx_c rx_l rx_p
                                set rxPort [join "$rx_c $rx_l $rx_p" .]
    
                                if {$calculateLatency || $calculateJitter} {
                                      if {[info exists fResultArray($trial,$fs,$iteration,[join "$rx_c $rx_l $rx_p" ,],$txPacketGroupId,minLatency)]} {
                                        lappend aggMinLatencyList $fResultArray($trial,$fs,$iteration,[join "$rx_c $rx_l $rx_p" ,],$txPacketGroupId,minLatency)
                                      } else {
                                        lappend aggMinLatencyList 0
                                      } 
                                      if {[info exists fResultArray($trial,$fs,$iteration,[join "$rx_c $rx_l $rx_p" ,],$txPacketGroupId,maxLatency)]} {
                                        lappend aggMaxLatencyList $fResultArray($trial,$fs,$iteration,[join "$rx_c $rx_l $rx_p" ,],$txPacketGroupId,maxLatency)
                                      } else {
                                        lappend aggMaxLatencyList 0
                                      } 
                                      if {[info exists fResultArray($trial,$fs,$iteration,[join "$rx_c $rx_l $rx_p" ,],$txPacketGroupId,avgLatency)]} {
                                        lappend aggAvgLatencyList $fResultArray($trial,$fs,$iteration,[join "$rx_c $rx_l $rx_p" ,],$txPacketGroupId,avgLatency)
                                      } else {
                                        lappend aggAvgLatencyList 0
                                      }                                   
                                }                         
                            } ;#loop rx
                        };#loop tx
                        set aggFps [passfail::ListSum fpsList]; 
                        set maxFps [passfail::ListMax fpsList];
                        set aggRate [passfail::ListMean rateList];
    
                        set resList [list $trial $fs $istr $aggFps $maxFps $aggRate]
    
                        if {$calculateLatency || $calculateJitter} {
                            set AggAvgLatency   [passfail::ListMean aggAvgLatencyList] 
                            set AggMinLatency   [passfail::ListMin  aggMinLatencyList] 
                            set AggMaxLatency   [passfail::ListMin  aggMaxLatencyList] 
                            lappend resList $AggMinLatency $AggMaxLatency $AggAvgLatency
                        }

                        if { $calculateDataIntegrity } {
                            set dataIntegrityList {}
                            foreach rxMap [getRxPorts fullMapArray] {
                                 scan $rxMap "%d %d %d" rx_c rx_l rx_p
                                 lappend dataIntegrityList $fResultArray($trial,$fs,$iteration,$rx_c,$rx_l,$rx_p,dataIntegrityErrors)
                            }    
                            set aggDataIntegrity  [passfail::ListSum dataIntegrityList]
                            lappend resList $aggDataIntegrity
                        }

                        regsub ",," [join $resList ,] "," lista
                        puts $csvFid $lista
                    } ;# loop iteration
                } ;# loop fs broadband
            } ;# loop framesize wan
        } ;# loop trial
    } ;# not imix mode
    close $csvFid

    debugPuts "Leave WriteAggregateResultsCSV"
    return $status;
}

proc bbThroughput::WriteInfoCSV {} {
    variable trialsPassed

    set testCmd [namespace current]

    set ${testCmd}::trialsPassed $trialsPassed;


    ##########################################
    #
    #  Create Info CSV 
    #
    ##########################################
    
    csvUtils::writeInfoCsv $testCmd;

}

########################################################################################
# bbThroughput::collectPacketGroupStats()
#
# DESCRIPTION:  
# Populate result arrays with collected packet group statistics.
#
# ARGS:    
# TxRxArray:      fullMapArray
# PGStatistics:   Array of packet group statistics in this format:
#                 pgStatistics(statName) resultArray
#
#                 where statName is the PG statistic
#                 resultArray is the array to pass to the Results API 
#                 (as registered with Results API)
#
#                 Sample Array:
#                                   
#                 array set pgStatistics {
#                    totalFrames          rxNumFrames          
#                    averageLatency       avgLatencyValues
#                 }
#
#                 In the above sample totalFrames is the name of the
#                 packet group stat, rxNumFrames is the place to store 
#                 the PG statistic, rxNumFrames becomes a metric parameter
#                 when results save is called.
#
#
#
# RETURNS:  
# status      TCL_OK     - on success
#             TCL_ERROR  - on failure
#
########################################################################################
proc bbThroughput::collectPacketGroupStats {TxRxArray PGStatisitics GroupIdList} \
{
    debugPuts "Start collectPacketGroupStats"

    set status $::TCL_OK;

    debugPuts "Leave collectPacketGroupStats"
    return $status;
}


#############################################################################
# bbThroughput::ConfigValidate()
#
# DESCRIPTION
# This procedure verifies configuration values specified by the user.
#
# RETURNS:  
# status      TCL_OK     - on success
#             TCL_ERROR  - on failure
#
###
proc bbThroughput::ConfigValidate {} {
    debugPuts "Start ConfigValidate"

    set status $::TCL_OK;

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
proc bbThroughput::writeIterationData2CSVFile { iteration testCmd TxRxArray Framerate TputRateArray \
                               TxNumFrames TotalTxNumFrames RxNumFrames TotalRxNumFrames \
                               OLoadArray TxRateBelowLimit } {
   debugPuts "Start writeIterationData2CSVFile"

   set status $::TCL_OK;

   debugPuts "Leave writeIterationData2CSVFile"
   return $status;
}

################################################################################
#
# bbThroughput::PassFailEnable(args)
#
# DESCRIPTION:
# This procedure enables or disables bbThroughput Pass/Fail Critiera related widgets.
# This either allows the user to click on and adjust widgets or prevents this.
#
# ARGUMENTS
# args       - variable arguments
#
# RETURNS
# none
#
###
proc bbThroughput::PassFailEnable {args} {
    global calcLatency
    global calcJitter
    global passFailEnable

    set state disabled;

    set latencyState disabled;
    set jitterState disabled;

    if {$passFailEnable} {
        bbThroughput::ThroughputThresholdToggle
    
        set state enabled
        set attributeList {
            thresholdMode
        }
        renderEngine::WidgetListStateSet $attributeList $state;
    
        # only enable if Calculate Latency is checked
        if  {$calcLatency == "yes"} {
            set latencyState enabled
        }
        if  {$calcJitter == "yes"} {
            set jitterState enabled
        }
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
    
    set jitterAttributeList {
        jitterLabel 
        jitterValue 
        jitterThresholdScale 
        jitterThresholdMode
    }

    renderEngine::WidgetListStateSet $jitterAttributeList $jitterState
         #::PassFailThroughputFrameLatencyEnable    
}

################################################################################
#
# bbThroughput::ThroughputThresholdToggle(args)
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
proc bbThroughput::ThroughputThresholdToggle {args} {
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

################################################################################
#
# bbThroughput::PassFailLatencyEnable(args)
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
proc bbThroughput::PassFailLatencyEnable {args} {
    global calcLatency;
    global passFailEnable

    set state disabled;

    if {$passFailEnable} {
    if {$calcLatency == "yes"} {
        set state enabled;
    }
    }

    set attributeList {
        latencyLabel 
        latencyValue 
        latencyThresholdScale 
        latencyThresholdMode
    };
    
    #renderEngine::WidgetListStateSet $attributeList $state;
}



########################################################################
# Procedure: buildImixAdvancedSchedulerStreams
#
# This command writes the streams used for the IMIX Throughtput No Drop Rate Test
# NOTE - This proc assumes the ports are in advancedScheduler mode..
#
# Arguments(s):
#   TxRxArray           - map, ie. one2oneArray
#   TxNumFrames         - array containing the number of frames Tx'd per port
#   TxFramesPerStream   - Tx frames per group
#   testCmd             - name of test command, ie. imix
#   preambleSize
#
########################################################################
proc bbThroughput::buildImixAdvancedSchedulerStreams {TxRxArray Framerate TxNumFrames TxFramesPerStream \
                                        {testCmd imix} {preambleSize 8} {enableTimestamp true} {GroupIdArray ""} {groupIdTx 0} } \
{
    upvar $TxRxArray          txRxArray
    upvar $TxNumFrames        txNumFrames
    upvar $TxFramesPerStream  txFramesPerStream
    upvar $Framerate          framerate
    upvar $GroupIdArray       groupIdArray
   
    set retCode 0

    global tcp
    global udp 
    
    udf setDefault
    stream setDefault
    filter setDefault
    filterPallette setDefault
    
    disableUdfs {1 2 3 4}

    set calculateJitter  [expr {![string compare [$testCmd cget -calculateJitter] yes]}]     
    set calculateLatency [expr {![string compare [$testCmd cget -calculateLatency] yes]}]
    set calculateDataIntegrity [expr {![string compare [$testCmd cget -calculateDataIntegrity] yes]}]

    set wanVlan [expr {![string compare [$testCmd cget -enableServerVLAN] true]}]
    set broadbandVlan [expr {![string compare [$testCmd cget -enableClientVLAN] true]}]

    set crcPacketSize           $broadband::crcPacketSize
    set latencyStampSize        $broadband::latencyStampSize        
    set crcDataIntegritySize    $broadband::crcDataIntegritySize
    set udfSize                 $broadband::udfSize
    set packetGroupIdSize       $broadband::packetGroupIdSize
    set dataIntegritySize       $broadband::dataIntegritySize

    set protocolName        [getProtocolName [protocol cget -name]]
    set smallestFrameSize   [lindex [lindex [lnumsort [$testCmd cget -framesizeList]] 0] 0]
 
    # For UDP packets the min PG signiture id/offset is 42.
    # For TCP packets the min PG signiture id/offset is 54. 
    # In order to tx and rx tcp packet with time stamp enabled, we need to have min framesize of 70 bye 
    # otherwise the timestamp will overlap with signiture or id
    # If min framesize is 64 and there are any tcp packets in imixList, then we can't use PG signiture
    # on tx side, and on rx side we need to point the the PG offset to packet's source IP address.
    # But if we have all udp packets, we can use PG on tx and rx side by using PG signiture/pattern.
    # If we have mixture of tcp and udp packets, then min framesize that we can have would be 70,
    # since no matter what the packet type or size is, everything would be based on the min framesize,
    # which may not be valid for tcp packets, that is why we have to use source IP address as rx PG signiture,
    # to be able to tx and rx min of 64 tcp byte packets.
    # So here are the conditions:
    # Only udp packets          - use packet group on both side
    # All frames are >= 70      - use packet group on both side
    # Other cases               - use IP source address as rx PG signiture 

    set udpPacketCount      0
    set otherPacketCount    0
    set packetGroupFlag     1  
    set rxVlanFillterOffset 0

    set packetGroupIdOffset 54   ;# Packet group signiture offset fro TCP    

    foreach {fsOption rate} [join [$testCmd cget -imixList]] {                
        set fs              [getImixFramesize    $fsOption]
        set ipProtocol      [getImixIpProtocol   $fsOption]
        if {$fs >= 64 && $ipProtocol == "udp"} {
            incr udpPacketCount
        } else {
            incr otherPacketCount
        }
    }

    if {$udpPacketCount == [llength [$testCmd cget -imixList]]} {
        #set packetGroupOffset       [expr $smallestFrameSize - 2]
        set packetGroupIdOffset     42          ;# Packet group signiture offset fro all UDP
        set packetGroupFlag         0           ;# All udp packets       
    } else {
        if {$smallestFrameSize >= 70 } {
            set packetGroupFlag     0           ;# No timestamp overlapping
        }
    }
    
    set packetGroupOffset   [expr $packetGroupIdOffset + 2]
  
    if {![info exists groupIdArray]} {      
        getGroupIds groupIdArray
    }
    
    debugMsg " buildImixAdvancedSchedulerStreams: groupIdArray [array get groupIdArray]"
    
    if [catch {llength [$testCmd cget -priorityPattern]} numPriorities] {
        set numPriorities  1
    }
    if [catch {$testCmd cget -priorityPattern} priorityPattern] {
        set priorityPattern {0}
    }
    set priorityCounter 0

    stream config -gapUnit          gapNanoSeconds
    stream config -numFrames        1
    stream config -enableTimestamp  $enableTimestamp
    stream config -loopCount        1
    stream config -dma              stopStream

  
    # Initialize test local variables for each Tx port configured on each card on all chassis
    foreach txMap [lnumsort [array names txRxArray]] {
        scan $txMap "%d,%d,%d" tx_c tx_l tx_p

        set txNumFrames($tx_c,$tx_l,$tx_p)  0
        set streamID                        1

        utils::FlexibleTimeStampOffsetMove $smallestFrameSize $tx_c $tx_l $tx_p;

        set numRxPorts [llength $txRxArray($tx_c,$tx_l,$tx_p)]

        foreach rxMap $txRxArray($tx_c,$tx_l,$tx_p) {
            scan [join $rxMap] "%d %d %d" rx_c rx_l rx_p
        
            logMsg "Configuring [getPortId $tx_c $tx_l $tx_p] -> [getPortId $rx_c $rx_l $rx_p]"

            set priorityIndex   [expr ($priorityCounter) % $numPriorities]
            set ipDefaultPrecedence    [lindex  $priorityPattern $priorityIndex]

            utils::FlexibleTimeStampOffsetMove $smallestFrameSize $rx_c $rx_l $rx_p;
            getProtocolArray protocolArray $testCmd
            foreach {fsOption rate} [join [$testCmd cget -imixList]] {                
                set fs              [getImixFramesize    $fsOption]
                set ipProtocol      [getImixIpProtocol   $fsOption]
                if {$groupIdTx} {                    
                    set groupID         $groupIdArray($txMap,$fs,$ipProtocol)
                } else {
                    set groupID         $groupIdArray($fs,$ipProtocol)
                }
                
                debugMsg "fsOption: fsOption, rate:$rate"       

                set ipPrecedence  [getImixIpPrecedence $fsOption]
                if {$ipPrecedence == ""} {
                    set ipPrecedence    $ipDefaultPrecedence
                }

                stream config -framesize    $fs
            
                if [catch {$testCmd cget -rateSelect} rateSelect] {
                    set rateSelect percentMaxRate
                }     

                # make the rate in the array relative the the percentMaxRate
                                
                switch $rateSelect {
                    percentMaxRate {

                       if [catch {mpexpr ($rate*[$testCmd cget -${rateSelect}]/100.)} rate] {
                           set rate    100
                       }
                       stream config -percentPacketRate [mpexpr $rate/$numRxPorts]
                       stream config -rateMode $::streamRateModePercentRate                       
                    }
                    kbpsRate {
                        set maxRateFS [calculateMaxRate $tx_c $tx_l $tx_p $fs]
                        if [catch {mpexpr ($rate*[$testCmd cget -${rateSelect}]/100)} rate] {
                               set rate  [mpexpr {$maxRateFS*$rate}]                               
                        }                        
                        set rate [mpexpr {$rate*1000/$numRxPorts}]                        
                        stream config -bpsRate $rate                        
                        stream config -rateMode $::streamRateModeBps                        
                    }
                    fpsRate {
                        set maxRateFS [calculateMaxRate $tx_c $tx_l $tx_p $fs]
                        if [catch {mpexpr ($rate*[$testCmd cget -${rateSelect}]/100)} rate] {
                               set rate  [mpexpr {$maxRateFS*$rate}]
                        }
                        stream config -fpsRate [mpexpr $rate/$numRxPorts]
                        stream config -rateMode $::streamRateModeFps                        
                    }
                }
                set rate [stream cget -percentPacketRate]
                  
                if [buildStreamParms  $protocolName "advancedImix$fs" $tx_c $tx_l $tx_p $rx_c $rx_l $rx_p] {
                    set retCode 1
                    continue
                }

                stream config -patternType repeat
                stream config -dataPattern allZeroes
                stream config -pattern     "00 00"

                # Configure ip protocol
                if [ip get $tx_c $tx_l $tx_p] {
                    errorMsg "Error getting IP on [getPortId $tx_c $tx_l $tx_p]"
                    set retCode 1
                    continue
                }                         
                debugMsg "ipProtocol:$ipProtocol"

                if { ([lsearch [array names protocolArray] $ipProtocol] != -1) } {

                    debugMsg "protocol:[getProtocol protocolArray $ipProtocol $testCmd]"
                    debugMsg "source  :[getSourcePort protocolArray $ipProtocol $testCmd]"
                    debugMsg "dest    :[getDestPort protocolArray $ipProtocol $testCmd]"

                    if { [getProtocol protocolArray $ipProtocol $testCmd] == "tcp" } {
                        if [tcp get $tx_c $tx_l $tx_p] {
                            errorMsg "Error getting tcp on [getPortId $tx_c $tx_l $tx_p]"
                            set retCode 1
                            continue
                        }

                        tcp config -sourcePort [getSourcePort protocolArray $ipProtocol $testCmd]
                        tcp config -destPort   [getDestPort   protocolArray $ipProtocol $testCmd] 

                        if [tcp set $tx_c $tx_l $tx_p] {
                            errorMsg "Error setting tcp on [getPortId $tx_c $tx_l $tx_p]"
                            set retCode 1
                            continue
                        }
                        ip config -ipProtocol $tcp
                    } elseif {[getProtocol protocolArray $ipProtocol $testCmd] == "udp" } { 
                        if [udp get $tx_c $tx_l $tx_p] {
                            errorMsg "Error getting tcp on [getPortId $tx_c $tx_l $tx_p]"
                            set retCode 1
                            continue
                        }

                        udp config -sourcePort [getSourcePort protocolArray $ipProtocol $testCmd]
                        udp config -destPort   [getDestPort   protocolArray $ipProtocol $testCmd] 

                        if [udp set $tx_c $tx_l $tx_p] {
                            errorMsg "Error setting tcp on [getPortId $tx_c $tx_l $tx_p]"
                            set retCode 1
                            continue
                        }
                        ip config -ipProtocol $udp
                    } else {
                        ip config -ipProtocol [getProtocol protocolArray $ipProtocol $testCmd]
                    }

                } else {
                    # Default it to UDP with default if the protocol does not exist
                    udp setDefault
                    if [udp set $tx_c $tx_l $tx_p] {
                        errorMsg "Error setting tcp on [getPortId $tx_c $tx_l $tx_p]"
                        set retCode 1
                        continue
                    }
                    ip config -ipProtocol $udp                            
                }

                ip config -precedence $ipPrecedence


                if {[ip set $tx_c $tx_l $tx_p]} {
                    errorMsg "Error setting IP on [getPortId $tx_c $tx_l $tx_p]"
                    set retCode 1
                }
                stream config -name [format "%s_%s/%s" "advancedImix$fs" $ipProtocol $protocolName]

                
                setVlanOnStream $testCmd "$tx_c.$tx_l.$tx_p" rxVlanFillterOffset

                # set the stream once so that we can get the framerate out of it for numFrames 
                if {[streamSet $tx_c $tx_l $tx_p $streamID]} {
                    set retCode 1
                    continue
                }

                configAddressesPerStream "$tx_c.$tx_l.$tx_p" "$rx_c.$rx_l.$rx_p" $streamID bbThroughput

                set numFrames [mpexpr [stream cget -floatRate]*[$testCmd cget -duration]]
                if {$numFrames < 1} {
                    set numFrames   1
                }

                # Note: The maximum numFrames is advanced scheduler is same as the max regular loopcount,
                # we just want to set numFrames to the maximum number if it is big
                # Set loopcountMultiple 1 for the loopcount, since in OC48 there is no loop count, just packet count
                set  loopcountMultiple 1
                adjustStreamNumFramesAndLoopCount loopcountMultiple numFrames
                if { $loopcountMultiple >1 } {
                    set newRate    [mpexpr double($rate)/$loopcountMultiple]
                    
                    stream config -percentPacketRate    $newRate 
                    stream config -rateMode $::streamRateModePercentRate

                    if {[streamSet $tx_c $tx_l $tx_p $streamID]} {
                        set retCode 1
                        continue
                    }
                    set numFrames [mpexpr [stream cget -floatRate]*[$testCmd cget -duration]]
                    if {$numFrames < 1} {
                        set numFrames   1
                    }
                }    

                # Get the rate for the smallest framesize
                if {$fs == $smallestFrameSize } {
                    set framerate($tx_c,$tx_l,$tx_p)    [stream cget -floatRate]
                }
                stream config -numFrames [mpexpr round($numFrames)]

                # This is done when we have limitation for the advanced scheduler stream packet count
                # If we run longer duration for the smallest frame size, we need to generate more streams
                # in order to achive the tx duration we want and total number of packet count is devided 
                # among the streams generated for the same frame size.

                set txVlanDelta 0
                set rxVlanDelta 0

                if {[IsWanPort $tx_c $tx_l $tx_p]} {
                    if {$wanVlan} {
                        set txVlanDelta 4
                    }
                } else {
                    if {$broadbandVlan} {
                        set txVlanDelta 4
                    }
                }

                 if {[IsWanPort $rx_c $rx_l $rx_p]} {
                    if {$wanVlan} {
                        set rxVlanDelta 4
                    }
                } else {
                    if {$broadbandVlan} {
                        set rxVlanDelta 4
                    }
                }
#logMsg " tx packetGroupIdOffset:$packetGroupIdOffset / packetGroupOffset:$packetGroupOffset / txVlanDelta:$txVlanDelta / "

                for {set newStreamIndex 1} { $newStreamIndex <= $loopcountMultiple} {incr  newStreamIndex} {

                    if {$enableTimestamp == "true" && $packetGroupFlag} {
                        # PGID
                        udf setDefault
                        udf config -enable      true
                        udf config -offset      [expr $packetGroupIdOffset + $txVlanDelta]
                        udf config -initval     [format "%04x" $groupID]
                        udf config -counterMode     udfCounterMode
                        udf config -countertype     c16
                        udf config -random      false
                        udf config -continuousCount false
                        udf config -repeat      1

                        if [udf set 2] {
                            errorMsg "Error setting UDF 2"
                            set retCode 1
                        } 
                    } else {           
                        # fixing the offset signature
                        set signature  [list db [format %02x $rx_c] [format %02x $rx_l] [format %02x $rx_p]]                     
                        packetGroup config -signatureOffset [expr $packetGroupOffset + $txVlanDelta]
                        packetGroup config -signature       $signature
                        packetGroup config -insertSignature true
                        packetGroup config -groupId $groupID
                        packetGroup config -groupIdOffset [expr $packetGroupIdOffset + $txVlanDelta]

                        if {$calculateDataIntegrity} {
                            
                            dataIntegrity setDefault                              
                            dataIntegrity config -enableTimeStamp $enableTimestamp
                            dataIntegrity config -signatureOffset [packetGroup cget -signatureOffset] 
                            dataIntegrity config -insertSignature true
                            dataIntegrity config -signature       [packetGroup cget -signature]
                            if [dataIntegrity setTx $tx_c $tx_l $tx_p $streamID ] {
                                errorMsg "Error setting Tx dataIntegrity on [getPortId $tx_c $tx_l $tx_p]"
                                set retCode 1
                            }

                        }


                        #setupPacketGroup $packetGroupOffset $rx_c $rx_l $rx_p $groupID
                        if [packetGroup setTx $tx_c $tx_l $tx_p $streamID] {
                            errorMsg "Error setting Tx packetGroup on [getPortId $tx_c $tx_l $tx_p]"
                            set retCode 1
                            continue
                        }
                    }

                    if {[$testCmd exists enableDataIntegrity] && [$testCmd cget -enableDataIntegrity] == "true"} {
                        setupDataIntegrity $dataIntegrityOffset $rx_c $rx_l $rx_p $dataIntegrityOffset
                        if [dataIntegrity setTx $tx_c $tx_l $tx_p $streamID] {
                            errorMsg "Error setting Tx dataIntegrity on [getPortId $tx_c $tx_l $tx_p]"
                            set retCode 1
                        }
                    }


                    if [streamSet $tx_c $tx_l $tx_p $streamID] {
                        set retCode 1
                        continue
                    }
 
                    if [info exists txFramesPerStream($tx_c,$tx_l,$tx_p,$groupID)] {
                        mpincr txFramesPerStream($tx_c,$tx_l,$tx_p,$groupID)  [stream cget -numFrames]
                    } else {
                        set txFramesPerStream($tx_c,$tx_l,$tx_p,$groupID)   [stream cget -numFrames]
                    }

                    mpincr txNumFrames($tx_c,$tx_l,$tx_p) [mpexpr [stream cget -numFrames] * [stream cget -loopCount]]

                    incr streamID
                }
            }


            # This changes are done to support 64 byte Tcp packets
            if {$enableTimestamp == "true" && $packetGroupFlag } {                      
                set packetView          [stream cget -packetView]
                set sourceIpAddr        [host2addr [ip cget -sourceIpAddr]]
                set pgSignitureOffset   [expr [string first $sourceIpAddr $packetView]/3] 

                # pgSignitureOffset is pointing to source ip address, destination can't be use because
                # of numRxAddresses 
                packetGroup config -signatureOffset $pgSignitureOffset
                packetGroup config -signature       $sourceIpAddr
                packetGroup config -insertSignature true

                # add setting of groupIdOffset because it remains from the old configurations
                packetGroup config -groupIdOffset [expr $packetGroupIdOffset + $rxVlanDelta]

            } else {
                #fixing the groupSignatureOffset position
                set signature  [list db [format %02x $rx_c] [format %02x $rx_l] [format %02x $rx_p]]                     
                packetGroup config -signatureOffset [expr $packetGroupOffset + $rxVlanDelta]
                packetGroup config -signature       $signature
                packetGroup config -insertSignature true
                packetGroup config -groupIdOffset [expr $packetGroupIdOffset + $rxVlanDelta]

                #setupPacketGroup $packetGroupOffset $rx_c $rx_l $rx_p
            }

            if {$calculateDataIntegrity} {                
                dataIntegrity setDefault                              
                dataIntegrity config -signatureOffset [packetGroup cget -signatureOffset]
                dataIntegrity config -signature       [packetGroup cget -signature]
                dataIntegrity config -enableTimeStamp $enableTimestamp                
                if [dataIntegrity setRx $rx_c $rx_l $rx_p] {
                    errorMsg "Error setting Rx dataIntegrity on [getPortId $rx_c $rx_l $rx_p]"
                    set retCode 1
                }
            }

            if {[catch {$testCmd cget -latencyTypes} latencyTypes]} {
                set latencyTypes "cutThrough"
            } 

            packetGroup config -latencyControl $latencyTypes

            if [packetGroup setRx $rx_c $rx_l $rx_p] {
                errorMsg "Error setting Rx packetGroup on [getPortId $rx_c $rx_l $rx_p]"
                set retCode 1
            }
         
            incr priorityCounter

            filterPallette config -pattern1             [packetGroup cget -signature]         
            filterPallette config -patternOffset1       [packetGroup cget -signatureOffset]  
            filterPallette config -DAMask1               "00 00 00 00 00 FF"                

            if [filterPallette set $rx_c $rx_l $rx_p] {
                errorMsg "Error setting filter pallette for [getPortId $rx_c $rx_l $rx_p]"
                set retCode 1
                continue
            }

            # set the filter parameters on the receive port
            filter config -userDefinedStat2Pattern      pattern1

            if [filter set $rx_c $rx_l $rx_p] {
                errorMsg "Error setting filters on [getPortId $rx_c $rx_l $rx_p]"
                set retCode 1
                continue
            }
        }
    }
    debugMsg "buildImixAdvancedSchedulerStreams:txNumFrames:[array get txNumFrames]"
    debugMsg "buildImixAdvancedSchedulerStreams:txFramesPerStream:[array get txFramesPerStream]"
    
    return $retCode
}


########################################################################
# Procedure: writeMixedInterfaceStreams
#
# This command writes the streams used for the IMIX Throughtput No Drop Rate Test
# NOTE - This proc assumes the ports are in advancedScheduler mode..
#
# Arguments(s):
#   TxRxArray           - map, ie. one2oneArray
#   TxNumFrames         - array containing the number of frames Tx'd per port
#   TxFramesPerStream   - Tx frames per group
#   testCmd             - name of test command, ie. imix
#   preambleSize
#
########################################################################
proc bbThroughput::writeMixedInterfaceStreams {TxRxArray Framerate TxNumFrames TxFramesPerStream {write write} \
                                {testCmd imix} {preambleSize 8} {GroupIdArray ""} {groupIdTx 0} } \
{
    upvar $TxRxArray          txRxArray
    upvar $TxNumFrames        txNumFrames
    upvar $TxFramesPerStream  txFramesPerStream
    upvar $Framerate          framerate
    upvar $GroupIdArray       groupIdArray  

    set retCode 0

    if [info exists txFramesPerStream] {
        unset txFramesPerStream
    }

    #puts "bbThroughput::writeMixedInterfaceStreams [$testCmd cget -rateSelect] groupIdArray"

    getAdvancedSchedulerArray txRxArray advancedSchedulerArray otherArray

    if {[llength [array get advancedSchedulerArray]] > 0} {
        if [bbThroughput::buildImixAdvancedSchedulerStreams advancedSchedulerArray framerate \
                        txNumFrames txFramesPerStream $testCmd $preambleSize true groupIdArray $groupIdTx] {
            set retCode 1
        }
    }

    if {[llength [array get otherArray]] > 0} {
        if [buildImixTpndrStreams otherArray framerate txNumFrames txFramesPerStream $testCmd $preambleSize] {
            set retCode 1
        }
    }

    debugMsg " ****  - txFramesPerStream: [array get txFramesPerStream]"
    debugMsg " ****  - txNumFrames: [array get txNumFrames]"

    if {$retCode == 0 && $write == "write"} {
        adjustOffsets           txRxArray
        writeConfigToHardware   txRxArray
    }

    return $retCode
}


########################################################################
# Procedure: bbThroughput::doBinarySearch
#
# This command performs a binary search.  
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
proc bbThroughput::doBinarySearch { \
        testCmd TxRxArray FullMapArray Framerate TputRateArray \
        TxNumFrames TotalTxNumFrames RxNumFrames TotalRxNumFrames PercentMaxRate \
        {multiTxStream no} {LossPercent ""} {AvgLatency "" } {StdDeviation "" } {NumAddressesPerStream ""} {BestIteration ""}} \
{
    global ixgJitterIndex

    upvar $FullMapArray     fullMapArray
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
    upvar $Framerate        localFramerate
    upvar $PercentMaxRate   localPercentMaxRate
    upvar $BestIteration    localBestIteration

    # This is needed to prevent the value of frameRate 
    # from being changed in this function
    array set framerate [array get localFramerate]
    set bestIteration 0

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
            if {[IsWanPort $tx_c $tx_l $tx_p]} {
                set percentMaxRate($tx_c,$tx_l,$tx_p)   [$testCmd cget -percentMaxWanRate]
            } else {
                set percentMaxRate($tx_c,$tx_l,$tx_p)   [$testCmd cget -percentMaxBroadBandRate]
            }
            
        }
    } else {
        array set percentMaxRate [array get localPercentMaxRate]
    }

    set retCode $::TCL_OK
    set jitterOnceOption no

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
     
    if {$NumAddressesPerStream == ""} {
        set numRxPortsPerStream 1 
    } else {
        set numRxPortsPerStream $numAddressesPerStream(1)
    }

    # make txRxArray list of rx-->tx so that we can count the total sent tx-->rx
    if {$multiTxStream == "no"} {
        swapPortList txRxArray rxTxArray
        countTxRxFrames rxTxArray txNumFrames txRxFrames $multiTxStream $testCmd
    } else {
        countTxRxFrames txRxArray txNumFrames txRxFrames $multiTxStream $testCmd $numRxPortsPerStream
    }

    # set the high and low indices for binary search algorithm
    foreach txMap $txPortList {
        scan $txMap "%d %d %d" tx_c tx_l tx_p
   
        if {[info exists tputRateArray($tx_c,$tx_l,$tx_p)]} {
            set best($tx_c,$tx_l,$tx_p)         $tputRateArray($tx_c,$tx_l,$tx_p)
        } else {
            set best($tx_c,$tx_l,$tx_p)         0
        }
        set high($tx_c,$tx_l,$tx_p)             $percentMaxRate($tx_c,$tx_l,$tx_p)
        set low($tx_c,$tx_l,$tx_p)              $lossPercent
        set advancedPortFlag($tx_c,$tx_l,$tx_p) 0
        set bestTputPercentRate($tx_c,$tx_l,$tx_p)  $percentMaxRate($tx_c,$tx_l,$tx_p)
    }

    foreach rxMap [getRxPorts txRxArray] {
        scan $rxMap "%d %d %d" rx_c rx_l rx_p
        set txStart($rx_c,$rx_l,$rx_p)      $txRxFrames($rx_c,$rx_l,$rx_p)
    }

    set doneList    [getTxPorts txRxArray]

    set iteration 1

    # the binary search procedure is called from outside after the first streams configurations  
    #
    # start binary search
    while {[llength $doneList] > 0} {
        # setup for transmitting
        logMsg "\n---> BINARY ITERATION $iteration,$trialStr Framesize Upstream:[set ${testCmd}::framesizeBroadBand],Framesize Downstream:[set ${testCmd}::framesizeWan], [$testCmd cget -testName]" 
        debugMsg "\n---> BINARY ITERATION $iteration,$trialStr framesize: $framesize, [$testCmd cget -testName]" 


# Exit point - verify if the Tx framerate is lower than minimus FPS

        set txRateBelowLimit 0
       
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
                set tputPercentRate($tx_c,$tx_l,$tx_p) $percentMaxRate($tx_c,$tx_l,$tx_p)
                set doneList {} 
                set bestIteration $iteration
#puts "Best Iteration .... $iteration"
            }
        }      

# sending traffic
# txRxArray
        if {[clearStatsAndTransmit fullMapArray [$testCmd cget -duration] [$testCmd cget -staggeredStart] yes avgRunningRate]} {
            return $::TCL_ERROR
        }

        waitForResidualFrames [$testCmd cget -waitResidual]

        # Poll the Tx counters until all frames are sent txRxArray
        stats::collectTxStats [getTxPorts fullMapArray] txNumFrames txActualFrames totalTxNumFrames
        collectRxStats [getRxPorts fullMapArray]  rxNumFrames totalRxNumFrames 

        array set tempRxNumFrames [array get rxNumFrames]

        ${testCmd}::ComputeBinaryIterationResults  txActualFrames $totalTxNumFrames tempRxNumFrames $totalRxNumFrames percentMaxRate $iteration sentFrames receivedFrames
        ${testCmd}::ShowIterationResults $iteration

        debugMsg "totalRxNumFrames:$totalRxNumFrames"

        ### diplay the result according to the rateSelect option of the testCmd
        if {[catch {$testCmd cget -rateSelect} outputType]} {
            array set OLoadArray [array get framerate]
            set OLoadHeaderString OLoad(fps)
        } else {
            switch $outputType {
                "fpsRate" -
                "percentMaxRate" {
                    array set OLoadArray [array get framerate]
                    set OLoadHeaderString OLoad(fps)
                } 
                "kbpsRate" {
                    rateConversionUtils::convertLoadRates txRxArray OLoadArray OLoadHeaderString $outputType framerate fpsRate $framesize
                    set OLoadHeaderString OLoad(kbps)
                }
            }
        }
       
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
            
        ${testCmd}::writeIterationData2CSVFile $iteration $testCmd txRxArray framerate tputRateArray \
                                           txNumFrames totalTxNumFrames rxNumFrames totalRxNumFrames \
                                           OLoadArray txRateBelowLimit       

        set warnings ""

        # don't use the transmit times if it's a staggered start!!!!
        if {[$testCmd cget -staggeredStart] == "staggeredStart" || [$testCmd cget -staggeredStart] == "true"} {
            foreach txMap [getTxPorts txRxArray] {
                scan $txMap "%d %d %d" tx_c tx_l tx_p
                set durationArray($tx_c,$tx_l,$tx_p)    [$testCmd cget -duration]
            }
        } else {
            getTransmitTime txRxArray [$testCmd cget -duration] durationArray warnings
        }

        if {$linearBinarySearch == "false"} {

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

                set txMode    [port cget -transmitMode]
                if {$txMode == $::portTxModeAdvancedScheduler} {
                    set advancedPortFlag($tx_c,$tx_l,$tx_p) 1
                }
                

                foreach rxMap $txRxArray($tx_c,$tx_l,$tx_p) {
                    scan $rxMap "%d %d %d" rx_c rx_l rx_p
                    debugMsg ">>>>>> txRxFrames($rx_c,$rx_l,$rx_p):$txRxFrames($rx_c,$rx_l,$rx_p),rxNumFrames($rx_c,$rx_l,$rx_p):$rxNumFrames($rx_c,$rx_l,$rx_p)"
                
                    set percentLoss   [calculatePercentLossExact $sentFrames($tx_c,$tx_l,$tx_p) $receivedFrames($tx_c,$tx_l,$tx_p)]

                    if {$rxNumFrames($rx_c,$rx_l,$rx_p) == 0} {
                        debugMsg ">>>>>> rxNumFrames($rx_c,$rx_l,$rx_p) == 0 "
                        set overalStatus zero
                        break
                    } elseif {$receivedFrames($tx_c,$tx_l,$tx_p) == $txStart($rx_c,$rx_l,$rx_p)} {
                        debugMsg ">>>>>> receivedFrames($tx_c,$tx_l,$tx_p) == txStart($rx_c,$rx_l,$rx_p) ($receivedFrames($tx_c,$tx_l,$tx_p) != $txStart($rx_c,$rx_l,$rx_p))"
                        # do nothing
                    } elseif {$receivedFrames($tx_c,$tx_l,$tx_p) != $sentFrames($tx_c,$tx_l,$tx_p) && ($percentLoss > $tolerance)} {
                        debugMsg ">>>>>> receivedFrames($tx_c,$tx_l,$tx_p) != sentFrames($tx_c,$tx_l,$tx_p) ($receivedFrames($tx_c,$tx_l,$tx_p) != $sentFrames($tx_c,$tx_l,$tx_p))&& ($percentLoss > $tolerance)) "
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

            switch $overalStatus {
                zero -
                done -
                equal {
                    set bestIteration $iteration
                }
            }

            foreach txMap $portList {
                scan $txMap "%d %d %d" tx_c tx_l tx_p

                switch $overalStatus {
                    zero {
                        set tputRateArray($tx_c,$tx_l,$tx_p)     0
                        set tputPercentRate($tx_c,$tx_l,$tx_p)   0
                    }
                    done {
                        set best($tx_c,$tx_l,$tx_p)          $framerate($tx_c,$tx_l,$tx_p)
                        set bestTputPercentRate($tx_c,$tx_l,$tx_p) $percentMaxRate($tx_c,$tx_l,$tx_p)

                        set tputRateArray($tx_c,$tx_l,$tx_p) $framerate($tx_c,$tx_l,$tx_p)                        
                    }
                    equal {
                        set best($tx_c,$tx_l,$tx_p)                $framerate($tx_c,$tx_l,$tx_p)
                        set bestTputPercentRate($tx_c,$tx_l,$tx_p) $percentMaxRate($tx_c,$tx_l,$tx_p)

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

        if {[catch {$testCmd cget -largePortCount} largePortCount]} {
            set largePortCount false
        }

# update the rates

        ${testCmd}::updateNextIterationRate txRxArray percentMaxRate txNumFrames newFramerate
         
        foreach txMap $portList {
            scan $txMap "%d %d %d" tx_c tx_l tx_p
            debugMsg "txMap:$txMap"
            debugMsg "*** percentMaxRate($tx_c,$tx_l,$tx_p) = $percentMaxRate($tx_c,$tx_l,$tx_p)  newFramerate($tx_c,$tx_l,$tx_p) = $newFramerate($tx_c,$tx_l,$tx_p)"

            if { ($newFramerate($tx_c,$tx_l,$tx_p)   <= $best($tx_c,$tx_l,$tx_p))      || \
                    ($newFramerate($tx_c,$tx_l,$tx_p)   == $framerate($tx_c,$tx_l,$tx_p)) || \
                    ($percentMaxRate($tx_c,$tx_l,$tx_p) >= $high($tx_c,$tx_l,$tx_p))} {

                set tputRateArray($tx_c,$tx_l,$tx_p) $best($tx_c,$tx_l,$tx_p)
                set tputPercentRate($tx_c,$tx_l,$tx_p) $bestTputPercentRate($tx_c,$tx_l,$tx_p)
                set indx [lsearch $doneList [list $tx_c $tx_l $tx_p]]
                
#puts "Best Iteration .... $iteration / $tx_c $tx_l $tx_p"
                if {$indx != -1} {
                    set doneList [lreplace $doneList $indx $indx]
                }
                debugMsg "DONE $tx_c,$tx_l,$tx_p, tputRateArray = $tputRateArray($tx_c,$tx_l,$tx_p)"
                continue
            }

            set framerate($tx_c,$tx_l,$tx_p) $newFramerate($tx_c,$tx_l,$tx_p) 
            
        }

        incr iteration
        protocol config -enable802dot1qTag $enable802dot1qTag 
   }

    copyPortList txActualFrames txNumFrames 
    
    set localBestIteration  $bestIteration

    catch {unset localPercentMaxRate}
    array set localPercentMaxRate [array get tputPercentRate]
    
    return $retCode
}

#######################################################################################
#
#
#
#
#
###################################
proc bbThroughput::updateNextIterationRate { TxRxArray PercentMaxRate TxNumFrames Framerate {testCmd bbThroughput}} {     
    upvar $TxRxArray        txRxArray
    upvar $PercentMaxRate   percentMaxRate
    upvar $TxNumFrames      txNumFrames
    upvar $Framerate        framerate

   
   if {[$testCmd cget -imixMode]=="yes"} {
        return [updateImixNextIterationRate txRxArray percentMaxRate txNumFrames framerate $testCmd]
   }

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


#######################################################################################
#
#
#
#
#
###################################
proc bbThroughput::updateImixNextIterationRate { TxRxArray PercentMaxRate TxNumFrames Framerate {testCmd bbThroughput}} {     
    upvar $TxRxArray        txRxArray
    upvar $PercentMaxRate   percentMaxRate
    upvar $TxNumFrames      txNumFrames
    upvar $Framerate        framerate
    variable txWanFramesPerStream
    variable txBroadBandFramesPerStream
    variable s_many2oneArray
    variable txGroupIdBroadBandArray
    variable groupIdBroadBandArray
    variable groupIdWanArray
    variable directions

   catch {unset framerate}

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

    if {$binaryDirection=="downstream"} {

       set txMap [lindex [lnumsort [array names txRxArray]] 0]
       set currentWanPercentRate $percentMaxRate($txMap)

       $testCmd config -rateSelect percentMaxRate
       $testCmd config -percentMaxRate $currentWanPercentRate 
    
       $testCmd config -imixList [$testCmd cget -imixWanList]
       $testCmd config -framesizeList [$testCmd cget -framesizeWanList]
    
       if [${testCmd}::writeMixedInterfaceStreams txRxArray  framerateWan txWanNumFrames txWanFramesPerStream write $testCmd 8 groupIdWanArray] {
           return $::TCL_ERROR
       }
    
       
       foreach element [array names groupIdWanArray] {
           set fsMatrix($groupIdWanArray($element))  [lindex [split $element ,] 0]
       }
    
       
       array set framerate         [array get framerateWan]
       array set txNumFrames       [array get txWanNumFrames]
       array set txFramesPerStream [array get txWanFramesPerStream]
    
       foreach txMap [array names one2manyArray] {
           set thruputRate($txMap) 0
       }
    
       foreach txMap [array names one2manyArray] {
           scan $txMap "%d,%d,%d" tx_c tx_l tx_p
           foreach groupId [array names fsMatrix] {
              set fs $fsMatrix($groupId)
              set thruputRate($txMap) [mpexpr {$thruputRate($txMap)+($txFramesPerStream($txMap,$groupId)*100.0/[calculateMaxRate $tx_c $tx_l $tx_p $fs])}]
           }            
           set thruputRate($txMap) [mpexpr {$thruputRate($txMap)/[$testCmd cget -duration]}]
           set framerate($txMap) [mpexpr {$txWanNumFrames($txMap)/[$testCmd cget -duration]}]            
       }
       #parray framerate
   } elseif {$binaryDirection=="upstream"} {
       set txMap [lindex [lnumsort [array names txRxArray]] 0]
       set currentBroadBandPercentRate $percentMaxRate($txMap)

       $testCmd config -rateSelect percentMaxRate
       $testCmd config -percentMaxRate $currentBroadBandPercentRate 

       $testCmd config -imixList [$testCmd cget -imixBroadBandList]
       $testCmd config -framesizeList [$testCmd cget -framesizeBroadBandList]      

       if [[namespace current]::writeMixedInterfaceStreams s_many2oneArray  framerateBroadBand txBroadBandNumFrames txBroadBandFramesPerStream write $testCmd 8 txGroupIdBroadBandArray 1] {
           return $::TCL_ERROR
       }

       array set framerate         [array get framerateBroadBand]
       array set txNumFrames       [array get txBroadBandNumFrames]

       #array set txFramesPerStream [array get txBroadBandFramesPerStream]         

       catch {unset tempTxFramesPerStream}
       foreach txMap [array names s_many2oneArray] {
           scan $txMap  "%d,%d,%d" tx_c tx_l tx_p 
           foreach groupItem [lnumsort [array names groupIdBroadBandArray]] {
                set txGroupId   $txGroupIdBroadBandArray($txMap,$groupItem)
                set nextGroupId $groupIdBroadBandArray($groupItem)
                set tempTxFramesPerStream($txMap,$nextGroupId)  $txBroadBandFramesPerStream($txMap,$txGroupId)
           }
       }

       catch {unset txBroadBandFramesPerStream}
       array set txBroadBandFramesPerStream [array get tempTxFramesPerStream]
       array set txFramesPerStream [array get tempTxFramesPerStream]         

   }
}

########################################################################
# bbThroughput::WriteResultsCSV()
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
proc bbThroughput::WriteIterationCSV {} {  
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

    puts "Start WriteResultsCSV"
    set status $::TCL_OK
           
    set testCmd [namespace current]
    set binarySearch        [expr {[$testCmd cget -searchType] == "binary"}]
    set calculateLatency    [expr {[$testCmd cget -calculateLatency] == "yes"}]
    set calculateJitter     [expr {[$testCmd cget -calculateJitter] == "yes"}]    
    set imixMode            [expr {[$testCmd cget -imixMode] == "yes"}]
    set linearSearch        [expr {[$testCmd cget -searchType] == "linear"}]
    set calculateDataIntegrity  [expr {[$testCmd cget -calculateDataIntegrity] == "yes"}]

    set testCmd [namespace current]
    
    if {$binarySearch==0} {
        return $status
    }

    if {[catch {set csvFid [open $dirName/iteration.csv w]}]} {
        logMsg "***** WARNING:  Cannot open csv file."
        return
    }

    if {$imixMode} {
        # Imix mode
        
        set colHeads {"Trial"  "Iteration"  "Directions" "Tx Port" "Rx Port" "Frame size" "Tx Tput (fps)" "Tx Tput (%)" "Tx Frames" "Rx Frames" "Loss (frames)" "Loss (%)" }

        if {$calculateLatency} {
            lappend colHeads "Min Latency (ns)" "Max Latency (ns)" "Avg Latency (ns)"
        }

        if {$calculateJitter} {
            lappend colHeads "Min Inter-Arrival (ns)" "Max Inter-Arrival (ns)" "Avg Inter-Arrival (ns)"
        }

        if {$calculateDataIntegrity} {
            lappend colHeads "Data Integrity Errors"
        }

        puts $csvFid [join $colHeads ,]

        for {set trial 1 } {$trial <= [$testCmd cget -numtrials]} {incr trial} {
            set numIterations $fResultArray($trial,numIterations)
            for {set iteration 1} {$iteration <= $numIterations } {incr iteration} {                
                foreach txMap [lsort [array names fullMapArray]] {
                    scan $txMap "%d,%d,%d" tx_c tx_l tx_p 

                    set txPacketGroupId $portPgId($txMap)                                
                    set first 1

                    set txPort [join "$tx_c $tx_l $tx_p" .]    

                    if {[lsearch [array names one2manyArray] $txMap] != -1} {
                        set isWanPort "- D -"   
                        set wanPort 1
                    } else {
                        set isWanPort "- U -"                  
                        set wanPort 0
                    }


                    foreach rxMap $fullMapArray($txMap) {          
                        scan $rxMap "%d %d %d" rx_c rx_l rx_p
                        set rxPort [join "$rx_c $rx_l $rx_p" .] 
                        if {$wanPort} {
                            set groupIdName groupIdWanArray
                        } else {
                            set groupIdName groupIdBroadBandArray
                        }
                        set firstGroup 1
                        foreach groupItem [lnumsort [array names $groupIdName]] {
                             set nextGroupId [set ${groupIdName}($groupItem)]
                             set globalGroupId $groupIdArray($groupItem)

                             if {[info exists fResultArray($trial,$iteration,$txMap,$nextGroupId,txThroughput)]} {
                                 set txThroughput $fResultArray($trial,$iteration,$txMap,$nextGroupId,txThroughput)
                             } else {
                                 set txThroughput  0;
                             }

                             if {[info exists fResultArray($trial,$iteration,$txMap,$nextGroupId,txTputPercent)]} {
                                 set txTput $fResultArray($trial,$iteration,$txMap,$nextGroupId,txTputPercent)
                             } else {
                                 set txTput 0
                             }       

                             set numTxFramesPerPgID $fResultArray($trial,$iteration,[join "$tx_c $tx_l $tx_p" ,],$nextGroupId,txNumFrames)
                             #set numRxFramesPerPgID $fResultArray($trial,$iteration,[join "$rx_c $rx_l $rx_p" ,],$nextGroupId,rxNumFrames)
                             if { $wanPort } {
                                set numRxFramesPerPgID $fResultArray($trial,$iteration,[join "$rx_c $rx_l $rx_p" ,],$nextGroupId,rxNumFrames)
                             } else {                             
                                set numRxFramesPerPgID $fResultArray($trial,$iteration,[join "$tx_c $tx_l $tx_p" ,],$nextGroupId,rxNumFrames)
                             }
    
                             set frameLoss      [mpexpr {$numTxFramesPerPgID-$numRxFramesPerPgID}]
                             set frameLossPct   [mpexpr {($numTxFramesPerPgID-$numRxFramesPerPgID)*100.0/$numTxFramesPerPgID}]
    
                             set resList [list $trial $iteration $isWanPort $txPort $rxPort [join [split $groupItem ,] -] $txThroughput $txTput  $numTxFramesPerPgID $numRxFramesPerPgID $frameLoss $frameLossPct]
     
                             if {$calculateLatency || $calculateJitter} {
                                if {[info exists fResultArray($trial,$iteration,[join "$rx_c $rx_l $rx_p" ,],$nextGroupId,minLatency)]} {
                                  set minLatency $fResultArray($trial,$iteration,[join "$rx_c $rx_l $rx_p" ,],$nextGroupId,minLatency)
                                } else {
                                  set minLatency 0
                                } 
                                if {[info exists fResultArray($trial,$iteration,[join "$rx_c $rx_l $rx_p" ,],$nextGroupId,maxLatency)]} {
                                  set maxLatency $fResultArray($trial,$iteration,[join "$rx_c $rx_l $rx_p" ,],$nextGroupId,maxLatency)
                                } else {
                                  set maxLatency 0
                                } 
                                if {[info exists fResultArray($trial,$iteration,[join "$rx_c $rx_l $rx_p" ,],$nextGroupId,avgLatency)]} {
                                  set avgLatency $fResultArray($trial,$iteration,[join "$rx_c $rx_l $rx_p" ,],$nextGroupId,avgLatency)
                                } else {
                                  set avgLatency 0
                                } 
                                lappend resList $minLatency $maxLatency $avgLatency
                             }
                                
                             if { $calculateDataIntegrity} {
                                if {$firstGroup} {
                                    set firstGroup 0
                                    lappend resList $fResultArray($trial,$iteration,$rx_c,$rx_l,$rx_p,dataIntegrityErrors)
                                } else {
                                    lappend resList "-"
                                }                                
                             }
                            regsub ",," [join $resList ,] "," lista
                            puts $csvFid $lista
                       } ;# loop groupItem                     
                    } ;#loop rx
                };#loop tx
            } ;# loop iteration
        } ;# loop trial
    } else {
# Standard (not Imix mode)


        set colHeads {"Trial" "Frame Size (bytes)"  "Iteration"  "Directions" "Tx Port" "Rx Port" "Tx Tput (fps)" "Tx Tput (%)" "Tx Frames" "Rx Frames" "Loss (frames)" "Loss (%)"}

        if {$calculateLatency} {
            lappend colHeads "Min Latency (ns)" "Max Latency (ns)" "Avg Latency (ns)"
        }

        if {$calculateJitter} {
            lappend colHeads "Min Inter-Arrival (ns)" "Max Inter-Arrival (ns)" "Avg Inter-Arrival (ns)"
        }

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
                    set numIterations $fResultArray($trial,numIterations)

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
    
    
                            if {[info exists fResultArray($trial,$fs,$iteration,$txMap,txThroughput)]} {
                                set txThroughput  $fResultArray($trial,$fs,$iteration,$txMap,txThroughput)
                            } else {
                                set txThroughput 0;
                            }
    
                            if {[info exists fResultArray($trial,$fs,$iteration,$txMap,txTputPercent)]} {
                                set txTput $fResultArray($trial,$fs,$iteration,$txMap,txTputPercent)
                            } else {
                                set txTput 0;
                            }            
                            
                            if {[info exists fResultArray($trial,$fs,$iteration,$txMap,txNumFrames)]} {
                                set txFrames [mpexpr {$fResultArray($trial,$fs,$iteration,$txMap,txNumFrames)/[llength $fullMapArray($txMap)]}]                            
                            } else {
                                set txFrames 0;
                            }            
    
                            foreach rxMap $fullMapArray($txMap) {          
                                scan $rxMap "%d %d %d" rx_c rx_l rx_p
                                set rxPort [join "$rx_c $rx_l $rx_p" .]                            
                                
                                if {[info exists fResultArray($trial,$fs,$iteration,[join "$rx_c $rx_l $rx_p" ,],$txPacketGroupId,rxNumFrames)]} {
                                   set rxFrames $fResultArray($trial,$fs,$iteration,[join "$rx_c $rx_l $rx_p" ,],$txPacketGroupId,rxNumFrames)
                                } else {
                                   set rxFrames  0;
                                } 

                                set frameLoss      [mpexpr {$txFrames-$rxFrames}]
                                set frameLossPct   [mpexpr {($txFrames-$rxFrames)*100.0/$txFrames}]

                                set resList [list $trial $fs $iteration $isWanPort $txPort $rxPort $txThroughput $txTput $txFrames $rxFrames $frameLoss $frameLossPct]
    
                                if {$calculateLatency || $calculateJitter} {
                                  if {[info exists fResultArray($trial,$fs,$iteration,[join "$rx_c $rx_l $rx_p" ,],$txPacketGroupId,minLatency)]} {
                                    set minLatency $fResultArray($trial,$fs,$iteration,[join "$rx_c $rx_l $rx_p" ,],$txPacketGroupId,minLatency)
                                  } else {
                                    set minLatency 0
                                  } 
                                  if {[info exists fResultArray($trial,$fs,$iteration,[join "$rx_c $rx_l $rx_p" ,],$txPacketGroupId,maxLatency)]} {
                                    set maxLatency $fResultArray($trial,$fs,$iteration,[join "$rx_c $rx_l $rx_p" ,],$txPacketGroupId,maxLatency)
                                  } else {
                                    set maxLatency 0
                                  } 
                                  if {[info exists fResultArray($trial,$fs,$iteration,[join "$rx_c $rx_l $rx_p" ,],$txPacketGroupId,avgLatency)]} {
                                    set avgLatency $fResultArray($trial,$fs,$iteration,[join "$rx_c $rx_l $rx_p" ,],$txPacketGroupId,avgLatency)
                                  } else {
                                    set avgLatency 0
                                  } 
                                  lappend resList $minLatency $maxLatency $avgLatency
                                }
                                if { $calculateDataIntegrity } {
                                   lappend resList  $fResultArray($trial,$fs,$iteration,$rx_c,$rx_l,$rx_p,dataIntegrityErrors)
                                }
                                regsub ",," [join $resList ,] "," lista
                                puts $csvFid $lista
                            } ;#loop rx
                        };#loop tx
                    } ;# loop iteration
                } ;# loop fs broadband
            } ;# loop framesize wan
        } ;# loop trial
    } 

    close $csvFid

    debugPuts "Leave WriteResultsCSV"
    return $status;
}



proc bbThroughput::ShowIterationItem {testCmd TxRxArray directions iteration fs} {
    upvar $TxRxArray   txRxArray
    variable portPgId
    variable fResultArray  
    variable trial

    set fileID  [openResultFile a]

  
    set calculateJitter  [expr {![string compare [$testCmd cget -calculateJitter] yes]}]     
    set calculateLatency [expr {![string compare [$testCmd cget -calculateLatency] yes] }]
    set linearSearch     [expr {[$testCmd cget -searchType] == "linear"}]   
    set calculateDataIntegrity  [expr {[$testCmd cget -calculateDataIntegrity] == "yes"}]

   if {$directions=="downstream" } {
        if { $calculateJitter  } { 
            set tableHeader [format "%10s %14s %10s %10s %14s %10s %10s %10s %10s %10s %10s" \
                 "WAN Port" "BroadBand Port" "TxFrames" "RxFrames" "TxTput(fps)" \
                 "%TxTput" "Loss(frames)" "Loss(%)" "MinInterArrival(ns)" "MaxInterArrival(ns)" "AvgInterArrival(ns)"]
        } elseif {$calculateLatency} {
            set tableHeader [format "%10s %14s %10s %10s %14s %10s %10s %10s %10s %10s %10s" \
                 "WAN Port" "BroadBand Port" "TxFrames" "RxFrames" "TxTput(fps)" \
                 "%TxTput" "Loss(frames)" "Loss(%)" "MinLatency(ns)" "MaxLatency(ns)" "AvgLatency(ns)"]
        } else {
           set tableHeader [format "%10s %14s %10s %10s %14s %10s %10s %10s" \
                "WAN Port" "BroadBand Port" "TxFrames" "RxFrames" "TxTput(fps)" \
                "%TxTput" "Loss(frames)" "Loss(%)"]
        }
    } else {
        if { $calculateJitter  } { 
            set tableHeader [format "%14s %10s %10s %10s %14s %10s %10s %10s %10s %10s %10s" \
                 "BroadBand Port" "WAN Port" "TxFrames" "RxFrames" "TxTput(fps)" \
                 "%TxTput" "Loss(frames)" "Loss(%)" "MinInterArrival(ns)" "MaxInterArrival(ns)" "AvgInterArrival(ns)"]
        } elseif {$calculateLatency} {
            set tableHeader [format "%14s %10s %10s %10s %14s %10s %10s %10s %10s %10s %10s" \
                 "BroadBand Port" "WAN Port" "TxFrames" "RxFrames" "TxTput(fps)" \
                 "%TxTput" "Loss(frames)" "Loss(%)" "MinLatency(ns)" "MaxLatency(ns)" "AvgLatency(ns)"]
        } else {
           set tableHeader [format "%14s %10s %10s %10s %14s %10s %10s %10s" \
                "BroadBand Port" "WAN Port" "TxFrames" "RxFrames" "TxTput(fps)" \
                "%TxTput" "Loss(frames)" "Loss(%)"]
        }
    }


    if {$calculateDataIntegrity} {
        set tableHeader [format "%s %21s" $tableHeader "Data Integrity Errors"]
    }

    set separator {}

    for {set i 0} {$i<[string length $tableHeader]} {incr i} {
          append separator "*"
    }

    if {$linearSearch} {       
        set strToPrint [format "\nTrial:%d Iteration:%d Linear Direction:%s " $trial $iteration $directions]          
        writeResult $fileID $strToPrint
    } else {
        set strToPrint [format "\nTrial:%d Iteration:%d Binary Search Direction:%s " $trial $iteration $directions]   
        writeResult $fileID $strToPrint
    }

    set totalTxFrames 0
    set totalRxFrames 0                
  
    set strToPrint $tableHeader
    writeResult $fileID $strToPrint
    set strToPrint $separator
    writeResult $fileID $strToPrint

    foreach txMap [lsort [array names txRxArray]] {
            scan $txMap "%d,%d,%d" tx_c tx_l tx_p  

            set txPacketGroupId $portPgId($txMap)                                
            set first 1

            foreach rxMap $txRxArray($txMap) {          
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

                if {$first} {
                    append line [format "%12s" $fResultArray($trial,$fs,$iteration,$txMap,txThroughput)]
                    append line [format "%12s" $fResultArray($trial,$fs,$iteration,$txMap,txTputPercent)]
                    set first   0
                } else {
                    append line [format "%12s" -]
                    append line [format "%12s" -]
                }

                append line [format "%12s %10.2f" $frameLoss $frameLossPct]

                if { $calculateJitter || $calculateLatency } { 
                    append line [format "%12s" $fResultArray($trial,$fs,$iteration,[join $rxMap ,],$txPacketGroupId,minLatency)]
                    append line [format "%12s" $fResultArray($trial,$fs,$iteration,[join $rxMap ,],$txPacketGroupId,maxLatency)]
                    append line [format "%12s" $fResultArray($trial,$fs,$iteration,[join $rxMap ,],$txPacketGroupId,avgLatency)]
                }

                if { $calculateDataIntegrity } {
                    append line [format "%21s" $fResultArray($trial,$fs,$iteration,$rx_c,$rx_l,$rx_p,dataIntegrityErrors)]
                }
                
                writeResult $fileID $line
            }
            incr  totalTxFrames $fResultArray($trial,$fs,$iteration,$txMap,txNumFrames)   
            incr  totalRxFrames $fResultArray($trial,$fs,$iteration,$txMap,framesReceivedPerTx)
      }
      writeResult $fileID  $separator                    

      set line [format "TotalTxFrames  = %d" $totalTxFrames]      
      writeResult $fileID $line
      set line [format "TotalRxFrames  = %d" $totalRxFrames]                 
      writeResult $fileID $line
      set line "TotalLoss(%)   = [calculatePercentLoss $totalTxFrames $totalRxFrames]"
      writeResult $fileID $line

      set strToPrint "\n"
      writeResult $fileID $strToPrint

      if {$fileID != "stdout"} {
         closeMyFile $fileID
      }

}

proc bbThroughput::GUIBidirectionalTrafficMap {{direction bidirectional}} {  
  global searchType
  global invisibleBinarySearch21FrameName
  global linearBinarySearchsFrameName

  if {$searchType == "linear"} {
      return 
  }

  if {$direction == "bidirectional"} {
      $invisibleBinarySearch21FrameName.binarySearchDirection.true  config -state normal
      $invisibleBinarySearch21FrameName.binarySearchDirection.false config -state normal
      $invisibleBinarySearch21FrameName.binarySearchDirection.true  config -bg gray83     
      $invisibleBinarySearch21FrameName.binarySearchDirection.false config -bg gray83       
      $linearBinarySearchsFrameName.invisibleBinarySearch21.label config -foreground black   
  } else {
      $invisibleBinarySearch21FrameName.binarySearchDirection.true  config -state disabled       
      $invisibleBinarySearch21FrameName.binarySearchDirection.false config -state disabled       
      $invisibleBinarySearch21FrameName.binarySearchDirection.true  config -bg gray      
      $invisibleBinarySearch21FrameName.binarySearchDirection.false config -bg gray       
      $linearBinarySearchsFrameName.invisibleBinarySearch21.label config -foreground gray40   
  }

}

