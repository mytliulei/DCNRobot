
namespace eval broadband {
    variable crcPacketSize           4
    variable latencyStampSize        6        
    variable crcDataIntegritySize    2
    variable udfSize                 4
    variable packetGroupIdSize       2    
    variable dataIntegritySize       4
}

########################################################################################
# learnRxInterfaces
#
# DESCRIPTION: 
# Configure streams for Rx ports subinterfaces and sent to the DUT to learn them. 
#
# ARGS:
#           - testCmd       test namespace
#           - txRxPortList  port list 
#
# RETURNS:  
# status      TCL_OK     - on success
#             TCL_ERROR  - on failure
#
##########################################################################################
proc learnRxInterfaces {testCmd TxRxArray} {
    upvar $TxRxArray    txRxArray

    global VlanID
    global NumVlans
    global DestDUTIpAddress
    global OctetToIncrement
    global SrcIpAddress

    set broadbandVlan       [expr {![string compare [$testCmd cget -enableClientVLAN] true]}]
    set protocolIP          [expr {![string compare [getProtocolName [protocol cget -name]] ip]}]
    set numAddressesPerPort [$testCmd cget -numAddressesPerPort]
    
    set sentList {}


    set portList3 [getRxPorts txRxArray]

    if {[ixTransmitArpRequest portList3] != 0} {
        puts "Could not transmit ARP request for $portList3\n"
    }

    puts "transmited ARP request for $portList3\n"

    return 0

    foreach pxPort [getAllPorts txRxArray] {
        scan $pxPort "%d %d %d" px_c px_l px_p

        if {[port get $px_c $px_l $px_p]} {
            return 1
        }

        if {[IsWanPort $px_c $px_l $px_p]} {
            set pxWan   1
        } else {
            set pxWan   0
        }
    
        if {[info exists VlanID($px_c,$px_l,$px_p)]} {
           set pxVlanId $VlanID($px_c,$px_l,$px_p)
        } else {
           set pxVlanId 1
        }
    
        if {[info exists NumVlans($px_c,$px_l,$px_p)]} {
            set pxNumVlans $NumVlans($px_c,$px_l,$px_p)
        } else {
            set pxNumVlans 1
        }

        if { $broadbandVlan && ($pxWan == 0) && ($pxNumVlans > 1) } {
            lappend sentList [list $px_c $px_l $px_p]
    
            protocol config -enable802dot1qTag vlanSingle
    
            stream setDefault
            stream config -sa [port cget -MacAddress]

            stream config -rateMode  usePercentRate
            stream config -name      "LearnStream"
            stream config -framesize [learn cget -framesize]
            stream config -dma       stopStream
            stream config -gapUnit   gapNanoSeconds
            stream config -enableIbg false
            stream config -enableIsg false        
            set learnPercentRate [expr double([learn cget -rate])/ \
                                  [rateConversionUtils::convertFpsRate $px_c $px_l $px_p [learn cget -framesize] percentMaxRate 100] \
                                  * 100.]        
            stream config -percentPacketRate $learnPercentRate
            
            vlan setDefault        
            vlan config -vlanID $pxVlanId
            vlan config -mode   vIncrement
            vlan config -repeat $pxNumVlans
            vlan set $px_c $px_l $px_p
    
            if {$protocolIP == 1} { 
                if {[info exists ::SrcIpAddress($px_c,$px_l,$px_p)]} {
                    set pxPortIpSrc $::SrcIpAddress($px_c,$px_l,$px_p)
                } else {
                    set pxPortIpSrc "198.35.0.100"
                }

                if {[info exists ::DestDUTIpAddress($px_c,$px_l,$px_p)]} {
                   set pxPortIpGw $::DestDUTIpAddress($px_c,$px_l,$px_p)
                } else {
                   set pxPortIpGw "198.35.0.1"
                }
    
                if {[info exists ::OctetToIncrement($px_c,$px_l,$px_p)]} {
                    set pxOctetToIncrement $::OctetToIncrement($px_c,$px_l,$px_p)
                } else {
                    set pxOctetToIncrement 4
                }
    
                ip setDefault
                ip config -sourceIpAddr             $pxPortIpSrc
                ip config -sourceIpAddrRepeatCount  1
                ip config -sourceIpAddrMode         fixed                  
                ip config -sourceIpMask             "255.255.255.0"
                ip config -sourceClass              classC
                
                ip config -destIpAddr               $pxPortIpGw
                ip config -destIpAddrRepeatCount    1
                ip config -destIpAddrMode           fixed
                ip config -destIpMask               "255.255.255.0"
                ip config -destClass                classC
    
                if [ip set $px_c $px_l $px_p] {
                    errorMsg "Error setting IP on [getPortId $px_c $px_l $px_p]"
                    set retCode $::TCL_ERROR
                }
    
                udf setDefault
                udf config -enable       $::true            
                udf config -offset       [expr 30 + $pxOctetToIncrement - 1]          
                udf config -countertype  $::c8
                udf config -counterMode  $::udfCounterMode
                udf config -initval      [format "%x" [lindex [split $pxPortIpSrc .] [expr $pxOctetToIncrement - 1]]]
    
                udf config -repeat       $pxNumVlans
                udf config -continuousCount $::false
    
                if {[udf set 1]} {
                    return 1
                }

                udf setDefault
                udf config -enable       $::true            
                udf config -offset       [expr 34 + $pxOctetToIncrement - 1]          
                udf config -countertype  $::c8
                udf config -counterMode  $::udfCounterMode
                udf config -initval      [format "%x" [lindex [split $pxPortIpGw .] [expr $pxOctetToIncrement - 1]]]

                udf config -repeat       $pxNumVlans
                udf config -continuousCount $::false

                if {[udf set 2]} {
                    return 1
                }

            }
            if [stream set $px_c $px_l $px_p 1] {
               errorMsg "Error setting stream on [getPortId $px_c $px_l $px_p] 1"
                set retCode $::TCL_ERROR
            }
        }
     }

    if {[llength $sentList] > 0} {        
        logMsg "Configuring learn frames ..."

        # zero stats everywhere to avoid confusion later...
        zeroStats txRxArray
        
        logMsg "Sending learning frames to Rx ports..."

        writeConfigToHardware sentList
        if [startTx sentList [$testCmd cget -staggeredStart]] {
            set retCode $::TCL_ERROR
        }
     
        after [learn cget -waitTime]
     }
     puts $sentList
}



