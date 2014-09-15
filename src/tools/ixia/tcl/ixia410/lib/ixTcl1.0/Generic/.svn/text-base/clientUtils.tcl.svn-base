##################################################################################
# Version 4.10    $Revision: 30 $
# $Date: 9/30/02 3:51p $
# $Author: Mgithens $
#
# $Workfile: clientUtils.tcl $ - Generic Actions
#
#   Copyright © 1997 - 2005 by IXIA
#   All Rights Reserved.
#
#    Revision Log:
#    Date           Author                 Comments
#    -----------    -------------------    --------------------------------------------
#    10/25/2000     ds                      initial release
#
# Description:  This file contains utilities for the client side of the Tcl proxy
#
##################################################################################


########################################################################################
# Procedure:    clientOpen
#
# Description:  Open a connection to the ixTclServer.
#                
# Input:        server:        host name of server
#               port:        port id of service
#
# Output:       socket handle
#
########################################################################################
proc clientOpen {host port} \
{
    if [catch {socket $host $port} socketId] {
        errorMsg "Error: $socketId"
        set socketId {}
    }

    return $socketId
}


########################################################################################
# Procedure:    clientClose
#
# Description:  Close connection from the client side.
#                
# Input:        socketId:    client-side socket
#
# Output:        0 if successful
#                1 if error while attempting to close socket
#
########################################################################################
proc clientClose {socketId} \
{
    set retCode 0

    if [catch {close $socketId}] {
        set retCode 1
    }

    return $retCode
}


########################################################################################
# Procedure:    clientSend
#
# Description:  Send a command from the client side.
#                
# Input:        socketId:    client-side socket
#                args:        TCL command to evaluate
#
# Returns:        Success:    TCL Return result
#               Failure:    {}
#
# Remarks:  TCL procs can embed i/o.
#
########################################################################################
proc clientSend {socketId args} \
{
    set retCode   1
    set retResult 0

    #
    # send data over the socket
    #
    set buf [lindex $args 0]

    #   
    #   Return buffer is formatted as follows:
    #
    #   0 to final lf/cr -> Tcl Standard Output
    #   final character  -> Tcl Return Code (TCL_OK, TCL_ERROR)
    #   
    if [catch { puts $socketId $buf ; 
                flush $socketId ; 
                #
                # read the reply
                #  the reply may have the format 
                #       sOutput/r/nsTclResult/r/n    -- i/o output followed by TCL result
                #                                                 /r/n -delimited
                #       sTclresult/r/nsTclResultCode -- simple TCL result
                #       null                         -- no TCL result available
                
                vwait tclServer::buffer
                set retBuffer $tclServer::buffer
                
                set indexOfLastCrlf [string last "\r\n" $retBuffer]
                if {$indexOfLastCrlf != -1 } {
                    set lenBuffer [string length $retBuffer]
                    set indexOfPenultimateCrlf [string last "\r\n" [string range $retBuffer 0 [expr $indexOfLastCrlf -1]]]
                    if {$indexOfPenultimateCrlf != -1 } {
                        set retResult [string range $retBuffer [expr $indexOfPenultimateCrlf + 2] $lenBuffer]
                    } else {
                        set length    [string length $retBuffer]
                        set retCode   [string index $retBuffer [incr length -1]]
                        set retResult [string range $retBuffer 0 [incr length -1]]
                    }
                } else {
                    set length    [string length $retBuffer]
                    set retCode   [string index $retBuffer [incr length -1]]
                    set retResult [string range $retBuffer 0 [incr length -1]]
                }
            } 
    ] {
        errorMsg $::errorInfo
        tclServer::disconnectTclServer
        set retResult 1
    }

    #
    # Force an error if the command returned TCL_ERROR.
    #   Can't use the constant TCL_ERROR here since it is not defined at
    #   this point in execution.
    #
    if {$retCode == 1} {
        set retCommand [list error $retResult $retResult]
    } else {
        set retCommand [list return $retResult]
    }

    eval $retCommand
}

