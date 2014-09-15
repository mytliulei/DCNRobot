##################################################################################
# Version 4.10   $Revision: 101 $
# $Date: 12/12/02 5:01p $
# $Author: Debby $
#
# $Workfile: highLevelAPI.tcl $
#
#   Copyright © 1997 - 2005 by IXIA
#   All Rights Reserved.
#
#   Revision Log:
#   04-28-1998  HS  Genesis
#
# Description:
#   This file contains high level Tcl API commands.
#
###################################################################################


###############################################################################
# Procedure:    ixInitialize
#
# Description: This procedure loads the IXIA Tcl package, sets the name of log
#              and debug files, and performs any other initializations, if necessary.
#
# Argument(s):
#    chassisList - List of hostnames or IP addresses of chassis in a chain.
#    cableLen    - Optional.  The cable length choice.  If not passed then cable3feet.
#    logfilename - Optional.  The name of the file for the test logs output.
#                  If not passed, then is blank.
#    client      - Optional.  The name of the client.  Defaults to local.  Currently unused
#
# Returns:
#    0 : if no error
#    1 : if error connecting to chassis
#    2 : if version mismatch
#    3 : if chassis timeout occurred
#    4 : if connection interrupted by user
#    5 : if error connecting to Tcl server
###############################################################################
proc ixInitialize {chassisList {cableLen cable3feet} {logfilename ""} {client local}} \
{
    set tclServer [lindex $chassisList 0]
    set retCode [ixProxyConnect $tclServer $chassisList $cableLen $logfilename]

    return $retCode
}


########################################################################################
# Procedure:   ixConnectToChassis
#
# Description: This procedure connects to a list of chassis. An ID number is assigned to
#              the chassis in sequence starting from 1 in the order that the list is passed.
#              The first chassis in the list is assigned as the master chassis.
#
# Argument(s):
#    chassisList - The list of hostnames or IP addresses of chassis in a chain
#    cableLength - Optional.  The length of the cables between the chassis.  If not passed in,
#                  then uses cable3feet.  Note - may be a list of lengths, one for each chassis
#                  in the chassisList.
#
# Returns:
#    0 : if no error
#    1 : if error connecting to chassis
#    2 : if version mismatch, ixTcl_versionMismatch
#    3 : if chassis timeout occurred, ixTcl_chassisTimeout
#    4 : if connection interrupted by user
########################################################################################
proc ixConnectToChassis {chassisList {cableLength cable3feet}} \
{
    return [connectToChassis $chassisList $cableLength]
}


########################################################################################
# Procedure:   ixConnectToTclServer
#
# Description: This procedure connects a unix  
#
# Argument(s):
#    serverName - Ip addr/name of TclServer
#
# Returns:
#    0 - if no error
#    1 - if any error found
########################################################################################
proc ixConnectToTclServer {serverName} \
{
    return [tclServer::connectToTclServer $serverName errMsg]
}


########################################################################################
# Procedure:   ixDisconnectTclServer
#
# Description: This procedure disconnects from the TclServer
#
# Argument(s): 
#    serverName - UNUSED.  Still exists for backwards script support
#
# Returns:
########################################################################################
proc ixDisconnectTclServer {{serverName ""}} \
{
    return [tclServer::disconnectTclServer]
}


########################################################################################
# Procedure:   ixGetChassisID
#
# Description: This procedure gets the chassis ID of the specified chassis name. It is
#              useful when multiple chassis are chained together.
#
# Argument(s):
#    chassisName - chassis name for which ID is to be obtained
#
# Returns:
#    -1 - if error found
#    chasissID - ID number of the chassis
########################################################################################
proc ixGetChassisID {chassisName} \
{
    if [chassis get $chassisName] {
        ixPuts "Error getting parameters for chassis $chassisName"
        return -1
    }
    set chassisID [chassis cget -id]
    return $chassisID
}


########################################################################################
# Procedure:   ixDisconnectFromChassis
#
# Description: Disconnects from input chassis or list of chassis; if no arg given, then
#              will removeAll.
#
# Argument(s):
#    args - list of chassis to del; if empty, removeAll
#
# Returns:
#    0 - if no error
#
########################################################################################
proc ixDisconnectFromChassis {args} \
{
    if {[llength $args] == 0} {
        chassisChain removeAll
    } else {
        foreach host $args {
            chassis del $host
        }
    }
    return 0
}


########################################################################
# Procedure:   ixGlobalSetDefault
#
# Description: This command calls the setDefault for all the stream/port related
#              commands as a form of initialization.
#
# Arguments:   None
#
# Returns:     Nothing
########################################################################
proc ixGlobalSetDefault {} \
{
    globalSetDefault
}


########################################################################################
# Procedure:   ixStartTransmit
#
# Description: Starts transmission on the specific ports
#
# Arguments:
#    PortList - Represented in Chassis Card Port and can be a list also, example {1,1,1 1,1,2}
#
# Returns:
########################################################################################
proc ixStartTransmit {PortList} \
{
    upvar $PortList portList

    return [startTx portList]
}


########################################################################
# Procedure:   ixStartPortTransmit
#
# Description: This command starts Transmit on a single port; it will also stop transmit &
#              zero stats on this port before transmitting.
#
# Arguments(s):
#    chassis
#    lm
#    port
#
# Return:
#    0 if OK, 1 if port not configured
########################################################################
proc ixStartPortTransmit {chassis lm port} \
{
    return [startPortTx $chassis $lm $port]
}


########################################################################
# Procedure:   ixStartStaggeredTransmit
#
# Description: This command arms each Tx port & then sends out a pulse to the master
#              to begin transmitting
#
# Arguments:
#    PortList - Represented in Chassis Card Port and can be a list also, for ex. {1,1,1 1,1,2}
#
# Returns:
########################################################################
proc ixStartStaggeredTransmit {PortList} \
{
    upvar $PortList portList

    return [startStaggeredTx portList]
}


########################################################################################
# Procedure:   ixStopTransmit
#
# Description: Stops transmission on the specific ports
#
# Arguments:
#    PortList - Represented in Chassis Card Port and can be a list also, for ex. {1,1,1 1,1,2}
#
# Returns:
########################################################################################
proc ixStopTransmit {PortList} \
{
    upvar $PortList portList

    return [stopTx portList]
}


########################################################################
# Procedure:   ixStopPortTransmit
#
# Description: This command stops Tx on a single port
#
# Arguments(s):
#    chassis
#    lm
#    port
#
# Return:      0 if OK, 1 if port not configured
########################################################################
proc ixStopPortTransmit {chassis lm port} \
{
    return [stopPortTx $chassis $lm $port]
}


