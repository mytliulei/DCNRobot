#############################################################################################
# Version 4.10	$Revision: 49 $
# $Date: 9/30/02 1:13p $
# $Author: Mgithens $
#
# $Workfile: sgPort.tcl $ - Utilities for scriptgen
#
#   Copyright © 1997 - 2005 by IXIA.
#   All Rights Reserved.
#
#	Revision Log:
#	04-03-2001	EM	Genesis
#
#
#############################################################################################


########################################################################
# Procedure: getPortScript
#
# This command generates port commands
# Arguments(s):
# chassis : chassis Id
# card    : card Id
# port    : port Id
# Returned Result:
########################################################################


proc scriptGen::getPortScript { chassis card port } \
{
    variable generateHdlcPerStream

    set retCode 0
    
	if {[port isValidFeature $chassis $card $port $::portFeaturePowerOverEthernet]} {

		if {![poePoweredDevice get $chassis $card $port]} {
			generateCommand poePoweredDevice
            sgPuts {poePoweredDevice set $chassis $card $port}
        } else {
            logMsg "Error getting poePoweredDevice"
            set retCode 1 
        }
        if {![poeSignalAcquisition get $chassis $card $port]} {
			generateCommand poeSignalAcquisition
            sgPuts {poeSignalAcquisition set $chassis $card $port}
        } else {
            logMsg "Error getting poeSignalAcquisition"
            set retCode 1 
        }
		return $retCode
	}


    sgPuts {port setFactoryDefaults $chassis $card $port}

# "port get" has been called in the ixSgMain to get the owner.
    if [port isValidFeature $chassis $card $port $::portFeatureDualPhyMode] {
        sgPuts [format "port setPhyMode $\::%s \$chassis \$card \$port" [getEnumString port -phyMode]]
        sgPuts ""
    }
 
    generateCommand port
    sgPuts {port set $chassis $card $port}    

    if {![port isActiveFeature $chassis $card $port $::portFeatureBert] && \
        ![port isActiveFeature $chassis $card $port $::portFeatureBertChannelized] && \
        ![port isValidFeature  $chassis $card $port $::portFeatureBertUnframed]} {

        if {![stat get statAllStats $chassis $card $port]} {
           generateCommand stat
           sgPuts {stat set $chassis $card $port}
        } else {
            logMsg "Error in getting stat"
            set retCode 1 
        }  
    
        if { $retCode == 0 && [stat cget -mode] == $::statQos} {
            if {![qos get $chassis $card $port]} {
                sgPuts "qos setup [getEnumString qos -packetType]"
                generateCommand qos no
                sgPuts {qos set $chassis $card $port}
            } else {
                logMsg "Error getting qos"
                set retCode 1 
            }  
        }

    } else {
        # We need the port transmitMode and receiveMode to be in correct mode in order the 
        # order the isActiveFeature portFeatureBertChannelized to work

        if [port isActiveFeature $chassis $card $port $::portFeatureBertChannelized]  {
            if [port isActiveFeature $chassis $card $port $::portFeatureXaui] {
                set levelList { 1 2 3 4}
            } else {
                set levelList { 1.0 2.0 3.0 4.0 }
            }

            foreach levelItem $levelList {
                if [bert isChannelized $chassis $card $port $levelItem] {
                    sgPuts "bert channelize \$chassis \$card \$port $levelItem"
                    for {set index 1 } {$index <= 4} { incr index } {
                        set nextLevel [format "%d.%d" [string range $levelItem 0 0] $index]
                        if {![getCommand bert $chassis $card $port $nextLevel]} {
                            sgPuts "bert set \$chassis \$card \$port $nextLevel"
                        } else {
                            logMsg "Error in getting bert on channel $nextLevel "
                            set retCode 1 
                        }
                    }
                } else {
                    if {![getCommand bert $chassis $card $port $levelItem]} {
                        sgPuts "bert set \$chassis \$card \$port $levelItem"
                    } else {
                        logMsg "Error in getting bert on channel $levelItem "
                        set retCode 1 
                    }
                }
            }
        } else {
            if {![getCommand bert $chassis $card $port]} {
                sgPuts {bert set $chassis $card $port}
            } else {
                logMsg "Error in getting bert"
                set retCode 1 
            }
        } 
    }

    if {[port isActiveFeature $chassis $card $port $::portFeatureBertErrorGeneration]} {

        if [port isActiveFeature $chassis $card $port $::portFeatureBertChannelized]  {
            if [port isActiveFeature $chassis $card $port $::portFeatureXaui] {
                set levelList { 1 2 3 4}
            } else {
                set levelList { 1.0 2.0 3.0 4.0 }
            }

            foreach levelItem $levelList {
                if [bert isChannelized $chassis $card $port $levelItem] {
                    for {set index 1 } {$index <= 4} { incr index } {
                        set nextLevel [format "%d.%d" [string range $levelItem 0 0] $index]
                        if {![getCommand bertErrorGeneration $chassis $card $port $nextLevel]} {
                            sgPuts "bertErrorGeneration set \$chassis \$card \$port $nextLevel"
                        } else {
                            logMsg "Error in getting bertErrorGeneration on channel $nextLevel "
                            set retCode 1 
                        }
                    }
                } else {
                    if {![getCommand bertErrorGeneration $chassis $card $port $levelItem]} {
                        sgPuts "bertErrorGeneration set \$chassis \$card \$port $levelItem"
                    } else {
                        logMsg "Error in getting bertErrorGeneration on channel $levelItem "
                        set retCode 1 
                    }
                }
            }

        } else {
            if {![getCommand bertErrorGeneration $chassis $card $port]} {          
                sgPuts {bertErrorGeneration set $chassis $card $port}
            } else {
                logMsg "Error in getting bertErrorGeneration"
                set retCode 1 
            }
        }  
    }
    
    if {[port isValidFeature $chassis $card $port $::portFeatureBertUnframed]} {

        if {![getCommand bertUnframed $chassis $card $port]} {          
            sgPuts {bertUnframed set $chassis $card $port}
        } else {
            logMsg "Error in getting bertUnframed"
            set retCode 1 
        }  
    }

    if {[port isValidFeature $chassis $card $port $::portFeatureForcedCollisions]} {

        if {![getCommand collisionBackoff $chassis $card $port]} {          
            sgPuts {collisionBackoff set $chassis $card $port}
        } else {
            logMsg "Error in getting collisionBackoff"
            set retCode 1 
        }  

        if {![getCommand forcedCollisions $chassis $card $port]} {          
            sgPuts {forcedCollisions set $chassis $card $port}
        } else {
            logMsg "Error in getting forcedCollisions"
            set retCode 1 
        }  
    }

    if {[port isActiveFeature $chassis $card $port $::portFeatureRxPacketGroups] || \
        [port isActiveFeature $chassis $card $port $::portFeatureRxSequenceChecking] || \
        [port isActiveFeature $chassis $card $port $::portFeatureRxWidePacketGroups]} {

        if {![packetGroup getRx $chassis $card $port]} { 
            generateCommand  packetGroup         
            sgPuts {packetGroup setRx $chassis $card $port}
        } else {
            logMsg "Error in getting packetGroup"
            set retCode 1 
        }  
    }

    if {[port isActiveFeature $chassis $card $port $::portFeatureRxDataIntegrity]} {

        if {![dataIntegrity getRx $chassis $card $port]} { 
            generateCommand  dataIntegrity         
            sgPuts {dataIntegrity setRx $chassis $card $port}
        } else {
            logMsg "Error in getting dataIntegrity"
            set retCode 1 
        }  
    }

    if {[port isActiveFeature $chassis $card $port $::portFeatureAutoDetectRx]} {

        if {![autoDetectInstrumentation getRx $chassis $card $port]} { 
            generateCommand  autoDetectInstrumentation         
            sgPuts {autoDetectInstrumentation setRx $chassis $card $port}
        } else {
            logMsg "Error in getting autoDetectInstrumentation"
            set retCode 1 
        }  
    }

    if {[port isActiveFeature $chassis $card $port $::portFeatureRxRoundTripFlows]} {

        if {![getCommand tcpRoundTripFlow  $chassis $card $port]} {          
            sgPuts {tcpRoundTripFlow set $chassis $card $port}
        } else {
            logMsg "Error in getting tcpRoundTripFlow"
            set retCode 1 
        }
    }
    if {![protocolServer get $chassis $card $port] && [port isValidFeature $chassis $card $port $::portFeatureProtocols]} {

		sgPuts ""
        if {![ipAddressTable get $chassis $card $port]} {
            getIpProtocol $chassis $card $port
        } else {
            logMsg "Error in getting ipAddressTable"
            set retCode 1 
        }
        
        if [protocolServer cget -enableArpResponse] {
            if {![getCommand arpServer $chassis $card $port] } {
                sgPuts {arpServer set $chassis $card $port}
            } else {
                logMsg "Error in getting arpServer"
                set retCode 1 
            }
        }
		doInterfaceTable $chassis $card $port

		if {[catch {doProtocols $chassis $card $port}]} {
			set lsaParamList [list enableArpResponse enablePingResponse]
			partiallyGenerateCommand protocolServer $lsaParamList
		} else {
			generateCommand protocolServer 
		}
        sgPuts {protocolServer set $chassis $card $port}
        sgPuts ""

    } 

    #We need to do a port get in order to get portMode. So I put the following part after port command.
   
    if {[port isActiveFeature $chassis $card $port $::portFeaturePos] || \
        [port isActiveFeature $chassis $card $port $::portFeatureAtm]} {
    
        if {![getCommand sonet $chassis $card $port]} {
            sgPuts {sonet set $chassis $card $port}
            sgPuts ""
        } else {
            logMsg "Error in getting sonet"
            set retCode 1 
        }

        set headerType [sonet cget -header]
    
        if { $headerType == $::sonetSrp } {
            if {![getCommand hdlc $chassis $card $port]} {               
                sgPuts {hdlc set $chassis $card $port}                 
            } else {
                logMsg "Error in getting hdlc"
                set retCode 1 
            }
            if {[port isActiveFeature $chassis $card $port $::portFeatureSrpFullFeatured]} {

                if {![getCommand srpUsage $chassis $card $port]} {               
                    sgPuts {srpUsage set $chassis $card $port}                 
                } else {
                    logMsg "Error in getting srpUsage"
                    set retCode 1 
                }
            }
        }

        if { $headerType == $::sonetRpr } {
            if {[port isActiveFeature $chassis $card $port $::portFeatureRpr]} {

                if {![getCommand rprFairness $chassis $card $port]} {
                    sgPuts {rprFairness set $chassis $card $port}                 
                } else {
                    logMsg "Error in getting rprFairness"
                    set retCode 1 
                }
            }
        }

		if {$headerType == $::sonetOther } {
			if { ![hdlc get $chassis $card $port]} {
				set hdlcCommandList [list address control]
				partiallyGenerateCommand hdlc $hdlcCommandList
				sgPuts {hdlc set $chassis $card $port}
			}
			set generateHdlcPerStream 1
		} else {
			set generateHdlcPerStream 0
		}

			
        if { $headerType == $::sonetHdlcPppIp } {
            if {![getCommand ppp $chassis $card $port]} {
                sgPuts {ppp set $chassis $card $port}
            } else {
                logMsg "Error in getting ppp"
                set retCode 1 
            }
        }
        if { $headerType == $::sonetGfp } {
            if {![getCommand gfpOverhead $chassis $card $port]} {
                sgPuts {gfpOverhead set $chassis $card $port}
            } else {
                logMsg "Error in getting gfpOverhead"
                set retCode 1 
            }
        }
        
    }
    
    
    if {[port isValidFeature $chassis $card $port $::portFeaturePos] || \
            [port isValidFeature $chassis $card $port $::portFeature10GigWan]  } {

        if {![sonetError get $chassis $card $port]} {
             sgPuts "sonetError setDefault"
            for {set errType $::sonetLofError} {$errType < $::sonetMaxSonetErrorStat} {incr errType} {
                if {![sonetError getError $errType]} {
	                generateCommand sonetError no
                    sgPuts "sonetError setError [getEnumString sonetError -sonetErrorType]"
                }
            }
            sgPuts {sonetError set $chassis $card $port}
            sgPuts ""
        } else {
            logMsg "Error in getting sonetError"
            set retCode 1 
        }
    }  
    
    if {[port isValidFeature $chassis $card $port $::portFeature10GigWan] ||\
           ( [port isActiveFeature $chassis $card $port $::portFeatureBert] && \
		   ![port isValidFeature $chassis $card $port $::portFeatureBertUnframed])} {

        if {![getCommand sonet $chassis $card $port]} {
            sgPuts {sonet set $chassis $card $port}
            sgPuts ""
        } else {
            logMsg "Error in getting sonet"
            set retCode 1 
        }
    }

	if {[port isValidFeature $chassis $card $port $::portFeatureXFP]} {

        if {![getCommand xfp $chassis $card $port]} {
            sgPuts {xfp set $chassis $card $port}
            sgPuts ""
        } else {
            logMsg "Error in getting xfp"
            set retCode 1 
        }  
    }

    if {[port isActiveFeature $chassis $card $port $::portFeatureLinkFault]} {

        if {![getCommand  linkFaultSignaling $chassis $card $port]} {
			# Currently we only support the WAN type of customOrderedSet
			if {[port isActiveFeature $chassis $card $port $::portFeature10GigWan] } {
				if {[generateCustomOrderedSet] } {
					logMsg "Error in generateCustomOrderedSet"
					set retCode 1
				}
			}
            sgPuts {linkFaultSignaling set $chassis $card $port}
            sgPuts ""
        } else {
            logMsg "Error in getting linkFaultSignaling"
            set retCode 1 
        }  
    }

    if {[port isValidFeature $chassis $card $port $::portFeatureXaui]} {

        if {![getCommand xaui $chassis $card $port]} {
            sgPuts {xaui set $chassis $card $port}
            sgPuts ""
        } else {
            logMsg "Error in getting xaui"
            set retCode 1 
        }  
    } elseif {[port cget -type] == $::port10GELSM} {
		# Currently there is no object that allows to config clock for Denali
		# temporarily it has been added to xaui object, only clockType applies
        if {![xaui get $chassis $card $port]} {
			partiallyGenerateCommand xaui clockType
			sgPuts {xaui set $chassis $card $port}
			sgPuts ""
		} else {
            logMsg "Error in getting xaui"
            set retCode 1 
        }  
	}

    if {[port isActiveFeature $chassis $card $port $::portFeatureLasi]} {

        if {![getCommand lasi $chassis $card $port]} {
            sgPuts {lasi set $chassis $card $port}
            sgPuts ""
        } else {
            logMsg "Error in getting lasi"
            set retCode 1 
        }  
    }

    if {[port isValidFeature $chassis $card $port $::portFeatureVsr]} {

        if {![getCommand vsrError $chassis $card $port]} {
            sgPuts {vsrError set $chassis $card $port}
            sgPuts ""
        } else {
            logMsg "Error in getting vsrError"
            set retCode 1 
        }  
    }

    if {[port isValidFeature $chassis $card $port $::portFeatureFec]} {

		if {![getCommand opticalDigitalWrapper $chassis $card $port]} {
            sgPuts {opticalDigitalWrapper set $chassis $card $port}
            sgPuts ""
        } else {
            logMsg "Error in getting opticalDigitalWrapper"
            set retCode 1 
        }

        if {![getCommand fecError $chassis $card $port]} {
            sgPuts {fecError set $chassis $card $port}
            sgPuts ""
        } else {
            logMsg "Error in getting fecError"
            set retCode 1 
        }  
    }

    if {[port isActiveFeature $chassis $card $port $::portFeatureDccProperties]} {

        if {![getCommand dcc $chassis $card $port]} {
            sgPuts {dcc set $chassis $card $port}
            sgPuts ""
        } else {
            logMsg "Error in getting dcc"
            set retCode 1 
        }  
    }
    
    if {[port isValidFeature $chassis $card $port $::portFeatureFlexibleTimestamp]} {
        if {![getCommand flexibleTimestamp $chassis $card $port]} {
            sgPuts {flexibleTimestamp set $chassis $card $port}
            sgPuts ""
        } else {
            logMsg "Error in getting flexibleTimestamp"
            set retCode 1 
        }  
    }

	generateAtmConfig  $chassis $card $port

    if {![port isActiveFeature $chassis $card $port $::portFeatureBert] && \
        ![port isActiveFeature $chassis $card $port $::portFeatureBertChannelized] && \
        ![port isValidFeature  $chassis $card $port $::portFeatureBertUnframed]} {

        if {![getCommand capture $chassis $card $port]} {
            sgPuts {capture set $chassis $card $port}
        } else {
            logMsg "Error in getting capture"
            set retCode 1 
        }  

        if {![getCommand filter $chassis $card $port]} {
            sgPuts {filter set $chassis $card $port}
        } else {
            logMsg "Error in getting filter"
            set retCode 1 
        }  
                                       
        if {![filterPallette get $chassis $card $port]} {
            generateCommand filterPallette 
            sgPuts {filterPallette set $chassis $card $port}
        } else {
            logMsg "Error in getting filterPallette"
            set retCode 1 
        }
	}
    
    if [port isActiveFeature $chassis $card $port $::portFeatureModifiablePreamble] {
        if {![getCommand txRxPreamble $chassis $card $port]} {
            sgPuts {txRxPreamble set $chassis $card $port}
        } else {
            logMsg "Error in getting txRxPreamble"
            set retCode 1 
        }  
    }

	# Since currently only gapControlMode is the only config streamRegion parm, therefore
	# we will check for the feature
    if { [port isValidFeature $chassis $card $port $::portFeatureGapControlMode] } {
		if {![getCommand streamRegion $chassis $card $port]} {
            sgPuts {streamRegion set $chassis $card $port}
        } else {
            logMsg "Error in getting streamRegion"
            set retCode 1 
        }  
    }

    return $retCode
}



