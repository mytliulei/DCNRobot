##################################################################################
# Version 4.10  $Revision: $
# $Date: 12/05/02 6:08p $
# $Author: Elmira $
#
# $Workfile: interfaceTableUtils.tcl $ Utilities for maintaining the Interface Table.
#
# Copyright © 1997 - 2005 by IXIA
# All Rights Reserved.
#
# Revision Log:
# 2002/07/09
#
# Description: Utilities for maintaining the Inteface Table.
#
##################################################################################

namespace eval interfaceTable {
}

########################################################################
# Procedure:    setDefault
#
# Arguments:    None
#
# Returns:      TCL_OK
#
########################################################################
proc interfaceTable::setDefault {PortArray} \
{
    upvar $PortArray portArray

    interfaceIpV6       setDefault
    interfaceIpV4       setDefault
    interfaceEntry      setDefault

    foreach portMap [getAllPorts portArray] {
        scan $portMap "%d %d %d" c l p
        interfaceTable select $c $l $p
        interfaceTable clearAllInterfaces
        interfaceEntry clearAllItems $::addressTypeIpV4
        interfaceEntry clearAllItems $::addressTypeIpV6
    }

    return $::TCL_OK
}

########################################################################
# Procedure:    configurePort
#
# Description:  Given a port, configure the interface table 
#               with information stored in the port, ip and ipV6 objects.
#
# Arguments(s): chassis
#               card
#               port
#               protocolList:   list of protocols to configure (default is all)
#               write:          write or noWrite (default)
#
# Return:       TCL_OK or TCL_ERROR
#
########################################################################
proc interfaceTable::configurePort "chassis card port {protocolList {$::ipV4 $::ipV6}} {numInterfaces 1} {write nowrite} {reset true}" \
{
    set portList [list [list $chassis $card $port]]
    set retCode  [interfaceTable::configure portList $protocolList $numInterfaces $write $reset]

    return $retCode
}


########################################################################
# Procedure:    configure
#
# Description:  Given a list of ports, configure the interface table 
#               with information stored in the port, ip and ipV6 objects.
#
# Arguments(s): portList        list of ports to configure
#               protocolList:   list of protocols to configure (default is all)
#               write:          write or noWrite (default)
#
# Return:       TCL_OK or TCL_ERROR
#
# NOTE:         This currently only builds one ipV6 table entry per port, however
#               in future implementations it needs the capability to do multiple
#               interfaces per port.
#
########################################################################
proc interfaceTable::configure "PortList {protocolList {$::ipV4 $::ipV6}} {numInterfaces 1} {write nowrite} {reset true}" \
{
    set retCode $::TCL_OK
    
    upvar $PortList portList

    if {$reset == "true"} {
        setDefault portList
    }

    foreach port $portList {

        scan $port "%d %d %d" c l p
        if {[port get $c $l $p]} {
            errorMsg "Error: Unable to get port: $c $l $p"
            set retCode $::TCL_ERROR
            break
        }

        if {![interfaceTable select $c $l $p]} {
            if {[addEntry $c $l $p $protocolList $numInterfaces]} {
                set retCode $::TCL_ERROR
                break
            }

        } else {
            set retCode $::TCL_ERROR
            break
        }
    }

    if {$retCode == $::TCL_OK} {
        set lowerWrite [string tolower $write]
        if {[stringCompare $lowerWrite "write"] == 0} {
            set retCode [writeConfigToHardware portList]
        }
    }

    return $retCode
}


