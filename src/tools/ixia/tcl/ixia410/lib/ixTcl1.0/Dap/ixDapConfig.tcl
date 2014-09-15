######################################################################################
# Version 3.70	$
# $Date: 1/15/03 2:59p $
# $Author: Zzhang $
#
# $Workfile: ixDapConfig.tcl $               
#
#   Copyright © 1997 - 2003 by IXIA
#   All Rights Reserved.
#
#	Revision Log:
#	11-14-02	Debby Stopp
#
########################################################################################

package req IxTclServices

namespace eval ixDapConfig {
    variable chassisList
    variable tclServer   ""
    variable userName    "ixDapConfig"
           
    variable appName
    variable defaultPortGroupId 1126

    if [info exists interfaceArray] {
        unset interfaceArray
    }    
    variable interfaceArray
    variable interfacePortIdIndex       0 
    variable interfaceMacAddressIndex   1 
    variable interfaceIpAddressIndex    2
    variable interfaceGwIndex           3
    variable interfaceMaskIndex         4
    variable interfaceEnableVlanIndex   5
    variable interfaceVlanIdIndex       6

    if [info exists routeArray] {
        unset routeArray
    }
    variable routeArray
    variable routePortIdIndex           0
    variable routeTargetIndex           1 
    variable routeIpAddressIndex        2 
    variable routeGwIndex               3
    variable routeMaskIndex             4

    if [info exists filterArray] {
        unset filterArray
    }
    variable filterArray
    variable filterResetIndex           0
    variable filterPortListIndex        1 
    variable filterActionIndex          2 
    variable filterTypeIndex            3
    variable filterValueListIndex       4

    variable logCmd    logMsg
    variable errorCmd  errorMsg
}

proc ixDapConfigPort {chassis card port macAddress ipAddress gateway mask {enableVlan false} {vlanId 0}} \
{
    set retCode [ixDapAddPortInterface -portId [list $chassis $card $port] -macAddress $macAddress \
                 -ipAddress $ipAddress -gateway $gateway -mask $mask  -enableVlan $enableVlan -vlanId $vlanId]
    return $retCode
}

proc ixDapAddPortInterface {args} \
{
    set retCode [::ixDapConfig::addInterfaceToArray $args]
    return $retCode
}

proc ixDapAddRouteTable {args} \
{
    set retCode [::ixDapConfig::addRouteToArray $args]
    return $retCode
}

proc ixDapAddPortFilter {args} \
{
    set retCode [::ixDapConfig::addFilterToArray $args]
    return $retCode
}

proc ixDapBaseIpAddresses {args} \
{
    set retCode $::TCL_ERROR
    if {[ixConnectToChassis $args] == $::TCL_OK} {
        set retCode [::ixDapConfig::validateBaseIpAddresses $args]
    }

    return $retCode
}

proc ixDapCleanUp       {}                                         {return [::ixDapConfig::cleanUp]}
proc ixDapSetBaseIp     {chassisName ipAddress {mask 255.255.0.0}} {return [::ixDapConfig::setBaseIp $chassisName $ipAddress $mask]}
proc ixDapAddRoute      {destination mask interface}               {return [::ixDapConfig::addRoute  $destination $mask $interface]}
proc ixDapDelRoute      {destination}                              {return [::ixDapConfig::delRoute  $destination]}

proc ixDapLogin         {userName}                                 {return [::ixDapConfig::login $userName]}

proc ixDapConfig::Log {msg} {
    variable logCmd; eval [concat $logCmd [list $msg]]
}
proc ixDapConfig::Error {msg} { 
    variable errorCmd; eval [concat $errorCmd [list $msg]] 
}


########################################################################
# Procedure: init
#
# This initializes the ixDapConfig namespace
#
# Arguments(s):
#
########################################################################
proc ixDapConfig::init {{appName ""}} \
{
    set retCode $::TCL_OK

    if {$appName != ""} {
        setAppName $appName
    } else {
        set retCode $::TCL_ERROR
        Error "No application name configured - check \"applicationName\""
    } 

    return $retCode
}


########################################################################
# Procedure: login
#
# This procedure logins the current user name; login will be enforced
#
# Arguments(s):
#
########################################################################
proc ixDapConfig::login {{newUserName "ixDapConfig"}} \
{
    variable userName

    if {$newUserName != ""} {
        set userName $newUserName
    }
    ixLogin $userName
}


########################################################################
# Procedure: printVersion
#
# This prints version info
#
# Arguments(s):
#
########################################################################
proc ixDapConfig::printVersion {} \
{
    set versionString [format "\n\t%s\n\t%s\n\t%s\n\n" \
                              [version cget -installVersion] \
                              [version cget -productVersion] \
                              [version cget -copyright] ]
    Log $versionString
}


########################################################################
# Procedure: viewRoutes
#
# This procedure prints the current route config "route print"
#
# Arguments(s):
#
########################################################################
proc ixDapConfig::viewRoutes {baseIpAddressList} \
{
    set routeWindow .routeWindow

    # we need to create a new one
    if [winfo exists $routeWindow] {
        catch {::destroy $routeWindow}
    }

    toplevel $routeWindow -class Dialog
    wm withdraw $routeWindow
    wm title $routeWindow "Route View"
    wm resizable $routeWindow 0 0

    set routeText [exec route print]
    set height    [regsub -all "\n" $routeText "\n" temp]
    set width     [string length [lindex $routeText 0]]

    set routeTextBox [createViewFrame $baseIpAddressList .routeWindow $height $width]
    
    $routeTextBox insert end $routeText

    wm deiconify $routeWindow
}


