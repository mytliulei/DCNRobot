###############################################################################
# Version 4.10 $
# $Date: 10/15/02 3:14p $
# $Author: Debby $
#
# $Workfile: switchLearn.tcl $
#
#   Copyright © 1997 - 2005 by IXIA
#	All Rights Reserved.
#
#	Revision Log:
#	08-13-1998    Hardev Soor
#
# Description: This file contains commands that send learn frames
# for various protocols to the switch (DUT).
#
########################################################################################

set ::udfList {1 2 3 4}

########################################################################################
#::::::::::::                    MAC Layer Learn frames                       :::::::::::::
########################################################################################

########################################################################################
# Procedure: send_learn_frames
#
# Description: This command sends directed learn frames to allow the DUT to learn the
#              mac addresses of the sending ports
#
# Argument(s):
#    PortArray    array of ports, ie., one2oneArray for a one2one configuration
#
########################################################################################
proc send_learn_frames {PortArray {RemovedPorts ""} {staggeredStart true}} \
{
    upvar $PortArray portArray
    if {[string length $RemovedPorts] > 0} {
        upvar $RemovedPorts removedPorts
    }

    set retCode       0
    set removedPorts  0

    set broadcastMac  $::kBroadcastMacAddress

    set enable802dot1qTag [protocol cget -enable802dot1qTag]

    # set the stream parameters.
    set preambleSize  8

    stream setDefault
    stream config -rateMode  usePercentRate
    stream config -name      "LearnStream"
    stream config -framesize [learn cget -framesize]
    stream config -dma       stopStream
    stream config -gapUnit   gapNanoSeconds
    stream config -enableIbg false
    stream config -enableIsg false

    # set frameType to "08 00" 
	if {[protocol cget -ethernetType] == $::ethernetII} {
		stream config -frameType [advancedTestParameter cget -streamFrameType]
	}

    set sentList ""
    # note - send one port at portArray time to allow time for learning;
    #         remember, learn frames are sent from Rx to Tx...
    foreach txMap [lnumsort [array names portArray]] {
        scan $txMap "%d,%d,%d" tx_c tx_l tx_p

        if [IsPOSPort $tx_c $tx_l $tx_p] {
            set txSA $broadcastMac
        } else {
            if [port get $tx_c $tx_l $tx_p] {
                errorMsg "Port [getPortId $tx_c $tx_l $tx_p] has not been configured yet."
                set retCode $::TCL_ERROR
                continue
            }
            set txSA [port cget -MacAddress]
        }

        foreach rxMap $portArray($txMap) {
            scan [join $rxMap] "%d %d %d" rx_c rx_l rx_p

            if {![IsPOSPort $rx_c $rx_l $rx_p] && [lsearch $sentList [list $rx_c $rx_l $rx_p]] < 0} {
                lappend sentList [list $rx_c $rx_l $rx_p]

                if {[port get $rx_c $rx_l $rx_p] == 1} {
                    errorMsg "Port [getPortId $rx_c $rx_l $rx_p] has not been configured yet."
                    continue
                }

                set learnPercentRate [expr double([learn cget -rate])/[calculateMaxRate $rx_c $rx_l $rx_p [learn cget -framesize]]*100.]
                stream config -percentPacketRate $learnPercentRate

                stream config -da           $txSA

                stream config -sa           [port cget -MacAddress]
                stream config -numSA        [port cget -numAddresses]

                if {[stream cget -numSA] > 1} {
                    stream config -saRepeatCounter  increment
                }

                set numFrames($rx_c,$rx_l,$rx_p)    [expr [learn cget -numframes] * [port cget -numAddresses]]
                stream config -numFrames            $numFrames($rx_c,$rx_l,$rx_p)

				if [catch {expr int(ceil(double($numFrames($rx_c,$rx_l,$rx_p))/[learn cget -rate]))} duration] {
					errorMsg "$duration"
					set retCode $::TCL_ERROR
					set duration 1
				}

                disableUdfs {1 2 3 4}
                
                if {![vlanUtils::isPortTagged $rx_c $rx_l $rx_p] && $enable802dot1qTag} {
                    protocol config -enable802dot1qTag  false
                }

                if [stream set $rx_c $rx_l $rx_p 1] {
                    errorMsg "Error setting stream for learning frames on [getPortId $rx_c $rx_l $rx_p] 1."
                    set retCode $::TCL_ERROR
                    continue
                }
            }
        }
    }

    if {[llength $sentList] > 0} {        
        logMsg "Configuring learn frames ..."

        # zero stats everywhere to avoid confusion later...
        zeroStats portArray

        if {$retCode == 0} {
            logMsg "Sending learning frames to all ports..."

            writeConfigToHardware sentList
	        if [startTx sentList $staggeredStart] {
                set retCode $::TCL_ERROR
            }
        }

        if {$duration < 1} {
            set duration 1
        }

        after [learn cget -waitTime]
        # Wait for all frames to be transmitted..
        writeWaitMessage "Transmit Status" "Transmitting learn frames" $duration

        statGroup setDefault
        foreach rxMap $sentList {
            scan $rxMap "%d %d %d" rx_c rx_l rx_p

            if [statGroup add $rx_c $rx_l $rx_p] {
                errorMsg "Error adding port [getPortId $rx_c $rx_l $rx_p] to statGroup"
                set retCode $::TCL_ERROR
                continue
            }
        }

        # wait the min refresh for 10/100 cards to let the stats update...
        after 800
        set tempSentList   $sentList 
        set retry           20

        while {([llength $tempSentList] > 0) && ($retry > 0)} {
            if [statGroup get] {
                errorMsg "Error getting stats for statGroup"
                set retCode $::TCL_ERROR
            }

            foreach rxMap $tempSentList {
                scan $rxMap "%d %d %d" rx_c rx_l rx_p

                if [statList get $rx_c $rx_l $rx_p] {
                    errorMsg "Error getting Tx statistics for [getPortId $rx_c $rx_l $rx_p]"
                    set retCode $::TCL_ERROR
                    continue
                }

				if [catch {statList cget -scheduledFramesSent} txNumFrames ] {
					if [catch {statList cget -framesSent} txNumFrames ] {
						set txNumFrames 0
					} else {
						if [catch {statList cget -protocolServerTx} numProtocolServerFrames ] {
							set numProtocolServerFrames  0
						}
						set txNumFrames [mpexpr $txNumFrames - $numProtocolServerFrames]
						if {[isNegative $txNumFrames]} {
							 set txNumFrames 0
						}
					}
				}

                if { $txNumFrames == $numFrames($rx_c,$rx_l,$rx_p) } {
                    set portIndex [lsearch $tempSentList [list $rx_c $rx_l $rx_p]]
			        if {$portIndex != -1} {
				        set tempSentList [lreplace $tempSentList $portIndex $portIndex]
			        }
                }
            }
            if { [llength $tempSentList] == 0 } {
                set retry  0
            } else {
                incr retry -1
            }
        }

        if {[llength $tempSentList] > 0} { 
            foreach rxMap $tempSentList {
                scan $rxMap "%d %d %d" rx_c rx_l rx_p
                logMsg "All Learn frames not sent on port [getPortId $rx_c $rx_l $rx_p]"
                set retCode $::TCL_ERROR
            }
        }

        logMsg "Learning frames sent..."
    }

    if {[fastpath cget -enable] == "true"} {
        if [send_fastpath_frames portArray] {
            errorMsg "Error sending fastpath frames"
            set retCode $::TCL_ERROR
        }
    }

    protocol config -enable802dot1qTag  $enable802dot1qTag   
    stream setDefault

    return $retCode
}


########################################################################################
#::::::::::::                    IP Layer Learn frames                       :::::::::::::
########################################################################################

