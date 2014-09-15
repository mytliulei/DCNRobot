##################################################################################
# Version 4.10   $Revision: 25 $
# $Author: Mgithens $
#
# $Workfile: chassisUtils.tcl $
#
#   Copyright © 1997 - 2005 by IXIA.
#   All Rights Reserved.
#
#       Revision Log:
#       10/16/2000      DS      Genesis
#
# Description: This file contains general chassis management/connection procs.
#
##################################################################################


########################################################################################
# Procedure: connectToChassis
#
# Description: Attempts to connect to all chassis given in the list
#
# Arguments: chassisList - A list of chassis names
#            cableLength - Optional.  A corresponding list of cable lengths for the given chassis
#            chassisIdList - Optional.  A corresponding list of chassis id numbers for the given chassis
#            chassisSeqList - Optional.  A corresponding list of sequence numbers for the given chassis
#
# Returns: A return code of 0 for success and different integers representing errors
########################################################################################
proc connectToChassis {chassisList {cableLengthList cable3feet} {chassisIdList ""} {chassisSeqList ""}} \
{
    set retCode 0

    # If either of the id list or sequence list contains less items than the chassis list, 
    # we will recreate these lists on our own starting from the number 1 until there are 
    # enough items in the lists.
    set numChassis [llength $chassisList]
    if {[llength $chassisIdList] < $numChassis} {
        catch {unset chassisIdList}
        for {set id 1} {$id <= $numChassis} {incr id} {
            lappend chassisIdList $id
        }
    }

    if {[llength $chassisSeqList] < $numChassis} {
        catch {unset chassisSeqList}
        for {set sequence 1} {$sequence <= $numChassis} {incr sequence} {
            lappend chassisSeqList $sequence
        }
    }

    # If the cable length list contains only one item, then that value will be used for all lengths.
    # If the list is greater than one, but less than the number of chassis, then cable3feet will be used
    # to complete the list.
    if {([llength $cableLengthList] == 1) && ($numChassis != 1)} {
        set cableLength $cableLengthList
        catch {unset cableLengthList}
        foreach item $chassisList {
            lappend cableLengthList $cableLength
        }
    } elseif {[llength $cableLengthList] < $numChassis} {
        while {[llength $cableLengthList] < $numChassis} {
            lappend cableLengthList "cable3feet"
        }
    }

    foreach chassis $chassisList chassisId $chassisIdList sequence $chassisSeqList cableLength $cableLengthList {
        logMsg "Connecting to Chassis $chassisId: $chassis ..."

        # Connect may not work the first time. So try a few times until a connect succeeds
        set maxConnectRetries [advancedTestParameter cget -maxConnectRetries]
        if {$maxConnectRetries < 1} {
            set maxConnectRetries 1
        }

        set retAddCode 1
        for {set connectNum 1} {$connectNum <= $maxConnectRetries && $retAddCode != 0} {incr connectNum} {

            set connectChassisFlag [getConnectChassisFlag]

            if { ![string compare $connectChassisFlag "stop"] } {
                #
                # Progress dialog is canceled. Connecting to chassis should stop.
                #
                setConnectChassisFlag "continue"
                set retAddCode 4
                break
            }

            set retAddCode [chassis add $chassis]
            switch $retAddCode "
                $::TCL_OK {
                    continue
                }
                $::ixTcl_versionMismatch {
                    # if it is a version mismatch, do not bother going any further...
                    chassis del $chassis
                    logMsg \"Error: Version mismatch between IxServer and Tcl Client\"
                    break
                }
                $::ixTcl_HardwareConflict {
                    # if it is a serial number conflict, do not bother going any further...
                    chassis del $chassis
                    logMsg \"Error: Hardware conflict detected. Please call customer support!\"
                    break
                }
                default {                                  
                    chassis del $chassis
                    logMsg \"Error connecting to chassis. Retrying $connectNum of $maxConnectRetries retries ..\"
                    after 20
                    update
                }
            "
        }

        # dump out here if there was an error connecting to one of the chassis
        switch $retAddCode "
            $::TCL_OK {
            }
            $::TCL_ERROR {
                logMsg \"Error connecting to chassis $chassis\"
                return $retAddCode
            }
            $::ixTcl_chassisTimeout {
                logMsg \"Timeout connecting to chassis $chassis. Try Again!\"
                return $retAddCode
            }
            4 {
                logMsg \"Connection was interrupted by user!\"
                return $retAddCode
            }
            default {
                return $retAddCode
            }
        "

        chassis config -name        $chassis
        chassis config -id          $chassisId
        chassis config -sequence    $sequence
        chassis config -cableLength $cableLength

        if {[chassis set $chassis]} {
            errorMsg "Error setting chassis $chassis"
            return $::TCL_ERROR
        }
    }

    # after connecting to all chassis, broadcast the topology of each chassis
    # to all other chassis
    chassisChain broadcastTopology

    # now we need to verify that it is a valid chain (ie., there is at least one master)
    if {[chassisChain validChain]} {
        errorMsg "Error: Chassis chain is not valid - check for master chassis in chain"
        set retCode $::ixTcl_invalidChassisChain
    }

    return $retCode
}


########################################################################################
# Procedure: setConnectChassisFlag
#
# Description: Set the value that indicates whether connecting to chassis should continue.
#
# Argument(s): value - "continue" or "stop".
#
# Return:      Nothing
#
########################################################################################
proc setConnectChassisFlag {value} \
{
    global ixgChassisContinueFlag

    switch $value {
        "continue" -
        "stop" {
            set ixgChassisContinueFlag $value
        }
        default {
            set ixgChassisContinueFlag "continue"
        }
    }
}


########################################################################################
# Procedure: getConnectChassisFlag
#
# Description: Get the value that indicates whether connecting to chassis should continue.
#
# Argument(s): None.
#
# Return:      "continue" or "stop".
#
########################################################################################
proc getConnectChassisFlag {} \
{
    global ixgChassisContinueFlag

    if { [info exists ixgChassisContinueFlag] } {
        set retCode $ixgChassisContinueFlag
    } else {
        set retCode "continue"
    }

    return $retCode
}
