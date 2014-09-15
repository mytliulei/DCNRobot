############################################################################################
#
#   Copyright © 1997 - 2004 by IXIA.
#   All Rights Reserved.
#
# Description: 
#   Implement utilities for printing result summary. 
#
#   NOTE:   To add a new metric to the summary table, simply add the metric name, printable
#           title, and result array name to the array resultParameterArray (defined below).
#           No other changes are required.
#			  
#############################################################################################

namespace eval ospfSuite {

    variable resultArray

    variable resultArrays
    set resultArrays                    [list avgConvergenceArray totalPacketLossArray txTputPercent txTputFps]

    variable resultParameterArray    
    #                                   Metric                      Title                               Array                
    array set resultParameterArray  {   avgAdvertiseConvergenceTime {avgAdvertiseConvergenceTime(ns)    avgAdvertiseConvergenceTimeArray    }
                                        avgWithdrawConvergenceTime  {avgWithdrawConvergenceTime(ns)     avgWithdrawConvergenceTimeArray     }
                                        totalTxPackets              {totalTxPackets                     totalTxPacketsArray                 }
                                        totalRxPackets              {totalRxPackets                     totalRxPacketsArray                 }
                                        totalPacketLoss             {totalPacketLoss(%)                 totalPacketLossArray                }
                                        txTputFps                   {txTput(fps)                        txTputFps                           }
                                        txTputPercent               {txTput(%)                          txTputPercent                       }
                                    }
}


########################################################################################
# Procedure:    ospfSuite::writeResultsFile
#
# Description:  Print results to CSV and Results files.
#
# Argument(s):
#
# Results :     TCL_OK or TCL_ERROR
#   
########################################################################################
proc ospfSuite::writeResultsFile {} \
{
    variable resultArray
    variable resultParameterArray

    set retCode $::TCL_OK

    set fileID [openResultFile]

    set resultFid [openMyFile [results cget -resultFile] a results]
    if {$resultFid == "stdout"} {
        logMsg "***** WARNING:  Cannot open result file.  The result will be printed to stdout"
    }

    writeTextResultsFileHeader $resultFid
    writeTextResultsFilePortConfig $resultFid 
    printResults $resultFid resultArray resultParameterArray
    closeMyFile $resultFid
    
    return $retCode
}


##################################################################################
# Procedure:   ospfSuite::printSummaryResults
#
# Description: Copy results to result file.
#
# Arguments:   resultArray:            Array results
#              resultParameterArray:   Array print parameters for results
#
# Results:     TCL_OK or TCL_ERROR
#
##################################################################################
proc ospfSuite::printResults {fileId ResultArray ResultParameterArray} \
{
    upvar $ResultArray resultArray
    upvar $ResultParameterArray resultParameterArray

    set retCode $::TCL_ERROR
    if {![catch {fconfigure $fileId}]} {

        set header "\nOSPF Convergence Statistics By Framesize\n"
        append header [stringRepeat "-" [string length $header]] "\n"
        puts $fileId $header
        
        set rowTitles		[list trial]
        set rowSubTitles	[list metric]

        puts $fileId [ospfSuite::buildSummaryTable resultArray resultParameterArray $rowTitles $rowSubTitles]

        set retCode $::TCL_OK
    }
    return $retCode
}


