#############################################################################################
#
# sgProtocolServer.tcl  Utilities for scriptgen
#
#   Copyright © 1997 - 2004 by IXIA.
#   All Rights Reserved.
#
#	Revision Log:
#	04-03-2004	EM	Genesis
#
#
#############################################################################################

########################################################################
# Procedure: doProtocols
#
# This command generats commands for enabled protocols.
# Arguments(s):
# chassis : chassis Id
# card    : card Id
# port    : port Id
# Returned Result:
#
########################################################################

proc scriptGen::doProtocols {chassis card port} \
{
	if {[protocolServer cget -enableBgp4Service]} {
        getBgp $chassis $card $port
    }
    
    if {[protocolServer cget -enableOspfService] } {
        getOspf $chassis $card $port
    }

    if {[protocolServer cget -enableIsisService]} {
        getIsis $chassis $card $port
    }
    if {[protocolServer cget -enableRsvpService]} {
        getRsvp $chassis $card $port
    }
    
    if {[protocolServer cget -enableRipService]} {
        getRip $chassis $card $port
    }

    if {[protocolServer cget -enableRipngService]} {
        getRipng $chassis $card $port
    }

    if {[protocolServer cget -enableLdpService]} {
        getLdp $chassis $card $port
    }

	if {[protocolServer cget -enableMldService]} {
        getMld $chassis $card $port
    }
	
	if {[protocolServer cget -enableOspfV3Service]} {
        getOspfV3 $chassis $card $port
    }
	
	if {[protocolServer cget -enablePimsmService]} {
        getPimsm $chassis $card $port
    }

    if [protocolServer cget -enableIgmpQueryResponse] {

		if {[port isValidFeature $chassis $card $port $::portFeatureProtocolIGMP]} {
			catch {getIgmpVx $chassis $card $port}
		} else {
			if {![igmpAddressTable get $chassis $card $port]} {
				getIgmpProtocol $chassis $card $port
			} else {
				logMsg "Error in getting igmpAddressTable"
			set retCode 1 
			}
		}	
	}

    if {[protocolServer cget -enableStpService]} {
        getStp $chassis $card $port
    }
}


########################################################################
# 
#       ------------  BGP procedures  ------------
#
########################################################################

########################################################################
# Procedure: getBgp
#
# This command generats bgp server commands
# Arguments(s):
# chassis : chassis Id
# card    : card Id
# port    : port Id
# Returned Result:
#
########################################################################

proc scriptGen::getBgp {chassis card port} \
{
    set retCode 0
    set nameIndex 2
    if {![bgp4Server select $chassis $card $port]} {
        sgPuts {bgp4Server select $chassis $card $port}
        sgPuts "bgp4Server clearAllNeighbors"
    
        if {![bgp4Server getFirstNeighbor]} {
            doBgpNeighbor neighbor1
            while {![bgp4Server getNextNeighbor]} {
                doBgpNeighbor [format "neighbor%i" $nameIndex]
				incr nameIndex
            }
        }
    
        if {![bgp4Server get]} {
            generateCommand bgp4Server
            sgPuts "bgp4Server set"
            sgPuts ""
        }
    }
    return $retCode
}



########################################################################
# Procedure: doBgpNeighbor
#
# This command gets bgp neighbor params.
# Arguments(s):
# name : NeighborName
# Returned Result:
#
########################################################################

proc scriptGen::doBgpNeighbor {name} \
{
    set retCode 0

    if {![bgp4Neighbor getFirstRouteRange]} {
        set nameIndex 2
        doBgpRouteRange routeRange1
      while {![bgp4Neighbor getNextRouteRange]} {
          doBgpRouteRange  [format "routeRange%i" $nameIndex]
		  incr nameIndex
      }
    }

	if [ixUtils isVpnL3Installed] {
		 if {![bgp4Neighbor getFirstMplsRouteRange]} {
			set nameIndex 2
			doBgpMplsRouteRange mplsRouteRange1
			while {![bgp4Neighbor getNextMplsRouteRange]} {
				doBgpMplsRouteRange  [format "mplsRouteRange%i" $nameIndex]
				incr nameIndex
			}
		}

		if {![bgp4Neighbor getFirstL3Site]} {
			set nameIndex 2
			doBgpVpnL3Site l3Site1
		  while {![bgp4Neighbor getNextL3Site]} {
			  doBgpVpnL3Site [format "l3Site%i" $nameIndex]
			  incr nameIndex
		  }
		}
	}

    if {![bgp4Neighbor getFirstPrefixFilter]} {
       doBgp4IncludePrefixFilter  
       while {![bgp4Neighbor getNextPrefixFilter]} {
           doBgp4IncludePrefixFilter  
	   }
    }       
	
	generateCommand	bgp4RouteFilter
    generateCommand bgp4Neighbor
    sgPuts "bgp4Server addNeighbor $name" 
    sgPuts ""
	sgPuts "bgp4Neighbor clearAllPrefixFilter"

    return $retCode
}

########################################################################
# Procedure: doBgp4IncludePrefixFilter
#
# This command gets bgp4IncludePrefixFilter Target parameters.
# Arguments(s):
# 
# Returned Result:
########################################################################

proc scriptGen::doBgp4IncludePrefixFilter {} \
{
    set retCode 0
       
    generateCommand bgp4IncludePrefixFilter
    
    sgPuts "bgp4Neighbor    addPrefixFilter"
    sgPuts ""

    return $retCode
}


########################################################################
# Procedure: doBgpRouteRange
#
# This command gets route ranges params for BGP
# Arguments(s):
# Name : RouteRange Name
# Returned Result:
########################################################################

proc scriptGen::doBgpRouteRange {name} \
{
  
    set retCode 0

    if {[bgp4RouteItem cget -enableASPath]} {
       if {![bgp4RouteItem getFirstASPathItem] } {
           doBgp4AsPath  bgp4RouteItem
           while {![bgp4RouteItem getNextASPathItem] } {
               doBgp4AsPath  bgp4RouteItem
           }
      }       
    }                                            
    
	if {![bgp4RouteItem getFirstExtendedCommunity] } {
       doBgp4Community  bgp4RouteItem
       while {![bgp4RouteItem getNextExtendedCommunity] } {
           doBgp4Community  bgp4RouteItem
       }
	}       

    generateCommand bgp4RouteItem
    sgPuts "bgp4Neighbor addRouteRange $name"     
    sgPuts ""
    sgPuts "bgp4RouteItem clearASPathList"

    return $retCode
}


########################################################################
# Procedure: doBgp4AsPath
#
# This command gets AsPath params for BGP
# Arguments(s):
# cmd: The command  for adding.
# Returned Result:
########################################################################

proc scriptGen::doBgp4AsPath { cmd  } \
{
    set retCode 0
       
    generateCommand bgp4AsPathItem
   
    sgPuts "$cmd    addASPathItem"


    sgPuts ""

    return $retCode
}


########################################################################
# Procedure: doBgpVpnL3Site
#
# This command gets l3 site params for BGP
# Arguments(s):
# Name : RouteRange Name
# Returned Result:
########################################################################

proc scriptGen::doBgpVpnL3Site {name} \
{
  
    set retCode 0

    if {![bgp4VpnL3Site getFirstVpnRouteRange]} {
        set nameIndex 2
        doBgpVpnRouteRange vpnRouteRange1
      while {![bgp4VpnL3Site getNextVpnRouteRange]} {
          doBgpVpnRouteRange  [format "vpnRouteRange%i" $nameIndex]
		  incr nameIndex
	  }
    }

    if {![bgp4VpnL3Site getFirstVpnTarget] } {
       doBgp4VpnTarget  
       while {![bgp4VpnL3Site getNextVpnTarget] } {
           doBgp4VpnTarget  
	   }
    }       
        
	if {![bgp4VpnL3Site getFirstImportTarget] } {
       doBgp4ImportTarget  
       while {![bgp4VpnL3Site getNextImportTarget] } {
           doBgp4ImportTarget  
	   }
    }

    generateCommand bgp4VpnL3Site
    sgPuts "bgp4Neighbor addL3Site $name"     
    sgPuts ""
    sgPuts "bgp4VpnL3Site clearAllVpnTargets"

    return $retCode
}

########################################################################
# Procedure: doBgp4VpnTarget
#
# This command gets bgp4Vpn Target parameters.
# Arguments(s):
# 
# Returned Result:
########################################################################

proc scriptGen::doBgp4VpnTarget {} \
{
    set retCode 0
       
    generateCommand bgp4VpnTarget
    
    sgPuts "bgp4VpnL3Site    addVpnTarget"
    sgPuts ""

    return $retCode
}