########################################################################################
# applyPacketGroupMode()
#
# DESCRIPTION: 
# Configures the ports to be WidePacketGroup Mode. 
#
# ARGS:
# txRxPortList        port list to be configured
#
# RETURNS:  
# status      TCL_OK     - on success
#             TCL_ERROR  - on failure
#
##########################################################################################
proc applyPacketGroupMode {widePacketGroupPortList {testCmd bbThroughput}} \
{
    debugPuts "Start applyPacketGroupMode"

    set status $::TCL_OK

    set newWidePacketGroupList {}
    set newPacketGroupList {}  

    foreach rxPort $widePacketGroupPortList {
        scan $rxPort "%d %d %d" rx_c rx_l rx_p
        #puts "rxPort=$rxPort"
        card get $rx_c $rx_l
        set cardType [card cget -type]
        if {($cardType == $::card1000Txs4) || ($cardType ==$::card1000Stxs4) } {
            lappend newWidePacketGroupList $rxPort
        } else {
            if {[$testCmd cget -calculateJitter] == "yes"} {
                logMsg "Port [getPortId $rx_c $rx_l $rx_p] doesn't support Inter-Arrival. Disabling Inter-Arrival for this run ..."
                $testCmd config -calculateJitter no
            }                   
            lappend newPacketGroupList $rxPort
        }                
    }
    #set testCmd [namespace current]    
    set calculateDataIntegrity [expr {![string compare [$testCmd cget -calculateDataIntegrity] yes]}]   


    if { $calculateDataIntegrity } {        
        set mode [expr $::portRxModeWidePacketGroup | $::portRxDataIntegrity ]            
        set modePacketGroup [expr $::portPacketGroup | $::portRxDataIntegrity ]            
        if {[llength $newPacketGroupList]>0} {
            set mode [expr $::portRxModeWidePacketGroup | $::portRxDataIntegrity ]
        } else {
            
        }        
    } else {
        set mode $::portRxModeWidePacketGroup     
        set newPacketGroupList {}
        set newWidePacketGroupList $widePacketGroupPortList
    }

    
    if { [llength $newWidePacketGroupList] > 0 } {
        if [changePortReceiveMode  newWidePacketGroupList $mode write] {
            errorMsg  "Error setting Receive Mode."
            return $::TCL_ERROR
        }
    }

    if { [llength $newPacketGroupList] > 0 } {
        logMsg "Setting Packet Group in order to enable data integrity for ports $newPacketGroupList"
        if [changePortReceiveMode  newPacketGroupList $modePacketGroup write] {
            errorMsg  "Error setting Receive Mode."
            return $::TCL_ERROR
        }
    }

    debugPuts "Leave applyPacketGroupMode"
    return $status    
}


########################################################################################
# IsWanPort()
#
# DESCRIPTION: 
# Verify is a port is wan or broadband port. 
#
# ARGS:
# 
#
# RETURNS:  
# status      1 - Is Wan Port
#             0 - Is Broadband Port
#
########################################################################################

proc IsWanPort {px_c px_l px_p} {
  global one2manyArray

    set pxPort [join "$px_c $px_l $px_p" ,]    
    
    if {[lsearch [array names one2manyArray] $pxPort] != -1} {
        set isWanPort 1                            
    } else {
        set isWanPort 0                     
    }

    return $isWanPort
}


########################################################################################
# IsWanPort()
#
# DESCRIPTION: 
# Verify is a port is wan or broadband port. 
#
# ARGS:
# 
#
# RETURNS:  
# status      1 - Is Wan Port
#             0 - Is Broadband Port
#
########################################################################################

proc setVlanOnStream {testCmd txPort RxVlanFillterOffset {useStream 0} {streamId 0} }\
{
    upvar $RxVlanFillterOffset rxVlanFillterOffset
    global VlanID
    global NumVlans

    scan $txPort "%d.%d.%d" tx_c tx_l tx_p    

    set wanVlan [expr {![string compare [$testCmd cget -enableServerVLAN] true]}]
    set broadbandVlan [expr {![string compare [$testCmd cget -enableClientVLAN] true]}]

    set rxVlanFillterOffset 0

    if {[info exists VlanID($tx_c,$tx_l,$tx_p)]} {
       set txVlanId $VlanID($tx_c,$tx_l,$tx_p)
    } else {
       set txVlanId 1
    }

    if {[info exists NumVlans($tx_c,$tx_l,$tx_p)]} {
        set txNumVlans $NumVlans($tx_c,$tx_l,$tx_p)
    } else {
        set txNumVlans 1
    }


    protocol config -enable802dot1qTag vlanNone
    vlan setDefault        

    # make offset fix for VLAN 
    if {[IsWanPort $tx_c $tx_l $tx_p]} {
        if {$wanVlan} {
            if {$useStream} {
                stream get $tx_c $tx_l $tx_p $streamID
            }
            
            protocol config -enable802dot1qTag vlanSingle
            vlan setDefault        
            vlan config -vlanID $txVlanId
            vlan config -mode   vIdle
            vlan set $tx_c $tx_l $tx_p

            if {$useStream} {
                stream set $tx_c $tx_l $tx_p $streamID
            }

            if {$broadbandVlan == 0} {
                set rxVlanFillterOffset  -4
            } 
        } else {
            if {$broadbandVlan } {
                set rxVlanFillterOffset  4
            } 
        }
    } else {
        if {$broadbandVlan} {
            if {$useStream} {
                stream get $tx_c $tx_l $tx_p $streamID            
            }
            protocol config -enable802dot1qTag vlanSingle
            vlan setDefault        
            vlan config -vlanID $txVlanId
            vlan config -mode vIncrement
            vlan config -repeat $txNumVlans
            vlan set $tx_c $tx_l $tx_p
            if {$useStream} {
                stream set $tx_c $tx_l $tx_p $streamID
            }
            if { $wanVlan == 0 } {
                 set rxVlanFillterOffset     -4
            } 
        } else {
            if { $wanVlan } {
                 set rxVlanFillterOffset     4
            } 
        }
    }    
}


