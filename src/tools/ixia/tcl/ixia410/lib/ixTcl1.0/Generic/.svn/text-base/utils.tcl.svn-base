########################################################################
# Version 4.10   $Revision: 314 $
# $Author: Debby $
#
# $Workfile: utils.tcl $
#
#   Copyright © 1997 - 2005 by IXIA
#   All Rights Reserved.
#
#       Revision Log:
#       05-7-1998       Hardev Soor
#
# Description: This file contains common commands used by the tests
#
########################################################################


########################################################################
# Procedure: globalSetDefault
#                       
# Description: This command calls the setDefault for all the stream/port related
# commands as a form of initialization.
#
# Arguments(s):
#
########################################################################
proc globalSetDefault {} \
{
    udf setDefault
    stream setDefault
    filter setDefault
    filterPallette setDefault

    capture setDefault
    captureBuffer setDefault
    stat setDefault

    qos setDefault

    protocolStackSetDefault
}


########################################################################
# Procedure: protocolStackSetDefault
#
# This command calls the setDefault for all the protocol stack related
# commands as a form of initialization.
#
# Arguments(s):
#
########################################################################
proc protocolStackSetDefault {} \
{
    global ixProtocolList

    foreach protocol $ixProtocolList {
        $protocol setDefault
    }
}

########################################################################
# Procedure: streamSet
#
# Description: This command sets the stream and prints an error message based on the 
# return code
#
# Argument(s):
#   chasId      - chassis id
#   cardId      - card id
#   portId      - port id
#   streamId    - stream id
#
# Results :     0 : No error found, else error
#                  
########################################################################
proc streamSet { chasId cardId portId streamId } \
{
    set level [expr [info level] - 2]
    if {$level > 0} {
        set levelStr    "[lindex [info level $level] 0]: "
    } else {
        set levelStr    "Error: "
    }

    set retCode [stream set $chasId $cardId $portId $streamId] 
    switch $retCode \
        $::ixTcl_outOfMemory {
            logger message "$levelStr Error setting stream $streamId on port [getPortId $chasId $cardId $portId] - Port is out of memory"
        }\
        $::ixTcl_generalError   {               
            logger message "$levelStr Error setting stream $streamId on port [getPortId $chasId $cardId $portId]"
        }\
        $::ixTcl_notAvailable {
            logger message "$levelStr Port [getPortId $chasId $cardId $portId] is unavailable, check ownership."
        }\
        $::ixTcl_ok -\
        default {
        }

    return $retCode
}


########################################################################
# Procedure: validateFramesizeForUSB 
#
# This command checks card type against USB card types
#
########################################################################
proc validateFramesizeForUSB {TxRxArray frameSizeList} \
{
    upvar $TxRxArray txRxArray

    set retCode 0
    set maxUsbFramesize 1514
    
    foreach txMap [getTxPorts txRxArray] {
        scan $txMap "%d %d %d" tx_c tx_l tx_p

        if {[port getInterface $tx_c $tx_l $tx_p] == $::interfaceUSB } {          
            if { [IsPortUSBMode $tx_c $tx_l $tx_p] } {
                foreach fs $frameSizeList {
                    if {$fs > $maxUsbFramesize} {                
                        set retCode 1
                        break            
                    }                   
                }
            }           
        }
    }

    return $retCode    
}


########################################################################
# Procedure:    validateFramesize
#
# Description:  Checks the framesize against 64-1518 valid EN type 
#                   framesize and tests against protocol restrictions
#
# Arguments(s): framesize   - framesize to validate
#
# Returns:      TCL_OK or TCL_ERROR (if invalid)
#
########################################################################
proc validateFramesize {framesize} \
{
    set retCode $::TCL_ERROR

    switch [getProtocolName [protocol cget -name]] {
        ipV6 {
            set minimumFramesize [ipv6::getMinimumValidFramesize]
            if {$framesize >= $minimumFramesize} {
                set retCode $::TCL_OK
            }
        }
        ip -
        mac -
        default {
            return $::TCL_OK
        }
    }

    return $retCode
}


########################################################################
# Procedure:    validateFramesizeList
#
# Description:  Checks the framesize against 64-1518 valid EN type 
#                   framesize and tests against protocol restrictions
#
# Arguments(s): framesizeList:  framesizes to validate
#
# Returns:      TCL_OK or TCL_ERROR (if invalid)
#
########################################################################
proc validateFramesizeList {framesizeList} \
{
    set retCode $::TCL_ERROR

    foreach framesize $framesizeList {
        set retCode [validateFramesize $framesize]
        if {$retCode == $::TCL_ERROR} {
            break
        }
    }

    return $retCode
}


########################################################################
# Procedure: validatePreamblesize
#
# This command checks the preamble size against 2-256 valid EN preamble size
#
# Arguments(s):
#       preambleSize   - Preamblesize to validate
#
########################################################################
proc validatePreamblesize {preambleSize} \
{
    set retCode 0

    if {$preambleSize > 256 || $preambleSize < 2} {
        logMsg "Invalid preamble size, must be between 2 & 256"
        set retCode 1
    }

    return $retCode
}


########################################################################
# Procedure: getLearnProc
#
# This command determines which learn proc to use
#
# Arguments(s):
#   portArray       - port map, ie. one2oneArray, one2manyArray, etc
#
########################################################################
proc getLearnProc {{portArray ""}} \
{
    set learnproc       send_learn_frames

    if {[learn cget -type] == "default"} {
        learn config -type      [getProtocolName [protocol cget -name]]
    }
       
    switch [learn cget -type]  {
        default -
        mac     {
                set learnproc   send_learn_frames
        }
        ip      {
                set learnproc   send_arp_frames
        }
        ipx     {
                set learnproc   send_ripx_frames
        }
        ipV6    {
                set learnproc   send_neighborDiscovery_frames
        }

    }

    return $learnproc
}


########################################################################
# Procedure:    validateProtocol
#
# Description:  This command validates the protocol type for this test
#
# Arguments:    protocols:  list of allowable protocols for this test, 
#                               ie. {mac ip ipx ipV6}
#
# Returns:      ::TCL_OK or TCL_ERROR
#
########################################################################
proc validateProtocol {protocols} \
{
    set retCode $::TCL_OK

    set protocolName [getProtocolName [protocol cget -name]]
    switch $protocolName {
        mac  -
        ip   -
        ipx  -
        ipV6 {
            if {[lsearch $protocols $protocolName] == -1} {
                set retCode $::TCL_ERROR
            }
        }
        default {
            set retCode $::TCL_ERROR
        }
    }
    return $retCode
}


