##################################################################################
# Version 3.65  $   Revision:   $
# $Date: 12/12/02 2:03p $
# $Author: Dheins $
#
# $Workfile: capacity.tcl $ - Tunnel Capacity Test
#
#   Copyright © 1997 - 2004 by IXIA
#   All Rights Reserved.
#
#   Revision Log:
#   10-29-2002      DHG     Initial Release
#
# Description:  This file contains the script for running the Tunnel Capacity
#               test.
#
##################################################################################

namespace eval tunnel {
   variable xmdDef
   set xmdDef  {
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
                        <Source scope="results.csv" entity_name="tunnelCapacity" format_id=""/>
                        <Source scope="info.csv" entity_name="tunnelCapacity_Info" format_id=""/>
                        <Source scope="AggregateResults.csv" entity_name="tunnelCapacity_Aggregate" format_id=""/>
                        <Source scope="Iteration.csv" entity_name="tunnelCapacity_Iteration" format_id=""/>
                     </Sources>
                  </XMD>
   }
}

## Tunnel Namespace Variables

#   Metric Name         Result Array            Port        Initial     Iteration   Result          Print
#                                               Direction   Value       Reset?      Set             Order
array unset ::tunnel::portResultArrays
variable ::tunnel::portResultArrays
array set ::tunnel::portResultArrays  {
    tunnelId            {tunnelIdValues             tx      0           true        standard         1   }
    transmitFrames      {txActualFrames             tx      0           true        standard         2   } 
    receiveFrames       {rxNumFrames                rx      0           true        standard         3   } 
    throughput          {thruputRate                tx      0.0         false       standard         4   } 
    percentTput         {percentTput                tx      0.0         false       standard         5   } 
    percentLoss         {frameloss                  rx      0.0         true        standard         6   } 
    avgLatency          {avgLatencyValues           rx      0           true        latency          1   }
    minLatency          {minLatencyValues           rx      0           true        latency          2   }
    maxLatency          {maxLatencyValues           rx      0           true        latency          3   }
    totalSeqError       {sequenceErrorValues        rx      0           true        sequenceTotal    1   }
    reverseSeqError     {reverseSequenceErrorValues rx      0           true        sequenceDetail   2   }
    bigSeqError         {bigSequenceErrorValues     rx      0           true        sequenceDetail   3   }
    smallSeqError       {smallSequenceErrorValues   rx      0           true        sequenceDetail   4   }
    integrityFrames     {integrityFrameValues       rx      0           true        integrity        1   }
    integrityErrors     {integrityErrorValues       rx      0           true        integrity        2   }
}

## End Tunnel Namespace Variables