########################################################################
# Procedure:   ixStartCapture
#
# Description: This command turns on capture for each Rx port
#
# Arguments:
#    PortList - Represented in Chassis Card Port and can be a list also for ex. {1,1,1 1,1,2}
#
# Returns:
########################################################################
proc ixStartCapture {PortList} \
{
    upvar $PortList portList

    return [startCapture portList]
}


########################################################################
# Procedure: ixStartPortCapture
#
# This command starts capture on a single port;
#
# Arguments(s):
#    chassis
#    lm
#    port
#
# Return:
#    0 if OK, 1 if port not configured
#
########################################################################
proc ixStartPortCapture {chassis lm port} \
{
    return [startPortCapture $chassis $lm $port]
}


########################################################################
# Procedure: ixStopCapture
#
# This command stops capture for each Rx port
#
# Arguments:
#      PortList  - Represented in Chassis Card Port and can be a list also
#                  for ex. {1,1,1 1,1,2}
#
########################################################################
proc ixStopCapture {PortList} \
{
    upvar $PortList portList

    return [stopCapture portList]
}


########################################################################
# Procedure: ixStopPortCapture
#
# This command stops capture on a single port
#
# Arguments(s):
#    chassis
#    lm
#    port
#
# Return:
#    1 if OK, 0 if port not configured
#
########################################################################
proc ixStopPortCapture {chassis lm port {groupId 710} {create create} {destroy destroy}} \
{
    return [stopPortCapture $chassis $lm $port]
}


########################################################################################
#  Procedure  :  ixClearStats
#
#  Description:  Clear statistics counters on the specific ports
#
#  Arguments  :
#      ports     - Represented in Chassis Card Port and can be a list also
#                  for ex. {1,1,1 1,1,2}
#
########################################################################################
proc ixClearStats {PortList} \
{
    upvar $PortList portList

    return [zeroStats portList]
}


########################################################################
# Procedure: ixClearPortStats
#
# This command zeros all stats & stops the specified port if transmitting
#
# Argument(s):
#    chassis     chassis ID
#    lm          Load Module number
#    port        port number
#
########################################################################
proc ixClearPortStats {chassis lm port} \
{
    return [zeroPortStats $chassis $lm $port]
}

########################################################################################
#  Procedure  :  ixClearPerStreamTxStats
#
#  Description:  Clear per stream Tx statistics counters on the portList
#
#  Arguments  :
#      PortList     - Represented in Chassis Card Port and can be a list also
#                  for ex. {1,1,1 1,1,2}
#
########################################################################################
proc ixClearPerStreamTxStats {PortList} \
{
    upvar $PortList portList

    return [clearPerStreamTxStats portList]
}


########################################################################
# Procedure: ixClearPerStreamTxPortStats
#
# This command zeros all stream Tx stats on this port
#
# Argument(s):
#    chassis     chassis ID
#    lm          Load Module number
#    port        port number
#
########################################################################
proc ixClearPerStreamTxPortStats {chassis lm port} \
{
    return [clearPerStreamTxPortStats $chassis $lm $port]
}


########################################################################################
# Procedure: ixRequestStats
#
# Description: This command combines the statGroup w/a portList or map array to request 
#              stats for a list of ports. statList command must be used to retrieve stats
#              after call completion.
#
# Arguments:
#    TxRxArray - either list of ports or array of ports
#                     
# Returns:
#       TCL_OK or TCL_ERROR
#
########################################################################################
proc ixRequestStats {TxRxArray} \
{
    upvar $TxRxArray   txRxArray

    return [requestStats txRxArray]
}


########################################################################
# Procedure: ixClearTimeStamp
#
# This command synchronizes the timestamp value among all chassis
#
# Arguments:
#      PortList  - Represented in Chassis Card Port and can be a list also
#                  for ex. {1,1,1 1,1,2}
#
########################################################################
proc ixClearTimeStamp {PortList} \
{
    upvar $PortList portList

    return [clearTimeStamp portList]
}


########################################################################
# Procedure: ixStartPacketGroups
#
# This command arms each Rx port & then sends out a pulse to the master
# to initiate packetGroup stats
#
# Arguments:
#      PortList  - Represented in Chassis Card Port and can be a list also
#                  for ex. {1,1,1 1,1,2}
#
########################################################################
proc ixStartPacketGroups {PortList} \
{
    upvar $PortList portList

    return [startPacketGroups portList]
}


########################################################################
# Procedure: ixStartPortPacketGroups
#
# This command starts packetGroup stats on a single port
#
# Arguments(s):
#    chassis
#    lm
#    port
#
# Return:
#    0 if OK, 1 if port not configured
#
########################################################################
proc ixStartPortPacketGroups {chassis lm port} \
{
    return [startPortPacketGroups $chassis $lm $port]
}


########################################################################
# Procedure: ixStopPacketGroups
#
# This command arms each Rx port & then sends out a pulse to the master
# to stop packetGroup stats
#
# Arguments:
#      PortList  - Represented in Chassis Card Port and can be a list also
#                  for ex. {1,1,1 1,1,2}
#
########################################################################
proc ixStopPacketGroups {PortList} \
{
    upvar $PortList portList

    return [stopPacketGroups portList]
}


########################################################################
# Procedure: ixClearPacketGroups
#
# This command arms each Rx port & then sends out a pulse to the master
# to clear packetGroup stats
#
# Arguments:
#      PortList  - Represented in Chassis Card Port and can be a list also
#                  for ex. {1,1,1 1,1,2}
#
########################################################################
proc ixClearPacketGroups {PortList} \
{
    upvar $PortList portList

    return [clearPacketGroups portList]
}


########################################################################
# Procedure: ixClearPortPacketGroups
#
# This command clears packetGroup stats on a single port
#
# Arguments(s):
#    chassis
#    lm
#    port
#
# Return:
#    0 if OK, 1 if port not configured
#
########################################################################
proc ixClearPortPacketGroups {chassis lm port} \
{
    return [clearPortPacketGroups $chassis $lm $port]
}

########################################################################
# Procedure:   ixSetScheduledTransmitTime
#
# Description: This command sets scheduled transmit time on given port list
#
# Arguments:
#    PortList - List of ports; for ex. {{1 1 1} {1 1 2}}
#
# Returns:
########################################################################
proc ixSetScheduledTransmitTime {PortList duration } \
{
    upvar $PortList portList

    return [setScheduledTransmitTime portList $duration]
}

########################################################################
# Procedure:   ixClearScheduledTransmitTime
#
# Description: This command clears/resets scheduled transmit time on given 
#              port list
#
# Arguments:
#    PortList - List of ports; for ex. {{1 1 1} {1 1 2}}
#
# Returns:
########################################################################
proc ixClearScheduledTransmitTime {PortList} \
{
    upvar $PortList portList

    set duration 0
    return [setScheduledTransmitTime portList $duration]
}