########################################################################
# Procedure: doBgp4ImportTarget
#
# This command gets bgp4Vpn Import Target parameters.
# Arguments(s):
# 
# Returned Result:
########################################################################

proc scriptGen::doBgp4ImportTarget {} \
{
    set retCode 0
       
    generateCommand bgp4VpnImportTarget
    
    sgPuts "bgp4VpnL3Site    addImportTarget"
    sgPuts ""

    return $retCode
}

########################################################################
# Procedure: doBgpVpnRouteRange
#
# This command gets VPN route ranges params for BGP
# Arguments(s):
# Name : RouteRange Name
# Returned Result:
########################################################################

proc scriptGen::doBgpVpnRouteRange {name} \
{
  
    set retCode 0

    if {[bgp4VpnRouteRange cget -enableASPath]} {
       if {![bgp4VpnRouteRange getFirstASPathItem] } {
           doBgp4AsPath  bgp4VpnRouteRange
           while {![bgp4VpnRouteRange getNextASPathItem] } {
               doBgp4AsPath bgp4VpnRouteRange 
		   }
      }       
    }                                          

	if {![bgp4VpnRouteRange getFirstExtendedCommunity] } {
       doBgp4Community  bgp4VpnRouteRange
       while {![bgp4VpnRouteRange getNextExtendedCommunity] } {
           doBgp4Community  bgp4VpnRouteRange
       }
	}     

    generateCommand bgp4VpnRouteRange
    sgPuts "bgp4VpnL3Site addVpnRouteRange $name"     
    sgPuts ""
    sgPuts "bgp4VpnRouteRange clearASPathList"

    return $retCode
}


########################################################################
# Procedure: doBgpMplsRouteRange
#
# This command gets MPLS route ranges params for BGP
# Arguments(s):
# Name : RouteRange Name
# Returned Result:
########################################################################

proc scriptGen::doBgpMplsRouteRange {name} \
{
  
    set retCode 0

    if {[bgp4MplsRouteRange cget -enableASPath]} {
       if {![bgp4MplsRouteRange getFirstASPathItem] } {
           doBgp4AsPath  bgp4MplsRouteRange
           while {![bgp4MplsRouteRange getNextASPathItem] } {
               doBgp4AsPath bgp4MplsRouteRange 
		   }
      }       
    }                                          

	if {![bgp4MplsRouteRange getFirstExtendedCommunity] } {
       doBgp4Community  bgp4MplsRouteRange
       while {![bgp4MplsRouteRange getNextExtendedCommunity] } {
           doBgp4Community  bgp4MplsRouteRange
       }
	}     

    generateCommand bgp4MplsRouteRange
    sgPuts "bgp4Neighbor addMplsRouteRange $name"     
    sgPuts ""
    sgPuts "bgp4MplsRouteRange clearASPathList"

    return $retCode
}

########################################################################
# Procedure: doBgp4Community
#
# This command gets bgp4 extended community parameters.
# Arguments(s):
# cmd : The command  for adding.
# Returned Result:
########################################################################

proc scriptGen::doBgp4Community {cmd} \
{
    set retCode 0
       
    generateCommand bgp4ExtendedCommunity
    
    sgPuts "$cmd    addExtendedCommunity"
    sgPuts ""

    return $retCode
}

########################################################################
# Procedure: getCommunityListEnum
#
# 
# Arguments(s):
#           communityList:
#
# Returned Result: List with Enum text
########################################################################
    
proc scriptGen::getCommunityListEnum {communityList} \
{
    variable enumsArray
	set enumText {}

    foreach value $communityList {
        set enumValList $enumsArray(bgp4RouteItem,communityList)
        set joinedList  [join $enumValList]
        set index       [lsearch $joinedList $value]
        set retString   [lindex $joinedList [expr $index-1]]
        if { $retString == ""} {
            set retString   $value
        } else {
            set retString [format "$%s" $retString]
        }
        lappend enumText $retString
    }	
 
	return [join $enumText]
  
} 
########################################################################
# 
#       ------------  OSPF procedures  ------------
#
########################################################################

########################################################################
# Procedure: getOspf
#
# This command generats Ospf server commands
# Arguments(s):
# chassis : chassis Id
# card    : card Id
# port    : port Id
# Returned Result:
#
########################################################################

proc scriptGen::getOspf {chassis card port} \
{
    set retCode 0
    set nameIndex 2
    if {![ospfServer select $chassis $card $port]} {
        sgPuts {ospfServer select $chassis $card $port}
        sgPuts "ospfServer clearAllRouters"
        
        if {![ospfServer getFirstRouter]} {
            doOspfRouter router1
            while {![ospfServer getNextRouter]} {
                doOspfRouter [format "router%i" $nameIndex]
                incr nameIndex
            }
        }
    }
    return $retCode
}


########################################################################
# Procedure: doOspfRouter
#
# This command gets OSPF router
# Arguments(s):
# name : RouterName
# Returned Result:
########################################################################

proc scriptGen::doOspfRouter {name} \
{
    set retCode 0
    
    if {![ospfRouter getFirstInterface]} {
        set nameIndex 2
        doOspfInterface interface1
        while {![ospfRouter  getNextInterface]} {
            doOspfInterface [format "interface%i" $nameIndex]
            incr nameIndex
        }
    }               
    if {![ospfRouter getFirstRouteRange]} {
        set nameIndex 2
        doOspfRouteRange routeRange1
        while {![ospfRouter  getNextRouteRange]} {
            doOspfRouteRange [format "routeRange%i" $nameIndex]
            incr nameIndex
        }
    }            
    if {![ospfRouter getFirstUserLsaGroup]} {
        set nameIndex 2
        doOspfUserLsaGroup userLsaGroup1
        while {![ospfRouter  getNextUserLsaGroup]} {
            doOspfUserLsaGroup [format "userLsaGroup%i" $nameIndex]
            incr nameIndex
        }
    }   
    
    generateCommand ospfRouter
    sgPuts "ospfServer addRouter $name"
    sgPuts ""
    return $retCode
}  

########################################################################
# Procedure: doOspfInterface
#
# This command gets OSPF Interface
# Arguments(s):
# name : RouterName
# Returned Result:
########################################################################      

proc scriptGen::doOspfInterface {name} \
{
    set retCode 0

    set includeSetDefault  yes

    if {![ospfInterface cget -connectToDut]} {
        generateCommand ospfNetworkRange
		sgPuts ""
		sgPuts "ospfInterface setDefault"
		sgPuts "ospfInterface config -ipAddress {[ospfInterface cget -ipAddress]}"
		sgPuts "ospfInterface config -ipMask	{[ospfInterface cget -ipMask]}"
		set includeSetDefault  no

	}
    generateCommand ospfInterface $includeSetDefault
    sgPuts "ospfRouter addInterface $name"
    return $retCode
}  


########################################################################
# Procedure: doOspfRouteRange
#
# This command gets OSPF route range
# Arguments(s):
# name : RouterName
# Returned Result:
########################################################################      

proc scriptGen::doOspfRouteRange {name} \
{
    set retCode 0
    generateCommand ospfRouteRange
    sgPuts "ospfRouter addRouteRange $name"
    return $retCode
}  


########################################################################
# Procedure: doOspfUserLsaGroup
#
# This command gets OSPF userLsa group
# Arguments(s):
# name : RouterName
# Returned Result:
########################################################################      

proc scriptGen::doOspfUserLsaGroup {name} \
{
    set retCode 0
    set nameIndex 2

    if {![ospfUserLsaGroup getFirstUserLsa]} {
        doOspfUserLsa userLsa1
        while {![ospfUserLsaGroup getNextUserLsa]} {
            doOspfUserLsa [format "userLsa%i" $nameIndex]
            incr nameIndex
        }
    }
            
    generateCommand ospfUserLsaGroup
    sgPuts "ospfRouter addUserLsaGroup $name"
    return $retCode
}


########################################################################
# Procedure: doOspfUserLsa
#
# This command gets OSPF userLsa 
# Arguments(s):
# name : RouterName
# Returned Result:
########################################################################      

