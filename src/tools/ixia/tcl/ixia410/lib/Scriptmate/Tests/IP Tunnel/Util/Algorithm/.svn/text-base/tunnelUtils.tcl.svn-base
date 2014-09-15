##################################################################################
# Version   $ Revision: $
# $Date: 12/12/02 5:22p $
# $Author: Dheins $
#
# $Workfile: tunnelUtils.tcl $ - Tunneling Throughput test
#
#   Copyright © 1997 - 2004 by IXIA
#   All Rights Reserved.
#
#   Revision Log:
#   10-01-2003      DHG  Initial
#
# Description: This file contains the script for running the Thoughput
# test via IP tunnels.
#
##################################################################################

## Procedures contained within file:

#   ::tunnel::initializePortResultArrays
#   ::tunnel::getResultListByClass
#   
#   ::tunnel::FindTranslationId
#   ::tunnel::FindTunnelId
#   ::tunnel::getTunnelTranslation
#   ::tunnel::getTunnelId
#   ::tunnel::getTranslationArray
#   ::tunnel::getTranslationList
#   ::tunnel::buildTunnelTranslations
#   ::tunnel::clearTunnelTranslations
#   
#   ::tunnel::collectPacketGroupStats
#   
#   ::tunnel::getFieldOffset
#   ::tunnel::getFieldOffsetInTunnel
#   ::tunnel::getHeaderLength
#   
#   ::tunnel::getSupportedProtocols {} 
#   
#   ::tunnel::learnEgressDut
#   ::tunnel::learnEgressDutIp
#   ::tunnel::learnEgressDutIpV6
#   ::tunnel::learnIngress
#   ::tunnel::learnIngressAndEgress
#
#   ::tunnel::getMinimumTunnels
#   ::tunnel::getMaximumTunnels


## End Procedures contained within file



##   Tunnel Namespace Variable Definitions

    # Needs to be replaced by procedure call (extension headers).                                    
    variable ::tunnel::ipV6HeaderLength       40

    variable ::tunnel::offsetIpV6Version        0x00
    variable ::tunnel::offsetIpV6TrafficClass   0x00
    variable ::tunnel::offsetIpV6PayloadLength  0x04
    variable ::tunnel::offsetIpV6NextHeader     0x06
    variable ::tunnel::offsetIpV6HopLimit       0x07
    variable ::tunnel::offsetIpV6Source         0x08
    variable ::tunnel::offsetIpV6Destination    0x18
                                                
    variable ::tunnel::offsetIpVersion          0x00
    variable ::tunnel::offsetIpHeaderLength     0x00
    variable ::tunnel::offsetIpTos              0x01
    variable ::tunnel::offsetIpTotalLength      0x02
    variable ::tunnel::offsetIpId               0x04
    variable ::tunnel::offsetIpFlags            0x06
    variable ::tunnel::offsetIpTtl              0x08
    variable ::tunnel::offsetIpProtocol         0x09    
    variable ::tunnel::offsetIpChecksum         0x0a
    variable ::tunnel::offsetIpSource           0x0c
    variable ::tunnel::offsetIpDestination      0x10

    variable ::tunnel::fieldOffset
    array set ::tunnel::fieldOffset "
        ip,version          $::tunnel::offsetIpVersion     
        ip,headerLength     $::tunnel::offsetIpHeaderLength
        ip,tos              $::tunnel::offsetIpTos         
        ip,totalLength      $::tunnel::offsetIpTotalLength 
        ip,id               $::tunnel::offsetIpId          
        ip,flags            $::tunnel::offsetIpFlags       
        ip,ttl              $::tunnel::offsetIpTtl         
        ip,protocol         $::tunnel::offsetIpProtocol    
        ip,checksum         $::tunnel::offsetIpChecksum    
        ip,source           $::tunnel::offsetIpSource
        ip,destination      $::tunnel::offsetIpDestination
        ipV6,version        $::tunnel::offsetIpV6Version      
        ipV6,trafficClass   $::tunnel::offsetIpV6TrafficClass 
        ipV6,payloadLength  $::tunnel::offsetIpV6PayloadLength
        ipV6,nextHeader     $::tunnel::offsetIpV6NextHeader   
        ipV6,hopLimit       $::tunnel::offsetIpV6HopLimit     
        ipV6,source         $::tunnel::offsetIpV6Source
        ipV6,destination    $::tunnel::offsetIpV6Destination
    "

    variable ::tunnel::tunnelTranslations

    # Used by each test to register result arrays & configuration of each.
    variable ::tunnel::portResultArrays

    # Upper Limit based up on # of packet groups allowed.
    variable ::tunnel::capacity
    set      ::tunnel::capacity(maximumTunnels)    0xE000
    set      ::tunnel::capacity(minimumTunnels)    1

    variable ::tunnel::addressTypes
    set      ::tunnel::addressTypes [list ipV4Compatible 6to4 isatap]

