####################################################################
# Version 4.10	$Revision: 35 $
# $Date: 9/30/02 3:59p $
# $Author: Mgithens $
#
# $Workfile: packetBuilder.tcl $ - Packet Builder parameters
#
#   Copyright © 1997 - 2005 by IXIA
#   All Rights Reserved.
#
#	Revision Log:
#	02-19-1998	DS	Genesis
#
# Description: This file contains common utility functions used to 
#			   build the data packets for various protocols.
#
########################################################################



####################################################################
#				Utility procs used in building packets
####################################################################



########################################################################
# Procedure: calculateChecksum
#
# This command calculates a checksum for the data argument
#
# Argument(s):
#	data		data to calculate checksum for	
#
#########################################################################
proc calculateChecksum {data} \
{
	set checksum	0

	foreach {hi low} $data \
	{
		set word [format 0x%02s%02s $hi $low]
		set compliment $word
		set checksum [expr $checksum + $compliment]
	}
	
	set checksum [expr (($checksum >> 16) + ($checksum & 0xffff))]
	set checksum [expr ~($checksum + ($checksum >> 16))]

	return [long2octet $checksum]
}


########################################################################
# Procedure: oid2octet
#
# This command converts an oid into an octet list for use in an SNMP
# packet.
#
# Argument(s):
#		oid		oid to convert
#
#########################################################################
proc oid2octet {oid} \
{
	set myOid	[oid2dot $oid]	;# just in case, doesn't hurt
	while {([string length $myOid] > 0)} \
	{
		set dot	[string first "." $myOid]
		if {($dot < 0)} \
		{
			lappend octet [format %02x $myOid]
			break;
		} \
		else \
		{
			lappend octet [format %02x [string range $myOid 0 [expr $dot-1]]]
			set myOid	[string range $myOid [expr $dot+1] end]
		}
	}
	set octet [join [lreplace $octet 0 1 2b]]
	return $octet
}


########################################################################
# Procedure: buildLLCHeader
#
# This command builds the LLC header for an 802.2 Ethernet frame.
#
# Argument(s):
#
#########################################################################
proc buildLLCHeader {} \
{
	set DSAP		e0
	set SSAP		e0
	set control		03

	set llcHeader	[concat $DSAP $SSAP $control]

	return $llcHeader
}


########################################################################
# Procedure: buildIpHeader
#
# This command builds the IP header for an IP frame including 
# checksum calculation.
#
# Argument(s):
#		sourceIP		IP address of source, in octet format
#		destinationIP	IP address of destination, in octet format
#		dataLength		Length of the data only if UDP; else length of 
#						all data except IP header.
#		TTL				time to live
#		protocol		Protocol for IP header, ie, 1 = ICMP, 11 - UDP, etc
#		flags			Flags for IP header
#		options			32-bit options + padding, not required
#
#########################################################################
proc buildIpHeader {sourceIP  destinationIP  \
					dataLength TOS TTL protocol flags options} \
{
	set ipType			{08 00}
	set	ipVersion		45
	set	id				{00 00}
	set headerChecksum	{00 00}
	set	TTL				[format %02x $TTL]
	set TOS				[format %02x $TOS]

	if {($protocol == 11)}	\
	{
		set	totalLength	[expr $dataLength + $::kHeaderLength(udp) + $::kHeaderLength(ip)]
	} \
	else \
	{
		set totalLength $dataLength
	}

	if {[llength $options] != 0} {
		for {set i [llength $options]} {$i < 4} {incr i} {
			set options	[concat $options 00]
		}
		set ipVersion	46
	}

	set totalLength [expr $totalLength + [llength $options]]

	set ipHeader [concat $ipVersion $TOS [long2octet $totalLength] $id \
						 $flags $TTL $protocol $headerChecksum \
						 $sourceIP $destinationIP]

	if {[llength $options] > 0} {
		set ipHeader [concat $ipHeader $options]
	}

	set headerChecksum [calculateChecksum $ipHeader]
	set ipHeader [concat $ipType [join [lreplace $ipHeader 10 11 $headerChecksum]]]

	return $ipHeader
}

