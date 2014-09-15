#############################################################################################
#
# highLevelAPI.tcl  
#
# Copyright © 1997-2004 by IXIA.
# All Rights Reserved.
#
#   Revision Log:
#   05-06-2004  EM  Genesis

#############################################################################################



########################################################################
# Procedure:   ixStartBGP4
#
# Description: This command turns ON the protocol server to start BGP4
#
# Arguments:
#    TxRxArray - either list of ports or array of ports
#
# Returns:     The return code from stopBgp4Server
########################################################################
proc ixStartBGP4 {TxRxArray} \
{
    upvar $TxRxArray        txRxArray

    return [startBgp4Server txRxArray]
}


########################################################################
# Procedure:   ixStopBGP4
#
# Description: This command turns ON the protocol server to stop BGP4
#
# Arguments:
#    TxRxArray - either list of ports or array of ports
#
# Returns:     The return code from stopBgp4Server
########################################################################
proc ixStopBGP4 {TxRxArray} \
{
    upvar $TxRxArray       txRxArray

    return [stopBgp4Server txRxArray]
}


########################################################################
# Procedure:   ixStartOspf
#
# Description: This command turns ON the protocol server to start ospf
#
# Arguments:
#    TxRxArray - either list of ports or array of ports
#
# Returns:     The return code from startOspfServer
########################################################################
proc ixStartOspf {TxRxArray} \
{
    upvar $TxRxArray        txRxArray

    return [startOspfServer txRxArray]
}


########################################################################
# Procedure:   ixStopOspf
#
# Description: This command turns ON the protocol server to stop ospf
#
# Arguments:
#    TxRxArray - either list of ports or array of ports
#
# Returns:     The return code from stopOspfServer
########################################################################
proc ixStopOspf {TxRxArray} \
{
    upvar $TxRxArray       txRxArray

    return [stopOspfServer txRxArray]
}


########################################################################
# Procedure:   ixStartIsis
#
# Description: This command turns ON the protocol server to start Isis
#
# Arguments:
#    TxRxArray - either list of ports or array of ports
#
# Returns:     The return code from startIsisServer
########################################################################
proc ixStartIsis {TxRxArray} \
{
    upvar $TxRxArray        txRxArray

    return [startIsisServer txRxArray]
}


########################################################################
# Procedure:   ixStopIsis
#
# Description: This command turns ON the protocol server to stop Isis
#
# Arguments:
#   TxRxArray - either list of ports or array of ports
#
# Returns:     The return code from stopIsisServer
########################################################################
proc ixStopIsis {TxRxArray} \
{
    upvar $TxRxArray       txRxArray

    return [stopIsisServer txRxArray]
}


########################################################################
# Procedure:   ixStartRsvp
#
# Description: This command turns ON the protocol server to start Rsvp
#
# Arguments:
#    TxRxArray - either list of ports or array of ports
#
# Returns:     The return code from startRsvpServer
########################################################################
proc ixStartRsvp {TxRxArray} \
{
    upvar $TxRxArray        txRxArray

    return [startRsvpServer txRxArray]
}


########################################################################
# Procedure:   ixStopRsvp
#
# Description: This command turns ON the protocol server to stop Rsvp
#
# Arguments:
#    TxRxArray - either list of ports or array of ports
#
# Returns:     The return code from stopRsvpServer
########################################################################
proc ixStopRsvp {TxRxArray} \
{
    upvar $TxRxArray       txRxArray

    return [stopRsvpServer txRxArray]
}


########################################################################
# Procedure:   ixStartRip
#
# Description: This command turns ON the protocol server to start Rip
#
# Arguments:
#    TxRxArray - either list of ports or array of ports
#
# Returns:     The return code from startRipServer
########################################################################
proc ixStartRip {TxRxArray} \
{
    upvar $TxRxArray       txRxArray

    return [startRipServer txRxArray]
}


########################################################################
# Procedure:   ixStopRip
#
# Description: This command turns ON the protocol server to stop Rip
#
# Arguments:
#    TxRxArray - either list of ports or array of ports
#                     
# Returns:     The return code from stopRipServer
########################################################################
proc ixStopRip {TxRxArray} \
{
    upvar $TxRxArray      txRxArray

    return [stopRipServer txRxArray]
}

########################################################################
# Procedure:   ixStartLdp
#
# Description: This command turns ON the protocol server to start LDP
#
# Arguments:
#    TxRxArray - either list of ports or array of ports
#
# Returns:     The return code from startLdpServer
########################################################################
proc ixStartLdp {TxRxArray} \
{
    upvar $TxRxArray       txRxArray

    return [startLdpServer txRxArray]
}


########################################################################
# Procedure:   ixStopLdp
#
# Description: This command turns ON the protocol server to stop LDP
#
# Arguments:
#    TxRxArray - either list of ports or array of ports
#                     
# Returns:     The return code from stopLdpServer
########################################################################
proc ixStopLdp {TxRxArray} \
{
    upvar $TxRxArray      txRxArray

    return [stopLdpServer txRxArray]
}

########################################################################
# Procedure:   ixStartRipng
#
# Description: This command turns ON the protocol server to start Ripng
#
# Arguments:
#    TxRxArray - either list of ports or array of ports
#
# Returns:     The return code from startRipngServer
########################################################################
proc ixStartRipng {TxRxArray} \
{
    upvar $TxRxArray       txRxArray

    return [startRipngServer txRxArray]
}


