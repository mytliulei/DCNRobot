#############################################################################################
#
# ixTclProtocolSetup.tcl
#
#  Package initialization file
#
# Copyright © 1997-2003 by IXIA.
# All Rights Reserved.
#
#############################################################################################
## these are the simple ones that don't have any ptr parameters...


set ixTclProtocol::noArgList    { protocolServer}

## these are the ones that we need simple pointers returned for other stuff...
set ixTclProtocol::pointerList   { ospfV3NetworkRange  ldpAtmLabelRange ldpLearnedIpV4AtmLabel \
                              ldpAssignedAtmLabel \
                              stpInterface stpLan stpInterfaceLearnedInfo}

## these are basically all the protocols that require a portPtr parameter for instantiation
                                   
## this initial list is all the complicated ones
set ixTclProtocol::commandList  { bgp4Server bgp4InternalTable bgp4InternalNeighborItem bgp4ExternalTable bgp4ExternalNeighborItem \
                             bgp4Neighbor bgp4RouteFilter bgp4LearnedRoute bgp4RouteItem bgp4AsPathItem bgpStatsQuery bgp4StatsQuery bgp4IncludePrefixFilter \
                             bgp4VpnL3Site bgp4VpnTarget bgp4VpnRouteRange bgp4MplsRouteRange  bgp4ExtendedCommunity bgp4VpnImportTarget \
                             ospfServer ospfRouter ospfRouteRange ospfInterface ospfRouterLsaInterface ospfUserLsa ospfUserLsaGroup ospfNetworkRange \
                             isisServer isisRouter isisRouteRange isisInterface isisGridTePath isisGridOutsideLink \
                             isisGridRangeTe isisGridEntryTe isisGridRoute isisGridInternodeRoute isisGrid \
							 ripngServer ripngRouter ripngRouteRange ripngInterface \
                             rsvpServer rsvpNeighborPair rsvpDestinationRange rsvpSenderRange rsvpEroItem rsvpRroItem rsvpPlrNodeIdPair\
							 rsvpCustomTlv ripServer ripInterfaceRouter ripRouteRange \
                             ldpServer ldpRouter ldpInterface ldpAdvertiseFecRange ldpLearnedIpV4Label ldpLearnedMartiniLabel \
                             ldpL2VpnInterface ldpL2VpnVcRange ldpTargetedPeer ldpL2VplsMacRange ldpExplicitIncludeIpFec ldpRequestFecRange \
							 mldServer mldHost mldGroupRange mldSourceRange \
							 igmpVxServer igmpHost igmpGroupRange igmpSourceRange \
							 ospfV3Server ospfV3Router ospfV3Interface ospfV3RouteRange ospfV3UserLsaGroup ospfV3LsaRouterInterface \
							 ospfV3IpV6Prefix ospfV3LsaAsExternal ospfV3LsaInterAreaPrefix ospfV3LsaInterAreaRouter ospfV3LsaIntraAreaPrefix \
							 ospfV3LsaLink ospfV3LsaNetwork ospfV3LsaRouter \
							 pimsmServer pimsmRouter pimsmInterface pimsmJoinPrune pimsmSource pimsmLearnedJoinState \
                             stpServer stpBridge stpBridgeLearnedInfo}

set myList [join [list $ixTclProtocol::noArgList $ixTclProtocol::pointerList $ixTclProtocol::commandList]]
eval lappend ::halCommands $myList 