########################################################################
# Procedure: buildRipBlock
#
# This command builds one block for a RIP packet
#
# Argument(s):
#	ipAddress		IP address to use in RIP packet
#	Metric			metric value to use in RIP packet	
#
# Note:
# ipAddress should be passed in as a string of the format:
#	"192.42.172.0" (class C) or "192.42.0.0" (class B) etc.
# Metric should be passed in as an integer, 1-15 or 16 for unreachable.
#  (ref. rfc1058)
#########################################################################
proc buildRipBlock {ipAddress Metric {familyId "00 02"}} \
{
	if {($Metric > 16)} \
	{
		puts "Invalid metric value. Must be between 1-16."
		return
	}

	set Metric			[format %02x $Metric]
	
	return	[concat $familyId {00 00} \
					[host2addr $ipAddress] \
					{00 00 00 00 00 00 00 00} \
					{00 00 00} $Metric]
}

########################################################################
# Procedure: buildVidHeader
#
# This procedure builds the VID of a vlan-tagged frame. 
#
# Argument(s):
#   userPriority    - user priority field of the TCI, eight priority levels, 0-7
#   CFIformat       - Canonical Format Indicator - if set to true, all MAC
#                     addresses in frame is in Canonical format
#   VID             - twelve-bit VLAN identifier that uniquely identifies
#                     the VLAN to which the frame belongs.
#
#########################################################################
proc buildVidHeader {userPriority CFIformat VID} \
{
    set tpid    {81 00}

    if {$userPriority > 7 || $userPriority < 0} {
        logMsg "Invalid userPriority value.  Parameter set to 0."
        set userPriority    0
        set retCode         1
    }

   switch $CFIformat {
        true {
            set CFIformat   1
        }
        false {
            set CFIformat   0
        }
	    default {
            logMsg "Invalid CFIformat value.  Parameter set to false."
            set CFIformat   0
            set retCode     1
        }
    }

    if {$VID > 0xfff || $VID < 0} {
        logMsg "Invalid VID value.  Parameter set to 0x00."
        set VID         0
        set retCode     1
    }

    set tci     [long2octet [expr ((($userPriority << 1) + $CFIformat) << 12) + $VID]]
    
    return [concat $tpid $tci]
}


####################################################################
#				Packet building procs
####################################################################

########################################################################
# Procedure: buildIPXPacket
#
# This procedure builds the header and data portion of an IPX packet
#
# Argument(s):
#	packetType		type of packet (1 byte)
#						0x00	- unknown packet type
#						0x01	- routing information packet (RIP)
#						0x04	- service advertising packet (SAP)
#						0x05	- sequenced packet
#						0x11	- netware core protocol packet
#						0x14	- propagated packet
#	destNetwork		destination network (4 bytes)
#	destNode		destination node (6 bytes)
#	destSocket		destination socket (2 bytes)
#						0x451	- NetWare core protocol
#						0x452	- Service advertising packet
#						0x453	- Routing information packet
#						0x455	- NetBIOS packet
#						0x456	- Diagnostic packet
#						0x457	- Serialization packet
#						0x4000 - 0x7fff		- dynamic sockets
#						0x8000 - 0xffff		- well-known sockets; assigned by Novell
#	sourceNetwork	source network (4 bytes)
#	sourceNode		source node (6 bytes)		
#	sourceSocket	source socket (2 bytes, see destSocket for description)
#	dataLength		length of the data
#	data			data to follow IPX header (length = dataLength bytes)
#
#########################################################################
proc buildIPXPacket {packetType destNetwork destNode destSocket \
				sourceNetwork sourceNode sourceSocket dataLength data} \
{
    set IPXtype             {81 37}
	set checksum			{ff ff}
	set	transportControl	00

	if {[llength $destSocket] == 1} {
		set	destSocket	  [concat [format %02x [expr (($destSocket >> 8) & 0xff)]] \
				  				  [format %02x [expr $destSocket & 0xff]]]
	}

	if {[llength $sourceSocket] == 1} {
		set	sourceSocket  [concat [format %02x [expr (($sourceSocket >> 8) & 0xff)]] \
				  				  [format %02x [expr $sourceSocket & 0xff]]]
	}

	set packetType		[format %02x $packetType]

	set packetLength	[expr $::kIPXHeaderLength + $dataLength]

	set	length			[concat [format %02x [expr (($packetLength >> 8) & 0xff)]] \
							    [format %02x [expr $packetLength & 0xff]]]

	set IPXheader [concat $checksum $length $transportControl $packetType \
						  $destNetwork $destNode $destSocket \
						  $sourceNetwork $sourceNode $sourceSocket]
	set IPXpacket [concat $IPXheader $data]

    if {[protocol cget -ethernetType] == 1} {
        set ipxFrame    [concat $IPXtype $IPXpacket]
    } else {
    	set enLength  [llength $IPXpacket]
	    set	length	  [concat [format %02x [expr (($enLength >> 8) & 0xff)]] \
		    		  	      [format %02x [expr $enLength & 0xff]]]
    	set ipxFrame 	[concat $length $IPXpacket]
    }

	return $ipxFrame
}

