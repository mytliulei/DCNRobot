#!/usr/bin/env tclsh
#

# proxy server to ixia, for RF

#version    :   1.0
#author     :   liuleic
#copyright  :   Copyright 2014, DigitalChina Network
#license    :   Apache License, Version 2.0
#mail       :   liuleic@digitalchina.com


package require IxTclHal


#process client connection
proc ProcessConn {channel clientaddr clientport} {
    #fconfigure $channel -blocking 0 -buffering line -encoding utf-8
    fconfigure $channel -blocking 0 -buffering line
    fileevent $channel readable [list IxiaCmd $channel]
}

#process ixia cmd
proc IxiaCmd {chan} {
    #global logfid
    set err "eof close channel"
    if { [catch {gets $chan line} err] || [eof $chan] } {
        #puts $logfid $err
        #flush $logfid
        close $chan
    } else {
        #eval ixia cmd
        if {$line != ""} {
            set cmdret [evalIxiaCmd $line $chan]
            puts $chan $cmdret
            flush $chan
            if {$cmdret == -10000} {
                exit 0
            }
        }
    }
}

#generat ixia cmd string
#error code -900 - -999
proc evalIxiaCmd {cmdstr chan} {
    set cmdstr [string trim $cmdstr]
    set cmdlist [split $cmdstr]
    set cmdname [lindex $cmdlist 0]
    set cmdstr [join [lrange $cmdlist 1 end]]
    set result ""
    #global logfid
    #puts $logfid "$cmdname started"
    #flush $logfid
    switch -exact $cmdname {
        "set_stream_from_hexstr" {
            if {[catch {set ret [SetStreamFromHexstr $cmdstr]} result]} {
                set ret -999
            }
        }
        "start_transmit" {
            if {[catch {set ret [StartTransmit $cmdstr]} result]} {
                set ret -998
            }
        }
        "stop_transmit" {
            if {[catch {set ret [StopTransmit $cmdstr]} result]} {
                set ret -997
            }
        }
        "get_statistics" {
            if {[catch {set ret [GetStatistics $cmdstr]} result]} {
                set ret -996
            }
        }
        "start_capture" {
            if {[catch {set ret [StartCapture $cmdstr]} result]} {
                set ret -995
            }
        }
        "stop_capture" {
            if {[catch {set ret [StopCapture $cmdstr]} result]} {
                set ret -994
            }
        }
        "check_transmit_done" {
            if {[catch {set ret [CheckTransmitDone $cmdstr]} result]} {
                set ret -993
            }
        }
        "clear_statics" {
            if {[catch {set ret [ClearStatistics $cmdstr]} result]} {
                set ret -992
            }
        }
        "get_capture_packet" {
            if {[catch {set ret [GetCapturePacket $cmdstr]} result]} {
                set ret -991
            }
        }
        "get_capture_packet_num"  {
            if {[catch {set ret [GetCapturePacketNum $cmdstr]} result]} {
                set ret -990
            }
        }
        "shutdown_proxy_server" {
            if {[catch {set ret [ShutdownProxyserver]} result]} {
                set ret -989
            }
        }
        "set_port_mode_default" {
            if {[catch {set ret [SetPortModeDefault $cmdstr]} result]} {
                set ret -988
            }
        }
        "set_stream_control" {
            if {[catch {set ret [SetStreamControl $cmdstr]} result]} {
                set ret -987
            }
        }
        "set_stream_enable" {
            if {[catch {set ret [SetStreamEnable $cmdstr]} result]} {
                set ret -986
            }
        }
        "connect_ixia" {
            if {[catch {set ret [ConnectToIxia $cmdstr]} result]} {
                set ret -985
            }
        }
        "set_stream_from_ixiaapi" {
            if {[catch {set ret [SetStreamFromIxiaAPI $cmdstr]} result]} {
                set ret -984
            }
        }
        "test_proxy_server" {
            if {[catch {set ret [Test_Proxy_Server $cmdstr]} result]} {
                set ret -983
            }
        }
        "set_port_speed_duplex" {
            if {[catch {set ret [SetPortSpeedDuplex $cmdstr]} result]} {
                set ret -982
            }
        }
        "set_port_flowcontrol" {
            if {[catch {set ret [SetPortFlowControl $cmdstr]} result]} {
                set ret -981
            }
        }
        "set_port_config_default" {
            if {[catch {set ret [SetPortConfigDefault $cmdstr]} result]} {
                set ret -980
            }
        }
        "set_port_ignorelink" {
            if {[catch {set ret [SetPortIgnoreLink $cmdstr]} result]} {
                set ret -979
            }
        }
        "get_statistics_for_timeout" {
            if {[catch {set ret [GetStatisticsTimeout $cmdstr]} result]} {
                set ret -978
            }
        }
        "set_port_filters_enable" {
            if {[catch {set ret [SetPortFiltersEnable $cmdstr]} result]} {
                set ret -977
            }
        }
        "get_capture_packet_timestamp" {
            if {[catch {set ret [GetCapturePacketTimestamp $cmdstr]} result]} {
                set ret -976
            }
        }
        "create_portgroup_id" {
            if {[catch {set ret [CreatePortgroupId $cmdstr]} result]} {
                set ret -975
            }
        }
        "add_port_to_portgroup" {
            if {[catch {set ret [AddPortToPortgroup $cmdstr]} result]} {
                set ret -974
            }
        }
        "del_port_to_portgroup" {
            if {[catch {set ret [DelPortToPortgroup $cmdstr]} result]} {
                set ret -973
            }
        }
        "destroy_portgroup_id" {
            if {[catch {set ret [DestroyPortgroupId $cmdstr]} result]} {
                set ret -972
            }
        }
        "set_cmd_to_portgroup" {
            if {[catch {set ret [SetCmdToPortgroup $cmdstr]} result]} {
                set ret -971
            }
        }
        "set_port_transmit_mode" {
            if {[catch {set ret [SetPortTransmitMode $cmdstr]} result]} {
                set ret -970
            }
        }
        default {
            set ret -900
        }
    }
    if {$ret < -900 && $ret >= -999} {
        #puts $logfid "err:$ret"
        #flush $logfid
        puts $chan $ret
        flush $chan
        append result "ixia proxy error buffer end"
        set ret $result
    }
    #puts $logfid "rtc:$ret"
    #flush $logfid
    return $ret
}

