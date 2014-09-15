########################################################################
# Version 4.10	$Revision: 113 $
# $Date: 12/11/02 2:46p $
# $Author: Hasmik $
#
# $Workfile: statistics.tcl $
#
#   Copyright © 1997 - 2005 by IXIA
#   All Rights Reserved.
#
#	Revision Log:
#	12-30-1998	DS
#
# Description: 
#	This file contains common procs used to access/calculate statistics
#
########################################################################


########################################################################
# Procedure: checkTransmitDone
#
# This command polls the TX rate counters & returns the number of frames
# transmitted
#
# Argument(s):
#	chassis		chassis ID
#	lm			Load Module number
#	port		port number
#
########################################################################
proc checkTransmitDone {chassis lm port} \
{
    set retCode     $::TCL_OK
	set numTxFrames	0

    while {[stat getTransmitState $chassis $lm $port] && ($::ixStopTest != 1)} {
        after 250
    }
 
    # just a wait to make sure stats are all updated...
    after 400
	
	set txList [list [list $chassis $lm $port]]
	requestStats txList

	if [statList get $chassis $lm $port] {
		errorMsg "Error getting statList for [getPortId $chassis $lm $port]."
		set retCode $::TCL_ERROR
	}

    if { !$retCode } {
		# we only need this cause this proc returns num frames sent...
		if [catch {statList cget -scheduledFramesSent} numTxFrames ] {
			if [catch {statList cget -framesSent} numTxFrames ] {
				set numTxFrames 0
			} else {
				set numTxFrames [mpexpr $numTxFrames - [statList cget -protocolServerTx]]
				if {[isNegative $numTxFrames]} {
					 set numTxFrames 0
				}
			}
		}
	}
    
    return $numTxFrames    
}


########################################################################
# Procedure: checkAllTransmitDone
#
# This command polls the TX rate counters for all ports in the list/map
#
# Argument(s):
#   TxRxArray          - list or map array containing ports
#
########################################################################
proc checkAllTransmitDone {TxRxArray {duration 0}} \
{
    upvar $TxRxArray    txRxArray

    set retCode $::TCL_OK

	set timeout		[expr $duration + 1]
    set currentTime [clock seconds]

    set txPorts     [getTxPorts txRxArray]

	foreach port $txPorts {
		scan $port "%d %d %d" c l p

	    while {[stat getTransmitState $c $l $p] == $::statActive && ($::ixStopTest != 1)} {
            after 250
            if {$duration > 0} {
                if {[mpexpr [clock seconds] - $currentTime] > $timeout} {
					set retCode $::TCL_ERROR 
					break                  
                }
            }
	    }
		if { $retCode } {
			break
		}
    }
    
    return $retCode   
}



########################################################################
# Procedure: requestStats
#
# This command request stats from a group of ports 
#
# Argument(s):
#   TxRxArray          - list or map array containing ports
#
########################################################################
proc requestStats {TxRxArray} \
{
    upvar $TxRxArray    txRxArray

    set retCode $::TCL_OK

    statGroup setDefault
	foreach port [getAllPorts txRxArray] {
		scan $port "%d %d %d" c l p
        
        if [statGroup add $c $l $p] {
            errorMsg "Error adding port [getPortId $c $l $p] to statGroup"
            set retCode $::TCL_ERROR
            continue
        }
	}

    if [statGroup get] {
        errorMsg "Error getting stats for ports in statGroup"
        set retCode $::TCL_ERROR
    }

    return $retCode
}


