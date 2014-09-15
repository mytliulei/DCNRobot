##################################################################################
# Version   3.65    $ Revision: $
# $Date: 12/12/02 2:03p $
# $Author: Dheins $
#
# $Workfile: tunnelStreamBuilder.tcl $ - Tunneling Throughput test
#
#   Copyright © 1997 - 2004 by IXIA
#   All Rights Reserved.
#
#   Revision Log:
#   10-31-2003      DHG  Initial
#
# Description:      Contains procedures used to build tunnel streams
#
##################################################################################

########################################################################################
# Procedure:    tunnel::buildTunnelStreamParms
#
# Description:  Given a payload packet, encapsulate it within the tunnel protocol.
#
# Arguments:    streamName:     name of stream
#               tx_c tx_l tx_p: tx port
#               rx_c rx_l rx_p: rx port
#               Packet:         payload packet (previously built)
#               preambleSize:   default 8
#
# Return(s):    TCL_OK or TCL_ERROR
#
########################################################################################
proc tunnel::buildStreamParms {streamName tx_c tx_l tx_p rx_c rx_l rx_p Packet {preambleSize 8} {incrementFramesize 1} } \
{
    upvar $Packet packet

    set retCode $::TCL_OK

    set tunnelProtocol      [tunnel cget -tunnelProtocol]
    set payloadProtocol     [tunnel cget -payloadProtocol]

    # Get MAC & IP addresses for the DA/SA
    if {[port get $rx_c $rx_l $rx_p]} {
        errorMsg "Error: Rx Port [getPortId $rx_c $rx_l $rx_p] not configured yet."
        set retCode $::TCL_ERROR
    }

    set rxMac               [port cget -MacAddress]
    set rxDUTMac            [port cget -DestMacAddress]
    set rxNumAddresses      [port cget -numAddresses]
    
    if {[port get $tx_c $tx_l $tx_p]} {
        errorMsg "Error: Tx Port [getPortId $tx_c $tx_l $tx_p] not configured yet."
        set retCode $::TCL_ERROR
    }

    set txMac               [port cget -MacAddress]
    set txDUTMac            [port cget -DestMacAddress]
    set txNumAddresses      [port cget -numAddresses]

    switch $tunnelProtocol {

        ip {
            stream config -sa           $txMac
            stream config -numSA        1
            stream config -numDA        1

            if {[ip get $tx_c $tx_l $tx_p]} {
                errorMsg "Error: Unable to get IP on [getPortId $tx_c $tx_l $tx_p]"
                set retCode $::TCL_ERROR
            }

            ip config -destIpAddr               [ip cget -destDutIpAddr]

            ip config -ttl                      [advancedTestParameter cget -ipTTL]
            ip config -destIpAddrMode       ipIdle
 
            ip config -ipProtocol $payloadProtocol
            if {$payloadProtocol == "ipV6"} {
                ip config -ipProtocol $::ipV6Payload
            }

            if {[ip set $tx_c $tx_l $tx_p]} {
                errorMsg "Error: Unable to set IP on [getPortId $tx_c $tx_l $tx_p]."
                set retCode $::TCL_ERROR
            }

            if {[udp get $tx_c $tx_l $tx_p]} {
                errorMsg "Error: Unable to get UDP on [getPortId $tx_c $tx_l $tx_p]"
                set retCode $::TCL_ERROR
            }

            udp config -enableChecksum          true
            udp config -enableChecksumOverride  true
            udp config -checksum                0
            udp config -sourcePort              [advancedTestParameter cget -udpSourcePort]
            udp config -destPort                [advancedTestParameter cget -udpDestPort]

            if {[udp set $tx_c $tx_l $tx_p]} {
                errorMsg "Error setting Udp on [getPortId $tx_c $tx_l $tx_p]"
                set retCode $::TCL_ERROR
            }
        }
        ipV6 {
            stream config -sa           $txMac
            stream config -numSA        1
            stream config -numDA        1
            
            # This is done only when we run Layer3 traffic on Layer2 device         
            if {[learn cget -type] == "mac"} {
                stream config -da       $rxMac
            } else {
                stream config -da       $txDUTMac
            }

            if [ipV6 get $rx_c $rx_l $rx_p] {
                errorMsg "Error: Unable to get IPv6 on [getPortId $rx_c $rx_l $rx_p]."
                set retCode $::TCL_ERROR
            }

            set rxIP [ipV6 cget -sourceAddr]

            if [ipV6 get $tx_c $tx_l $tx_p] {
                errorMsg "Error getting IPv6 on [getPortId $tx_c $tx_l $tx_p]"
                set retCode $::TCL_ERROR
            }

            ipV6 config -destAddr               $rxIP
            ipV6 config -destAddrRepeatCount    $rxNumAddresses

            if {$rxNumAddresses > 1} {
                ipV6 config -destAddrMode       ipV6IncrHost
            } else {
                ipV6 config -destAddrMode       ipV6Idle
            }

            ipV6 config -nextHeader             $payloadProtocol

            if [ipV6 set $tx_c $tx_l $tx_p] {
                errorMsg "Error: Unable to set IPv6 on [getPortId $tx_c $tx_l $tx_p]."
                set retCode $::TCL_ERROR
            }

            if [udp get $tx_c $tx_l $tx_p] {
                errorMsg "Error getting Udp on [getPortId $tx_c $tx_l $tx_p]"
                set retCode $::TCL_ERROR
            }

            udp config -enableChecksum          true
            udp config -enableChecksumOverride  true
            udp config -checksum                0
            udp config -sourcePort              [advancedTestParameter cget -udpSourcePort]
            udp config -destPort                [advancedTestParameter cget -udpDestPort]

            if [udp set $tx_c $tx_l $tx_p] {
                errorMsg "Error: Unable to set UDP on [getPortId $tx_c $tx_l $tx_p]."
                set retCode $::TCL_ERROR
            }
        }
        default {
        }
    }

    # Calculate tunnel packet's length.
    set headerLength            [getHeaderLength $tunnelProtocol]
    set framesize               [expr [llength $packet] + $headerLength + 4]

    if {$incrementFramesize == 1 } {    
            stream config -framesize    $framesize
    }

    stream config -patternType  nonRepeat 
    stream config -dataPattern  userpattern
    stream config -pattern      $packet

    stream config -name         [format "%s_%s" $streamName $tunnelProtocol]
    stream config -enableIbg    false
    stream config -enableIsg    false
    stream config -preambleSize $preambleSize

    # Setup UDF to increment payload packet's addresses if necesary.
    set retCode [setupIncrementingIP $rx_c $rx_l $rx_p $rxNumAddresses packet]

    return $retCode
}



