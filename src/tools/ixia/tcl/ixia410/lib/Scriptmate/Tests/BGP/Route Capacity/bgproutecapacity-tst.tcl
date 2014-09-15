############################################################################################
#
#   Copyright © 1997 - 2004 by IXIA.
#   All Rights Reserved.
#
# Description: This file contains the script for running BGP route capacity test
#              For performing this test we need 2 ixia ports, one transmit port 
#              and one receive port. Transmit direction is unidirectional.
#              1) Configure the  external neighbor and route range on receive port
#              2) Configure number of routes ( For the first iteration it is number of routes per peer)
#              3) start BGP server and pause for (advertiseDelayPerRoute * numberOfRoutes) Sec to
#                 advertise routes  
#              4) Start transmit ( one packet to each route )
#              5) Stop BGP server and wait for the same amount of time to tear down
#              6) Collect the stats 
#              7) If TotalLoss is 0 or less than tolerance go to number 2 else stop the test 
#              
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
                        <Source scope="results.csv" entity_name="bgpSuiteRouteCapacity" format_id=""/>
                        <Source scope="info.csv" entity_name="bgpSuiteRouteCapacity_Info" format_id=""/>
                        <Source scope="Iteration.csv" entity_name="bgpSuiteRouteCapacity_Iteration" format_id=""/>
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
proc bgpSuite::registerResultVars_routeCapacity {} \
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
# Procedure: routeCapacity
#
# Description: This command starts running the route capacity test.
#
########################################################################################
proc bgpSuite::routeCapacity {args} \
{
    variable status;
    
    set status $::TCL_OK;
    
    if {[catch {set status [bgpSuite::TestMethod_routeCapacity $args]} ERROR]} {	
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
# bgpSuite::TestMethod_routeCapacity(args)
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
proc bgpSuite::TestMethod_routeCapacity {args} {
    global one2oneArray 
    global testConf
    variable xmdDef
    variable resultsDirectory
    variable trial
    variable framesize


    set retCode 0

    set bgpPorts    [getRxPorts one2oneArray]

    realTimeGraphs::InitRealTimeStat \
	[list [list framesSent     [getTxPorts one2oneArray] "Tx Frames per second" "Tx Frames" 1e0]\
	     [list framesReceived [getRxPorts one2oneArray] "Rx Frames per second" "Rx Frames" 1e0]\
	     [list bitsSent       [getTxPorts one2oneArray] "Tx Kbps"              "Tx Kb"     1e3]\
	     [list bitsReceived   [getRxPorts one2oneArray] "Rx Kbps"              "Rx Kb"     1e3]\
	    ];

    if [validateUnidirectionalMap one2oneArray] {
        return $::TCL_ERROR
    }

    if [checkCapacityMap one2oneArray] {
        errorMsg "Invalid Map for capacity test. Should be one Tx port and one Rx port"
        return $::TCL_ERROR 
    }

    set dirName "[results cget -directory]/BGP.resDir/Route Capacity.resDir/[file rootname [csvUtils::getCurrentScriptName]].res"

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
               "Number of Routes"
               "Tx Frames"
               "Rx Frames"
               "Frame Loss"
               "Frame Loss (%)"
               "Frame Rate (FPS)"
    }
  
    if {[csvUtils::createIterationCSVFile bgpSuite $colHeads]} {
        return $::TCL_ERROR
    }
    
    if {[dutConfig::DutConfigure]} {
		logMsg "***** ERROR:  DUT Configuration failed.  Test aborted."
		return $::TCL_ERROR
    }


    bgpSuite config -testName "BGP Route Capacity Test"
	learn config -when        oncePerTest
 
    if [initTest bgpSuite one2oneArray {ip} errMsg] {
        errorMsg $errMsg
return $::TCL_ERROR
    }
    
    if {[bgpSuite cget -routesPerPeer] == 0 } {
        bgpSuite config -routesPerPeer  1
    }
    set beginNumberRoutes   [bgpSuite cget -routesPerPeer]

    realTimeGraphs::StartRealTimeStat;
    scriptMateGuiCommand openProgressMeter

    foreach framesize [bgpSuite cget -framesizeList] {
    
        bgpSuite config -framesize  $framesize
        setupTestResults bgpSuite one2one "" one2oneArray $framesize [bgpSuite cget -numtrials] false 1 routeCapacity
        set framesizeString "Framesize:$framesize"

        if [disableAutoCreateInterface  bgpPorts bgp4] {
            errorMsg "***** Error Configuring AutoCreateInterface..."
            return $::TCL_ERROR
        }         

        for {set trial 1} {$trial <= [bgpSuite cget -numtrials]} {incr trial} {
            logMsg " ******* TRIAL $trial - [bgpSuite cget -testName], Routes per peer: [bgpSuite cget -routesPerPeer]   ******* "
            
            if {[dutConfig::DutConfigure TrialSetup]} {
               logMsg "***** ERROR:  DUT Configuration failed.  Test aborted."
               return $::TCL_ERROR
           }

 
	    realTimeGraphs::SaveRealTimeMarker "-- Trial:$trial FS:$framesize --"

            set done 1
            set count 1
            set totalRoutes         [bgpSuite cget -routesPerPeer]
            set currRoutesPerPeer   [bgpSuite cget -routesPerPeer]
            while { $done && $retCode == 0 } {

                logMsg "####### Iteration : $count, $framesizeString, Current Number of Routes : $currRoutesPerPeer #######"  
           
                # initialize bgp server on rx port
                foreach port $bgpPorts {

                    scan $port "%d %d %d" c l p
                    initializeBgp $c $l $p

                    if [ip get $c $l $p] {
                        errorMsg "Error getting ip on port [getPortId $c $l $p]"
                        set retCode 1
                    }
               
                    set dutIP   [ip cget -destDutIpAddr ]
                    set peerIP  [ip cget -sourceIpAddr]
                    setupRouteItem  [bgpSuite cget -networkIPAddress] \
                                        [bgpSuite cget -prefixLength] \
                                                   $currRoutesPerPeer \
                                                             $peerIP]
                                        

                    if {[bgp4Neighbor addRouteRange     routeRange1]} {
                        errorMsg "Error adding route range [bgpSuite cget -networkIPAddress]"
                        set retCode 1
                    }
                    bgp4Neighbor config -type                   bgp4NeighborExternal
                    bgp4Neighbor config -localIpAddress         $peerIP
                    bgp4Neighbor config -rangeCount             1
                    bgp4Neighbor config -dutIpAddress           $dutIP
                    bgp4Neighbor config -localAsNumber          [bgpSuite cget -firstAsNumber] 
                
        
                    if [bgp4Server  addNeighbor neighbor1] {
                        errorMsg "Error adding Neighbor with IP [bgp4Neighbor cget -localIpAddress] address to the server"
                        set retCode 1
                    }

                    bgp4Server config -enableExternalEstablishOnce true
                    if [bgp4Server  set] {
                        errorMsg "Error setting the bgp4Server"
                    }

                    enablePortProtocolStatistics    $c $l $p enableBgpStats
                    enablePortProtocolServer        $c $l $p bgp4 noWrite
                }
            
                if [configureBgp4statsQuery neighborIpAddressArray dutIpAddressArray $bgpPorts ] {
                    logMsg " Error in configuring bgp4StatsQuery"
                    return $::TCL_ERROR
                }
            
                # write the streams
                if [writeBgpStreams one2oneArray txNumFrames $currRoutesPerPeer] {
		            return $::TCL_ERROR
                }
                       
                set advertiseDelay [estimateAdvertiseDelay $currRoutesPerPeer]

                # Start BGP Server
                logMsg "Starting BGP4..."
                if [startBgp4Server bgpPorts] {
                    errorMsg "Error Starting BGP!"
                    return $::TCL_ERROR
                }

                if [confirmPeerEstablished bgpPorts] {
                    errorMsg "Error!! Peers could not be established. The delay is not long enough or there is a network problem."
                    errorMsg "Please make sure the AS number is correct."
		    bgp4CleanUp bgpPorts no
                    return $::TCL_ERROR
                }
                logMsg "Waiting $advertiseDelay seconds for all routes to be advertised..."
                writeWaitForPause  "Waiting for routes to be advertised ..." $advertiseDelay
                logMsg "Confirming all routes have been advertised ..."
                if { [confirmAllRoutesAdvertised neighborIpAddressArray dutIpAddressArray $bgpPorts $currRoutesPerPeer extraTime] } {
                    logMsg "Warning: All routes have not been advertised yet."
                    bgp4CleanUp bgpPorts 
                    return $::TCL_ERROR

                } 
            
                logMsg "Pausing for [bgpSuite cget -delayTime] seconds before starting transmitting ..."          
                writeWaitForPause  "Pause before transmitting.." [bgpSuite cget -delayTime]          
                if [clearStatsAndTransmit one2oneArray [bgpSuite cget -duration] [bgpSuite cget -staggeredStart]] {
                    bgp4CleanUp bgpPorts
	                return $::TCL_ERROR
                }

                waitForResidualFrames [bgpSuite cget -waitResidual]
                
            
        
	            # Poll the Tx counters until all frames are sent
	            stats::collectTxStats [getTxPorts one2oneArray] txNumFrames txActualFrames totalTxNumFrames
	            collectRxStats [getRxPorts one2oneArray] rxNumFrames totalRxNumFrames
                debugMsg "rxNumFrames :[array get rxNumFrames]"

                bgp4CleanUp bgpPorts

                set totalLoss          [calculatePercentLoss $totalTxNumFrames $totalRxNumFrames]
                set tolerance          [bgpSuite cget -tolerance]

                #  Write in Iteration.CSV 
		csvUtils::writeIterationCSVFile bgpSuite [list $count \
						   [join [lindex [getTxPorts one2oneArray] 0] .] \
						   [join [lindex [getRxPorts one2oneArray] 0] .] \
                                                   [bgpSuite cget -routesPerPeer] \
						   $totalTxNumFrames \
						   $totalRxNumFrames \
                                                   [mpexpr $totalTxNumFrames - $totalRxNumFrames] \
						   $totalLoss \
                                                   [stream cget -framerate]]
                                                                            
                if { ($totalLoss <= [bgpSuite cget -tolerance] ) && ( $retCode ==0 ) && ([bgpSuite cget -routeStep] != 0) } {
					catch {unset savedTxActualFrames }
					array set savedTxActualFrames [array get txActualFrames]
					catch {unset savedRxNumFrames }
					array set savedRxNumFrames [array get rxNumFrames]
					set savedTotalLoss $totalLoss

                    set totalRoutes $currRoutesPerPeer
                    logMsg " Continue to increase number of Routes. Number of routes up to now is $currRoutesPerPeer "
                    mpincr currRoutesPerPeer          [bgpSuite cget -routeStep]
                    bgpSuite config -routesPerPeer    $currRoutesPerPeer
                    incr count
                } else {
                    set done 0
                    if {$count == 1} {
                        set totalRoutes $totalRxNumFrames
                    }
                    logMsg " Done "
                    bgpSuite config -routesPerPeer   $beginNumberRoutes
                }
            }
            set packetRate      [stream cget -framerate]

            if {[info exists savedTotalLoss]} {
                catch {unset txActualFrames}
                array set txActualFrames [array get savedTxActualFrames]
                catch {unset rxNumFrames}
                array set rxNumFrames [array get savedRxNumFrames]
                set totalLoss $savedTotalLoss 
            }

            if [results save one2one [bgpSuite cget -framesize] $trial  \
                                                           txActualFrames      \
                                                           rxNumFrames     \
                                                           packetRate       \
                                                           totalLoss     \
                                                           tolerance  \
                                                           totalRoutes  ] {
                    errorMsg "Error saving results for Trial $trial. "
                    return 1
            }
            if [results printToScreen one2one [bgpSuite cget -framesize] $trial] {
                set retCode 1
            }
            
            if {[dutConfig::DutConfigure TrialCleanup]} {
               logMsg "***** ERROR:  DUT Configuration failed.  Test aborted."
               return $::TCL_ERROR
           }


        } ;# end of for loop ( trial)
    }
    
    if {[dutConfig::DutConfigure TestCleanup]} {
		logMsg "***** ERROR:  DUT Configuration failed.  Test aborted."
		return $::TCL_ERROR
    }


    realTimeGraphs::StopRealTimeStat;
    scriptMateGuiCommand closeProgressMeter
    PassFailCriteriaEvaluateRouteCapacity
    bgpSuite::writeNewResults_routeCapacity


    # This is done to support the backward compatibility (old sample scripts)
    bgpSuite config -framesizeList  [list]

    if { [advancedTestParameter cget -removeStreamsAtCompletion] == "true"} {
        if [removeStreams one2oneArray] {
            errorMsg "Error removing streams."
            set retCode 1
        }
    }
        
    return $retCode
}

