#############################################################################
# Version 3.65	$Revision: 2 $
# $Date: 12/12/02 2:07p $
# $Author: Dheins $
#
# $Workfile: guiTunnelFrameLoss.tcl $
#
#   Copyright © 1997 - 2004 by IXIA
#   All Rights Reserved.
#
#   Revision Log:
#       11-14-02    D. Heins-Gelder     Initial Release.
#
#############################################################################


#-------------------------------
global tunnelFrameLossAction
set tunnelFrameLossAction \
{##################################################################################
##################################################################################
#   DON'T CHANGE ANYTHING BELOW HERE!!
##################################################################################
##################################################################################

if [configureTest one2one] {
    cleanUp
    return 1
}


if [catch {tunnel start -floss} result] {
    logMsg "ERROR: $::errorInfo\n"
    cleanUp
    return
}

teardown
return
}
#-------------------------------


proc grainCmd {value} { 
    tunnel config -grain [string tolower $value]
}

###################
# Run Parameteres #
###################
proc runParamsShow {w} {
    global runParamsFrame staggeredStart

    set runParamsLabelFrame [tixLabelFrame $w.runParams -label "Run Parameters"]
    set runParamsFrame [$runParamsLabelFrame subwidget frame]
    set leftFrame [frame $runParamsFrame.leftFrame]

    # test parameters label frame
    #
    set testParamsFrame [tixLabelFrame $leftFrame.testParams -label "Test Parameters"]

    set numTrials [tixControl $runParamsFrame.trialCount -label "No. of Trials: " \
            -integer true -min 1 -value [tunnel cget -numtrials] \
            -options { entry.width 8 label.width 14 }]
    fieldConf $numTrials trialCountInfo
    bind [$numTrials subwidget entry] <KeyRelease> [eval {parseInteger [$numTrials subwidget entry]}]

    set numFrames [tixControl $runParamsFrame.frameCount -label "No. of Frames: " \
            -integer true -min 0 -value [tunnel cget -numFrames] \
            -options { entry.width 8 label.width 14 }]
    fieldConf $numFrames frameCountInfo
    bind [$numFrames subwidget entry] <KeyRelease> [eval {parseInteger [$numFrames subwidget entry]}]

    set maxRate [tixControl $runParamsFrame.percentRate -label "Max Rate (%): " \
            -integer false -min 0.0001 -max 100 -value [tunnel cget -percentMaxRate] \
            -options { entry.width 8 label.width 14 }]
    fieldConf $maxRate percentRateInfo
    bind [$maxRate subwidget entry] <KeyRelease> [eval {parseDecimal [$maxRate subwidget entry]}]

    set granularity [tixComboBox $runParamsFrame.granularity -label "Granularity: " \
            -command grainCmd -options { \
            arrow.image       arrowImage \
            arrow.width       14 \
            arrow.height      16 \
            arrow.borderWidth 1 \
            label.width       14 \
            entry.width       8 \
            listbox.height    1 }]
    [$granularity subwidget entry] configure -background white
    fieldConf $granularity granularityInfo
    foreach opt {Coarse Fine} {
        $granularity insert end $opt
    }
    $granularity configure -value [valCapitalize [tunnel cget -grain]]

    initStaggeredStart tunnel

    set staggeredTransmit [checkbutton $runParamsFrame.staggeredStart -borderwidth 1 \
            -selectcolor white -text "Staggered Transmit" \
            -variable staggeredStart -command {setStaggeredStart tunnel}]
    fieldConf $staggeredTransmit staggeredStartInfo

    pack $numTrials $numFrames $maxRate $granularity $staggeredTransmit \
            -side top -anchor w -pady 2 -in [$testParamsFrame subwidget frame]

    # passFail label frame
    #    
    set passFail [ TunnelPassFailFrame $::false $::true $::false $::false $::true ]

    # do the placement
    #
    pack $testParamsFrame -side top -anchor w -padx 6 -expand y -fill both -in $leftFrame
    pack $passFail -side top -anchor w -padx 6 -expand y -fill both -in $leftFrame
    pack $leftFrame -side top -anchor w 

    return $runParamsLabelFrame
}


proc runParamsUpdate {} {
    global runParamsFrame

    tixControl:Tab $runParamsFrame.trialCount NotifyNonlinear
    tunnel config -numtrials [[$runParamsFrame.trialCount subwidget entry] get]

    tixControl:Tab $runParamsFrame.frameCount NotifyNonlinear
    tunnel config -numFrames [[$runParamsFrame.frameCount subwidget entry] get]

    tixControl:Tab $runParamsFrame.percentRate NotifyNonlinear
    tunnel config -percentMaxRate [[$runParamsFrame.percentRate subwidget entry] get]

    testConfig::setTestConfItem protocolName [tunnel cget -payloadProtocol]

}


proc runParamsSave {fileId} {
    global adjustForTags

    puts $fileId ""
    puts $fileId "tunnel config -numtrials              [tunnel cget -numtrials]"
    puts $fileId "tunnel config -numFrames              [tunnel cget -numFrames]"
    puts $fileId "tunnel config -percentMaxRate         [tunnel cget -percentMaxRate]"
    puts $fileId "tunnel config -grain                  [tunnel cget -grain]"
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
    puts $fileId "tunnel config -enableDataIntegrity    [tunnel cget -enableDataIntegrity]"
    puts $fileId ""

    fputs $fileId ""

    TunnelThresholdSave $fileId  $::false $::true $::false $::false $::true
}

########################################################
# Create the setup window for Frame-Loss test category #
########################################################
proc tunnelFrameLossShow {} {
    sysSetupShow
    return [testSetupShow]
}


#############################################
# Update the variables and run the commands #
#############################################
proc tunnelFrameLossUpdate {} {
    sysSetupUpdate
    testSetupUpdate
}

#############################################################
# Save the current test (i.e. test configuration) in a file #
#############################################################
proc tunnelFrameLossSave {filename} {
    global fileEntry
    global tunnelFrameLossAction
    global currContext

    tunnelFrameLossUpdate

    set fileId [open $filename w]

    puts $fileId "# Tunnel/tunnelFrameLoss"
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

    puts $fileId $tunnelFrameLossAction
    set currContext(realTimeSetup) tunnelFrameLossRealtimeConfig
    close $fileId
}

 proc tunnelFrameLossRealtimeConfig {txList rxList} {
    set statList [list   [list framesSent     $txList "Tx Frames per second" "Tx Frames" 1e0]\
                         [list framesReceived $rxList "Rx Frames per second" "Rx Frames" 1e0]\
                         [list bitsSent       $txList "Tx Kbps"              "Tx Kb"     1e3]\
                         [list bitsReceived   $rxList "Rx Kbps"              "Rx Kb"     1e3]\
                 ]
    openRealTimeTab "IP Tunnel: Tunnel Frame Loss " $statList
 }