########################################################################
# Procedure: addEntry
#
# Description:  Build and save an entry into the interface table with 
#               information stored in the port, ip and ipV6 objects.
#
# Arguments(s): chassis 
#               card
#               port
#               protocolList:   list of protocols to configure
#
# Return:       TCL_OK or TCL_ERROR
#
########################################################################
proc interfaceTable::addEntry "chassis card port {protocolList {$::ipV4 $::ipV6}} {numInterfaces 1} " \
{
    eval array set protocolFunctions \{ \
        $::ipV4    interfaceTable::updateItemIpV4 \
        $::ipV6    interfaceTable::updateItemIpV6 \
    \}

    set retCode $::TCL_OK

    # If the interface already exists, then update it.
    if {![interfaceTable getInterface [interfaceTable::formatEntryDescription $chassis $card $port]]} {
        set retCode [updateEntry $chassis $card $port $protocolList]
        
    # Else, add new interface entry.
    } else {

        interfaceEntry setDefault
        
        # Build IPv4/IPv6 Entries.
        set message ""
        
        set sourceIpAddr [ip cget -sourceIpAddr]
        
        # Build & Save General Entry.
        
        set portMacAddress  [port cget -MacAddress]
        interfaceEntry config -description          [formatEntryDescription $chassis $card $port]
        interfaceEntry config -macAddress           [port cget -MacAddress]
        interfaceEntry config -enable               $::true
        
        for {set interfaceCount 0 } { $interfaceCount < $numInterfaces} { incr interfaceCount} {
        
            if {[vlanUtils::isPortTagged $chassis $card $port]} {
                if {[protocol cget -enable802dot1qTag]} {
                    if {![vlan get $chassis $card $port]} {
                        interfaceEntry config -enableVlan       $::true
                        interfaceEntry config -vlanId           [vlan cget -vlanID]
                    } else {
                        errorMsg "Error getting vlan parameters for $chassis $card $port"
                        set retCode $::TCL_ERROR
                    }
                }
            }
            foreach protocol $protocolList {        
                if {[info exists protocolFunctions($protocol)]} {
                    set retCode [eval $protocolFunctions($protocol) $chassis $card $port message $interfaceCount]
                }                    
            } 
        
            if {[interfaceTable addInterface ]} {
                errorMsg "Error: Unable to add interface to Interface Table for port: $chassis $card $port."
                set retCode $::TCL_ERROR
            }
        
            # Don't change the following order, otherwise the configuratin will be lost
            interfaceEntry config -description          [formatEntryDescription $chassis $card $port]
            interfaceEntry config -enable               $::true
            incrMacAddress portMacAddress 1
            interfaceEntry config -macAddress           $portMacAddress
            set sourceIpAddr [incrIpField $sourceIpAddr 4]
            ip config -sourceIpAddr         $sourceIpAddr       
        }
        
        interfaceEntry clearAllItems $::addressTypeIpV4
        interfaceEntry clearAllItems $::addressTypeIpV6
    }
     
    return $retCode
}



########################################################################
# Procedure: updateEntry
#
# Description:  Modify an existing entry and re-save (actually, delete and
#               re-add) the entry.
#
#               In it's current state, this method doesn't handle multiple
#               entries per interface.
#
# Arguments(s): chassis 
#               card
#               port
#               protocolList:   list of protocols to configure
#
# Return:       TCL_OK or TCL_ERROR
#
########################################################################
proc interfaceTable::updateEntry "chassis card port {protocolList {$::ipV4 $::ipV6}}" \
{
    eval array set protocolFunctions \{ \
        $::ipV4    interfaceTable::updateItemIpV4 \
        $::ipV6    interfaceTable::updateItemIpV6 \
    \}

    set retCode $::TCL_ERROR

    foreach protocol $protocolList {        
        if {$protocol == $::ipV4} {
            set addressType $::addressTypeIpV4
            if {![interfaceEntry getFirstItem $addressType]} {
                interfaceEntry delItem $addressType [interfaceIpV6 cget -ipAddress]
            }
        } else {
            set addressType $::addressTypeIpV6
            if {![interfaceEntry getFirstItem $addressType]} {
                interfaceEntry delItem $addressType [interfaceIpV6 cget -ipAddress]
            }
        }
        set retCode [eval $protocolFunctions($protocol) $chassis $card $port message]
    }

    if {$retCode == $::TCL_OK} {
        if {![interfaceTable delInterface]} {
            if {[interfaceTable addInterface]} {
                set retCode [interfaceTable write]
            }
        }
    }
    
    return $retCode
}