##   End of Tunnel Namespace Variable Definitions


########################################################################################
# Procedure:    tunnel::initializePortResultArrays
#
# Description:  Given a Tx/Rx array, set all result arrays to their initial values as
#               defined in namespace array tunnel::portResultArrays.
#
#               Note each tunnel test intializes portResultArrays as needed.
#
#               PortResultArrays possesses te following fields (sample follows):
#                  metric      |arrayName   |portDirection  |initialValue  |resetOnIteration?  |resultClass
#                  percentTput |percentTput |tx             |0.0           |false              |standard
#                   
#
# Arguments:    TxRxArray:  ie, one2oneArray
#               mode:       initial     = 1st time initialization
#                           iteration   = Suceeding initializations, arrays can be skipped
#                                         depending upon setting of iterationReset.
#
# Returns:      TCL_OK or TCL_ERROR
#
########################################################################################
proc tunnel::initializePortResultArrays {TxRxArray {mode initial}} \
{
    variable portResultArrays

    upvar $TxRxArray txRxArray

    set retCode $::TCL_OK

    foreach {metric arrayList} [array get portResultArrays] {
        scan $arrayList "%s %s %s %s %s" Array portDirection initialValue iterationReset class

        if {$mode == "iteration" && $iterationReset == "false"} {
            continue
        }

        upvar $Array array
        set retCode $::TCL_ERROR
        set command [format "get%sPorts" [stringToUpper $portDirection 0]]
        if {![catch {eval $command txRxArray} portList]} {
            set retCode $::TCL_OK
            foreach portMap $portList {
                scan $portMap "%d %d %d" c l p
                set array($c,$l,$p) $initialValue
            }
        }
    }

    return $retCode
}

########################################################################################
# Procedure:    tunnel::getResultListByClass
#
# Description:  Given a class of result metrics, return a list of result arrays
#               within that class.
#
# Arguments:    resultClass:    standard, sequence, latency or dataIntegrity
#
# Returns:      List of metric arrays or NULL
#
########################################################################################
proc tunnel::getResultListByClass {{resultClass standard}} \
{
    variable portResultArrays

    set resultMetrics [list]

    foreach {metric arrayList} [array get portResultArrays] {
        scan $arrayList "%s %s %s %s %s %s" Array portDirection initialValue iterationReset class sort

        upvar $Array array
        if {$class == $resultClass} {
            set resultMetrics [linsert $resultMetrics [expr $sort-1] $Array]
        }
    }

    return $resultMetrics
}


########################################################################
# Procedure:    getFieldOffset
#
# Description:  Given the desired protocol, return the offset to the 
#               desired field (from the beginning of the $protocol's header).
#
#               Note;   This procedure does NOT take preceding layers into
#                       account when determining offset.
#
# Arguments(s): protocol:   ip, ipV6
#               field:      ip:     version, headerLength, tos, 
#                                   totalLength, id, flags, ttl         
#                                   protocol, checksum, source, destination
#                           ipV6:   version, trafficClass, payloadLength
#                                   nextHeader, hopLimit, source, destination
#
# Returns:      offset to desired address field within protocol.
#
########################################################################
proc tunnel::getFieldOffset {protocol {field destination}} \
{
    variable fieldOffset

    set offset 0

    switch $protocol {
        default { 
            if {[lsearch [getSupportedProtocols] $protocol] >= 0} {
                if {[info exists fieldOffset($protocol,$field)]} {
                    incr offset $fieldOffset($protocol,$field)
                }
            }
        }
    }

    return $offset
}


