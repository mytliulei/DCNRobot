##################################################################################
# Version 3.70  $Revision: 6 $
# $Date: 12/12/02 2:03p $
# $Author: Dheins $
#
# $Workfile: frameloss.tcl $ - Tunnel Frame Loss test
#
#   Copyright © 1997 - 2004 by IXIA
#   All Rights Reserved.
#
#   Revision Log:
#   10-01-2002      DHG     Initial
#
# Description: This file contains the script for running the Frame Loss Rate
# test as defined in RFC 2544 by S.Bradner over an IP/IPv6 tunnel.
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
                        <Source scope="results.csv" entity_name="tunnelFrameLoss" format_id=""/>
                        <Source scope="info.csv" entity_name="tunnelFrameLoss_Info" format_id=""/>
                        <Source scope="AggregateResults.csv" entity_name="tunnelFrameLoss_Aggregate" format_id=""/>
                        <Source scope="Iteration.csv" entity_name="tunnelFrameLoss_Iteration" format_id=""/>
                     </Sources>
                  </XMD>
   }
}

##   Tunnel Namespace Variable Definitions

#   Metric Name         Result Array            Port        Initial     Iteration   Result         Print
#                                               Direction   Value       Reset?      Set            Order
array unset ::tunnel::portResultArrays
variable ::tunnel::portResultArrays
array set ::tunnel::portResultArrays  {
    tunnelId            {tunnelIdValues             tx      0           false       standard       1}
    transmitFrames      {txActualFrames             tx      0           true        standard       2} 
    receiveFrames       {rxNumFrames                rx      0           true        standard       3} 
    throughput          {thruputRate                tx      0.0         false       standard       4} 
    percentTput         {percentTput                tx      0.0         false       standard       5} 
    percentLoss         {frameloss                  rx      0.0         true        standard       6} 
    integrityErrors     {integrityErrorValues       rx      0           true        integrity      2}
    integrityFrames     {integrityFrameValues       rx      0           true        integrity      1}
}

##   End Tunnel Namespace Variable Definitions

