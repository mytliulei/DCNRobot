#############################################################################################
#
# IxTclProtocol.tcl  - required file for package require IxTclProtocol
#
# Copyright © 1997-2004 by IXIA.
# All Rights Reserved.
#
#   Revision Log:
#   05-06-2004  EM  Genesis
#
#############################################################################################

package provide IxTclProtocol 4.10

if {[catch {package require IxTclHal}]} { 
	logMsg "Error in package require IxTclHal"
	return 1
}

set currDir [file dirname [info script]]

foreach fileItem1 [glob -nocomplain [file join $currDir/*]] {
    # We only are concerned with directories
    if {[file isdirectory $fileItem1]} {
        foreach fileItem2 [glob -nocomplain $fileItem1/*] {
            if {![file isdirectory $fileItem2]} {
				source  $fileItem2
			} 
        }
    } 
}

namespace eval ixTclProtocol {
    variable noArgList
    variable pointerList
    variable commandList
}

source [file join $currDir ixTclProtocolSetup.tcl]