########################################################################
# Procedure: initMaxRate
#
# This command initializes an array containing the max rate values per
# all TX ports in the array
#
# Arguments(s):
#   PortArray       - port map, ie. one2oneArray, one2manyArray, etc
#   maxRateArray    - array containing the max rates for each tx port
#   framesize       - framesize ref for max rate
#   userRateArray   - array containing the actual user rate to tx
#   percentRate     - user-specifed percent of max rate
#   preambleSize
#
########################################################################
proc initMaxRate {PortArray maxRateArray framesize {userRateArray ""} {percentRate 100} {preambleSize 8}} \
{
    upvar $PortArray portArray
    upvar $maxRateArray maxRate

    if {[string length $userRateArray] > 0} {
        upvar $userRateArray userRate
    }

    set retCode $::TCL_OK

    set txRxList    [getAllPorts portArray]

    foreach portMap $txRxList {
        scan $portMap "%d %d %d" c l p

        set maxRate($c,$l,$p)   [calculateMaxRate $c $l $p $framesize $preambleSize]
        set userRate($c,$l,$p)  [expr round($percentRate/100. * $maxRate($c,$l,$p))]

        if {$userRate($c,$l,$p) > $maxRate($c,$l,$p)} {
            logMsg "****** WARNING: Rate $userRate($c,$l,$p) fps exceeded Maximum Rate $maxRate($c,$l,$p) for [getPortId $c $l $p]"
            set userRate($c,$l,$p) $maxRate($c,$l,$p) 
        }

        if {$userRate($c,$l,$p) <= 0} {
            logMsg "****** ERROR: Rate cannot be 0 for [getPortId $c $l $p]"
            set retCode $::TCL_ERROR
        }
    }


    return $retCode
}


########################################################################
# Procedure: buildIpMcastMacAddress
#
# This command builds the MAC address to use when transmitting multi-
# cast packets.
#
# Arguments(s):
#       groupAddress    IP multicast group address
#
# NOTE:The Ethernet directly supports the sending of local multicast
# packets by allowing multicast addresses in the destination field of 
# Ethernet packets. All that is needed to support the sending of
# multicast IP datagrams is a procedure for mapping IP host group
# addresses to Ethernet multicast addresses. 
#
# An IP host group address is mapped to an Ethernet multicast address 
# by placing the low-order 23-bits of the IP address into the low-order
# 23 bits of the Ethernet multicast address 01-00-5E-00-00-00 (hex)
# [RFC1112]. Because there are 28 significant bits in an IP host group
# address, more than one host group address may map to the same Ethernet
# multicast address. 
########################################################################
proc buildIpMcastMacAddress {groupAddress} \
{
    set mcastIP [host2addr $groupAddress]

    # the lower 3 bytes of DA need to match the lower 23 bits of the multicast IP addr
    set DA  [format "%02x %02x %02x %02x %02x %02x" 01 00 0x5e \
                    [expr "0x[lindex $mcastIP 1]" & 0x7f] \
                    "0x[lindex $mcastIP 2]" \
                    "0x[lindex $mcastIP 3]"]

    return $DA
}


########################################################################
# Procedure: setPortName
#
# This command sets a character string name to a specified port
#
# Arguments(s):
#   portName      - name of port
#   chassis
#   card  
#   port
#
# Return:
#       TCL_OK if port found
#
########################################################################
proc setPortName {portName chassis card pt} \
{
    set retCode 0

    if [catch {port get $chassis $card $pt} retCode] {
        global ixgPortNameMap
        set ixgPortNameMap($chassis,$card,$pt)    $portName
        set retCode 0
    } else {
        port config -name   $portName
        if [port set $chassis $card $pt] {
            set ixgPortNameMap($chassis,$card,$pt)    $portName
        }
    }

    return $retCode
}


##################################################################################
# Procedure: getPortString
#
# This command gets the port name as a string.
#
##################################################################################
proc getPortString {c l p {testCmd results}} \
{
    set portname [getPortName $c $l $p]

    if {[$testCmd cget -portNameOption] == "both" && $portname != ""} {   
        set portString [format "%s.%s.%s %s" $c $l $p $portname]
    } elseif {[$testCmd cget -portNameOption] == "number" && $portname != ""} {
        set portString $portname
    } elseif {[$testCmd cget -portNameOption] == "name" && $portname != ""} {
        set portString $portname
    } else {
        set portString [format "%s.%s.%s" $c $l $p]
    }

    return $portString
}


########################################################################
# Procedure: getPortId
#
# This command gets the portID + character string name of a port
#
# Arguments(s):
#   c
#   l  
#   p
#
# Return:
#       portName
#
########################################################################
proc getPortId {c l p} \
{

    if [catch {port getId $c $l $p} portname] {
        set portname  "$c.$l.$p "
    }

    return $portname
}


########################################################################
# Procedure: getPortName
#
# This command gets the character string name from a specified port
#
# Arguments(s):
#   chassis
#   card  
#   port
#   default - optionally, if no name was specified, name defaults
#             to "$chassis.$card.$port", otherwise empty string returned.
#
# Return:
#       portName
#
########################################################################
proc getPortName {chassis card port {default default}} \
{
    set retCode  0
    set portName ""

    global ixgPortNameMap

    if [catch {port get $chassis $card $port} retCode] {
        if [catch {set portName $ixgPortNameMap($chassis,$card,$port)}] {
            set portName    ""
        }
    } else {
        if [info exists ixgPortNameMap($chassis,$card,$port)] {
            set portName $ixgPortNameMap($chassis,$card,$port)
            setPortName  $portName $chassis $card $port
            unset ixgPortNameMap($chassis,$card,$port)
        } 
     
        if {$retCode != 0} {  
            set portName    ""
        } else {
            set portName    [port cget -name]
        }      
    }

    if {$portName == "" && $default == "default"} {
        set portName    "$chassis.$card.$port"
    }

    return $portName
}


########################################################################################
# Procedure: setPortFactoryDefaults
#
# Description: This command sets the factory defaults on a port
#
# Argument(s):
#   chassis -
#   card    -
#   port    -
#
########################################################################################
proc setPortFactoryDefaults {chassis card port} \
{
    set retCode [port setFactoryDefaults $chassis $card $port]
    switch $retCode "
        $::ixTcl_ok {
        }
        $::ixTcl_generalError {
			errorMsg \"Error setting factory defaults on port [getPortId $chassis $card $port].\"
        }
        $::ixTcl_notAvailable {
            errorMsg \"Port [getPortId $chassis $card $port] is unavailable, check ownership.\"
        }
    "

    return $retCode
}


########################################################################################
# Procedure: setFactoryDefaults
#
# Description: This command sets the factory defaults on all ports in the map
#
# Argument(s):
#   portList     - list containing all ports to set factory defaults on, may be an array
#
########################################################################################
proc setFactoryDefaults {portList {write nowrite}} \
{
    set retCode $::TCL_OK

    foreach port $portList {
        scan $port "%d %d %d" chassisId cardId portId

        set retCode [setPortFactoryDefaults $chassisId $cardId $portId]
        if {$retCode != $::TCL_OK} {
            break
        }
    }

    if {$retCode == $::TCL_OK && $write == "write"} {
        ixWritePortsToHardware portList
    }

    return $retCode
}


########################################################################
# Procedure: getProtocolName
#
# This command returns the protocol as a character string name
#
# Arguments(s):
#       protocol        integer value of protocol, from protocol cget -name
#
# Return:
#       character name of protocol or 0 if error
#
########################################################################
proc getProtocolName {protocol} \
{
    global kProtocol

    # this is for scripts that are sending valid ip packets, but
    # we are treating it like an l2 test
    if {[advancedTestParameter cget -l2DataProtocol] == "ip"} {
        set name "mac"
        return $name
    }

    foreach {pr name} [array get kProtocol] {
        if {$protocol == $pr} {
            return $name
        }
    }

    return 0
}