########################################################################
# Procedure:    getFieldOffsetInTunnel
#
# Description:  Return an offset to a field inside a tunnel.
#
#               Note: If layers == all, the offset is calculated from 
#               the beginning of the packet, otherwise it is calculated
#               from the beginning of the tunnel protocol.
#
# Arguments(s): payloadProtocol:    ip, ipV6
#               tunnelProtocol:     ip, ipV6
#               field:              (refer to header in getFieldOffset)
#               layers:             all, current
#
# Returns:      offset to desired address field within the tunnel protocol.
#
########################################################################
proc tunnel::getFieldOffsetInTunnel {payloadProtocol tunnelProtocol {field destination} {layers all}} \
{
    set offset 0

    if {[lsearch [getSupportedProtocols] $payloadProtocol] >= 0  && \
        [lsearch [getSupportedProtocols] $tunnelProtocol]  >= 0  }  {

        incr offset [getHeaderLength $tunnelProtocol $layers]
        incr offset [getFieldOffset  $payloadProtocol $field]
    }    

    return $offset
}



########################################################################
# Procedure:    getHeaderLength
#
# Description:  Given the desired protocol, return the size in bytes of
#               header, including the size of the header in layers 
#               beneath.  For example, if the protocol is ip, the header 
#               length includes the size of the mac layer header as well.
#
# Arguments(s): protocol:   mac, ip, ipV6, udp
#               layers:     all or current
#
# Returns:      length of packet header
#
########################################################################
proc tunnel::getHeaderLength {protocol {layers all}} \
{
    variable ipV6HeaderLength

    set headerLength 0

    switch $protocol {

        mac {
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
        }
        ip {
            if {$layers == "all"} {
                incr headerLength [getHeaderLength mac]
            }
            incr headerLength $::ipHeaderLength 
        }
        ipV6 {
            if {$layers == "all"} {
                incr headerLength [getHeaderLength mac]
            }
            incr headerLength $ipV6HeaderLength
        }
        udp {
            if {$layers == "all"} {
                incr headerLength [getHeaderLength mac]
                incr headerLength [getHeaderLength [protocol cget -name]]
            }
            incr headerLength $::udpHeaderLength 
        }
    }

    return $headerLength
}

########################################################################
# Procedure:    getSupportedProtocols
#
# Description:  Return a list of protocols supported for tunneling.
#
# Arguments(s): None
#
# Returns:      List of protocols supported for tunneling
#
########################################################################
proc tunnel::getSupportedProtocols {} \
{
    return [list ip ipV6]
}


########################################################################
# Procedure:    clearTunnelTranslations
#
# Description:  Clear tunnel id array.
#
# Arguments(s): None
#
# Returns:      TCL_OK
#
########################################################################
proc tunnel::clearTunnelTranslations {} \
{
    variable tunnelTranslations

    catch {array unset tunnelTranslations}
    array set tunnelTranslations {}

    return $::TCL_OK
}

