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
            set cmdret [evalIxiaCmd $line]
            puts $chan $cmdret
            if {$cmdret == -10000} {
                exit 0
            }
        }
    }
}

#generat ixia cmd string
proc evalIxiaCmd {cmdstr} {
    set cmdstr [string trim $cmdstr]
    set cmdlist [split $cmdstr]
    set cmdname [lindex $cmdlist 0]
    set cmdstr [join [lrange $cmdlist 1 end]]
    switch -exact $cmdname {
        "set_stream_from_hexstr" {
            set ret [SetStreamFromHexstr $cmdstr]
        }
        "start_transmit" {
            set ret [StartTransmit $cmdstr]
        }
        "stop_transmit" {
            set ret [StopTransmit $cmdstr]
        }
        "get_statistics" {
            set ret [GetStatistics $cmdstr]
        }
        "start_capture" {
            set ret [StartCapture $cmdstr]
        }
        "stop_capture" {
            set ret [StopCapture $cmdstr]
        }
        "check_transmit_done" {
            set ret [CheckTransmitDone $cmdstr]
        }
        "clear_statics" {
            set ret [ClearStatistics $cmdstr]
        }
        "get_capture_packet" {
            set ret [GetCapturePacket $cmdstr]
        }
        "get_capture_packet_num"  {
            set ret [GetCapturePacketNum $cmdstr]
        }
        "shutdown_proxy_server" {
            set ret [ShutdownProxyserver]
        }
        "set_port_mode_default" {
            set ret [SetPortModeDefault $cmdstr]
        }
        default {
            set ret -1000
        }
    }
    return $ret
}

#set ixia stream from hexstring
proc SetStreamFromHexstr {cmdstr} {
    set cmdlist [split $cmdstr]
    set cmdlen [llength $cmdlist]
    if {$cmdlen <= 9} {
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
    set packet [lindex $cmdlist 9]
    set dstmac [string trim [join [split [string range $packet 0 17] "$"]]]
    set srcmac [string trim [join [split [string range $packet 18 35] "$"]]]
    set pattern [string trim [join [split [string range $packet 36 end] "$"]]]
    set portlist [list [list $chasId $port $card]]
    set packetlen [expr [llength [split $packet "$"]] + 4]
    #ixia config
    stream setDefault
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
        }
    }
    set retstr [join $ret]
    return $retstr
}

#clear ixia statistics
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
    capture get $chasId $port $card
    set capnum [capture cget -nPackets]
    if {$capnum < $toPacket} {
        set toPacket $capnum
    }
    captureBuffer get $chasId $port $card $fromPacket $toPacket
    set ret ""
    for {set i $fromPacket} {$i <= $toPacket} {incr i} {
        captureBuffer getframe $i
        set data [captureBuffer cget -frame]
        lappend ret $data
    }
    set retstr [join $ret "$"]
    return $retstr
}

#get capture packet Num
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
