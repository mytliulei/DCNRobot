##################################################################################
# Version 3.70  $Revision: 7 $
# $Date: 12/12/02 2:03p $
# $Author: Dheins $
#
# $Workfile: thruput.tcl $ - RFC 2544 Throughput test
#
#   Copyright © 1997 - 2004 by IXIA
#   All Rights Reserved.
#
#   Revision Log:
#   01-23-1998  DS  Genesis
#   04-21-1998      RM  removed unset one2oneArray which caused error in tcl interp
#
# Description: This file contains the script for running the Thoughput
# test as defined in RFC 2544 by S.Bradner
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
                        <Source scope="results.csv" entity_name="tunnelTput" format_id=""/>
                        <Source scope="info.csv" entity_name="tunnelTput_Info" format_id=""/>
                        <Source scope="AggregateResults.csv" entity_name="tunnelTput_Aggregate" format_id=""/>
                        <Source scope="Iteration.csv" entity_name="tunnelTput_Iteration" format_id=""/>
                     </Sources>
                  </XMD>
   }
}
     
## Tunnel Namespace Variables

#   Metric Name         Result Array            Port        Initial     Iteration   Result         Print
#                                               Direction   Value       Reset?      Set            Order
array unset ::tunnel::portResultArrays
variable ::tunnel::portResultArrays
array set ::tunnel::portResultArrays  {
    tunnelId            {tunnelIdValues             tx      0           false       standard       1}
    throughput          {thruputRate                tx      0           true        standard       2} 
    percentTput         {percentTput                tx      0.0         false       standard       3} 
    avgLatency          {avgLatencyValues           rx      0           true        latency        1}
    minLatency          {minLatencyValues           rx      0           true        latency        2}
    maxLatency          {maxLatencyValues           rx      0           true        latency        3}
    totalSeqError       {sequenceErrorValues        rx      0           true        sequenceTotal  1}
    reverseSeqError     {reverseSequenceErrorValues rx      0           true        sequenceDetail 2}
    bigSeqError         {bigSequenceErrorValues     rx      0           true        sequenceDetail 3}
    smallSeqError       {smallSequenceErrorValues   rx      0           true        sequenceDetail 4}
    integrityErrors     {integrityErrorValues       rx      0           true        integrity      2}
    integrityFrames     {integrityFrameValues       rx      0           true        integrity      1}
}

## End Tunnel Namespace Variables