########################################################################
# Procedure: addRoute
#
# This procedure adds a route config "route add"
#
# Arguments(s):
#   destination - destination ip address, ie., 10.0.0.0
#   mask        - associated mask, ie., 255.255.0.0
#   interface   - to route through
#
########################################################################
proc ixDapConfig::addRoute {destination mask interface} \
{
    set retCode $::TCL_OK

    catch {exec route delete $destination}
    if [catch {exec route add -p $destination mask $mask $interface} error] {
        Log $error
        set retCode $::TCL_ERROR
    }

    return $retCode
}


########################################################################
# Procedure: delRoute
#
# This procedure deletes a route config "route delete"
#
# Arguments(s):
#   destination - destination ip address, ie., 10.0.0.0
#
########################################################################
proc ixDapConfig::delRoute {destination} \
{
    set retCode $::TCL_OK

    catch {exec route delete $destination}

    return $retCode
}


##################################################################################
# Procedure:    ixDapConfig::createViewFrame
#
# Description:  Create frame for viewing stuff
#
# Arguments:    none
#
# Returns:      TCL_OK:     success
#
##################################################################################
proc ixDapConfig::createViewFrame { baseIpAddressList parent {height 25} {width 80} {xpad 3} {ypad 2}} \
{
    
    option add *font ansi
    incr width $xpad
    incr height $ypad

    set width  [expr ($width < 80)  ? $width : 80]
    set height [expr ($height < 50) ? $height : 50]

    set labelFrame [frame $parent.routeViewFrame] 
    set infoLabelFrame $labelFrame

    grid $labelFrame     -row 0 -column 0 -padx 0 -pady 10 -sticky w

    set numBaseIp [llength $baseIpAddressList]
    if {$numBaseIp <= 1} {
        set text1 "The Ixia port's management address is"
        set text2 "Please ensure that your PC has a route to this network."
    } else {
        set text1 "The Ixia ports' management addresses are"
        set text2 "Please ensure that your PC has routes to these networks."
    }

    set labelIndex 0
    set infoLabel$labelIndex \
        [label $labelFrame.infoLabel$labelIndex -text $text1 -font {ansi 8} -width 92]
    grid [set infoLabel$labelIndex] -row $labelIndex -column 0 -padx 6 -pady 0  -sticky w

    foreach baseIp $baseIpAddressList {
        incr labelIndex        
        set infoLabel$labelIndex \
            [label $labelFrame.infoLabel$labelIndex -text "\t - $baseIp/16" -font {ansi 8} -width 92]
        grid [set infoLabel$labelIndex] -row $labelIndex -column 0 -padx 6 -pady 0  -sticky w
    }

    incr labelIndex
    set infoLabel$labelIndex \
        [label $labelFrame.infoLabel$labelIndex -text $text2 -font {ansi 8} -width 92]
    grid [set infoLabel$labelIndex] -row $labelIndex -column 0 -padx 6 -pady 0  -sticky w

    set routeFrame [frame $parent.routeFrame]

    # Create a list widget to contain all the route
    set widgets(routeText) [text $routeFrame.routeText \
            -height $height -width $width -wrap none -font {courier 8} -xscrollcommand "$routeFrame.xScroll set" \
            -yscrollcommand "$routeFrame.yScroll set"]

    set xScroll [scrollbar $routeFrame.xScroll -orient horizontal \
            -command "$widgets(routeText) xview"]
    set yScroll [scrollbar $routeFrame.yScroll -orient vertical \
            -command "$widgets(routeText) yview"]

    grid $widgets(routeText) -row 1 -column 0 -sticky news
    grid $xScroll            -row 2 -column 0 -sticky we
    grid $yScroll            -row 1 -column 1 -sticky ns
    grid rowconfigure        $routeFrame 1 -weight 1
    grid columnconfigure     $routeFrame 0 -weight 1

    grid $infoLabelFrame -row 0 -column 0 -padx 16 -pady 10 -sticky w -columnspan 2
    grid $routeFrame     -row 1 -column 0 -padx 20 -pady 10 -sticky wens
    grid columnconfigure $parent 0 -weight 1
    grid rowconfigure    $parent 1 -weight 1
    grid columnconfigure $parent 1 -weight 1

    Log "\n*** Please check the Route View window and make sure a route exist for the following network address.\n"
    Log " Network Address: \{$baseIpAddressList\} "
    return $widgets(routeText)
}


########################################################################
# Procedure: setAppName
#
# This sets the appName for the ixDapConfig namespace
#
# Arguments(s):
#
########################################################################
proc ixDapConfig::setAppName {userAppName} \
{
    variable appName
    
    set appName $userAppName
}


########################################################################
# Procedure: setChassisList
#
# This sets the chassisList for the ixDapConfig namespace
#
# Arguments(s):
#
########################################################################
proc ixDapConfig::setChassisList {userChassisList {userTclServer ""}} \
{
    variable chassisList
    variable tclServer

    set retCode $::TCL_OK

    set chassisList $userChassisList
    set tclServer   $userTclServer

    return $retCode
}


########################################################################
# Procedure: getBaseIpAddressList
#
# This gets the chassis baseIpAddressList. Once error getting any one of
# chassis, reset baseIpAddressList to empty which means error happened.
#
# Arguments(s):
#
########################################################################
proc ixDapConfig::getBaseIpAddressList {} \
{
    variable chassisList

    set baseIpAddressList [list]

    foreach chassis $chassisList {
        if {![chassis get $chassis]} {
            lappend baseIpAddressList [chassis cget -baseIpAddress]
        } else {
            Error "Error getting chassis $chassis"
            set baseIpAddressList [list]
            break
        }
    }

    return $baseIpAddressList
}


