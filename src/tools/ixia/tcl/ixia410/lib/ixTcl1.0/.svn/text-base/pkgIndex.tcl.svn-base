#############################################################################################
# Version 4.10	$Revision: 27 $
# $Date: 12/10/02 9:15a $
# $Author: Debby $
#
# $Workfile: pkgIndex.tcl $ - required file for package req IxTclHal
#
# Copyright © 1997-2005 by IXIA.
# All Rights Reserved.
#
#############################################################################################

if {$::tcl_platform(platform) != "unix"} {
    # if this package is already loaded, then don't load it again
    if {[lsearch [package names] IxTclHal] != -1} {
        return
    }
} else {
    lappend ::auto_path $dir
}

package ifneeded IxTclHal 4.10 [list source [file join $dir ixTclHal.tcl]]