########################################################################################
# createBroadbandInterfaces()
#
# DESCRIPTION: 
# Create SubInterfaces for Vlan usage
#
# ARGS:
# 
#
# RETURNS:  
# status      1 - Is Wan Port
#             0 - Is Broadband Port
#
########################################################################################
proc createBroadbandInterfaces {TxRxArray {testCmd bbThroughput}} {
    upvar $TxRxArray txRxArray

                                
    set wanVlan [expr {![string compare [$testCmd cget -enableServerVLAN] true]}]
    set broadbandVlan [expr {![string compare [$testCmd cget -enableClientVLAN] true]}]

    foreach txMap [array names txRxArray] {
        scan $txMap "%d,%d,%d" tx_c tx_l tx_p
        if {[IsWanPort $tx_c $tx_l $tx_p]} {
            set txWan   1
            if {$wanVlan} {
                set txVlan  1
            } else {
                set txVlan  0
            }
        } else {
            set txWan   0
            if {$broadbandVlan} {
                set txVlan  1
            } else {
                set txVlan  0
            }
        }

        createInterfacesPerPort $tx_c $tx_l $tx_p 1 $txWan $txVlan [$testCmd cget -numAddressesPerPort]  $testCmd

        foreach rxMap $txRxArray($txMap) {
            scan $rxMap "%d %d %d" rx_c rx_l rx_p
            if {[IsWanPort $rx_c $rx_l $rx_p]} {
                set rxWan   1
                if {$wanVlan} {
                    set rxVlan  1
                } else {
                    set rxVlan  0
                }
            } else {
                set rxWan   0
                if {$broadbandVlan} {
                    set rxVlan  1
                } else {
                    set rxVlan  0
                }
            }

            createInterfacesPerPort $rx_c $rx_l $rx_p 0 $rxWan $rxVlan [$testCmd cget -numAddressesPerPort] $testCmd       
        }

    }  

}


########################################################################
# 
#
#
########################################################################


#########################################################################################
# Create Interfaces as follows:
#    - For TX/RX Wan  - how many addresses are on WAN port with the same VLAN and
#       MAC/Ip Src Address different
#    - For Tx/RX Broadband - how many VLANs are with different VLAN, MAC and Ip Src Address 
#
##########################################################################################

proc createInterfacesPerPort { px_c px_l px_p {isTxPort 1} {isWan 1} {hasVlan 1} {numAddressesPerPort 1} {testCmd bbThroughput}} {

    set clientDHCP  [mpexpr {[string tolower [$testCmd cget -enableClientDHCP]] == "true"}]
    set serverDHCP  [mpexpr {[string tolower [$testCmd cget -enableServerDHCP]] == "true"}]

    set protocolIP [expr {![string compare [getProtocolName [protocol cget -name]] ip]}]

    set octetToIncrement 4

    if {$hasVlan} {
        if {[info exists ::NumVlans($px_c,$px_l,$px_p)]} {
            set numVlans $::NumVlans($px_c,$px_l,$px_p)
        } else {
            set numVlans 1
        }
        if {[info exists ::VlanID($px_c,$px_l,$px_p)]} {
           set vlanId $::VlanID($px_c,$px_l,$px_p)
        } else {
           set vlanId 0
        }

        if {[info exists ::OctetToIncrement($px_c,$px_l,$px_p)]} {
           set octetToIncrement $::::OctetToIncrement($px_c,$px_l,$px_p)
        }

    }      
    

    if {$protocolIP == 1} { 

        if [ip get $px_c $px_l $px_p] {
            errorMsg "Error setting ip on port $px_c $px_l $px_p"
            set retCode $::TCL_ERROR
        }
          
        set portIpSrc [ip cget -sourceIpAddr]
        set portIpGw  [ip cget -destDutIpAddr]


        debugMsg "Src:[ip cget -sourceIpAddr] Dest:[ip cget -destDutIpAddr]"


        arpServer           setDefault
        protocolServer      setDefault

        # because we want to use requestRepeatCount, so need to ARP and Learn for all ports
        arpServer config -mode          arpGatewayAndLearn
        arpServer config -retries       [learn cget -retries]
        arpServer config -rate          [learn cget -rate]
        arpServer config -requestRepeatCount   [learn cget -numframes]
        protocolServer config -enableArpResponse    true

        if [arpServer set $px_c $px_l $px_p] {
            errorMsg "Error setting arpServer on port [getPortId $px_c $px_l $px_p]"
            set retCode 1            
        }

        if [protocolServer set $px_c $px_l $px_p] {
            errorMsg "Error setting protocolServer on port [getPortId $px_c $px_l $px_p]"
            set retCode 1
        }


    }
    
    set numInterfaces 1

    if {$isWan} {
        set numInterfaces $numAddressesPerPort
    } else {
        if {$hasVlan} {
           set numInterfaces $numVlans
        }
    }

    debugMsg "$px_c.$px_l.$px_p isTxPort:$isTxPort isWan:$isWan hasVlan:$hasVlan numAddressesPerPort:$numAddressesPerPort  numInterfaces:$numInterfaces"

    if {[interfaceTable select $px_c $px_l $px_p]} {
        return 1
    }

    interfaceTable clearAllInterfaces

    if {[port get $px_c $px_l $px_p]} {
        return 1
    }

    if {$protocolIP == 1} {
        if {[ip get $px_c $px_l $px_p]} {
            return 1
        }
    }
   
    set macAddress [port cget -MacAddress]

    for {set i 0} {$i <= [expr $numInterfaces - 1]} {incr i} { ;# <= [expr $numInterfaces - 1]
        if {$protocolIP == 1} {                    
            interfaceIpV4 setDefault

            if {$hasVlan} {
                set noVlan $vlanId
            } else {
                set noVlan 0
            }

            if { ( ($isWan && $serverDHCP) || (($isWan==0) && $clientDHCP) ) \
                            && ([$testCmd cget -dhcpDone] == "yes") } {

                if [info exists dhcp::dhcpTable($px_c,$px_l,$px_p,$noVlan,IpAddress)] {
                    interfaceIpV4 config -ipAddress $dhcp::dhcpTable($px_c,$px_l,$px_p,$noVlan,IpAddress)                         
             
                    debugMsg "$i dhcp::dhcpTable($px_c,$px_l,$px_p,$noVlan,IpAddress)=$dhcp::dhcpTable($px_c,$px_l,$px_p,$noVlan,IpAddress) interface:[interfaceIpV4 cget -ipAddress]"                       

                }

            }  else {
                interfaceIpV4 config -ipAddress $portIpSrc
            }

            if {$isWan} {
               interfaceIpV4 config -ipAddress [incrIpField  [interfaceIpV4 cget -ipAddress] 4 $i]                         
            }

            interfaceIpV4 config -gatewayIpAddress          $portIpGw
            interfaceIpV4 config -maskWidth                 [getIpV4MaskWidth [ip cget -sourceIpMask]]
            interfaceEntry addItem                          $::addressTypeIpV4

            if {$isWan == 0 } {
                set portIpSrc [incrIpField $portIpSrc $octetToIncrement]
            }

            if {$isWan == 0 } {
                #set portIpGw  [incrIpField $portIpGw  $octetToIncrement]
            }

         #   set portIpGw  [incrIpField $portIpGw $octetToIncrement]
        }
        interfaceEntry setDefault
        interfaceEntry config -enable       $::true

        interfaceEntry config -macAddress $macAddress

        if { $isWan && ($numAddressesPerPort > 1) } {
            incrMacAddress macAddress 0  ;# +2
        } else {
            incrMacAddress macAddress 1
        }
        

        if {$hasVlan} {
            interfaceEntry config -enableVlan               $::true
            interfaceEntry config -vlanId                   $vlanId

            if {$isWan == 0} {
                incr vlanId
            }
            
        }
        interfaceTable addInterface
        interfaceEntry clearAllItems addressTypeIpV4
    }
    interfaceTable write
   
}