########################################################################
# Procedure: collectTxStats
#
# This command polls the TX counters 
#
# Argument(s):
#   txList          - list of transmit ports
#   TxNumFrames     - array containing the number of frames that should have been transmitted
#   TxActualFrames  - array containing the actual transmitted stats (returned val)
#
########################################################################
proc collectTxStats {txList TxNumFrames TxActualFrames {TotalTxFrames ""} {verbose true} } \
{
    upvar $TxNumFrames    txNumFrames
    upvar $TxActualFrames txActualFrames

    if {[info exists TotalTxFrames]} {
        upvar $TotalTxFrames	totalTxFrames
    }

    set retCode		        0
    set totalTxFrames		0

    if {$verbose == "true"} {
        logMsg "Collecting transmit statistics ..."
    }

    checkAllTransmitDone txList
    requestStats txList

    # Loop through all receive ports and find the longest name.  Then the log messages can be formatted well.
    # Keep the names in a temporary array for use in the next loop.  This is so unix will not be calling twice
    # for the name.
    set nameLen 0
    foreach txMap $txList {
        scan $txMap "%d %d %d" tx_c tx_l tx_p
        set tempTxArray($tx_c,$tx_l,$tx_p) [getPortId $tx_c $tx_l $tx_p]
        set newLen [string length $tempTxArray($tx_c,$tx_l,$tx_p)]
        if {$newLen > $nameLen} {
            set nameLen $newLen
        }
    }

    foreach txMap $txList {
        scan $txMap	"%d %d %d" tx_c tx_l tx_p

        if [statList get $tx_c $tx_l $tx_p] {
            errorMsg "Error getting stats for [getPortId $tx_c $tx_l $tx_p]."
            set txActualFrames($tx_c,$tx_l,$tx_p)   0
            continue
        }

        # there's a new stat for the txs-family so that we don't have to subtract out the protocol stats, yea!!
        if [catch {statList cget -scheduledFramesSent} numTxFrames] {
            # if this port doesn't support nifty new stat, then just use config'd value
            set numTxFrames $txNumFrames($tx_c,$tx_l,$tx_p)

            # only make use of the protocolServerTx stats if the user aborted the test whilst transmitting
            if {$::ixStopTest} {
                if [catch {statList cget -framesSent} numTxFrames ] {
                    set numTxFrames  0
                }
                if [catch {statList cget -protocolServerTx} numProtocolServerFrames ] {
                    set numProtocolServerFrames  0
                }
                set numTxFrames [mpexpr ($numTxFrames - $numProtocolServerFrames ) ]
                # Since 32 bit counter (mpexpr) is used here, if we get a 32 bit long number (in binary) whose most significiant
                # bit is 1, it will be recognized as a negtive number. 
                # So we use regexp to determine wheather numTxFrames is a negative number instead of using "$numTxFrames < 0"
                if { [regexp {^-[0-9]+$} $numTxFrames] } {
                    set numTxFrames 0
                }
            }
        }
        set txActualFrames($tx_c,$tx_l,$tx_p) $numTxFrames

        if {$txActualFrames($tx_c,$tx_l,$tx_p) < $txNumFrames($tx_c,$tx_l,$tx_p)} {
            if {$verbose == "true"} {
                logMsg "All $txNumFrames($tx_c,$tx_l,$tx_p) frames not transmitted on [getPortId $tx_c $tx_l $tx_p] - check the device"
            }
            set retCode $::TCL_ERROR
        } elseif {$txActualFrames($tx_c,$tx_l,$tx_p) > $txNumFrames($tx_c,$tx_l,$tx_p)} {
            if {$verbose == "true"} {
                logMsg "Transmitted more frames than expected on [getPortId $tx_c $tx_l $tx_p]"
            }
        }

        if {$verbose == "true"} {
            logMsg [format "%-${nameLen}s:  Total frames transmitted: $txActualFrames($tx_c,$tx_l,$tx_p)" $tempTxArray($tx_c,$tx_l,$tx_p)]
        }

        mpincr totalTxFrames $txActualFrames($tx_c,$tx_l,$tx_p)
    }

    return $retCode
}


########################################################################
# Procedure: collectRxStats
#
# This command polls the RX counters 
#
# Argument(s):
#   rxList          - list of receive ports
#   RxNumFrames     - array containing the returned rx stats
#   TotalRxFrames   - total received frames
#   printError      - if no frames received, print error message
#
########################################################################
proc collectRxStats {rxList RxNumFrames {TotalRxFrames ""} {printError yes} {receiveCounter userDefinedStat2}} \
{
    upvar $RxNumFrames		rxNumFrames
    if {[info exists TotalRxFrames]} {
        upvar $TotalRxFrames	totalRxFrames
    }

    set retCode				0
    set totalRxFrames		0

    logMsg "Collecting receive statistics ..."

    set retCode [requestStats rxList]

    # Loop through all receive ports and find the longest name.  Then the log messages can be formatted well.
    set nameLen 0
    foreach rxMap [lnumsort $rxList] {
        scan $rxMap "%d %d %d" rx_c rx_l rx_p
        set tempRxArray($rx_c,$rx_l,$rx_p) [getPortId $rx_c $rx_l $rx_p]
        set newLen [string length $tempRxArray($rx_c,$rx_l,$rx_p)]
        if {$newLen > $nameLen} {
            set nameLen $newLen
        }
    }

    foreach rxMap [lnumsort $rxList] {
        scan $rxMap	"%d %d %d" rx_c rx_l rx_p

        # count the Rx Frames
        if [statList get $rx_c $rx_l $rx_p] {
            errorMsg "Error getting Rx statistics for [getPortId $rx_c $rx_l $rx_p]"
        }

        if [catch {statList cget -$receiveCounter} rxNumFrames($rx_c,$rx_l,$rx_p)] {
            errorMsg "$receiveCounter is not a valid counter for port [getPortId $rx_c $rx_l $rx_p]"
            set rxNumFrames($rx_c,$rx_l,$rx_p)  0
        }

        # if no frames received, there must be a connection error... dump out
        if {$rxNumFrames($rx_c,$rx_l,$rx_p) == 0} {
            if {$printError == "yes"} {
                logMsg "\n\n\tError !!"
                logMsg "\tZero packets received on port [getPortId $rx_c $rx_l $rx_p]"    
                logMsg "\tCheck the connections." 
            }
            set retCode 1
        }

        logMsg [format "%-${nameLen}s:  Total frames received   : $rxNumFrames($rx_c,$rx_l,$rx_p)" \
                $tempRxArray($rx_c,$rx_l,$rx_p)]

        mpincr totalRxFrames $rxNumFrames($rx_c,$rx_l,$rx_p)
    }

    return $retCode
}