########################################################################################
# Procedure: OLDsend_arp_frames
#
# Description: This command send the arp frames from rx to tx
#
# Argument(s):
#    PortArray    array of ports, ie., one2oneArray for a one2one configuration
#
########################################################################################
proc OLDsend_arp_frames {PortArray {RemovedPorts ""}} \
{
    upvar $PortArray portArray
    if {[string length $RemovedPorts] > 0} {
        upvar $RemovedPorts removedPorts
    }

    set retCode 0
    
    # This code has been added for "Send MAC Only" option
    if {[learn cget -type] == "mac" } {
		if [send_learn_frames portArray] {
			return -code error -errorinfo "Error sending MAC learning frames"
		}
        return $retCode
    }
            
    set removedPorts 0

    disableUdfs $::udfList
    filter setDefault
    stream setDefault
    udf setDefault

    # set the stream parameters.
    set preambleSize            8
    set framesize               [learn cget -framesize]
    set enable802dot1qTag       [protocol cget -enable802dot1qTag]
    set duration                [expr [learn cget -numframes] / [learn cget -rate]]

    stream config -rateMode     usePercentRate
    stream config -name         "ArpStream"
    stream config -framesize    $framesize
    stream config -dma          stopStream
    stream config -numFrames    [learn cget -numframes]
    stream config -fcs          good
    stream config -gapUnit      gapNanoSeconds

    filter config -captureFilterPattern          any
    filter config -captureFilterError            errGoodFrame
    filter config -captureFilterFrameSizeEnable  false
    filter config -captureFilterFrameSizeEnable  false
    filter config -captureTriggerError           errGoodFrame

    # zero stats everywhere to avoid confusion later...
    zeroStats portArray

    # note - send one port at portArray time to allow time for learning; arp frames should
    #         be sent from tx->DUT & rx->DUT.

    set rxList  [lnumsort [getAllPorts portArray]]

    set tempAppName [protocol cget -appName]
    protocol config -appName  Arp

    foreach txMap $rxList {
        scan $txMap "%d %d %d" tx_c tx_l tx_p

        if [IsPOSPort $tx_c $tx_l $tx_p] {
            set index   [lsearch  $rxList $txMap]
            set rxList  [lreplace $rxList $index $index]
            continue
        }

        if {[port get $tx_c $tx_l $tx_p] == 1 || [ip get $tx_c $tx_l $tx_p] == 1} {
            errorMsg "Port [getPortId $tx_c $tx_l $tx_p] has not been configured yet."
            set retCode 1
            continue
        }

        set txSA            [port cget -MacAddress]
        set numTx           [port cget -numAddresses]

        set txDA            $::kBroadcastMacAddress
        set txIP            [ip cget -sourceIpAddr]
        set txDutIP         [ip cget -destDutIpAddr]


        arp config -operation           arpRequest
        arp config -sourceProtocolAddr  $txIP
        arp config -destProtocolAddr    $txDutIP
        arp config -sourceHardwareAddr  $txSA
        arp config -destHardwareAddr    $txDA
                               
        if {$numTx > 1} {
            arp config -sourceHardwareAddrMode arpIncrement
            arp config -sourceHardwareAddrRepeatCount $numTx
            arp config -sourceProtocolAddrMode arpIncrement
            arp config -sourceProtocolAddrRepeatCount $numTx
            stream config -numFrames [expr $numTx * [learn cget -numframes]]
            if {[expr [stream cget -numFrames]/[learn cget -rate]] > $duration} {
                set duration    [expr [stream cget -numFrames]/[learn cget -rate]]
            }
        }

        if [arp set $tx_c $tx_l $tx_p] {
            errorMsg "Error setting Arp for port [getPortId $tx_c $tx_l $tx_p]"
            set retCode 1
            continue
        }

        set learnPercentRate             [expr double([learn cget -rate])/[calculateMaxRate $tx_c $tx_l $tx_p $framesize]*100.]
        stream config -percentPacketRate $learnPercentRate

        stream config -da       $txDA
        stream config -numDA    1

        stream config -sa       $txSA
        stream config -numSA    $numTx
        if {$numTx > 1} {
            stream config -saRepeatCounter increment
        }

        stream config -patternType    repeat
        stream config -dataPattern    allZeroes

        if {$enable802dot1qTag && ![vlanUtils::isPortTagged $tx_c $tx_l $tx_p]} {
            protocol config -enable802dot1qTag  false
        }

        if [stream set $tx_c $tx_l $tx_p 1] {
            errorMsg "Error setting stream 1 on [getPortId $tx_c $tx_l $tx_p] for ARP frames."
            set retCode 1
        }

        protocol config -enable802dot1qTag  $enable802dot1qTag

        # set up the pattern filter
        filterPallette config -pattern1        [host2addr $txDutIP]
        filterPallette config -patternOffset1    28
        if [filterPallette set $tx_c $tx_l $tx_p] {
            errorMsg "Error setting filter pallette for [getPortId $tx_c $tx_l $tx_p]"
            set retCode 1
        }

        # set the filter parameters on the receive port
        debugMsg "    configuring filters"
        filter config -captureFilterEnable   true
        filter config -captureTriggerEnable  true
        if [filter set $tx_c $tx_l $tx_p] {
            errorMsg "Error setting filters on [getPortId $tx_c $tx_l $tx_p]"
            set retCode 1
        }
    }
    protocol config -appName  $tempAppName

    if {[llength $rxList] == 0} {
        return $retCode
    }

    disableArpResponse    rxList

    if [setCaptureMode rxList] {
        set retCode 1
    }

    writeConfigToHardware rxList

	if {[checkLinkState rxList ]} {
        set retCode 1
    }

    if [startCapture rxList] {
        errorMsg "Error starting capture."
        set retCode 1
    }

    foreach txMap $rxList {
        scan $txMap "%d %d %d" tx_c tx_l tx_p

        if [arp get $tx_c $tx_l $tx_p] {
            errorMsg "Error getting Arp on [getPortId $tx_c $tx_l $tx_p]"
            set retCode 1
        }

        logMsg "sending ARP frame from [getPortId $tx_c $tx_l $tx_p], SrcPort: [arp cget -sourceProtocolAddr] to DestPort: [arp cget -destProtocolAddr]"
    }
	set retCode [startStaggeredTx rxList]

    # wait the min refresh for 10/100 cards to let the stats update...
    after 800

    after [learn cget -waitTime]
    # Wait for all frames to be transmitted..
    for {set timeCtr 1} {$timeCtr <= $duration} {incr timeCtr} {
        logMsg  "Transmitted arp frames $timeCtr of $duration seconds"
        after 1000
    }

    checkAllTransmitDone rxList

    foreach txMap $rxList {
        scan $txMap "%d %d %d" tx_c tx_l tx_p

        # look for ARP responses
        set maxArp  100
        if [captureBuffer get $tx_c $tx_l $tx_p 1 $maxArp] {
            errorMsg "Error getting capture buffer for [getPortId $tx_c $tx_l $tx_p]"
            set retCode 1
            continue
        }
        set found 0
        set nFrame 1
        while {[captureBuffer getframe $nFrame] != 1 && $nFrame <= $maxArp} {
            debugMsg "Getting frame $nFrame from Buffer   ....."
            set capframe    [captureBuffer cget -frame]
            if {([arp decode $capframe] == 0) && ([arp cget -operation] == $::arpReply)} {
                set found 1
                break
            }
            incr nFrame
        }

        if {$found == 0} {
            logMsg "No ARP response frames received on [getPortId $tx_c $tx_l $tx_p]"
            if {[learn cget -removeOnError] == "true"} {
                logMsg "Removing port $txMap from map..."
                if [array exists portArray] {
                    if [info exists portArray($c,$l,$p)] {
                        unset portArray($c,$l,$p)
                        set removedPorts    1
                    }
                    foreach txMap [array names portArray] {
                        scan $txMap "%d,%d,%d" tx_c tx_l tx_p

                        foreach rxMap $portArray($tx_c,$tx_l,$tx_p) {
                            set index [lsearch $portArray($tx_c,$tx_l,$tx_p) "$c $l $p"]

                            if {$index >= 0} {
                                set portArray($tx_c,$tx_l,$tx_p) [lreplace $portArray($tx_c,$tx_l,$tx_p) $index $index]
                                set removedPorts    1
                            }
                            if {[llength $portArray($tx_c,$tx_l,$tx_p)] <= 0} {
                                unset portArray($tx_c,$tx_l,$tx_p)
                            }
                        }
                    }                   
                } else {
                    set index [lsearch [getAllPorts portArray] "$c $l $p"]
                    if {$index >= 0} {
                        set portArray [lreplace [getAllPorts portArray $index $index]]
                        set removedPorts    1
                    }
                }

                # remember to set an error if we removed all ports!!
                if {![info exists portArray]} {
                    set retCode 1
                } else {
                    if {[llength [array get portArray]] <= 0} {
                        set retCode 1
                    }
                }
            } else {
                set retCode 1
            }
            continue
        }

        if [port get $tx_c $tx_l $tx_p] {
            errorMsg "Error getting port [getPortId $tx_c $tx_l $tx_p] for storing DestMacAddress."
            set retCode 1
            continue
        }
        port config -DestMacAddress    [arp cget -sourceHardwareAddr]
        if [port set $tx_c $tx_l $tx_p] {
            errorMsg "Error setting port [getPortId $tx_c $tx_l $tx_p]"
            set retCode 1
        }
        logMsg "Got ARP RESPONSE on [getPortId $tx_c $tx_l $tx_p], DUT MAC address for [getPortId $tx_c $tx_l $tx_p]: [arp cget -sourceHardwareAddr]"
    }

    if {[learn cget -waitTime] > 1000} {
        logMsg "Waiting for DUT to settle down after learning for [expr [learn cget -waitTime]/1000] second(s)..."
    }

    after [learn cget -waitTime]

    if {$retCode == 0 && [ipfastpath cget -enable] == "true"} {
        if [send_ipfastpath_frames portArray] {
            errorMsg "Error sending IP fastpath frames"
            set retCode 1
        }
    } elseif {$retCode == 0 && [fastpath cget -enable] == "true"} {
        if [send_fastpath_frames portArray] {
            errorMsg "Error sending IP fastpath frames"
            set retCode 1
        }
    }

    stream setDefault

    return $retCode
}


