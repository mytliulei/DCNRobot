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
#	05-05-03	DS
#
# Description: This file contains common procs used to configure features
#              via the MII ixTclHal api
#
##################################################################################


proc ixMiiConfigPreEmphasis           {chassis card port peSetting} {return [miiConfig::preEmphasis $chassis $card $port $peSetting]}
proc ixMiiConfigLossOfSignalThreshold {chassis card port threshold} {return [miiConfig::lossOfSignalThreshold $chassis $card $port $threshold]}
proc ixMiiConfigXgxsLinkMonitoring    {chassis card port enable}    {return [miiConfig::xgxsLinkMonitoring $chassis $card $port $enable]}
proc ixMiiConfigAlignRxDataClock      {chassis card port clock}     {return [miiConfig::alignRxDataClock $chassis $card $port $clock]}
proc ixMiiConfigReceiveEqualization   {chassis card port value}     {return [miiConfig::receiveEqualization $chassis $card $port $value]}
proc ixMiiConfigXauiOutput            {chassis card port enable}    {return [miiConfig::xauiOutput $chassis $card $port $enable]}
proc ixMiiConfigXauiSerialLoopback    {chassis card port enable}    {return [miiConfig::xauiSerialLoopback $chassis $card $port $enable]}
proc ixMiiConfigXgmiiParallelLoopback {chassis card port enable}    {return [miiConfig::xgmiiParallelLoopback $chassis $card $port $enable]}


namespace eval miiConfig {
}


########################################################################
# Procedure: preEmphasis
#
# This command configs the pre-emphasis bits for 10ge
#
# Arguments(s):
#   chassis
#   card
#   port
#   peSetting  <miiPreemphasis_none|miiPreemphasis_18|miiPreemphasis_38|miiPreemphasis_75>
#
########################################################################
proc miiConfig::preEmphasis {chassis card port peSetting} \
{
    switch $peSetting {
        75 {
            set peSetting $::miiPreemphasis_75
        }
        38 {
            set peSetting $::miiPreemphasis_38
        }
        18 {
            set peSetting $::miiPreemphasis_18
        }
    }            

    if {$peSetting > 3 || $peSetting < 0} {
        errorMsg "$peSetting not supported for preEmphasis"
        set retCode $::TCL_ERROR
        return $retCode
    }

    set peSetting [expr $peSetting << 14]

    return [setRegister $chassis $card $port $::miiRegister28 0xc000 $peSetting]
}


########################################################################
# Procedure: lossOfSignalThreshold
#
# This command configs the lossOfSignalThreshold bits for 10ge
#
# Arguments(s):
#   chassis
#   card
#   port
#   threshold  <miiPreemphasis_none|miiPreemphasis_18|miiPreemphasis_38|miiPreemphasis_75>
#
########################################################################
proc miiConfig::lossOfSignalThreshold {chassis card port threshold} \
{
    switch $threshold {
        160 {
            set threshold $::miiLossOfSignal160mv
        }
        240 {
            set threshold $::miiLossOfSignal240mv
        }
        200 {
            set threshold $::miiLossOfSignal200mv
        }
        120 {
            set threshold $::miiLossOfSignal120mv
        }
        80 {
            set threshold $::miiLossOfSignal80mv
        }
    }            

    if {$threshold > 4 || $threshold < 0} {
        errorMsg "$threshold not supported for lossOfSignalThreshold"
        set retCode $::TCL_ERROR
        return $retCode
    }

    set threshold [expr $threshold << 4]

    return [setRegister $chassis $card $port $::miiRegister29 0x0070 $threshold]
}


########################################################################
# Procedure: xgxsLinkMonitoring
#
# This command configs the xgxsLinkMonitoring bits for 10ge
#
# Arguments(s):
#   chassis
#   card
#   port
#   enable <$::TRUE|$::FALSE>
#
########################################################################
proc miiConfig::xgxsLinkMonitoring {chassis card port enable} \
{
    switch $enable {
        enable -
        ENABLE -
        true -
        TRUE {
            set enable $::TRUE
        }
        enable -
        ENABLE -
        false -
        FALSE {
            set enable $::FALSE
        }
        1 -
        0 {
        }
        default {
            errorMsg "XgxsLinkMonitoring enable must be bool <1|0>"
            set retCode $::TCL_ERROR
            return $retCode
        }
    }

    return [setRegister $chassis $card $port $::miiRegister29 0x0040 $enable]
}


