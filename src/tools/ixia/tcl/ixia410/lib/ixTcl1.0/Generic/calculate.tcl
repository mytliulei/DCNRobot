##################################################################################
# Version 4.10	$Revision: 82 $
# $Date: 10/18/02 4:28p $
# $Author: Debby $
#
# $Workfile: calculate.tcl $ - Calculations
#
#   Copyright © 1997 - 2005 by IXIA
#   All Rights Reserved.
#
#	Revision Log:
#	12-30-1998	DS
#
# Description: This file contains common procs used for calculating things
#
##################################################################################


########################################################################
# Procedure: mpincr
#
# This command uses mpexpr stuff to overlay the Tcl incr for use w/
# 64-bit numbers.
#
########################################################################
proc mpincr {Value {incrAmt 1}} \
{
    upvar $Value value

    set value [mpexpr $value + $incrAmt]
    return $value
}

########################################################################
# Procedure: calculatePercentLossExact
#
# This command calculates the percent loss based on tx/rx frames -
#    returns *exact* percent loss (not prettied up)
#
# Arguments(s):
#   txFrames    - number of transmitted frames
#   rxFrames    - number of received frames
#
########################################################################
proc calculatePercentLossExact {txFrames rxFrames} \
{
    set loss 0.00

	if [catch {mpexpr double($txFrames-$rxFrames)/$txFrames * 100.} loss] {
        set loss    100.00
    }

    if {$loss < 0.} {
        set loss 0.00
    }

    return $loss
}


########################################################################
# Procedure: calculatePercentLoss
#
# This command calculates the percent loss based on tx/rx frames &
# returns a formatted string of the form "%6.2f"
#
# Arguments(s):
#   txFrames    - number of transmitted frames
#   rxFrames    - number of received frames
#
########################################################################
proc calculatePercentLoss {txFrames rxFrames} \
{
    set loss                [calculatePercentLossExact $txFrames $rxFrames]
	set percentLossFormat   [advancedTestParameter cget -percentLossFormat]
    set loss                [formatNumber $loss $percentLossFormat]

    # check to see if we received more frames than we transmitted
	# Since 32 bit counter (mpexpr) is used here, if we get a 32 bit long number (in binary) whose most 
	# significant bit is 1, it will be recognized as a negtive number. So we use regexp
    # to determinde wheather $txFrames - $rxFrames is a negative number.
    if { [regexp {^-[0-9]+$} [mpexpr $txFrames - $rxFrames]] } {
        set loss  "$loss - NOTE: Received more frames than tx'd"
    }
	#if {[mpexpr $txFrames-$rxFrames] < 0} {
    #    set loss  "$loss - NOTE: Received more frames than tx'd"
    #}

    return $loss
}


########################################################################
# Procedure: calculatePercentThroughput
#
# This command calculates the percent throughput based on tx/rx frames &
# returns a formatted string of the form "%6.2f"
#
# Arguments(s):
#   tputRate    - throughput rate
#   maxRate     - max throughput rate
#
########################################################################
proc calculatePercentThroughput {tputRate maxRate} \
{
    set thruput 0.00

	if [catch {mpexpr ($tputRate*100.)/$maxRate} thruput] {
        set thruput    0.
    }

    return  [format "%6.2f" $thruput]
}


########################################################################
# Procedure: calculateDuration
#
# This command calculates the approximate transmit time
#
# Arguments(s):
#   numTxFrames - total number of frames to transmit
#   frameRate   - transmit rate
#   numFrames   - the 'numFrame' value set to stream config -numFrames
#   loopcount   - the loopcount
#
########################################################################
proc calculateDuration {numTxFrames frameRate {numFrames 1} {loopcount 1}} \
{
    set duration 0

    if {$frameRate > 0} {
        if [catch {mpexpr $numTxFrames/$frameRate} duration] {
            if [catch {mpexpr $numFrames/$frameRate * $loopcount} duration] {
                logMsg "******* WARNING:::: duration is longer than 4294967295 seconds!!!"
                set duration 4294967295
            }
        }
    } else {
        logMsg "****** WARNING:::: frameRate is set to 0, duration set to 0"
    }

    return $duration
}