########################################################################
# Procedure: buildIPXData
#
# This procedure builds the data portion of an IPX packet
########################################################################
proc buildIPXData {frameSize} \
{
	set ipxdataList {}
	set currLen 0
	set typeLen			2
	set dasaLen			12
	set crcLen			4

	while {$currLen < [expr $frameSize - $::kIPXHeaderLength - $typeLen - $dasaLen - $crcLen]} {
		set ipxdataList [lappend ipxdataList "B8"]
		incr currLen
	}
	return $ipxdataList
}

########################################################################
# Procedure: buildServerEntry
#
# This procedure builds one server entry (64 bytes) for a SAP packet,
# For a SAP request, only the service type field will be used to build
# the entry.
#
# Argument(s):
#	serverType		- type of server (2 bytes)
#	serverName		- server name (SAP response only, 48 bytes)
#	netAddress		- network address on which server resides (4 bytes)
#	nodeAddress		- address of the node on which server resides (2 bytes)
#	socketNum		- socket number server will receive service requests (2 bytes)
#	hops			- number of hops to reach server (2 bytes)
#
#########################################################################
proc buildServerEntry {operation serviceType serverName netAddress nodeAddress socketNum hops} \
{
	set entry $serviceType

	if {($operation == $::kSapOperation(response)) || ($operation == $::kSapOperation(getNearestServerResponse))} {
		set entry [concat $entry $serverName $netAddress $nodeAddress $socketNum $hops]
	} else {
		set emptyList {}
#		for {set i 0} {$i < 62} {incr i} {
#			set emptyList [lappend emptyList "00"]
#		}
#		set entry [concat $entry $emptyList]
	}
	return $entry
}

########################################################################
# Procedure: buildSapPacket
#
# This procedure builds a SAP packet.
# For a SAP request, only the service type field will be used to build
# the server entry.
#
# Argument(s):
#	operation		- type of operation the SAP packet performs
#						1 - request
#						2 - response
#						3 - get nearest server request
#						4 - get nearest server response	
#	serverEntry		- server information (64 bytes)
#
#########################################################################
proc buildSapPacket {operation serviceType serverName netAddress nodeAddress socketNum hops} \
{
	
	set oper	[format "00 %02x" $operation]

	if {[llength $socketNum] == 1} {
		set	socketNum	  [concat [format %02x [expr (($socketNum >> 8) & 0xff)]] \
				  				  [format %02x [expr $socketNum & 0xff]]]
	}

	set serverEntry [buildServerEntry $operation $serviceType $serverName $netAddress $nodeAddress \
					 $socketNum $hops]
	set sapFrame [concat $oper $serverEntry]
	return $sapFrame
}

########################################################################
# Procedure: buildNetworkEntry
#
# This procedure builds one network entry (8 bytes) for a RIPX packet.
#
# Argument(s):
#	networkNumber	- network number. Set to all F's for requests (4 bytes)
#	hops			- number of routers to pass through to reach the network
#					  number (2 bytes)
#	ticks			- how much time it takes to reach the network number
#					  (2 bytes)
#
#########################################################################
proc buildNetworkEntry {networkNumber hops ticks} \
{
	return [concat $networkNumber [format "00 %02x" $hops] [format "00 %02x" $ticks]]
}

########################################################################
# Procedure: buildRipxPacket
#
# This procedure builds a RIP packet used in IPX.
#
# Argument(s):
#	operation		- type of operation the SAP packet performs (2 bytes)
#						1 - request
#						2 - response
#	networkEntry	- network information (8 bytes)
#
#########################################################################
proc buildRipxPacket {operation networkNumber hops ticks} \
{
	set oper [format "00 %02x" $operation]
	set nwEntry [buildNetworkEntry $networkNumber $hops $ticks]
	return [concat $oper $nwEntry]
}