########################################################################
# Procedure: collectVlanStats
#
# This command polls the Vlan counters 
#
# Argument(s):
#   vlanList          - list of receive ports
#   VlanNumFrames     - array containing the returned Vlan stats
#   TotalVlanFrames   - total received frames
#
########################################################################
proc collectVlanStats {vlanList VlanNumFrames {TotalVlanFrames ""}} \
{
    upvar $VlanNumFrames		vlanNumFrames
	if {[info exists TotalVlanFrames]} {
		upvar $TotalVlanFrames	totalVlanFrames
	}

	set retCode				0
	set totalVlanFrames		0

	debugMsg "Collecting vlan tagged frame statistics ..."

    set retCode [requestStats vlanList]

	foreach rxMap [lnumsort $vlanList] {
		scan $rxMap	"%d %d %d" rx_c rx_l rx_p

	    # count the vlan tagged frames
        if [statList get $rx_c $rx_l $rx_p] {
	        errorMsg "Error getting vlan tagged frame statistics for [getPortId $rx_c $rx_l $rx_p]"
        } else {
            if [catch {statList cget -vlanTaggedFramesRx} vlanNumFrames($rx_c,$rx_l,$rx_p)] {
                errorMsg "***** WARNING:Invalid statistic (vlanTaggedFramesRx) for the port:[getPortString $rx_c $rx_l $rx_p]\n"
                set vlanNumFrames($rx_c,$rx_l,$rx_p) 0
                set retCode 1
            }

            mpincr totalVlanFrames $vlanNumFrames($rx_c,$rx_l,$rx_p)       
        }
    }
    return $retCode
}

########################################################################
# Procedure: collectDataIntegrityStats
#
# This command polls the Data Integrity counters 
#
# Argument(s):
#   rxPortList      - list of receive ports
#   Errors          - array containing the error stats
#   RxFrames        - received data integrity frames per rx port
#   TotalRxFrames   - total received data integrity frames
#
########################################################################
proc collectDataIntegrityStats {rxPortList Errors RxFrames {TotalRxFrames ""} {TotalErrorFrames ""}} \
{
    upvar $Errors	errors
	upvar $RxFrames	rxFrames

	if {[string length $TotalRxFrames] != 0 } {
		upvar $TotalRxFrames	totalRxFrames
	}

	if {[string length $TotalErrorFrames] != 0 } {
		upvar $TotalErrorFrames	totalErrorFrames
	}

	set retCode				$::TCL_OK
	set totalRxFrames		0
    set totalErrorFrames    0

	logMsg "Collecting data integrity statistics ..."
    
    set retCode [requestStats rxPortList]

	foreach rxMap $rxPortList {
		scan $rxMap	"%d %d %d" rx_c rx_l rx_p

	    # count the data integrity frames
        if [statList get $rx_c $rx_l $rx_p] {
	        errorMsg "Error getting data integrity frame statistics for [getPortId $rx_c $rx_l $rx_p]"
        } else {

            if {[catch {statList cget -dataIntegrityFrames} rxFrames($rx_c,$rx_l,$rx_p)]} {
                errorMsg "***** WARNING:Invalid statistic (dataIntegrityFrames) for the port:[getPortString $rx_c $rx_l $rx_p]\n"
                set rxFrames($rx_c,$rx_l,$rx_p) 0
                set retCode $::TCL_ERROR
            }
            mpincr totalRxFrames $rxFrames($rx_c,$rx_l,$rx_p)       

            if {[catch {statList cget -dataIntegrityErrors} errors($rx_c,$rx_l,$rx_p)]} {
                errorMsg "***** WARNING:Invalid statistic (dataIntegrityErrors) for the port:[getPortString $rx_c $rx_l $rx_p]\n"
                set errors($rx_c,$rx_l,$rx_p) 0
                set retCode $::TCL_ERROR
            }
            mpincr totalErrorFrames $errors($rx_c,$rx_l,$rx_p)            
        }
    }
    return $retCode
}

