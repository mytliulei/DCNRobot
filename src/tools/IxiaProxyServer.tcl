#!/usr/bin/env tclsh
#

# proxy server to ixia, for RF

#version    :   0.1
#author     :   liuleic
#copyright  :   Copyright 2014, DigitalChina Network
#license    :   Apache License, Version 2.0
#mail       :   liuleic@digitalchina.com


#package requires IxTclHal


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
        }
    }
}

#generat ixia cmd string
proc evalIxiaCmd {cmdstr} {
    set cmdlist [split $cmdstr]
    set cmdname [lindex $cmdlist 0]
    switch -exact $cmdname {
        "set_stream_from_hexstr" {
            set ret [SetStreamFromHexstr $cmdstr]
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

set bind_addr 127.0.0.1
set bind_port 11917
set ixia_version 4.10
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
}

socket -server ProcessConn -myaddr $bind_addr $bind_port
vwait forever