########################################################################
# Procedure: alignRxDataClock
#
# This command configs the alignRxDataClock bits for 10ge
#
# Arguments(s):
#   chassis
#   card
#   port
#   clock
#
########################################################################
proc miiConfig::alignRxDataClock {chassis card port clock} \
{
    set retCode $::TCL_OK

    switch $clock "
        miiRecoveredClock -
        $::miiRecoveredClock {
            set clock $::miiRecoveredClock
        }
        miiLocalRefClock -
        $::miiLocalRefClock {
            set clock $::miiLocalRefClock
        }
        default {
            errorMsg [list Invalid clock $clock selected.]
            set retCode $::TCL_ERROR
            return $retCode
        }
    "
    return [setRegister $chassis $card $port $::miiRegister24 0x0001 $clock]
}


########################################################################
# Procedure: receiveEqualization
#
# This command configs the receiveEqualization bits for 10ge
#
# Arguments(s):
#   chassis
#   card
#   port
#   value
#
########################################################################
proc miiConfig::receiveEqualization {chassis card port value} \
{
    if {$value > 15 || $value < 0} {
        errorMsg "$value not supported for receiveEqualization"
        set retCode $::TCL_ERROR
        return $retCode
    }

    return [setRegister $chassis $card $port $::miiRegister28 0x000F $value]
}


########################################################################
# Procedure: xauiOutput
#
# This command configs the xauiOutput bits for 10ge
#
# Arguments(s):
#   chassis
#   card
#   port
#   enable <$::TRUE|$::FALSE>
#
########################################################################
proc miiConfig::xauiOutput {chassis card port enable} \
{
    switch $enable {
        1 -
        enable -
        ENABLE -
        true -
        TRUE {
            set enable 0xAAAA
        }
        0 -
        enable -
        ENABLE -
        false -
        FALSE {
            set enable 0
        }
        default {
            errorMsg "XAUI Output enable must be bool <1|0>"
            set retCode $::TCL_ERROR
            return $retCode
        }
    }

    return [setRegister $chassis $card $port $::miiRegister30 0xAAAA $enable]
}


########################################################################
# Procedure: xauiSerialLoopback
#
# This command enable/disables the xauiSerialLoopback bits for 10ge
#
# Arguments(s):
#   chassis
#   card
#   port
#   enable
#
########################################################################
proc miiConfig::xauiSerialLoopback {chassis card port enable} \
{
    set retCode $::TCL_ERROR

    switch $enable {
        enable -
        ENABLE -
        true -
        TRUE {
            set enable $::TRUE
        }
        enable -
        ENABLE -
        false -
        FALSE {
            set enable $::FALSE
        }
        1 -
        0 {
        }
        default {
            errorMsg "XAUISerialLoopback enable must be bool <1|0>"
            set retCode $::TCL_ERROR
            return $retCode
        }
    }

    # If Serial loopback selected:
    #       - set bit 14 of register 0. If it's not selected, clear that bit
    #       - clear bits 0-3 and set bits 8-11 for register 23.
    if {$enable} {
        set reg23   0x0F00
    } else {
        set reg23   0x0000
    }

    if {[setRegister $chassis $card $port $::miiRegister23 0x0F0F $reg23] == $::TCL_OK} {        
        set bits [expr $enable << 14]
        if {[setRegister $chassis $card $port $::miiControl 0x4000 $bits noGet] == $::TCL_OK} {
            set retCode $::TCL_OK
        }
    }

    return $retCode
}


