#############################################################################################
#
# actions.tcl  
#
# Copyright © 1997-2004 by IXIA.
# All Rights Reserved.
#
#   Revision Log:
#   05-06-2004  EM  Genesis
#
#############################################################################################


########################################################################
# Procedure: startBGP4Server
#
# This command turns ON the protocol server to start BGP4 
#
# Argument(s):
#	TxRxArray	         either list of ports or array of ports
#
########################################################################
proc startBgp4Server {TxRxArray {groupId 710} {create create} {destroy destroy}} \
{
    upvar $TxRxArray txRxArray

    set retCode 0

    set txRxList [getRxPorts txRxArray]
    if [issuePortGroupCommand startBgp4 txRxList noVerbose firstTimestamp $groupId $create $destroy] {
	    errorMsg "Error starting BGP4"
	    set retCode 1
    }

    return $retCode
}

########################################################################
# Procedure: stopBgp4Server
#
# This command turns ON the protocol server to stop BGP4 
#
# Argument(s):
#	TxRxArray	         either list of ports or array of ports
#
########################################################################
proc stopBgp4Server {TxRxArray {groupId 710} {create create} {destroy destroy}} \
{
    upvar $TxRxArray txRxArray

    set retCode 0

    set txRxList [getRxPorts txRxArray]
    if [issuePortGroupCommand stopBgp4 txRxList noVerbose firstTimestamp $groupId $create $destroy] {
	    errorMsg "Error stoping BGP4"
	    set retCode 1
    }

    return $retCode
}

########################################################################
# Procedure: startOspfServer
#
# This command turns ON the protocol server to start ospf
#
# Argument(s):
#	TxRxArray	         either list of ports or array of ports
#
########################################################################
proc startOspfServer {TxRxArray {groupId 710} {create create} {destroy destroy}} \
{
    upvar $TxRxArray txRxArray

    set retCode 0

    set txRxList [getRxPorts txRxArray]
    if [issuePortGroupCommand startOspf txRxList noVerbose firstTimestamp $groupId $create $destroy] {
	    errorMsg "Error starting OSPF"
	    set retCode 1
    }

    return $retCode
}

########################################################################
# Procedure: stopOspfServer
#
# This command turns ON the protocol server to stop ospf
#
# Argument(s):
#	TxRxArray	         either list of ports or array of ports
#
########################################################################
proc stopOspfServer {TxRxArray {groupId 710} {create create} {destroy destroy}} \
{
    upvar $TxRxArray txRxArray

    set retCode 0

    set txRxList [getRxPorts txRxArray]
    if [issuePortGroupCommand stopOspf txRxList noVerbose firstTimestamp $groupId $create $destroy] {
	    errorMsg "Error stoping OSPF"
	    set retCode 1
    }

    return $retCode
}


########################################################################
# Procedure: startIsisServer
#
# This command turns ON the protocol server to start Isis
#
# Argument(s):
#	TxRxArray	    List of ports or array of ports
#
#   Results :       0 : No error found
#                   1 : Error found
# 
########################################################################
proc startIsisServer {TxRxArray {groupId 710} {create create} {destroy destroy}} \
{
    upvar $TxRxArray txRxArray

    set retCode 0

    set txRxList [getRxPorts txRxArray]
    if [issuePortGroupCommand startIsis txRxList noVerbose firstTimestamp $groupId $create $destroy] {
	    errorMsg "Error starting Isis"
	    set retCode 1
    }

    return $retCode
}


########################################################################
# Procedure: stopIsisServer
#
# This command turns ON the protocol server to stop Isis
#
# Argument(s):
#	TxRxArray	    List of ports or array of ports
#
#   Results :       0 : No error found
#                   1 : Error found
#
########################################################################
proc stopIsisServer {TxRxArray {groupId 710} {create create} {destroy destroy}} \
{
    upvar $TxRxArray txRxArray

    set retCode 0

    set txRxList [getRxPorts txRxArray]
    if [issuePortGroupCommand stopIsis txRxList noVerbose firstTimestamp $groupId $create $destroy] {
	    errorMsg "Error stoping Isis"
	    set retCode 1
    }

    return $retCode
}


########################################################################
# Procedure: startRsvpServer
#
# This command turns ON the protocol server to start Rsvp
#
# Argument(s):
#	TxRxArray	    List of ports or array of ports
#
#   Results :       0 : No error found
#                   1 : Error found
# 
########################################################################
proc startRsvpServer {TxRxArray {groupId 710} {create create} {destroy destroy}} \
{
    upvar $TxRxArray txRxArray

    set retCode 0

    set txRxList [getAllPorts txRxArray]
    if [issuePortGroupCommand startRsvp txRxList noVerbose firstTimestamp $groupId $create $destroy] {
	    errorMsg "Error starting Rsvp"
	    set retCode 1
    }

    return $retCode
}