########################################################################
# Procedure: addInterfaceToArray
#
# This procedure add interface to interfaceArray
#
# Arguments(s):
#
########################################################################
proc ixDapConfig::addInterfaceToArray {args} \
{
    variable      interfaceArray

    set retCode   $::TCL_OK

    set portId     none
    set macAddress "00 00 00 00 00 00"
    set ipAddress  "0.0.0.0"
    set mask       "0.0.0.0"
    set gateway    "0.0.0.0"
    set enableVlan false
    set vlanId     0

    set arraySize [array size interfaceArray]
    foreach arg [lindex $args 0] {
        if {[regexp {^-[a-zA-Z].+} $arg]} {
            #
            # Current argument is preceeded by '-'.
            #
            switch -- $arg {
                "-portId"      -
                "-macAddress"  -
                "-ipAddress"   -
                "-mask"        -
                "-gateway"     -
                "-enableVlan"   -
                "-vlanId"       {
                    set currentOption [string trimleft $arg -]
                    set currentAction getValue
                }
                default {
                    Error "Invalid option \"$arg\""
                    set retCode $::TCL_ERROR
                    break
                }
            }
        } else {
            if {[info exists currentAction]} {
                switch $currentAction {
                    "getValue" {
                        switch $currentOption {
                            portId {
                                set $currentOption $arg
				            }
                            macAddress {
                                set $currentOption $arg
                            }
                            ipAddress  {
                                set $currentOption $arg
				            }
                            mask      {
                                set $currentOption $arg
				            }
                            gateway   {
                                set $currentOption $arg
				            }
                            enableVlan   {
                                set $currentOption $arg
				            }
                            vlanId   {
                                set $currentOption $arg
				            }
                        }
                        catch {unset currentOption}
                        catch {unset currentAction}
                    }
                    default {
                        set retCode $::TCL_ERROR
                        break
                    }
                }
            } else {
                set retCode $::TCL_ERROR
                break
            }
        }
    }

    if {$retCode == $::TCL_OK && $portId != "none"} {
        set interfaceArray($arraySize) \
            [list $portId $macAddress $ipAddress $gateway $mask $enableVlan $vlanId]
    }

    return $retCode
}


########################################################################
# Procedure: getInterfacePortList
#
# This procedure gets the port list to use w/this application
#
# Arguments(s):
#
########################################################################
proc ixDapConfig::getInterfacePortList {{unique 1}} \
{
    variable interfaceArray
    variable interfacePortIdIndex

    set portList [list]
    foreach {index interface} [array get interfaceArray] {
        set port [lindex $interface $interfacePortIdIndex]
        if {$unique == $::true} {
            if {[lsearch $portList $port] == -1} {
                lappend portList [join [split $port ',']]
            }
        } else {
            lappend portList [join [split $port ',']]
        }
    }

    return [lnumsort $portList]
}



########################################################################
# Procedure: getSortListFromArray
#
# This procedure gets sort list from array like {0 caa 1 bbb 2 abc}
#
# Arguments(s):
#
########################################################################
proc ixDapConfig::getSortListFromArray {arrayName} \
{
    variable $arrayName

    set itemList {}

    set arraySize [array get $arrayName]

    foreach {index args} [array get $arrayName] {
        if {[llength $itemList] == 0} {
            lappend itemList $index $args
        } else {
            set insertIndex 0
            foreach {tempIndex tempArgs} $itemList {
                if {$index < $tempIndex} {
                    set itemList [linsert $itemList $insertIndex $index $args]
                } else {
                    set insertIndex [expr $insertIndex + 2]
                    if {[llength $itemList] == [expr $insertIndex]} {
                        set itemList [linsert $itemList $insertIndex $index $args]
                    }                         
                }
            }
        }
    }
    
    return $itemList
}

########################################################################
# Procedure: removeInterfaceFromArray
#
# This procedure remove interface from interfaceArray
#
# Arguments(s):
#
########################################################################
proc ixDapConfig::removeInterfaceFromArray {c l p} \
{
    variable interfaceArray
    variable interfacePortIdIndex

    foreach {index interface} [array get interfaceArray] {
        set myPort [lindex $interface $interfacePortIdIndex]
        if {$c == [lindex $myPort 0] && $l == [lindex $myPort 1] && $p == [lindex $myPort 2]} {
            unset interfaceArray($index)
        }
    }
}


########################################################################
# Procedure: addRouteToArray
#
# This procedure add route to routeArray
#
# Arguments(s):
#
########################################################################
proc ixDapConfig::addRouteToArray {args} \
{
    variable routeArray

    set retCode         $::TCL_OK
    set portId          none
    set target          "net"
    set ipAddress       "0.0.0.0"
    set gateway         "0.0.0.0"
    set mask            "0.0.0.0"

    set arraySize [array size routeArray]
    foreach arg [lindex $args 0] {
        if {[regexp {^-[a-zA-Z].+} $arg]} {
            #
            # Current argument is preceeded by '-'.
            #
            switch -- $arg {
                "-portId"           -
                "-target"           -
                "-ipAddress"        -
                "-mask"             -
                "-gateway"          {
                    set currentOption [string trimleft $arg -]
                    set currentAction getValue
                }
                default {
                    Error "Invalid option \"$arg\""
                    set retCode $::TCL_ERROR
                    break
                }
            }
        } else {
            if {[info exists currentAction]} {
                switch $currentAction {
                    "getValue" {
                        switch $currentOption {
                            portId {
                                set $currentOption $arg
				            }
                            target {
                                set $currentOption $arg
				            }                                
                            ipAddress  {
                                set $currentOption $arg
				            }
                            mask      {
                                set $currentOption $arg
				            }
                            gateway   {
                                set $currentOption $arg
				            }
                        }
                        catch {unset currentOption}
                        catch {unset currentAction}
                    }
                    default {
                        set retCode $::TCL_ERROR
                        break
                    }
                }
            } else {
                set retCode $::TCL_ERROR
                break
            }
        }
    }

    if {$retCode == $::TCL_OK && $portId != "none"} {
        set routeArray($arraySize) [list $portId $target $ipAddress $gateway $mask]
    }

    return $retCode
}