########################################################################
# Procedure: getIpProtocol
#
# This command gets Ip protocol parameters.
# Arguments(s):
# chassis : chassis Id
# card    : card Id
# port    : port Id
# Returned Result:
########################################################################

proc scriptGen::getIpProtocol { chassis card port} \
{
    set retCode 0

    getCommand ipAddressTable $chassis $card $port
    
    if {![ipAddressTable getFirstItem]} {
		generateCommand ipAddressTableItem
        sgPuts "ipAddressTable addItem"  
        while {![ipAddressTable getNextItem]} {
			generateCommand ipAddressTableItem
            sgPuts "ipAddressTable addItem"       
        }
    }   
    sgPuts {ipAddressTable set $chassis $card $port}
    
    return $retCode 
}

 
########################################################################
# Procedure: doPortReceiveMode
#
# This command gets the enum for receiveMode param.
# Arguments(s):
# value : The value of receiveMode
# Returned Result: Text for receiveMode ( [expr x|y]) 
########################################################################
    
proc scriptGen::doPortReceiveMode {value} \
{
    variable enumsArray
    set retCode 0 
    set modes {}
    set flag 0
 
    set enumValList $enumsArray(port,receiveMode)
    set joinedList  [join $enumValList]

    for {set i 0} {$i < [llength $enumValList]} {incr i} {
        set enumValue [expr 1 << $i]

        if {($enumValue > 1) && [expr $value & $enumValue] && $flag} {
            lappend modes "|"
        }
        if {[expr $value & $enumValue]} {
            set flag 1
            lappend modes {$::}
        }
        set enumValue [expr $value & $enumValue]         
        set index       [lsearch $joinedList $enumValue]
        lappend modes   [lindex $joinedList [expr $index-1]]
        
   }

   return [format "%cexpr %s%c" 91 [removeSpaces [join $modes]] 93]
  
}