########################################################################
# Procedure: getDuplexModeString
#
# This command returns the duplex mode as a character string name
#
# Arguments(s):
#       duplexMode      integer value of duplex mode, from port cget -duplex
#
# Return:
#       character name of duplex mode or 0 if error
#
########################################################################
proc getDuplexModeString {duplex} \
{
    global kDuplexMode

    foreach {dp name} [array get kDuplexMode] {
        if {$duplex == $dp} {
                return $name
        }
    }

    return 0
}


########################################################################
# Procedure: disableUdfs
#
# This command disables the udfs in the list.
#
# Arguments(s):
#       udfList     Tcl list of udfs to disable, in the form {1 2 3 4}
#
# Return:
#       1 if error
#
########################################################################
proc disableUdfs {udfList} \
{
    set retCode 0

    udf config -enable  false
    foreach u $udfList {
        if [udf set $u] {
            set retCode 1
        }
    }

    return $retCode
}


########################################################################
# Procedure: getIpClassName
#
# This command returns the class type of IP address as a character string name
#
# Arguments(s):
#       classNum        integer value of IP addr class, from ip cget -class
#
# Return:
#       character name of IP addr class or 0 if error
#
########################################################################
proc getIpClassName {classNum} \
{
    global kIpAddrClass

    foreach {ipclass className} [array get kIpAddrClass] {
        if {$classNum == $ipclass} {
                return $className
        }
    }

    return 0
}


########################################################################
# Procedure: getMinimum
#
# This command returns the minimum value in the passed array
#
# Arguments(s):
#       ValArray        - array of values
#
# Return:
#       minimum value in array
#
########################################################################
proc getMinimum {ValArray} \
{
    upvar $ValArray valArray

    foreach index [array names valArray] {
        if {[info exists minimum] && $valArray($index) >= $minimum} {
            continue
        }
        set minimum $valArray($index)
    }

    if {![info exists minimum]} {
        set minimum 0
    }

    return $minimum
}


########################################################################
# Procedure: swapPortList
#
# This command swaps the Tx/Rx pairs
#
# Argument(s):
#       portList        list of ports, ie, one2oneArray, one2manyArray etc
#       newList         copied list
#
########################################################################
proc swapPortList {portList newList} \
{
    upvar $portList old
    upvar $newList  new

    set retCode 0

    if [info exists new] {
        unset new
    }

    foreach txMap [lsort [array names old]] {
        scan $txMap "%d,%d,%d" tx_c tx_l tx_p

        foreach rxMap [lsort $old($txMap)] {
            scan [join $rxMap]  "%d %d %d" rx_c rx_l rx_p

            set new($rx_c,$rx_l,$rx_p) [lappend new($rx_c,$rx_l,$rx_p) [list $tx_c $tx_l $tx_p]]
        }
    }

        return $retCode
}


########################################################################
# Procedure: copyPortList
#
# This command copies the port array into another local variable
#
# Argument(s):
#       portList        list of ports, ie, one2oneArray, one2manyArray etc
#       newList         copied list
#
########################################################################
proc copyPortList {SourceList DestList} \
{
    upvar $SourceList   sourceList
    upvar $DestList     destList

    array set destList [array get sourceList]

    return $::TCL_OK
}


########################################################################
# Procedure: removePorts
#
# This command removes ports from the port array/list. 
#
# Argument(s):
#       PortList        port map or list of ports, ie, one2oneArray, one2manyArray etc
#       removePortList  list of ports to be removed from the PortList
#
########################################################################
proc removePorts {PortList removePortList} \
{

    upvar $PortList portList

    set retCode 0

    if [array exists portList] {
        foreach txMap [array names portList] {

            scan [split [join $txMap] ,] "%d %d %d" tx_c tx_l tx_p

            if {[lsearch $removePortList [list $tx_c $tx_l $tx_p]] >= 0} {
                logMsg "Removing TX port [getPortId $tx_c $tx_l $tx_p] from map..."
                unset portList($tx_c,$tx_l,$tx_p)
                continue
            }

            foreach rxMap $portList($tx_c,$tx_l,$tx_p) {

                set index [lsearch $removePortList $rxMap]

                if {$index >= 0} {
                    logMsg "Removing RX port [join $rxMap ,] from map..."
                    set rmIndex [lsearch $portList($tx_c,$tx_l,$tx_p) $rxMap]

                    set portList($tx_c,$tx_l,$tx_p) [lreplace $portList($tx_c,$tx_l,$tx_p) $rmIndex $rmIndex]

                    if {[llength $portList($tx_c,$tx_l,$tx_p)] <= 0} {
                        unset portList($tx_c,$tx_l,$tx_p)
                    }

                }                    
            }
        }

        if {[llength [array names portList]] == 0} {
            set errMsg "Error - invalid map after removing ports!!!"
            #errorMsg "Error - invalid map after removing ports!!!"
            set retCode 1    
        }

    } else {

        if { [llength $portList] >0 && [llength  $removePortList] > 0 } {
            foreach portMap $removePortList {
                scan [join $portMap] "%d %d %d" c l p

                set index    [lsearch $portList [list $c $l $p]]
                if {$index >= 0} {
                    logMsg "Removing port [join [split $portMap ,] ,] from map..."
                    set portList [lreplace $portList $index $index]
                }
            }
        } else {
            logMsg "No ports to remove."
            set retCode 1
        }
    }

    return $retCode
}


########################################################################
# Procedure: lnumsort
#
# This command sorts a list (like ports) into numerical order
#
# Argument(s):
#       option        -decending
#       MyList        list of stuff
#
########################################################################
proc lnumsort {option {MyList ""}} \
{
    if {[string index [lindex $option 0] 0] != "-"} {
        set MyList  $option
        set sortedList  [lsort -dictionary $MyList]
    } else {
        set sortedList  [lsort -dictionary $option $MyList]
    }

    return $sortedList
}


########################################################################
# Procedure: mergeLists
#
# This command merges two lists
#
# Arguments(s):
#   MergedList  - returned merged list w/dups removed
#   args        - variable number of lists to be merged together
#   <sortedOrder - return list in sorted order, default is no sort>
#
# Return values:
#   If there are duplicate items in the list, returns number of dups, otherwise
#   returns 0
#
########################################################################
proc mergeLists {MergedList args} \
{
    upvar $MergedList   mergedList

    set mergedList  ""
    set sortFlag    0
    set duplicate   0

    foreach list $args {
        if {$list == "sortedOrder"} {
            set sortFlag    1
            continue
        }
        foreach item $list {
            if {[lsearch $mergedList $item] >= 0} {
                incr duplicate
            } else {
                lappend mergedList $item
            }
        }
    }

    if {$sortFlag} {
        set mergedList  [lnumsort $mergedList]
    }

    return $duplicate
}



########################################################################
# Procedure:    host2addr
#
# Description:  This command converts an IP address in form 100.101.102.103 
#               to a list of hex bytes all in upper case letters.
#
# Arguments(s): ipAddr: ip address to convert
#
# Return(s):    IP address in list of hex bytes
#
########################################################################
proc host2addr {ipAddr} \
{
    set ipHex        {}

    set delimiter .
    regexp {([:.])} $ipAddr match delimiter

    set protocol [expr [string match $delimiter :]?"ipV6":"ip"]

    switch $protocol {
        ipV6 {
            set ipHex [ipv6::host2addr $ipAddr]
        }
        ip {
            set ipname [split $ipAddr $delimiter]
            if {[llength [string trim [join $ipname]]] == 4} {
                foreach i $ipname {
                    if {$i > 255 || $i < 0} {
                        set ipHex {}
                        break
                    }
                    set hexCharacter [format "%02X" $i]
                    set ipHex [linsert $ipHex end $hexCharacter]
                }
            }
        }
    }

    return $ipHex
}


