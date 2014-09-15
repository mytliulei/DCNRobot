#############################################################################################
# Version 4.10	$Revision: 32 $
# $Date: 9/30/02 1:13p $
# $Author: Mgithens $
#
# $Workfile: sgStream.tcl $ - Utilities for scriptgen
#
#   Copyright © 1997 - 2005 by IXIA.
#   All Rights Reserved.
#
#	Revision Log:
#	04-02-2001	EM	Genesis
#
#
#############################################################################################


########################################################################
# Procedure: getProtocolInStream
#
# This command generates commands for specific protocol in the stream
# Arguments(s):
#
# cmd     : command. ( arp, icmp,igmp, ip, ipx, rip, tcp, udp, pauseControl )
# packet  : 
# chassis : chassis Id
# card    : card Id
# port    : port Id

########################################################################
proc scriptGen::getProtocolInStream { cmd chassis card port packet {enableSet yes} } \
{
    set retCode $::TCL_OK

    set  isProtocol 1
    if {[llength $packet] != 0 } {
        set isProtocol   [expr ![$cmd  decode $packet $chassis $card $port]]
    }

    if [$cmd get $chassis $card $port] {
        errorMsg "Error getting $cmd on $chassis $card $port"
        set retCode $::TCL_ERROR 
    }

    if {($retCode == 0) && $isProtocol} {
        generateCommand $cmd

        if { $enableSet == "yes" } {
            sgPuts "$cmd set [format "$%s $%s $%s" chassis card port]"
        }
    } else {
		set retCode  $::TCL_ERROR
	}

    return $retCode    
}


########################################################################
# Procedure: generateCommonStreamConfigs
#
# This command generates commands for protocols in the stream
# Arguments(s):
#
# packet  : 
# chassis : chassis Id
# card    : card Id
# port    : port Id

########################################################################
proc scriptGen::generateCommonStreamConfig { chassis card port streamId sequenceTypeOrQueueId  } \
{
    variable generatePacketView
    variable generateHdlcPerStream

    generateCommand stream
    generateCommand protocol

	# Start of the gre config generation
	if { [isGrePacket $chassis $card $port ] } {
		generateGreProtocols $chassis $card $port

		# We need one more stream get here in order to get the outer IP configuration
		if {[port isActiveFeature $chassis $card $port $::portFeatureAtm]} {
			if {[stream getQueue $chassis $card $port $sequenceTypeOrQueueId $streamId]} {
				errorMsg "Error getting stream queue $sequenceTypeOrQueueId on $chassis $card $port for stream $streamId "
				set retCode $::TCL_ERROR 
			}
		} else {
			if {[stream get $chassis $card $port $streamId $sequenceTypeOrQueueId]} {
				errorMsg "Error getting stream on $chassis $card $port for stream $streamId "
				set retCode $::TCL_ERROR 
			}
		}
		# since we've already generated the appName stuff <dhcp, rip, etc.>, we can disable it
		protocol config -appName none
	}
	# End of Gre code

    generateAllProtocols		$chassis $card $port 
	generateOtherL2Config		$chassis $card $port
    getUdfInStream				$chassis $card $port
	getTableUdfInStream			$chassis $card $port
    getWeightedRandomFrameSize	$chassis $card $port

    set retCode $::TCL_OK


}


########################################################################
# Procedure: generateAllProtocols
#
# This command generates commands for protocols in the stream
# Arguments(s):
#
# packet  : 
# chassis : chassis Id
# card    : card Id
# port    : port Id

########################################################################
proc scriptGen::generateAllProtocols { chassis card port } \
{
    variable generatePacketView

    set retCode $::TCL_OK

    # We don't care to decode the packet, when generatePacketView is set to 0
    # and the generated code will be based on the serialized stream information,
    # instead of packet view

    set packet [list]
    if { $generatePacketView } {
        set packet  [stream cget -packetView]
    } 

    # We don't want to generate ip configurations when appName is Arp,
    # the default protocol name for ARP is ipV4 when we do stream get
    # since ip config is not needed for ARP, then we have to check the
    # the appName in order to skip the ip configuration generation

	set l4Protocol 0

    switch [protocol cget -name] \
        $::ip { \
            if { [protocol cget -appName ] != $::Arp } { \
                getProtocolInStream ip $chassis $card $port $packet; \
				set l4Protocol  [ip cget -ipProtocol ];	\
            } \
        } \
        $::ipx { \
            getProtocolInStream ipx $chassis $card $port $packet \
        }\
        $::ipV6 { \
            getProtocolInStream ipV6 $chassis $card $port $packet no ; \
            set ipV6NextHeader [ipV6 cget -nextHeader] ;            \
            if { ($ipV6NextHeader != $::ipV6NoNextHeader) } { ; \
				set l4Protocol [getIpV6ExtensionHeaders] ;\
			}; \
        
            sgPuts "ipV6 set [format "$%s $%s $%s" chassis card port]"\

        } \
        $::pauseControl { \
            getProtocolInStream pauseControl $chassis $card $port $packet \
        } \

    # Generate code fore tunneled IP
    switch $l4Protocol \
        $::ip { \
            if { [protocol cget -appName ] != $::Arp } { \
                getProtocolInStream ip $chassis $card $port $packet; \
				set l4Protocol  [ip cget -ipProtocol ];	\
            } \
        } \
        $::ipV4ProtocolIpv6 { \
            getProtocolInStream ipV6 $chassis $card $port $packet no ; \
            set ipV6NextHeader [ipV6 cget -nextHeader] ;            \
            if { ($ipV6NextHeader != $::ipV6NoNextHeader) } { ; \
				set l4Protocol [getIpV6ExtensionHeaders] ;\
			}; \
        
            sgPuts "ipV6 set [format "$%s $%s $%s" chassis card port]"\

        } \

	getLayer4Protocols $chassis $card $port $l4Protocol

    if { $generatePacketView } {
        getProtocolInStream arp $chassis $card $port $packet
		getDhcpInStream $chassis $card $port $packet 
        getRipInStream  $chassis $card $port $packet 

    } else {
        switch [protocol cget -appName ] \
            $::SrpArp - \
            $::Arp { \
                getProtocolInStream arp $chassis $card $port $packet ; \
            } \
		    $::Dhcp { \
                getDhcpInStream  $chassis $card $port $packet \
            } \
		    $::Rip { \
                getRipInStream   $chassis $card $port $packet \
            }
    }

    return $retCode    
}