########################################################################
# Procedure: addFilterToArray
#
# This procedure add filter to filterArray
#
# Arguments(s):
#
########################################################################
proc ixDapConfig::addFilterToArray {args} \
{
    variable filterArray

    set retCode   $::TCL_OK

    set reset       false 
    set action      enable
    set portList    none
    set type        none
    set valueList   none

    set arraySize [array size filterArray]
    foreach arg [lindex $args 0] {
        if {[regexp {^-[a-zA-Z].+} $arg]} {
            #
            # Current argument is preceeded by '-'.
            #
            switch -- $arg {
                "-reset"        -
                "-action"       -
                "-portList"     -
                "-type"         -
                "-valueList"    {
                    set currentOption [string trimleft $arg -]
                    set currentAction getValue
                }
                default {
                    Error "Invalid option \"$arg\""
                    set retCode $::TCL_ERROR
                    break
                }
            }
        } else {
            if {[info exists currentAction]} {
                switch $currentAction {
                    "getValue" {
                        switch $currentOption {
                            reset {
                                set $currentOption $arg
				            }
                            action {
                                set $currentOption $arg
                            }
                            portList  {
                                set $currentOption $arg
				            }
                            type      {
                                set $currentOption $arg
				            }
                            valueList   {
                                set $currentOption $arg
				            }
                        }
                        catch {unset currentOption}
                        catch {unset currentAction}
                    }
                    default {
                        set retCode $::TCL_ERROR
                        break
                    }
                }
            } else {
                set retCode $::TCL_ERROR
                break
            }
        }
    }

    if {$retCode == $::TCL_OK && $portList != "none"} {
        set filterArray($arraySize) [list $reset $portList $action $type $valueList]
    }

    return $retCode
}


########################################################################
# Procedure: getValueFromList
#
# This procedure gets value from itemList by passing index
#
# Arguments(s):
#
########################################################################
proc ixDapConfig::getValueFromList {itemList index} \
{
    set retValue ""

    if {$index < [llength $itemList]} {
        set retValue [lindex $itemList $index]
    }

    return $retValue           
}


########################################################################
# Procedure: isSubnetOverlapped
#
# This procedure checks for overlapping subnets, should be eventually
# be moved into main code for 3.70.
#
# Arguments(s):
#
########################################################################
proc ixDapConfig::isSubnetOverlapped {ipAddr1 mask1 ipAddr2 mask2} \
{
    set retCode $::false

    set resultMask      [expr [ip2num $mask1] & [ip2num $mask2]]
    set range1Subnet    [expr [ip2num $ipAddr1] & $resultMask]
    set range2Subnet    [expr [ip2num $ipAddr2] & $resultMask]

    if {$range1Subnet == $range2Subnet} {
        set retCode $::true
    } 

    return $retCode
}


########################################################################
# Procedure: setBaseIp
#
# This procedure sets a new base IP address on the chassis
#
# Arguments(s):
#   chassisName - name or ID of chassis
#   ipAddress   - base ip address to use
#   mask        - mask to use w/base ip address
#
# Return:
#   returns TCL_OK if successful
#
########################################################################
proc ixDapConfig::setBaseIp {chassisName ipAddress {mask 255.255.0.0}} \
{
    set retCode $::TCL_OK

    if [chassis get $chassisName] {
        if [ixConnectToChassis $chassisName] {
            Error "Error - invalid chassis $chassisName specified."
            return $::TCL_ERROR
        }
    }
    
    chassis config -baseIpAddress   $ipAddress
    chassis config -baseAddressMask $mask
    if [chassis setBaseIp $chassisName] {
        Error "Unable to set base IP address $ipAddress/$mask."
        set retCode $::TCL_ERROR
    }

    return $retCode
}


########################################################################
# Procedure: validateBaseIpAddresses
#
# This procedure validates & checks for overlapping ip addresses among
# all base ip address in all chassis in chain
#
# Arguments(s):
#
# Return:
#   returns TCL_OK if all valid base ip address & no overlap
#
########################################################################
proc ixDapConfig::validateBaseIpAddresses {chassisList} \
{
    set currentBaseIp ""
    set currentMask   ""
    set overlapping   $::false

    Log "\n**************************************************************"
    foreach myChassis $chassisList {
        if [chassis get $myChassis] {
            Error "Error getting chassis $myChassis"
            set retCode $::TCL_ERROR
            break
        }
        set nextBaseIp [chassis cget -baseIpAddress]
        set nextMask   [chassis cget -baseAddressMask]
        Log "Chassis $myChassis base IP Address == $nextBaseIp/$nextMask"
        if {$currentBaseIp != "" } {
            if [isSubnetOverlapped $currentBaseIp $currentMask $nextBaseIp $nextMask] {
                set overlapping $::true
                break
            }
        }
        set currentBaseIp $nextBaseIp
        set currentMask   $nextMask
    }

    Log "**************************************************************\n"

    if {$overlapping} {
        Log "----> WARNING: Overlapping base ip address configuration detected in your chassis chain!!!"
        Log "      Please verify base ip address configuration on all chassis in chain"
        Log "      To modify/update the base ip address of a chassis, use the following command:\n"
        Log " ixDapSetBaseIp <chassisNameOrId> <baseIpAddress>\n\n"
    }

    return [expr $overlapping?$::TCL_ERROR:$::TCL_OK]
}