########################################################################
# Procedure: buildArpPacket
#
# This procedure builds the data portion of an ARP packet
#
# Argument(s):
#	sourceMAC		source MAC address, list format
#	sourceIP		IP address of the source, in text format
#	dutIP			IP address of the DUT, in text format
#
#########################################################################
# ARP request on ethernet
proc buildArpPacket {sourceMAC sourceIP dutIP} \
{
	set ethernetType	{08 06}
	set destMAC			{00 00 00 00 00 00}
	set hwType			{00 01}
	set protocolType	{08 00}
	set hwAddressLen	06		;# length of MAC address
	set	prAddressLen	04		;# length of IP address
	set opcode			{00 01}

	return	[concat $ethernetType $hwType $protocolType $hwAddressLen $prAddressLen \
					$opcode $sourceMAC [host2addr $sourceIP] $destMAC [host2addr $dutIP]]
}


########################################################################
# Procedure: buildRipPacket
#
# This procedure builds the data portion of a routing update frame. Note-
# up to 25 IP addresses may be specified in one datagram.
#
# Argument(s):
#		sourceMAC		source MAC address, list format
#		sourceIP		IP address of source, in text format
#		destinationIP	IP address of destination, in text format
#		RipCommand		Command for RIP frame:  01 - request
#												02 - response
#		IpList			List of RIP blocks to build RIP packet from -
#						use buildRipBlocks
#
#########################################################################
proc buildRipPacket {sourceMAC sourceIP destinationIP RipCommand IpList {ttl 0x40} {ripVersion 02}} \
{
	# Determine number of items in IpList first...
	set	IpListLength	[llength $IpList]
	if {($IpListLength > 25)} \
	{
		puts "Too many IP addresses specified for RIP"
		return
	}

	# Determine data length for IP header & UDP header
	set	RipLength		20
	set dataLength		[expr ($IpListLength * $RipLength) + $::kHeaderLength(rip)]

	# Build IP header for RIP packet
	set TOS				00		;# includes precedence bits
	set protocol		11
	set	flags			{00 00}
	set options			{}

	# make the destination IP address into a broadcast type...
	set destinationIP	[host2addr $destinationIP]
	if {( [llength $destinationIP] == 0 )} \
	{
		puts "Invalid destination IP address."
		return
	}
	set ipHeader		[buildIpHeader [host2addr $sourceIP] $destinationIP \
										$dataLength $TOS $ttl $protocol $flags $options]

	# build UDP part
	set sourcePort		{02 08}		;# source port 208 = RIP
	set destPort		{02 08}
	set udpLength		[expr $dataLength + $::kHeaderLength(udp)]
	set	udpLength		[concat [format %02x [expr (($udpLength >> 8) & 0xff)]] \
							    [format %02x [expr $udpLength & 0xff]]]
	set udpChecksum		{00 00}

	# build data part of UDP
	set RipCommand		[format %02x $RipCommand]	;# just to clean it up
	set data			[concat $RipCommand [format %02x $ripVersion] {00 00}]

	foreach {ipItem} $IpList \
	{
		set data		[concat $data $ipItem]
	}

	set	udpData			[concat $sourcePort $destPort $udpLength $udpChecksum $data]
	set	pseudoIpHdr		[concat [host2addr $sourceIP] $destinationIP 00 $protocol $udpLength]
	set	udpChecksum		[calculateChecksum $pseudoIpHdr]

	# replace udpChecksum in udpData
	return	[concat $ipHeader [join [lreplace $udpData 6 7 $udpChecksum]]]
}