########################################################################################
# configAddressesPerStream
#
# Description:  Configure Addresses IP & Mac counters on a stream 
#
#
# Input:        txPort rxPort streamId testCmd
#
# Output:       retCode         : 0 if success, else
#                                 1 if failure  
#
########################################################################################
proc configAddressesPerStream { txPort rxPort streamId {testCmd bbThroughput}} {

    debugMsg "$txPort $rxPort $streamId"

    scan $txPort "%d.%d.%d" tx_c tx_l tx_p
    scan $rxPort "%d.%d.%d" rx_c rx_l rx_p

    set protocolIP [expr {![string compare [getProtocolName [protocol cget -name]] ip]}]
    set wanVlan [expr {![string compare [$testCmd cget -enableServerVLAN] true]}]
    set broadbandVlan [expr {![string compare [$testCmd cget -enableClientVLAN] true]}]
    set numAddressesPerPort [$testCmd cget -numAddressesPerPort]

    set clientDHCP  [mpexpr {[string tolower [$testCmd cget -enableClientDHCP]] == "true"}]
    set serverDHCP  [mpexpr {[string tolower [$testCmd cget -enableServerDHCP]] == "true"}]

    set dhcpBits    [mpexpr ($clientDHCP<<1) | $serverDHCP]   

    if {$protocolIP} {
        if {[info exists ::OctetToIncrement($tx_c,$tx_l,$tx_p)]} {
            set txOctetToIncrement $::OctetToIncrement($tx_c,$tx_l,$tx_p)
        } else {
            set txOctetToIncrement 4
        }

        if {[info exists ::SrcIpAddress($tx_c,$tx_l,$tx_p)]} {
            set txPortIpSrc $::SrcIpAddress($tx_c,$tx_l,$tx_p)
        } else {
            set txPortIpSrc "198.35.0.100"
        }

        if {[info exists ::OctetToIncrement($rx_c,$rx_l,$rx_p)]} {
            set rxOctetToIncrement $::OctetToIncrement($rx_c,$rx_l,$rx_p)
        } else {
            set rxOctetToIncrement 4
        }

        if {[info exists ::SrcIpAddress($rx_c,$rx_l,$rx_p)]} {
            set rxPortIpSrc $::SrcIpAddress($rx_c,$rx_l,$rx_p)
        } else {
            set rxPortIpSrc "198.35.0.100"
        }

    }

    if {[vlanUtils::isPortTagged $tx_c $tx_l $tx_p]} {
        if {[info exists ::NumVlans($tx_c,$tx_l,$tx_p)]} {
            set txNumVlans $::NumVlans($tx_c,$tx_l,$tx_p)
        } else {
            set txNumVlans 1
        }
        if {[info exists ::VlanID($tx_c,$tx_l,$tx_p)]} {
            set firstTxVlan $::VlanID($tx_c,$tx_l,$tx_p)
        } else {
            set firstTxVlan  0
        }
    } else {
       set txNumVlans 1
       set firstTxVlan  0
    }

    if {[vlanUtils::isPortTagged $rx_c $rx_l $rx_p]} {

        if {[info exists ::NumVlans($rx_c,$rx_l,$rx_p)]} {
            set rxNumVlans $::NumVlans($rx_c,$rx_l,$rx_p)
        } else {
            set rxNumVlans 1
        }
        
    
        if {[info exists ::VlanID($rx_c,$rx_l,$rx_p)]} {
            set firstRxVlan $::VlanID($rx_c,$rx_l,$rx_p)
        } else {
            set firstRxVlan  0
        }

    } else {
       set rxNumVlans 1
       set firstRxVlan  0
    }

    stream get  $tx_c $tx_l $tx_p $streamId

    if {$protocolIP} {
         if [ip get $tx_c $tx_l $tx_p] {
           errorMsg "Error getting IP on [getPortId $tx_c $tx_l $tx_p]"
            set retCode $::TCL_ERROR
         }
    }

    debugMsg "$tx_c,$tx_l,$tx_p WAN=[IsWanPort $tx_c $tx_l $tx_p] - $protocolIP && $serverDHCP) && ([$testCmd cget -dhcpDone]"

    # WAN TX port
    if {[IsWanPort $tx_c $tx_l $tx_p]} {

        if { ($protocolIP && $serverDHCP) && ([$testCmd cget -dhcpDone] == "yes") } {
           if [info exists dhcp::dhcpTable($tx_c,$tx_l,$tx_p,$firstTxVlan,IpAddress)] {
               ip config -sourceIpAddr $dhcp::dhcpTable($tx_c,$tx_l,$tx_p,$firstTxVlan,IpAddress)
               debugMsg "DHCP Source set for $tx_c,$tx_l,$tx_p [ip cget -sourceIpAddr]"
           }
        }

        if {$numAddressesPerPort > 1} {            
            if {$protocolIP} {
                ip config -sourceIpAddrRepeatCount  $numAddressesPerPort
                ip config -sourceIpAddrMode         ipIncrHost                
                ip config -sourceIpMask             "255.255.255.0"
            } else {
                stream config -saRepeatCounter increment
                stream config -numSA $numAddressesPerPort
            }
        }       

        if {$broadbandVlan} {         
            if {$protocolIP} {
                udf setDefault
                udf config -enable       $::true

                # DHCP on RX Broadband ports
                if { $clientDHCP && [$testCmd cget -dhcpDone] == "yes" } {

                    set valueList {}

                    if {$wanVlan} {
                        udf config -offset 34 
                    } else {
                        udf config -offset 30 
                    }

                    for {set i 0} {$i <$rxNumVlans } {incr i} {

                        if {[info exists dhcp::dhcpTable($rx_c,$rx_l,$rx_p,[expr $i+$firstRxVlan],IpAddress)]} {
                            set ipAddress $dhcp::dhcpTable($rx_c,$rx_l,$rx_p,[expr $i+$firstRxVlan],IpAddress)
                        } else {
                            logMsg "DHCP IP unavailable for $rx_c $rx_l $rx_p [expr $i+$firstRxVlan]"
                            set ipAddress "0.0.0.0"
                        }                        

                        debugMsg "dhcp for ? $ipAddress $rx_c,$rx_l,$rx_p,[expr $i+$firstRxVlan],IpAddress "

                        lappend valueList [host2addr $ipAddress]
                    }
                    
                    udf config -counterMode udfValueListMode
                    udf config -countertype c32
                    udf config -valueList $valueList

                    debugMsg $valueList

                } else {

                    if {$wanVlan} {
                        udf config -offset       [expr 34 + $rxOctetToIncrement - 1]
                    } else {
                        udf config -offset       [expr 30 + $rxOctetToIncrement - 1]
                    }
    
                    udf config -countertype  $::c8
                    udf config -counterMode  $::udfCounterMode
                    udf config -initval      [format "%x" [lindex [split $rxPortIpSrc .] [expr $rxOctetToIncrement - 1]]]
    
    
                    udf config -repeat       $rxNumVlans
                    udf config -continuousCount $::false
                }    

                if {[udf set 1]} {
                    return 1
                }
            } else {
                stream config -daRepeatCounter increment
                stream config -numDA $rxNumVlans
            }

        } else {
            if {$protocolIP && $clientDHCP && [$testCmd cget -dhcpDone] == "yes" } {              
               if {[info exists dhcp::dhcpTable($rx_c,$rx_l,$rx_p,0,IpAddress)]} {
                   ip config -destIpAddr $dhcp::dhcpTable($rx_c,$rx_l,$rx_p,0,IpAddress)
                
               }                        
            }            

        }
    } else {
        if {$broadbandVlan } { ;#&& $txNumVlans > 1
            
            if {$protocolIP} {

                udf setDefault        
                udf config -enable $::true              

                if { $clientDHCP && [$testCmd cget -dhcpDone] == "yes" } {

                    set valueList {}

                    for {set i 0} {$i < $txNumVlans } {incr i} {
                        lappend valueList [host2addr $dhcp::dhcpTable($tx_c,$tx_l,$tx_p,[expr $i+$firstTxVlan],IpAddress)]
                    }

                    debugMsg "RX - $valueList "

                    udf config -offset 30
                    udf config -counterMode udfValueListMode
                    udf config -countertype c32
                    udf config -valueList $valueList

                } else {
                    udf config -offset       [expr 30 + $txOctetToIncrement - 1]                
                    udf config -countertype  $::c8
                    udf config -counterMode  $::udfCounterMode
                    udf config -initval      [format "%x" [lindex [split $txPortIpSrc .] [expr $txOctetToIncrement - 1]]]
                    udf config -repeat       $txNumVlans
                    udf config -continuousCount $::false
                }

                if {[udf set 1]} {
                    return 1
                }                
            } 

            stream config -saRepeatCounter increment
            stream config -numSA  $txNumVlans
            
        } else {
            if {$protocolIP && $clientDHCP && [$testCmd cget -dhcpDone] == "yes" } {
               ip config -sourceIpAddr $dhcp::dhcpTable($tx_c,$tx_l,$tx_p,0,IpAddress)
            }
        }

        if {$numAddressesPerPort > 1} {            
            if {$protocolIP} {
               if { ($serverDHCP) && ([$testCmd cget -dhcpDone] == "yes") } {
                   if [info exists dhcp::dhcpTable($rx_c,$rx_l,$rx_p,$firstRxVlan,IpAddress)] {
                       ip config -destIpAddr $dhcp::dhcpTable($rx_c,$rx_l,$rx_p,$firstRxVlan,IpAddress)
                   }
               }
               ip config -destIpAddrRepeatCount  $numAddressesPerPort
               ip config -destIpAddrMode         ipIncrHost                
               ip config -destIpMask             "255.255.255.0"

            } else {
               stream config -daRepeatCounter increment
               stream config -numDA $numAddressesPerPort
            }
        } else {      
            if { $protocolIP && ($serverDHCP) && ([$testCmd cget -dhcpDone] == "yes") } {
               if [info exists dhcp::dhcpTable($rx_c,$rx_l,$rx_p,$firstRxVlan,IpAddress)] {
                   ip config -destIpAddr $dhcp::dhcpTable($rx_c,$rx_l,$rx_p,$firstRxVlan,IpAddress)
               }
            }
        }
    }

#   don't need some udfs -> disable them
    if {$protocolIP} {
        udf get 2
        udf config -enable $::false
        udf set 2
    
        udf get 3
        udf config -enable $::false
        udf set 3
    } elseif {$broadbandVlan} {
        udf get 1
        udf config -enable $::false
        udf set 1

        udf get 3
        udf config -enable $::false
        udf set 3
    }
    #udf get 4
    #udf config -enable $::false
    #udf set 4

    if [ip set $tx_c $tx_l $tx_p] {
        errorMsg "Error setting IP on [getPortId $tx_c $tx_l $tx_p]"
        set retCode $::TCL_ERROR
    }

    if [stream set $tx_c $tx_l $tx_p $streamId] {
        errorMsg "Error setting stream on [getPortId $tx_c $tx_l $tx_p] $streamId"
        set retCode $::TCL_ERROR
    }

}


