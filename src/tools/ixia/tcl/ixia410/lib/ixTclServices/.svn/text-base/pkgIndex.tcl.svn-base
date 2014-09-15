#############################################################################################
# Version 4.10	$Revision: 2 $
# $Date: 6/19/02 2:35p $
# $Author: Debby $
#
# $Workfile: pkgIndex.tcl $ - required file for package req IxServices
#
# Copyright © 1997-2005 by IXIA.
# All Rights Reserved.
#
#############################################################################################
if {[lsearch [package names] IxTclServices] != -1} {
    return
}

package ifneeded IxTclServices 4.10 [list source [file join $dir ixTclServicesSetup.tcl]]