########################################################################
# Procedure: generateOtherL2Config
#
# This command generates other stream config parameters
# Arguments(s):
#
# packet  : 
# chassis : chassis Id
# card    : card Id
# port    : port Id

########################################################################
proc scriptGen::generateOtherL2Config { chassis card port } \
{
    variable generateHdlcPerStream

    set retCode $::TCL_OK

    getSrpInStream   $chassis $card $port
    getRprInStream   $chassis $card $port

    if { [protocol cget -enableISLtag] } {
        getCommand isl  $chassis $card $port
        sgPuts {isl set $chassis $card $port}
    }          

	getVlanInStream $chassis $card $port         

    if { [protocol cget -enableMPLS] } {
        getCommand mpls  $chassis $card $port  
        set labelNo 1
        while { [mplsLabel get $labelNo] == 0 } { 
            generateCommand mplsLabel 
            sgPuts "mplsLabel set $labelNo" 
            incr labelNo
        }
        sgPuts {mpls set $chassis $card $port}  
    }

	if { $generateHdlcPerStream } {
		if {![getCommand hdlc $chassis $card $port]} {               
            sgPuts {hdlc set $chassis $card $port}                
        } else {
            logMsg "Error in getting hdlc"
            set retCode 1 
        }
	}
    set headerType [sonet cget -header]
    if {[port isActiveFeature $chassis $card $port $::portFeaturePos] } {

        if { $headerType == $::sonetFrameRelay1490   || \
             $headerType == $::sonetFrameRelayCisco  || \
             $headerType == $::sonetFrameRelay2427 } {

            getCommand frameRelay  $chassis $card $port
            sgPuts  {frameRelay set $chassis $card $port}
        }
		if { $headerType == $::sonetGfp } {
            getCommand gfp  $chassis $card $port
            sgPuts  {gfp set $chassis $card $port}
        }
    }

    if { [protocol cget -ethernetType] == $::protocolOffsetType } {
		if {[protocolOffset get $chassis $card $port] == $::TCL_OK} {
			generateCommand protocolOffset
			sgPuts {protocolOffset set $chassis $card $port}
		}
	}

    #Set it to original value 
	set generateHdlcPerStream 0

    return $retCode    
}


########################################################################
# Procedure: getLayer4Protocols
#
# This command generates commands for ip protocols ( Layer 4 protocols)
# Arguments(s):
#
# chassis		: chassis Id
# card			: card Id
# port			: port Id
# l4Protocol	: inner (when Gre is present) or outer IP protocol
# packet		: packet bytes
#
########################################################################
proc scriptGen::getLayer4Protocols { chassis card port l4Protocol } \
{
    variable generatePacketView

    set packet [list]

    set retCode $::TCL_OK

    set appNameFlag 1
    if { $generatePacketView } {
        set packet  [stream cget -packetView]
        set l4Protocol [list $::ipV4ProtocolIcmp $::ipV4ProtocolTcp $::ipV4ProtocolUdp $::ipV4ProtocolIgmp ]

    } else {
        # We don't need to generate any L4 protocol config when appName is ARP
        if { ([protocol cget -appName ] == $::SrpArp) || ([protocol cget -appName ] == $::Arp) } {
			set appNameFlag 0 
        } 
    }

	if {$appNameFlag } {	
		foreach protocol $l4Protocol {
			# We don't need to generate any L4 protocol config when appName is ARP
			switch $protocol \
				$::ipV4ProtocolUdp { \
					getProtocolInStream udp $chassis $card $port $packet \
				} \
				$::ipV4ProtocolTcp { \
					getProtocolInStream tcp $chassis $card $port $packet \
				} \
				$::igmp { \
					if {![ getProtocolInStream igmp $chassis $card $port $packet no]} { ;\
						getIgmpV3GroupRecords ;\
						sgPuts "igmp set [format "$%s $%s $%s" chassis card port]" }\
				} \
				$::ipV4ProtocolIcmp { \
					getProtocolInStream icmp $chassis $card $port $packet \
				}
		}
	}

    return $retCode    
}


########################################################################
# Procedure: isGrePacket
#
# This command checks if the packet is a Gre packet
# Arguments(s):
#
# chassis		: chassis Id
# card			: card Id
# port			: port Id
#
# Return values :
#   1 if TRUE
#   0 if FALSE
#
########################################################################
proc scriptGen::isGrePacket { chassis card port } \
{
    variable generatePacketView

    set retCode $::true

    set packet [list]
    if { $generatePacketView } {
        set packet  [stream cget -packetView]
    }

	#
	# NOTE: Assuming there was a stream get performed before this
	#
	# Encapsulated gre protocol
	# Find out if Gre is enabled either in ip or ipV6 

	if {[port isValidFeature $chassis $card $port $::portFeatureGre]} {

		if { $generatePacketView } {
			if {[ip decode $packet $chassis $card $port]} {
				if {[ipV6 decode $packet $chassis $card $port]} {
					return $::false
				} 
			}
		}

		if {[ip get $chassis $card $port]} {
			errorMsg "Error getting ip on $chassis $card $port"
			set retCode $::false 
		}

		if {[ipV6 get $chassis $card $port]} {
			errorMsg "Error getting ipV6 on $chassis $card $port"
			set retCode $::false 
		}
		if {$retCode && ([ip cget -ipProtocol] != $::ipV4ProtocolGre) && ( [getIpV6NextHeader] != $::ipV4ProtocolGre)} {
			set retCode $::false 
		}
	} else {
		set retCode $::false
	}							
							
    return $retCode    
}


