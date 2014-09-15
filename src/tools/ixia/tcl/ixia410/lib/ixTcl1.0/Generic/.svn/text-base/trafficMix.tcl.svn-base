########################################################################
# Version 4.10	$Revision: 24 $
# $Author: Mgithens $
#
# $Workfile: trafficMix.tcl $
#
#   Copyright © 1997 - 2005 by IXIA
#   All Rights Reserved.
#
#	Revision Log:
#	09-15-1999	DS
#
# Description: This file contains special procs to set up multiple
#              streams w/one aggregate rate
#
########################################################################


########################################################################
# Procedure: calcTrafficMix
#
# This command calculates the relative percents (number of frames) for
# a number of streams based on one aggregate percent utilization.
#
# Arguments(s):
#   StreamArray         - array indexed by streamID, that
#                         contains the framesize & percentFrameRate
#                         for that stream
#   BurstArray          - calc'd burst size for each stream
#   percentUtilization  - desired aggregate percent utilization
#
# Return:
#
########################################################################
proc calcTrafficMix {StreamArray BurstArray {percentUtilization 100}} \
{
    set retCode 0

    upvar $StreamArray  streamArray
    upvar $BurstArray burstArray

    set maxFrameSize    0
    foreach streamID [array names streamArray] {
        scan $streamArray($streamID) "%d %d" fs percent
        lappend frameSizeList   $fs
        if {$fs > $maxFrameSize} {
            set maxFrameSize    $fs
            set maxFsIndex      $streamID
        }
    }

    foreach streamID [array names streamArray] {
        scan $streamArray($streamID) "%d %d" fs percent

        set burstArray($streamID)  [expr ([lindex $streamArray($maxFsIndex) 0]/double([lindex $streamArray($maxFsIndex) end]))/$fs*double($percent)]
    }

    debugMsg "calcTrafficMix: burstArray:[array get burstArray]"

    return $retCode
}


########################################################################
# Procedure: calcAggregateDataRate
#
# This command calculates the ifgs for an aggregrate data rate, assuming
# there is one packet per stream/one packet per fs.
#
# Arguments(s):
#
#   frameSizeList   - list of framesizes to use in aggregrate calculation
#   bitRate         - desired aggregrate bit rate
#   speed           - in mbps, ie., 100, 10 or 1000 mbps
#
# Return:
#   ifg, in nanoseconds OR 0 if bit rate is greater than achievable wire
#   speed or error calculating
#
########################################################################
proc calcAggregateDataRate {frameSizeList bitRate speed {preambleSize 8}} \
{
    return [calcAggregateBitRate $frameSizeList $bitRate $speed false false $preambleSize]
}


########################################################################
# Procedure: calcAggregateFrameRate
#
# This command calculates the ifgs for an aggregrate frame rate, assuming
# there is one packet per stream/one packet per fs.
#
# Arguments(s):
#
#   frameSizeList   - list of framesizes to use in aggregrate calculation
#   bitRate         - desired aggregrate bit rate
#   speed           - in mbps, ie., 100, 10 or 1000 mbps
#
# Return:
#   ifg, in nanoseconds OR 0 if bit rate is greater than achievable wire
#   speed or error calculating
#
########################################################################
proc calcAggregateFrameRate {frameSizeList bitRate speed {preambleSize 8}} \
{
    return [calcAggregateBitRate $frameSizeList $bitRate $speed true false $preambleSize]
}


########################################################################
# Procedure: calcAggregateTotalRate
#
# This command calculates the ifgs for an aggregrate total bit rate, assuming
# there is one packet per stream/one packet per fs.
#
# Arguments(s):
#
#   frameSizeList   - list of framesizes to use in aggregrate calculation
#   bitRate         - desired aggregrate bit rate
#   speed           - in mbps, ie., 100, 10 or 1000 mbps
#
# Return:
#   ifg, in nanoseconds OR 0 if bit rate is greater than achievable wire
#   speed or error calculating
#
########################################################################
proc calcAggregateTotalRate {frameSizeList bitRate speed {preambleSize 8}} \
{
    return [calcAggregateBitRate $frameSizeList $bitRate $speed true true $preambleSize]
}


########################################################################
# Procedure: calcAggregateBitRate
#
# This command calculates the ifgs for an aggregrate bit rate, assuming
# there is one packet per stream/one packet per fs.
#
# Arguments(s):
#
#   frameSizeList   - list of framesizes to use in aggregrate calculation
#   bitRate         - desired aggregrate bit rate
#   speed           - in mbps, ie., 100, 10 or 1000 mbps
#
# Return:
#   ifg, in nanoseconds OR 0 if bit rate is greater than achievable wire
#   speed or error calculating
#
########################################################################
proc calcAggregateBitRate {frameSizeList bitRate speed {includeCRC true} {includePreamble true} {preambleSize 8}} \
{
    set nBits   [calcTotalBits $frameSizeList $includeCRC $includePreamble $preambleSize]
    if [catch {mpexpr double([llength $frameSizeList] * $bitRate)/$nBits} pps] {
        logMsg "calcAggregateBitRate: Error converting bit rate to PPS"
        return 0
    }
    return [calcAggregatePPS $frameSizeList $pps $speed $preambleSize]
}