#set ixia stream from hexstring
#err code : 1200-1299
proc SetStreamFromHexstr {cmdstr} {
    set cmdlist [split $cmdstr]
    set cmdlen [llength $cmdlist]
    if {$cmdlen <= 4} {
        return -100
    }
    global ixia_ip
    if {[ConnectToIxia $ixia_ip] != 0 } {
        return -400
    }
    set chasId [GetIxiaChassID $ixia_ip]
    set x [lindex $cmdlist 0]
    set port [lindex $cmdlist 1]
    set card [lindex $cmdlist 2]
    if {[IxiaLogin $chasId $port $card] != 0} {
        return -401
    }
    set streamId [lindex $cmdlist 3]
    # set streamRateMode [lindex $cmdlist 4]
    # set streamRate [lindex $cmdlist 5]
    # set streamMode [lindex $cmdlist 6]
    # set numFrames [lindex $cmdlist 7]
    # set ReturnId [lindex $cmdlist 8]
    set packet [lindex $cmdlist 4]
    set dstmac [string trim [join [split [string range $packet 0 17] "#"]]]
    set srcmac [string trim [join [split [string range $packet 18 35] "#"]]]
    set pattern [string trim [join [split [string range $packet 36 end] "#"]]]
    set portlist [list [list $chasId $port $card]]
    set packetlen [expr [llength [split $packet "#"]] + 4]
    #ixia config
    stream setDefault
    # #streamRateMode
    # # 0: usePercentRate
    # # 1: streamRateModeFps
    # # 2: streamRateModeBps
    # if {$streamRateMode == 0} {
    #     stream config -rateMode usePercentRate
    #     stream config -percentPacketRate $streamRate
    # } elseif {$streamRateMode == 1} {
    #     stream config -rateMode streamRateModeFps
    #     stream config -fpsRate $streamRate
    # } elseif {$streamRateMode == 2} {
    #     stream config -rateMode streamRateModeBps
    #     stream config -bpsRate $streamRate
    # }
    # #stream Mode
    # # 0: continuous
    # # 1: end
    # # 2: advance
    # # 3: return to ID
    # if {$streamMode == 0} {
    #     stream config -dma contPacket
    # } elseif {$streamMode == 1} {
    #     stream config -numFrames $numFrames
    #     stream config -dma stopStream
    # } elseif {$streamMode == 2} {
    #     stream config -numFrames $numFrames
    #     stream config -dma advance
    # } elseif {$streamMode == 3} {
    #     stream config -numFrames $numFrames
    #     stream config -dma gotoFirst
    #     stream config -returnToId $ReturnId
    # }
    stream config -sa $srcmac
    stream config -da $dstmac
    stream config -frameSizeType sizeFixed
    stream config -framesize $packetlen
    stream config -frameSizeMIN $packetlen
    stream config -frameSizeMAX $packetlen
    stream config -patternType nonRepeat
    stream config -dataPattern userpattern
    stream config -pattern $pattern
    stream config -frameType "08 00"
    protocol setDefault
    stream set $chasId $port $card $streamId
    ixWriteConfigToHardware portlist -noProtocolServer
    return 0
}

#set ixia port mode default
#err code : 1300-1399
proc SetPortModeDefault {cmdstr} {
    set cmdlist [split $cmdstr]
    set cmdlen [llength $cmdlist]
    if {$cmdlen != 3} {
        return -100
    }
    global ixia_ip
    if {[ConnectToIxia $ixia_ip] != 0} {
        return -400
    }
    set chasId [GetIxiaChassID $ixia_ip]
    set x [lindex $cmdlist 0]
    set port [lindex $cmdlist 1]
    set card [lindex $cmdlist 2]
    if {[IxiaLogin $chasId $port $card] != 0} {
        return -401
    }
    set portlist [list [list $chasId $port $card]]
    set ret [port setModeDefaults $chasId $port $card]
    ixWriteConfigToHardware portlist
    return $ret
}

#start ixia stream
proc StartTransmit {cmdstr} {
    set cmdlist [split $cmdstr]
    set cmdlen [llength $cmdlist]
    if {[expr $cmdlen % 3] != 0} {
        return -100
    }
    global ixia_ip
    if {[ConnectToIxia $ixia_ip] != 0} {
        return -400
    }
    set chasId [GetIxiaChassID $ixia_ip]
    set ret 0
    foreach {x port card} $cmdlist {
        IxiaLogin $chasId $port $card
        set portlist [list [list $chasId $port $card]]
        set res [ixStartTransmit portlist]
        set ret [expr $ret + $res]
    }
    return $ret
}

#stop ixia stream
#err code : 1400-1499
proc StopTransmit {cmdstr} {
    set cmdlist [split $cmdstr]
    set cmdlen [llength $cmdlist]
    if {[expr $cmdlen % 3] != 0} {
        return -100
    }
    global ixia_ip
    if {[ConnectToIxia $ixia_ip] != 0} {
        return -400
    }
    set chasId [GetIxiaChassID $ixia_ip]
    set ret 0
    foreach {x port card} $cmdlist {
        IxiaLogin $chasId $port $card
        set portlist [list [list $chasId $port $card]]
        set res [ixStopTransmit portlist]
        set ret [expr $ret + $res]
    }
    return $ret
}