########################################################################
# Procedure: collectSequenceStats
#
# This command polls the Sequence counters 
#
# Argument(s):
#   rxPortList      - list of receive ports
#   Errors          - array containing the error stats
#   RxFrames        - received sequence frames per rx port
#   TotalRxFrames   - total received sequence frames
#
########################################################################
proc collectSequenceStats {rxPortList Errors RxFrames {TotalRxFrames ""} {TotalErrorFrames ""}} \
{
    upvar $Errors	errors
	upvar $RxFrames	rxFrames

	if {[info exists TotalRxFrames]} {
		upvar $TotalRxFrames	totalRxFrames
	}

	if {[info exists TotalErrorFrames]} {
		upvar $TotalErrorFrames	totalErrorFrames
	}

	set retCode				$::TCL_OK
	set totalRxFrames		0
    set totalErrorFrames    0

	logMsg "Collecting sequence statistics ..."
    
    set retCode [requestStats rxPortList]

	foreach rxMap $rxPortList {
		scan $rxMap	"%d %d %d" rx_c rx_l rx_p

	    # count the data integrity frames
        if [statList get $rx_c $rx_l $rx_p] {
	        errorMsg "Error getting data integrity frame statistics for [getPortId $rx_c $rx_l $rx_p]"
        } else {

            if {[catch {statList cget -sequenceFrames} rxFrames($rx_c,$rx_l,$rx_p)]} {
                errorMsg "***** WARNING:Invalid statistic (dataIntegrityFrames) for the port:[getPortString $rx_c $rx_l $rx_p]\n"
                set rxFrames($rx_c,$rx_l,$rx_p) 0
                set retCode $::TCL_ERROR
            }
            mpincr totalRxFrames $rxFrames($rx_c,$rx_l,$rx_p)       

            if {[catch {statList cget -sequenceErrors} errors($rx_c,$rx_l,$rx_p)]} {
                errorMsg "***** WARNING:Invalid statistic (dataIntegrityErrors) for the port:[getPortString $rx_c $rx_l $rx_p]\n"
                set errors($rx_c,$rx_l,$rx_p) 0
                set retCode $::TCL_ERROR
            }
            mpincr totalErrorFrames $errors($rx_c,$rx_l,$rx_p)       
        }
    }
    return $retCode
}

########################################################################
# Procedure: collectErroredFramesStats
#
# This command collects the counters for the errored frames received 
# 
# Argument(s):
# rxPortList            - receive port list
# ErrorredFrames        - array containing the number of errored frames per rx port
# errorList		        - list that contains errors, example {oversize undersize}
#
# NOTE: This proc is used by custom code, don't remove it
#
########################################################################
proc collectErroredFramesStats {rxPortList ErrorredFrames errorList} \
{
    upvar $ErrorredFrames	errorredFrames

    set retCode     0   
    set retCode     [requestStats rxPortList]
            
	foreach rxMap $rxPortList {
		scan $rxMap	"%d %d %d" rx_c rx_l rx_p

        if [statList get $rx_c $rx_l $rx_p] {
	        errorMsg "Error getting statList for [getPortId $rx_c $rx_l $rx_p]"
        } else {
            foreach errType $errorList {
                if [catch {statList cget -$errType} statValue] {
                    logMsg "\n\n***** WARNING: Invalid statistic ($errType) for the port:[getPortString $rx_c $rx_l $rx_p] \n"
                    set errorredFrames($errType,$rx_c,$rx_l,$rx_p)    "N/A"
                } else {       
                    set errorredFrames($errType,$rx_c,$rx_l,$rx_p)    [statList cget -$errType]
                }
            }
        }
    }

    return $retCode
}

########################################################################
# Procedure: collectQosStats
#
# This command polls the QoS counters 
#
# Argument(s):
#   rxList          - list of receive ports
#   RxQosNumFrames  - array containing the returned rx stats per priority
#   TotalQosFrames  - array containing the total Qos frames, per priority
#   TotalRxFrames   - total received frames
#   printError      - if no frames received, print error message
#
########################################################################
proc collectQosStats {rxList RxQosNumFrames {TotalQosFrames ""} {TotalRxFrames ""} {printError yes}} \
{
    upvar $RxQosNumFrames		rxQosNumFrames

    if [info exists TotalQosFrames] {
        upvar $TotalQosFrames   totalQosFrames
    }

	if [info exists TotalRxFrames] {
		upvar $TotalRxFrames	totalRxFrames
	}

	set retCode 0

    set numPriorities 8

    # init the totals first
    for {set i 0} {$i < $numPriorities} {incr i} {
        set totalQosFrames($i)  0
    }

    set retCode [requestStats rxList]

	set totalRxFrames    0

    # look at each qost stat
	foreach rxMap $rxList {
		scan $rxMap	"%d %d %d" rx_c rx_l rx_p

        if [statList get $rx_c $rx_l $rx_p] {
			errorMsg "Error getting Rx statistics for [getPortId $rx_c $rx_l $rx_p]"
			set retCode 1
		}

        set totalRx($rx_c,$rx_l,$rx_p)  0

        for {set priority 0} {$priority < $numPriorities} {incr priority} {
		    if [catch {statList cget -qualityOfService$priority} rxQosNumFrames($priority,$rx_c,$rx_l,$rx_p)] {
                errorMsg "***** WARNING:Invalid statistic (qualityOfService$priority) for the port:[getPortString $rx_c $rx_l $rx_p]\n"
                set rxQosNumFrames($priority,$rx_c,$rx_l,$rx_p) 0
                set retCode 1
            }
            mpincr totalQosFrames($priority)  $rxQosNumFrames($priority,$rx_c,$rx_l,$rx_p)
            mpincr totalRxFrames              $rxQosNumFrames($priority,$rx_c,$rx_l,$rx_p)
            mpincr totalRx($rx_c,$rx_l,$rx_p) $rxQosNumFrames($priority,$rx_c,$rx_l,$rx_p)
 
        }

		if {$totalRx($rx_c,$rx_l,$rx_p) == 0 && $printError == "yes"} {
			logMsg "\n\n\tError !!"
			logMsg "\tZero packets received on port [getPortId $rx_c $rx_l $rx_p]"    
			logMsg "\tCheck the connections." 
		}

	    logMsg "[getPortId $rx_c $rx_l $rx_p]:	Total frames received: $totalRx($rx_c,$rx_l,$rx_p)"
	}

    return $retCode
}