########################################################################
# Procedure: ixStopPortPacketGroups
#
# This command stops packetGroup stats on a single port
#
# Arguments(s):
#    chassis
#    lm
#    port
#
# Return:
#    0 if OK, 1 if port not configured
#
########################################################################
proc ixStopPortPacketGroups {chassis lm port} \
{
    return [stopPortPacketGroups $chassis $lm $port]
}


########################################################################
# Procedure: ixStartCollisions
#
# This command arms each Rx port & then sends out a pulse to the master
# to initiate collisions
#
# Arguments:
#      PortList  - Represented in Chassis Card Port and can be a list also
#                  for ex. {1,1,1 1,1,2}
#
########################################################################
proc ixStartCollisions {PortList} \
{
    upvar $PortList portList

    return [startCollisions portList]
}


########################################################################
# Procedure: ixStartPortCollisions
#
# This command starts packetGroup stats on a single port
#
# Arguments(s):
#    chassis
#    lm
#    port
#
# Return:
#    0 if OK, 1 if port not configured
#
########################################################################
proc ixStartPortCollisions {chassis lm port} \
{
    return [startPortCollisions $chassis $lm $port]
}


########################################################################
# Procedure: ixStopCollisions
#
# This command arms each Rx port & then sends out a pulse to the master
# to stop collisions
#
# Arguments:
#      PortList  - Represented in Chassis Card Port and can be a list also
#                  for ex. {1,1,1 1,1,2}
#
########################################################################
proc ixStopCollisions {PortList} \
{
    upvar $PortList portList

    return [stopCollisions portList]
}


########################################################################
# Procedure: ixStopPortCollisions
#
# This command stops collisions on a single port
#
# Arguments(s):
#    chassis
#    lm
#    port
#
# Return:
#    0 if OK, 1 if port not configured
#
########################################################################
proc ixStopPortCollisions {chassis lm port} \
{
    return [stopPortCollisions $chassis $lm $port]
}


########################################################################
# Procedure: ixLoadPoePulse
#
# This command loads the poe pulse
#
# Argument(s):
#	PortArray	            either list of ports or array of ports
#
########################################################################
proc ixLoadPoePulse {PortList} \
{
    upvar $PortList portList

    return [loadPoePulse portList]
}


########################################################################
# Procedure: ixLoadPortPoePulse
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
proc ixLoadPortPoePulse {chassis lm port} \
{
    return [loadPortPoePulse $chassis $lm $port]
}


########################################################################
# Procedure: ixArmPoeTrigger
#
# This command arms the poe trigger
#
# Argument(s):
#	PortArray	            either list of ports or array of ports
#
########################################################################
proc ixArmPoeTrigger {PortList} \
{
    upvar $PortList portList

    return [armPoeTrigger portList]
}


########################################################################
# Procedure: ixArmPortPoeTrigger
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
proc ixArmPortPoeTrigger {chassis lm port} \
{
    return [armPortPoeTrigger $chassis $lm $port]
}


########################################################################
# Procedure: ixAbortPoeArm
#
# This command aborts the poe trigger
#
# Argument(s):
#	PortArray	            either list of ports or array of ports
#
########################################################################
proc ixAbortPoeArm {PortList} \
{
    upvar $PortList portList

    return [abortPoeArm portList]
}


########################################################################
# Procedure: ixAbortPortPoeArm
#
# This command aborts the poe trigger on a single port.
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
proc ixAbortPortPoeArm {chassis lm port} \
{
    return [abortPortPoeArm  $chassis $lm $port]
}


########################################################################
# Procedure: ixStartAtmOamTransmit
#
# This command starts the atm oam transmit
#
# Argument(s):
#	PortArray	            either list of ports or array of ports
#
########################################################################
proc ixStartAtmOamTransmit {PortList} \
{
    upvar $PortList portList

    return [startAtmOamTransmit portList]
}


########################################################################
# Procedure: ixStartPortAtmOamTransmit
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
proc ixStartPortAtmOamTransmit {chassis lm port} \
{
    return [startPortAtmOamTransmit $chassis $lm $port]
}

########################################################################
# Procedure: ixStopAtmOamTransmit
#
# This command starts the atm oam transmit
#
# Argument(s):
#	PortArray	            either list of ports or array of ports
#
########################################################################
proc ixStopAtmOamTransmit {PortList} \
{
    upvar $PortList portList

    return [stopAtmOamTransmit portList]
}


########################################################################
# Procedure: ixStopPortAtmOamTransmit
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
proc ixStopPortAtmOamTransmit {chassis lm port} \
{
    return [stopPortAtmOamTransmit $chassis $lm $port]
}




########################################################################################
#  Procedure  :  ixCreatePortListWildCard
#
#  Description:  This commands creates a list of ports in a sorted order based on the
# physical slots. It accepts * as a wild card to indicate all cards or all ports on a
# card. A wild card cannot be used for chassis ID. Also, if a combination of a list
# element containing wild cards and port numbers are passed, then the port list passed
# MUST be in a sorted order, otherwise the some of those ports might not make it in the
# list. For example,
# ixCreatePortListWildCard {1 * *} - all cards and all ports on chassis 1
# ixCreatePortListWildCard {{1 1 *} {1 2 1} { 1 2 2}} - all ports on card 1 and
#                           ports 1 and 2 on card 2.
#
#  Arguments  :
#      portList         - Represented in Chassis Card Port and can be a list also
#      excludePorts     - exclude these ports from the sorted port list
#
########################################################################################
proc ixCreatePortListWildCard {portList {excludePorts {}}} \
{
    set retList {}

    # If excludePorts is passed as a single list, then put braces around it
    if {[llength $excludePorts] == 3 && [llength [lindex $excludePorts 0]] == 1} {
        set excludePorts [list $excludePorts]
    }

    foreach portItem $portList {
        scan [join [split $portItem ,]] "%s %s %s" ch fromCard fromPort
    
        set origFromPort    $fromPort

        if { $ch == "*"} {
            errorMsg "Chassis ID cannot be a wildcard. Enter a valid number"
            return $retList
        }

        if [chassis getFromID $ch] {
            errorMsg "Chassis ID $ch has not been added to chassis chain."
            continue
        }

        set maxCardsInChassis   [chassis cget -maxCardCount]
        if { $fromCard == "*"} {
            set fromCard 1
            set toCard   $maxCardsInChassis
        } else {
            set toCard   $fromCard
        }

        for {set l $fromCard} {$l <= $toCard} {incr l} {
            if [card get $ch $l] {
                #errorMsg "Error getting card $ch $l"
                continue
            }

            set maxPorts    [card cget -portCount]

            if { $origFromPort == "*"} {
                set fromPort 1
                set toPort   $maxPorts
            } else {
                set toPort   $fromPort
            }

            for {set p $fromPort} {$p <= $toPort} {incr p} {
                if [port get $ch $l $p] {
                    continue
                }
                if {[lsearch $excludePorts "$ch $l $p"] == -1 && [lsearch $retList "$ch $l $p"] == -1} {
                    lappend retList [list $ch $l $p]
                }

            }
        }
    }

    return [lnumsort $retList]
}


