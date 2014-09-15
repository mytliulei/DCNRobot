##################################################################################
# Version 4.10	$Revision: 16 $
# $Author: Debby $
#
# $Workfile: utilWrappers.tcl $ - User parameters
#
#   Copyright © 1997 - 2005 by IXIA
#   All Rights Reserved.
#
#	Revision Log:
#	06-18-2001	HSH	Genesis
#
# Description: Wrappers for utility commands from IxTclHal
#
##################################################################################

########################################################################################
# Procedure: ixIsBgpInstalled
#
# Description: This command checks if Bgp client installed
#
# Returned value : 
#
#               TRUE  : If it is installed.
#				FALSE : If it is NOT installed.
########################################################################################
proc ixIsBgpInstalled {} \
{
	return [ixUtils isBgpInstalled]
}


########################################################################################
# Procedure: ixIsIsisInstalled
#
# Description: This command checks if Isis client installed
# Returned value : 
#
#               TRUE  : If it is installed.
#				FALSE : If it is NOT installed.
########################################################################################
proc ixIsIsisInstalled {} \
{
	return [ixUtils isIsisInstalled]
}

########################################################################################
# Procedure: ixIsRsvpInstalled
#
# Description: This command checks if Rsvp client installed
# Returned value : 
#
#               TRUE  : If it is installed.
#				FALSE : If it is NOT installed.
########################################################################################
proc ixIsRsvpInstalled {} \
{
	return [ixUtils isRsvpInstalled]
}


########################################################################################
# Procedure: ixIsOspfInstalled
#
# Description: This command checks if Ospf client installed
# Returned value : 
#
#               TRUE  : If it is installed.
#				FALSE : If it is NOT installed.
########################################################################################
proc ixIsOspfInstalled {} \
{
	return [ixUtils isOspfInstalled]
}


########################################################################################
# Procedure: ixIsRipInstalled
#
# Description: This command checks if Rip client installed
# Returned value : 
#
#               TRUE  : If it is installed.
#				FALSE : If it is NOT installed.
########################################################################################
proc ixIsRipInstalled {} \
{
	return [ixUtils isRipInstalled]
}

########################################################################################
# Procedure: ixIsArpInstalled
#
# Description: This command checks if Arp client installed
# Returned value : 
#
#               TRUE  : If it is installed.
#				FALSE : If it is NOT installed.
########################################################################################
proc ixIsArpInstalled {} \
{
	return [ixUtils isArpInstalled]
}

########################################################################################
# Procedure: ixIsIgmpInstalled
#
# Description: This command checks if Igmp client installed
# Returned value : 
#
#               TRUE  : If it is installed.
#				FALSE : If it is NOT installed.
########################################################################################
proc ixIsIgmpInstalled {} \
{
	return [ixUtils isIgmpInstalled]
}


########################################################################################
# Procedure: ixIsVpnL2Installed
#
# Description: This command checks if VpnL2 client installed
# Returned value : 
#
#               TRUE  : If it is installed.
#				FALSE : If it is NOT installed.
########################################################################################
proc ixIsVpnL2Installed {} \
{
	return [ixUtils isVpnL2Installed]
}


########################################################################################
# Procedure: ixIsVpnL3Installed
#
# Description: This command checks if VpnL3 client installed
# Returned value : 
#
#               TRUE  : If it is installed.
#				FALSE : If it is NOT installed.
########################################################################################
proc ixIsVpnL3Installed {} \
{
	return [ixUtils isVpnL3Installed]
}


########################################################################################
# Procedure: ixIsMldInstalled
#
# Description: This command checks if MLD client installed
# Returned value : 
#
#               TRUE  : If it is installed.
#				FALSE : If it is NOT installed.
########################################################################################
proc ixIsMldInstalled {} \
{
	return [ixUtils isMldInstalled]
}


########################################################################################
# Procedure: ixIsOspfV3Installed
#
# Description: This command checks if OSPF V3 client installed
# Returned value : 
#
#               TRUE  : If it is installed.
#				FALSE : If it is NOT installed.
########################################################################################
proc ixIsOspfV3Installed {} \
{
	return [ixUtils isOspfV3Installed]
}