########################################################################################
# Procedure: send_arp_frames
#
# Description: This command uses the protocol server to configure arp, send out arp 
#              requests & enable arp response
#
# Argument(s):
#    PortArray    array of ports, ie., one2oneArray for a one2one configuration
#
########################################################################################
proc send_arp_frames {PortArray {RemovedPorts ""} {resetInterfaces true}} \
{
    upvar $PortArray    portArray
    if {[string length $RemovedPorts] > 0} {
        upvar $RemovedPorts removedPorts
    }

    set retCode			0
	set numInterfaces	1
    set arpList         [getAllPorts portArray]

    if [configureArp portArray arpList write $numInterfaces $resetInterfaces] {
        errorMsg "Error configuring ARP"
        set retCode 1
    }   
    if {[llength $arpList] != 0} {
        
        if {[sendArp portArray $arpList removedPorts] || $retCode } {
            errorMsg "Error sending ARP"
            set retCode 1
        }

        if {$retCode == 0 && [ipfastpath cget -enable] == "true"} {
            if [send_ipfastpath_frames portArray] {
                errorMsg "Error sending IP fastpath frames"
                set retCode 1
            }
        } elseif {$retCode == 0 && [fastpath cget -enable] == "true"} {
            if [send_fastpath_frames portArray] {
                errorMsg "Error sending IP fastpath frames"
                set retCode 1
            }
        }
    }
    return $retCode
}


########################################################################################
# Procedure: configureArp
#
# Description: This command configures the protocol server for ARP 
#
# Argument(s):
#    PortArray  - array of ports, ie., one2oneArray for a one2one configuration
#                 NOTE:This array is passed for internal modem configuration purposes      
#    ArpList
#
########################################################################################
proc configureArp {PortArray ArpList {write write} {numInterfaces 1} {resetInterfaces true}} \
{
    upvar $PortArray    portArray
    upvar $ArpList      arpList

    set retCode 0

    #set rxList  [getRxPorts  portArray]
    set enable802dot1qTag   [protocol cget -enable802dot1qTag]

    foreach txMap $arpList {
        scan $txMap "%d %d %d" tx_c tx_l tx_p
        
        if [IsPOSPort $tx_c $tx_l $tx_p] {
            set index   [lsearch $arpList $txMap]
            set arpList [lreplace $arpList $index $index]
            continue
        }

        ipAddressTable      setDefault
        ipAddressTableItem  setDefault
        arpServer           setDefault
        protocolServer      setDefault
                         
        if {![catch {hasInternalModem portArray $tx_c $tx_l $tx_p} internalModemFlag] && $internalModemFlag } {
            configureArpInternalModem portArray $tx_c $tx_l $tx_p

        } else {
            if {[port get $tx_c $tx_l $tx_p] == 1 || [ip get $tx_c $tx_l $tx_p] == 1} {
                errorMsg "Port [getPortId $tx_c $tx_l $tx_p] has not been configured yet."
                set retCode 1
                continue
            }
            set txSA                [port cget -MacAddress]
            set numTx               [port cget -numAddresses]
                              
            ipAddressTable config -defaultGateway       [ip cget -destDutIpAddr]

            ipAddressTableItem config -fromIpAddress    [ip cget -sourceIpAddr]
            ipAddressTableItem config -fromMacAddress   $txSA
            ipAddressTableItem config -numAddresses     $numTx

            if {[vlanUtils::isPortTagged $tx_c $tx_l $tx_p] && $enable802dot1qTag} {
                if [vlan get $tx_c $tx_l $tx_p] {
                    errorMsg "Error getting vlan parameters for $tx_c $tx_l $tx_p"
                    set retCode 1
                }
                ipAddressTableItem config -enableVlan   true
                ipAddressTableItem config -vlanId   [vlan cget -vlanID]
            }

            if [ipAddressTableItem set] {
                errorMsg "Error setting ipAddressTableItem"
                set retCode 1
                continue
            }
            if [ipAddressTable addItem] {
                errorMsg "Error adding ipAddressTable item"
                set retCode 1
                continue
            }
        }
        
        if [ipAddressTable set $tx_c $tx_l $tx_p] {
             errorMsg "Error setting ipAddressTable on port [getPortId $tx_c $tx_l $tx_p]"
             set retCode 1
             continue
        }

        # if this is a receive port, then make sure we learn as well as get the DUT mac addr...
        #if {[lsearch $rxList [list $tx_c $tx_l $tx_p]] >= 0} {
        #   arpServer config -mode   arpGatewayAndLearn
        #} else {
        #   # we only need the gateway address if we're not a receiver...
        #   arpServer config -mode   arpGatewayOnly
        #}
    
        # because we want to use requestRepeatCount, so need to ARP and Learn for all ports
        arpServer config -mode          arpGatewayAndLearn
        arpServer config -retries       [learn cget -retries]
        arpServer config -rate          [learn cget -rate]
        arpServer config -requestRepeatCount   [learn cget -numframes]

        if [arpServer set $tx_c $tx_l $tx_p] {
            errorMsg "Error setting arpServer on port [getPortId $tx_c $tx_l $tx_p]"
            set retCode 1
            continue
        }
        protocolServer config -enableArpResponse    true
        if [protocolServer set $tx_c $tx_l $tx_p] {
            errorMsg "Error setting protocolServer on port [getPortId $tx_c $tx_l $tx_p]"
            set retCode 1
        }

        if {[interfaceTable::configurePort $tx_c $tx_l $tx_p $::ipV4 $numInterfaces nowrite $resetInterfaces]} {
            errorMsg "Error: Unable to set interface table on port [getPortId $tx_c $tx_l $tx_p]"
            set retCode $::TCL_OK
        }
    }

    if {[llength $arpList] > 0 && $retCode == 0 && $write == "write"} {
        writeConfigToHardware arpList
    }

    return $retCode
}