#get ixia statistics
#err code : 1500-1599
proc GetStatistics {cmdstr} {
    set cmdlist [split $cmdstr]
    set cmdlen [llength $cmdlist]
    if {$cmdlen <= 3} {
        return -100
    }
    global ixia_ip
    if {[ConnectToIxia $ixia_ip] != 0} {
        return -400
    }
    set chasId [GetIxiaChassID $ixia_ip]
    set x [lindex $cmdlist 0]
    set port [lindex $cmdlist 1]
    set card [lindex $cmdlist 2]
    if {[IxiaLogin $chasId $port $card] != 0} {
        return -401
    }
    set portlist [list [list $chasId $port $card] ]
    set ret ""
    set statlist [lrange $cmdlist 3 end]
    foreach stat_type $statlist {
        switch -exact $stat_type {
            "txpps" {
                stat getRate statframesSent $chasId $port $card
                set statnum [stat cget -framesSent]
                lappend ret $statnum
            }
            "txBps" {
                stat getRate statbytesSent $chasId $port $card
                set statnum [stat cget -bytesSent]
                lappend ret $statnum
            }
            "txbps" {
                stat getRate statbitsSent $chasId $port $card
                set statnum [stat cget -bitsSent]
                lappend ret $statnum
            }
            "txpackets" {
                stat get statframesSent $chasId $port $card
                set statnum [stat cget -framesSent]
                lappend ret $statnum
            }
            "txbytes" {
                stat get statbytesSent $chasId $port $card
                set statnum [stat cget -bytesSent]
                lappend ret $statnum
            }
            "txbits" {
                stat get statbitsSent $chasId $port $card
                set statnum [stat cget -bitsSent]
                lappend ret $statnum
            }
            "rxpps" {
                stat getRate statframesReceived $chasId $port $card
                set statnum [stat cget -framesReceived]
                lappend ret $statnum
            }
            "rxBps" {
                stat getRate statbytesReceived $chasId $port $card
                set statnum [stat cget -bytesReceived]
                lappend ret $statnum
            }
            "rxbps" {
                stat getRate statbitsReceived $chasId $port $card
                set statnum [stat cget -bitsReceived]
                lappend ret $statnum
            }
            "rxpackets" {
                stat get statframesReceived $chasId $port $card
                set statnum [stat cget -framesReceived]
                lappend ret $statnum
            }
            "rxbytes" {
                stat get statbytesReceived $chasId $port $card
                set statnum [stat cget -bytesReceived]
                lappend ret $statnum
            }
            "rxbits" {
                stat get statbitsReceived $chasId $port $card
                set statnum [stat cget -bitsReceived]
                lappend ret $statnum
            }
            "updown" {
                stat get statlink $chasId $port $card
                set statnum [stat cget -link]
                if {$statnum != 1} {
                    set statnum 0
                }
                lappend ret $statnum
            }
            "txstate" {
                stat get allStats $chasId $port $card
                set statnum [stat cget -transmitState]
                lappend ret $statnum
            }
            "lineSpeed" {
                stat get allStats $chasId $port $card
                set statnum [stat cget -lineSpeed]
                lappend ret $statnum
            }
            "duplex" {
                stat get allStats $chasId $port $card
                set statnum [stat cget -duplexMode]
                lappend ret $statnum
            }
            "flowControlFrames" {
                stat get allStats $chasId $port $card
                set statnum [stat cget -flowControlFrames]
                lappend ret $statnum
            }
            "rxIpv4Packets" {
                stat get allStats $chasId $port $card
                set statnum [stat cget -ipPackets]
                lappend ret $statnum
            }
            "rxUdpPackets" {
                stat get allStats $chasId $port $card
                set statnum [stat cget -udpPackets]
                lappend ret $statnum
            }
            "rxTcpPackets" {
                stat get allStats $chasId $port $card
                set statnum [stat cget -tcpPackets]
                lappend ret $statnum
            }
            "userStat1" {
                stat get allStats $chasId $port $card
                set statnum [stat cget -userDefinedStat1]
                lappend ret $statnum
            }
            "userStat2" {
                stat get allStats $chasId $port $card
                set statnum [stat cget -userDefinedStat2]
                lappend ret $statnum
            }
            "captureFilter" {
                stat get allStats $chasId $port $card
                set statnum [stat cget -captureFilter]
                lappend ret $statnum
            }
            "captureTrigger" {
                stat get allStats $chasId $port $card
                set statnum [stat cget -captureTrigger]
                lappend ret $statnum
            }
            "userStat1_pps" {
                stat getRate statUserDefinedStat1 $chasId $port $card
                set statnum [stat cget -userDefinedStat1]
                lappend ret $statnum
            }
            "userStat2_pps" {
                stat getRate statUserDefinedStat2 $chasId $port $card
                set statnum [stat cget -userDefinedStat2]
                lappend ret $statnum
            }
            "captureFilter_pps" {
                stat getRate statCaptureFilter $chasId $port $card
                set statnum [stat cget -captureFilter]
                lappend ret $statnum
            }
            "captureTrigger_pps" {
                stat getRate statCaptureTrigger $chasId $port $card
                set statnum [stat cget -captureTrigger]
                lappend ret $statnum
            }
        }
    }
    set retstr [join $ret]
    return $retstr
}

#clear ixia statistics
#err code : 1600-1699
proc ClearStatistics {cmdstr} {
    set cmdlist [split $cmdstr]
    set cmdlen [llength $cmdlist]
    if {[expr $cmdlen % 3] != 0} {
        return -100
    }
    global ixia_ip
    if {[ConnectToIxia $ixia_ip] != 0} {
        return -400
    }
    set chasId [GetIxiaChassID $ixia_ip]
    set ret 0
    # set x [lindex $cmdlist 0]
    # set port [lindex $cmdlist 1]
    # set card [lindex $cmdlist 2]
    # set portlist [list [list $chasId $port $card]]
    # set ret [ixClearPortStats portlist]
    foreach {x port card} $cmdlist {
        IxiaLogin $chasId $port $card
        set res [ixClearPortStats $chasId $port $card]
        set ret [expr $ret + $res]
    }
    return $ret
}

#start capture
#err code : 1700-1799
proc StartCapture {cmdstr} {
    set cmdlist [split $cmdstr]
    set cmdlen [llength $cmdlist]
    if {[expr $cmdlen % 3] != 0} {
        return -100
    }
    global ixia_ip
    if {[ConnectToIxia $ixia_ip] != 0} {
        return -400
    }
    set chasId [GetIxiaChassID $ixia_ip]
    set ret 0
    foreach {x port card} $cmdlist {
        IxiaLogin $chasId $port $card
        set portlist [list [list $chasId $port $card]]
        set res [ixStartCapture portlist]
        set ret [expr $ret + $res]
    }
    return $ret
}

#start capture
#err code : 1800-1899
proc StopCapture {cmdstr} {
    set cmdlist [split $cmdstr]
    set cmdlen [llength $cmdlist]
    if {[expr $cmdlen % 3] != 0} {
        return -100
    }
    global ixia_ip
    if {[ConnectToIxia $ixia_ip] != 0} {
        return -400
    }
    set chasId [GetIxiaChassID $ixia_ip]
    set ret 0
    foreach {x port card} $cmdlist {
        IxiaLogin $chasId $port $card
        set portlist [list [list $chasId $port $card]]
        set res [ixStopCapture portlist]
        set ret [expr $ret + $res]
    }
    return $ret
}

#check transmit done
proc CheckTransmitDone {cmdstr} {
    set cmdlist [split $cmdstr]
    set cmdlen [llength $cmdlist]
    if {$cmdlen != 3} {
        return -100
    }
    global ixia_ip
    if {[ConnectToIxia $ixia_ip] != 0} {
        return -400
    }
    set chasId [GetIxiaChassID $ixia_ip]
    set x [lindex $cmdlist 0]
    set port [lindex $cmdlist 1]
    set card [lindex $cmdlist 2]
    if {[IxiaLogin $chasId $port $card] != 0} {
        return -401
    }
    set portlist [list [list $chasId $port $card]]
    set ret [ixCheckTransmitDone portlist]
    return $ret
}

