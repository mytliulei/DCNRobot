#################################################################################
#   Version 4.10    $Revision: 14 $
#   $Date: 12/12/02 2:03p $
#   $Author: Dheins $
#
#   $Workfile: ipV6Utils.tcl $
#
#   Copyright © 1997 - 2005 by IXIA
#   All Rights Reserved.
#
#   Description:    This file contains utilities for manipulating IPv6 addresses.
#
#	Revision Log:
#	Date		Author				Comments
#	-----------	-------------------	--------------------------------------------
#	2002/05/16  D. Heins-Gelder     Initial release 
#
##################################################################################

#   Procedure List
#
#    convertAddress
#    convertIpToIpV6
#    convertIpV6ToIp
#    convertIpV6ToMac
#    convertMacToIpV6
#    convertNoop
#    expandAddress
#    getAddressFieldOffset
#    getAddressFields
#    getFieldListByPrefix
#    getFieldMask 
#    getFieldNamesByPrefix 
#    getFormatPrefix 
#    getHeaderLength 
#    getInterfaceId 
#    getLoopbackAddress
#    getMinimumValidFramesize
#    getNextLevelAggregateId
#    getSiteLevelAggregateId
#    getSubnetId
#    getTopLevelAggregateId
#    host2addr
#    incrIpField
#    isMixedVersionAddress
#    isReservedMCAddress
#    isValidAddress
#    validateAddress

namespace eval ipv6 {

    variable ipV6AddressSize            128
    variable ipV4AddressSize            32
    variable macAddressSize             48

    # IPv6 Addresses can be mixed with Ipv4 address as: 66:66:66:66:66:66:444.444.444.444
    #   In this case the first 6 segements are the hex V6 address, the lower 4 segment are
    #   decimal V4 address (traditional format).  For example: 
    #
    #       fffe:0000:0a3d:0001:0dce:1234:192.168.10.1

    # Known IPv6 addresses.
    variable addressUnspecified         ::0
    variable addressLoopback            ::1
    variable addressTest                03ff:e0::00
    variable addressUnicastLinkLocal    fe80::00
    variable addressUnicastSiteLocal    fec0::00
    variable addressIsatap              00005efe

    #
    # Multicast addresses
    #
    variable addressMulticast           ff::00
    variable addressMulticastAllNodes   [list     \
                                        ff:01::01 \
                                        ff:02::01 ]

    variable addressMulticastAllRouters [list   ff:01::02 \
                                                ff:02::02 \
                                                ff:05::02]
    # Well known multicast addresses
	variable reservedMCAddressList
    set reservedMCAddressList			[list \
                                        ff01:0000:0000:0000:0000:0000:0000:0001 \
                                        ff01:0000:0000:0000:0000:0000:0000:0002 \
                                        ff02:0000:0000:0000:0000:0000:0000:0001 \
                                        ff02:0000:0000:0000:0000:0000:0000:0002 \
                                        ff02:0000:0000:0000:0000:0000:0000:0003 \
										ff02:0000:0000:0000:0000:0000:0000:0004	\
                                        ff02:0000:0000:0000:0000:0000:0000:0005 \
                                        ff02:0000:0000:0000:0000:0000:0000:0006 \
                                        ff02:0000:0000:0000:0000:0000:0000:0007 \
                                        ff02:0000:0000:0000:0000:0000:0000:0008 \
                                        ff02:0000:0000:0000:0000:0000:0000:0009 \
                                        ff02:0000:0000:0000:0000:0000:0000:000a \
                                        ff02:0000:0000:0000:0000:0000:0000:000b \
                                        ff02:0000:0000:0000:0000:0000:0000:000c \
                                        ff02:0000:0000:0000:0000:0000:0000:000d \
                                        ff02:0000:0000:0000:0000:0000:0000:000e \
										ff02:0000:0000:0000:0000:0000:0001:0001	\
										ff02:0000:0000:0000:0000:0000:0001:0002	\
										ff05:0000:0000:0000:0000:0000:0000:0002	\
										ff05:0000:0000:0000:0000:0000:0001:0003	\
										ff05:0000:0000:0000:0000:0000:0001:0004	]
	# The reservedMCAddressList also contains addresses in the following range
	# ff02:0000:0000:0000:0000:0001:FFXX:XXXX  where X is a place holder for a variable scope value
	# ff05:0000:0000:0000:0000:0000:0001:1000 to ff05:0000:0000:0000:0000:0000:0001:13FF

    variable fieldNames                 {topLevelAggregationId nextLevelAggregationId siteLevelAggregationId subnetId interfaceId}

    variable fieldListByPrefix
    eval array set fieldListByPrefix    \{ \
		$::ipV6Reserved                 \{interfaceId\} \
		$::ipV6NSAPAllocation           \{interfaceId\} \
		$::ipV6IPXAllocation            \{interfaceId\} \
        $::ipV6GlobalUnicast            \{topLevelAggregationId reserved nextLevelAggregationId siteLevelAggregationId interfaceId\} \
        $::ipV6LinkLocalUnicast         \{interfaceId\} \
        $::ipV6SiteLocalUnicast         \{subnetId interfaceId \} \
        $::ipV6UserDefined              \{interfaceId topLevelAggregationId nextLevelAggregationId siteLevelAggregationId subnetId\} \
    \}