########################################################################
# Procedure: buildUdpEchoPacket
#
# This procedure builds the data portion of a test packet for use 
# w/Bradner's test suite
#
# Argument(s):
#	sourceIP		IP address of source, in text format
#	destIP			IP address of destination, in text format
#	frameLength		total length of frame, including IP & UDP headers	
#
#########################################################################
proc buildUdpEchoPacket {sourceIP destIP frameLength} \
{
	# a couple of constants...
	set	addressLength	6
	set	crcLength		4
	set	typeLength		2

	set dataLength		[expr $frameLength - $addressLength*2 - $typeLength - \
							  $::kHeaderLength(ip) - $::kHeaderLength(udp) - $crcLength]

	set TOS				00		;# includes precedence bits
 	set TTL				0x0a
 	set protocol		11			;# UDP
 	set flags			{00 00}
	set options			{}
	set ipHeader		[buildIpHeader [host2addr $sourceIP] [host2addr $destIP] \
										$dataLength $TOS $TTL $protocol $flags $options]

	# build UDP part
 	set sourcePort		{C0 20}
 	set destPort		{00 07}		;# ethernet Echo
	set udpLength		[concat {00} [format %02x [expr $dataLength + $::kHeaderLength(udp)]]]
	set udpChecksum		{00 00}

 	set data {}
    for {set x 0} {$x < $dataLength} {incr x} {
 		lappend data [format %02x [expr $x & 0xff]]
 	}

 	set udpHeader		[concat $sourcePort $destPort $udpLength $udpChecksum]
	set pseudoIpHeader	[concat [host2addr $sourceIP] [host2addr $destIP] 00 $protocol $udpLength]
	set udpChecksum		[calculateChecksum [concat $pseudoIpHeader $udpHeader $data]]
	set udpHeader		[join [lreplace $udpHeader 6 end $udpChecksum]]

 	return [concat $ipHeader $udpHeader $data]
}


########################################################################
# Procedure: buildIgmpPacket
#
# This procedure builds the data portion of an IP-multicast (IGMP)
# packet.
#
# Argument(s):
#	sourceIP		IP address of source, in text format
#	destIP			IP address of destination, in text format
#	version			v1 or v2 IGMP
#	type			IGMP message type:
#						0x11	- Membership query
#						0x16	- Version 2 membership report
#						0x17	- Leave group
#						0x12	- Version 1 membership report (provided
#								  for backwards capability only)
#	respTime		Maximum allowed time before sending a responding
#					report, in units of 1/10 second.  Valid only for
#					type = 0x11 (membership query)
#	groupAddr		IP multicast group address, set to zero for sending
#					a general membership query.
#
#########################################################################

proc buildIgmpPacket {sourceIP destIP version type respTime groupAddr} \
{
	set TOS				0xc0			;# includes precedence bits
 	set TTL				0x01
 	set protocol		02			;# IGMP
	set IgmpHdrLength	[expr 8 + $::kHeaderLength(ip)]
 	set flags			{00 00}

	switch $version {
		default -
		v1	{
			set options			{}
		}
		v2	{
			set options			{94 04}
		}
	}
	set ipHeader		[buildIpHeader [host2addr $sourceIP] [host2addr $destIP] \
										$IgmpHdrLength $TOS $TTL $protocol $flags $options]

	# build IGMP part
	set type			[format %02x $type]
	set respTime		[format %02x $respTime]
	set igmpChecksum	{00 00}
	if {$groupAddr == 0} {
		set groupAddr	0.0.0.0
	}

	set igmpHeader		[concat $type $respTime $igmpChecksum [host2addr $groupAddr]]

	set igmpChecksum	[calculateChecksum $igmpHeader]
	set igmpHeader		[join [lreplace $igmpHeader 2 3 $igmpChecksum]]

 	return [concat $ipHeader $igmpHeader]
}


########################################################################
# Procedure: buildIpPriorityPacket
#
# This procedure builds the data portion of a test UDP packet for Priority
# Queue test.
#
# Argument(s):
#	sourceIP		IP address of source, in text format
#	destIP			IP address of destination, in text format
#	frameLength		total length of frame, including IP & UDP headers
#	precedence	
#
#########################################################################

