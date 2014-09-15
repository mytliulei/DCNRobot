#############################################################################################
# Version 4.10	$Revision: 1 $
# $Date: 7/09/02 11:41a $
# $Author: Debby $
#
# $Workfile: ixInit.tcl $ - file used to rebuild tclIndex for IxTclServices package
#
# NOTE: This file should be sourced from the ixTclServices directory structure
#
# Copyright © 1997 - 2005 by IXIA.
# All Rights Reserved.
#
#############################################################################################

# Set the initial pattern to nothing
set newPatterns {}

# Get the current directory
set dir [pwd]

# Get all items in the directory
foreach fileItem1 [glob -nocomplain *] {

    # We only are concerned with directories
    if {[file isdirectory $fileItem1]} {
        lappend newPatterns [file join $fileItem1 "*.tcl"]

        foreach fileItem2 [glob -nocomplain $fileItem1/*] {
            if {[file isdirectory $fileItem2]} {
                lappend newPatterns [file join $fileItem2 "*.tcl"]
            } 
        }
    } 
}

eval auto_mkindex . $newPatterns