########################################################################################
# Procedure:    tunnel::registerResultVars_tput
#
# Description:  This command registers all the local variables that are used in the
#               display of the results with the Results Options Database.  This procedure must exist
#               for each test.
#
# Arguments:    None
#
# Returns:      TCL_OK
#
########################################################################################
proc tunnel::registerResultVars_tput {} \
{   
    variable portResultArrays

    # Add extra variables the result registry.
    if [ results addOptionToDB    tolerance         "Tolerance(%)    "      16 16 iter]    { return $::TCL_ERROR }
    if [ results addOptionToDB    TXtunnelId        "TunnelId  "            15 15 port]    { return $::TCL_ERROR }
    if [ results setOptionInDB    RXminLatency      "MinLatency(ns)"        15 15 port]    { return $::TCL_ERROR }
    if [ results setOptionInDB    RXmaxLatency      "MaxLatency(ns)"        15 15 port]    { return $::TCL_ERROR }
    if [ results addOptionToDB    RXintegrityErrors "IntegrityErrors"       16 16 port]    { return $::TCL_ERROR }
    if [ results addOptionToDB    RXintegrityFrames "IntegrityFrames"       16 16 port]    { return $::TCL_ERROR }
    if [ results setOptionInDB    totalTxFrames     "TotalTxFrames"         18 18 iter]    { return $::TCL_ERROR }
    if [ results setOptionInDB    totalRxFrames     "TotalRxFrames"         18 18 iter]    { return $::TCL_ERROR }

    # Configuration information stored for results.
    if [ results registerTestVars testName          testName                "[tunnel cget -testName] Throughput"  test ] { return $::TCL_ERROR }
    if [ results registerTestVars protocol          protocolName            [string toupper [getProtocolName [protocol cget -name]]] test ] { return $::TCL_ERROR }
    if [ results registerTestVars chassisName       chassisName             [chassis cget -name]            test   ] { return $::TCL_ERROR }
    if [ results registerTestVars chassisID         chassisID               [chassis cget -id]              test   ] { return $::TCL_ERROR }
    if [ results registerTestVars productName       productName             [user cget -productname]        test   ] { return $::TCL_ERROR }
    if [ results registerTestVars versionNumber     versionNumber           [user cget -version]            test   ] { return $::TCL_ERROR }
    if [ results registerTestVars serialNumber      serialNumber            [user cget -serial#]            test   ] { return $::TCL_ERROR }
    if [ results registerTestVars userName          userName                [user cget -username]           test   ] { return $::TCL_ERROR }
    if [ results registerTestVars percentMaxRate    percentMaxRate          [tunnel cget -percentMaxRate]   test   ] { return $::TCL_ERROR }
    if [ results registerTestVars numTrials         numTrials               [tunnel cget -numtrials]        test   ] { return $::TCL_ERROR }
    if [ results registerTestVars duration          duration                [tunnel cget -duration]         test   ] { return $::TCL_ERROR }
                                                                            
    # Metrics obtained after each iteration (aggregate).                                
    if [ results registerTestVars avgRate           avgTput                 0                               iter   ]  { return $::TCL_ERROR }
    if [ results registerTestVars tolerance         tolerance               0                               iter   ]  { return $::TCL_ERROR }
  
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
# Procedure: tunnel::show
#
# Description: This command is called when the user enters:
#               tunnel show
# Displays currently configured parameters.
########################################################################################
proc tunnel::show {args} \
{
    logMsg "\ntunnel command parameters"
    logMsg "====================================="
    showCmd tunnel
}


########################################################################################
# Procedure: tunnel::tput
#
# Description: This command starts the Tunnel Throughput test. 
#
# Note: The frames on desired ports should have been configured using the "port" 
#       and "streams" commands.  
#
#       For this test, there is only one stream per port with a specific frame size 
#       and rate.  In each trial, frames are transmitted at the given Tx rate. Each
#       Tx port is polled one at a time until all frames are sent. Then the number of 
#       frames received on Rx ports are counted and the Rx rate is calculated. The 
#       rates are compared and a binary search algorithm is used to come to a rate 
#       when no frame loss is experienced. 
#
#       Binary search algorithm for rates; duration constant, vary gap
#
# Argument(s):  None
#
# Return:       TCL_OK or TCL_ERR (uses TCL return -error for fatal errors)
#
########################################################################################
proc tunnel::tput {} {
    variable status;
    
    set status $::TCL_OK;
    
    if {[catch {set status [tunnel::TestMethod_tput]} ERROR]} { 
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
# tunnel::TestMethod_tput()
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
proc tunnel::TestMethod_tput {} {
    global one2oneArray    
    global testConf
    variable xmdDef
    variable resultsDirectory
    variable trial
    variable framesize

    #fix Ipv6 addresses for 6to4 Automatic mode
    FixIPV6TunnelAddresses one2oneArray

    set retCode $::TCL_OK

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
        logMsg "Error: Invalid port map for test."
        return $::TCL_ERROR
    }
    if {[validateFrameSizeList [tunnel cget -framesizeList]]} {
        return $::TCL_ERROR
    }

    set dirName "[results cget -directory]/IP Tunnel.resDir/Tunnel Throughput.resDir/[file rootname [csvUtils::getCurrentScriptName]].res"

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
               "Offered Load (fps)"
               "Max Tx Rate (%)"
               "Tx Count (frames)"
               "Rx Count (frames)"
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

    # Packet Group Statistics collected.
    array set pgStatistics {
        totalFrames          rxNumFrames          
        averageLatency       avgLatencyValues
        minLatency           minLatencyValues
        maxLatency           maxLatencyValues
        reverseSequenceError reverseSequenceErrorValues
        bigSequenceError     bigSequenceErrorValues    
        smallSequenceError   smallSequenceErrorValues  
        totalSequenceError   sequenceErrorValues
    }

    set encapsulation   [tunnel cget -encapsulation]
    if {$encapsulation == "ingress"} {
        learn config -type $tunnelProtocol
    } else {
        learn config -type $payloadProtocol
    }

    # Setup Port Recieve Mode.
    set receiveMode [expr $::portRxSequenceChecking | $::portPacketGroup | $::portRxDataIntegrity]
    if [changePortReceiveMode one2oneArray $receiveMode write] {
        errorMsg  "Error: Unable to set port recieve mode."
return $::TCL_ERROR
    }

    set testName "IPv6 Tunnel Throughput Test - [stringToUpper $encapsulation 0], [getBinarySearchString tunnel]"
    tunnel config -testName $testName

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

    # Set Tunnel Parameters.
    set preambleSize    8
    set duration        [tunnel cget -duration]    
    set protocolName    [getProtocolName [protocol cget -name]]
    set tolerance       [tunnel cget -tolerance]
    set percentMaxRate  [tunnel cget -percentMaxRate]
    set lossPercent     $percentMaxRate

    initializePortResultArrays one2oneArray
    buildTunnelTranslations one2oneArray

    # Arrays used in this test:
    #
    #   These array are setup before the test:
    #   maxFrameRate:           per port estimate of the maximum rate (at 100%) for a given framesize 
    #   frameRate:              per port estimate of the frame rate at ($percentMaxRate)
    #   txNumFrames:            per port estimate of # of frames to transmit (calculated in buildTputStreams by frameRate * duration)
    #   thruputRate:            per port estimate tput rate by frameRate/maxFrameRate
    #   tunnelIdValues:         per port mapping of packet group #'s to Tunnel Id's
    #
    #   These arrays hold results:
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

        tunnel config -framesize        $framesize  
        tunnel config -percentMaxRate   $percentMaxRate

        # Learn for each frame size if needed.
        if {[learn cget -when] == "oncePerFramesize"} {
            if {[learnIngressAndEgress one2oneArray]} {
                errorMsg "Error: Unable to send ARP/Neighbor Discovery frames"
                return $::TCL_ERROR
            }
        }

        # Set up results for this test.
        setupTestResults tunnel one2one ""                  \
                one2oneArray                \
                $framesize                  \
                [tunnel cget -numtrials]    \
                false                       \
                1                           \
                tput      
        
        results config -rowTitleType        tunnelId
        results config -rowStyle            oneFramesizePerRow
        results config -printRxRowValues    allRows
        results config -numPortMapColumns   0
        results config -summary             true



        for {set trial 1} {$trial <= [tunnel cget -numtrials]} {incr trial} {
            logMsg "\n******* TRIAL $trial - [tunnel cget -testName] *******"
            
            if {[dutConfig::DutConfigure TrialSetup]} {
               logMsg "***** ERROR:  DUT Configuration failed.  Test aborted."
               return $::TCL_ERROR
           }

        realTimeGraphs::SaveRealTimeMarker "-- Trial:$trial FS:$framesize--";

        if {[info exists thruputRate]} {
                unset thruputRate
            }
            if {[array exists  percentMaxRateArray]} {
                unset percentMaxRateArray
            }


            initializePortResultArrays one2oneArray iteration

            tunnel config -percentMaxRate $percentMaxRate
            if [initMaxRate one2oneArray maxRate $framesize framerate $percentMaxRate] {
                return $::TCL_ERROR
            }
            if { $lossPercent == $percentMaxRate } {
                set lossPercent 0
            }

            if {[learn cget -when] == "onTrial"} {
                if {[learnIngressAndEgress one2oneArray]} {
                    errorMsg "Error: Unable to send ARP/Neighbor Discovery frames"
                    return $::TCL_ERROR
                }
            }

            if {[writeTputStreams one2oneArray framerate txNumFrames]} {
                tunnel config -percentMaxRate $percentMaxRate
                return $::TCL_ERROR
            }

            # Calculate the rate based upon the actual frame size.
            foreach txMap [array names one2oneArray] {}
            scan $txMap "%d,%d,%d" c l p
            stream get $c $l $p 1
            if [initMaxRate one2oneArray maxRate [stream cget -framesize] framerate $percentMaxRate] {
                return $::TCL_ERROR
            }

            doBinarySearch tunnel one2oneArray framerate thruputRate txNumFrames totalTxFrames rxNumFrames \
                    totalRxFrames percentMaxRateArray no lossPercent

            set lossPercent $percentMaxRate

            set totalTput 0
            foreach txMap [lsort [array names one2oneArray]] {
                scan $txMap "%d,%d,%d" tx_c tx_l tx_p
                set percentTput($tx_c,$tx_l,$tx_p) [calculatePercentThroughput $thruputRate($tx_c,$tx_l,$tx_p) $maxRate($tx_c,$tx_l,$tx_p)]
                incr totalTput $thruputRate($tx_c,$tx_l,$tx_p)
            }

            set avgTput [mpexpr $totalTput/[llength [array names one2oneArray]]]

            if {[tunnel::collectPacketGroupStats one2oneArray pgStatistics]} {
                errorMsg "Error: Unable to collect packet group statistics"
                set retCode $::TCL_ERROR
            }

            collectDataIntegrityStats [getRxPorts one2oneArray] integrityErrorValues integrityFrameValues

            catch {array unset tunnelIdValues}
            getTranslationArray tunnelIdValues prefix

            foreach txMap [lnumsort [array names one2oneArray]] {
               scan $txMap "%d,%d,%d" tx_c tx_l tx_p
               foreach rxMap $one2oneArray($tx_c,$tx_l,$tx_p) {
                  scan $rxMap "%d %d %d" rx_c rx_l rx_p
                  if {$thruputRate($tx_c,$tx_l,$tx_p)==0} {
                      if {[tunnel cget -enableLatency]} {
                         set avgLatencyValues($rx_c,$rx_l,$rx_p) notCalculated
                         set minLatencyValues($rx_c,$rx_l,$rx_p) notCalculated
                         set maxLatencyValues($rx_c,$rx_l,$rx_p) notCalculated
                      }
                  }
               }
            }

            # Store Results Per Trial.
            logMsg "Saving results for Trial $trial ..."
            
            # Determine Which Result Arrays are to be printed.
            set resultArrays [getResultListByClass standard]

            if {[tunnel cget -enableLatency]} {
                lappend resultArrays [join [getResultListByClass latency]]
            }
            if {[tunnel cget -enableSequenceTotal]} {
                lappend resultArrays [getResultListByClass sequenceTotal]
            }
            if {[tunnel cget -enableSequenceDetail]} {
                lappend resultArrays [getResultListByClass sequenceDetail]
            }
            if {[tunnel cget -enableDataIntegrity]} {
                lappend resultArrays [getResultListByClass integrity]
            }
            lappend resultArrays avgTput tolerance
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
        tunnel config -percentMaxRate $percentMaxRate
    }
    
    if {[dutConfig::DutConfigure TestCleanup]} {
        logMsg "***** ERROR:  DUT Configuration failed.  Test aborted."
        return $::TCL_ERROR
    }

    realTimeGraphs::StopRealTimeStat
    scriptMateGuiCommand closeProgressMeter
    PassFailCriteriaTunnelTputEvaluate
    tunnel::writeNewResults_tunnelTput

    if { [advancedTestParameter cget -removeStreamsAtCompletion]} {
        if [removeStreams one2oneArray] {
            errorMsg "Error removing streams."
            set retCode $::TCL_ERROR
        }
    }  

    return $retCode
}

########################################################################
# Procedure: writeNewResults_tunnelTput
#
# This procedure create the CSV files used for PDF Report generation
# CSV File Format
#
########################################################################
proc tunnel::writeNewResults_tunnelTput {} {
   variable resultsDirectory   
   global resultArray testConf passFail
   global one2oneArray 
   global aggregateArray loggerParms

   if {[csvUtils::retrieveIterationDataFromTempFile tunnel binaryIterationArray] != $::TCL_OK} {
           logMsg "***** WARNING:  Cannot open temporary iteration csv file"
           return 
   }
 
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

   set enLatency    [expr {[tunnel cget -enableLatency]}]
   set enSeqTotal   [expr {[tunnel cget -enableSequenceTotal]}]
   set enSeqDetail   [expr {[tunnel cget -enableSequenceDetail]}]
   set enDataIntegrity [expr {[tunnel cget -enableDataIntegrity]}]

   set csvHeader "Trial,Frame Size,Tx Port,Rx Port,Tunnel ID,Tx Tput (fps),Tx Tput (%),Tx Count (frames),Rx Count (frames)" 

   if {$enLatency} {
       set csvHeader "$csvHeader,Avg Latency (ns),Min Latency (ns),Max Latency (ns)"
   }
   if {$enSeqTotal} {
       set csvHeader "$csvHeader,Seq Errors"
   }
   if {$enSeqDetail} {
       set csvHeader "$csvHeader,Big Seq Errors,Small Seq Errors,Rev Seq Errors"
   }
   if {$enDataIntegrity} {
       set csvHeader "$csvHeader,Integrity Frames,Integrity Errors"
   }

   puts $csvFid $csvHeader

   for {set trial 1} {$trial <= [tunnel cget -numtrials] } {incr trial} {
      foreach fs [lsort -dictionary [tunnel cget -framesizeList]] {
           foreach pair $portList {
        set txPort  [lindex $pair 0]
        set rxPort  [lindex $pair 1]

                set tunnelID $resultArray($trial,$fs,1,[join $txPort ,],port,TXtunnelId)
                set txTput $resultArray($trial,$fs,1,[join $txPort ,],port,TXthroughput)
                set txTputPct $resultArray($trial,$fs,1,[join $txPort ,],port,TXpercentTput)  

                set txTotalFrames $binaryIterationArray($trial,$fs,[join $txPort ,],txCount)
                set rxTotalFrames $binaryIterationArray($trial,$fs,[join $rxPort ,],rxCount)

                #set txCount $resultArray($trial,$fs,1,[join $txPort ,],port,TXtransmitFrames)
                #set rxCount $resultArray($trial,$fs,1,[join $rxPort ,],port,RXreceiveFrames) 

                set csvEntry "$trial,$fs,[join $txPort .],[join $rxPort .],$tunnelID,$txTput,$txTputPct,$txTotalFrames,$rxTotalFrames"

                if {$enLatency} {  
                foreach nval {avg min max} {
                    set ${nval}Latency $resultArray($trial,$fs,1,[join $rxPort ,],port,RX${nval}Latency)          
                } 
                    set csvEntry "$csvEntry,$avgLatency,$minLatency,$maxLatency"
                }

                if {$enSeqTotal} {
                    set seqErrors $resultArray($trial,$fs,1,[join $rxPort ,],port,RXtotalSeqError)
                    set csvEntry "$csvEntry,$seqErrors"
                }

                if {$enSeqDetail} {
                    foreach nval {big small reverse} {
                        set ${nval}SeqErrors $resultArray($trial,$fs,1,[join $rxPort ,],port,RX${nval}SeqError)
                    }                    
                    set csvEntry "$csvEntry,$bigSeqErrors,$smallSeqErrors,$reverseSeqErrors"
                }

                if {$enDataIntegrity} {
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
                     "Avg Tx Tput (%)"
                     "Agg Tx Count (frames)"
                     "Agg Rx Count (frames)"                     
                  }

   if {$enLatency} {
       lappend colHeads "Agg Avg Latency (ns)" "Agg Min Latency (ns)" "Agg Max Latency (ns)"
   }
   if {$enSeqTotal} {
       lappend colHeads "Agg Seq Errors"
   }
   if {$enSeqDetail} {
       lappend colHeads "Agg Big Seq Errors" "Agg Small Seq Errors" "Agg Rev Seq Errors"
   }
   if {$enDataIntegrity} {
       lappend colHeads "Agg Integrity Frames" "Agg Integrity Errors"
   }
    
   puts $csvFid [join $colHeads ,]

   for {set trial 1} {$trial <= [tunnel cget -numtrials] } {incr trial} {
       foreach fs [lsort -dictionary [tunnel cget -framesizeList]] {
            
                    set aggTxTputPctList {}
                    set aggTxTputList {}
                    set aggTxCountList {}
                    set aggRxCountList {}           
                    set aggAvgLatencyList {}
                    set aggMinLatencyList {}
                    set aggMaxLatencyList {}
                    set aggSeqErrorsList {}
                    set aggBigSeqErrorsList {}
                    set aggRevSeqErrorsList {}
                    set aggSmallSeqErrorsList {}
                    set aggIntegrityFramesList {}
                    set aggIntegrityErrorsList {}

             catch {unset aggAvgLatency}

         foreach pair $portList {
            set txPort  [lindex $pair 0]
            set rxPort  [lindex $pair 1]

                    lappend aggTxTputPctList $resultArray($trial,$fs,1,[join $txPort ,],port,TXpercentTput)
                    lappend aggTxTputList $resultArray($trial,$fs,1,[join $txPort ,],port,TXthroughput)

                    #lappend aggTxCountList $resultArray($trial,$fs,1,[join $txPort ,],port,TXtransmitFrames)
                    #lappend aggRxCountList $resultArray($trial,$fs,1,[join $rxPort ,],port,RXreceiveFrames)

                    lappend aggTxCountList $binaryIterationArray($trial,$fs,[join $txPort ,],txCount)
                    lappend aggRxCountList $binaryIterationArray($trial,$fs,[join $rxPort ,],rxCount)
                    
                    if {$enLatency} {  
                        if {[string is double -strict $resultArray($trial,$fs,1,[join $rxPort ,],port,RXavgLatency)]==0} {
                            set aggAvgLatency "notCalculated"
                            set aggMinLatency "notCalculated"
                            set aggMaxLatency "notCalculated"
                        } else {              
                            lappend aggAvgLatencyList $resultArray($trial,$fs,1,[join $rxPort ,],port,RXavgLatency)
                            lappend aggMinLatencyList $resultArray($trial,$fs,1,[join $rxPort ,],port,RXminLatency)
                            lappend aggMaxLatencyList $resultArray($trial,$fs,1,[join $rxPort ,],port,RXmaxLatency)
                        }
                    }

                    if {$enSeqTotal} {
                        lappend aggSeqErrorsList $resultArray($trial,$fs,1,[join $rxPort ,],port,RXtotalSeqError)
                    }

                    if {$enSeqDetail} {
                        lappend aggBigSeqErrorsList $resultArray($trial,$fs,1,[join $rxPort ,],port,RXbigSeqError)
                        lappend aggRevSeqErrorsList $resultArray($trial,$fs,1,[join $rxPort ,],port,RXreverseSeqError)
                        lappend aggSmallSeqErrorsList $resultArray($trial,$fs,1,[join $rxPort ,],port,RXsmallSeqError) 
                    }

                    if {$enDataIntegrity} {
                        lappend aggIntegrityFramesList $resultArray($trial,$fs,1,[join $rxPort ,],port,RXintegrityFrames)
                        lappend aggIntegrityErrorsList $resultArray($trial,$fs,1,[join $rxPort ,],port,RXintegrityErrors) 
                    }
             }           

           set aggTxTputPct [passfail::ListMean aggTxTputPctList]
           set aggTxTput [passfail::ListMean aggTxTputList]
           set aggTxCount [passfail::ListSum aggTxCountList]
           set aggRxCount [passfail::ListSum aggRxCountList]           
           set csvEntry "$trial,$fs,$aggTxTput,$aggTxTputPct,$aggTxCount,$aggRxCount"

           if {$enLatency} {

               if {![info exists aggAvgLatency]} {
                    set aggAvgLatency [passfail::ListMean aggAvgLatencyList]
                    set aggMinLatency [passfail::ListMin aggMinLatencyList]
                    set aggMaxLatency [passfail::ListMax aggMaxLatencyList]
               }   
               set csvEntry "$csvEntry,$aggAvgLatency,$aggMinLatency,$aggMaxLatency"
           }

           if {$enSeqTotal} {
               set aggSeqErrors [passfail::ListSum aggSeqErrorsList]
               set csvEntry "$csvEntry,$aggSeqErrors"
           }
           if {$enSeqDetail} {
               set aggBigSeqErrors [passfail::ListSum aggBigSeqErrorsList]             
               set aggSmallSeqErrors [passfail::ListSum aggSmallSeqErrorsList]
               set aggRevSeqErrors [passfail::ListSum aggRevSeqErrorsList]
               set csvEntry "$csvEntry,$aggBigSeqErrors,$aggSmallSeqErrors,$aggRevSeqErrors"
           }

           if {$enDataIntegrity} {
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

    csvUtils::writeInfoCsv tunnel

    #################################
    #
    #  Create Real Time Chart CSV
    #
    #################################
    
    csvUtils::writeRealTimeCsv tunnel "IP Tunnel:Tunnel Throughput"

    csvUtils::GeneratePDFReportFromCLI tunnel
}

########################################################################
# Procedure: writeTputStreams
#
# This command writes the streams used for the RFC 2544 tput test
#
# Arguments(s):
#   TxRxArray       - map, ie. one2oneArray
#   frameRate       - array containing the user frame rate per port
#   txNumFrames     - (not used, needed for binarySearch
#   testCmd         - name of test command, ie. tput
#   preambleSize
#
########################################################################
proc tunnel::writeTputStreams {TxRxArray Framerate {TxNumFrames ""} {testCmd tunnel} {preambleSize 8}} \
{
    upvar $TxRxArray    txRxArray
    upvar $Framerate    framerate
    upvar $TxNumFrames  txNumFrames

    set retCode $::TCL_OK

    set retCode [buildTputStreams txRxArray framerate txNumFrames $testCmd $preambleSize]
    if {$retCode == $::TCL_OK} {
        adjustOffsets txRxArray
        set retCode [writeConfigToHardware txRxArray]
    }

    return $retCode
}


########################################################################
# Procedure:    tunnel::buildTputStreams
#
# Description:  Build & write streams used for tunneling RFC 2544 tput
#               frames.
#
# Arguments(s): TxRxArray       - map, ie. one2oneArray
#               frameRate       - array containing the user frame rate per port
#               txNumFrames     - (not used, needed for binarySearch
#               testCmd         - name of test command, ie. tput
#               preambleSize
#
########################################################################
proc tunnel::buildTputStreams {TxRxArray Framerate {TxNumFrames ""} {testCmd tunnel} {preambleSize 8}} \
{
    upvar $TxRxArray    txRxArray
    upvar $Framerate    framerate
    upvar $TxNumFrames  txNumFrames

    set retCode $::TCL_OK

    set tunnelProtocol      [tunnel cget -tunnelProtocol]
    set payloadProtocol     [tunnel cget -payloadProtocol]
    set encapsulation       [tunnel cget -encapsulation]

    set framesize           [$testCmd cget -framesize]

    if {[tunnel cget -encapsulation] == "ingress"} {
        set signatureOffset         82
        set dataIntegrityOffset     82
    } else {
        set signatureOffset         62
        set dataIntegrityOffset     62
    }

    set groupIdOffset        [expr $signatureOffset + 4]
    set sequenceNumberOffset [expr $signatureOffset + 8]

    stream setDefault
    stream config -rateMode     usePercentRate
    stream config -numBursts    1
    stream config -loopCount    1
    stream config -dma          stopStream
    stream config -gapUnit      gapNanoSeconds

    disableUdfs {1 2 3 4}
    set duration            [tunnel cget -duration]

    foreach txMap [lnumsort [array names txRxArray]] {
        scan $txMap "%d,%d,%d" tx_c tx_l tx_p

        set streamID    1
        foreach rxMap $txRxArray($tx_c,$tx_l,$tx_p) {
            scan $rxMap "%d %d %d" rx_c rx_l rx_p

            set txPortId    [getPortId $tx_c $tx_l $tx_p] 
            set rxPortId    [getPortId $rx_c $rx_l $rx_p] 

            # Construct tunnel payload (inside packet).
            logMsg "Configuring Tunnel Payload $txPortId -> $rxPortId"

            set framesize           [$testCmd cget -framesize]

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

            protocol config -name $payloadProtocol
            set streamName [format "TunnelPayload%sStream%d" Tput $streamID]
            ::buildStreamParms  $payloadProtocol \
                    $streamName \
                    $tx_c $tx_l $tx_p \
                    $rx_c $rx_l $rx_p \
                    no \
                    $framesize \
                    no

            stream config -framesize         $framesize
            stream config -percentPacketRate [$testCmd cget -percentMaxRate]
            stream config -fir               true
            
            set txNumFrames($tx_c,$tx_l,$tx_p)  [mpexpr $framerate($tx_c,$tx_l,$tx_p) * [$testCmd cget -duration]]

            if {[stream set $tx_c $tx_l $tx_p $streamID]} {
                errorMsg "Error: Unable to set stream $streamID on [getPortId $tx_c $tx_l $tx_p]"
                set retCode $::TCL_ERROR
            }

            # Construct Encapsulation packet.
            if {[tunnel cget -encapsulation] == "ingress"} {

                logMsg "Configuring Tunnel $txPortId -> $rxPortId"
                
                set streamName          [format "Tunnel%sStream%d" Tput $streamID]
                set offset              [getHeaderLength mac]
                set packet              [lrange [stream cget -packetView] $offset end-4]
                
                protocol config -name $tunnelProtocol
                ::tunnel::buildStreamParms  $streamName \
                        $tx_c $tx_l $tx_p \
                        $rx_c $rx_l $rx_p \
                        packet
                
                

                if [initMaxRate one2oneArray maxRate [stream cget -framesize] framerate [$testCmd cget -percentMaxRate]] {
                    return $::TCL_ERROR
                }

                if [stream set $tx_c $tx_l $tx_p $streamID] {
                    errorMsg "Error setting stream $streamID on [getPortId $tx_c $tx_l $tx_p]"
                    set retCode $::TCL_ERROR
                }

            }

            if [catch {calculateStreamNumFrames [stream cget -framerate] duration} numFrames] {
                $testCmd config -duration $duration
            }

            stream config -numFrames $numFrames
            set txNumFrames($tx_c,$tx_l,$tx_p)  [stream cget -numFrames]

            set framerate($tx_c,$tx_l,$tx_p)    [stream cget -framerate]
            if [stream set $tx_c $tx_l $tx_p $streamID] {
                errorMsg "Error setting stream $streamID on [getPortId $tx_c $tx_l $tx_p]"
                set retCode $::TCL_ERROR
            }

            ### framesize is modified in tunnel::buildStreamParms
            set framesize [stream cget -framesize]
            set signature                               [format "%02x %02x %02x %02x" 0x58 $rx_c $rx_l $rx_p]
            packetGroupStats setDefault
            packetGroup config -insertSignature         true

            packetGroup config -signatureOffset         $signatureOffset
            packetGroup config -signature               $signature
            packetGroup config -groupIdOffset           $groupIdOffset
            packetGroup config -groupId                 [getTunnelTranslation $tx_c $tx_l $tx_p]
            packetGroup config -sequenceNumberOffset    $sequenceNumberOffset
            packetGroup config -insertSequenceSignature true
            packetGroup config -allocateUdf             true

            dataIntegrity config -signatureOffset       $dataIntegrityOffset
            dataIntegrity config -signature             $signature
            dataIntegrity config -insertSignature       true
            dataIntegrity config -enableTimeStamp       true

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
            filterPallette config -pattern1         [packetGroup cget -signature]
            filterPallette config -patternOffset1   [expr $signatureOffset + $offset]
            
            if [filterPallette set $rx_c $rx_l $rx_p] {
                errorMsg "Error setting filter pallette for [getPortId $rx_c $rx_l $rx_p]"
                set retCode $::TCL_ERROR
                continue
            }
            
            # set the filter parameters on the receive port
            filter config -userDefinedStat2Enable   true
            filter config -userDefinedStat2Pattern  pattern1
            
            if [filter set $rx_c $rx_l $rx_p] {
                errorMsg "Error setting filters on [getPortId $rx_c $rx_l $rx_p]"
                set retCode $::TCL_ERROR
                continue
            }

            incr streamID

        }
    }

    stream setDefault

    return $retCode
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
proc tunnel::PassFailCriteriaTunnelTputEvaluate {} {
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

    set enLatency    [expr {[tunnel cget -enableLatency]}]
    set enSeqTotal   [expr {[tunnel cget -enableSequenceTotal]}]
    set enSeqDetail   [expr {[tunnel cget -enableSequenceDetail]}]
    set enDataIntegrity [expr {[tunnel cget -enableDataIntegrity]}]

    #set enLatency    [expr {[tunnel cget -enableLatency] == "true"}]
    #set enSeqTotal   [expr {[tunnel cget -enableSequenceTotal] == "true"}]
    #set enDataIntegrity [expr {[tunnel cget -enableDataIntegrity] == "true"}]
    
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
        set avgLatencyList {}
    set maxLatencyList {}
        set seqErrorsList {}
        set crcErrorsList {}

    foreach fs [lsort -dictionary [tunnel cget -framesizeList]] {

        foreach pair $portList {
        set txPort  [lindex $pair 0]
        set rxPort  [lindex $pair 1]

                lappend percentLineRateList \
                    $resultArray($trial,$fs,1,[join $txPort ,],port,TXpercentTput)

                set frameRate $resultArray($trial,$fs,1,[join $txPort ,],port,TXthroughput)

                lappend frameRateList $frameRate

                set dataRate  [mpexpr 8 * $fs * $frameRate]

                lappend dataRateList $dataRate

                if {$enLatency } {
                    lappend avgLatencyList \
                        $resultArray($trial,$fs,1,[join $rxPort ,],port,RXavgLatency)
                    lappend maxLatencyList \
                        $resultArray($trial,$fs,1,[join $rxPort ,],port,RXmaxLatency)
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

        # Minimum % Line Rate is the smallest throughput percentage of any port pair 
    # across any frame sizes for a given trial.
    set minPercentLineRate [passfail::ListMin percentLineRateList]

    # Average % Line Rate is an average throughput percentage across any frame 
    # sizes and all ports for a given trial
    set avgPercentLineRate [passfail::ListMean percentLineRateList]
    
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
    set result [passfail::PassFailCriteriaThroughputEvaluate \
                  $avgPercentLineRate $minPercentLineRate \
                  $avgDataRate $minDataRate "N/A" \
                  $avgFrameRate $minFrameRate]
    
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

########################################################################
# Procedure: writeIterationData2CSVFile
#
# This command writes the test iteration data to the result CSV file. 
#
# Applicable tests: tunnel
#
# Arguments(s):
#   iteration           - iteration in which this write to CSV is called
#   testCmd             - name of test command
#   arrayName           - used to distinguish between meshMany2One and meshOne2Many tests, 
#                         which currently share the same namespace
#   TxRxArray           - map, ie. many2oneArray
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
proc tunnel::writeIterationData2CSVFile { iteration testCmd TxRxArray Framerate TputRateArray \
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

    set framesize   [tunnel cget -framesize]
    if {[catch {$testCmd cget -tolerance} tolerance]} {
        set tolerance   0
    }
    
    foreach txMap [getTxPorts txRxArray] {
    scan $txMap "%d %d %d" tx_c tx_l tx_p

    set percentPacketRate [getPercentPacketRate $tx_c $tx_l $tx_p]
        if { !$txRateBelowLimit && ($framerate($tx_c,$tx_l,$tx_p) < [$testCmd cget -minimumFPS])} {
           set txRateBelowLimit 1
        }

    foreach rxMap $txRxArray($tx_c,$tx_l,$tx_p) {
        scan $rxMap "%d %d %d" rx_c rx_l rx_p  

        csvUtils::writeIterationCSVFile $testCmd [list $iteration                       \
                              [getPortString $tx_c $tx_l $tx_p] \
                              [getPortString $rx_c $rx_l $rx_p] \
                              $oLoadArray($tx_c,$tx_l,$tx_p)    \
                              $percentPacketRate                \
                              $txNumFrames($tx_c,$tx_l,$tx_p)   \
                              $rxNumFrames($rx_c,$rx_l,$rx_p)   \
                              [mpexpr ($txNumFrames($tx_c,$tx_l,$tx_p) - $rxNumFrames($rx_c,$rx_l,$rx_p))] \
                              [mpexpr (($txNumFrames($tx_c,$tx_l,$tx_p) - $rxNumFrames($rx_c,$rx_l,$rx_p)) * 100.0) / $txNumFrames($tx_c,$tx_l,$tx_p)]]
                                                          
        set myPercentLoss [mpexpr (($txNumFrames($tx_c,$tx_l,$tx_p) - $rxNumFrames($rx_c,$rx_l,$rx_p) ) * 100.0 / $txNumFrames($tx_c,$tx_l,$tx_p))] 
        if { ($myPercentLoss <= $tolerance) || ($myPercentLoss >= 100) || ($txRateBelowLimit == 1) } {      
        csvUtils::saveIterationDataToTempFile $testCmd [list $tunnel::trial $framesize $tx_c $tx_l $tx_p txCount $txNumFrames($tx_c,$tx_l,$tx_p)] 
        csvUtils::saveIterationDataToTempFile $testCmd [list $tunnel::trial $framesize $rx_c $rx_l $rx_p rxCount $rxNumFrames($rx_c,$rx_l,$rx_p)]           
        }
    }
    }
}

