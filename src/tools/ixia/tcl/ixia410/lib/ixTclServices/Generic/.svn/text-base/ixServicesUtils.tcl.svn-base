##################################################################################
# Version 4.10	$Revision: 5 $
# $Date: 1/08/03 3:42p $
# $Author: Debby $
#
# $Workfile: ixServicesUtils.tcl $ - Generic Actions
#
#   Copyright © 1997 - 2005 by IXIA
#   All Rights Reserved.
#
#	Revision Log:
#	07/09/2002	DS
#
# Description: This file contains common procs used for specific actions,
#              such as startTx, stopTx, etc
#
##################################################################################

namespace eval ixServices {
    variable portGroupId        42

    variable sessionId          ""
    variable captureServiceId   ""
    variable dispatchServiceId  ""
}

proc issuePcpuCommand {PortArray args} {upvar $PortArray portArray; return [::ixServices::issuePcpuCommand portArray [lindex $args 0]]}


########################################################################
# Procedure: ixServices::createPortGroup
#
# This command creates a portGroup for the serviceManager namespace for a set of ports
#
# Arguments(s):
#   PortArray       - array of ports start the service on
#
########################################################################
proc ixServices::createPortGroup {PortArray {verbose noVerbose}} \
{
	upvar $PortArray portArray

    variable portGroupId

	set retCode	$::TCL_OK
    if [llength $portArray] {
        set verbose "-$verbose"

        portGroup destroy $portGroupId
        if [portGroup create $portGroupId] {
            errorMsg $verbose "Error creating portGroupId $portGroupId"
            set retCode $::TCL_ERROR                
        }

        if {$retCode == $::TCL_OK} {
	        foreach port $portArray {
		        scan $port "%d %d %d" c l p
                if [portGroup add $portGroupId $c $l $p] {
                    errorMsg $verbose "Error adding [getPortId $c $l $p] to port group."
                    set retCode $::TCL_ERROR
                }
	        }
        }
    }

	return $retCode
}


########################################################################
# Procedure: ixServices::setSessionId
#
# This command sets the sessionId; must be called before any services
# are started or configured. 
#
# Arguments(s):
#   sessionId
#
########################################################################
proc ixServices::setSessionId {newSessionId} \
{
    variable sessionId

    set sessionId $newSessionId

    serviceManager config -sessionId $sessionId

    return $::TCL_OK
}


########################################################################
# Procedure: ixServices::getSessionId
#
# This command gets the sessionId
#
# Arguments(s):
#   none
#
########################################################################
proc ixServices::getSessionId {args} \
{
    variable sessionId

    set sessionId [serviceManager cget -sessionId]

    return $sessionId
}


########################################################################
# Procedure: ixServices::start
#
# This command starts a service via the serviceManager
#
# Arguments(s):
#   serviceName     - ie., captureService, dispatchService
#   serviceId
#   PortArray       - array or list of ports to start service on
#
########################################################################
proc ixServices::start {serviceName serviceId {PortArray ""}} \
{
    upvar $PortArray portArray

    variable sessionId

	set retCode	$::TCL_OK

    if {[llength $sessionId] > 0} {
        if {[info exists portArray] && [llength $portArray] > 0} {
            if [createPortGroup portArray] {
                set retCode $::TCL_ERROR
            } else {              
                variable portGroupId

                if [serviceManager start $serviceName $serviceId $portGroupId] {
                    errorMsg "Error starting $serviceName on $serviceId"
                    set retCode $::TCL_ERROR
                }
            }
        } else {
            if [serviceManager start $serviceName $serviceId] {
                errorMsg "Error starting $serviceName on $serviceId"
                set retCode $::TCL_ERROR
            }
        }
    } else {
        errorMsg "Invalid sessionId specified"
        set retCode $::TCL_ERROR
    }

	return $retCode
}


########################################################################
# Procedure: ixServices::startCaptureService
#
# This command starts the captureService service via the serviceManager
#
# Arguments(s):
#   serviceId
#   PortArray       - array or list of ports to start service on
#
########################################################################
proc ixServices::startCaptureService {serviceId PortArray} \
{
    upvar $PortArray portArray

    variable captureServiceId

    set captureServiceId $serviceId

    return [start captureService $serviceId portArray]
}


########################################################################
# Procedure: ixServices::startDispatchService
#
# This command starts the dispatchService service via the serviceManager
#
# Arguments(s):
#   serviceId
#
########################################################################
proc ixServices::startDispatchService {serviceId } \
{
    variable dispatchServiceId

    set dispatchServiceId $serviceId

    return [start dispatchService $serviceId]
}