########################################################################
# Procedure:   ixStopRipng
#
# Description: This command turns ON the protocol server to stop Ripng
#
# Arguments:
#    TxRxArray - either list of ports or array of ports
#                     
# Returns:     The return code from stopRipngServer
########################################################################
proc ixStopRipng {TxRxArray} \
{
    upvar $TxRxArray      txRxArray

    return [stopRipngServer txRxArray]
}

########################################################################
# Procedure:   ixStartMld
#
# Description: This command turns ON the protocol server to start MLD
#
# Arguments:
#    TxRxArray - either list of ports or array of ports
#
# Returns:     The return code from startMldServer
########################################################################
proc ixStartMld {TxRxArray} \
{
    upvar $TxRxArray       txRxArray

    return [startMldServer txRxArray]
}


########################################################################
# Procedure:   ixStopMld
#
# Description: This command turns ON the protocol server to stop MLD
#
# Arguments:
#    TxRxArray - either list of ports or array of ports
#                     
# Returns:     The return code from stopMldServer
########################################################################
proc ixStopMld {TxRxArray} \
{
    upvar $TxRxArray      txRxArray

    return [stopMldServer txRxArray]
}



########################################################################
# Procedure:   ixStartPimsm
#
# Description: This command turns ON the protocol server to start PIM-SM
#
# Arguments:
#    TxRxArray - either list of ports or array of ports
#
# Returns:     The return code from startPimsmServer
########################################################################
proc ixStartPimsm {TxRxArray} \
{
    upvar $TxRxArray       txRxArray

    return [startPimsmServer txRxArray]
}


########################################################################
# Procedure:   ixStopPimsm
#
# Description: This command turns ON the protocol server to stop PIM-SM
#
# Arguments:
#    TxRxArray - either list of ports or array of ports
#                     
# Returns:     The return code from stopPimsmsServer
########################################################################
proc ixStopPimsm {TxRxArray} \
{
    upvar $TxRxArray      txRxArray

    return [stopPimsmServer txRxArray]
}


########################################################################
# Procedure:   ixStartOspfV3
#
# Description: This command turns ON the protocol server to start OSPFV3
#
# Arguments:
#    TxRxArray - either list of ports or array of ports
#
# Returns:     The return code from startOspfV3Server
########################################################################
proc ixStartOspfV3 {TxRxArray} \
{
    upvar $TxRxArray       txRxArray

    return [startOspfV3Server txRxArray]
}


########################################################################
# Procedure:   ixStopOspfV3
#
# Description: This command turns ON the protocol server to stop OSPFV3
#
# Arguments:
#    TxRxArray - either list of ports or array of ports
#                     
# Returns:     The return code from stopOspfV3Server
########################################################################
proc ixStopOspfV3 {TxRxArray} \
{
    upvar $TxRxArray      txRxArray

    return [stopOspfV3Server txRxArray]
}


########################################################################
# Procedure:   ixStartIgmp
#
# Description: This command turns ON the protocol server to start Igmp
#
# Arguments:
#    TxRxArray - either list of ports or array of ports
#
# Returns:     The return code from startIgmpServer
########################################################################
proc ixStartIgmp {TxRxArray} \
{
    upvar $TxRxArray       txRxArray

    return [startIgmpServer txRxArray]
}


########################################################################
# Procedure:   ixStopIgmp
#
# Description: This command turns ON the protocol server to stop Igmp
#				without sending any leaves.
#
# Arguments:
#    TxRxArray - either list of ports or array of ports
#                     
# Returns:     The return code from stopIgmpServer
########################################################################
proc ixStopIgmp {TxRxArray} \
{
    upvar $TxRxArray      txRxArray

    return [stopIgmpServer txRxArray]
}


########################################################################
# Procedure: ixTransmitIgmpJoin
#
# This command sends IGMP report message to the ports in the TxRxArray
#
# Argument(s):
#   TxRxArray - list or array of RX ports to change
#   groupId   - groupId Number
#   create    - create set to create for new port group
#   destroy   - destroy set to destroy to clean up the port group when
#               comnmand complete
#
########################################################################
proc ixTransmitIgmpJoin {TxRxArray { groupId 101064 } {create create} {destroy destroy}} \
{
  upvar $TxRxArray txRxArray

  return [transmitIgmpJoin txRxArray $groupId $create $destroy]

}

########################################################################
# Procedure: ixTransmitIgmpLeave
#
# This command sends IGMP leave message to the ports in the TxRxArray
#
# Argument(s):
#   TxRxArray - list or array of RX ports to change
#   groupId   - groupId Number
#   create    - create set to create for new port group
#   destroy   - destroy set to destroy to clean up the port group when
#               comnmand complete
#
########################################################################
proc ixTransmitIgmpLeave {TxRxArray { groupId 101064 } {create create} {destroy destroy}} \
{
  upvar $TxRxArray txRxArray

  return [transmitIgmpLeave txRxArray $groupId $create $destroy]

}

########################################################################
# Procedure:   ixStartStp
#
# Description: This command turns ON the protocol server to start STP
#
# Arguments:
#    TxRxArray - either list of ports or array of ports
#
# Returns:     The return code from startOspfV3Server
########################################################################
proc ixStartStp {TxRxArray} \
{
    upvar $TxRxArray       txRxArray

    return [startStpServer txRxArray]
}


########################################################################
# Procedure:   ixStopStp
#
# Description: This command turns ON the protocol server to stop STP
#
# Arguments:
#    TxRxArray - either list of ports or array of ports
#                     
# Returns:     The return code from stopOspfV3Server
########################################################################
proc ixStopStp {TxRxArray} \
{
    upvar $TxRxArray      txRxArray

    return [stopStpServer txRxArray]
}