########################################################################
# Procedure:    long2IpAddr
#
# Description   Converts long word into an IP address in 
#                   form x.y.z.a
#
# Argument(s):  longword to convert
#
# Returns:      Ip Address x.y.z.a OR 
#               0.0.0.0 if invalid input arguments
#
#########################################################################
proc long2IpAddr {value} \
{
    if [catch {set ipAddress "[expr {(($value >> 24) & 0xff)}].[expr {(($value >> 16) & 0xff)}].[expr {(($value >> 8 ) & 0xff)}].[expr {$value & 0xff}]"} ipAddress] {
        set ipAddress 0.0.0.0
    }

    return $ipAddress
}


########################################################################
# Procedure:    byte2IpAddr
#
# Description   Converts 4 hexideciaml bytes into an IP address in 
#                   form x.y.z.a
#
# Argument(s):  hexBytes:   list of bytes to convert
#
# Returns:      Ip Address x.y.z.a OR 
#               0.0.0.0 if invalid input arguments
#
#########################################################################
proc byte2IpAddr {hexBytes} \
{
    set newIpAddr       "0.0.0.0"

    # Validate input parameters.

    # If given a string of 8 bytes instead of list of 4, convert it to a list.
    set hexBytes       [string trim $hexBytes]
    set hexBytesLength  [llength $hexBytes]

    if {$hexBytesLength == 1} {

        if {[string length [string trim $hexBytes]] == 8} {

            set hexBytesString  $hexBytes
            set hexBytes [list]
            for {set i 0} {$i < 4} {incr i} {
                lappend hexBytes   [string range   $hexBytesString 0 1]
                set hexBytesString [string replace $hexBytesString 0 1]
            }

        } else {
            set hexBytes [list 0 0 0 0]
        }

    } elseif {$hexBytesLength != 4} {
        set hexBytes [list 0 0 0 0]
    }


    # Convert to decimal.
    regsub -all {(.*) (.*) (.*) (.*)} $hexBytes \
        {[format "%d %d %d %d" "0x\1" "0x\2" "0x\3" "0x\4"]} newIpAddr
    if {[catch {subst $newIpAddr} newIpAddr]} {
        set newIpAddr [list 0 0 0 0]
    }

    # If any invalid values, return 0.0.0.0
    foreach byte $newIpAddr {
        if {$byte < 0 || $byte > 255} {
            set newIpAddr [list 0 0 0 0]
            break
        }
    }
    set newIpAddr [join $newIpAddr .]

    debugMsg "byte2IpAddr: newIpAddr = $newIpAddr"
    return $newIpAddr
}




########################################################################
# Procedure: num2ip
#
# Description:
#   This command convert a number to an IP address.
# 
# Arguments(s):
#   num - number
#
# Returns: 
#   An IP address.
#             
########################################################################
proc num2ip {num} \
{
    set ipAddr [format "%d.%d.%d.%d" [expr {($num >> 24) & 255}] [expr {($num >> 16) & 255}] \
                                     [expr {($num >>  8) & 255}] [expr { $num        & 255}]]
    return $ipAddr
}



########################################################################
# Procedure: ip2num
#
# This command converts an IP address of the form d.d.d.d into a 32-bit
# unsigned number.
#
# Arguments(s):
#   ipAddr      - ip address of the form d.d.d.d
#
# Return:
#   ipNum
#
########################################################################
proc ip2num {ipAddr} \
{
    set ipNum   0

    if {[scan $ipAddr "%d.%d.%d.%d" a b c d] == 4} {
        set ipNum   [format %u [expr {($a<<24)|($b<<16)|($c<<8)|$d}]]
    }

    return $ipNum
}


########################################################################
# Procedure: long2octet
#
# This command converts a multi-byte number into multi octets in a list
#
# Argument(s):
#       value           the value to convert
#
#########################################################################
proc long2octet {value {sizeInBytes 2} } \
{

    switch $sizeInBytes {
            2 {
                return  [format "%02x %02x" \
                                    [expr {(($value >> 8) & 0xff)}]   \
                                    [expr   {$value & 0xff}]]
            }
            3 {
                return  [format "%02x %02x %02x" \
                                    [expr {(($value >> 16) & 0xff)}]  \
                                    [expr {(($value >> 8 ) & 0xff)}]  \
                                    [expr   {$value & 0xff}]]
            }
            4 {
                return  [format "%02x %02x %02x %02x" \
                                    [expr {(($value >> 24) & 0xff)}]  \
                                    [expr {(($value >> 16) & 0xff)}]  \
                                    [expr {(($value >> 8 ) & 0xff)}]  \
                                    [expr   {$value & 0xff}]]     
            }
            1 -
            default {
                return [list [format %02x $value ]]
            }
    }  
}


########################################################################
# Procedure: list2word
#
# This command converts a 2-byte list into a word
#
# Argument(s):
#       mylist           the value to convert
#
#########################################################################
proc list2word {mylist} \
{
    set listlength  [llength $mylist]
    set result      0

    if {$listlength <= 2 && $listlength > 0} {
        incr listlength -1
        set j 0
        for {set i $listlength} {$i >= 0} {incr i -1} {
            incr result  [expr [hextodec [lindex $mylist $i]] << ($j * 8)]
            incr j                
        }
    }

    return $result
}

########################################################################
# Procedure: value2Hexlist
#
# Description:	This command converts a number into a hex
#
# Argument(s):
#   value   - a number
#	width	- the hex list lenght to be generated
#
#########################################################################
proc value2Hexlist { value width } \
{
    set retValue {}
    while { $width } {
        set retValue [linsert $retValue 0 [format "%02x" [mpexpr $value & 255]]]
        incr width -1
        set value [mpexpr $value >> 8]
    }
    return $retValue
}

########################################################################
# Procedure: hexlist2Value
#
# Description:	This command converts a hex list into a number
#
# Argument(s):
#       hexlist		- the hex list ( example {01 02 03 04} )
#
#########################################################################
proc hexlist2Value { hexlist } \
{
   set retValue 0
   foreach byte $hexlist {
      set retValue [mpexpr ($retValue << 8) | 0x$byte]
   }
   return $retValue
}



########################################################################
# Procedure:    expandHexString
#
# Description:  Expands a string of delimited hex values:
#
#                   0 a b 1  becomes 00 0a 0b 01
#                   0:a:b:21 becomes 00:0a:0b:21
#
#               Does not verify the validity of the original hex string.
#
# Argument(s):  bytesList
#               delimiter
#
# Returns:      expanded hex string
#
#########################################################################
proc expandHexString {byteList {delimiter :}} \
{
    set hexList [list]

    regsub -all $delimiter $byteList " " byteList
    foreach byte $byteList {
        regsub -all {(.*)} $byte \
            {[format "%02x " 0x\1]} byte 
        append hexList [subst "$byte"]
    }
    regsub -all " " [string trim $hexList] $delimiter hexList

    return $hexList
}