########################################################################
# Procedure:    buildTunnelTranslations
#
# Description:  Given a port map array, build a table of tunnel Id's.
#
# Arguments(s): PortMap:    one2oneArray, etc.
#
# Returns:      TCL_OK
#
########################################################################
proc tunnel::buildTunnelTranslations {PortArray} \
{
    variable tunnelTranslations

    upvar $PortArray portArray

    set retCode $::TCL_OK

    clearTunnelTranslations
    set protocol [tunnel cget -payloadProtocol]
    set id 1

    foreach txMap [getTxPorts portArray] {
        scan $txMap "%d %d %d" c l p

        if {![$protocol get $c $l $p]} {

            foreach rxMap $portArray($c,$l,$p) {
                scan $rxMap "%d %d %d" rxc rxl rxp
            
                switch $protocol {
                    ip {
                        set byte [testConfig::getIncrIpAddrByteNum]
                        scan [ip cget -sourceIpAddr] "%d.%d.%d.%d" 1 2 3 4
                        set prefix [format "%02x%02x" [set [expr $byte-1]] ${byte}]
                    }
                    ipV6 {
                        set prefixLength [expr [tunnel cget -prefixLength]/4]
                        regsub -all { |:} [ipv6::expandAddress [ipV6 cget -sourceAddr]] "" address
                        set prefix [string range $address 0 [expr $prefixLength-1]]

                        if {[tunnel cget -tunnelConfiguration] == "automatic"} {
                            if {[tunnel cget -encapsulation] == "ingress"} {
                                set prefix [ipv6::convertAddress [ipV6 cget -sourceAddr] ipV6 ip]
                            }
                        }
                    }
                }
            
                if {![info exists tunnelTranslations($c,$l,$p,prefix)]} {
                    set  tunnelTranslations($c,$l,$p,id)        $id
                    set  tunnelTranslations($c,$l,$p,prefix)    $prefix
                    incr id
                }
            }
        }
    }

    return $retCode
}



########################################################################
# Procedure:    getTunnelTranslation
#
# Description:  Given a portId, determine the packet group id.
#
# Arguments(s): chassis
#               card
#               port
#
# Returns:      tunnelId
#
########################################################################
proc tunnel::getTunnelTranslation {chassis card port} \
{
    variable tunnelTranslations

    set retValue {}

    if {[info exists tunnelTranslations($chassis,$card,$port,id)]} {
        set retValue $tunnelTranslations($chassis,$card,$port,id)
    }

    return $retValue
}


########################################################################
# Procedure:    getTunnelId
#
# Description:  Given a portId, determine the tunnel Id (packet groupId),
#               if IPv6, the tunnel Id is the prefix, if IP, the address.
#
# Arguments(s): chassis
#               card
#               port
#
# Returns:      tunnelId
#
########################################################################
proc tunnel::getTunnelId {chassis card port} \
{
    variable tunnelTranslations

    set retValue {}

    if {[info exists tunnelTranslations($chassis,$card,$port,prefix)]} {
        set retValue $tunnelTranslations($chassis,$card,$port,prefix)
    }

    return $retValue
}

########################################################################
# Procedure:    FindTunnelId
#
# Description:  Given a translation id (group #), return the associated
#               prefix.
#
# Arguments(s): translationId
#
# Returns:      tunnelId
#
########################################################################
proc tunnel::FindTunnelId {translationId} \
{
    variable tunnelTranslations

    set retValue {}

    foreach {c l p field value} [array get tunnelTranslations] {
        if {$field == "id"} {
            if {$value == $translationId} {
                set retValue $tunnelTranslations($c,$l,$p,prefix)
            }
        }
    }

    return $retValue
}

########################################################################
# Procedure:    FindTranslationId
#
# Description:  Given a tunnel id (prefix), return the associated
#               prefix.
#
# Arguments(s): tunnelId
#
# Returns:      translationId
#
########################################################################
proc tunnel::FindTranslationId {tunnelId} \
{
    variable tunnelTranslations

    set retValue {}

    foreach {c l p field value} [array get tunnelTranslations] {
        if {$field == "prefix"} {
            if {$value == $tunnelId} {
                set retValue $tunnelTranslations($c,$l,$p,id)
            }
        }
    }

    return $retValue
}

########################################################################
# Procedure:    getTunnelTranslationList
#
# Description:  Return a list of items from the translation table.
#               field.
#
# Arguments(s): field:  id or prefix
#
# Returns:      list of groupId's or prefixes
#
########################################################################
proc tunnel::getTranslationList {{field id}} \
{
    variable tunnelTranslations

    set retValue [list]

    set translation [array get tunnelTranslations]
    foreach {index value} $translation {
        if {[string first $field $index] >= 0} {
            lappend retValue $value
        }             
    }             

    return $retValue
}