########################################################################
# Procedure: setupPortInterfaces
#
# This procedure adds the interfaces for the ixDapConfig
#
# Arguments(s): write    - write to hardware, default is write
#
########################################################################
proc ixDapConfig::setupPortInterfaces {PortList {write write}} \
{
    upvar $PortList portList

    variable interfaceArray
    variable interfacePortIdIndex
    variable interfaceMacAddressIndex
    variable interfaceIpAddressIndex
    variable interfaceGwIndex
    variable interfaceMaskIndex
    variable interfaceEnableVlanIndex
    variable interfaceVlanIdIndex

    set retCode $::TCL_OK

    Log "" ;# empty line
    ip setDefault
    set configedPortList {}
    set interfaceList [getSortListFromArray interfaceArray]

    if [interfaceTable::setDefault portList] {
        Error "Error setting interface table to default"
        set retCode $::TCL_ERROR
        break
    }

    foreach {index interface} $interfaceList {
        set myPort      [getValueFromList $interface $interfacePortIdIndex]
        set macAddress  [getValueFromList $interface $interfaceMacAddressIndex]
        set ipAddress   [getValueFromList $interface $interfaceIpAddressIndex]
        set gateway     [getValueFromList $interface $interfaceGwIndex]
        set mask        [getValueFromList $interface $interfaceMaskIndex]
        set enableVlan  [getValueFromList $interface $interfaceEnableVlanIndex]
        set vlanId      [getValueFromList $interface $interfaceVlanIdIndex]

        set c [lindex $myPort 0]
        set l [lindex $myPort 1]
        set p [lindex $myPort 2]
        if {[lsearch $configedPortList $myPort] != -1} {
            continue
        } else {
            lappend configedPortList $myPort
        }

        if [port get $c $l $p] {
            Error "Error getting port $c $l $p"
            set retCode $::TCL_ERROR
            break
        }

        port config -MacAddress $macAddress

        if {$enableVlan == "true"} {
            # protocol cget -enable802dot1qTag is for all ports in configArp
            # once one of ports is vlan enabled, we need to config enable802dot1qTag true
            protocol config -enable802dot1qTag true
            vlan config -vlanID $vlanId
            if [vlanUtils::setPortTagged $c $l $p] {
                Error "Error setting vlan tag for port $c $l $p"
                set retCode $::TCL_ERROR
                break
            }            
            if [vlan set $c $l $p] {
                Error "Error setting vlan for port $c $l $p"
                set retCode $::TCL_ERROR
                break
            }                
        } else {
            if [vlanUtils::setPortUntagged $c $l $p] {
                Error "Error unsetting vlan tag for port $c $l $p"
                set retCode $::TCL_ERROR
                break
            }
            if [vlan set $c $l $p] {
                Error "Error setting vlan for port $c $l $p"
                set retCode $::TCL_ERROR
                break
            }                
        }
        
        if [port set $c $l $p] {
            Error "Error setting port $c $l $p"
            set retCode $::TCL_ERROR
            break
        }

        ip config -sourceIpAddr  $ipAddress
        ip config -destDutIpAddr $gateway
        ip config -sourceIpMask  $mask

        if [ip set $c $l $p] {
            Error "Error setting ip $c $l $p"
            set retCode $::TCL_ERROR
            break
        }
        Log "Adding an interface on port $c $l $p: MAC:$macAddress, IP:$ipAddress, GW:$gateway, Mask:$mask, Vlan Enable:$enableVlan, Vlan Id:$vlanId"
    }

    if {$retCode == $::TCL_OK} {
        set retCode [configureArp configedPortList configedPortList nowrite]
    }

    if {$retCode == $::TCL_OK} {
        set configedPortList {}
        foreach {index interface} [array get interfaceArray] {
            set myPort [getValueFromList $interface $interfacePortIdIndex]
            if {[lsearch $configedPortList $myPort] == -1} {
                lappend configedPortList $myPort
                continue
            } else {
                set retCode [addPortInterface $interface $write]
            }
        }
    }

    if {$retCode == $::TCL_OK && $write == "write"} {
        if [writeConfigToHardware configedPortList] {
            Error "Error writing ports to hardware"
            set retCode $::TCL_ERROR
        }
    }


    return $retCode
}


########################################################################
# Procedure: addPortInterface
#
# This procedure add one interface
#
# Arguments(s): write - write to hardware, default is write
#
########################################################################
proc ixDapConfig::addPortInterface {interface {write write}} \
{
    variable interfaceArray
    variable interfacePortIdIndex
    variable interfaceMacAddressIndex
    variable interfaceIpAddressIndex
    variable interfaceGwIndex
    variable interfaceMaskIndex
    variable interfaceEnableVlanIndex
    variable interfaceVlanIdIndex

    set retCode $::TCL_OK
                            
    set myPort      [getValueFromList $interface $interfacePortIdIndex]
    set macAddress  [getValueFromList $interface $interfaceMacAddressIndex]
    set ipAddress   [getValueFromList $interface $interfaceIpAddressIndex]
    set gateway     [getValueFromList $interface $interfaceGwIndex]
    set mask        [getValueFromList $interface $interfaceMaskIndex]
    set enableVlan  [getValueFromList $interface $interfaceEnableVlanIndex]
    set vlanId      [getValueFromList $interface $interfaceVlanIdIndex]
    set maskWidth   [getIpV4MaskWidth $mask]

    set c [lindex $myPort 0]
    set l [lindex $myPort 1]
    set p [lindex $myPort 2]
    set portList [list $myPort]

    # Add multiple interfaces into protocol interface table
    if [interfaceTable  select  $c $l $p] {
        Error "Error seleting port $c $l $p"
        set retCode $::TCL_ERROR
        break
    }

    interfaceEntry  clearAllItems     addressTypeIpV4
    interfaceEntry  clearAllItems     addressTypeIpV6
    interfaceIpV4   setDefault        
    interfaceIpV4   config  -ipAddress          $ipAddress
    interfaceIpV4   config  -gatewayIpAddress   $gateway
    interfaceIpV4   config  -maskWidth          $maskWidth
    if {[interfaceEntry  addItem addressTypeIpV4]} {
        Error "Error adding item into interfaceEntry"
        set retCode $::TCL_ERROR
        break
    }

    interfaceEntry  setDefault        
    interfaceEntry  config  -enable             true
    interfaceEntry  config  -description        [interfaceTable::formatEntryDescription $c $l $p]
    interfaceEntry  config  -macAddress         $macAddress
    interfaceEntry  config  -enableVlan         $enableVlan
    interfaceEntry  config  -vlanId             $vlanId
    if {[interfaceTable  addInterface]} {
        Error "Unable to add interface to Interface Table for port $c $l $p"
        set retCode $::TCL_ERROR
        break
    }
    interfaceEntry  clearAllItems     addressTypeIpV4
    interfaceEntry  clearAllItems     addressTypeIpV6

    Log "Adding an interface on port $c $l $p: MAC:$macAddress, IP:$ipAddress, GW:$gateway, Mask:$mask, VLAN Enable:$enableVlan, VLAN ID:$vlanId"
    
    return $retCode
}