    variable fieldNamesByPrefix
    eval array set fieldNamesByPrefix   \{ \
		$::ipV6Reserved                 \{\"Interface Id\"\} \
		$::ipV6NSAPAllocation           \{\"Interface Id\"\} \
		$::ipV6IPXAllocation            \{\"Interface Id\"\} \
        $::ipV6GlobalUnicast            \{\"Interface Id\" \"Top-Level Aggregation Id\" \"Next-Level Aggregation Id\" \"Site-Level Aggregation Id\"\} \
        $::ipV6SiteLocalUnicast         \{\"Interface Id\" \"Subnet Id\"\} \
        $::ipV6LinkLocalUnicast         \{\"Interface Id\"\} \
        $::ipV6UserDefined              \{\"Interface Id\" \"Top-Level Aggregation Id\" \"Next-Level Aggregation Id\" \"Site-Level Aggregation Id\" \"Subnet Id\"\} \
    \}



    variable  fieldPositions
    array set fieldPositions {
        prefix                          4
        topLevelAggregationId           16
        nextLevelAggregationId          48
        siteLevelAggregationId          64
        subnetId                        64
        interfaceId                     128
		groupId							128							
    }

    variable  fieldOffsets
    array set fieldOffsets {
        prefix                          0
        topLevelAggregationId           0
        nextLevelAggregationId          3
        siteLevelAggregationId          6
        subnetId                        6
        interfaceId                     8
    }

    variable  fieldMasks
    array set fieldMasks {
        prefix                  0xE0000000000000000000000000000000
        topLevelAggregationId   0x1FFF0000000000000000000000000000
        nextLevelAggregationId  0x000000FFFFFF00000000000000000000
        siteLevelAggregationId  0x000000000000FFFF0000000000000000
        subnetId                0x000000000000FFFF0000000000000000
        interfaceId             0x0000000000000000FFFFFFFFFFFFFFFF
		groupId					0xFF00FFFFFFFFFFFFFFFFFFFFFFFFFFFF
    }

}   

########################################################################################
#
#   Conversion Utilities
#   
########################################################################################

########################################################################################
#
# Procedure:        ipv6::host2addr
#
# Description:      Given an IPv6 address, expand it, then return a string of hex
#                   characters (similar function to host2addr for IPv4 in utils.tcl)
#
# Argument(s):      address:    Ipv6 address (any acceptable IPv6 format)
#               
# Returns:          hex byte string, for example:
#                       ffe1::1 becomes
#                       ff e1 00 00 00 00 00 00 00 00 00 00 00 00 00 01
#
#                       ffe1:ffff:eeee:dddd:cccc:bbbb:aaaa:0001 becomes
#                       ff e1 ff ff ee ee dd dd cc cc bb bb aa aa 00 01
#
########################################################################################
proc ipv6::host2addr {address} \
{
    variable ipV6AddressSize
    set bytes {}

    if {[isValidAddress $address]        || \
        [isMixedVersionAddress $address]  } {

        set address [expandAddress $address]
        
        set length [expr $ipV6AddressSize / 8]
        regsub -all ":" $address {} address
        for {set i 0} {$i < $length} {incr i} {
            lappend bytes [string range   $address 0 1]
            set address   [string replace $address 0 1]
        }
    }

    return $bytes
}

########################################################################################
#
# Procedure:        ipv6::expandAddress
#
# Description:      Expand and IPv6 address from it's compressed form (RFC 2373, section
#                   2.1 & 2.2) to a full 16 byte address delimited by colons:
#
#                   Handles the following:
#                       
#                   1. Zeros compression operator ::
#                           ::1 becomes
#                           0000:0000:0000:0000:0000:0000:0000:0001 
#
#                           fffe::1 becomes
#                           fffe:0000:0000:0000:0000:0000:0000:0001
#
#                   2. Mixed IPv4 and IPv6 Address:
#                           0:0:0:0:0:0:192.168.10.1 becomes
#                           0000:0000:0000:0000:0000:0000:C0a8:0a01
#
# Argument(s):      address:    compressed ipv6 address
#               
# Returns:          expanded address
#
########################################################################################
proc ipv6::expandAddress {address} \
{
    variable ipV6AddressSize
    variable ipV4AddressSize

    set retValue    {}
    set segments    8

    if {[isValidAddress $address]} {

        # Convert IPv4 address to Hex.
        if {[isMixedVersionAddress $address]} {
            set end [expr [llength [split $address :]] - 1]
            set ipv4Address [lindex [split $address :] $end]
            regsub "$ipv4Address" $address {} address
            regsub -all {(.*)\.(.*)\.(.*)\.(.*)} $ipv4Address \
                {[format "%02x%02x:%02x%02x" \1 \2 \3 \4]} ipv4Address
            set ipv4Address [subst $ipv4Address]
            append address $ipv4Address
        }

        # Check for Zero Compression operator, if found split into before and after.
        set segmentsBefore {}
        set segmentsAfter  $address
        
        regexp {(.*)::(.*)} $address result segmentsBefore segmentsAfter
        
        #
        # Fill in the zeroes needed to expand.
        set segmentsBefore [split $segmentsBefore :]
        set segmentsAfter  [split $segmentsAfter  :]
        set segmentsNeeded [expr  $segments - ([llength $segmentsBefore] + [llength $segmentsAfter])]
        set segmentList "$segmentsBefore [string repeat " 0" $segmentsNeeded] $segmentsAfter"
        
        # Build it back into a list as the expanded address in 8 segments (2 bytes each).
        set expandedAddress [list]
        foreach segment $segmentList {
            lappend expandedAddress [format "%04x" 0x$segment]
        }
        set retValue [join $expandedAddress :]
    }
                    
    return $retValue
}

########################################################################################
#
# Procedure:        ipv6::compressAddress
#
# Description:  
#
# Argument(s):
#               
# Returns:
#
########################################################################################
proc ipv6::compressAddress { address } \
{
    regsub -all {(:0{1,3})+} $address ":" stripZeros
    regsub {(:0)+} $stripZeros ":" dc
    if {[string index $dc end] == ":"} {
        set num_colons [regsub -all {:} $dc " " dc_ignore]
        if {$num_colons < 7} {
            append dc :0
        } else  {
            append dc 0
        }
    }
    regsub {^(0{1,3})(.*):(.*)} $dc {\2:\3} dc
    return $dc
}


########################################################################################
#
# Procedure:        ipv6::convertAddress
#
# Description:      Converts from one type of address to another:
#                       mac     -> ipv4 invalid
#                       mac     -> ipv6
#                       ipv4    -> ipv6
#                       ipv4    -> mac  invalid
#                       ipv6    -> mac  (returns lower 6 bytes)
#                       ipv6    -> ipv4 (returns lower 4 bytes)
#
# Argument(s):      address:        mac or ip address (version 4 or 6)
#                                       mac format: 00:00:00:00:00:00 (hex)
#                                       ip format:  000.000.000.000 (decimal)        
#                                       ipv6 format:  0000:0000:0000:0000:0000:0000:0000:0000
#
#                   sourceType:     ip, ipV6, mac
#                   destType:       ip, ipV6, mac
#                   args:           prefix if destType = ipv6 (must be fully expanded prefix)
#
# Returns:          converted address
#
########################################################################################
proc ipv6::convertAddress {address sourceType destType {args ""}} \
{
    set retValue {}

    array set conversion {
        mac,ip              ipv6::convertNoop
        mac,ipV6            ipv6::convertMacToIpV6      
        ip,mac              ipv6::convertNoop
        ip,ipV6             ipv6::convertIpToIpV6
        ip,isatap           ipv6::convertIpToIsatap
        ip,ipV4Compatible   ipv6::convertIptoIpV4Compatible
        ip,6to4             ipv6::convertIpTo6to4
        isatap,ip           ipv6::convertIpV6ToIp
        ipV4Compatible,ip   ipv6::convertIpV6ToIp
        6to4,ip             ipv6::convertIpV6ToIp
        ipV6,mac            ipv6::convertIpV6ToMac   
        ipV6,ip             ipv6::convertIpV6ToIp    
    }

    if {[info exists conversion($sourceType,$destType)]} {
        set command $conversion($sourceType,$destType)
        if {$command != {}} {
            set retValue [eval $command $address $args]
        }
    }

    return $retValue
}

########################################################################################
#
# Procedure:        ipv6::convertMacToIpV6
#
# Description:      Converts a MAC address to an IPv6 address.
#
# Argument(s):      address:    mac address
#                   prefix:     defaults to 0
#               
# Returns:          converted address
#
########################################################################################
proc ipv6::convertMacToIpV6 {address {prefix 0}} \
{
    variable ipV6AddressSize
    variable macAddressSize

    set retValue {}
    if {[isMacAddressValid $address] == $::TCL_OK} {

        # Convert the address and prefix to a string of bytes.
        regsub -all ":" $prefix { } prefixList
        set prefix {}
        foreach segment $prefixList {
            lappend prefix [format "%04X" 0x$segment]
        }
        regsub -all " " $prefix "" prefix
        regsub -all ":" $address {} address

        # Expand if necessary.
        set prefixLength [expr [string length $prefix]/2]
        set expand [expr $ipV6AddressSize/8 - $macAddressSize/8 - $prefixLength]
        for {set i $expand} {$i} {incr i -1} {
            append prefix "00"
        }
        append prefix $address

        # Build prefix-address string into IPv6 style address
        set address {}
        while {[string length $prefix] > 0} {
            append address "[string range $prefix 0 3]:"
            set prefix [string replace $prefix 0 3]
        }
        regexp {(.*):$} $address match address  
        set retValue $address
    }            

    return $retValue
}

########################################################################################
#
# Procedure:        ipv6::convertIpToIpV6
#
# Description:      Converts an IP address to an IPv6 address.
#
# Argument(s):      address:    version 4 style IP address
#                   prefix:     defaults to 0
#               
# Returns:          converted address
#
########################################################################################
proc ipv6::convertIpToIpV6 {address {prefix 0} {option addressAtTheEnd}} \
{
    variable ipV4AddressSize
    variable ipV6AddressSize

    set retValue {}

    if {[isIpAddressValid $address]} {

        # Convert prefix to string.
        regsub -all ":" $prefix { } prefixList
        set prefix {}
        foreach segment $prefixList {
            lappend prefix [format "%04X" "0x$segment"]
        }
        regsub -all " " $prefix "" prefix
        
        
        # Convert ip address to string.
        regsub -all {(.*)\.(.*)\.(.*)\.(.*)} $address \
            {[format "%02x%02x%02x%02x" \1 \2 \3 \4]} address
        set address [subst $address]
        
        
        # Expand if necessary.
        set prefixLength [expr [string length $prefix]/2]
        set expand [expr $ipV6AddressSize/8 - $ipV4AddressSize/8 - $prefixLength]
        if {$option == "addressFollowPrefix"} {
            append prefix $address
            ### append the rest with 00...01
            ### because host address cannot be all 0's
            incr expand -1
            for {set i $expand} {$i} {incr i -1} {
                append prefix "00"
            } 
            append prefix "01" 
        } else {
           for {set i $expand} {$i} {incr i -1} {
                append prefix "00"
           }
           append prefix $address          
        }
        
        # Break it up into IPv6 address seperated by colons.
        set address {}
        while {[string length $prefix] > 0} {
            append address "[string range $prefix 0 3]:"
            set prefix [string replace $prefix 0 3]
        }
        regexp {(.*):$} $address match address            
        set retValue $address
    }

    return $retValue
}


########################################################################################
#
# Procedure:        ipv6::convertIpToIsatap
#
# Description:      Converts an IP address to an IPv6 Isatap address.
#
# Argument(s):      address:    version 4 style IP address
#                   prefix:     defaults to 0
#               
# Returns:          converted address
#
########################################################################################
proc ipv6::convertIpToIsatap {address {prefix 0}} \
{
    variable ipV4AddressSize
    variable ipV6AddressSize
    variable addressIsatap

    set retValue {}

    if {[isIpAddressValid $address]} {

        # Convert prefix to string.
        regsub -all ":" $prefix { } prefixList
        set prefix {}
        foreach segment $prefixList {

            lappend prefix [format "%04X" "0x$segment"]
        }
        regsub -all " " $prefix "" prefix
        
        # Convert ip address to string.
        regsub -all {(.*)\.(.*)\.(.*)\.(.*)} $address \
            {[format "%02x%02x%02x%02x" \1 \2 \3 \4]} address 
        set address [subst $address]
        set address [format "%08x%08x" 0x$addressIsatap 0x$address]

        set isatapSize [expr [string length $addressIsatap]/2]

        
        # Expand if necessary.
        set prefixLength [expr [string length $prefix]/2]
        set expand [expr $ipV6AddressSize/8 - $ipV4AddressSize/8 - $prefixLength - $isatapSize]
        for {set i $expand} {$i} {incr i -1} {
            append prefix "00"
        }
        append prefix $address
        
        # Break it up into IPv6 address seperated by colons.
        set address {}
        while {[string length $prefix] > 0} {
            append address "[string range $prefix 0 3]:"
            set prefix [string replace $prefix 0 3]
        }
        regexp {(.*):$} $address match address            
        set retValue $address
    }

    return $retValue
}

########################################################################################
#
# Procedure:        ipv6::convertIpToIpV4Compatible
#
# Description:      Converts an IP address to an IPv6 IPv4 Compatible address.
#
# Argument(s):      address:    version 4 style IP address
#                   prefix:     defaults to 0
#               
# Returns:          converted address
#
########################################################################################
proc ipv6::convertIptoIpV4Compatible {address {prefix 0}} \
{
    set retValue [convertIpToIpV6 $address $prefix]
    return $retValue
}


########################################################################################
#
# Procedure:        ipv6::convertIpTo6To4
#
# Description:      Converts an IP address to an IPv6 6to4 address.
#
# Argument(s):      address:    version 4 style IP address
#                   prefix:     defaults to 2002
#               
# Returns:          converted address
#
########################################################################################
proc ipv6::convertIpTo6to4 {address {prefix 2002}} \
{
    set retValue [convertIpToIpV6 $address $prefix addressFollowPrefix]
    return $retValue
}


########################################################################################
#
# Procedure:        ipv6::convertIpV6ToMac
#
# Description:      Converts an IPv6 address to a MAC.
#
# Argument(s):      address:    IpV6 address
#               
# Returns:          converted address
#
########################################################################################
proc ipv6::convertIpV6ToMac {address {args ""}} \
{
    variable macAddressSize
    variable ipV6AddressSize

    set retValue {}

    if {[isValidAddress $address]} {
        set address [expandAddress $address]
        regsub -all ":" $address {} address
        
        set start [expr ($ipV6AddressSize/4) - ($macAddressSize/4)]
        set end   [expr ($ipV6AddressSize/4) - 1]
        set byteString [string range $address $start $end]
        
        set address {}
        while {[string length $byteString] > 0} {
            append address "[string range $byteString 0 1]:"
            set byteString [string replace $byteString 0 1]
        }
        regexp {(.*):$} $address match address            
        set retValue $address
    }

    return $retValue
}

########################################################################################
#
# Procedure:        ipv6::convertIpV6ToIp
#
# Description:      Converts an IPv6 address to an IP address, aka IPv4-Compatible Address.
#
# Argument(s):      address:    IPv4 style address (192.168.1.10)
#               
# Returns:          converted address
#
########################################################################################
proc ipv6::convertIpV6ToIp {address {args ""}} \
{
    variable ipV4AddressSize
    variable ipV6AddressSize

    set retValue {}

    if {[isValidAddress $address]} {
        set address [expandAddress $address]
        regsub -all ":" $address {} address
        
        set start [expr ($ipV6AddressSize/4) - ($ipV4AddressSize/4)]
        set end   [expr ($ipV6AddressSize/4) - 1]
        set byteString [string range $address $start $end]
        
        set address {}
        while {[string length $byteString] > 0} {
            lappend address "[string range $byteString 0 1]"
            set byteString [string replace $byteString 0 1]
        }
        regsub -all {(.*) (.*) (.*) (.*)} $address \
            {[format "%d.%d.%d.%d" 0x\1 0x\2 0x\3 0x\4]} address
        set address [subst $address]
        set retValue $address
    }

    return $retValue
}

########################################################################################
#
# Procedure:        ipv6::convertNoop
#
# Description:      Place holder, doesn't do any thing
#
# Argument(s):      None
#               
# Returns:          None
#
########################################################################################
proc ipv6::convertNoop {address {args ""}} \
{
}

########################################################################################
#
#   Field 'get' Utilities
#   
########################################################################################

proc ipv6::getAddressFields {} \
{
    variable fieldNames
    return  $fieldNames
}

########################################################################
# Procedure:    getFieldListByPrefix
#
# Description:  Given an address, return a list of the valid fields
#                   for that address type.
#
# Argument(s):  ipAddress:  IP address
#
# Returns:      field list (enums are interfaceId, subnetID, siteLevelAggregationId,
#                    nextLevelAggregationId, topLevelAggregationId).
#
########################################################################
proc ipv6::getFieldListByPrefix {address} \
{
    variable fieldListByPrefix

    set retValue {}

    if {![ipV6Address decode $address]} {
        set prefixType [ipV6Address cget -prefixType]
        if {[info exists fieldListByPrefix($prefixType)]} {
            set retValue $fieldListByPrefix($prefixType)
        }
    }
    
    return $retValue    
}

########################################################################
# Procedure:    getFieldNamesByPrefix
#
# Description:  Given an address, return a list of the field names
#                   for that address type.
#
# Argument(s):  ipAddress:  IP address
#
# Returns:      list of field names
#
########################################################################
proc ipv6::getFieldNamesByPrefix {address} \
{
    variable fieldNamesByPrefix

    set retValue {}

    if {![ipV6Address decode $address]} {
        set prefixType [ipV6Address cget -prefixType]
        if {[info exists fieldNamesByPrefix($prefixType)]} {
            set retValue $fieldNamesByPrefix($prefixType)
        }
    }

    return $retValue    
}




########################################################################################
#
# Procedure:        ipv6::getFormatPrefix
#
# Description:      Returns the format prefix of an IPv6 address.
#
# Argument(s):      address
#               
# Returns:          format prefix (enums: ipV6NSAPAllocation, ipV6GlobalUnicast, 
#                                         ipV6LinkLocalUnicast, ipV6SiteLocalUnicast,
#                                         ipV6IPXAllocation, ipV6Multicast)
#
########################################################################################
proc ipv6::getFormatPrefix {address} \
{
    set retValue {}

    if {![ipV6Address decode $address]} {
        set retValue [list [ipV6Address cget -prefixValue]]
    }        

    return $retValue
}


########################################################################################
#
# Procedure:        ipv6::getTopLevelAggregationId
#
# Description:      Returns the top level aggregation id of the global aggregate address.
#
# Argument(s):      address
#               
# Returns:          top level aggregation id
#
########################################################################################
proc ipv6::getTopLevelAggregateId {address} \
{
    set retValue {}

    if {![ipV6Address decode $address]} {
        if {[ipV6Address cget -prefixType] == $::ipV6GlobalUnicast} {
            set retValue [ipV6Address cget -topLevelAggregationId]
        }        
    }        

    return $retValue
}

########################################################################################
#
# Procedure:        ipv6::getNextLevelAggregationId
#
# Description:      Returns the Next Level Aggregation Id of the Global Aggregate address.
#
# Argument(s):      address
#               
# Returns:          next level aggregation id
#
########################################################################################
proc ipv6::getNextLevelAggregateId {address} \
{
    set retValue {}

    if {![ipV6Address decode $address]} {
        if {[ipV6Address cget -prefixType] == $::ipV6GlobalUnicast} {
            set retValue [ipV6Address cget -nextLevelAggregationId]
        }        
    }        

    return $retValue
}

########################################################################################
#
# Procedure:        ipv6::getSiteLevelAggregationId
#
# Description:      Returns the Site Level Aggregation Id of the Global Aggregate address.
#
# Argument(s):      address
#               
# Returns:          site level aggregation id
#
########################################################################################
proc ipv6::getSiteLevelAggregateId {address} \
{
    set retValue {}

    if {![ipV6Address decode $address]} {
        if {[ipV6Address cget -prefixType] == $::ipV6GlobalUnicast} {
            set retValue [ipV6Address cget -siteLevelAggregationId]
        }        
    }        

    return $retValue
}


########################################################################################
#
# Procedure:        ipv6::getSubnetId
#
# Description:      Returns the Subnet Id of the Site Local address.
#
# Argument(s):      address
#               
# Returns:          subnet id
#
########################################################################################
proc ipv6::getSubnetId {address} \
{
    set retValue {}

    if {![ipV6Address decode $address]} {
        if {[ipV6Address cget -prefixType] == $::ipV6SiteLocalUnicast} {
            set retValue [ipV6Address cget -subnetId]
        }        
    }        

    return $retValue
}

########################################################################################
#
# Procedure:        ipv6::getInterfaceId
#
# Description:      Returns the Interface Id Global Aggregate, Site Local, or Link
#                       local address.
#
# Argument(s):      address
#               
# Returns:          interface id
#
########################################################################################
proc ipv6::getInterfaceId {address} \
{
    set retValue {}

    if {![ipV6Address decode $address]} {
        switch [ipV6Address cget -prefixType] "
            $::ipV6GlobalUnicast -
            $::ipV6SiteLocalUnicast -
            $::ipV6LinkLocalUnicast {
                set retValue [list [ipV6Address cget -interfaceId]]
            }        
        "        
    }        

    return $retValue
}

########################################################################################
#
# Procedure:        ipv6::getLoopbackAddress
#
# Description:      Returns the loopback address.
#
# Argument(s):      None
# Argument(s):      None
#               
# Returns:          loopback address
#
########################################################################################
proc ipv6::getLoopbackAddress {} \
{
    variable addressLoopback
    return $addressLoopback
}    


########################################################################################
#
#   Validation Utilities
#   
########################################################################################

########################################################################################
#
# Procedure:        ipv6::isValidAddress
#
# Description:      TRUE/FALSE: Is the given ipv6 address valid?
#
# Argument(s):      address
#                   type:       unicast (default), anycast, multicast
#               
# Returns:          ::true or ::false
#
########################################################################################
proc ipv6::isValidAddress {address {type unicast}} \
{
    variable ipV4AddressSize 

    set retCode $::false

    set segments        8
    set nibbleSize      4
    
    set segmentsBefore  {}
    set segmentsAfter   $address
    set ipv4Address     {}
    
    set count [regsub -all ":" $address ":" address]
    if {$count > 0 && $count <= [expr $segments-1]} {
    
        if {[isMixedVersionAddress $address]} {
            set end [expr [llength [split $address :]] - 1]
            set ipv4Address [lindex [split $address :] $end]
            regsub "$ipv4Address" $address {} address
            regsub -all {(.*)\.(.*)\.(.*)\.(.*)} $ipv4Address \
                {[format "%02x%02x:%02x%02x" \1 \2 \3 \4]} ipv4Address
            set ipv4Address [subst $ipv4Address]
            append address $ipv4Address
        }
        
        #
        # Fill in the zeroes needed to expand.
        set segmentsBefore {}
        set segmentsAfter  $address
        
        if {[regexp {(.*)::(.*)} $address match segmentsBefore segmentsAfter]} {
            set segmentsBefore [split $segmentsBefore :]
            set segmentsAfter  [split $segmentsAfter  :]
            set segmentsNeeded [expr  $segments - ([llength $segmentsBefore] + [llength $segmentsAfter])]
            set segmentList "$segmentsBefore [string repeat " 0" $segmentsNeeded] $segmentsAfter"
        } else {
            set segmentList [split $address :]
        }
        
        if {[llength [join $segmentList]] == 8} {
            set retCode $::true
            foreach segment $segmentList {
                if {[regexp {[^0-9a-fA-f]} $segment match] > 0} {
                    set retCode $::false
                    break
                }
                if {[mpexpr 0x$segment > 0xffff]} {
                    set retCode $::false
                    break
                }
            }
        }
    }
    

    return $retCode
}

########################################################################################
#
# Procedure:    ipv6::validAddress
#
# Description:  Given and address, determine it's validitiy
#
# Argument(s):  address:    ipv6 address
#               type:       unicast, multicast, anycast
#               
# Returns:      ::true or ::false
#
########################################################################################
proc ipv6::validateAddress {address {type unicast}} \
{
    set retCode $::true

	set retCode [isValidAddress $address]

	if { $retCode } {

		switch $type {
			unicast -
			anycast {
				
			}
			multicast {
				set retCode [isValidMCAddress $address]
			}
			default {
				set retCode $::false
			}
		}
	}

    return $retCode
}

########################################################################################
#
# Procedure:        ipv6::isReservedMCAddress
#
# Description:      TRUE/FALSE: Is this a reserved multicast address?
#
# Argument(s):      address:    Ipv6 address
#               
# Returns:          ::true or ::false
#
########################################################################################
proc ipv6::isReservedMCAddress {address} \
{
    variable reservedMCAddressList
	set retCode $::false

	set expand_address [ipv6::expandAddress $address]
	if { [llength expand_address] } {

		# Check in the list for predefined multicast addresses
		if { [lsearch $reservedMCAddressList $expand_address] < 0 } {

			# Check for Solicited-node addresses
			if {[string first "ff02:0000:0000:0000:0000:0001:ff" $expand_address] < 0 } {
			
				# Check for Service location addresses
				if { [string first "ff05:0000:0000:0000:0000:0000:0001" $expand_address] == 0} {
					set splittedAddr [split $expand_address ":"]
					set comparedPart [format "0x%s" [lindex $splittedAddr 7]]	
					if { $comparedPart >= 0x1000 &&  $comparedPart <= 0x13ff } {	
						set retCode $::true
					}
				} 
			} else {
				set retCode $::true
			}	
		} else {
			set retCode $::true
		}
	}

    return $retCode
}


########################################################################################
#
# Procedure:        ipv6::isValidMCAddress
#
# Description:      TRUE/FALSE: Is this a reserved multicast address?
#
# Argument(s):      address:    Ipv6 address
#               
# Returns:          ::true or ::false
#
########################################################################################
proc ipv6::isValidMCAddress {address} \
{
    set retCode $::false

	set expand_address [ipv6::expandAddress $address]
	if { [llength expand_address] } {

		set splittedAddr [split $expand_address ":"]
		set mcastPart [format "0x%s" [lindex $splittedAddr 0]]
		if { $mcastPart >= 0xff00 &&  $mcastPart <= 0xff1f } {	
			set retCode $::true
		}
	}
			
    return $retCode
}

########################################################################################
#
# Procedure:        ipv6::isMixedVersionAddress
#
# Description:      Given an IPv6 address, determine if it is compiled of both
#                   IPv4 and IPv6 components, ie:
#
#                           0:0:0:0:0:0:192.168.10.1 
#
# Argument(s):      address:    Ipv6 address (any acceptable IPv6 format)
#               
# Returns:          ::true or ::false
#
########################################################################################
proc ipv6::isMixedVersionAddress {address} \
{
    set retCode $::false
    set address [lindex [split $address :] end]
    if {[llength [split $address .]] == 4} {
        set retCode $::true
    }
        
    return $retCode
}

########################################################################
# Procedure:    incrIpV6Field
#
# Description:  Increments the specified field of a 128 bit IPv6 address
#
# Argument(s):  ipAddress:  IP address whose field to be incremented
#               field:      IPv6 - field to be incremented, default is interfaceId
#                                  refer to TCLIpV6Address field enumerations, or 
#								   any prefix, overflow is not supported yet
#               increment:  increment the field by this number, default is 1
#
# Returns:      Modified IP address
#
########################################################################
proc ipv6::incrIpField {address {prefix 128} {increment 1} } \
{
    variable  fieldPositions

    set newAddress {}
	set errorFlag  0

    if {[info exists fieldPositions($prefix)]} {
        set prefix $fieldPositions($prefix)	
    } else {
		if {[isValidInteger $prefix] } {
			if { $prefix  > 128 || $prefix  < 0 } { 
				errorMsg "Error: Invalid prefix value, must be between 0 - 128, inclusive"
				set errorFlag 1
			} 
		} else {
			set errorFlag 1
			errorMsg "Error: Invalid predefined field enumeration"
		}

	}	
	if { !$errorFlag } {  	
		ipV6Address setDefault
		if  {![ipV6Address decode $address]} {

			set prefixType [ipV6Address cget -prefixType]  
			set newAddress [incIpv6AddressByPrefix $address $prefix  $increment]
			 
			# Invalid if increment overflows into the format prefix.
			if  {![ipV6Address decode $newAddress]} {
				set newAddress [ipV6Address encode]
				if {[ipV6Address cget -prefixType] != $prefixType} {
					set newAddress {}
				}
			}
		} else {
			errorMsg "Error: Invalid ipV6 address:$address"
		}
	}

    return $newAddress
}



# This is NOT COMPLETE
# The idea was to get the previous field to the "prefix" from the fieldListByPrefix	then 
# make sure it didn't change after increment, and only supports the predefined prefixes
# in order to finish this method, we need to create one more method, and test it
# proc getOverflowField { prefix prefixType } this will return the field that is overflown

#proc ipv6::incrIpField_withOverflow {address {prefix 0} {increment 1} {wrapOverflow no} } \
#{
#    variable  fieldPositions
#
#    set newAddress {}
#	set predefinedField		0
#	set fieldMaxValue		255
#
#    if {[info exists fieldPositions($prefix)]} {
#        set prefix $fieldPositions($prefix)
#		set predefinedField 1
#    } else {
#		set wrapOverflow no
#	}
#     puts "prefix:$prefix"
#
#    ipV6Address setDefault
#    if  {![ipV6Address decode $address]} {
#
#        set prefixType [ipV6Address cget -prefixType]  
#        set newAddress [incIpv6AddressByPrefix $address $prefix  $increment]
#		if { $predefinedField } {
#			set overflowField	[getOverflowField $prefix $prefixType]
#		}
#		 
#        # Invalid if increment overflows into the format prefix.
#        if  {![ipV6Address decode $newAddress]} {	
#
#            set newAddress [ipV6Address encode]
#			if {$wrapOverflow == "yes" } {
#				set newOverflowField  [hexlist2Value [ipV6Address cget -overflowField]]
#				ipV6Address decode $address
#				set oldOverflowFieldValue [hexlist2Value [ipV6Address cget -overflowField]]
#				if { $newOverflowField >  $oldOverflowFieldValue } {
#					ipV6Address config -$prefix [value2Hexlist $increment]
#				}
#			}
#			set newAddress [ipV6Address encode] 
#		}
#    } else {
#		errorMsg "Invalid ipV6 address:$address"
#	}
#
#    return $newAddress
#} 

########################################################################
# Procedure:    convertIpv6AddrToBytes
#
# Description:  Converts the IPv6 into bytes 
#
# Argument(s):  address:      IPv6 address
#
# Returns:      
#
########################################################################
proc ipv6::convertIpv6AddrToBytes { address } \
{
    set expand_address [expandAddress $address]
    regsub -all ":" $expand_address " " expand_address
    regsub -all {([0-9a-fA-F]{2})([0-9a-fA-F]{2})} $expand_address {\1 \2} addrList
    return $addrList
}

########################################################################
# Procedure:    convertBytesToIpv6Address
#
# Description:  Converts the bytes into IPv6 address 
#
# Argument(s):  address:      IPv6 address
#
# Returns:      
#
########################################################################
proc ipv6::convertBytesToIpv6Address { bytes } \
{
   set str {}
   foreach {b1 b2} $bytes {
      lappend str "$b1$b2"
   }
   set str [join $str ":"]
   return [compressAddress [join $str ""]]
}


########################################################################
# Procedure:    incIpv6AddressByPrefix
#
# Description:  Increments the specified field of a 128 bit IPv6 address
#
# Argument(s):  ipAddress:  IP address whose field to be incremented
#               prefix:     IPv6 - field to be incremented, default is 32
#               inc:		increment the prefix by this number, default is 1
#
# Returns:      Modified IP address
#
########################################################################
proc ipv6::incIpv6AddressByPrefix {ipAddress {prefix 32} {inc 1}} \
{
    variable ipV6AddressSize 

	set retAddress {}

	if {[isValidInteger $prefix] } {
		if { $prefix  > 128 || $prefix  < 0 } { 
			errorMsg "Error: Invalid prefix value, must be between 0 - 128, inclusive"
			set errorFlag 1
		} else {
		 	set ipAddress	[expandAddress $ipAddress]
			set host		[mpexpr [hexlist2Value [convertIpv6AddrToBytes $ipAddress]] & (int(pow(2,($ipV6AddressSize - $prefix)) - 1))]
			set network		[mpexpr [hexlist2Value [convertIpv6AddrToBytes $ipAddress]] >> ($ipV6AddressSize - $prefix)]
			mpincr	network $inc

			set retAddress	[convertBytesToIpv6Address [value2Hexlist [mpexpr ($network << ($ipV6AddressSize - $prefix)) | $host] 16]]
		}
	} else {
		errorMsg "Error: Expecting integer prefix value between 0 - 128, inclusive."
	}
	return $retAddress
}

########################################################################
# Procedure:    getFieldMask
#
# Description:  Return the IPv6 Field Mask (used with stream increment).
#
# Argument(s):  field:      IPv6 - field to be incremented, default is interfaceId
#                                  refer to TCLIpV6Address field enumerations
#
# Returns:      mask
#
########################################################################
proc ipv6::getFieldMask {{field interfaceId}} \
{
    variable fieldPositions

    set mask 64

    switch $field {
        interfaceId {
            set mask 64
        }
        subnetId -
        siteLevelAggregationId -
        nextLevelAggregationId -
        topLevelAggregationId {
            if {[info exists fieldPositions($field)]} {
                set mask $fieldPositions($field)
            }
        }
    }

    return $mask
}

########################################################################
# Procedure:    getMinimumValidFramesize
#
# Description:  Returns the minimum valid header length for and IPv6
#               packet.

#               IPv6 header length can vary depending on the options
#               selected.  The base header is 40 bytes long.
#
# Argument(s):  useUdf
#               useFir
#
# Returns:      minimum acceptable frame size
#
########################################################################
proc ipv6::getMinimumValidFramesize {{useUdf true} {useFir true}} \
{
    global kFirSize	kCrcSize kUdfSize kHeaderLength

    if {$useFir == "true"} {
        set firSize $kFirSize
    } else {
        set firSize 0
    }

    if {$useUdf == "true"} {
        set udfSize $kUdfSize
    } else {
        set udfSize 0
    }

    set minimum [expr [getHeaderLength] + \
                      $firSize + \
                      $udfSize + \
                      $kCrcSize]

    set minimum [expr $minimum & 0xfffffffe]

}

########################################################################
# Procedure:    getHeaderLength
#
# Description:  Return the length of the IPv6 Header including the
#               MAC and UDP headers (in other words, everything up to
#               the payload).
#
#               NOTE:   THis is incomplete since it handles only
#                       the simplest case... needs work.
#
# Arguments(s): None
#
# Returns:      length of IPv6 header
#
########################################################################
proc ipv6::getHeaderLength {} \
{
    global kHeaderLength

    set headerLength 0

    if {[protocol cget -name] == $::ipV6} {
        set headerLength   $::DaSaLength
        switch [protocol cget -ethernetType] "
            $::ethernetII -
            $::ieee8023 -
            $::ieee8022 {
                incr headerLength   2
            }
            $::ieee8023snap {
                incr headerLength   10
            }
        "
        incr headerLength [expr $::kHeaderLength(ipV6) + $::udpHeaderLength]
    }

    return $headerLength
}

########################################################################
# Procedure:    getAddressFieldOffset
#
# Description:  Return the offset to the given address field from the
#               start of the IPv6 address field (not from the start of
#               the header).
#
# Arguments(s): field:      prefix, topLevelAggregationId, nextLevelAggregationId,
#                           siteLevelAggregationId, subnetId, interfaceId
#
# Returns:      Offset
#
########################################################################
proc ipv6::getAddressFieldOffset {field} \
{
    variable  fieldOffsets

    set retValue 0

    if {[info exists fieldOffsets($field)]} {
        set retValue $fieldOffsets($field)
    }

    return $retValue
}