########################################################################################
# broadbandLearn
#
# Description:  Helper procedure for acquisition of an IP address via DHCP discovery
#               and ARPing.  After acquiring an IP address ARP is required to verify
#               that IP address is not already in use?
#
# Input:        testCmd         : default is 'wip'
#
# Output:       retCode         : 0 if success, else
#                                 1 if failure  
#
########################################################################################
proc broadbandLearn {{when "oncePerTest"} {testCmd bbThroughput} } \
{
    global one2manyArray
    
    set retCode $::TCL_OK

    if {[learn cget -when] != $when} {
        return $retCode
    }

    set rxPortList [getAllPorts ${testCmd}::fullMapArray]

    if {[getProtocolName [protocol cget -name]]=="ip"} {

        # ARP fails on TXS8 when RX is set to pachet mode -> reset it to portRxDataIntegrity

        if [changePortReceiveMode  rxPortList $::portRxDataIntegrity write] {
            errorMsg  "Error setting Receive Mode."
            return $::TCL_ERROR
        }

        set clientDHCP  [mpexpr {[string tolower [$testCmd cget -enableClientDHCP]] == "true"}]
        set serverDHCP  [mpexpr {[string tolower [$testCmd cget -enableServerDHCP]] == "true"}]
    
        set dhcpBits    [mpexpr ($clientDHCP<<1) | $serverDHCP]        
    
        # 
        #   Acquire IP addresses, if needed.
        #       Client or server or both.
        #    
        if {([$testCmd cget -dhcpDone] == "no") && ($dhcpBits) } {
    
            if [info exists portList] {
                unset portList
            }
    
            switch $dhcpBits {
                3 {     ;# both enabled
                    set portList  [getAllPorts one2manyArray]
                }
                2 {     ;# just client
                    set portList  [getRxPorts  one2manyArray]
                }
                1 {     ;# just server
                    set portList  [getTxPorts  one2manyArray]
                }
                0 {
                }
                default {
                    set retCode $::TCL_ERROR
                }
            }
    
            if [info exists portList] {
                if [DiscoveDHCPIpAddresses portList] {
                    errorMsg "Error sending DHCP discover frames"
                    set retCode $::TCL_ERROR
                } else {
                    $testCmd config -dhcpDone   yes
                }

                # set the IPs for DUT & Chassis                   
                foreach pxPort $portList {
                    scan $pxPort "%d %d %d" px_c px_l px_p

                    if [ip get $px_c $px_l $px_p] {
                        errorMsg "Error getting IP on [getPortId $px_c $px_l $px_p]"
                        set retCode $::TCL_ERROR
                    }
               
                    if {[testConfig::getTestConfItem autoMapGeneration "yes"] == "yes" } {    
                        if {[info exists ::DestDUTIpAddress($px_c,$px_l,$px_p)]} {
                           ip config -destDutIpAddr   $::DestDUTIpAddress($px_c,$px_l,$px_p)
                        } else {
                           logMsg "For automatic mode the Gateway/DUT Ip Address should be set in Ip,Port Names &VLAN IDs window (as for manual mode) for port $px_c $px_l $px_p"
                        }
                    }
                    
                    #$dhcpClient::dhcpLeaseRecord($px_c,$px_l,$px_p,ip)

                    #parray dhcp::dhcpTable
                }      

            }
        }
        
        set learnproc [switchLearn::getSendOnlyLearnProc]
  #      set learnproc [switchLearn::getLearnProc]
    
        createBroadbandInterfaces ${testCmd}::fullMapArray $testCmd
    
        if {[writeConfigToHardware one2manyArray]} { 
            errorMsg "Failed to writeConfigToHardware"
            return $::TCL_ERROR 
        }
        

        if {[$learnproc one2manyArray [getAllPorts one2manyArray] ] != 0} { 
            errorMsg "Error sending learn frames"
            set status $::TCL_ERROR    
            return $status
        }

        #learnRxInterfaces $testCmd one2manyArray
    } else {
         set learnproc switchLearn::send_learn_frames

         createBroadbandInterfaces ${testCmd}::fullMapArray $testCmd

         if {[writeConfigToHardware one2manyArray]} { 
            errorMsg "Failed to writeConfigToHardware"
            return $::TCL_ERROR 
         }

         if {[$learnproc ${testCmd}::fullMapArray] != 0} {            
            errorMsg "Error sending learn frames"                       
            set retCode  $::TCL_ERROR
         }
    }    


    set widePacketGroupPortList {}

    #creating rxPortList for ports supporting WidePacketGroup 

    foreach rxMap $rxPortList {
         scan $rxMap "%d %d %d" rx_c rx_l rx_p        
         if {[port isValidFeature $rx_c $rx_l $rx_p portFeatureRxWidePacketGroups]} {
            set widePacketGroupPortList [lappend packetGroupPortList [list $rx_c $rx_l $rx_p]]
         } else {
            logMsg "Error! Port $rx_c $rx_l $rx_p doesn't support WidePacketGroup"
            return $::TCL_ERROR
         }
    }

    # Put back the original rx mode                                               
    set retCode [applyPacketGroupMode $rxPortList $testCmd]                

    return $retCode
}