proc buildIpPriorityPacket {sourceIP destIP frameLength TOS} \
{
	# a couple of constants...
	set	addressLength	6
	set	crcLength		4
	set	typeLength		2

	set dataLength		[expr $frameLength - $addressLength*2 - $typeLength - \
							  $::kHeaderLength(ip) - $::kHeaderLength(udp) - $crcLength]

	set TOS				[format %02x $TOS]		;# includes precedence bits
 	set TTL				0x0a
 	set protocol		11			;# UDP
 	set flags			{00 00}
	set options			{}
	set ipHeader		[buildIpHeader [host2addr $sourceIP] [host2addr $destIP] \
										$dataLength $TOS $TTL $protocol $flags $options]

	# build UDP part
 	set sourcePort		{C0 20}
 	set destPort		{00 07}		;# ethernet Echo
	set udpLength		[concat {00} [format %02x [expr $dataLength + $::kHeaderLength(udp)]]]
	set udpChecksum		{00 00}

 	for {set x 0} {$x < $dataLength} {incr x} {
 		lappend data [format %02x [expr $x & 0xff]]
 	}

 	set udpHeader		[concat $sourcePort $destPort $udpLength $udpChecksum]
	set pseudoIpHeader	[concat [host2addr $sourceIP] [host2addr $destIP] 00 $protocol $udpLength]
	set udpChecksum		[calculateChecksum [concat $pseudoIpHeader $udpHeader $data]]
	set udpHeader		[join [lreplace $udpHeader 6 end $udpChecksum]]

 	return [concat $ipHeader $udpHeader $data]
}



########################################################################
# Procedure: buildVlanTagPacket
#
# This procedure builds the data portion of a vlan tag packet. 
#
# Argument(s):
#   userPriority    - user priority field of the TCI, eight priority levels, 0-7
#   CFIformat       - Canonical Format Indicator - if set to true, all MAC
#                     addresses in frame is in Canonical format
#   VID             - twelve-bit VLAN identifier that uniquely identifies
#                     the VLAN to which the frame belongs.
#   data            - remaining data for packet
#
#########################################################################
proc buildVlanTagPacket {userPriority CFIformat VID data} \
{
    return [concat [buildVidHeader $userPriority $CFIformat $VID] $data]
}


########################################################################
# Procedure: buildSnmpPacket
#
# This procedure builds the data portion of an SNMP management frame. 
# Only 'get' requests are supported.
#
# Argument(s):
#	sourceIP		IP address of source, in text format
#	destIP			IP address of destination, in text format
#	sourcePort		Source port to aim SNMP packet at
#	communityName	community name, in text format (usually 'public')
#	oid				oid to get	
#
#########################################################################
proc buildSnmpPacket {sourceIP destIP sourcePort communityName oid } \
{
	# build SNMPv1 part first...
	set	asn1Header		30
	set snmpVersion		{02 01 00}
	set community		04
	set	NullValue		{05 00}					;# cause we only do gets...

	set	snmpGet			a0
	set snmpRequestID	{02 02 00 00}
	set	snmpErrorIndex	{02 01 00 02 01 00}

	# begin building varbind list
	set	oid				[oid2octet $oid]		;# turn oid into an octet list
	set oidLength		[llength $oid]
	
	set	VarBind			[concat [list 06 [format %02x $oidLength]] $oid]
	
	set VarBindLength	[list 30 [format %02x [expr $oidLength + 4]]]
	set	VarBind			[concat	$VarBindLength $VarBind]

	set	VarBindList		[list 30 [format %02x [expr [llength $VarBind] + 2]]]

	set	VarBind			[concat $snmpRequestID $snmpErrorIndex $VarBindList $VarBind]
	set	VarBind			[concat $snmpGet [format %02x [expr [llength $VarBind] + 2]] $VarBind]

	# Finish by building pdu
	set	communityName	[string tolower $communityName]
	set	pdu				[concat $snmpVersion $community [format %02x [llength $communityName]] \
								$communityName $VarBind]
	
	set pdu				[concat $asn1Header [format %02x [expr [llength $pdu] + 2]] $pdu $NullValue]

	
	# build UDP part next
	set destPort		{00 a1}		;# SNMP port 161
	set	udpLength		[concat {00} [format %02x [expr [llength $pdu] + $::kHeaderLength(udp)]]]
	set	udpChecksum		{00 00}
	set sourcePort		[list [format %02x [expr $sourcePort >> 8]] \
							  [format %02x [expr $sourcePort & 0xff]]]
	set	udp				[concat $sourcePort $destPort $udpLength $udpChecksum $pdu]
	set	udpChecksum		[calculateChecksum $udp]
	set udp				[join [lreplace $udp 6 7 $udpChecksum]]

	set TOS				00		;# includes precedence bits
	set TTL				80
	set protocol		11			;# UDP
	set flags			{00 00}
	set options			{}
	set	ipHeader		[buildIpHeader [host2addr $sourceIP] [host2addr $destIP] \
									    [llength $pdu] $TOS $TTL $protocol $flags $options]

 	return [concat $ipHeader $udp]
}

