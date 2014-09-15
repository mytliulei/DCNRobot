#################################################################
#
#   Copyright © 1997 - 2004 by IXIA
#   All Rights Reserved.
#
# Description: GUI utilities for test class: "Ospf Route Tests"
#
#################################################################

namespace eval smOspfUtils \
{
variable widgets
variable widgetVariable

variable ospfVersionList
set ospfVersionList [list "V2" "V3"]

variable lsaTypeList
set lsaTypeList     [list "Summary" "External" "Router"]

variable minimumLsa 1
variable maximumLsa 57344
}

########################################################################################
# Procedure:    smOspfSuite::convergence
#
# Description:  Builds run parameter form for test.
#
# Argument(s):  w:  window address
#
# Returns:      None
########################################################################################
proc smOspfUtils::ospfConvergence {w} \
{
    # Display the parameters of this test
    variable widgets 
    variable widgetVariable
    variable minimumLsa
    variable maximumLsa


	tixLabelFrame $w.runParams -label "Run Parameters"
    
    global runParamsFrame
	set runParamsFrame [$w.runParams subwidget frame]

    frame $runParamsFrame.frame1
    frame $runParamsFrame.frame2
    frame $runParamsFrame.frame3
    frame $runParamsFrame.frame4
    frame $runParamsFrame.waitTimeFrame -relief groove -borderwidth 2

	tixControl $runParamsFrame.trialCount -label "No. of Trials: " \
	           -integer true -min 1 -value [ospfSuite cget -numtrials] \
	           -options {
            	    entry.width  4
	                label.width  20
	            }
    fieldConf $runParamsFrame.trialCount trialCountInfo

    tixControl $runParamsFrame.percentRate -label "Max Rate (%): " \
               -integer false -min 1 -max 100 -value [ospfSuite cget -percentMaxRate] \
               -options {
                    entry.width  4
                    label.width  30
                }
    fieldConf $runParamsFrame.percentRate percentRateInfo

    tixControl $runParamsFrame.areaId -label "Area ID: " \
           -integer false -min 0 -value [ospfSuite cget -areaId] \
           -options {
                entry.width  4
                label.width  20
            }


    tixControl $runParamsFrame.numberOfFlaps -label "No. of Withdrawals: " \
               -integer true -min 0 -value [ospfSuite cget -numberOfFlaps] \
               -options {
                    entry.width  4
                    label.width  20
                }

    set widgets(totalDelay) \
        [tixLabelEntry $runParamsFrame.totalDelay \
                    -label "Max Wait Time (s):\n    (# of LSAs x AdvertiseDelay)" \
                    -options \
                    {
                    entry.width  10
                    label.width  27
                    }]

    set widgetVariable(enableValidateMtu) [ospfSuite cget -enableValidateMtu]

	checkbutton $runParamsFrame.enableValidateMtu -borderwidth 1 -selectcolor white \
		    -text "Validate MTU Size" -variable smOspfUtils::widgetVariable(enableValidateMtu) \
            -onvalue "true" -offvalue "false" -command smOspfUtils::enableValidateMtuCmd

    tixControl $runParamsFrame.interfaceMTUSize -label "" \
               -integer false -min 26 -max 65535 -value [ospfSuite cget -interfaceMTUSize] \
               -options {
                    entry.width  6
                    label.width  0
                }


    # Traffic Pattern Widgets.
    set widgets(trafficPatternLabelFrame) [tixLabelFrame $runParamsFrame.trafficPattern -label "Traffic Pattern"]
    set widgets(trafficPatternFrame) [$widgets(trafficPatternLabelFrame) subwidget frame]
    
    set row 0

    foreach version [getOspfVersionList] {
        foreach lsaType [getLsaList] {
            set column 0
            
            set widgetName                  [getParameterName $version $lsaType advertise]
            set widgetVariable($widgetName) [ospfSuite cget -$widgetName]
    	    set widgets($widgetName)        [checkbutton $widgets(trafficPatternFrame).$widgetName \
                                            -borderwidth 1 -selectcolor white \
    	    	                            -text [format "Ospf%s Advertise %s LSA" $version $lsaType] \
                                            -variable smOspfUtils::widgetVariable($widgetName) \
                                            -onvalue "true" -offvalue "false" \
                                            -command [format "smOspfUtils::enableOspfLsaCmd %s %s" $version $lsaType]]
            grid $widgets($widgetName)      -row $row -column $column -padx 1 -pady 0 -sticky w
            incr column
            
            set labelNumLsa                 "Number LSA: "
            set widgetName                  [getParameterName $version $lsaType "number"]

            set widgetVariable($widgetName) [ospfSuite cget -$widgetName]
            set widgets($widgetName)        [tixControl $widgets(trafficPatternFrame).$widgetName \
                                            -label $labelNumLsa \
                                            -integer false -min $minimumLsa \
                                            -value $widgetVariable($widgetName) \
                                            -command [format "smOspfUtils::numOspfLsaCmd %s %s" $version $lsaType] \
                                            -options "
                                                 entry.width  [string length maximumLsa]
                                                 label.width  [string length labelNumLsa]
                                            "]
            grid $widgets($widgetName)      -row $row -column $column -padx 5 -pady 0 -sticky w
            incr column
            
            
            set widgetName                  [getParameterName $version $lsaType "withdraw"]
            set widgetVariable($widgetName) [ospfSuite cget -$widgetName]
    	    set widgets($widgetName)        [checkbutton $widgets(trafficPatternFrame).$widgetName \
                                            -borderwidth 1 -selectcolor white \
    	    	                            -text [format "Withdraw %s LSA" $lsaType] \
                                            -variable smOspfUtils::widgetVariable($widgetName) \
                                            -onvalue "true" -offvalue "false" \
                                            -state disabled \
                                            -command [format "smOspfUtils::withdrawOspfLsaCmd %s %s" $version $lsaType]]

            grid $widgets($widgetName)      -row $row -column $column -padx 5 -pady 0 -sticky w
            incr column
            
            incr row
        }
        incr row
    }
    grid $widgets(trafficPatternFrame)  -row 0 -column 0 -padx 1 -pady 0 -sticky w

    # Route Frame
    [$runParamsFrame.totalDelay subwidget label] config -justify left
    [$runParamsFrame.totalDelay subwidget entry] config -state disabled -bg grey85

    set widgets(advertiseDelay) \
        [tixControl $runParamsFrame.advertiseDelay -label "Advertise Delay Per LSA (s):" \
               -integer false -min 0 -value [ospfSuite cget -advertiseDelayPerRoute] \
               -command smOspfUtils::updateTotalDelay \
               -options {
                    entry.width  8
                    label.width  27
                }]
    # fieldConf $runParamsFrame.advertiseDelay advertiseDelayInfo

    bind [$runParamsFrame.advertiseDelay subwidget entry] <KeyRelease> smOspfUtils::updateTotalDelay

    tixControl $runParamsFrame.dutProcessingDelay -label "DUT Processing Delay:" \
               -integer false -min 10 -value [ospfSuite cget -dutProcessingDelay] \
               -options {
                    entry.width  6
                    label.width  20
                }

    set widgets(transmitDurationBetweenFlaps) \
        [tixControl $runParamsFrame.transmitDurationBetweenFlaps -label "Transmit Duration Between Flaps (s):" \
               -integer false -min 20 -value [ospfSuite cget -transmitDurationBetweenFlaps] \
               -options {
                    entry.width  6
                    label.width  30
                }]


    tixControl $runParamsFrame.transmitTimeout -label "Transmit Timeout (s):" \
               -integer false -min 10 -value [ospfSuite cget -transmitTimeout] \
               -options {
                    entry.width  6
                    label.width  20
                }


    #
    # Ospf interface network type
    #
    tixComboBox $runParamsFrame.interfaceNetworkType -label "Interface Network Type: " \
                -options {
                    arrow.image       arrowImage
                    arrow.width       14
                    arrow.height      16
                    arrow.borderWidth 1
                    label.width       20
                    entry.width       11
                    listbox.height    1
                }
    # fieldConf $runParamsFrame.interfaceNetworkType interfaceNetworkTypeInfo

    $runParamsFrame.interfaceNetworkType subwidget entry configure -background white
    $runParamsFrame.interfaceNetworkType insert end "Point-Point"
    $runParamsFrame.interfaceNetworkType insert end "Broadcast"

    switch [ospfSuite cget -interfaceNetworkType] {
        ospfBroadcast {
            $runParamsFrame.interfaceNetworkType config -value Broadcast
        }
        ospfPointToPoint {
            $runParamsFrame.interfaceNetworkType config -value "Point-Point"
        }
        default {
        }
    }

    #
    # Display all the widgets.
    #
    pack $runParamsFrame.trialCount $runParamsFrame.percentRate \
            -in $runParamsFrame.frame1 -side left -padx 4 -anchor nw

    pack $runParamsFrame.areaId \
            -in $runParamsFrame.frame2 -side left -padx 4 -anchor nw

    pack $runParamsFrame.numberOfFlaps $widgets(transmitDurationBetweenFlaps) \
            -in $runParamsFrame.frame3 -side left -padx 4 -anchor nw

    pack    $runParamsFrame.frame1 \
            $runParamsFrame.frame2 \
            $runParamsFrame.frame3 \
            -side top -padx 0 -pady 1 -anchor nw

    pack    $runParamsFrame.dutProcessingDelay   \
            -side top -padx 4 -pady 2 -anchor nw

    pack    $runParamsFrame.transmitTimeout \
            $runParamsFrame.interfaceNetworkType \
            -side top -padx 4 -pady 2 -anchor nw

    pack    $runParamsFrame.enableValidateMtu $runParamsFrame.interfaceMTUSize \
            -in $runParamsFrame.frame4 -side left -padx 2 -anchor nw

    pack    $runParamsFrame.frame4 \
            -side top -padx 0 -pady 2 -anchor nw

    pack    $widgets(trafficPatternLabelFrame) \
            -side top -padx 0 -pady 2 -anchor nw

    pack    $runParamsFrame.advertiseDelay       \
            $runParamsFrame.totalDelay           \
            -in $runParamsFrame.waitTimeFrame -side top -padx 4 -pady 2 -anchor nw

    pack $runParamsFrame.waitTimeFrame -side top -padx 4 -pady 2 -anchor nw

    return $w.runParams
}

########################################################################################
# Procedure:    smOspfSuite::getOspfVersionList
#
# Description:  Returns Ospf versions.
#
# Argument(s):  None
#
# Returns:      version list
########################################################################################
proc smOspfUtils::getOspfVersionList {} \
{
    variable ospfVersionList
    return $ospfVersionList
}


########################################################################################
# Procedure:    smOspfSuite::getLsaList
#
# Description:  Returns list of LSAs handled.
#
# Argument(s):  None
#
# Returns:      Lsa list
########################################################################################
proc smOspfUtils::getLsaList {} \
{
    variable lsaTypeList
    return $lsaTypeList
}

########################################################################################
# Procedure:    smOspfSuite::getParameterName
#
# Description:  Returns ospfSuite parameter name
#
# Argument(s):  version:        v2, v3
#               lsaType         summary, router, externl
#               parameterType:  "advertise", "number", "withdraw"
#
# Returns:      ixTclHal parameter name
########################################################################################
proc smOspfUtils::getParameterName {version lsaType parameterType} \
{
    set retValue ""
    array set parameterTranslation  {   enableOspfV2SummaryLsa  enableOspfV2SummaryLsa
                                        enableOspfV2ExternalLsa enableOspfV2ExternalLsa
                                        enableOspfV2RouterLsa   enableOspfV2RouterLsa
                                        flapOspfV2SummaryLsa    flapOspfV2SummaryLsa   
                                        flapOspfV2ExternalLsa   flapOspfV2ExternalLsa  
                                        flapOspfV2RouterLsa     flapOspfV2RouterLsa    
                                        numOspfV2SummaryLsa     numberOfRoutes    
                                        numOspfV2ExternalLsa    numOspfV2ExternalLsa   
                                        numOspfV2RouterLsa      numOspfV2RouterLsa     
                                        enableOspfV3SummaryLsa  enableOspfV3InterAreaPrefixLsa 
                                        enableOspfV3ExternalLsa enableOspfV3ExternalLsa
                                        enableOspfV3RouterLsa   enableOspfV3RouterLsa  
                                        flapOspfV3SummaryLsa    flapOspfV3InterAreaPrefixLsa   
                                        flapOspfV3ExternalLsa   flapOspfV3ExternalLsa  
                                        flapOspfV3RouterLsa     flapOspfV3RouterLsa    
                                        numOspfV3SummaryLsa     numOspfV3InterAreaPrefixLsa    
                                        numOspfV3ExternalLsa    numOspfV3ExternalLsa   
                                        numOspfV3RouterLsa      numOspfV3RouterLsa     
                                    }

    switch $parameterType {
        advertise {
            set parameterType "enable"
        }
        number {
            set parameterType "num"
        }
        withdraw {
            set parameterType "flap"
        }
    }

    set parameterName [format "%sOspf%s%sLsa" $parameterType $version $lsaType]
    if {[info exists parameterTranslation($parameterName)]} {
        set retValue $parameterTranslation($parameterName)
    }

    return $retValue
}




####################################################
#   Widget Commands
####################################################

########################################################################################
# Procedure:    smOspfSuite::enableValidateMtuCmd
#
# Description:  Widget command for Validate MTU widget
#
# Argument(s):  None
#
# Returns:      None
########################################################################################
proc smOspfUtils::enableValidateMtuCmd {} {
    global runParamsFrame
    variable widgetVariable

    ospfSuite config -enableValidateMtu $widgetVariable(enableValidateMtu)

    set state [expr [string match $widgetVariable(enableValidateMtu) "true"]?\"normal\":\"disabled\"]
    setStateTixLabelEntry $runParamsFrame.interfaceMTUSize $state
}

########################################################################################
# Procedure:    smOspfSuite::initTrafficPattern
#
# Description:  Widget command for Ospf V2
#
# Argument(s):  None
#
# Returns:      None
########################################################################################
proc smOspfUtils::initTrafficPattern {} {
    variable widgetVariable
    foreach version [getOspfVersionList] {
        foreach lsaType [getLsaList] {
            enableOspfLsaCmd    $version $lsaType
            withdrawOspfLsaCmd  $version $lsaType
            set parameterName   [getParameterName $version $lsaType number]
            numOspfLsaCmd       $version $lsaType $widgetVariable($parameterName)
        }
    }
}



########################################################################################
# Procedure:    smOspfSuite::enableOspfVersion
#
# Description:  Enable/Disable Ospf Version
#
# Argument(s):  version: V2 or V3
#               enable:  true or false
#
# Returns:      None
########################################################################################
proc smOspfUtils::enableOspfVersion {version {enable "true"}} {
    variable widgetVariable
    set parameter [format "enableOspf%s" $version]
    set widgetVariable($parameter) $enable
#    catch {ospfSuite config -$parameter $widgetVariable($parameter)}
}



########################################################################################
# Procedure:    smOspfSuite::enableOspfLsaCmd
#
# Description:  Enable/Disable LSA Advertisement.
#
# Argument(s):  frame:      Parent frame
#               version:    V2 or V3
#               type:       "Summary", "Router", "External"
#
# Returns:      None
########################################################################################
proc smOspfUtils::enableOspfLsaCmd {version type} \
{
    variable widgetVariable
    variable widgets

    set widgetName [getParameterName $version $type advertise]

    # Set the state of associated variables.
    set state [expr [string match $widgetVariable($widgetName) true]?\"normal\":\"disabled\"]
    set widgetName [getParameterName $version $type withdraw]
    $widgets(trafficPatternFrame).$widgetName  configure -state $state

    set widgetName [getParameterName $version $type number]
    $widgets(trafficPatternFrame).$widgetName  configure -state $state

    # Set the version state based on the LSAs used.
    set state $::false
    foreach lsaType [getLsaList] {
        set parameter [getParameterName $version $lsaType advertise]
        set typeState [expr [string match $widgetVariable($parameter) "true"]?1:0]
        set state [expr $state | $typeState]
    }
    set state [expr $state == 1?\"true\":\"false\"]
    enableOspfVersion $version $state

    updateTotalDelay
}

########################################################################################
# Procedure:    smOspfSuite::withdrawOspfLsaCmd
#
# Description:  Enable/Disable LSA Withdrawal.
#
# Argument(s):  version:    V2 or V3
#               type:       "Summary", "Router", "External"
#
# Returns:      None
########################################################################################
proc smOspfUtils::withdrawOspfLsaCmd {version type} \
{
#    variable widgetVariable
#    set widgetName [getParameterName $version $type withdraw]
}

########################################################################################
# Procedure:    smOspfSuite::numOspfLsaCmd
#
# Description:  Enable/Disable LSA Withdrawal.
#
# Argument(s):  version:    V2 or V3
#               type:       "Summary", "Router", "External"
#               value:      From GUI
#
# Returns:      None
########################################################################################
proc smOspfUtils::numOspfLsaCmd {version type {value 1}} \
{
    variable widgetVariable

    set widgetName [getParameterName $version $type number]
    set widgetVariable($widgetName) $value

    updateTotalDelay
}

###############################################################################
# Procedure:    updateTotalDelay
#
# Description:  Update the value of entry Total Delay when any of number of
#               routes or advertise delay is changed.
#
# Arguments:    None
#
# Returns:      None
###############################################################################
proc smOspfUtils::updateTotalDelay { {value 0} } \
{
    variable widgets
    set advertiseDelay [[$widgets(advertiseDelay) subwidget entry] get]
    set numberOfRoutes [getTotalNumberLSA]

    if { ([string length $advertiseDelay] > 0) && \
         ([string length $numberOfRoutes] > 0) } {

        if { [stringIsDouble $advertiseDelay] && [stringIsInteger $numberOfRoutes] } {
            
            set totalDelay [mpexpr round (double ($advertiseDelay) * $numberOfRoutes)]
            set totalDelay [expr $totalDelay > 0?$totalDelay:1]
            [$widgets(totalDelay) subwidget entry] config -state normal
            [$widgets(totalDelay) subwidget entry] delete 0 end
            [$widgets(totalDelay) subwidget entry] insert 0 $totalDelay
            [$widgets(totalDelay) subwidget entry] config -state disabled
        }
    }
}

###############################################################################
# Procedure:    getTotalNumberLSA
#
# Description:  Returns the total number of LSAs for all versions and types.
#
# Arguments:    None
#
# Returns:      # of LSAs
###############################################################################
proc smOspfUtils::getTotalNumberLSA {} \
{
    variable widgetVariable
    variable widgets
    set totalLsa 0

    foreach version [getOspfVersionList] {
        if {[catch {set enabled $smOspfUtils::widgetVariable([format "enableOspf%s" $version])}]} {
            continue
        }

        if {$enabled == "true"} {        
            foreach lsaType [getLsaList] {
                if {$widgetVariable([getParameterName $version $lsaType advertise]) == "true"} {
                    set parameter [getParameterName $version $lsaType number]
                    tixControl:Tab $widgets($parameter) NotifyNonlinear
                    incr totalLsa [$widgets($parameter) subwidget entry get]
                }
            }
        }
    }
        
    return $totalLsa
}


