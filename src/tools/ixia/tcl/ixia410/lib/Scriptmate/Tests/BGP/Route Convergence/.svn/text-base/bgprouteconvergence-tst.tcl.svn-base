#############################################################################################
#
#   Copyright © 1997 - 2004 by IXIA.
#   All Rights Reserved.
#
# Description: Description: This file contains the script for running BGP route convergence test
#              This test needs 3 ports. one transmit port and 2 receive ports. Transmit direction
#              is unidirectional
#              1) Configure the external neighbors and route range on receive ports. Notice that
#                 both ports should advertise the same routes.
#              2) Configure the preferable route for flapping. ( The preferable route has 
#                 shorter AS-path. and it is the first receive port in the list)
#              3) Start BGP server and after some time when all routes have been advertised
#                 Start sending the traffic.
#              4) There are at least two flaps during the transmitting data. 
#              5) Stop BGP server and collect the stats
#              6) Number of packet loss determines the time that router was not available for 
#                 forwarding the packets 
#
#
#############################################################################################

namespace eval bgpSuite {
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
                        <Source scope="results.csv" entity_name="bgpSuiteRouteConvergence" format_id=""/>
                        <Source scope="info.csv" entity_name="bgpSuiteRouteConvergence_Info" format_id=""/>                        
                     </Sources>
                  </XMD>
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
proc bgpSuite::registerResultVars_routeConvergence {} \
{
    if [results addOptionToDB totalPacketLoss        "TotalPacketLoss "                    12 12 iter] { return 1 } 
    if [results addOptionToDB convergenceMetric      "ConvergenceMetric(seconds)"          12 12 iter] { return 1 } 
    if [results addOptionToDB totalRoutes            "MaxRoutesVerified"                   12 12 iter] { return 1 }
    if [results addOptionToDB tolerance              "Tolerance(%)    "                    12 12 iter] { return 1 }
    if [results addOptionToDB numWithdraw            "Number of Withdrawals"               12 12 iter] { return 1 }
    if [results addOptionToDB convergencePerWithdraw "ConvergenceMetricPerWithdrawal(sec)" 12 12 iter] { return 1 } 
    if [results addOptionToDB packetRate             "PacketRate (PPS)"                    12 12 iter] { return 1 }
    if [results addOptionToDB actualPacketLoss       "ActualPacketLoss"                    12 12 iter] { return 1 }
    if [results addOptionToDB misDirectedPackets     "MisDirectedPackets"                  12 12 iter] { return 1 }

    # configuration information stored for results      
    if [results registerTestVars testName       testName       [bgpSuite cget -testName]  test ] { return 1 }
    if [results registerTestVars protocol       protocolName   [string toupper [getProtocolName [protocol cget -name]]] test] { return 1 }
    if [results registerTestVars chassisName    chassisName    [chassis cget -name]            test] { return 1 }
    if [results registerTestVars chassisID      chassisID      [chassis cget -id]              test] { return 1 }
    if [results registerTestVars productName    productName    [user cget -productname]        test] { return 1 }
    if [results registerTestVars versionNumber  versionNumber  [user cget -version]            test] { return 1 }
    if [results registerTestVars serialNumber   serialNumber   [user cget -serial#]            test] { return 1 }
    if [results registerTestVars userName       userName       [user cget -username]           test] { return 1 }
    if [results registerTestVars percentMaxRate percentMaxRate [bgpSuite cget -percentMaxRate] test] { return 1 }
    if [results registerTestVars numTrials      numTrials      [bgpSuite cget -numtrials]      test] { return 1 }
    if [results registerTestVars duration       duration       [bgpSuite cget -duration]       test] { return 1 }
                                                        
    # results obtained after each iteration             
    if [results registerTestVars transmitFrames         txActualFrames         0 port TX] { return 1 }
    if [results registerTestVars receiveFrames          rxNumFrames            0 port RX] { return 1 }
    if [results registerTestVars totalTxFrames          totalTxNumFrames       0 iter   ] { return 1 }     
    if [results registerTestVars totalRxFrames          totalRxNumFrames       0 iter   ] { return 1 }
    if [results registerTestVars percentLoss            totalLoss              0 iter   ] { return 1 }
    if [results registerTestVars totalPacketLoss        totalPacketLoss        0 iter   ] { return 1 }
    if [results registerTestVars convergenceMetric      convergenceMetric      0 iter   ] { return 1 }
    if [results registerTestVars totalRoutes            totalRoutes            0 iter   ] { return 1 }
    if [results registerTestVars tolerance              tolerance              0 iter   ] { return 1 }
    if [results registerTestVars numWithdraw            numWithdraw            0 iter   ] { return 1 }
    if [results registerTestVars convergencePerWithdraw convergencePerWithdraw 0 iter   ] { return 1 }
    if [results registerTestVars packetRate             packetRate             0 iter   ] { return 1 }
    if [results registerTestVars actualPacketLoss       actualPacketLoss       0 iter   ] { return 1 }
    if [results registerTestVars misDirectedPackets     misDirectedPackets     0 iter   ] { return 1 }

    return 0
}
#################################################################################
# Procedure: routeConvergence
#
# Description: This command starts running the route convergence test.
#
########################################################################################
proc bgpSuite::routeConvergence {args} \
{
    variable status;
    
    set status $::TCL_OK;
    
    if {[catch {set status [bgpSuite::TestMethod_routeConvergence $args]} ERROR]} {	
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
# bgpSuite::TestMethod_routeConvergence(args)
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
proc bgpSuite::TestMethod_routeConvergence {args} {	
	set retCode       0
	set mapArray    [format "%sArray"   [bgpSuite cget -mapType]]
    global $mapArray    
    global testConf
	variable xmdDef
    variable resultsDirectory
    variable trial
    variable framesize


    set dirName "[results cget -directory]/BGP.resDir/Route Convergence.resDir/[file rootname [csvUtils::getCurrentScriptName]].res"

    set resultsDirectory [makeNewRunDirectory $dirName $xmdDef]
    results config -resultDir $resultsDirectory
    scriptMateGuiCommand setDirName $resultsDirectory


    if {[string length $resultsDirectory] == 0} {
        return $::TCL_Error
    }
    
    if {[dutConfig::DutConfigure]} {
		logMsg "***** ERROR:  DUT Configuration failed.  Test aborted."
		return $::TCL_ERROR
    }


    
    set numWithdraw 2

    realTimeGraphs::InitRealTimeStat \
	[list [list framesSent     [getTxPorts $mapArray] "Tx Frames per second" "Tx Frames" 1e0]\
	     [list framesReceived [getRxPorts $mapArray] "Rx Frames per second" "Rx Frames" 1e0]\
	     [list bitsSent       [getTxPorts $mapArray] "Tx Kbps"              "Tx Kb"     1e3]\
	     [list bitsReceived   [getRxPorts $mapArray] "Rx Kbps"              "Rx Kb"     1e3]\
	    ];
 
    if [validateUnidirectionalMap $mapArray] {
        return $::TCL_ERROR
    }

    if [checkConvergenceMap $mapArray] {
        errorMsg "Invalid Map for convergence test. Should be one Tx port and Two Rx ports"
        return $::TCL_ERROR 
    }

    set bgpPorts    [getRxPorts $mapArray]
    bgpSuite config -testName "BGP Route Convergence Test"
    learn config -when        oncePerTest

    if [initTest bgpSuite $mapArray {ip} errMsg] {
        errorMsg $errMsg
return $::TCL_ERROR
    }

    if {[bgpSuite cget -routesPerPeer] == 0 } {
        bgpSuite config -routesPerPeer  1
    }

    realTimeGraphs::StartRealTimeStat;
    scriptMateGuiCommand openProgressMeter

    foreach framesize [bgpSuite cget -framesizeList] {

        bgpSuite config -framesize  $framesize
        set framesizeString "Framesize:$framesize"
        setupTestResults bgpSuite [bgpSuite cget -mapType] "" $mapArray $framesize [bgpSuite cget -numtrials] false 1 routeConvergence

        if [disableAutoCreateInterface  bgpPorts bgp4] {
            errorMsg "***** Error Configuring AutoCreateInterface..."
            return $::TCL_ERROR
        }

        for {set trial 1} {$trial <= [bgpSuite cget -numtrials]} {incr trial} {
            logMsg " ******* TRIAL $trial - [bgpSuite cget -testName], $framesizeString, Total routes: [bgpSuite cget -routesPerPeer] ***** "
            
            if {[dutConfig::DutConfigure TrialSetup]} {
               logMsg "***** ERROR:  DUT Configuration failed.  Test aborted."
               return $::TCL_ERROR
            }
 
	        realTimeGraphs::SaveRealTimeMarker "-- Trial:$trial FS:$framesize --";

            # initialize bgp server on each rx port
            set count 0

            foreach port $bgpPorts {
                scan $port "%d %d %d" c l p

                initializeBgp $c $l $p

                if [ip get $c $l $p] {
                    errorMsg "Error getting ip on port [getPortId $c $l $p]"
                    set retCode 1
                }

                set dutIP  [ip cget -destDutIpAddr]
                set peerIP [ip cget -sourceIpAddr]

                # Add Stable Route Range
                if { $count == 1 } {
                    setupRouteItem  [bgpSuite cget -networkIPAddress] \
                            [bgpSuite cget -prefixLength] \
                            [bgpSuite cget -routesPerPeer] \
                            $peerIP \
                            [list [bgpSuite cget -firstAsNumber]]

                    if {[bgp4Neighbor addRouteRange routeRange1]} {
                        errorMsg "Error adding stable route range [bgpSuite cget -networkIPAddress]"
                        set retCode 1
                    }

                # Add Flapping Route Range
                } else { 
                    setupRouteItem  [bgpSuite cget -networkIPAddress] \
                            [bgpSuite cget -prefixLength] \
                            [bgpSuite cget -routesPerPeer] \
                            $peerIP

                    if {[bgpSuite cget -enableUserDelay]} {
                        set advertiseDelay [mpexpr  ceil ( [bgpSuite cget -routesPerPeer] * [bgpSuite cget -advertiseDelayPerRoute])]
                    } else {
                        set advertiseDelay [estimateAdvertiseDelay [bgpSuite cget -routesPerPeer]]
                        logMsg "Advertise Delay is $advertiseDelay seconds, advertise delay per route is [format "%6.6f" [expr $advertiseDelay/[bgpSuite cget -routesPerPeer]]]"
                    }

                    # I can get this one from user
                       bgpSuite config -upFlapTime  [mpexpr [bgpSuite cget -delayTime] + $advertiseDelay + [bgpSuite cget -downFlapTime] ]
                       logMsg "Up flap time is  delay + advertiseDelay + down Flap Time = [bgpSuite cget -upFlapTime] seconds"
   
                    #Calculate transmit duration
                       set timeForWithdrawals      [mpexpr $numWithdraw * ([ bgpSuite cget -downFlapTime ] + [bgpSuite cget -upFlapTime] + 2* $advertiseDelay)]
                       set totalPauseBeforeTx      [mpexpr $advertiseDelay + [bgpSuite cget -delayTime]]
                       bgpSuite config -duration   [mpexpr $timeForWithdrawals - $totalPauseBeforeTx]


                    # consider making this values relative to the user-config'd test duration parameter
                    # if down flaptime is 0 it means we don't want flapping so don't enable  
                    if { [bgpSuite cget -downFlapTime] == 0 } {
                        set numWithdraw 0
                        bgpSuite config -downFlapTime 10
                        bgpSuite config -duration 10
                    }

                    if {[bgp4Neighbor addRouteRange routeRange1]} {
                        errorMsg "Error adding flag route range [bgpSuite cget -networkIPAddress]"
                        set retCode 1
                    }
                }

                bgp4Neighbor config -type  bgp4NeighborExternal
                bgp4Neighbor config -localIpAddress         $peerIP
                bgp4Neighbor config -rangeCount             1
                bgp4Neighbor config -dutIpAddress           $dutIP
                bgp4Neighbor config -localAsNumber          [expr [bgpSuite cget -firstAsNumber] + $count]


                if [bgp4Server addNeighbor neighbor1] {
                    errorMsg "Error adding Neighbor with IP [bgp4Neighbor cget -localIpAddress] address to the server"
                    set retCode 1
                }

                bgp4Server config -enableExternalEstablishOnce true

                if [bgp4Server set] {
                    errorMsg "Error setting the bgp4ExternalTable"
                }

                enablePortProtocolStatistics    $c $l $p enableBgpStats
                enablePortProtocolServer        $c $l $p bgp4 noWrite

                incr count
            }

            if [configureBgp4statsQuery neighborIpAddressArray dutIpAddressArray $bgpPorts ] {
                logMsg " Error in configuring bgp4StatsQuery"
                return $::TCL_ERROR
            }

            if [writeBgpStreams $mapArray txNumFrames] {
                return -code error 
            }

            # Start BGP Server
            logMsg "Starting BGP4..."
            if [startBgp4Server bgpPorts] {
                errorMsg "Error Starting BGP!"
                return $::TCL_ERROR
            }
        
            if [confirmPeerEstablished bgpPorts] {
                errorMsg "Error!! Peers could not be established. The delay is not enough or there is a network problem."
                errorMsg "Please make sure the AS number is correct."
                bgp4CleanUp bgpPorts
                return $::TCL_ERROR
            }

            logMsg "Waiting $advertiseDelay seconds for all routes to be advertised..."
            writeWaitForPause "Waiting for routes to be advertised..." $advertiseDelay
            logMsg "Confirming all routes have been advertised ..."
            if { [confirmAllRoutesAdvertised neighborIpAddressArray dutIpAddressArray $bgpPorts [bgpSuite cget -routesPerPeer] extraTime] } {
                logMsg "Warning: All routes have not been advertised yet or the session is disconnected."
                bgp4CleanUp bgpPorts
                return $::TCL_ERROR
            }

            logMsg "Pausing for [bgpSuite cget -delayTime] seconds before starting transmitting ..."          
            writeWaitForPause  "Pause before transmitting.." [bgpSuite cget -delayTime]    

             if { $extraTime } {
                 if {[getRoutesWithdrawn neighborIpAddressArray dutIpAddressArray $bgpPorts] > 0 } {
                     logMsg "Warning: The estimated delay to advertise all routes was not enough.\nPlease\
                             run the test in enableUserDelay mode and use advertiseDelayPerRoute\
                             equal to or greater than [format "%6.6f" [expr ($advertiseDelay + $extraTime * [bgpSuite cget -delayTime])/[bgpSuite cget -routesPerPeer]]]"
                     bgp4CleanUp bgpPorts
                     return 1
                 }
             }

             set retCode [prepareToTransmit  $mapArray]

             if {$retCode == 0} {
                set retCode [startTx $mapArray]
             }

             if {$retCode == 0} {     
                if {[bgpSuite cget -duration] > 0} {
                   logMsg "Transmitting frames for [ bgpSuite cget -downFlapTime ] seconds"
                } else {
                   logMsg "Transmitting frames for < 1 second"
                }
             }  

             set duration [ bgpSuite cget -downFlapTime ]
             writeWaitForTransmit    $duration

             set preferredPort       [lindex $bgpPorts 0]
             set notPreferredPort    [lindex $bgpPorts 1]
             scan $preferredPort     "%d %d %d" prx_c prx_l prx_p
             scan $notPreferredPort  "%d %d %d" nprx_c nprx_l nprx_p

             set rxNumFrames($nprx_c,$nprx_l,$nprx_p)    0
             set rxNumFrames($prx_c,$prx_l,$prx_p)       0

             set maxNumChanges [expr $numWithdraw * 2]
             set wrongDestFrames 0

             for {set count 0} {$count < $maxNumChanges } {incr count} {
                 set enableFlap      [expr round (fmod ($count,2))]

                 #flap the preferred route by disabling the routeRange
                 if [setEnableRouteRange  $preferredPort $enableFlap] {
                    logMsg "Could not flap"
                    set $retCode 1
                 }
                      
                 collectStats [getRxPorts $mapArray] userDefinedStat2 currentRxNumFrames          
                 if { $enableFlap == 0 } { 
                    logMsg "Withdraw the routes on preferred port:$preferredPort"
                    set frameLoss [mpexpr $currentRxNumFrames($nprx_c,$nprx_l,$nprx_p) - $rxNumFrames($nprx_c,$nprx_l,$nprx_p)]               
                    set duration [bgpSuite cget -downFlapTime]
                 } else {
                    logMsg "Readvertise the route on preferred port:$preferredPort"
                    set duration [bgpSuite cget -upFlapTime]
                 }
                 if { $frameLoss > 0} {
                    incr wrongDestFrames $frameLoss
                 }
                 set rxNumFrames($nprx_c,$nprx_l,$nprx_p)    $currentRxNumFrames($nprx_c,$nprx_l,$nprx_p)
                 set rxNumFrames($prx_c,$prx_l,$prx_p)       $currentRxNumFrames($prx_c,$prx_l,$prx_p)

                 logMsg "Transmitting frames for $duration seconds"
                 writeWaitForTransmit    $duration 
                    
             }

             if [stopTx $mapArray] {
                 logMsg "Error stopping Tx on one or more ports."
                 set retCode 1
             }

             waitForResidualFrames [bgpSuite cget -waitResidual]                 

             stats::collectTxStats [getTxPorts $mapArray] txNumFrames txActualFrames totalTxNumFrames
             collectRxStats [getRxPorts $mapArray] rxNumFrames totalRxNumFrames
             debugMsg "rxNumFrames :[array get rxNumFrames]"

             if {  $numWithdraw != 0 } {         
                 if {[expr round (fmod ($count,2))]} {
                     set frameLoss [mpexpr $rxNumFrames($prx_c,$prx_l,$prx_p) - $currentRxNumFrames($prx_c,$prx_l,$prx_p)]
                 } else {
                     set frameLoss [mpexpr $rxNumFrames($nprx_c,$nprx_l,$nprx_p) - $currentRxNumFrames($nprx_c,$nprx_l,$nprx_p)]
                 }

                 if { $frameLoss > 0} {
                    incr wrongDestFrames $frameLoss
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
                set convergencePerWithdraw      [format "%6.6f" [expr $convergenceMetric / $numWithdraw]]
            } else {           
                set convergenceMetric       N/A
                set convergencePerWithdraw  N/A
            }

            bgp4CleanUp bgpPorts
            
            set flapPort [lindex $bgpPorts 0]
            scan $flapPort "%d %d %d" c l p

            if { $rxNumFrames($c,$l,$p) == 0} {
                logMsg "NOTE: Try to use enableUserDelay mode with advertiseDelayPerRoute\
                        equal to or greater than [format "%6.6f" [expr ($advertiseDelay + $extraTime * [bgpSuite cget -delayTime])/[bgpSuite cget -routesPerPeer]]]."
                set convergenceMetric       N/A
                set convergencePerWithdraw  N/A
            } 
            
            set packetRate      [stream cget -framerate]
            set misDirectedPackets [expr $totalPacketLoss - $actualPacketLoss]
            if { $misDirectedPackets < 0 } {
               set misDirectedPackets 0
            }

            if [results save one2many [bgpSuite cget -framesize] $trial     \
                    txActualFrames       \
                    rxNumFrames          \
                    numWithdraw          \
                    packetRate           \
                    actualPacketLoss     \
                    misDirectedPackets   \
                    totalLoss            \
                    totalPacketLoss      \
                    convergenceMetric    \
                    convergencePerWithdraw] {
                errorMsg "Error saving results for Trial $trial. "
                return 1
            }
            if [results printToScreen one2many [bgpSuite cget -framesize] $trial] {
                set retCode 1
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


    realTimeGraphs::StopRealTimeStat;
    scriptMateGuiCommand closeProgressMeter
    PassFailCriteriaEvaluateRouteConvergence
	bgpSuite::writeNewResults_routeConvergence

    # This is done to support the backward compatibility (old sample scripts)
    bgpSuite config -framesizeList  [list]

    if { [advancedTestParameter cget -removeStreamsAtCompletion] == "true"} {
        if [removeStreams one2manyArray] {
            errorMsg "Error removing streams."
            set retCode 1
        }
    }
    return $retCode
}

################################################################################
#
# bgpSuite::PassFailCriteriaEvaluateRouteConvergence()
#
# DESCRIPTION:
# This procedure calculates the number of trials that have executed successfully
# based upon user-specified Pass/Fail criteria.  
#
# The criteria which must be met is based upon an acceptable value of
# convergence time.
# Total Convergence Time is the maximum convergence time across any frame sizes for a given trial.
# Average Convergence Time per Withdrawal is the maximum convergence time per withdrawal 
# across any frame sizes for a given trial.
#
# MODIFIES
# trialsPassed      - namespace variable indicating number of successful trials.
#
# RETURNS
# none
#
###
proc bgpSuite::PassFailCriteriaEvaluateRouteConvergence {} {
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
        
    for {set trial 1} {$trial <= [bgpSuite cget -numtrials] } {incr trial} {

	logMsg "*** Trial #$trial"

	set routeConvWithdrawList {}
        set routeConvMetricList {}

	foreach fs [lsort -dictionary [bgpSuite cget -framesizeList]] {
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
########################################################################
# Procedure: writeNewResults
#
# This procedure create the CSV files used for PDF Report generation
# CSV File Format
#
########################################################################
proc bgpSuite::writeNewResults_routeConvergence {} {
   variable resultsDirectory
   variable trialsPassed;
   global resultArray testConf passFail
   global aggregateArray loggerParms

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

 
   set mapArray    [format "%sArray"   [bgpSuite cget -mapType]]
   global $mapArray

   if {[catch {set csvFid [open $dirName/results.csv w]}]} {
      logMsg "***** WARNING:  Cannot open csv file."
      return
   }

   puts $csvFid "Trial,Frame Size (bytes),Tx Port,Rx Port,Max Rate (%),Number of routes,Tx Frames,Rx Frames,Frame Rate (FPS),Number of withdrawals,Total Loss (%),Total Frame Loss,Agg Advertise Convergence Time,Agg Withdraw Convergence Time"
   for {set trial 1} {$trial <= [bgpSuite cget -numtrials] } {incr trial} {
      foreach fs [lsort -dictionary [bgpSuite cget -framesizeList]] {
         
         set txPort   [lindex [getTxPorts $mapArray] 0]
         set rxPort1  [lindex [getRxPorts $mapArray] 0]
         set rxPort2  [lindex [getRxPorts $mapArray] 1]
         set maxRate [bgpSuite cget -percentMaxRate]
         set noOfRoutes [bgpSuite cget -routesPerPeer]
         set txCount $resultArray($trial,$fs,1,[join $txPort ,],port,TXtransmitFrames)
         set rxCount1 $resultArray($trial,$fs,1,[join $rxPort1 ,],port,RXreceiveFrames)
         set rxCount2 $resultArray($trial,$fs,1,[join $rxPort2 ,],port,RXreceiveFrames)
         set frameRate $resultArray($trial,$fs,1,iter,packetRate)
         set noOfWithdrawals $resultArray($trial,$fs,1,iter,numWithdraw)
         set totalFrameLossPct $resultArray($trial,$fs,1,iter,percentLoss)
         set totalFrameLoss $resultArray($trial,$fs,1,iter,totalPacketLoss)
         set convergenceMetric $resultArray($trial,$fs,1,iter,convergenceMetric)
         set convergenceMetricPerWithdrawal $resultArray($trial,$fs,1,iter,convergencePerWithdraw)
         
         puts $csvFid "$trial,$fs,[join $txPort .],[join $rxPort1 .],$maxRate,$noOfRoutes,$txCount,$rxCount1,$frameRate,$noOfWithdrawals,$totalFrameLossPct,$totalFrameLoss,$convergenceMetric,$convergenceMetricPerWithdrawal"
         puts $csvFid "-,-,-,[join $rxPort2 .],-,-,-,$rxCount2,-,-,-,-,-,-"
     }
   }

   closeMyFile $csvFid

  
    #################################
    #
    #  Create Info CSV
    #
    #################################
    
    csvUtils::writeInfoCsv bgpSuite;
    
    #################################
    #
    #  Create Real Time Chart CSV
    #
    #################################
    
    csvUtils::writeRealTimeCsv bgpSuite "BGP:Route Convergence"; 

    csvUtils::GeneratePDFReportFromCLI bgpSuite
}