########################################################################
# Procedure: ixServices::writeServiceConfiguration
#
# This command writes the service configuration to the pcpu
#
# Arguments(s):
#   serviceName
#   PortArray       - array or list of ports to config service on
#   serviceId
#
########################################################################
proc ixServices::writeServiceConfiguration {serviceName {PortArray ""} {serviceId ""}} \
{
    upvar $PortArray portArray

    set retCode $::TCL_OK

    if {$serviceId == ""} {
        set serviceId [format "%sId" $serviceName]
        variable $serviceId
        set useServiceId [set $serviceId]
    } else {
        set useServiceId $serviceId
    }

    if {[info exists portArray] && [llength $portArray] > 0} {
        variable portGroupId

        if [createPortGroup portArray] {
            set retCode $::TCL_ERROR
        } else {
            variable portGroupId
                      
            if [$serviceName set $useServiceId $portGroupId] {
                errorMsg $::errorInfo
                set retCode $::TCL_ERROR
            } 
        }
    } else {
        if [$serviceName set $useServiceId] {
            errorMsg $::errorInfo
            set retCode $::TCL_ERROR
        }
    }  

    return $retCode
}


########################################################################
# Procedure: ixServices::issuePcpuCommand
#
# This command issues an OS command to the pcpu
#
# Arguments(s):
#
########################################################################
proc ixServices::issuePcpuCommand {PortArray args} \
{
    upvar $PortArray portArray

    set retCode $::TCL_ERROR
    set verbose "-verbose"

    set sessionId "<public>"
    set serviceId pcpuManager

    if {[info exists portArray] && [llength $portArray] > 0} {
        if {[createPortGroup portArray] == $::TCL_OK} {
            variable portGroupId

            switch -- [lindex $args 0] {
                "-noVerbose" -
                "-verbose" {
                    set verbose [lindex $args 0]
                    set args [lrange $args 1 end]
                }
            } 

            set currentSessionId [serviceManager cget -sessionId]
            serviceManager config -sessionId $sessionId

            genericService setDefault
            genericService add 1 typeINT        ;# this is the version
            genericService add 1 typeINT        ;# this is the command - kExecuteShellCommand
            genericService add [join $args] typeString ;# this is the command line to execute...

            if [genericService set $serviceId $portGroupId] {
                errorMsg $verbose "Error issuing pcpu command [join $args]\n\t---->$::errorInfo"
                set retCode $::TCL_ERROR
            } else {
                set retCode $::TCL_OK
            }

            portGroup destroy $portGroupId
            serviceManager config -sessionId $currentSessionId
        }
    }  

    return $retCode
}


########################################################################
# Procedure: ixServices::writeCaptureServiceConfiguration
#
# This command writes the capture service configuration to the pcpu
#
# Arguments(s):
#   PortArray       - array or list of ports to config service on
#
########################################################################
proc ixServices::writeCaptureServiceConfiguration { PortArray } \
{
    upvar $PortArray portArray

    return [writeServiceConfiguration captureService portArray]
}


########################################################################
# Procedure: ixServices::writeDispatchServiceConfiguration
#
# This command writes the dispatch service configuration to the pcpu
#
# Arguments(s):
#
########################################################################
proc ixServices::writeDispatchServiceConfiguration {} \
{
    return [writeServiceConfiguration dispatchService]
}


########################################################################
# Procedure: ixServices::stop
#
# This command stops a service via the serviceManager
#
# Arguments(s):
#   serviceId
#   PortArray       - array or list of ports to stop service on
#
########################################################################
proc ixServices::stop {serviceId {PortArray ""} {verbose noVerbose}} \
{
    upvar $PortArray portArray

	set retCode	$::TCL_OK

    set verbose "-$verbose"
    if {[info exists portArray] && [llength $portArray] > 0} {
        if [createPortGroup portArray] {
            set retCode $::TCL_ERROR
        } else {    
            variable portGroupId

            if [serviceManager stop $serviceId $portGroupId] {
                errorMsg $verbose "Error stopping $serviceId"
                set retCode $::TCL_ERROR
            }
        }
    } else {          
        if [serviceManager stop $serviceId] {
            errorMsg $verbose "Error stopping $serviceId"
            set retCode $::TCL_ERROR
        }
    }

	return $retCode
}


########################################################################
# Procedure: ixServices::stopCaptureService
#
# This command stops the captureService service via the serviceManager
#
# Arguments(s):
#   PortArray       - array or list of ports to start service on
#
########################################################################
proc ixServices::stopCaptureService {PortArray} \
{
    upvar $PortArray portArray

    variable captureServiceId

    return [stop $captureServiceId portArray]
}


########################################################################
# Procedure: ixServices::stopDispatchService
#
# This command stops the dispatchService service via the serviceManager
#
# Arguments(s):
#
########################################################################
proc ixServices::stopDispatchService {} \
{
    variable dispatchServiceId

    return [stop $dispatchServiceId]
}