########################################################################################
#  Procedure  :  ixCreateSortedPortList
#
#  Description:  This commands creates a list of ports in a sorted order based on the
# range of ports passed.
#
# For example - to add all ports on cards 1 through 5:
# ixCreateSortedPortList {{1 1 1} {1 5 4}}
#
#
#  Arguments  :
#       portListFrom     - First port
#       portListTo       - Last port
#
########################################################################################
proc ixCreateSortedPortList {portListFrom portListTo excludePortList} \
{
    scan $portListFrom "%d %d %d" fromChassis fromCard fromPort
    scan $portListTo "%d %d %d" toChassis toCard toPort
    set sortMap {}

    for {set c $fromChassis} {$c <= $toChassis} {incr c} {
        if [chassis get $c] {
            errorMsg "Chassis ID $c has not been added to chassis chain."
            continue
        }

        set maxCardsInChassis   [chassis cget -maxCardCount]

        if {$c == $fromChassis} {
            set firstCard   $fromCard
        } else {
            set firstCard   1
        }
        if {$c == $toChassis} {
            if {$maxCardsInChassis < $toCard} {
                set currLastCard    $maxCardsInChassis
            } else {
                set currLastCard    $toCard
            }
        } else {
            set currLastCard    $maxCardsInChassis
        }

        for {set l $firstCard} {$l <= $currLastCard} {incr l} {
            if [card get $c $l] {
                ixPuts "Error getting card $l on chassis $c"
                return 1
            }
            set numports    [card cget -portCount]
            if {$numports == 0} {
                continue
            }

            if {($c == $fromChassis) && ($l == $fromCard)} {
                set firstPort   $fromPort
            } else {
                set firstPort   1
            }

            if {($c == $toChassis) && ($l == $toCard)} {
                if {$numports < $toPort} {
                    set currLastPort    $numports
                } else {
                    set currLastPort    $toPort
                }
            } else {
                set currLastPort    [card cget -portCount]
            }

            for {set p $firstPort} {$p <= $currLastPort} {incr p} {
                if {[lsearch $excludePortList "$c $l $p"] != -1} {
                    continue
                }
                set sortMap [lappend sortMap [list $c $l $p]]
            }
        }
    }
    return $sortMap
}


########################################################################################
#  Procedure : ixPuts
#
#  Description:  This command is similar to "puts" except that it has an update command
# so that the output queue gets flushed and the message gets printed immediately. In
# Window 95/NT platform, the "puts" command does not print the messages rightaway.
#
#  Arguments :
#       args - Message to display
#
########################################################################################
proc ixPuts {args} \
{
    catch {
        if {[lindex $args 0] == "-nonewline"} {
            set args [lreplace $args 0 0]
            puts -nonewline [logger cget -ioHandle] [join $args " "]
        } else {
            puts [logger cget -ioHandle] [join $args " "]
        }

        # Reported that the update blocks the display on Solaris using wish8.0
        # so use update idletasks instead
        update
    }
}


########################################################################################
#  Procedure  :  ixiaPortSetParms
#
#  Description:  This procedure sets specific port parameters
#
#  Arguments  :  chassis - Chassis ID
#                card    - Card Number
#                port    - Port Number
#                parm    - Parameter to be set
#                value   - Value to set
########################################################################################
proc ixiaPortSetParms {chassis card port parm value} \
{
   if [port get $chassis $card $port]  {
      ixPuts "Error getting port $chassis $card $port from HAL"
      return 1
   }

   puts "port config -$parm $value"

   port config -$parm $value

   if [port set $chassis $card $port] {
      ixPuts "Error setting port $chassis $card $port in HAL"
      return 1
   }
   if [port write $chassis $card $port] {
      ixPuts "Error writing port $chassis $card $port in Hardware"
      return 1
   }

   return 0
}


########################################################################################
#  Procedure  : ixiaReadWriteMII
#
#  Description: This procedure will read/write values from/to the MII <register>
#               on <ports>.   4 character hex string and Action will be READ or
#               WRITE.   register will be a value between 0 and 31
#
#  Arguments  :
#      ports     - Represented in Chassis Card Port and can be a list also
#                  for ex. {1,1,1 1,1,2}
#      action    - READ or WRITE
#      register  - Value between 0 and 31
#      code      - 4 character hex string
#
########################################################################################

proc ixiaReadWriteMII {ports action register code} \
{

  if {($action != "READ") && ($action != "WRITE")} {
     ixPuts "Error: Action parameter error use READ or WRITE"
     return 1
     }
  if {($register < 0) || ($register > 31)} {
     ixPuts "Error: register parameter error - valid range between 0 - 31"
     return 1
     }

  set retValues {}

  foreach prt $ports {
     scan $prt "%d %d %d" c l p
     mii get $c $l $p

     if {$action == "READ"} {
        set val [mii cget -registerValue]
        lappend retValues $val
        }

     mii configure -miiRegister $register
     mii configure -registerValue $code
     if {$action == "WRITE"} {
        if [mii set $c $l $p] {
           errorMsg "Error setting Mii [getPortId $c $l $p] in HAL."
           return 1
        }
        if [mii write $c $l $p] {
           errorMsg "Error setting Mii [getPortId $c $l $p] in HAL."
           return 1
        }
     }
  }

#
#  This procedure is set up to return a list of MII register values for multiple ports
#  however if only one port is fed to it then one value will be return.  It works with
#  either multiple ports or a single port in the $ports list
#
  if {$action == "READ"} {
     return $retValues
  } else {
     return 0
  }
}


########################################################################################
# Procedure: ixTclSvrConnect
#
# Description: This procedure launches the Tcl Server on the chassis for multi-users.
#
# Argument(s):
#       serverName         name of hostnames or IP address of chassis to connect to
#
########################################################################################
proc ixTclSvrConnect { serverName } \
{
    return [tclServer::connectToTclServer $serverName errMsg]
}


########################################################################################
# Procedure: ixTclSvrDisconnect
#
# Description: This procedure disconnects from the TclServer socket.
#
#
########################################################################################
proc ixTclSvrDisconnect {} \
{
    return [tclServer::disconnectTclServer]
}