########################################################################
# Procedure:    getTranslationArray
#
# Description:  Return an array of either group id's or prefix id's by
#               rx port.
#
# Arguments(s): NewArray:   location to store resulting array
#               field:      prefix or id (group id)
#
# Returns:      array of id's or prefix's
#
########################################################################
proc tunnel::getTranslationArray {NewArray {field prefix}} \
{
    variable tunnelTranslations

    upvar $NewArray newArray

    set retCode $::TCL_OK

    foreach {index value} [array get tunnelTranslations] {
        scan $index "%d,%d,%d,%s" c l p identifier
        if {$identifier == $field} {
            set newArray($c,$l,$p) $value
        }             
    } 

    return $retCode
}


########################################################################################
# Procedure:    tunnel::learnIngressAndEgress
#
# Description:  Perform Arp from the Rx ports to the DUT at the tunnel egress.
#
# Arguments:    PortArray:  List of ports in test
#               write:      noWrite/write configuration to hardware?  Default is write.
#
# Return(s):    TCL_OK or TCL_ERROR
#
########################################################################################
proc tunnel::learnIngressAndEgress {PortArray {write write}} \
{
    upvar $PortArray portArray

    set retCode $::TCL_OK
                           
    set portList [getTxPorts portArray]
    if {![set retCode [eval [switchLearn::getLearnProc] portList]]} {
        set retCode [learnEgressDut portArray]
    }

    return $retCode
}

########################################################################################
# Procedure:    tunnel::learnIngress
#
# Description:  Perform Arp/Neighbor Discovery from the Tx ports only at tunnel
#               entry point.
#
# Arguments:    PortArray:  List of ports in test
#               write:      noWrite/write configuration to hardware?  Default is write.
#
# Return(s):    TCL_OK or TCL_ERROR
#
########################################################################################
proc tunnel::learnIngress {PortArray {write write}} \
{
    upvar $PortArray portArray
    set retCode $::TCL_OK
    set portList [getTxPorts portArray]
    eval [switchLearn::getLearnProc] portList
    return $retCode
}

########################################################################################
# Procedure:    tunnel::learnEgressDut
#
# Description:  Perform Neighbor Discovery or Arp from the Rx ports to the DUT at the
#               tunnel egress
#
# Arguments:    PortArray:  List of ports in test
#               write:      noWrite/write configuration to hardware?  Default is write.
#
# Return(s):    TCL_OK or TCL_ERROR
#
########################################################################################
proc tunnel::learnEgressDut {PortArray {write write}} \
{
    upvar $PortArray portArray

    set retCode $::TCL_ERROR
    set portList              [getRxPorts portArray]


    switch [tunnel cget -encapsulation] {
        ingress {
            set protocol [tunnel cget -payloadProtocol]
        }
        egress {
            set protocol [tunnel cget -tunnelProtocol]
        }
    }
            
    switch $protocol {
        ip {
            set retCode [switchLearn::send_arp_frames portList] 
        }
        ipV6 {
            set retCode [switchLearn::send_neighborDiscovery_frames portList] 
        }
    }
    return $retCode
}