proc scriptGen::doOspfUserLsa {name} \
{  
    set retCode 0
    
    set lsaType [ospfUserLsa cget -lsaType]

    if {$lsaType == $::ospfLsaRouter } {
        if {![ospfUserLsa getFirstRouterLsaInterface]} {
            doRouterLsaInterface 
            while {![ospfUserLsa getNextRouterLsaInterface]} {
                doRouterLsaInterface
            }
        }
        set lsaParamList [list advertisingRouterId enable options linkStateId routerCapabilityBits]

    } elseif {$lsaType == $::ospfLsaNetwork } {
        set lsaParamList [list advertisingRouterId enable options linkStateId neighborId networkMask]

    } elseif {$lsaType == $::ospfLsaSummaryIp } {
        set lsaParamList [list advertisingRouterId enable options linkStateId incrementLinkStateIdBy \
                          metric networkMask numberOfLSAs]

    } elseif {$lsaType == $::ospfLsaSummaryAs} {
        set lsaParamList [list advertisingRouterId enable options linkStateId]

    } elseif {$lsaType == $::ospfLsaExternal } {
        set lsaParamList [list advertisingRouterId enable options linkStateId incrementLinkStateIdBy \
                              metric networkMask numberOfLSAs forwardingAddress externalRouteTag \
                              externalMetricEBit]

    } elseif {$lsaType == $::ospfLsaOpaqueLocal || \
              $lsaType == $::ospfLsaOpaqueArea || \
              $lsaType == $::ospfLsaOpaqueDomain } {

        set tlvType [ospfUserLsa cget -tlvType]
        if {$tlvType == $::ospfRouterTlv} {

            set lsaParamList [list advertisingRouterId enable options linkStateId \
                                   tlvType tlvRouterIpAddress]
        } else {
  
            set lsaParamList [list advertisingRouterId enable options linkStateId \
                               tlvType tlvLinkType enableTlvLinkType \
                               tlvLinkId enableTlvLinkId tlvLinkMetric enableTlvLinkMetric \
                               tlvResourceClass enableTlvResourceClass tlvLocalIpAddress \
                               enableTlvLocalIpAddress tlvRemoteIpAddress  enableTlvRemoteIpAddress \
                               tlvMaxBandwidth enableTlvMaxBandwidth tlvMaxReservableBandwidth \
                               enableTlvMaxReservableBandwidth enableTlvUnreservedBandwidth \
                               tlvUnreservedBandwidthPriority0 tlvUnreservedBandwidthPriority1 \
                               tlvUnreservedBandwidthPriority2 tlvUnreservedBandwidthPriority3 \
                               tlvUnreservedBandwidthPriority4 tlvUnreservedBandwidthPriority5 \
                               tlvUnreservedBandwidthPriority6 tlvUnreservedBandwidthPriority7] 
        }
    
    } else {
        set lsaParamList {}
    }
        
    partiallyGenerateCommand ospfUserLsa $lsaParamList
    sgPuts "ospfUserLsaGroup addUserLsa $name [getEnumString ospfUserLsa -lsaType] " 
    sgPuts "ospfUserLsa  clearAllRouterLsaInterface" 
    

    return $retCode
}

########################################################################
# Procedure: doRouterLsaInterface
#
# This command gets OSPF Router Lsa Interface
# Arguments(s):
# Returned Result:
########################################################################      

proc scriptGen::doRouterLsaInterface {} \
{  
    set retCode 0
    generateCommand ospfRouterLsaInterface
    sgPuts "ospfUserLsa addInterfaceDescriptionToRouterLsa"

    return $retCode
}

########################################################################
# 
#       ------------  ISIS procedures  ------------
#
########################################################################

########################################################################
# Procedure: getisis
#
# This command generats isis server commands
# Arguments(s):
# chassis : chassis Id
# card    : card Id
# port    : port Id
# Returned Result:
#
########################################################################

proc scriptGen::getIsis {chassis card port} \
{
    set retCode 0
    set nameIndex 2
    if {![isisServer select $chassis $card $port]} {
        sgPuts {isisServer select $chassis $card $port}
        sgPuts "isisServer clearAllRouters"
        
        if {![isisServer getFirstRouter]} {
            doIsisRouter router1
            while {![isisServer getNextRouter]} {
                doIsisRouter [format "router%i" $nameIndex]
                incr nameIndex
            }
        }
    }
    return $retCode
}


########################################################################
# Procedure: doIsisRouter
#
# This command gets isis router
# Arguments(s):
# name : RouterName
# Returned Result:
########################################################################

proc scriptGen::doIsisRouter {name} \
{
    set retCode 0
    
    if {![isisRouter getFirstInterface]} {
        set nameIndex 2
        doIsisInterface interface1
        while {![isisRouter  getNextInterface]} {
            doIsisInterface [format "interface%i" $nameIndex]
            incr nameIndex
        }
    }               
    if {![isisRouter getFirstRouteRange]} {
        set nameIndex 2
        doIsisRouteRange routeRange1
        while {![isisRouter  getNextRouteRange]} {
            doIsisRouteRange [format "routeRange%i" $nameIndex]
            incr nameIndex
        }
    }            
 
	if {![isisRouter getFirstGrid]} {
        set nameIndex 2
        doIsisGrid grid1
        while {![isisRouter  getNextGrid]} {
            doIsisGrid [format "grid%i" $nameIndex]
            incr nameIndex
        }
    }            

    generateCommand isisRouter
    sgPuts "isisServer addRouter $name"
    sgPuts ""
    return $retCode
}  

########################################################################
# Procedure: doIsisInterface
#
# This command gets isis Interface
# Arguments(s):
# name : RouterName
# Returned Result:
########################################################################      

proc scriptGen::doIsisInterface {name} \
{
    set retCode 0

    sgPuts "isisInterface setDefault"
	if {![isisInterface cget -connectToDut]} {
		sgPuts "isisInterface config -ipAddress {[isisInterface cget -ipAddress]}"
		sgPuts "isisInterface config -ipMask	{[isisInterface cget -ipMask]}"
	}

    generateCommand isisInterface noSetDefault
    sgPuts "isisRouter addInterface $name"
	sgPuts ""
    return $retCode
}  


########################################################################
# Procedure: doIsisRouteRange
#
# This command gets isis route range
# Arguments(s):
# name : RouterName
# Returned Result:
########################################################################      

proc scriptGen::doIsisRouteRange {name} \
{
    set retCode 0
    generateCommand isisRouteRange
    sgPuts "isisRouter addRouteRange $name"
	sgPuts ""
    return $retCode
}  

########################################################################
# Procedure: doIsisGrid
#
# This command gets isis grid
# Arguments(s):
# name : RouterName
# Returned Result:
########################################################################

proc scriptGen::doIsisGrid {name} \
{
    set retCode 0
    
    if {![isisGrid getFirstInternodeRoute]} {
        doIsisInternodeRoute 
        while {![isisGrid  getNextInternodeRoute]} {
            doIsisInternodeRoute 
        }
    } 
	              
    if {![isisGrid getFirstRoute]} {
        doIsisGridRoute 
        while {![isisGrid  getNextRoute]} {
            doIsisGridRoute 
        }
    }   
	
	sgPuts ""

	if {![isisGrid getFirstOutsideLink]} {
        doIsisGridOutsideLink 
        while {![isisGrid  getNextOutsideLink]} {
            doIsisGridOutsideLink 
        }
    }   

	sgPuts ""
	if {[isisGrid cget -enableTe]} {

		if {![isisGrid getFirstTePath]} {
			doIsisGridTePath
			while {![isisGrid  getNextTePath]} {
				doIsisGridTePath 
			}
		} 
		sgPuts "" 
		generateCommand isisGridRangeTe
		
		sgPuts ""
		if {[isisGrid cget -overrideEntryTe]} {
			generateCommand isisGridEntryTe
			sgPuts ""
		}
	}

	
    generateCommand isisGrid
    sgPuts "isisRouter addGrid $name"
    sgPuts ""
    return $retCode
}  



########################################################################
# Procedure: doIsisInternodeRoute
#
# This command gets isis Grid internode
# Arguments(s):
# Returned Result:
########################################################################      

proc scriptGen::doIsisInternodeRoute {} \
{
    set retCode 0
    generateCommand isisGridInternodeRoute
    sgPuts "isisGrid addInternodeRoute"
	sgPuts ""
    return $retCode
}  


########################################################################
# Procedure: doIsisGridRoute
#
# This command gets isis Grid route 
# Arguments(s):
# Returned Result:
########################################################################      

proc scriptGen::doIsisGridRoute {} \
{
    set retCode 0
    generateCommand isisGridRoute
    sgPuts "isisGrid addRoute"
	sgPuts ""
    return $retCode
}  


########################################################################
# Procedure: doIsisGridTePath
#
# This command gets isis Grid TE Path
# Arguments(s):
# Returned Result:
########################################################################      

proc scriptGen::doIsisGridTePath {} \
{
    set retCode 0
    generateCommand isisGridTePath
    sgPuts "isisGrid addTePath"
    return $retCode
}  


########################################################################
# Procedure: doIsisGridOutsideLink
#
# This command gets isis grid outsideLink
# Arguments(s):
# Returned Result:
########################################################################      