########################################################################
# Procedure: ixEnableArpResponse
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
#       0 if OK, 1 if port not configured
#
########################################################################
proc ixEnableArpResponse { mapType PortMap } \
{
    upvar $PortMap   portMap
    return [enableArpResponse $mapType portMap write]
}


########################################################################
# Procedure: ixEnablePortArpResponse
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
#       0 if OK, 1 if port not configured
#
########################################################################
proc ixEnablePortArpResponse { mapType chassis lm port {write write}} \
{
    return [enablePortArpResponse $mapType $chassis $lm $port $write]
}


########################################################################
# Procedure: ixDisableArpResponse
#
# This command disables the arp response engine for all ports in
# the portlist
#
# Arguments(s):
#   PortMap - list or array of ports, ie. ixgSortMap
#
# Return:
#       0 if OK, 1 if port not configured
#
########################################################################
proc ixDisableArpResponse { PortMap } \
{
    upvar $PortMap   portMap

    return [disableArpResponse portMap write]
}


########################################################################
# Procedure: ixTransmitArpRequest
#
# This command transmits an Arp request via the protocol server.
#
# Arguments:
#   TxRxArray       - either array or list containing ports to transmit
#                     arp request on
#
########################################################################
proc ixTransmitArpRequest {TxRxArray} \
{
    upvar $TxRxArray        txRxArray

    return [transmitArpRequest txRxArray]
}


########################################################################
# Procedure: ixClearArpTable
#
# This command clears the arp table via the protocol server.
#
# Arguments:
#   TxRxArray       - either array or list containing ports to clear
#                     arp table on
#
########################################################################
proc ixClearArpTable {TxRxArray} \
{
    upvar $TxRxArray        txRxArray

    return [clearArpTable txRxArray]
}


########################################################################
# Procedure: ixDisablePortArpResponse
#
# This command disables the arp response engine for the specified port
#
# Arguments(s):
#   chassis
#   lm
#   port
#
# Return:
#       0 if OK, 1 if port not configured
#
########################################################################
proc ixDisablePortArpResponse {chassis lm port {write write}} \
{
    return [disablePortArpResponse $chassis $lm $port $write]
}


########################################################################
# Procedure: ixTransmitPortArpRequest
#
# This command transmits an Arp request via the protocol server on a
# single port
#
# Arguments(s):
#       chassis
#       lm
#       port
#
# Return:
#       0 if OK, 1 if port not configured
#
########################################################################
proc ixTransmitPortArpRequest {chassis lm port} \
{
    return [transmitPortArpRequest $chassis $lm $port]
}


########################################################################
# Procedure: ixClearPortArpTable
#
# This command clears the arp table on a single port
#
# Arguments(s):
#       chassis
#       lm
#       port
#
# Return:
#       0 if OK, 1 if port not configured
#
########################################################################
proc ixClearPortArpTable {chassis lm port} \
{
    return [clearPortArpTable $chassis $lm $port]
}

########################################################################
# Procedure: ixSetPacketGroupMode
#
# This command sets all the RX ports in the list or array to packet
# group mode
#
# Arguments(s):
#   TxRxArray       - list or array of RX ports to change
#   write           - write ports to hw as they are modified
#
# Return:
#       0 if OK, 1 if port not configured
#
########################################################################
proc ixSetPacketGroupMode {TxRxArray {write nowrite}} \
{
    upvar $TxRxArray    txRxArray

    return [setPacketGroupMode txRxArray $write]
}


########################################################################
# Procedure: ixSetPortPacketGroupMode
#
# This command sets all the RX ports for this port to packet
# group mode
#
# Arguments(s):
#   chassis
#   lm
#   port
#   write           - write port to hw
#
# Return:
#       0 if OK, 1 if port not configured
#
########################################################################
proc ixSetPortPacketGroupMode {chassis lm port {write nowrite}} \
{
    set retCode $::TCL_OK

    if [catch {format "%d,%d,%d" $chassis $lm $port} txRxArray] {
        errorMsg $txRxArray
        set retCode $::TCL_ERROR
    } else {
        set retCode [setPacketGroupMode txRxArray $write]
    }

    return $retCode
}


########################################################################
# Procedure: ixSetAutoDetectInstrumentationMode
#
# This command sets all the RX ports in the list or array to 
# all the autoinstrumentation modes PG/DataIntegrity/SequenceChecking
#
# Arguments(s):
#   TxRxArray       - list or array of RX ports to change
#   write           - write ports to hw as they are modified
#
# Return:
#       0 if OK, 1 if port not configured
#
########################################################################
proc ixSetAutoDetectInstrumentationMode {TxRxArray {write nowrite}} \
{
    upvar $TxRxArray    txRxArray

    return [setAutoDetectInstrumentationMode txRxArray $write]
}


########################################################################
# Procedure: ixSetPortAutoDetectInstrumentationMode
#
# This command sets all the RX ports for this port to 
# all the autoinstrumentation modes PG/DataIntegrity/SequenceChecking
#
# Arguments(s):
#   chassis
#   lm
#   port
#   write           - write port to hw
#
# Return:
#       0 if OK, 1 if port not configured
#
########################################################################
proc ixSetPortAutoDetectInstrumentationMode {chassis lm port {write nowrite}} \
{
    set retCode $::TCL_OK

    if [catch {format "%d,%d,%d" $chassis $lm $port} txRxArray] {
        errorMsg $txRxArray
        set retCode $::TCL_ERROR
    } else {
        set retCode [setAutoInstrumentationMode txRxArray $write]
    }

    return $retCode
}

########################################################################
# Procedure: ixSetWidePacketGroupMode
#
# This command sets all the RX ports in the list or array to wide packet
# group mode
#
# Arguments(s):
#   TxRxArray       - list or array of RX ports to change
#   write           - write ports to hw as they are modified
#
# Return:
#       0 if OK, 1 if port not configured
#
########################################################################
proc ixSetWidePacketGroupMode {TxRxArray {write nowrite}} \
{
    upvar $TxRxArray    txRxArray

    return [setWidePacketGroupMode txRxArray $write]
}


########################################################################
# Procedure: ixSetPortWidePacketGroupMode
#
# This command sets all the RX ports for this port to wide packet
# group mode
#
# Arguments(s):
#   chassis
#   lm
#   port
#   write           - write port to hw
#
# Return:
#       0 if OK, 1 if port not configured
#
########################################################################
proc ixSetPortWidePacketGroupMode {chassis lm port {write nowrite}} \
{
    set retCode $::TCL_OK

    if [catch {format "%d,%d,%d" $chassis $lm $port} txRxArray] {
        errorMsg $txRxArray
        set retCode $::TCL_ERROR
    } else {
        set retCode [setWidePacketGroupMode txRxArray $write]
    }

    return $retCode
}