########################################################################
# Procedure: xgmiiParallelLoopback
#
# This command enable/disables the xgmiiParallelLoopback bits for 10ge
#
# Arguments(s):
#   chassis
#   card
#   port
#   loopback
#
########################################################################
proc miiConfig::xgmiiParallelLoopback {chassis card port enable} \
{
    switch $enable {
        enable -
        ENABLE -
        true -
        TRUE {
            set enable $::TRUE
        }
        enable -
        ENABLE -
        false -
        FALSE {
            set enable $::FALSE
        }
        1 -
        0 {
        }
        default {
            errorMsg "XGMIIParallelLoopback enable must be bool <1|0>"
            set retCode $::TCL_ERROR
            return $retCode
        }
    }

    if {$enable} {
        set reg23   0x000F
    } else {
        set reg23   0x0000
    }

    if {[setRegister $chassis $card $port $::miiControl 0x4000 0x0000] == $::TCL_OK} {
        if {[setRegister $chassis $card $port $::miiRegister23 0x0F0F $reg23 noGet] == $::TCL_OK} {        
            set retCode $::TCL_OK
        }
    }
    return $retCode
}


########################################################################
# Procedure: isXauiSerialLoopback
#
# This command checks the xauiSerialLoopback bits for 10ge
#
# Arguments(s):
#   chassis
#   card
#   port
#
# Return code:
#   true if enabled
#
########################################################################
proc miiConfig::isXauiSerialLoopback {chassis card port} \
{
    return [expr [getRegister $chassis $card $port $::miiControl] & 0x4000 && \
                 [getRegister $chassis $card $port $::miiRegister23 noGet] & 0x0f00]

}


########################################################################
# Procedure: isXgmiiParallelLoopback
#
# This command checks the isXgmiiParallelLoopback bits for 10ge
#
# Arguments(s):
#   chassis
#   card
#   port
#
# Return code:
#   true if enabled
#
########################################################################
proc miiConfig::isXgmiiParallelLoopback {chassis card port} \
{
    if {[expr [getRegister $chassis $card $port $::miiRegister23] & 0x000F] == 0x000f} {
        set retCode $::true
    } else {
        set retCode $::false
    }

    return $retCode
}


########################################################################
# Procedure: setRegister
#
# This command sets the register for 10ge - PRIVATE
#
# Arguments(s):
#   chassis
#   card
#   port
#   register    <ie., $::register28>
#   bitMask     <ie., 0xc000>
#   get         default: true; sometimes you don't want to 'get' first...
#
########################################################################
proc miiConfig::setRegister {chassis card port register bitMask value {get true}} \
{
    set retCode $::TCL_OK

    if {$get == "true"} {
        if [mii get $chassis $card $port] {
            errorMsg "Error getting mii for port [getPortId $chassis $card $port]"
            set retCode $::TCL_ERROR
        }
    }

    if [mii selectRegister $register] {
        errorMsg "Error selecting register $register"
        set retCode $::TCL_ERROR
    }

    set registerValue [format "0x%s" [mii cget -registerValue]]
    mii config -registerValue [format %04x [expr {$value & $bitMask} | {$registerValue & ~$bitMask}]]
    
    if [mii set $chassis $card $port] {
        errorMsg "Error setting mii for port [getPortId $chassis $card $port]"
        set retCode $::TCL_ERROR
    }
   
    return $retCode
}



########################################################################
# Procedure: getRegister
#
# This command gets the register for 10ge - PRIVATE
#
# Arguments(s):
#   chassis
#   card
#   port
#   register    <ie., $::register28>
#   get         default: true; sometimes you don't want to 'get' first...
#
# Returns:
#   value of register as hex number
#
########################################################################
proc miiConfig::getRegister {chassis card port register {get true}} \
{
    set value 0x0000

    if {$get == "true"} {
        if [mii get $chassis $card $port] {
            errorMsg "Error getting mii for port [getPortId $chassis $card $port]"
            set retCode $::TCL_ERROR
        }
    }

    if [mii selectRegister $register] {
        errorMsg "Error selecting register $register"
        return $value
    }

    return [format "0x%s" [mii cget -registerValue]]
} 