########################################################################
# Procedure: removeSpaces
#
# This command removes spaces. It is a helper proc for doPortReceiveMode.
# Arguments(s):
# inputStr : a string 
# Returned Result: String with no spaces
########################################################################

proc scriptGen::removeSpaces { inputStr } \
{
    set outStr ""
    set sLeng [string length $inputStr]
    for {set a 0} {$a <= $sLeng } {incr a } {
        string range $inputStr $a 1
        if { [string range $inputStr $a $a] != " " } {
            append outStr [string range $inputStr $a $a]
        }
    }
    return $outStr
}


########################################################################
# Procedure: doInterfaceTable
#
# This command gets  protocol interface table parameters.
# Arguments(s):
# chassis : chassis Id
# card    : card Id
# port    : port Id
# Returned Result: Always return OK
########################################################################

proc scriptGen::doInterfaceTable { chassis card port} \
{
    set retCode 0

	sgPuts ""

    if {![interfaceTable select $chassis $card $port]} {
        sgPuts {interfaceTable select $chassis $card $port}
		interfaceTable get
		generateCommand interfaceTable
        sgPuts {interfaceTable set}
        sgPuts {interfaceTable clearAllInterfaces}
		
		set paramList [list $::interfaceTypeConnected  $::interfaceTypeRouted $::interfaceTypeGre]
		foreach param $paramList {
			if {![interfaceTable getFirstInterface $param]} {
				doInterfaceEntry  $chassis $card $port
				while {![interfaceTable getNextInterface $param]} {
					sgPuts ""
				    doInterfaceEntry $chassis $card $port
     
				}
			}
		}
    }      
    return $retCode 
}