########################################################################
# Procedure: generateGreProtocols
#
# This command generates commands for gre along with it's encapsulated
# protocols
#
# Arguments(s):
#
# packet  : 
# chassis : chassis Id
# card    : card Id
# port    : port Id
#
########################################################################
proc scriptGen::generateGreProtocols { chassis card port } \
{
    variable generatePacketView

    set retCode $::TCL_OK

	# save the original...
	set protocolName [protocol cget -name]

    # We don't care to decode the packet, when generatePacketView is set to 0
    # and the generated code will be based on the serialized stream information,
    # instead of packet view

    set packet [list]
    if { $generatePacketView } {
        set packet  [stream cget -packetView]
		if {[llength $packet] != 0 } {
			if {[gre decode $packet $chassis $card $port]} {
				errorMsg "Error getting gre on port $chassis $card $port"
				set retCode $::TCL_ERROR 
			}
		}    
	} 

	if {[gre get $chassis $card $port]} {
		errorMsg "Error getting gre on port $chassis $card $port"
		set retCode $::TCL_ERROR 
	}

	# now we need to know what the next thing is, so get it from the gre protocol type
	switch [gre cget -protocolType] {
		"08 00" {
			protocol config -name ip
		}
		"86 dd" {
			protocol config -name ipV6
		} 
	}

	# note - this just gets the inner IP protocol stuff
	generateAllProtocols $chassis $card $port

	generateCommand gre
	sgPuts "gre set [format "$%s $%s $%s" chassis card port]"

	# put back the original
	protocol config -name	$protocolName

    return $retCode    
}


########################################################################
# Procedure: generateScriptForStreams
#
# This command generates commands for streams
# Arguments(s):
#
# chassis : chassis Id
# card    : card Id
# port    : port Id
#
########################################################################
proc scriptGen::getStreamScript { chassis card port} \
{
    set retCode $::TCL_OK

    set streamId 1

    set streamSequenceTypeList streamSequenceTypeAll

    # need to account for dcc flows
    if {[port isActiveFeature $chassis $card $port $::portFeatureTxDccFlowsSpeStreams] ||
        [port isActiveFeature $chassis $card $port $::portFeatureTxDccFlowsSpeAdvancedScheduler]} {
        set streamSequenceTypeList {streamSequenceTypeStreams streamSequenceTypeFlows}
    }

    foreach streamSequenceType $streamSequenceTypeList {

		if { [stream get $chassis $card $port $streamId $streamSequenceType] } {
		    sgPuts {port reset $chassis $card $port}
			continue
		}
        sgPuts "set streamId 1"
        sgPuts

        for {set streamId 1} {[stream get $chassis $card $port $streamId $streamSequenceType] != 1} {incr streamId} {
            sgPuts "#  Stream $streamId"
            if {[port isActiveFeature $chassis $card $port $::portFeature10GigWan] || \
                [port isActiveFeature $chassis $card $port $::portFeature10GigLan] ||
                [port isActiveFeature $chassis $card $port $::portFeaturePos] } {
                stream config -rateMode usePercentRate
            }

			generateCommonStreamConfig $chassis $card $port $streamId $streamSequenceType 
        
        	if { [port isActiveFeature $chassis $card $port $::portFeatureCiscoCDL] } {
                if {[cdlPreamble get $chassis $card $port] == $::TCL_OK} {
            	    generateCommand cdlPreamble
              	    sgPuts {cdlPreamble set $chassis $card $port}
                } else {
                     errorMsg "Error getting cdlPreamble $chassis $card $port"
                     set retCode $::TCL_ERROR
                }                    
        	}

            if {$streamSequenceType == "streamSequenceTypeAll"} {
                sgPuts {stream set $chassis $card $port $streamId}
                set pgCmd [format {packetGroup setTx $chassis $card $port $streamId}]
                set diCmd [format {dataIntegrity setTx $chassis $card $port $streamId}]
            } else {
                sgPuts [format {stream set $chassis $card $port $streamId $::%s} $streamSequenceType]
                set pgCmd [format {packetGroup setTx $chassis $card $port $streamId $::%s} $streamSequenceType]
                set diCmd [format {dataIntegrity setTx $chassis $card $port $streamId $::%s} $streamSequenceType]
            }

            if { ![packetGroup getTx $chassis $card $port $streamId] } {
                if { [packetGroup cget -insertSignature] || [packetGroup cget -insertSequenceSignature] } {
                    generateCommand packetGroup 
                    sgPuts {packetGroup setTx  $chassis $card $port $streamId}
                }
            } else {
                 errorMsg "Error getting packet Group $chassis $card $port $streamId"
                 set retCode $::TCL_ERROR
            }   

            if { ![dataIntegrity getTx $chassis $card $port $streamId] } {
                if [dataIntegrity cget -insertSignature] {
                    generateCommand dataIntegrity 
                    sgPuts {dataIntegrity setTx  $chassis $card $port $streamId}
                }
            } else {
                 errorMsg "Error getting dataIntegrity $chassis $card $port $streamId"
                 set retCode $::TCL_ERROR
            }   
 
            sgPuts "incr streamId"                            
        }
    }

    return $retCode
}

########################################################################
# Procedure: getWeightedRandomFrameSize
#
# This command generates commands for Rip and rip routes in the stream
# Arguments(s):
#
# packet  : 
# chassis : chassis Id
# card    : card Id
# port    : port Id
#
# Return value:
#   1 if TCL_ERORR
#   0 if TCL_OK
########################################################################
proc scriptGen::getWeightedRandomFrameSize { chassis card port } \
{
    set retCode $::TCL_OK

    if { [port isActiveFeature $chassis $card $port $::portFeatureRandomFrameSizeWeightedPair] } {
    
		if {![weightedRandomFramesize get $chassis $card $port] } {

			if { [weightedRandomFramesize cget -randomType] != $::randomUniform } {

				if {[weightedRandomFramesize cget -randomType] == $::randomQuadGaussian } {
					sgPuts "weightedRandomFramesize setDefault"
					sgPuts "weightedRandomFramesize config -randomType randomQuadGaussian"
					set excludedParmList [list randomType]
					for { set curveId 1} { $curveId <= 4 } { incr curveId} {

						if {![weightedRandomFramesize retrieveQuadGaussianCurve $curveId] } {
							generateCommand weightedRandomFramesize no	$excludedParmList
							sgPuts "weightedRandomFramesize updateQuadGaussianCurve $curveId"					
						} 					                    
					}
				} else {           
					set excludedParmList [list weight center widthAtHalf]
					generateCommand weightedRandomFramesize	yes $excludedParmList
				}

				if {[weightedRandomFramesize cget -randomType] == $::randomWeightedPair } {

					foreach weightPair [weightedRandomFramesize cget -pairList] {

						set frSize [lindex $weightPair 0]
						set weight [lindex $weightPair 1]

						weightedRandomFramesize addPair $frSize  $weight
						sgPuts "weightedRandomFramesize addPair $frSize  $weight"
					}
				}
			 
				sgPuts {weightedRandomFramesize set $chassis $card $port}
			} else {
				# This needs to be added just in case if the previous script or configuration has the
				# weightedRandomFramesize configured
				sgPuts
				sgPuts -noFormat "if \{\[port isValidFeature \$chassis \$card \$port \$::portFeatureRandomFrameSizeWeightedPair\]\} \{ "
				sgPuts -noFormat {	weightedRandomFramesize setDefault}
				sgPuts -noFormat {	weightedRandomFramesize set $chassis $card $port}
				sgPuts -noFormat "\}"
				sgPuts
			}
		}
	}
        
    return $retCode
}




