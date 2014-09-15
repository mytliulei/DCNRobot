#################################################################
#
#   Copyright © 1997 - 2004 by IXIA
#   All Rights Reserved.
#
# Description: gui file for test "RouteCapacity"
#
#################################################################


global automap directions

set automap(BGP_routeCapacity)           {Automatic Manual}
set directions(BGP_routeCapacity)        {unidirectional}

set testConf(protocolName)               ip

global routeCapacityAction
set routeCapacityAction \
{##################################################################################
##################################################################################
#       DON'T CHANGE ANYTHING BELOW HERE!!
##################################################################################
##################################################################################
# Do not change the protocol type
# Supported protocols are IP ONLY
set testConf(protocolName)          ip

bgpSuite config -mapType   one2one



if [configureTest one2one bgpSuite] {
    cleanUp
    return 1
}

if [catch {bgpSuite start -routeCapacity} result] {
    logMsg "ERROR: $::errorInfo"
    cleanUp
    return 1
}

teardown
return 0

}


##################################################################################
# Run Parameters
##################################################################################
proc runParamsShow {w} {
    #
    # Display the parameters of this test
    #
    global currContext testConf

	tixLabelFrame $w.runParams -label "Run Parameters"
    
    global runParamsFrame
	set runParamsFrame [$w.runParams subwidget frame]

    frame $runParamsFrame.leftFrame

    # test params
    tixLabelFrame $runParamsFrame.testParams -label "Test Parameters"

    set testParamsFrame [$runParamsFrame.testParams subwidget frame]

	tixControl $testParamsFrame.trialCount -label "No. of Trials: " \
	           -integer true -min 1 -value [bgpSuite cget -numtrials] \
	           -options {
	    entry.width  4
	    label.width  18
	}
    fieldConf $testParamsFrame.trialCount trialCountInfo

    tixControl $testParamsFrame.percentRate -label "Max Rate (%): " \
               -integer false -min 1 -max 100 -value [bgpSuite cget -percentMaxRate] \
               -options {
        entry.width  4
        label.width  18
    }
    fieldConf $testParamsFrame.percentRate percentRateInfo

    tixControl $testParamsFrame.tolerance -label "Tolerance (%): " \
               -integer false -min 0 -max 100 -value [bgpSuite cget -tolerance] \
               -options {
        entry.width  4
        label.width  18
    }

    # bgp params
    tixLabelFrame $runParamsFrame.bgpParams -label "BGP Peer Parameters"

    set bgpParamsFrame [$runParamsFrame.bgpParams subwidget frame]

    tixControl $bgpParamsFrame.firstAsNumber -label "AS Number: " \
               -integer false -min 1 -value [bgpSuite cget -firstAsNumber] \
               -options {
        entry.width  8
        label.width  18
    }
    fieldConf $bgpParamsFrame.firstAsNumber firstAsNumberInfo

    tixControl $bgpParamsFrame.routesPerPeer -label "Routes Per Peer: " \
               -integer false -min 1 -value [bgpSuite cget -routesPerPeer] \
               -command bgpUpdateTotalDelay \
               -options {
        entry.width  8
        label.width  18
    }
    fieldConf $bgpParamsFrame.routesPerPeer routesPerPeerInfo

    tixComboBox $bgpParamsFrame.prefixLength -label "Prefix Length: " \
                -options {
        arrow.image       arrowImage
        arrow.width       14
        arrow.height      16
        arrow.borderWidth 1
        label.width       18
        entry.width       7
        listbox.height    1
    }
    fieldConf $bgpParamsFrame.prefixLength prefixLengthInfo

    $bgpParamsFrame.prefixLength subwidget entry configure -background white    
    $bgpParamsFrame.prefixLength configure -value [bgpSuite cget -prefixLength]
    $bgpParamsFrame.prefixLength insert end 16
    $bgpParamsFrame.prefixLength insert end 24

    tixControl $bgpParamsFrame.routeStep -label "Route Step: " \
               -integer false -min 0 -value [bgpSuite cget -routeStep] \
               -options {
        entry.width  8
        label.width  18
    }

    tixControl $bgpParamsFrame.delayTime -label "Delay (Seconds):" \
               -integer false -min 5 -value [bgpSuite cget -delayTime] \
               -options {
        entry.width  8
        label.width  18
    }

    set currContext(enableUserDelay) [bgpSuite cget -enableUserDelay]

    tixLabelEntry $bgpParamsFrame.networkIpAddress \
        -label "Network IP Address: " -options {
            entry.width  14
            label.width  18
        }

    $bgpParamsFrame.networkIpAddress subwidget entry delete 0 end
    $bgpParamsFrame.networkIpAddress subwidget entry insert 0 [bgpSuite cget -networkIPAddress]

    #pass/fail frame
    set passFail [ RouteCapacityPassFailFrame ]

    #pack test params
    pack $testParamsFrame.trialCount $testParamsFrame.percentRate $testParamsFrame.tolerance \
          -side top -padx 4 -pady 2 -anchor nw 
    #pack bgp params
    pack $bgpParamsFrame.firstAsNumber  $bgpParamsFrame.prefixLength \
         $bgpParamsFrame.routesPerPeer $bgpParamsFrame.routeStep \
         $bgpParamsFrame.delayTime \
         $bgpParamsFrame.networkIpAddress \
         -side top -padx 4 -pady 2 -anchor nw 

    #pack frames
    pack $testParamsFrame $bgpParamsFrame -side top -padx 4 -pady 1 -anchor nw
    pack $runParamsFrame.testParams $runParamsFrame.bgpParams $passFail -in $runParamsFrame.leftFrame -side top -padx 6 -anchor nw -fill x
    pack $runParamsFrame.leftFrame -side top -padx 4 -pady 1 -anchor nw

    return $w.runParams    
}

