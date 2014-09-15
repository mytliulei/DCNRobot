#############################################################################################
# Version 4.10	$Revision: 120 $
# $Date: 12/12/02 5:01p $
# $Author: Debby $
#
# $Workfile: ixTclHalSetup.tcl $ - required file for package req IxTclHal
#
#  Package initialization file
#
#  This file is executed when you use "package require IxTclHal" to
#  load the IxTclHal library package. It sets up the TclHal related
#  objects and commands. This file will be called by ixtclhal.tcl file
#  on the server side or whereever the TclHal.dll file is installed.
#
#
# Copyright © 1997 - 2005 by IXIA.
# All Rights Reserved.
#
#############################################################################################

if [isWindows] {
    load ixTclHal.dll

	# This is done for the applications that don't know the location of the mpexpr10.dll, itm
	set mpexprPath "$env(IXTCLHAL_LIBRARY)/../../bin"
	if { [catch {load Mpexpr10.dll}] } {
		catch {load $mpexprPath/Mpexpr10.dll}
	}


    ############################ OBJECT INSTANTIATION ##########################

    foreach procName $ixTclHal::noArgList {
        set tclCmd [format "TCL%s%s" [string toupper [string index $procName 0]] [string range $procName 1 end]]
        ixTclHal::createCommand $tclCmd $procName
    }

    ixTclHal::createCommand TCLStatistics    stat
    ixTclHal::createCommand TCLUtils         ixUtils
    ixTclHal::createCommand TCLVsrStatistics vsrStat

    foreach procName $ixTclHal::pointerList {
        set tclCmd [format "TCL%s%s" [string toupper [string index $procName 0]] [string range $procName 1 end]]
        ixTclHal::createCommandPtr $tclCmd $procName
    }

    foreach procName $ixTclHal::protocolList {
        set tclCmd [format "TCL%s%s" [string toupper [string index $procName 0]] [string range $procName 1 end]]
        ixTclHal::createCommand $tclCmd $procName \$::portPtr
    }
	ixTclHal::createCommandPtr TCLProtocolOffset	  protocolOffset   \$::portPtr
    ixTclHal::createCommandPtr TCLStream              stream           \$::portPtr \$::protocolPtr \$::protocolOffsetPtr
    ixTclHal::createCommandPtr TCLIgmpAddressTable    igmpAddressTable \$::igmpAddressTableItemPtr
    ixTclHal::createCommandPtr TCLRip                 rip              \$::portPtr
    ixTclHal::createCommandPtr TCLMpls                mpls             \$::portPtr 
    ixTclHal::createCommand    TCLAtmHeader           atmHeader        \$::portPtr \$::atmHeaderCounterPtr
    ixTclHal::createCommandPtr TCLSrpDiscovery        srpDiscovery     \$::portPtr \$::srpMacBindingPtr
    ixTclHal::createCommandPtr TCLSrp                 srpHeader        \$::portPtr \$::protocolPtr
    ixTclHal::createCommand    TCLIgmp			      igmp			   \$::portPtr	\$::igmpGroupRecordPtr

    ixTclHal::createCommand    TCLUdf                 udf              \$::streamPtr
    ixTclHal::createCommand    TCLTableUdf            tableUdf         \$::portPtr	\$::tableUdfColumnPtr

    ixTclHal::createCommand    TCLIpAddressTable      ipAddressTable   \$::ipAddressTableItemPtr
    ixTclHal::createCommand    TCLArpServer           arpServer        \$::arpAddressTableEntryPtr
    ixTclHal::createCommand    TCLRipRoute            ripRoute         \$::ripPtr
    ixTclHal::createCommand    TCLMplsLabel           mplsLabel        \$::mplsPtr

    ixTclHal::createCommandPtr TCLRprRingControl            rprRingControl  \$::portPtr \$::protocolPtr
    ixTclHal::createCommandPtr TCLRprTlvIndividualBandwidth rprTlvIndividualBandwidth   \$::rprTlvBandwidthPairPtr
    ixTclHal::createCommand    TCLRprTopology               rprTopology     \$::portPtr \$::rprTlvIndividualBandwidthPtr \
                                                                                        \$::rprTlvStationNamePtr    \
                                                                                        \$::rprTlvNeighborAddressPtr    \
                                                                                        \$::rprTlvTotalBandwidthPtr     \
                                                                                        \$::rprTlvVendorSpecificPtr     \
                                                                                        \$::rprTlvWeightPtr 
																						
																						
    ixTclHal::createCommandPtr TCLIpV6HopByHop      ipV6HopByHop       \$::ipV6OptionPAD1Ptr                    \
                                                                       \$::ipV6OptionPADNPtr                    \
                                                                       \$::ipV6OptionJumboPtr                   \
                                                                       \$::ipV6OptionRouterAlertPtr             \
                                                                       \$::ipV6OptionBindingUpdatePtr           \
                                                                       \$::ipV6OptionBindingAckPtr              \
                                                                       \$::ipV6OptionHomeAddressPtr             \
                                                                       \$::ipV6OptionBindingRequestPtr          \
                                                                       \$::ipV6OptionMIpV6UniqueIdSubPtr        \
                                                                       \$::ipV6OptionMIpV6AlternativeCoaSubPtr  \
                                                                       \$::ipV6OptionUserDefinePtr
																						                                          

    ixTclHal::createCommand    TCLIpV6               ipV6              \$::portPtr  \$::ipV6RoutingPtr          \
                                                                                    \$::ipV6FragmentPtr         \
                                                                                    \$::ipV6DestinationPtr      \
                                                                                    \$::ipV6AuthenticationPtr	\
																					\$::ipV6HopByHopPtr
    ixTclHal::createCommandPtr TCLCustomOrderedSet   customOrderedSet
    ixTclHal::createCommand    TCLLinkFaultSignaling linkFaultSignaling \$::customOrderedSetPtr
    ixTclHal::createCommandPtr TCLPacketGroupStats   packetGroupStats  \$::latencyBinPtr
    ixTclHal::createCommandPtr TCLGfp				 gfp			   \$::portPtr
                                                                                        
    ixTclHal::createCommand    TCLAtmOam			atmOam				\$::portPtr		\$::atmOamAisPtr	\
                                                                                        \$::atmOamRdiPtr	\
                                                                                        \$::atmOamFaultManagementCCPtr	\
                                                                                        \$::atmOamFaultManagementLBPtr  \
																						\$::atmOamActDeactPtr
                                                                                        
    ixTclHal::createCommandPtr TCLAtmOamTrace		atmOamTrace			\$::portPtr

    ixTclHal::createCommandPtr TCLVlan				vlan		        \$::portPtr
    ixTclHal::createCommand	   TCLStackedVlan       stackedVlan         \$::portPtr \$::vlanPtr


    ixTclHal::createCommandPtr TCLMmd   mmd     \$::mmdRegisterPtr
    ixTclHal::createCommandPtr TCLMiiae miiae   \$::mmdPtr

    ixTclHal::createCommandPtr TCLDhcpV4Properties		dhcpV4Properties		\$::dhcpV4TlvPtr
    ixTclHal::createCommandPtr TCLDhcpV4DiscoveredInfo  dhcpV4DiscoveredInfo	\$::dhcpV4TlvPtr

	# dhcpV6Tlv command is exactly the same as dhcpV4Tlv.  We use the same underlying C++ object.
	ixTclHal::createCommandPtr TCLDhcpV4Tlv				dhcpV6Tlv	
    ixTclHal::createCommandPtr TCLDhcpV6Properties		dhcpV6Properties		\$::dhcpV6TlvPtr
    ixTclHal::createCommandPtr TCLDhcpV6DiscoveredInfo  dhcpV6DiscoveredInfo	\$::dhcpV6TlvPtr

    ixTclHal::createCommandPtr TCLInterfaceEntry     interfaceEntry     \$::interfaceIpV4Ptr \$::interfaceIpV6Ptr \$::dhcpV4PropertiesPtr \$::dhcpV6PropertiesPtr
    ixTclHal::createCommandPtr TCLDiscoveredNeighbor discoveredNeighbor \$::discoveredAddressPtr
    ixTclHal::createCommandPtr TCLDiscoveredList     discoveredList     \$::discoveredNeighborPtr \$::discoveredAddressPtr

    ixTclHal::createCommand    TCLInterfaceTable     interfaceTable     \$::interfaceEntryPtr \$::discoveredListPtr	 \$::dhcpV4DiscoveredInfoPtr \$::dhcpV6DiscoveredInfoPtr


    # Enable logging of messages from SWIG
    enableEvents true

    #################################################################################
    # Procedure: after
    #
    # NOTE:  This command effective 'steps on' the original after command
    #        so that we have more control over what happens during the sleep
    #        process (ie., so that we can make some task switches)
    #
    #        It is used *exactly* like the original after.
    #
    #        This proc is here because we don't want to overload the 'after' command
    #        in unix, only windows.
    #
    # Argument(s):
    #   duration    - time to sleep, in milliseconds
    #
    #################################################################################
    proc after {args} \
    {
	    set retCode ""

	    set argc    [llength $args]

	    set duration  [lindex $args 0]  
	    if {[stringIsInteger $duration] && $argc == 1} {
		    ixSleep $duration
		    set retCode ""
	    } else {
		    catch {eval originalAfter $args} retCode
	    }

	    set retCode [stringSubstitute $retCode originalAfter after]

	    return $retCode
    }

} else {
    catch {package req Mpexpr}

    proc enableEvents {flag} {}
	logMsg "Tcl Client is running Ixia Software version: $env(IXIA_VERSION)"
}


# note that mpexpr is only req'd for 8.3 & below.
if {[info command mpexpr] == ""} {
    # if we didn't get a real mpexpr AND we're not 8.4, that's ugly so throw an exception - otherwise just make it work
    if {[info tclversion] <= 8.3} {
        puts "Package req failed: Mpexpr package/file not found"
        return -code error -errorinfo "Mpexpr package/file not found"
    } else {    
        proc mpexpr {args}   {return [eval expr $args]}
        proc mpformat {args} {return [eval format $args]}
        proc mpincr {args} \
        {
            set Item [lindex $args 0]
            upvar $Item item
            set args [lrange $args 1 end]
            return [eval incr item $args]
        }
    }
}


useProfile false 