########################################################################
# Procedure: setupRouteTable
#
# This procedure setup port routing table
#
# Arguments(s): None
#
########################################################################
proc ixDapConfig::setupRouteTable {} \
{
    variable           routeArray
    variable           routePortIdIndex
    variable           routeTargetIndex
    variable           routeIpAddressIndex
    variable           routeGwIndex
    variable           routeMaskIndex

    set retCode        $::TCL_OK
    set configPortList [getInterfacePortList]
                            
    Log "" ;# empty line
    set routeList [getSortListFromArray routeArray]
    foreach {index route} $routeList {
        set myPort          [getValueFromList $route $routePortIdIndex]
        set target          [getValueFromList $route $routeTargetIndex]
        set ipAddress       [getValueFromList $route $routeIpAddressIndex]
        set gateway         [getValueFromList $route $routeGwIndex]
        set mask            [getValueFromList $route $routeMaskIndex]

        set c [lindex $myPort 0]
        set l [lindex $myPort 1]
        set p [lindex $myPort 2]
        set portList [list $myPort]

        if {[lsearch $configPortList $myPort] == -1} {
            Log "Port $myPort doesn't exist. Ignore adding a route on port $c $l $p:Target:$target, IP:$ipAddress, GW:$gateway, Mask:$mask"
        } else {
            # delete a route if it exists before adding it
            managePcpuCommand portList [format "route del -%s %s gw %s netmask %s" $target $ipAddress $gateway $mask]
            set errorInfo ""
            if [managePcpuCommand portList [format "route add -%s %s gw %s netmask %s" $target $ipAddress $gateway $mask]] {
                Error "Error adding a route for port $c $l $p:Target:$target, IP:$ipAddress, GW:$gateway, Mask:$mask"
                set retCode $::TCL_ERROR
                break
            } else {
                Log "Adding a route on port $c $l $p:Target:$target, IP:$ipAddress, GW:$gateway, Mask:$mask"
            }
        }
    }

    return $retCode
}


########################################################################
# Procedure: setupPortFilters
#
# This procedure sets up filter on ports
#
# Arguments(s): None
#
########################################################################
proc ixDapConfig::setupPortFilters {} \
{
    variable           filterArray
    variable           filterResetIndex
    variable           filterPortListIndex
    variable           filterActionIndex
    variable           filterTypeIndex
    variable           filterValueListIndex

    set retCode        $::TCL_OK
    set configPortList [getInterfacePortList]
    
    Log "" ;# empty line
    set filterList [getSortListFromArray filterArray]
    foreach {index filter} $filterList {
        set reset       [getValueFromList $filter $filterResetIndex]
        set portList    [getValueFromList $filter $filterPortListIndex]
        set action      [getValueFromList $filter $filterActionIndex]
        set type        [getValueFromList $filter $filterTypeIndex]
        set valueList   [getValueFromList $filter $filterValueListIndex]

        set removePortList {}
        set newPortList    {}
        foreach myPort $portList {
            if {[lsearch $configPortList $myPort] == -1} {
                lappend removePortList $myPort
            } else {
                lappend newPortList $myPort
            }
        }

        if {[llength $removePortList] != 0} {
            Log "Port $removePortList doesn't exist. Ignore adding a filter on port $removePortList: Reset:$reset, Action:$action, Type:$type, ValueList:$valueList"
        }
        if {[llength $newPortList] != 0} {
            # Add a route on portList
            if {$reset == "true"} {
                if [managePcpuCommand newPortList "filter --reset"] {
                    Error "Error resetting filter for port $newPortList"
                    set retCode $::TCL_ERROR
                    break
                } else {
                    Log "Resetting filter on port $newPortList"
                }
            }   

            if [manageFilter newPortList $action $type $valueList] {
                Error "Error adding filter on port $newPortList: Reset:$reset, Action:$action, Type:$type, ValueList:$valueList"
                set retCode $::TCL_ERROR
                break
            } else {
                Log "Adding a filter on port $newPortList: Reset:$reset, Action:$action, Type:$type, ValueList:$valueList"
            }
        }
    }

    return $retCode
}