########################################################################
# Procedure: stopRsvpServer
#
# This command turns ON the protocol server to stop Rsvp
#
# Argument(s):
#	TxRxArray	    List of ports or array of ports
#
#   Results :       0 : No error found
#                   1 : Error found
#
########################################################################
proc stopRsvpServer {TxRxArray {groupId 710} {create create} {destroy destroy}} \
{
    upvar $TxRxArray txRxArray

    set retCode 0

    set txRxList [getAllPorts txRxArray]
    if [issuePortGroupCommand stopRsvp txRxList noVerbose firstTimestamp $groupId $create $destroy] {
	    errorMsg "Error stoping Rsvp"
	    set retCode 1
    }

    return $retCode
}


########################################################################
# Procedure: startRipServer
#
# This command turns ON the protocol server to start Rip
#
# Argument(s):
#	TxRxArray	    List of ports or array of ports
#
#   Results :       0 : No error found
#                   1 : Error found
# 
########################################################################
proc startRipServer {TxRxArray {groupId 710} {create create} {destroy destroy}} \
{
    upvar $TxRxArray txRxArray

    set retCode 0

    set txRxList [getRxPorts txRxArray]
    if [issuePortGroupCommand startRip txRxList noVerbose firstTimestamp $groupId $create $destroy] {
	    errorMsg "Error starting Rip"
	    set retCode 1
    }

    return $retCode
}


########################################################################
# Procedure: stopRipServer
#
# This command turns ON the protocol server to stop Rip
#
# Argument(s):
#	TxRxArray	    List of ports or array of ports
#
#   Results :       0 : No error found
#                   1 : Error found
#
########################################################################
proc stopRipServer {TxRxArray {groupId 710} {create create} {destroy destroy}} \
{
    upvar $TxRxArray txRxArray

    set retCode 0

    set txRxList [getRxPorts txRxArray]
    if [issuePortGroupCommand stopRip txRxList noVerbose firstTimestamp $groupId $create $destroy] {
	    errorMsg "Error stoping Rip"
	    set retCode 1
    }

    return $retCode
}


########################################################################
# Procedure: startLdpServer
#
# This command turns ON the protocol server to start LDP
#
# Argument(s):
#	TxRxArray	    List of ports or array of ports
#
#   Results :       0 : No error found
#                   1 : Error found
# 
########################################################################
proc startLdpServer {TxRxArray {groupId 710} {create create} {destroy destroy}} \
{
    upvar $TxRxArray txRxArray

    set retCode 0

    set txRxList [getRxPorts txRxArray]
    if [issuePortGroupCommand startLdp txRxList noVerbose firstTimestamp $groupId $create $destroy] {
	    errorMsg "Error starting Ldp"
	    set retCode 1
    }

    return $retCode
}


########################################################################
# Procedure: stopLdpServer
#
# This command turns ON the protocol server to stop LDP
#
# Argument(s):
#	TxRxArray	    List of ports or array of ports
#
#   Results :       0 : No error found
#                   1 : Error found
#
########################################################################
proc stopLdpServer {TxRxArray {groupId 710} {create create} {destroy destroy}} \
{
    upvar $TxRxArray txRxArray

    set retCode 0

    set txRxList [getRxPorts txRxArray]
    if [issuePortGroupCommand stopLdp txRxList noVerbose firstTimestamp $groupId $create $destroy] {
	    errorMsg "Error stoping Ldp"
	    set retCode 1
    }

    return $retCode
}

########################################################################
# Procedure: startRipngServer
#
# This command turns ON the protocol server to start Ripng
#
# Argument(s):
#	TxRxArray	    List of ports or array of ports
#
#   Results :       0 : No error found
#                   1 : Error found
# 
########################################################################
proc startRipngServer {TxRxArray {groupId 710} {create create} {destroy destroy}} \
{
    upvar $TxRxArray txRxArray

    set retCode 0

    set txRxList [getRxPorts txRxArray]
    if [issuePortGroupCommand startRipng txRxList noVerbose firstTimestamp $groupId $create $destroy] {
	    errorMsg "Error starting Ripng"
	    set retCode 1
    }

    return $retCode
}