########################################################################################
# Procedure:    tunnel::collectPacketGroupStats
#
# Description:  Populate result arrays with collected packet group
#               statistics.
#
# Arguments:    TxRxArray:      one2oneArray
#               PGStatistics:   Array of packet group statistics in this format:
#                                   statName(resultArray)
#
#                                   where statName is the PG statistic
#                                         resultArray is the array to pass to the Results API 
#                                         (as registered with Results API)
#
#                                   Sample Array:
#                                   
#                                       array set pgStatistics {
#                                          totalFrames          rxNumFrames          
#                                          averageLatency       avgLatencyValues
#                                       }
#
#                                   In the above sample totalFrames is the name of the
#                                   packet group stat, rxNumFrames is the place to store 
#                                   the PG statistic, rxNumFrames becomes a metric parameter
#                                   when results_save is called.
#
#
#
# Return(s):    TCL_OK or TCL_ERROR
#
########################################################################################
proc tunnel::collectPacketGroupStats {TxRxArray PGStatisitics} \
{
    upvar $TxRxArray        txRxArray    
    upvar $PGStatisitics    pgStatistics

    set rxPortList [getRxPorts txRxArray]

    # Populate array with default values (zero).
    foreach {PgStat PgStatArray} [array get pgStatistics] {
        upvar ${PgStatArray} pgStatArray
        upvar ${PgStat} pgStat
        foreach rxMap $rxPortList {
            scan $rxMap "%d %d %d" rx_c rx_l rx_p
            set pgStatArray($rx_c,$rx_l,$rx_p) 0
            set txMap [getTxBasedOnRx txRxArray $rx_c $rx_l $rx_p]
            scan $txMap "%d %d %d" tx_c tx_l tx_p
            set groupId [getTunnelTranslation $tx_c $tx_l $tx_p]
            set pgStat($rx_c,$rx_l,$rx_p,$groupId) 0
        }
    }

    # Build array of packet group id's per port by Rx port.
    foreach txMap [array names txRxArray] {
        scan $txMap "%d,%d,%d" tx_c tx_l tx_p
        set groupId [getTunnelTranslation $tx_c $tx_l $tx_p]
        foreach rxMap $txRxArray($tx_c,$tx_l,$tx_p) {
            scan $rxMap "%d %d %d" rx_c rx_l rx_p
            set pgIdArray($rx_c,$rx_l,$rx_p) $groupId
        }
    }

    set pgStatisticsList [array names pgStatistics]
    
    # Populate array with packet group statistics.
     set retCode [::collectPacketGroupStats rxPortList pgIdArray $pgStatisticsList]
     unset PgStat PgStatArray
     foreach {PgStat PgStatArray} [array get pgStatistics] {
         upvar $PgStatArray pgStatArray
         foreach element [array names $PgStat] {
             scan $element "%d,%d,%d,%s" c l p tunnelId
             set pgStatArray($c,$l,$p) [set ${PgStat}($c,$l,$p,$tunnelId)]
         }
     }

    return $retCode
}


########################################################################################
# Procedure:    tunnel::getMaximumTunnels
#
# Description:  Return the maximum # of tunnels allowed in a test.
#
# Arguments:    None
#
# Return(s):    maximum # of tunnels
#
########################################################################################
proc tunnel::getMaximumTunnels {} \
{
    variable capacity
    return $capacity(maximumTunnels)
}

########################################################################################
# Procedure:    tunnel::getMinimumTunnels
#
# Description:  Return the minimum # of tunnels allowed in a test.
#
# Arguments:    None
#
# Return(s):    minimum # of tunnels
#
########################################################################################
proc tunnel::getMinimumTunnels {} \
{
    variable capacity
    return $capacity(minimumTunnels)
}