########################################################################################
# Procedure: sendArp
#
# Description: This command uses the protocol server to send out arp requests & enable
#              arp response
#
# Argument(s):
#    PortArray    array of ports, ie., one2oneArray for a one2one configuration
#
# Returns:        TCL_OK or TCL_ERROR
#
########################################################################################
proc sendArp { PortArray arpList {RemovedPorts ""} } \
{

    upvar $PortArray    portArray
    #upvar $ArpList      arpList
    if {[string length $RemovedPorts] > 0} {
        upvar $RemovedPorts removedPorts
    }

    set retCode $::TCL_OK

    if {[info exists removedPorts]} {
        unset removedPorts
    }
    set removedPorts    0

    if {[clearArpTable arpList]} {
        errorMsg "Error clearing arp table"
        set retCode $::TCL_ERROR
    }

    set numAddress          [advancedTestParameter cget -numAddressesPerPort]
    set duration            [expr ceil (double([learn cget -numframes]) / [learn cget -rate])]

    if {[issuePortGroupCommand resetStatistics arpList]} {
	    errorMsg "Error: Unable to issue port group commands: resetStatistics"
	    set retCode $::TCL_ERROR
    }
    set numFrames  $numAddress

    if {[advancedTestParameter cget -verifyAllArpReply] == "true"} {
        set numFrames [expr $numAddress * [learn cget -numframes]]
    }

    if {[expr ceil (double($numFrames)/[learn cget -rate])] > $duration } {
        set duration    [expr $numFrames/[learn cget -rate]]
    }

    if {[transmitArpRequest arpList]} {
        errorMsg "Error transmitting arp request"
        set retCode $::TCL_ERROR
    }

    if {$duration > 2 } {
        logMsg "Transmiting ARP frames for $duration seconds..."
        # Wait for at least 1 frame per address gets transmitted..
        set retCode [writeWaitMessage "Transmit ARP Status" "Transmitting" $duration destroy]
    }

    if {[learn cget -waitTime] > 1000 } {
        logMsg "Waiting for DUT to settle down after learning for [expr [learn cget -waitTime]/1000] second(s)..."
    }

    after [learn cget -waitTime]

    if {$numAddress > 1 } {
        if {[verifyAllArpFramesSent $arpList]} {
            errorMsg "Error verifying all Arp frames sent."
            return $::TCL_ERROR
        }
    } 
       
    if {[advancedTestParameter cget -verifyAllArpReply] == "true"} {
        if {[verifyArpReply $arpList]} {
            errorMsg "Error verifying all Arp replies"
            return $::TCL_ERROR
        }
    }

    set retries     [learn cget -retries]
    while {[llength $arpList] > 0 && $retries > 0} {
        incr retries -1

        foreach txMap [lnumsort $arpList] {
            scan $txMap "%d %d %d" tx_c tx_l tx_p

            if {[ipAddressTable get $tx_c $tx_l $tx_p]} {
                errorMsg "Error getting ipAddressTable on [getPortId $tx_c $tx_l $tx_p]"
                set retCode $::TCL_ERROR
                continue
            }
            # look for ARP responses
            if {[arpServer get $tx_c $tx_l $tx_p]} {
                errorMsg "Error getting arpServer from [getPortId $tx_c $tx_l $tx_p]"
                set retCode $::TCL_ERROR
                continue
            }

            if {![catch {hasInternalModem portArray $tx_c $tx_l $tx_p} internalModemFlag] && $internalModemFlag} {
                if {[internalModemCheckArpResponse portArray $tx_c $tx_l $tx_p]} {
                    set retCode $::TCL_ERROR
                } else {
                    set mapIndex    [lsearch  $arpList $txMap]
                    set arpList     [lreplace $arpList $mapIndex $mapIndex]
                    set retCode $::TCL_OK
                }
            } else {
                set gateway [ipAddressTable cget -defaultGateway]


                if {[arpServer getEntry $gateway]} {
                    logMsg "Waiting for ARP response from $gateway on [getPortId $tx_c $tx_l $tx_p] ..."
                    after [learn cget -waitTime]
                    continue
                }
                if {[arpAddressTableEntry get]} {
                    errorMsg "Error getting arpAddressTableEntry"
                    set retCode $::TCL_ERROR
                    continue
                }
                set dutMacAddress   [arpAddressTableEntry cget -macAddress]

                if {[port get $tx_c $tx_l $tx_p]} {
                    errorMsg "Error getting port [getPortId $tx_c $tx_l $tx_p] for storing DestMacAddress."
                    set retCode $::TCL_ERROR
                    continue
                }
                port config -DestMacAddress    $dutMacAddress
                if {[port set $tx_c $tx_l $tx_p]} {
                    errorMsg "Error setting port [getPortId $tx_c $tx_l $tx_p]"
                    set retCode $::TCL_ERROR
                }
                logMsg "Got ARP RESPONSE on [getPortId $tx_c $tx_l $tx_p], Gateway: $gateway, DUT MAC address for [getPortId $tx_c $tx_l $tx_p]: $dutMacAddress"
                set mapIndex    [lsearch  $arpList $txMap]
                set arpList     [lreplace $arpList $mapIndex $mapIndex]
            } 
        }
    }
    
    foreach txMap [lnumsort $arpList] {
        scan $txMap "%d %d %d" c l p
        if {![catch {hasInternalModem portArray $c $l $p} internalModemFlag] && $internalModemFlag} {
            getInternalModemNoArpResponse portArray $c $l $p
        } else {
            if {[ipAddressTable get $c $l $p]} {
                errorMsg "Error getting ipAddressTable on [getPortId $c $l $p]"
                set retCode $::TCL_ERROR
                continue
            }
            set gateway [ipAddressTable cget -defaultGateway]
            logMsg "No ARP response received from $gateway on $txMap"
        }

    }
    
    if {[llength $arpList] > 0 && $retCode == 0} {
        if {[learn cget -removeOnError] == "true"} {
            removePorts portArray $arpList
            set removedPorts      1
        } else {
            set retCode     $::TCL_ERROR
        }
    }

    return $retCode
}


########################################################################################
# Procedure: verifyAllArpFramesSent
#
# Description: This command verifies all the ARP frames sent for all the addresses
#
# Argument(s):
#    portList   - list of ports
#
########################################################################################
proc verifyAllArpFramesSent { portList } \
{

    set retCode $::TCL_OK

    set numAddress  [advancedTestParameter cget -numAddressesPerPort]
    if {[advancedTestParameter cget -verifyAllArpReply] == "true"} {
        set numFrames   [expr $numAddress * [learn cget -numframes]]
    } else {
        set numFrames $numAddress
    }

    set retries     [learn cget -retries]
    while {[llength $portList] > 0 && $retries > 0} {
        
        set retCode [requestStats portList]
        
        foreach portMap $portList {
            scan $portMap	"%d %d %d" c l p

            if {[statList get $c $l $p]} {
                errorMsg "Error getting stats for [getPortId $c $l $p]."
                set retCode     $::TCL_ERROR
                continue
            }

			if [catch {statList cget -framesSent} framesSent ] {
				if [catch {statList cget -atmAal5FramesSent} framesSent ] {
					set framesSent 0
				}
			}

            # Since 32 bit counter (mpexpr) is used here, if we get a 32 bit long number (in binary) whose most significiant
            # bit is 1, it will be recognized as a negtive number. 
            # So we use regexp to determine wheather numTxFrames is a negative number instead of using "$numTxFrames < 0"
            if { [regexp {^-[0-9]+$} $framesSent] } {
                set framesSent 0
            }
            if { $framesSent >= $numFrames } {
                set mapIndex    [lsearch  $portList $portMap]
                set portList    [lreplace $portList $mapIndex $mapIndex] 
            }   
            after 1000
        }
        incr retries -1
    }

    foreach txMap [lnumsort $portList] {
        scan $txMap "%d %d %d" c l p
   
        logMsg "Not all ARP frames sent for all $numAddress addresses on $txMap"
        set retCode     $::TCL_ERROR
    }

    return $retCode
}