########################################################################
# Procedure: doInterfaceEntry
#
# This command gets  protocol interface table entry parameters.
# Arguments(s):
# Returned Result: Always return OK
########################################################################

proc scriptGen::doInterfaceEntry { chassis card port} \
{
    set retCode 0
    
	set interfaceType [interfaceEntry cget -interfaceType]
	

	if {$interfaceType == $::interfaceTypeConnected } {
        set interfaceParamList [list enable description macAddress eui64Id atmEncapsulation \
									 atmMode atmVpi atmVci enableDhcp enableVlan vlanId vlanPriority enableDhcpV6]
		set interfaceEntryParamList [list gatewayIpAddress maskWidth ipAddress ]
    
	} elseif {$interfaceType == $::interfaceTypeGre } {
        set interfaceParamList [list enable description greSourceIpAddress greDestIpAddress enableGreChecksum enableGreSequence enableGreKey greInKey greOutKey]
		set interfaceEntryParamList [list maskWidth ipAddress ]

    } elseif {$interfaceType == $::interfaceTypeRouted } {
        set interfaceParamList [list enable description connectedVia eui64Id ]
		set interfaceEntryParamList [list maskWidth ipAddress ]

    } else {
        set interfaceParamList {}
		set interfaceEntryParamList {}
	}

    sgPuts "interfaceEntry clearAllItems addressTypeIpV6"
    sgPuts "interfaceEntry clearAllItems addressTypeIpV4"
	sgPuts "interfaceEntry setDefault"
	sgPuts ""

    if {![interfaceEntry getFirstItem $::addressTypeIpV6]} {
        doInterfaceIpV6
        while {![interfaceEntry getNextItem  $::addressTypeIpV6]} {
            doInterfaceIpV6      
        }
    }

	#IpV4 is not a list now. 
   
    if {![interfaceEntry getFirstItem $::addressTypeIpV4]} {
	    partiallyGenerateCommand interfaceIpV4 $interfaceEntryParamList
        sgPuts {interfaceEntry addItem addressTypeIpV4}
        sgPuts ""
    }

	doDhcpV4Properties $chassis $card $port
	doDhcpV6Properties $chassis $card $port
      
    partiallyGenerateCommand interfaceEntry $interfaceParamList	no
	sgPuts "interfaceTable addInterface [getEnumString interfaceEntry -interfaceType]"
	sgPuts ""     
   
    return $retCode 
}



