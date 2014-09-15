##################################################################################
# Version 4.10	$Revision: 167 $
# $Date: 11/15/02 10:18a $
# $Author: Debby $
#
# $Workfile: actions.tcl $ - Generic Actions
#
#   Copyright © 1997 - 2005 by IXIA
#   All Rights Reserved.
#
#	Revision Log:
#	12-30-1998	DS
#
# Description: This file contains common procs used for specific actions,
#              such as startTx, stopTx, etc
#
##################################################################################


########################################################################
# Procedure: clearStatsAndTransmit
#
# This command clears the stat counters, starts capture & starts transmit
#
# Arguments(s):
#   TxRxArray       - array of ports to transmit, ie. one2oneArray
#   duration        - approximate time of transmit
#   staggeredStart  - if set to 'staggeredStart' the transmit will be staggered
#   calcAvgRates    - "yes" if we want to get the rates while transmitting
#   avgRateArray    - array containing the average running rate for tx/rx ports
#
########################################################################
proc clearStatsAndTransmit {TxRxArray duration {staggeredStart notStaggeredStart} {calcAvgRates no} \
                            {AvgRateArray ""} {calcQosRates no} {QosRateArray ""} {calcTxRxRates no} \
							{delay delay}} \
{
    upvar $TxRxArray		txRxArray
	upvar $AvgRateArray		arArray
	upvar $QosRateArray		qosRateArray

    set txPorts [getTxPorts txRxArray]
    
    if {[advancedTestParameter cget -primeDut] == $::true} {
		startTx txRxArray $staggeredStart
        after 2000
		stopTx txRxArray
    }

    set retCode [prepareToTransmit txRxArray]

	if {$retCode == 0} {
		set retCode [startTx txRxArray $staggeredStart]
	}

    if {$retCode == 0 && $delay == "delay"} {     
	    if {$duration > 0} {
	        logMsg "Transmitting frames for $duration seconds"
        } else {
	        logMsg "Transmitting frames for < 1 second"
        }
       
	    if {$calcAvgRates == "yes"} {
            if {$calcQosRates == "yes" && $calcTxRxRates == "no" } {
                upvar $QosRateArray qosAvgRateArray
                set retCode [collectRates txRxArray arArray $duration qosRate qosAvgRateArray ]
            } elseif { $calcQosRates == "yes" && $calcTxRxRates == "yes" } {
                upvar $QosRateArray qrArray
				# Note: We need to get rid of this method when we get rid of cable modem suite              
                set retCode [getRunRatePerSecond txRxArray arArray qrArray $duration]

            } else {
                set retCode [collectRates txRxArray arArray $duration]
            }
        } else {
	        # Wait for all frames to be transmitted, print msg to screen while waiting..
            if [writeWaitForTransmit $duration] {
	            if [stopTx txPorts] {
		            errorMsg "Error stopping Tx on one or more ports."
                    set retCode 1
	            }
                set ::ixStopTest 1
            }
        }
    }

    return $retCode
}


########################################################################
# Procedure: transmitAndCollectRxRatesPerSecond
#
# This command starts transmit and collecting those receive rates we want
#
# Arguments(s):
#   TxRxArray       - array of ports to transmit, ie. one2oneArray
#	RateArray		- array of rates we want
#	args			- list of stat names we want to get rate of
#   duration        - approximate time of transmit
#   staggeredStart  - if set to 'staggeredStart' the transmit will be staggered
#
########################################################################
proc transmitAndCollectRxRatesPerSecond {TxRxArray RxRateArray rxRateArgs duration {staggeredStart notStaggeredStart}} \
{
    upvar $TxRxArray    txRxArray
	upvar $RxRateArray	rxRateArray
    
    set retCode		[prepareToTransmit txRxArray]

	if {$retCode == 0} {
		set retCode [startTx txRxArray $staggeredStart]
	}

	if {$duration > 0} {
		logMsg "Transmitting frames for $duration seconds"
    } else {
		logMsg "Transmitting frames for < 1 second"
    }
   
	set retCode [collectRxRatesPerSecond txRxArray rxRateArray $rxRateArgs $duration]

	# Wait for all frames to be transmitted, print msg to screen while waiting..
	if [writeWaitForTransmit $duration] {
		if [stopTx txRxArray] {
			errorMsg "Error stopping Tx on one or more ports."
			set retCode 1
		}
	}
   
    return $retCode
}