########################################################################################
# Procedure:    tunnel::registerResultVars_floss
#
# Description:  This command registers all the local variables that are used in the
#               display of the results with the Results Options Database.  This procedure 
#               must exist for each test.
#
# Arguments:    None
#
# Returns:      TCL_OK
#
########################################################################################
proc tunnel::registerResultVars_floss {} \
{
    variable portResultArrays

    # Add extra variables the result registry.
    if [ results addOptionToDB    tolerance         "Tolerance(%)    "      12 12 iter]    { return $::TCL_ERROR }
    if [ results addOptionToDB    TXtunnelId        "TunnelId  "            15 15 port]    { return $::TCL_ERROR }
    if [ results addOptionToDB    RXintegrityErrors "IntegrityErrors"       16 16 port]    { return $::TCL_ERROR }
    if [ results addOptionToDB    RXintegrityFrames "IntegrityFrames"       16 16 port]    { return $::TCL_ERROR }


    # Configuration information stored for results
    if [ results registerTestVars testName          testName            [tunnel cget -testName] test ] { return $::TCL_ERROR }
    if [ results registerTestVars protocol          protocolName        [string toupper [getProtocolName [protocol cget -name]]] test ] { return $::TCL_ERROR }
    if [ results registerTestVars chassisName       chassisName         [chassis cget -name]            test    ] { return $::TCL_ERROR }
    if [ results registerTestVars chassisID         chassisID           [chassis cget -id]              test    ] { return $::TCL_ERROR }
    if [ results registerTestVars productName       productName         [user cget -productname]        test    ] { return $::TCL_ERROR }
    if [ results registerTestVars versionNumber     versionNumber       [user cget -version]            test    ] { return $::TCL_ERROR }
    if [ results registerTestVars serialNumber      serialNumber        [user cget -serial#]            test    ] { return $::TCL_ERROR }
    if [ results registerTestVars userName          userName            [user cget -username]           test    ] { return $::TCL_ERROR }
    if [ results registerTestVars percentMaxRate    percentMaxRate      [tunnel cget -percentMaxRate]   test    ] { return $::TCL_ERROR }
    if [ results registerTestVars numTrials         numTrials           [tunnel cget -numtrials]        test    ] { return $::TCL_ERROR }
    if [ results registerTestVars duration          duration            0                               test    ] { return $::TCL_ERROR }

    # Results obtained after each iteration
    if [ results registerTestVars totalTxFrames     totalTxNumFrames    0                               iter    ] { return $::TCL_ERROR }     
    if [ results registerTestVars totalRxFrames     totalRxNumFrames    0                               iter    ] { return $::TCL_ERROR }

    # Results obtained per port.
    foreach {metric arrayList} [array get portResultArrays] {
        scan $arrayList "%s %s %s %s %s" array portDirection initialValue iterationReset class
        if {[results registerTestVars $metric $array $initialValue port [stringToUpper $portDirection 0 1]]} {
            set retCode $::TCL_ERROR
            break
        }
    }



    return $::TCL_OK
}


########################################################################################
# Procedure:    tunnel::floss
#
# Description:  This procedure implements the RFC 2544 Frame Loss Rate test. Frames are sent
#               on each port of every card (load module) in the configuration file. For this test,
#               there is only one stream per port with a specific frame size and rate. First, the 
#               ports on each card are configured with the speed and duplex mode. Then the stream per
#               port is configured.
#
#               Then the trials are run. In each trial, for each port on all cards, the burst and frame
#               parametres for each stream are configured first. Then the frames are transmitted at the
#               given Tx rate. 
#
#               From rfc 2544, page 16, frame loss is defined as the following:
#               Send a specific number of frames at a specific rate through the
#               DUT to be tested and count the frames that are transmitted by the
#               DUT.   The frame loss rate at each point is calculated using the
#               following equation:
#                   
#                ( ( input_count - output_count ) * 100 ) / input_count
#               
#               The first trial SHOULD be run for the frame rate that corresponds
#               to 100% of the maximum rate for the frame size on the input media.
#               Repeat the procedure for the rate that corresponds to 90% of the
#               maximum rate used and then for 80% of this rate.  This sequence
#               SHOULD be continued (at reducing 10% intervals) until there are
#               two successive trials in which no frames are lost. The maximum
#               granularity of the trials MUST be 10% of the maximum rate, a finer
#               granularity is encouraged.
#
# Arguments:    None
#
# Returns:      TCL_OK
#
########################################################################################
proc tunnel::floss {} \
{ 
    variable status;
    
    set status $::TCL_OK;
    
    if {[catch {set status [tunnel::TestMethod_floss]} ERROR]} {    
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
# tunnel::TestMethod_floss()
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
proc tunnel::TestMethod_floss {} {
    global one2oneArray
    set retCode $::TCL_OK
    global testConf

    variable xmdDef
    variable resultsDirectory
    variable trial
    variable framesize

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

    set dirName "[results cget -directory]/IP Tunnel.resDir/Tunnel Frame Loss.resDir/[file rootname [csvUtils::getCurrentScriptName]].res"

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
               "Frame Rate (fps)"
               "Tx Count (frames)"
               "Rx Count (frames)"
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




    # Packet Group Statistics collected.
    array set pgStatistics {
       totalFrames          rxNumFrames          
    }

    
    set encapsulation   [tunnel cget -encapsulation]
    if {$encapsulation == "ingress"} {
        learn config -type $tunnelProtocol
    } else {
        learn config -type $payloadProtocol
    }

    set testName "IPv6 Tunnel Frame Loss Test - [stringToUpper $encapsulation 0], [getBinarySearchString tunnel]"
    tunnel config -testName $testName

    # Setup Port Recieve Mode.
    set receiveMode [expr $::portPacketGroup | $::portRxDataIntegrity]
    if [changePortReceiveMode one2oneArray $receiveMode write] {
        errorMsg  "Error: Unable to set port recieve mode."
return $::TCL_ERROR
    }

    if [initTest tunnel one2oneArray {ip ipV6} errMsg no] {
        errorMsg $errMsg
return $::TCL_ERROR
    }

    if {[learn cget -when] == "oncePerTest"} {
        if {[learnIngressAndEgress one2oneArray]} {
            errorMsg "Error: Unable to send ARP/Neighbor Discovery frames"
            return $::TCL_ERROR
        }
    }

    set txPortList          [getTxPorts one2oneArray]
    set rxPortList          [getRxPorts one2oneArray]

    set preambleSize        8
    set protocolName        [getProtocolName [protocol cget -name]]
    set percentMaxRate      [tunnel cget -percentMaxRate]
    if {[string compare [tunnel cget -grain] "fine"] == 0} {
        set grain   1       ;# 1 clock tick
    } else {
        set grain   10      ;# 10 percent
    }

    initializePortResultArrays one2oneArray
    buildTunnelTranslations one2oneArray

    realTimeGraphs::StartRealTimeStat;
    scriptMateGuiCommand openProgressMeter


    set totalDuration 0

    foreach framesize [tunnel cget -framesizeList] {
    
        tunnel config -framesize  $framesize  

        tunnel config -percentMaxRate    $percentMaxRate

        # Learn for each frame size if needed.
        if {[learn cget -when] == "oncePerFramesize"} {
            if {[learnIngressAndEgress one2oneArray]} {
                errorMsg "Error: Unable to send ARP/Neighbor Discovery frames"
                return $::TCL_ERROR
            }
        }

        # Set up results for this test
        setupTestResults tunnel one2one "one2one"           \
                                one2oneArray                \
                                $framesize                  \
                                [tunnel cget -numtrials]    \
                                true                        \
                                2                           \
                                floss               

        results config -rowStyle            oneFramesizePerRow
        results config -rowTitleType        tunnelId
        results config -printRxRowValues    allRows
        results config -numPortMapColumns   0
        results config -summary             true


        for {set trial 1} {$trial <= [tunnel cget -numtrials]} {incr trial} {
            logMsg "******* TRIAL $trial - [tunnel cget -testName] *******"
            
            if {[dutConfig::DutConfigure TrialSetup]} {
               logMsg "***** ERROR:  DUT Configuration failed.  Test aborted."
               return $::TCL_ERROR
           } 

        realTimeGraphs::SaveRealTimeMarker "-- Trial:$trial FS:$framesize--";

            if {[learn cget -when] == "onTrial"} {
                if {[learnIngressAndEgress one2oneArray]} {
                    errorMsg "Error: Unable to send ARP/Neighbor Discovery frames"
                    return $::TCL_ERROR
                }
            }

            if [initMaxRate one2oneArray maxFrameRate $framesize userRate] {
                return $::TCL_ERROR
            }

            # Initialize local test variables for each Tx port.
            set donelist [list]
            foreach txMap $txPortList {
                scan $txMap "%d %d %d" tx_c tx_l tx_p
                scan $one2oneArray($tx_c,$tx_l,$tx_p) "{%d %d %d}" rx_c rx_l rx_p

                set doneList                        [lappend doneList [list $txMap]]
                set currPercent($tx_c,$tx_l,$tx_p)  [tunnel cget -percentMaxRate]
            }

            if [writeFlossStreams one2oneArray currPercent currFrameRate txNumFrames] {
                return $::TCL_ERROR
            }


            # Re-Calculate the rate based upon the actual frame size.
            foreach txMap [array names one2oneArray] {}
            scan $txMap "%d,%d,%d" c l p
            stream get $c $l $p 1
            if [initMaxRate one2oneArray maxFrameRate [stream cget -framesize] userRate] {
                return $::TCL_ERROR
            }

            set iteration 1

            # Start frameloss search at 100% max rate, then work down by 10% until 0 frameloss is acheived.
            while {[llength $doneList] > 0} {
                logMsg "\n---> ITERATION $iteration, framesize $framesize, [tunnel cget -testName]"

                initializePortResultArrays one2oneArray iteration
                set maxDuration 0

                # Set the stream based on new rate
                foreach txMap [array names one2oneArray] {

                    scan $txMap "%d,%d,%d" tx_c tx_l tx_p
                    if [stream get $tx_c $tx_l $tx_p 1] {
                        errorMsg "Error getting stream [getPortId $tx_c $tx_l $tx_p] 1."
                        set retCode $::TCL_ERROR
                    }                         

                    set duration [mpexpr int( ceil( [calculateDuration $txNumFrames($tx_c,$tx_l,$tx_p) \
                                                                        $currFrameRate($tx_c,$tx_l,$tx_p) \
                                                                        [stream cget -numFrames] \
                                                                        [stream cget -loopCount]] ))]
                    if {$duration == 0} {
                        set duration    1
                    }

                    if {$duration > $maxDuration} {
                        set maxDuration $duration
                    }
                }

                if [clearStatsAndTransmit one2oneArray $maxDuration [tunnel cget -staggeredStart]] {
                    return $::TCL_ERROR
                }

                set totalDuration [mpexpr {$maxDuration+$totalDuration}]

                waitForResidualFrames [tunnel cget -waitResidual]

        # Poll the Tx counters until all frames are sent
                stats::collectTxStats $txPortList txNumFrames txActualFrames totalTxNumFrames

                # Collect Packet Group Stats.
                foreach {stat statArray} [array get statistics] {
                    catch {array unset $statArray}
                    array set $statArray {}
                }
                if {[tunnel::collectPacketGroupStats one2oneArray pgStatistics]} {
                    errorMsg "Error: Unable to collect packet group statistics"
                    set retCode $::TCL_ERROR
                }

                # Collect Total Frames Rx'd for all Tunnels
                set totalRxNumFrames 0
                foreach {rxMap value} [array get rxNumFrames] {
                    incr totalRxNumFrames $value
                }
                debugMsg "totalRxNumFrames:$totalRxNumFrames"
                
                
                catch {array unset tunnelIdValues}
                getTranslationArray tunnelIdValues prefix


                foreach txMap [lnumsort $doneList] {
                    scan [join $txMap] "%d %d %d" tx_c tx_l tx_p

                    scan $one2oneArray($tx_c,$tx_l,$tx_p) "{%d %d %d}" rx_c rx_l rx_p

                    # if no frames received, there must be a connection error... dump out
                    if {$rxNumFrames($rx_c,$rx_l,$rx_p) == 0} {
                        set percentLossFormat [advancedTestParameter cget -percentLossFormat]
                        set percentLossValue  [formatNumber 100 $percentLossFormat]
                        lappend frameLoss($tx_c,$tx_l,$tx_p) [list $currFrameRate($tx_c,$tx_l,$tx_p) $percentLossValue]
                        set rxFrames($rx_c,$rx_l,$rx_p,$currFrameRate($tx_c,$tx_l,$tx_p)) 0

                        if {[set index [lsearch $doneList $txMap]] >= 0} {
                            set doneList [lreplace $doneList $index $index]
                        }                            
                        set percentLoss   100.0
                    } else {

                    # Get the frameLoss; remember it's in array form: frameLoss(c,lm,p,framerate)
                       set percentLoss [calculatePercentLoss $txNumFrames($tx_c,$tx_l,$tx_p) $rxNumFrames($rx_c,$rx_l,$rx_p)]
                       lappend frameLoss($tx_c,$tx_l,$tx_p) [list $currFrameRate($tx_c,$tx_l,$tx_p) [join $percentLoss]]
                       set rxFrames($rx_c,$rx_l,$rx_p,$currFrameRate($tx_c,$tx_l,$tx_p))   $rxNumFrames($rx_c,$rx_l,$rx_p)
                    }

                    #  Write in Iteration.CSV 
                    csvUtils::writeIterationCSVFile tunnel [list $iteration \
                                                                 "$tx_c.$tx_l.$tx_p" \
                                                                 "$rx_c.$rx_l.$rx_p" \
                                                                 $tunnelIdValues($tx_c,$tx_l,$tx_p) \
                                                                 $currFrameRate($tx_c,$tx_l,$tx_p) \
                                                                 $txNumFrames($tx_c,$tx_l,$tx_p) \
                                                                 $rxNumFrames($rx_c,$rx_l,$rx_p) \
                                                                 $percentLoss]
                    

                    if {$rxNumFrames($rx_c,$rx_l,$rx_p) == 0} {
                             continue
                    }

                    # Port is done.
                    if {$rxNumFrames($rx_c,$rx_l,$rx_p) == $txNumFrames($tx_c,$tx_l,$tx_p)} {
                        if {[set index [lsearch $doneList $txMap]] >= 0} {
                            set doneList [lreplace $doneList $index $index]
                        }

                    } else {
                        set currPercent($tx_c,$tx_l,$tx_p)    [mpexpr $currPercent($tx_c,$tx_l,$tx_p) - $grain]

                        if {$currPercent($tx_c,$tx_l,$tx_p) > 0} {
                            set currFrameRate($tx_c,$tx_l,$tx_p)    [stream cget -floatRate]

                        } else {

                            if {[set index [lsearch $doneList $txMap]] >= 0} {
                                set doneList [lreplace $doneList $index $index]
                            }
                        }

                        debugMsg "2)currPercent($tx_c,$tx_l,$tx_p):$currPercent($tx_c,$tx_l,$tx_p)"
                        debugMsg "currFrameRate($tx_c,$tx_l,$tx_p):$currFrameRate($tx_c,$tx_l,$tx_p)"
                    }
                }
                if [writeFlossStreams one2oneArray currPercent currFrameRate txNumFrames] {
                                   return $::TCL_ERROR
                }
                 catch {array unset tunnelIdValues}
                 getTranslationArray tunnelIdValues prefix
                if {[llength $doneList] > 0} {
                    writeConfigToHardware   one2oneArray
                    printIntermediateResults one2oneArray tunnelIdValues txActualFrames rxNumFrames frameLoss
                }
                incr iteration
            }

            set percentFormat   [advancedTestParameter cget -defaultFloatFormat]

            foreach txMap $txPortList {
                scan $txMap "%d %d %d" tx_c tx_l tx_p
                scan $one2oneArray($tx_c,$tx_l,$tx_p) "{%d %d %d}" rx_c rx_l rx_p

                foreach item $frameLoss($tx_c,$tx_l,$tx_p) {
                    scan $item "%s %s" crate percentLoss
                
                    set txRate [calculatePercentThroughput [expr round($crate)] $maxFrameRate($tx_c,$tx_l,$tx_p)]
                    set percentTput($tx_c,$tx_l,$tx_p) $txRate
                    set thruputRate($tx_c,$tx_l,$tx_p) [expr round($crate)]
                
                    regsub -all {[^0-9.]} $percentLoss {} percentLoss

                    set percentLoss [formatNumber $percentLoss [advancedTestParameter cget -percentLossFormat]]
                    set frameloss($rx_c,$rx_l,$rx_p) $percentLoss
                }
            }
            collectDataIntegrityStats [getRxPorts one2oneArray] integrityErrorValues integrityFrameValues

            catch {array unset tunnelIdValues}
            getTranslationArray tunnelIdValues prefix


            # Store Results.
            logMsg "Saving results for Trial $trial ..."

            set resultArrays [getResultListByClass standard]
            if {[tunnel cget -enableDataIntegrity] == "true"} {
                lappend resultArrays [getResultListByClass integrity]
            }
            lappend resultArrays totalTxNumFrames totalRxNumFrames
            set resultArrays [join $resultArrays]

            # Store Results Per Trial.
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

    tunnel config -duration  [mpexpr round($totalDuration/([tunnel cget -numtrials]*[llength [tunnel cget -framesizeList]]))]
    realTimeGraphs::StopRealTimeStat;
    scriptMateGuiCommand closeProgressMeter
    PassFailCriteriaTunnelFrameLossEvaluate
    tunnel::writeNewResults_tunnelFrameLoss 


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
proc tunnel::writeNewResults_tunnelFrameLoss {} {
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

   set enDataIntegrity [tunnel cget -enableDataIntegrity]
   
   set csvHeader "Trial,Frame Size,Tx Port,Rx Port,Tunnel ID,Tx Tput (fps),Tx Tput (%),Tx Count (frames),Rx Count (frames),Frame Loss (frames),Frame Loss (%)" 

   if {$enDataIntegrity == "true"} {
       set csvHeader "$csvHeader,Integrity Frames,Integrity Errors"
   }

   puts $csvFid $csvHeader

   for {set trial 1} {$trial <= [tunnel cget -numtrials] } {incr trial} {
      foreach fs [lsort -dictionary [tunnel cget -framesizeList]] {
       
         foreach pair $portList {

            set txPort  [lindex $pair 0]
            set rxPort  [lindex $pair 1]

            set tunnelID $resultArray($trial,$fs,1,[join $txPort ,],port,TXtunnelId)
            set txTputPct $resultArray($trial,$fs,1,[join $txPort ,],port,TXpercentTput)
            set txTputFps $resultArray($trial,$fs,1,[join $txPort ,],port,TXthroughput)
            set txCount $resultArray($trial,$fs,1,[join $txPort ,],port,TXtransmitFrames)
            set rxCount $resultArray($trial,$fs,1,[join $rxPort ,],port,RXreceiveFrames)
            set frameLossPct $resultArray($trial,$fs,1,[join $rxPort ,],port,RXpercentLoss)
            set frameLoss [mpexpr $txCount - $rxCount]

            set csvEntry "$trial,$fs,[join $txPort .],[join $rxPort .],$tunnelID,$txTputFps,$txTputPct,$txCount,$rxCount,$frameLoss,$frameLossPct"

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
                     "Agg Tx Tput (fps)"
                     "Agg Tx Tput (%)"
                     "Agg Tx Count (frames)"
                     "Agg Rx Count (frames)"
                     "Total Frame Loss (%)"
                  }

   if {$enDataIntegrity == "true"} {
       lappend colHeads "Agg Integrity Frames" "Agg Integrity Errors"
   }
    
   puts $csvFid [join $colHeads ,]

   for {set trial 1} {$trial <= [tunnel cget -numtrials] } {incr trial} {
       foreach fs [lsort -dictionary [tunnel cget -framesizeList]] {

           set aggTxTputPctList {}
           set aggTxTputFpsList {}
           set aggTxCountList {}
           set aggRxCountList {}
           set totalFrameLossPctList {}

           set aggIntegrityFramesList {}
           set aggIntegrityErrorsList {}

           foreach pair $portList {
               
               set txPort  [lindex $pair 0]
               set rxPort  [lindex $pair 1]
               lappend aggTxTputPctList \
                   $resultArray($trial,$fs,1,[join $txPort ,],port,TXpercentTput)
               lappend aggTxTputFpsList \
                   $resultArray($trial,$fs,1,[join $txPort ,],port,TXthroughput)
               lappend aggTxCountList \
                   $resultArray($trial,$fs,1,[join $txPort ,],port,TXtransmitFrames)
               lappend aggRxCountList \
                   $resultArray($trial,$fs,1,[join $rxPort ,],port,RXreceiveFrames)
               lappend totalFrameLossPctList \
                   $resultArray($trial,$fs,1,[join $rxPort ,],port,RXpercentLoss)

               if {$enDataIntegrity == "true"} {
                   lappend aggIntegrityFramesList \
                       $resultArray($trial,$fs,1,[join $rxPort ,],port,RXintegrityFrames)
                   lappend aggIntegrityErrorsList \
                       $resultArray($trial,$fs,1,[join $rxPort ,],port,RXintegrityErrors) 
               }
           }
           set aggTxTputPct [passfail::ListMean aggTxTputPctList]
           set aggTxTputFps [mpexpr round([passfail::ListMean aggTxTputFpsList])]
           
           set aggTxCount [passfail::ListSum aggTxCountList]
           set aggRxCount [passfail::ListSum aggRxCountList]
           set totalFrameLossPct [passfail::ListMean totalFrameLossPctList]
           
           set csvEntry "$trial,$fs,$aggTxTputFps,$aggTxTputPct,$aggTxCount,$aggRxCount,$totalFrameLossPct"
           
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
   #  Create Info CSV & Real Time Chart CSV
   #
   #################################

   csvUtils::writeInfoCsv tunnel 

   #################################
   #
   #  Create Real Time Chart CSV
   #
   #################################

   csvUtils::writeRealTimeCsv tunnel "IP Tunnel:Tunnel Frame Loss"

   csvUtils::GeneratePDFReportFromCLI tunnel
}


########################################################################
# Procedure: tunnel::writeFlossStreams
#
# This command writes the streams used for the RFC 2544 floss test
#
# Arguments(s):
#   TxRxArray       - map, ie. one2oneArray
#   frameRate       - array containing the user frame rate per port
#   txNumFrames     - (not used, needed for binarySearch
#   testCmd         - name of test command, ie. tput
#   preambleSize
#
########################################################################
proc tunnel::writeFlossStreams {TxRxArray PercentMaxRate Framerate {TxNumFrames ""} {testCmd tunnel} {preambleSize 8}} \
{
    upvar $TxRxArray        txRxArray
    upvar $PercentMaxRate   percentMaxRate
    upvar $Framerate        framerate
    upvar $TxNumFrames      txNumFrames

    set retCode $::TCL_OK

    set tunnelProtocol                  [tunnel cget -tunnelProtocol]
    set payloadProtocol                 [tunnel cget -payloadProtocol]
    set encapsulation                   [tunnel cget -encapsulation]


    stream setDefault
    stream config -rateMode             usePercentRate
    stream config -gapUnit              gapNanoSeconds
    stream config -framesize            [$testCmd cget -framesize]
    stream config -dma                  firstLoopCount
    stream config -preambleSize         $preambleSize
    stream config -numBursts            1
    stream config -fir                  true

    if {[tunnel cget -encapsulation] == "ingress"} {
        set signatureOffset         82
        set dataIntegrityOffset     82
    } else {
        set signatureOffset         62
        set dataIntegrityOffset     62
    }

    set groupIdOffset        [expr $signatureOffset + 4]

    disableUdfs {1 2 3 4}

    set numFrames   [$testCmd cget -numFrames]
    set loopcount   [calculateLoopCounterFromTxFrames numFrames]

    # Initialize test local variables for each Tx port configured on each card on all chassis
    foreach txMap [lnumsort [array names txRxArray]] {
        scan $txMap "%d,%d,%d" tx_c tx_l tx_p

        set streamID    1
        foreach rxMap $txRxArray($tx_c,$tx_l,$tx_p) {
            scan [join $txRxArray($txMap)] "%d %d %d" rx_c rx_l rx_p

            set txPortId    [getPortId $tx_c $tx_l $tx_p] 
            set rxPortId    [getPortId $rx_c $rx_l $rx_p] 

            # Construct tunnel payload (inside packet).
            logMsg "Configuring Tunnel Payload $txPortId -> $rxPortId"

            stream config -loopCount            $loopcount
            stream config -numFrames            $numFrames
            stream config -percentPacketRate    $percentMaxRate($tx_c,$tx_l,$tx_p)

            set txNumFrames($tx_c,$tx_l,$tx_p)   [mpexpr $numFrames * $loopcount]
            if {[mpexpr $txNumFrames($tx_c,$tx_l,$tx_p)/$loopcount] != $numFrames} {
                set txNumFrames($tx_c,$tx_l,$tx_p)   [format "%s%s" $numFrames [string trimleft $loopcount 1]]
                logMsg "Readjusted Tx frames to $txNumFrames($tx_c,$tx_l,$tx_p) for [getPortId $tx_c $tx_l $tx_p]"
            }


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
            set streamName [format "TunnelPayload%sStream%d" Floss $streamID]
            ::buildStreamParms  $payloadProtocol            \
                                $streamName                 \
                                $tx_c $tx_l $tx_p           \
                                $rx_c $rx_l $rx_p           \
                                no                          \
                                [$testCmd cget -framesize]  \
                                no

            stream config -framesize [$testCmd cget -framesize]
            if [streamSet $tx_c $tx_l $tx_p $streamID] {
                errorMsg "Error setting stream $streamID on [getPortId $tx_c $tx_l $tx_p]"
                set retCode $::TCL_ERROR
            }

            # Construct Encapsulation packet.
            if {[tunnel cget -encapsulation] == "ingress"} {

                logMsg "Configuring Tunnel $txPortId -> $rxPortId"
                
                set streamName          [format "Tunnel%sStream%d" Floss $streamID]
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
            set framesize [stream cget -framesize]
            set signature                           [format "%02x %02x %02x %02x" 0x58 $rx_c $rx_l $rx_p]
                                                    
            packetGroupStats setDefault             
            packetGroup config -insertSignature     true
            packetGroup config -signatureOffset     $signatureOffset
            packetGroup config -signature           $signature
            packetGroup config -groupIdOffset       $groupIdOffset
            packetGroup config -groupId             [getTunnelTranslation $tx_c $tx_l $tx_p]

            dataIntegrity config -signatureOffset   $dataIntegrityOffset
            dataIntegrity config -signature         $signature
            dataIntegrity config -insertSignature   true
            dataIntegrity config -enableTimeStamp   true

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
	    dataIntegrity config -signatureOffset       [expr $dataIntegrityOffset + $offset]
            
            foreach command {packetGroup dataIntegrity} {
                if {[eval $command setRx $rx_c $rx_l $rx_p]} {
                    errorMsg "Error: Unable to perform $command setRx on [getPortId $rx_c $rx_l $rx_p]"
                    set retCode $::TCL_ERROR
                    continue
                }
            }

            # Setup the pattern filter
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

        set framerate($tx_c,$tx_l,$tx_p)    [stream cget -floatRate]
        }
    }

    if {$retCode == 0} {
        adjustOffsets    txRxArray
        set retCode [writeConfigToHardware txRxArray]
    }

    return $retCode
}


########################################################################
# Procedure:    tunnel::printIntermediateResults
#
# Description:  Given a list of metrics, print intermediate results.
#                   Note that the Results API doesn't allow for printing
#                   of intermediate results like the RFC 2544 Floss test
#                   uses, this is a work-around for it (but really it 
#                   should be part of the Results API too).
#
# Arguments(s): TxRxArray:  port map array     
#               TunnelId:       tunnel id's
#               TransmitFrames: # frames tx'd per port
#               ReceiveFrames:  # frames rx'd per port
#               PercentLoss:    % of loss per rx port
#
# Returns:      TCL_OK
#
########################################################################
proc tunnel::printIntermediateResults {TxRxArray TunnelId TransmitFrames ReceiveFrames PercentLoss} \
{
    upvar $TxRxArray        txRxArray 
    upvar $TunnelId         tunnelId
    upvar $TransmitFrames   transmitFrames
    upvar $ReceiveFrames    receiveFrames
    upvar $PercentLoss      percentLoss

    set metricList [list TXtunnelId TXtransmitFrames RXreceiveFrames RXpercentLoss]

    # Print Title
    set printLine [format "%-12s%-12s" TX RX]
    foreach metric $metricList {
        set titleFormat [results::getMetricTitleFormat port $metric]
        set title [results::getOptionTitle port $metric]
        append printLine [format $titleFormat $title]
    }
    logMsg $printLine
    logMsg [stringRepeat "*" [string length $printLine]]


    foreach txMap [array names txRxArray] {
        scan $txMap "%d,%d,%d" TXc TXl TXp

        foreach rxMap $txRxArray($TXc,$TXl,$TXp) {
            scan $rxMap "%d %d %d" RXc RXl RXp

            set txPortId [getPortId $TXc $TXl $TXp]
            set rxPortId [getPortId $RXc $RXl $RXp]

            foreach item $percentLoss($TXc,$TXl,$TXp) {
                scan $item "%s %s" crate percentLossValue
            
                regsub -all {[^0-9.]} $percentLossValue {} percentLossValue
                set percentLossValue [formatNumber $percentLossValue [advancedTestParameter cget -percentLossFormat]]
                regsub -all {[^0-9.]} $percentLossValue {} percentLossValue
                set percentLoss($RXc,$RXl,$RXp) $percentLossValue
            }

            # Print Report Detail 
            #   The metrics in the result DB, come in format: RXmetricName (ie: TXtransmitFrames).
            set printLine [format "%-12s%-12s" $txPortId $rxPortId]
            foreach metric $metricList {
                regexp {^(.*X)(.*)} $metric all direction metricName
                set c [set ${direction}c]
                set l [set ${direction}l]
                set p [set ${direction}p]
                set valueFormat [results::getMetricValueFormat port $metric]
                append printLine [format $valueFormat [set ${metricName}($c,$l,$p)]]
            }
            logMsg $printLine

        }
    }
    logMsg [stringRepeat "*" [string length $printLine]]

    return $::TCL_OK
}

################################################################################
#
# tunnel::PassFailCriteriaTunnelTputEvaluate()
#
# DESCRIPTION:
# This procedure calculates the number of trials that have executed successfully
# based upon user-specified Pass/Fail criteria.  
# 
# Average % Line Rate is an average throughput percentage across any frame 
# sizes and all ports for a given trial
# Minimum % Line Rate is the smallest throughput percentage of any port pair 
# across any frame sizes for a given trial.
# Average Data Rate is an average absolute bit rate across any frame sizes and 
# all ports for a given trial
# Minimum Data Rate is the smallest absolute bit rate of any port pair across any 
# frame sizes for a given trial.
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
proc tunnel::PassFailCriteriaTunnelFrameLossEvaluate {} {
    variable resultsDirectory
    variable trialsPassed
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

    set enDataIntegrity [expr {[tunnel cget -enableDataIntegrity] == "true"}]
    
    # compute list of ports used by the test
    set portList {}
    set pList [results cget -mapList]
    while {[llength $pList]} {
    regsub -all , [lindex $pList 0] " " txPort
    set rxPort [join [lindex $pList 1]]
    lappend portList [list $txPort $rxPort]
    set pList [lrange $pList 2 end]
    }
    set portList [lsort -dictionary $portList]

    set portCount     [llength $portList]
    set trialsPassed  0

    for {set trial 1} {$trial <= [tunnel cget -numtrials] } {incr trial} {

    logMsg "*** Trial #$trial"

        set percentLineRateList {}
        set frameRateList {}
        set dataRateList {}
        set crcErrorsList {}
    set percentLineRate 0.0


    foreach fs [lsort -dictionary [tunnel cget -framesizeList]] {

        foreach pair $portList {
        set txPort  [lindex $pair 0]
        set rxPort  [lindex $pair 1]

            if {($resultArray($trial,$fs,1,[join $rxPort ,],port,RXpercentLoss) > 0.0) || ($percentLineRate == "notCalculated")} {
        set percentLineRate notCalculated
            } else {
        set percentLineRate $resultArray($trial,$fs,1,[join $txPort ,],port,TXpercentTput)
        lappend percentLineRateList $percentLineRate
        }            

            set frameRate $resultArray($trial,$fs,1,[join $txPort ,],port,TXthroughput)

            lappend frameRateList $frameRate

            set dataRate  [mpexpr 8 * $fs * $frameRate]

            lappend dataRateList $dataRate

            if {$enDataIntegrity} {
                    lappend crcErrorsList \
                        $resultArray($trial,$fs,1,[join $rxPort ,],port,RXintegrityErrors)
                } 
            } 
     
    } 

      if {$percentLineRate == "notCalculated" } {
        set minPercentLineRate 0.0
        set avgPercentLineRate 0.0
      } else {

        # Minimum % Line Rate is the smallest throughput percentage of any port pair 
    # across any frame sizes for a given trial.
    set minPercentLineRate [passfail::ListMin percentLineRateList]

    # Average % Line Rate is an average throughput percentage across any frame 
    # sizes and all ports for a given trial
    set avgPercentLineRate [passfail::ListMean percentLineRateList]   
      }
    
    # Minimum Data Rate is the smallest absolute bit rate of any port pair across any 
    # frame sizes for a given trial. Data Rate is computed in bits/sec
    set minDataRate [passfail::ListMin dataRateList]

    # Average Data Rate is an average absolute bit rate across any frame sizes and 
    # all ports for a given trial
    set avgDataRate [passfail::ListMean dataRateList]

    # Minimum Frame Rate is the smallest frame rate of any port pair across any 
    # frame sizes for a given trial. Data Rate is computed in bits/sec
    set minFrameRate [passfail::ListMin frameRateList]

    # Average Frame Rate is an average frame rate across any frame sizes and 
    # all ports for a given trial
    set avgFrameRate [passfail::ListMean dataRateList]
            
        if {$enDataIntegrity} {
            # Maximum CRC Errors is the maximum numer of crc errors accross any frame
            # sizes and all ports for a given trial
            set maxCRCErrors [passfail::ListMax crcErrorsList]
            
            # Average CRC Errors is an average number of crc errors across any frame 
            # sizes and all ports for a given trial
            set avgCRCErrors [passfail::ListMean crcErrorsList]
        }

        # Pass/Fail Criteria is based on the logical AND of more criteria
    set result [passfail::PassFailCriteriaThroughputEvaluate \
                  $avgPercentLineRate $minPercentLineRate \
                  $avgDataRate $minDataRate "N/A" \
                  $avgFrameRate $minFrameRate]
    
            
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


