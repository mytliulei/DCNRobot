#############################################################################
# Version 3.65	$Revision: 2 $
# $Date: 12/12/02 2:07p $
# $Author: Dheins $
#
# $Workfile: guiTunnelCapacity.tcl $
#
#   Copyright © 1997 - 2004 by IXIA
#   All Rights Reserved.
#
#   Revision Log:
#       11-14-02    D. Heins-Gelder     Initial Release.
#
#############################################################################


#-------------------------------
global tunnelCapacityAction
set tunnelCapacityAction \
{##################################################################################
##################################################################################
#   DON'T CHANGE ANYTHING BELOW HERE!!
##################################################################################
##################################################################################

if [configureTest one2one] {
    cleanUp
    return 1
}


if [catch {tunnel start -capacity} result] {
    logMsg "ERROR: $::errorInfo\n"
    cleanUp
    return
}

teardown
return
}
#-------------------------------


###################
# Run Parameteres #
###################
proc runParamsShow {w} {
    global runParamsFrame staggeredStart

    set runParamsLabelFrame [tixLabelFrame $w.runParams -label "Run Parameters"]
    set runParamsFrame [$runParamsLabelFrame subwidget frame]
    set leftFrame [frame $runParamsFrame.leftFrame]

    # duration label frame
    #
    set durationFrame [setupDurationWidgets [tunnel cget -duration]]

    # test parameters label frame
    #
    set testParamsFrame [tixLabelFrame $leftFrame.testParams -label "Test Parameters"]
    
    set numTrials [tixControl $runParamsFrame.trialCount -label "No. of Trials: " \
            -integer true -min 1 -value [tunnel cget -numtrials] \
            -options { entry.width 8 label.width 18 }]
    fieldConf $numTrials trialCountInfo
    bind [$numTrials subwidget entry] <KeyRelease> [eval {parseInteger [$numTrials subwidget entry]}]

    set maxRate [tixControl $runParamsFrame.percentRate -label "Max Rate (%): " \
            -integer false -min 0.0001 -max 100 -value [tunnel cget -percentMaxRate] \
            -options { entry.width 8 label.width 18 }]
    fieldConf $maxRate percentRateInfo
    bind [$maxRate subwidget entry] <KeyRelease> [eval {parseDecimal [$maxRate subwidget entry]}]

    set lossTolerance [tixControl $runParamsFrame.lossTolerance -label "Loss Tolerance (%): " \
            -integer false -min 0 -max 100 -value [tunnel cget -tolerance] \
            -options { entry.width 8 label.width 18 }]
    bind [$lossTolerance subwidget entry] <KeyRelease> "parseDecimal [$lossTolerance subwidget entry]"

    initStaggeredStart tunnel

    set staggeredTransmit [checkbutton $runParamsFrame.staggeredStart -borderwidth 1 \
            -selectcolor white -text "Staggered Transmit" \
            -variable staggeredStart -command {setStaggeredStart tunnel}]
    fieldConf $staggeredTransmit staggeredStartInfo

    pack $numTrials $maxRate $lossTolerance $staggeredTransmit \
	-side top -anchor w -pady 2 -in [$testParamsFrame subwidget frame]

    # passFail label frame
    #
    set passFail [ TunnelPassFailFrame $::true $::false $::true $::false $::true ]
    
    # do the placement
    #
    pack $durationFrame $testParamsFrame $passFail \
	-side top -anchor w -padx 6 -expand y -fill both -in $leftFrame
    pack $leftFrame -side top -anchor w 

    return $runParamsLabelFrame
}


proc runParamsUpdate {} {
    global runParamsFrame

    tunnel config -duration [getDurationFromGUI]

    tixControl:Tab $runParamsFrame.trialCount NotifyNonlinear
    tunnel config -numtrials [[$runParamsFrame.trialCount subwidget entry] get]

    tixControl:Tab $runParamsFrame.percentRate NotifyNonlinear
    tunnel config -percentMaxRate [[$runParamsFrame.percentRate subwidget entry] get]

    tixControl:Tab $runParamsFrame.lossTolerance NotifyNonlinear
    tunnel config -tolerance [[$runParamsFrame.lossTolerance subwidget entry] get]

    testConfig::setTestConfItem protocolName [tunnel cget -payloadProtocol]
}