########################################################################
# Procedure: ixSetCaptureMode
#
# This command sets all the RX ports in the list or array to capture
# mode
#
# Arguments(s):
#   TxRxArray       - list or array of RX ports to change
#   write           - write ports to hw as they are modified
#
########################################################################
proc ixSetCaptureMode {TxRxArray {write nowrite}} \
{
    upvar $TxRxArray txRxArray

    return [setCaptureMode txRxArray $write]
}


########################################################################
# Procedure: ixSetPortCaptureMode
#
# This command sets receive mode for the specified port to capture mode
#
# Arguments(s):
#   chassis
#   lm
#   port
#   write           - write port to hw
#
########################################################################
proc ixSetPortCaptureMode {chassis lm port {write nowrite}} \
{
    set retCode $::TCL_OK

    if [catch {format "%d,%d,%d" $chassis $lm $port} txRxArray] {
        errorMsg $txRxArray
        set retCode $::TCL_ERROR
    } else {
        set retCode [setCaptureMode txRxArray $write]
    }

    return $retCode
}


########################################################################
# Procedure: ixSetTcpRoundTripFlowMode
#
# This command sets all the RX ports in the list or array to tcp round 
# trip flow mode
#
# Arguments(s):
#   TxRxArray       - list or array of RX ports to change
#   write           - write ports to hw as they are modified
#
########################################################################
proc ixSetTcpRoundTripFlowMode {TxRxArray {write nowrite}} \
{
    upvar $TxRxArray txRxArray

    return [setTcpRoundTripFlowMode txRxArray $write]
}


########################################################################
# Procedure: ixSetPortTcpRoundTripFlowMode
#
# This command sets receive mode for the specified port to tcp round 
# trip flow mode
#
# Arguments(s):
#   c        - chassis
#   l        - card
#   p        - port
#   write   - write port to hw
#
########################################################################
proc ixSetPortTcpRoundTripFlowMode {c l p {write nowrite}} \
{
    set retCode 0

    if [catch {format "%d,%d,%d" $c $l $p} txRxArray] {
        errorMsg "$txRxArray"
        set retCode 1
    } else {
        set retCode [setTcpRoundTripFlowMode txRxArray $write]
    }

    return $retCode
}


########################################################################
# Procedure: ixSetDataIntegrityMode
#
# This command sets all the RX ports in the list or array to Data Integrity 
# mode
#
# Arguments(s):
#   TxRxArray       - list or array of RX ports to change
#   write           - write ports to hw as they are modified
#
########################################################################
proc ixSetDataIntegrityMode {TxRxArray {write nowrite}} \
{
    upvar $TxRxArray txRxArray

    return [setDataIntegrityMode txRxArray $write]
}


########################################################################
# Procedure: ixSetPortDataIntegrityMode
#
# This command sets receive mode for the specified port to Data Integrity 
# mode
#
# Arguments(s):
#   c        - chassis
#   l        - card
#   p        - port
#   write   - write port to hw
#
########################################################################
proc ixSetPortDataIntegrityMode {c l p {write nowrite}} \
{
    set retCode $::TCL_OK

    if [catch {format "%d,%d,%d" $c $l $p} txRxArray] {
        errorMsg "$txRxArray"
        set retCode $::TCL_ERROR
    } else {
        set retCode [setDataIntegrityMode txRxArray $write]
    }

    return $retCode
}


########################################################################
# Procedure: ixSetSequenceCheckingMode
#
# This command sets all the TX ports in the list or array to Sequence
# Checking Mode
#
# Arguments(s):
#   TxRxArray       - list or array of RX ports to change
#   write           - write ports to hw as they are modified
#
########################################################################
proc ixSetSequenceCheckingMode {TxRxArray {write nowrite}} \
{
    upvar $TxRxArray txRxArray

    return [setSequenceCheckingMode txRxArray $write]
}


########################################################################
# Procedure: ixSetPortSequenceCheckingMode
#
# This command sets receive mode for the specified port to Sequence
# Checking Mode
#
# Arguments(s):
#   c        - chassis
#   l        - card
#   p        - port
#   write   - write port to hw
#
########################################################################
proc ixSetPortSequenceCheckingMode {c l p {write nowrite}} \
{
    set retCode $::TCL_OK

    if [catch {format "%d,%d,%d" $c $l $p} txRxArray] {
        errorMsg "$txRxArray"
        set retCode $::TCL_ERROR
    } else {
        set retCode [setSequenceCheckingMode txRxArray $write]
    }

    return $retCode
}


########################################################################
# Procedure: ixSetPacketFlowMode
#
# This command sets all the TX ports in the list or array to packet
# flow mode
#
# Arguments(s):
#   TxRxArray       - list or array of TX ports to change
#   write           - write ports to hw as they are modified
#
########################################################################
proc ixSetPacketFlowMode {TxRxArray {write nowrite}} \
{
    upvar $TxRxArray txRxArray

    return [setPacketFlowMode txRxArray $write]
}


########################################################################
# Procedure: ixSetPortPacketFlowMode
#
# This command sets specified port to packet flow mode
#
# Arguments(s):
#   chassis
#   lm
#   port
#   write           - write port to hw
#
########################################################################
proc ixSetPortPacketFlowMode {c l p {write nowrite}} \
{
    set retCode 0

    if [catch {format "%d,%d,%d" $c $l $p} txRxArray] {
        logMsg "ixSetPortPacketFlowMode: $txRxArray"
        set retCode 1
    } else {
        set retCode [setPacketFlowMode txRxArray $write]
    }

    return $retCode
}


########################################################################
# Procedure: ixSetPacketStreamMode
#
# This command sets all the TX ports in the list or array to packet
# stream mode
#
# Arguments(s):
#   TxRxArray       - list or array of TX ports to change
#   write           - write ports to hw as they are modified
#
########################################################################
proc ixSetPacketStreamMode {TxRxArray {write nowrite}} \
{
    upvar $TxRxArray txRxArray

    return [setPacketStreamMode txRxArray $write]
}


########################################################################
# Procedure: ixSetPortPacketStreamMode
#
# This command sets specified port to packet stream mode
#
# Arguments(s):
#   chassis
#   lm
#   port
#   write           - write port to hw
#
########################################################################
proc ixSetPortPacketStreamMode {chassis lm port {write nowrite}} \
{
    set retCode 0

    if [catch {format "%d,%d,%d" $chassis $lm $port} txRxArray] {
        logMsg "ixSetPortPacketStreamMode: $txRxArray"
        set retCode 1
    } else {
        set retCode [setPacketStreamMode txRxArray $write]
    }

    return $retCode
}