#get capture packet
#err code : 1100-1199
proc GetCapturePacket {cmdstr} {
    set cmdlist [split $cmdstr]
    set cmdlen [llength $cmdlist]
    if {$cmdlen != 5} {
        return -100
    }
    global ixia_ip
    if {[ConnectToIxia $ixia_ip] != 0} {
        return -400
    }
    set chasId [GetIxiaChassID $ixia_ip]
    set x [lindex $cmdlist 0]
    set port [lindex $cmdlist 1]
    set card [lindex $cmdlist 2]
    if {[IxiaLogin $chasId $port $card] != 0} {
        return -401
    }
    set fromPacket [lindex $cmdlist 3]
    set toPacket [lindex $cmdlist 4]
    if {$fromPacket < 1} {
        return -1103
    }
    if {$fromPacket > $toPacket} {
        return -1102
    }
    set capres [capture get $chasId $port $card]
    if {$capres != 0} {
        return -1101
    }
    set capnum [capture cget -nPackets]
    if {$capnum == 0} {
        return ""
    }
    if {$capnum < $toPacket} {
        set toPacket $capnum
    }
    if {$fromPacket > $toPacket} {
        return ""
    }
    set capres [captureBuffer get $chasId $port $card $fromPacket $toPacket]
    if {$capres != 0} {
        return -1104
    }
    set ret ""
    set plen [expr $toPacket - $fromPacket + 1]
    for {set i 1} {$i <= $plen} {incr i} {
        set ires [captureBuffer getframe $i]
        if {$ires == 0} {
            set data [captureBuffer cget -frame]
            set data [string range $data 0 end-12]
            lappend ret $data
        }
    }
    set retstr [join $ret "$"]
    return $retstr
}

#get capture packet Num
#err code : 1900-1999
proc GetCapturePacketNum {cmdstr} {
    set cmdlist [split $cmdstr]
    set cmdlen [llength $cmdlist]
    if {$cmdlen != 3} {
        return -100
    }
    global ixia_ip
    if {[ConnectToIxia $ixia_ip] != 0} {
        return -400
    }
    set chasId [GetIxiaChassID $ixia_ip]
    set x [lindex $cmdlist 0]
    set port [lindex $cmdlist 1]
    set card [lindex $cmdlist 2]
    if {[IxiaLogin $chasId $port $card] != 0} {
        return -401
    }
    #set portlist [list [list $chasId $port $card]]
    capture get $chasId $port $card
    set ret [capture cget -nPackets]
    return $ret
}

#set_stream_control
#err code : 2000-2099
proc SetStreamControl {cmdstr} {
    set cmdlist [split $cmdstr]
    set cmdlen [llength $cmdlist]
    if {$cmdlen <= 8} {
        return -100
    }
    global ixia_ip
    if {[ConnectToIxia $ixia_ip] != 0 } {
        return -400
    }
    set chasId [GetIxiaChassID $ixia_ip]
    set x [lindex $cmdlist 0]
    set port [lindex $cmdlist 1]
    set card [lindex $cmdlist 2]
    if {[IxiaLogin $chasId $port $card] != 0} {
        return -401
    }
    set streamId [lindex $cmdlist 3]
    set streamRateMode [lindex $cmdlist 4]
    set streamRate [lindex $cmdlist 5]
    set streamMode [lindex $cmdlist 6]
    set numFrames [lindex $cmdlist 7]
    set ReturnId [lindex $cmdlist 8]

    #stream setDefault
    #streamRateMode
    # 0: usePercentRate
    # 1: streamRateModeFps
    # 2: streamRateModeBps
    if {$streamRateMode == 0} {
        stream config -rateMode usePercentRate
        stream config -percentPacketRate $streamRate
    } elseif {$streamRateMode == 1} {
        stream config -rateMode streamRateModeFps
        stream config -fpsRate $streamRate
    } elseif {$streamRateMode == 2} {
        stream config -rateMode streamRateModeBps
        stream config -bpsRate $streamRate
    }
    #stream Mode
    # 0: continuous
    # 1: end
    # 2: advance
    # 3: return to ID
    if {$streamMode == 0} {
        stream config -dma contPacket
    } elseif {$streamMode == 1} {
        stream config -numFrames $numFrames
        stream config -dma stopStream
    } elseif {$streamMode == 2} {
        stream config -numFrames $numFrames
        stream config -dma advance
    } elseif {$streamMode == 3} {
        stream config -numFrames $numFrames
        stream config -dma gotoFirst
        stream config -returnToId $ReturnId
    }
    stream set $chasId $port $card $streamId
    set portlist [list [list $chasId $port $card]]
    ixWriteConfigToHardware portlist
    return 0
}

#set_stream_enable
#err code : 2100-2199
proc SetStreamEnable {cmdstr} {
    set cmdlist [split $cmdstr]
    set cmdlen [llength $cmdlist]
    if {$cmdlen <= 4} {
        return -100
    }
    global ixia_ip
    ixDisconnectFromChassis $ixia_ip
    if {[ConnectToIxia $ixia_ip] != 0 } {
        return -400
    }
    set chasId [GetIxiaChassID $ixia_ip]
    set x [lindex $cmdlist 0]
    set port [lindex $cmdlist 1]
    set card [lindex $cmdlist 2]
    if {[IxiaLogin $chasId $port $card] != 0} {
        return -401
    }
    set streamId [lindex $cmdlist 3]
    set enable [lindex $cmdlist 4]
    set portlist [list [list $chasId $port $card]]
    #stream setDefault
    if {$enable == 1} {
        stream config -enable true
    } else {
        stream config -enable false
    }
    stream set $chasId $port $card $streamId
    ixWriteConfigToHardware portlist
    return 0
}

