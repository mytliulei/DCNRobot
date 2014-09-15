##################################################################################
# Version 4.10	$Revision: 167 $
# $Date: 11/15/02 10:18a $
# $Author: Hasmik $
#
# $Workfile: pkgIndex.tcl $ - Required file for package req Scriptgen
#
#   Copyright © 1997 - 2004 by IXIA
#   All Rights Reserved.
#
#	Revision Log:
#	01-24-2004	Hasmik
#
##################################################################################

if {![package vsatisfies [package provide Tcl] 8.0]} {return}

# if this package is already loaded, then don't load it again
if {[lsearch [package names] Scriptgen] != -1} {
    return
}

package ifneeded Scriptgen 4.10 [list source [file join $dir scriptGen.tcl]]