########################################################################################
# Procedure: verifyArpReply
#
# Description: This command verifies all the ARP replies - number of ARP replies from all
#              the addresses
#
# Argument(s):
#    portList   - list of ports
#
########################################################################################
proc verifyArpReply { portList } \
{

    set retCode $::TCL_OK

    set numAddress  [advancedTestParameter cget -numAddressesPerPort]

    set retries     [learn cget -retries]
    while {[llength $portList] > 0 && $retries > 0} {
        
        set retCode [requestStats portList]
        
        foreach portMap $portList {
            scan $portMap	"%d %d %d" c l p

            if {[statList get $c $l $p]} {
                errorMsg "Error getting stats for [getPortId $c $l $p]."
                set retCode     $::TCL_ERROR
                continue
            }

            set numRxArpReply [statList cget -rxArpReply]

            # Since 32 bit counter (mpexpr) is used here, if we get a 32 bit long number (in binary) whose most significiant
            # bit is 1, it will be recognized as a negtive number. 
            # So we use regexp to determine wheather numTxFrames is a negative number instead of using "$numTxFrames < 0"
            if { [regexp {^-[0-9]+$} $numRxArpReply] } {
                set numRxArpReply 0
            }
            if { $numRxArpReply >= $numAddress } {
                set mapIndex    [lsearch  $portList $portMap]
                set portList    [lreplace $portList $mapIndex $mapIndex] 
            }   
            after 1000
        }
        incr retries -1
    }

    foreach txMap [lnumsort $portList] {
        scan $txMap "%d %d %d" c l p
   
        if {[ipAddressTable get $c $l $p]} {
            errorMsg "Error getting ipAddressTable on [getPortId $c $l $p]"
            set retCode $::TCL_ERROR
            continue
        }
        set gateway [ipAddressTable cget -defaultGateway]
        logMsg "Not all ARP responses received for all $numAddress addresses from $gateway on $txMap"
        set retCode     $::TCL_ERROR
    }

    return $retCode
}

########################################################################################
#::::::::::::                    IPV6 Layer Learn frames                   :::::::::::::
########################################################################################
########################################################################################
# Procedure:    send_neighborDiscovery_frames
#
# Description:  Solicit and save the link-layer addresses for the ports of the 
#                   given portArray
#
# Argument(s):  PortArray:      ports array, ie: one2oneArray, many2oneArray...
#               RemovedPorts:   return removed ports here
#
# Returns:      ::TCL_OK or ::TCL_ERROR
#
########################################################################################
proc send_neighborDiscovery_frames {PortArray {RemovedPorts ""} {resetInterfaces true}} \
{
    upvar $PortArray portArray
    if {[string length $RemovedPorts] > 0} {
        upvar $RemovedPorts removedPorts
    }

    set retCode $::TCL_OK

    if {![catch {namespace parent userCode}]} {
        set retCode [userCode::performNeighborDiscovery portArray]
        
    } else {
        set retCode [performNeighborDiscovery portArray removedPorts $resetInterfaces]
    }
    return $retCode
}

########################################################################################
# Procedure:    performNeighborDiscovery
#
# Description:  Solicit and save the link-layer addresses for the ports of the 
#                   given portArray
#
#                   In this implementation, the neighbor discovery table is populated
#                   after a set of router solicitation/advertisement commands are 
#                   sent and recieved.  The 'source link-layer option' of the router
#                   advertisement is used to extract the DUT's link layer address.
#
# Argument(s):  PortArray:      ports array, ie: one2oneArray, many2oneArray...
#               RemovedPorts:   return removed ports here
#
# Returns:      ::TCL_OK or ::TCL_ERROR
#
########################################################################################
proc performNeighborDiscovery {PortArray {RemovedPorts ""} {resetInterfaces true}} \
{
    upvar $PortArray    portArray
    if {[string length $RemovedPorts] > 0} {
        upvar $RemovedPorts removedPorts
    }

    set retCode $::TCL_OK

    set retries     [learn cget -retries]
    set waitTime    [learn cget -waitTime]
    set portList    [getAllPorts portArray]

    if {[llength $portList] > 0} {

        discoveredNeighbor  setDefault
        if {![interfaceTable::configure portList $::ipV6 1 nowrite $resetInterfaces]} {

            set discoveryList $portList

			foreach portItem $portList {
				scan $portItem "%d %d %d" tx_c tx_l tx_p

				if [IsPOSPort $tx_c $tx_l $tx_p] {
					set index   [lsearch $discoveryList $portItem]
					set discoveryList [lreplace $discoveryList $index $index]
					continue
				}
			}
			if {[llength $discoveryList] } {
				if {![set retCode [sendRouterSolicitation discoveryList]]} {
					while {$retries >= 0} {
                
						set retCode $::TCL_OK
						if {![getNeighborDiscovery discoveryList]} {
							break
						} else {
							set retCode $::TCL_ERROR
							incr retries -1
						}
						after $waitTime

						sendRouterSolicitation discoveryList
					}

					# Handle ports that didn't respond with Neighbor Advertisement.
					if {[llength $discoveryList] > 0} {
                
						if {[learn cget -removeOnError] == "true"} {
							removePorts portArray $discoveryList
							set removedPorts $::true
						} else {
							errorMsg "Error: Unable to discover neighbors on ports: $discoveryList"
							set retCode $::TCL_ERROR
						}
					}
				}
			}

        } else {
            errorMsg "Error configuring Interface Table"
            set retCode $::TCL_ERROR
        }
    }

    return $retCode
}

########################################################################################
# Procedure:    SendRouterSolicitation
#
# Description:  Send router solicitation to each port in the portList.
#
#               This command causes the router to respond with a router advertisement 
#               where the source link-layer option is used to extract the link layer 
#               address of the DUT.
#
# Argument(s):  PortArray:      ports array, ie: one2oneArray, many2oneArray...
#
# Returns:      ::TCL_OK or ::TCL_ERROR
#
########################################################################################
proc sendRouterSolicitation {PortList} \
{
    upvar $PortList portList

    set retCode $::TCL_OK

    foreach portMap $portList {
        scan $portMap "%d %d %d" c l p

        if {![interfaceTable select $c $l $p]} {

            if {[interfaceTable sendRouterSolicitation]} {
                errorMsg "Error: Unable to send router solicitation on $c $l $p"
                set retCode $::TCL_ERROR
                break
            } 

        } else {
            errorMsg "Error: Unable to selected interface on $c $l $p"
            set retCode $::TCL_ERROR
            break
        }
    }
    after [learn cget -waitTime]

    return $retCode
}


########################################################################################
# Procedure:    getNeighborDiscovery
#
# Description:  Store the link-layer addresses solicited.
#
# Argument(s):  PortList:  port list
#
# Returns:      ::TCL_OK or ::TCL_ERROR
#
########################################################################################
proc getNeighborDiscovery {PortList} \
{
    upvar $PortList     portList

    set retCode $::TCL_OK

    set waitTime     [learn cget -waitTime]

    logMsg "\nPerforming Neighbor Discovery on ports: $portList."

    # Read neighbors from neighbor discovery table.
    foreach portMap $portList {

        scan $portMap "%d %d %d" c l p

        set macAddress [getNeighborDiscoveryPort $c $l $p]
        if {[isMacAddressValid $macAddress] == $::TCL_OK} {

            logMsg "Neighbor Discovery Complete for [getPortId $c $l $p]: $macAddress"
            if {![port get $c $l $p]} {
                port config -DestMacAddress $macAddress
            }
            if {[port set $c $l $p]} {
                errorMsg "Error: Unable configure port $c $l $p with link-layer address"
                set retCode $::TCL_ERROR
            }

            set index    [lsearch $portList $portMap]
            set portList [lreplace $portList $index $index]

        } else {
            set retCode $::TCL_ERROR
            continue
        }
    }

    return $retCode
}

########################################################################################
# Procedure:    getNeighborDiscoveryPort
#
# Description:  Return link-layer address of DUT.
#
# Argument(s):  chassis
#               card
#               port
#
# Returns:      ::TCL_OK or ::TCL_ERROR
#
########################################################################################
proc getNeighborDiscoveryPort {chassis card port {verbose false}} \
{
    set macAddress 0

    set message ""
    if {![interfaceTable select $chassis $card $port]} {

        interfaceTable requestDiscoveredTable
        after [learn cget -waitTime]
        
        set description [interfaceTable::formatEntryDescription $chassis $card $port]
        if {![interfaceTable getDiscoveredList $description]} {
            
#            if {![ipV6 get $chassis $card $port]} {    
                            
#                 if {![discoveredList getNeighbor [ipV6 cget -destAddr]]} {}
                 if {![discoveredList getFirstNeighbor]} {
                     set macAddress [discoveredNeighbor cget -macAddress]
                 } else {
                     set message \
                         "Error: Unable to get neighbor in discovery list for $chassis $card $port"
                 }

#             } else {
#                 set message \
#                     "Error: Unable to get IPv6 configuration for $chassis $card $port"
#             }
        
        } else {
            set message \
                "Error: Unable to get neighbor discovery list for $chassis $card $port"
        }

    } else {
        set message \
            "Error: Unable to select interface table for $chassis $card $port"
    }

    if {$verbose == "true"} {
        if {[string length $message] > 0} {
            errorMsg $message
        }
    }

    return $macAddress
}