############################################################################
# PacketGroupStreamBuild()
#
# DESCRIPTION
# This helper procedure builds the stream that will be used to 
# measure key traffic metrics through the DUT and configure dataIntegrity
#
#
# ARGS:
# TxRxArray       - contains Rx and Tx Maps used by this test.
# 
#
# RETURNS:  
# status      TCL_OK     - on success
#             TCL_ERROR  - on failure
#
#############################################################################
proc PacketGroupStreamBuild {testCmd TxRxArray TxNumFrames framesize userPercentRateArray {preambleSize 8} {startStream 1} {frameSizeMin 0}} \
{
    upvar $TxRxArray    txRxArray
    upvar $TxNumFrames  txNumFrames  

    global VlanID
    global NumVlans

    set directions [set ${testCmd}::directions]
    array set portPgId [array get ${testCmd}::portPgId]

    debugPuts " FS - $framesize"   

    set calculateJitter  [expr {![string compare [$testCmd cget -calculateJitter] yes]}]     
    set calculateLatency [expr {![string compare [$testCmd cget -calculateLatency] yes]}]
    set calculateDataIntegrity [expr {![string compare [$testCmd cget -calculateDataIntegrity] yes]}]
    set wanVlan [expr {![string compare [$testCmd cget -enableServerVLAN] true]}]
    set broadbandVlan [expr {![string compare [$testCmd cget -enableClientVLAN] true]}]


    $testCmd cget -calculateJitter  no
    $testCmd cget -calculateLatency no 

    set status $::TCL_OK;

    if {$frameSizeMin == 0} {
        set frameSizeMin $framesize
    }

    set crcPacketSize           $broadband::crcPacketSize
    set latencyStampSize        $broadband::latencyStampSize        
    set crcDataIntegritySize    $broadband::crcDataIntegritySize
    set udfSize                 $broadband::udfSize
    set packetGroupIdSize       $broadband::packetGroupIdSize    
    set dataIntegritySize       $broadband::dataIntegritySize

    if {$calculateLatency == 0 && $calculateLatency == 0} {
      #  set latencyStampSize        6
        set enableTimeStamp         false
    } else {
        set enableTimeStamp         true
    }

    if {$calculateDataIntegrity == 0} {
        set crcDataIntegritySize    0       
        set dataIntegritySize       0
    }

    set packetGroupOffset [mpexpr {($frameSizeMin - $crcPacketSize - $latencyStampSize - $crcDataIntegritySize - \
            2*$udfSize - $packetGroupIdSize) & 0xfffffffe}]

    # substract 1 byte for making sure the bit 7 from previous byte is 0 ?    
    set dataIntegrityOffset    [mpexpr {$packetGroupOffset - $dataIntegritySize}]


    set wanVlan [expr {![string compare [$testCmd cget -enableServerVLAN] true]}]
    set broadbandVlan [expr {![string compare [$testCmd cget -enableClientVLAN] true]}]
    set numAddressesPerPort  [$testCmd cget -numAddressesPerPort]

    foreach rxMap [getRxPorts txRxArray] {
        scan $rxMap "%d %d %d" rx_c rx_l rx_p
        set rxSetUDSOffset($rx_c,$rx_l,$rx_p)  1
    }

    #logMsg "packetgroup build - vlans - $wanVlan - $broadbandVlan"
    foreach txMap [getTxPorts txRxArray] {
        scan $txMap "%d %d %d" tx_c tx_l tx_p

        set txPacketGroupId $portPgId([join $txMap ,])        
        if {[IsWanPort $tx_c $tx_l $tx_p]} {
            set txWan   1
        } else {
            set txWan   0
        }

        if [port get $tx_c $tx_l $tx_p] {
            errorMsg "Error getting port [getPortId $tx_c $tx_l $tx_p]"
            set status $::TCL_ERROR
            continue
        }
        set numTxAddresses [port cget -numAddresses];

        set numRxPorts [llength $txRxArray($tx_c,$tx_l,$tx_p)];

        logMsg "Configuring transmit port: [getPortId $tx_c $tx_l $tx_p] for $numRxPorts receive ports, $numTxAddresses address(es) per port"

        set streamID $startStream

        foreach rxMap $txRxArray($tx_c,$tx_l,$tx_p) {
            scan $rxMap "%d %d %d" rx_c rx_l rx_p

            stream get $tx_c $tx_l $tx_p $streamID
            stream config -enableTimestamp true   
            stream config -patternType repeat
            stream config -dataPattern allZeroes
            stream config -pattern     "00 00"
            stream config -numFrames [mpexpr [stream cget -numFrames]/$numRxPorts]
            stream set $tx_c $tx_l $tx_p $streamID            

            configAddressesPerStream "$tx_c.$tx_l.$tx_p" "$rx_c.$rx_l.$rx_p" $streamID $testCmd

            if [port get $rx_c $rx_l $rx_p] {
                errorMsg "Error getting port [getPortId $rx_c $rx_l $rx_p]"
                set status $::TCL_ERROR
                continue
            }       

            if {$calculateJitter} {
                card get $rx_c $rx_l
                set cardType [card cget -type]
                if {($cardType == $::card1000Txs4) || ($cardType ==$::card1000Stxs4) } {
                    packetGroup config -latencyControl interArrivalJitter
                } else {
                    if {[$testCmd cget -calculateJitter] == "yes"} {
                        logMsg "Port [getPortId $rx_c $rx_l $rx_p] doesn't support Inter-Arrival. Disabling Inter-Arrival for this run ..."
                        $testCmd config -calculateJitter no
                    }                    
                }                
            }

            if {$calculateLatency} {
                packetGroup config -latencyControl [$testCmd cget -latencyTypes]
            }             

            #set pattern to zero to assurethe the previous byte of packet group is zero                      
            set rxVlanFillterOffset 0

            if {[info exists VlanID($tx_c,$tx_l,$tx_p)]} {
               set txVlanId $VlanID($tx_c,$tx_l,$tx_p)
            } else {
               set txVlanId 1
            }

            if {[info exists NumVlans($tx_c,$tx_l,$tx_p)]} {
                set txNumVlans $NumVlans($tx_c,$tx_l,$tx_p)
            } else {
                set txNumVlans 1
            }

            if {[info exists VlanID($rx_c,$rx_l,$rx_p)]} {
               set rxVlanId $VlanID($rx_c,$rx_l,$rx_p)
            } else {
               set rxVlanId 1
            }

            if {[info exists NumVlans($rx_c,$rx_l,$rx_p)]} {
                set rxNumVlans $NumVlans($rx_c,$rx_l,$rx_p)
            } else {
                set rxNumVlans 1
            }


            # make offset fix for VLAN 
            if {[IsWanPort $tx_c $tx_l $tx_p]} {
                if {$wanVlan} {
                    stream get $tx_c $tx_l $tx_p $streamID
                    protocol config -enable802dot1qTag vlanSingle
                    vlan setDefault        
                    vlan config -vlanID $txVlanId
                    vlan config -mode   vIdle
                    vlan set $tx_c $tx_l $tx_p
                    stream set $tx_c $tx_l $tx_p $streamID

                    if {$broadbandVlan == 0} {
                        set rxVlanFillterOffset  -4
                    } 
                } else {
                    if {$broadbandVlan } {
                        set rxVlanFillterOffset  4
                    } 
                }
            } else {
                if {$broadbandVlan} {
                    stream get $tx_c $tx_l $tx_p $streamID
                    protocol config -enable802dot1qTag vlanSingle
                    vlan setDefault        
                    vlan config -vlanID $txVlanId
                    vlan config -mode vIncrement
                    vlan config -repeat $txNumVlans
                    vlan set $tx_c $tx_l $tx_p

                    stream set $tx_c $tx_l $tx_p $streamID
                    if { $wanVlan == 0 } {
                         set rxVlanFillterOffset     -4
                    } 
                } else {
                    if { $wanVlan } {
                         set rxVlanFillterOffset     4
                    } 
                }
            }


            #logMsg "values: rxVlanFillterOffset:$rxVlanFillterOffset"


            if {$calculateDataIntegrity} {
                stream get $tx_c $tx_l $tx_p $streamID
                if [udf get 2] {
                    errorMsg "Error getting UDF 2 on PAcketGroupStream"
                    set retCode $::TCL_ERROR
                }
                set offset [udf cget -offset]
                set offset [expr $offset - $crcDataIntegritySize]
                udf config -offset $offset
                if [udf set 2] {
                    errorMsg "Error setting UDF 2 on PAcketGroupStream"
                    set retCode $::TCL_ERROR
                }
                if [udf get 4] {
                    errorMsg "Error getting UDF 4 on PAcketGroupStream"
                    set retCode $::TCL_ERROR
                }
                set offset [udf cget -offset]
                set offset [expr $offset - $crcDataIntegritySize]

                udf config -offset $offset
                set signature [udf cget -initval]

                if [udf set 4] {
                    errorMsg "Error setting UDF 4 on PAcketGroupStream"
                    set retCode $::TCL_ERROR
                }                

                dataIntegrity setDefault      
                #set signature  [list db [format %02x $rx_c] [format %02x $rx_l] [format %02x $rx_p]]                    
                dataIntegrity config -signatureOffset [expr $offset + $rxVlanFillterOffset]
                dataIntegrity config -signature $signature
                dataIntegrity config -enableTimeStamp $enableTimeStamp
                dataIntegrity setRx $rx_c $rx_l $rx_p
                dataIntegrity config -signatureOffset $offset 
                dataIntegrity config -insertSignature true
                dataIntegrity setTx $tx_c $tx_l $tx_p $streamID
                
                set sigOffset $offset


            } else {
                stream get $tx_c $tx_l $tx_p $streamID
                if [udf get 4] {
                    errorMsg "Error getting UDF 4 on PAcketGroupStream"
                    set retCode $::TCL_ERROR
                }
                set offset [udf cget -offset]

                set signature  [list db [format %02x $rx_c] [format %02x $rx_l] [format %02x $rx_p]]                    
                set sigOffset $offset                
            }


            #setupPacketGroup $frameSizeMin $rx_c $rx_l $rx_p "" $packetGroupOffset

            #set signature  [list db [format %02x $rx_c] [format %02x $rx_l] [format %02x $rx_p]] 

            packetGroup config -signatureOffset [expr $sigOffset+$rxVlanFillterOffset]
            packetGroup config -signature       $signature
            packetGroup config -insertSignature true
            packetGroup config -groupIdOffset   [expr $packetGroupOffset+$rxVlanFillterOffset]

            if [packetGroup setRx $rx_c $rx_l $rx_p] {
                errorMsg "Error setting Rx packetGroup on [getPortId $rx_c $rx_l $rx_p]"
                set status $::TCL_ERROR
            }  

            packetGroup config -signatureOffset $sigOffset
            packetGroup config -signature       $signature
            packetGroup config -insertSignature true
            packetGroup config -groupIdOffset   $packetGroupOffset
            packetGroup config -groupId         $txPacketGroupId


            if [streamUtils::packetGroupSetTx $tx_c $tx_l $tx_p $streamID] {
                logMsg "writePacketFlows: Error setting Tx packetGroup on [getPortId $tx_c $tx_l $tx_p]"
                set status $::TCL_ERROR
            }

            stream set $tx_c $tx_l $tx_p $streamID

            filterPallette get $rx_c $rx_l $rx_p
            filterPallette config -patternOffset1 [expr $offset + $rxVlanFillterOffset]
            filterPallette config -DAMask1 "00 00 00 00 00 FF"
            filterPallette set $rx_c $rx_l $rx_p        

            incr streamID

        }

    }

    if {$status == 0} {
        adjustOffsets txRxArray
        writeConfigToHardware txRxArray
    }

    if {$calculateJitter} {
        $testCmd cget -calculateJitter  yes
    }

    if {$calculateLatency} {
        $testCmd cget -calculateLatency yes
    }

    return $status
}