########################################################################
# Procedure:    updateIpItemV4
#
# Description:  Updates the IPv4 entry of the interface table.
#
# Arguments(s): chassis 
#               card
#               port

# Return:       TCL_OK or TCL_ERROR
#
########################################################################
proc interfaceTable::updateItemIpV4 {chassis card port Message {incrByte 0}} \
{               
    set retCode $::TCL_OK
    
    upvar $Message message
    set message ""

    if {![ip get $chassis $card $port]} {
        interfaceIpV4 setDefault
        set sourceIpAddr [ip cget -sourceIpAddr]
        interfaceIpV4 config -ipAddress         [incrIpField $sourceIpAddr 4 $incrByte]
        interfaceIpV4 config -gatewayIpAddress  [ip cget -destDutIpAddr]
		interfaceIpV4 config -maskWidth			[getIpV4MaskWidth [ip cget -sourceIpMask]]

        if {[interfaceEntry addItem $::addressTypeIpV4]} {
            set retCode $::TCL_ERROR
            set message "Error: Unable to add IPv4 Item for port $chassis $card $port"
        } 

     } else {
        set retCode $::TCL_ERROR
        set message "Error: Unable to get IP for port $chassis $card $port"
    }
        

    return $retCode
}

########################################################################
# Procedure:    updateIpItemV6
#
# Description:  Updates the IPv6 entry of the interface table.
#
# Arguments(s): chassis 
#               card
#               port
#
# Return:       TCL_OK or TCL_ERROR
#
########################################################################
proc interfaceTable::updateItemIpV6 {chassis card port Message {numInterfaces 1} } \
{
    set retCode $::TCL_OK

    upvar $Message message
    set message ""

    if {![ipV6 get $chassis $card $port]} {

        interfaceIpV6 setDefault
        interfaceIpV6 config -maskWidth        [ipV6 cget -sourceMask]
        interfaceIpV6 config -ipAddress        [ipV6 cget -sourceAddr]

        if {[interfaceEntry addItem $::addressTypeIpV6]} {
            set retCode $::TCL_ERROR
            set message "Error: Unable to add IPv6 Item for port $chassis $card $port"
        }

    } else {
        set retCode $::TCL_ERROR
        set message "Error: Unable to get IPv6 for port $chassis $card $port"
    }

    return $retCode
}


########################################################################
# Procedure: addEntries
#
# Description:  Build and save an entries into the interface table with 
#               information stored in the port, ip V4, and vlan objects.
#
# Arguments(s): chassis 
#               card
#               port
#               protocolList:   list of protocols to configure
#               numInterfaces   not used.  It is only for compatibility with addEntry proc
#
# Return:       TCL_OK or TCL_ERROR
#
########################################################################
proc interfaceTable::addMultipleEntry "chassis card port {protocolList {$::ipV4}} {numInterfaces 1} " \
{
    eval array set protocolFunctions \{ \
        $::ipV4    interfaceTable::addItemIpV4 \
    \}

    set retCode $::TCL_OK

    interfaceEntry setDefault

    # Build IPv4/IPv6 Entries.
    set message ""

    set sourceIpAddr [ip cget -sourceIpAddr]
    set destDutIpAddr [ip cget -destDutIpAddr]
    set octetToIncr [advancedTestParameter cget -octetToIncr]
    set incrGateway no

    if {[vlanUtils::isPortTagged $chassis $card $port] && [protocol cget -enable802dot1qTag]} {
        set vlanSupport 1
        if {![vlan get $chassis $card $port]} {
            set vlanId  [vlan cget -vlanID]
            set numInterfaces [vlan cget -repeat]
            set incrGateway yes
        } else {
            errorMsg "Error getting vlan parameters for $chassis $card $port"
            set retCode $::TCL_ERROR
        }
    } else {
        set vlanSupport 0
        set numInterfaces 1
    }

    # Build & Save General Entry.
    set portMacAddress  [port cget -MacAddress]
    interfaceEntry config -description          [formatEntryDescription $chassis $card $port]
    interfaceEntry config -macAddress           [port cget -MacAddress]
    interfaceEntry config -enable               $::true

    for {set interfaceCount 0 } { $interfaceCount < $numInterfaces} { incr interfaceCount} {

        if {$vlanSupport} {
            interfaceEntry config -enableVlan       $::true
            interfaceEntry config -vlanId           $vlanId
            incr vlanId                                  
        }
        foreach protocol $protocolList {        
            if {[info exists protocolFunctions($protocol)]} {
                set retCode [eval $protocolFunctions($protocol) $chassis $card $port message \
                                                                $octetToIncr $interfaceCount $incrGateway]
            }                    
        } 

        if {[interfaceTable addInterface ]} {
            errorMsg "Error: Unable to add interface to Interface Table for port: $chassis $card $port."
            set retCode $::TCL_ERROR
        }

        # Don't change the following order, otherwise the configuratin will be lost
        interfaceEntry config -description          [formatEntryDescription $chassis $card $port]
        interfaceEntry config -enable               $::true
        incrMacAddress portMacAddress               1
        interfaceEntry config -macAddress           $portMacAddress    
    }   
    
    interfaceEntry clearAllItems $::addressTypeIpV4
     
    return $retCode
}