########################################################################
# Procedure: calcAggregatePPS
#
# This command calculates the ifgs for an aggregrate pps rate, assuming
# there is one packet per stream/one packet per fs.
#
# Arguments(s):
#
#   frameSizeList   - list of framesizes to use in aggregrate calculation
#   pps             - desired aggregrate pps rate
#   speed           - in mbps, ie., 100, 10 or 1000 mbps
#
# Return:
#   ifg, in nanoseconds OR 0 if pps rate is greater than achievable wire
#   speed or error calculating
#
########################################################################
proc calcAggregatePPS {frameSizeList pps speed {preambleSize 8}} \
{
    set ifgNS 0

    set nBits       [calcTotalBits $frameSizeList true true $preambleSize]
    set speed       [mpexpr $speed*1000000.]

    if [catch {mpexpr double($nBits)/$speed} dataTime] {
        logMsg "calcAggregratePPS: Error calculating data time."
        return $ifgNS
    }

    if [catch {mpexpr ((1./$pps) - ($dataTime/[llength $frameSizeList]))/0.000000001} ifgNS] {
        logMsg "calcAggregratePPS: Error calculating ifg."
        return $ifgNS
    }

    if {$ifgNS < 0} {
        set ifgNS   0
    }

    return [mpexpr round($ifgNS)]
}


########################################################################
# Procedure: calcTotalBits
#
# This command calculates the total bits, including preamble, of the
# frames in the frameSizeList
#
# Arguments(s):
#
#   frameSizeList   - list of framesizes to use in aggregrate calculation
#
# Return:
#   0 if pps rate is greater than achievable wire speed.
#
########################################################################
proc calcTotalBits {frameSizeList {includeCRC true} {includePreamble true} {preambleSize 8}} \
{
    set nBits   0

    if {$includePreamble != "true"} {
        set preambleSize    0
    }

    set nPackets    [llength $frameSizeList]
    if {$nPackets > 0} {
        set totalFS 0
        foreach fs $frameSizeList {
            if {$includeCRC == "true"} {
                incr totalFS    $fs
            } else {
                incr totalFS    [expr $fs - 4]
            }
        }
        set nBits       [mpexpr ($totalFS + ($preambleSize * $nPackets)) * 8]
    }

    return $nBits
}



########################################################################
# Procedure: calcTotalStreamTime
#
# This command calculates the total time the aggregate streams will take
# if using the giving duration & percentUtilization & returns an array,
# Loopcount, that contains a loopcount number for each transmit port.
#
# Arguments(s):
#   TxRxArray           - array (ie., one2oneArray) or list of ports to
#                         transmit on
#   StreamArray         - array indexed by streamID, that
#                         contains the framesize & percentFrameRate
#                         for that stream
#   BurstArray          - calc'd burst size for each stream
#   Loopcount           - calc'd loopcount for each tx port
#   duration            - tx time
#   percentUtilization  - desired aggregate percent utilization
#
# Return:
#
########################################################################
proc calcTotalStreamTime {TxRxArray StreamArray BurstArray Loopcount duration {percentUtilization 100} {numRxAddresses 1} {preambleSize 8}} \
{
    set retCode 0

    upvar $TxRxArray    txRxArray
    upvar $StreamArray  streamArray
    upvar $BurstArray   burstArray
    upvar $Loopcount    loopcount

    set txList  [getTxPorts txRxArray]

    foreach txMap $txList {
        scan $txMap "%d %d %d" tx_c tx_l tx_p

        if [port get $tx_c $tx_l $tx_p] {
            logMsg "calcTotalStreamTime: Error getting port [getPortId $tx_c $tx_l $tx_p]"
            set retCode 1
            continue
        }
        set speed   [port cget -speed]

        set totalTime   0
        foreach streamID [array names streamArray] {
            scan $streamArray($streamID) "%d %d" fs percent

            set rate        [mpexpr ($percentUtilization * [calculateMaxRate $tx_c $tx_l $tx_p $fs $preambleSize])/100.]
            set gapInBytes  [calculateGapBytes $tx_c $tx_l $tx_p $rate $fs]

            set currTime    [mpexpr ((($fs + $preambleSize + $gapInBytes) * 8.) * $burstArray($streamID) * $numRxAddresses)/($speed*1000000.)]
            set totalTime   [mpexpr $totalTime + $currTime]
        }
        set loopcount($tx_c,$tx_l,$tx_p)    [mpexpr round($duration / $totalTime)]
        debugMsg "calcTotalStreamTime: totalTime:$totalTime, loopcount:$loopcount($tx_c,$tx_l,$tx_p)"
    }

    return $retCode
}