proc scriptGen::doIsisGridOutsideLink {} \
{
    set retCode 0

	if {![isisGridOutsideLink getFirstRoute]} {

        generateCommand isisGridInternodeRoute
		sgPuts "isisGridOutsideLink addRoute"

        while {![isisGridOutsideLink  getNextRoute]} {
            generateCommand isisGridInternodeRoute
			sgPuts "isisGridOutsideLink addRoute"
        }
    }   

    generateCommand isisGridOutsideLink
    sgPuts "isisGrid addOutsideLink"
	sgPuts ""
    return $retCode
}  

########################################################################
# 
#       ------------  RIP procedures  ------------
#
########################################################################


########################################################################
# Procedure: scriptGen::getRip
#
# This command generats rip server commands
#
# Arguments(s):
#   chassis :       chassis Id
#   card    :       card Id
#   port    :       port Id
#
#   Results :        Always returns 0
#       
########################################################################
proc scriptGen::getRip {chassis card port} \
{
    set retCode 0
    set nameIndex 2

    if {![ripServer select $chassis $card $port]} {
        sgPuts {ripServer select $chassis $card $port}
        sgPuts "ripServer clearAllRouters"
        
        if {![ripServer getFirstRouter]} {
            doRipRouter router1
            while {![ripServer getNextRouter]} {
                doRipRouter [format "router%i" $nameIndex]
                incr nameIndex
            }
        } 
    } 

    return $retCode
}

########################################################################
# Procedure: doRipRouter
#
# This command gets rip router
#
# Arguments(s):
#
#   name :          Rip router name
#
#   Results :        Always returns 0
#       
########################################################################
proc scriptGen::doRipRouter {name} \
{
    set retCode 0
            
    if {![ripInterfaceRouter getFirstRouteRange]} {
        set nameIndex 2
        doRipRouteRange routeRange1
        while {![ripInterfaceRouter  getNextRouteRange]} {
            doRipRouteRange [format "routeRange%i" $nameIndex]
            incr nameIndex
        }
    } 

    generateCommand ripInterfaceRouter
    sgPuts "ripServer addRouter $name"
    sgPuts ""
    
    return $retCode
}  

########################################################################
# Procedure: doRipRouter
#
# This command gets rip router range
#
# Arguments(s):
#
#   name :          Rip router range name
#
#   Results :      Always returns 0
#       
########################################################################
proc scriptGen::doRipRouteRange {name} \
{
    set retCode 0

    generateCommand ripRouteRange
    sgPuts "ripInterfaceRouter addRouteRange $name"

    return $retCode
}


########################################################################
# 
#       ------------  RIPng procedures  ------------
#
########################################################################

########################################################################
# Procedure: getripng
#
# This command generats ripng server commands
# Arguments(s):
# chassis : chassis Id
# card    : card Id
# port    : port Id
# Returned Result:
#
########################################################################
proc scriptGen::getRipng {chassis card port} \
{
    set retCode 0
    set nameIndex 2
    if {![ripngServer select $chassis $card $port]} {
        sgPuts {ripngServer select $chassis $card $port}
        sgPuts "ripngServer clearAllRouters"
        
        if {![ripngServer getFirstRouter]} {
            doRipngRouter router1
            while {![ripngServer getNextRouter]} {
                doRipngRouter [format "router%i" $nameIndex]
                incr nameIndex
            }
        }
        if {![ripngServer get]} {
            generateCommand ripngServer
            sgPuts "ripngServer set"
            sgPuts ""
        }    
    }

    return $retCode
}


########################################################################
# Procedure: doRipngRouter
#
# This command gets ripng router
# Arguments(s):
# name : RouterName
# Returned Result:
########################################################################
proc scriptGen::doRipngRouter {name} \
{
    set retCode 0
    
    if {![ripngRouter getFirstInterface]} {
        set nameIndex 2
        doRipngInterface interface1
        while {![ripngRouter  getNextInterface]} {
            doRipngInterface [format "interface%i" $nameIndex]
            incr nameIndex
        }
    }               
    if {![ripngRouter getFirstRouteRange]} {
        set nameIndex 2
        doRipngRouteRange routeRange1
        while {![ripngRouter  getNextRouteRange]} {
            doRipngRouteRange [format "routeRange%i" $nameIndex]
            incr nameIndex
        }
    }            
 
    generateCommand ripngRouter
    sgPuts "ripngServer addRouter $name"
    sgPuts ""
    return $retCode
}  

########################################################################
# Procedure: doRipngInterface
#
# This command gets ripng Interface
# Arguments(s):
# name : RouterName
# Returned Result:
########################################################################      
proc scriptGen::doRipngInterface {name} \
{
    set retCode 0
    generateCommand ripngInterface
    sgPuts "ripngRouter addInterface $name"
    return $retCode
}  


########################################################################
# Procedure: doRipngRouteRange
#
# This command gets ripng route range
# Arguments(s):
# name : RouterName
# Returned Result:
########################################################################      
proc scriptGen::doRipngRouteRange {name} \
{
    set retCode 0
    generateCommand ripngRouteRange
    sgPuts "ripngRouter addRouteRange $name"
    return $retCode
}  


########################################################################
# 
#       ------------  RSVP procedures  ------------
#
########################################################################

########################################################################
# Procedure: getRsvp
#
# This command generats rsvp server commands
#
# Arguments(s):
#   chassis :       chassis Id
#   card    :       card Id
#   port    :       port Id
#
#   Results :        Always returns 0
#       
########################################################################
proc scriptGen::getRsvp {chassis card port} \
{
    set retCode 0
    set nameIndex 2

    if {![rsvpServer select $chassis $card $port]} {
		sgPuts ""
        sgPuts {rsvpServer select $chassis $card $port}
        sgPuts "rsvpServer clearAllNeighborPair"
        
        if {![rsvpServer getFirstNeighborPair]} {
            doRsvpNeighborPair neighborPair1
            while {![rsvpServer getNextNeighborPair]} {
                doRsvpNeighborPair [format "neighborPair%i" $nameIndex]
                incr nameIndex
            }
        }
    } 

    return $retCode
}

########################################################################
# Procedure: doRsvpNeighborPair
#
# This command gets rip router
#
# Arguments(s):
#
#   name :          Rsvp neighbor pair name
#
#   Results :        Always returns 0
#       
########################################################################
proc scriptGen::doRsvpNeighborPair {name} \
{
    set retCode 0
           
    if {![rsvpNeighborPair getFirstDestinationRange]} {
        set nameIndex 2
        doRsvpDestinationRange destinationRange1
        while {![rsvpNeighborPair   getNextDestinationRange]} {
            doRsvpDestinationRange [format "destinationRange%i" $nameIndex]
            incr nameIndex
        }
    }         

	if {![rsvpNeighborPair getFirstHelloTlv]} {
        generateCommand rsvpCustomTlv
		sgPuts "rsvpNeighborPair addHelloTlv"
		sgPuts ""
        while {![rsvpNeighborPair   getNextHelloTlv]} {
			generateCommand rsvpCustomTlv
			sgPuts "rsvpNeighborPair addHelloTlv"
			sgPuts ""
        }
    }

    generateCommand rsvpNeighborPair
    sgPuts "rsvpServer addNeighborPair $name"
    sgPuts ""


    return $retCode
} 