########################################################################
# Procedure: calculateTotalBursts
#
# This command calculates the number of bursts for the specified duration,
#
# Arguments(s):
#   framerate   - in pps
#   ifg         - in nanoseconds
#   burstsize   - in fps
#   ibg         - inter burst gap, in nanoseconds
#   duration    - duration to calculate number of bursts over
#
# Returns:
#   total number of bursts per this duration
#
########################################################################
proc calculateTotalBursts {framerate ifg burstsize ibg {duration 1}} \
{
    set megabits    1000000.
    set nanoseconds 1000000000.

    if [catch {mpexpr $burstsize*((1./$framerate)* $nanoseconds)} packetTime] {
        errorMsg "****** Error calculating packet time: $packetTime, packet time set to 0"
        set packetTime  0
    }

    if [catch {mpexpr round(($duration*$nanoseconds)/(($packetTime - $ifg) + $ibg))} numBursts] {
        errorMsg "****** Error calculating numBursts: $numBursts, numBursts set to 0"
        set numBursts  0
    }

    return $numBursts
}



########################################################################
# Procedure: calculateAvgLatency
#
# This command calculates the average latency of the latencies in the 
# array
#
# Arguments(s):
#	LatencyArray	- array containing latency values
#
########################################################################
proc calculateAvgLatency {LatencyArray} \
{
	if [info exists LatencyArray] {
		upvar $LatencyArray latencyArray
	} else {
		return 0
	}

	set avgLatency	0

    set count	[llength [array names latencyArray]]
	foreach txMap [lsort [array names latencyArray]] {
        if {$latencyArray($txMap) == 0} {
            mpincr count -1
        }
	}

	if {$count > 0} {
        foreach txMap [lsort [array names latencyArray]] {
            if {$latencyArray($txMap) != 0} {               
                if [catch {mpexpr round($avgLatency + ((double($latencyArray($txMap)))/$count))} temp] {
                    logMsg "******* ERROR::: Port $txMap - $temp"
                } else {
                    set avgLatency  $temp
                }
            }
		}
    }

	return $avgLatency
}


########################################################################
# Procedure: calculateLoopCounterFromTxFrames
#
# This command calculates the loopcounter based on the numFrame parameter
# used for stream.  Note that numFrame is a 24-bit number; if numFrame is
# greater than 24 bits than loopcount must be used in conjuction.
#
# Arguments(s):
#   totalFrames     - total number of frames to transmit
#
# Return:
#   loopcount
#
########################################################################
proc calculateLoopCounterFromTxFrames {totalFrames} \
{
    upvar $totalFrames  numFrames

    set loopcount   1

    if [catch {expr $numFrames & 0xffffff}] {
        # bigger than 32 bit number
        set loopcount   1
        set numLength   [string length $numFrames]
        while {$numLength > 9} {
            set numFrames   [string range $numFrames 0 [expr $numLength - 2]]
            set numLength   [string length $numFrames]
            mpincr loopcount
        }
        mpincr loopcount -1
        set loopcount   [mpexpr round(pow(10,$loopcount))]
    } else {
        set temp   $numFrames
        while {[mpexpr $temp & 0xffffff] != $temp && $loopcount < 10} {
            set temp [mpexpr $numFrames >> 1]
            mpincr loopcount
        }
        set numFrames   [mpexpr $numFrames/$loopcount]
    }

    return $loopcount
}


########################################################################
# Procedure: calculateStreamNumFrames
#
# This command calculates the stream numFrames value. Assumes a max 
# numFrame value of 0xffffffff.
#
# Arguments(s):
#   framerate   - fps
#   duration    - seconds
#
# Return:
#   numFrames; throws an exception if the duration gets modified.
#
########################################################################
proc calculateStreamNumFrames {framerate Duration {maxNumFrames 0xffffffff}} \
{
    upvar $Duration duration

    set numFrames [mpexpr $framerate * $duration]
    if {[isNegative [mpexpr $maxNumFrames - $numFrames]]} {
        set duration   [mpexpr $maxNumFrames/$framerate]

        errorMsg "Error - selected duration $duration is too long - change to max duration of $duration"
        set numFrames [mpexpr $framerate * $duration]

        return -code error -errorinfo $numFrames
    }

    return $numFrames
}