########################################################################
# Procedure: collectStats
#
# This command polls the RX counters for the specified stat
#
# Argument(s):
#   rxList          - list of receive ports
#   statNameList    - list name of stats to poll, return total (need cget name)
#   RxNumFrames     - array containing the returned rx stats
#   TotalRxFrames   - total received frames
#
########################################################################
proc collectStats {rxList statNameList RxNumFrames {TotalRxFrames ""} {verbose verbose} } \
{
    upvar $RxNumFrames		rxNumFrames
	if {[info exists TotalRxFrames]} {
		upvar $TotalRxFrames	totalRxFrames
	}

	set retCode				0
	set totalRxFrames		0

    logMsg "Collecting [join $statNameList] statistics ..."
    set retCode [requestStats rxList]

	foreach rxMap [lnumsort $rxList] {
		scan $rxMap	"%d %d %d" rx_c rx_l rx_p

		# count the Rx Frames
		if [statList get $rx_c $rx_l $rx_p] {
			errorMsg "Error getting Rx statistics for [getPortId $rx_c $rx_l $rx_p]"
            set retCode 1
		} else {
            set rxNumFrames($rx_c,$rx_l,$rx_p)  0
            foreach statName $statNameList {
	            # make sure we're using the proper stat name!!
                if {[string first stat $statName] == 0} {
                    set statName     [string trimleft $statName stat]
                    set firstChar    [string tolower [string index $statName 0]]
                    append firstChar [string range $statName 1 end]
                    set statName     $firstChar
                }

 		        if [catch {statList cget -$statName} value] {
                    if {$verbose == "verbose"} {
                        errorMsg "***** WARNING:Invalid statistic ($statName) for the port:[getPortString $rx_c $rx_l $rx_p]\n"
                    }
		            set value   0
                    set retCode 1
                }
                 
                mpincr rxNumFrames($rx_c,$rx_l,$rx_p) $value
            }
		    mpincr totalRxFrames $rxNumFrames($rx_c,$rx_l,$rx_p)
        }
    }

    return $retCode
}


########################################################################
# Procedure: getNumErroredFrames
#
# This command gets the counter that contains the number of errored frames 
# received
#
# Argument(s):
#	chassis		chassis ID
#	lm			Load Module number
#	port		port number
#	error		allErrors OR {oversize|undersize|alignment|dribble|badCRC}
#
########################################################################
proc getNumErroredFrames {chassis lm port {error allErrors}} \
{ 
    set numRxFrames     0

    set errList         {fragments undersize oversize fcsErrors symbolErrors \
                         alignmentErrors dribbleErrors collisions lateCollisions \
                         collisionFrames excessiveCollisionFrames oversizeAndCrcErrors \
                         symbolErrorFrames synchErrorFrames} 
 
    if [stat get statAllStats $chassis $lm $port] {
        errorMsg "Error getting statistics for $chassis,$lm,$port"
    } else {
        if {$error != "allErrors"} {
            set errList $error
        }
        foreach error $errList {
            if [catch {stat cget -$error} msg]  {
               errorMsg $msg
            } else {
                catch {mpincr numRxFrames [stat cget -$error]}
            }
        }
    }
 
    return $numRxFrames
}


########################################################################
# Procedure: checkLinkState
#
# This command checks the link state of all ports in parallel and labels
# the ones that are down. Then it polls the links that are down for two
# seconds and returns 1 if any port is still down and a 0 if all ports are
# up.
#
# Arguments(s):
#	PortArray		array or list of ports, ie, ixgSortMap
#   PortsToRemove	list containing the ports to be removed
#
########################################################################
proc checkLinkState {PortArray {PortsToRemove ""} {message messageOn}} \
{
	upvar $PortArray portArray
    upvar $PortsToRemove portsToRemove

    global kLinkState interfaceUSB

    set retCode 0

	if {$message == "messageOn"} {
        set logger  "logMsg"
    } else {
        set logger  "debugMsg"
    }

    eval $logger "Checking link states on ports ..."

	if {[info exists linkState]} {
		unset linkState
	}
    
    after 1000  ;# give the port some time to begin it's in autonegotiate mode or PPP
    
    set portList    [getAllPorts portArray]
    
	# go through all the ports and label the ones whose links are down
	foreach portMap $portList {
		scan $portMap "%d %d %d" tx_c tx_l tx_p
        debugMsg "checking link state on [getPortId $tx_c $tx_l $tx_p]"

		if {![info exists linkState($tx_c,$tx_l,$tx_p)]} {
            set state   [stat getLinkState $tx_c $tx_l $tx_p]
			if {$state != $kLinkState(linkUp) && $state != $kLinkState(pppUp) && $state != $kLinkState(linkLoopback)} {
				set linkState($tx_c,$tx_l,$tx_p)	1
				debugMsg "Link on Tx port [getPortId $tx_c $tx_l $tx_p] is down."
			}
		}
	}

	# the linkState array are all the ports whose links are down. Now poll
	# them a few times until they are all up or return.
    set loopCount   [expr [advancedTestParameter cget -linkStateTimeout] * 2] 
	for {set ctr 0} {$ctr < $loopCount} {incr ctr} {
		foreach downlink [array names linkState] {
			scan $downlink "%d,%d,%d" c l p
            set state   [stat getLinkState $c $l $p]
		    if {$state == $kLinkState(linkUp) || $state == $kLinkState(pppUp) || $state == $kLinkState(linkLoopback)} {
				debugMsg "Link on port [getPortId $c $l $p] is now up."
				unset linkState($c,$l,$p)
			}
		}
		if {[llength [array names linkState]] == 0} {
			break
		} else {
			after 500
		}
	}

	set portsToRemove [getTxPorts linkState]

	if {[llength [array names linkState]] == 0} {
		eval $logger "Links on all ports are up."
	} else {
		logMsg "Link on these ports are down:"
		foreach downlink [array names linkState] {
			scan $downlink "%d,%d,%d" c l p
			logMsg [getPortId $c $l $p]
		}
        set retCode 1       
	}

    after [advancedTestParameter cget -dutDelay]

	return $retCode
}