########################################################################
# Procedure: doRsvpDestinationRange
#
# This command gets Rsvp Destination Range
#
# Arguments(s):
#
#   name :          Rsvp Destination Range name
#
#   Results :        Always returns 0
#       
########################################################################
proc scriptGen::doRsvpDestinationRange {name} \
{
    set retCode 0

    if {![rsvpDestinationRange getFirstSenderRange]} {
        set nameIndex 2
        doRsvpSenderRange senderRange1
        while {![rsvpDestinationRange  getNextSenderRange]} {
            doRsvpSenderRange [format "senderRange%i" $nameIndex]
            incr nameIndex
        }
    } 
       
    if {![rsvpDestinationRange getFirstEroItem]} {
        doRsvpEroItem 
        while {![rsvpDestinationRange  getNextEroItem]} {
            doRsvpEroItem 
        }
    }

    if {![rsvpDestinationRange getFirstRroItem]} {
        doRsvpRroItem 
        while {![rsvpDestinationRange  getNextRroItem]} {
            doRsvpRroItem 
        }
    }     
    
	if {[rsvpDestinationRange cget -behavior] == $::rsvpEgress } {
		if {![rsvpDestinationRange getFirstResvTlv]} {
			generateCommand rsvpCustomTlv
			sgPuts "rsvpDestinationRange addResvTlv"
			sgPuts ""
			while {![rsvpDestinationRange   getNextResvTlv]} {
				generateCommand rsvpCustomTlv
				sgPuts "rsvpDestinationRange addResvTlv"
				sgPuts ""
			}
		}

		if {![rsvpDestinationRange getFirstResvTearTlv]} {
			generateCommand rsvpCustomTlv
			sgPuts "rsvpDestinationRange addResvTearTlv"
			sgPuts ""
			while {![rsvpDestinationRange   getNextResvTearTlv]} {
				generateCommand rsvpCustomTlv
				sgPuts "rsvpDestinationRange addResvTearTlv"
				sgPuts ""
			}
		}


		if {![rsvpDestinationRange getFirstPathTlv]} {
			generateCommand rsvpCustomTlv
			sgPuts "rsvpDestinationRange addPathTlv"
			sgPuts ""
			while {![rsvpDestinationRange   getNextPathTlv]} {
				generateCommand rsvpCustomTlv
				sgPuts "rsvpDestinationRange addPathTlv"
				sgPuts ""
			}
		}

	} else {

		if {![rsvpDestinationRange getFirstResvErrTlv]} {
			generateCommand rsvpCustomTlv
			sgPuts "rsvpDestinationRange addResvErrTlv"
			sgPuts ""
			while {![rsvpDestinationRange   getNextResvErrTlv]} {
				generateCommand rsvpCustomTlv
				sgPuts "rsvpDestinationRange addResvErrTlv"
				sgPuts ""
			}
		}
	}


 
    generateCommand rsvpDestinationRange
    sgPuts "rsvpNeighborPair addDestinationRange $name"
    sgPuts "rsvpDestinationRange clearAllEro"
    sgPuts "rsvpDestinationRange clearAllRro"
    sgPuts ""


    return $retCode
}

########################################################################
# Procedure: doRsvpSenderRange
#
# This command gets rsvp router range
#
# Arguments(s):
#
#   name :          Rsvp sender range name
#
#   Results :      Always returns 0
#       
########################################################################
proc scriptGen::doRsvpSenderRange {name} \
{
    set retCode 0

	if {![rsvpSenderRange getFirstPlr]} {
        doRsvpPlr 
        while {![rsvpSenderRange  getNextPlr]} {
            doRsvpPlr 
        }
    }

	if {![rsvpSenderRange getFirstTearTlv]} {
			generateCommand rsvpCustomTlv
			sgPuts "rsvpSenderRange addTearTlv"
			sgPuts ""
			while {![rsvpSenderRange   getNextTearTlv]} {
				generateCommand rsvpCustomTlv
				sgPuts "rsvpSenderRange addTearTlv"
				sgPuts ""
			}
		}


	if {![rsvpSenderRange getFirstPathTlv]} {
		generateCommand rsvpCustomTlv
		sgPuts "rsvpSenderRange addPathTlv"
		sgPuts ""
		while {![rsvpSenderRange   getNextPathTlv]} {
			generateCommand rsvpCustomTlv
			sgPuts "rsvpSenderRange addPathTlv"
			sgPuts ""
		}
	}


    generateCommand rsvpSenderRange
    sgPuts "rsvpDestinationRange addSenderRange $name"
	sgPuts "rsvpSenderRange clearPlrList"
	sgPuts ""

    return $retCode
}

########################################################################
# Procedure: doRsvpEroItem
#
# This command gets Rsvp Ero item
#
# Arguments(s):
#
#   Results :      Always returns 0
#       
########################################################################
proc scriptGen::doRsvpEroItem {} \
{
    set retCode 0

    generateCommand rsvpEroItem
    sgPuts "rsvpDestinationRange addEroItem"
	sgPuts ""

    return $retCode
}

########################################################################
# Procedure: doRsvpRroItem
#
# This command gets Rsvp Rro Item
#
# Arguments(s):
#
#
#   Results :      Always returns 0
#       
########################################################################
proc scriptGen::doRsvpRroItem {} \
{
    set retCode 0

    generateCommand rsvpRroItem
    sgPuts "rsvpDestinationRange addRroItem"
	sgPuts ""

    return $retCode
}  


########################################################################
# Procedure: doRsvpPlr
#
# This command gets Rsvp plr list
#
# Arguments(s):
#
#   Results :      Always returns 0
#       
########################################################################
proc scriptGen::doRsvpPlr {} \
{
    set retCode 0

    generateCommand rsvpPlrNodeIdPair
    sgPuts "rsvpSenderRange addPlr"
	sgPuts ""

    return $retCode
}

########################################################################
# 
#       ------------  LDP procedures  ------------
#
########################################################################

########################################################################
# Procedure: getLdp
#
# This command generats ldp server commands
#
# Arguments(s):
#   chassis :       chassis Id
#   card    :       card Id
#   port    :       port Id
#
#   Results :        Always returns 0
#       
########################################################################
proc scriptGen::getLdp {chassis card port} \
{
    set retCode 0
    set nameIndex 2

    if {![ldpServer select $chassis $card $port]} {
        sgPuts {ldpServer select $chassis $card $port}
        sgPuts "ldpServer clearAllRouters"
        
        if {![ldpServer getFirstRouter]} {
            doLdpRouter router1
            while {![ldpServer getNextRouter]} {
                doLdpRouter [format "router%i" $nameIndex]
                incr nameIndex
            }
        }
    } 

	if {![ldpServer get]} {
        generateCommand ldpServer
        sgPuts "ldpServer set"
        sgPuts ""
    }    

    return $retCode
}




########################################################################
# Procedure: doLdpRouter
#
# This command gets LDP router
# Arguments(s):
# name : RouterName
# Returned Result:
########################################################################

proc scriptGen::doLdpRouter {name} \
{
    set retCode 0
    
    if {![ldpRouter getFirstInterface]} {
        set nameIndex 2
        doLdpInterface interface1
        while {![ldpRouter  getNextInterface]} {
            doLdpInterface [format "interface%i" $nameIndex]
            incr nameIndex
        }
    }
    sgPuts ""              
    if {![ldpRouter getFirstAdvertiseFecRange]} {
        set nameIndex 2
        doLdpAdvertiseFecRange advertiseFecRange1
        while {![ldpRouter  getNextAdvertiseFecRange]} {
            doLdpAdvertiseFecRange [format "advertiseFecRange%i" $nameIndex]
            incr nameIndex
        }
    } 
	sgPuts ""
	if {![ldpRouter getFirstExplicitIncludeIpFec]} {
       set nameIndex 2
       doLdpExplicitIncludeIpFec explicitIncludeIpFec1
       while {![ldpRouter  getNextExplicitIncludeIpFec]} {
           doLdpExplicitIncludeIpFec [format "explicitIncludeIpFec%i" $nameIndex]
           incr nameIndex
       }
    }            
	sgPuts ""          
    if {![ldpRouter getFirstRequestFecRange]} {
        set nameIndex 2
        doLdpRequestFecRange requestFecRange1
        while {![ldpRouter  getNextRequestFecRange]} {
            doLdpRequestFecRange [format "requestFecRange%i" $nameIndex]
            incr nameIndex
        }
    }            
   sgPuts ""
   if [ixUtils isVpnL2Installed] {
     
	   if {![ldpRouter getFirstL2VpnInterface]} {
			set nameIndex 2
			doLdpL2VpnInterface l2VpnInterface1
			while {![ldpRouter  getNextL2VpnInterface]} {
				doLdpL2VpnInterface [format "l2VpnInterface%i" $nameIndex]
				incr nameIndex
			}
		}
	}                
    generateCommand ldpRouter
    sgPuts "ldpServer addRouter $name"
    sgPuts ""
    return $retCode
}  




########################################################################
# Procedure: doLdpInterface
#
# This command gets LDP Interface
# Arguments(s):
# name : Interface Name
# Returned Result:
########################################################################      

proc scriptGen::doLdpInterface {name} \
{
    set retCode 0
    
    if {![ldpInterface getFirstTargetedPeer]} {
        set nameIndex 2
        doLdpTargetedPeer  targetedPeer1
        while {![ldpInterface getNextTargetedPeer]} {
            doLdpTargetedPeer [format "targetedPeer%i" $nameIndex]
            incr nameIndex
        }
    }

	if {[ldpInterface cget -enableAtmSession] == 1} {
        if {![ldpInterface getFirstAtmLabelRange]} {
            set nameIndex 2
            doLdpAtmLabelRanger  atmLabelRange1
            while {![ldpInterface getNextAtmLabelRange]} {
                doLdpAtmLabelRanger [format "atmLabelRange%i" $nameIndex]
                incr nameIndex
            }
        }
    }

    generateCommand ldpInterface
    sgPuts "ldpRouter addInterface $name"
	sgPuts ""
    return $retCode
}  