########################################################################
# Procedure: getMultipleNumbers
#
# This procedure gives two numbers that are multiples of each other but
# less than the allowed maximum number. If he "number" is a prime number
# than this procedure may not be useful.
#
# Argument(s):
#       number              the number whose multiple is to be found
#       maxAllowedNum   the maximum allowed number
#       numA                the multiplier
#       numB                    the divider
#
#########################################################################
proc getMultipleNumbers {number maxAllowedNum numA numB} \
{
    upvar $numA a
    upvar $numB b

    # just pick an arbitrary number for max value for loop
    for {set divider 2} {$divider <= 1000} {incr divider} {
        set result      [mpexpr $number/$divider]
        set remainder   [mpexpr $number%$divider]
        if {$remainder != 0} {
            continue
        }
        if {$result > $maxAllowedNum} {
            continue
        }
        set a $result
        set b $divider
        return 0
    }

    return 1
}


########################################################################
# Procedure: hextodec
#
# This command converts a hex number to a decimal number
#
# Argument(s):
#   number  - hex number to convert
#
########################################################################
proc hextodec {number} \
{
    if [catch {format "%u" "0x$number"} retCode] {
        logMsg "Invalid hex number: $number"
        set retCode -1
    }
    return $retCode
}


########################################################################
# Procedure: dectohex
#
# This command converts a decimal number to a hex number
#
# Argument(s):
#   number  - decimal number to convert
#
########################################################################
proc dectohex {number} \
{
    if [catch {format "%x" $number} retCode] {
        logMsg "Invalid decimal number: $number"
        set retCode -1
    }

    return $retCode
}


########################################################################
# Procedure: incrMacAddress
#
# This command increments the last three bytes (24-bit word) of the MAC
# address.
#
# Argument(s):
#   macaddr         mac address to increment
#   amt             increment the field by this number
#
########################################################################
proc incrMacAddress {macaddr amt} \
{
    upvar $macaddr valList

    set hexnum [format "%02x%02x%02x" "0x[lindex $valList 3]" \
                             "0x[lindex $valList 4]" "0x[lindex $valList 5]"]
    set decnum [hextodec $hexnum]
    set decnum [incr decnum $amt]
    set hexnum [format "%06x" "0x[dectohex $decnum]"]

    scan $hexnum "%02s%02s%02s" byte3 byte4 byte5

    set valList [lreplace $valList 3 3 $byte3]
    set valList [lreplace $valList 4 5 $byte4 $byte5]
    return $valList
}


########################################################################
# Procedure: incrIpField
#
# Description: Increments the specified byte of IP address
#
#
# Argument(s):
#   ipAddress       IP address whose byte to be incremented
#   byteNum         the byte field to be incremented
#   amount             increment the field by this number
#
########################################################################
proc incrIpField {ipAddress {byteNum 4} {amount 1}} \
{
    set one [ip2num $ipAddress]
    set two [expr {$amount<<(8*(4-$byteNum))}]

    return  [long2IpAddr [expr {$one + $two}]]
}



########################################################################
# Procedure: incrIpFieldHexFormat
#
# Description: Increments the specified byte of IP address.  Both the input
#              and returned IP address are in hex format.
#
#
# Argument(s):
#   ipAddress       IP address whose byte to be incremented (It's in the form
#                    of 4 byte hex number:  ex, "4c 2e 01 05"  
# 
#   byteNum         the byte field to be incremented
#   amount          increment the field by this number
#
########################################################################
proc incrIpFieldHexFormat {ipAddress {byteNum 4} {amount 1}} \
{
    set hexIpAddr   0x[join $ipAddress ""]

    set val [format %x [expr [format %d $hexIpAddr] + [expr {$amount<<(8*(4-$byteNum))}]]]
    return [long2octet [format %d "0x$val"] 4]
}


########################################################################
# Procedure: assignIncrMacAddresses
#
# Description: Assigns an incrementing MAC address
#
# Argument(s):
#   portList       a list of sorted ports
#
########################################################################
proc assignIncrMacAddresses {portList} \
{
    logMsg "Assigning incrementing addresses on all ports ..."
    set retCode $::TCL_OK

    scan [lindex $portList 0] "%d %d %d" c l p
    set currMacAddr [join [list 00 [format "%02x %02x" $l $p ] 00 00 00 ]]

    foreach maplist $portList {
        scan $maplist "%d %d %d" c l p

        if {![IsPOSPort $c $l $p] } {
            if [port get $c $l $p] {
                errorMsg "Error getting port [getPortId $c $l $p]"
                set retCode $::TCL_ERROR
            }

            port config -MacAddress $currMacAddr
            if [port set $c $l $p] {
                errorMsg "Error setting port [getPortId $c $l $p]"
                set retCode $::TCL_ERROR
            }

            logMsg "[getPortId $c $l $p] ====>  MAC: $currMacAddr"
            set currMacAddr [incrMacAddress currMacAddr [port cget -numAddresses]]
        }
    }
    return $retCode
}


########################################################################
# Procedure: incrHostIpAddr
#
# Description: Increments the host portion of the IP address
#              NOTE:  will carry!!
#
# Argument(s):
#   ipAddress      - ip address to increment
#   amount         - amount to increment by
#
########################################################################
proc incrHostIpAddr {ipAddress {amount 1}} \
{
    return [incrIpField $ipAddress 4 $amount]
}


########################################################################
# Procedure: waitForResidualFrames
#
# Description: Waits for residual rx frames
#
# Argument(s):
#   time        - time to wait
#
########################################################################
proc waitForResidualFrames {time} \
{
    logMsg "Waiting for Residual frames to settle down for $time seconds"
    for {set timeCtr 1} {$timeCtr <= $time} {incr timeCtr} {
        logMsg "Waited for $timeCtr of $time seconds"
        after 1000
    }
}


########################################################################################
# Procedure: getPerTxArray
#
# Description: Helper proc that seperates multiple map per Tx port
#
# Arguments(s):
#   TxRxArray       - map, ie. one2oneArray
#   PerTxArray      - per Tx map, ie. one2one or one2many
#   txPort          - tx port
#   testCmd         - name of test command, ie. tput
#
########################################################################################
proc getPerTxArray {TxRxArray PerTxArray txPort } \
{
    upvar $TxRxArray    txRxArray
    upvar $PerTxArray   perTxArray

    set retCode 0

    if [info exists perTxArray] {
        unset perTxArray
    }
    foreach rxPort $txRxArray($txPort) {
        scan [join $rxPort] "%d %d %d" rx_c rx_l rx_p               
        set perTxArray($txPort)   [lappend perTxArray($txPort) [list $rx_c $rx_l $rx_p]] 
    }

    return $retCode
}


########################################################################
# Procedure: getTxPorts
#
# Description: Gets all the Tx ports from any map array passed.
#
# Argument(s):
#   MapArray        the reference to map array to be scanned
#
# Returns:
#   txList          List containing all Tx ports
#
########################################################################
proc getTxPorts {MapArray} \
{
    upvar $MapArray mapArray

    set txList {}

    if [info exists mapArray] {
        if {[array exists mapArray]} {
            foreach txMap [array names mapArray] {

                regsub -all "," $txMap " " txPort

                if {[lsearch $txList $txPort] == -1} {
                    # add this Tx port to the list
                    lappend txList $txPort
                }
            }
        } else {
            foreach port $mapArray {
                lappend txList [join [split $port ',']]
            }
        }
    }

    return [lsort -dictionary $txList]
}