##################################################################################
# Procedure:   ospfSuite::buildSummaryTable
#
# Description: Given a trial, list of frame sizes and a list of row titles, builds a tabular 
#              summary of the results generated for that trial/iteration ordered by frames sizes.
#
#              Field sizes are calculated dynamically based upon the size of the largest field/title.
#
#              The list of row titles allows the users to specifying dynamically which row headings will be
#              inserted into the table.
#
# Input:       trial:		            trial #
#              frameSizeList:	        list of frame sizes to report on.
#              resultArray:             Array of results
#              resultParameterArray:    Array of parameters specifying how to print summary results.
#              titleItems:	            list of row titles: portId, & trial are allowed.
#                   For Example:
#
#					trial:		"Trial: n"
#								
#       			Creates:
#					"Trial: 1 Thruput(fps)"
#
#               subTitleItems:	        list of row sub-titles: metric title
#
# Output:       summary string
#
##################################################################################
proc ospfSuite::buildSummaryTable {ResultArray ResultParameterArray titleItems subTitleItems args} \
{
    upvar $ResultArray          resultArray
    upvar $ResultParameterArray resultParameterArray

    results config -frameSizeList [ospfSuite cget -framesizeList]

    set output ""

    set frameSizes		[results cget -frameSizeList]
    set frameSizesSize	[llength $frameSizes]

    set reportWidth [results cget -reportWidth]
    set fieldSize [getMaxColumnSize frameSize resultParameterArray]
    set numFrameSizeColumns \
            [expr $reportWidth/($fieldSize + 1)]

    set numFrameSizeRows \
            [expr round(ceil(double($frameSizesSize)/double($numFrameSizeColumns)))]  

    set frameSizeList $frameSizes
    for {set trial 1} {$trial <= [ospfSuite cget -numtrials]} {incr trial} {

        set validItems [list portId trial]
        foreach item $validItems {
            if {![info exists $item]} {
                set $item ""
            }
        }

        set firstColumn 0

        for {set numRow 0} {$numRow < $numFrameSizeRows} {incr numRow} {

            set lastColumn [expr $firstColumn + ($numFrameSizeColumns - 1)]
            set currFrameSizeList \
                    [lrange $frameSizes $firstColumn $lastColumn]
            incr firstColumn $numFrameSizeColumns

            results config -frameSizeList $currFrameSizeList
            append output "\n" [buildSummaryTitle frameSize resultParameterArray $titleItems $subTitleItems] "\n"
            results config -frameSizeList $frameSizes

            # Calculate field sizes.
            set maximumRowTitleSize 0
            foreach item $subTitleItems {
                incr maximumRowTitleSize [getMaxColumnSize $item resultParameterArray]
                incr maximumRowTitleSize
            }
            set maximumColumnSize       [getMaxColumnSize frameSize resultParameterArray]
            
            # Build Row Title with title portion of row heading.
            set items ""
            foreach i $titleItems {
                set items [lappend items $i [set ${i}]]
            }
            set rowTitle [buildRowTitle $items resultParameterArray]
            set rowTitleSize [string length $rowTitle]
            
            set metricList [getMetricList resultParameterArray]
            
            # Build a table of summary values.
            foreach metricItem $metricList {
            
                set metric [stringSplitToTitle [getMetricTitle $metricItem resultParameterArray]]
            
                # Build Sub-Title portion of row heading.
                set items ""
                foreach i $subTitleItems {
                    set items [lappend items $i [set ${i}]]
                }
                set metricTitle [buildRowTitle $items resultParameterArray]
            
                # Build Row Detail.
                set rowDetail \
                        [buildSummaryDetail \
                        $trial $currFrameSizeList resultArray $metricItem $maximumColumnSize ]
                
                # Output row
                append output \
                        [format "%-$rowTitleSize\s%-$maximumRowTitleSize\s%s" \
                        $rowTitle $metricTitle $rowDetail]\n
            
                set rowTitle ""
            }
        }
        append output "\n"

    }

    return $output
} 

##################################################################################
# Procedure:    buildSummaryTitle
#
# Description:  Given a sub-title type, return a summary sub-title.  Takes into
#					account the row detail size.
#
# Input:        type:			Type of summary row: frameSize
#               resultParameterArray: Array of summary parameters.
#               titleItems:		List of items that make up the row title: available
#								options are: trial portId
#               subtitleItems:	List of items that make up the row title: available
#								options are: metric 
#
# Output:       sub-title string
#
##################################################################################
proc ospfSuite::buildSummaryTitle {type ResultParameterArray titleItems subTitleItems} \
{
    upvar $ResultParameterArray resultParameterArray
    set output ""

    # Initialize row title items & account for the size of the row title.
    set items ""
    foreach item $titleItems {
        switch $item {
            trial {
                set trial [results::getNumTestTrials]
                set items [lappend items trial $trial]
            }
            portId {
                set portId ""
                set items [lappend items portId $portId]
            }
        }
    }

    set rowTitle [buildRowTitle $items resultParameterArray]
    set rowTitleSize [string length $rowTitle]

    # Account for sub-title in row size.
    foreach item $subTitleItems {
        set increment 0
        switch $item {
            metric {
                set increment [getMaxColumnSize metric resultParameterArray]
                incr increment
            }
        }
        incr rowTitleSize $increment
    }

    # Build overall title with: title, sub-titles and column titles.
    switch $type {

        frameSize {
            set length [expr $rowTitleSize + 1]
            append output \
                    [format "%-$length\s" "Frame Size"]

            set maximumColumnSize [getMaxColumnSize frameSize resultParameterArray]
            foreach frameSize [results cget -frameSizeList] {
                append output [format "%$maximumColumnSize\s " $frameSize]
            }
        }
    }
    return $output
}



