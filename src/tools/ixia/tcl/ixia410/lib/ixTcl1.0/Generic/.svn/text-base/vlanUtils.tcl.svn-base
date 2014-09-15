########################################################################
# Version 4.10	$Revision: 11 $
# $Date: 9/30/02 4:00p $
# $Author: Mgithens $
#
# $Workfile: vlanUtils.tcl $
#
#   Copyright © 1997 - 2005 by IXIA
#   All Rights Reserved.
#
#	Revision Log:
#	11-02-2001	DS
#
# Description: This file contains common vlan utilities
#
########################################################################

proc vlanUtilsSetDefault {} {
    set ::vlanUtils::untaggedPortList ""
}


namespace eval vlanUtils {} {
    vlanUtilsSetDefault
}


########################################################################
# Procedure: vlanUtils::setPortTagged
#
# Description: Sets a boolean indicated whether this port is a vlan-tagged port
#
# Arguments:
#   chassis - The number of the chassis
#   card - The number of the card
#   port - The number of the port
#
# Returns: TCL_OK on completion
########################################################################
proc vlanUtils::setPortTagged {chassis card port} \
{
    variable untaggedPortList

    set retCode $::TCL_OK

    if {[catch {lsearch $untaggedPortList [list $chassis $card $port]} found]} {
        set found -1
    }

    if {$found >= 0} {
        set untaggedPortList [lreplace $untaggedPortList $found $found]
    }

    return $retCode
}


########################################################################
# Procedure: vlanUtils::setTagged
#
# Description: Sets a boolean indicated whether the ports in this list are vlan-tagged ports
#
# Arguments: portList - A list of ports to tag.  A port identifier is of the list form: chassis card port.
#
# Returns: TCL_OK on success and TCL_ERROR on failure
########################################################################
proc vlanUtils::setTagged {portList} \
{
    set retCode $::TCL_OK

    foreach taggedPort $portList {
        scan $taggedPort "%d %d %d" c l p

        if {[setPortTagged $c $l $p]} {
            set retCode $::TCL_ERROR
            break
        }
    }

    return $retCode
}


########################################################################
# Procedure: vlanUtils::setPortUntagged
#
# Description: Sets a boolean indicated whether this port is a vlan-tagged port
#
# Arguments:
#   chassis - The number of the chassis for the port
#   card - The number of the card for the port
#   port - The number of the port
#
# Returns: TCL_OK on success
########################################################################
proc vlanUtils::setPortUntagged {chassis card port} \
{
    variable untaggedPortList

    set retCode $::TCL_OK

    if {[catch {lsearch $untaggedPortList [list $chassis $card $port]} found]} {
        set found -1
    }

    if {$found < 0} {
        lappend untaggedPortList [list $chassis $card $port]
    }

    return $retCode
}


########################################################################
# Procedure: vlanUtils::setUntagged
#
# Description: Sets a boolean indicated whether the ports in this list are NOT vlan-tagged ports
#
# Arguments: portList - A list of ports to tag.  A port identifier is of the list form: chassis card port.
#
# Returns: TCL_OK on success and TCL_ERROR on failure
########################################################################
proc vlanUtils::setUntagged {portList} \
{
    set retCode $::TCL_OK

    foreach taggedPort $portList {
        scan $taggedPort "%d %d %d" c l p

        if {[setPortUntagged $c $l $p]} {
            set retCode $::TCL_ERROR
            break
        }
    }

    return $retCode
}


########################################################################
# Procedure: vlanUtils::isPortTagged
#
# Description: Returns a boolean indicated whether this port is a vlan-tagged port
#
# Arguments:
#   chassis - The number of the chassis for the port
#   card - The number of the card for the port
#   port - The number of the port
#
# Returns: true if the port is tagged and false if it is not.
########################################################################
proc vlanUtils::isPortTagged {chassis card port} \
{
    variable untaggedPortList

    if {[catch {lsearch $untaggedPortList [list $chassis $card $port]} found]} {
        set tagged $::true
    } else {

        if {$found < 0} {
            set tagged $::true
        } else {
            set tagged $::false
        }
    }

    return $tagged
}


########################################################################
# Procedure: emptyUntaggedPortList
#
# Description: Reset the untagged port list to a empty list.
#
# Arguments:
#
# Returns:
########################################################################
proc vlanUtils::emptyUntaggedPortList {} \
{
    variable untaggedPortList

    set untaggedPortList ""
}


########################################################################
# Procedure: setPortTagged
#
# Description: Sets a boolean indicated whether this port is a vlan-tagged port
#
# Arguments:
#   chassis - The number of the chassis
#   card - The number of the card
#   port - The number of the port
#
# Returns: TCL_OK on completion
########################################################################
proc setPortTagged {chassis card port} \
{
    return [vlanUtils::setPortTagged $chassis $card $port]
}


########################################################################
# Procedure: setTagged
#
# Description: Sets a boolean indicated whether the ports in this list are vlan-tagged ports
#
# Arguments: portList - A list of ports to tag.  A port identifier is of the list form: chassis card port.
#
# Returns: TCL_OK on success and TCL_ERROR on failure
########################################################################
proc setTagged {portList} \
{
    return [vlanUtils::setTagged $portList]
}


########################################################################
# Procedure: setPortUntagged
#
# Description: Sets a boolean indicated whether this port is a vlan-tagged port
#
# Arguments:
#   chassis - The number of the chassis for the port
#   card - The number of the card for the port
#   port - The number of the port
#
# Returns: TCL_OK on success
########################################################################
proc setPortUntagged {chassis card port} \
{
    return [vlanUtils::setPortUntagged $chassis $card $port]
}


########################################################################
# Procedure: setUntagged
#
# Description: Sets a boolean indicated whether the ports in this list are NOT vlan-tagged ports
#
# Arguments: portList - A list of ports to tag.  A port identifier is of the list form: chassis card port.
#
# Returns: TCL_OK on success and TCL_ERROR on failure
########################################################################
proc setUntagged {portList} \
{
    return [vlanUtils::setUntagged $portList]
}


########################################################################
# Procedure: isPortTagged
#
# Description: Returns a boolean indicated whether this port is a vlan-tagged port
#
# Arguments:
#   chassis - The number of the chassis for the port
#   card - The number of the card for the port
#   port - The number of the port
#
# Returns: true if the port is tagged and false if it is not.
########################################################################
proc isPortTagged {chassis card port} \
{
    return [vlanUtils::isPortTagged $chassis $card $port]
}


########################################################################
# Procedure: getUntaggedPortList
#
# Description: Returns the list of untagged ports
#
# Arguments:
#
# Returns: The list of untagged ports.
########################################################################
proc getUntaggedPortList {} \
{
    return $::vlanUtils::untaggedPortList
}


########################################################################
# Procedure: emptyUntaggedPortList
#
# Description: Reset the untagged port list to a empty list.
#
# Arguments:
#
# Returns:
########################################################################
proc emptyUntaggedPortList {} \
{
    vlanUtils::emptyUntaggedPortList
}