########################################################################
# Procedure: getTransmitTime
#
# This command calculates the total transmit time for the current stream
# configuration from the pulse startTx time - the last frame captured.
# If no frames were captured, it returns the original duration.
#
# Arguments(s):
#   PortArray           - array of ports
#   originalDuration    - original duration of test
#
# Returns:
#   test duration calculated from captured frame or original duration
#   if no frames captured.
#
########################################################################
proc getTransmitTime {PortArray originalDuration {DurationArray ""} {Warnings ""}} \
{
    upvar $PortArray         portArray
    upvar $DurationArray     durationArray
    upvar $Warnings          warnings

    set errorCode   0
    set duration    $originalDuration
    catch {unset durationArray}

    requestStats portArray

    # get the test duration
    foreach txMap [array names portArray] {
        scan $txMap "%d,%d,%d" tx_c tx_l tx_p

        # initialize array
        set durationArray($tx_c,$tx_l,$tx_p)   $originalDuration
    
        if [statList get $tx_c $tx_l $tx_p] {
	        errorMsg "Error getting Tx statistics for [getPortId $tx_c $tx_l $tx_p]"
            set errorCode 1
            continue
        }
        if [catch {mpexpr [statList cget -transmitDuration]/1000000000.} tempDuration] {
            if [catch {getDurationFromCapture portArray $tx_c $tx_l $tx_p $duration} tempDuration] {
                set errorCode 1
                continue
            }

        }

        if {$tempDuration < $originalDuration} {
            set duration $originalDuration
        }

        lappend durationList $duration
        set durationArray($tx_c,$tx_l,$tx_p) $duration
    }

    if {($errorCode == 1) && ($warnings != "")} {
        set warnings "\n\n***** Warning *****\n\
                      Instrumented packets were dropped by the DUT and the rate\n\
                      cannot be reliably measured on one or more ports.\n\n\
                      To reliably measure rate, change the tolerance for dropped\n\
                      packets to zero.\n"
    }

    if [info exists durationList] {
        set duration    [lindex [lnumsort $durationList] 0]
    }
    if [info exists durationArray] {
        debugMsg "getTransmitTime: [array get durationArray]"
    }
 
    return $duration
}


########################################################################
# Procedure: getDurationFromCapture
#
# This command calculates the total transmit time using the capture buffer.
# If no frames were captured, it returns the original duration.
#
# Arguments(s):
#   originalDuration    - original duration of test
#
# Returns:
#   test duration calculated from captured frame or original duration
#   if no frames captured.
#
########################################################################
proc getDurationFromCapture {PortArray tx_c tx_l tx_p  originalDuration} \
{
    upvar $PortArray         portArray

    set maxDuration 0
    foreach rxMap $portArray($tx_c,$tx_l,$tx_p) {
        scan $rxMap "%d %d %d" rx_c rx_l rx_p

        if [capture get $rx_c $rx_l $rx_p] {
            set errorMessage "Error getting capture data on [getPortId $rx_c $rx_l $rx_p]"
            set errorCode 1
            continue
        }
        set numCapPackets   [capture cget -nPackets]

        # get first packet
        if [captureBuffer get $rx_c $rx_l $rx_p] {
            set errorMessage "Error getting capture buffer for [getPortId $rx_c $rx_l $rx_p]"
            set errorCode 1
            continue
        }

        if [captureBuffer getframe 1] {
            set errorMessage "Error getting frame from capture buffer for [getPortId $rx_c $rx_l $rx_p]"
            set errorCode 1
            continue
        }
        set firstTimeStamp  [captureBuffer cget -fir]
        debugMsg "firstTimeStamp:$firstTimeStamp"
        debugMsg "ixgFirstTimeStamp:$::ixgFirstTimeStamp"

        if [captureBuffer get $rx_c $rx_l $rx_p $numCapPackets $numCapPackets] {
            set errorMessage "Error getting capture buffer for [getPortId $rx_c $rx_l $rx_p]"
            set errorCode 1
            continue
        }
        if [captureBuffer getframe 1] {
            set errorMessage "Error getting frame from capture buffer for [getPortId $rx_c $rx_l $rx_p]"
            set errorCode 1
            continue
        }
        set duration    [mpexpr ([captureBuffer cget -timestamp] - $firstTimeStamp)/1000000000.]
        debugMsg "duration:$duration"

        if {$duration < $originalDuration || $numCapPackets < [mpexpr $originalDuration * 2]} {
            set duration $originalDuration
        }
        # get the max transmit time for TX ports that have more than one RX ports
        if {$duration > $maxDuration} {
            set maxDuration    $duration
        }
    }

    if {$errorCode == 1} {
		return -code error -errorinfo $errorMessage
    } else {
        return $maxDuration
    }
}
 

########################################################################
# Procedure: min
#
# This command calculates the minimum value
#
# Arguments(s):
########################################################################
proc min {x y} \
{
    return [mpexpr ($x < $y) ? $x : $y ]
}


########################################################################
# Procedure: max
#
# This command calculates the maximum value
#
# Arguments(s):
########################################################################
proc max {x y} \
{
    return [mpexpr ($x > $y) ? $x : $y ]
}


########################################################################
# Procedure: maxArray
#
# This command calculates the maximum value of an array.
#
# Arguments(s):
########################################################################
proc maxArray {NumArray} \
{
	upvar $NumArray numArray

	set maxNum 0
	for {set index 0} {$index < [llength [array names numArray]]} {incr index} {
		set item [lindex [lnumsort [array names numArray]] $index]
		set maxNum [max $maxNum $numArray($item)]
	}

	return $maxNum
}