#set_stream_from_ixiaapi
#err code : 2200-2299
proc SetStreamFromIxiaAPI {cmdstr} {
    set cmdlist [split $cmdstr]
    set cmdlen [llength $cmdlist]
    if {$cmdlen <= 5} {
        return -100
    }
    global ixia_ip
    if {[ConnectToIxia $ixia_ip] != 0 } {
        return -400
    }
    global logflag
    global logfid
    set chasId [GetIxiaChassID $ixia_ip]
    set x [lindex $cmdlist 0]
    set port [lindex $cmdlist 1]
    set card [lindex $cmdlist 2]
    if {[IxiaLogin $chasId $port $card] != 0} {
        return -401
    }
    set streamId [lindex $cmdlist 3]
    set fcs [lindex $cmdlist 4]
    set packetlist [lrange $cmdlist 5 end]
    set packet [join $packetlist " "]
    if {$logflag == 1} {
        puts $logfid $packet
    }
    set pktlist [split $packet "$"]
    stream setDefault
    if {$logflag == 1} {
        puts $logfid "stream setDefault"
    }
    foreach {xcmd ycmd} $pktlist {
        set xcmdlist [split $xcmd "@"]
        set ycmdlist [split $ycmd "@"]
        set ilist 0
        foreach icmd $xcmdlist {
            set icmdlist [split $icmd "!"]
            foreach ecmd $icmdlist {
                eval $ecmd
                if {$logflag == 1} {
                    puts $logfid $ecmd
                }
            }
            set wcmd [lindex $ycmdlist $ilist]
            if {$wcmd != "none"} {
                set ewcmd "$wcmd $chasId $port $card"
                eval $ewcmd
                if {$logflag == 1} {
                    puts $logfid $ewcmd
                }
            }
            incr ilist
        }
    }
    stream config -fcs $fcs
    stream set $chasId $port $card $streamId
    set portlist [list [list $chasId $port $card]]
    set ret [ixWriteConfigToHardware portlist -noProtocolServer]
    if {$logflag == 1} {
        puts $logfid "stream set $chasId $port $card $streamId"
        puts $logfid "ixWriteConfigToHardware portlist -noProtocolServer"
    }
    return $ret
}

#test_proxy_server
#err code : 2300-2399
proc Test_Proxy_Server {cmdstr} {
    set cmdlist [split $cmdstr]
    set cmdlen [llength $cmdlist]
    set cmd_type [lindex $cmdlist 0]
    switch -exact $cmd_type {
        "alive" {
            return 0
        }
        "connect" {
            set ip [lindex $cmdlist 1]
            set ret [ConnectToIxia $ip]
            return $ret
        }
        default {
            set ret -2399
            return $ret
        }
    }
}

#set_port_speed_duplex
#err code : 2400-2499
proc SetPortSpeedDuplex {cmdstr} {
    set cmdlist [split $cmdstr]
    set cmdlen [llength $cmdlist]
    if {$cmdlen <= 4} {
        return -100
    }
    global ixia_ip
    ixDisconnectFromChassis $ixia_ip
    if {[ConnectToIxia $ixia_ip] != 0 } {
        return -400
    }
    set chasId [GetIxiaChassID $ixia_ip]
    set x [lindex $cmdlist 0]
    set port [lindex $cmdlist 1]
    set card [lindex $cmdlist 2]
    if {[IxiaLogin $chasId $port $card] != 0} {
        return -401
    }
    set mode [lindex $cmdlist 3]
    set negstr [lindex $cmdlist 4]
    set portlist [list [list $chasId $port $card]]
    #port setDefault
    if {$mode == 0} {
        port config -duplex full
        port config -autonegotiate true
        port config -advertise100FullDuplex true
        port config -advertise100HalfDuplex true
        port config -advertise10FullDuplex true
        port config -advertise10HalfDuplex true
        port config -advertise1000FullDuplex true
    } elseif {$mode == 1} {
        port config -speed 1000
        port config -duplex full
        port config -autonegotiate false
        port config -advertise100FullDuplex false
        port config -advertise100HalfDuplex false
        port config -advertise10FullDuplex false
        port config -advertise10HalfDuplex false
        port config -advertise1000FullDuplex true
    } elseif {$mode == 2} {
        port config -speed 100
        port config -duplex full
        port config -autonegotiate false
        port config -advertise100FullDuplex true
        port config -advertise100HalfDuplex false
        port config -advertise10FullDuplex false
        port config -advertise10HalfDuplex false
        port config -advertise1000FullDuplex false
    } elseif {$mode == 3} {
        port config -speed 100
        port config -duplex half
        port config -autonegotiate false
        port config -advertise100FullDuplex false
        port config -advertise100HalfDuplex true
        port config -advertise10FullDuplex false
        port config -advertise10HalfDuplex false
        port config -advertise1000FullDuplex false
    } elseif {$mode == 4} {
        port config -speed 10
        port config -duplex full
        port config -autonegotiate false
        port config -advertise100FullDuplex false
        port config -advertise100HalfDuplex false
        port config -advertise10FullDuplex true
        port config -advertise10HalfDuplex false
        port config -advertise1000FullDuplex false
    } elseif {$mode == 5} {
        port config -speed 10
        port config -duplex half
        port config -autonegotiate false
        port config -advertise100FullDuplex false
        port config -advertise100HalfDuplex false
        port config -advertise10FullDuplex false
        port config -advertise10HalfDuplex true
        port config -advertise1000FullDuplex false
    } elseif {$mode == 6} {
        port config -autonegotiate false
    } elseif {$mode == -1} {
        port config -autonegotiate true
        port config -advertise100FullDuplex false
        port config -advertise100HalfDuplex false
        port config -advertise10FullDuplex false
        port config -advertise10HalfDuplex false
        port config -advertise1000FullDuplex false
        set neglist [split $negstr ";"]
        foreach negx $neglist {
            switch -exact $negx {
                "1" {
                    port config -advertise1000FullDuplex true
                }
                "2" {
                    port config -advertise100FullDuplex true
                }
                "3" {
                    port config -advertise100HalfDuplex true
                }
                "4" {
                    port config -advertise10FullDuplex true
                }
                "5" {
                    port config -advertise10HalfDuplex true
                }
            }
        }
    } else {

    }
    port set $chasId $port $card
    #ixWriteConfigToHardware portlist
    ixWritePortsToHardware portlist
    return 0
}

#set_port_flowcontrol
#err code : 2500-2599
proc SetPortFlowControl {cmdstr} {
    set cmdlist [split $cmdstr]
    set cmdlen [llength $cmdlist]
    if {$cmdlen <= 3} {
        return -100
    }
    global ixia_ip
    ixDisconnectFromChassis $ixia_ip
    if {[ConnectToIxia $ixia_ip] != 0 } {
        return -400
    }
    set chasId [GetIxiaChassID $ixia_ip]
    set x [lindex $cmdlist 0]
    set port [lindex $cmdlist 1]
    set card [lindex $cmdlist 2]
    if {[IxiaLogin $chasId $port $card] != 0} {
        return -401
    }
    set mode [lindex $cmdlist 3]
    set portlist [list [list $chasId $port $card]]
    if {[port get $chasId $port $card] == 0} {
        set phy_now [port cget -phyMode]
        port setPhyMode $phy_now $chasId $port $card
    }
    #port setDefault
    if {$mode == 0} {
        port config -flowControl false
        port config -advertiseAbilities portAdvertiseNone
    } elseif {$mode == 1} {
        port config -flowControl true
        port config -advertiseAbilities portAdvertiseSendAndOrReceive
    } else {

    }
    port set $chasId $port $card
    #ixWriteConfigToHardware portlist
    ixWritePortsToHardware portlist
    return 0
}