########################################################################
# Procedure: stopRipngServer
#
# This command turns ON the protocol server to stop Ripng
#
# Argument(s):
#	TxRxArray	    List of ports or array of ports
#
#   Results :       0 : No error found
#                   1 : Error found
#
########################################################################
proc stopRipngServer {TxRxArray {groupId 710} {create create} {destroy destroy}} \
{
    upvar $TxRxArray txRxArray

    set retCode 0

    set txRxList [getRxPorts txRxArray]
    if [issuePortGroupCommand stopRipng txRxList noVerbose firstTimestamp $groupId $create $destroy] {
	    errorMsg "Error stoping Ripng"
	    set retCode 1
    }

    return $retCode
}

########################################################################
# Procedure: startMldServer
#
# This command turns ON the protocol server to start MLD
#
# Argument(s):
#	TxRxArray	    List of ports or array of ports
#
#   Results :       0 : No error found
#                   1 : Error found
# 
########################################################################
proc startMldServer {TxRxArray {groupId 710} {create create} {destroy destroy}} \
{
    upvar $TxRxArray txRxArray

    set retCode 0

    set txRxList [getRxPorts txRxArray]
    if [issuePortGroupCommand startMld txRxList noVerbose firstTimestamp $groupId $create $destroy] {
	    errorMsg "Error starting MLD"
	    set retCode 1
    }

    return $retCode
}


########################################################################
# Procedure: stopMldServer
#
# This command turns ON the protocol server to stop MLD
#
# Argument(s):
#	TxRxArray	    List of ports or array of ports
#
#   Results :       0 : No error found
#                   1 : Error found
#
########################################################################
proc stopMldServer {TxRxArray {groupId 710} {create create} {destroy destroy}} \
{
    upvar $TxRxArray txRxArray

    set retCode 0

    set txRxList [getRxPorts txRxArray]
    if [issuePortGroupCommand stopMld txRxList noVerbose firstTimestamp $groupId $create $destroy] {
	    errorMsg "Error stoping MLD"
	    set retCode 1
    }

    return $retCode
}



########################################################################
# Procedure: startPimsmServer
#
# This command turns ON the protocol server to start PIM-SM
#
# Argument(s):
#	TxRxArray	    List of ports or array of ports
#
#   Results :       0 : No error found
#                   1 : Error found
# 
########################################################################
proc startPimsmServer {TxRxArray {groupId 710} {create create} {destroy destroy}} \
{
    upvar $TxRxArray txRxArray

    set retCode 0

    set txRxList [getRxPorts txRxArray]
    if [issuePortGroupCommand startPimsm txRxList noVerbose firstTimestamp $groupId $create $destroy] {
	    errorMsg "Error starting PIM-SM"
	    set retCode 1
    }

    return $retCode
}


########################################################################
# Procedure: stopPimsmServer
#
# This command turns ON the protocol server to stop PIM-SM
#
# Argument(s):
#	TxRxArray	    List of ports or array of ports
#
#   Results :       0 : No error found
#                   1 : Error found
#
########################################################################
proc stopPimsmServer {TxRxArray {groupId 710} {create create} {destroy destroy}} \
{
    upvar $TxRxArray txRxArray

    set retCode 0

    set txRxList [getRxPorts txRxArray]
    if [issuePortGroupCommand stopPimsm txRxList noVerbose firstTimestamp $groupId $create $destroy] {
	    errorMsg "Error stoping PIM-SM"
	    set retCode 1
    }

    return $retCode
}



########################################################################
# Procedure: startOspfV3Server
#
# This command turns ON the protocol server to start OSPFV3
#
# Argument(s):
#	TxRxArray	    List of ports or array of ports
#
#   Results :       0 : No error found
#                   1 : Error found
# 
########################################################################
proc startOspfV3Server {TxRxArray {groupId 710} {create create} {destroy destroy}} \
{
    upvar $TxRxArray txRxArray

    set retCode 0

    set txRxList [getRxPorts txRxArray]
    if [issuePortGroupCommand startOspfV3 txRxList noVerbose firstTimestamp $groupId $create $destroy] {
	    errorMsg "Error starting OSPFV3"
	    set retCode 1
    }

    return $retCode
}


