##################################################################################
# Version 4.10	$Revision: 167 $
# $Date: 1/25/2005 10:18a $
# $Author: Hasmik $
#
# $Workfile: explorerMacroUtils.tcl $ - Utility procs
#
#   Copyright © 1997 - 2005 by IXIA
#   All Rights Reserved.
#
#	Revision Log:
#	01-25-2005	Hasmik
#
# Description: This file contains procs used for ixExplorer macros
#              
#
#	***************** NOTE NOTE NOTE *****************
#	PROCEDURES IN THIS NAMESPACE SHOULD NOT BE USED ANYWHERE ELSE
#   THESE WILL BE USED FOR IXEXPLORER MACRO SCRIPTS ONLY
#  
##################################################################################
namespace eval ixExplorerMacro { } {
    
}

proc ixExplorerMacro::enablePortLoopback { TxRxArray } \
{
    upvar $TxRxArray txRxArray

	return [::changePortLoopback txRxArray $::true verbose]
}

proc ixExplorerMacro::disablePortLoopback { TxRxArray } \
{
    upvar $TxRxArray txRxArray

	return [::changePortLoopback txRxArray $::false verbose]
}

proc ixExplorerMacro::rebootLocalCpu { TxRxArray } \
{
    upvar $TxRxArray txRxArray

	return [::rebootLocalCpu txRxArray ]
}

proc ixExplorerMacro::removeStreams { TxRxArray } \
{
    upvar $TxRxArray txRxArray

	return [::removeStreams txRxArray verbose ]
}


proc ixExplorerMacro::cleanUp {} \
{
    global halCommands 

    # Special case that sometimes happens that a global named item existed
    if {[string compare [info globals item] "item"] == 0} {
        global item
        catch {unset item}
    }

    if [info exists halCommands] {
        foreach halCmd $halCommands {
            if {[info commands $halCmd] != ""} {
                debugMsg "Deleting      $halCmd"
                rename $halCmd ""
                # remove this commands from the list
                lreplace $halCommands 0 0
            }
        }

        # now delete the list
        unset halCommands
    }

    # we need to delete the pointer refs too, because otherwise the next package req will be using stale pointers
    foreach ptr [info global *Ptr] {
        if [catch {unset ::$ptr} msg] {puts $msg}
    }

	package forget IxTclProtocol
	package forget IxTclExplorer
    package forget IxTclHal

    if [info exists defineCommand::commandList] {
        foreach testCmd $defineCommand::commandList {
            if { $testCmd != "results" } {               
                $testCmd setDefault
            }

        }
    }
}