########################################################################
# Procedure: doInterfaceIpV6
#
# This command gets  protocol interface iPv6 parameters.
# Arguments(s):
# Returned Result: Always return OK
########################################################################

proc scriptGen::doInterfaceIpV6 {} \
{
    set retCode 0
      
    generateCommand interfaceIpV6
    sgPuts {interfaceEntry addItem addressTypeIpV6}
    sgPuts ""
       
    return $retCode 
}

########################################################################
# Procedure: doDhcpV4Properties
#
# This command gets  protocol interface for Dhcp V4 properties.
# Arguments(s):
# Returned Result: Always return OK
########################################################################

proc scriptGen::doDhcpV4Properties { chassis card port } \
{
    set retCode 0

	if {[port isValidFeature $chassis $card $port $::portFeatureProtocolDHCP] } {

		sgPuts "dhcpV4Properties removeAllTlvs"
		generateCommand dhcpV4Properties


		if {![dhcpV4Properties getFirstTlv]} {
			generateCommand dhcpV4Tlv
			sgPuts "dhcpV4Properties addTlv"
			while {![dhcpV4Properties getNextTlv]} {
				generateCommand dhcpV4Tlv
				sgPuts "dhcpV4Properties addTlv"
			}
		}
		sgPuts ""      
	}
	       
    return $retCode 
}