########################################################################################
#::::::::::::                    IPX Layer Learn frames                       :::::::::::::
########################################################################################

########################################################################################
# Procedure: sapStr2Asc
#
# Description: Converts a string into hex and pads to make it into 48 bytes. SAP frame
# has 48 bytes reserved for server name.
#
# Argument(s):
#    string to convert
#
########################################################################################

proc sapStr2Asc {strName} \
{
    set nameList {}
    for {set i 0} {$i < [string length $strName]} {incr i} {
        binary scan [string index $strName $i] tx_c val
        set hexVal [format %02x [set val]]
        set nameList [lappend nameList $hexVal]
    }

    set currLen [string length $strName]
    while {$currLen < 48} {
        set nameList [lappend nameList "00"]
        incr currLen
    }
    return $nameList
}

########################################################################################
# Procedure: send_ripx_frames
#
# Description: This command sends ripx frames all ports in order to advertise the
#               sourceNode for IPX routing
# The algorithm of establishing an IPX connection is as follows:
#    - send RIPX broadcast (requests) to the destination node's (router's) network number
#        from all ports in the port map
#    - the router responds to this request giving its network and node (MAC) adddress in
#        the IPX header
#    - to send traffic now, the sending node
#        * places the destination node's (router's) network, node addresses and socket number
#            in the destination address fields of the IPX header
#        * places its own network, node addresses and socket number in the source address
#            fields of the IPX header
#        * places the node (MAC) address of the router (port) in the destination address
#            address field of MAC header
#        * places its own node address in the source address field of the MAC header
#
# Argument(s):
#    PortArray    array of ports, ie., one2oneArray for a one2one configuration
#
########################################################################################
proc send_ripx_frames {PortArray {RemovedPorts ""}} \
{
    global udfList

    upvar $PortArray portArray
    if {[string length $RemovedPorts] > 0} {
        upvar $RemovedPorts removedPorts
    }

    set retCode         0
    set removedPorts    0

    # set the stream parameters.
    set preambleSize    8
    set framesize       [learn cget -framesize]

    set duration    [expr [learn cget -numframes] / [learn cget -rate]]

    stream setDefault
    stream config -rateMode         usePercentRate
    stream config -dma              stopStream
    stream config -fcs              good
    stream config -enableTimestamp  false
    stream config -gapUnit          gapNanoSeconds

    # need to turn off signature...!!
    packetGroup setDefault

    udf setDefault
    if [disableUdfs $udfList] {
        errorMsg "Error disabling udfs in switchLearn for RIPx frames"
        set retCode 1
    }

    filterPallette setDefault

    filter setDefault
    filter config -captureFilterError   errGoodFrame
    filter config -captureTriggerError  errGoodFrame

    # zero stats everywhere to avoid confusion later...
    zeroStats portArray

    # note - send one port at portArray time to allow time for learning

    debugMsg "Configuring RIPX frames..."

    # send RIPX on all ports involved in this map, but just send once...
    set ripxMap     [getAllPorts portArray]

    # >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>><<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    # >>>>>>>>>>>>>>>>>>>>>>>>>>  Send RIPX Frames <<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    # >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>><<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    # first send the RIPX broadcast request to the router asking for its addresses
    foreach txMap $ripxMap {
        scan $txMap "%d %d %d" tx_c tx_l tx_p

        if {[port get $tx_c $tx_l $tx_p] == 1} {
            errorMsg "port [getPortId $tx_c $tx_l $tx_p] has not been configured yet."
            continue
        }

        set learnPercentRate             [expr double([learn cget -rate])/[calculateMaxRate $tx_c $tx_l $tx_p $framesize]*100.]
        stream config -percentPacketRate $learnPercentRate

        stream config -name         "RIPXStream"

        stream config -da       $::kBroadcastMacAddress
        stream config -numDA    1

        set numAddresses        [port cget -numAddresses]
          stream config -sa     [port cget -MacAddress]
        stream config -numSA    $numAddresses

        stream config -patternType    nonRepeat
        stream config -dataPattern    userpattern
        stream config -numFrames      [expr [learn cget -numframes] * $numAddresses]
        if {[expr [stream cget -numFrames]/[learn cget -rate]] > $duration} {
            set duration    [expr [stream cget -numFrames]/[learn cget -rate]]
        }

        if [ipx get $tx_c $tx_l $tx_p] {
            errorMsg "Error getting IPx on [getPortId $tx_c $tx_l $tx_p] for RIPX frames."
            set retCode 1
            continue
        }

        # save the original setup and restore it at the end
        set origSrcSocket($tx_c,$tx_l,$tx_p)    [ipx cget -sourceSocket]

        # build the RIPX packet which is the data portion of the IPX packet
        ipx config -packetType        1        ;# RIP type packet

        set RIPXNetworkNumber   {ff ff ff ff}
        set numHops             1
        set numTicks            2

        ipx config -destNetwork     {00 00 00 00}
        ipx config -destNode        $::kBroadcastMacAddress
        ipx config -destSocket      [format %d $::kRipSocket]

        ipx config -sourceNetwork   {00 00 00 00}
        ipx config -sourceNode      [port cget -MacAddress]
        if {$numAddresses > 1} {
            ipx config -sourceNodeRepeatCounter $numAddresses
            ipx config -sourceNodeCounterMode   ipxIncrement
        } else {
            ipx config -sourceNodeCounterMode   ipxIdle
        }
        ipx config -destNetworkCounterMode  ipxIdle
        ipx config -destNodeCounterMode     ipxIdle
        ipx config -destSocketCounterMode   ipxIdle

        ipx config -sourceSocket        [format %d $::kRipSocket]
        ipx config -lengthOverride      true
        ipx config -length              40

        if [ipx set $tx_c $tx_l $tx_p] {
            errorMsg "Error setting IPX parameters on [getPortId $tx_c $tx_l $tx_p]"
            set retCode 1
            continue
        }

       
        # now build the IPX packet with the RIPX in it
        set streamPattern    [buildRipxPacket $::kRIPXOperation(request) $RIPXNetworkNumber $numHops $numTicks]    

        stream config -pattern $streamPattern
        stream config -framesize [learn cget -framesize]
        if [stream set $tx_c $tx_l $tx_p 1] {
            errorMsg "Error setting stream 1 on [getPortId $tx_c $tx_l $tx_p]"
            set retCode 1
            continue
        }

        # need to turn off signature for ripx frames...!!
        if [packetGroup setTx $tx_c $tx_l $tx_p 1] {
            errorMsg "Error disabling packetGroup signatures on stream 1, [getPortId $tx_c $tx_l $tx_p]"
            set retCode 1
            continue
        }

        # set up the pattern filter
        filterPallette config -DA1 [port cget -MacAddress]
        if [filterPallette set $tx_c $tx_l $tx_p] {
            errorMsg "Error setting filter pallette for [getPortId $tx_c $tx_l $tx_p]"
            set retCode 1
            continue
        }

        # set the filter parameters on the receive port
        debugMsg "    configuring filters"
        filter config -captureFilterEnable  true
        filter config -captureTriggerEnable true
        if [filter set $tx_c $tx_l $tx_p] {
            errorMsg "Error setting filters on [getPortId $tx_c $tx_l $tx_p]"
            set retCode 1
            continue
        }

        if [filterPallette write $tx_c $tx_l $tx_p] {
            errorMsg "Error writing filterPallette to hardware for RIPX frames"
            set retCode 1
            continue
        }

    }

    writeConfigToHardware portArray
    if [startCapture ripxMap] {
        errorMsg "Error starting capture."
        set retCode 1
    }

    foreach txMap [lnumsort $ripxMap] {
        scan $txMap "%d %d %d" tx_c tx_l tx_p

        logMsg "sending RIPX broadcast frame from [getPortId $tx_c $tx_l $tx_p]"
    }
	set retCode [startStaggeredTx ripxMap]

    # wait the min refresh for 10/100 cards to let the stats update...
    after 800

    after [learn cget -waitTime]
    # Wait for all frames to be transmitted..
    for {set timeCtr 1} {$timeCtr <= $duration} {incr timeCtr} {
        logMsg  "Transmitted $timeCtr of $duration seconds"
        after 1000
    }

    checkAllTransmitDone ripxMap

    foreach txMap [lnumsort $ripxMap] {
        scan $txMap "%d %d %d" tx_c tx_l tx_p

        # decode the RIPX response and get the router's node address
        set maxRip  100

        if [port get $tx_c $tx_l $tx_p] {
            errorMsg "port [getPortId $tx_c $tx_l $tx_p] has not been configured yet."
            continue
        }

        if [captureBuffer get $tx_c $tx_l $tx_p 1 $maxRip] {
            errorMsg "Error getting capture buffer from frame(s) 1 to 1 for [getPortId $tx_c $tx_l $tx_p]"
            set retCode 1
            continue
        }

        set found 0
        set nFrame 1
        while {[captureBuffer getframe $nFrame] != 1 && $nFrame <= $maxRip} {
            debugMsg "Getting frame $nFrame from Buffer   ....."
            set capframe    [captureBuffer cget -frame]

            if {[ipx decode $capframe] == 0 && ([ipx cget -destSocket] == 1107) && ([ipx cget -destNode] == [string toupper [port cget -MacAddress]])} {
                logMsg "Got RIPX RESPONSE on [getPortId $tx_c $tx_l $tx_p]"
                set found 1

                ipx config -sourceSocket    $origSrcSocket($tx_c,$tx_l,$tx_p)
                ipx config -destNetwork     [ipx cget -sourceNetwork]
                ipx config -sourceNetwork   [ipx cget -destNetwork]

                set sourceNode              [ipx cget -destNode]
                set destNode                [ipx cget -sourceNode]
                ipx config -sourceNode      $sourceNode
                ipx config -destNode        $destNode

                if [ipx set $tx_c $tx_l $tx_p] {
                    errorMsg "Error setting IPX parameters for [getPortId $tx_c $tx_l $tx_p]"
                    set retCode 1
                    continue
                }

                if [port get $tx_c $tx_l $tx_p] {
                    errorMsg "Error getting port [getPortId $tx_c $tx_l $tx_p]"
                    set retCode 1
                    continue
                }
                port config -DestMacAddress    [ipx cget -destNode]
                if [port set $tx_c $tx_l $tx_p] {
                    errorMsg "Error setting port [getPortId $tx_c $tx_l $tx_p]"
                    set retCode 1
                    continue
                }
                break
            }
            incr nFrame
        }

        if {$found == 0} {
            errorMsg "No RIPX response frames received on [getPortId $tx_c $tx_l $tx_p]"
            set retCode 1
return -code error
            continue
        }
    }

    if {$retCode == 0 && [fastpath cget -enable] == "true"} {
        if [send_fastpath_frames portArray] {
            errorMsg "Error sending fastpath frames"
            set retCode 1
        }
    }

    stream setDefault

    logMsg "RIPX frames sent ..."
    return $retCode
}

