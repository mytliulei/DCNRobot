###############################################################################
# Version 4.10 $
# $Date: 9/30/02 4:00p $
# $Author: Mgithens $
#
# $Workfile: tclServer.tcl $
#
# Copyright ¨ 1997 - 2003 by IXIA
# All Rights Reserved.
#
# Revision Log:
# 3-1-2001 Michael Githens
#
# Description: This file contains procedures that handle any connections with
#              the Tcl Server.
#
# NOTE: All routines in this file must be able to stand on their own.  There
#       can be no dependence on ScriptMate
#
###############################################################################

namespace eval tclServer \
{
    variable tclServerName      ""
    variable tclServerConnected 0
}
# End of tclServer namespace

# The following are the procedures that are meant to be called from outside
# of the namespace.  The rest are just helper routines for use within the
# namespace.
#
#  tclServer::getTclServerName
#  tclServer::setTclServerName
#  tclServer::disconnectTclServer
#  tclServer::connectToTclServer serverName errMsg clientPort
#  tclServer::isTclServerConnected
#


###############################################################################
# Procedure:   tclServer::getTclServerName
#
# Description: Retrieve the hostname of tcl server.
#
# Arguments:   None
#
# Returns:     Hostname of the tcl server.
###############################################################################
proc tclServer::getTclServerName {} \
{
    variable tclServerName

    return  $tclServerName
}


###############################################################################
# Procedure:   tclServer::setTclServerName
#
# Description: Sets the hostname of tcl server.
#
# Arguments:   hostname - the new hostname
#
# Returns:     None
###############################################################################
proc tclServer::setTclServerName { hostname } \
{
    variable tclServerName

    set tclServerName $hostname

    return
}


###############################################################################
# Procedure: tclServer::disconnectTclServer
#
# Description: Disconnects from the TclServer socket
#
# Results: Returns the code from the clientClose call.
###############################################################################
proc tclServer::disconnectTclServer {} \
{
    global   ixTclSvrHandle ixErrorInfo

    variable tclServerName
    variable tclServerConnected

    set retCode 0

    if {[isUNIX]} {
        # We only want to see this message on unix machines.  We do not want 
        # to see it on windows, because it is meaningless.
        logMsg "Disconnecting from Tcl Server ..."
    }
    if {[info exists ixTclSvrHandle]} {
        set retCode [clientClose $ixTclSvrHandle]
        catch {unset ixTclSvrHandle}
    }
    set tclServerConnected 0
    set tclServerName      ""
    set ixErrorInfo        ""

    return $retCode
}


###############################################################################
# Procedure: tclServer::read
#
# Description: Reads the buffer from the TclServer socket
#
# Results: 
###############################################################################
proc tclServer::read {socket} \
{
    variable buffer

    set buffer ""
    set length -1

	if {[eof $socket] || [catch {gets $socket buffer}]} {
		# end-of-file or abnormal connection drop
        catch {close $socket}
        debugMsg "Close $socket"
        return -code error -errorinfo "Socket closed prematurely.."
    } else {
        debugMsg "buffer=$buffer"
    }
}


