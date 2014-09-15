#############################################################################################
#
#   Copyright © 1997 - 2004 by IXIA.
#   All Rights Reserved.
#
# Description: 
#
#############################################################################################


########################################################################################
# Procedure: registerResultVars
#
# Description: This command registers all the local variables that are used in the
# display of the results with the Results Options Database.  This procedure must exist
# for each test.
#
########################################################################################
proc bgpSuite::registerResultVars {} \
{
    if [results addOptionToDB totalPacketLoss        "TotalPacketLoss "                    12 12 iter] { return 1 } 
    if [results addOptionToDB convergenceMetric      "ConvergenceMetric(seconds)"          12 12 iter] { return 1 } 
    if [results addOptionToDB totalRoutes            "MaxRoutesVerified"                   12 12 iter] { return 1 }
    if [results addOptionToDB tolerance              "Tolerance(%)    "                    12 12 iter] { return 1 }
    if [results addOptionToDB numWithdraw            "Number of Withdrawals"               12 12 iter] { return 1 }
    if [results addOptionToDB convergencePerWithdraw "ConvergenceMetricPerWithdrawal(sec)" 12 12 iter] { return 1 } 
    if [results addOptionToDB packetRate             "PacketRate (PPS)"                    12 12 iter] { return 1 }
    if [results addOptionToDB actualPacketLoss       "ActualPacketLoss"                    12 12 iter] { return 1 }
    if [results addOptionToDB misDirectedPackets     "MisDirectedPackets"                  12 12 iter] { return 1 }

    # configuration information stored for results      
    if [results registerTestVars testName       testName       [bgpSuite cget -testName]  test ] { return 1 }
    if [results registerTestVars protocol       protocolName   [string toupper [getProtocolName [protocol cget -name]]] test] { return 1 }
    if [results registerTestVars chassisName    chassisName    [chassis cget -name]            test] { return 1 }
    if [results registerTestVars chassisID      chassisID      [chassis cget -id]              test] { return 1 }
    if [results registerTestVars productName    productName    [user cget -productname]        test] { return 1 }
    if [results registerTestVars versionNumber  versionNumber  [user cget -version]            test] { return 1 }
    if [results registerTestVars serialNumber   serialNumber   [user cget -serial#]            test] { return 1 }
    if [results registerTestVars userName       userName       [user cget -username]           test] { return 1 }
    if [results registerTestVars percentMaxRate percentMaxRate [bgpSuite cget -percentMaxRate] test] { return 1 }
    if [results registerTestVars numTrials      numTrials      [bgpSuite cget -numtrials]      test] { return 1 }
    if [results registerTestVars duration       duration       [bgpSuite cget -duration]       test] { return 1 }
                                                        
    # results obtained after each iteration             
    if [results registerTestVars transmitFrames         txActualFrames         0 port TX] { return 1 }
    if [results registerTestVars receiveFrames          rxNumFrames            0 port RX] { return 1 }
    if [results registerTestVars totalTxFrames          totalTxNumFrames       0 iter   ] { return 1 }     
    if [results registerTestVars totalRxFrames          totalRxNumFrames       0 iter   ] { return 1 }
    if [results registerTestVars percentLoss            totalLoss              0 iter   ] { return 1 }
    if [results registerTestVars totalPacketLoss        totalPacketLoss        0 iter   ] { return 1 }
    if [results registerTestVars convergenceMetric      convergenceMetric      0 iter   ] { return 1 }
    if [results registerTestVars totalRoutes            totalRoutes            0 iter   ] { return 1 }
    if [results registerTestVars tolerance              tolerance              0 iter   ] { return 1 }
    if [results registerTestVars numWithdraw            numWithdraw            0 iter   ] { return 1 }
    if [results registerTestVars convergencePerWithdraw convergencePerWithdraw 0 iter   ] { return 1 }
    if [results registerTestVars packetRate             packetRate             0 iter   ] { return 1 }
    if [results registerTestVars actualPacketLoss       actualPacketLoss       0 iter   ] { return 1 }
    if [results registerTestVars misDirectedPackets     misDirectedPackets     0 iter   ] { return 1 }

    return 0
}


########################################################################################
# Procedure: bgpSuite::show
#
# Description: This command is called when the user enters: bgpSuite show
# Displays currently configured parameters.
########################################################################################
proc bgpSuite::show {args} \
{
    logMsg "\nbgpSuite command parameters"
    logMsg "====================================="
    showCmd bgpSuite
}


#################################################################################
# Procedure: setupRouteItem
#
# Description: This command configures a route range .
#
##################################################################################
proc setupRouteItem {networkAddress prefixLength numRoutes peerIP {asPathSeqList ""}} \
{
    set retCode 0
    global bgpSegmentAsSequence
    bgp4RouteItem setDefault
    bgp4RouteItem config -networkAddress    $networkAddress
    bgp4RouteItem config -fromPrefix        $prefixLength
    bgp4RouteItem config -thruPrefix        $prefixLength
    bgp4RouteItem config -numRoutes         $numRoutes
    bgp4RouteItem config -enableASPath      1
    bgp4RouteItem config -enableNextHop     1
    bgp4RouteItem config -nextHopIpAddress  $peerIP
    bgp4RouteItem config -enableRouteRange  1

    bgp4AsPathItem setDefault
    if {[llength $asPathSeqList] > 0} {
        bgp4AsPathItem config -enableAsSegment  true
        bgp4AsPathItem config -asList           $asPathSeqList 
        bgp4AsPathItem config -asSegmentType    $bgpSegmentAsSequence

        if {[bgp4RouteItem addASPathItem]} {
            errorMsg "*** Error Adding AS_PATH item"
            set retCode 1
        }
    }

    return $retCode
}


#################################################################################
# Procedure: writeBgpConvergenceStreams
#
# Description: This command configures and writes the stream for bgp convergence test
#
#################################################################################
proc writeBgpStreams {TxRxArray {TxNumFrames ""} {numFrames 0} {testCmd bgpSuite}} \
{
    upvar $TxRxArray    txRxArray
    upvar $TxNumFrames  txNumFrames

    variable atmOnlyPortList
    variable nonAtmPortList

    set retCode 0

    set preambleSize    8

    if {[atmUtils::configureAtmPorts txRxArray atmOnlyPortList nonAtmPortList] == $::TCL_ERROR} {
        errorMsg "***** ERROR:  failed to configure ATM ports.  Test aborted."
        return $::TCL_ERROR;
    }

    stream setDefault
    stream config -daRepeatCounter   daArp
    stream config -framesize         [$testCmd cget -framesize]
    stream config -enableTimestamp   true

    stream config -enableIbg         false
    stream config -enableIsg         false

    stream config -rateMode          usePercentRate
    stream config -percentPacketRate [$testCmd cget -percentMaxRate]
    stream config -gapUnit           gapNanoSeconds

    packetGroup setDefault
    packetGroup config -insertSignature true
    packetGroup config -signatureOffset 48

    # Setup filters on receive port to count our test packets
    filterPallette setDefault

    filter setDefault

    filter config -userDefinedStat2Enable   true
    filter config -userDefinedStat2Pattern  pattern2    ;# this will measure the flap routes
    
    foreach txPort [getTxPorts txRxArray] {
        scan $txPort "%d %d %d" tx_c tx_l tx_p

        set streamID    1
        set txNumFrames($tx_c,$tx_l,$tx_p)   0

        # get the mac & Ip addresses for the da/sa
        if [port get $tx_c $tx_l $tx_p] {
            errorMsg "Port [getPortId $tx_c $tx_l $tx_p] not configured yet!"
            set retCode 1
        }
        stream config -sa   [port cget -MacAddress]

        ##### Stream for generating traffic to the routes #####
        stream config -name         "Tx->[$testCmd cget -networkIPAddress]"

        if { $numFrames == 0 } {
           stream config -numFrames    [$testCmd cget -routesPerPeer]
        } else {
            stream config -numFrames    $numFrames
        }
        stream config -preambleSize     $preambleSize

        if [ip get $tx_c $tx_l $tx_p] {
            errorMsg "Error getting ip on port [getPortId $tx_c $tx_l $tx_p]"
            set retCode 1
        }

        ip config -ipProtocol       255
        ip config -destIpAddr       [$testCmd cget -networkIPAddress]
        ip config -destIpAddrMode   ipIncrNetwork

        switch [$testCmd cget -prefixLength] {
            16 {
                logMsg "Setting prefix length to 16"
                ip config -destClass classB
            }
            24 {
                logMsg "Setting prefix length to 24"
                ip config -destClass classC
            }
        }
        ip config -destIpAddrRepeatCount [$testCmd cget -routesPerPeer]
        if [ip set $tx_c $tx_l $tx_p] {
            errorMsg "Error setting ip on port [getPortId $tx_c $tx_l $tx_p]"
            set retCode 1
        }

        stream config -dma   firstLoopCount

        if [stream set $tx_c $tx_l $tx_p $streamID] {
            errorMsg "Error setting stream $streamID for network on port [getPortId $tx_c $tx_l $tx_p]"
            set retCode 1
        }

        # note - we set the stream twice because we need to get the conf'd framerate for calc'ing the duration
        set framerate   [stream cget -framerate]
        set loopCount 1

#calculate the duration 
        if { $numFrames == 0 } {
            set loopCount    [mpexpr round (double ($framerate)/[stream cget -numFrames] * [$testCmd cget -duration])]
            if { $loopCount == 0} {
                set loopCount 1
            }
            $testCmd config -duration [format "%.0f" [mpexpr ceil (double ([stream cget -numFrames])/$framerate * $loopCount)]]
            set txNumFrames($tx_c,$tx_l,$tx_p) [mpexpr $loopCount* [stream cget -numFrames]]

        } else {
            set transmitDuration  [format "%.0f" [mpexpr ceil (double ([stream cget -numFrames])/$framerate)]]     
            bgpSuite config -duration  $transmitDuration
            set txNumFrames($tx_c,$tx_l,$tx_p) [stream cget -numFrames]
          }   
        stream config -loopCount    $loopCount
        if {[atmUtils::isAtmPort $tx_c $tx_l $tx_p]} {
            if {[atmUtils::buildAtmParams  $tx_c $tx_l $tx_p]} {
                errorMsg "Error building ATM parameters."
                set retCode $::TCL_ERROR
            }
        }

        if [streamUtils::streamSet $tx_c $tx_l $tx_p $streamID] {
            errorMsg "Error setting stream $streamID for network on port [getPortId $tx_c $tx_l $tx_p]"
            set retCode $::TCL_ERROR
        }

        # config packet group signature for UDS 1, Network
        scan [$testCmd cget -networkIPAddress] "%d.%d.%d.%d" a b c d
        packetGroup config -signature       [format "%02x %02x %02x %02x" $a $b $c $d]

            if {[atmUtils::isAtmPort $tx_c $tx_l $tx_p]} { 
                if {[packetGroup setQueueTx $tx_c $tx_l $tx_p 1 $streamID]} {
                    errorMsg "Error setting ATM TX packet group for stable network on port [getPortId $tx_c $tx_l $tx_p]"
                    set retCode $::TCL_ERROR
                }
            } else {
                if {[packetGroup setTx $tx_c $tx_l $tx_p $streamID]} {
                    errorMsg "Error setting TX packet group for stable network on port [getPortId $tx_c $tx_l $tx_p]"
                    set retCode $::TCL_ERROR
                }
            }

        # Setup filters on receive port to count our test packets
        filterPallette config -pattern2         [packetGroup cget -signature]
        filterPallette config -patternOffset2   [packetGroup cget -signatureOffset]
        
        filter config -captureTriggerEnable     true
        filter config -captureFilterEnable      true
    
        foreach rxPort $txRxArray($tx_c,$tx_l,$tx_p) {
            scan [join $rxPort] "%d %d %d" rx_c rx_l rx_p

            if [filter set $rx_c $rx_l $rx_p] {
                errorMsg "Error setting filters on port [getPortId $rx_c $tx_l $rx_p]"
                set retCode 1
            }

            if [filterPallette set $rx_c $rx_l $rx_p] {
                errorMsg "Error setting filterPallette on port [getPortId $rx_c $rx_l $rx_p]"
                set retCode 1
            }
        }

        incr streamID
    }

    if {$retCode == 0} {
        adjustOffsets txRxArray
        set retCode [writeConfigToHardware txRxArray]
    }
    return $retCode
}


#################################################################################
# Procedure: confirmAllRoutesAdvertised
#
# Description: This command checks that All routes have been advertised. It also checkes whether the session is up
# Arguments:
# bgpPorts:
# routesPerPeer: number of routes
# NeighborIpAddressArray : Array of neighbor Ip address
# DutIpAddressArray:       Array of DUT Ip address
# ExtraTime :              The time that it takes to advertise all routes after estimated delay. 
#
# Results :       0 : No error found
#                 1 : Error found
#
#################################################################################

proc confirmAllRoutesAdvertised { NeighborIpAddressArray DutIpAddressArray bgpPorts routesPerPeer ExtraTime}  \
{         
    upvar  $NeighborIpAddressArray    neighborIpAddressArray
    upvar  $DutIpAddressArray         dutIpAddressArray
    upvar  $ExtraTime                  extraTime

    set retCode  0
    set maxCount  10
    set extraTime 0

    copyPortList neighborIpAddressArray neighborArray
    copyPortList dutIpAddressArray      dutArray

    if {[protocol cget -name] == $::ip} {
        set type addressTypeIpV4
    } else {
        set type addressTypeIpV6
    }

    for {set timer 0} {$timer < $maxCount } {incr timer} {
        foreach portItem $bgpPorts {
            scan $portItem "%d %d %d" c l p
            if { [bgp4StatsQuery get $c $l $p] } {
                logMsg " Error sending bgp stats query "
                set retCode 2
            }
            after 1000
            set index 0
            if [info exist neighborArray($c,$l,$p)] {
                foreach neighborIpAddress $neighborArray($c,$l,$p) {
                    set dutIpAddress    [lindex $dutArray($c,$l,$p) $index]
                    bgp4StatsQuery setDefault
                    for {set retry 10} {$retry >= 0} {incr retry -1} {
                        if [bgp4StatsQuery getStat bgpRoutesAdvertised $neighborIpAddress $dutIpAddress $type] {
                            after 1000
                            continue
                        } else {
                            break
                         }
                    }
                     if {[bgp4StatsQuery cget -statValue] == $routesPerPeer} {
                         logMsg "Number of advertised routes for $neighborIpAddress  on port [getPortId $c $l $p] :[bgp4StatsQuery cget -statValue], number of routes $routesPerPeer"

                         # this one is done so remove it from the neighborIpAddress & dutIpAddres lists
                         set neighborArray($c,$l,$p)      [lreplace $neighborArray($c,$l,$p) $index $index]
                         set dutArray($c,$l,$p)           [lreplace $dutArray($c,$l,$p) $index $index]
                     }
                    bgp4StatsQuery setDefault
                    set state [bgp4StatsQuery getStat bgpStateMachineState $neighborIpAddress $dutIpAddress $type]
                    if $state {
                        logMsg "Error in getting bgpStateMachineState"
                        set retCode 1
                    }
                    set stateValue [bgp4StatsQuery cget -statValue]
                    if {[string compare $stateValue Established] != 0} {  
                        errorMsg "ERROR: The connection on port $c $l $p has been disconnected." 
                        return 1 
                    }
                }   
                # If all peers in this port have been removed, remove the port from the port list
                if { [llength $neighborArray($c,$l,$p)] == 0 } {
                    set index [lsearch $bgpPorts [list $c $l $p]]
			        if {$index != -1} {
				        set bgpPorts [lreplace $bgpPorts $index $index]
			        }
                }
            } else {
                set retCode 1 
              }      
        }

        # if the list is empty at this point, then all routes on all ports have been advertised & we're done
        if {[llength $bgpPorts] == 0 && $retCode == 0} {
            set extraTime $timer
            set timer     $maxCount
   
        } else {
            after [expr [bgpSuite cget -delayTime] * 1000]
            if { $timer == [expr $maxCount - 1]} {
                set retCode  1
            }
        }
    }
    return $retCode
}

#################################################################################
# Procedure: configureBgp4statsQuery
#
# Description: This command configure the bgp4stats query. Added the neighborIp and stats
# Arguments:
# bgpPorts : 
# NeighborIpAddressArray : Array of neighbor Ip address
# DutIpAddressArray:       Array of DUT Ip address
#
# Results :       0 : No error found
#                 1 : Error found
#
#################################################################################

proc configureBgp4statsQuery { NeighborIpAddressArray DutIpAddressArray bgpPorts} \
{  
    upvar $NeighborIpAddressArray    neighborIpAddressArray
    upvar $DutIpAddressArray         dutIpAddressArray
    set retCode 0

    if {[protocol cget -name] == $::ip} {
        set type addressTypeIpV4
    } else {
        set type addressTypeIpV6
    }
    bgp4StatsQuery clearAllNeighbors
    bgp4StatsQuery clearAllStats 
       
    bgp4StatsQuery setDefault
    bgp4StatsQuery addStat bgpRoutesAdvertised
    bgp4StatsQuery addStat bgpRoutesWithdrawn
    bgp4StatsQuery addStat bgpStateMachineState  

    foreach portItem $bgpPorts {
        scan $portItem "%d %d %d" c l p
        if { [bgp4Server select $c $l $p] } {
            errorMsg "Error selecting BGP server on this port "
            set retCode 1
        }
 
        if {![bgp4Server getFirstNeighbor] } {
            set neighborIpAddressArray($c,$l,$p)       [bgp4Neighbor cget -localIpAddress]
            set dutIpAddressArray($c,$l,$p)            [bgp4Neighbor cget -dutIpAddress]
            if [bgp4StatsQuery addNeighbor [bgp4Neighbor cget -localIpAddress] [bgp4Neighbor cget -dutIpAddress] $type] {
                set retCode 1
            }

            while { [bgp4Server getNextNeighbor] == 0 } {
                lappend neighborIpAddressArray($c,$l,$p)       [bgp4Neighbor cget -localIpAddress]
                lappend dutIpAddressArray($c,$l,$p)            [bgp4Neighbor cget -dutIpAddress]
                if [bgp4StatsQuery addNeighbor [bgp4Neighbor cget -localIpAddress] [bgp4Neighbor cget -dutIpAddress] $type] {
                    set retCode 1
                }
            }
        }
                
    }
    return $retCode
}


################################################################################
# Procedure: getRoutesWithdrawn
#
# Description: This command gets number of withdrawn routes for the neighbor 
#              whose routeRanges flap. (First port in the map)
# Arguments:
# bgpPorts:
# NeighborIpAddressArray : Array of neighbor Ip address
# DutIpAddressArray:       Array of DUT Ip address
#
# Results :   Number of withdrawn routes
#
#################################################################################

proc getRoutesWithdrawn { NeighborIpAddressArray DutIpAddressArray bgpPorts} \
{         
    upvar $NeighborIpAddressArray    neighborIpAddressArray
    upvar $DutIpAddressArray         dutIpAddressArray
    
    set flapPort [lindex $bgpPorts 0]
    scan $flapPort "%d %d %d" c l p

    if { [bgp4StatsQuery get $c $l $p] } {
        logMsg " Error sending bgp stats query "
        set retCode 1
    }
    after 1000
    set index 0
    if [info exist neighborIpAddressArray($c,$l,$p)] {
        foreach neighborIpAddress $neighborIpAddressArray($c,$l,$p) {
            set dutIpAddress    [lindex $dutIpAddressArray($c,$l,$p) $index]
            bgp4StatsQuery setDefault
            for {set retry 10} {$retry >= 0} {incr retry -1} {
                if [bgp4StatsQuery getStat bgpRoutesWithdrawn $neighborIpAddress $dutIpAddress] {
                    after 1000
                    continue
                } else {
                    break
                 }
            } 
            set numRoutesWithdrawn  [bgp4StatsQuery cget -statValue]
        }
    }
    
    return $numRoutesWithdrawn
}



#################################################################################
# Procedure: estimateAdvertiseDelay
#
# Description: This command estimate AdvertiseDelay base on number of routes.
# Arguments :
# numRoutes : Number of routes to be advertised. 
#         
# Returned Value :   advertisDelay
#
#################################################################################
proc estimateAdvertiseDelay {numRoutes} \
{   
    #The numbers come from "Max update size" and this fact that each update message is 3 packets.
    #It also included number of ACKs.
    
    set rate    20
    set numPrefixeInPacket 675
    set numPackets 3
    
    set estimatedAdvertiseDelay [expr (($numRoutes/$numPrefixeInPacket)*$numPackets * 2)/$rate]
    #Add a fudge factor to estimated delay. (%20 of it)  
    set estimatedAdvertiseDelay [expr $estimatedAdvertiseDelay + ceil (0.2 * $estimatedAdvertiseDelay)]

    return $estimatedAdvertiseDelay
}

#################################################################################
# Procedure: configureBgp
#
# Description: This command configures bgp for bgp performance test
# Arguments :
# bgpPortList : list of ports on which BGP is configured. 
#         
# Returned Value :  
#
#################################################################################
proc configureBgp {bgpPortList} \
{
    global testConf

    set status $::TCL_OK

    set networkIPAddress [bgpSuite cget -firstRoute]
    set asNumber [bgpSuite cget -firstAsNumber]

    logMsg "Configure BGP on ports ..."
    set count 0
    foreach port $bgpPortList {
        scan $port "%d %d %d" c l p

        # initialize bgp server on rx port
        initializeBgp $c $l $p

        if {[protocol cget -name] == $::ip} {
            if [ip get $c $l $p] {
                errorMsg "Error getting ip on port [getPortId $c $l $p]"
                set retCode 1
            }
               
            set dutIP   [ip cget -destDutIpAddr ]
            set peerIP  [ip cget -sourceIpAddr]
            set prefixLength [bgpSuite cget -incrByRoutes]
        } else {
            if [ipV6 get $c $l $p] {
                errorMsg "Error getting ip on port [getPortId $c $l $p]"
                set retCode 1
            }
               
            set dutIP   [ipv6::incrIpField $testConf(firstDestDUTIpV6Address) $testConf(ipV6DstMaskWidth) $count]
            set peerIP  [ipV6 cget -sourceAddr]    
            set prefixLength [bgpSuite cget -incrByRoutes]
        }
        
        
        set incrByRouters [bgpSuite cget -incrByRouters]
        set routesPerPeer [bgpSuite cget -routesPerPeer]

        if {[string tolower [testConfig::getTestConfItem protocolName]] == "ipv6"} {
            set type "addressTypeIpV6"
        } else {
            set type "addressTypeIpV4"
        }

        for {set router 1} {$router <= [bgpSuite cget -numPeers]} {incr router} {


            setupRouteItem  $networkIPAddress $prefixLength $routesPerPeer $peerIP
                                        
            bgp4RouteItem config -ipType $type
            bgp4RouteItem config -nextHopIpType  $type
            bgp4RouteItem config -enableRouteRange true

            if {[bgpSuite cget -bgpType] == "Internal"} {
                bgp4RouteItem config -enableLocalPref true
		bgp4RouteItem config -asPathSetMode   bgpRouteAsPathNoInclude
            }

            if {[bgp4Neighbor addRouteRange     routeRange1]} {
                errorMsg "Error adding route range $networkIPAddress"
                set status 1
            }

            bgp4Neighbor config -type                   bgp4Neighbor[bgpSuite cget -bgpType]
            bgp4Neighbor config -localIpAddress         $peerIP
            bgp4Neighbor config -dutIpAddress           $dutIP
            bgp4Neighbor config -localAsNumber          $asNumber
            bgp4Neighbor config -bgpId                  $l.$p.0.$router
            bgp4Neighbor config -ipType                 $type

            if [bgp4Server  addNeighbor neighbor$router] {
                errorMsg "Error adding Neighbor with IP [bgp4Neighbor cget -localIpAddress] address to the server"
                set retCode 1
            }

            if {[bgpSuite cget -bgpType] == "External"} {
                incr asNumber
            }
            if {[protocol cget -name] == $::ip} {
                set networkIPAddress [num2ip [mpexpr [ip2num $networkIPAddress]+[ip2num [bgpSuite cget -incrByRouters]]]]
                set peerIP [num2ip [mpexpr [ip2num $peerIP]+[ip2num $testConf(ipSrcIncr)]]]
                set dutIP [num2ip [mpexpr [ip2num $dutIP]+[ip2num $testConf(ipDestIncr)]]]
            } else {
                set networkIPAddress [ipv6::convertBytesToIpv6Address [value2Hexlist [mpexpr [hexlist2Value \
                           [ipv6::host2addr $networkIPAddress]] +[hexlist2Value [ipv6::host2addr [bgpSuite cget -incrByRouters]]]] 16]]
                set peerIP [ipv6::convertBytesToIpv6Address [value2Hexlist [mpexpr [hexlist2Value \
                           [ipv6::host2addr $peerIP]] +[hexlist2Value [ipv6::host2addr $testConf(ipV6SrcIncr)]]] 16]]
                set dutIP [ipv6::convertBytesToIpv6Address [value2Hexlist [mpexpr [hexlist2Value [ipv6::host2addr $dutIP]] \
                             +[hexlist2Value [ipv6::host2addr $testConf(ipV6DstIncr)]]] 16]]
            }
            
        }

        if [bgp4Server  set] {
           errorMsg "Error setting the bgp4Server"
        }

        enablePortProtocolStatistics    $c $l $p enableBgpStats
        enablePortProtocolServer        $c $l $p bgp4 noWrite
	incr count
    }

    return $status
}

#################################################################################
# Procedure: writeBgpPerformanceConvergenceStreams
#
# Description: This command configures and writes the stream for bgp performance test
#
#################################################################################
proc writeBgpPerformanceStreams {TxRxArray {TxNumFrames ""} {numFrames 0} {testCmd bgpSuite}} \
{
    upvar $TxRxArray    txRxArray
    upvar $TxNumFrames  txNumFrames
    variable atmOnlyPortList
    variable nonAtmPortList

    if {[atmUtils::configureAtmPorts txRxArray atmOnlyPortList nonAtmPortList] == $::TCL_ERROR} {
        errorMsg "***** ERROR:  failed to configure ATM ports.  Test aborted."
        return $::TCL_ERROR;
    }

    set framesize	[bgpSuite cget -framesize]

    set initialDuration [$testCmd cget -duration]

    filterPallette setDefault
    filter setDefault
    udf             setDefault

    if {![info exists udfList]} {
        set udfList {1 2 3 4}
    }

    disableUdfs $udfList

    set genericPattern        {AA AA AA AA}
    set adjustVlanOffset        0

    set retCode 0
    
    set preambleSize    8

    stream setDefault
    stream config -daRepeatCounter   daArp
    stream config -framesize         [$testCmd cget -framesize]
    stream config -enableTimestamp   true

    stream config -enableIbg         false
    stream config -enableIsg         false

    stream config -rateMode          usePercentRate
    stream config -percentPacketRate [$testCmd cget -percentMaxRate]
    stream config -gapUnit           gapNanoSeconds

    set firstRouteAddress [$testCmd cget -firstRoute]

    set streamGroup 0
    foreach txPort [lsort [array names txRxArray]] {
        scan $txPort "%d,%d,%d" tx_c tx_l tx_p

        if {[protocol cget -name] == $::ip} {
            set packetGroupIdOffset     42 
            set packetGroupOffset       48   
            set sequenceNumberOffset    52
            set dataIntegrityOffset     44
            set destIpOffset            30

#             if {[atmUtils::isAtmPort $tx_c $tx_l $tx_p]} {
#                 set packetGroupIdOffset     52
#                 set packetGroupOffset       58
#                 set sequenceNumberOffset    62
#                 set dataIntegrityOffset     54
#                 set destIpOffset            40
#             }
        } else {
            set packetGroupIdOffset     62 
            set packetGroupOffset       68   
            set sequenceNumberOffset    72
            set dataIntegrityOffset     64
	    set destIpOffset            38

#             if {[atmUtils::isAtmPort $tx_c $tx_l $tx_p]} {
#                 set packetGroupIdOffset     72
#                 set packetGroupOffset       78
#                 set sequenceNumberOffset    82
#                 set dataIntegrityOffset     74
#                 set destIpOffset            48
#             }
        }

        set atmTxOffset 0
        if {[atmUtils::isAtmPort $tx_c $tx_l $tx_p]} {
            set atmTxOffset 10
        }

        if {[protocol cget -enable802dot1qTag]} {
            set adjustVlanOffset        4
            set destIpOffset       [expr $destIpOffset+4]
        }
        
        set pppTxOffset 0
        if {[detectPPP $tx_c $tx_l $tx_p]} {
            set pppTxOffset 10
        }

        set streamID    1
        set txNumFrames($tx_c,$tx_l,$tx_p)   0

        # get the mac & Ip addresses for the da/sa
        if [port get $tx_c $tx_l $tx_p] {
            errorMsg "Port [getPortId $tx_c $tx_l $tx_p] not configured yet!"
            set retCode 1
        }

        set numRxPorts [llength  $txRxArray($txPort)]
        foreach rxPort [lsort $txRxArray($txPort)] {
            scan [join $rxPort] "%d %d %d" rx_c rx_l rx_p

            set count [lsearch [getAllPorts txRxArray] $rxPort]

            stream config -sa   [port cget -MacAddress]

            for {set router 0} {$router < [bgpSuite cget -numPeers]} {incr router} {

                set stepToIncrement [mpexpr $count*[bgpSuite cget -numPeers]+$router]

                if { $numFrames == 0 } {
                    stream config -numFrames    [bgpSuite cget -routesPerPeer]
                } else {
                    stream config -numFrames    $numFrames
                }
                stream config -preambleSize     $preambleSize

                if {[protocol cget -name] == $::ip} {

                    set networkIPAddress [num2ip [mpexpr [ip2num $firstRouteAddress]+[ip2num [bgpSuite cget -incrByRouters]]*$stepToIncrement]]

                    #   Use UDF 1 for Destination Ip Address
                    udf setDefault
                    udf config -enable          $::true
                    udf config -offset          [expr $destIpOffset-$pppTxOffset+$atmTxOffset]
                    udf config -countertype     $::c32
                    udf config -initval         [host2addr $networkIPAddress]
                    udf config -repeat          [bgpSuite cget -routesPerPeer]
                    udf config -step            [mpexpr 2<<[expr 31 -  [bgpSuite cget -incrByRoutes]]]

                    if {[udf set 1]} {
                        errorMsg "Error setting udf 1."
                        set status 1
                    }

                } else {

                    set networkIPAddress [ipv6::convertBytesToIpv6Address [value2Hexlist [mpexpr [hexlist2Value \
                               [ipv6::host2addr $firstRouteAddress]] +[hexlist2Value [ipv6::host2addr [bgpSuite cget -incrByRouters]]]*$stepToIncrement] 16]]

                    if [ipV6 get $tx_c $tx_l $tx_p] {
                        errorMsg "Error getting ip on port [getPortId $tx_c $tx_l $tx_p]"
                        set retCode 1
                    }

                    ipV6   config -destAddr       $networkIPAddress
                    ipV6   config -destMask       [bgpSuite cget -incrByRoutes]
                    ipV6   config -destAddrMode   ipV6IncrNetwork

                    if [ipV6 set $tx_c $tx_l $tx_p] {
                        errorMsg "Error setting ip on port [getPortId $tx_c $tx_l $tx_p]"
                        set retCode 1
                    }   

                }

                ##### Stream for generating traffic to the routes #####
                stream config -name         "Tx->$networkIPAddress"

                if {[atmUtils::isAtmPort $tx_c $tx_l $tx_p]} {
                    if {[atmUtils::buildAtmParams  $tx_c $tx_l $tx_p]} {
                        errorMsg "Error building ATM parameters."
                        set retCode $::TCL_ERROR
                    }
                }

                if [streamUtils::streamSet $tx_c $tx_l $tx_p $streamID] {
                    errorMsg "Error setting stream $streamID for network on port [getPortId $tx_c $tx_l $tx_p]"
                    set retCode $::TCL_ERROR
                }

                # note - we set the stream twice because we need to get the conf'd framerate for calc'ing the duration
                if {[port isActiveFeature $tx_c $tx_l $tx_p $::portFeatureAtm]} {
                    if {[streamQueue get $tx_c $tx_l $tx_p 1]} {
                        errorMsg "Error getting streamQueue on [getPortId $tx_c $tx_l $tx_p] for queue 1"
                    }
                    set framerate    [mpexpr round ([streamQueue cget -aal5FrameRate])]
                } else {
                    if [stream get $tx_c $tx_l $tx_p $streamID] {
                        errorMsg "Error getting stream $streamID from port [getPortId $tx_c $tx_l $tx_p]"
                        set retCode 1
                    }
                    set framerate    [stream cget -framerate]
                }

                set loopCount 1
		
                #calculate the duration 
                set loopCount    [mpexpr round (double ($framerate)/[stream cget -numFrames]/[bgpSuite cget -numPeers]/$numRxPorts * $initialDuration)]
		if { $loopCount == 0} {
                    set loopCount 1
		    set newDuration [mpexpr round(1.0 * $loopCount * [stream cget -numFrames] * [bgpSuite cget -numPeers] * $numRxPorts / $framerate)]
		    if {[$testCmd cget -duration] < $newDuration} {
		    $testCmd config -duration $newDuration
		    
		    }
		}

                set txNumFrames($tx_c,$tx_l,$tx_p)  [mpexpr $txNumFrames($tx_c,$tx_l,$tx_p)+($loopCount* [stream cget -numFrames])]

                if {$streamID < [mpexpr [llength $txRxArray($txPort)]*[bgpSuite cget -numPeers]] } {
                    stream config -dma   3
                } else {
                    stream config -dma   firstLoopCount
                    stream config -loopCount    $loopCount
                }
                
                set  packetGroupId [mpexpr ($streamGroup << 8) | $stepToIncrement]

                #   Use UDF 2 for packet Group Id
                udf setDefault
                udf config -enable          $::true
                udf config -offset          [expr $packetGroupIdOffset-$pppTxOffset+$atmTxOffset]
 		udf config -initval         [value2Hexlist $packetGroupId 2]
                udf config -countertype     $::c16
 		udf config -continuousCount $::false
 		udf config -repeat          1
		udf config -step            1

                if {[udf set 2]} {
		    errorMsg "Error setting udf 2."
                    set status 1
                }

                packetGroup setDefault

                setupPacketGroup $framesize $tx_c $tx_l $tx_p

                packetGroup config -signatureOffset	       [expr $packetGroupOffset-$pppTxOffset+$atmTxOffset]
                packetGroup config -groupIdOffset	       [expr $packetGroupIdOffset-$pppTxOffset+$atmTxOffset]  
                packetGroup config -signature	           $genericPattern
                packetGroup config -insertSequenceSignature $::true
                packetGroup config -sequenceNumberOffset    [expr $sequenceNumberOffset-$pppTxOffset+$atmTxOffset]
                packetGroup config -allocateUdf             $::false

                if {[atmUtils::isAtmPort $tx_c $tx_l $tx_p]} { 
                    if {[packetGroup setQueueTx $tx_c $tx_l $tx_p 1 $streamID]} {
                        errorMsg "Error setting packetGroup setQueueTx on [getPortId $tx_c $tx_l $tx_p] 1 $streamID"
                        set retCode $::TCL_ERROR
                    }
                } else {
                    if {[packetGroup setTx $tx_c $tx_l $tx_p $streamID]} {
                        errorMsg "Error setting packetGroup setTx on [getPortId $tx_c $tx_l $tx_p] $streamID"
                        set retCode $::TCL_ERROR
                    }
                }

                dataIntegrity config -signatureOffset [expr $packetGroupOffset-$pppTxOffset+$atmTxOffset]
                dataIntegrity config -signature       $genericPattern
                dataIntegrity config -insertSignature true
                dataIntegrity config -enableTimeStamp true

                if {[atmUtils::isAtmPort $tx_c $tx_l $tx_p]} { 
                    if {[dataIntegrity setQueueTx $tx_c $tx_l $tx_p 1 $streamID]} {
                        errorMsg "Error setting packetGroup setQueueTx on [getPortId $tx_c $tx_l $tx_p] 1 $streamID"
                        set retCode $::TCL_ERROR
                    }
                } else {
                    if {[dataIntegrity setTx $tx_c $tx_l $tx_p $streamID]} {
                        errorMsg "Error setting packetGroup setTx on [getPortId $tx_c $tx_l $tx_p] $streamID"
                        set retCode $::TCL_ERROR
                    }
                }
                if {[atmUtils::isAtmPort $tx_c $tx_l $tx_p]} {
                    if {[atmUtils::buildAtmParams  $tx_c $tx_l $tx_p]} {
                        errorMsg "Error building ATM parameters."
                        set retCode $::TCL_ERROR
                    }
                }

                if [streamUtils::streamSet $tx_c $tx_l $tx_p $streamID] {
                    errorMsg "Error setting stream $streamID on port [getPortId $tx_c $tx_l $tx_p]"
                    set retCode $::TCL_ERROR
                }

                incr streamID
            }   
	     set pppRxOffset 0
             if {[detectPPP $rx_c $rx_l $rx_p]} {
                 set pppRxOffset 10
             }

             set atmRxOffset 0
             if {[atmUtils::isAtmPort $rx_c $rx_l $rx_p]} {
                 set atmRxOffset 10
             }

            # set up the pattern filter
            filterPallette config -pattern1		    $genericPattern
            filterPallette config -patternMask1		{00 00 00 00}
            filterPallette config -patternOffset1	[expr $packetGroupOffset-$pppRxOffset+$atmRxOffset + [adjustSignatureUdfForVlan $txPort $rxPort]]

            if [filterPallette set $rx_c $rx_l $rx_p] {
                errorMsg "Error setting filter pallette for [getPortId $rx_c $rx_l $rx_p]"
                set status $::TCL_ERROR
            }

            # set the filter parameters on the receive port
            filter setDefault
            filter config -captureFilterEnable	        true
            filter config -captureTriggerEnable	        true            
            filter config -userDefinedStat2Enable  true
            filter config -userDefinedStat2Pattern pattern1

            if [filter set $rx_c $rx_l $rx_p] {
                errorMsg "Error setting filters on [getPortId $rx_c $rx_l $rx_p]"
            }

            setupPacketGroup $framesize $rx_c $rx_l $rx_p 0 [expr $packetGroupIdOffset-$pppRxOffset+$atmRxOffset]
            packetGroup config -signatureOffset        [expr $packetGroupOffset-$pppRxOffset+$atmRxOffset + [adjustSignatureUdfForVlan $txPort $rxPort]]
            packetGroup config -groupIdOffset          [expr $packetGroupIdOffset-$pppRxOffset+$atmRxOffset + [adjustSignatureUdfForVlan $txPort $rxPort]]
            packetGroup config -signature              $genericPattern
            packetGroup config -sequenceNumberOffset   [expr $sequenceNumberOffset-$pppRxOffset+$atmRxOffset + [adjustSignatureUdfForVlan $txPort $rxPort]]

            if [packetGroup setRx $rx_c $rx_l $rx_p] {
                errorMsg "Error setting Rx packetGroup on [getPortId $rx_c $rx_l $rx_p]"
                set status $::TCL_ERROR
            }

            dataIntegrity config -signatureOffset [expr $packetGroupOffset-$pppRxOffset+$atmRxOffset + [adjustSignatureUdfForVlan $txPort $rxPort]]
            dataIntegrity config -signature       $genericPattern

            if [dataIntegrity setRx $rx_c $rx_l $rx_p] {
                errorMsg "Error setting Tx dataIntegrity on [getPortId $rx_c $rx_l $rx_p]"
                set status $::TCL_ERROR
            }

            if [filter set $rx_c $rx_l $rx_p] {
                errorMsg "Error setting filters on port [getPortId $rx_c $tx_l $rx_p]"
                set retCode 1
            }

            if [filterPallette set $rx_c $rx_l $rx_p] {
                errorMsg "Error setting filterPallette on port [getPortId $rx_c $rx_l $rx_p]"
                set retCode 1
            }
            
        }
        incr streamGroup

    }
    if {[$testCmd cget -duration] != $initialDuration} {
	logMsg "The configured duration was changed to [$testCmd cget -duration] in order to test all advertised routes."
	foreach txPort [lsort [array names txRxArray]] {
	    scan $txPort "%d,%d,%d" tx_c tx_l tx_p
    
	    set txNumFrames($tx_c,$tx_l,$tx_p)   0
    
	    set numRxPorts [llength  $txRxArray($txPort)]
	    set numStreams [mpexpr $numRxPorts *[bgpSuite cget -numPeers]]
            # note - we set the stream twice because we need to get the conf'd framerate for calc'ing the duration
            if {[port isActiveFeature $tx_c $tx_l $tx_p $::portFeatureAtm]} {
                if {[streamQueue get $tx_c $tx_l $tx_p 1]} {
                    errorMsg "Error getting streamQueue on [getPortId $tx_c $tx_l $tx_p] for queue 1"
                    set retCode 1
                }
                set framerate    [mpexpr round ([streamQueue cget -aal5FrameRate])]
            } else {
                if [stream get $tx_c $tx_l $tx_p $numStreams] {
                    errorMsg "Error getting stream $numStreams from port [getPortId $tx_c $tx_l $tx_p]"
                    set retCode 1
                }
                set framerate    [stream cget -framerate]
            }
    
	    set loopCount 1
	    
	    #calculate the duration 
	    set loopCount    [mpexpr round (double ($framerate)/[stream cget -numFrames]/$numStreams * [$testCmd cget -duration])]
	    stream config -loopCount    $loopCount
	    set txNumFrames($tx_c,$tx_l,$tx_p)  [mpexpr $txNumFrames($tx_c,$tx_l,$tx_p)+($loopCount* [stream cget -numFrames]*$numStreams)]
            if {[atmUtils::isAtmPort $tx_c $tx_l $tx_p]} {
                if {[atmUtils::buildAtmParams  $tx_c $tx_l $tx_p]} {
                    errorMsg "Error building ATM parameters."
                    set retCode 1
                }
            }

            if [streamUtils::streamSet $tx_c $tx_l $tx_p $numStreams] {
                errorMsg "Error setting stream $numStreams for network on port [getPortId $tx_c $tx_l $tx_p]"
                set retCode 1
            }
	}
    }
    if {$retCode == 0} {
       # adjustOffsets txRxArray
        set retCode [writeConfigToHardware txRxArray]
    }
    return $retCode
}

########################################################################
# Procedure: bgpPerformance::doBinarySearch
#
# This command performs a binary search for BGP Performance test.  
#
# Arguments(s):
#   testCmd             - name of test command
#   TxRxArray           - map, ie. one2oneArray
#   Framerate           - array containing the framerates, per port
#   TputRateArray       - array containing the binary search results
#   TxNumFrames         - array containing the number of frames to Tx 
#   TotalTxNumFrames    - total number of frames transmitted
#   RxNumFrames         - array containing the number of frames recv'd
#   TotalRxNumFrames    - total number of frames recv'd
#   PercentMaxRate      - array containing the percent max rate per stream
#   multiTxStream       - (optional) flag; if yes then there is more than one stream created per tx port
#   LossPercent         - (optional) percent rate at which loss occurred
#   AvgLatency          - (optional) 
#   StdDeviation        - (optional)
#   NumAddressesPerStream   - (optional)
#
########################################################################
proc bgpPerformance::doBinarySearch { \
        testCmd TxRxArray Framerate TputRateArray \
        TxNumFrames TotalTxNumFrames RxNumFrames TotalRxNumFrames PercentMaxRate \
        {multiTxStream no} {LossPercent ""} {AvgLatency "" } {StdDeviation "" } {NumAddressesPerStream ""}} \
{
    global ixgJitterIndex
    upvar $TxRxArray        txRxArray
    upvar $TputRateArray    tputRateArray
    upvar $TxNumFrames      txNumFrames
    upvar $TotalTxNumFrames totalTxNumFrames
    upvar $RxNumFrames      rxNumFrames
    upvar $TotalRxNumFrames totalRxNumFrames
    upvar $LossPercent      lossPercent
    upvar $AvgLatency       avgLatency
    upvar $StdDeviation     stdDeviation
    upvar $NumAddressesPerStream numAddressesPerStream
    upvar $Framerate localFramerate
    upvar $PercentMaxRate localPercentMaxRate

    # This is needed to prevent the value of frameRate 
    # from being changed in this function
    array set framerate [array get localFramerate]

    set txPortList [getTxPorts txRxArray]

    if {[info exists ${testCmd}::trial]} {
       set trialStr " trial [set ${testCmd}::trial],"
    } else {
       set trialStr ""
    }


    # This is needed to prevent the value of percentMaxRate 
    # from being changed in this function
    if {![array exists localPercentMaxRate]} {
        foreach txMap $txPortList {
            scan $txMap "%d %d %d" tx_c tx_l tx_p
            set percentMaxRate($tx_c,$tx_l,$tx_p)   [$testCmd cget -percentMaxRate]
        }
    } else {
        array set percentMaxRate [array get localPercentMaxRate]
    }
    set retCode $::TCL_OK
    
    set enable802dot1qTag   [protocol cget -enable802dot1qTag]
    set framesize           [$testCmd cget -framesize]
    set latencyOffset       [min 1500 [expr [getUdfOffset $framesize] - 4]]

    if {[catch {$testCmd cget -linearBinarySearch} linearBinarySearch]} {
        set linearBinarySearch false 
    }

    set preambleSize  8

    if {[catch {format %d $lossPercent}]} {
        set lossPercent 0
    }

    if {[catch {$testCmd cget -tolerance} tolerance]} {
        set tolerance   0
    }
     
    set numRxPortsPerStream 1 

    # make txRxArray list of rx-->tx so that we can count the total sent tx-->rx
    bgpPerformance::countTxRxFrames txRxArray txNumFrames txRxFrames

    # set the high and low indices for binary search algorithm
    foreach txMap $txPortList {
        scan $txMap "%d %d %d" tx_c tx_l tx_p
   
        set best($tx_c,$tx_l,$tx_p)         0
        set bestTxNumFrames($tx_c,$tx_l,$tx_p) 0
        
        set high($tx_c,$tx_l,$tx_p)             $percentMaxRate($tx_c,$tx_l,$tx_p)
        set low($tx_c,$tx_l,$tx_p)              $lossPercent
    }

    foreach rxMap [getRxPorts txRxArray] {
        scan $rxMap "%d %d %d" rx_c rx_l rx_p
        set txStart($rx_c,$rx_l,$rx_p)      $txRxFrames($rx_c,$rx_l,$rx_p)
        
        set bestRxNumFrames($rx_c,$rx_l,$rx_p) 0
    }

    set initialDuration [$testCmd cget -duration]
    set doneList    [getTxPorts txRxArray]
    set iteration 1
    # start binary search
    while {[llength $doneList] > 0} {
        # setup for transmitting
        if {$linearBinarySearch == "false"} {
            logMsg "\n---> BINARY ITERATION $iteration,$trialStr framesize: $framesize, [$testCmd cget -testName]" 
            debugMsg "\n---> BINARY ITERATION $iteration,$trialStr framesize: $framesize, [$testCmd cget -testName]" 
        } else {
            set totalRate 0
            foreach txMap [getTxPorts txRxArray] {
                set totalRate [mpexpr $totalRate+$percentMaxRate($tx_c,$tx_l,$tx_p)]
            }
            set rate [format "%3.4f" [mpexpr $totalRate/[llength  [getTxPorts txRxArray]]]]
            logMsg "\n---> BINARY ITERATION $iteration, transmit rate: $rate%,$trialStr framesize: $framesize, [$testCmd cget -testName]" 
            debugMsg "\n---> BINARY ITERATION $iteration, transmit rate: $rate%,$trialStr framesize: $framesize, [$testCmd cget -testName]"
        }
        set txRateBelowLimit 0

        if {$linearBinarySearch == "false"} {
            set portList    $doneList

            foreach txMap $portList {
                scan $txMap "%d %d %d" tx_c tx_l tx_p

                if {$framerate($tx_c,$tx_l,$tx_p) < [$testCmd cget -minimumFPS]} {
                    logMsg "\n***> Throughput has fallen below [$testCmd cget -minimumFPS]fps on [getPortId $tx_c $tx_l $tx_p] ***<"
                    set tputRateArray($tx_c,$tx_l,$tx_p) $framerate($tx_c,$tx_l,$tx_p)
                    set indx [lsearch $doneList [list $tx_c $tx_l $tx_p]]
                    if {$indx != -1} {
                        set doneList [lreplace $doneList $indx $indx]
                    }
                }
            }
        } else {
            set portList    [getTxPorts txRxArray]

            foreach txMap $portList {
                scan $txMap "%d %d %d" tx_c tx_l tx_p
                set  flag 0
                if {$framerate($tx_c,$tx_l,$tx_p) < [$testCmd cget -minimumFPS]} {
                    set flag 1
                    break
                }
            }

            if {$flag} {
                logMsg "\n***> Throughput has fallen below [$testCmd cget -minimumFPS]fps on at least one port ***<"
                foreach txMap $portList {
                    scan $txMap "%d %d %d" tx_c tx_l tx_p
                    set tputRateArray($tx_c,$tx_l,$tx_p) $framerate($tx_c,$tx_l,$tx_p)
                    set doneList {}                             
                }
            }

        }

	if {$initialDuration != [$testCmd cget -duration]} {
	    logMsg "The configured duration was changed to [$testCmd cget -duration] in order to test all advertised routes."
	}
        if {[clearStatsAndTransmit txRxArray [$testCmd cget -duration] "" yes avgRunningRate]} {
            return $::TCL_ERROR
        }

        waitForResidualFrames [$testCmd cget -waitResidual]

        # Poll the Tx counters until all frames are sent
        stats::collectTxStats [getTxPorts txRxArray] txNumFrames txActualFrames totalTxNumFrames
        collectRxStats [getRxPorts txRxArray]  rxNumFrames totalRxNumFrames 
        

        debugMsg "totalRxNumFrames:$totalRxNumFrames"

        ### diplay the result according to the rateSelect option of the testCmd
        array set OLoadArray [array get framerate]
        set OLoadHeaderString OLoad(fps)

        # here display TX rate after each iteration
        logMsg "\nConfigured Transmit Rates used for iteration $iteration"
        logMsg [format "%-12s\t%-12s\t%-10s\t%-10s\t%-10s\t%-10s\t%-10s" "TX" "RX" $OLoadHeaderString "%MaxTxRate" "AvgTxRunRate" "AvgRxRunRate" "%Percent Loss"]
        logMsg "*************************************************************************************************************"

        set oldRxPort " "
        set oldTxPort " "

        foreach txPort [getTxPorts txRxArray] {
            scan $txPort "%d %d %d" tx_c tx_l tx_p

            foreach rxPort $txRxArray($tx_c,$tx_l,$tx_p) {
                scan $rxPort "%d %d %d" rx_c rx_l rx_p          

                set txPortString [getPortString $tx_c $tx_l $tx_p]
                set rxPortString [getPortString $rx_c $rx_l $rx_p]
                set OLoadString $OLoadArray($tx_c,$tx_l,$tx_p)
                set pctPktRateArray [format "%8.4f" $percentMaxRate($tx_c,$tx_l,$tx_p)]
                set txAvgRateString $avgRunningRate(TX,$tx_c,$tx_l,$tx_p)
                set rxAvgRateString $avgRunningRate(RX,$rx_c,$rx_l,$rx_p)
                set percentLoss   [format "%3.2f" [calculatePercentLossExact $txRxFrames($rx_c,$rx_l,$rx_p) $rxNumFrames($rx_c,$rx_l,$rx_p)]]

                if {$rxPort == $oldRxPort} {
                    set rxPortString " "
                    set rxAvgRateString " "
                    set percentLoss " "
                } else {
                    set oldRxPort $rxPort           
                }
        
                if {$txPort == $oldTxPort} {
                    set txPortString " "
                    set OLoadString " "
                    set pctPktRateArray " "
                    set txAvgRateString " "
                } else {
                    set oldTxPort $txPort           
                } 

                logMsg [format "%-12s\t%-12s\t%-10s\t%-10s\t%-10s\t%-10s\t%-10s" \
                    $txPortString \
                    $rxPortString \
                    $OLoadString \
                    $pctPktRateArray \
                    $txAvgRateString \
                    $rxAvgRateString\
                    $percentLoss]
           }
        }

        # if one port received zero frames and binayrsearch is linear,to save the iterations data
        # for the csv files we force by setting txRateBelowLimit , because it is the last iteration anyway

        if {$linearBinarySearch == "true"} {
            foreach txMap $portList {
                scan $txMap "%d %d %d" tx_c tx_l tx_p
                foreach rxMap $txRxArray($tx_c,$tx_l,$tx_p) {
                    scan $rxMap "%d %d %d" rx_c rx_l rx_p
                    if {$rxNumFrames($rx_c,$rx_l,$rx_p) == 0} {
                        debugMsg "\nPort $rx_c,$rx_l,$rx_p received zero"
                        set txRateBelowLimit 1
                        break
                    } 
                }
                if { $txRateBelowLimit == 1 } {
                    break
                }
            } ;# for txMap
        }

        writeIterationData2CSVFile $iteration $testCmd txRxArray framerate tputRateArray \
                                                 txRxFrames totalTxNumFrames rxNumFrames totalRxNumFrames \
                                                 OLoadArray txRateBelowLimit

        logMsg "*************************************************************************************************************"

        set warnings ""

        getTransmitTime txRxArray [$testCmd cget -duration] durationArray warnings

        if {$linearBinarySearch == "false"} {
            foreach txMap $portList {
                scan $txMap "%d %d %d" tx_c tx_l tx_p

                set numRxPort [llength $txRxArray($tx_c,$tx_l,$tx_p)]

                if {[port get $tx_c $tx_l $tx_p]} {
                    logMsg "writeBgpPerformanceStreams: port [getPortId $tx_c $tx_l $tx_p] not configured yet!"
                    set retCode $::TCL_ERROR
                }

                set txMode    [port cget -transmitMode]

                set doneFlag($tx_c,$tx_l,$tx_p) done
                foreach rxMap $txRxArray($tx_c,$tx_l,$tx_p) {
                    scan $rxMap "%d %d %d" rx_c rx_l rx_p

                    debugMsg " ********* rxNumFrames($rx_c,$rx_l,$rx_p):$rxNumFrames($rx_c,$rx_l,$rx_p),txRxFrames($rx_c,$rx_l,$rx_p):$txRxFrames($rx_c,$rx_l,$rx_p)"

                    set percentLoss   [calculatePercentLossExact $txRxFrames($rx_c,$rx_l,$rx_p) $rxNumFrames($rx_c,$rx_l,$rx_p)]

                    if {$rxNumFrames($rx_c,$rx_l,$rx_p) == 0} {
                        set status($rx_c,$rx_l,$rx_p)    zero
                        set doneFlag($tx_c,$tx_l,$tx_p)  zero
                        break
                    } elseif {$rxNumFrames($rx_c,$rx_l,$rx_p) == $txStart($rx_c,$rx_l,$rx_p)} {
                        set status($rx_c,$rx_l,$rx_p)    done
                    } elseif {$rxNumFrames($rx_c,$rx_l,$rx_p) != $txRxFrames($rx_c,$rx_l,$rx_p) && ($percentLoss > $tolerance)} {
                        set status($rx_c,$rx_l,$rx_p)    notequal
                        set doneFlag($tx_c,$tx_l,$tx_p)  notequal
                    } else {
                        set status($rx_c,$rx_l,$rx_p)    equal
                        if {$numRxPort == 1} {
                            set doneFlag($tx_c,$tx_l,$tx_p)  equal
                        } elseif {$doneFlag($tx_c,$tx_l,$tx_p) != "notequal"} {
                            set doneFlag($tx_c,$tx_l,$tx_p)  equal
                        }
                    }
                    debugMsg "status($rx_c,$rx_l,$rx_p):$status($rx_c,$rx_l,$rx_p)"
                }
                debugMsg "doneFlag($tx_c,$tx_l,$tx_p): $doneFlag($tx_c,$tx_l,$tx_p)"

                switch $doneFlag($tx_c,$tx_l,$tx_p) {
                    zero {
                        set tputRateArray($tx_c,$tx_l,$tx_p) 0
                        set indx [lsearch $doneList [list $tx_c $tx_l $tx_p]]
                        if {$indx != -1} {
                            set doneList [lreplace $doneList $indx $indx]
                        }
                        continue
                    }
                    done {
                        if {$warnings != ""} {
                            logMsg $warnings
                            set warnings ""
                        }
                        set best($tx_c,$tx_l,$tx_p)          $framerate($tx_c,$tx_l,$tx_p)
                        set tputRateArray($tx_c,$tx_l,$tx_p) $framerate($tx_c,$tx_l,$tx_p)
                        set indx [lsearch $doneList [list $tx_c $tx_l $tx_p]]
                        if {$indx != -1} {
                            set doneList [lreplace $doneList $indx $indx]
                        }
                        debugMsg "done: best($tx_c,$tx_l,$tx_p):$best($tx_c,$tx_l,$tx_p), doneList:$doneList"
                    }
                    equal {
                        # up the framerate & normalize it
                        set best($tx_c,$tx_l,$tx_p)           $framerate($tx_c,$tx_l,$tx_p)
                        set low($tx_c,$tx_l,$tx_p)            $percentMaxRate($tx_c,$tx_l,$tx_p)
                        set percentMaxRate($tx_c,$tx_l,$tx_p) [mpexpr ($high($tx_c,$tx_l,$tx_p) + $low($tx_c,$tx_l,$tx_p))/2.00]
                        debugMsg "equal: best($tx_c,$tx_l,$tx_p):$best($tx_c,$tx_l,$tx_p), durationArray($tx_c,$tx_l,$tx_p):$durationArray($tx_c,$tx_l,$tx_p)"
                    }
                    notequal {
                        # lower framerate
                        set high($tx_c,$tx_l,$tx_p)           $percentMaxRate($tx_c,$tx_l,$tx_p)
                        set percentMaxRate($tx_c,$tx_l,$tx_p) [mpexpr ($high($tx_c,$tx_l,$tx_p) + $low($tx_c,$tx_l,$tx_p))/2.00]
                    }
                }
            }
        } else {
            # we need to see totally if there is any port fail, and decide the overalStatus         
            set equalCount      0
            set notequalCount   0
            set overalStatus    done

            foreach txMap $portList {
                scan $txMap "%d %d %d" tx_c tx_l tx_p

                if {[port get $tx_c $tx_l $tx_p]} {
                    logMsg "writeImixTpndrStreams: port [getPortId $tx_c $tx_l $tx_p] not configured yet!"
                    set retCode $::TCL_ERROR
                }

                foreach rxMap $txRxArray($tx_c,$tx_l,$tx_p) {

                    scan $rxMap "%d %d %d" rx_c rx_l rx_p
                    debugMsg ">>>>>> txRxFrames($rx_c,$rx_l,$rx_p):$txRxFrames($rx_c,$rx_l,$rx_p),rxNumFrames($rx_c,$rx_l,$rx_p):$rxNumFrames($rx_c,$rx_l,$rx_p)"
                    set percentLoss   [calculatePercentLossExact $txRxFrames($rx_c,$rx_l,$rx_p) $rxNumFrames($rx_c,$rx_l,$rx_p)]

                    if {$rxNumFrames($rx_c,$rx_l,$rx_p) == 0} {
                        debugMsg ">>>>>> rxNumFrames($rx_c,$rx_l,$rx_p) == 0 "
                        set overalStatus zero
                        break
                    } elseif {$rxNumFrames($rx_c,$rx_l,$rx_p) == $txStart($rx_c,$rx_l,$rx_p)} {
                        debugMsg ">>>>>> rxNumFrames($rx_c,$rx_l,$rx_p) == txStart($rx_c,$rx_l,$rx_p) "
                        # do nothing
                    } elseif {$rxNumFrames($rx_c,$rx_l,$rx_p) != $txRxFrames($rx_c,$rx_l,$rx_p) && ($percentLoss > $tolerance)} {
                        debugMsg ">>>>>> rxNumFrames($rx_c,$rx_l,$rx_p) != txRxFrames($rx_c,$rx_l,$rx_p) && ($percentLoss > $tolerance)) "
                        incr notequalCount
                    } else {
                        debugMsg ">>>>>> equalCount :$equalCount "
                        incr equalCount
                    }
                }
            }

            if {$overalStatus == "zero"} {
                set doneList {}
            } elseif {$notequalCount > 0} {
                set overalStatus notequal
            } elseif {$equalCount > 0} {
                set overalStatus equal
            } else {
                set overalStatus done
                set doneList {}
            }

            foreach txMap $portList {
                scan $txMap "%d %d %d" tx_c tx_l tx_p

                switch $overalStatus {
                    zero {
                        set tputRateArray($tx_c,$tx_l,$tx_p)    0
                    }
                    done {
                        set best($tx_c,$tx_l,$tx_p)          $framerate($tx_c,$tx_l,$tx_p)
                        set bestTxNumFrames($tx_c,$tx_l,$tx_p) $txActualFrames($tx_c,$tx_l,$tx_p)
                        set bestRxNumFrames($rx_c,$rx_l,$rx_p) $rxNumFrames($rx_c,$rx_l,$rx_p)
                        
                        set tputRateArray($tx_c,$tx_l,$tx_p) $framerate($tx_c,$tx_l,$tx_p)
                    }
                    equal {
                        set best($tx_c,$tx_l,$tx_p)           $framerate($tx_c,$tx_l,$tx_p)
                        set bestTxNumFrames($tx_c,$tx_l,$tx_p) $txActualFrames($tx_c,$tx_l,$tx_p)
                        set bestRxNumFrames($rx_c,$rx_l,$rx_p) $rxNumFrames($rx_c,$rx_l,$rx_p)

                        set low($tx_c,$tx_l,$tx_p)            $percentMaxRate($tx_c,$tx_l,$tx_p)
                        set percentMaxRate($tx_c,$tx_l,$tx_p) [mpexpr ($high($tx_c,$tx_l,$tx_p) + $low($tx_c,$tx_l,$tx_p))/2.]
                    }
                    notequal {
                        # lower framerate
                        set high($tx_c,$tx_l,$tx_p)           $percentMaxRate($tx_c,$tx_l,$tx_p)
                        set percentMaxRate($tx_c,$tx_l,$tx_p) [mpexpr ($high($tx_c,$tx_l,$tx_p) + $low($tx_c,$tx_l,$tx_p))/2.]
                    }
                }
            }
        }
        
        #iterate over the transmiting ports and creates a list with the streams number
        set allStreams [list]
        foreach txMap $portList {
            scan $txMap "%d %d %d" tx_c tx_l tx_p
            debugMsg "txMap:$txMap"

            set numRxPorts [llength $txRxArray($tx_c,$tx_l,$tx_p)]
            set numStreams [mpexpr $numRxPorts*[bgpSuite cget -numPeers]]

            lappend allStreams $numStreams
        }        
        set refStreams [LCM allStreams]

        $testCmd config -duration $initialDuration

        foreach txMap $portList {
            scan $txMap "%d %d %d" tx_c tx_l tx_p
            debugMsg "txMap:$txMap"

            set numRxPorts [llength $txRxArray($tx_c,$tx_l,$tx_p)]

            set numStreams [mpexpr $numRxPorts*[bgpSuite cget -numPeers]]

            if {[streamUtils::streamGet $tx_c $tx_l $tx_p $numStreams]} {
                errorMsg "Error getting stream [getPortId $tx_c $tx_l $tx_p] $numStreams"
                set retCode $::TCL_ERROR
                continue
            }
    
            # we need to calculate the 'real' percent
            stream config -rateMode           usePercentRate
            stream config -percentPacketRate  $percentMaxRate($tx_c,$tx_l,$tx_p)
            if {[streamUtils::streamSet $tx_c $tx_l $tx_p $numStreams]} {
                errorMsg "Error setting stream [getPortId $tx_c $tx_l $tx_p] $numStreams"
                set retCode $::TCL_ERROR
                continue
            }
            set percentMaxRate($tx_c,$tx_l,$tx_p) [stream cget -percentPacketRate]
            set newFramerate($tx_c,$tx_l,$tx_p)   [streamUtils::getStreamFrameRate $tx_c $tx_l $tx_p]

            debugMsg "*** percentMaxRate($tx_c,$tx_l,$tx_p) = $percentMaxRate($tx_c,$tx_l,$tx_p)  newFramerate($tx_c,$tx_l,$tx_p) = $newFramerate($tx_c,$tx_l,$tx_p)"

            set numframes  [stream cget -numFrames]
            
            
            set ref_loopcount [mpexpr int(1.0 * $newFramerate($tx_c,$tx_l,$tx_p) / $numframes / $refStreams * $initialDuration)]
            set loopcount [expr {$ref_loopcount * ( $refStreams / $numStreams )}]
	    if {$loopcount == 0} {
                set loopcount 1
		set newDuration [mpexpr round(1.0 * $loopcount * $numframes * $numStreams / $newFramerate($tx_c,$tx_l,$tx_p))]
		if {[$testCmd cget -duration] < $newDuration } {
		    $testCmd config -duration $newDuration
		}
	    }
            if {    ($newFramerate($tx_c,$tx_l,$tx_p)   <= $best($tx_c,$tx_l,$tx_p))      || \
                    ($newFramerate($tx_c,$tx_l,$tx_p)   == $framerate($tx_c,$tx_l,$tx_p)) || \
                    ($percentMaxRate($tx_c,$tx_l,$tx_p) >= $high($tx_c,$tx_l,$tx_p))} {
                set tputRateArray($tx_c,$tx_l,$tx_p) $best($tx_c,$tx_l,$tx_p)
                set txActualFrames($tx_c,$tx_l,$tx_p) $bestTxNumFrames($tx_c,$tx_l,$tx_p)
                set rxNumFrames($rx_c,$rx_l,$rx_p) $bestRxNumFrames($rx_c,$rx_l,$rx_p)
                
                set indx [lsearch $doneList [list $tx_c $tx_l $tx_p]]
                if {$indx != -1} {
                    set doneList [lreplace $doneList $indx $indx]
                }
                debugMsg "DONE $tx_c,$tx_l,$tx_p, tputRateArray = $tputRateArray($tx_c,$tx_l,$tx_p)"
                continue
            }

            set framerate($tx_c,$tx_l,$tx_p) $newFramerate($tx_c,$tx_l,$tx_p) 
                     
            set lastStream  0
            set totalNumFrames 0
            #cycle through all the streams & change their gaps
            for {set i 1} {($i <= $numStreams) && (!$lastStream)} {incr i} {
                if {[streamUtils::streamGet $tx_c $tx_l $tx_p $i]} {
                    set lastStream 1
                    continue
                }
                stream config -rateMode          usePercentRate

                stream config -percentPacketRate $percentMaxRate($tx_c,$tx_l,$tx_p)

                stream config -loopCount $loopcount
                stream config -numFrames $numframes

                
                if {[streamUtils::streamSet $tx_c $tx_l $tx_p $i]} {
                    errorMsg "Error setting stream [getPortId $tx_c $tx_l $tx_p] $i"
                    set retCode $::TCL_ERROR
                    continue
                }
            }
            
            set txNumFrames($tx_c,$tx_l,$tx_p)  [mpexpr $loopcount * $numframes * $numStreams]
            debugMsg "txNumFrames($tx_c,$tx_l,$tx_p):$txNumFrames($tx_c,$tx_l,$tx_p), numframes:$numframes , numStreams:$numStreams"

        }
	if {[$testCmd cget -duration] != $initialDuration} {
	    foreach txMap $portList {
		scan $txMap "%d %d %d" tx_c tx_l tx_p

		set numRxPorts [llength $txRxArray($tx_c,$tx_l,$tx_p)]

		set numStreams [mpexpr $numRxPorts*[bgpSuite cget -numPeers]]
    
		if {[streamUtils::streamGet $tx_c $tx_l $tx_p $numStreams]} {
		    errorMsg "Error getting stream [getPortId $tx_c $tx_l $tx_p] $numStreams"
		    set retCode $::TCL_ERROR
		    continue
		}
	
		set newFramerate($tx_c,$tx_l,$tx_p)   [streamUtils::getStreamFrameRate $tx_c $tx_l $tx_p]

		set numframes  [stream cget -numFrames]
            
		set ref_loopcount [mpexpr round(1.0 * $newFramerate($tx_c,$tx_l,$tx_p) / $numframes / $refStreams * [$testCmd cget -duration])]
		set loopcount [expr {$ref_loopcount * ( $refStreams / $numStreams )}]
		stream config -loopCount    $loopcount
		set txNumFrames($tx_c,$tx_l,$tx_p)  [mpexpr $loopcount * $numframes * $numStreams]
                if {[streamUtils::streamSet $tx_c $tx_l $tx_p $numStreams]} {
                    errorMsg "Error setting stream [getPortId $tx_c $tx_l $tx_p] $numStreams"
                    set retCode $::TCL_ERROR
                    continue
                }
	    }
	}

        if {[llength $doneList] > 0} {
            bgpPerformance::countTxRxFrames txRxArray txNumFrames txRxFrames
            if { [writeConfigToHardware txRxArray -noProtocolServer] } {
                errorMsg "Error witting the configuration to the hardware"
                set retCode $::TCL_ERROR
            }

            debugMsg "framerate: [array get framerate]"
            debugMsg "txNumFrames: [array get txNumFrames]"
            debugMsg "txRxFrames: [array get txRxFrames]"
        }

        incr iteration
        protocol config -enable802dot1qTag $enable802dot1qTag 
   }

   copyPortList txActualFrames txNumFrames 

    return $retCode
}

########################################################################
# Procedure: bgpPerformance::countTxRxFrames
#
# This command returns an array w/containing total frames transmitted 
# to each rx port
#
# Argument(s):
#       RxTxArray      -list of ports, ie, one2oneArray, one2manyArray etc
#       TxNumFrames    -array of frames to transmit from tx ports
#       TxRxNumFrames  -array of total frames transmitted to this rx port
#
########################################################################
proc bgpPerformance::countTxRxFrames {TxRxArray TxNumFrames TxRxNumFrames} {
    upvar $TxRxArray        txRxArray
    upvar $TxNumFrames      txNumFrames
    upvar $TxRxNumFrames    txRxNumFrames

    set status $::TCL_OK

    if [info exists txRxNumFrames] {
        unset txRxNumFrames
    }

    foreach txMap [array names txRxArray] {
        scan $txMap "%d,%d,%d" tx_c tx_l tx_p

        set numRxPorts  [llength $txRxArray($tx_c,$tx_l,$tx_p)]
        set numStreams  [mpexpr $numRxPorts*[bgpSuite cget -numPeers]]

        if {[port isActiveFeature $tx_c $tx_l $tx_p $::portFeatureAtm]} {
            if {[streamQueue get $tx_c $tx_l $tx_p 1]} {
                errorMsg "Error getting streamQueue on [getPortId $tx_c $tx_l $tx_p] for queue 1"
                set retCode 1
            }
        } else {
            if [stream get $tx_c $tx_l $tx_p $numStreams] {
                errorMsg "Error getting stream $numStreams from port [getPortId $tx_c $tx_l $tx_p]"
                set retCode 1
            }
        }

        set loopcount   [stream cget -loopCount]
        set streamID 1

        foreach rxMap $txRxArray($tx_c,$tx_l,$tx_p) {
            scan [join $rxMap] "%d %d %d" rx_c rx_l rx_p

            for {set count 1} {$count <= [bgpSuite cget -numPeers] } {incr count} {
                if {[port isActiveFeature $tx_c $tx_l $tx_p $::portFeatureAtm]} {
                    if {[streamQueue get $tx_c $tx_l $tx_p 1]} {
                        errorMsg "Error getting streamQueue on [getPortId $tx_c $tx_l $tx_p] for queue 1"
                        set retCode 1
                    }
                } else {
                    if [stream get $tx_c $tx_l $tx_p $streamID] {
                        errorMsg "Error getting stream $streamID from port [getPortId $tx_c $tx_l $tx_p]"
                        set retCode 1
                    }
                }

                incr streamID
                set numFrames   [stream cget -numFrames]
                if {[info exists txRxNumFrames($rx_c,$rx_l,$rx_p)]} {
                    set txRxNumFrames($rx_c,$rx_l,$rx_p)  [mpexpr $txRxNumFrames($rx_c,$rx_l,$rx_p)+($loopcount*$numFrames)]
                } else {
                    set txRxNumFrames($rx_c,$rx_l,$rx_p)  [mpexpr $loopcount*$numFrames]
                }

            }
        }

    }
    return $status
}



