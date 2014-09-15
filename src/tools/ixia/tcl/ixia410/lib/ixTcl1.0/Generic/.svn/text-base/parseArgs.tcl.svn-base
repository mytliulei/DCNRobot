##################################################################################
# Version 4.10	$Revision: 167 $
# $Date: 10/11/04 10:18a $
# $Author: Hasmik $
#
# $Workfile: parseArgs.tcl $ - Argument parsing utils
#
#   Copyright © 1997 - 2004 by IXIA
#   All Rights Reserved.
#
#	Revision Log:
#	10-11-2004	Hasmik
#
# Description: This file contains common procs used for parsing
#              
#
##################################################################################



########################################################################
# Procedure:   ixGetArgument
#
# Description: This command will return a value from an argument list
#              for a given named argument
#
# Arguments:
#    argList   - A list of arguments.
#    argToFind - The name of the option to find in the argList
#
########################################################################
proc ixGetArgument { argList argToFind } \
{
	
	set retValue ""

	if {[llength $argList] == 0 } {
		errorMsg "Error - empty argument list"
		return $retValue
	}

    # Put on the dash if it is missing.
    if {[string index $argToFind 0] != "-"} {
        set argToFind [format "-%s" $argToFind]
    } 

    set index [lsearch -exact $argList $argToFind]

    if {$index != -1} {
        # Just in case they passed a list with the argument, then nothing
        # after it, this will return null in that case.
        if {[catch {lindex $argList [expr $index + 1]} retValue]} {
            set retValue ""
        }
    }

	return $retValue
}