##################################################################################
# Procedure:    buildRowTitle
#
# Description:  Given a list of row titles, builds a tabular summary of the 
#					results generated for that trial/iteration for all frames
#					sizes tested.
#
#					The list of row titles allows the users to specify
#					dynamically which row headings will be inserted into the
#					title.
#
# Input:        items:		    list of row titles: portId, metric & trial.
#								are allowed:
#								
#								portId:		"1.1.1 PortName"
#								trial:		"Trial: n"
#								
#								For example:
#								"Trial: 1 Iteration: 1 AvgRate(bps)"
#								"1.1.1 MyPort Trial: 1 Iteration: 1 AvgRate(bps)"
#								"AvgRate(bps)"
#               parameterArray: Array of information required to print summary
#
# Output:       row title string
#
##################################################################################
proc ospfSuite::buildRowTitle {items ParameterArray} \
{
    upvar $ParameterArray parameterArray

    set validItems [list portId direction metric trial]
    foreach item $validItems {
        set $item ""
        set $item\Size 0
    }

    foreach {item value} $items {
        switch $item {
            portId {
                set $item\Size [getMaximumColumnSize portId parameterArray]
                incr $item\Size
                append ${item} $value
            }
            metric {
                set $item\Size [getMaxColumnSize frameSize parameterArray]
                incr $item\Size
                append ${item} $value
            }
            trial {
                append $item "[stringToUpper $item 0 0]: "
                set $item\Size [string length [set $item]]
                incr $item\Size [string length [ospfSuite cget -numtrials]]
                incr $item\Size
                append ${item} $value
            }
        }
    }

    set output ""
    foreach {item value} $items {
        append output [format "%-[set $item\Size]\s" [set $item]]
    }

    return $output
}


##################################################################################
# Procedure:    buildSummaryDetail
#
# Description:  Given a list of row titles, builds a tabular summary of the 
#					results generated for that trial/iteration for all frames
#					sizes tested.
#
#					The list of row titles allows the users to specify
#					dynamically which row headings will be inserted into the
#					title.
#
# Input:        trial:			trial #
#               frameSizes:		list of frame sizes to report on.
#               ResultArray:    Array of result values
#               metric:			metric
#               fieldSize:		size of field, maximum
#
# Output:       row detail string
#
##################################################################################
proc ospfSuite::buildSummaryDetail {trial frameSizes ResultArray metric columnSize} \
{
    upvar $ResultArray resultArray

    set output ""

    # Build Row Detail.
    incr columnSize
    foreach frameSize $frameSizes {

        set key $trial,$frameSize,$metric
        if [catch {set value $resultArray($key)}] {
            set value 0
        }
        if {[string is integer $value]} {
            append output [format "%$columnSize\s" $value]
        } elseif {[string is double $value]} {
            append output [format "%$columnSize.2f" $value]
        } else {
            append output [format "%$columnSize\s" $value]
        }
    }
    return $output
}


##################################################################################
# Procedure:    getMaxRowTitleSize
#
# Description:  Searches the result parameter array for the field with the 
#               largest metric title size.
#
# Input:        ResultArray:    Array of result values
#
# Output:       Size of largest metric title
#
##################################################################################
proc ospfSuite::getMaxRowTitleSize {ResultParameterArray} \
{
    upvar $ResultParameterArray resultParameterArray

    set maximum 0

    foreach i [getMetricList resultParameterArray] {

        set titleLength [string length [stringSplitToTitle [getMetricTitle $i resultParameterArray]]]
        if {$maximum < $titleLength} {
            set maximum $titleLength
        }
    }

    return $maximum
}

##################################################################################
# Procedure:    getMaxMetricSize
#
# Description:  Searches the result parameter array for the largest metric field.
#
# Input:        ResultArray:    Array of result values
#
# Output:       Size of largest metric column
#
##################################################################################
proc ospfSuite::getMaxMetricSize {} \
{
    variable resultArray

    set maximum 0

    foreach {key value} [array get resultArray] {
        set metricLength [string length $value]
        if {$maximum < $metricLength} {
            set maximum $metricLength
        }
    }

    # Add 3 for '.00'
    return [expr $maximum + 3]
}

