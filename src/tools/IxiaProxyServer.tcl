#!/usr/bin/env tclsh
#

# proxy server to ixia, for RF

#version    :   0.1
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
    set err "eof close channel"
    if { [catch {gets $chan line} err] || [eof $chan] } {
        puts $err
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
        default {
            set ret -900
        }
    }
    if {$ret < -900 && $ret >= -999} {
        puts $chan $ret
        flush $chan
        append result "ixia proxy error buffer end"
        set ret $result
    }
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
    set portlist [list [list $chasId $port $card] ]
    set ret ""
    set statlist [lrange $cmdlist 3 end]
    foreach stat_type $statlist {
        switch -exact $stat_type {
            "txpps" {
                stat getRate allStats $chasId $port $card
                set statnum [stat cget -framesSent]
                lappend ret $statnum
            }
            "txBps" {
                stat getRate allStats $chasId $port $card
                set statnum [stat cget -bytesSent]
                lappend ret $statnum
            }
            "txbps" {
                stat getRate allStats $chasId $port $card
                set statnum [stat cget -bitsSent]
                lappend ret $statnum
            }
            "txpackets" {
                stat get allStats $chasId $port $card
                set statnum [stat cget -framesSent]
                lappend ret $statnum
            }
            "txbytes" {
                stat get allStats $chasId $port $card
                set statnum [stat cget -bytesSent]
                lappend ret $statnum
            }
            "txbits" {
                stat get allStats $chasId $port $card
                set statnum [stat cget -bitsSent]
                lappend ret $statnum
            }
            "rxpps" {
                stat getRate allStats $chasId $port $card
                set statnum [stat cget -framesReceived]
                lappend ret $statnum
            }
            "rxBps" {
                stat getRate allStats $chasId $port $card
                set statnum [stat cget -bytesReceived]
                lappend ret $statnum
            }
            "rxbps" {
                stat getRate allStats $chasId $port $card
                set statnum [stat cget -bitsReceived]
                lappend ret $statnum
            }
            "rxpackets" {
                stat get allStats $chasId $port $card
                set statnum [stat cget -framesReceived]
                lappend ret $statnum
            }
            "rxbytes" {
                stat get allStats $chasId $port $card
                set statnum [stat cget -bytesReceived]
                lappend ret $statnum
            }
            "rxbits" {
                stat get allStats $chasId $port $card
                set statnum [stat cget -bitsReceived]
                lappend ret $statnum
            }
            "updown" {
                stat get allStats $chasId $port $card
                set statnum [stat cget -link]
                if {statnum != 1} {
                    set statnum 0
                }
                lappend ret $statnum
            }
            "txstate" {
                stat get allStats $chasId $port $card
                set statnum [stat cget -transmitState]
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
    foreach {x port card} $cmdlist {
        set portlist [list [list $chasId $port $card]]
        set res [ixClearStats portlist]
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
    set fromPacket [lindex $cmdlist 3]
    set toPacket [lindex $cmdlist 4]
    if {$fromPacket < 1} {
        return -1103
    }
    set capres [capture get $chasId $port $card]
    if {$capres != 0} {
        return -1101
    }
    set capnum [capture cget -nPackets]
    if {$capnum < $toPacket} {
        set toPacket $capnum
    }
    if {$fromPacket > $toPacket} {
        return -1102
    }
    set capres [captureBuffer get $chasId $port $card $fromPacket $toPacket]
    if {$capres != 0} {
        return -1104
    }
    set ret ""
    for {set i $fromPacket} {$i <= $toPacket} {incr i} {
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
    if {[ConnectToIxia $ixia_ip] != 0 } {
        return -400
    }
    set chasId [GetIxiaChassID $ixia_ip]
    set x [lindex $cmdlist 0]
    set port [lindex $cmdlist 1]
    set card [lindex $cmdlist 2]
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

set bind_addr 0.0.0.0
set bind_port 11917
set ixia_version 4.10
set ixia_ip 0.0.0.0
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
}

if {[ConnectToIxia $ixia_ip] == 0} {
    puts "ConnectToIxia success"
    socket -server ProcessConn -myaddr $bind_addr $bind_port
    vwait forever
} else {
    #code error -400: not connect to ixia
    exit -400
}