########################################################################################
# Procedure:    tunnel::registerResultVars_capacity
#
# Description:  This command registers all the local variables that are used in the
#               display of the results with the Results Options Database.
#
# Arguments:    None
#
# Returns:      TCL_OK or TCL_ERROR
#
########################################################################################
proc tunnel::registerResultVars_capacity {} \
{
    variable portResultArrays

    set retCode $::TCL_OK

    # Add extra variables the result registry.
    if [ results addOptionToDB    tunnelCount       "RemainingTunnels"      18 18 iter]    { return $::TCL_ERROR }
    if [ results addOptionToDB    tolerance         "Tolerance(%)"          18 18 iter]    { return $::TCL_ERROR }
    if [ results setOptionInDB    totalTxFrames     "TotalTxFrames"         18 18 iter]    { return $::TCL_ERROR }
    if [ results setOptionInDB    totalRxFrames     "TotalRxFrames"         18 18 iter]    { return $::TCL_ERROR }
    if [ results setOptionInDB    RXminLatency      "MinLatency(ns)"        15 15 port]    { return $::TCL_ERROR }
    if [ results setOptionInDB    RXmaxLatency      "MaxLatency(ns)"        15 15 port]    { return $::TCL_ERROR }
    if [ results addOptionToDB    TXtunnelId        "TunnelId"              15 15 port]    { return $::TCL_ERROR }
    if [ results addOptionToDB    RXintegrityErrors "IntegrityErrors"       16 16 port]    { return $::TCL_ERROR }
    if [ results addOptionToDB    RXintegrityFrames "IntegrityFrames"       16 16 port]    { return $::TCL_ERROR }

    # Configuration information stored for results
    if [ results registerTestVars testName          testName             [tunnel cget -testName] test ] { return $::TCL_ERROR }
    if [ results registerTestVars protocol          protocolName         [string toupper [getProtocolName [protocol cget -name]]] test ] { return $::TCL_ERROR }
    if [ results registerTestVars chassisName       chassisName          [chassis cget -name]            test    ] { return $::TCL_ERROR }
    if [ results registerTestVars chassisID         chassisID            [chassis cget -id]              test    ] { return $::TCL_ERROR }
    if [ results registerTestVars productName       productName          [user cget -productname]        test    ] { return $::TCL_ERROR }
    if [ results registerTestVars versionNumber     versionNumber        [user cget -version]            test    ] { return $::TCL_ERROR }
    if [ results registerTestVars serialNumber      serialNumber         [user cget -serial#]            test    ] { return $::TCL_ERROR }
    if [ results registerTestVars userName          userName             [user cget -username]           test    ] { return $::TCL_ERROR }
    if [ results registerTestVars percentMaxRate    percentMaxRate       [tunnel cget -percentMaxRate]   test    ] { return $::TCL_ERROR }
    if [ results registerTestVars numTrials         numTrials            [tunnel cget -numtrials]        test    ] { return $::TCL_ERROR }
    if [ results registerTestVars duration          duration             0                               test    ] { return $::TCL_ERROR }
                                                                         
    # Results obtained after each iteration                              
    if [ results registerTestVars totalTxFrames     totalTxNumFrames     0                               iter    ] { return $::TCL_ERROR }     
    if [ results registerTestVars totalRxFrames     totalRxNumFrames     0                               iter    ] { return $::TCL_ERROR }
    if [ results registerTestVars tolerance         tolerance            0                               iter    ] { return $::TCL_ERROR }
    if [ results registerTestVars tunnelCount       tunnelCount          0                               iter    ] { return $::TCL_ERROR }

    # Results obtained per port.
    foreach {metric arrayList} [array get portResultArrays] {
        scan $arrayList "%s %s %s %s %s" array portDirection initialValue iterationReset class
        if {[results registerTestVars $metric $array $initialValue port [stringToUpper $portDirection 0 1]]} {
            set retCode $::TCL_ERROR
            break
        }
    }

    return $retCode
}


########################################################################################
# Procedure: tunnel::capacity
#
# Description:  This command starts the Tunnel Capacity test. 
#
#               The frames on desired ports should have been configured using the "port" 
#               and "streams" commands.  
#               
#               The Capacity test determines how many tunnels can support a given (non-
#               varying) frame rate and frame size without loss.  The tunnel count 
#               begins with the maximum # of tunnels (as configured by the user), and
#               while loss is present, decrements the tunnel load by a configured
#               number of tunnels until there is no loss.
#
# Argument(s):  None
#
# Return:       TCL_OK or TCL_ERR (uses TCL return -error for fatal errors)
#
########################################################################################
proc tunnel::capacity {} \
{ 
    variable status;
    
    set status $::TCL_OK;
    
    if {[catch {set status [tunnel::TestMethod_capacity]} ERROR]} { 
    logMsg "***** ERROR:  Test Method failed.  Test aborted.";
    logMsg "$ERROR"
    set status $::TCL_ERROR;
    }

    if {$status == $::TCL_ERROR} {
    if {[dutConfig::DutConfigure TestCleanup]} {
        logMsg "***** ERROR:  DUT Configuration failed.  Test aborted."
        return $::TCL_ERROR
    }
    }

    return $status;
}

#############################################################################
# tunnel::TestMethod_capacity()
#
# DESCRIPTION
# This procedure encloses the overall test method execution including the
# primary test loops and core algorithm.
#
# RETURNS:  
# status      TCL_OK     - on success
#             TCL_ERROR  - on failure
#
###
proc tunnel::TestMethod_capacity {} {
    global one2oneArray
    variable ::tunnel::capacity

    set retCode $::TCL_OK
    global testConf

    variable xmdDef
    variable resultsDirectory
    variable trial
    variable framesize

    tunnel config -enableLatency false

    #fix Ipv6 addresses for 6to4 Automatic mode
    FixIPV6TunnelAddresses one2oneArray

    # Exit if invalid configuration.
    if {[advancedTestParameter cget -streamPatternType] == "patternTypeRandom" } {
        logMsg "\n**** ERROR: Stream pattern type must not be random. Test aborted."
        logMsg "            Reconfigure the stream pattern type and restart the test.\n"
        return $::TCL_ERROR
    }

    set tunnelProtocol  [tunnel cget -tunnelProtocol]
    set payloadProtocol [tunnel cget -payloadProtocol]
    if {[string match $tunnelProtocol $payloadProtocol]} {
        logMsg "Error: Matching payload and tunnel protocols not supported"
        return $::TCL_ERROR
    }

    if {[validateUnidirectionalMap one2oneArray]} {
        logMsg "Error: Invalid port map for this test."
        return $::TCL_ERROR
    }
    if {[validateFrameSizeList [tunnel cget -framesizeList]]} {
        return $::TCL_ERROR
    }

    set rxPortList [getRxPorts one2oneArray] 
    if {[llength $rxPortList] < [tunnel cget -maximumTunnels]} {
        logMsg "Error: The maximum number of tunnels should not exceed the number of rx ports."
        return $::TCL_ERROR
    }

    set dirName "[results cget -directory]/IP Tunnel.resDir/Tunnel Capacity.resDir/[file rootname [csvUtils::getCurrentScriptName]].res"

    set resultsDirectory [makeNewRunDirectory $dirName $xmdDef]
    results config -resultDir $resultsDirectory
    scriptMateGuiCommand setDirName $resultsDirectory

    if {[string length $resultsDirectory] == 0} {
        return $::TCL_Error
    }

    set colHeads { "Trial"
               "Frame Size"
               "Iteration"
               "Tx Port"
               "Rx Port"
               "Tunnel ID"
               "Tx Tput (%)"
               "Tx Tput (fps)"
               "Tx Count"
               "Rx Count"
               "Frame Loss"
               "Frame Loss (%)"
    }
  
    if {[csvUtils::createIterationCSVFile tunnel $colHeads]} {
        return $::TCL_ERROR
    }
    
    if {[dutConfig::DutConfigure]} {
        logMsg "***** ERROR:  DUT Configuration failed.  Test aborted."
        return $::TCL_ERROR
    }
    
    realTimeGraphs::InitRealTimeStat \
        [list [list framesSent     [getTxPorts one2oneArray] "Tx Frames per second" "Tx Frames" 1e0]\
         [list framesReceived [getRxPorts one2oneArray] "Rx Frames per second" "Rx Frames" 1e0]\
         [list bitsSent       [getTxPorts one2oneArray] "Tx Kbps"              "Tx Kb"     1e3]\
         [list bitsReceived   [getRxPorts one2oneArray] "Rx Kbps"              "Rx Kb"     1e3]\
        ];

    # Setup port-protocol configuration for the tunnel protocol (the payload
    #   protocol is setup by default in testConfig::configurePortProtocol).
    if {[tunnel::configurePortProtocol $tunnelProtocol one2oneArray]} {
        logMsg "Error: Unable to configure port protocol for $tunnelProtocol"
        return $::TCL_ERROR
    }

    # Define/Initialize Statistics collected.
    #  Statistic Name       Result Array
    array set pgStatistics {
       averageLatency       avgLatencyValues
       minLatency           minLatencyValues
       maxLatency           maxLatencyValues
       totalSequenceError   sequenceErrorValues
       reverseSequenceError reverseSequenceErrorValues
       bigSequenceError     bigSequenceErrorValues    
       smallSequenceError   smallSequenceErrorValues  
       totalFrames          rxNumFrames          
    }

    initializePortResultArrays one2oneArray
    buildTunnelTranslations one2oneArray
    
    set encapsulation [tunnel cget -encapsulation]
    switch $encapsulation {
        ingress {
            learn config -type $tunnelProtocol
        }
        egress {
            learn config -type $payloadProtocol
        }
    }

    set testName [format "IPv6 Tunnel Capacity Test - %s" [stringToUpper $encapsulation 0]]
    tunnel config -testName $testName

    # Setup Port Recieve Mode.
    set receiveMode [expr $::portRxSequenceChecking | $::portPacketGroup | $::portRxDataIntegrity]
    if {[changePortReceiveMode one2oneArray $receiveMode write]} {
        set errorinfo "***** WARNING: Some interfaces don't support [getTxRxModeString $receiveMode RX] simultaneously."
        errorMsg  $errorinfo
return $::TCL_ERROR
    }


    # Initialize test, perform learning as required.
    if {[initTest tunnel one2oneArray {ip ipV6} errMsg no]} {
        errorMsg $errMsg
return $::TCL_ERROR
    }

    if {[learn cget -when] == "oncePerTest"} {
        if {[learnIngressAndEgress one2oneArray]} {
            errorMsg "Error: Unable to send ARP/Neighbor Discovery frames"
            return $::TCL_ERROR
        }
    }

    set preambleSize        8
    set protocolName        [getProtocolName [protocol cget -name]]

    set percentMaxRate      [expr [tunnel cget -percentMaxRate]/1.0]
    set duration            [tunnel cget -duration]
    set tunnelStep          [tunnel cget -tunnelStep]
    set minimumTunnels      [tunnel cget -minimumTunnels]
    set maximumTunnels      [tunnel cget -maximumTunnels]
    set tolerance           [tunnel cget -tolerance]

    # Validate user settings.
    foreach item {tunnelStep minimumTunnels maximumTunnels } {
        upvar 0 $item itemValue
        if {$itemValue < $capacity(minimumTunnels)} {
            set itemValue $capacity(minimumTunnels)
        } elseif {$itemValue > $capacity(maximumTunnels)} {
            set $itemValue $capacity(maximumTunnels)
        }
    }

    if {$minimumTunnels > $maximumTunnels} {
          set maximumTunnels $minimumTunnels
          set message [format "\nMax Number of Tunnels: $maximumTunnels less than Min $minimumTunnels\n Setting Max same value as Min"]
          logMsg $message
    }

    set noTunnels [llength [array names one2oneArray]]

    if { $noTunnels > $maximumTunnels } {
         set message [format "\nMax Number of Tunnels ($maximumTunnels) is less than running tunnels ($noTunnels) -> Set the number of tunnels to $maximumTunnels"]
         logMsg $message        
     
         for {set count $noTunnels} {  ($count > $maximumTunnels) && ($count >= $minimumTunnels) } {incr count -1} {    
              set txMap [lindex [lsort [array names one2oneArray]]  end]
              scan $txMap "%d,%d,%d" tx_c tx_l tx_p
              scan $one2oneArray($txMap) "{%d %d %d}" rx_c rx_l rx_p
              set message [format "Removing tunnel %s ($tx_c.$tx_l.$tx_p)" [getTunnelId $tx_c $tx_l $tx_p]]
              logMsg $message 
              map del $tx_c $tx_l $tx_p $rx_c $rx_l $rx_p
         }
    } 

    array set txRxArray     [array get one2oneArray]

    set percentLossFormat [advancedTestParameter cget -percentLossFormat]

    #
    # Arrays used in this test:
    #
    #   These array are setup before the test:
    #   maxFrameRate:           per port estimate of the maximum rate (at 100%) for a given framesize 
    #   frameRate:              per port estimate of the maximum rate (at $percentMaxRate) for a given framesize (calculated in writeCapacityStreams)
    #   txNumFrames:            per port estimate of # of frames to transmit (calculated in writeCapacityStreams)
    #   thruputRate:            per port estimate tput rate by frameRate/maxFrameRate
    #   tunnelIdValues:         per port mapping of packet group #'s to Tunnel Id's
    #
    #   These arrays hold results:
    #   frameLoss:              per port calculation of the frame loss for a given framesize & given numTunnels
    #   rxNumFrames:            per port number of frames recieved in packet group
    #   avgLatencyValues        per port calculation of average latency (packet group)
    #   minLatencyValues        per port minumum latency (packet group)
    #   maxLatencyValues        per port maximum latecy (packet group)
    #   sequenceErrorValues     per port count of total sequence errors (packet group)
    #   integrityErrorValues    per port number of data integrity errors
    #   integrityFrameValues    per port number of data integrity frames tx'd

    realTimeGraphs::StartRealTimeStat;
    scriptMateGuiCommand openProgressMeter

    foreach framesize [tunnel cget -framesizeList] {
    
        tunnel config -framesize    $framesize  

        catch {array unset one2oneArray}
        array set one2oneArray      [array get txRxArray]
        set txPortList              [getTxPorts one2oneArray]

        # Set up results for this test
        setupTestResults tunnel one2one "one2one"           \
                                one2oneArray                \
                                $framesize                  \
                                [tunnel cget -numtrials]    \
                                true                        \
                                2                           \
                                capacity               

        results config -rowStyle            oneFramesizePerRow
        results config -rowTitleType        tunnelId
        results config -printRxRowValues    allRows
        results config -numPortMapColumns   0
        results config -summary             true

        # Perform learning as required.
        if {[learn cget -when] == "oncePerFramesize"} {
            if {[learnIngressAndEgress one2oneArray]} {
                errorMsg "Error: Unable to send ARP/Neighbor Discovery frames"
                return $::TCL_ERROR
            }
        }

        # Build Stream, estimate frame rate (at $percentMaxRate), estimate # tx frames.
        if {[writeCapacityStreams one2oneArray $percentMaxRate frameRate txNumFrames]} {
            errorMsg  "Unable to build streams for test."
return $::TCL_ERROR
        }
        
        # Estimate the maximum frame rate (100%) based upon the tunneled frame size.
        foreach txMap [array names one2oneArray] {}
        scan $txMap "%d,%d,%d" tx_c tx_l tx_p
        if {![stream get $tx_c $tx_l $tx_p 1]} {
            if {[initMaxRate one2oneArray maxFrameRate [stream cget -framesize]]} {
                return $::TCL_ERROR
            }
        }        

        # Estimate throughput rate.
        foreach txMap $txPortList {
            scan $txMap "%d %d %d" tx_c tx_l tx_p
            set portFrameRate                   [expr round($frameRate($tx_c,$tx_l,$tx_p))]
            set portMaxFrameRate                $maxFrameRate($tx_c,$tx_l,$tx_p)
            set percentTput($tx_c,$tx_l,$tx_p)  [calculatePercentThroughput $portFrameRate $portMaxFrameRate]
            set thruputRate($tx_c,$tx_l,$tx_p) $portFrameRate

        }

        
        for {set trial 1} {$trial <= [tunnel cget -numtrials]} {incr trial} {
            logMsg "******* TRIAL $trial - [tunnel cget -testName] *******"
            
            if {[dutConfig::DutConfigure TrialSetup]} {
               logMsg "***** ERROR:  DUT Configuration failed.  Test aborted."
               return $::TCL_ERROR
           }

        realTimeGraphs::SaveRealTimeMarker "-- Trial:$trial FS:$framesize--";

            # Initialize local test variables.
            catch {array unset one2oneArray}
            array set one2oneArray  [array get txRxArray]

            results config -txRxMapList [list one2one {} [array get one2oneArray]]
            set txPortList          [getTxPorts txPortList]

            set tunnelCount         $maximumTunnels
            set frameLossOccurred   $::false

            # Learn as required.
            if {[learn cget -when] == "onTrial"} {
                if {[learnIngressAndEgress one2oneArray]} {
                    errorMsg "Error: Unable to send ARP/Neighbor Discovery frames"
                    return $::TCL_ERROR
                }
                # on ipv6 switchlearn case the interfaces are reset, so reconfigure again
                if {[writeCapacityStreams one2oneArray $percentMaxRate frameRate txNumFrames]} {
                   errorMsg  "Unable to build streams for test."
return $::TCL_ERROR
                }   
            }

            set iteration 1

            # Start Capacity test at $maximumTunnels # of tunnels, decrement & iterate while loss is present.
            while {$tunnelCount >= $minimumTunnels } {

                logMsg [format "\n---> ITERATION %d, Frame Size: %d, Number of Tunnels: %d" $iteration $framesize $tunnelCount]

                set txPortList [getTxPorts one2oneArray]

                initializePortResultArrays txRxArray iteration
                set frameLossOccurred   $::false

                if {[clearStatsAndTransmit one2oneArray $duration [tunnel cget -staggeredStart]]} {
                    return $::TCL_ERROR
                }

                waitForResidualFrames [tunnel cget -waitResidual]

        # Poll the Tx counters until all frames are sent
            stats::collectTxStats $txPortList txNumFrames txActualFrames totalTxNumFrames

                # Collect Packet Group Stats (refer to pgStatistics for a list arrays populated).
                if {[tunnel::collectPacketGroupStats one2oneArray pgStatistics]} {
                    errorMsg "Error: Unable to collect packet group statistics"
                    set retCode $::TCL_ERROR
                }

                # Collect Total Frames Rx'd for all Tunnels
                set totalRxNumFrames 0
                foreach {rxMap value} [array get rxNumFrames] {
                    incr totalRxNumFrames $value
                }

                collectDataIntegrityStats [getRxPorts one2oneArray] integrityErrorValues integrityFrameValues

                foreach txMap [lnumsort $txPortList] {

                    scan $txMap "%d %d %d" tx_c tx_l tx_p
                    scan $one2oneArray($tx_c,$tx_l,$tx_p) "{%d %d %d}" rx_c rx_l rx_p

                    set tunnelIdValues($tx_c,$tx_l,$tx_p) [getTunnelId $tx_c $tx_l $tx_p]

                    # Rx Frames = 0, continue with next port.
                    if {$rxNumFrames($rx_c,$rx_l,$rx_p) == 0} {
                        set frameloss($rx_c,$rx_l,$rx_p) [formatNumber 100 $percentLossFormat]
                        set frameLossOccurred $::true                                                  
                    } else {
                        # Calculate Frame Loss
                        set percentLoss [calculatePercentLoss $txNumFrames($tx_c,$tx_l,$tx_p) \
                                                              $rxNumFrames($rx_c,$rx_l,$rx_p)]
    
                        regsub -all {[^0-9.]} $percentLoss {} percentLoss
                        set frameloss($rx_c,$rx_l,$rx_p) [formatNumber $percentLoss $percentLossFormat]
    
                        # Rx Frames < Tx Frames
                        if {$rxNumFrames($rx_c,$rx_l,$rx_p) < $txNumFrames($tx_c,$tx_l,$tx_p)} {
                            if {[expr $tolerance - $percentLoss] < 0} {
                                set frameLossOccurred $::true
                            }
                        }
                    }
                    #  Write in Iteration.CSV 
                    csvUtils::writeIterationCSVFile tunnel [list $iteration \
                                                                 "$tx_c.$tx_l.$tx_p" \
                                                                 "$rx_c.$rx_l.$rx_p" \
                                                                 $tunnelIdValues($tx_c,$tx_l,$tx_p) \
                                                                 $percentTput($tx_c,$tx_l,$tx_p) \
                                                                 $thruputRate($tx_c,$tx_l,$tx_p) \
                                                                 $txNumFrames($tx_c,$tx_l,$tx_p) \
                                                                 $rxNumFrames($rx_c,$rx_l,$rx_p) \
                                                                 [mpexpr $txNumFrames($tx_c,$tx_l,$tx_p) - $rxNumFrames($rx_c,$rx_l,$rx_p)] \
                                                                 $frameloss($rx_c,$rx_l,$rx_p)]
                }

               # If frame loss occurred, iterate with one less tunnel.
               if {$frameLossOccurred} {
                  set message [format "\n---> Frame Loss encountered outside of acceptable tolerance"]
    
                  incr  tunnelCount  [expr 0-$tunnelStep]
                  if {$tunnelCount <  $minimumTunnels} {             
                      break
                  }
    
                  for {set count $tunnelStep} {  $count > 0 } {incr count -1} { 
                     set txMap [lindex [lsort [array names one2oneArray]]  end]
                     scan $txMap "%d,%d,%d" tx_c tx_l tx_p
                     scan $one2oneArray($txMap) "{%d %d %d}" rx_c rx_l rx_p
    
                     set message [format "Removing tunnel %s ($tx_c.$tx_l.$tx_p)" [getTunnelId $tx_c $tx_l $tx_p]]
                     logMsg $message 
                     map del $tx_c $tx_l $tx_p $rx_c $rx_l $rx_p
                  }
                  results config -txRxMapList [list one2one {} [array get one2oneArray]] 
                # If no frame loss, test is complete.
                } else {
                    break
                }
                incr iteration
            }


            # Print Results
            logMsg "Saving results for Trial $trial ..."

            # Adjust tunnel count for last iteration.
            if {$frameLossOccurred} {
                incr tunnelCount $tunnelStep
            }

            # Determine Which Result Arrays are to be printed.
            set resultArrays [getResultListByClass standard]

            if {!$frameLossOccurred} {
                if {[tunnel cget -enableLatency] == "true"} {
                    lappend resultArrays [join [getResultListByClass latency]]
                }
            } else {
                set message [format "\n---> WARNING: Frame loss encountered at the minimum tunnel load: %d" $minimumTunnels]
                logMsg $message
            }
            if {[tunnel cget -enableSequenceTotal] == "true"} {
                lappend resultArrays [getResultListByClass sequenceTotal]
            }
            if {[tunnel cget -enableSequenceDetail] == "true"} {
                lappend resultArrays [getResultListByClass sequenceDetail]
            }
            if {[tunnel cget -enableDataIntegrity] == "true"} {
                lappend resultArrays [getResultListByClass integrity]
            }

            # Append Iteration-level results to list.
            set resultArrays [join $resultArrays]
            lappend resultArrays tunnelCount tolerance totalTxNumFrames totalRxNumFrames
            set resultArrays [join $resultArrays]

            if {[results save one2one $framesize $trial 1 $resultArrays]}  {
                errorMsg "Error saving results for Trial $trial"
                set retCode $::TCL_ERROR
            }
             
            if [results printToScreen one2one $framesize $trial] {
                set retCode $::TCL_ERROR
            }
            
            if {[dutConfig::DutConfigure TrialCleanup]} {
               logMsg "***** ERROR:  DUT Configuration failed.  Test aborted."
               return $::TCL_ERROR
           }
        }
    }
    
    if {[dutConfig::DutConfigure TestCleanup]} {
        logMsg "***** ERROR:  DUT Configuration failed.  Test aborted."
        return $::TCL_ERROR
    }

    catch {array unset one2oneArray}
    array set one2oneArray  [array get txRxArray]

    realTimeGraphs::StopRealTimeStat;
    scriptMateGuiCommand closeProgressMeter
    PassFailCriteriaTunnelCapacityEvaluate
    tunnel::writeNewResults_tunnelCapacity 


    if { [advancedTestParameter cget -removeStreamsAtCompletion] == "true"} {
        if [removeStreams one2oneArray] {
            errorMsg "Error removing streams."
            set retCode $::TCL_ERROR
        }
    }  

    return $retCode
}


########################################################################
# Procedure: writeNewResults
#
# This procedure create the CSV files used for PDF Report generation
# CSV File Format
#
########################################################################
proc tunnel::writeNewResults_tunnelCapacity {} {
   global one2oneArray 
   variable resultsDirectory
   variable trialsPassed;
   global resultArray testConf passFail
   global aggregateArray loggerParms

   set dirName $resultsDirectory

   if { [tunnel cget -framesizeList] == {} } {
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


   if {[catch {set csvFid [open $dirName/results.csv w]}]} {
       logMsg "***** WARNING:  Cannot open csv file."
       return
   }

   set portList {}

   foreach txMap [lnumsort [array names one2oneArray]] {
        scan $txMap "%d,%d,%d" tx_c tx_l tx_p
        set txPort [list $tx_c $tx_l $tx_p]
        foreach rxMap $one2oneArray($tx_c,$tx_l,$tx_p) {
           scan $rxMap "%d %d %d" rx_c rx_l rx_p
           set rxPort [list $rx_c $rx_l $rx_p]
       lappend portList [list $txPort $rxPort]
        }
     }
   
   set portList [lsort -dictionary $portList]  

   if {[catch {set csvFid [open $dirName/results.csv w]}]} {
      logMsg "***** WARNING:  Cannot open csv file."
      return
   }

   set enLatency [tunnel cget -enableLatency]
   set enSeqTotal [tunnel cget -enableSequenceTotal]
   set enSeqDetail [tunnel cget -enableSequenceDetail]
   set enDataIntegrity [tunnel cget -enableDataIntegrity]

   set csvHeader "Trial,Frame Size,Tx Port,Rx Port,Tunnel ID,Tx Tput (%),Tx Tput (fps),Tx Count (frames),Rx Count (frames),Frame Loss (frames),Frame Loss (%)" 
   
   if {$enSeqTotal == "true"} {
       set csvHeader "$csvHeader,Seq Errors"
   }
   
   if {$enDataIntegrity == "true"} {
       set csvHeader "$csvHeader,Integrity Frames,Integrity Errors"
   }

   puts $csvFid $csvHeader

   for {set trial 1} {$trial <= [tunnel cget -numtrials] } {incr trial} {
      foreach fs [lsort -dictionary [tunnel cget -framesizeList]] {

         set tunnelCount $resultArray($trial,$fs,1,iter,tunnelCount)

         for {set cnt 0} {$cnt < $tunnelCount} {incr cnt} {

            set pair [lindex $portList $cnt]
            set txPort  [lindex $pair 0]
            set rxPort  [lindex $pair 1]

            set tunnelID $resultArray($trial,$fs,1,[join $txPort ,],port,TXtunnelId)
            set txTputPct $resultArray($trial,$fs,1,[join $txPort ,],port,TXpercentTput)
            set txTput $resultArray($trial,$fs,1,[join $txPort ,],port,TXthroughput)
            set txCount $resultArray($trial,$fs,1,[join $txPort ,],port,TXtransmitFrames)
            set rxCount $resultArray($trial,$fs,1,[join $rxPort ,],port,RXreceiveFrames)
            set frameLossPct $resultArray($trial,$fs,1,[join $rxPort ,],port,RXpercentLoss)
            set frameLoss [mpexpr $txCount - $rxCount]

            set csvEntry "$trial,$fs,[join $txPort .],[join $rxPort .],$tunnelID,$txTputPct,$txTput,$txCount,$rxCount,$frameLoss,$frameLossPct"
            
            if {$enSeqTotal == "true"} {
                set seqErrors $resultArray($trial,$fs,1,[join $rxPort ,],port,RXtotalSeqError)
                set csvEntry "$csvEntry,$seqErrors"
            }
            
            if {$enDataIntegrity == "true"} {
                set integrityFrames $resultArray($trial,$fs,1,[join $rxPort ,],port,RXintegrityFrames)
                set integrityErrors $resultArray($trial,$fs,1,[join $rxPort ,],port,RXintegrityErrors)
                set csvEntry "$csvEntry,$integrityFrames,$integrityErrors"
            }

            puts $csvFid $csvEntry
         }         
      }
   }

   closeMyFile $csvFid


   #################################
   #
   #  Create Aggregate Result CSV
   #
   #################################

   if {[catch {set csvFid [open $dirName/AggregateResults.csv w]}]} {
      logMsg "***** WARNING:  Cannot open AggregateResults.csv file."
      return
   }
   set colHeads   {  "Trial"
                     "Frame Size"
                     "Agg Tx Tput (%)"
                     "Agg Tx Tput (fps)"
                     "Agg Tx Count (frames)"
                     "Agg Rx Count (frames)"
                     "Total Frame Loss (%)"
                     "Remaining Tunnels"
                  }
   
   if {$enSeqTotal == "true"} {
       lappend colHeads "Agg Seq Errors"
   }
  
   if {$enDataIntegrity == "true"} {
       lappend colHeads "Agg Integrity Frames" "Agg Integrity Errors"
   }
    
   puts $csvFid [join $colHeads ,]

   for {set trial 1} {$trial <= [tunnel cget -numtrials] } {incr trial} {
       foreach fs [lsort -dictionary [tunnel cget -framesizeList]] {

           set tunnelCount $resultArray($trial,$fs,1,iter,tunnelCount)

       set aggTxTputPctList {}
       set aggTxTputList {}
           set aggTxCountList {}
           set aggRxCountList {}
           set totalFrameLossPctList {}
           
           set aggSeqErrorsList {}           
           set aggIntegrityFramesList {}
           set aggIntegrityErrorsList {}

           set notCalculated 0

           for {set cnt 0} {$cnt < $tunnelCount} {incr cnt} {
               set pair [lindex $portList $cnt]
               set txPort  [lindex $pair 0]
               set rxPort  [lindex $pair 1]
               lappend aggTxTputPctList \
                   $resultArray($trial,$fs,1,[join $txPort ,],port,TXpercentTput)
               lappend aggTxTputList \
                   $resultArray($trial,$fs,1,[join $txPort ,],port,TXthroughput)
               lappend aggTxCountList \
                   $resultArray($trial,$fs,1,[join $txPort ,],port,TXtransmitFrames)
               lappend aggRxCountList \
                   $resultArray($trial,$fs,1,[join $rxPort ,],port,RXreceiveFrames)
               lappend totalFrameLossPctList \
                   $resultArray($trial,$fs,1,[join $rxPort ,],port,RXpercentLoss)
               
               if {$enSeqTotal == "true"} {
                   lappend aggSeqErrorsList \
                       $resultArray($trial,$fs,1,[join $rxPort ,],port,RXtotalSeqError)
               }
               
               if {$enDataIntegrity == "true"} {
                   lappend aggIntegrityFramesList \
                       $resultArray($trial,$fs,1,[join $rxPort ,],port,RXintegrityFrames)
                   lappend aggIntegrityErrorsList \
                       $resultArray($trial,$fs,1,[join $rxPort ,],port,RXintegrityErrors) 
               }
           }
           set aggTxTputPct [passfail::ListMean aggTxTputPctList]
           set aggTxTput [passfail::ListMean aggTxTputList]
           set aggTxCount [passfail::ListSum aggTxCountList]
           set aggRxCount [passfail::ListSum aggRxCountList]
           set totalFrameLossPct [passfail::ListMean totalFrameLossPctList]
           set remainingTunnels $tunnelCount
           set csvEntry "$trial,$fs,$aggTxTputPct,$aggTxTput,$aggTxCount,$aggRxCount,$totalFrameLossPct,$remainingTunnels"
           
           if {$enSeqTotal == "true"} {
               set aggSeqErrors [passfail::ListSum aggSeqErrorsList]
               set csvEntry "$csvEntry,$aggSeqErrors"
           }
           
           if {$enDataIntegrity == "true"} {
               set aggIntegrityFrames [passfail::ListSum aggIntegrityFramesList]
               set aggIntegrityErrors [passfail::ListSum aggIntegrityErrorsList]
               set csvEntry "$csvEntry,$aggIntegrityFrames,$aggIntegrityErrors"
           }

           puts $csvFid $csvEntry
       }
   }
   
   close $csvFid

   #################################
   #
   #  Create Info CSV
   #
   #################################

    csvUtils::writeInfoCsv tunnel;

    #################################
    #
    #  Create Real Time Chart CSV
    #
    #################################

    csvUtils::writeRealTimeCsv tunnel "IP Tunnel:Tunnel Capacity";

    csvUtils::GeneratePDFReportFromCLI tunnel
}


########################################################################
# Procedure:    tunnel::writeCapacityStreams
#
# Description:  Build and write Capacity test streams.
#       
#               Estimate & save frame rate at percentMaxRate
#               Estimate & save # of frames to transmit
#
# Arguments(s): TxRxArray:      map array, ie. one2oneArray
#               PercentMaxRate: maximum transmission rate
#               frameRate:      location to store frame rate (at percentMaxRate)
#               txNumFrames:    location to store estimate of # tx frames
#               testCmd:        name of test command, capacity
#               preambleSize:   preamble size, default = 8
#
# Returns:      TCL_OK or TCL_ERROR
#
########################################################################
proc tunnel::writeCapacityStreams {TxRxArray percentMaxRate Framerate {TxNumFrames ""} {testCmd tunnel} {preambleSize 8}} \
{
    upvar $TxRxArray        txRxArray
    upvar $Framerate        framerate
    upvar $TxNumFrames      txNumFrames

    set retCode $::TCL_OK

    if {$percentMaxRate <= 0} {
        set percentMaxRate 1
    }

    set tunnelProtocol                  [tunnel cget -tunnelProtocol]
    set payloadProtocol                 [tunnel cget -payloadProtocol]
    set encapsulation                   [tunnel cget -encapsulation]

    if {$encapsulation == "ingress"} {
        set signatureOffset         82
        set dataIntegrityOffset     82
    } else {
        set signatureOffset         62
        set dataIntegrityOffset     62
    }

    set groupIdOffset        [expr $signatureOffset + 4]
    set sequenceNumberOffset [expr $signatureOffset + 8]

    stream setDefault
    stream config -rateMode             usePercentRate
    stream config -gapUnit              gapNanoSeconds
    stream config -framesize            [$testCmd cget -framesize]
    stream config -preambleSize         $preambleSize
    stream config -numBursts            1
    stream config -loopCount            1
    stream config -dma                  stopStream
    stream config -fir                  $::true
    stream config -percentPacketRate    $percentMaxRate
    set duration                        [tunnel cget -duration]

    disableUdfs {1 2 3 4}


    # Initialize test local variables for each Tx port configured on each card on all chassis
    foreach txMap [lnumsort [array names txRxArray]] {
        scan $txMap "%d,%d,%d" tx_c tx_l tx_p
        set streamID    1
        foreach rxMap $txRxArray($tx_c,$tx_l,$tx_p) {
            scan $rxMap "%d %d %d" rx_c rx_l rx_p

            set txPortId    [getPortId $tx_c $tx_l $tx_p] 
            set rxPortId    [getPortId $rx_c $rx_l $rx_p] 

            # Construct tunnel payload (inside packet).
            logMsg "Configuring Tunnel Payload $txPortId -> $rxPortId"

            # If in automatic-mode, construct the addresses appropriately (only need the tunnel endpoint).
            if {[tunnel cget -tunnelConfiguration] == "automatic"} {

                if {$payloadProtocol == "ipV6"} {

                    if {$encapsulation == "ingress"} {
                        scan $txMap "%d,%d,%d" c l p
                    } else {
                        scan [join $txRxArray($txMap)] "%d %d %d" c l p
                    }

                    if {![ipV6 get $c $l $p]} {
                        ipV6 config -sourceAddr  [buildAutomaticAddress $c $l $p source]

                        if {[ipV6 set $c $l $p]} {
                            logMsg "Error: Unable to configure IPv6 parameters for [getPortId $c $l $p]"
                            set retCode $::TCL_ERROR
                        }

                        #set protocolList [list $::ipV6 $::ip]
                        #set retCode [interfaceTable::configurePort $c $l $p $protocolList]
                        
                        buildTunnelTranslations txRxArray

                    } else {
                        logMsg "Error: Unable to build automatic addresses."
                        set retCode $::TCL_ERROR
                    }

                } else {
                    logMsg "Error: Invalid configuration for Automatic Tunneling."
                    set retCode $::TCL_ERROR
                }
            }   

            # Construct the payload packet.
            protocol config -name $payloadProtocol
            set streamName [format "TunnelPayload%sStream%d" Capacity $streamID]
            ::buildStreamParms  $payloadProtocol            \
                                $streamName                 \
                                $tx_c $tx_l $tx_p           \
                                $rx_c $rx_l $rx_p           \
                                no                          \
                                [$testCmd cget -framesize]  \
                                no

            stream config -framesize [$testCmd cget -framesize]
            if {[stream set $tx_c $tx_l $tx_p $streamID]} {
                errorMsg "Error setting stream $streamID on [getPortId $tx_c $tx_l $tx_p]"
                set retCode $::TCL_ERROR
            }

            # Construct Encapsulation packet.
            if {$encapsulation == "ingress"} {

                logMsg "Configuring Tunnel $txPortId -> $rxPortId"
                
                set streamName          [format "Tunnel%sStream%d" Capacity $streamID]
                set offset              [getHeaderLength mac]
                set packet              [lrange [stream cget -packetView] $offset end-4]

                protocol config -name $tunnelProtocol
                tunnel::buildStreamParms  $streamName \
                                  $tx_c $tx_l $tx_p \
                                  $rx_c $rx_l $rx_p \
                                  packet
                if [stream set $tx_c $tx_l $tx_p $streamID] {
                    errorMsg "Error setting stream $streamID on [getPortId $tx_c $tx_l $tx_p]"
                    set retCode $::TCL_ERROR
                }
            }

            if [catch {calculateStreamNumFrames [stream cget -framerate] duration} numFrames] {
                $testCmd config -duration $duration
            }
            stream config -numFrames $numFrames
            if [stream set $tx_c $tx_l $tx_p $streamID] {
                errorMsg "Error setting stream $streamID on [getPortId $tx_c $tx_l $tx_p]"
                set retCode $::TCL_ERROR
            }


            # Setup Packet Groups for Tx Ports.
            set framesize [stream cget -framesize]
            set signature                               [format "%02x %02x %02x %02x" 0x58 $rx_c $rx_l $rx_p]

            packetGroupStats setDefault
            packetGroup config -insertSignature true
            packetGroup config -signatureOffset         $signatureOffset
            packetGroup config -signature               $signature
            packetGroup config -groupIdOffset           $groupIdOffset
            packetGroup config -groupId                 [getTunnelTranslation $tx_c $tx_l $tx_p]
            packetGroup config -sequenceNumberOffset    $sequenceNumberOffset

            packetGroup config -insertSequenceSignature true
            packetGroup config -allocateUdf             true

            dataIntegrity config -signatureOffset $dataIntegrityOffset
            dataIntegrity config -signature       $signature
            dataIntegrity config -insertSignature true
            dataIntegrity config -enableTimeStamp true

            foreach command {packetGroup dataIntegrity} {
                if {[eval $command setTx $tx_c $tx_l $tx_p $streamID]} {
                    errorMsg "Error: Unable to perform $command setTx on [getPortId $tx_c $tx_l $tx_p]"
                    set retCode $::TCL_ERROR
                    continue
                }
            }

	    #
            # Modify Rx Filters by length of Tunnel Header.
	    #
            if {$encapsulation == {ingress}} {
		set offset -[getHeaderLength $tunnelProtocol current]
	    } else {
		set offset [getHeaderLength $tunnelProtocol current]
	    }

	    packetGroup config -signatureOffset         [expr $signatureOffset + $offset]
            packetGroup config -groupIdOffset           [expr $groupIdOffset + $offset]
            packetGroup config -sequenceNumberOffset    [expr $sequenceNumberOffset + $offset]
	    dataIntegrity config -signatureOffset       [expr $dataIntegrityOffset + $offset]

            foreach command {packetGroup dataIntegrity} {
                if {[eval $command setRx $rx_c $rx_l $rx_p]} {
                    errorMsg "Error: Unable to perform $command setRx on [getPortId $rx_c $rx_l $rx_p]"
                    set retCode $::TCL_ERROR
                    continue
                }
            }

            # Set up the pattern filter
            filterPallette config -pattern1         $signature
            filterPallette config -patternOffset1   [expr $signatureOffset + $offset]
            
            if [filterPallette set $rx_c $rx_l $rx_p] {
                errorMsg "Error setting filter pallette for [getPortId $rx_c $rx_l $rx_p]"
                set retCode $::TCL_ERROR
                continue
            }
            
            # Set the filter parameters on the receive port
            filter config -userDefinedStat2Enable           true
            filter config -userDefinedStat2Pattern          pattern1
            if [filter set $rx_c $rx_l $rx_p] {
                errorMsg "Error setting filters on [getPortId $rx_c $rx_l $rx_p]"
                set retCode $::TCL_ERROR
                continue
            }
            incr streamID

        }
        set framerate($tx_c,$tx_l,$tx_p)    [stream cget -floatRate]
        set txNumFrames($tx_c,$tx_l,$tx_p)  [stream cget -numFrames]
    }

    if {$retCode == 0} {
        adjustOffsets    txRxArray
        set retCode [writeConfigToHardware txRxArray]
    }

    return $retCode
}

################################################################################
#
# tunnel::PassFailCriteriaTunnelCapacityEvaluate()
#
# DESCRIPTION:
# This procedure calculates the number of trials that have executed successfully
# based upon user-specified Pass/Fail criteria.  
# 
# Tunnel Capacity is the minimum number of remaining tunnels
# across any frame sizes for a given trial.
#
# Average Latency is the average latency of any port pair across any frame sizes 
# for a given trial
# Maximum Latency is the largest latency of any port pair across any frame sizes 
# for a given trial
#
# Average Sequence Errors is an average number of seqeunce errors across any frame 
# sizes and all ports for a given trial
# Maximum Sequence Errors is the maximum number of sequence errors accross any frame
# sizes and all ports for a given trial
#
# Average CRC Errors is an average number of crc errors across any frame 
# sizes and all ports for a given trial
# Maximum CRC Errors is the maximum number of crc errors accross any frame
# sizes and all ports for a given trial
#
# MODIFIES
# trialsPassed      - namespace variable indicating number of successful trials.
#
# RETURNS
# none
#
###
proc tunnel::PassFailCriteriaTunnelCapacityEvaluate {} {
    variable resultsDirectory
    variable trialsPassed
    global resultArray testConf
    global one2oneArray

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

    set enLatency    [expr {[tunnel cget -enableLatency] == "true"}]
    set enSeqTotal   [expr {[tunnel cget -enableSequenceTotal] == "true"}]
    set enDataIntegrity [expr {[tunnel cget -enableDataIntegrity] == "true"}]
    
    # compute list of ports used by the test
    set portList {}
    foreach txMap [lnumsort [array names one2oneArray]] {
        scan $txMap "%d,%d,%d" tx_c tx_l tx_p
        set txPort [list $tx_c $tx_l $tx_p]
        foreach rxMap $one2oneArray($tx_c,$tx_l,$tx_p) {
           scan $rxMap "%d %d %d" rx_c rx_l rx_p
           set rxPort [list $rx_c $rx_l $rx_p]
       lappend portList [list $txPort $rxPort]
        }
     }
   
    set portList [lsort -dictionary $portList]  

    set portCount     [llength $portList]
    set trialsPassed  0

    for {set trial 1} {$trial <= [tunnel cget -numtrials] } {incr trial} {

    logMsg "*** Trial #$trial"

        set capacityList {}
    set avgLatencyList {}
    set maxLatencyList {}
        set seqErrorsList {}
        set crcErrorsList {}

    foreach fs [lsort -dictionary [tunnel cget -framesizeList]] {
           set tunnelCount $resultArray($trial,$fs,1,iter,tunnelCount)  
           for {set cnt 0} {$cnt < $tunnelCount} {incr cnt} {
                set pair [lindex $portList $cnt]

        set txPort  [lindex $pair 0]
        set rxPort  [lindex $pair 1]

                set frameLossPct $resultArray($trial,$fs,1,[join $rxPort ,],port,RXpercentLoss)

                if {$frameLossPct <= [tunnel cget -tolerance]} {
                    lappend capacityList $resultArray($trial,$fs,1,iter,tunnelCount) 
                } else {
                    lappend capacityList "notCalculated" 
                }
        
                
                if {$enLatency && (!$frameLossPct) } {
                    lappend avgLatencyList \
                        $resultArray($trial,$fs,1,[join $rxPort ,],port,RXavgLatency)
                    lappend maxLatencyList \
                        $resultArray($trial,$fs,1,[join $rxPort ,],port,RXmaxLatency)
                } else { 
                    lappend avgLatencyList "notCalculated"
                    lappend maxLatencyList "notCalculated"
                }
                
                if {$enSeqTotal} {
                    lappend seqErrorsList $resultArray($trial,$fs,1,[join $rxPort ,],port,RXtotalSeqError)                
                } 

                if {$enDataIntegrity} {
                    lappend crcErrorsList \
                        $resultArray($trial,$fs,1,[join $rxPort ,],port,RXintegrityErrors)
                } 
            } 

    } 

    #Minimum Tunnel Capacity is the minimum number of remaining tunnels
        # across any frame sizes for a given trial.
        if {[lsearch $capacityList "notCalculated"] >= 0} {
            set minCapacity "notCalculated"
        } else {
            set minCapacity  [passfail::ListMin capacityList]
        }
        
        if {$enLatency} {
            
            if {[lsearch $avgLatencyList "notCalculated"] >= 0} {
                set avgLatency "notCalculated"
                set maxLatency "notCalculated"
            } else {
                # Maximum Latency is the largest latency of any port pair
                # across any frame sizes for a given trial
                set maxLatency [passfail::ListMax maxLatencyList]

                # Average Latency is the average latency of any port pair
                # across any frame sizes for a given trial
                set avgLatency [passfail::ListMean avgLatencyList]
            }
        } 

        if {$enSeqTotal} {
            # Maximum Sequence Errors is the maximum number of seq errors accross any frame
            # sizes and all ports for a given trial
            set maxSeqErrors [passfail::ListMax seqErrorsList]
    
            # Average Sequence Errors is an average number of sequence errors across any frame 
            # sizes and all ports for a given trial
            set avgSeqErrors [passfail::ListMean seqErrorsList]
        } 

        if {$enDataIntegrity} {
            # Maximum CRC Errors is the maximum numer of crc errors accross any frame
            # sizes and all ports for a given trial
            set maxCRCErrors [passfail::ListMax crcErrorsList]
            
            # Average CRC Errors is an average number of crc errors across any frame 
            # sizes and all ports for a given trial
            set avgCRCErrors [passfail::ListMean crcErrorsList]
        }

        # Pass/Fail Criteria is based on the logical AND of more criteria
    set result [passfail::PassFailCriteriaCapacityEvaluate $minCapacity]
    
    if {$enLatency} {  
            if {([passfail::PassFailCriteriaLatencyEvaluate $avgLatency $maxLatency] == "PASS") \
                 && ($result == "PASS") } {
        set result "PASS"
        } else {
                set result "FAIL"
            }
        }
        
        if {$enSeqTotal} {
            if {([passfail::PassFailCriteriaSeqErrorsEvaluate $avgSeqErrors $maxSeqErrors] == "PASS") \
                 && ($result == "PASS") } {
        set result "PASS"
        } else {
                set result "FAIL"
            }

        }
        
        if {$enDataIntegrity} {
            if {([passfail::PassFailCriteriaCRCErrorsEvaluate $avgCRCErrors $maxCRCErrors] == "PASS") \
                 && ($result == "PASS") } {
        set result "PASS"
        } else {
                set result "FAIL"
            }
        }
        

    if { $result == "PASS" } {
        incr trialsPassed
    }
    logMsg "*** $result\n"
       
    } ;# loop over trials

    logMsg "*** # Of Trials Passed: $trialsPassed"
    logMsg "***************************************"

}