########################################################################
# Procedure: getUdfInStream
#
# This command generates commands for udf in the stream
# Arguments(s):
#
# packet  : 
# chassis : chassis Id
# card    : card Id
# port    : port Id

########################################################################
proc scriptGen::getUdfInStream { chassis card port } \
{
	set retCode $::TCL_OK

    set maxUdfNum 4
    if [port isValidFeature $chassis $card $port $::portFeatureUdf5] {
        set maxUdfNum 5
    }

    for {set udfId 1} {$udfId <= $maxUdfNum} {incr udfId} {
        if {[udf get $udfId] } {
             errorMsg "Error getting udf$udfId for $streamId "
             set retCode $::TCL_ERROR
        }

        if {[udf cget -enable]} {
            if {[udf cget -counterMode] == $::udfRangeListMode } {
                set  udfParamList [list enable offset counterMode chainFrom countertype initval repeat step cascadeType]

                if { ![udf getFirstRange] } {

                    sgPuts "udf clearRangeList"
                    partiallyGenerateCommand udf $udfParamList
                    sgPuts "udf addRange"
                    
                    while {![udf getNextRange]} {
                        partiallyGenerateCommand udf $udfParamList
                        sgPuts "udf addRange"
                    }
                } else {
					set  udfParamList [list enable offset counterMode chainFrom countertype cascadeType]
					partiallyGenerateCommand udf $udfParamList
				}
            } elseif {[udf cget -counterMode] == $::udfValueListMode } {
               set  udfParamList [list  enable offset counterMode chainFrom countertype valueList cascadeType]
               partiallyGenerateCommand udf $udfParamList

            } elseif {[udf cget -counterMode] == $::udfIPv4Mode } {
                set udfParamList [list enable offset counterMode chainFrom countertype initval innerRepeat innerStep \
                                       continuousCount repeat enableSkipZerosAndOnes skipMaskBits cascadeType]
               partiallyGenerateCommand udf $udfParamList

            } elseif {[udf cget -counterMode] == $::udfNestedCounterMode } {
				set udfParamList [list enable offset counterMode chainFrom countertype initval repeat \
									    step  innerRepeat innerLoop innerStep cascadeType ]
               partiallyGenerateCommand udf $udfParamList
			
			} elseif {[udf cget -counterMode] == $::udfRandomMode } {
				set udfParamList [list enable offset counterMode  countertype chainFrom maskselect maskval ]
               partiallyGenerateCommand udf $udfParamList
			
			} else {
				set udfParamList [list enable continuousCount offset counterMode chainFrom countertype  \
									   updown initval repeat cascadeType enableCascade step ]

               partiallyGenerateCommand udf $udfParamList
            }                                     
            sgPuts "udf set $udfId"
        }
    }
    set udfParamList {}

    return $retCode
}


########################################################################
# Procedure: getTableUdfInStream
#
# This command generates commands for udf in the stream
# Arguments(s):
#
# packet  : 
# chassis : chassis Id
# card    : card Id
# port    : port Id
########################################################################
proc scriptGen::getTableUdfInStream { chassis card port } \
{
	set retCode TCL_OK
    if {[port isValidFeature $chassis $card $port $::portFeatureTableUdf] } {

		if {[tableUdf get $chassis $card $port] } {
			 errorMsg "Error getting tableUdf on port $chassis $card $port "
			 set retCode $::TCL_ERROR
		}

		if {[tableUdf cget -enable] } {
			sgPuts "tableUdf setDefault"
			sgPuts "tableUdf clearColumns"
			sgPuts "tableUdf config -enable [tableUdf cget -enable]"

			if { ![tableUdf getFirstColumn] } {
				generateCommand tableUdfColumn
				sgPuts "tableUdf addColumn"
				while {![tableUdf getNextColumn]} {
					generateCommand tableUdfColumn
					sgPuts "tableUdf addColumn"
				}
				set numRows [tableUdf cget -numRows]
				if {$numRows > 0 } {
					set rowValueList [tableUdf getFirstRow]
					while {[llength $rowValueList]} {
						sgPuts "set rowValueList [list $rowValueList]" 
						sgPuts {tableUdf addRow $rowValueList}
						set rowValueList [tableUdf getNextRow]
					} 
				}
			}
            sgPuts {tableUdf set $chassis $card $port}
		} else {
			# This is needed to clear from the previous	script configuration
			sgPuts
			sgPuts -noFormat "if \{\[port isValidFeature \$chassis \$card \$port \$::portFeatureTableUdf\]\} \{ "
			sgPuts -noFormat "	tableUdf setDefault"
			sgPuts -noFormat "	tableUdf clearColumns"
			sgPuts -noFormat {	tableUdf set $chassis $card $port}
			sgPuts -noFormat "\}"
			sgPuts
		}
	}
	return $retCode		       

}