########################################################################
# Procedure: checkPPPState
#
# This command checks the PPP state of all PoS ports in parallel and labels
# the ones that are down. Then it polls the links that are down for two
# seconds and returns 1 if any port is still down and a 0 if all ports are
# up.
#
# Arguments(s):
#	PortArray	array or list of ports, ie, ixgSortMap
#
########################################################################
proc checkPPPState {PortArray {message messageOn}} \
{
	upvar $PortArray portArray

    global kLinkState

    set retCode 0

	if {$message == "messageOn"} {
        set logger  "logMsg"
    } else {
        set logger  "debugMsg"
    }

    eval $logger "Checking PPP states on ports ..."

	if {[info exists linkState]} {
		unset linkState
	}
 
    after 1000  ;# give the port some time to begin it's in autonegotiate mode or PPP

    set portList    [getAllPorts portArray]
    
	# go through all the ports and label the ones whose links are down
	foreach portMap $portList {
		scan $portMap "%d %d %d" c l p

        if [IsPOSPort $c $l $p] {
		    if {![info exists linkState($c,$l,$p)]} {
                debugMsg "checking link state on [getPortId $c $l $p]"
                set state   [stat getLinkState $c $l $p]

			    if {$state != $kLinkState(pppUp)} {
				    set linkState($c,$l,$p)	$state
				    debugMsg "Link on Tx port [getPortId $c $l $p] is down"
			    }
		    }
        }
	}

	# the linkState array are all the ports whose links are down. Now poll
	# them a few times until they are all up or return.
    set loopCount   [expr [advancedTestParameter cget -linkStateTimeout] * 4] 
	for {set ctr 0} {$ctr < $loopCount} {incr ctr} {
		foreach downlink [array names linkState] {
			scan $downlink "%d,%d,%d" c l p
            set state   [stat getLinkState $c $l $p]

            # if the state has transitioned to something else, print it & check it...
            if {$state != $linkState($c,$l,$p)} {
                foreach {stateName stateValue} [array get kLinkState] {
                    if {$state == $stateValue} {
                        eval $logger "Link state on port $c $l $p: $stateName"
                        break
                    }
                }
		        if {$state == $kLinkState(pppUp)} {
				    debugMsg "Link on port [getPortId $c $l $p] is now up."
				    unset linkState($c,$l,$p)
			    } else {
                    set linkState($c,$l,$p)    $state
                }
            }
		}
		if {[llength [array names linkState]] == 0} {
			break
		} else {
			after 250
		}
	}

	if {[llength [array names linkState]] == 0} {
	    if {$message == "messageOn"} {
		    logMsg "Links on all ports are up."
        } else {
		    debugMsg "Links on all ports are up."
        }
	} else {
		logMsg "Link on these ports are down:"
		foreach d [array names linkState] {
			logMsg $d
		}
		set retCode 1
	}

	return $retCode
}