########################################################################################
# Procedure: ixIsPimsmInstalled
#
# Description: This command checks if PIM-SM client installed
# Returned value : 
#
#               TRUE  : If it is installed.
#				FALSE : If it is NOT installed.
########################################################################################
proc ixIsPimsmInstalled {} \
{
	return [ixUtils isPimsmInstalled]
}

########################################################################################
# Procedure: ixGetLineUtilization
#
# Description: This command returns the total port rate.
#
# Input:
#   rateType - i.e. typePercentMaxRate or typeFpsRate
#
# Returned value : 
#
#               TRUE  : If it is installed.
#				FALSE : If it is NOT installed.
########################################################################################
proc ixGetLineUtilization {chassis card port {rateType typePercentMaxRate}} \
{
	return [ixUtils getLineUtilization $chassis $card $port $rateType]
}

########################################################################################
# Procedure: ixIsLdpInstalled
#
# Description: This command checks if LDP client installed
# Returned value : 
#
#               TRUE  : If it is installed.
#				FALSE : If it is NOT installed.
########################################################################################
proc ixIsLdpInstalled {} \
{
	return [ixUtils isLdpInstalled]
}

########################################################################################
# Procedure: ixIsRipngInstalled
#
# Description: This command checks if Ripng client installed
# Returned value : 
#
#               TRUE  : If it is installed.
#				FALSE : If it is NOT installed.
########################################################################################
proc ixIsRipngInstalled {} \
{
	return [ixUtils isRipngInstalled]
}


########################################################################################
# Procedure: calculateMaxRate
#
# This proc calculates the max rate in packets per second for this interface
#
# Arguments(s):
#   chassis 
#   card
#   port
#   framesize
#   preambleSize, default == 8   
#
# Returned value : 
#   returns the max rate in PPS
#
########################################################################################
proc calculateMaxRate {chassis card port {framesize 64} {preambleOrAtmEncap 8} } \
{
	return [ixUtils calculateMaxRate $chassis $card $port $framesize $preambleOrAtmEncap ]
}


########################################################################################
# Procedure: calculateGapBytes
#
# This proc calculates the number of bytes that fit in between each packet for this rate
#
# Arguments(s):
#   chassis 
#   card
#   port
#   framerate
#   framesize, default = 64
#   preambleSize, default == 8   
#
# Returned value : 
#   returns the number of bytes that fit in a gap space of a certain rate
#
########################################################################################
proc calculateGapBytes {chassis card port framerate {framesize 64} {preambleSize 8}} \
{
	return [ixUtils calculateGapBytes $chassis $card $port $framerate $framesize $preambleSize]
}


########################################################################################
# Procedure: calculateFPS
#
# This proc calculates the framerate in frames per second given the percent line rate
#
# Arguments(s):
#   chassis 
#   card
#   port
#   percentLineRate = 100
#   framesize, default = 64
#   preambleSize, default == 8   
#
# Returned value : 
#   returns framerate, in PPS
#
########################################################################################
proc calculateFPS {chassis card port {percentLineRate 100} {framesize 64} {preambleOrAtmEncap 8} } \
{
	return [ixUtils calculateFPS $chassis $card $port $percentLineRate $framesize $preambleOrAtmEncap]
}


########################################################################################
# Procedure: calculatePercentMaxRate
#
# This proc calculates percent of line rate for this PPS value
#
# Arguments(s):
#   chassis 
#   card
#   port
#   framerate
#   framesize, default = 64
#   preambleSize, default == 8   
#
# Returned value : 
#   returns the number of bytes that fit in a gap space of a certain rate
#
########################################################################################
proc calculatePercentMaxRate {chassis card port framerate framesize {preambleOrAtmEncap 8}} \
{
	return [ixUtils calculatePercentMaxRate $chassis $card $port $framerate $framesize $preambleOrAtmEncap]
}