########################################################################################
# Procedure:    remoteDefine
#
# Description:     Create a proc to proxy over a ixTclHal command.
#                
# Input:        commandList
#
# Output:        0 if successful
#                1 if error
#
########################################################################################
proc remoteDefine { commandList } \
{
    foreach procName $commandList {
        eval [format   "proc %s {args} \
                        {\
                            global ixTclSvrHandle; \
                            if \[catch { eval \"clientSend \$ixTclSvrHandle {%s \$args}\" } result\] {error \$result \$result}; \
	                        if  {\$result != \"\"} {if \[catch { eval \"clientSend \$ixTclSvrHandle {set ixErrorInfo}\" } ::ixErrorInfo] {error \$::ixErrorInfo \$::ixErrorInfo}}; \
                            return \$result \
                        }" \
        $procName $procName]
    }
    return 0
}

########################################################################################
# Procedure:    getConstantsValue
#
# Description:     Get the list of constants from ixTclServer.
#                
# Input:        serverSocket
#
# Output:        0 if successful
#                1 if error
#
########################################################################################
proc getConstantsValue {serverSocket} \
{
    set retCode 0

    set constList  [clientSend $serverSocket {array get ixConstants}]
    if {[llength $constList] > 0} {
        foreach {constName constVal} $constList {
            global $constName
            # The catch prevents the error message from flowing back on windows
            catch {set $constName $constVal}
        }
    } else {
        set retCode 1
    }

    return $retCode
}


########################################################################################
# Procedure:    ixMasterSet
#
# Description:     No clue what this is here for, but I'm leaving it for backwards compatibility
#
# Input:
#
########################################################################################
proc ixMasterSet {name element op} \
{
    upvar ${name}($element) master
    tclServer::connectToTclServer $master errMsg
}

########################################################################################
# Procedure:    redefineCommand
#
# Description:     Redefine the specified command to make its methods import and export work 
#               for UNIX client.
#
# Input:        command - name of the command to be redefined.
#
########################################################################################
proc redefineCommand {command} \
{
    set commandOld ${command}Old

    if { [info command $command] != "" } {
        if { [info command $commandOld] == "" } {
            rename $command $commandOld
        }
    }
    eval [format "proc %s {args} \
          { \
              set cmdLine %s ; \
              set path \[file dirname \[lindex \$args 1\]\] ;\
              set fileName \[file tail \[lindex \$args 1\]\] ;\ 
              if { \$path == \".\" } { \
                append cmdLine \" \$args\"; set path \$fileName } else { \
                append cmdLine \" \[lindex \$args 0\] \$fileName \[lindex \$args 2\] \[lindex \$args 3\] \[lindex \$args 4\] \" }\

              switch \[lindex \$args 0\] { \
                  import { \
                      doFileTransfer \"put\" \[lindex \$args 1\] \$fileName ; \
                      eval \$cmdLine; \
                  } \
                  export { \
                      set retCode \[eval \$cmdLine\]; \
                      if \{\$retCode == 0\} \{ \
                          doFileTransfer \"get\" \$fileName \[lindex \$args 1\]; \
                      \} \
                  } \
                  default { \
                      eval \$cmdLine; \
                  } \
               } \
           }" \
    $command $commandOld]
}

########################################################################################
# Procedure:    doFileTransfer
#
# Description:     Transfer files between client and chassis.
#
# Input:        action    - Has to be either put or get.
#                            
# Unix doesn't need the full path of the file, that is why it is based on the direction 
# if it is put or get, we have to pass in two filenames, one for source the other for
# destination  
#               filename1  - Name of the file to be transfered.
#               filename2  - Name of the file to be transfered. 
#
########################################################################################
proc doFileTransfer {action filename1 filename2 {port 4500}} \
{
    set retCode 1

    if [tclServer::isTclServerConnected] {
        set retCode [fileTransferClient::${action}File [tclServer::getTclServerName] $port "$filename1" "$filename2"]
    }

    return $retCode
}