proc runParamsSave {fileId} {
    global adjustForTags

    puts $fileId ""
    puts $fileId "tunnel config -numtrials              [tunnel cget -numtrials]"
    puts $fileId "tunnel config -duration               [tunnel cget -duration]"
    puts $fileId "tunnel config -numFrames              [tunnel cget -numFrames]"
    puts $fileId "tunnel config -percentMaxRate         [tunnel cget -percentMaxRate]"
    puts $fileId "tunnel config -tolerance              [tunnel cget -tolerance]"
    puts $fileId "tunnel config -staggeredStart         [tunnel cget -staggeredStart]"
    puts $fileId ""
    puts $fileId "tunnel config -tunnelProtocol         [tunnel cget -tunnelProtocol]"
    puts $fileId "tunnel config -payloadProtocol        [tunnel cget -payloadProtocol]"
    puts $fileId ""
    puts $fileId "tunnel config -encapsulation          [tunnel cget -encapsulation]"
    puts $fileId "tunnel config -tunnelConfiguration    [tunnel cget -tunnelConfiguration]"
    puts $fileId "tunnel config -addressType            [tunnel cget -addressType]"
    puts $fileId "tunnel config -prefixLength           [tunnel cget -prefixLength]"
    puts $fileId "tunnel config -prefixType             \"[tunnel cget -prefixType]\""

    puts $fileId ""
    puts $fileId "tunnel config -tunnelStep             [tunnel cget -tunnelStep]"
    puts $fileId "tunnel config -minimumTunnels         [tunnel cget -minimumTunnels]"
    puts $fileId "tunnel config -maximumTunnels         [tunnel cget -maximumTunnels]"
    puts $fileId ""
    puts $fileId "tunnel config -enableLatency          [tunnel cget -enableLatency]"
    puts $fileId "tunnel config -enableSequenceTotal    [tunnel cget -enableSequenceTotal]"
    puts $fileId "tunnel config -enableSequenceDetail   [tunnel cget -enableSequenceDetail]"
    puts $fileId "tunnel config -enableDataIntegrity    [tunnel cget -enableDataIntegrity]"
    puts $fileId ""

    TunnelThresholdSave $fileId  $::true $::false $::true $::false $::true

    fputs $fileId ""
}

########################################################
# Create the setup window for Capacity test category #
########################################################
proc tunnelCapacityShow {} {
    sysSetupShow
    return [testSetupShow]
}


#############################################
# Update the variables and run the commands #
#############################################
proc tunnelCapacityUpdate {} {
    sysSetupUpdate
    testSetupUpdate
}

#############################################################
# Save the current test (i.e. test configuration) in a file #
#############################################################
proc tunnelCapacitySave {filename} {
    global fileEntry
    global tunnelCapacityAction
    global currContext

    tunnelCapacityUpdate

    set fileId [open $filename w]

    puts $fileId "# Tunnel/tunnelCapacity"
    puts $fileId $fileEntry(Separator)
    puts $fileId "# File: [file tail $filename]"
    puts $fileId "#"
    puts $fileId $fileEntry(copyrightHdr)
    puts $fileId $fileEntry(Separator)
    puts $fileId ""
    puts $fileId $fileEntry(packReq)
    puts $fileId $fileEntry(globalDefs)
    puts $fileId ""

    sysSetupSave  $fileId
    testSetupSave $fileId

    puts $fileId ""
    puts $fileId ""

    puts $fileId $tunnelCapacityAction
    set currContext(realTimeSetup) tunnelCapacityRealtimeConfig
    close $fileId
}

 proc tunnelCapacityRealtimeConfig {txList rxList} {
    set statList [list   [list framesSent     $txList "Tx Frames per second" "Tx Frames" 1e0]\
                         [list framesReceived $rxList "Rx Frames per second" "Rx Frames" 1e0]\
                         [list bitsSent       $txList "Tx Kbps"              "Tx Kb"     1e3]\
                         [list bitsReceived   $rxList "Rx Kbps"              "Rx Kb"     1e3]\
                 ]
    openRealTimeTab "IP Tunnel: Tunnel Capacity " $statList
 }
