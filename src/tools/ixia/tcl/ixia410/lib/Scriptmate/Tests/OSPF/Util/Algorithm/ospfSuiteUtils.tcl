#############################################################################################
#
#   Copyright © 1997 - 2004 by IXIA.
#   All Rights Reserved.
#
# Description:
#
#############################################################################################

########################################################################################
# Procedure: ospfSuite::registerResultVars
#
# Description: This command registers all the local variables that are used in the
# display of the results with the Results Options Database.  This procedure must exist
# for each test.
#
# Argument(s):
# Returned result:
########################################################################################

proc ospfSuite::registerResultVars {} \
{
    if [ results addOptionToDB totalPacketLoss          "TotalPacketLoss(Actual + MisDirected)"  12  12   iter   ] { return 1 } 
    if [ results addOptionToDB convergenceMetric        "ConvergenceMetric(seconds)"             12  12   iter   ] { return 1 } 
    if [ results addOptionToDB totalRoutes              "MaxRoutesVerified"                      12  12   iter   ] { return 1 }
    if [ results addOptionToDB tolerance                "Tolerance(%)    "                       12  12   iter   ] { return 1 }
    if [ results addOptionToDB actualPacketLoss         "ActualPacketLoss"                       12  12   iter   ] { return 1 }
    if [ results addOptionToDB convergencePerWithdraw   "ConvergenceMetricPerWithdrawal(sec)"    12  12   iter   ] { return 1 }
    if [ results addOptionToDB numWithdraw              "Number of Withdrawals"                  12  12   iter   ] { return 1 }
    if [ results addOptionToDB numberOfRoutes           "NumberOfRoutes  "                       12  12   iter   ] { return 1 }
    if [ results addOptionToDB packetRate               "PacketRate (PPS)"                       12  12   iter   ] { return 1 }
    if [ results addOptionToDB routeStep                "RouteStep       "                       12  12   iter   ] { return 1 }
    if [ results addOptionToDB misDirectedPackets       "MisDirectedPackets"                     12  12   iter   ] { return 1 }
    if [ results addOptionToDB txDurationPerFlap        "Tx Duration Per Flap (sec)"             12  12   iter   ] { return 1 }
                                                        
    # configuration information stored for results      
    if [ results registerTestVars testName              testName            [ospfSuite cget -testName]  test ] { return 1 }
    if [ results registerTestVars protocol              protocolName        [string toupper [getProtocolName [protocol cget -name]]] \
                                                                                    test ] { return 1 }
    if [ results registerTestVars chassisName           chassisName         [chassis cget -name]            test ] { return 1 }
    if [ results registerTestVars chassisID             chassisID           [chassis cget -id]              test ] { return 1 }
    if [ results registerTestVars productName           productName         [user cget -productname]        test ] { return 1 }
    if [ results registerTestVars versionNumber         versionNumber       [user cget -version]            test ] { return 1 }
    if [ results registerTestVars serialNumber          serialNumber        [user cget -serial#]            test ] { return 1 }
    if [ results registerTestVars userName              userName            [user cget -username]           test ] { return 1 }
    if [ results registerTestVars percentMaxRate        percentMaxRate      [ospfSuite cget -percentMaxRate] test ] { return 1 }
    if [ results registerTestVars numTrials             numTrials           [ospfSuite cget -numtrials]      test ] { return 1 }
    if [ results registerTestVars duration              duration            [ospfSuite cget -duration]       test ] { return 1 }
                                                        
    # results obtained after each iteration             
    if [ results registerTestVars transmitFrames        txActualFrames      0                               port TX ] { return 1 }
    if [ results registerTestVars receiveFrames         rxNumFrames         0                               port RX ] { return 1 }
    if [ results registerTestVars totalTxFrames         totalTxNumFrames    0                               iter    ] { return 1 }     
    if [ results registerTestVars totalRxFrames         totalRxNumFrames    0                               iter    ] { return 1 }
    if [ results registerTestVars percentLoss           totalLoss           0                               iter    ] { return 1 }
    if [ results registerTestVars totalPacketLoss       totalPacketLoss     0                               iter    ] { return 1 }
    if [ results registerTestVars convergenceMetric     convergenceMetric   0                               iter    ] { return 1 }
    if [ results registerTestVars totalRoutes           totalRoutes         0                               iter    ] { return 1 }
    if [ results registerTestVars tolerance             tolerance           0                               iter    ] { return 1 }
    if [ results registerTestVars actualPacketLoss      actualPacketLoss    0                               iter    ] { return 1 }
    if [ results registerTestVars convergencePerWithdraw convergencePerWithdraw  0                          iter    ] { return 1 }
    if [ results registerTestVars numWithdraw           numWithdraw         0                               iter    ] { return 1 }
    if [ results registerTestVars numberOfRoutes        numberOfRoutes      0                               iter    ] { return 1 }
    if [ results registerTestVars packetRate            packetRate          0                               iter    ] { return 1 }
    if [ results registerTestVars routeStep             routeStep           0                               iter    ] { return 1 }
    if [ results registerTestVars misDirectedPackets    misDirectedPackets  0                               iter    ] { return 1 }
    if [ results registerTestVars txDurationPerFlap     txDurationPerFlap   0                               iter    ] { return 1 }

    return 0
}


########################################################################################
# Procedure: ospfSuite::show
#
# Description: This command is called when the user enters: ospfSuite show
# Displays currently configured parameters.
########################################################################################
proc ospfSuite::show {args} \
{
    logMsg "\nospfSuite command parameters"
    logMsg "====================================="
    showCmd ospfSuite
}


########################################################################################
# Procedure: configureOspf
#
# Description: This command added a routeRange to the router.
#
# Argument(s):
# TxRxArray       - map, ie. one2oneArray
# enable          - enabling the route item and interface item
# write           - flag to commit or not commit the changes
# testCmd         - name of test command, ie. tput
#
# Results :       0 : No error found
#                 1 : Error found
#         
########################################################################################
proc configureOspf {TxRxArray {write nowrite} {enableConnectDut true} {enableRouteRange true} {testCmd ospfSuite}} \
{   

    upvar $TxRxArray    txRxArray

    set retCode 0

    set rxPortList      [getRxPorts txRxArray]

    logMsg "Configuring OSPF ..."
    foreach rxPort $rxPortList {
        scan $rxPort "%d %d %d" tx_c tx_l tx_p

        initializeOspf $tx_c $tx_l $tx_p
      
        if [ip get $tx_c $tx_l $tx_p] {
            errorMsg "Error getting ip on port [getPortId $tx_c $tx_l $tx_p]"
            set retCode 1
        }
        cleanUpOspfGlobals
        if {[addRouteItem $enableRouteRange]} {
            errorMsg "*** Error Adding routeItem for routeRange"
            set retCode 1
        }
        ospfInterface config -protocolInterfaceDescription [interfaceTable::formatEntryDescription $tx_c $tx_l $tx_p]
        if {[addInterfaceItem $enableConnectDut]} {
            errorMsg "*** Error Adding routeItem for routeRange"
            set retCode 1
        } 
                                           
        ospfRouter  config  -routerId  $tx_l.$tx_p.0.0
        ospfRouter  config  -enable     1
        
        set routerName   router[getNextRouter]
                                              
        if [ospfServer addRouter $routerName] {
            errorMsg "Error in adding router $routerName"
            set $retCode 1
        }

        if {$write == "write"} {
            if [ospfServer write] {
                errorMsg "*** Error writing ospfServer"
                set retCode 1
            }
        }
    }

    return $retCode
}



#################################################################################
# Procedure: generateOspfStreams
#
# Description: This command generate ospf streams test the stream for ospf
#               
#
#################################################################################
proc generateOspfStreams {TxRxArray {testCmd ospfSuite} } \
{
    upvar $TxRxArray    txRxArray

    set retCode 0

    #We can use this proc both for capacity and convergence test because in convergence test 
    foreach txPort [getTxPorts txRxArray] {
        scan $txPort "%d %d %d" tx_c tx_l tx_p

        foreach rxPort [getRxPorts txRxArray] {
            scan $rxPort "%d %d %d" rx_c rx_l rx_p
            if [ospfServer select $rx_c $rx_l $rx_p] {
                errorMsg "Error in selecting ospf server on port $rx_c $rx_l $rx_p"
                set retCode 1
            } 
            if [ospfServer generateStreams $tx_c $tx_l $tx_p] {
                errorMsg "Error in generating streams for capacity test on port $tx_c $tx_l $tx_p" 
                set retCode 1
            }
        }
    }
    return $retCode
}

#################################################################################
# Procedure: writeOspfStreams
#
# Description: This command configures and writes the stream for ospf
#               
#
#################################################################################
proc writeOspfStreams {TxRxArray {TxNumFrames ""} {numFrames 0} {testCmd ospfSuite}} \
{
    upvar $TxRxArray    txRxArray
    upvar $TxNumFrames  txNumFrames

    set retCode 0

    if [generateOspfStreams  txRxArray] {
        logMsg "Error in genrating streams"
        set retCode 1
    }
    
    # Setup filters on receive port to count our test packets
    filterPallette setDefault

    filter setDefault
    filter config -userDefinedStat2Enable   true
    filter config -userDefinedStat2Pattern  pattern2    ;# this will measure the flap routes

    packetGroup setDefault
    packetGroup config -insertSignature true
    packetGroup config -signatureOffset 48

    foreach txPort [getTxPorts txRxArray] {
        scan $txPort "%d %d %d" tx_c tx_l tx_p

        set streamID    1
        set txNumFrames($tx_c,$tx_l,$tx_p)   0
        
        #Get the stream which you generated before by using ospfServer
        if [stream get $tx_c $tx_l $tx_p $streamID] {
            errorMsg "stream  $tx_c $tx_l $tx_p $streamID not configured yet!"
            set retCode 1
        }
        #Configure the parameters which were not set in generate stream

        stream config -daRepeatCounter   daArp
        stream config -framesize         [$testCmd cget -framesize]
        stream config -enableTimestamp   true

        stream config -enableIbg         false
        stream config -enableIsg         false

        stream config -rateMode          usePercentRate
        stream config -percentPacketRate [$testCmd cget -percentMaxRate]
        stream config -gapUnit           gapNanoSeconds
        
        # get the mac & Ip addresses for the sa ( da will be set from arp table in generate stream)
        if [port get $tx_c $tx_l $tx_p] {
            errorMsg "Port [getPortId $tx_c $tx_l $tx_p] not configured yet!"
            set retCode 1
        }
        stream config -sa   [port cget -MacAddress]

        ##### Stream for generating traffic to the routes #####
        stream config -name         "Tx->[$testCmd cget -networkIpAddress]"

        if { $numFrames == 0 } {
           stream config -numFrames    [$testCmd cget -numberOfRoutes]
        } else {
            stream config -numFrames    $numFrames
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
            #Calculate new duration
            set newDuration [format "%.0f" [mpexpr ceil (double ([stream cget -numFrames])/$framerate * $loopCount)]]
            if { $newDuration != [$testCmd cget -duration] } {
                $testCmd config -duration $newDuration
                logMsg "The configured duration was changed to $newDuration."
            }
            
            set txNumFrames($tx_c,$tx_l,$tx_p) [mpexpr $loopCount* [stream cget -numFrames]]

        } else {
            set transmitDuration  [format "%.0f" [mpexpr ceil (double ([stream cget -numFrames])/$framerate)]]    
            ospfSuite config -duration  $transmitDuration
            set txNumFrames($tx_c,$tx_l,$tx_p) [stream cget -numFrames]
          }   
        stream config -loopCount    $loopCount
        if [stream set $tx_c $tx_l $tx_p $streamID] {
            errorMsg "Error setting stream $streamID for network on port [getPortId $tx_c $tx_l $tx_p]"
            set retCode 1
        }

        # config packet group signature for UDF 1, Network
        scan [$testCmd cget -networkIpAddress] "%d.%d.%d.%d" a b c d
        packetGroup config -signature       [format "%02x %02x %02x %02x" $a $b $c $d]

        if [packetGroup setTx $tx_c $tx_l $tx_p $streamID] {
            errorMsg "Error setting TX packet group for stable network on port [getPortId $tx_c $tx_l $tx_p]"
            set retCode 1
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
# Procedure: setEnableRouteRange
#
# Description: This command enables/disables the routeRange with routeRangeId on a 
#              router with routerId
#               
# portId            - the port id
# enable            - used to enable or disable, true/false
# routerId          - name or Id of the router
# routeRangeId      - name or Id of the route range              
#
#################################################################################
proc setEnableRouteRange {portId enable routerId {routeRangeId 1} {write write}} \
{
    set retCode 0

    scan $portId "%d %d %d" chassis card port

    if [ospfServer select $chassis $card $port] {
        errorMsg "Error in selecting port $chassis $card $port"
        set $retCode 1
    }
 
    if [ospfServer getRouter router$routerId] {
        errorMsg "Error in getting the router router$routerId"
        set $retCode 1
    }

    if [ospfRouter getRouteRange routeRange$routeRangeId] {
        errorMsg "Error in getting the routeRange$routeRangeId"
        set $retCode 1
    }

    ospfRouteRange config -enable $enable

    if [ospfRouter setRouteRange routeRange$routeRangeId] {
        errorMsg "Error in adding routeRange$routeRangeId"
        set $retCode 1
    }   
   
    if {$retCode == 0 && $write == "write"} {
        if [ospfServer write] {
            errorMsg "Error in writing ospf configuration"
            set $retCode 1
        }    
    }         
   
    return $retCode
}


#################################################################################
# Procedure: setEnableInterface
#
# Description: This command enables/disables the interface with interfaceId on a 
#              router with routerId
#               
# portId            - the port id
# enable            - used to enable or disable, true/false
# routerId          - name or Id of the router
# interfaceId       - name or Id of the interface
#
#################################################################################
proc setEnableInterface {portId enable routerId {interfaceId 1} {write nowrite} } \
{
    set retCode 0

    scan $portId "%d %d %d" chassis card port

    if [ospfServer select $chassis $card $port] {
        errorMsg "Error in selecting port $chassis $card $port"
        set $retCode 1
    }
 
    if [ospfServer getRouter router$routerId] {
        errorMsg "Error in getting the router router$routerId"
        set $retCode 1
    }

    if [ospfRouter getInterface interface$interfaceId] {
        errorMsg "Error in getting the interface$interfaceId"
        set $retCode 1
    }

    ospfInterface config -enable $enable

    if [ospfRouter setInterface interface$interfaceId] {
        errorMsg "Error in adding interface$interfaceId"
        set $retCode 1
    }   
   
    if {$retCode == 0 && $write == "write"} {
        if [ospfServer write] {
            errorMsg "Error in writing ospf configuration"
            set $retCode 1
        }    
    }         
   
    return $retCode
}

#################################################################################
# Procedure: setEnableOspfV3LsaGroup
#
# Description: This command enables/disables the OSPFV3 First LSA Group with  
#              on the first router.
#               
# portId            - the port id
# enable            - used to enable or disable, true/false
# routerId          - name or Id of the router
# routeRangeId      - name or Id of the route range              
#
#################################################################################
proc ospfSuite::setEnableOspfV3LsaGroup {portId enable {write nowrite}} \
{
    set retCode 0

    scan $portId "%d %d %d" chassis card port

    if [ospfV3Server select $chassis $card $port] {
        errorMsg "Error in selecting port $chassis $card $port"
        set $retCode 1
    }
 
    if [ospfV3Server getFirstRouter] {
        errorMsg "Error in getting first router."
        set $retCode 1
    }

    if [ospfV3Router getFirstUserLsaGroup] {
        errorMsg "Error in getting first user Lsa group."
        set $retCode 1
    }

    ospfV3UserLsaGroup config -enable $enable

    if [ospfV3Router setUserLsaGroup] {
        errorMsg "Error in setting user LSA group"
        set $retCode 1
    }   

    if {$retCode == 0 && $write == "write"} {
        if [ospfV3Server write] {
            errorMsg "Error in writing ospfV3 configuration"
            set $retCode 1
        }
    }         
   
    return $retCode
}

#################################################################################
# Procedure: setEnableOspfV3RouteRange
#
# Description: This command enables/disables the ospfV3 routeRange with routeRangeId on a 
#              router with routerId
#               
# portId            - the port id
# enable            - used to enable or disable, true/false
# routerId          - name or Id of the router
# routeRangeId      - name or Id of the route range              
#
#################################################################################
proc ospfSuite::setEnableOspfV3RouteRange {portId enable routerId {routeRangeId 1} {write nowrite}} \
{
    set retCode 0

    scan $portId "%d %d %d" chassis card port

    if [ospfV3Server select $chassis $card $port] {
        errorMsg "Error in selecting port $chassis $card $port"
        set $retCode 1
    }
 
    if [ospfV3Server getRouter router$routerId] {
        errorMsg "Error in getting the router router$routerId"
        set $retCode 1
    }

    if [ospfV3Router getRouteRange routeRange$routeRangeId] {
        errorMsg "Error in getting the routeRange$routeRangeId"
        set $retCode 1
    }

    ospfV3RouteRange config -enable $enable

    if [ospfV3Router setRouteRange routeRange$routeRangeId] {
        errorMsg "Error in setting routeRange$routeRangeId"
        set $retCode 1
    }   
   
    if {$retCode == 0 && $write == "write"} {
        if [ospfV3Server write] {
            errorMsg "Error in writing ospfV3 configuration"
            set $retCode 1
        }
    }        
   
    return $retCode
}

#################################################################################
# Procedure: setEnableOspfV2NetworkRange
#
# Description: This command enables/disables the interface with interfaceId on a 
#              router with routerId
#               
# portId            - the port id
# enable            - used to enable or disable, true/false
# routerId          - name or Id of the router
# interfaceId       - name or Id of the interface
#
#################################################################################
proc ospfSuite::setEnableOspfV2NetworkRange {portId enable routerId {interfaceId 1} {write nowrite} } \
{
    set retCode 0

    scan $portId "%d %d %d" chassis card port

    if [ospfServer select $chassis $card $port] {
        errorMsg "Error in selecting port $chassis $card $port"
        set $retCode 1
    }
 
    if [ospfServer getRouter router$routerId] {
        errorMsg "Error in getting the router router$routerId"
        set $retCode 1
    }

    if [ospfRouter getInterface interface$interfaceId] {
        errorMsg "Error in getting the interface$interfaceId"
        set $retCode 1
    }

    ospfInterface config -enable $enable
    ospfInterface config -enableAdvertiseNetworkRange $enable

    if [ospfRouter setInterface interface$interfaceId] {
        errorMsg "Error in setting interface$interfaceId"
        set $retCode 1
    } 
    if {$retCode == 0 && $write == "write"} {
        if [ospfServer write] {
            errorMsg "Error in writing ospf configuration"
            set $retCode 1
        }    
    }         
   
    return $retCode
}

#################################################################################
# Procedure: ospfSuite::SetIpV4Mask
#
# Description: This command sets ospf interface ip mask for interface Table.
#               
#
#################################################################################
proc ospfSuite::setIpV4Mask {TxRxArray } \
{
    upvar $TxRxArray    txRxArray

	set retCode 0
	set ospfPorts    [getRxPorts txRxArray]

	foreach rxPort $ospfPorts {
		scan $rxPort "%d %d %d" c l p
		if [ip get $c $l $p] {
            errorMsg "Error getting ip on port [getPortId $c $l $p]"
            set retCode 1
        }

		ip config  -sourceIpMask  [ospfSuite cget -interfaceIpMask]

		if [ip set $c $l $p] {
            errorMsg "Error setting ip on port [getPortId $c $l $p]"
            set retCode 1
        }
	}	

	if {[interfaceTable::configure ospfPorts $::ipV4]} {
		return $::TCL_ERROR
	}

	return $retCode
}

########################################################################################
# Procedure: configureOspfProtocols
#
# Description: This command Configures OSPF vrsion2/version3 for convergence test.
#
# Argument(s):
# TxRxArray       - map, ie. one2oneArray
# write           - flag to commit or not commit the changes
#
# Results :       0 : No error found
#                 1 : Error found
#         
########################################################################################
proc ospfSuite::configureOspfProtocols {TxRxArray {write nowrite}} \
{   
    upvar $TxRxArray    txRxArray
    set retCode 0

    set rxPortList      [getRxPorts txRxArray]

    if {[ospfSuite cget -enableOspfV2] == "true"} {
        if {[configureOspfV2  $rxPortList $write]} {
            set retCode 1
        }
    } 

    if {[ospfSuite cget -enableOspfV3] == "true"} {
        if {[configureOspfV3  $rxPortList $write]} {
            set retCode 1
        }  
    }

    return $retCode
}

#  EM. NOTE: configureOspf can be replaced with configureOspfV2. 

########################################################################################
# Procedure: configureOspfV2
#
# Description: This command configures OSPF version 2.
#
# Argument(s):
# portList        
# write           - flag to commit or not commit the changes
#
# Results :       0 : No error found
#                 1 : Error found
#         
########################################################################################
proc ospfSuite::configureOspfV2 {portList {write nowrite} } \
{   
    set retCode 0
    logMsg "Configuring OSPF Version 2..."
    set index 0

    foreach rxPort $portList {
        scan $rxPort "%d %d %d" c l p
        initializeOspf $c $l $p
        cleanUpOspfGlobals
        
        if [ip get $c $l $p] {
            errorMsg "Error getting ip on port [getPortId $c $l $p]"
            set retCode 1
        }

        ospfInterface setDefault
        ospfInterface config -protocolInterfaceDescription [interfaceTable::formatEntryDescription $c $l $p]

        ospfInterface config -metric    [expr 20 * ([lsearch $portList $rxPort]+1)]	

        if {[addInterfaceItem true]} {
            errorMsg "*** Error Adding connected interface."
            set retCode 1
        } 
        if {[ospfSuite cget -enableOspfV2RouterLsa] == "true"} {
            
            ospfNetworkRange config -firstRouterId          [ospfSuite cget -ospfV2RouterLsaRouterId]
            ospfNetworkRange config -firstSubnetIpAddress   [ospfSuite cget -ospfV2RouterLsaSubnet]
            
           # set numRows [expr [ospfSuite cget -numOspfV2RouterLsa]/2]
	   # Number of subnets in a network range is (2*numRows*numColumns)-numRows-numColumns
	   # Number of routers in a network range is numRows*numColumns
	   # Number of LSAs in a network range is numSubnets+numRouters
	   # Considering numColumns 2, numRows is (numLSAs+ 2)/5
	    set numRows [expr round(([ospfSuite cget -numOspfV2RouterLsa]+2)/5)]
            if { $numRows == 0} {
                set numRows 1
            }
            ospfNetworkRange config -numRows     $numRows
            ospfNetworkRange config -numColumns  2
            
            ospfInterface config -enableAdvertiseNetworkRange  true

            if {[addInterfaceItem false]} {
                errorMsg "*** Error Adding unconnected interface with network range."
                set retCode 1
            } 
        }
        set enableRouteRange true
        if {[ospfSuite cget -enableOspfV2SummaryLsa] == "true"} {
            if {[addRouteItem  $enableRouteRange ospfSuite ospfRouteOriginArea]} {
                errorMsg "*** Error Adding routeItem for routeRange"
                set retCode 1
            }
        }
        
        if {[ospfSuite cget -enableOspfV2ExternalLsa] == "true"} {
            if {[addRouteItem $enableRouteRange ospfSuite ospfRouteOriginExternal]} {
                errorMsg "*** Error Adding routeItem for routeRange route origin ospfRouteOriginExternal"
                set retCode 1
            }
        }
                                          
        ospfRouter  config  -routerId  $l.$p.0.0
        ospfRouter  config  -enable     1
        ospfRouter  config  -enableDiscardLearnedLsas true
        
        set routerName   router[getNextRouter]
                                              
        if [ospfServer addRouter $routerName] {
            errorMsg "Error in adding router $routerName"
            set $retCode 1
        }

        if {$write == "write"} {
            if [ospfServer write] {
                errorMsg "*** Error writing ospfServer"
                set retCode 1
            }
        }
        incr index
    }

    return $retCode
}


########################################################################################
# Procedure: configureOspfV3
#
# Description: This command configures OSPF version 3.
#
# Argument(s):
# portList        
# write           - flag to commit or not commit the changes
#
# Results :       0 : No error found
#                 1 : Error found
#         
########################################################################################
proc ospfSuite::configureOspfV3 {portList {write nowrite} } \
{   
    set retCode 0

    logMsg "Configuring OSPF Version 3..."
    set index 0

    foreach rxPort $portList {
        scan $rxPort "%d %d %d" c l p
        initializeOspfV3 $c $l $p
        cleanUpOspfGlobals
        
        ospfV3Interface config -protocolInterfaceDescription [interfaceTable::formatEntryDescription $c $l $p]
        if {[addOspfV3InterfaceItem]} {
            errorMsg "*** Error Adding connected interface."
            set retCode 1
        } 
        
        if {[ospfSuite cget -enableOspfV3InterAreaPrefixLsa] == "true"} {
            if {[addOspfV3RouteItem  ospfV3RouteOriginAnotherArea]} {
                errorMsg "*** Error Adding routeItem for routeRange, route origin ospfV3RouteOriginAnotherArea."
                set retCode 1
            }
        }
        
        if {[ospfSuite cget -enableOspfV3ExternalLsa] == "true"} {
            if {[addOspfV3RouteItem ospfV3RouteOriginExternalType1]} {
                errorMsg "*** Error Adding routeItem for routeRange, route origin ospfRouteOriginExternal."
                set retCode 1
            }
        }
                                          
        ospfV3Router  config  -routerId  $l.$p.0.0
        ospfV3Router  config  -enable     1
        ospfV3Router  config  -enableDiscardLearnedLsas         true

        
        set routerName   router[getNextRouter]
                                              
        if [ospfV3Server addRouter $routerName] {
            errorMsg "Error in adding ospfV3 router $routerName"
            set $retCode 1
        }

        if {[ospfSuite cget -enableOspfV3RouterLsa] == "true"} {
            
            if [ospfV3Server getRouter $routerName] {
                errorMsg "Error in getting ospfV3 router $routerName"
                set $retCode 1
            }

            
            ospfV3NetworkRange config -firstRouterId          [ospfSuite cget -ospfV3RouterLsaRouterId]
            ospfV3NetworkRange config -firstSubnetIpAddress   [ospfSuite cget -ospfV3RouterLsaSubnet]
            
            #set numRows [expr round([ospfSuite cget -numOspfV3RouterLsa]/2.0)]
	    # Number of subnets in a network range is (2*numRows*numColumns)-numRows-numColumns
	    # Number of routers in a network range is numRows*numColumns
	    # Number of LSAs in a network range is numSubnets+numRouters
	    # Considering numColumns 2, numRows is (numLSAs+ 2)/5
	    set numRows [expr round(([ospfSuite cget -numOspfV2RouterLsa]+2)/5)]
	    if { $numRows == 0} {
                set numRows 1
            }
            
            #Bug in ixTclHal. Remove it for the next release.
            ospfServer select $c $l $p
            #
            ospfV3NetworkRange config -numRows              $numRows
            ospfV3NetworkRange config -numColumns           2
            ospfV3NetworkRange config -entryPointMetric     [expr ($index+1) * 10]
            
            if {[ospfV3Router generateGridGroupLsa 1 [ospfSuite cget -areaId]]} {
                errorMsg "Error in generating user LSAs for Grid."
                set $retCode 1
            }

            if [ospfV3Server setRouter $routerName] {
                errorMsg "Error in setting ospfV3 router $routerName"
                set $retCode 1
            }
            if {[enableEBitBBit $c $l $p]} {
                errorMsg "Error in enableEBitBBit."
                set $retCode 1
            }   
        }

        if {$write == "write"} {
            if [ospfV3Server write] {
                errorMsg "*** Error writing ospfV3Server"
                set retCode 1
            }
        }
        incr index
    }

    return $retCode
}


########################################################################################
# Procedure: performFlap
#
# Description: This command performs the flap.
#
# Argument(s):
# portList        
# write           - flag to commit or not commit the changes
#
# Results :       0 : No error found
#                 1 : Error found
#         
########################################################################################
proc ospfSuite::performFlap {portList enableFlap {write nowrite} } \
{   
    set retCode 0

    set routerId      1
    foreach portItem $portList {
        if {[ospfSuite cget -enableOspfV2] == "true"} {
            set routeRangeId  1
            
            if {[ospfSuite cget -enableOspfV2SummaryLsa] == "true"} {
                if {[ospfSuite cget -flapOspfV2SummaryLsa] == "true"} {
                    if [setEnableRouteRange  $portItem $enableFlap $routerId $routeRangeId nowrite] {
                        errorMsg "Could not flap."
                        set $retCode 1
                    }
                }
                incr routeRangeId
            }

            if {[ospfSuite cget -enableOspfV2RouterLsa] == "true" && [ospfSuite cget -flapOspfV2RouterLsa] == "true"} {
                if [setEnableOspfV2NetworkRange  $portItem $enableFlap $routerId 2] {
                    errorMsg "Could not flap."
                    set $retCode 1
                }
            }

            if {[ospfSuite cget -enableOspfV2ExternalLsa] == "true" && [ospfSuite cget -flapOspfV2ExternalLsa] == "true"} {
                if [setEnableRouteRange  $portItem $enableFlap $routerId $routeRangeId] {
                    errorMsg "Could not flap."
                    set $retCode 1
                }
            }

            if {$write == "write"} {
                if [ospfServer write] {
                    errorMsg "*** Error writing ospfV2Server"
                    set retCode 1
                }
            }
        }

        if {[ospfSuite cget -enableOspfV3] == "true"} {
            set routeRangeId  1
            if {[ospfSuite cget -enableOspfV3RouterLsa] == "true" && [ospfSuite cget -flapOspfV3RouterLsa] == "true"} {
                if [setEnableOspfV3LsaGroup  $portItem $enableFlap] {
                    errorMsg "Could not flap."
                    set $retCode 1
                }
            }
            if {[ospfSuite cget -enableOspfV3InterAreaPrefixLsa] == "true"} {
                if {[ospfSuite cget -flapOspfV3InterAreaPrefixLsa] == "true"} {
                    if [setEnableOspfV3RouteRange  $portItem $enableFlap $routerId $routeRangeId] {
                        errorMsg "Could not flap."
                        set $retCode 1
                    }
                }
                incr routeRangeId
            }

            if {[ospfSuite cget -enableOspfV3ExternalLsa] == "true" && [ospfSuite cget -flapOspfV3ExternalLsa] == "true"} {
                if [setEnableOspfV3RouteRange  $portItem $enableFlap $routerId $routeRangeId] {
                    errorMsg "Could not flap."
                    set $retCode 1
                }
            }

            if {$write == "write"} {
                if [ospfV3Server write] {
                    errorMsg "*** Error writing ospfV3Server"
                    set retCode 1
                }
            }
        }
    }

    return $retCode 
}


########################################################################################
# Procedure: getTotalLsas
#
# Description: This command calculate sum of advertised LSAs
#
# Argument(s):
#
# Results :      totalLsas
#         
########################################################################################
proc ospfSuite::getTotalLsas {} \
{   
    set totalLsas 0

    if {[ospfSuite cget -enableOspfV2] == "true"} {
        if {[ospfSuite cget -enableOspfV2SummaryLsa] == "true"} {
            mpincr totalLsas [ospfSuite cget -numberOfRoutes]
        }

        if {[ospfSuite cget -enableOspfV2RouterLsa] == "true" } {
            mpincr totalLsas [ospfSuite cget -numOspfV2RouterLsa]
        }

        if {[ospfSuite cget -enableOspfV2ExternalLsa] == "true" } {
            mpincr totalLsas [ospfSuite cget -numOspfV2ExternalLsa]
        }
    }

    if {[ospfSuite cget -enableOspfV3] == "true"} {
        if {[ospfSuite cget -enableOspfV3RouterLsa] == "true" } {
            mpincr totalLsas [ospfSuite cget -numOspfV3RouterLsa]
        }

        if {[ospfSuite cget -enableOspfV3ExternalLsa] == "true" } {
            mpincr totalLsas [ospfSuite cget -numOspfV3ExternalLsa]
        }

        if {[ospfSuite cget -enableOspfV3InterAreaPrefixLsa] == "true" } {
            mpincr totalLsas [ospfSuite cget -numOspfV3InterAreaPrefixLsa]
        }
    }
    return $totalLsas
}

proc ospfSuite::getTotalWithdrawnLsas {} \
{   
    set totalLsas 0

    if {[ospfSuite cget -enableOspfV2] == "true"} {
        if {[ospfSuite cget -flapOspfV2RouterLsa] == "true" && \
            [ospfSuite cget -enableOspfV2RouterLsa] == "true" } {
                mpincr totalLsas [ospfSuite cget -numOspfV2RouterLsa] 
        }

        if {[ospfSuite cget -flapOspfV2SummaryLsa] == "true" && \
            [ospfSuite cget -enableOspfV2SummaryLsa] == "true" } {
                mpincr totalLsas [ospfSuite cget -numberOfRoutes]
        }

        if {[ospfSuite cget -flapOspfV2ExternalLsa] == "true" && \
            [ospfSuite cget -enableOspfV2ExternalLsa] == "true" } {
                mpincr totalLsas [ospfSuite cget -numOspfV2ExternalLsa]
        }

    }
        
    if {[ospfSuite cget -enableOspfV3] == "true"} {
        if {[ospfSuite cget -flapOspfV3RouterLsa] == "true" && \
            [ospfSuite cget -enableOspfV3RouterLsa] == "true" } {
                mpincr totalLsas [ospfSuite cget -numOspfV3RouterLsa] 
        }

        if {[ospfSuite cget -flapOspfV3InterAreaPrefixLsa] == "true" && \
            [ospfSuite cget -enableOspfV3InterAreaPrefixLsa] == "true" } {
                mpincr totalLsas [ospfSuite cget -numOspfV3InterAreaPrefixLsa] 
        }

        if {[ospfSuite cget -flapOspfV3ExternalLsa] == "true" && \
            [ospfSuite cget -enableOspfV3ExternalLsa] == "true" } {
                mpincr totalLsas [ospfSuite cget -numOspfV3ExternalLsa] 
        }

    }

    return $totalLsas
}


proc ospfSuite::getNumberOfWithdrawnLsaGroups  {} \
{   
    set totalLsas 0

    if {[ospfSuite cget -enableOspfV2] == "true"} {
        if {[ospfSuite cget -flapOspfV2RouterLsa] == "true" && \
            [ospfSuite cget -enableOspfV2RouterLsa] == "true" } {
                incr totalLsas 
        }

        if {[ospfSuite cget -flapOspfV2SummaryLsa] == "true" && \
            [ospfSuite cget -enableOspfV2SummaryLsa] == "true" } {
                incr totalLsas 
        }

        if {[ospfSuite cget -flapOspfV2ExternalLsa] == "true" && \
            [ospfSuite cget -enableOspfV2ExternalLsa] == "true" } {
                incr totalLsas 
        }

    }
        
    if {[ospfSuite cget -enableOspfV3] == "true"} {
        if {[ospfSuite cget -flapOspfV3RouterLsa] == "true" && \
            [ospfSuite cget -enableOspfV3RouterLsa] == "true" } {
                incr totalLsas 
        }

        if {[ospfSuite cget -flapOspfV3InterAreaPrefixLsa] == "true" && \
            [ospfSuite cget -enableOspfV3InterAreaPrefixLsa] == "true" } {
                incr totalLsas 
        }

        if {[ospfSuite cget -flapOspfV3ExternalLsa] == "true" && \
            [ospfSuite cget -enableOspfV3ExternalLsa] == "true" } {
                incr totalLsas 
        }

    }
    return $totalLsas
}

proc ospfSuite::getNumberOfEnabledLsaGroups  {} \
{   
    set totalLsas 0

    if {[ospfSuite cget -enableOspfV2] == "true"} {
        if {[ospfSuite cget -enableOspfV2RouterLsa] == "true" } {
            incr totalLsas 
        }

        if {[ospfSuite cget -enableOspfV2SummaryLsa] == "true" } {
            incr totalLsas 
        }

        if {[ospfSuite cget -enableOspfV2ExternalLsa] == "true" } {
            incr totalLsas 
        }

    }
        
    if {[ospfSuite cget -enableOspfV3] == "true"} {
        if {[ospfSuite cget -enableOspfV3RouterLsa] == "true" } {
            incr totalLsas 
        }

        if {[ospfSuite cget -enableOspfV3InterAreaPrefixLsa] == "true" } {
            incr totalLsas 
        }

        if {[ospfSuite cget -enableOspfV3ExternalLsa] == "true" } {
            incr totalLsas 
        }

    }
    return $totalLsas
}







#################################################################################
# Procedure: writeOspfV2V3Streams
#
# Description: This command configures and writes the stream for ospfV2 V3 convergence test
#               
#
# Results :       0 : No error found
#                 1 : Error found
#
#################################################################################
proc ospfSuite::writeOspfV2V3Streams {TxRxArray {TxNumFrames ""}} \
{
    upvar $TxRxArray    txRxArray
    upvar $TxNumFrames  txNumFrames

    set retCode 0

    set packetGroupOffset   48
    set signature           "AA AA EE EE"
    set groupIdOffset       52

    # Setup filters on receive port to count our test packets
    filterPallette setDefault

    filter setDefault
    filter config -userDefinedStat2Enable   true
    filter config -userDefinedStat2Pattern  pattern1    

    packetGroup setDefault
    packetGroup config -insertSignature true
    packetGroup config -signatureOffset 48

    stream setDefault
    stream config -enable            true
    stream config -daRepeatCounter   daArp
    stream config -framesize         [ospfSuite cget -framesize]
    stream config -enableTimestamp   true

    stream config -enableIbg         false
    stream config -enableIsg         false

    stream config -rateMode          usePercentRate
    stream config -percentPacketRate [ospfSuite cget -percentMaxRate]
    stream config -gapUnit           gapNanoSeconds

    foreach txPort [getTxPorts txRxArray] {
        scan $txPort "%d %d %d" tx_c tx_l tx_p

        set streamID    1
        set txNumFrames($tx_c,$tx_l,$tx_p)   0
        
        if [port get $tx_c $tx_l $tx_p] {
            errorMsg "Port [getPortId $tx_c $tx_l $tx_p] not configured yet!"
            set retCode 1
        }
        stream config -sa                [port cget -MacAddress]
        
        if {[ospfSuite cget -enableOspfV2] == "true"} {

            if [ip get $tx_c $tx_l $tx_p] {
                errorMsg "Error getting IP on [getPortId $tx_c $tx_l $tx_p]"
                set retCode $::TCL_ERROR
            }

            ip   config   -ttl	            [advancedTestParameter cget -ipTTL]
            ip   config   -destIpMask       [getMaskWidth [ospfSuite cget -prefixLength]]

            protocol setDefault        
            protocol config    -name            ipV4
            protocol config    -ethernetType    ethernetII

            udf setDefault
            udf                          config            -enable                             true
            udf                          config            -continuousCount                    false
            udf                          config            -offset                             30
            udf                          config            -countertype                        c32
            udf                          config            -counterMode                        udfCounterMode
            udf                          config            -step                               [expr 1 << 32 - [ospfSuite cget -prefixLength]]
                
            if {[ospfSuite cget -enableOspfV2SummaryLsa] == "true"} {
                stream config -name         "OspfV2SummaryLsa"

                ip   config   -destIpAddr   [ospfSuite cget -networkIpAddress]

                udf  config   -initval      [getByteIp [ospfSuite cget -networkIpAddress]]
                udf  config   -repeat       [ospfSuite cget -numberOfRoutes]
                
                stream config -numFrames    [ospfSuite cget -numberOfRoutes]
                if [ip set $tx_c $tx_l $tx_p] {
                    errorMsg "Error setting IP on [getPortId $tx_c $tx_l $tx_p]"
                    set retCode $::TCL_ERROR
                }

                if [udf set 1] {
                    errorMsg "Error setting UDF 1."
                    set retCode $::TCL_ERROR
                }

                if [stream set $tx_c $tx_l $tx_p $streamID] {
                    errorMsg "Error setting stream $streamID for network on port [getPortId $tx_c $tx_l $tx_p]"
                    set retCode 1
                }
                incr streamID
            }

            if {[ospfSuite cget -enableOspfV2RouterLsa] == "true" } {
                stream config -name         "OspfV2RouterLsa"

                ip   config   -destIpAddr   [ospfSuite cget -ospfV2RouterLsaSubnet]
                if [ip set $tx_c $tx_l $tx_p] {
                    errorMsg "Error setting IP on [getPortId $tx_c $tx_l $tx_p]"
                    set retCode $::TCL_ERROR
                }


                udf  config   -initval      [getByteIp [ospfSuite cget -ospfV2RouterLsaSubnet]]
                udf  config   -repeat       [ospfSuite cget -numOspfV2RouterLsa]
                if [udf set 1] {
                    errorMsg "Error setting UDF 1."
                    set retCode $::TCL_ERROR
                }
                
                stream config -numFrames    [ospfSuite cget -numOspfV2RouterLsa]
                
                if [stream set $tx_c $tx_l $tx_p $streamID] {
                    errorMsg "Error setting stream $streamID for network on port [getPortId $tx_c $tx_l $tx_p]"
                    set retCode 1
                }
                incr streamID
            }

            if {[ospfSuite cget -enableOspfV2ExternalLsa] == "true" } {
                stream config -name         "OspfV2ExternalLsa"

                ip   config   -destIpAddr   [ospfSuite cget -ospfV2ExternalLsaSubnet]
                if [ip set $tx_c $tx_l $tx_p] {
                    errorMsg "Error setting IP on [getPortId $tx_c $tx_l $tx_p]"
                    set retCode $::TCL_ERROR
                }

                udf  config   -initval      [getByteIp [ospfSuite cget -ospfV2ExternalLsaSubnet]]
                udf  config   -repeat       [ospfSuite cget -numOspfV2ExternalLsa]
                if [udf set 1] {
                    errorMsg "Error setting UDF 1."
                    set retCode $::TCL_ERROR
                }
                
                stream config -numFrames    [ospfSuite cget -numOspfV2ExternalLsa]
                if [stream set $tx_c $tx_l $tx_p $streamID] {
                    errorMsg "Error setting stream $streamID for network on port [getPortId $tx_c $tx_l $tx_p]"
                    set retCode 1
                }
                incr streamID
            }
        }


        if {[ospfSuite cget -enableOspfV3] == "true"} {

            set packetGroupOffset   58
            set groupIdOffset       62
            
            udf setDefault
            udf                          config            -enable                             false
            if [udf set 1] {
                errorMsg "Error setting UDF 1."
                set retCode $::TCL_ERROR
            
            }
            if [ipV6 get $tx_c $tx_l $tx_p] {
                errorMsg "Error getting IPV6 on [getPortId $tx_c $tx_l $tx_p]"
                set retCode $::TCL_ERROR
            }
            ipV6   config   -destMask       [ospfSuite cget -ospfV3PrefixLength]
            # before destAddrMode was set to ipV6IncrNetwork, but now this value doesn't work
            # with Global Unicast IPv6 addreses
            # There is no need to supply this parameter when specifying destMask
            #ipV6   config   -destAddrMode   ipV6IncrGlobalUnicastSiteLevelAggrId

            

            protocol setDefault        
            protocol config    -name            ipV6
            protocol config    -ethernetType    ethernetII

            if {[ospfSuite cget -enableOspfV3InterAreaPrefixLsa] == "true"} {
                stream config -name         "OspfV3InterAreaPrefixLsa"
                
                set address     [ospfSuite cget -ospfV3InterAreaPrefixLsaSubnet]
                regsub -all " " [ipv6::getInterfaceId $address] "" interfaceId
                if {$interfaceId == 0} {
                    set address [ipv6::incrIpField $address]
                }

                ipV6  config   -destAddr                $address
                ipV6  config   -destAddrRepeatCount     [ospfSuite cget -numOspfV3InterAreaPrefixLsa]                     

                 if [ipV6 set $tx_c $tx_l $tx_p] {
                    errorMsg "Error setting IPV6 on [getPortId $tx_c $tx_l $tx_p]"
                    set retCode $::TCL_ERROR
                }

                stream config -numFrames    [ospfSuite cget -numOspfV3InterAreaPrefixLsa]

                if [stream set $tx_c $tx_l $tx_p $streamID] {
                    errorMsg "Error setting stream $streamID for network on port [getPortId $tx_c $tx_l $tx_p]"
                    set retCode 1
                }
                incr streamID
            }

            if {[ospfSuite cget -enableOspfV3RouterLsa] == "true" } {
                stream config -name         "OspfV3RouterLsa"

                set address     [ospfSuite cget -ospfV3RouterLsaSubnet]
                regsub -all " " [ipv6::getInterfaceId $address] "" interfaceId
                if {$interfaceId == 0} {
                    set address [ipv6::incrIpField $address]
                }
                ipV6  config   -destAddr                $address
                ipV6  config   -destAddrRepeatCount     [ospfSuite cget -numOspfV3RouterLsa]                     

                 if [ipV6 set $tx_c $tx_l $tx_p] {
                    errorMsg "Error setting IPV6 on [getPortId $tx_c $tx_l $tx_p]"
                    set retCode $::TCL_ERROR
                }
                stream config -numFrames    [ospfSuite cget -numOspfV3RouterLsa]

                if [stream set $tx_c $tx_l $tx_p $streamID] {
                    errorMsg "Error setting stream $streamID for network on port [getPortId $tx_c $tx_l $tx_p]"
                    set retCode 1
                }
                incr streamID
            }

            if {[ospfSuite cget -enableOspfV3ExternalLsa] == "true" } {
                stream config -name         "OspfV3ExternalLsa"

                set address     [ospfSuite cget -ospfV3ExternalLsaSubnet]
                regsub -all " " [ipv6::getInterfaceId $address] "" interfaceId
                if {$interfaceId == 0} {
                    set address [ipv6::incrIpField $address]
                }
                ipV6  config   -destAddr                $address
                ipV6  config   -destAddrRepeatCount     [ospfSuite cget -numOspfV3ExternalLsa]                     

                if [ipV6 set $tx_c $tx_l $tx_p] {
                    errorMsg "Error setting IPV6 on [getPortId $tx_c $tx_l $tx_p]"
                    set retCode $::TCL_ERROR
                }
                stream config -numFrames    [ospfSuite cget -numOspfV3ExternalLsa]

                if [stream set $tx_c $tx_l $tx_p $streamID] {
                    errorMsg "Error setting stream $streamID for network on port [getPortId $tx_c $tx_l $tx_p]"
                    set retCode 1
                }
                incr streamID
            }
        }

        packetGroup config -signatureOffset    $packetGroupOffset
        packetGroup config -signature          $signature
        packetGroup config -groupIdOffset      $groupIdOffset 
        

        udf setDefault
        udf     config    -enable           true
        udf     config    -offset           $groupIdOffset
        udf     config    -countertype      c32
        udf     config    -counterMode      udfCounterMode
        
        set initVal  1
    
        for {set index 1} {$index < $streamID} {incr index} { 
            
            if [stream get $tx_c $tx_l $tx_p $index] {
                errorMsg "Error getting stream $index for network on port [getPortId $tx_c $tx_l $tx_p]"
                set retCode 1
            }
            
            if [packetGroup setTx $tx_c $tx_l $tx_p $index] {
                errorMsg "Error setting TX packet group for stable network on port [getPortId $tx_c $tx_l $tx_p]"
                set retCode 1
            }

            #UDF 2 packet group Id.
            udf  config   -repeat   [stream cget -numFrames]
            udf  config   -initval  [format "%04x" $initVal]
            incr initVal [stream cget -numFrames]

            if [udf set 2] {
                errorMsg "Error setting UDF 1."
                set retCode $::TCL_ERROR
            }

            stream config -percentPacketRate [ospfSuite cget -percentMaxRate]

            stream config -dma  advance
            if {$index == [expr $streamID-1]} {
                stream config -dma  gotoFirst
            }
            if [stream set $tx_c $tx_l $tx_p $index] {
                errorMsg "Error setting stream $index for network on port [getPortId $tx_c $tx_l $tx_p]"
                set retCode 1
            }
        }

        # Setup filters on receive port to count our test packets
        filterPallette config -pattern1         [packetGroup cget -signature]
        filterPallette config -patternOffset1   [packetGroup cget -signatureOffset]
        
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
	    packetGroup config -enable128kBinMode  true
            if [packetGroup setRx $rx_c $rx_l $rx_p] {
                errorMsg "Error setting RX packet group for stable network on port [getPortId $rx_c $rx_l $rx_p]"
                set retCode 1
            }
        }
    }

    if {$retCode == 0} {
        adjustOffsets txRxArray
        set retCode [writeConfigToHardware txRxArray]
    }
    return $retCode
}


########################################################################################
# Procedure: getByteIp
#
# Description: This command builds a byte string from an Ip address to be used for UDF.
#
# Argument(s):
#
# Results :      byte string 
#         
########################################################################################
proc ospfSuite::getByteIp {ipAddress} \
{   
    scan $ipAddress "%d.%d.%d.%d" b1 b2 b3 b4

    #To be consistent with the ixExplorer
    if {$b4 != 1} {
        set b4 100
    }

   return "[format %.2x $b1] [format %.2x $b2] [format %.2x $b3] [format %.2x $b4]"

}

########################################################################################
# Procedure: enableEBitBBit
#
# Description: This command enable E bit and B bit on the ixia Router LSA in the grid.
#
# Argument(s):
#
# Results :      
#         
########################################################################################
proc ospfSuite::enableEBitBBit {chassis card port} \
{   
    set retCode 0

    if [ospfV3Server select $chassis $card $port] {
        errorMsg "Error selecting ospfV3 server."
        set $retCode 1
    }

    if [ospfV3Server getFirstRouter] {
        errorMsg "Error in getting ospfV3 router."
        set $retCode 1
    }

    if {[ospfV3Router getFirstUserLsaGroup]} {
        errorMsg "Error in getting first userLsaGroup."
        set $retCode 1
    }

    set routerLsa [ospfV3UserLsaGroup getFirstUserLsa]
     
    while  {$routerLsa  != "NULL"} {
        if {[$routerLsa cget -type] == $::ospfV3LsaRouter && [$routerLsa cget -advertisingRouterId] == [ospfV3Router cget -routerId]} {
            $routerLsa config -enableEBit true
            $routerLsa config -enableBBit true
            break
        }
        set routerLsa [ospfV3UserLsaGroup getNextUserLsa]
    }
    
    if [ospfV3UserLsaGroup setUserLsa] {
        errorMsg "Error setting router Lsa."
    }
    return $retCode
}


########################################################################################
# Procedure:    validateFramesizeList
#
# Description:  Verifies that the given protocol list is valid for OSPF tests.
#
# Argument(s):  framesizeList
#
# Results:      $::TCL_OK or $::TCL_ERROR
#         
########################################################################################
proc ospfSuite::validateFramesizeList {framesizeList} \
{   
    set retCode $::TCL_ERROR

    set mask 0x00

    if {[ospfSuite cget -enableOspfV2] == "true"} {
        set mask [expr $mask | 0x01]
    }
    if {[ospfSuite cget -enableOspfV3] == "true"} {
        set mask [expr $mask | 0x10]
    }

    switch [format "%02x" $mask] {
        01 {
            set retCode $::TCL_OK
        }
        10 -
        11 {
            set protocol [protocol cget -name]
            protocol config -name ipV6
            if {[lindex [lnumsort $framesizeList] 0] >= [ipv6::getMinimumValidFramesize]} {
                set retCode $::TCL_OK
            }                    
            protocol config -name $protocol
        }
    }

    return $retCode
}

########################################################################
# Procedure: ospfPerformance::doBinarySearch
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
proc ospfPerformance::doBinarySearch { \
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
    ospfPerformance::countTxRxFrames txRxArray txNumFrames txRxFrames

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
            set rate [format "%3.2f" [mpexpr $totalRate/[llength  [getTxPorts txRxArray]]]]
            logMsg "\n---> BINARY ITERATION $iteration, transmit rate: $rate%,$trialStr framesize: $framesize, [$testCmd cget -testName]" 
            debugMsg "\n---> BINARY ITERATION $iteration, transmit rate: $rate%,$trialStr framesize: $framesize, [$testCmd cget -testName]"
        }
        set txRateBelowLimit 0

        if {$linearBinarySearch == "false"} {
            set portList    $doneList

            foreach txMap $portList {
                scan $txMap "%d %d %d" tx_c tx_l tx_p

                if {$framerate($tx_c,$tx_l,$tx_p) < [$testCmd cget -minimumFPS]} {
                    logMsg "\n***> Throughput has fallen below [$testCmd cget -minimumFPS] fps on [getPortId $tx_c $tx_l $tx_p] ***<"
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
        logMsg [format "%-12s\t%-12s\t%-10s\t%-10s\t%-10s\t%-10s\t%-10s" "TX" "RX" $OLoadHeaderString "%MaxTxRate" "AvgTxRunRate" "AvgRxRunRate" "% Loss"]
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

	set settleDown 3
        logMsg "\nWaiting $settleDown sec for the DUT streams to settle down..."
        after [expr $settleDown*1000]

        set warnings ""

        getTransmitTime txRxArray [$testCmd cget -duration] durationArray warnings

        if {$linearBinarySearch == "false"} {
            foreach txMap $doneList {
                scan $txMap "%d %d %d" tx_c tx_l tx_p

                set numRxPort [llength $txRxArray($tx_c,$tx_l,$tx_p)]

                if {[port get $tx_c $tx_l $tx_p]} {
                    logMsg "writeOspfPerformanceStreams: port [getPortId $tx_c $tx_l $tx_p] not configured yet!"
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
                        set tputRateArray($tx_c,$tx_l,$tx_p) $framerate($tx_c,$tx_l,$tx_p)
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
                        set tputRateArray($tx_c,$tx_l,$tx_p)    $framerate($tx_c,$tx_l,$tx_p)
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
        foreach txMap $doneList {
            scan $txMap "%d %d %d" tx_c tx_l tx_p
            debugMsg "txMap:$txMap"

            set numRxPorts [llength $txRxArray($tx_c,$tx_l,$tx_p)]
            set numStreams [mpexpr $numRxPorts*[ospfSuite cget -numPeers]]

            lappend allStreams $numStreams
        }        
        set refStreams [LCM allStreams]

        $testCmd config -duration $initialDuration

        foreach txMap $doneList {
            scan $txMap "%d %d %d" tx_c tx_l tx_p
            debugMsg "txMap:$txMap"

            set numRxPorts [llength $txRxArray($tx_c,$tx_l,$tx_p)]

            set numStreams [mpexpr $numRxPorts*[ospfSuite cget -numPeers]]

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
            ospfPerformance::countTxRxFrames txRxArray txNumFrames txRxFrames
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

   copyPortList  txActualFrames txNumFrames 

    return $retCode
}


########################################################################
# Procedure: ospfPerformance::countTxRxFrames
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
proc ospfPerformance::countTxRxFrames {TxRxArray TxNumFrames TxRxNumFrames} {
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
        set numStreams  [mpexpr $numRxPorts*[ospfSuite cget -numPeers]]

        if {[streamUtils::streamGet $tx_c $tx_l $tx_p $numStreams]} {
            errorMsg "Error getting stream $numStreams on [getPortId $tx_c $tx_l $tx_p]"
            set status 1
        }

        set loopcount   [stream cget -loopCount]
        set streamID 1

        foreach rxMap $txRxArray($tx_c,$tx_l,$tx_p) {
            scan [join $rxMap] "%d %d %d" rx_c rx_l rx_p

            for {set count 1} {$count <= [ospfSuite cget -numPeers] } {incr count} {
                if {[streamUtils::streamGet $tx_c $tx_l $tx_p $numStreams]} {
                    errorMsg "Error getting stream $numStreams on [getPortId $tx_c $tx_l $tx_p]"
                    set status 1
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