#set_port_config_default
#err code : 2600-2699
proc SetPortConfigDefault {cmdstr} {
    set cmdlist [split $cmdstr]
    set cmdlen [llength $cmdlist]
    if {$cmdlen != 3} {
        return -100
    }
    global ixia_ip
    ixDisconnectFromChassis $ixia_ip
    if {[ConnectToIxia $ixia_ip] != 0} {
        return -400
    }
    set chasId [GetIxiaChassID $ixia_ip]
    set x [lindex $cmdlist 0]
    set port [lindex $cmdlist 1]
    set card [lindex $cmdlist 2]
    if {[IxiaLogin $chasId $port $card] != 0} {
        return -401
    }
    set portlist [list [list $chasId $port $card]]
    if {[port get $chasId $port $card] == 0} {
        set phy_now [port cget -phyMode]
    }
    #set ret [port setModeDefaults $chasId $port $card]
    set ret [port setFactoryDefaults $chasId $port $card]
    port setPhyMode $phy_now $chasId $port $card
    ixWritePortsToHardware portlist
    return $ret
}

#set_port_ignorelink
#err code : 2700-2799
proc SetPortIgnoreLink {cmdstr} {
    set cmdlist [split $cmdstr]
    set cmdlen [llength $cmdlist]
    if {$cmdlen <= 3} {
        return -100
    }
    global ixia_ip
    ixDisconnectFromChassis $ixia_ip
    if {[ConnectToIxia $ixia_ip] != 0 } {
        return -400
    }
    set chasId [GetIxiaChassID $ixia_ip]
    set x [lindex $cmdlist 0]
    set port [lindex $cmdlist 1]
    set card [lindex $cmdlist 2]
    if {[IxiaLogin $chasId $port $card] != 0} {
        return -401
    }
    set flag [lindex $cmdlist 3]
    set portlist [list [list $chasId $port $card]]
    #port setDefault
    if {$flag == 0} {
        set ret [port config -ignoreLink false]
    } elseif {$flag == 1} {
        set ret [port config -ignoreLink true]
    } else {
        set ret 2700
    }
    port set $chasId $port $card
    #ixWriteConfigToHardware portlist
    ixWritePortsToHardware portlist
    return 0
}

#get ixia statistics
#err code : 2800-2899
proc GetStatisticsTimeout {cmdstr} {
    set cmdlist [split $cmdstr]
    set cmdlen [llength $cmdlist]
    if {$cmdlen <= 4} {
        return -100
    }
    global ixia_ip
    if {[ConnectToIxia $ixia_ip] != 0} {
        return -400
    }
    set chasId [GetIxiaChassID $ixia_ip]
    set x [lindex $cmdlist 0]
    set port [lindex $cmdlist 1]
    set card [lindex $cmdlist 2]
    if {[IxiaLogin $chasId $port $card] != 0} {
        return -401
    }
    set portlist [list [list $chasId $port $card] ]
    set ret ""
    set statis [lindex $cmdlist 3]
    set timeout [lindex $cmdlist 4]
    switch -exact $statis {
        "txpps" {
            stat getRate statframesSent $chasId $port $card
            set statnum1 [stat cget -framesSent]
            after $timeout
            stat getRate statframesSent $chasId $port $card
            set statnum2 [stat cget -framesSent]
            lappend ret $statnum1
            lappend ret $statnum2
        }
        "txBps" {
            stat getRate statbytesSent $chasId $port $card
            set statnum1 [stat cget -bytesSent]
            after $timeout
            stat getRate statbytesSent $chasId $port $card
            set statnum2 [stat cget -bytesSent]
            lappend ret $statnum1
            lappend ret $statnum2
        }
        "txbps" {
            stat getRate statbitsSent $chasId $port $card
            set statnum1 [stat cget -bitsSent]
            after $timeout
            stat getRate statbitsSent $chasId $port $card
            set statnum2 [stat cget -bitsSent]
            lappend ret $statnum1
            lappend ret $statnum2
        }
        "txpackets" {
            stat get statframesSent $chasId $port $card
            set statnum1 [stat cget -framesSent]
            after $timeout
            stat get statframesSent $chasId $port $card
            set statnum2 [stat cget -framesSent]
            lappend ret $statnum1
            lappend ret $statnum2
        }
        "txbytes" {
            stat get statbytesSent $chasId $port $card
            set statnum1 [stat cget -bytesSent]
            after $timeout
            stat get statbytesSent $chasId $port $card
            set statnum2 [stat cget -bytesSent]
            lappend ret $statnum1
            lappend ret $statnum2
        }
        "txbits" {
            stat get statbitsSent $chasId $port $card
            set statnum1 [stat cget -bitsSent]
            after $timeout
            stat get statbitsSent $chasId $port $card
            set statnum2 [stat cget -bitsSent]
            lappend ret $statnum1
            lappend ret $statnum2
        }
        "rxpps" {
            stat getRate statframesReceived $chasId $port $card
            set statnum1 [stat cget -framesReceived]
            after $timeout
            stat getRate statframesReceived $chasId $port $card
            set statnum2 [stat cget -framesReceived]
            lappend ret $statnum1
            lappend ret $statnum2
        }
        "rxBps" {
            stat getRate statbytesReceived $chasId $port $card
            set statnum1 [stat cget -bytesReceived]
            after $timeout
            stat getRate statbytesReceived $chasId $port $card
            set statnum2 [stat cget -bytesReceived]
            lappend ret $statnum1
            lappend ret $statnum2
        }
        "rxbps" {
            stat getRate statbitsReceived $chasId $port $card
            set statnum1 [stat cget -bitsReceived]
            after $timeout
            stat getRate statbitsReceived $chasId $port $card
            set statnum2 [stat cget -bitsReceived]
            lappend ret $statnum1
            lappend ret $statnum2
        }
        "rxpackets" {
            stat get statframesReceived $chasId $port $card
            set statnum1 [stat cget -framesReceived]
            after $timeout
            stat get statframesReceived $chasId $port $card
            set statnum2 [stat cget -framesReceived]
            lappend ret $statnum1
            lappend ret $statnum2
        }
        "rxbytes" {
            stat get statbytesReceived $chasId $port $card
            set statnum1 [stat cget -bytesReceived]
            after $timeout
            stat get statbytesReceived $chasId $port $card
            set statnum2 [stat cget -bytesReceived]
            lappend ret $statnum1
            lappend ret $statnum2
        }
        "rxbits" {
            stat get statbitsReceived $chasId $port $card
            set statnum1 [stat cget -bitsReceived]
            after $timeout
            stat get statbitsReceived $chasId $port $card
            set statnum2 [stat cget -bitsReceived]
            lappend ret $statnum1
            lappend ret $statnum2
        }
        "updown" {
            stat get statlink $chasId $port $card
            set statnum1 [stat cget -link]
            if {$statnum1 != 1} {
                set statnum1 0
            }
            after $timeout
            stat get statlink $chasId $port $card
            set statnum2 [stat cget -link]
            if {$statnum2 != 1} {
                set statnum2 0
            }
            lappend ret $statnum1
            lappend ret $statnum2
        }
        "txstate" {
            stat get allStats $chasId $port $card
            set statnum1 [stat cget -transmitState]
            after $timeout
            stat get allStats $chasId $port $card
            set statnum2 [stat cget -transmitState]
            after $timeout
            lappend ret $statnum1
            lappend ret $statnum2
        }
        "lineSpeed" {
            stat get allStats $chasId $port $card
            set statnum1 [stat cget -lineSpeed]
            after $timeout
            stat get allStats $chasId $port $card
            set statnum2 [stat cget -lineSpeed]
            lappend ret $statnum1
            lappend ret $statnum2
        }
        "duplex" {
            stat get allStats $chasId $port $card
            set statnum1 [stat cget -duplexMode]
            after $timeout
            stat get allStats $chasId $port $card
            set statnum2 [stat cget -duplexMode]
            lappend ret $statnum1
            lappend ret $statnum2
        }
        "flowControlFrames" {
            stat get allStats $chasId $port $card
            set statnum1 [stat cget -flowControlFrames]
            after $timeout
            stat get allStats $chasId $port $card
            set statnum2 [stat cget -flowControlFrames]
            lappend ret $statnum1
            lappend ret $statnum2
        }
    }
    set retstr [join $ret]
    return $retstr
}