########################################################################################
# Procedure:    tunnel::setupIncrementingIP
#
# Description:  Setup a UDF to create incrementing IP/IPv6 addresses for the payload
#               packet of a tunnel.
#
# Arguments:    chassis-card-port:  Rx port
#               rxNumAddresses:     Number of addresses per recieve port
#               Packet:             Payload of tunnel
#               udf:                default 4
#
# Return(s):    TCL_OK or TCL_ERROR
#
########################################################################################
proc tunnel::setupIncrementingIP {chassis card port rxNumAddresses Packet {udf 4}} \
{
    upvar $Packet packet

    set retCode $::TCL_OK

    if {$rxNumAddresses > 1} {

        set payloadProtocol [tunnel cget -payloadProtocol]
        set tunnelProtocol  [tunnel cget -tunnelProtocol]
        
        set tunnelIpOffset  [getFieldOffsetInTunnel $payloadProtocol $tunnelProtocol destination]
        set payloadIpOffset [getFieldOffset $payloadProtocol destination]
        
        set udfPattern {}
        udf setDefault
        
        # Determine udfPattern (based on address) & counter size.
        switch $payloadProtocol {
            ip {
                set udfPattern      [lrange $packet $payloadIpOffset [expr $payloadIpOffset + 3]]
                set counter         [format "c%s" 32]
            }
            ipV6 {
                set incrementField  interfaceId
        
                set address         [lrange $packet $payloadIpOffset [expr $payloadIpOffset + ($::ipv6::ipV6AddressSize/8-1)]]
                ipV6Address         decode $address
                set addressField    [ipV6Address cget -$incrementField]
                set udfPattern      [lrange $addressField end-3 end]
        
                set counter [format "c%s" [expr [llength $udfPattern] * 8]]
        
                incr tunnelIpOffset [ipv6::getAddressFieldOffset $incrementField]
                incr tunnelIpOffset [expr [llength $addressField] - [llength $udfPattern]]
            }
        }

        udf config -enable      true
        udf config -offset          $tunnelIpOffset
        udf config -initval     $udfPattern
        udf config -counterMode     udfCounterMode
        udf config -countertype     $counter
        udf config -maskselect      {00 00 00 00}
        udf config -maskval         {00 00 00 00}
        udf config -random      false
        udf config -continuousCount false
        udf config -repeat      $rxNumAddresses

        if {[udf set $udf]} {
            errorMsg "Error: Unable to set UDF $udf"
            set retCode $::TCL_ERROR
        }
    }
    return $retCode
}


