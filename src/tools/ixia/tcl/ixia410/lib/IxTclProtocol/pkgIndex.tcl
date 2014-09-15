#############################################################################################
#
# pkgIndex.tcl  
#
# Copyright © 1997-2004 by IXIA.
# All Rights Reserved.
#
#   Revision Log:
#   05-06-2004  EM  Genesis
#
#############################################################################################

# if this package is already loaded, then don't load it again
if {[lsearch [package names] IxTclProtocol] != -1} {
    return
}

package ifneeded IxTclProtocol 4.00 [list source [file join $dir IxTclProtocol.tcl]]