########################################################################################
# Procedure: send_sap_server_frames
#
# Description: This command sends IPX SAP broadcast frames in order to advertise the
#               port as portArray server node for IPX routing.
#
# Argument(s):
#    PortArray    array of ports, ie., one2oneArray for portArray one2one configuration
#
########################################################################################
proc send_sap_server_frames {PortArray} \
{
    global udfList

    upvar $PortArray portArray
    set retCode 0

    # set the stream parameters.
    set preambleSize                8
    set framesize                   [learn cget -framesize]

    stream config -rateMode         usePercentRate
    stream config -dma              stopStream
    stream config -fcs              good
    stream config -enableTimestamp  false
    stream config -numFrames        [learn cget -numframes]
    stream config -gapUnit          gapNanoSeconds

    udf setDefault
    disableUdfs $udfList

    filterPallette setDefault

    filter setDefault
    filter config -captureTriggerDA     addr1
    filter config -captureFilterError   errGoodFrame
    filter config -captureTriggerError  errGoodFrame

    # zero stats everywhere to avoid confusion later...
    zeroStats portArray

    # note - send one port at portArray time to allow time for learning

    debugMsg "Configuring SAP frames..."

    # send sap on all ports involved in this map, but just send once...
    foreach txMap [array names portArray] {
        if {![info exists sapMap($txMap]} {
            set sapMap($txMap)    1
        }

        foreach rxMap $portArray($txMap) {
            scan $rxMap "%d %d %d" tx_c tx_l tx_p
            if {![info exists sapMap($tx_c,$tx_l,$tx_p)]} {
                set sapMap($tx_c,$tx_l,$tx_p)    1
            }
        }
    }

    # >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>><<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    # >>>>>>>>>>>>>>>>>>>  SAP Broadcast - Advertise Servers <<<<<<<<<<<<<<<<<<<
    # >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>><<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    foreach txMap [lnumsort [array names sapMap]] {
        scan $txMap "%d,%d,%d" tx_c tx_l tx_p
        if {[port get $tx_c $tx_l $tx_p] == 1} {
            logMsg "port [getPortId $tx_c $tx_l $tx_p] has not been configured yet."
            continue
        }

        if [ipx get $tx_c $tx_l $tx_p] {
            errorMsg "Error getting IPx on [getPortId $tx_c $tx_l $tx_p] for SAP frames."
            set retCode 1
            continue
        }
        # if this port is set up as SERVER, then send SAP broadcast announcing iteslf
        if {[ipx cget -svrClientType] == 1} {
            set txSA  [port cget -MacAddress]

            set learnPercentRate [expr double([learn cget -rate])/[calculateMaxRate $tx_c $tx_l $tx_p $framesize]*100.]
            stream config -percentPacketRate $learnPercentRate

            stream config -name    "SapBroadcastStream"

            stream config -da      $::kBroadcastMacAddress
            stream config -numDA   1

            stream config -sa      $txSA
            stream config -numSA   1

            stream config -patternType    nonRepeat
            stream config -dataPattern    userpattern

            set netAddress  [ipx cget -sourceNetwork]
            set nodeAddress [port cget -MacAddress]

            set hops {00 01}
            ipx config -packetType     4

            ipx config -destSocket     $::kSapSocket
            ipx config -sourceNode     $txSA
            ipx config -sourceNetwork  {00 00 00 00}
            ipx config -destNetwork    {00 00 00 00}

            set serverName [sapStr2Asc "ixiaServer$tx_c$tx_l$tx_p"]

            if [ipx set $tx_c $tx_l $tx_p] {
                errorMsg "Error setting IPX packet on [getPortId $tx_c $tx_l $tx_p]"
                set retCode 1
            }

            # build the SAP broadcast packet (which is service type General Service Response)
            set streamPattern [buildSapPacket $::kSapOperation(response) $::kSapServiceType(fileServer) \
                                         $serverName $netAddress $nodeAddress $::kSapSocket $hops]
                                                         
            stream config -pattern $streamPattern

            set IPXheaderLen    30
            set DASATypeLen     14
            set CRCLen          4
            stream config -framesize [expr [llength [ipx cget -data]] + $IPXheaderLen + $DASATypeLen + $CRCLen]

            if [stream set $tx_c $tx_l $tx_p 1] {
                errorMsg "Error setting stream 1 on [getPortId $tx_c $tx_l $tx_p] for SAP frames."
                set retCode 1
            }

            if [stream write $tx_c $tx_l $tx_p 1] {
                errorMsg "Error writing stream to hardware for SAP frames"
                set retCode 1
                continue
            }

            logMsg "sending SAP broadcast frame from [getPortId $tx_c $tx_l $tx_p] server, Network address: [ipx cget -sourceNetwork]"
            if [startPortTx $tx_c $tx_l $tx_p] {
                errorMsg "Error starting Tx on port [getPortId $tx_c $tx_l $tx_p]"
                set retCode 1
            }

            # wait for portArray second portArray look for nearest SAP response on each port
            after 1000

            # make sure something got transmitted
            set txNumFrames    [stat cget -counterVal]
            if {$txNumFrames == 0} {
                errorMsg "Error transmitting SAP broadcast frames for SERVER on [getPortId $tx_c $tx_l $tx_p]"
                set retCode 1
                continue
            }
        }
    }

    logMsg "SAP broadcast frames sent..."
    return $retCode
}