########################################################################
# Procedure: manageFilter
#
# This procedure manage filter IP protocol pcpu command excuted on the ports
#
# Arguments(s): PortList   - port list
#               action     - enable or disable
#               type       - ip-protocols or icmp-types or udp-ports or tcp-ports
#               valueList  - type value list something like {1 2 3} 
#
########################################################################
proc ixDapConfig::manageFilter {PortList action type valueList} \
{
    upvar $PortList portList

    set retCode $::TCL_OK
    set action  [string tolower $action]
    set type    [string tolower  $type]

    if {$action != "enable" && $action != "disable"} {
        Error "Valid action value is enable or disable"
        set retCode $::TCL_ERROR
    }

    if {$type != "ip-protocols" && $type != "icmp-types" && \
        $type != "udp-ports" && $type != "tcp-ports"} {
        Error "Valid type value is ip-protocols, icmp-types, udp-ports or tcp-ports"
        set retCode $::TCL_ERROR
    }

    if {$retCode == $::TCL_OK} {
        set pcpuCommand [format "filter --%s-%s=%s" $action $type [join $valueList ,]]
        set retCode [managePcpuCommand portList $pcpuCommand]
    }

    return $retCode
}


########################################################################
# Procedure: managePcpuCommand
#
# This procedure manage pcpu command excuted on the ports
#
# Arguments(s): PortList      - port list
#               pcpuCommand   - pcpuCommand in string such as ls
#
########################################################################
proc ixDapConfig::managePcpuCommand {PortList pcpuCommand} \
{
    upvar $PortList portList
    return [issuePcpuCommand portList $pcpuCommand]
}


########################################################################
# Procedure: downloadPackage
#
# This procedure downloads the package to the ports
#
# Arguments(s):
#
########################################################################
proc ixDapConfig::downloadPackage {portList} \
{
    return [managePackage $portList downloadPackage]
}


########################################################################
# Procedure: deletePackage
#
# This procedure deletes downloaded package on the ports
#
# Arguments(s):
#
########################################################################
proc ixDapConfig::deletePackage {portList} \
{ 
    return [managePackage $portList deletePackage -noverbose]
}


########################################################################
# Procedure: managePackage
#
# This procedure is a utility for manager the package <download/delete>
#
# Arguments(s):
#    portList
#    action    - downloadPackage | deletePackage
#
########################################################################
proc ixDapConfig::managePackage {portList action {verbose -verbose}} \
{ 
    variable defaultPortGroupId
    variable appName
    set retCode $::TCL_OK

    # need a portgroup
    portGroup destroy $defaultPortGroupId
    if [portGroup create $defaultPortGroupId] {
        Error "Error creating port group $defaultPortGroupId"
        set retCode $::TCL_ERROR
        return $retCode
    }

    foreach port $portList {
        scan $port "%d %d %d" c l p
        if [portGroup add $defaultPortGroupId $c $l $p] {
            Error "Error adding port $c $l $p to port group $defaultPortGroupId"
            set retCode $::TCL_ERROR
            break
        }
    }
    
    if {$retCode == $::TCL_OK} {
        switch $action {
            "downloadPackage" {
                if {$verbose == "-verbose"} {
                    Log "\nDownloading application $appName on port list..."
                }
                if [serviceManager $action $appName $defaultPortGroupId] {
                    # Get failed portList
                    set failedPorts [list]
                    foreach port $portList {
                        scan $port "%d %d %d" c l p
                        set installedPackages    [split [serviceManager getInstalledPackages $c $l $p] ,]
                        if {[lsearch $installedPackages $appName] < 0} {
                            lappend failedPorts [list $c $l $p]
                        }
                    }
                    Error "Error downloading package $appName on port $failedPorts"
                    set retCode $::TCL_ERROR
                } else {
                    if {$verbose == "-verbose"} {
                        Log "Download complete"
                    }
                }
            }
            "deletePackage" {
                if {$verbose == "-verbose"} {
                    Log "\nDeleting application $appName on port list..."
                }
                serviceManager $action $appName $defaultPortGroupId
                set retCode $::TCL_OK
            }
        }
    }

    portGroup destroy $defaultPortGroupId

    return $retCode
}


########################################################################
# Procedure: pingBaseIpAddress
#
# This procedure ping chassis base Ip address.
#
# Arguments(s): retryTime: default value is 1
#
########################################################################
proc ixDapConfig::pingBaseIpAddress {{retryTime 1}} \
{
    variable chassisList
    
    set retCode $::TCL_OK

    foreach chassis $chassisList {
        if {![chassis get $chassis]} {
            set baseIpAddress [chassis cget -baseIpAddress]
            regsub -all ".0$" $baseIpAddress ".1" baseIpAddress
            set i 1
	        Log ""  ;# empty line
            while {$i <= $retryTime} {
	        Log "Pinging $baseIpAddress for chassis $chassis - $i of $retryTime ..."
                set replyMsg    "Reply from $baseIpAddress"
                set pingResults [eval {exec ping $baseIpAddress}]
                if [regexp $replyMsg $pingResults] {
                    break
                } else {
                    if {$i == $retryTime} { 
                        Error "Error pinging $baseIpAddress for chassis $chassis"
                        set retCode $::TCL_ERROR
                        break
                    }
                }
                incr i
            }
        } else {
            Error "Error getting chassis $chassis"
            set retCode $::TCL_ERROR
        }

        if {$retCode} {
            break
        } else {
	        Log "Ping to $baseIpAddress for chassis $chassis is successful"
        }
    }

    return $retCode
}


########################################################################
# Procedure: cleanUp
#
# This procedure clean up global array.
#
# Arguments(s):
#
########################################################################
proc ixDapConfig::cleanUp {} \
{
    variable interfaceArray
    variable routeArray
    variable filterArray

    if [info exists interfaceArray] {
        unset interfaceArray
    }

    if [info exists routeArray] {
        unset routeArray
    }
    
    if [info exists filterArray] {
        unset filterArray
    }

    return $::TCL_OK
}


