##################################################################################
# Version 4.10	$Revision: 18 $
# $Date: 9/30/02 3:52p $
# $Author: Mgithens $
#
# $Workfile: conversions.tcl $
#
# Copyright © 1997 - 2005 by IXIA
# All Rights Reserved.
#
# Description: This file contains some utility procs for running the cable modem
#              and ATP tests.
#
# Revision Log:
#
# Date		    Author				Comments
# -----------	-------------------	--------------------------------------------
# 2000/05/01	DS	                Genesis (for cable modem testing)
# 2000/10/02	D. Heins-Gelder		Moved rate converters to Generic/converstions.tcl
#
##################################################################################



########################################################################################
# getPercentMaxRate
#
# Description:  Helper procedure which derives the percentMaxRate based on the
#               user selected rate type (ie: percentMaxMate, kbps or fps)
#
# Input:        chassis card port
#               framesize       : 
#               rateType        : 
#               rate            :
#               loss            : default is NULL
#
# Output:       retCode         : 0 if invalid chassis-card-port, else
#                                 percentMaxRate
#
########################################################################################
proc getPercentMaxRate {chassis card port framesize rateType rate {preambleSize 8}} \
{
    set percentMaxRate  0

    if [port get $chassis $card $port] {
        errorMsg "Error getting $chassis $card $port"
    } else {

        switch $rateType {
            percentMaxRate {
                set percentMaxRate  $rate
            }
            kbpsRate {
                set percentMaxRate [calculatePercentMaxRate $chassis $card $port [mpexpr $rate*1000./($framesize * 8.)] $framesize $preambleSize]
            }
            fpsRate {
                set percentMaxRate [calculatePercentMaxRate $chassis $card $port $rate $framesize $preambleSize]
            }
            default {
                set percentMaxRate  0.
            }
        }
    }
    
    return [format %.6f $percentMaxRate]
}


########################################################################################
########################################################################################
#           Rate converters
#           Note - these things live in the cablemodem.tcl file because they are really
#                  only applicable to cablemodems.  Also, note that the getMaxFPS
#                  proc will probably fall apart w/PoS implementations.
########################################################################################
########################################################################################
#
#
#     Conversion formulae implemented in code (checked by David Selenkow 5/4/2000)
#
# Given rate=%maxRate, then:                                        as found in:
#   percentMaxRate  = rate                                      convertPercentMaxRate
#   kbps            = (maxFPS*(rate/100)*framesize*8) / 1000    convertKbpsRate
#   fps             = (rate/100)*maxFPS                         convertFpsRate
#
# Given rate = kpbs, then:     
#   percentMaxRate  = ((rate*1000)/(framesize*8*maxFPS)) * 100  convertPercentMaxRate 
#   kpbs            = rate                                      convertKpbsRate
#   fps             = (rate*1000)/(framesize*8)                 convertFpsRate
#
# Given rate=fps, then          
#   percentMaxRate  = (rate/maxFPS)*100                         convertPercentMaxRate
#   kbps            = (rate*framesize*8) / 1000                 convertKbpsRate
#   fps             = rate                                      convertFpsRate

########################################################################################



########################################################################################
# Procedure: getMaxFPS
#
# Description: Get the max fps rate based on speed/framesize, assuming a 96 bit minimum
#              gap (802.3)
#
########################################################################################
proc getMaxFPS {speed framesize {preambleSize 8}} \
{
   set expr    [unixCludgeGetExpr]

   set minimumGap            96    ;# bits 
    if [catch {$expr round((double($speed) * 1000000.) / (double($minimumGap) + (($preambleSize + $framesize)*8.)))} maxFps] {
        set maxFps 0
    }

    return $maxFps
}


########################################################################################
# Procedure: convertPercentMaxRate
#
# Description: Converts to the % rate based on speed/framesize, assuming a 96 bit
#              minimum gap (802.3)
#
########################################################################################
proc convertPercentMaxRate {framesize rateType rate speed {preambleSize 8}} \
{
    set expr    [unixCludgeGetExpr]

    set maxRate [getMaxFPS $speed $framesize $preambleSize]

    if {[isValidPartialFloat $framesize] && [isValidPartialFloat $rate] && [isValidPartialFloat $speed] && \
            [isValidPartialFloat $preambleSize]} {
        switch $rateType {
            percentMaxRate {
                set percentMaxRate  $rate
            }
            kbpsRate {
                if [catch {$expr ($rate*1000./($framesize * 8. * $maxRate))*100.} percentMaxRate] {
                    set percentMaxRate 1.0
                }
            }
            fpsRate {
                if [catch {$expr (($rate*100.)/$maxRate)} percentMaxRate] {
                    set percentMaxRate 1.0
                }
            }
            default {
                set percentMaxRate 1.0
            }
        }
    } else {
        set percentMaxRate 1.0
    }
    return [format %.6f $percentMaxRate]
}


########################################################################################
# Procedure: convertKbpsRate
#
# Description: Converts to the kbps rate based on speed/framesize, assuming a 96 bit
#              minimum gap (802.3)
#
########################################################################################
proc convertKbpsRate {framesize rateType rate speed {preambleSize 8}} \
{
    set expr    [unixCludgeGetExpr]

    set kbpsRate 1.0

    if {[isValidPartialFloat $framesize] && [isValidPartialFloat $rate] && [isValidPartialFloat $speed] && \
            [isValidPartialFloat $preambleSize]} {
        switch $rateType {
            percentMaxRate {
                set maxRate [getMaxFPS $speed $framesize $preambleSize]
                set kbpsRate [$expr (($maxRate*($rate/100.)) * $framesize * 8.) / 1000.]
            }
            kbpsRate {
                set kbpsRate $rate
            }
            fpsRate {
                set kbpsRate [$expr ($rate * $framesize * 8.)/1000.]
            }
        }
    }
    return [format %.6f $kbpsRate]
}


########################################################################################
# Procedure: convertFpsRate
#
# Description: Converts to the max fps rate based on speed/framesize, assuming a 96 bit
#              minimum gap (802.3)
#
########################################################################################
proc convertFpsRate {framesize rateType rate speed {preambleSize 8}} \
{
    set expr    [unixCludgeGetExpr]

    set fpsRate 1.0

    if {[isValidPartialFloat $framesize] && [isValidPartialFloat $rate] && [isValidPartialFloat $speed] && \
            [isValidPartialFloat $preambleSize]} {
        switch $rateType {
            percentMaxRate {
                set maxRate [getMaxFPS $speed $framesize $preambleSize]
                if {[catch {$expr ($rate/100.)*$maxRate} fpsRate]} {
                    set fpsRate 1.0
                }
            }
            kbpsRate {
                if {[catch {$expr ($rate/($framesize * 8.))*1000.} fpsRate]} {
                    set fpsRate 1.0
                }
            }
            fpsRate {
                set fpsRate $rate
            }
        }
    }
    return [format %.6f $fpsRate]
}


########################################################################
# Procedure: generateFullList
#
# Helper proc to generate the full list for the burstsize
#
########################################################################
proc generateFullList { originalList {burstsize 10} } \
{
    set maxFramesize  0
    foreach item $originalList {
        for {set i 1} { $i <= 10} {incr i} {
            lappend fullFrameSizeList $item
        }
    }

    return $fullFrameSizeList
}


