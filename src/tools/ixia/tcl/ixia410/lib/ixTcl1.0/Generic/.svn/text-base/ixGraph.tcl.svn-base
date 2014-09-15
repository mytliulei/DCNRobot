#################################################################################
# Version 4.10    $Revision: 28 $
# $Date: 9/30/02 3:59p $
# $Author: Mgithens $
#
# $Workfile: ixGraph.tcl $ -Learn parameters
#
#   Copyright © 1997 - 2005 by IXIA
#   All Rights Reserved.
#
#    Revision Log:
#    Date        Author                Comments
#    -----------    -------------------    --------------------------------------------
#    2001/06/11  D. Heins-Gelder     Initial release
#
# Description:  This file contains API commands for generating a graph
#               and displaying data on the graph.
#
##################################################################################

package ifneeded BLT 2.4

namespace eval ixGraph {
#
#   Public Procedures:  
#       ixGraph::create:            Create graph with given attributes
#       ixGraph::destroy            Destroy graph.
#       ixGraph::reset                Reset all data.
#       ixGraph::addLine            Add a line to given graph
#       ixGraph::deleteLine            Delete a line from given graph
#       ixGraph::resetLine            Clear a given line of it's data
#       ixGraph::updateLine              Add new x,y coordinates(s) to graph
#       ixGraph::updateCoordinates    Append new coordinate to either x or y axis.
#       ixGraph::getLines            Show a list of line names
#       ixGraph::getDataVector      Obtain data vector handle from graph
#       ixGraph::setDataVector      Set data vector handle in graph
#       ixGraph::updateDataVector   Append data to the end of the data vector  
#       ixGraph::resetDataVector    Clear data from the data vector   
#

#   Private Procedures: 
#       None
#
#   Private Variables:                                                           
#       None
#
#
#   SAMPLE USAGE:
#   -------------
#
#    SAMPLE 1
#
#set xyList \
#    [list 1 1 2 2 3 3 4 4 5 5 6 6 7 7 8 8 9 9 10 9.5 11 9 12 8 13 7 14 6 15 5 16 4 17 3 18 2 19 1.5 20 2 21 3 22 4 23 5 24 6 25 7 26 8 27 9 28 8.5 29 9 30 8]
#
#set g [ixGraph::create .g    -title          "MY GRAPH"      \
#                             -background     black           \
#                             -foreground     white           \
#                             -plotColor      grey            \
#                             -legendColor    grey            \
#                             -xColor         red             \
#                             -yColor         red             \
#                             -font           {Arial-Bold 14} \
#                             -xTitle         "X-AXIS TITLE"  \
#                             -yTitle         "Y-AXIS TITLE"  \
#                             -xRange         [list 0 10 2]   \
#                             -yRange         [list 0 10 2]   \
#                             -logoFile       ixiaLogo.gif    \
#                             -crossHairs     on              \
#                             -grid           on              ]
#pack $g
#
#ixGraph::addLine $g rate     -color          white   \
#                             -lineWidth      2       
#
## Update line with a list of coordinates.
#ixGraph::updateLine $g rate $xyList
#foreach {x y} $xyList {
## Update line with a single set of coordinates.
#    ixGraph::updateLine $g rate  [list $x $y]
#
##     or
#
## Update x / y coordinates individually.
#    ixGraph::updateCoordinate $g rate x [list $x] 
#    ixGraph::updateCoordinate $g rate y [list $y] 
#
#    after 250
#}
#
#ixGraph::destroy $g
#
#   END SAMPLE OF SAMPLE 1

#
#    SAMPLE 2
#
#ixGraph::destroy $g
#stat setDefault
#set g [ixGraph::create .g    -title          "MY GRAPH"      \
#                             -background     black           \
#                             -foreground     white           \
#                             -plotColor      grey            \
#                             -legendColor    grey            \
#                             -xColor         red             \
#                             -yColor         red             \
#                             -font           {Arial-Bold 14} \
#                             -xTitle         "X-AXIS TITLE"  \
#                             -yTitle         "Y-AXIS TITLE"  \
#                             -xRange         [list 0 20 1]   \
#                             -yRange         [list 0 200000 10000] \
#                             -crossHairs     on              \
#                             -grid           on              ]
#pack $g
#
#ixGraph::addLine $g rate     -color          white   \
#                             -lineWidth      2       
#
#set i 0
#while {$i < 50} {
#    after 1000
#    incr i 1
#    stat get -bytesReceived 1 1 1
#    set value [stat cget -bytesReceived]
#    set value [expr $value / 1000]
#   ixGraph::updateLine $g rate [list $i $value]
#}
#   END SAMPLE OF SAMPLE 2

}
## End of ixGraph namespace