########################################################################
# Procedure:    interfaceTable
#
# Description:  Create new IPv4 entry of the interface table.  The IP source and gateway
#                address is based on the sourceIpAddr and destDutIpAddr fields of the ip 
#                command with the adjustments specified by "octetToIncr" and "incrValue"  
#                parameters.
#
# Arguments(s): chassis 
#               card
#               port
#               octetToIncr - octet of the IP address to increment
#               incrValue    - the number to increment
#
# Return:       TCL_OK or TCL_ERROR
#
########################################################################
proc interfaceTable::addItemIpV4 {chassis card port Message {octetToIncr 3} {incrValue 0} {incrGateway no}}\
{               
    set retCode $::TCL_OK
    
    upvar $Message message
    set message ""

    if {![ip get $chassis $card $port]} {
        interfaceIpV4 setDefault
        set sourceIpAddr [ip cget -sourceIpAddr]  
        interfaceIpV4 config -ipAddress         [incrIpField $sourceIpAddr $octetToIncr $incrValue]
        set destDutIpAddr [ip cget -destDutIpAddr]
        if {$incrGateway == "yes"} {
            interfaceIpV4 config -gatewayIpAddress  [incrIpField $destDutIpAddr $octetToIncr $incrValue]
        } else {
            interfaceIpV4 config -gatewayIpAddress $destDutIpAddr
        }
		interfaceIpV4 config -maskWidth			[getIpV4MaskWidth [ip cget -sourceIpMask]]

        if {[interfaceEntry addItem $::addressTypeIpV4]} {
            set retCode $::TCL_ERROR
            set message "Error: Unable to add IPv4 Item for port $chassis $card $port"
        } 

     } else {
        set retCode $::TCL_ERROR
        set message "Error: Unable to get IP for port $chassis $card $port"
     }       

    return $retCode
}


########################################################################
# Procedure:    formatEntryDescription
#
# Description:  TBD.  
#
#               Currently, this procedure builds a description in the format
#               of "card:port".  This will need to change later when 
#               multiple interfaces are allowed per port.
#
# Arguments(s): chassis 
#               card
#               port
#               identifier: true/false: Prepend count id to description.
#
# Return:       Entry Description
#
########################################################################
proc interfaceTable::formatEntryDescription {chassis card port {identifier "false"}} \
{
    set retValue {}

    if {$identifier == "false"} {
        set retValue [format "%02d:%02d" $card $port]
#        set retValue [format "%02d:%02d ProtocolInterface" $card $port]
    } else {
        set id [getInterfaceCount $chassis $card $port]
        set retValue [format "%d-%02d:%02d ProtocolInterface" $id $card $port]
    }

    return "$retValue"
}

