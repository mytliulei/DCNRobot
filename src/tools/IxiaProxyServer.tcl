#!/usr/bin/env tclsh
#

# proxy server to ixia, for RF

#version    :   0.1
#author     :   liuleic
#copyright  :   Copyright 2014, DigitalChina Network
#license    :   Apache License, Version 2.0
#mail       :   liuleic@digitalchina.com


package requires IxTclHal


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
            cmdret = evalIxiaCmd($line)
            puts $chan $cmdret
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
        default {
            set ret None
        }
    }
    return $ret
}

#set ixia stream from hexstring
proc SetStreamFromHexstr {cmdstr} {

}

#start ixia stream
proc StartTransmit {cmdstr} {
    set cmdlist [split $cmdstr]
    set cmdlen [llength $cmdlist]
    if {[expr $cmdlen % 3] != 0} {
        return -100
    }
    global ixia_ip
    if {[ConnectToIxia $ixia_ip] != 0 ]} {
        return -400
    }
    set chasId [GetIxiaChassID $ixia_ip]
    set ret 0
    foreach {x port card} $cmdlist {
        set portlist [list [list $chasId $port $card]]
        set res [ixStartTransmit portlist]
        set res [expr $ret + $res]
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
    if {[ConnectToIxia $ixia_ip] != 0 ]} {
        return -400
    }
    set chasId [GetIxiaChassID $ixia_ip]
    set ret 0
    foreach {x port card} $cmdlist {
        set portlist [list [list $chasId $port $card]]
        set res [ixStopTransmit portlist]
        set res [expr $ret + $res]
    }
    return $ret
}

#get ixia statistics
proc GetStatistics {cmdstr} {

}

#start capture
proc StartCapture {cmdstr} {
    set cmdlist [split $cmdstr]
    set cmdlen [llength $cmdlist]
    if {[expr $cmdlen % 3] != 0} {
        return -100
    }
    global ixia_ip
    if {[ConnectToIxia $ixia_ip] != 0 ]} {
        return -400
    }
    set chasId [GetIxiaChassID $ixia_ip]
    set ret 0
    foreach {x port card} $cmdlist {
        set portlist [list [list $chasId $port $card]]
        set res [ixStartCapture portlist]
        set res [expr $ret + $res]
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
    if {[ConnectToIxia $ixia_ip] != 0 ]} {
        return -400
    }
    set chasId [GetIxiaChassID $ixia_ip]
    set ret 0
    foreach {x port card} $cmdlist {
        set portlist [list [list $chasId $port $card]]
        set res [ixStopCapture portlist]
        set res [expr $ret + $res]
    }
    return $ret
}

#check transmit done
proc CheckTransmitDone {cmdstr} {
    set cmdlist [split $cmdstr]
    set cmdlen [llength $cmdlist]
    if {[expr $cmdlen % 3] != 0} {
        return -100
    }
    global ixia_ip
    if {[ConnectToIxia $ixia_ip] != 0 ]} {
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

set bind_addr 127.0.0.1
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
    socket -server ProcessConn -myaddr $bind_addr $bind_port
    vwait forever
} else {
    #code error -400: not connect to ixia
    exit -400
}