########################################################################
# Procedure: getDhcpInStream
#
# This command generates commands for dhcp in the stream
# Arguments(s):
#
# packet  : 
# chassis : chassis Id
# card    : card Id
# port    : port Id

########################################################################

proc scriptGen::getDhcpInStream { chassis card port packet } \
{
    set retCode 0

    set  isProtocol 1
    if {[llength $packet] != 0 } {
        set isProtocol   [expr ![dhcp  decode $packet $chassis $card $port]]
    }

    if [dhcp get $chassis $card $port] {
        errorMsg "Error getting dhcp on $chassis $card $port"
        set retCode 1 
    }
    if {($retCode == 0) && $isProtocol} {
        
        generateCommand dhcp 

		if {![dhcp getFirstOption]} {
			set data [dhcp cget -optionData]
			set optionEnum [getDhcpOptionString [dhcp cget -optionCode]]
			if {[string length $data] > 0 } {
				sgPuts "dhcp config -optionData       {$data}"
				sgPuts "dhcp setOption                $optionEnum"
			} else {
				sgPuts "dhcp setOption                $optionEnum"
			}
							
			while {![dhcp getNextOption]} {
				set data [dhcp cget -optionData]
				set optionEnum [getDhcpOptionString [dhcp cget -optionCode]]
				if {[string length $data] > 0 } {
					sgPuts "dhcp config -optionData       {$data}"
					sgPuts "dhcp setOption                $optionEnum"
				} else {
					sgPuts "dhcp setOption                $optionEnum"
				}
			}
		}

        sgPuts {dhcp set $chassis $card $port}
    }
    return $retCode
}

proc scriptGen::getDhcpOptionString { optionValue } \
{
    variable dhcpOptionDataList

	set retString ""
	set index 0

	foreach item $dhcpOptionDataList {
		set value [set ::$item]
		if { $value == $optionValue } {
			set retString [lindex $dhcpOptionDataList $index]
		}
		incr index 
	}
	return $retString
}


########################################################################
# Procedure: getRipInStream
#
# This command generates commands for Rip and rip routes in the stream
# Arguments(s):
#
# packet  : 
# chassis : chassis Id
# card    : card Id
# port    : port Id
#
# Return value:
#   1 if TCL_ERORR
#   0 if TCL_OK
########################################################################

proc scriptGen::getRipInStream { chassis card port packet } \
{
    set retCode 0

    set  isRip 1
    if {[llength $packet] != 0 } {
        set isRip   [expr ![rip  decode $packet $chassis $card $port]]
    }
    if [rip get $chassis $card $port] {
        errorMsg "Error getting rip on $chassis $card $port"
        set retCode 1 
    }
    if {($retCode == 0) && $isRip} {
        
        generateCommand rip
        for {set routeID 1} {![ripRoute get $routeID]} {incr routeID} {
            generateCommand ripRoute
            sgPuts "ripRoute set $routeID"
        }
        sgPuts {rip set $chassis $card $port}
    }    
    return $retCode
}

########################################################################
# Procedure:    getSrpInStream
#
# Description:  Generate commands for Srp commands in the stream.
#
# Arguments(s): chassis : chassis Id
#               card    : card Id
#               port    : port Id
#
# Returns:      TCL_ERROR or TCL_OK
#
########################################################################
proc scriptGen::getSrpInStream {chassis card port } \
{
    set retCode         $::TCL_OK
    set generateFlag    1

    if {[sonet cget -header] == $::sonetSrp} {
        if {[port isActiveFeature $chassis $card $port $::portFeatureSrpFullFeatured]} {

            switch [protocol cget -appName ] "
                $::SrpDiscovery {
                    set command srpDiscovery
                }                         
               	$::SrpArp {
                    set command srpArp
                }                  
		        $::SrpIps {
                    set command srpIps
                }
                default {
                    set generateFlag    0
                }
             
            "
            if {$generateFlag } {
                if {[$command get $chassis $card $port]} {
                    errorMsg "Error getting $command on $chassis $card $port"
                    set retCode $::TCL_ERROR 
                }
                generateCommand $command
                if {$command == "srpDiscovery" } {
                    getSrpMacBindingList
                }
                sgPuts "$command set [format "$%s $%s $%s" chassis card port]"
            } elseif {[protocol cget -name ] == $::ip ||  [protocol cget -name ] == $::mac} {
                if {[srpHeader get $chassis $card $port]} {
                    errorMsg "Error getting srpHeader on $chassis $card $port"
                    set retCode $::TCL_ERROR 
                }
                generateCommand srpHeader
                sgPuts {srpHeader set $chassis $card $port}
            }
        }
    }

    return $retCode
}                