if [isWindows] {

	load ixTCLProtocol.dll

	rename protocolServer ""

    ############################ OBJECT INSTANTIATION ##########################

    foreach procName $ixTclProtocol::noArgList {
        set tclCmd [format "TCL%s%s" [string toupper [string index $procName 0]] [string range $procName 1 end]]
        ixTclHal::createCommand $tclCmd $procName
    }
    foreach procName $ixTclProtocol::pointerList {
        set tclCmd [format "TCL%s%s" [string toupper [string index $procName 0]] [string range $procName 1 end]]
        ixTclHal::createCommandPtr $tclCmd $procName
    }

    # BGP command set

    ixTclHal::createCommandPtr TCLBgp4AsPathItem        bgp4AsPathItem
	ixTclHal::createCommandPtr TCLBgp4ExtendedCommunity bgp4ExtendedCommunity

    ixTclHal::createCommandPtr TCLBgp4RouteItem         bgp4RouteItem       \$::bgp4AsPathItemPtr \$::bgp4ExtendedCommunityPtr
    ixTclHal::createCommandPtr TCLBgp4RouteFilter       bgp4RouteFilter
    ixTclHal::createCommandPtr TCLBgp4LearnedRoute      bgp4LearnedRoute
	ixTclHal::createCommandPtr TCLBgp4MplsRouteRange	bgp4MplsRouteRange  \$::bgp4AsPathItemPtr \$::bgp4ExtendedCommunityPtr
	ixTclHal::createCommandPtr TCLBgp4IncludePrefixFilter	bgp4IncludePrefixFilter
    
    ixTclHal::createCommandPtr TCLBgp4VpnRouteRange bgp4VpnRouteRange  \$::bgp4AsPathItemPtr  \$::bgp4ExtendedCommunityPtr
    ixTclHal::createCommandPtr TCLBgp4VpnTarget     bgp4VpnTarget
	ixTclHal::createCommandPtr TCLBgp4VpnTarget     bgp4VpnImportTarget	
    ixTclHal::createCommandPtr TCLBgp4VpnL3Site     bgp4VpnL3Site      \$::bgp4VpnRouteRangePtr \$::bgp4VpnTargetPtr   \$::bgp4VpnImportTargetPtr  \$::bgp4LearnedRoutePtr

    ixTclHal::createCommandPtr TCLBgp4Neighbor              bgp4Neighbor             \$::bgp4RouteItemPtr \$::bgp4VpnL3SitePtr \$::bgp4RouteFilterPtr \$::bgp4LearnedRoutePtr  \$::bgp4MplsRouteRangePtr  \$::bgp4IncludePrefixFilterPtr
    ixTclHal::createCommandPtr TCLBgp4InternalNeighborItem  bgp4InternalNeighborItem \$::bgp4RouteItemPtr
    ixTclHal::createCommandPtr TCLBgp4ExternalNeighborItem  bgp4ExternalNeighborItem \$::bgp4RouteItemPtr
    ixTclHal::createCommand    TCLBgp4Server                bgp4Server               \$::bgp4NeighborPtr
    
    ixTclHal::createCommand    TCLBgp4ExternalTable         bgp4ExternalTable        \$::bgp4ExternalNeighborItemPtr
    ixTclHal::createCommand    TCLBgp4InternalTable         bgp4InternalTable        \$::bgp4InternalNeighborItemPtr
    ixTclHal::createCommand    TCLBGPStatsQuery             bgp4StatsQuery
    ixTclHal::createCommand    TCLBGPStatsQuery             bgpStatsQuery   ;# this one is provided for backwards compatibility


    # OSPF command set
        
    ixTclHal::createCommandPtr TCLOspfRouteRange         ospfRouteRange
    ixTclHal::createCommandPtr TCLOspfRouterLsaInterface ospfRouterLsaInterface

    ixTclHal::createCommandPtr TCLOspfUserLsa            ospfUserLsa            \$::ospfRouterLsaInterfacePtr
    ixTclHal::createCommandPtr TCLOspfUserLsaGroup       ospfUserLsaGroup       \$::ospfUserLsaPtr

    ixTclHal::createCommandPtr TCLOspfNetworkRange       ospfNetworkRange
    ixTclHal::createCommandPtr TCLOspfInterface          ospfInterface          \$::ospfUserLsaPtr \$::ospfNetworkRangePtr
    ixTclHal::createCommandPtr TCLOspfRouter             ospfRouter             \$::ospfInterfacePtr \$::ospfRouteRangePtr \$::ospfUserLsaGroupPtr

    ixTclHal::createCommand    TCLOspfServer             ospfServer             \$::ospfRouterPtr    
     

     # Isis command set

	ixTclHal::createCommandPtr TCLIsisGridTePath          isisGridTePath
	ixTclHal::createCommandPtr TCLIsisGridInternodeRoute  isisGridInternodeRoute
	ixTclHal::createCommandPtr TCLIsisGridOutsideLink     isisGridOutsideLink    \$::isisGridInternodeRoutePtr
    ixTclHal::createCommandPtr TCLIsisGridTe              isisGridRangeTe
    ixTclHal::createCommandPtr TCLIsisGridTe              isisGridEntryTe
    ixTclHal::createCommandPtr TCLIsisGridRoute           isisGridRoute
    ixTclHal::createCommandPtr TCLIsisGrid                isisGrid    \$::isisGridOutsideLinkPtr   \$::isisGridRangeTePtr  \$::isisGridEntryTePtr \
																	  \$::isisGridRoutePtr    \$::isisGridInternodeRoutePtr    \$::isisGridTePathPtr																		

    ixTclHal::createCommandPtr TCLIsisInterface          isisInterface
    ixTclHal::createCommandPtr TCLIsisRouteRange         isisRouteRange
    ixTclHal::createCommandPtr TCLIsisRouter             isisRouter             \$::isisInterfacePtr \$::isisRouteRangePtr  \$::isisGridPtr

    ixTclHal::createCommand    TCLIsisServer             isisServer             \$::isisRouterPtr    
     
    
	# RSVP command set      

    ixTclHal::createCommandPtr TCLRsvpEroItem            rsvpEroItem
    ixTclHal::createCommandPtr TCLRsvpRroItem            rsvpRroItem
	ixTclHal::createCommandPtr TCLRsvpPlrNodeIdPair      rsvpPlrNodeIdPair
	ixTclHal::createCommandPtr TCLRsvpCustomTlv          rsvpCustomTlv
    ixTclHal::createCommandPtr TCLRsvpSenderRange        rsvpSenderRange		\$::rsvpPlrNodeIdPairPtr  \$::rsvpCustomTlvPtr
    ixTclHal::createCommandPtr TCLRsvpDestinationRange   rsvpDestinationRange   \$::rsvpSenderRangePtr \$::rsvpRroItemPtr \$::rsvpEroItemPtr \$::rsvpCustomTlvPtr
    ixTclHal::createCommandPtr TCLRsvpNeighborPair       rsvpNeighborPair       \$::rsvpDestinationRangePtr  \$::rsvpCustomTlvPtr

    ixTclHal::createCommand    TCLRsvpServer             rsvpServer \$::rsvpNeighborPairPtr    


    # RIP command set 
	     
    ixTclHal::createCommandPtr TCLRipRouteRange          ripRouteRange
    ixTclHal::createCommandPtr TCLRipInterfaceRouter     ripInterfaceRouter     \$::ripRouteRangePtr
    
    ixTclHal::createCommand    TCLRipServer              ripServer               \$::ripInterfaceRouterPtr    


    # RIPNG command set

    ixTclHal::createCommandPtr TCLRipngInterface         ripngInterface
    ixTclHal::createCommandPtr TCLRipngRouteRange        ripngRouteRange
    ixTclHal::createCommandPtr TCLRipngRouter            ripngRouter            \$::ripngRouteRangePtr \$::ripngInterfacePtr

    ixTclHal::createCommand    TCLRipngServer            ripngServer            \$::ripngRouterPtr


    # LDP command set   

    ixTclHal::createCommandPtr TCLLdpAdvertiseFecRange    ldpAdvertiseFecRange
    ixTclHal::createCommandPtr TCLLdpRequestFecRange      ldpRequestFecRange
    ixTclHal::createCommandPtr TCLLdpTargetedPeer         ldpTargetedPeer
    ixTclHal::createCommandPtr TCLLdpLearnedIpV4Label     ldpLearnedIpV4Label
	ixTclHal::createCommandPtr TCLLdpExplicitIncludeIpFec ldpExplicitIncludeIpFec

	ixTclHal::createCommandPtr TCLLdpLearnedMartiniLabel ldpLearnedMartiniLabel
    ixTclHal::createCommandPtr TCLLdpL2VplsMacRange		 ldpL2VplsMacRange
    ixTclHal::createCommandPtr TCLLdpL2VpnVcRange        ldpL2VpnVcRange			\$::ldpL2VplsMacRangePtr
    ixTclHal::createCommandPtr TCLLdpL2VpnInterface      ldpL2VpnInterface          \$::ldpL2VpnVcRangePtr
        
    ixTclHal::createCommandPtr TCLLdpInterface  ldpInterface    \$::ldpTargetedPeerPtr \$::ldpLearnedIpV4LabelPtr \$::ldpLearnedMartiniLabelPtr \
                                                                \$::ldpLearnedIpV4AtmLabelPtr \$::ldpAssignedAtmLabelPtr \$::ldpAtmLabelRangePtr
    ixTclHal::createCommandPtr TCLLdpRouter     ldpRouter       \$::ldpInterfacePtr \$::ldpAdvertiseFecRangePtr \$::ldpL2VpnInterfacePtr \$::ldpExplicitIncludeIpFecPtr \$::ldpRequestFecRangePtr

    ixTclHal::createCommand    TCLLdpServer     ldpServer       \$::ldpRouterPtr    

	# MLD command set

    ixTclHal::createCommandPtr TCLMldSourceRange        mldSourceRange
    ixTclHal::createCommandPtr TCLMldGroupRange			mldGroupRange	\$::mldSourceRangePtr
    ixTclHal::createCommandPtr TCLMldHost		        mldHost         \$::mldGroupRangePtr
    ixTclHal::createCommand    TCLMldServer             mldServer		\$::mldHostPtr
	

	# OspfV3 command set
	  
    ixTclHal::createCommandPtr    TCLOspfV3LsaRouterInterface	   ospfV3LsaRouterInterface
    ixTclHal::createCommandPtr    TCLOspfV3IpV6Prefix	           ospfV3IpV6Prefix

    ixTclHal::createCommandPtr    TCLOspfV3LsaAsExternal	       ospfV3LsaAsExternal
	ixTclHal::createCommandPtr    TCLOspfV3LsaInterAreaPrefix	   ospfV3LsaInterAreaPrefix
    ixTclHal::createCommandPtr    TCLOspfV3LsaInterAreaRouter	   ospfV3LsaInterAreaRouter
    ixTclHal::createCommandPtr    TCLOspfV3LsaIntraAreaPrefix	   ospfV3LsaIntraAreaPrefix   \$::ospfV3IpV6PrefixPtr
    ixTclHal::createCommandPtr    TCLOspfV3LsaLink	               ospfV3LsaLink			  \$::ospfV3IpV6PrefixPtr
    ixTclHal::createCommandPtr    TCLOspfV3LsaNetwork	           ospfV3LsaNetwork
    ixTclHal::createCommandPtr    TCLOspfV3LsaRouter	           ospfV3LsaRouter		\$::ospfV3LsaRouterInterfacePtr

    ixTclHal::createCommandPtr TCLOspfV3UserLsaGroup  ospfV3UserLsaGroup    \$::ospfV3LsaAsExternalPtr  \
																			\$::ospfV3LsaInterAreaPrefixPtr  \
																			\$::ospfV3LsaInterAreaRouterPtr  \
																			\$::ospfV3LsaIntraAreaPrefixPtr  \
																			\$::ospfV3LsaLinkPtr  \
																			\$::ospfV3LsaNetworkPtr  \
																			\$::ospfV3LsaRouterPtr

	ixTclHal::createCommandPtr TCLOspfV3RouteRange         ospfV3RouteRange 

    ixTclHal::createCommandPtr TCLOspfV3Interface          ospfV3Interface          
    ixTclHal::createCommandPtr TCLOspfV3Router             ospfV3Router             \$::ospfV3InterfacePtr \
                                                                                    \$::ospfV3RouteRangePtr \
                                                                                    \$::ospfV3UserLsaGroupPtr \
                                                                                    \$::ospfV3NetworkRangePtr

    ixTclHal::createCommand    TCLOspfV3Server             ospfV3Server             \$::ospfV3RouterPtr    



	# IGMP command set

	ixTclHal::createCommandPtr TCLIgmpSourceRange        igmpSourceRange
	ixTclHal::createCommandPtr TCLIgmpGroupRange		 igmpGroupRange	   \$::igmpSourceRangePtr
	ixTclHal::createCommandPtr TCLIgmpHost               igmpHost          \$::igmpGroupRangePtr
	ixTclHal::createCommand    TCLIgmpVxServer           igmpVxServer	   \$::igmpHostPtr
	
	ixTclHal::createCommandPtr TCLPimsmLearnedJoinState	 pimsmLearnedJoinState
	ixTclHal::createCommandPtr TCLPimsmJoinPrune         pimsmJoinPrune
    ixTclHal::createCommandPtr TCLPimsmSource            pimsmSource		    \$::pimsmLearnedJoinStatePtr
    ixTclHal::createCommandPtr TCLPimsmInterface         pimsmInterface         \$::pimsmJoinPrunePtr \$::pimsmSourcePtr
	ixTclHal::createCommandPtr TCLPimsmRouter            pimsmRouter            \$::pimsmInterfacePtr 
    ixTclHal::createCommand    TCLPimsmServer            pimsmServer            \$::pimsmRouterPtr    

    # STP command set
    ixTclHal::createCommandPtr TCLStpBridgeLearnedInfo stpBridgeLearnedInfo            \$::stpInterfaceLearnedInfoPtr
    ixTclHal::createCommandPtr TCLStpBridge            stpBridge            \$::stpInterfacePtr  \$::stpBridgeLearnedInfoPtr
    ixTclHal::createCommand    TCLStpServer            stpServer            \$::stpBridgePtr \$::stpLanPtr

}