########################################################################
# Procedure: doLdpTargetedPeer
#
# This command gets LDP targeted peer
# Arguments(s):
# name : TargetedPeer Name
# Returned Result:
########################################################################      

proc scriptGen::doLdpTargetedPeer {name} \
{
    set retCode 0
       
    generateCommand ldpTargetedPeer
    sgPuts "ldpInterface addTargetedPeer $name"
	sgPuts ""
    return $retCode
}  

########################################################################
# Procedure: doLdpAtmLabelRanger
#
# This command gets LDP ATM label Range
# Arguments(s):
# name : ATM Label range Name
# Returned Result:
########################################################################      

proc scriptGen::doLdpAtmLabelRanger {name} \
{
    set retCode 0
       
    generateCommand ldpAtmLabelRange
    sgPuts "ldpInterface addAtmLabelRange $name"
	sgPuts ""
    return $retCode
}

########################################################################
# Procedure: doLdpAdvertiseFecRange
#
# This command gets LDP advertise FEC Range
# Arguments(s):
# name : AdvertiseFecRange Name
# Returned Result:
########################################################################      

proc scriptGen::doLdpAdvertiseFecRange {name} \
{
    set retCode 0
       
    generateCommand ldpAdvertiseFecRange
    sgPuts "ldpRouter addAdvertiseFecRange $name"
	sgPuts ""
    return $retCode
}  


########################################################################
# Procedure: doLdpExplicitIncludeIpFec
#
# This command gets LDP Explicit Include FEC range
# Arguments(s):
# name : AdvertiseFecRange Name
# Returned Result:
########################################################################      

proc scriptGen::doLdpExplicitIncludeIpFec {name} \
{
    set retCode 0
       
    generateCommand ldpExplicitIncludeIpFec
    sgPuts "ldpRouter addExplicitIncludeIpFec $name"
    return $retCode
}  




########################################################################
# Procedure: doLdpRequestFecRange
#
# This command gets LDP request FEC Range
# Arguments(s):
# name : RequestFecRange Name
# Returned Result:
########################################################################      

proc scriptGen::doLdpRequestFecRange {name} \
{
    set retCode 0
      
    generateCommand ldpRequestFecRange
    sgPuts "ldpRouter addRequestFecRange $name"
    return $retCode
}  


########################################################################
# Procedure: doLdpL2VpnInterface
#
# This command gets LDP L2 VPN Interface
# Arguments(s):
# name : ldpL2VpnInterface Name
# Returned Result:
########################################################################      

proc scriptGen::doLdpL2VpnInterface {name} \
{
    set retCode 0
    
    if {![ldpL2VpnInterface getFirstL2VpnVcRange]} {
        set nameIndex 2
        doLdpL2VpnVcRange  l2VpnVcRange1
        while {![ldpL2VpnInterface getNextL2VpnVcRange]} {
            doLdpL2VpnVcRange [format "l2VpnVcRange%i" $nameIndex]
            incr nameIndex
        }
    }

    generateCommand ldpL2VpnInterface
    sgPuts "ldpRouter addL2VpnInterface $name"
    return $retCode
}  


########################################################################
# Procedure: doLdpL2VpnVcRange
#
# This command gets LDP L2 VPN VC Range
# Arguments(s):
# name : ldpL2VpnVcRange Name
# Returned Result:
########################################################################      

proc scriptGen::doLdpL2VpnVcRange {name} \
{
    set retCode 0
    
	if {![ldpL2VpnVcRange getFirstVplsMacRange]} {
        set nameIndex 2
        doLdpL2VplsMacRange  l2VplsMacRange1
        while {![ldpL2VpnVcRange getNextVplsMacRange]} {
            doLdpL2VplsMacRange [format "l2VplsMacRange%i" $nameIndex]
            incr nameIndex
        }
    }
	  
    generateCommand ldpL2VpnVcRange
    sgPuts "ldpL2VpnInterface addL2VpnVcRange $name"
    return $retCode
}  


########################################################################
# Procedure: doLdpL2VplsMacRange
#
# This command gets LDP L2 VPLS Mac Ranges
# Arguments(s):
# name : ldpL2VpnVcRange Name
# Returned Result:
########################################################################      

proc scriptGen::doLdpL2VplsMacRange {name} \
{
    set retCode 0
	  
    generateCommand ldpL2VplsMacRange
    sgPuts "ldpL2VpnVcRange addVplsMacRange $name"
    return $retCode
}  


########################################################################
# 
#       ------------  MLD procedures  ------------
#
########################################################################

########################################################################
# Procedure: getMld
#
# This command generats Mld server commands
#
# Arguments(s):
#   chassis :       chassis Id
#   card    :       card Id
#   port    :       port Id
#
#   Results :        Always returns 0
#       
########################################################################
proc scriptGen::getMld {chassis card port} \
{
    set retCode 0
    set nameIndex 2

    if {![mldServer select $chassis $card $port]} {
        sgPuts {mldServer select $chassis $card $port}
        sgPuts "mldServer clearAllHosts"
        
        if {![mldServer getFirstHost]} {
            doMldHost host1
            while {![mldServer getNextHost]} {
                doMldHost [format "host%i" $nameIndex]
                incr nameIndex
            }
        }
    } 

    if {![mldServer get]} {
        generateCommand mldServer
        sgPuts "mldServer set"
        sgPuts ""
    }    

    return $retCode
}

########################################################################
# Procedure: doMldHost
#
# This command gets Mld host
#
# Arguments(s):
#
#   name :          MLD host name
#
#   Results :        Always returns 0
#       
########################################################################
proc scriptGen::doMldHost {name} \
{
    set retCode 0
            
    if {![mldHost getFirstGroupRange]} {
        set nameIndex 2
        doMldGroupRange groupRange1
        while {![mldHost   getNextGroupRange]} {
            doMldGroupRange [format "groupRange%i" $nameIndex]
            incr nameIndex
        }
    }         

    generateCommand mldHost
    sgPuts "mldServer addHost $name"
    sgPuts ""


    return $retCode
} 

########################################################################
# Procedure: doMldGroupRange
#
# This command gets MLD Group range.
#
# Arguments(s):
#
#   name :          MLD Group range name
#
#   Results :        Always returns 0
#       
########################################################################
proc scriptGen::doMldGroupRange {name} \
{
    set retCode 0

    if {![mldGroupRange getFirstSourceRange]} {
        set nameIndex 2
        doMldSourceRange sourceRange1
        while {![mldGroupRange  getNextSourceRange]} {
            doMldSourceRange [format "sourceRange%i" $nameIndex]
            incr nameIndex
        }
    } 
        
    generateCommand mldGroupRange
    sgPuts "mldHost addGroupRange $name"
    sgPuts ""


    return $retCode
}

########################################################################
# Procedure: doMldSourceRange
#
# This command gets MLD source range
#
# Arguments(s):
#
#   name :         MLD source range name
#
#   Results :      Always returns 0
#       
########################################################################
proc scriptGen::doMldSourceRange {name} \
{
    set retCode 0

    generateCommand mldSourceRange
    sgPuts "mldGroupRange addSourceRange $name"
	sgPuts ""
    return $retCode
}

########################################################################
# 
#       ------------  IGMP procedures  ------------
#
########################################################################


########################################################################
# Procedure: getIgmpProtocol
#
# This command gets igmp protocol parameters.
# Arguments(s):
# chassis : chassis Id
# card    : card Id
# port    : port Id
# Returned Result:
########################################################################

proc scriptGen::getIgmpProtocol { chassis card port} \
{
    set retCode 0

    getCommand igmpServer $chassis $card $port
    sgPuts {igmpServer set $chassis $card $port}

    sgPuts "igmpAddressTable clear"

    if {![igmpAddressTable getFirstItem]} {
        getProtocolTableItem igmpAddressTableItem  
        sgPuts "igmpAddressTable addItem"
        while {![igmpAddressTable getNextItem]} {
            getProtocolTableItem igmpAddressTableItem   
            sgPuts "igmpAddressTable addItem"      
        }
    }      
    sgPuts {igmpAddressTable set $chassis $card $port}

    return $retCode 
}