########################################################################
# Procedure: stopOspfV3Server
#
# This command turns ON the protocol server to stop OSPFV3
#
# Argument(s):
#	TxRxArray	    List of ports or array of ports
#
#   Results :       0 : No error found
#                   1 : Error found
#
########################################################################
proc stopOspfV3Server {TxRxArray {groupId 710} {create create} {destroy destroy}} \
{
    upvar $TxRxArray txRxArray

    set retCode 0

    set txRxList [getRxPorts txRxArray]
    if [issuePortGroupCommand stopOspfV3 txRxList noVerbose firstTimestamp $groupId $create $destroy] {
	    errorMsg "Error stoping OSPFV3"
	    set retCode 1
    }

    return $retCode
}


########################################################################
# Procedure: startIgmpServer
#
# This command turns ON the protocol server to start IGMP
#
# Argument(s):
#	TxRxArray	    List of ports or array of ports
#
#   Results :       0 : No error found
#                   1 : Error found
# 
########################################################################
proc startIgmpServer {TxRxArray {groupId 710} {create create} {destroy destroy}} \
{
    upvar $TxRxArray txRxArray

    set retCode 0

    set txRxList [getRxPorts txRxArray]
    if [issuePortGroupCommand startIgmp txRxList noVerbose firstTimestamp $groupId $create $destroy] {
	    errorMsg "Error starting Igmp"
	    set retCode 1
    }

    return $retCode
}


########################################################################
# Procedure: stopIgmpServer
#
# This command turns ON the protocol server to stop IGMP without sending any leaves
#
# Argument(s):
#	TxRxArray	    List of ports or array of ports
#
#   Results :       0 : No error found
#                   1 : Error found
#
########################################################################
proc stopIgmpServer {TxRxArray {groupId 710} {create create} {destroy destroy}} \
{
    upvar $TxRxArray txRxArray

    set retCode 0

    set txRxList [getRxPorts txRxArray]
    if [issuePortGroupCommand stopIgmp txRxList noVerbose firstTimestamp $groupId $create $destroy] {
	    errorMsg "Error stoping Igmp"
	    set retCode 1
    }

    return $retCode
}


########################################################################
# Procedure: transmitIgmpJoin
#
# This command turns ON the protocol server to issue Joins
#
# Argument(s):
#	PortArray	            either list of ports or array of ports
#
########################################################################
proc transmitIgmpJoin {TxRxArray { groupId 101064 } {create create} {destroy destroy}} \
{
    upvar $TxRxArray txRxArray

    set retCode 0

    set txRxList [getRxPorts txRxArray]

    if [issuePortGroupCommand transmitIgmpJoin txRxList noVerbose firstTimestamp $groupId $create $destroy] {
	    errorMsg "Error stopping transmitting igmp join for port group"
	    set retCode 1
    }

    return $retCode
}

########################################################################
# Procedure: transmitIgmpLeave
#
# This command turns OFF the protocol server to issue Joins
#
# Argument(s):
#	PortArray	            either list of ports or array of ports
#
########################################################################
proc transmitIgmpLeave {TxRxArray { groupId 042364 } {create create} {destroy destroy}} \
{
    upvar $TxRxArray txRxArray

    set retCode 0

    set txRxList [getRxPorts txRxArray]

    if [issuePortGroupCommand transmitIgmpLeave txRxList noVerbose firstTimestamp $groupId $create $destroy] {
	    errorMsg "Error stopping transmitting igmp join for port group"
	    set retCode 1
    }

    return $retCode
}

########################################################################
# Procedure: startStpServer
#
# This command turns ON the protocol server to start STP
#
# Argument(s):
#	TxRxArray	    List of ports or array of ports
#
#   Results :       0 : No error found
#                   1 : Error found
# 
########################################################################
proc startStpServer {TxRxArray {groupId 710} {create create} {destroy destroy}} \
{
    upvar $TxRxArray txRxArray

    set retCode 0

    set txRxList [getAllPorts txRxArray]
    if [issuePortGroupCommand startStp txRxList noVerbose firstTimestamp $groupId $create $destroy] {
	    errorMsg "Error starting STP"
	    set retCode 1
    }

    return $retCode
}


########################################################################
# Procedure: stopStpServer
#
# This command turns ON the protocol server to stop STP
#
# Argument(s):
#	TxRxArray	    List of ports or array of ports
#
#   Results :       0 : No error found
#                   1 : Error found
#
########################################################################
proc stopStpServer {TxRxArray {groupId 710} {create create} {destroy destroy}} \
{
    upvar $TxRxArray txRxArray

    set retCode 0

    set txRxList [getAllPorts txRxArray]
    if [issuePortGroupCommand stopStp txRxList noVerbose firstTimestamp $groupId $create $destroy] {
	    errorMsg "Error stoping STP"
	    set retCode 1
    }

    return $retCode
}