########################################################################
# Procedure: getRxPorts
#
# Description: Gets all the Tx ports from any map array passed.
#
# Argument(s):
#   MapArray        the reference to map array to be scanned
#
# Returns:
#   rxList          List containing all Rx ports
#
########################################################################
proc getRxPorts {MapArray} \
{
    upvar $MapArray mapArray

    set rxList {}

    if [info exists mapArray] {

        if {[array exists mapArray]} {

            foreach {txMap rxMap} [array get mapArray] {

                foreach rxPort $rxMap {
                    if {[lsearch $rxList $rxPort] == -1} {
                        # add this Rx port to the list
                        lappend rxList $rxPort
                    }
                }
            }

        } else {
            foreach port $mapArray {
                lappend rxList [join [split $port ',']]
            }
        }
    }

    return [lsort -dictionary $rxList]
}


########################################################################
# Procedure:    getAllPorts
#
# Description:  Gets all the ports from any map array passed.
#
# Argument(s):  MapArray:   Reference to map array to be scanned
#
# Returns:      portList:   List containing all ports
#
########################################################################
proc getAllPorts {MapArray} \
{
    upvar $MapArray mapArray

    set portList {}

    if [info exists mapArray] {
        if {[array exists mapArray]} {

            foreach {txMap rxMap} [array get mapArray] {

                regsub -all "," $txMap " " txPort

                if {[lsearch $portList $txPort] == -1} {
                    # add this Tx port to the list
                    lappend portList $txPort
                }

                foreach rxPort $rxMap {
                    if {[lsearch $portList $rxPort] == -1} {
                        # add this Rx port to the list
                        lappend portList $rxPort
                    }
                }
            }
        } else {
            foreach port $mapArray {
                lappend portList [join [split $port ',']]
            }
        }
    }

    return [lsort -dictionary $portList]
}


########################################################################
# Procedure: comparePortArray
#
# This command compares two arrays; if one array contains ports that
#           the other array doesn't, it will optionally remove those ports
#
# Argument(s):
#       KeepArray        array of ports to compare against
#       CompareArray     array to check
#       removePorts      optionally remove ports from compareArray that
#                        are not in keepArray
#
# Return:
#       returns 1 if ports are in CompareArray that are not in KeepArray
#
########################################################################
proc comparePortArray {KeepArray CompareArray {removePorts remove}} \
{
    upvar $KeepArray     keepArray
    upvar $CompareArray  compareArray

    set retCode 0

    set keepList   [getAllPorts keepArray]

    foreach txPort [array names compareArray] {
        scan [split [join $txPort] ,] "%d %d %d" c l p
        # if we don't find the tx port in the keepArray, remove it from the compareArray
        if {[lsearch $keepList "$c $l $p"] == -1 && [info exists compareArray]} {
            if {$removePorts == "remove"} {
                unset compareArray($txPort)
            }
            set retCode 1
            continue
        }
        # now cycle through the rx ports & remove them if they're not in the keepArray
        foreach rxPort $compareArray($txPort) {
            scan [join $rxPort] "%d %d %d" c l p

            if {[lsearch $keepList "$c $l $p"] == -1} {
                if {$removePorts == "remove"} {
                    set index                 [lsearch  $compareArray($txPort) "$c $l $p"]
                    set compareArray($txPort) [lreplace $compareArray($txPort) $index $index]
                }
                set retCode 1
            }
            if {[llength $compareArray($txPort)] <= 0} {
                unset compareArray($txPort)
            }
        }
    }

    return $retCode
}


########################################################################
# Procedure: mergePortArray
#
# Description:  This command merges the two array into one (TxRxArray and 
#               MapArray are merged into TxRxArray
#              
#
# Argument(s):
#        TxRxArray  - first array before merge and then final array after merge
#        mapArray   - second array to be merged into TxRxArray
# 
#
########################################################################
proc mergePortArray { TxRxArray MapArray } \
{
    upvar $TxRxArray    txRxArray
    upvar $MapArray     mapArray

    set retCode 0

    foreach txMap [array names mapArray] {
        scan $txMap "%d,%d,%d" tx_c tx_l tx_p
        foreach rxMap $mapArray($txMap) {
            scan [join $rxMap] "%d %d %d" rx_c rx_l rx_p
            
            if [info exists txRxArray($txMap)] {
                if {[lsearch $txRxArray($txMap) [list $rx_c $rx_l $rx_p]] < 0} {
                    lappend txRxArray($txMap)  [list $rx_c $rx_l $rx_p]
                }
            } else {
                set txRxArray($txMap)  [list [list $rx_c $rx_l $rx_p]]
            }  
        }
    }

    return $retCode
}


########################################################################
# Procedure: getAdvancedSchedulerArray
#
# This command seperates the portmap that supports adand other portmap from txRxArray
#
# Argument(s):
# 
#   TxRxArray               - map, ie. one2oneArray
#   AdvancedSchedulerArray  - map for interfaces that support advanced stream scheduler
#   OtherArray              - map for rest of the interfaces (rest of the TxRxArray)
#
########################################################################
proc getAdvancedSchedulerArray {TxRxArray AdvancedSchedulerArray OtherArray} \
{
    upvar $TxRxArray                txRxArray
    upvar $AdvancedSchedulerArray   advancedSchedulerArray
    upvar $OtherArray               otherArray

    set retCode 0

    if [info exists advancedSchedulerArray] {
        unset interfaceArray
    }

    if [info exists otherArray] {
        unset otherArray
    }

    foreach txMap [lnumsort [array names txRxArray]] {
        scan $txMap "%d,%d,%d" tx_c tx_l tx_p
        foreach rxMap $txRxArray($tx_c,$tx_l,$tx_p) {
            scan [join $rxMap] "%d %d %d" rx_c rx_l rx_p

            if [port isValidFeature $tx_c $tx_l $tx_p portFeatureAdvancedScheduler] {
                if [info exist advancedSchedulerArray($tx_c,$tx_l,$tx_p)] {
                    if { [lsearch $advancedSchedulerArray($tx_c,$tx_l,$tx_p) [list $rx_c $rx_l $rx_p]] < 0 } {
                        set advancedSchedulerArray($tx_c,$tx_l,$tx_p)   [lappend advancedSchedulerArray($tx_c,$tx_l,$tx_p) [list $rx_c $rx_l $rx_p]]
                    }
                } else {
                    set advancedSchedulerArray($tx_c,$tx_l,$tx_p)   [lappend advancedSchedulerArray($tx_c,$tx_l,$tx_p) [list $rx_c $rx_l $rx_p]]
                }
            } else {
                if [info exist otherArray($tx_c,$tx_l,$tx_p)] {
                    if { [lsearch $otherArray($tx_c,$tx_l,$tx_p) [list $rx_c $rx_l $rx_p]] < 0 } {
                        set otherArray($tx_c,$tx_l,$tx_p)   [lappend otherArray($tx_c,$tx_l,$tx_p) [list $rx_c $rx_l $rx_p]]
                    }
                } else {
                    set otherArray($tx_c,$tx_l,$tx_p)   [lappend otherArray($tx_c,$tx_l,$tx_p) [list $rx_c $rx_l $rx_p]]
                }                
            }
        }
    }

    debugMsg "advancedSchedulerArray: [array get advancedSchedulerArray]"
    debugMsg "otherArray: [array get otherArray]"

    return $retCode
}


