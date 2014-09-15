#############################################################################################
#
#  sgProtocolUtils.tcl $ - Utilities for scriptgen
#
#   Copyright © 1997 - 2004 by IXIA.
#   All Rights Reserved.
#
#	Revision Log:
#	05-12-2004	EM	Genesis
#
#
#############################################################################################

########################################################################
# Procedure: handleProtocolsOddParams
#
# This command takes care of protocols odd parameters like 
# Arguments(s):
# cmd       : command
#
# Returned Result: The enum text.
########################################################################


proc scriptGen::handleProtocolsOddParams {cmd {parameter ""} } \
{
	variable enumsArray

    set enumText ""

	if { $cmd == "ospfV3Interface" } {
        set enumText [doOspfV3Options [ospfV3Interface cget -options] $enumsArray(ospfV3Interface,options)]
    }
	
	if { $cmd == "ospfV3LsaRouter" } {
        set enumText [doOspfV3Options [ospfV3LsaRouter cget -options] $enumsArray(ospfV3LsaRouter,options)]
    }
	
	if { $cmd == "ospfV3LsaNetwork" } {
        set enumText [doOspfV3Options [ospfV3LsaNetwork cget -options] $enumsArray(ospfV3LsaNetwork,options)]
    }

	if { $cmd == "ospfV3LsaLink" } {
        set enumText [doOspfV3Options [ospfV3LsaLink cget -options] $enumsArray(ospfV3LsaLink,options)]
    }

	if { $cmd == "ospfV3LsaInterAreaRouter" } {
        set enumText [doOspfV3Options [ospfV3LsaInterAreaRouter cget -options] $enumsArray(ospfV3LsaInterAreaRouter,options)]
    }

	if { $cmd == "ospfV3IpV6Prefix" } {
        set enumText [doOspfV3Options [ospfV3IpV6Prefix cget -options] $enumsArray(ospfV3IpV6Prefix,options)]
    }

	if { $cmd == "ospfV3LsaInterAreaPrefix" } {
        set enumText [doOspfV3Options [ospfV3LsaInterAreaPrefix cget -prefixOptions] $enumsArray(ospfV3LsaInterAreaPrefix,prefixOptions)]
    }
	if { $cmd == "ospfV3LsaAsExternal" } {
        set enumText [doOspfV3Options [ospfV3LsaAsExternal cget -prefixOptions] $enumsArray(ospfV3LsaAsExternal,prefixOptions)]
    }

    if { $cmd == "protocolServer" } {
        set enumText false
    }

    if { $parameter == "communityList" } {
        set value 0
        switch $cmd {
            bgp4RouteItem { 
                set value [bgp4RouteItem cget -communityList] 
            } 
            bgp4VpnRouteRange { 
                set value [bgp4VpnRouteRange cget -communityList] 
            }
            bgp4MplsRouteRange { 
                set value [bgp4MplsRouteRange cget -communityList] 
            }
        }
        set enumText [format "\"%s\"" [getCommunityListEnum $value]]
    }

    if { $cmd == "isisInterface" || $cmd == "isisRouter"} {
       set newValue [list]
	    foreach item [$cmd cget -$parameter] { 
			regsub -all "\"" $item {\\"} item
            regsub -all "{" $item "\\{" item
			regsub -all "}" $item "\\}" item
			lappend newValue $item
		}
        set enumText [format "\{%s\}" $newValue]
    }

    return $enumText
}


########################################################################
# Procedure: createProtocolsObsoleteParamsArray
#
# Description: This command creates obsolete params array
#
# Arguments(s):
#
# Result:   Always returns 0
#
########################################################################
proc scriptGen::createProtocolsObsoleteParamsArray { } \
{
    variable obsoleteParamsArray 
    set retCode 0

    set asPathParamList [list enableAsPathSeq asPathSeqList enableAsPathSet \
                              asPathSetList enableAsPathConfedSeq asPathConfedSeqList \
                              enableAsPathConfedSet asPathConfedSetList]
 
    set obsoleteParamsArray(bgp4AsPathItem) $asPathParamList  

	
    set protocolParamList [list arpServerEnable pingServerEnable repeatCount \
                                rate MacAddress IpAddress count mapType]
    set obsoleteParamsArray(protocolServer) $protocolParamList

	set isisRouteRangeParamList [list extendedDefaultMetric]
	set obsoleteParamsArray(isisRouteRange) $isisRouteRangeParamList

	set protocolInterfaceList [list ipAddress ipMask maskWidth networkIpAddress]
	set obsoleteParamsArray(ospfInterface) $protocolInterfaceList
	set obsoleteParamsArray(ldpInterface) $protocolInterfaceList

	# note that the traffic engineering ones are really deprecated
    set isisInterfaceList [list ipAddress ipMask maskWidth networkIpAddress trafficEngineeringMetric1 trafficEngineeringMetric2 enableTrafficEngineering]
	set obsoleteParamsArray(isisInterface) $isisInterfaceList
	
	set ldpAdvertiseFecRangeList [list baseLabel]
	set obsoleteParamsArray(ldpAdvertiseFecRange) $ldpAdvertiseFecRangeList

    set obsoleteParamsArray(pimsmServer) [list messagesPerInterval]

    set obsoleteParamsArray(pimsmJoinPrune) [list  joinPruneRate joinPruneRateDuration]
    
    set obsoleteParamsArray(bgp4Neighbor) [list  externalNeighborASNum]
    set obsoleteParamsArray(pimsmInterface) [list  neighborIpV6]
	
	return $retCode
}

########################################################################
# Procedure: createRoutingProtocolEnums
#
# This command calls all functions to create the enumsArray
# Arguments(s):
# 
# Returned Result:
########################################################################
proc scriptGen::createRoutingProtocolEnums { } \
{
	set retCode 0

	createBgp4Enums
    createOspfEnums
    createIsisEnums
    createRsvpEnums
    createRipEnums
	createLdpEnums
	createMulticastEnums
	createProtocolServerEnums
    createStpEnums
}


########################################################################
# Procedure: createBgp4Enums
#
# This command creates bgp4 enums
# Arguments(s):
# Returned Result:
#
########################################################################

proc scriptGen::createBgp4Enums { } \
{
    variable enumsArray
    variable oddParamsList

    set retCode 0
    set enumValList {}
    set enumList    {}

    set enumList [list bgpOriginIGP bgpOriginEGP bgpOriginIncomplete]
    setEnumValList $enumList enumValList
    set enumsArray(bgp4RouteItem,originProtocol)    $enumValList 

    set enumList [list bgpRouteAsPathNoInclude bgpRouteAsPathIncludeAsSeq bgpRouteAsPathIncludeAsSet\
                   bgpRouteAsPathIncludeAsSeqConf bgpRouteAsPathIncludeAsSetConf \
                   bgpRouteAsPathPrependAs]
    setEnumValList $enumList enumValList
    set enumsArray(bgp4RouteItem,asPathSetMode)    $enumValList

    set enumList [list bgpSegmentUnknown bgpSegmentAsSet bgpSegmentAsSequence bgpSegmentAsConfedSet\
                   bgpSegmentAsConfedSequence]
    setEnumValList $enumList enumValList
    set enumsArray(bgp4AsPathItem,asSegmentType)    $enumValList                
   
    set enumList [list bgpRouteNextHopSetManually bgpRouteNextHopSetSameAsLocalIp]
    setEnumValList $enumList enumValList
    set enumsArray(bgp4RouteItem,nextHopSetMode)    $enumValList

    set enumList [list bgp4NeighborInternal bgp4NeighborExternal]
    setEnumValList $enumList enumValList
    set enumsArray(bgp4Neighbor,type)    $enumValList

    set enumList [list bgp4AsNumModeFixed bgp4AsNumModeIncrement]
    setEnumValList $enumList enumValList
    set enumsArray(bgp4Neighbor,asNumMode)    $enumValList

    set enumList [list bgp4VpnFixedLabel bgp4VpnIncrementLabel]
    setEnumValList $enumList enumValList
    set enumsArray(bgp4VpnRouteRange,labelMode)    $enumValList
	set enumsArray(bgp4MplsRouteRange,labelMode)    $enumValList

	set enumList [list bgpRouteNextHopFixed bgpRouteNextHopIncrement bgpRouteNextHopIncrementPerPrefix]   
    setEnumValList $enumList enumValList
    set enumsArray(bgp4MplsRouteRange,nextHopMode)    $enumValList 
    set enumsArray(bgp4VpnRouteRange,nextHopMode)    $enumValList 

    set enumList [list bgp4DistinguisherTypeAS bgp4DistinguisherTypeIP]
    setEnumValList $enumList enumValList
    set enumsArray(bgp4VpnRouteRange,distinguisherType)    $enumValList
	set enumsArray(bgp4MplsRouteRange,distinguisherType)    $enumValList
	set enumsArray(bgp4VpnL3Site,distinguisherType)    $enumValList

    set enumList [list bgp4TargetTypeAS bgp4TargetTypeIP]
    setEnumValList $enumList enumValList
    set enumsArray(bgp4VpnTarget,type)    $enumValList

    set enumList [list vpnDistinguisherIncrementGlobalPart vpnDistinguisherIncrementLocalPart]
    setEnumValList $enumList enumValList
    set enumsArray(bgp4VpnRouteRange,distinguisherMode)    $enumValList
	set enumsArray(bgp4MplsRouteRange,distinguisherMode)    $enumValList

    set enumList [list bgpOriginIGP bgpOriginEGP bgpOriginIncomplete]
    setEnumValList $enumList enumValList
    set enumsArray(bgp4VpnRouteRange,originProtocol)    $enumValList 
    set enumsArray(bgp4MplsRouteRange,originProtocol)    $enumValList 

    set enumList [list addressTypeIpV4 addressTypeIpV6]   
    setEnumValList $enumList enumValList
    set enumsArray(bgp4VpnRouteRange,ipType)    $enumValList 
    set enumsArray(bgp4Neighbor,ipType)    $enumValList 
    set enumsArray(bgp4RouteItem,ipType)    $enumValList 
	set enumsArray(bgp4MplsRouteRange,ipType)    $enumValList 
	set enumsArray(bgp4RouteItem,nextHopIpType)    $enumValList

	set enumList [list bgpRouteNextHopFixed bgpRouteNextHopIncrement bgpRouteNextHopIncrementPerPrefix]   
    setEnumValList $enumList enumValList
    set enumsArray(bgp4RouteItem,nextHopMode)    $enumValList 

    set enumList [list bgpCommunityNoExport bgpCommunityNoAdvertise bgpCommunityExportSubconfed]   
    setEnumValList $enumList enumValList
    
    set enumsArray(bgp4VpnRouteRange,communityList)     $enumValList 
    set enumsArray(bgp4RouteItem,communityList)         $enumValList 
	set enumsArray(bgp4MplsRouteRange,communityList)    $enumValList 

    lappend oddParamsList [list bgp4VpnRouteRange communityList \
                                bgp4RouteItem communityList \
                                bgp4MplsRouteRange communityList]

    return $retCode
}   


########################################################################
# Procedure: createOspfEnums
#
# This command creates ospf enums
# Arguments(s):
# Returned Result:
#
########################################################################

proc scriptGen::createOspfEnums { } \
{

    variable enumsArray
    variable oddParamsList

    set retCode 0
    set enumValList {}
    set enumList    {}

    set enumList [list ospfRouteOriginArea ospfRouteOriginExternal]
    setEnumValList $enumList enumValList
    set enumsArray(ospfRouteRange,routeOrigin)    $enumValList 

    set enumList [list ospfLinkPointToPoint ospfLinkTransit ospfLinkStub\
                   ospfLinkVirtual] 
    setEnumValList $enumList enumValList
    set enumsArray(ospfRouterLsaInterface,linkType)    $enumValList 

    set enumList [list ospfBroadcast ospfPointToPoint ospfPointToMultipoint]
    setEnumValList $enumList enumValList
    set enumsArray(ospfInterface,networkType)    $enumValList 

    set enumList [list ospfInterfaceAuthenticationNull ospfInterfaceAuthenticationPassword ospfInterfaceAuthenticationMD5]
    setEnumValList $enumList enumValList
    set enumsArray(ospfInterface,authenticationMethod)    $enumValList 

    set enumList [list ospfLsaRouter ospfLsaNetwork ospfLsaSummaryIp \
                       ospfLsaSummaryAs ospfLsaExternal ospfLsaOpaqueLocal \
                       ospfLsaOpaqueArea ospfLsaOpaqueDomain]
    setEnumValList $enumList enumValList
    set enumsArray(ospfUserLsa,lsaType)    $enumValList 

    set enumList [list ospfTlvLinkPointToPoint ospfTlvLinkMultiAccess]
    setEnumValList $enumList enumValList
    set enumsArray(ospfUserLsa,tlvLinkType)    $enumValList 

    set enumList [list ospfRouterTlv ospfLinkTlv]
    setEnumValList $enumList enumValList
    set enumsArray(ospfUserLsa,tlvType)    $enumValList 

    set enumList [list ospfLinkPointToPoint ospfLinkTransit ospfLinkStub\
                   ospfLinkVirtual] 
    setEnumValList $enumList enumValList
    set enumsArray(ospfInterface,linkType)    $enumValList 

    set enumList [list ospfExteralMetricType1 ospfExteralMetricType2]
    setEnumValList $enumList enumValList
    set enumsArray(ospfUserLsa,externalMetricEBit)    $enumValList
    
    set enumList [list ospfNetworkRangeLinkBroadcast ospfNetworkRangeLinkPointToPoint]
    setEnumValList $enumList enumValList
    set enumsArray(ospfNetworkRange,linkType)    $enumValList

#ospfV3 enums

	set enumList [list ospfV3InterfaceOptionDCBit ospfV3InterfaceOptionRBit ospfV3InterfaceOptionNBit \
					ospfV3InterfaceOptionMCBit ospfV3InterfaceOptionEBit ospfV3InterfaceOptionV6Bit]
    setEnumValList $enumList enumValList
    set enumsArray(ospfV3Interface,options)    $enumValList

	lappend oddParamsList [list ospfV3Interface options]

	set enumList [list ospfV3RouteOriginAnotherArea ospfV3RouteOriginExternalType1 \
					ospfV3RouteOriginExternalType2]
    setEnumValList $enumList enumValList
    set enumsArray(ospfV3RouteRange,routeOrigin)    $enumValList

	set enumList [list ospfV3LsaOptionV6Bit ospfV3LsaOptionEBit ospfV3LsaOptionMCBit \
					ospfV3LsaOptionNBit ospfV3LsaOptionRBit ospfV3LsaOptionDCBit]
    setEnumValList $enumList enumValList
    set enumsArray(ospfV3LsaInterAreaRouter,options)    $enumValList
	set enumsArray(ospfV3LsaLink,options)    $enumValList
	set enumsArray(ospfV3LsaNetwork,options)    $enumValList
	set enumsArray(ospfV3LsaRouter,options)    $enumValList

	lappend oddParamsList [list ospfV3LsaInterAreaRouter options]
	lappend oddParamsList [list ospfV3LsaLink options]
	lappend oddParamsList [list ospfV3LsaNetwork options]
	lappend oddParamsList [list ospfV3LsaRouter options]

	set enumList [list ospfV3PrefixOptionPBit ospfV3PrefixOptionMCBit ospfV3PrefixOptionLABit \
					ospfV3PrefixOptionNUBit]
    setEnumValList $enumList enumValList
    set enumsArray(ospfV3IpV6Prefix,options)                  $enumValList
	set enumsArray(ospfV3LsaInterAreaPrefix,prefixOptions)    $enumValList
	set enumsArray(ospfV3LsaAsExternal,prefixOptions)		  $enumValList

	lappend oddParamsList [list ospfV3IpV6Prefix options]
	lappend oddParamsList [list ospfV3LsaInterAreaPrefix prefixOptions]
	lappend oddParamsList [list ospfV3LsaAsExternal prefixOptions]


	set enumList [list ospfV3LsaRouterInterfacePointToPoint ospfV3LsaRouterInterfaceTransit\
					ospfV3LsaRouterInterfaceVirtual]
    setEnumValList $enumList enumValList
    set enumsArray(ospfV3LsaRouterInterface,type)    $enumValList

	set enumList [list ospfV3InterfacePointToPoint ospfV3InterfaceBroadcast]
    setEnumValList $enumList enumValList
    set enumsArray(ospfV3Interface,type)    $enumValList

    return $retCode
}   


########################################################################
# Procedure: createIsisEnums
#
# This command creates Isis enums
# Arguments(s):
# Returned Result:
#
########################################################################

proc scriptGen::createIsisEnums { } \
{

    variable enumsArray
    variable oddParamsList

    set retCode 0
    set enumValList {}
    set enumList    {}

	set enumList [list isisDraftVersion3 isisDraftVersion4]   
    setEnumValList $enumList enumValList
    set enumsArray(isisRouter,hitlessRestartVersion)    $enumValList

	set enumList [list isisNormalRouter isisRestartingRouter isisStartingRouter isisHelperRouter]   
    setEnumValList $enumList enumValList
    set enumsArray(isisRouter,hitlessRestartMode)    $enumValList

    set enumList [list isisAuthTypeNone isisAuthTypePassword]
    setEnumValList $enumList enumValList
    set enumsArray(isisRouter,domainAuthType)        $enumValList
    set enumsArray(isisRouter,areaAuthType)          $enumValList
    set enumsArray(isisInterface,circuitAuthType)    $enumValList

    set enumList [list isisBroadcast isisPointToPoint]
    setEnumValList $enumList enumValList
    set enumsArray(isisInterface,networkType)    $enumValList 

    set enumList [list isisLevel1 isisLevel2 isisLevel1Level2]   
    setEnumValList $enumList enumValList
    set enumsArray(isisInterface,level)    $enumValList 

    set enumList [list addressTypeIpV4 addressTypeIpV6]   
    setEnumValList $enumList enumValList
    set enumsArray(isisRouteRange,ipType)    $enumValList
	set enumsArray(isisGridInternodeRoute,ipType)    $enumValList
	set enumsArray(isisGridRoute,ipType)    $enumValList

	set enumList [list isisRouteInternal isisRouteExternal]   
    setEnumValList $enumList enumValList
    set enumsArray(isisRouteRange,routeOrigin)    $enumValList

	set enumList [list isisGridLinkPointToPoint isisGridLinkBroadcast]   
    setEnumValList $enumList enumValList
    set enumsArray(isisGrid,linkType)    $enumValList

    lappend oddParamsList [list isisRouter domainRxPasswordList]
    lappend oddParamsList [list isisRouter areaRxPasswordList]
    lappend oddParamsList [list isisInterface circuitRxPasswordList]

    return $retCode
} 

########################################################################
# Procedure: createRsvpEnums
#
# Description: This command creates Rsvp enums
#
# Arguments(s):
#
# Result:   Always returns 0
#
########################################################################
proc scriptGen::createRsvpEnums { } \
{
    variable enumsArray

    set retCode 0
    set enumValList {}
    set enumList    {}

    set prependEroModeEnumList [list rsvpNone rsvpPrependLoose rsvpPrependStrict]
    setEnumValList $prependEroModeEnumList enumValList
    set enumsArray(rsvpDestinationRange,prependEroMode)    $enumValList 

    set behaviorEnumList [list rsvpIngress rsvpEgress]   
    setEnumValList $behaviorEnumList enumValList
    set enumsArray(rsvpDestinationRange,behavior)    $enumValList 

    set typeEnumList [list rsvpTrafficEndPoint rsvpTunnelEndPoint]   
    setEnumValList $typeEnumList enumValList
    set enumsArray(rsvpDestinationRange,type)    $enumValList

    set reservationStyleEnumList [list rsvpFF rsvpSE]   
    setEnumValList $reservationStyleEnumList enumValList
    set enumsArray(rsvpDestinationRange,reservationStyle)    $enumValList

    set eroTypeEnumList [list rsvpEroIpV4 rsvpAs]   
    setEnumValList $eroTypeEnumList enumValList
    set enumsArray(rsvpEroItem,type)    $enumValList

    set rroTypeEnumList [list rsvpRroIpV4 rsvpLabel]   
    setEnumValList $rroTypeEnumList enumValList
    set enumsArray(rsvpRroItem,type)    $enumValList

    set rroTypeEnumList [list rsvpEgressAlwaysUseConfiguredStyle \
                              rsvpEgressUseSEIfInAttribute]   
    setEnumValList $rroTypeEnumList enumValList
    set enumsArray(rsvpDestinationRange,egressBehavior)    $enumValList

    set rroTypeEnumList [list rsvpLabelValueExplicitNull rsvpLabelValueRouterAlert \
                              rsvpLabelValueIPv6ExplicitNull rsvpLabelValueImplicitNull]   
    setEnumValList $rroTypeEnumList enumValList
    set enumsArray(rsvpDestinationRange,labelValue)    $enumValList

    return $retCode
}


########################################################################
# Procedure: createRipEnums
#
# Description: This command creates Rip enums
#
# Arguments(s):
#
# Result:   Always returns 0
#
########################################################################
proc scriptGen::createRipEnums { } \
{

    variable enumsArray

    set retCode 0
    set enumValList {}
    set enumList    {}

    set sendTypeEnumList [list ripMulticast ripBroadcastV1 ripBroadcastV2]
    setEnumValList $sendTypeEnumList enumValList
    set enumsArray(ripInterfaceRouter,sendType)    $enumValList 

    set responseModeEnumList [list ripDefault ripSplitHorizon ripPoisonReverse ripSplitHorizonSpaceSaver ripSilent]   
    setEnumValList $responseModeEnumList enumValList
    set enumsArray(ripInterfaceRouter,responseMode)    $enumValList 

    set receiveTypeEnumList [list ripInvalidVersion ripReceiveVersion1 ripReceiveVersion2 ripReceiveVersion1And2]   
    setEnumValList $receiveTypeEnumList enumValList
    set enumsArray(ripInterfaceRouter,receiveType)    $enumValList

    return $retCode
}


########################################################################
# Procedure: createLdpEnums
#
# Description: This command creates LDP enums
#
# Arguments(s):
#
# Result:   Always returns 0
#
########################################################################
proc scriptGen::createLdpEnums { } \
{

    variable enumsArray

    set retCode 0
    set enumValList {}
    set enumList    {}

    set enumList [list ldpInterfaceDownstreamUnsolicited ldpInterfaceDownstreamOnDemand]

    setEnumValList $enumList enumValList
    set enumsArray(ldpInterface,advertisingMode)  $enumValList

#    set enumList [list ldpInterfaceRequestModeUnknown ldpInterfaceIndependent]

    set enumList [list ldpInterfaceIndependent]
    setEnumValList $enumList enumValList
    set enumsArray(ldpInterface,requestingMode)  $enumValList

    set enumList [list ldpAdvertiseFecRangeNone ldpAdvertiseFecRangeIncrement]
    setEnumValList $enumList enumValList
    set enumsArray(ldpAdvertiseFecRange,labelIncrementMode)  $enumValList

    
    set enumList [list ldpInterfaceBasic ldpInterfaceExtended ldpInterfaceExtendedMartini]
    setEnumValList $enumList enumValList
    set enumsArray(ldpInterface,discoveryMode)  $enumValList

    set enumList [list l2VpnInterfaceFrameRelay l2VpnInterfaceATMAAL5 l2VpnInterfaceATMXCell \
                   l2VpnInterfaceVLAN  l2VpnInterfaceEthernet l2VpnInterfaceHDLC l2VpnInterfacePPP \
                   l2VpnInterfaceCEM l2VpnInterfaceATMVCC l2VpnInterfaceATMVPC l2VpnInterfaceEthernetVPLS]
    setEnumValList $enumList enumValList
    set enumsArray(ldpL2VpnInterface,type)  $enumValList

    set enumList [list ldpL2VpnVcFixedLabel ldpL2VpnVcIncrementLabel]
    setEnumValList $enumList enumValList
    set enumsArray(ldpL2VpnVcRange,labelMode)  $enumValList

	set enumList [list atmVcUnidirectional atmVcBidirectional]
    setEnumValList $enumList enumValList
    set enumsArray(ldpInterface,atmVcDirection)  $enumValList



    return $retCode
}


########################################################################
# Procedure: createMulticastEnums
#
# This command creates IGMPVx, MLD, PIM-SM enums
# Arguments(s):
# Returned Result:
#
########################################################################

proc scriptGen::createMulticastEnums { } \
{
    variable enumsArray

    set retCode 0
    set enumValList {}
    set enumList    {}

	set enumList [list mldVersion1 mldVersion2]      
    setEnumValList $enumList enumValList
    set enumsArray(mldHost,version)  $enumValList

	set enumList [list multicastSourceModeInclude multicastSourceModeExclude]      
    setEnumValList $enumList enumValList
    set enumsArray(mldGroupRange,sourceMode)  $enumValList
	set enumsArray(igmpGroupRange,sourceMode)  $enumValList

	set enumList [list igmpHostVersion1 igmpHostVersion2 igmpHostVersion3]      
    setEnumValList $enumList enumValList
    set enumsArray(igmpHost,version)  $enumValList

	set enumList [list pimsmGenerationIdModeIncremental pimsmGenerationIdModeRandom \
					pimsmGenerationIdModeConstant]      
    setEnumValList $enumList enumValList
    set enumsArray(pimsmInterface,generationIdMode)  $enumValList

	set enumList [list pimsmJoinsPrunesTypeRP pimsmJoinsPrunesTypeG pimsmJoinsPrunesTypeSG \
					pimsmJoinsPrunesTypeSPTSwitchOver pimsmJoinsPrunesTypeRegisterTriggeredSG]      
    setEnumValList $enumList enumValList
    set enumsArray(pimsmJoinPrune,rangeType)  $enumValList

    set enumList [list pimsmMappingFullyMeshed pimsmMappingOneToOne]     
    setEnumValList $enumList enumValList
    set enumsArray(pimsmJoinPrune,sourceGroupMapping)  $enumValList
    set enumsArray(pimsmSource,sourceGroupMapping)  $enumValList

    set enumList [list addressTypeIpV4 addressTypeIpV6]     
    setEnumValList $enumList enumValList
    set enumsArray(pimsmInterface,ipType)  $enumValList


    return $retCode
}

########################################################################
# Procedure: createProtocolServerEnums
#
# Description: This command creates protocolServer enums
#
# Arguments(s):
#
# Result:   Always returns 0
#
########################################################################
proc scriptGen::createProtocolServerEnums { } \
{
	lappend oddParamsList [list protocolServer enableBgp4CreateInterface enableIsisCreateInterface enableOspfCreateInterface \
                            enableRipCreateInterface enableRsvpCreateInterface enableIgmpCreateInterface]

    set enumList [list false]
    setEnumValList $enumList enumValList
    set enumsArray(protocolServer,enableBgp4CreateInterface)    $enumValList 
	set enumsArray(protocolServer,enableIsisCreateInterface)    $enumValList 
	set enumsArray(protocolServer,enableOspfCreateInterface)    $enumValList 
	set enumsArray(protocolServer,enableRipCreateInterface)     $enumValList 
	set enumsArray(protocolServer,enableRsvpCreateInterface)    $enumValList
	set enumsArray(protocolServer,enableIgmpCreateInterface)    $enumValList 
}

########################################################################
# Procedure: createStpEnums
#
# Description: This command creates STP enums
#
# Arguments(s):
#
# Result:   Always returns 0
#
########################################################################
proc scriptGen::createStpEnums { } \
{
    variable enumsArray

    set retCode 0
    set enumValList {}
    set enumList    {}

    set enumList [list stpInterfacePointToPoint stpInterfaceShared]

    setEnumValList $enumList enumValList
    set enumsArray(stpInterface,interfaceType)  $enumValList

    set enumList [list bridgeStp bridgeRstp]

    setEnumValList $enumList enumValList
    set enumsArray(stpBridge,mode)  $enumValList


}