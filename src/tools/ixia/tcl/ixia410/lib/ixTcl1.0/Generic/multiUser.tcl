########################################################################
# Version 4.10    $Revision: 50 $
# $Author: Mgithens $
#
# $Workfile: multiUser.tcl $ - Multi-user related procedures.
#
#   Copyright © 1997 - 2005 by IXIA
#   All Rights Reserved.
#
#    Revision Log:
#    03-01-1998    HS    Genesis
#
# Description: This file contains commands related to multi-user scripts
# to run.
#
########################################################################

##################################################################################
# Procedure: ixSource
#
# This command sources a list of files passed an an argument or the files under
# the directory names passed as an argument. If a list of files is passed, then the
# full path of the file must be specified.
#
# Argument(s):
#   dirFileName        directory name or list of files to be sourced
#
##################################################################################
proc ixSource {dirFileName} \
{
    if [file isdirectory $dirFileName] {
        #  if there are .tcl files here, source them first
        if {![catch {glob -nocomplain -- [file join $dirFileName *.tcl]}] != -1} {
            foreach filename [glob -nocomplain [file join $dirFileName *.tcl]] {
                if [catch {source $filename} srcError] {
                    ixPuts "*** $filename: $srcError"
                }
            }
        }
        sourceRecursively $dirFileName
    } else {
        # else dirFileName is a list of files, so source them
        foreach filename $dirFileName {
            if [catch {source $filename} srcError] {
                ixPuts "*** $filename: $srcError"
            }
        }
    }
}

##################################################################################
# Procedure: sourceRecursively
#
# This command sources all .tcl files in directories recursively.
#
# Argument(s):
#   dirName        directory name under which files to be sourced
#
##################################################################################
proc sourceRecursively {dirName} \
{
    foreach currDir [glob -nocomplain [file join $dirName *]] {
        if [file isdirectory $currDir] {
            foreach filename [glob -nocomplain [file join $currDir *.tcl]] {
                if [catch {source $filename} srcError] {
                    ixPuts "*** $filename: $srcError"
                }
            }
            sourceRecursively [file join $dirName $currDir]
        }
    } 
}


########################################################################
# Procedure: ixLogin
#
# This command logs in a user.
#
# Argument(s):
#   userName    - name of the user to login
#
########################################################################
proc ixLogin {userName} \
{
    session login $userName
}

########################################################################
# Procedure: ixLogout
#
# This command logs out the current user.
#
# Argument(s):
#   None
#
########################################################################
proc ixLogout {} \
{
    session logout
}

########################################################################
# Procedure: ixTakeOwnership
#
# This command attempts to take ownership of all the ports in the list
#
# Argument(s):
#   txRxList    - list of ports to take ownership
#   takeType    - if "force" take regardless of whether
#                 the port is previously owned by someone else
#
########################################################################
proc ixTakeOwnership {txRxList {takeType ""}} \
{
    set retCode 0
  
	set portList $txRxList
    set removedPorts {}

    foreach port $txRxList {

		scan $port "%d %d %d" c l p


		if {[lsearch -exact $port "*"] != -1}  {
			set portList [ixCreatePortListWildCard $txRxList]
			break
		} else {
			# in case we pass the name of the txRxList, which causes ixTakeOwnership 
			# misbehaves after error condition, so we check if the parm passed is 
			# really the value of the port list
			if [catch {format "%d %d %d" $c $l $p} port] {
				errorMsg  "Error creating port list"
				return 1
			}
		}
	}

    if {[info exists takeType] && $takeType == "force"} {
        if [issuePortGroupCommand takeOwnershipForced portList] {
            errorMsg "Error forcing ownership on requested ports"
            set retCode 1
        }
    } else {
        foreach portItem $portList {
		    scan $portItem "%d %d %d" c l p

            if [canUse $c $l $p] {
                set index    [lsearch $portList [list $c $l $p]]
                if {$index >= 0} {
                    logMsg "Port [getPortId $c $l $p] is not available, removing port from the list."
                    lappend removedPorts    [list $c $l $p] 
                    set portList [lreplace $portList $index $index]
                } 
                continue
            }
        }
        if [llength $portList] {
            if [issuePortGroupCommand takeOwnership portList] {
                errorMsg "Error taking ownership on requested ports"
                set retCode 1
            }
        } else {
            logMsg "No available ports to take ownership."
            set retCode 1
        }
    }

    if {$retCode == 0} {
        logMsg "Took ownership of following ports:"
        logMsg "$portList"
    }

    if [llength $removedPorts] {
        errorMsg "Error taking ownership of ports:"
        logMsg $removedPorts
    } 

    return $retCode
}