################################################################################
#
# ospfSuite::PassFailCriteriaEvaluateRouteCapacity()
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
proc bgpSuite::PassFailCriteriaEvaluateRouteCapacity {} {
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

	set routeCapacityList {}

	foreach fs [lsort -dictionary [bgpSuite cget -framesizeList]] {

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

########################################################################
# Procedure: writeNewResults
#
# This procedure create the CSV files used for PDF Report generation
# CSV File Format
#
########################################################################
proc bgpSuite::writeNewResults_routeCapacity {} {
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

   puts $csvFid "Trial,Frame Size (bytes),Tx Port,Rx Port,Number of routes,Tx Frames,Rx Frames,Total Frame Loss,Total Loss (%),Frame Rate (FPS),Max Routes Verified"
   for {set trial 1} {$trial <= [bgpSuite cget -numtrials] } {incr trial} {
      foreach fs [lsort -dictionary [bgpSuite cget -framesizeList]] {
         foreach pair $portList {
            set txPort  [lindex $pair 0]
            set rxPort  [lindex $pair 1]
            set txCount $resultArray($trial,$fs,1,[join $txPort ,],port,TXtransmitFrames)
            set rxCount $resultArray($trial,$fs,1,[join $rxPort ,],port,RXreceiveFrames)
            set frameLoss [mpexpr $txCount - $rxCount]
            set frameLossPct $resultArray($trial,$fs,1,iter,percentLoss)
            set noRoutes [bgpSuite cget -routesPerPeer]
            set frameRate $resultArray($trial,$fs,1,iter,packetRate)
            set maxRoutesVerified $resultArray($trial,$fs,1,iter,totalRoutes)
            puts $csvFid "$trial,$fs,[join $txPort .],[join $rxPort .],$noRoutes,$txCount,$rxCount,$frameLoss,$frameLossPct,$frameRate,$maxRoutesVerified"
         }
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
    
    csvUtils::writeRealTimeCsv bgpSuite "BGP:Route Capacity"; 

    csvUtils::GeneratePDFReportFromCLI bgpSuite
}