########################################################################
#
# NOTE: This proc is only used by Scriptmate, it will be removed from
#       IxOs eventually
#
# Procedure: cleanUpMultiuser
#
# Description: Clears ownership and does ixLogout if applicable
#
# Argument(s):
#
########################################################################
proc cleanUpMultiuser {} \
{
    global multiList

    if {[info exists multiList] && ([llength $multiList] > 0)} {
          ixClearOwnership $multiList
          logMsg "Cleared ownership for the following ports:"
          logMsg "$multiList"
    }

    if {[testConfig::getLoginId] != ""} {
          logMsg "[testConfig::getLoginId] - logging out."
          ixLogout
    }

}


########################################################################
# Procedure: cleanUp
#
# Description: Cleans up global memory & empties the chassis chain
#
# Argument(s):
#
########################################################################
proc cleanUp {} \
{
    global halCommands testConf
    global chassisGroup ixStopTest

    # Special case that sometimes happens that a global named item existed
    if {[string compare [info globals item] "item"] == 0} {
        global item
        catch {unset item}
    }

    set ixStopTest 0

    dhcpStopTimers

    #if {(![info exists cleanUpDone]) || ($cleanUpDone == 1)} {
    #   return
    #   }

    # destroy the chassisGroup - we don't really care if it succeeded or not...
    if [info exists chassisGroup] {
        if {[info commands portGroup] != ""} {
            portGroup destroy $chassisGroup
        }
    }

    foreach item [info globals ixg*] {
        global $item
        catch {unset $item}
    }



    # delete all chassis from the chain, call destructors of SWIG commands
    # and forget the package
    if {[info commands chassisChain] != ""} {
        chassisChain removeAll
    }

    if [info exists halCommands] {
        foreach halCmd $halCommands {
            if {[info commands $halCmd] != ""} {
                debugMsg "Deleting      $halCmd"
                rename $halCmd ""
                # remove this commands from the list
                lreplace $halCommands 0 0
            }
        }

        # now delete the list
        unset halCommands
    }

    # we need to delete the pointer refs too, because otherwise the next package req will be using stale pointers
    foreach ptr [info global *Ptr] {
        if [catch {unset ::$ptr} msg] {puts $msg}
    }

    if [info exists testConf] {
        unset testConf
    }

    debugOff
    logOff

    ixFileUtils::closeAll

    if {[isUNIX]} {
        if [tclServer::isTclServerConnected] {
            tclServer::disconnectTclServer
        }
    }

    package forget IxTclHal
	package forget IxTclProtocol

    if [info exists defineCommand::commandList] {
        foreach testCmd $defineCommand::commandList {
            if { $testCmd != "results" } {               
                $testCmd setDefault
            }

        }
    }

    ixTclHal::cleanUpDone

    return
}


###############################################################################
# Procedure: isIpAddressValid
#
# Description: Verify that the ip address is valid.
#
# Arguments: ipAddress - the ip address to validate
#
# Returns: true if the ip address is valid, false otherwise.
###############################################################################
proc isIpAddressValid {ipAddress} {

    set retCode $::true

    if {[info tclversion] == "8.0"} {
        # Advanced regular expressions are not supported in 8.0

        # First check to see that there are four octets
        if {[regexp {^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$} $ipAddress]} {

            # Now check each octet for a legitimate value
            foreach byte [split $ipAddress .] {
                if {($byte < 0) || ($byte > 255)} {
                    set retCode $::false
                    break
                }
            }
        } else {
            set retCode $::false
        }
    } else {

        # The ip address should be four octets
        if {[regexp {^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$} \
                $ipAddress]} {

            # Now check each octet for a legitimate value
            foreach byte [split $ipAddress .] {
                if {($byte < 0) || ($byte > 255)} {
                    set retCode $::false
                    break
                }
            }
        } else {
            set retCode $::false
        }
    }

    return $retCode
}


###############################################################################
# Procedure:    isMacAddressValid
#
# Description:  Verify that the mac address is valid.
#
# Input:        macAddress:    address to validate
#
# Output:       TCL_OK if address is valid, else
#               TCL_ERROR
#
###############################################################################
proc isMacAddressValid {macAddress} \
{
    set retCode $::TCL_ERROR

    regsub -all { |:} $macAddress " " macAddress
    if {[llength $macAddress] == 6} {

    	set retCode $::TCL_OK
        foreach value $macAddress {
            if {[string length $value] == 2} {
                if {![regexp {[0-9a-fA-F]} $value match]} {
                    set retCode $::TCL_ERROR
                    break
                }
            } else {
                set retCode $::TCL_ERROR
                break
            }
        }
    }

    return $retCode
}


###############################################################################
# Procedure:   isPartialMacAddressValid
#
# Description: Given a mac address, is it valid.  The given address does not have 
#              to be complete
#
# Arguments:   macAddress - the partial address to verify
#
# Returns:     1 if it is valid, 0 if not valid
###############################################################################
proc isPartialMacAddressValid { macAddress } \
{
    set retCode 1

    if {[info tclversion] > 8.0} {
        if {![regexp {^([0-9a-fA-F]{1,2}( )*)*$} $macAddress]} {
            set retCode 0
        }
    } else {
        if {[string length $macAddress] > 2} {
            set splitChar [string index $macAddress 2]
            set macAddress [split $macAddress $splitChar]
        }

        foreach value $macAddress {
            if {![regexp {^([0-9a-fA-F]+)$} $value]} {
                set retCode 0
            }
        }
    }

    return $retCode
}


###############################################################################
# Procedure:   getCommandParameters
#
# Description: Retrieve the parameters for a given command.
#
# Arguments:   command - name of the command.
#    
# Returns      All the parameters of the specified command.
###############################################################################
proc getCommandParameters {command} \
{
    set commandParameters {}

    if {![info exists command] || ($command == "")} {
        return $commandParameters
    }

    set testMethods [format "%s%s" $command "Methods"]

    global $testMethods

    foreach parm [set ${testMethods}(cget)] {
        lappend commandParameters $parm
    }

    return $commandParameters
}


###############################################################################
# Procedure:   changePortLoopback
#
# Description: Retrieve the parameters for a given command.
#
# Arguments:   TxRxArray - map, ie. one2oneArray
#              enabled   - flag to enable or disable the port loopback 
#    
# Output:        TCL_OK if loopback enabled/disabled, else
#                TCL_ERROR
###############################################################################
proc changePortLoopback {TxRxArray {enabled true} {verbose noVerbose}} \
{
    upvar $TxRxArray txRxArray

    set retCode $::TCL_OK

    if {$verbose == "verbose" } {
        if {$enabled == $::true} {
            logMsg "Putting ports into loopback."    
        } else {
            logMsg "Getting ports out of loopback."
        }
    }

    foreach txMap [getAllPorts txRxArray] {
        scan $txMap "%d %d %d" c l p

        if [port get $c $l $p] {
            errorMsg "Error getting port [getPortId $c $l $p]"
            set retCode $::TCL_ERROR
        }
        port config -loopback $enabled
        
        # This part apply only to Gig SX card
        if { $enabled } {
            port config -rxTxMode $::gigLoopback
        } else {
            port config -rxTxMode $::gigNormal
        }

        if [port set $c $l $p] {
            errorMsg "Error setting port [getPortId $c $l $p]"
            set retCode $::TCL_ERROR
        }                        
    }

    if [writePortsToHardware txRxArray -noProtocolServer ] {
        errorMsg "Error writing port configurations."
        set retCode $::TCL_ERROR
    }
 
    return $retCode
}


