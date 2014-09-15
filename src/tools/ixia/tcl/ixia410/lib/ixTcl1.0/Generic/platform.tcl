##################################################################################
# Version 4.10   $Revision: 13 $
# $Date: 9/30/02 3:59p $
# $Author: Mgithens $
#
# $Workfile: platform.tcl $
#
#   Copyright © 1997 - 2005 by IXIA
#   All Rights Reserved.
#
#       Revision Log:
#       09-29-2000       DS
#
# Description: This file contains platform-independent stuff
#
##################################################################################


############################################################
# Procedure  : isUNIX
# 
# Description: This proc tells if current OS is Windows.
# Output     : 1 if it is UNIX, 0 otherwise.
#
############################################################
proc isUNIX {} \
{
    global tcl_platform

    set retCode 0

    if {$tcl_platform(platform) == "unix"} {
        set retCode 1
    }

    return $retCode
}


############################################################
# Procedure  : isWindows
# 
# Description: This proc tells if current OS is Windows.
# Output     : 1 if it is UNIX, 0 otherwise.
#
############################################################

proc isWindows {} \
{
    global tcl_platform

    set retCode 0

    if {$tcl_platform(platform) == "windows"} {
        set retCode 1
    }

    return $retCode
}