########################################################################################
# Procedure: send_sapgns_frames
#
# Description: This command sends SAP GNS frames on all ports for IPX routing
#
# Argument(s):
#    PortArray    array of ports, ie., one2oneArray for portArray one2one configuration
#
########################################################################################
proc send_sapgns_frames {PortArray} \
{
    global udfList

    upvar $PortArray portArray
    set retCode 0

    # set the stream parameters.
    set preambleSize        8
    set framesize           [learn cget -framesize]

    stream config -rateMode         usePercentRate
    stream config -dma              stopStream
    stream config -fcs              good
    stream config -enableTimestamp  false
    stream config -numFrames        [learn cget -numframes]
    stream config -gapUnit          gapNanoSeconds

    udf setDefault
    disableUdfs $udfList

    filterPallette setDefault

    filter setDefault
    filter config -captureTriggerDA     addr1
    filter config -captureFilterError   errGoodFrame
    filter config -captureTriggerError  errGoodFrame

    # zero stats everywhere to avoid confusion later...
    zeroStats portArray

    # note - send one port at portArray time to allow time for learning

    debugMsg "Configuring SAP frames..."

    # send sap on all ports involved in this map, but just send once...
    foreach txMap [array names portArray] {
        if {![info exists sapMap($txMap]} {
            set sapMap($txMap)    1
        }

        foreach rxMap $portArray($txMap) {
            scan $rxMap "%d %d %d" tx_c tx_l tx_p
            if {![info exists sapMap($tx_c,$tx_l,$tx_p)]} {
                set sapMap($tx_c,$tx_l,$tx_p)    1
            }
        }
    }

    # >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>><<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    # >>>>>>>>>>>>>>>>>>>>  SAP Get Nearest Server Request <<<<<<<<<<<<<<<<<<<<<
    # >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>><<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    foreach txMap [lnumsort [array names sapMap]] {
        scan $txMap "%d,%d,%d" tx_c tx_l tx_p
        if {[port get $tx_c $tx_l $tx_p] == 1} {
            logMsg "port [getPortId $tx_c $tx_l $tx_p] has not been configured yet."
            continue
        }

        set txSA [port cget -MacAddress]

        if [ipx get $tx_c $tx_l $tx_p] {
            errorMsg "Error getting IPx on [getPortId $tx_c $tx_l $tx_p] for SAP frames."
            set retCode 1
            continue
        }
        # if this port is set up as CLIENT, then send SAP Get Nearest server request
        if {[ipx cget -svrClientType] == 2} {
            filter config -captureFilterPattern         any
            filter config -captureFilterError           errGoodFrame
            filter config -captureFilterFrameSizeEnable false
            filter config -captureFilterFrameSizeEnable false
            filter config -captureTriggerError          errGoodFrame

            if [startPortCapture $tx_c $tx_l $tx_p] {
                errorMsg "Error starting Capture on port [getPortId $tx_c $tx_l $tx_p]"
                set retCode 1
            }

            set learnPercentRate             [expr double([learn cget -rate])/[calculateMaxRate $tx_c $tx_l $tx_p $framesize]*100.]
            stream config -percentPacketRate $learnPercentRate

            stream config -name     "SapGNSStream"

            stream config -da       [port cget -DestMacAddress]
            stream config -numDA    1

              stream config -sa     $txSA
            stream config -numSA    1

            stream config -patternType    nonRepeat
            stream config -dataPattern    userpattern

            set netAddress    [ipx cget -sourceNetwork]
            set nodeAddress   [port cget -MacAddress]
            set hops {00 01}

            ipx config -packetType      4

            ipx config -destNode        $::kBroadcastMacAddress
            ipx config -destSocket      $::kSapSocket

            ipx config -sourceNode      $txSA
            ipx config -sourceSocket    $::kSapSocket

            set serverName [sapStr2Asc "ixiaServer$tx_c$tx_l$tx_p"]        ;# this is ignored by the router

            if [ipx set $tx_c $tx_l $tx_p] {
                errorMsg "Error setting IPX packet on [getPortId $tx_c $tx_l $tx_p]"
                set retCode 1
            }

            set streamPattern [buildSapPacket $::kSapOperation(getNearestServerRequest) $::kSapServiceType(fileServer) \
                                           $serverName $netAddress $nodeAddress $::kSapSocket $hops]    
    
            stream config -pattern $streamPattern
            stream config -framesize 64

            if [stream set $tx_c $tx_l $tx_p 1] {
                errorMsg "Error setting stream 1 on [getPortId $tx_c $tx_l $tx_p] for SAP GNS frames."
                set retCode 1
            }


            if [stream write $tx_c $tx_l $tx_p 1] {
                errorMsg "Error writing stream to hardware for SAP GNS frames"
                set retCode 1
                continue
            }

            logMsg "sending SAP GNS request frame from [getPortId $tx_c $tx_l $tx_p] client, Network address: [ipx cget -sourceNetwork]"
            if [startPortTx $tx_c $tx_l $tx_p] {
                errorMsg "Error starting Tx on port [getPortId $tx_c $tx_l $tx_p]"
                set retCode 1
            }

            # wait for portArray second portArray look for nearest SAP response on each port
            after 1000

            # make sure something got transmitted
            set txNumFrames    [stat cget -counterVal]
            if {$txNumFrames == 0} {
                errorMsg "Error transmitting SAP GNS frames for CLIENT on [getPortId $tx_c $tx_l $tx_p]"
                set retCode 1
                continue
            }

            # decode the SAP GNS response and get the server's net address
            if [capture get $tx_c $tx_l $tx_p] {
                errorMsg "Error getting capture data on [getPortId $tx_c $tx_l $tx_p]"
                set retCode 1
                continue
            }
    
            set numCapturedFrames [capture cget -nPackets]
            debugMsg "numCapturedFrames = $numCapturedFrames"

            if {$numCapturedFrames < 1} {
                logMsg "No SAP GNS response frames received on [getPortId $tx_c $tx_l $tx_p]"
            } else {
                # look for SAP GNS responses
                if [captureBuffer get $tx_c $tx_l $tx_p 1 $numCapturedFrames] {
                    errorMsg "Error getting capture buffer from frame(s) 1 to 1 for [getPortId $tx_c $tx_l $tx_p]"
                    set retCode 1
                    continue
                }
                set found 0
                for {set nFrame 1} {$nFrame <= $numCapturedFrames} {incr nFrame} {
                    debugMsg "Getting frame $nFrame from Buffer   ....."
                    if [captureBuffer getframe $nFrame] {
                        errorMsg "Error getting frame $nFrame from capture buffer for [getPortId $tx_c $tx_l $tx_p]"
                        set retCode 1
                        continue
                    }
                    set capframe    [captureBuffer cget -frame]
                    debugMsg $capframe

                    if [ipx get $tx_c $tx_l $tx_p] {
                        errorMsg "Error getting IPx on [getPortId $tx_c $tx_l $tx_p] for SAP frames."
                        set retCode 1
                        continue
                    }

                    set ipxPacketType   [lindex $capframe 19]
                    set sapOperType     [lrange $capframe 44 45]
                    set destSocket      [lrange $capframe 106 107]
                    set serverType      [lrange $capframe 46 47]
                    set serverNetAddr   [lrange $capframe 96 99]

                    if {($sapOperType == "00 04") && ($destSocket == "04 52") && ($serverType == $::kSapServiceType(fileServer))} {
                        logMsg "Got SAP GNS RESPONSE on [getPortId $tx_c $tx_l $tx_p]"
                        set found 1
                        break
                    }
                }

                if {$found == 0} {
                    logMsg "No SAP GNS response frames received on [getPortId $tx_c $tx_l $tx_p]"
                    continue
                }

                ipx config -destNetwork $serverNetAddr
                if [ipx set $tx_c $tx_l $tx_p] {
                    errorMsg "Error setting IPX parameters for [getPortId $tx_c,$tx_c,$tx_p]"
                }
            }
        }
    }

    logMsg "SAP GNS frames sent..."
    return $retCode
}