##################################################################################
# Procedure:    getMetricList
#
# Description:  Returns a list of the metrics reported in the summary.
#
# Input:        ResultParameterArray
#
# Output:       list of metric names
#
##################################################################################
proc ospfSuite::getMetricList {ResultParameterArray} \
{
    upvar $ResultParameterArray resultParameterArray
    return [lsort [array names resultParameterArray]]
}

##################################################################################
# Procedure:    getResultParameter
#
# Description:  Performs a look-up of the result parameter array.
#
# Input:        type:   field to lookup: title, arrayName
#               metric: metric name
#               resultParameterArray:   array of parameter settings
#
# Output:       lookup value
#
##################################################################################
proc ospfSuite::getResultParameter {type metric ResultParameterArray} \
{
    upvar $ResultParameterArray resultParameterArray

    set retValue ""

    if {[info exists resultParameterArray($metric)]} {
        scan $resultParameterArray($metric) "%s %s" title arrayName 
        switch $type {
            title {
                set retValue $title 
            }
            arrayName {
                set retValue $arrayName
            }
        }
    }
    return $retValue
}

##################################################################################
# Procedure:    getMetricTitle
#
# Description:  Given a metric, return the metric title string.
#
# Input:        metric: metric name
#               resultParameterArray:   array of parameter settings
#
# Output:       lookup value
#
##################################################################################
proc ospfSuite::getMetricTitle {metric ResultParameterArray} \
{
    upvar $ResultParameterArray resultParameterArray
    set retValue [getResultParameter title $metric resultParameterArray]
    return $retValue
}

##################################################################################
# Procedure:    getArrayName
#
# Description:  Given a metric, return the name of the result array
#
# Input:        metric: metric name
#               resultParameterArray:   array of parameter settings
#
# Output:       lookup value
#
##################################################################################
proc ospfSuite::getArrayName {metric ResultParameterArray} \
{
    upvar $ResultParameterArray resultParameterArray
    set retValue [getResultParameter arrayName $metric resultParameterArray]
    return $retValue
}

##################################################################################
# Procedure:    getMaxColumnSize
#
# Description:  Return the maximum colunm width including the column 
#               headings for a given column type.
#
# Input:        type:                   column type: frameSize, portId 
#               resultParameterArray:   array of parameter settings
#
# Output:       maximum column width
#
##################################################################################
proc ospfSuite::getMaxColumnSize {type ResultParameterArray {portList {}}} \
{
    upvar $ResultParameterArray resultParameterArray
    set retValue 0

    switch $type {
        frameSize {
            set maximum [getMaxMetricSize]
            foreach framesize [ospfSuite cget -framesizeList] {
                if {[string length $framesize] > $maximum} {
                    set maximum [string length $framesize]           
                }
            }
            set retValue $maximum
        }

        metric {
            set retValue [getMaxRowTitleSize resultParameterArray]
        }

        portId {
            set maximum 0
            foreach portId $portList {
                scan $portId "%s %s %s" c l p
                set size [string length [getPortId $c $l $p]]
                if {$size > $maximum} {
                    set maximum $size
                }
            }
            set retValue $maximum
        }
    }

    return $retValue
}


##################################################################################
# Procedure:    clearSummaryArray
#
# Description:  Empty the array of summary result data.
#
# Input:        summary result array
#
# Output:       TCL_OK
#
##################################################################################
proc ospfSuite::clearResultArray {ResultArray} \
{
    upvar $ResultArray resultArray
    foreach item [array names resultArray] {
        unset resultArray($item)
    }
    return $::TCL_OK
}

########################################################################################
# Procedure:    ospfSuite::metricSave
#
# Description:  Stores metric in resultArray with key:
#                   resultArray($trial,$framesize,$metricName)
#
#               Appends, increments or overwrites (default) value if the value already
#               exists in the array.
#
# Argument(s):  trial:
#               framesize:
#               metric:     metric name
#               value:      result value
#               writeType:  overwrite, increment or append
#
# Results :     TCL_OK
#   
########################################################################################
proc ospfSuite::metricSave {trial framesize metric value {writeType overwrite}} \
{
    variable resultArray

    set retCode $::TCL_OK    

    set key "$trial,$framesize,$metric"
    if {[info exists resultArray($key)]} {
        switch $writeType {
            overwrite {
                set resultArray($key) $value
            }
            append {
                append resultArray($key) $value
            }
            increment {
                if {[string is double]} {
                    set resultArray($key) [expr $resultArray($key) + $value]
                } else {
                    set resultArray($key) $value
                }
            }
        }

    } else {
        set resultArray($key) $value
    }

    return $retCode
} 