#################################################################################
# Procedure: validateUnidirectionalMap
#
# Description: This command validates the unidirectional map
#  
# Argument(s):
# TxRxArray       - map, ie. one2oneArray
#             
# Results :       0 : No error found
#                 1 : Error found
#
#################################################################################
proc validateUnidirectionalMap {TxRxArray } \
{   
    upvar $TxRxArray txRxArray

    set retCode $::TCL_OK

    set txPortList  [getTxPorts txRxArray]
    set rxPortList  [getRxPorts txRxArray] 

    if {[map cget -echo] != "true" } {
        foreach txMap $txPortList {
             if { [lsearch $rxPortList $txMap] > -1 } {
                logMsg "***** WARNING:Invalid map configuration, only unidirectional map is allowed."
                set retCode $::TCL_ERROR
                break
             }
        }
    }

    return $retCode
}


###############################################################################
# Procedure:   getTxRxModeString
#
# Description: Retrieve the string for the value given
#
# Arguments:   modeType - txMode or rxMode
#              value    - integer value of the string 
#    
# Output:        Returns the string corresponding that value
#
###############################################################################
proc getTxRxModeString { value {modeType "TX"} } \
{
    set retString "Invalid"

    set modeType [string toupper $modeType]

    set modeTX($::portTxPacketStreams)                      portTxPacketStreams                     
    set modeTX($::portTxPacketFlows)                        portTxPacketFlows                       
    set modeTX($::portTxTcpSessions)                        portTxTcpSessions                       
    set modeTX($::portTxTcpRoundTrip)                       portTxTcpRoundTrip                      
    set modeTX($::portTxModeAdvancedScheduler)              portTxModeAdvancedScheduler             
    set modeTX($::portTxModeBert)				            portTxModeBert				            
    set modeTX($::portTxModeEcho)						    portTxModeEcho							
    set modeTX($::portTxModeBertChannelized)	            portTxModeBertChannelized	            
    set modeTX($::portTxModeDccStreams)				        portTxModeDccStreams					
    set modeTX($::portTxModeDccAdvancedScheduler)		    portTxModeDccAdvancedScheduler			
    set modeTX($::portTxModeDccFlowsSpeStreams)		        portTxModeDccFlowsSpeStreams			
    set modeTX($::portTxModeDccFlowsSpeAdvancedScheduler)   portTxModeDccFlowsSpeAdvancedScheduler	

    set modeRX($::portCapture)                  portCapture                                     
    set modeRX($::portPacketGroup)              portPacketGroup             
    set modeRX($::portRxTcpSessions)            portRxTcpSessions           
    set modeRX($::portRxTcpRoundTrip)           portRxTcpRoundTrip          
    set modeRX($::portRxDataIntegrity)          portRxDataIntegrity         
    set modeRX($::portRxFirstTimeStamp)         portRxFirstTimeStamp        
    set modeRX($::portRxSequenceChecking)	    portRxSequenceChecking	    
    set modeRX($::portRxModeBert)			    portRxModeBert			    
    set modeRX($::portRxModeIsl)				portRxModeIsl				
    set modeRX($::portRxModeBertChannelized)    portRxModeBertChannelized	
    set modeRX($::portRxModeDcc) 				portRxModeDcc 				
    set modeRX($::portRxModeEcho)				portRxModeEcho
    set modeRX($::portRxModeWidePacketGroup)	portRxModeWidePacketGroup

    if {$modeType == "TX"} {
        if [info exists modeTX($value)] {
            set retString $modeTX($value)
        }
    } else {
	    set flag  0
        set modes ""
        for {set i 0} {$i < [llength [array names modeRX]]} {incr i} {
            set enumValue [expr 1 << $i]

            if {($enumValue > 1) && [expr $value & $enumValue] && $flag} {
                append modes " | "
            }
            if {[expr $value & $enumValue]} {
                set flag 1
            }
            set enumValue [expr $value & $enumValue] 
            if [info exists modeRX($enumValue)] {
                append modes  $modeRX($enumValue)        
            }
        }
        set retString $modes
    }
 
    return $retString
}


########################################################################
# Procedure: removeStreams
#
# Description: This proc removes all the stream on ports in given map
#
# Arguments: TxRxPortList       - map, ie. one2oneArray
#
# Results :       0 : No error found
#                 1 : Error found
#
########################################################################
proc removeStreams { TxRxPortList {verbose verbose} } \
{
    upvar $TxRxPortList    txRxPortList
    
 	set retCode		$::TCL_OK
    set portList	[getAllPorts txRxPortList]
													   
    if {$verbose == "verbose"} {
        logMsg "Removing streams on the ports...\n"
    }
	
    foreach portItem $portList {
        scan $portItem "%d %d %d" chassId cardId portId

		set retValue [port isValidFeature $chassId $cardId $portId portFeaturePacketStreams]

		switch $retValue {
		    1 {
		        lappend featurePortList [list $chassId $cardId $portId]
		    }
		    0 {
		        errorMsg "!WARNING: portFeaturePacketStreams is not supported on port [getPortId $chassId $cardId $portId]"
		        continue
		    }
		}

		if [port isValidFeature $chassId $cardId $portId portFeatureAtm] {
			if {[streamQueueList select $chassId $cardId $portId]} {
				errorMsg "Error selecting streamQueueList on port $chassId $cardId $portId"
				set retCode $::TCL_ERROR
				break
			}

			if {[streamQueueList clear]} {
				errorMsg "Error clearing stream queue list on port $chassId $cardId $portId"
				set retCode $::TCL_ERROR
				break
			}			
		} else {
			if {[port reset $chassId $cardId $portId]} {
				errorMsg "Error deleting streams on port $chassId $cardId $portId"
				set retCode $::TCL_ERROR
			}
		}
	}

	if {[info exists featurePortList]} {
		set retCode [ixWriteConfigToHardware featurePortList -noProtocolServer ]
	}

	return $retCode		
}


###############################################################################
# Procedure:   getIpV4MaskWidth
#
# Description: This proc gets ip mask as input and calculates the maskWidth.
#
# Arguments:   ip mask - ipV4 format.
#    
# Returns      mask width.
###############################################################################
proc getIpV4MaskWidth {ipV4Mask} \
{
    scan $ipV4Mask "%d.%d.%d.%d" b1 b2 b3 b4
	
	set result  [mpexpr ($b4 | $b3 << 8 | $b2 << 16 | $b1 << 24) ^ 0xFFFFFFFF]
	
	for {set mask  0} { $mask < 32} {incr mask} {
		if { [mpexpr $result >> $mask] == 0} {
			break;
		}
	}
	set mask [expr 32 - $mask]
	
    return $mask
}


###############################################################################
# Procedure:   getIpV4MaskFromWidth
#
# Description: This proc takes the mask prefix as input and calculates the ip mask.
#
# Arguments:   mask width - an integer number between 0 and 32.
#    
# Returns      mask ip.
###############################################################################
proc getIpV4MaskFromWidth {maskWidth} \
{
    set mask [mpexpr (0xffffffff << (32 - $maskWidth)) & 0xffffffff]
    return [num2ip $mask]
}