########################################################################
# Procedure: ixSetAdvancedStreamSchedulerMode
#
# This command sets all the TX ports in the list or array to packet
# flow mode
#
# Arguments(s):
#   TxRxArray       - list or array of TX ports to change
#   write           - write ports to hw as they are modified
#
########################################################################
proc ixSetAdvancedStreamSchedulerMode {TxRxArray {write nowrite}} \
{
    upvar $TxRxArray txRxArray

    return [changePortTransmitMode txRxArray $::portTxModeAdvancedScheduler $write]
}


########################################################################
# Procedure: ixSetPortAdvancedStreamSchedulerMode
#
# This command sets specified port to packet flow mode
#
# Arguments(s):
#   chassis
#   lm
#   port
#   write           - write port to hw
#
########################################################################
proc ixSetPortAdvancedStreamSchedulerMode {c l p {write nowrite}} \
{
    set retCode $::TCL_OK

    if [catch {format "%d,%d,%d" $c $l $p} txRxArray] {
        errorMsg "$txRxArray"
        set retCode $::TCL_ERROR
    } else {
        set retCode [setAdvancedStreamSchedulerMode txRxArray $write]
    }

    return $retCode
}


########################################################################
# Procedure: ixWritePortsToHardware
#
# This command writes the ports, including speed, etc into hardware. It
# differs from writeConfigToHardware because this command writes all
# the phy as well as the configuration.
#
# Argument(s):
#    PortArray      either list of ports or array of ports
#    args           options include:
#                   -verbose             <turn on messages>
#                   -noVerbose           <turn off messages, default>
#                   -writeProtocolServer <stops protocol server & writes 
#                                         all associated objects, default>
#                   -noProtocolServer    <no effect on protocol server,
#                                         doesn't update protocol server objects>
#
########################################################################
proc ixWritePortsToHardware {PortArray args} \
{
    upvar $PortArray portArray

    return [writePortsToHardware portArray [join [list -noVerbose $args]]]
}


########################################################################
# Procedure: ixWriteConfigToHardware
#
# This command writes the port array into hardware
#
# Argument(s):
#    PortArray      either list of ports or array of ports
#    args           options include:
#                   -verbose             <turn on messages>
#                   -noVerbose           <turn off messages, default>
#                   -writeProtocolServer <stops protocol server & writes 
#                                         all associated objects, default>
#                   -noProtocolServer    <no effect on protocol server,
#                                         doesn't update protocol server objects>
#
########################################################################
proc ixWriteConfigToHardware {PortArray args} \
{
    upvar $PortArray portArray

    return [writeConfigToHardware portArray [join [list -noVerbose $args]]]
}


########################################################################
# Procedure: ixCheckTransmitDone
#
# This command polls the TX rate counters & returns when done transmitting
#
# Argument(s):
#    PortArray                either list of ports or array of ports
#
########################################################################
proc ixCheckTransmitDone {PortArray} \
{
    upvar $PortArray portArray

    return [checkAllTransmitDone portArray]
}


########################################################################
# Procedure: ixCheckPortTransmitDone
#
# This command polls the TX rate counters & returns the number of frames
# transmitted
#
# Argument(s):
#    chassis        chassis ID
#    lm            Load Module number
#    port        port number
#
########################################################################
proc ixCheckPortTransmitDone {chassis lm port} \
{
    return [checkTransmitDone $chassis $lm $port]
}


########################################################################
# Procedure: ixCheckLinkState
#
# This command checks the link state of all ports in parallel and labels
# the ones that are down. Then it polls the links that are down for two
# seconds and returns 1 if any port is still down and a 0 if all ports are
# up.
#
# Arguments(s):
#    PortArray    array or list of ports, ie, ixgSortMap
#
########################################################################
proc ixCheckLinkState {PortArray {message messageOn}} \
{
    upvar $PortArray portArray

    return [checkLinkState portArray]
}


########################################################################
# Procedure: ixCheckPPPState
#
# This command checks the PPP state of all PoS ports in parallel and labels
# the ones that are down. Then it polls the links that are down for two
# seconds and returns 1 if any port is still down and a 0 if all ports are
# up.
#
# Arguments(s):
#    PortArray    array or list of ports, ie, ixgSortMap
#
########################################################################
proc ixCheckPPPState {PortArray {message messageOn}} \
{
    upvar $PortArray portArray

    return [checkPPPState portArray $message]
}



########################################################################
# Procedure: ixCollectStats
#
# This command polls the RX counters for the specified stat
#
# Argument(s):
#   rxList          - list of receive ports
#   statName        - name of stat to poll (need cget name)
#   RxNumFrames     - array containing the returned rx stats
#   TotalRxFrames   - total received frames
#
########################################################################
proc ixCollectStats {rxList statName RxNumFrames TotalRxFrames} \
{
    upvar $RxNumFrames        rxNumFrames
    upvar $TotalRxFrames    totalRxFrames

    return [collectStats $rxList $statName rxNumFrames totalRxFrames]
}


########################################################################################
# Procedure:   ixProxyConnect
#
# Description: This command connects to the proxy server...
#
# Argument(s):
#    tclServer   - The name of the machine that is running an ixTclServer to connect with
#    chassisList - The list of hostnames or IP addresses of chassis in a chain
#    cableLen    - The choice of the cable length between chassis.  Defaults to cable3feet is not given
#    logFilename - The name of the file for the test logs output
#
# Returns:
#    0 : if no error
#    1 : if error connecting to chassis
#    2 : if version mismatch
#    3 : if chassis timeout occurred
#    4 : if connection interrupted by user
#    5 : if error connecting to Tcl server
########################################################################################
proc ixProxyConnect {tclServer chassisList {cableLen cable3feet} {logFilename ""}} \
{
    # Default return code to no error found
    set retCode 0

    if {[ixTclHal::isCleanUpDone]} {
        debugMsg "ixProxyConnect: package req IxTclHal"
        package req IxTclHal
    }

    if {[info exists logFilename] && ([string length $logFilename] > 0)} {
        logOn $logFilename
    }

    if {[isUNIX]} {
        set retCode [ixConnectToTclServer $tclServer]
        if {$retCode == 1} {
            # We need to change the return code, because it conflicts with the code from ixConnectToChassis
            set retCode 5
        }
    }
    if {$retCode == 0} {
        set retCode [ixConnectToChassis $chassisList $cableLen]
    }
    return $retCode
}


########################################################################
# Procedure: ixResetSequenceIndex 
#
# This command reset the sequence index
#
# Argument(s):
#    PortArray                either list of ports or array of ports
#
########################################################################
proc ixResetSequenceIndex {PortArray} \
{
    upvar $PortArray portArray

    return [resetSequenceIndex portArray]
}