#set ixia port filters
#err code : 2900-2999
proc SetPortFiltersEnable {cmdstr} {
    set cmdlist [split $cmdstr]
    set cmdlen [llength $cmdlist]
    if {$cmdlen <= 3} {
        return -100
    }
    global ixia_ip
    if {[ConnectToIxia $ixia_ip] != 0 } {
        return -400
    }
    global logflag
    global logfid
    set chasId [GetIxiaChassID $ixia_ip]
    set x [lindex $cmdlist 0]
    set card [lindex $cmdlist 1]
    set port [lindex $cmdlist 2]
    if {[IxiaLogin $chasId $port $card] != 0} {
        return -401
    }
    set filterlist [lrange $cmdlist 3 end]
    set filter_cmdstr [join $filterlist " "]
    if {$logflag == 1} {
        puts $logfid $filter_cmdstr
    }
    set filter_cmdlist [split $filter_cmdstr "$"]
    set filter_cmd1 [lindex $filter_cmdlist 0]
    set filter_cmd2 [lindex $filter_cmdlist 1]
    #config filter
    filter setDefault
    if {$logflag == 1} {
        puts $logfid "filter setDefault"
    }
    set filter_cmd1_list [split $filter_cmd1 "@"]
    foreach ecmd $filter_cmd1_list {
        eval $ecmd
        if {$logflag == 1} {
            puts $logfid $ecmd
        }
    }
    filter set $chasId $card $port
    if {$logflag == 1} {
        puts $logfid "filter set $chasId $card $port"
    }
    #config filterPallette
    filterPallette setDefault
    if {$logflag == 1} {
        puts $logfid "filterPallette setDefault"
    }
    set filter_cmd2_list [split $filter_cmd2 "@"]
    foreach ecmd $filter_cmd2_list {
        eval $ecmd
        if {$logflag == 1} {
            puts $logfid $ecmd
        }
    }
    filterPallette set $chasId $card $port
    if {$logflag == 1} {
        puts $logfid "filterPallette set $chasId $card $port"
    }
    port set $chasId $card $port
    if {$logflag == 1} {
        puts $logfid "port set $chasId $card $port"
    }
    set portlist [list [list $chasId $card $port]]
    ixWriteConfigToHardware portlist
}

#get capture packet timestamp
#err code : 3000-3099
proc GetCapturePacketTimestamp {cmdstr} {
    set cmdlist [split $cmdstr]
    set cmdlen [llength $cmdlist]
    if {$cmdlen != 5} {
        return -100
    }
    global ixia_ip
    if {[ConnectToIxia $ixia_ip] != 0} {
        return -400
    }
    set chasId [GetIxiaChassID $ixia_ip]
    set x [lindex $cmdlist 0]
    set port [lindex $cmdlist 1]
    set card [lindex $cmdlist 2]
    if {[IxiaLogin $chasId $port $card] != 0} {
        return -401
    }
    set fromPacket [lindex $cmdlist 3]
    set toPacket [lindex $cmdlist 4]
    if {$fromPacket < 1} {
        return -3003
    }
    if {$fromPacket > $toPacket} {
        return -3002
    }
    set capres [capture get $chasId $port $card]
    if {$capres != 0} {
        return -3001
    }
    set capnum [capture cget -nPackets]
    if {$capnum == 0} {
        return ""
    }
    if {$capnum < $toPacket} {
        set toPacket $capnum
    }
    if {$fromPacket > $toPacket} {
        return ""
    }
    set capres [captureBuffer get $chasId $port $card $fromPacket $toPacket]
    if {$capres != 0} {
        return -3004
    }
    set ret ""
    set plen [expr $toPacket - $fromPacket + 1]
    for {set i 1} {$i <= $plen} {incr i} {
        set ires [captureBuffer getframe $i]
        if {$ires == 0} {
            set data [captureBuffer cget -timestamp]
            lappend ret $data
        }
    }
    set retstr [join $ret "$"]
    return $retstr
}