########################################################################################
# Procedure:    tunnel::buildAutomaticAddress
#
# Description:  Build an address for automatic tunneling.
#
#               Tunnels which are configured for automatic tunnels derive the tunnel
#               endpoint address from the address of the packet in the tunnel.  The
#               following summarizes the conversions supported:
#
#               Isatap: Uses the existing upper 64 bits of the IPv6 address, the 
#                       succeeding 32 bits contain 0x00005efe, the final 32 bits contain
#                       and IPv4 address.
#                       Example: 2000:0:0:1:0:5efe:c612:0164 (Ipv4 address = 198.18.1.100)
#
#               IPv4 Compatible:    Prepends the lower 32 bits containing an IPv4 address
#                       with zeros.
#                       Example: 0:0:0:0:0:0:c612:0164 (Ipv4 address = 198.18.1.100)
#
#               6to4:   Prepends the lower 32 bits containing an IPv4 address,
#                       with zeros, the high 16 bits contains a special address 2002 which
#                       identies the address as 6to4.
#                       Example: 2002:0:0:0:0:0:c612:0164 (Ipv4 address = 198.18.1.100)
#
# Arguments:    chassis-card-port:  port
#               direction:          destination or source
#
# Return(s):    Converted address
#
########################################################################################
proc tunnel::buildAutomaticAddress {chassis card port {direction destination}} \
{
    set retValue {}

    # Automatic mode required.
    if {[tunnel cget -tunnelConfiguration] == "automatic"} {

        set addressType     [tunnel cget -addressType]
        set tunnelProtocol  [tunnel cget -tunnelProtocol]
 
        if {![eval $tunnelProtocol get $chassis $card $port]} {
            switch $tunnelProtocol {

                ip {
                    switch $direction {
                        destination {
                            set address    [ip cget -destIpAddr]
                        }
                        source {
                            set address    [ip cget -sourceIpAddr]
                        }
                    }
                }
                ipV6 {
                    switch $direction {
                        destination {
                            set address    [ipV6 cget -destAddr] 
                        }
                        source {
                            set address    [ipV6 cget -sourceAddr]
                        }
                    }
                }
            }

            set args ""
            if {$addressType == "isatap"} {
                #set prefixAddress [ipV6 cget -sourceAddr]
                set prefixAddress [testConfig::getFirstDestDUTIpV6Address]
                if {$direction == "destination"} {
                    set prefixAddress [ipV6 cget -destAddr]
                }
                set mask    [expr [ipv6::getFieldMask] / 8]
                set args    [string range [ipv6::expandAddress $prefixAddress] 0 [expr $mask*2-1+3]]

                debugMsg "$chassis $card $port direction=$direction mask=$mask args=$args"

            } elseif {$addressType == "6to4"} {
                set args 2002
            }                  
            set retValue [ipv6::convertAddress $address $tunnelProtocol $addressType $args]
        } else {
            logMsg [format "Error: %s not configured" $tunnelProtocol]
        }
    }
    debugMsg "Tunnel Address Type: [tunnel cget -addressType]"
    return $retValue
}