########################################################################
# Procedure: main
#
# The main procedure for the ixDapConfig package
#
# Options:
#
#
#	-appName _name_of_application_to_download_
#
#		name of application to download
#
#	-setFactoryDefaults _boolean_
#		reset all the ports to factory defaults as part of the download
#		process.
#
#	-checkLinkState _boolean_
#
#		check the link state of the target ports prior to
#		starting the download process. if the link state is
#		down on any of the target ports, the download process is
#		stopped and $::TCL_ERROR is returned
#
#	-deletePackage _boolean_
#
#		delete downloaded package before downloading package
#
#	-verbose _boolean_
#		be more verbose when logging status messages
#
#   The following options may merit removal
#   since the application could employ them reasonably outside of main ??
#
#	-hideMainWindow _boolean_
#		Hide the main Tk window "."
#
#	-pingBaseIpAddress _boolean_
#
#		ping the base ip addresses of all the chassis
#		that are part of the download process. If 
#		if any of the chassis do not repsoned to the ping
#		then pop up a routeview window and return $::TCL_ERROR
#
# Logging and Error messages:
#
#	By default, logging and error messages are generated via the std.
#	ixia API functions 'logMsg' and 'errorMsg'. These can be overridden
#	by resetting the namespace varibles 
#		ixDapConfig::logCmd
#	and 
#		ixDapConfig::errorCmd
#
#	Should be functions that allow one to set these variables ??
#
# Return Values:
#
#	$::TCL_ERROR on success
#	$::TCL_OK on error
#
########################################################################
proc ixDapConfig::main {args} \
{
    variable chassisList
    variable tclServer   ""
    
    set retCode          $::TCL_OK

    #
    # option defaults
    #
    array set opts [list                 \
	    -hideMainWindow         $::true  \
    	-appName                ""       \
	    -setFactoryDefaults     $::true  \
	    -checkLinkState         $::false \
        -deletePackage          $::true  \
	    -pingBaseIpAddress      $::true  \
	    -verbose                $::true  \
    ]
    
    if {![string match "-*" [lindex $args 0]]} {
    	set opts(-appName) [lindex $args 0]
	    array set opts [lrange $args 1 end]
    } else {
	    if {[llength $args] == 1} {
	        # Allow option pairs to be passed as a single list
	        set args [lindex $args 0]
	    }
	    array set opts $args
    }

    if {$opts(-hideMainWindow)} {
    	wm withdraw .
    }

    if {$opts(-verbose)} {
	    printVersion
    }

    if [init $opts(-appName)] {
        return $::TCL_ERROR
    }


    #****************************************************************
    # Delete all chassis from the chain before connecting to them
    # This is a bug workaround somewhere for something 
    # downstream. See Debby Stopp for details
    #****************************************************************
    if {[info commands chassisChain] != ""} {
        chassisChain removeAll
    }
    if [ixProxyConnect $tclServer $chassisList] {
        return $::TCL_ERROR
    }
    #****************************************************************
    
    # Login is mandatory for this application... 
    if {[session cget -userName] == ""} {
        ixDapConfig::login
    }

    Log "Validating chassis base IP addresses..."
    if [validateBaseIpAddresses $chassisList] {
        return $::TCL_ERROR
    }

    set portIndex 0
    set portList  [getInterfacePortList]
    foreach myPort $portList {
        scan $myPort "%d %d %d" c l p
        
        if {![port isValidFeature $c $l $p $::portFeatureLocalCPU]} {
            Log "PortCPU not supported on port $c $l $p - removing port from list"
            set portList [lreplace $portList $portIndex $portIndex]
            removeInterfaceFromArray $c $l $p
        } else {
            incr portIndex
        }
    }

    set portIndex 0
    foreach myPort $portList {
        scan $myPort "%d %d %d" c l p
        if [ixPortTakeOwnership $c $l $p] {
            set portList [lreplace $portList $portIndex $portIndex]
            removeInterfaceFromArray $c $l $p
        } else {
            incr portIndex
        }
    }

    if {[llength $portList] == 0} {
        Log "No ports in port list"
        return $::TCL_ERROR
    }
   
    if {$opts(-setFactoryDefaults)} {
        Log "Setting factory defaults on all ports in port list..."
        if [setFactoryDefaults $portList] {
            Error "Error setting factory defaults on one or more ports"
            return $::TCL_ERROR
        }

        if [ixWritePortsToHardware portList] {
            Error "Error writing ports to hardware"
            return $::TCL_ERROR
        }
    }

    if {$opts(-checkLinkState)} {
        if [ixCheckLinkState portList] {
            return $::TCL_ERROR
        }
    }

    if [setupPortInterfaces portList] {
        return $::TCL_ERROR
    }

    if [setupRouteTable] {
        return $::TCL_ERROR
    }

    if [setupPortFilters] {
        return $::TCL_ERROR
    }


    if {$opts(-deletePackage)} {
        if [deletePackage $portList] {
            return $::TCL_ERROR
        }
    }

    if [downloadPackage $portList] {
        return $::TCL_ERROR
    }

    # Ping chassis base ip address. If failed after retryTime, launch viewRoutes.
    if {$opts(-pingBaseIpAddress)} {
        set retryTime 3
        if {[pingBaseIpAddress $retryTime]} {
	        set retCode $::TCL_ERROR
            # Move viewRoutes gui here and make it behind wish console
            # If baseIpAddressList is empty, we don't show viewRoutes gui.
            set baseIpAddressList [getBaseIpAddressList]
            if {[llength $baseIpAddressList] > 0 } {
                viewRoutes [getBaseIpAddressList]
                console hide
                console show
            }
        }
    }

    return $retCode
}



