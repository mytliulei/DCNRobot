#############################################################################################
# Version 4.10	$Revision: 1 $
# $Date: 1/14/03 5:01p $
# $Author: Michael Githens $
#
# $Workfile: scriptmateBackCompat.tcl $
#
#  This file is used to create backwards compatibility for sample scripts created prior to
#  IxOS 3.70.  Post of this version, a package require Scriptmate is needed.  This will handle
#  attempting to define the commands that used to be defined by IxTclHal and now are defined 
#  Scriptmate
#  
# Copyright © 1997 - 2005 by IXIA.
# All Rights Reserved.
#
#############################################################################################

namespace eval scriptmateBackwardsCompatibility {}


proc scriptmateBackwardsCompatibility::createAllCommands { } {

    foreach cmd {addr back2back bcast cableModem congest dataVerify dtm errframe floss flow gapcheck imix \
            ipmulticast latency tunnel mesh qost randomFS tput tputerror tputjitter tputnat tputl2l3 tputlat \
            tputmfs tputvlan ttl wip results internalModem user bgpSuite dslats ospfSuite rsvpSuite ldpSuite \
            l2VpnSuite l3VpnSuite} {

        proc $cmd { args } {
            if {[catch {package require Scriptmate}]} {
                return "Command is not supported by IxTclHal, it is part of Scriptmate"
            } else {
                return [eval $cmd $args]
            }
        }
    }
}