########################################################################
# Procedure:   ixResetPortSequenceIndex 
#
# Description: This command reset sequence index on a single port
#
# Arguments(s):
#    chassis
#    lm
#    port
#
# Return:      0 if OK, 1 if port not configured
########################################################################
proc ixResetPortSequenceIndex  {chassis lm port} \
{
    return [resetPortSequenceIndex $chassis $lm $port]
}



########################################################################
# Procedure:   ixRestartAutoNegotiation
#
# Description: This command restarts auto negotiation
#
# Arguments:
#    TxRxArray - either list of ports or array of ports
#                     
# Returns:     The return code from restartAutoNegotiation
########################################################################
proc ixRestartAutoNegotiation {TxRxArray} \
{
    upvar $TxRxArray      txRxArray

    return [restartAutoNegotiation txRxArray]
}

########################################################################
# Procedure:   ixRestartPortAutoNegotiation
#
# Description: This command restarts auto negotiation
#
# Arguments(s):
#    chassis
#    lm
#    port
#
# Returns:     The return code from restartAutoNegotiation
########################################################################
proc ixRestartPortAutoNegotiation {chassis lm port} \
{
    set retCode $::TCL_OK

    if [catch {format "%d,%d,%d" $chassis $lm $port} txRxArray] {
        errorMsg "$txRxArray"
        set retCode $::TCL_ERROR
    } else {
        set retCode [restartAutoNegotiation txRxArray]
    }

    return $retCode
}


########################################################################
# Procedure:   ixRestartPPPNegotiation
#
# Description: This command restarts PPP negotiation 
#
# Arguments:
#    TxRxArray - either list of ports or array of ports
#                     
# Returns:     The return code from restartAutoNegotiation
########################################################################
proc ixRestartPPPNegotiation {TxRxArray} \
{
    upvar $TxRxArray      txRxArray

    set allPorts [getAllPorts txRxArray]

    ixStopTransmit allPorts
    return [restartAutoNegotiation txRxArray]
}


########################################################################
# Procedure:   ixRestartPortPPPNegotiation
#
# Description: This command restarts PPP negotiation 
#
# Arguments(s):
#    chassis
#    lm
#    port
#
# Returns:     The return code from restartAutoNegotiation
########################################################################
proc ixRestartPortPPPNegotiation {chassis lm port} \
{
    set retCode $::TCL_OK

    if [catch {format "%d,%d,%d" $chassis $lm $port} txRxArray] {
        errorMsg "$txRxArray"
        set retCode $::TCL_ERROR
    } else {
        ixStopPortTransmit $chassis $lm $port
        set retCode [restartAutoNegotiation txRxArray]
    }

    return $retCode
}



##################################################################################
# Procedure:   ixIsOverlappingIpAddress  
#
# Description: Check if IP addresses are overlapping.
#
# Arguments:   ipAddress1  - first IP address to compare to
#              count1      - number of IP addresses starting from ipAddress1 to compare to
#              ipAddress2  - first IP address to compare to
#              count2      - number of IP addresses starting from ipAddress2 to compare to
#
# Returns:     1 - $::true
#              0 - $::false
#
##################################################################################
proc ixIsOverlappingIpAddress {ipAddress1 count1 ipAddress2 count2} \
{
    return [dataValidation::isOverlappingIpAddress $ipAddress1 $count1 $ipAddress2 $count2]
}


##################################################################################
# Procedure:   ixIsSameSubnet   
#
# Description: Check if ip addresses are in the same subnet.
#              Note that all ports in one user porfile should be in same subnet.
#
# Arguments:   ipAddr1 - ipAddress to compare to
#              mask1   - net mask of ipAddr1
#              ipAddr2 - ipAddress to compare to
#              mask2   - net mask of ipAddr2
#
# Returns:     1 - $::true
#              0 - $::false
#
##################################################################################
proc ixIsSameSubnet {ipAddr1 mask1 ipAddr2 mask2} \
{
    return [dataValidation::isSameSubnet $ipAddr1 $mask1 $ipAddr2 $mask2]
}


##################################################################################
# Procedure:   ixIsValidHost   
#
# Description: Check if the host part of an IP address is not all 0's or all 1's assuming
#              its net mask is valid.
#
# Arguments:   ipAddr - ipAddress
#              mask   - net mask
#
# Returns:     1 - $::true
#              0 - $::false
#
##################################################################################
proc ixIsValidHost {ipAddr mask} \
{
    return [dataValidation::isValidHostPart $ipAddr $mask]
}


##################################################################################
# Procedure:   ixIsValidNetMask   
#
# Description: Check if net mask is valid. i.e. In binary form, the mask must 
#              have consecutive 1's followed by consecutive 0's
#
# Arguments:   mask - net mask
#
# Returns:     1 - $::true
#              0 - $::false
#
##################################################################################
proc ixIsValidNetMask {mask} \
{
    return [dataValidation::isValidNetMask $mask]
}


##################################################################################
# Procedure:   ixIsValidUnicastIp   
#
# Description: Check if ipAddress accomplied with the following
#                   1) it is not 0.0.0.0
#                   2) it is not 255.255.255.255
#                   3) it is not loopback address (127.x.x.x)
#                   4) it is not multicast address 
#                      (224.0.0.0 - 239.255.255.255, i.e first 4 bits not 1110)
#
# Arguments:   ipAddr - IP address 
#
# Returns:     1 - $::true
#              0 - $::false
#
##################################################################################
proc ixIsValidUnicastIp {ipAddr} \
{
    return [dataValidation::isValidUnicastIp $ipAddr]
}


##################################################################################
# Procedure:   ixConvertFromSeconds   
#
# Description: Convert seconds to hours, minutes, seconds
#
# Arguments:   seconds
#               Hours   - returned
#               Minutes - returned
#               Seconds - returned
#
# Returns:     $::TCL_OK or $::TCL_ERROR
#
##################################################################################
proc ixConvertFromSeconds {time Hours Minutes Seconds} \
{
    upvar $Hours   hours
    upvar $Minutes minutes
    upvar $Seconds seconds

    return [convertFromSeconds $time hours minutes seconds]
}


##################################################################################
# Procedure:   ixConvertToSeconds   
#
# Description: Convert time in hours:minutes:seconds format to seconds
#
# Arguments:   hours    - number of hours of time
#              minutes  - number of minutes of time
#              seconds  - number of seconds of time
#
# Returns:     number of seconds
#
##################################################################################
proc ixConvertToSeconds {hours minutes seconds} \
{
    return [convertToSeconds $hours $minutes $seconds]
}