########################################################################
# Procedure: doDhcpV6Properties
#
# This command gets  protocol interface for Dhcp V6 properties.
# Arguments(s):
# Returned Result: Always return OK
########################################################################

proc scriptGen::doDhcpV6Properties { chassis card port } \
{
    set retCode 0

	if {[port isValidFeature $chassis $card $port $::portFeatureProtocolDHCPv6] } {

		sgPuts "dhcpV6Properties removeAllTlvs"
		generateCommand dhcpV6Properties


		if {![dhcpV6Properties getFirstTlv]} {
			generateCommand dhcpV6Tlv
			sgPuts "dhcpV6Properties addTlv"
			while {![dhcpV6Properties getNextTlv]} {
				generateCommand dhcpV6Tlv
				sgPuts "dhcpV6Properties addTlv"
			}
		}
		sgPuts ""      
	}
	       
    return $retCode 
}


########################################################################
# Procedure: doAtmFilter
#
# This command gets  atm Filter parameters.
# Arguments(s):
# chassis : chassis Id
# card    : card Id
# port    : port Id
# Returned Result:
########################################################################

proc scriptGen::doAtmFilter {chassis card port vpi vci} \
{
    set retCode 0
    
	if {![atmFilter get $chassis $card $port $vpi $vci]} {
		generateCommand atmFilter
		sgPuts "atmFilter set \$chassis \$card \$port $vpi $vci"
		sgPuts ""
	} else {
		set retCode 1
	}
       
    return $retCode 
}