##################################################################################
# Create the setup window
##################################################################################
proc routeCapacityShow {} {
    sysSetupShow
    return [testSetupShow]
}

##################################################################################
# Update the variables and run the commands
##################################################################################
proc routeCapacityUpdate {} {
    sysSetupUpdate
    testSetupUpdate
}


####################################################
#
####################################################
proc enableUserDelayCmd {} {
    global currContext
    global runParamsFrame

    bgpSuite config -enableUserDelay $currContext(enableUserDelay)
    set bgpParamsFrame $runParamsFrame.bgpParams.border.frame
    if { $currContext(enableUserDelay) == "true" } {
        [$bgpParamsFrame.totalDelay subwidget label] configure -fg black
        setStateTixLabelEntry $bgpParamsFramee.advertiseDelay normal
    } else {
        [$bgpParamsFrame.totalDelay subwidget label] configure -fg grey50
        setStateTixLabelEntry $bgpParamsFrame.advertiseDelay disabled
    }
}


####################################################
#
####################################################
proc runParamsUpdate {} {
    dbgputs "enter runParamsUpdate"

    global runParamsFrame

    set testParamsFrame $runParamsFrame.testParams.border.frame
    set bgpParamsFrame $runParamsFrame.bgpParams.border.frame
    bgpSuite config -numtrials              [[$testParamsFrame.trialCount       subwidget entry] get]
    bgpSuite config -percentMaxRate         [[$testParamsFrame.percentRate      subwidget entry] get]
    bgpSuite config -firstAsNumber          [[$bgpParamsFrame.firstAsNumber    subwidget entry] get]
    bgpSuite config -routesPerPeer          [[$bgpParamsFrame.routesPerPeer    subwidget entry] get]
    bgpSuite config -prefixLength           [[$bgpParamsFrame.prefixLength     subwidget entry] get]
    bgpSuite config -networkIPAddress       [[$bgpParamsFrame.networkIpAddress subwidget entry] get]
    bgpSuite config -routeStep              [[$bgpParamsFrame.routeStep        subwidget entry] get]
    bgpSuite config -tolerance              [[$testParamsFrame.tolerance        subwidget entry] get]
    bgpSuite config -delayTime              [[$bgpParamsFrame.delayTime     subwidget entry] get]
    
    dbgputs "exit  runParamsUpdate"
}

####################################################
#
####################################################
proc runParamsSave {fileId} {
    dbgputs "enter runParamsSave $fileId"

    puts $fileId "bgpSuite config -numtrials                    [bgpSuite cget -numtrials]"
    puts $fileId "bgpSuite config -percentMaxRate               [bgpSuite cget -percentMaxRate]"
    puts $fileId "bgpSuite config -firstAsNumber                [bgpSuite cget -firstAsNumber]"
    puts $fileId "bgpSuite config -routesPerPeer                [bgpSuite cget -routesPerPeer]"
    puts $fileId "bgpSuite config -prefixLength                 [bgpSuite cget -prefixLength]"
    #puts $fileId "bgpSuite config -advertiseDelayPerRoute       [bgpSuite cget -advertiseDelayPerRoute]"
    puts $fileId "bgpSuite config -networkIPAddress             [bgpSuite cget -networkIPAddress]"
    puts $fileId "bgpSuite config -routeStep                    [bgpSuite cget -routeStep]"
    puts $fileId "bgpSuite config -tolerance                    [bgpSuite cget -tolerance]"
    puts $fileId "bgpSuite config -delayTime                 [  bgpSuite cget -delayTime]"
    #puts $fileId "bgpSuite config -enableUserDelay              [bgpSuite cget -enableUserDelay]"

    RouteCapacityThresholdSave $fileId

    puts $fileId ""
    puts $fileId "set testConf(ethernetType)      ethernetII"

    dbgputs "exit  runParamsSave"
}

##################################################################################
# Save the current test (i.e. test configuration) in a file
##################################################################################
proc routeCapacitySave {filename} {
    global fileEntry
    global routeCapacityAction
    global currContext

    routeCapacityUpdate

    set fileId [open $filename w]

    puts $fileId "# BGP/routeCapacity"
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

    puts $fileId $routeCapacityAction
    set currContext(realTimeSetup) routeCapacityRealtimeConfig
    close $fileId
}

 proc routeCapacityRealtimeConfig {txList rxList} {
    set statList [list   [list framesSent     $txList "Tx Frames per second" "Tx Frames" 1e0]\
                         [list framesReceived $rxList "Rx Frames per second" "Rx Frames" 1e0]\
                         [list bitsSent       $txList "Tx Kbps"              "Tx Kb"     1e3]\
                         [list bitsReceived   $rxList "Rx Kbps"              "Rx Kb"     1e3]\
                 ]
    openRealTimeTab "BGP: Route Capacity" $statList
 }