########################################################################################
# Procedure:    tunnel::configurePortProtocol
#
# Description:  Performs a similar action as testConfig::configurePortProtocol on a 
#               given protocol.  By default this action is performed on the [tunnel
#               cget -payloadProtocol], but it must also be performed on [tunnel cget
#               -tunnelProtocol].
#
# Arguments:    protocol:   ip or ipV6
#
# Return(s):    TCL_OK
#
########################################################################################
proc tunnel::configurePortProtocol {protocol PortArray} \
{
    upvar $PortArray portArray

    set txPortList [getTxPorts portArray]
    set rxPortList [getRxPorts portArray]

    set retCode $::TCL_ERROR

    set encapsulation [tunnel cget -encapsulation]

    switch $encapsulation {    
        ingress {
                foreach txPort $txPortList {
                    scan $txPort "%d %d %d" c l p
                    set portProtocol($c,$l,$p) ip
                }
                foreach rxPort $rxPortList {
                    scan $rxPort "%d %d %d" c l p
                    set portProtocol($c,$l,$p) ipV6
                }
            }

       egress {
            foreach txPort $txPortList {
                scan $txPort "%d %d %d" c l p
                set portProtocol($c,$l,$p) ipV6
            }
            foreach rxPort $rxPortList {
                scan $rxPort "%d %d %d" c l p
                set portProtocol($c,$l,$p) ip
            }
        }
    }

    if {[lsearch [getSupportedProtocols] $protocol] >= 0} {

        foreach portMap [getAllPorts portArray] {
            scan $portMap "%d %d %d" chassis card port
            switch $portProtocol($chassis,$card,$port) {
                ip {
                    set protocolList $::ipV4
                    set retCode [interfaceTable::configurePort $chassis $card $port $protocolList]
                }
                ipV6 {
                    if [ipV6 get $chassis $card $port] {
                        errorMsg "Error getting ipV6 on port $chassis $card $port"
                        set retCode $::TCL_ERROR
                    }
                    ipV6 config -hopLimit         [advancedTestParameter cget -ipV6HopLimit]
                    ipV6 config -flowLabel        [advancedTestParameter cget -ipV6FlowLabel]
                    ipV6 config -trafficClass     [advancedTestParameter cget -ipV6TrafficClass]
            
                    set incrementField [testConfig::getIncrIpV6AddressField]
                    switch $incrementField {
                        interfaceId {
                            ipV6 config -destAddrMode   ipV6IncrHost
                        }
                        default {
                            ipV6 config -destAddrMode   ipV6IncrNetwork
                        }
                    }

                    ipV6 config -sourceMask [tunnel cget -prefixLength]
           
                    if [ipV6 set $chassis $card $port] {
                        errorMsg "Error setting ipV6 on port $chassis $card $port"
                        set retCode $::TCL_ERROR
                    }
                    advancedTestParameter config -primeDut $::true
            
                    set protocolList $::ipV6
                    set retCode [interfaceTableUtils::configurePort $chassis $card $port $protocolList]
                }
            }
        }
        
        if {$retCode == $::TCL_OK} {
            set retCode [writePortsToHardware portArray -noVerbose]
        }
    }

    return $retCode
}

########################################################################################
# Procedure:    tunnel::getSupportedAddressTypes
#
# Description:  Performs a similar action as testConfig::configurePortProtocol on a 
#               given protocol.  By default this action is performed on the [tunnel
#               cget -payloadProtocol], but it must also be performed on [tunnel cget
#               -tunnelProtocol].
#
# Arguments:    protocol:   ip or ipV6
#
# Return(s):    TCL_OK
#
########################################################################################
proc tunnel::getSupportedAddressTypes {} \
{
    variable addressTypes
    return $addressTypes
}

########################################################################################
# Procedure:    tunnel::validateFrameSizeList
#
# Description:  Given a list of frame sizes verify that the frame sizes are valid after
#               encapsulation/decapsulation.
#
# Arguments:    FrameSizeList:  list of frame sizes in test
#
# Return(s):    TCL_OK or TCL_ERROR (if invalid)
#
########################################################################################
proc tunnel::validateFrameSizeList {frameSizeList} \
{
    set retCode $::TCL_OK

    set tunnelProtocol      [tunnel cget -tunnelProtocol]
    set payloadProtocol     [tunnel cget -payloadProtocol]
    set encapsulation       [tunnel cget -encapsulation]

    set minimumFrameSize [lindex [lnumsort -decreasing $frameSizeList] end]
    set maximumFrameSize [lindex [lnumsort -decreasing $frameSizeList] 0]

    set tunnelOverhead   [getHeaderLength $tunnelProtocol current]
    #### minimumAllowed = 14(mac) + 40(ipv6) + 12(3 udfs) + 6(timeStamp) + 4(crc) + 4(extra - don't know why)
    set minimumAllowed 88
    
    ### streamBuilder adds  $tunnelOverhead to framesize if Ingress.
    if {$minimumFrameSize < $minimumAllowed} {
        logMsg "\n***** Error: Frame size $minimumFrameSize is below the minumum allowed ($minimumAllowed).  Please re-configure."
        set retCode $::TCL_ERROR
    }

    ### The max that goes thru the Cisco 6500 is frame size 1536 (GUI framesize setting of 1516)  
    if {[expr $maximumFrameSize + $tunnelOverhead] > 1518} {
        logMsg "\n***** WARNING: When encapsulated, frame size $maximumFrameSize exceeds 1518.  DUT may drop the frame.\n"
    }
     
    return $retCode
}