###############################################################################
# Procedure: tclServer::connectToTclServer
#
# Description: This procedure connects the remote tcl session to a
#              TclServer/proxy.
#
# Side Effects: If the connection is successful, then define the remote 
#               commands and functions that can now be accessed.
#
# Arguments:
#    serverName: Hostname or IP address of the machine to connect with.
#    ErrMsg: Pass by reference.  If there is an error connecting, this will contain the error message.
#    clientPort: Optional.  The port number to use.
#
# Results: Returns 0 on success and 1 on failure
###############################################################################
proc tclServer::connectToTclServer { serverName ErrMsg {clientPort 4555} } \
{
    global halCommands halFuncs ixTclSvrHandle ixErrorInfo
    variable tclServerConnected
    variable tclServerName

    upvar $ErrMsg errMsg
    set errMsg ""

    set retCode 0

    set ixErrorInfo ""

    logMsg "Connecting to Tcl Server $serverName ..."
    if {[info exists ixTclSvrHandle]} {
        catch { clientClose $ixTclSvrHandle }
        catch { unset ixTclSvrHandle }
    }

    set clientSocket [clientOpen $serverName $clientPort]
    set ixTclSvrHandle $clientSocket

    if {$clientSocket == {}} {
        set tclServerConnected 0
        set errMsg "Error opening client socket."
        set retCode 1
    } else {
        set tclServerConnected 1
        set tclServerName      $serverName

	    fconfigure $clientSocket -buffering line -translation crlf
        fileevent  $clientSocket readable [list tclServer::read $clientSocket]

        if [catch {clientSend $ixTclSvrHandle "package req IxTclHal"} result] {
            errorMsg $result
        }

        remoteDefine $halCommands
        remoteDefine $halFuncs

        getConstantsValue $clientSocket

        if { [isUNIX] } {
            foreach command {chassis card port stream captureBuffer} {
                redefineCommand $command
            }
        }
    }

    # Warn user if using different Ixia versions on client & server.
    if {[isUNIX]} {
        if {[isTclServerConnected]} {
            set clientVersion $::env(IXIA_VERSION)
            set clientVers [scan $clientVersion "%d.%d" clientMajor clientMinor]

            set serverVers [scan [version cget -ixTclHALVersion] "%d.%d" serverMajor serverMinor]
            set serverVersion [format "%d.%d" $serverMajor $serverMinor]

            if {$clientVers != 2 || $serverMajor != $clientMajor || $serverMinor < $clientMinor} {
                set retCode 1
                set errMsg "WARNING: Tcl Server and Client are running incompatible Ixia Software Versions"
                append errMsg "\n\tTcl Server: $serverVersion"
                append errMsg "\n\tTcl Client: $clientVersion\n\n"
                set ixErrorInfo $errMsg
            }
        }
    }

    return $retCode
}


###############################################################################
# Procedure: tclServer::isTclServerConnected
#
# Description: Tells if the there is a connection to a tcl server
#
# Results: Returns the value of the tclServerConnected variable
###############################################################################
proc tclServer::isTclServerConnected {} \
{
    variable tclServerConnected
    return $tclServerConnected
}


###############################################################################
# Procedure: tclServer::setTclServer
#
# Description: Create a window that will ask for the location of the tcl
#              server.  Only used on Unix and Linux platforms.
#
# Arguments:
#    warningMsg - the text to place next to the warning sign
###############################################################################
proc tclServer::setTclServer {warningMsg} \
{
    variable tclServerName
    variable tclServerConnected

    # Return if not on unix or linux
    if {[isUNIX] == 0} {
        # Always let windows think it is connected
        set tclServerConnected 1
        return
    }

    set tclServerDlg .tclServer

    # If it already exists, destroy it.
    if {[winfo exists $tclServerDlg]} {
        catch {destroy $tclServerDlg}
    }

    # Create the new top level window and make it transient to the top
    toplevel $tclServerDlg -class Dialog
    wm withdraw $tclServerDlg
    wm title $tclServerDlg "Tcl Server"

    # Create a frame and the entry for the tcl server value
    set serverFrame [frame $tclServerDlg.frame]
    set serverLabel [label $serverFrame.label -text "Hostname: " -width 10]
    set serverEntry [entry $serverFrame.entry -width 20]

    # Bind the enter key to the window. It will be the same as clicking connect
    bind $tclServerDlg <Key-Return> "[namespace current]::connectButton \
            $tclServerDlg $serverEntry \"$warningMsg\""

    # Create a warning note about the consequences of not being connected
    set serverWarning [label $serverFrame.warning -text "WARNING: " \
            -fg red]
    set serverMessage [label $serverFrame.message -text $warningMsg]

    # Create the connect and cancel buttons
    set connectButton [button $tclServerDlg.connect -text "Connect" -width 6 \
            -command "[namespace current]::connectButton $tclServerDlg \
            $serverEntry \"$warningMsg\""]
    set cancelButton [button $tclServerDlg.cancel -text "Cancel" -width 6 \
            -command "[namespace current]::cancelButton $tclServerDlg \
            $serverEntry"]

    # Grid the entry and warning into the frame
    grid $serverLabel   -row 0 -column 0 -padx 5  -pady 5 -sticky wens
    grid $serverEntry   -row 0 -column 1 -padx 10 -pady 5 -sticky wens
    grid $serverWarning -row 1 -column 0 -pady 10 -sticky ens
    grid $serverMessage -row 1 -column 1 -pady 10 -sticky wns

    # Grid the frame and the buttons into the dialog
    grid $serverFrame   -row 0 -column 0 -padx 5 -pady 5 -sticky wens \
            -columnspan 2
    grid $connectButton -row 1 -column 0 -padx 5 -pady 5 -sticky ens
    grid $cancelButton  -row 1 -column 1 -padx 5 -pady 5 -sticky wns

    # Make the first row and the second column expandable
    grid rowconfigure $tclServerDlg 0 -weight 1

    # Set the entry with the currently saved value
    if {[string compare $tclServerName ""] != 0} {
        $serverEntry insert 0 $tclServerName
    } else {
        $serverEntry insert 0 [testConfig::getTestConfItem serverName]
    }

    # Bring up the dialog and set its size
    wm deiconify $tclServerDlg
    wm minsize $tclServerDlg 325 150
    wm resizable $tclServerDlg 0 0

    # Make the user do something in this window before continuing
    focus $tclServerDlg
    grab $tclServerDlg
    tkwait window $tclServerDlg

    return
}