########################################################################
# Procedure: collectRxRatesPerSecond
#
# This command starts transmit and collecting those receive rates we want
#
# Arguments(s):
#   TxRxArray       - array of ports to transmit
#	RxRateArray		- array of receive rates we want
#	rxRateArgs		- list of stat names we want to get receive rate of
#   duration        - approximate time of transmit
#
########################################################################
proc collectRxRatesPerSecond {TxRxArray RxRateArray rxRateArgs duration} \
{
    upvar $TxRxArray    txRxArray
	upvar $RxRateArray	rxRateArray

    set retCode             0
    set count               0

    set rxPortList  [getRxPorts txRxArray]
 
    if [createDialog "Transmit Status"] {
        set cmd logMsg
    } else {
        set cmd writeDialog
    }

    set timeStart   [clock seconds]
    set getStatTime 0

    for {set timeCtr 1} {$timeCtr <= $duration} {incr timeCtr} {
        $cmd  "Transmitted $timeCtr of $duration seconds"
        mpincr count				
        if [getRunningRate $rxPortList rxRateArray $rxRateArgs $count] {
            set retCode 1
        }
        set getStatTime [mpexpr [clock seconds] - $timeStart]
        if {$getStatTime <= $timeCtr} {
    		after 1000
        }
    }
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


########################################################################
# Procedure: prepareToTransmit
#
# This command stops current transmision, clears the stat counters.
#
# Arguments(s):
#   TxRxArray       - array of ports to transmit, ie. one2oneArray
#
########################################################################
proc prepareToTransmit {TxRxArray} \
{
    upvar $TxRxArray txRxArray
   
    set retCode $::TCL_OK

    set allPorts    [getAllPorts txRxArray]
    set rxPorts     [getRxPorts txRxArray]

	if [stopTx allPorts] {
		errorMsg "Error stopping Tx on one or more ports."
		set retCode $::TCL_ERROR
	}

    if {$retCode == $::TCL_OK} {
        set retCode [checkAllTransmitDone txRxArray]
    }

    set commandList [list resetStatistics clearTimeStamp]
    if [issuePortGroupCommand $commandList allPorts] {
	    errorMsg "Error: Unable to issue port group commands: $commandList"
		set retCode $::TCL_ERROR
	}

    set commandList [list startCapture startLatency]
    if [issuePortGroupCommand $commandList rxPorts] {
	    errorMsg "Error: Unable to issue port group commands: $commandList"
		set retCode $::TCL_ERROR
	}

    return $retCode
}



########################################################################
# Procedure: writeWaitForTransmit
#
# This command writes the transmit msg to a little text box
#
########################################################################
proc writeWaitForTransmit {duration {destroy destroy}} \
{
    set retCode [writeWaitMessage "Transmit Status" "Transmitting" $duration $destroy]

    return $retCode
}


########################################################################
# Procedure: writeWaitForPause
#
# This command writes the pause msg to a little text box
#
########################################################################
proc writeWaitForPause {dialogName duration {destroy destroy}} \
{
    set retCode [writeWaitMessage $dialogName "Pausing" $duration $destroy]

    return $retCode
}



########################################################################
# Procedure: writeWaitMessage
#
# This command writes the msg to a little text box
#
########################################################################
proc writeWaitMessage {dialogName messageType duration {destroy destroy}} \
{
    global ixStopTest

    set retCode 0

    debugMsg "Begin $messageType for $duration seconds...\n"
    
    set messageProc  writeDialog

    if {$duration <= 1 || [createDialog $dialogName]} {
        set messageProc  ixPuts
    }

    set currentTime [clock seconds]
	for {set timeCtr 1} {$timeCtr <= $duration && $ixStopTest != 1} {incr timeCtr} {
    	$messageProc "$messageType $timeCtr of $duration seconds"	

        while {[expr {[clock seconds] - $currentTime}] < 1} {
            update
            after 20
        }
        set currentTime   [clock seconds]
	}

    incr timeCtr -1

    if {$duration != $timeCtr} {
        $messageProc "******* Test terminated by user after $timeCtr seconds"
        set retCode 1
    } else {
        if {$duration < 1 } {
            logMsg "Done after < 1 second.\n"
        } else {
            logMsg "Done after $duration seconds.\n"
        }
    }

    if {$messageProc == "writeDialog" && $destroy == "destroy"} {
        destroyDialog
    }

    return $retCode
}


########################################################################
# Procedure: issuePortGroupCommand
#
# This command builds a port group & issues the specified command, then
# destroys the port group when it's done
#
########################################################################
proc issuePortGroupCommand {command TxRxList {verbose noVerbose} {LastTimestamp ""} {groupId 710} {create create} {destroy destroy}} \
{
	upvar $TxRxList         txRxList
    upvar $LastTimestamp    lastTimestamp

    return [issuePortGroupMethod txRxList lastTimestamp -method setCommand -commandList $command  -groupId $groupId -$verbose -$create -$destroy]
}


########################################################################
# Procedure: getPortGroupObject
#
# This command builds a port group & issues the specified command, then
# destroys the port group when it's done
#
########################################################################
proc getPortGroupObject {object TxRxList {verbose noVerbose} {groupId 710} {create create} {destroy destroy}} \
{
	upvar $TxRxList         txRxList

    set lastTimestamp ""
    return [issuePortGroupMethod txRxList lastTimestamp -method get -commandList $object -groupId $groupId -$verbose   -$create -$destroy]
}


########################################################################
# Procedure: getUsbObject
#
# This command builds a port group & issues the specified command, then
# destroys the port group when it's done
#
########################################################################
proc getUsbObject {object TxRxList {verbose noVerbose} {groupId 710} {create create} {destroy destroy}} \
{
	upvar $TxRxList         txRxList

    set lastTimestamp ""
    return [issuePortGroupMethod txRxList lastTimestamp -method get -commandList $object  -groupId $groupId -$verbose -$create -$destroy]
}


########################################################################
# Procedure: issuePortGroupMethod
#
# This command builds a port group & issues the specified command, then
# destroys the port group when it's done
#
# Argument(s):
#	PortArray	   either list of ports or array of ports
#   args           options include:
#                   -method              <portGroup method to be called>
#                   -commandList         <list of commands to be executed>
#                   -verbose             <turn on messages>
#                   -noVerbose           <turn off messages, default>
#                   -groupId             <groupId, default == 1126>
#                   -create/-noCreate    <default = create, optionally create/don't create portGroup>
#                   -destroy/-noDestroy  <default = destroy, optionally leave portGroup around when done>
#                   -duration            <scheduled transmit duration, default == 0>        
#
########################################################################
proc issuePortGroupMethod { PortArray LastTimestamp args } \
{
	upvar $PortArray        portArray
    upvar $LastTimestamp    lastTimestamp

	set retCode	0

    # default some vars here...
    set method          setCommand
    set commandList     [list]
    set verbose         $::true
    set groupId         710
    set create          $::true
    set destroy         $::true
    set duration        0
    set command         none
    set finalCommandList [list]

    foreach arg [join $args] {
        # just go ahead & remove the '-', makes things easier
        set dash [expr [regsub -all {^-} $arg "" arg]?"-":""]

        if { $arg == "commandList" } {
            set $command $arg
            set command  commandList
            continue
        } else {
            if { $command == "commandList" } {
                if { $dash == "" && [lsearch $finalCommandList $arg] <= 0 } {
                    lappend finalCommandList  $arg
                    set command  commandList
                    set $command $finalCommandList
                    continue
                } else {   
                    set $command $finalCommandList
                    set command  none
                }
            } 
        }

        switch $command {
            method -
            groupId -
            duration -
            noDestroy {
                set $command $arg
                set command  none
            }

            none {
                switch $arg {
                    method {
                        set command method
                    }
                    duration {
                        set command duration
                    }
                    groupId {
                        set command groupId
                    }
                    verbose {
                        set verbose $::true
                    }
                    noVerbose -
                    noverbose {
                        set verbose $::false
                    }
                    create {
                        set create $::true
                    }
                    nocreate -
                    noCreate {
                        set create $::false
                    }
                    destroy {
                        set destroy $::true
                    }
                    nodestroy -
                    noDestroy {
                        set destroy $::false
                    }
                    default {
                        errorMsg "Parameter not supported: $dash$arg"
                        set retCode $::TCL_ERROR
                    }
                }
            }
            default {
                errorMsg "Error in parameters: $args"
                set retCode $::TCL_ERROR
            }
        }
    }
    #logMsg "\n method:$method, verbose:$verbose, groupId:$groupId, duration:$duration, \
    #        create:$create, destroy:$destroy, commandList:$commandList\n"


    if [llength $portArray] {
        set verbose "-$verbose"
        if {$create == $::true} {
            debugMsg "issuePortGroupCommand: create port group $groupId"
            if [portGroup create $groupId] {
                errorMsg $verbose "Error creating port group $groupId"
                set retCode $::TCL_ERROR
            }
        }

        if {$retCode == 0} {
            set tx_l 0
            set tx_p 0
	        foreach tx_port $portArray {
		        scan $tx_port "%d %d %d" tx_c tx_l tx_p
                if [portGroup add $groupId $tx_c $tx_l $tx_p] {
                    errorMsg $verbose "Error adding [getPortId $tx_c $tx_l $tx_p] to Tx Port Group."
                    set retCode $::TCL_ERROR
                }
	        }

            foreach command $commandList {
                switch $method {
                    setCommand {
                    debugMsg "issuePortGroupCommand: method:$method, Command -$command, portArray -$portArray"
	                    if {[portGroup $method $groupId $command]} {
		                    errorMsg $verbose "Error setting command $command for port group $groupId"
		                    set retCode $::TCL_ERROR
	                    }
                
                        set lastTimestamp   [portGroup cget -lastTimestamp]
                    }
                    get {
	                    if {[portGroup $method $groupId $command]} {
		                    errorMsg $verbose "Error setting $method $command for port group $groupId"
		                    set retCode $::TCL_ERROR
	                    }
                    }
                    clearScheduledTransmitTime {
                        if {[portGroup $method $groupId]} {
		                    errorMsg $verbose "Error $method for port group $groupId"
		                    set retCode $::TCL_ERROR
	                    }
                    }

                    setScheduledTransmitTime {
                        if {[portGroup $method $groupId $duration]} {
		                    errorMsg $verbose "Error $method for port group $groupId"
		                    set retCode $::TCL_ERROR
	                    }
                    }
                }
            }
        }

        if {$destroy == $::true} {
            debugMsg "issuePortGroupCommand: destroy port group $groupId"
            if [portGroup destroy $groupId] {
                errorMsg $verbose "Error destroying port group $groupId"
                set retCode $::TCL_ERROR
            }
        }
    } else {
        set retCode $::TCL_ERROR
    }

	return $retCode
}


########################################################################
# Procedure: startTx
#
# This command arms each Tx port & then sends out a pulse to the master
# to begin transmitting
#
# Arguments:
#   TxRxArray       - either array or list containing ports to start
#                     transmit on
#
########################################################################
proc startTx {TxRxArray {staggeredStart notStaggeredStart} {FirstTimestamp ""} {groupId 710} {create create} {destroy destroy}} \
{
    global ixgFirstTimeStamp

	upvar $TxRxArray        txRxArray
    upvar $FirstTimestamp   firstTimestamp

	set retCode	        $::TCL_OK
    set firstTimestamp  0

    set txRxList    [getTxPorts txRxArray]

    if {$staggeredStart == "notStaggeredStart" || $staggeredStart == "false"} {
        set command  startTransmit
    } else {
        set command staggeredStartTransmit
    }

    if [issuePortGroupCommand $command txRxList noVerbose firstTimestamp $groupId $create $destroy] {
	    errorMsg "Error starting Transmission for port group"
		set retCode $::TCL_ERROR
	}

    set ixgFirstTimeStamp   $firstTimestamp

	return $retCode
}


########################################################################
# Procedure: startStaggeredTx
#
# This command arms each Tx port & then sends out a pulse to the master
# to begin transmitting
#
# Arguments:
#   TxRxArray       - either array or list containing ports to start
#                     transmit on
#
########################################################################
proc startStaggeredTx {TxRxArray {groupId 710} {create create} {destroy destroy}} \
{
	upvar $TxRxArray        txRxArray

	return [startTx txRxArray staggeredStart firstTimeStamp $groupId $create $destroy]
}


########################################################################
# Procedure: stopTx
#
# This command arms each Tx port & then sends out a pulse to the master
# to stop transmitting
#
# Arguments:
#   TxRxArray       - either array or list containing ports to stop
#                     transmit on
#
########################################################################
proc stopTx {TxRxArray {groupId 710} {create create} {destroy destroy}} \
{
	upvar $TxRxArray txRxArray

	set retCode	$::TCL_OK

    set txRxList    [getTxPorts txRxArray]
    if [issuePortGroupCommand stopTransmit txRxList noVerbose lastTimestamp $groupId $create $destroy] {
	    errorMsg "Error stopping Transmission on port group"
		set retCode $::TCL_ERROR
	}

	return $retCode
}


########################################################################
# Procedure: startPortTx
#
# This command starts Tx on a single port; it will also stop transmit &
# zero stats on this port before transmitting.
#
# Arguments(s):
#	chassis
#	lm
#	port
#
# Return:
#	0 if OK, 1 if port not configured
#
########################################################################
proc startPortTx {chassis lm port {FirstTimestamp ""} {groupId 710} {create create} {destroy destroy}} \
{
    upvar $FirstTimestamp   firstTimestamp
	set retCode	$::TCL_OK

    set portList    [list [list $chassis $lm $port]]
    if [issuePortGroupCommand startTransmit portList noVerbose firstTimestamp $groupId $create $destroy] {
	    errorMsg "Error starting Transmission on port $chassis,$lm,$port"
		set retCode $::TCL_ERROR
	}
    if [info exists firstTimestamp] {
        debugMsg "startPortTx on port $chassis,$lm,$port: firstTimestamp = $firstTimestamp"
	}
	return $retCode
}


########################################################################
# Procedure: stopPortTx
#
# This command stops Tx on a single port
#
# Arguments(s):
#	chassis
#	lm
#	port
#
# Return:
#	0 if OK, 1 if port not configured
#
########################################################################
proc stopPortTx {chassis lm port {groupId 710} {create create} {destroy destroy}} \
{
	set retCode	$::TCL_OK

    set portList    [list [list $chassis $lm $port]]
    if [issuePortGroupCommand stopTransmit portList noVerbose lastTimestamp $groupId $create $destroy] {
	    errorMsg "Error stopping Transmission on port $chassis,$lm,$port"
		set retCode $::TCL_ERROR
	}
	return $retCode
}


########################################################################
# Procedure: startCapture
#
# This command turns on capture for each Rx port
#
# Arguments:
#   TxRxArray       - either array or list containing ports to start
#                     capture on
#
########################################################################
proc startCapture {TxRxArray {groupId 710} {create create} {destroy destroy}} \
{
	upvar $TxRxArray txRxArray

	set retCode 0

    set txRxList    [getRxPorts txRxArray]
    if [issuePortGroupCommand startCapture txRxList noVerbose lastTimestamp $groupId $create $destroy] {
	    errorMsg "Error starting Capture for port group"
		set retCode 1
	}

	return $retCode
}


########################################################################
# Procedure: stopCapture
#
# This command stops capture for each Rx port
#
# Arguments:
#   TxRxArray       - either array or list containing ports to stop
#                     capture on
#
########################################################################
proc stopCapture {TxRxArray {groupId 710} {create create} {destroy destroy}} \
{
	upvar $TxRxArray txRxArray

	set retCode 0

    set txRxList    [getRxPorts txRxArray]
    if [issuePortGroupCommand stopCapture txRxList noVerbose lastTimestamp $groupId $create $destroy] {
	    errorMsg "Error stopping Capture for port group"
		set retCode 1
	}

	return $retCode
}


########################################################################
# Procedure: startPortCapture
#
# This command starts capture on a single port;
#
# Arguments(s):
#	chassis
#	lm
#	port
#
# Return:
#	0 if OK, 1 if port not configured
#
########################################################################
proc startPortCapture {chassis lm port {groupId 710} {create create} {destroy destroy}} \
{
	set retCode	0

    set portList    [list [list $chassis $lm $port]]
    if [issuePortGroupCommand startCapture portList noVerbose lastTimestamp $groupId $create $destroy] {
	    errorMsg "Error starting Capture on port $chassis,$lm,$port"
		set retCode 1
	}

	return $retCode
}


########################################################################
# Procedure: stopPortCapture
#
# This command stops capture on a single port
#
# Arguments(s):
#	chassis
#	lm
#	port
#
# Return:
#	1 if OK, 0 if port not configured
#
########################################################################
proc stopPortCapture {chassis lm port {groupId 710} {create create} {destroy destroy}} \
{
	set retCode	0

    set portList    [list [list $chassis $lm $port]]
    if [issuePortGroupCommand stopCapture portList noVerbose lastTimestamp $groupId $create $destroy] {
	    errorMsg "Error stopping Capture on port $chassis,$lm,$port"
		set retCode $::TCL_ERROR
	}

	return $retCode
}


########################################################################
# Procedure: startPacketGroups
#
# This command arms each Rx port & then sends out a pulse to the master
# to initiate packetGroup stats
#
# Arguments:
#   TxRxArray       - either array or list containing ports to start
#                     capturing latency stats on
#
########################################################################
proc startPacketGroups {TxRxArray {groupId 710} {create create} {destroy destroy}} \
{
	upvar $TxRxArray txRxArray

	set retCode $::TCL_OK

    set txRxList    [getRxPorts txRxArray]

    if [issuePortGroupCommand startLatency txRxList noVerbose lastTimestamp $groupId $create $destroy] {
	    errorMsg "Error starting packetGroup stats for port group"
		set retCode $::TCL_ERROR
	}

	return $retCode
}


########################################################################
# Procedure: stopPacketGroups
#
# This command arms each Rx port & then sends out a pulse to the master
# to stop packetGroup stats
#
# Arguments:
#   TxRxArray       - either array or list containing ports to stop
#                     capturing latency stats on
#
########################################################################
proc stopPacketGroups {TxRxArray {groupId 710} {create create} {destroy destroy}} \
{
	upvar $TxRxArray txRxArray

	set retCode $::TCL_OK

    set txRxList    [getRxPorts txRxArray]
    if [issuePortGroupCommand stopLatency txRxList noVerbose lastTimestamp $groupId $create $destroy] {
	    errorMsg "Error stopping packetGroup stats for port group"
		set retCode $::TCL_ERROR
	}

	return $retCode
}


########################################################################
# Procedure: startPortPacketGroups
#
# This command starts packetGroup stats on a single port
#
# Arguments(s):
#	chassis
#	lm
#	port
#
# Return:
#	0 if OK, 1 if port not configured
#
########################################################################
proc startPortPacketGroups {chassis lm port {groupId 710} {create create} {destroy destroy}} \
{
	set retCode $::TCL_OK

    set portList    [list [list $chassis $lm $port]]
    if [issuePortGroupCommand startLatency portList noVerbose lastTimestamp $groupId $create $destroy] {
	    errorMsg "Error starting packetGroup stats on port $chassis,$lm,$port"
		set retCode $::TCL_ERROR
	}

	return $retCode
}

########################################################################
# Procedure: stopPortPacketGroups
#
# This command stops packetGroup stats on a single port
#
# Arguments(s):
#	chassis
#	lm
#	port
#
# Return:
#	0 if OK, 1 if port not configured
#
########################################################################
proc stopPortPacketGroups {chassis lm port {groupId 710} {create create} {destroy destroy}} \
{
	set retCode $::TCL_OK

    set portList    [list [list $chassis $lm $port]]
    if [issuePortGroupCommand stopLatency portList noVerbose lastTimestamp $groupId $create $destroy] {
	    errorMsg "Error stopping packetGroup stats on port $chassis,$lm,$port"
		set retCode $::TCL_ERROR
	}
	return $retCode
}

########################################################################
# Procedure: clearPacketGroups
#
# This command arms each Rx port & then sends out a pulse to the master
# to clear packetGroup stats
#
# Arguments:
#   TxRxArray       - either array or list containing ports to stop
#                     capturing latency stats on
#
########################################################################
proc clearPacketGroups {TxRxArray {groupId 710} {create create} {destroy destroy}} \
{
	upvar $TxRxArray txRxArray

	set retCode $::TCL_OK

    set txRxList    [getRxPorts txRxArray]
    if [issuePortGroupCommand clearLatency txRxList noVerbose lastTimestamp $groupId $create $destroy] {
	    errorMsg "Error clearing packetGroup stats for port group"
		set retCode $::TCL_ERROR
	}

	return $retCode
}

########################################################################
# Procedure: clearPortPacketGroups
#
# This command clears packetGroup stats on a single port
#
# Arguments(s):
#	chassis
#	lm
#	port
#
# Return:
#	0 if OK, 1 if port not configured
#
########################################################################
proc clearPortPacketGroups {chassis lm port {groupId 710} {create create} {destroy destroy}} \
{
	set retCode $::TCL_OK

    set portList    [list [list $chassis $lm $port]]
    if [issuePortGroupCommand clearLatency portList noVerbose lastTimestamp $groupId $create $destroy] {
	    errorMsg "Error clearing packetGroup stats on port $chassis,$lm,$port"
		set retCode $::TCL_ERROR
	}
	return $retCode
}


########################################################################
# Procedure: startCollisions
#
# This command arms each Rx port & then sends out a pulse to the master
# to initiate collisions
#
# Arguments:
#   TxRxArray	- either array or list containing ports to start collisions
#
########################################################################
proc startCollisions {TxRxArray {groupId 710} {create create} {destroy destroy}} \
{
	upvar $TxRxArray txRxArray

	set retCode	0

    set rxPortList    [getRxPorts txRxArray]

    if [issuePortGroupCommand collisionStart rxPortList noVerbose lastTimestamp $groupId $create $destroy] {
	    errorMsg "Error starting collisions stats for port group"
		set retCode 1
	}

	return $retCode
}


########################################################################
# Procedure: stopCollisions
#
# This command arms each Rx port & then sends out a pulse to the master
# to stop collisions
#
# Arguments:
#   TxRxArray       - either array or list containing ports to stop collisions
#
########################################################################
proc stopCollisions {TxRxArray {groupId 710} {create create} {destroy destroy}} \
{
	upvar $TxRxArray txRxArray

	set retCode	0

    set rxPortList    [getRxPorts txRxArray]
    if [issuePortGroupCommand collisionStop rxPortList noVerbose lastTimestamp $groupId $create $destroy] {
	    errorMsg "Error stopping collisions stats for port group"
		set retCode 1
	}

	return $retCode
}


########################################################################
# Procedure: startPortCollisions
#
# This command starts collisions on a single port
#
# Arguments(s):
#	c	- chassis
#	l	- card
#	p	- port
#
# Return:
#	0 if OK, 1 if port not configured
#
########################################################################
proc startPortCollisions {c l p {groupId 710} {create create} {destroy destroy}} \
{
	set retCode	0

    set portList    [list [list $c $l $p]]
	
	if [startCollisions portList $groupId $create $destroy] {
		errorMsg "Error starting collisions stats on port [getPortId $c $l $p]"
		set retCode 1
	}

	return $retCode
}

########################################################################
# Procedure: stopPortCollisions
#
# This command stops collisions on a single port
#
# Arguments(s):
#	c	- chassis
#	l	- card
#	p	- port
#
# Return:
#	0 if OK, 1 if port not configured
#
########################################################################
proc stopPortCollisions {c l p {groupId 710} {create create} {destroy destroy}} \
{
	set retCode	0

    set portList    [list [list $c $l $p]]
    if [stopCollisions portList $groupId $create $destroy] {
	    errorMsg "Error stopping collisions stats on port [getPortId $c $l $p]"
		set retCode 1
	}
	return $retCode
}


########################################################################
# Procedure: zeroStats
#
# This command zeros all stats
#
# Arguments:
#   TxRxArray       - either array or list containing ports to zero
#                     stats on
#
########################################################################
proc zeroStats {TxRxArray {groupId 710} {create create} {destroy destroy}} \
{
	upvar $TxRxArray txRxArray

	set retCode $::TCL_OK

	logMsg "Resetting Statistics ..."

    set txRxList    [getAllPorts txRxArray]
    if [issuePortGroupCommand resetStatistics txRxList noVerbose lastTimestamp $groupId $create $destroy] {
	    errorMsg "Error resetting stats for port group"
		set retCode $::TCL_ERROR
	}

	return $retCode
}


########################################################################
# Procedure: zeroPortStats
#
# This command zeros all stats on this port
#
# Argument(s):
#	chassis		chassis ID
#	lm			Load Module number
#	port		port number
#
########################################################################
proc zeroPortStats {chassis lm port {groupId 710} {create create} {destroy destroy}} \
{
	set retCode $::TCL_OK

    set portList    [list [list $chassis $lm $port]]
    if [issuePortGroupCommand resetStatistics portList noVerbose lastTimestamp $groupId $create $destroy] {
	    errorMsg "Error resetting stats on port $chassis,$lm,$port"
		set retCode $::TCL_ERROR
	}

	return $retCode
}


########################################################################
# Procedure: clearPerStreamTxStats
#
# This command zeros all stream Tx stats on all ports
#
# Arguments:
#   TxRxArray       - either array or list containing ports to zero
#                     stats on
#
########################################################################
proc clearPerStreamTxStats {TxRxArray {groupId 710} {create create} {destroy destroy}} \
{
	upvar $TxRxArray txRxArray

	set retCode $::TCL_OK

    set txRxList    [getAllPorts txRxArray]
    if [issuePortGroupCommand clearPerStreamTxStats txRxList noVerbose lastTimestamp $groupId $create $destroy] {
	    errorMsg "Error clearing per stream Tx stats for port group"
		set retCode $::TCL_ERROR
	}

	return $retCode
}


########################################################################
# Procedure: clearPerStreamTxPortStats
#
# This command zeros all stream Tx stats on this port
#
# Argument(s):
#	chassis		chassis ID
#	lm			Load Module number
#	port		port number
#
########################################################################
proc clearPerStreamTxPortStats {chassis lm port {groupId 710} {create create} {destroy destroy}} \
{
	set retCode $::TCL_OK

    set portList    [list [list $chassis $lm $port]]
    if [issuePortGroupCommand clearPerStreamTxStats portList noVerbose lastTimestamp $groupId $create $destroy] {
	    errorMsg "Error clearing per stream Tx stats on port $chassis,$lm,$port"
		set retCode $::TCL_ERROR
	}

	return $retCode
}


########################################################################
# Procedure: clearTimeStamp
#
# This command synchronizes the timestamp value among all chassis
#
# Arguments:
#   TxRxArray   - either array or list containing ports to clear/synchronize
#                 time stamp on
#
########################################################################
proc clearTimeStamp {TxRxArray {groupId 710} {create create} {destroy destroy}} \
{
	upvar $TxRxArray txRxArray

	set retCode	0

    set txRxList    [getAllPorts txRxArray]
    if [issuePortGroupCommand clearTimeStamp txRxList noVerbose lastTimestamp $groupId $create $destroy] {
	    errorMsg "Error clearing the time stamp for port group "
		set retCode 1
	}

	return $retCode
}


########################################################################
# Procedure: flushAddressTable
#
# This command writes MII in order to flush the address table. Note:
# this may not work with all DUTs.
#
# Arguments(s):
#   PortMap     one2oneArray, one2manyArray, many2oneArray or many2manyArray
#
# Return:
#	0 if OK, 1 if port not configured
#
########################################################################
proc flushAddressTable { PortMap {checkLink yes}} \
{
	upvar $PortMap portMap

    set retCode $::TCL_OK

    set portList  [getAllPorts portMap]

    changePortLoopback portList $::true verbose
    checkLinkState portMap portsToRemove messageOff
    changePortLoopback portList $::false verbose

	# check the link state of all ports; if down, remove from list
    if {$checkLink == "yes"} {
	    if [checkLinkState portList portsToRemove noMessage] {
            if { [llength $portsToRemove] >0 && [advancedTestParameter cget -removePortOnLinkDown] == "true" } {
                set retCode [removePorts portList $portsToRemove]
            } else {
                set errMsg   "Link down on one or more ports"
                set retCode $::TCL_ERROR
            }
	    }
    }

    return $retCode
}


########################################################################
# Procedure: enableArpResponse
#
# This command gets the MAC & IP addresses for that port, sets up the
# address table and enables the arp response engine for all ports in
# the portlist
#
# Arguments(s):
#   mapType - either oneIpToOneMAC or manyIpToOneMAC
#   PortMap - list or array of ports, ie. ixgSortMap
#
# Return:
#	0 if OK, 1 if port not configured
#
########################################################################
proc enableArpResponse { mapType PortMap {write nowrite}} \
{
    upvar $PortMap   portMap
    set retCode 0

    set portList    [getAllPorts portMap]
    foreach myport $portList {
		scan $myport "%d %d %d" c l p

        if [enablePortArpResponse $mapType $c $l $p nowrite] {
            set retCode 1
        }
    }

    if {$retCode == 0 && $write == "write"} {
        set retCode [writeConfigToHardware portMap]
    }

    return $retCode
}


########################################################################
# Procedure: enablePortArpResponse
#
# This command gets the MAC & IP addresses for that port, sets up the
# address table and enables the arp response engine for the specified port
#
# Arguments(s):
#   mapType - either oneIpToOneMAC or manyIpToOneMAC
#   chassis
#   lm
#   port
#
# Return:
#	0 if OK, 1 if port not configured
#
########################################################################
proc enablePortArpResponse { mapType chassis lm port {write write}} \
{
    set retCode 0

    protocolServer config -enableArpResponse true

    if [protocolServer set $chassis $lm $port] {
        errorMsg "Error setting protocol server on $chassis $lm $port"
        set retCode 1
    }

    if {$write == "write" && $retCode == 0} {
        if [protocolServer write $chassis $lm $port] {
            errorMsg "Error writing protocol server on $chassis $lm $port"
            set retCode 1
        }
    }

    return $retCode
}


########################################################################
# Procedure: disableArpResponse
#
# This command disables the arp response engine for all ports in
# the portlist
#
# Arguments(s):
#   PortMap - list or array of ports, ie. ixgSortMap
#
# Return:
#	0 if OK, 1 if port not configured
#
########################################################################
proc disableArpResponse { PortMap {write nowrite}} \
{
    upvar $PortMap   portMap
    set retCode 0

    set portList    [getAllPorts portMap]
    foreach myport $portList {
		scan $myport "%d %d %d" c l p

        if [disablePortArpResponse $c $l $p nowrite] {
            set retCode 1
        }
    }

    if {$retCode == 0 && $write == "write"} {
        set retCode [writeConfigToHardware portMap]
    }

    return $retCode
}


########################################################################
# Procedure: disablePortArpResponse
#
# This command disables the arp response engine for the specified port
#
# Arguments(s):
#   chassis
#   lm
#   port
#
# Return:
#	0 if OK, 1 if port not configured
#
########################################################################
proc disablePortArpResponse {chassis lm port {write write}} \
{
    set retCode 0

    if [protocolServer get $chassis $lm $port] {
        errorMsg "Error getting protocol server on $chassis $lm $port"
        set retCode 1
    }

    protocolServer config -enableArpResponse false

    if [protocolServer set $chassis $lm $port] {
        errorMsg "Error setting protocol server on $chassis $lm $port"
        set retCode 1
    }

    if {$write == "write" && $retCode == 0} {
        if [protocolServer write $chassis $lm $port] {
            errorMsg "Error writing protocol server on $chassis $lm $port"
            set retCode 1
        }
    }

    return $retCode
}



########################################################################
# Procedure: transmitArpRequest
#
# This command transmits an Arp request via the protocol server.
#
# Arguments:
#   TxRxArray       - either array or list containing ports to transmit
#                     arp request on
#
########################################################################
proc transmitArpRequest {TxRxArray {groupId 710} {create create} {destroy destroy}} \
{
	upvar $TxRxArray        txRxArray

	set retCode	0

    set txRxList    [getTxPorts txRxArray]
    if [issuePortGroupCommand transmitArpRequest txRxList noVerbose lastTimestamp $groupId $create $destroy] {
	    errorMsg "Error transmitting arp request for port group"
		set retCode 1
	}


	return $retCode
}


########################################################################
# Procedure: transmitPortArpRequest
#
# This command transmits an Arp request via the protocol server on a
# single port
#
# Arguments(s):
#	chassis
#	lm
#	port
#
# Return:
#	0 if OK, 1 if port not configured
#
########################################################################
proc transmitPortArpRequest {chassis lm port} \
{
	set retCode	0

    if [arpServer sendArpRequest $chassis $lm $port] {
	    errorMsg "Error transmitting arp request on port $chassis,$lm,$port"
		set retCode 1
	}

	return $retCode
}


########################################################################
# Procedure: clearArpTable
#
# This command clears the arp table via the protocol server.
#
# Arguments:
#   TxRxArray       - either array or list containing ports to clear
#                     arp table on
#
########################################################################
proc clearArpTable {TxRxArray {groupId 710} {create create} {destroy destroy}} \
{
	upvar $TxRxArray        txRxArray

	set retCode	0

    set txRxList    [getTxPorts txRxArray]
    if [issuePortGroupCommand clearArpTable txRxList noVerbose lastTimestamp $groupId $create $destroy] {
	    errorMsg "Error clearing arp for port group"
		set retCode 1
	}

	return $retCode
}


########################################################################
# Procedure: clearPortArpTable
#
# This command clears the arp table on a single port
#
# Arguments(s):
#	chassis
#	lm
#	port
#
# Return:
#	0 if OK, 1 if port not configured
#
########################################################################
proc clearPortArpTable {chassis lm port} \
{
	set retCode	0

    if [arpServer clearArpTable $chassis $lm $port] {
	    errorMsg "Error clearing arp table on port $chassis,$lm,$port"
		set retCode 1
	}

	return $retCode
}



########################################################################
# Procedure: setDataIntegrityMode
#
# This command sets all the RX ports in the list or array to data 
# integrity mode
#
# Arguments(s):
#   TxRxArray       - list or array of RX ports to change
#   write           - write ports to hw as they are modified
#
########################################################################
proc setDataIntegrityMode {TxRxArray {write nowrite}} \
{
    upvar $TxRxArray txRxArray

    return [changePortReceiveMode txRxArray $::portRxDataIntegrity $write]
}

########################################################################
# Procedure: setPacketGroupMode
#
# This command sets all the RX ports in the list or array to packet
# group mode
#
# Arguments(s):
#   TxRxArray       - list or array of RX ports to change
#   write           - write ports to hw as they are modified
#
########################################################################
proc setPacketGroupMode {TxRxArray {write nowrite}} \
{
    upvar $TxRxArray txRxArray

    return [changePortReceiveMode txRxArray $::portPacketGroup $write]
}


########################################################################
# Procedure: setWidePacketGroupMode
#
# This command sets all the RX ports in the list or array to wide packet
# group mode
#
# Arguments(s):
#   TxRxArray       - list or array of RX ports to change
#   write           - write ports to hw as they are modified
#
########################################################################
proc setWidePacketGroupMode {TxRxArray {write nowrite}} \
{
    upvar $TxRxArray txRxArray

    return [changePortReceiveMode txRxArray $::portRxModeWidePacketGroup $write]
}


########################################################################
# Procedure: setCaptureMode
#
# This command sets all the RX ports in the list or array to capture
# mode
#
# Arguments(s):
#   TxRxArray       - list or array of RX ports to change
#   write           - write ports to hw as they are modified
#
########################################################################
proc setCaptureMode {TxRxArray {write nowrite}} \
{
    upvar $TxRxArray txRxArray

    return [changePortReceiveMode txRxArray $::portCapture $write]
}


########################################################################
# Procedure: setTcpRoundTripFlowMode
#
# This command sets all the RX ports in the list or array to round trip
# tcp flow mode
#
# Arguments(s):
#   TxRxArray       - list or array of TX ports to change
#   write           - write ports to hw as they are modified
#
########################################################################
proc setTcpRoundTripFlowMode {TxRxArray {write nowrite}} \
{
    upvar $TxRxArray txRxArray
    global portRxTcpRoundTrip

    return [changePortReceiveMode txRxArray $portRxTcpRoundTrip $write]
}


########################################################################
# Procedure: setPacketStreamMode
#
# This command sets all the TX ports in the list or array to packet
# stream mode
#
# Arguments(s):
#   TxRxArray       - list or array of TX ports to change
#   write           - write ports to hw as they are modified
#
########################################################################
proc setPacketStreamMode {TxRxArray {write nowrite}} \
{
    upvar $TxRxArray txRxArray
    global portTxPacketStreams

    return [changePortTransmitMode txRxArray $portTxPacketStreams $write]
}


########################################################################
# Procedure: setPacketFlowMode
#
# This command sets all the TX ports in the list or array to packet
# flow mode
#
# Arguments(s):
#   TxRxArray       - list or array of TX ports to change
#   write           - write ports to hw as they are modified
#
########################################################################
proc setPacketFlowMode {TxRxArray {write nowrite}} \
{
    upvar $TxRxArray txRxArray

    set retCode $::TCL_OK

    set retCode [changePortTransmitMode txRxArray $::portTxPacketFlows $write]
    switch $retCode "
        $::TCL_OK -
        $::ixTcl_unsupportedFeature {
            set retCode $::TCL_OK
        }
    "
    return $retCode
}


########################################################################
# Procedure: setAdvancedStreamSchedulerMode
#
# This command sets all the TX ports in the list or array to use the
# advanced scheduler
#
# Arguments(s):
#   TxRxArray       - list or array of TX ports to change
#   write           - write ports to hw as they are modified
#
########################################################################
proc setAdvancedStreamSchedulerMode {TxRxArray {write nowrite}} \
{
    upvar $TxRxArray txRxArray

    set retCode $::TCL_OK

    set retCode [changePortTransmitMode txRxArray $::portTxModeAdvancedScheduler $write]
    switch $retCode "
        $::TCL_OK -
        $::ixTcl_unsupportedFeature {
            set retCode $::TCL_OK
        }
    "
    return $retCode
}


########################################################################
# Procedure: setFirstLastTimestampMode
#
# This command sets all the TX ports in the list or array to PG TimeStamp
#
# Arguments(s):
#   TxRxArray       - list or array of TX ports to change
#   write           - write ports to hw as they are modified
#
########################################################################
proc setFirstLastTimestampMode {TxRxArray {write nowrite}} \
{
    upvar $TxRxArray txRxArray
    global portRxFirstTimeStamp

    return [changePortReceiveMode txRxArray $portRxFirstTimeStamp $write]
}

########################################################################
# Procedure: setDataIntegrityMode
#
# This command sets all the TX ports in the list or array to Data integrity
# Mode
#
# Arguments(s):
#   TxRxArray       - list or array of TX ports to change
#   write           - write ports to hw as they are modified
#
########################################################################
proc setDataIntegrityMode {TxRxArray {write nowrite}} \
{
    upvar $TxRxArray txRxArray
    global portRxDataIntegrity

    return [changePortReceiveMode txRxArray $portRxDataIntegrity $write]
}


########################################################################
# Procedure: setSequenceCheckingMode
#
# This command sets all the TX ports in the list or array to Sequence
# Checking Mode
#
# Arguments(s):
#   TxRxArray       - list or array of TX ports to change
#   write           - write ports to hw as they are modified
#
########################################################################
proc setSequenceCheckingMode {TxRxArray {write nowrite}} \
{
    upvar $TxRxArray txRxArray

    return [changePortReceiveMode txRxArray $::portRxSequenceChecking $write]
}


########################################################################
# Procedure: changePortTransmitMode
#
# This command sets all the TX ports in the list or array to the
# specified transmit mode & optionally writes it to hw
#
#   NOTE:  This proc does not affect oc12 cards because transmit modes
#          are not yet supported on those cards.
#
#   NOTE:  For OC48, if the transmit mode is specifed as "packetFlows", 
#          this proc will download the advancedScheduler fpga.
#
# Arguments(s):
#   TxRxArray       - list or array of TX ports to change
#   transmitMode    - either portTxPacketStreams or portTxPacketFlows
#   write           - write ports to hw as they are modified
#
########################################################################
proc changePortTransmitMode {TxRxArray transmitMode {write nowrite}} \
{
    upvar $TxRxArray txRxArray

    set retCode 0
    set infoFlag 1

	foreach tx_port [getTxPorts txRxArray] {
		scan $tx_port "%d %d %d" tx_c tx_l tx_p
        
        # Check if the transmit mode is valid for the port, if it is not valid, just do nothing.
        # Some tests use packetFlow mode, but it is not available for 10100DPM, OC48 and oc192
        # (only packetStream & AdvancedScheduler modes applicable to 10100DPM, OC48 and oc192),
        # in this case we still use packetStream mode.
       
        set retCode [port setTransmitMode $transmitMode $tx_c $tx_l $tx_p]

        switch $retCode {
            0 {
                lappend modList [list $tx_c $tx_l $tx_p]
            }
            1 {
                errorMsg "Error setting port [getPortId $tx_c $tx_l $tx_p]"
                continue
            }
            100 {
                errorMsg "Port [getPortId $tx_c $tx_l $tx_p] is unavailable, check ownership."
                continue
            }
            101 {
                # Note: we won't print out this warning msg temporarily.
                # logMsg "!WARNING:[getTxRxModeString $transmitMode ] not supported on port\
                #        [getPortId $tx_c $tx_l $tx_p], actual transmit rate may vary from configured rate."

                set infoFlag 0
                continue
            }
            200 {
                set retCode 0
                continue
            }
        }
	}

    if {$write == "write" && [info exists modList]} {
        logMsg "Changing TX port mode - downloading FPGA, please wait ..."
        set retCode [writePortsToHardware modList -noProtocolServer]
    } else {
        if {$infoFlag} {
            logMsg "Configuring TX port mode to [getTxRxModeString $transmitMode]"
        }
    }

    return $retCode
}


########################################################################
# Procedure: changePortReceiveMode
#
# This command sets all the RX ports in the list or array to the
# specified Receive mode & optionally writes it to hw
#
# Arguments(s):
#   TxRxArray       - list or array of RX ports to change
#   receiveMode     -
#   write           - write ports to hw as they are modified
#
########################################################################
proc changePortReceiveMode {TxRxArray receiveMode {write nowrite} {verbose yes} } \
{
    upvar $TxRxArray txRxArray
    set retCode 0

    set txRxList    [getRxPorts txRxArray]

    # Checking link state here because if the link is coming up or not quite up yet when we do
    # the port set, then the port gets set all wrong...
    
#    checkLinkState txRxList portsToRemove noMessage

	foreach rx_port $txRxList {
		scan $rx_port "%d %d %d" rx_c rx_l rx_p
		set retCode [port setReceiveMode $receiveMode $rx_c $rx_l $rx_p]

		switch $retCode {
		    0 {
		        lappend modList [list $rx_c $rx_l $rx_p]
		    }
		    1 {
		        errorMsg "Error setting port [getPortId $rx_c $rx_l $rx_p]"
		        continue
		    }
		    100 {
		        errorMsg "Port [getPortId $rx_c $rx_l $rx_p] is unavailable, check ownership."
		        continue
		    }
		    101 {
		        errorMsg "!WARNING:[getTxRxModeString $receiveMode RX] mode not supported on port \
                        [getPortId $rx_c $rx_l $rx_p]"
		        continue
		    }
		    200 {
                set retCode 0
		        continue
		    }
		}
    }

    if {$write == "write" && [info exists modList]} {
        logMsg "Changing RX port mode - downloading FPGA, please wait ..."
        if [writePortsToHardware modList -noProtocolServer] {
            set retCode 1
        }
        set retCode [checkLinkState modList]
    } else {
        if {$verbose == "yes" } {
            logMsg "Configuring RX port mode to [getTxRxModeString $receiveMode RX]"
        }
    }

    return $retCode
}


########################################################################
# Procedure: writeToHardware
#
# This command writes into hardware.
#
# Argument(s):
#	PortArray	            either list of ports or array of ports
#
########################################################################
proc writeToHardware {PortArray args} \
{
    upvar $PortArray portArray
    ixProfile
    set retCode $::TCL_OK

    set portList    [getAllPorts portArray]

    # default some vars here...
    set method  write
    set verbose $::true
    set groupId 1126
    set create  $::true
    set destroy $::true

    # this one is *new*, set to false to avoid stopping the protocol server 
    # when you really just want to write all streams + filters...
    # default is to write protocolServer to support backwards compatibility
    set writeProtocolServer $::true

    set command none
    foreach arg [join $args] {
        # just go ahead & remove the '-', makes things easier
        set dash [expr [regsub -all {^-} $arg "" arg]?"-":""]
        switch $command {
            method -
            groupId -
            noDestroy {
                set $command $arg
                set command  none
            }
            none {
                switch $arg {
                    method {
                        set command method
                    }
                    protocolServer -
                    writeProtocolServer {
                        set writeProtocolServer $::true
                    }
                    noProtocolServer -                       
                    noWriteProtocolServer {
                        set writeProtocolServer $::false
                    }
                    verbose {
                        set verbose $::true
                    }
                    noVerbose -
                    noverbose {
                        set verbose $::false
                    }
                    groupId {
                        set command groupId
                    }
                    create {
                        set create $::true
                    }
                    nocreate -
                    noCreate {
                        set create $::false
                    }
                    destroy {
                        set destroy $::true
                    }
                    nodestroy -
                    noDestroy {
                        set destroy $::false
                    }
                    default {
                        errorMsg "Parameter not supported: $dash$arg"
                        set retCode $::TCL_ERROR
                    }
                }
            }
            default {
                errorMsg "Error in parameters: $args"
                set retCode $::TCL_ERROR
            }
        }
    }
    debugMsg "method:$method, writeProtocolServer:$writeProtocolServer, verbose:$verbose, groupId:$groupId, create:$create, destroy:$destroy"

    if [llength $portList] {
        if {$create} {
            portGroup destroy $groupId
            if [portGroup create $groupId] {
                errorMsg "Error creating port group $groupId"
                set retCode $::TCL_ERROR
            }
        }

        if {$retCode == 0} {
            if [catch {
	            foreach tx_port $portList {
		            scan $tx_port "%d %d %d" tx_c tx_l tx_p

                    if [portGroup add $groupId $tx_c $tx_l $tx_p] {
                        errorMsg "Error adding [getPortId $tx_c $tx_l $tx_p] to port group"
                        set retCode $::TCL_ERROR
                    }
	            }

                if {$verbose} {
                    ixPuts "--->Writing configuration to hardware..."
                }
	            if [portGroup $method $groupId $writeProtocolServer] {
		            errorMsg "Error writing configuration for port group $groupId"
		            set retCode $::TCL_ERROR
	            }

                if {$verbose} {
                    ixPuts "    done writing configuration to hardware..."
                }
            } error] {
                errorMsg $error
                set retCode $::TCL_ERROR
            }
        }
        if {$destroy} {
            if [portGroup destroy $groupId] {
                errorMsg "Error destroying port group"
                set retCode $::TCL_ERROR
            }
        }
    } else {
        errorMsg "No ports in port list/map"
        set retCode $::TCL_ERROR
    }

    ixProfile
    return $retCode
}


########################################################################
# Procedure: writeToHardwareAsChunks
#
# This command writes the ports, including speed, etc into hardware. It
# differs from writeConfigToHardware because this command writes all
# the phy as well as the configuration.
#
# Argument(s):
#	PortArray	   either list of ports or array of ports
#   action         write | writeConfig
#   args           options include:
#                   -verbose             <turn on messages>
#                   -noVerbose           <turn off messages, default>
#                   -writeProtocolServer <stops protocol server & writes 
#                                         all associated objects, default>
#                   -noProtocolServer    <no effect on protocol server,
#                                         doesn't update protocol server objects>
#                   -groupId             <groupId, default == 1126>
#                   -create/-noCreate    <default = create, optionally create/don't create portGroup
#                   -destroy/-noDestroy  <default = destroy, optionally leave portGroup around when done>        
#
########################################################################
proc writeToHardwareAsChunks {PortArray action args} \
{
    upvar $PortArray portArray

##############
##  funky workaround to avoid sending too much crap at once to the server
##############
    set retCode $::TCL_OK

    set chunkSize [advancedTestParameter cget -portWriteChunkSize]
    set allPorts  [getAllPorts portArray]
    set from      0

    if {[llength $allPorts]} {

		if {$chunkSize > 0} {
			set to   [expr $chunkSize - 1]
		} else {
			set to   [llength $allPorts]
		}
		set actionGroup [lrange $allPorts $from $to]
		set myArgs [concat $args "-noVerbose"]
	
		while {$actionGroup != ""} {
			if {$to >= [llength $allPorts]} {
				set myArgs $args
			}
			if [writeToHardware actionGroup [join [list -method $action [join $myArgs]]]] {
				set retCode $::TCL_ERROR
			}
			if {$chunkSize > 0} {
				incr from $chunkSize
				incr to   $chunkSize

				set actionGroup [lrange $allPorts $from $to]
			} else {
				set actionGroup ""
			}
		}
	} else {
        errorMsg "No ports in port list/map"
        set retCode $::TCL_ERROR
    } 	
    
    return $retCode    
}



########################################################################
# Procedure: writePortsToHardware
#
# This command writes the ports, including speed, etc into hardware. It
# differs from writeConfigToHardware because this command writes all
# the phy as well as the configuration.
#
# Argument(s):
#	PortArray	   either list of ports or array of ports
#   args           options include:
#                   -verbose             <turn on messages>
#                   -noVerbose           <turn off messages, default>
#                   -writeProtocolServer <stops protocol server & writes 
#                                         all associated objects, default>
#                   -noProtocolServer    <no effect on protocol server,
#                                         doesn't update protocol server objects>
#                   -groupId             <groupId, default == 1126>
#                   -create/-noCreate    <default = create, optionally create/don't create portGroup
#                   -destroy/-noDestroy  <default = destroy, optionally leave portGroup around when done>        
#
########################################################################
proc writePortsToHardware {PortArray args} \
{
    upvar $PortArray portArray

    return [writeToHardwareAsChunks portArray write [join $args]]
}


########################################################################
# Procedure: writeConfigToHardware
#
# This command writes the port array into hardware
#
# Argument(s):
#	PortArray	   either list of ports or array of ports
#   args           options include:
#                   -verbose             <turn on messages>
#                   -noVerbose           <turn off messages, default>
#                   -writeProtocolServer <stops protocol server & writes 
#                                         all associated objects, default>
#                   -noProtocolServer    <no effect on protocol server,
#                                         doesn't update protocol server objects>
#                   -groupId             <groupId, default == 1126>
#                   -create/-noCreate    <default = create, optionally create/don't create portGroup
#                   -destroy/-noDestroy  <default = destroy, optionally leave portGroup around when done>        
#
########################################################################
proc writeConfigToHardware {PortArray args} \
{
    upvar $PortArray portArray

    return [writeToHardwareAsChunks portArray writeConfig [join $args]]
}


########################################################################
# Procedure: resetSequenceIndex
#
# This command reset the sequence index
#
# Argument(s):
#	PortArray	            either list of ports or array of ports
#
########################################################################
proc resetSequenceIndex {TxRxArray { groupId 710 } {create create} {destroy destroy}} \
{
    upvar $TxRxArray txRxArray

    set retCode $::TCL_OK

    set txRxList [getRxPorts txRxArray]
    if [issuePortGroupCommand resetSequenceIndex txRxList noVerbose firstTimestamp $groupId $create $destroy] {
	    errorMsg "Error reseting the sequence index for port group"
	    set retCode $::TCL_ERROR
    }

    return $retCode
}


########################################################################
# Procedure: resetPortSequenceIndex
#
# This command reset sequence index on a single port.
# 
#
# Arguments(s):
#	chassis
#	lm
#	port
#
# Return:
#	0 if OK, 1 if port not configured
#
########################################################################
proc resetPortSequenceIndex {chassis lm port {FirstTimestamp ""} {groupId 710} {create create} {destroy destroy}} \
{
    upvar $FirstTimestamp   firstTimestamp
    set retCode $::TCL_OK

    set portList    [list [list $chassis $lm $port]]
    if [issuePortGroupCommand resetSequenceIndex portList noVerbose firstTimestamp $groupId $create $destroy] {
	    errorMsg "Error reseting the sequence index on port $chassis,$lm,$port"
	    set retCode $::TCL_ERROR
	}
	return $retCode
}


########################################################################
# Procedure: loadPoePulse
#
# This command loads the poe pulse
#
# Argument(s):
#	PortArray	            either list of ports or array of ports
#
########################################################################
proc loadPoePulse {TxRxArray { groupId 710 } {create create} {destroy destroy}} \
{
    upvar $TxRxArray txRxArray

    set retCode $::TCL_OK

    set txRxList [getAllPorts txRxArray]
    if [issuePortGroupCommand loadPoePulse txRxList noVerbose firstTimestamp $groupId $create $destroy] {
	    errorMsg "Error loading the poe pulse for port group"
	    set retCode $::TCL_ERROR
    }

    return $retCode
}


########################################################################
# Procedure: loadPortPoEPulse
#
# This command loads the poe pulse on a single port.
# 
#
# Arguments(s):
#	chassis
#	lm
#	port
#
# Return:
#	0 if OK, 1 if port not configured
#
########################################################################
proc loadPortPoePulse {chassis lm port} \
{
    set retCode $::TCL_OK

    set portList    [list [list $chassis $lm $port]]
    return [loadPoePulse portList]
}


########################################################################
# Procedure: armPoeTrigger
#
# This command arms the poe trigger
#
# Argument(s):
#	PortArray	            either list of ports or array of ports
#
########################################################################
proc armPoeTrigger {TxRxArray { groupId 710 } {create create} {destroy destroy}} \
{
    upvar $TxRxArray txRxArray

    set retCode $::TCL_OK

    set txRxList [getAllPorts txRxArray]
    if [issuePortGroupCommand armPoeTrigger txRxList noVerbose firstTimestamp $groupId $create $destroy] {
	    errorMsg "Error arming the poe trigger for port group"
	    set retCode $::TCL_ERROR
    }

    return $retCode
}


########################################################################
# Procedure: armPortPoeTrigger
#
# This command arms the poe trigger on a single port.
# 
#
# Arguments(s):
#	chassis
#	lm
#	port
#
# Return:
#	0 if OK, 1 if port not configured
#
########################################################################
proc armPortPoeTrigger {chassis lm port} \
{
    set retCode $::TCL_OK

    set portList    [list [list $chassis $lm $port]]
    return [armPoeTrigger portList]
}


########################################################################
# Procedure: abortPoeArm
#
# This command aborts the poe arm
#
# Argument(s):
#	PortArray	            either list of ports or array of ports
#
########################################################################
proc abortPoeArm {TxRxArray { groupId 710 } {create create} {destroy destroy}} \
{
    upvar $TxRxArray txRxArray

    set retCode $::TCL_OK

    set txRxList [getAllPorts txRxArray]
    if [issuePortGroupCommand abortPoeArm txRxList noVerbose firstTimestamp $groupId $create $destroy] {
	    errorMsg "Error aborting the poe arm for port group"
	    set retCode $::TCL_ERROR
    }

    return $retCode
}


########################################################################
# Procedure: abortPortPoeArm
#
# This command aborts the poe arm on a single port.
# 
#
# Arguments(s):
#	chassis
#	lm
#	port
#
# Return:
#	0 if OK, 1 if port not configured
#
########################################################################
proc abortPortPoeArm {chassis lm port} \
{
    set retCode $::TCL_OK

    set portList    [list [list $chassis $lm $port]]
    return [abortPoeArm portList]
}


########################################################################
# Procedure: resetSequenceIndex
#
# This command reset the sequence index
#
# Argument(s):
#	PortArray	            either list of ports or array of ports
#
########################################################################
proc resetSequenceIndex {TxRxArray { groupId 710 } {create create} {destroy destroy}} \
{
    upvar $TxRxArray txRxArray

    set retCode 0

    set txRxList [getRxPorts txRxArray]
    if [issuePortGroupCommand resetSequenceIndex txRxList noVerbose firstTimestamp $groupId $create $destroy] {
	    errorMsg "Error reseting the sequence index for port group"
	    set retCode 1
    }

    return $retCode
}


########################################################################
# Procedure: resetPortSequenceIndex
#
# This command reset sequence index on a single port.
# 
#
# Arguments(s):
#	chassis
#	lm
#	port
#
# Return:
#	0 if OK, 1 if port not configured
#
########################################################################
proc resetPortSequenceIndex {chassis lm port {FirstTimestamp ""} {groupId 710} {create create} {destroy destroy}} \
{
    upvar $FirstTimestamp   firstTimestamp
	set retCode	0

    set portList    [list [list $chassis $lm $port]]
    if [issuePortGroupCommand resetSequenceIndex portList noVerbose firstTimestamp $groupId $create $destroy] {
	    errorMsg "Error reseting the sequence index on port $chassis,$lm,$port"
		set retCode 1
	}
    if [info exists firstTimestamp] {
        debugMsg "resetPortSequenceIndex on port $chassis,$lm,$port: firstTimestamp = $firstTimestamp"
	}
	return $retCode
}


########################################################################
# Procedure: loadPoEPulse
#
# This command loads the poe pulse
#
# Argument(s):
#	PortArray	            either list of ports or array of ports
#
########################################################################
proc loadPoEPulse {TxRxArray { groupId 710 } {create create} {destroy destroy}} \
{
    upvar $TxRxArray txRxArray

    set retCode $::TCL_OK

    set txRxList [getAllPorts txRxArray]
    if [issuePortGroupCommand loadPoEPulse txRxList noVerbose firstTimestamp $groupId $create $destroy] {
	    errorMsg "Error loading the poe pulse for port group"
	    set retCode $::TCL_ERROR
    }

    return $retCode
}


########################################################################
# Procedure: loadPortPoEPulse
#
# This command loads the poe pulse on a single port.
# 
#
# Arguments(s):
#	chassis
#	lm
#	port
#
# Return:
#	0 if OK, 1 if port not configured
#
########################################################################
proc loadPortPoEPulse {chassis lm port {FirstTimestamp ""} {groupId 710} {create create} {destroy destroy}} \
{
    upvar $FirstTimestamp   firstTimestamp
    set retCode $::TCL_OK

    set portList    [list [list $chassis $lm $port]]
    if [issuePortGroupCommand loadPoEPulse portList noVerbose firstTimestamp $groupId $create $destroy] {
	    errorMsg "Error loading the poe pulse on port $chassis,$lm,$port"
	    set retCode $::TCL_ERROR
	}

	return $retCode
}




########################################################################
# Procedure: restartAutoNegotiation
#
# This command restarts auto negotiation OR restarts PPP negotiation
#
# Argument(s):
#	TxRxArray	    List of ports or array of ports
#
#   Results :       0 : No error found
#                   1 : Error found
#
########################################################################
proc restartAutoNegotiation {TxRxArray {groupId 710} {create create} {destroy destroy}} \
{
    upvar $TxRxArray txRxArray

    set retCode $::TCL_OK

    set txRxList [getAllPorts txRxArray]
    if [issuePortGroupCommand restartAutoNegotiate txRxList noVerbose firstTimestamp $groupId $create $destroy] {
	    errorMsg "Error restarting auto negotiation"
	    set retCode $::TCL_ERROR
    }

    return $retCode
}


########################################################################
# Procedure: rebootLocalCpu
#
# This command reboots the local Cpu on a port list
#
# Argument(s):
#	PortArray	- either list of ports or array of ports
#
# Return:
#	0 if OK, 1 if action failed
#
########################################################################
proc rebootLocalCpu {TxRxArray { groupId 710 } {create create} {destroy destroy}} \
{
    upvar $TxRxArray txRxArray

    set retCode		$::TCL_OK
    set txRxList	[getAllPorts txRxArray]

    foreach portItem $txRxList {
        scan $portItem "%d %d %d" chassId cardId portId

		set retValue [port isValidFeature $chassId $cardId $portId portFeatureLocalCPU]

		switch $retValue {
		    1 {
		        lappend cpuPortList [list $chassId $cardId $portId]
		    }
		    0 {
		        errorMsg "!WARNING: portFeatureLocalCPU is not supported on port [getPortId $chassId $cardId $portId]"
		        continue
		    }
		}
	}

	if {[info exists cpuPortList]} {
		logMsg "Rebooting port cpu, please wait ..."
		if [issuePortGroupCommand rebootLocalCPU cpuPortList noVerbose firstTimestamp $groupId $create $destroy] {
			errorMsg "Error rebooting local cpu for port group"
			set retCode $::TCL_ERROR
		}
	}

    return $retCode
}


########################################################################
# Procedure: rebootPortLocalCpu
#
# This command reboots the local Cpu on a single port.
# 
#
# Arguments(s):
#	chassis
#	lm
#	port
#
# Return:
#	0 if OK, 1 if action failed
#
########################################################################
proc rebootPortLocalCpu {chassis lm port {groupId 710} {create create} {destroy destroy}} \
{
    set retCode $::TCL_OK

    set portList	[list [list $chassis $lm $port]]
    return  [rebootLocalCpu portList $groupId $create $destroy] 
}

########################################################################
# Procedure: startAtmOamTransmit
#
# This command starts the atm oam transmit
#
# Argument(s):
#	PortArray	            either list of ports or array of ports
#
########################################################################
proc startAtmOamTransmit {TxRxArray { groupId 710 } {create create} {destroy destroy}} \
{
    upvar $TxRxArray txRxArray

    set retCode $::TCL_OK

    set txRxList [getAllPorts txRxArray]
    if [issuePortGroupCommand startAtmOamTx txRxList noVerbose firstTimestamp $groupId $create $destroy] {
	    errorMsg "Error starting Atm Oam transmit for port group"
	    set retCode $::TCL_ERROR
    }

    return $retCode
}


########################################################################
# Procedure: startPortAtmOamTransmit
#
# This command starts the atm oam transmit on a single port.
# 
#
# Arguments(s):
#	chassis
#	lm
#	port
#
# Return:
#	0 if OK, 1 if port not configured
#
########################################################################
proc startPortAtmOamTransmit {chassis lm port} \
{
    set retCode $::TCL_OK

    set portList    [list [list $chassis $lm $port]]
    return [startAtmOamTransmit portList]
}


########################################################################
# Procedure: stopAtmOamTransmit
#
# This command starts the atm oam transmit
#
# Argument(s):
#	PortArray	            either list of ports or array of ports
#
########################################################################
proc stopAtmOamTransmit {TxRxArray { groupId 710 } {create create} {destroy destroy}} \
{
    upvar $TxRxArray txRxArray

    set retCode $::TCL_OK

    set txRxList [getAllPorts txRxArray]
    if [issuePortGroupCommand stopAtmOamTx txRxList noVerbose firstTimestamp $groupId $create $destroy] {
	    errorMsg "Error stoping Atm Oam transmit for port group"
	    set retCode $::TCL_ERROR
    }

    return $retCode
}


########################################################################
# Procedure: stopPortAtmOamTransmit
#
# This command starts the atm oam transmit on a single port.
# 
#
# Arguments(s):
#	chassis
#	lm
#	port
#
# Return:
#	0 if OK, 1 if port not configured
#
########################################################################
proc stopPortAtmOamTransmit {chassis lm port} \
{
    set retCode $::TCL_OK

    set portList    [list [list $chassis $lm $port]]
    return [stopAtmOamTransmit portList]
}


########################################################################
# Procedure: setScheduledTransmitTime
#
# This command builds a port group, sets/clears the scheduled transmit
# time and destroys the port group when it's done
#
########################################################################
proc setScheduledTransmitTime {TxRxArray duration {groupId 710}} \
{
    upvar $TxRxArray txRxArray

    set txRxList        [getTxPorts txRxArray]
    set object          [list noCommand]
    set lastTimestamp   ""

    if { $duration } {
        return [issuePortGroupMethod txRxList lastTimestamp -method setScheduledTransmitTime -duration $duration \
                -commandList $object -groupId $groupId -noVerbose  -create -destroy ]
    } else {
        return [issuePortGroupMethod txRxList lastTimestamp -method clearScheduledTransmitTime \
                -commandList $object -groupId $groupId -noVerbose  -create -destroy ]

    }
}

########################################################################
# Procedure: setAutoInstrumentationMode
#
# This command sets all the RX ports in the list or array to packet
# group mode
#
# Arguments(s):
#   TxRxArray       - list or array of RX ports to change
#   write           - write ports to hw as they are modified
#
########################################################################
proc setAutoDetectInstrumentationMode {TxRxArray {write nowrite}} \
{
    upvar $TxRxArray txRxArray

	set retCode $::TCL_OK

    set portList		[getRxPorts txRxArray]
	set validPortList	[list]

	foreach portItem $portList {
		scan $portItem "%d %d %d" chassId cardId portId

		if {[port isValidFeature $chassId $cardId $portId $::portFeatureAutoDetectRx]} {
			if {[port get $chassId $cardId $portId]} {
				errorMsg "Error getting port [getPortId $chassId $cardId $portId]."
				set retCode $::TCL_ERROR
				break
			}

			if {[port isValidFeature $chassId $cardId $portId $::portFeatureRxWidePacketGroups]} {
				set receiveMode	[expr ($::portRxModeWidePacketGroup | $::portRxDataIntegrity | $::portRxSequenceChecking)]
			} else {				
				set receiveMode	[expr ($::portPacketGroup | $::portRxDataIntegrity | $::portRxSequenceChecking)]
			}			
			 
			port config -receiveMode					$receiveMode
			port config -enableAutoDetectInstrumentation $::true

			if {[port set $chassId $cardId $portId]} {
				errorMsg "Error setting port [getPortId $chassId $cardId $portId]."
				set retCode $::TCL_ERROR
				break
			}
			lappend validPortList [list $chassId $cardId $portId]
		}
	}

    if {$write == "write" && [llength $validPortList]} {
        logMsg "Changing RX port mode to [getTxRxModeString $receiveMode RX] - please wait ..."
        if [writePortsToHardware validPortList -noProtocolServer] {
            set retCode 1
        }
        set retCode [checkLinkState validPortList]
    } else {
		logMsg "Configuring RX port mode to [getTxRxModeString $receiveMode RX]"
    }

    return $retCode
}