########################################################################
# Procedure: getIgmpVx
#
# This command generats Igmp server commands fo CPU ports.
#
# Arguments(s):
#   chassis :       chassis Id
#   card    :       card Id
#   port    :       port Id
#
#   Results :        Always returns 0
#       
########################################################################
proc scriptGen::getIgmpVx {chassis card port} \
{
    set retCode 0
    set nameIndex 2

    if {![igmpVxServer select $chassis $card $port]} {
        sgPuts {igmpVxServer select $chassis $card $port}
        sgPuts "igmpVxServer clearAllHosts"
        
        if {![igmpVxServer getFirstHost]} {
            doIgmpHost host1
            while {![igmpVxServer getNextHost]} {
                doIgmpHost [format "host%i" $nameIndex]
                incr nameIndex
            }
        }
    } 

    if {![igmpVxServer get]} {
        generateCommand igmpVxServer
        sgPuts "igmpVxServer set"
        sgPuts ""
    }       
    return $retCode
}

########################################################################
# Procedure: doIgmpHost
#
# This command gets Igmp host
#
# Arguments(s):
#
#   name :          Igmp host name
#
#   Results :        Always returns 0
#       
########################################################################
proc scriptGen::doIgmpHost {name} \
{
    set retCode 0
            
    if {![igmpHost getFirstGroupRange]} {
        set nameIndex 2
        doIgmpGroupRange groupRange1
        while {![igmpHost   getNextGroupRange]} {
            doIgmpGroupRange [format "groupRange%i" $nameIndex]
            incr nameIndex
        }
    }         

    generateCommand igmpHost
    sgPuts "igmpVxServer addHost $name"
    sgPuts ""


    return $retCode
} 

########################################################################
# Procedure: doIgmpGroupRange
#
# This command gets Igmp Group range.
#
# Arguments(s):
#
#   name :          Igmp Group range name
#
#   Results :        Always returns 0
#       
########################################################################
proc scriptGen::doIgmpGroupRange {name} \
{
    set retCode 0

    if {![igmpGroupRange getFirstSourceRange]} {
        set nameIndex 2
        doIgmpSourceRange sourceRange1
        while {![igmpGroupRange  getNextSourceRange]} {
            doIgmpSourceRange [format "sourceRange%i" $nameIndex]
            incr nameIndex
        }
    } 
        
    generateCommand igmpGroupRange
    sgPuts "igmpHost addGroupRange $name"
    sgPuts ""


    return $retCode
}

########################################################################
# Procedure: doIgmpSourceRange
#
# This command gets Igmp source range
#
# Arguments(s):
#
#   name :         Igmp source range name
#
#   Results :      Always returns 0
#       
########################################################################
proc scriptGen::doIgmpSourceRange {name} \
{
    set retCode 0

    generateCommand igmpSourceRange
    sgPuts "igmpGroupRange addSourceRange $name"
	sgPuts ""
    return $retCode
}

########################################################################
# 
#       ------------  OSPFV3 procedures  ------------
#
########################################################################

########################################################################
# Procedure: getOspfV3
#
# This command generats OspfV3 server commands
# Arguments(s):
# chassis : chassis Id
# card    : card Id
# port    : port Id
# Returned Result:
#
########################################################################

proc scriptGen::getOspfV3 {chassis card port} \
{
    set retCode 0
    set nameIndex 2
    if {![ospfV3Server select $chassis $card $port]} {
        sgPuts {ospfV3Server select $chassis $card $port}
        sgPuts "ospfV3Server clearAllRouters"
        
        if {![ospfV3Server getFirstRouter]} {
            doOspfV3Router router1
            while {![ospfV3Server getNextRouter]} {
                doOspfV3Router [format "router%i" $nameIndex]
                incr nameIndex
            }
        }
    }
    return $retCode
}


########################################################################
# Procedure: doOspfV3Router
#
# This command gets OSPFV3 router
# Arguments(s):
# name : RouterName
# Returned Result:
########################################################################

proc scriptGen::doOspfV3Router {name} \
{
    set retCode 0
    
    if {![ospfV3Router getFirstInterface]} {
        set nameIndex 2
        doOspfV3Interface interface1
        while {![ospfV3Router  getNextInterface]} {
            doOspfV3Interface [format "interface%i" $nameIndex]
            incr nameIndex
        }
    }               
    if {![ospfV3Router getFirstRouteRange]} {
        set nameIndex 2
        doOspfV3RouteRange routeRange1
        while {![ospfV3Router  getNextRouteRange]} {
            doOspfV3RouteRange [format "routeRange%i" $nameIndex]
            incr nameIndex
        }
    }            
    if {![ospfV3Router getFirstUserLsaGroup]} {
        set nameIndex 2
        doOspfV3UserLsaGroup userLsaGroup1
        while {![ospfV3Router  getNextUserLsaGroup]} {
            doOspfV3UserLsaGroup [format "userLsaGroup%i" $nameIndex]
            incr nameIndex
        }
    }   
    
    generateCommand ospfV3Router
    sgPuts "ospfV3Server addRouter $name"
    sgPuts ""
    return $retCode
}  

########################################################################
# Procedure: doOspfV3Interface
#
# This command gets OSPFV3 Interface
# Arguments(s):
# name : RouterName
# Returned Result:
########################################################################      

proc scriptGen::doOspfV3Interface {name} \
{
    set retCode 0

    generateCommand ospfV3Interface 
    sgPuts "ospfV3Router addInterface $name"
    return $retCode
}  


########################################################################
# Procedure: doOspfV3RouteRange
#
# This command gets OSPFV3 route range
# Arguments(s):
# name : RouterName
# Returned Result:
########################################################################      

proc scriptGen::doOspfV3RouteRange {name} \
{
    set retCode 0
    generateCommand ospfV3RouteRange
    sgPuts "ospfV3Router addRouteRange $name"
    return $retCode
}  


########################################################################
# Procedure: doOspfV3UserLsaGroup
#
# This command gets OSPF userLsa group
# Arguments(s):
# name : RouterName
# Returned Result:
########################################################################      

proc scriptGen::doOspfV3UserLsaGroup {name} \
{
    set retCode 0
    set nameIndex 2

    set lsaObject [ospfV3UserLsaGroup getFirstUserLsa]
	if {$lsaObject != "NULL" } {
		set lsaType [$lsaObject cget -type]
		doOspfV3UserLsa userLsa1 $lsaType

		set lsaObject [ospfV3UserLsaGroup getNextUserLsa]

        while {$lsaObject != "NULL"} {
			set lsaType [$lsaObject cget -type]
            doOspfV3UserLsa [format "userLsa%i" $nameIndex] $lsaType
			set lsaObject [ospfV3UserLsaGroup getNextUserLsa]
            incr nameIndex
        }
    }
            
    generateCommand ospfV3UserLsaGroup
    sgPuts "ospfV3Router addUserLsaGroup $name"
    return $retCode
}


########################################################################
# Procedure: doOspfV3UserLsa
#
# This command gets OSPFV3 userLsa 
# Arguments(s):
# name : RouterName
# lsaType: lsa type.
# Returned Result:
########################################################################      

proc scriptGen::doOspfV3UserLsa {name  lsaType} \
{  
    set retCode 0
	set lsaTypeString "ospfV3LsaRouter"
    switch $lsaType \
        $::ospfV3LsaRouter { \
			doOspfV3LsaRouterInterface
            generateCommand  ospfV3LsaRouter 
			set lsaTypeString "ospfV3LsaRouter" \
		} \
        $::ospfV3LsaNetwork { \
            generateCommand ospfV3LsaNetwork 
			set lsaTypeString "ospfV3LsaNetwork" \
        }\
        $::ospfV3LsaInterAreaPrefix { \
            generateCommand ospfV3LsaInterAreaPrefix 
			set lsaTypeString "ospfV3LsaInterAreaPrefix" 
        } \
        $::ospfV3LsaInterAreaRouter { \
            generateCommand ospfV3LsaInterAreaRouter 
			set lsaTypeString "ospfV3LsaInterAreaRouter" \
        } \
        $::ospfV3LsaAsExternal { \
            generateCommand ospfV3LsaAsExternal 
			set lsaTypeString "ospfV3LsaAsExternal" \
        } \
		$::ospfV3LsaLink { \
			doOspfV3Prefix ospfV3LsaLink
            generateCommand ospfV3LsaLink 
			set lsaTypeString "ospfV3LsaLink"  \
        } \
		$::ospfV3LsaIntraAreaPrefix { \
			doOspfV3Prefix ospfV3LsaIntraAreaPrefix
            generateCommand ospfV3LsaIntraAreaPrefix 
			set lsaTypeString "ospfV3LsaIntraAreaPrefix" \
        } \

    sgPuts "ospfV3UserLsaGroup addUserLsa $name $lsaTypeString" 
	
	switch $lsaType \
        $::ospfV3LsaRouter { \
			sgPuts "ospfV3LsaRouter clearAllInterfaces" \
        } \
		$::ospfV3LsaLink { \
			sgPuts "ospfV3LsaLink clearPrefixList" \
        } \
		$::ospfV3LsaIntraAreaPrefix { \
			sgPuts "ospfV3LsaIntraAreaPrefix clearPrefixList" \
        } \
	
	sgPuts "" 
    
    return $retCode
}