#create_portgroup_id
#err code : 3100-3199
proc CreatePortgroupId {cmdstr} {
    set cmdlist [split $cmdstr]
    set cmdlen [llength $cmdlist]
    if {$cmdlen != 2} {
        return -100
    }
    global ixia_ip
    if {[ConnectToIxia $ixia_ip] != 0} {
        return -400
    }
    set chasId [GetIxiaChassID $ixia_ip]
    set x [lindex $cmdlist 0]
    set goupid [lindex $cmdlist 1]
    set ret [portGroup create $goupid]
    return $ret
}

#add_port_to_portgroup
#err code : 3200-3299
proc AddPortToPortgroup {cmdstr} {
    set cmdlist [split $cmdstr]
    set cmdlen [llength $cmdlist]
    if {$cmdlen != 4} {
        return -100
    }
    global ixia_ip
    if {[ConnectToIxia $ixia_ip] != 0} {
        return -400
    }
    set chasId [GetIxiaChassID $ixia_ip]
    set x [lindex $cmdlist 0]
    set card [lindex $cmdlist 1]
    set port [lindex $cmdlist 2]
    if {[IxiaLogin $chasId $port $card] != 0} {
        return -401
    }
    set goupid [lindex $cmdlist 3]
    set ret [portGroup add $goupid $chasId $card $port]
    return $ret
}

#del_port_to_portgroup
#err code : 3300-3399
proc DelPortToPortgroup {cmdstr} {
    set cmdlist [split $cmdstr]
    set cmdlen [llength $cmdlist]
    if {$cmdlen != 4} {
        return -100
    }
    global ixia_ip
    if {[ConnectToIxia $ixia_ip] != 0} {
        return -400
    }
    set chasId [GetIxiaChassID $ixia_ip]
    set x [lindex $cmdlist 0]
    set card [lindex $cmdlist 1]
    set port [lindex $cmdlist 2]
    if {[IxiaLogin $chasId $port $card] != 0} {
        return -401
    }
    set goupid [lindex $cmdlist 3]
    set ret [portGroup del $goupid $chasId $card $port]
    return $ret
}

#destroy_portgroup_id
#err code : 3100-3199
proc DestroyPortgroupId {cmdstr} {
    set cmdlist [split $cmdstr]
    set cmdlen [llength $cmdlist]
    if {$cmdlen != 2} {
        return -100
    }
    global ixia_ip
    if {[ConnectToIxia $ixia_ip] != 0} {
        return -400
    }
    set chasId [GetIxiaChassID $ixia_ip]
    set x [lindex $cmdlist 0]
    set goupid [lindex $cmdlist 1]
    set ret [portGroup destroy $goupid]
    return $ret
}

#set_cmd_to_portgroup
#err code : 3300-3399
proc SetCmdToPortgroup {cmdstr} {
    set cmdlist [split $cmdstr]
    set cmdlen [llength $cmdlist]
    if {$cmdlen != 3} {
        return -100
    }
    global ixia_ip
    if {[ConnectToIxia $ixia_ip] != 0} {
        return -400
    }
    set chasId [GetIxiaChassID $ixia_ip]
    set x [lindex $cmdlist 0]
    set goupid [lindex $cmdlist 1]
    set cmd [lindex $cmdlist 2]
    set ret [portGroup setCommand $goupid $cmd]
    return $ret
}

#set_port_transmit_mode
#err code : 3400-3499
proc SetPortTransmitMode {cmdstr} {
    set cmdlist [split $cmdstr]
    set cmdlen [llength $cmdlist]
    if {$cmdlen <= 3} {
        return -100
    }
    global ixia_ip
    ixDisconnectFromChassis $ixia_ip
    if {[ConnectToIxia $ixia_ip] != 0 } {
        return -400
    }
    set chasId [GetIxiaChassID $ixia_ip]
    set x [lindex $cmdlist 0]
    set port [lindex $cmdlist 1]
    set card [lindex $cmdlist 2]
    if {[IxiaLogin $chasId $port $card] != 0} {
        return -401
    }
    set mode [lindex $cmdlist 3]
    set portlist [list [list $chasId $port $card]]
    #port setDefault
    if {$mode == 0} {
        set ret [port config -transmitMode 0]
    } elseif {$mode == 4} {
        set ret [port config -transmitMode 4]
    } elseif {$mode == 7} {
        set ret [port config -transmitMode 7]
    } else {
        set ret [port config -transmitMode 0]
    }
    port set $chasId $port $card
    #ixWriteConfigToHardware portlist
    ixWritePortsToHardware portlist
    return $ret
}

#connect to ixia
proc ConnectToIxia {ip} {
    set ret [ixConnectToChassis $ip]
    return $ret
}

#get ixia chass id
proc GetIxiaChassID {ip} {
    chassis get $ip
    set chasid [chassis cget -id]
    return $chasid
}

proc ShutdownProxyserver {} {
    global ixia_ip
    ixDisconnectFromChassis $ixia_ip
    return -10000
}

proc OpenLog {} {
    set filepath [info script]
    set logfile [file join [file dirname $filepath] "ixia" "ixia.log"]
    set fid [open $logfile "w"]
    return $fid
}

proc IxiaLogin {chas card port} {
    global username
    if {$username != ""} {
        ixLogin $username
        set portlist [list [list $chas $card $port]]
        ixTakeOwnership $portlist force
    }
    return 0
}

set bind_addr 0.0.0.0
set bind_port 11917
set ixia_version 4.10
set ixia_ip 0.0.0.0
set logflag 0
set logfid ""
set username ""

if {$argc > 2} {
    array set argarray $argv
    if {[info exists argarray(ixiaversion)]} {
        set ixia_version $argarray(ixiaversion)
    }
    if {[info exists argarray(bindaddr)]} {
        set bind_addr $argarray(bindaddr)
    }
    if {[info exists argarray(bindport)]} {
        set bind_port $argarray(bindport)
    }
    if {[info exists argarray(ixiaip)]} {
        set ixia_ip $argarray(ixiaip)
    }
    if {[info exists argarray(logflag)]} {
        set logflag $argarray(logflag)
    }
    if {[info exists argarray(username)]} {
        set username $argarray(username)
    }
}

set sockserver [socket -server ProcessConn -myaddr $bind_addr $bind_port]
if {$logflag == 1} {
    set logfid [OpenLog]
}
set sockname [fconfigure $sockserver -sockname]
set listen [lindex $sockname 2]
puts "proxy server listen port:$listen"
vwait forever
# if {[ConnectToIxia $ixia_ip] == 0} {
#     puts "ConnectToIxia success"
#     socket -server ProcessConn -myaddr $bind_addr $bind_port
#     set logfid [OpenLog]
#     vwait forever
# } else {
#     #code error -400: not connect to ixia
#     exit -400
# }