########################################################################
# Procedure:    getSrpMacBindingList
#
# Description:  Generate commands for srpMacBinding in the stream.
#
# Arguments(s): chassis : chassis Id
#               card    : card Id
#               port    : port Id
#
# Returns:      TCL_ERROR or TCL_OK
#
########################################################################
proc scriptGen::getSrpMacBindingList {} \
{
    set retCode $::TCL_OK

    sgPuts "srpDiscovery clearAllMacBindings"
        
    if {![srpDiscovery getFirstMacBinding]} {

        generateCommand srpMacBinding
        sgPuts "srpDiscovery addMacBinding"

        while {![srpDiscovery getNextMacBinding]} {
            generateCommand srpMacBinding
            sgPuts "srpDiscovery addMacBinding"
        }
    }
    return $retCode
}


        
########################################################################
# Procedure: getAtmStreamQueueScript
#
# This command generates commands for stream queues
# Arguments(s):
#
# chassis : chassis Id
# card    : card Id
# port    : port Id
#
########################################################################
proc scriptGen::getAtmStreamQueueScript { chassis card port } \
{    
	set retCode $::TCL_OK

    variable generateHdlcPerStream

    if [streamQueueList select $chassis $card $port] {
        errorMsg "Error selecting port for streamQueueList..."
        set retCode $::TCL_ERROR
        return $retCode
    }
    set queueId 1

    sgPuts {streamQueueList select $chassis $card $port}
	sgPuts {streamQueueList clear}

	if {[streamQueue get $chassis $card $port $queueId] } {
		return $retCode
	} 

    sgPuts "set                          queueId          1"

    while {[streamQueue get $chassis $card $port $queueId] == $::TCL_OK} {
        sgPuts "############  Queue $queueId ############"
        sgPuts "streamQueueList add"

        generateCommand streamQueue
        sgPuts {streamQueue set $chassis $card $port $queueId}
        
        set streamId 1

		if { [stream getQueue $chassis $card $port $queueId $streamId] } {
			sgPuts {streamQueue clear $chassis $card $port $queueId}
			incr queueId
			sgPuts "incr queueId"
			continue
		}	

        while {[stream getQueue $chassis $card $port $queueId $streamId] == $::TCL_OK} {
            sgPuts "############  Stream $streamId ############"
            sgPuts "set                          streamId          $streamId"
            if {[port isActiveFeature $chassis $card $port $::portFeature10GigWan] || \
                [port isActiveFeature $chassis $card $port $::portFeature10GigLan] ||
                [port isActiveFeature $chassis $card $port $::portFeaturePos] } {
                stream config -rateMode usePercentRate
            }

			generateCommonStreamConfig $chassis $card $port $streamId $queueId 

            if {[atmHeader get $chassis $card $port]} {
                errorMsg "Error getting atmHeader for port $chassis $card $port"
                set retCode $::TCL_ERROR
                return $retCode
            }
            if {[getVpiVci]} {
                errorMsg "Error getting Vpi/Vci"
                set retCode $::TCL_ERROR
                return $retCode
            }

            generateCommand atmHeader
            sgPuts {atmHeader set $chassis $card $port}
                  
            sgPuts {stream setQueue $chassis $card $port $queueId $streamId}

            if {![packetGroup getQueueTx $chassis $card $port $queueId $streamId]} {
                if { [packetGroup cget -insertSignature] || [packetGroup cget -insertSequenceSignature] } {
                    generateCommand packetGroup 
                    sgPuts {packetGroup setQueueTx  $chassis $card $port $queueId $streamId}
                }
            } else {
                 errorMsg "Error getting packet Group $chassis $card $port $queueId $streamId"
                 set retCode $::TCL_ERROR
            }
               
            if {![dataIntegrity getQueueTx $chassis $card $port $queueId $streamId]} {
                if {[dataIntegrity cget -insertSignature]} {
                    generateCommand dataIntegrity 
                    sgPuts {dataIntegrity setQueueTx  $chassis $card $port $queueId $streamId}
                }
            } else {
                 errorMsg "Error getting dataIntegrity $chassis $card $port $queueId $streamId"
                 set retCode $::TCL_ERROR
            } 
              
            sgPuts "incr streamId"                                    
            incr streamId
        }
		sgPuts "incr queueId"
        incr queueId
        set  streamId 1
        sgPuts "set                          streamId          1"
    }
    
    return $retCode
}
########################################################################
# Procedure: getVpiVci
#
# This command generates commands atmHeaderCounter for vpi and vci
# Arguments(s):
#
#
########################################################################
proc scriptGen::getVpiVci { } \
{    
	set retCode $::TCL_OK

    if {[atmHeaderCounter get atmVpi]} {
        errorMsg "Error getting atmHeaderCounter for atmVpi"
        set retCode $::TCL_ERROR
    } else {
        generateCommand atmHeaderCounter
        sgPuts "atmHeaderCounter set atmVpi"
    }

    if {[atmHeaderCounter get atmVci]} {
        errorMsg "Error getting atmHeaderCounter for atmVci"
        set retCode $::TCL_ERROR
    } else {
        generateCommand atmHeaderCounter
        sgPuts "atmHeaderCounter set atmVci"
    }

    return $retCode
}

########################################################################
# Procedure:    getIpV6NextHeader
#
# Description:  Generate commands for each Tlv in the rpr topology.
#
# Arguments(s): 
#
# Returns:      TCL_ERROR or TCL_OK
#
########################################################################
proc scriptGen::getIpV6NextHeader { } \
{

    set ipV6NextHeader  [ipV6 cget -nextHeader]

    if { ($ipV6NextHeader != $::ipV4ProtocolTcp) && ($ipV6NextHeader != $::ipV4ProtocolUdp) && \
		 ($ipV6NextHeader != $::ipV4ProtocolIpv6Icmp) && ($ipV6NextHeader != $::ipV4ProtocolGre) && \
         ($ipV6NextHeader != $::ipV6HopByHopOptions) && ( $ipV6NextHeader != $::ipV6EncapsulatingSecurityPayload) } {

        set extHeaderObject [ipV6 getFirstExtensionHeader]
        set lastExtHeaderObject  $extHeaderObject

	    if {$extHeaderObject != "NULL" } {

            set ipV6NextHeader  [$extHeaderObject cget -nextHeader]
            set lastExtHeaderObject  $extHeaderObject
		    set extHeaderObject [ipV6 getNextExtensionHeader]
            while {$extHeaderObject != "NULL"} {
                set ipV6NextHeader  [$extHeaderObject cget -nextHeader]
                set lastExtHeaderObject  $extHeaderObject
			    set extHeaderObject [ipV6 getNextExtensionHeader]
            }
        }

	    if {$lastExtHeaderObject != "NULL" } {
            set ipV6NextHeader  [$lastExtHeaderObject cget -nextHeader]
        }
    } 
          
    return $ipV6NextHeader
}