########################################################################
# Procedure: getRunningRate
#
# Description: Gets the running rates of a list of ports
#
# Argument(s):
#   portList    - list of ports or array contains tx and rx ports
#   RunningRate - array w/rate values
#   sampleNum   - for keeping track of different sample times
#
########################################################################
proc getRunningRate {portList RunningRate args {sampleNum 1}} \
{
	upvar $RunningRate  runningRate

    set retCode $::TCL_OK

	requestStats portList

    # even if we got an error, go ahead & fill array so we don't crash anyone...
	foreach portMap $portList {
		scan $portMap "%d %d %d" c l p

	    if [statList getRate $c $l $p] {
		    errorMsg "Error getting rates on port $c,$l,$p"
            set retCode $::TCL_ERROR
	    }

        foreach counter [join $args] {
			set failCount 0
			set tempCounter $counter
			
		    if [catch {statList cget -$counter} currRate($counter)] {

				switch $counter {

					"framesReceived" {			
						set tempCounter atmAal5FramesReceived
						if [catch {statList cget -atmAal5FramesReceived} currRate($counter)] {
							incr failCount
						}
					}
					"scheduledFramesSent" { 
						set tempCounter framesSent
						if [catch {statList cget -framesSent} currRate($counter)] {
							incr failCount
						}
					}
				}

				if { $counter == $tempCounter } {
					incr failCount
				}
			}

			if { $failCount } {				
				errorMsg "$tempCounter is not a valid rate counter"
				set currRate($counter)  0
		    }
        }
  
		if {[llength $args] == 1} {
    		set runningRate($c,$l,$p,$sampleNum) $currRate($args)
			debugMsg "TX: runningRate($c,$l,$p,$sampleNum) = $runningRate($c,$l,$p,$sampleNum)"
		} else {
			foreach counter $args {
    			set runningRate($c,$l,$p,$counter,$sampleNum) $currRate($counter)
				debugMsg "TX: runningRate($c,$l,$p,$counter,$sampleNum) = $runningRate($c,$l,$p,$counter,$sampleNum)"
			}
		}
    }

    return $retCode
}



##################################################################################
# Procedure: getRunRatePerSecond
#
# Description: Collects the rate during transmission at every second.
#
# Argument(s):
#   TxRxArray       - array of ports to transmit, ie. one2oneArray
#   TxRateArray     - array containing the running rate for tx ports
#   RxRateArray     - array containing the receive rate for rx ports
#   duration        - duration of tx
#
# Note: We need to get rid of this method when we get rid of cable modem suite
#
##################################################################################
proc getRunRatePerSecond {TxRxArray TxRateArray RxRateArray duration} \
{
    upvar $TxRxArray    txRxArray
    upvar $TxRateArray  txRateArray
    upvar $RxRateArray  rxRateArray

    set retCode 0
    set count   0

    set txPortList  [getTxPorts txRxArray]
    set rxPortList  [getRxPorts txRxArray]
 
    if [createDialog "Transmit Status"] {
        set cmd logMsg
    } else {
        set cmd writeDialog
    }

    set currentTime [clock seconds]

    for {set timeCtr 1} {$timeCtr <= $duration} {incr timeCtr} {
        $cmd  "Transmitted $timeCtr of $duration seconds"
        mpincr count				

        if [getRunningRate $txPortList txRateArray scheduledFramesSent $count] {
            set retCode 1
        }
        if {$retCode == 0 && [getRunningRate $rxPortList rxRateArray framesReceived $count]} {
            set retCode 1
        }

        while {[expr {[clock seconds] - $currentTime}] < 1} {
            update idletasks
            after 20
        }
        set currentTime   [clock seconds]
    }
    debugMsg "txRateArray: [array get txRateArray] "
    debugMsg "rxRateArray: [array get rxRateArray]"

    incr timeCtr -1
    if {$duration != $timeCtr} {
        logMsg "******* Test terminated by user after $timeCtr seconds"
    }

    logMsg "Done transmitting for $duration seconds...\n"

    # destroy the dialog box if it is created
    if {$cmd == "writeDialog"} {
        destroyDialog
    }

    return $retCode
}