###############################################################################
# Procedure: tclServer:connectButton
#
# Description: Called when the connect button on the set tcl server window is
#              pressed.  This will 
#              1. If already connected, save any values that need to carry
#                 across to the new connection and then disconnect.
#              2. Connect to the newly chosen tcl server.
#              3. Restore any saved settings from step 1.
#
# Arguments:
#    tclServerDlg - The widget name for the set tcl server dialog
#    serverEntry - The entry widget that contains the tcl server data
#    warningMsg - If failure to connect, the message to pass to the dialog
###############################################################################
proc tclServer::connectButton { tclServerDlg serverEntry warningMsg } \
{
    variable tclServerName
    variable tclServerConnected

    # If connected, we first need to disconnect
    set continueFlag 1

    if {$tclServerConnected} {
        if { [llength [smChassisUtils::getHostName]] > 0 } {
            set    message "Reconnecting to Tcl Server will cause reconnecting"
            append message "\nto all configured chassis.\n\nDo you want to continue?"
            set answer [tk_messageBox -parent $tclServerDlg -title "Warning" -type yesno \
                    -icon warning -message $message]

            if { $answer == "no" } {
                catch {destroy $tclServerDlg}
                set continueFlag 0
            }
        }

        if { $continueFlag == 1 } {
            tclServer::disconnectTclServer
        }
    }

    if { $continueFlag == 1 } {

        set tclServerName [$serverEntry get]

        testConfig::setTestConfItem serverName $tclServerName

        # Connect to this server
        $tclServerDlg configure -cursor watch
        set retcode [tclServer::connectToTclServer $tclServerName errMsg]

        if {$retcode == 0} {
            setConnectChassisFlag "continue" 
            smGlobalChassis::reconnect
    	    $tclServerDlg configure -cursor arrow
            catch {destroy $tclServerDlg}
        } else {
            $tclServerDlg configure -cursor arrow
            # Could not connect to tcl server, ask them again
            set msg "Could not connect to Tcl Server on $tclServerName.\n"
            append msg $errMsg
            tk_messageBox -parent $tclServerDlg -title "Tcl Server" -type ok \
                    -icon error -message $msg
            tclServer::setTclServer $warningMsg

            set tclServerName ""
        }
    }

    return
}


###############################################################################
# Procedure: tclServer:cancelButton
#
# Description: Called when the cancel button on the set tcl server window is
#              pressed.  This will 
#
# Arguments:
#    tclServerDlg - The widget name for the set tcl server dialog
#    serverEntry - The entry widget that contains the tcl server data
###############################################################################
proc tclServer::cancelButton { tclServerDlg serverEntry } \
{
    variable tclServerConnected

    set tclServerName [$serverEntry get]

    # Set the server name
    testConfig::setTestConfItem serverName $tclServerName

    if {[info exists tclServerConnected] == 0} {
        set tclServerConnected 0
    }

    # Destroy the dialog
    catch {destroy $tclServerDlg}

    return
}