########################################################################
# Procedure: ixPortTakeOwnership
#
# This command attempts to take ownership of this port
#
# Arguments(s):
#    chassis
#    lm
#    port
#   takeType    - if "force" take regardless of whether
#                 the port is previously owned by someone else
#
########################################################################
proc ixPortTakeOwnership {chassis lm port {takeType ""}} \
{
    set portList    [list [list $chassis $lm $port]]
    return          [ixTakeOwnership $portList $takeType]
}


########################################################################
# Procedure: ixClearOwnership
#
# This command clears ownership of all the ports in the list
#
# Argument(s):
#   txRxList    - list of ports to take ownership
#   takeType    - if "force" take regardless of whether
#                 the port is previously owned by someone else
#
########################################################################
proc ixClearOwnership {{txRxList "" } {takeType ""}} \
{
    set retCode 0

    if {$txRxList == ""} {
        clearAllMyOwnership
    } else {
        set portList [ixCreatePortListWildCard $txRxList]
        if {[info exists takeType] && $takeType == "force"} {
            if [issuePortGroupCommand clearOwnershipForced portList] {
                errorMsg "Error forcing clear ownership on requested ports"
                set retCode 1
            }
        } else {
			set otherPortList {}
			foreach port $portList {
				scan $port "%d %d %d" c l p
				if {![isMine $c $l $p]} {
					lappend otherPortList $port
					set index [lsearch $portList $port]
					set portList [lreplace $portList $index $index]
				}
			}
			if {[llength $portList] > 0} {
				if [issuePortGroupCommand clearOwnership portList] {
					errorMsg "Error clearing ownership on requested ports"
					set retCode 1
				}
			}
			if {[llength $otherPortList] > 0} {
				errorMsg "Error clearing ownership of ports owned by other user(s):"
				logMsg $otherPortList
				set retCode 1
			}
        }
    }
    return $retCode
}


########################################################################
# Procedure: ixPortClearOwnership
#
# This command clears ownership of this port
#
# Arguments(s):
#    chassis
#    lm
#    port
#   takeType    - if "force" take regardless of whether
#                 the port is previously owned by someone else
#
########################################################################
proc ixPortClearOwnership {chassis lm port {takeType ""}} \
{
    set portList    [list [list $chassis $lm $port]]
    return          [ixClearOwnership $portList $takeType]
}


########################################################################
# Procedure: ixCheckOwnership
#
# This command checks ownership of all the ports in the list
#
# Argument(s):
#   TxRxList    - list of ports to take ownership
#
########################################################################
proc ixCheckOwnership {txRxList} \
{
    set retCode 0

    set portList [ixCreatePortListWildCard $txRxList]

    foreach myport $portList {
        scan $myport "%d %d %d" c l p
       
        set retCode [canUse $c $l $p] 
        if {$retCode != 0} {
            return $retCode
        }
    }           
    
    return $retCode
}


########################################################################
# Procedure: canUse
#
# This command checks to see if the port can be used (ie., if it's not
# owned by someone else)
#
# Argument(s):
#   c    - chassis
#   l    - card
#   p    - port
#
# NOTE:  logMsg is used here rather than ixPuts so that if logs are 
#        turned on, the canUse message *will* be saved into the test log.
#
########################################################################
proc canUse {c l p} \
{
    set retCode $::TCL_OK

    if {![port canUse $c $l $p]} {
        set retCode $::ixTcl_notAvailable
    }

    return $retCode
}


########################################################################
# Procedure: isMine
#
# This command checks to see if the currently logged in user owns this
# port.
#
# Argument(s):
#   c   - chassis
#   l   - card
#   p   - port
#
# Returns :
#	0	-	the port is owned by other user
#	1	-	the ixLogin user name matches the ownership owner
#	2	-	the port does not belong to any user
#
########################################################################
proc isMine {chassis card port} \
{
    set isMine 0

    global ixTcl_notAvailable

    if [port get $chassis $card $port] {
        errorMsg "Error getting port $chassis $card $port"
        set retCode 1
    } else {
        set owner   [port cget -owner]
        if {[string tolower $owner] == [string tolower [session cget -userName]]} {
            set isMine  1   ;# this is my port
        } elseif {[string tolower $owner] == ""} {
			set isMine	2	;# this is unowned port
		} else {
			set isMine	0	;# this is owned by other			
		}
    }

    return $isMine
}