#####################################################################################################
# assignTxPortPGID(): 
#
# DESCRIPTION: 
# Assigns the packet group id for each port in TxRxArray
#
# RETURNS:  
# none
#  
# NOTE: 
# large port count stream builder does not support the sequence checking, therefore the PGID is
# set to 0 for all packets.
#####################################################################################################
proc assignTxPortPGID {TxRxArray GroupIdArray txPortList PortPgId} \
{
    upvar $TxRxArray txRxArray
    upvar $GroupIdArray groupIdArray
    upvar $PortPgId portPgId

    debugPuts "Start assignTxPortPGID"

    set status $::TCL_OK;
    set pgid    0

    foreach txMap $txPortList {
        scan $txMap "%d %d %d" c l p
        set portPgId($c,$l,$p) $pgid
        incr pgid
    }

    swapPortList txRxArray rxTxArray
    foreach rxMap [array names rxTxArray] {
        scan [join [split $rxMap ',']] "%d %d %d" rx_c rx_l rx_p
        set groupIdArray($rx_c,$rx_l,$rx_p) {}
        foreach txMap $rxTxArray($rxMap) {
            scan $txMap "%d %d %d" tx_c tx_l tx_p
            set groupIdArray($rx_c,$rx_l,$rx_p) \
                [lappend groupIdArray($rx_c,$rx_l,$rx_p) \
                $portPgId($tx_c,$tx_l,$tx_p) ]
        }
    } 


    debugPuts "Leave assignTxPortPGID"
    return $status;
}



#tracedVariable
#trace variable tracedVariable w traceProc


##################################################
###
#
# Only for Developement
#
#
#############
proc traceProc {varName index operation} {
    upvar $varName var
    set lvl [info level]
    incr lvl -1;
    puts "Variable $varName is being modified in: [info level $lvl]"
    if {$lvl > 1} {
        incr lvl -1;
        puts "Which was invoked from: [info level $lvl]"
    }
    puts "The current value of $varName is: $var\n"

}

proc debugPuts {args} {
    global scriptmateDebug

    if {![info exists scriptmateDebug(debugLevel)]} {
        set scriptmateDebug(debugLevel) 0xFF
    }

    # puts message
    if {$scriptmateDebug(debugLevel) & 1} {
        logMsg "DEBUG Message: $args"
    }

    
}