########################################################################
# Procedure: doOspfV3LsaRouterInterface
#
# This command gets OSPFV3 Router LSA Interface 
# Arguments(s):
# Returned Result:
########################################################################      

proc scriptGen::doOspfV3LsaRouterInterface {} \
{  
	if {![ospfV3LsaRouter getFirstInterface]} {
        generateCommand ospfV3LsaRouterInterface
		sgPuts "ospfV3LsaRouter addInterface" 
        while {![ospfV3LsaRouter getNextInterface]} {
            generateCommand ospfV3LsaRouterInterface
			sgPuts "ospfV3LsaRouter addInterface"
        }
    } 
}  


########################################################################
# Procedure: doOspfV3Prefix
#
# This command gets OSPFV3 prefix
# Arguments(s):
# Returned Result:
########################################################################      

proc scriptGen::doOspfV3Prefix {cmd} \
{  
	if {![$cmd getFirstPrefix]} {
        generateCommand ospfV3IpV6Prefix
		sgPuts "$cmd addPrefix" 
        while {![$cmd getNextPrefix]} {
            generateCommand ospfV3IpV6Prefix
			sgPuts "$cmd addPrefix"
        }
    } 
} 


########################################################################
# Procedure: doOspfV3Options
#
# This command gets the enum for ospfV3 options.
# Arguments(s):
# value : The value of options
# Returned Result: Text for options ( [expr x|y]) 
########################################################################
    
proc scriptGen::doOspfV3Options {value enumValList} \
{
    variable enumsArray
    set retCode 0 
    set modes {}
	set enumText 0
	set itemIndex 0
 
    set joinedList  [join $enumValList]
    for {set i 1} {$i < 0xFF} {set i [expr $i << 1]} {

        if {[expr $value & $i]} {
			set enumValue [expr $value & $i]         
			set index       [lsearch $joinedList $enumValue]		
			if { $index != -1 } {
				if { $itemIndex > 0 } {
					lappend modes "|"
				}
                lappend modes {$::}
				lappend modes   [lindex $joinedList [expr $index-1]]
				incr itemIndex
			} 
        }
	}
	if {[string length $modes] != 0} {
		set enumText [format "%cexpr %s%c" 91 [removeSpaces [join $modes]] 93]
	}
	return $enumText
  
} 


########################################################################
# 
#       ------------  PIM-SM procedures  ------------
#
########################################################################

########################################################################
# Procedure: getPimsm
#
# This command generats PIM SM server commands fo CPU ports.
#
# Arguments(s):
#   chassis :       chassis Id
#   card    :       card Id
#   port    :       port Id
#
#   Results :        Always returns 0
#       
########################################################################
proc scriptGen::getPimsm {chassis card port} \
{
    set retCode 0
    set nameIndex 2

    if {![pimsmServer select $chassis $card $port]} {
        sgPuts {pimsmServer select $chassis $card $port}
        sgPuts "pimsmServer clearAllRouters"
        
        if {![pimsmServer getFirstRouter]} {
            doPimsmRouter router1
            while {![pimsmServer getNextRouter]} {
                doPimsmRouter [format "router%i" $nameIndex]
                incr nameIndex
            }
        }
    } 

  	if {![pimsmServer get]} {
  		generateCommand pimsmServer
  		sgPuts "pimsmServer set"
  		sgPuts ""
  	}
    return $retCode
}

########################################################################
# Procedure: doPimsmRouter
#
# This command gets PIM-SM router
#
# Arguments(s):
#
#   name :          PIM-SM router name
#
#   Results :        Always returns 0
#       
########################################################################
proc scriptGen::doPimsmRouter {name} \
{
    set retCode 0
            
    if {![pimsmRouter getFirstInterface]} {
        set nameIndex 2
        doPimsmInterface interface1
        while {![pimsmRouter   getNextInterface]} {
            doPimsmInterface [format "interface%i" $nameIndex]
            incr nameIndex
        }
    }         

    generateCommand pimsmRouter
    sgPuts "pimsmServer addRouter $name"
    sgPuts ""


    return $retCode
} 

########################################################################
# Procedure: doPimsmInterface
#
# This command gets PIM-SM interface.
#
# Arguments(s):
#
#   name :          PIM-SM interface name
#
#   Results :        Always returns 0
#       
########################################################################
proc scriptGen::doPimsmInterface {name} \
{
    set retCode 0

    if {![pimsmInterface getFirstJoinPrune]} {
        set nameIndex 2
        doPimsmJoinPrune joinPrune1
        while {![pimsmInterface  getNextJoinPrune]} {
            doPimsmJoinPrune [format "joinPrune%i" $nameIndex]
            incr nameIndex
        }
    } 
        
	if {![pimsmInterface getFirstSource]} {
        set nameIndex 2
        doPimsmSource source1
        while {![pimsmInterface  getNextSource]} {
            doPimsmSource [format "source%i" $nameIndex]
            incr nameIndex
        }
    } 

    generateCommand pimsmInterface
    sgPuts "pimsmRouter addInterface $name"
    sgPuts ""


    return $retCode
}

########################################################################
# Procedure: doPimsmJoinPrune
#
# This command gets PIM-SM Multicast range
#
# Arguments(s):
#
#   name :         IPIM-SM Multicast range name
#
#   Results :      Always returns 0
#       
########################################################################
proc scriptGen::doPimsmJoinPrune {name} \
{
    set retCode 0

    generateCommand pimsmJoinPrune
    sgPuts "pimsmInterface addJoinPrune $name"
	sgPuts ""
    return $retCode
}



########################################################################
# Procedure: doPimsmSource
#
# This command gets PIM-SM register range.
#
# Arguments(s):
#
#   name :         PIM-SM register range name
#
#   Results :      Always returns 0
#       
########################################################################
proc scriptGen::doPimsmSource {name} \
{
    set retCode 0

    generateCommand pimsmSource
    sgPuts "pimsmInterface addSource $name"
	sgPuts ""
    return $retCode
}


########################################################################
# 
#       ------------  STP procedures  ------------
#
########################################################################

########################################################################
# Procedure: getStp
#
# This command generats STP server commands fo CPU ports.
#
# Arguments(s):
#   chassis :       chassis Id
#   card    :       card Id
#   port    :       port Id
#
#   Results :        Always returns 0
#       
########################################################################
proc scriptGen::getStp {chassis card port} \
{
    set retCode 0

    if {![stpServer select $chassis $card $port]} {
        sgPuts {stpServer select $chassis $card $port}
        sgPuts "stpServer clearAllBridges"
        sgPuts "stpServer clearAllLans"
        
        if {![stpServer getFirstLan]} {
            doStpLan 
            while {![stpServer getNextLan]} {
                doStpLan 
            }
        }
        
        if {![stpServer getFirstBridge]} {
            doStpBridge 
            while {![stpServer getNextBridge]} {
                doStpBridge 
            }
        }
    } 
    return $retCode
}

########################################################################
# Procedure: doStpBridge
#
# This command gets STP Bridge
#
# Arguments(s):
#
#
#   Results :        Always returns 0
#       
########################################################################
proc scriptGen::doStpBridge {} \
{
    set retCode 0
	set nameIndex 2
            
    if {![stpBridge getFirstInterface]} {
        doStpInterface stpBridgeInterface1
        while {![stpBridge   getNextInterface]} {
            doStpInterface [format "stpBridgeInterface%i" $nameIndex]
			incr nameIndex
        }
    }         

    generateCommand stpBridge
    sgPuts "stpServer addBridge [stpBridge cget -name]"
    sgPuts ""


    return $retCode
} 

########################################################################
# Procedure: doStpInterface
#
# This command gets STP interface.
#
# Arguments(s):
#
# name : StpBridgeInterfaceName
# Results :        Always returns 0
#       
########################################################################
proc scriptGen::doStpInterface {name} \
{
    set retCode 0
    generateCommand stpInterface
    sgPuts "stpBridge addInterface $name"
    sgPuts ""


    return $retCode
}

########################################################################
# Procedure: doStpLan
#
# This command gets STP Global LANs
#
# Arguments(s):
#
#
#   Results :      Always returns 0
#       
########################################################################
proc scriptGen::doStpLan {} \
{
    set retCode 0

    generateCommand stpLan
    sgPuts "stpServer addLan [stpLan cget -name]"
	sgPuts ""
    return $retCode
}