########################################################################
# Procedure:    getInterfaceId
#
# Description:  Given a port # and a MAC address, return the interface id.
#               defined for that port.
#
# Arguments(s): chassis 
#               card
#               port
#               ipAddress:  Ip address associated with port interface,
#                           if null, the id of the first interface is
#                           returned.
#
# Return:       interface id
#
########################################################################
proc interfaceTable::getInterfaceId {chassis card port {macAddress ""}} \
{
    set retValue 0

    if {![interfaceTable select $chassis $card $port]} {

        if {[string length $macAddress] == 0} {
            if {![interfaceTable getFirstInterface]} {
                set retValue [interfaceEntry cget -description]
            }

        } else {
            if {![interfaceTable getFirstInterface]} {
                set interfaceMacAddress [interfaceEntry cget -macAddress]
                if {[stringCompare $macAddress $interfaceMacAddress] == 0} {
                    set retValue [interfaceEntry cget -description]
                } else {
                    while {![interfaceTable getNextInterface]} {
                        set interfaceMacAddress [interfaceEntry cget -macAddress]
                        if {[stringCompare $macAddress $interfaceMacAddress] == 0} {
                            set retValue [interfaceEntry cget -description]
                            break
                        }
                    }
                }
            }
        }
    }

    return $retValue
}


########################################################################
# Procedure:    getInterfaceCount
#
# Description:  Given a port number, return the number of interfaces
#               defined for that port.
#
# Arguments(s): chassis 
#               card
#               port
#
# Return:       # of interfaces
#
########################################################################
proc interfaceTable::getInterfaceCount {chassis card port} \
{
    set retValue 0

    if {![interfaceTable select $chassis $card $port]} {
        if {![interfaceTable getFirstInterface]} {
            incr retValue
            while {![interfaceTable getNextInterface]} {
                incr retValue
            }
        }
    }
    return $retValue
}

########################################################################
# Procedure:    enableInterface
#
# Description:  Given a port number and interface Id, enable the interface.
#
# Arguments(s): chassis 
#               card
#               port
#               interfaceId:    See format returned by [formatEntryDescription]
#
# Return:       ::TCL_OK or ::TCL_ERROR
#
########################################################################
proc interfaceTable::enableInterface {chassis card port interfaceId} \
{
    set retCode $::TCL_ERROR

    if {![interfaceTable select $chassis $card $port]} {
        if {![interfaceTable getInterface $interfaceId]} {
            interfaceEntry config -enable true
            interfaceTable write
            set retCode $::TCL_OK
        }
    }
    return $retCode
}

########################################################################
# Procedure:    disableInterface
#
# Description:  Given a port number and interface Id, disable the interface.
#
# Arguments(s): chassis 
#               card
#               port
#               interfaceId:    See format returned by [formatEntryDescription]
#
# Return:       ::TCL_OK or ::TCL_ERROR
#
########################################################################
proc interfaceTable::disableInterface {chassis card port interfaceId} \
{
    set retCode $::TCL_ERROR

    if {![interfaceTable select $chassis $card $port]} {
        if {![interfaceTable getInterface $interfaceId]} {
            interfaceEntry config -enable false
            interfaceTable write
            set retCode $::TCL_OK
        }
    }
    return $retCode
}

########################################################################
# Procedure:    disableAllInterfaces
#
# Description:  Given a port number, disable the interfaces on that port.
#
# Arguments(s): chassis 
#               card
#               port
#
# Return:       ::TCL_OK or ::TCL_ERROR
#
########################################################################
proc interfaceTable::disableAllInterfaces {chassis card port} \
{
    set retCode $::TCL_ERROR

    if {![interfaceTable select $chassis $card $port]} {
        if {![interfaceTable getFirstInterface]} {
            interfaceEntry config -enable false
            set retCode $::TCL_OK
            while {![interfaceTable getNextInterface]} {
                interfaceEntry config -enable false
            }
            interfaceTable write
        }
    }
    return $retCode
}

