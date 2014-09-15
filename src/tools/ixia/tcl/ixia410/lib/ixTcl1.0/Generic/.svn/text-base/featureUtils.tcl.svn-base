########################################################################
# Version 4.10	$Revision: 5 $
# $Date: 10/24/02 6:07p $
# $Author: Hasmik $
#
# $Workfile: featureUtils.tcl $ - contains utils to validate features
#
#   Copyright © 1997 - 2005 by IXIA
#   All Rights Reserved.
#
#	Revision Log:
#	07-31-2002	DS	Genesis
#
# Description: This file contains helper utilities that check for 
#              specific features on a port or portArray.
#
########################################################################


########################################################################
# Procedure: IsPortUSBMode
#
# This command checks port modes against USB port mode 
#
########################################################################
proc IsPortUSBMode {c l p} \
{
    set retCode $::false

    if { [port getInterface $c $l $p] == $::interfaceUSB } {
        if [port get $c $l $p] {
            errorMsg "Error getting port [getPortId $c $l $p]"
        } else {
            set portMode  [port cget -portMode]

            if {$portMode == $::portUsbUsb} {
                set retCode $::true
            }
        }
    }

    return $retCode
}

########################################################################
# Procedure: IsPOSPort
#
# This command checks the port if it is a POS port
#
########################################################################
proc IsPOSPort {c l p} \
{
    return [port isActiveFeature $c $l $p $::portFeaturePos]
}


########################################################################
# Procedure: Is10GigEPort
#
# This command checks the port if it is a 10GigE port
#
########################################################################
proc Is10GigEPort {c l p} \
{
    set retCode 0
    
    set interfaceType [port getInterface $c $l $p]

    if {$interfaceType == $::interface10GigE } {
        set retCode 1
    }


    return $retCode
}


########################################################################
# Procedure: IsGigabitPort
#
# This command checks card type against Gigabit card types
#
########################################################################
proc IsGigabitPort {c l p} \
{
    set retCode 0

    set interfaceType [port getInterface $c $l $p]
    if {$interfaceType == $::interfaceGigabit} {
        set retCode 1
    }

    return $retCode
}


########################################################################
# Procedure: any10100Ports
#
# This command check if there are any 10/100 cards in the map.
# Returns 1 if there are 10/100 cards in the map.
#
# Argument(s):
#
########################################################################
proc any10100Ports {TxRxArray} \
{
     upvar $TxRxArray txRxArray

    return [anyPortsBySpeed txRxArray {10 100}]
}


########################################################################
# Procedure: anyGigPorts
#
# This command checks if there are any gig cards in the map
#
# Argument(s):
#
########################################################################
proc anyGigPorts {TxRxArray} \
{
    upvar $TxRxArray txRxArray

    return [anyPortsBySpeed txRxArray 1000]
}


########################################################################
# Procedure: anyOc48Ports
#
# This command checks if there are any oc48 cards in the map
#
# Argument(s):
#
########################################################################
proc anyOc48Ports {TxRxArray} \
{
    upvar $TxRxArray txRxArray

    return [anyPortsByInterface txRxArray interfaceOc48]
}


########################################################################
# Procedure: anyOc192Ports
#
# This command checks if there are any oc192 cards in the map
#
# Argument(s):
#
########################################################################
proc anyOc192Ports {TxRxArray} \
{
    upvar $TxRxArray txRxArray

    return [anyPortsByInterface txRxArray interfaceOc192]
}


########################################################################
# Procedure: anyPortsByInterface
#
# This command checks if there are any ports of that interface type
#
# Argument(s):
#
########################################################################
proc anyPortsByInterface {TxRxArray interface} \
{
    upvar $TxRxArray txRxArray

    global $interface

    set retCode 0
    
    foreach portMap [getAllPorts txRxArray] {
        scan $portMap "%d %d %d" c l p
        if {[port getInterface $c $l $p] == [set $interface]} {
            set retCode 1
            break
        }
    }

    return $retCode
}


########################################################################
# Procedure: anyPortsBySpeed
#
# This command checks if there are any ports of that SPEED(list)
#
# Argument(s):
#
########################################################################
proc anyPortsBySpeed {TxRxArray speed} \
{
    upvar $TxRxArray txRxArray

    set retCode 0
    
    foreach portMap [getAllPorts txRxArray] {
        scan $portMap "%d %d %d" c l p

        if {[lsearch $speed [stat getLineSpeed $c $l $p]] >= 0} {
            set retCode 1
            break
        }
    }

    return $retCode
}


########################################################################
# Procedure: supportsProtocolServer
#
# This command checks if all the ports support protocol server
#
# Argument(s):
#   TxRxArray   - port array or list
#
# Return:
#   TRUE if all ports support protocol server
#
########################################################################
proc supportsProtocolServer {TxRxArray} \
{
    upvar $TxRxArray txRxArray

    return [isValidFeature txRxArray $::portFeatureProtocols]
}


########################################################################
# Procedure: supportsPortCPU
#
# This command checks if all the ports are portCPU-based
#
# Argument(s):
#   TxRxArray   - port array or list
#
# Return:
#   TRUE if all ports are portCPU-based
#
########################################################################
proc supportsPortCPU {TxRxArray} \
{
    upvar $TxRxArray txRxArray

    return [isValidFeature txRxArray $::portFeatureLocalCPU]
}


########################################################################
# Procedure:    isValidFeature
#
# Description:  TRUE/FALSE:  Is a feature valid for the ports in the given 
#               port array?
#
# Arguments:    PortArray    array, map or list of ports to check feature on
#               featureList  one or more features to validate port against
#
# Returns:      $::true is valid, else $::false
#
########################################################################
proc isValidFeature {PortArray featureList} \
{
    upvar $PortArray portArray

    set retCode $::true

    foreach portMap [getAllPorts portArray] {
        scan $portMap "%d %d %d" c l p
        
        foreach feature $featureList {
            if {![port isValidFeature $c $l $p $feature]} {
                set retCode $::false
                break
            }
        }
    }

    return $retCode
}


########################################################################
# Procedure: isPacketFlowMode
#
# This command checks if the port is in packet flow mode 
#
# Argument(s):
#
########################################################################
proc isPacketFlowMode {c l p} \
{
    return [port isActiveFeature $c $l $p $::portFeaturePacketFlows]
}


########################################################################
# Procedure: isAdvancedStreamSchedulerMode
#
# This command checks if the port is in packet flow mode 
#
# Argument(s):
#
########################################################################
proc isAdvancedStreamSchedulerMode {c l p} \
{
    return [port isActiveFeature $c $l $p $::portTxModeAdvancedScheduler]
}