########################################################################
# Procedure: generateCustomOrderedSet
#
# This command gets customOrderedSet parameters.
# Arguments(s):
# chassis : chassis Id
# card    : card Id
# port    : port Id
# Returned Result:
########################################################################
proc scriptGen::generateCustomOrderedSet {} \
{
    set retCode 0
    
	if {[linkFaultSignaling cget -orderedSetTypeA] == $::linkFaultCustom || \
		[linkFaultSignaling cget -orderedSetTypeB] == $::linkFaultCustom} {
		sgPuts ""			
		sgPuts "customOrderedSet setDefault"
	}

	if { [linkFaultSignaling cget -orderedSetTypeA] == $::linkFaultCustom } {
		if {![customOrderedSet get linkFaultOrderedSetTypeA]} {
			generateCommand customOrderedSet no
			sgPuts "customOrderedSet set linkFaultOrderedSetTypeA "
			sgPuts ""
		} else {
			logMsg "Error in getting customOrderedSet"
			set retCode 1 
		}
	}	
	
	if { [linkFaultSignaling cget -orderedSetTypeB] == $::linkFaultCustom} {
		if {![customOrderedSet get linkFaultOrderedSetTypeB]} {
			sgPuts ""
			generateCommand customOrderedSet no
			sgPuts "customOrderedSet set linkFaultOrderedSetTypeB "
			sgPuts ""
		} else {
			logMsg "Error in getting customOrderedSet "
			set retCode 1 
		}
	} 
       
    return $retCode 
}