########################################################################
# Procedure:    deleteInterface
#
# Description:  Given a port number and interface Id, disable the interface.
#
# Arguments(s): chassis 
#               card
#               port
#               interfaceId:    See format returned by [formatEntryDescription]
#
# Return:       ::TCL_OK or ::TCL_ERROR
#
########################################################################
proc interfaceTable::deleteInterface {chassis card port interfaceId} \
{
    set retCode $::TCL_ERROR

    if {![interfaceTable select $chassis $card $port]} {
        if {![interfaceTable getInterface $interfaceId]} {
            interfaceTable delInterface
            interfaceTable write
            set retCode $::TCL_OK
        }
    }
    return $retCode
}

########################################################################
# Procedure:    getEntryList
#
# Description:  Given a port number and interface Id return a list
#               of all entries in that interface.  Really just a debugging
#               tool that I left in because I thought if might be useful.
#
# Arguments(s): chassis 
#               card
#               port
#               interfaceId:    See format returned by [formatEntryDescription]
#               typeList:       list of address types desired, default is all:
#                                   addressTypeIpV4, addressTypeIpV6
#
# Return:       ::TCL_OK or ::TCL_ERROR
#
########################################################################
proc interfaceTable::getEntryList "chassis card port interfaceId {typeList {$::addressTypeIpV4 $::addressTypeIpV6}}" \
{
    set interfaceList [list]

    if {![interfaceTable select $chassis $card $port]} {

        if {![interfaceTable getInterface $interfaceId]} {

            foreach typeId $typeList {
                if {![interfaceEntry getFirstItem $typeId]} {

                    switch $typeId "
                        $::addressTypeIpV4 {
                            set command interfaceIpV4
                        }
                        $::addressTypeIpV6 {
                            set command interfaceIpV6
                        }
                    "
                    lappend interfaceList [eval $command cget -ipAddress]
                    while {![interfaceEntry getNextItem $typeId]} {
                        lappend interfaceList [eval $command cget -ipAddress]
                    }
                }                   
            }                   
        }
    }

    return $interfaceList
}


########################################################################
# Procedure:    getGatewayList
#
# Description:  Given a port number, this proc returns a list of all gateway 
#               entries in that port.  
# Arguments(s): chassis 
#               card
#               port
#               typeList:       list of address types desired, default is all:
#                                   addressTypeIpV4, addressTypeIpV6
#
# Return:       ::TCL_OK or ::TCL_ERROR
#
########################################################################
proc interfaceTable::getGatewayArray "GatewayArray portList {typeList {$::addressTypeIpV4 $::addressTypeIpV6}}" \
{
    upvar $GatewayArray gatewayArray

    foreach txMap $portList {
        scan $txMap "%d %d %d" c l p
        set gatewayArray($c,$l,$p) [list]

        if {![interfaceTable select $c $l $p]} {

            if {![interfaceTable getFirstInterface]} {

                foreach typeId $typeList {
                    if {![interfaceEntry getFirstItem $typeId]} {

                        switch $typeId "
                            $::addressTypeIpV4 {
                                set command interfaceIpV4
                            }
                            $::addressTypeIpV6 {
                                set command interfaceIpV6
                            }
                        "
                        lappend gatewayArray($c,$l,$p) [eval $command cget -gatewayIpAddress]
            
                        while {![interfaceEntry getNextItem $typeId]} {
                            lappend gatewayArray($c,$l,$p) [eval $command cget -gatewayIpAddress]
                        }
                    }                   
                }                   
            }

            while {![interfaceTable getNextInterface]} {
                foreach typeId $typeList {
                    if {![interfaceEntry getFirstItem $typeId]} {

                        switch $typeId "
                            $::addressTypeIpV4 {
                                set command interfaceIpV4
                            }
                            $::addressTypeIpV6 {
                                set command interfaceIpV6
                            }
                        "
                        lappend gatewayArray($c,$l,$p) [eval $command cget -gatewayIpAddress]
                        while {![interfaceEntry getNextItem $typeId]} {
                            lappend gatewayArray($c,$l,$p) [eval $command cget -gatewayIpAddress]
                        }
                    }                   
                }
            }                 
        }
    }

}

