##################################################################################
# Version 4.10	$Revision: 17 $
# $Date: 9/30/02 3:51p $
# $Author: Mgithens $
#
# $Workfile: addressTableUtils.tcl $ - Address Table Utils
#
#   Copyright © 1997 - 2005 by IXIA
#   All Rights Reserved.
#
#	Revision Log:
#	04/05/2000	DS
#
# Description: This file contains common procs used for ipAddressTable
#              manipulation
#
##################################################################################


########################################################################
# Procedure: ipAddressSetDefault
#
# This command sets the ipAddressTable & iAddressTableItem to defaults
#
#
########################################################################
proc ipAddressSetDefault {} \
{
    ipAddressTable setDefault
    ipAddressTableItem setDefault
}


########################################################################
# Procedure: updateIpAddressTable
#
# This command updates the ipAddressTable w/current ip & port objects
#
# Arguments(s):
#   chassis
#   card
#   port
#
########################################################################
proc updateIpAddressTable {chassis card port {write nowrite}} \
{
    set retCode 0

    if [ip get $chassis $card $port] {
        errorMsg "Error getting ip on port $chassis $card $port"
        set retCode 1
    }

    if [port get $chassis $card $port] {
        errorMsg "Error getting port $chassis $card $port"
        set retCode 1
    }

    ipAddressTableItem config -fromIpAddress            [ip cget -sourceIpAddr]
    ipAddressTableItem config -gatewayIpAddress         [ip cget -destDutIpAddr]
    ipAddressTableItem config -fromMacAddress           [port cget -MacAddress]
    ipAddressTableItem config -numAddresses             [port cget -numAddresses]

    if [ipAddressTableItem set] {
        errorMsg "Error setting ipAddressTableItem"
        set retCode 1
    }

    if [ipAddressTable addItem] {
        errorMsg "Error adding item to ipAddressTable"
        set retCode 1
    }

    ipAddressTable config -defaultGateway               [ipAddressTableItem cget -gatewayIpAddress]
    if [ipAddressTable set $chassis $card $port] {
        errorMsg "Error setting ipAddressTable on port $chassis $card $port"
        set retCode 1
    }

    if {$write == "write" && $retCode == 0} {
        if [protocolServer write $chassis $card $port] {
            errorMsg "Error writing protocol server on $chassis $card $port"
            set retCode 1
        }
    }

    return $retCode
}