########################################################################################
# Procedure:    create
#
# Description:  Create a graph as a free-floating element and return it's handle  
#                   
# Input:        graphName:      window path name, ie: .myGraph or .window.myGraph      
#               args:           configuration parameters for the graph, the following
#                               are currently valid:
#                                   -title          value   - Graph Title
#                                   -foreground     value   - Graph foreground color (default grey)
#                                   -background     value   - Graph background color (default black)
#                                   -plotColor        value   - Color of plot area (default white)
#                                   -font           value   - Graph text font
#                                   -logoFile       value   - path and file of logo
#                                   -xTickFont      value   - font of the numbers on the graph
#                                   -yTickFont      value   - font of the numbers on the graph
#                                   -xTitle         value   - X Axis Title
#                                   -yTitle         value   - Y Axis Title
#                                   -xTitleFont     value   - font of the axis titles
#                                   -yTitleFont     value   - font of the axis titles
#                                   -xRange         value   - [list $minimum $maximum $step]
#                                   -yRange         value   - [list $minimum $maximum $step]
#                                   -xColor         value   - color of x axis titles
#                                   -yColor         value   - color of y axis titles
#                                   -grid           value   - on or off
#                                   -crossHairs     value   - on or off
#                                   -legendColor    value   - color of legend (default grey)
#
# Output:       
#
########################################################################################
proc ixGraph::create {graphName args} \
{
    set parameters [list title          ""          \
                         foreground     "black"     \
                         background     "grey"      \
                         plotColor      "white"     \
                         legendColor    "grey"      \
                         logoFile       ""          \
                         font           {Arial 10}  \
                         xTitle         ""          \
                         xTitleFont     {Arial 10}  \
                         xTickFont      {Arial 8}   \
                         xMinimum       ""          \
                         xMaximum       ""          \
                         xStep          0.0         \
                         xColor         "black"     \
                         yTitle         ""          \
                         yTitleFont     {Arial 10}  \
                         yTickFont      {Arial 8}   \
                         yMinimum       ""          \
                         yMaximum       ""          \
                         yStep          0.0         \
                         yColor         "black"     \
                         grid           "off"       \
                         crossHairs     "off"       ]

    set retValue ""

    # Initialize graph parameters
    foreach {parameter value} $parameters {
        set $parameter $value
    }
    
    foreach {parameter value} $args {
        switch -- $parameter {
            -title {
                set title $value
            }
            -foreground {
                set foreground $value
            }
            -background {
                set background $value
            }
            -plotColor {
                set plotColor $value
            }
            -legendColor {
                set legendColor $value
            }
            -font {
                set font $value
            }
            -xTitle {
                set xTitle $value
            }
            -yTitle {
                set yTitle $value
            }
            -xColor {
                set xColor $value
            }
            -yColor {
                set yColor $value
            }
            -xTickFont {
                set xTickFont $value
            }
            -yTickFont {
                set yTickFont $value
            }
            -xTitleFont {
                set xTitleFont $value
            }
            -yTitleFont {
                set yTitleFont $value
            }
            -xRange {
                foreach {xMinimum xMaximum xStep} $value {}
                if {$xMaximum != ""} {
                    if {$xMinimum > $xMaximum} {
                        return $::TCL_ERROR
                    }
                }
            }
            -yRange {
                foreach {yMinimum yMaximum yStep} $value {}
                if {$yMaximum != ""} {
                    if {$yMinimum > $yMaximum} {
                        return $::TCL_ERROR
                    }
                }
                if {$yStep == ""} {set yStep 0}
            }
            -grid {
                switch $value {
                    on -
                    true -
                    yes {
                        set grid "on"
                    }
                }
            }
            -crossHairs {
                switch $value {
                    on -
                    true -
                    yes {
                        set crossHairs "on"
                    }
                }
            }
            -logoFile {
                if {[file exists $value]} {
                    set logoFile $value
                } else {
                    return $::TCL_ERROR
                }
            }
            default {
                return $retValue
            }
        }
    }

    # Create graph and configure as requested.
    if {![catch {blt::graph $graphName} graph]} {

        $graph configure -title $title
        $graph configure -bufferelements $::false
        $graph axis configure x -title $xTitle -min $xMinimum \
            -max $xMaximum -stepsize $xStep
        $graph axis configure y -title $yTitle -min $yMinimum \
            -max $yMaximum -stepsize $yStep -command "stringFormatNumber value"

        $graph grid $grid

        if {$crossHairs == "on"} {
            Blt_Crosshairs $graph
            $graph crosshairs configure -color grey
        }

        $graph configure -foreground $foreground
        $graph configure -background $background
        $graph configure -plotbackground $plotColor
        $graph configure -font $font

        $graph legend configure -background $legendColor

        $graph axis configure x -tickfont $xTickFont
        $graph axis configure y -tickfont $yTickFont
        $graph axis configure x -titlefont $xTitleFont
        $graph axis configure y -titlefont $yTitleFont
        $graph axis configure x -color $xColor
        $graph axis configure y -color $yColor
        $graph axis configure x -titlecolor $foreground
        $graph axis configure y -titlecolor $foreground

        if {$logoFile == "on"} {
            set marker [$graph marker create image \
                -image [image create photo -file ixiaLogo.gif]]
            $graph marker configure $marker -coords {1 1} -under 1
        }

        set retValue $graph
    }

    return $retValue
}