##################################################################################
# Procedure: collectRates
#
# Description: Collects the rate during transmission at the following points:
# 1. Half way during tx
# 2. 15% of half duration before the half way point
# 3. 15% of half duration after the half way point
#
# Then get the average of these rates for the QoS counters!!.
#
# Argument(s):
#   AvgRateArray    - array containing the average running rate for tx/rx ports
#	statNameList	- name of the stats that rates will be collected
#   RxRateArray		- array containing the average rx running rate for the corresponding
#					  rateType: rxRate (regular) or qosRate (qos counters)
#   duration        - duration of tx
#	rateType		- the type of the rate will be collected
#
##################################################################################
proc collectRates { TxRxArray AvgRateArray duration {rateType rxRate} { RxRateArray ""} } \
{
	upvar $TxRxArray		txRxArray
	upvar $AvgRateArray     avgRateArray
    upvar $RxRateArray		rxRateArray

	set retCode     $::TCL_OK
    set sampleCount 0
	set numSamples	3
	set count       1
    set txStartTime [clock seconds]
    set runTime		0
    set sampleIndex 0
    set txPortList  [getTxPorts txRxArray]
    set rxPortList  [getRxPorts txRxArray]

	if {$rateType == "qosRate" } {
		set statNameList	[list qualityOfService0 qualityOfService1 qualityOfService2 qualityOfService3	\
							  qualityOfService4 qualityOfService5 qualityOfService6 qualityOfService7]
	} else {
		set statNameList	[list userDefinedStat2] 

	}

    # it may take very long time to get all Qos stats, so we want to start earlier...
	set sampleDuration2 [max [mpexpr $duration/2]  5]
    set sampleDuration1 [mpexpr $sampleDuration2 - round((.15 * $sampleDuration2))]
    set sampleDuration3 [mpexpr $sampleDuration2 + round(ceil((.15 * $sampleDuration2)))]
	debugMsg "***** sampleDuration2 = $sampleDuration2, sampleDuration1 = $sampleDuration1, sampleDuration3 = $sampleDuration3"
    set sampleTimes [list $sampleDuration1 $sampleDuration2 $sampleDuration3 -1] 

	if [createDialog "Transmit Status"] {
		set cmd logMsg
	} else {
		set cmd writeDialog
	}

    set nextSample	[lindex $sampleTimes $sampleIndex]

	set percentToDuration	0
	set sampleCount			0
    while {$runTime <= $duration} {
        set currentTime [clock seconds]
		set percentToDuration	[mpexpr int(ceil(double($runTime)/$duration*100))]

		$cmd  "Transmitted $percentToDuration% of $duration seconds"
      
        if { ($nextSample > 0) && ($runTime >= $nextSample) } {

			set startSample $runTime

			if {[getRunningRate $txPortList txRunningRate scheduledFramesSent $count]} {
                set retCode $::TCL_ERROR
		    }
			
			if {[getRunningRate $rxPortList rxRunningRate $statNameList $count]} {
				set retCode $::TCL_ERROR
			}

			set runTime [expr ([clock seconds] - $txStartTime)]

            if {$runTime > $duration } {
				logMsg "\nWARNING!!!: Sampled rate values maybe incorrect. Increase test duration."
			}

    		incr count				
 			incr sampleIndex
            set nextSample [lindex $sampleTimes $sampleIndex]
			incr sampleCount
		}

        while {[expr {[clock seconds] - $currentTime}] < 1} {
            update idletasks
            after 20
        }
        set runTime [expr ([clock seconds] - $txStartTime)]
    }

	if { $sampleCount < $numSamples } {
		# We don't want to miss the last transmit status
		$cmd  "Transmitted 100% of $duration seconds"
	}

	logMsg "Done transmitting for $duration seconds...\n"

    if {$duration > $runTime} {
        logMsg "******* Test terminated by user after $runTime seconds"
    }


	# destroy the dialog box if it is created
	if {$cmd == "writeDialog"} {
		destroyDialog
	}

	if {!$retCode } {

		# get the average running rate for transmitted frame, received frame & qos rates
		foreach txMap $txPortList {
			scan $txMap	"%d %d %d" tx_c tx_l tx_p
			set total 0
			for {set i 1} {$i <= $sampleCount} {incr i} {
				if {![info exists txRunningRate($tx_c,$tx_l,$tx_p,$i)]} {
					logMsg "Running rate for [getPortId $tx_c $tx_l $tx_p] sample $i not calculated during transmission"
					set retCode $::TCL_ERROR
				} else {
					mpincr total  $txRunningRate($tx_c,$tx_l,$tx_p,$i)
				}    
			}

			if {$rateType == "qosRate" } {
				if [catch {mpexpr $total/$sampleCount} avgRateArray($tx_c,$tx_l,$tx_p)] {
					set avgRateArray($tx_c,$tx_l,$tx_p)   0
				}
			} else {

				if [catch {mpexpr $total/$sampleCount} avgRateArray(TX,$tx_c,$tx_l,$tx_p)] {
					set avgRateArray(TX,$tx_c,$tx_l,$tx_p)   0
				}
			}
			debugMsg "avgRateArray:[array get avgRateArray]"
		}

		if {$rateType == "qosRate" } {
			foreach rxMap $rxPortList {
				scan $rxMap	"%d %d %d" rx_c rx_l rx_p

				for {set priority 0} {$priority < 8} {incr priority} {
					set total 0
    				for {set i 1} {$i <= $sampleCount} {incr i} {
						set counter qualityOfService$priority
						if {![info exists rxRunningRate($rx_c,$rx_l,$rx_p,$counter,$i)]} {
							logMsg "QOS Running rate, priority $priority for [getPortId $rx_c $rx_l $rx_p] sample $i not calculated during transmission."
							set retCode $::TCL_ERROR
						} else {
							mpincr total  $rxRunningRate($rx_c,$rx_l,$rx_p,$counter,$i)
						}
					}
					if [catch {mpexpr round($total/$sampleCount)} rxRateArray($rx_c,$rx_l,$rx_p,$priority)] {
						rxRateArray($rx_c,$rx_l,$rx_p,$priority)   0
					}
				}
			}
		} else {
			foreach rxMap $rxPortList {
				scan $rxMap	"%d %d %d" rx_c rx_l rx_p
				set total 0
				for {set i 1} {$i <= $sampleCount} {incr i} {
					if {![info exists rxRunningRate($rx_c,$rx_l,$rx_p,$i)]} {
						logMsg "Running rate for [getPortId $rx_c $rx_l $rx_p] sample $i not calculated during transmission."
						set retCode $::TCL_ERROR
					} else {
						mpincr total  $rxRunningRate($rx_c,$rx_l,$rx_p,$i)
					}    
				}
				if [catch {mpexpr $total/$sampleCount} avgRateArray(RX,$rx_c,$rx_l,$rx_p)] {
					set avgRateArray(RX,$rx_c,$rx_l,$rx_p)   0
				}
			}
		}
	}

    return $retCode
}