########################################################################
# Procedure:    getIpV6ExtensionHeaders
#
# Description:  Generate commands for each Tlv in the rpr topology.
#
# Arguments(s): 
#
# Returns:      TCL_ERROR or TCL_OK
#
########################################################################
proc scriptGen::getIpV6ExtensionHeaders { } \
{
    sgPuts "ipV6 clearAllExtensionHeaders"

    set ipV6NextHeader  [ipV6 cget -nextHeader]


    if { ($ipV6NextHeader != $::ipV4ProtocolTcp) && ($ipV6NextHeader != $::ipV4ProtocolUdp) && \
		 ($ipV6NextHeader != $::ipV4ProtocolIpv4) && \
		 ($ipV6NextHeader != $::ipV4ProtocolIpv6Icmp) && ($ipV6NextHeader != $::ipV4ProtocolGre) && \
         ($ipV6NextHeader != $::ipV6EncapsulatingSecurityPayload) } {

        set extHeaderObject [ipV6 getFirstExtensionHeader]
        set lastExtHeaderObject  $extHeaderObject

	    if {$extHeaderObject != "NULL" } {
		    generateExtensionHeader $ipV6NextHeader

            set ipV6NextHeader  [$extHeaderObject cget -nextHeader]
            set lastExtHeaderObject  $extHeaderObject
		    set extHeaderObject [ipV6 getNextExtensionHeader]

            while {$extHeaderObject != "NULL"} {
		        generateExtensionHeader $ipV6NextHeader
                set ipV6NextHeader  [$extHeaderObject cget -nextHeader]
                set lastExtHeaderObject  $extHeaderObject
			    set extHeaderObject [ipV6 getNextExtensionHeader]
            }
        }

	    if {$lastExtHeaderObject != "NULL" } {
            set ipV6NextHeader  [$lastExtHeaderObject cget -nextHeader]
            generateExtensionHeader $ipV6NextHeader
        }
    } else {
        generateExtensionHeader $ipV6NextHeader
    }
          
    return $ipV6NextHeader
}


########################################################################
# Procedure: generateExtensionHeader
#
# This command gets Tlvs for the RPR Topology
# Arguments(s):
#
# tlvObject: pointer to Tlv object.
#
# Returned Result:
########################################################################      
proc scriptGen::generateExtensionHeader {ipV6ExtHeaderType} \
{  
    set retCode 0
    
	set generateCmdFlag 1

    set headerType "ipV6Routing"

    switch $ipV6ExtHeaderType "
        $::ipV6Routing { 
            generateCommand  ipV6Routing 
			set headerType ipV6Routing 
        } 
        $::ipV6Fragment {  
            generateCommand ipV6Fragment 
			set headerType ipV6Fragment 
        } 
        $::ipV6Authentication { 
            generateCommand ipV6Authentication 
			set headerType ipV6Authentication 
        } 
        $::ipV6DestinationOptions { 
            generateCommand ipV6Destination 
			set headerType ipV6DestinationOptions 
        }
        $::ipV6HopByHopOptions {
            set headerType ipV6HopByHopOptions 
            generateIpV6Options 
        }
        $::ipV6EncapsulatingSecurityPayload {
	        set generateCmdFlag 0
            set headerType ipV6EncapsulatingSecurityPayload 
            sgPuts \"#****** WARNING: Currently no IxTclHal support for ipV6EncapsulatingSecurityPayload.\" 
        }
        $::ipV4ProtocolTcp {
            set headerType ipV4ProtocolTcp 
        }
        $::ipV4ProtocolUdp {
            set headerType ipV4ProtocolUdp
        }
        $::ipV4ProtocolGre {
            set headerType ipV4ProtocolGre 
        }
        $::ipV4ProtocolIpv4 {
            set headerType ipV4ProtocolIpv4 
        }
        $::ipV4ProtocolIpv6Icmp {
	        set generateCmdFlag 0
            set headerType ipV4ProtocolIpv6Icmp 
            sgPuts \"#****** WARNING: Currently no IxTclHal support for icmpV6 over IpV6.\" 
        }
		$::ipV6NoNextHeader {
			set generateCmdFlag 0
		}         
    " 
    if { $generateCmdFlag } {
        sgPuts "ipV6 addExtensionHeader $headerType " 
    }
    
    return $retCode
}

########################################################################
# Procedure:    generateIpV6Options
#
# Description:  Generate commands for IpV6 HopByHop Options.
#
# Arguments(s): 
#
# Returns:      TCL_ERROR or TCL_OK
#
########################################################################
proc scriptGen::generateIpV6Options { } \
{
    set retCode $::TCL_OK

    sgPuts "ipV6HopByHop clearAllOptions"

    set optionObject [ipV6HopByHop getFirstOption]


	if {$optionObject != "NULL" } {
        set optionType [$optionObject cget -optionType]
		generateIpV6HopByHopOptions $optionType
		set optionObject [ipV6HopByHop getNextOption]

        while {$optionObject != "NULL"} {
            set optionType [$optionObject cget -optionType]
            generateIpV6HopByHopOptions  $optionType
			set optionObject [ipV6HopByHop getNextOption]
        }
    }
            
    return $retCode
}

########################################################################
# Procedure: generateIpV6HopByHopOptions
#
# This command generates IpV6 HopByHop Options
# Arguments(s):
#
#   type    - the option type to be generated
#
# Returned Result:
########################################################################      
proc scriptGen::generateIpV6HopByHopOptions {type} \
{  
    variable enumsArray

    set retCode 0

	# All the options have the same list values
	foreach optionItem $enumsArray(ipV6OptionPAD1,optionType) {
		set value	[lindex $optionItem 1]
		set name	[lindex $optionItem 0]
		if {$value == $type } {
			break
		}
	} 
  
	if { $type == $::ipV6OptionPAD1} {
		generateCommand $name no
	} else {
		generateCommand $name
	}

    sgPuts "ipV6HopByHop addOption $name"
    sgPuts ""
    
    return $retCode
}

########################################################################
# Procedure:    getRprInStream
#
# Description:  Generate commands for Srp commands in the stream.
#
# Arguments(s): packet  :
#                   chassis : chassis Id
#                   card    : card Id
#                   port    : port Id
#
# Returns:      TCL_ERROR or TCL_OK
#
########################################################################
proc scriptGen::getRprInStream {chassis card port } \
{
    set retCode         $::TCL_OK
    set generateFlag    1

    if {[sonet cget -header] == $::sonetRpr} {
        if {[port isActiveFeature $chassis $card $port $::portFeatureRpr]} {

            if {[rprRingControl get $chassis $card $port]} {
                errorMsg "Error getting rprRingControl on $chassis $card $port"
                set retCode $::TCL_ERROR 
            }

            generateCommand rprRingControl
            sgPuts {rprRingControl set $chassis $card $port}

            switch [protocol cget -appName ] "
                $::RprTopology {
                    set command rprTopology
                }                         
		        $::RprProtection {
                    set command rprProtection
                }
                $::RprOam {
                    set command rprOam
                }
                default {
                    set generateFlag    0
                }
             
            "

            if {$generateFlag } {
                if {[$command get $chassis $card $port]} {
                    errorMsg "Error getting $command on $chassis $card $port"
                    set retCode $::TCL_ERROR 
                }
                if {$command == "rprTopology" } {
                    sgPuts "rprTopology clearAllTlvs" 
                    getTlvs
                }
                generateCommand $command
                sgPuts "$command set [format "$%s $%s $%s" chassis card port]"

            }
        }
    }

    return $retCode
}   
                 