########################################################################
# Procedure: buildIcmpPacket
#
# This procedure builds the data portion of an icmp/ping packet.
#
# Argument(s):
#	sourceIP		IP address of source, in text format
#	destIP			IP address of destination, in text format
#	dataLength		length of ping
#	icmpEcho		== 1 if this is this an Echo frame, 0 if response
#	icmpSequence	sequence number for this ping, 0 is valid.
#
#########################################################################
proc buildIcmpPacket {sourceIP destIP dataLength icmpEcho icmpSequence} \
{
	set	start				97
	set	max					[expr $start + 22]

 	if {($icmpEcho == 1)} \
	{
		set icmpEcho	08
	} \
	else \
	{
		set icmpEcho	00
	}
	
	set	icmpCode		00
	set	icmpChecksum	{00 00}
	set	icmpId			{01 00}

	set	icmpSequence	[long2octet $icmpSequence]

 	for {set x 0} {$x < $dataLength} {incr x } {
		if {($start > $max)} {set start 97}
 		lappend data [format %02x $start]
		incr start
 	}

	set	icmp			[concat $icmpEcho $icmpCode $icmpChecksum \
								$icmpId $icmpSequence $data]
	set icmpChecksum	[calculateChecksum $icmp]
	set icmp			[join [lreplace $icmp 2 3 $icmpChecksum]]

	set TOS				00		;# includes precedence bits
	set TTL				0x0a
	set protocol		01			;# ICMP
	set flags			{00 00}
	set options			{}
	set	ipHeader		[buildIpHeader [host2addr $sourceIP] [host2addr $destIP] \
									   [expr [llength $icmp] + $::kHeaderLength(ip)] \
									    $TOS $TTL $protocol $flags $options]

	return	[concat $ipHeader $icmp]
}


########################################################################
# Procedure: buildBpduPacket
#
# This procedure builds the data portion of a 802.1d BPDU packet.
#
# Argument(s):
#   rootID      root id in IEEE 802.1d BPDU packet
#   bridgeID    bridge id in IEEE 802.1d BPDU packet
#	
#########################################################################
proc buildBpduPacket { {rootID {00 10 FF E4 1C 0D}} {bridgeID {00 10 FF E4 1C 0D}} {protocolID 0} {versionID 0} {bpduType 0} {bitField 0} \
                  {rootPriority 0} {rootPathCost 0} {bridgePriority 32768} {portID 128} \
                  {messageAge 17920} {maxAge 20} {helloTime 2} {forwardDelay 15} } \
{
    set bpduData {}

    set llcHeader       {42 42 03}                              
    set protocolID      [long2octet $protocolID]              ;# 2 byte
    set versionID       [long2octet $versionID 1]             ;# 1 byte
    set bpduType        [long2octet $bpduType  1]             ;# 1 byte
    set bitField        [long2octet $bitField  1]             ;# 1 byte
    set rootPriority    [long2octet $rootPriority]            ;# 2 byte
    set rootPathCost    [long2octet $rootPathCost 4]          ;# 4 byte
    set bridgePriority  [long2octet $bridgePriority]          ;# 2 byte
    set portID          [long2octet $portID 1]                ;# 1 byte
    set messageAge      [long2octet $messageAge]              ;# 2 byte
    set maxAge          [long2octet $maxAge]                  ;# 2 byte
    set helloTime       [long2octet $helloTime]               ;# 2 byte
    set forwardDelay    [long2octet $forwardDelay]            ;# 2 byte
   
    set otherData       {00 10 54 65 73 74 5f 52 6f}
    set bpduData        [concat $llcHeader $protocolID $versionID $bpduType $bitField $rootPriority \
                                $rootID $rootPathCost $bridgePriority $bridgeID $portID $messageAge \
                                $maxAge $helloTime $forwardDelay $otherData] 
    
    
    set length          [long2octet [llength $bpduData]]

    return              [concat  $length $bpduData ] 
}




