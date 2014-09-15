##################################################################################
# Version 4.10   $Revision: 50 $
# $Author: Mgithens $
#
# $Workfile: eventHandler.tcl $
#
#   Copyright © 1997 - 2005 by IXIA
#   All Rights Reserved.
#
#       Revision Log:
#       04-25-2000      DS      Genesis
#
# Description: The procedures in this file are used for handling events 
#           
#       NOTE:  THIS FILE NEEDS TO BE MOVED INTO SM LAND AS IT'S NOT USED
#              BY IXTCLHAL GENERIC PROCS!!!
#
##################################################################################


#################################################################################
# Procedure:    setStopTestFlag
#
# Description:  Set the global variable ixStopTest to the given value.
#
# Argument(s):  The new value for ixStopTest.
#
# Output:
#################################################################################
proc setStopTestFlag { value } \
{
    global ixStopTest

    set ixStopTest $value
}


#################################################################################
# Procedure:    stopTest
#
# Description:  Handle the message stopTest that is sent from Scriptmate.
#
# Argument(s):
#
# Output:
#################################################################################

proc stopTest {} \
{
    global ixStopTest ixStopAction

    set ixStopTest 1
    switch $ixStopAction {
        0 {
            # close pipe & socket
            catch { puts       "closePipe"   }
            catch { putsServer "closeSocket" }
            destroyDialog
            exit
        }
        default {
        }
    }
    
    debugMsg "The test is being stopped!"
}


#################################################################################
# Procedure:    isTestStopped
#
# Description:  Find out if the test is being stopped by looking at the flag ixStopTest.
#
# Argument(s):
#
# Output:
#################################################################################
proc isTestStopped {} {
    global ixStopTest
    return $ixStopTest
}


#################################################################################
# Procedure:    informServerCurrentTestStopped
#
# Description:  Send the message "runningStatus:currentTestStoppedByUser" to Scriptmate.
#
# Argument(s):
#
# Output:
#################################################################################
proc informServerCurrentTestStopped {} \
{
    logMsg "runningStatus:currentTestStoppedByUser"
}