########################################################################
# Procedure:    getTlvs
#
# Description:  Generate commands for each Tlv in the rpr topology.
#
# Arguments(s): 
#
# Returns:      TCL_ERROR or TCL_OK
#
########################################################################
proc scriptGen::getTlvs { } \
{
    set retCode $::TCL_OK

    set tlvObject [rprTopology getFirstTlv]

	if {$tlvObject != "NULL" } {
        set tlvType [$tlvObject cget -type]
		generateTlv $tlvType

		set tlvObject [rprTopology getNextTlv]
        while {$tlvObject != "NULL"} {
            set tlvType [$tlvObject cget -type]
		    generateTlv $tlvType
			set tlvObject [rprTopology getNextTlv]
        }
    }
            
    return $retCode
}


########################################################################
# Procedure: generateTlv
#
# This command gets Tlvs for the RPR Topology
# Arguments(s):
#
# tlvObject: pointer to Tlv object.
#
# Returned Result:
########################################################################      
proc scriptGen::generateTlv {type} \
{  
    set retCode 0
    
	set tlvType "rprTlvWeight"

    switch $type "
        $::rprWeight {
            generateCommand  rprTlvWeight
			set tlvType rprWeight
        } 
        $::rprTotalBandwidth {
            generateCommand rprTlvTotalBandwidth
			set tlvType rprTotalBandwidth
        }
        $::rprStationName {
            generateCommand rprTlvStationName
			set tlvType rprStationName
        } 
        $::rprNeighborAddress {
            generateCommand rprTlvNeighborAddress
			set tlvType rprNeighborAddress
        } 
        $::rprIndividualBandwidth { 
            getTlvBandwidthPairs
            generateCommand rprTlvIndividualBandwidth
			set tlvType rprIndividualBandwidth
        }
		$::rprVendorSpecific { 
            generateCommand rprTlvVendorSpecific 
			set tlvType rprVendorSpecific
        } 
    "
    sgPuts "rprTopology addTlv $tlvType" 
	
	sgPuts "" 
    
    return $retCode
}


########################################################################
# Procedure:    getTlvBandwidthPairs
#
# Description:  Generate commands for srpMacBinding in the stream.
#
# Arguments(s): 
#
# Returns:      TCL_ERROR or TCL_OK
#
########################################################################
proc scriptGen::getTlvBandwidthPairs {} \
{
    set retCode $::TCL_OK

    sgPuts "rprTlvIndividualBandwidth clearAllBandwidthPairs"
        
    if {![rprTlvIndividualBandwidth getFirstBandwidthPair]} {

        generateCommand rprTlvBandwidthPair
        sgPuts "rprTlvIndividualBandwidth addBandwidthPair"

        while {![rprTlvIndividualBandwidth getNextBandwidthPair]} {
            generateCommand rprTlvBandwidthPair
            sgPuts "rprTlvIndividualBandwidth addBandwidthPair"
        }
    } 

    return $retCode
}


########################################################################
# Procedure:    getIgmpV3GroupRecords
#
# Description:  Generate commands for IgmpV3GroupRecords in the stream.
#
# Arguments(s): 
#
# Returns:      TCL_ERROR or TCL_OK
#
########################################################################
proc scriptGen::getIgmpV3GroupRecords {} \
{
    set retCode $::TCL_OK

	if {([igmp cget -version] == $::igmpVersion3) && ([igmp cget -type] == $::membershipReport3 ) } {
		if {![igmp getFirstGroupRecord]} {
			sgPuts "igmp clearGroupRecords"
			generateCommand igmpGroupRecord
			sgPuts "igmp addGroupRecord"

			while {![igmp getNextGroupRecord]} {
				generateCommand igmpGroupRecord
				sgPuts "igmp addGroupRecord"
			}
		}
	} 

    return $retCode
}

########################################################################
# Procedure:    getVlanInStream
#
# Description:  Generate commands for vlan or stacked vlan in the stream.
#
# Arguments(s): 
#
# Returns:      TCL_ERROR or TCL_OK
#
########################################################################
proc scriptGen::getVlanInStream { chassis card port } \
{
    variable generatePacketView

    set retCode $::TCL_OK

    set packet [list]
    if { $generatePacketView } {
        set packet  [stream cget -packetView]
    }
	sgPuts "" 

    if { [protocol cget -enable802dot1qTag] == $::vlanSingle } {
        getProtocolInStream vlan $chassis $card $port $packet

    } elseif {[protocol cget -enable802dot1qTag] == $::vlanStacked } {
		if {[port isValidFeature $chassis $card $port $::portFeatureStackedVlan]} {

			getProtocolInStream stackedVlan $chassis $card $port $packet no

			set vlanPos 1
			sgPuts "set vlanPosition $vlanPos"
			if {![stackedVlan get $chassis $card $port] } {
				if {![stackedVlan getFirstVlan] } {
					generateCommand vlan
					sgPuts {stackedVlan setVlan $vlanPosition}
					sgPuts "" 
					sgPuts {incr vlanPosition}
				
					if {![stackedVlan getNextVlan] } {

						generateCommand vlan
						sgPuts {stackedVlan setVlan $vlanPosition}
						while {![stackedVlan getNextVlan] } {
							sgPuts ""
							generateCommand vlan
							sgPuts {stackedVlan addVlan}
						}

					}
				}
			}
		}
		sgPuts {stackedVlan set $chassis $card $port}
		sgPuts ""
	}
        

    return $retCode
}


        
        
         