########################################################################################
# Procedure:    reset
#
# Description:  Set/Reset the graph and all associated data vectors to initial values.
#                   
# Input:        graph:      handle
#
# Output:       TCL_OK or TCL_ERROR
#
########################################################################################
proc ixGraph::reset {graph} \
{
    set retCode $::TCL_OK

    if ![winfo exists $graph] {
        return $::TCL_ERROR
    }

    foreach item [$graph element names] {
        resetLine $graph $item
    }

    # Axis maximum set dynamically, reset to auto scale.
    $graph yaxis configure -max ""

    update idletasks
    return $retCode    

}

########################################################################################
# Procedure:    destroy
#
# Description:  Deletes all data associated with the graph.
#                   
# Input:        graph:      handle
#
# Output:       TCL_OK or TCL_ERROR
#
########################################################################################
proc ixGraph::destroy {graph} \
{
    set retCode $::TCL_OK

    if {![winfo exists $graph]} {
        return $::TCL_ERROR
    }

    foreach item [$graph element names] {
        blt::vector destroy [$graph element cget $item -xdata]
        blt::vector destroy [$graph element cget $item -ydata]

        $graph element delete $item
    }
    ::destroy $graph

    return $retCode    

}

########################################################################################
# Procedure:    addLine
#
# Description:  Add a data line to the given graph.
#                   
# Input:        graph:      handle
#               args:       configuration parameters for the graph, the following
#                           are currently valid:
#
#                           -color      value   - line color name (ie red) or
#                                                  hex value (ie #000000)
#                           -lineWidth  value   - line size (default 1)
#                           -dashes     value   - # from 1-255, "" is solid line
#                           -legendFont value   - Font of legend text
#                           
# Output:       vector handle
#
########################################################################################
proc ixGraph::addLine {graph name args} \
{
    set parameters [list    color       black     \
                            symbol      none      \
                            smooth      linear    \
                            lineWidth   1         \
                            dashes      ""        \
                            legendFont  {Arial 7} \
                                                  ]

    set retValue ""

    # Initialize graph parameters
    foreach {parameter value} $parameters {
        set $parameter $value
    }

    if {![winfo exists $graph]} {
        return $retValue
    }

    foreach {parameter value} $args {
        switch -- $parameter {
            -color {
                set color $value
            }
            -xSize {
                set xSize $value
            }
            -ySize {
                set ySize $value
            }
            -symbol {
                set symbol $value
            }
            -lineWidth {
                set lineWidth $value
            }
            -dashes {
                set dashes $value
            }
            -legendFont {
                set legendFont $value
            }
            default {
                return $retValue
            }
        }
    }               

    if {![catch {$graph element create $name}]} {
        set xVector [blt::vector create #auto(1)]
        set yVector [blt::vector create #auto(1)]


        $graph element configure $name -xdata       $xVector
        $graph element configure $name -ydata       $yVector
        $graph element configure $name -color       $color
        $graph element configure $name -symbol      $symbol
        $graph element configure $name -smooth      $smooth
        $graph element configure $name -linewidth   $lineWidth
        $graph element configure $name -dashes      $dashes
        $graph legend  configure -font $legendFont

        set retValue [list $xVector $yVector]
    }

    return $retValue
}

########################################################################################
# Procedure:    getLines
#
# Description:  Get a list of lines attached to a graph.
#                   
# Input:        graph:      handle
#                           
# Output:       List of lines attached to graph
#
########################################################################################
proc ixGraph::getLines {graph} \
{

    set retCode $::TCL_OK

    if ![winfo exists $graph] {
        return $::TCL_ERROR
    }

    return [lsort [$graph element names]]
}


########################################################################################
# Procedure:    deleteLine
#
# Description:  Delete a line from the given graph.
#                   
# Input:        graph:      handle
#               line:       name of graph line
#                           
# Output:       vector handle
#
########################################################################################
proc ixGraph::deleteLine {graph name} \
{
    set retCode $::TCL_OK

    if ![winfo exists $graph] {
        return $::TCL_ERROR
    }

    if {[lsearch [$graph element names] $name] < 0} {
        return $::TCL_ERROR
    }

    set xVector [$graph element cget $name -xdata]
    if {$xVector != ""} {
        blt::vector destroy $xVector
    }
    set yVector [$graph element cget $name -ydata]
    if {$yVector != ""} {
        blt::vector destroy $yVector
    }

    if {[catch {$graph element delete $name}]} {
        set retCode $::TCL_ERROR
    }
     
    return $retCode
}


########################################################################################
# Procedure:    resetLine
#
# Description:  Resets a graph line to no data.
#                   
# Input:        graph:      handle
#               line:       name of graph line
#                           
# Output:       vector handle
#
########################################################################################
proc ixGraph::resetLine {graph line} \
{
    set retCode $::TCL_OK

    # Valid graph handle?
    if ![winfo exists $graph] {
        return $::TCL_ERROR
    }

    # Is the given line a member of this graph?
    if {[lsearch [$graph element names] $line] < 0} {
        return $::TCL_ERROR
    }

    # Clear the x & y vectors.
    if {[set xVector [$graph element cget $line -xdata]] != ""} {
        resetDataVector $graph $xVector
    }
    if {[set yVector [$graph element cget $line -ydata]] != ""} {
        resetDataVector $graph $yVector
    }

    $graph axis view x moveto 0.0
}

########################################################################################
# Procedure:    updateLine
#
# Description:  Inserts new data into a given line.
#                   
# Input:        graph:          handle
#               line:           name of graph line
#               xyCoordinate:   [list x y x1 y1 x2 x2 .... xn yn]
#                           
# Output:       vector handle
#
########################################################################################
proc ixGraph::updateLine {graph line xyCoordinate} \
{
    set retCode $::TCL_OK

    if ![winfo exists $graph] {
        return $::TCL_ERROR
    }

    if {[lsearch [$graph element names] $line] < 0} {
        return $::TCL_ERROR
    }

    # Don't allow graph to grow beyond size setting.
    set xVector [$graph element cget $line -xdata]
    set yVector [$graph element cget $line -ydata]

    foreach {x y} $xyCoordinate {
        updateDataVector $graph $xVector $yVector [list $x $y]

        set xMaximum [$graph xaxis cget -max]
        if {$x > $xMaximum} {
            $graph axis view x moveto 1.0
        }
    }  
    update idletasks
          
    return $retCode
}

########################################################################################
# Procedure:    getDataVector
#
# Description:  Given a graph and line, return the data vector 
#                   associated with the given axis.
#                   
# Input:        graph:      handle
#               line:       desired line (name of)
#               axis:       x or y
#                           
# Output:       vector handle
#
########################################################################################
proc ixGraph::getDataVector {graph line axis} \
{
    set retValue ""

    # Valid graph?
    if {[winfo exists $graph]} {

        # Valid line?
        if {[lsearch [getLines $graph] $line] >= 0} {
            switch $axis {
                x {
                    set retValue [$graph element cget $line -xdata]
                }
                y {
                    set retValue [$graph element cget $line -ydata]
                }
                default {
                    set retValue ""
                }
            }
        }
    }
    return $retValue
}

########################################################################################
# Procedure:    setDataVector
#
# Description:  Associate the given data vector with the given graph-line-axis 
#                   combination.
#                   
# Input:        graph:      graph handle
#               line:       line handle
#               axis:       x or y
#               vector:     vector handle
#                           
# Output:       TCL_OK or TCL_ERROR
#
########################################################################################
proc ixGraph::setDataVector {graph line axis vector} \
{
    set retCode $::TCL_ERROR

    if {[winfo exists $graph]} {

        if {[lsearch [getLines $graph] $line] >= 0} {
            switch $axis {
                x {
                    $graph element config $line -xdata $vector
                    set retCode $::TCL_OK
                }
                y {
                    $graph element config $line -ydata $vector
                    set retCode $::TCL_OK
                }
                default {
                    set retCode $::TCL_ERROR
                }
            }
        }
    }
    return $retCode
}

########################################################################################
# Procedure:    resetDataVector
#
# Description:  Resets a data vector to no data.
#                   
# Input:        graph:      graph handle
#               vector:     vector handle
#                           
# Output:       vector handle
#
########################################################################################
proc ixGraph::resetDataVector {graph vector} \
{
    set retCode $::TCL_OK

    # Valid graph handle?
    if ![winfo exists $graph] {
        return $::TCL_ERROR
    }

    # Valid vector handle?
    if {![info exists $vector]} {
        return $::TCL_ERROR
    }

    if {[$vector length] > 0} {
        $vector delete 0:end
    }
}


########################################################################################
# Procedure:    updateDataVectorPair
#
# Description:  Inserts new data into a given vector x,y pair.
#                   
# Input:        graph:          handle
#               vector:         vector handle
#               xyCoordinate:   [list x y x1 y1 x2 x2 .... xn yn]
#                           
# Output:       vector handle
#
########################################################################################
proc ixGraph::updateDataVectorPair {graph xVector yVector xyCoordinate} \
{
    set retCode $::TCL_OK

    if {![winfo exists $graph]} {
        return $::TCL_ERROR
    }

    foreach {x y} $xyCoordinate {

        updateDataVector $graph $xVector $yVector x $x
        updateDataVector $graph $xVector $yVector y $y
    }

    return $retCode
}


########################################################################################
# Procedure:    updateDataVector
#
# Description:  Inserts new data into a given vector
#                   
# Input:        graph:          handle
#               vector:         vector handle
#               Coordinate:     [list x x1 x2 ... xn] OR [list y y1 y2 ... yn]
#               increment:      graph update increment (ie, how often is the graph updated)
#                           
# Output:       vector handle
#
########################################################################################
proc ixGraph::updateDataVector {graph xVector yVector axis coordinates {increment 1}} \
{
    set retCode $::TCL_OK

    if {![winfo exists $graph]} {
        return $::TCL_ERROR
    }

    switch $axis {
        x {
            set vector $xVector
        }
        y {
            set vector $yVector
        }
        default {
            return $::TCL_ERROR
        }
    }

    set xMaximum [$graph xaxis cget -max]
    set xMinimum [$graph xaxis cget -min]
    set windowLength [expr $xMaximum-$xMinimum]

    foreach coordinate $coordinates {

        # BLT is limited to an signed long - temporary fix.
        if {$coordinate < 0} {
            set coordinate 0x07fffffff
            errorMsg "Negative number encountered"
        }
        if {[catch {set ${vector}(++end) $coordinate} errorMsg]} {
            errorMsg "$errorMsg"
            set ${vector}(++end) 0x07fffffff
        }

        # Dynamically set maximum for Y axis.
        set yMaximum [$graph yaxis cget -max]
        if {$yMaximum == "" } {
            $graph yaxis config -max 100
        }
        if {[$graph yaxis cget -max] < $coordinate} {
            if {[catch {$graph yaxis config -max [expr {round($coordinate*1.05)}]}]} {
                $graph yaxis config -max [expr {round($coordinate)}]
            }
        }

        if {[$vector length] > [expr {$windowLength/$increment}]} {
            $xVector delete 0:0
            $yVector delete 0:0
        }
        advanceBuffer $graph $xVector $windowLength $increment
    }        

    return $retCode
}


########################################################################################
# Procedure:    updateCoordinates
#
# Description:  Append new data into the given axis on the given line in the given
#                    graph.
#                   
# Input:        graph:          handle
#               line:           name of graph line
#               axis:            x or y
#               coordinates:    [list value1 value2 value 3... valuen]
#               increment:      graph update increment (ie, how often is the graph updated)
#                           
# Output:       vector handle
#
########################################################################################
proc ixGraph::updateCoordinates {graph line axis coordinates {increment 1}} \
{
    set retCode $::TCL_OK

    if ![winfo exists $graph] {
        return $::TCL_ERROR
    }

    if {[lsearch [$graph element names] $line] < 0} {
        return $::TCL_ERROR
    }

    set xVector [$graph element cget $line -xdata]
    set yVector [$graph element cget $line -ydata]

    switch $axis {
        x {
            set vector $xVector
        }
        y {
            set vector $yVector
        }
        default {
            return $::TCL_ERROR
        }
    }

    set xMaximum [expr {round([$graph xaxis cget -max])}]
    set xMinimum [expr {round([$graph xaxis cget -min])}]
    set windowLength [expr $xMaximum-$xMinimum]

    foreach coordinate $coordinates {

        # BLT is limited to an signed long - temporary fix.
        if {$coordinate < 0} {
            set coordinate 0x07fffffff
            errorMsg "Negative number encountered, statistic: $line."
        }
        if {[catch {set ${vector}(++end) $coordinate} errorMsg]} {
            errorMsg "$errorMsg"
            set ${vector}(++end) 0x07fffffff
        }

        # Dynamically set maximum for Y axis.
        set yMaximum [$graph yaxis cget -max]
        if {$yMaximum == "" } {
            $graph yaxis config -max 100
        } 
        if {[$graph yaxis cget -max] < $coordinate} {
            if {[catch {$graph yaxis config -max [expr {round($coordinate*1.05)}]}]} {
                $graph yaxis config -max [expr {round($coordinate)}]
            }
        }

        if {[$vector length] > [expr {$windowLength/$increment}]} {
            $yVector delete 0:0
            $xVector delete 0:0

            $graph axis view x moveto [mpexpr 1.0/[$xVector length]]
        }
        advanceBuffer $graph $xVector $windowLength $increment
    }        

    return $retCode
}

########################################################################################
# Procedure:    advanceBuffer
#
# Description:  The x axis contains time data which can be determined at the start of
#                   the test, therefore to optimize graphing the x axis is updated
#                   in multiples of the window length.  This procedure performs the
#                   incrementation of the x axis vector.
#                   
# Input:        graph:          handle
#               vector:         vector handle
#               range:          increment size  (window)
#               increment:      graph update increment
#                           
# Output:       $::TCL_ERROR or $::TCL_OK
#
########################################################################################
proc ixGraph::advanceBuffer {graph vector range {increment 1}} \
{
    set retCode $::TCL_OK
   
    if ![winfo exists $graph] {
        return $::TCL_ERROR
    }

    if {[$vector length] > [expr {$range/$increment}]} {
        return $::TCL_OK
    }

    set nextVectorSegment [blt::vector create #auto(1)]
    #set range [expr round($range - 1)]
    $nextVectorSegment set [$vector range 0 [mpexpr $range/$increment-1]]
 
    $nextVectorSegment expr {$nextVectorSegment + $range}
    $vector append $nextVectorSegment

    blt::vector destroy $nextVectorSegment

    return $retCode
}



