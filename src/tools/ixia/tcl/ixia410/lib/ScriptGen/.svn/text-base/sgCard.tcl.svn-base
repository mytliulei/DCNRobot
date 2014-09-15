#############################################################################################
# Version 4.10	$Revision: 4 $
# $Date: 9/30/02 1:13p $
# $Author: Mgithens $
#
# $Workfile: sgCard.tcl $ - Utilities for scriptgen
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
# Procedure: getCardScript
#
# This command generates card commands
# Arguments(s):
# chassis : chassis Id
# card    : card Id
# port    : port Id
# Returned Result:
########################################################################


proc scriptGen::getCardScript { chassis card port } \
{
    set retCode 0

# "card get" has been called in ixSgMain before calling this proc so I don't call it again
# Configurable card properties are only available on reducedMII and unframedBert.
    set cardParamList {}  
    if {[card cget -type] == $::card10100RMii} {
        set cardParamList [list clockTxRisingEdge clockRxRisingEdge]
    } 
    if {[port isValidFeature $chassis $card $port $::portFeatureBertUnframed]} {
        set cardParamList [list clockSelect]
    }

    if {[port isValidFeature $chassis $card $port $::portFeatureTxFrequencyDeviation]} {
        set cardParamList [list txFrequencyDeviation]
    } 

    if {[llength $cardParamList] != 0} {
        partiallyGenerateCommand card $cardParamList
        sgPuts {card set $chassis $card}
        sgPuts {card write $chassis $card}
    }


    return $retCode
}