########################################################################################
# Procedure:    tunnel::FixIPV6TunnelAddresses
#
# Description:  Fix the IPv6 addresses for Automatic mode 6to4 - initially wrong set by 
#               configure Test procedures  
#
# Arguments:    map array
#
# Return(s):    TCL_OK or TCL_ERROR (if invalid)
#
########################################################################################
proc tunnel::FixIPV6TunnelAddresses {TxRxArray} {
 upvar $TxRxArray txRxArray

 set tunnelProtocol     [tunnel cget -tunnelProtocol]
 set payloadProtocol    [tunnel cget -payloadProtocol]
 set encapsulation      [tunnel cget -encapsulation]

 set retCode $::TCL_OK

 foreach txMap [lnumsort [array names txRxArray]] {
     scan $txMap "%d,%d,%d" tx_c tx_l tx_p

     foreach rxMap $txRxArray($tx_c,$tx_l,$tx_p) {
         scan $rxMap "%d %d %d" rx_c rx_l rx_p

         # If in automatic-mode, construct the IPV6 addresses appropriately 
         if {[tunnel cget -tunnelConfiguration] == "automatic"} {

             if {$payloadProtocol == "ipV6"} {

                 if {$encapsulation == "ingress"} {
                     scan $txMap "%d,%d,%d" c l p
                     scan [join $txRxArray($txMap)] "%d %d %d" rc rl rp
                     set step 1
                 } else {
                     scan $txMap "%d,%d,%d" rc rl rp
                     scan [join $txRxArray($txMap)] "%d %d %d" c l p
                     set step -1

                 }

                 if {![ipV6 get $c $l $p]} {
                     ipV6 config -sourceAddr  [tunnel::buildAutomaticAddress $c $l $p source]

                     if {[tunnel cget -addressType] == "6to4" } {
                         set incrPosition [expr {($::testConf(incrIpAddrByteNum)+2)*8}]
                     } elseif {[tunnel cget -addressType] == "isatap" } {                          
                         set incrPosition [expr {(12 + $::testConf(incrIpAddrByteNum))*8}]                      
                     } else {
                         set incrPosition -1
                     }
                         

                     if { $incrPosition > 0} {
                         set destIpv6Addr [ipv6::incIpv6AddressByPrefix [ipV6 cget -sourceAddr] $incrPosition $step]                      

                         debugMsg "#### -- $c $l $p ipV6 destAddr : [ipV6 cget -destAddr] / [ipV6 cget -sourceAddr]"                        

                         if {[ipV6 set $c $l $p]} {
                             logMsg "Error: Unable to configure IPv6 parameters for [getPortId $c $l $p]"
                             set retCode $::TCL_ERROR
                         }
                         if {(![ipV6 get $rc $rl $rp])  } {
                             ipV6 config -sourceAddr  $destIpv6Addr
                             if {[ipV6 set $rc $rl $rp]} {
                                 logMsg "Error: Unable to configure IPv6 parameters for [getPortId $rc $rl $rp]"
                                 set retCode $::TCL_ERROR
                             }
                         }
                     } 

                    debugMsg "#### -- $rc $rl $rp ipV6 destAddr : [ipV6 cget -destAddr] / [ipV6 cget -sourceAddr]"                        

                 } else {
                     logMsg "Error: Unable to build automatic addresses."
                     set retCode $::TCL_ERROR
                 }

             } else {
                 logMsg "Error: Invalid configuration for Automatic Tunneling."
                 set retCode $::TCL_ERROR
             } ;# if $payloadProtocol == "ipV6"
         } ;# if automatic 
     } ;# for rx
   } ;# for tx

   return $retCode
}