proc scriptGen::generateAtmConfig { chassis card port } \
{
    set retCode 0


	if {[port isActiveFeature $chassis $card $port $::portFeatureAtm]} {
		if {![getCommand atmPort $chassis $card $port]} {
			sgPuts {atmPort set $chassis $card $port}
		} else {
			logMsg "Error in getting atmPort"
			set retCode 1 
		} 
		sgPuts ""
		if {![atmReassembly getFirstPair $chassis $card $port]} {
            generateCommand atmReassembly
			sgPuts "atmReassembly add \$chassis \$card \$port [atmReassembly cget -vpi] [atmReassembly cget -vci]"
			sgPuts ""
            if {[port isValidFeature $chassis $card $port $::portFeatureAtmPatternMatcher]} {
			    doAtmFilter	$chassis $card $port [atmReassembly cget -vpi] [atmReassembly cget -vci]
            }
			while {![atmReassembly getNextPair $chassis $card $port]} {
                generateCommand atmReassembly
				sgPuts "atmReassembly add \$chassis \$card \$port [atmReassembly cget -vpi] [atmReassembly cget -vci]"
				sgPuts ""
                if {[port isValidFeature $chassis $card $port $::portFeatureAtmPatternMatcher]} {
				    doAtmFilter	$chassis $card $port [atmReassembly cget -vpi] [atmReassembly cget -vci]
                }

		  }
		}
		sgPuts ""
		if {![atmStat getFirstTxPair $chassis $card $port]} {
			sgPuts "atmStat addTx \$chassis \$card \$port [atmStat cget -vpi] [atmStat cget -vci]"
			while {![atmStat getNextTxPair $chassis $card $port]} {
				sgPuts "atmStat addTx \$chassis \$card \$port [atmStat cget -vpi] [atmStat cget -vci]"
		  }
		}
		
		if {![atmStat getFirstRxPair $chassis $card $port]} {
			sgPuts "atmStat addRx \$chassis \$card \$port [atmStat cget -vpi] [atmStat cget -vci]"
			while {![atmStat getNextRxPair $chassis $card $port]} {
				sgPuts "atmStat addRx \$chassis \$card \$port [atmStat cget -vpi] [atmStat cget -vci]"
		  }
		}
		
		sgPuts ""
		generateAtmOam	$chassis $card $port
		sgPuts ""
		 
	}
    return $retCode 
}


proc scriptGen::generateAtmOam { chassis card port } \
{
    set retCode 0

	if {![atmOam select $chassis $card $port]} {
		sgPuts {atmOam select $chassis $card $port}
		sgPuts {atmOam removeAll}
		if {![atmOam getFirstPair]} {
			generateAtmOamCell
			while {![atmOam getNextPair]} {
				generateAtmOamCell
		  }
		}		
	}

    return $retCode 
}

proc scriptGen::generateAtmOamCell {} \
{
	generateCommand atmOam

	set functionType [atmOam cget -functionType]

    switch $functionType "
        $::atmOamAis { 
            generateCommand  atmOamAis 
        } 
        $::atmOamRdi {  
            generateCommand atmOamRdi 
        } 
        $::atmOamFaultMgmtCC { 
            generateCommand atmOamFaultManagementCC 
        }
        $::atmOamFaultMgmtLB {  
            generateCommand atmOamFaultManagementLB 
        } 
        $::atmOamActDeactCC { 
            generateCommand atmOamActDeact 
        }
	"
	sgPuts "atmOam add  [atmOam cget -vpi] [atmOam cget -vci]"
	sgPuts ""

}







