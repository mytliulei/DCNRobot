###############################################################################
# Version 4.10 $Revision: 33 $
# $Date: 10/03/02 2:43p $
# $Author: Mgithens $
#
# $Workfile: socket.tcl $
#
#   Copyright © 1997 - 2005 by IXIA
#   All Rights Reserved.
#
# Revision Log:
#
# Description: 
#
###############################################################################

###############################################################################
# Procedure: serverSocketAccept
#
# Description: This function accepts a connection request from client and 
#              spawns a new socket that will be used to communicate with client
#
# Arguments:
#    socket - the name of the socket to configure
#    addr - the ip address or hostname of client
#    port - the port number of the server socket
###############################################################################
proc serverSocketAccept {socket addr port} \
{ 
    debugMsg "enter serverSocketAccept $socket from $addr port $port"

    fconfigure $socket -buffering none
    fconfigure $socket -blocking 0
    fileevent  $socket readable [list readsocket $socket]

    debugMsg "exit  serverSocketAccept"
}


###############################################################################
# Procedure: readSocket
#
# Description: This function reads a line from client. It is invoked 
#              everytime a message arrived from client.
#
# Arguments:
#    socket - the socket that is communicating with the client.
###############################################################################
proc readsocket {socket} \
{
    global socketArray

    debugMsg "enter readSocket $socket"

    if {[eof $socket] || [catch {gets $socket line}]} {

        closeSocket $socket
        debugMsg "Close $socket"

     } else {
        
        debugMsg "line=$line"

        if {[string compare $line "quit"] == 0} {
            close $socketArray(serverSocket)
            catch {unset socketArray(serverSocket)}
        }

        if [isLogSocket $socket] {

            if { ![regexp {client response:|runningStatus:|this is log socket} $line] } {

                if [fblocked $socket] {
                    set line [read -nonewline $socket]
                    updateLog $line 0
                } else {
                    updateLog $line
                }

            } else {

                handleEvent $socket $line
            }

        } elseif {[isCommandSocket $socket]} {
            fileTransferServer::handleCommand $line

        } elseif {[isDataSocket $socket]} {

            fileTransferServer::handleData $line

        } else {

            handleEvent $socket $line
        }
    }

    update idletask
    debugMsg "exit  readSocket"
}


###############################################################################
# Procedure: handleEvent
#
# Description: This function invokes the appropriate action according to the
#              contents of the input from client.
#
# Arguments:
#    socket - the socket that received the line.
#    line - the character string received from the client
###############################################################################
proc handleEvent {socket line} \
{
    global currContext
    global socketArray

    debugMsg "enter handleEvent socket=$socket line=$line"
    
    set commandPattern ""
    catch { regexp {(.*): (.*)} $line match commandPattern portMapList }


    if {[regexp {client response} $line]} {

        # Nothing to do

    } elseif {$line == "closeSocket"} {

        closeSocket $socket

    } elseif {$line == "runningStatus:currentTestFinished"} {

        updateLog "\n****** Current test(s) finished ******"

        runStop
        forceToStop

       	setSF08StartButtonState normal

        displayResults

    } elseif {$line == "runningStatus:currentTestFailed"} {

        updateLog "\n****** Current test(s) failed ******"

        runStop
        forceToStop

    } elseif {$line == "runningStatus:currentTestStopped"} {

        updateLog "\n****** Current test(s) stopped ******"

        runStop
        forceToStop

        setSF08StartButtonState normal

    } elseif {$line == "runningStatus:currentTestStoppedByUser"} {

        updateLog "\n****** Current test(s) stopped by user ******"

        forceToStop
       
        setSF08StartButtonState normal

    } elseif {[regexp {removefile} $line]} {

        set file [lindex [split $line "?"] 1]
        debugMsg "file to be removed is $file"

        if [file exists $file] {
            catch {file delete $file}
        }

    } elseif {$line == "progress dialog is ready"} {

        progressDialogReady

    } elseif {$line == "this is test command socket"} {

        set currContext(commandSocketReady) 1
        set socketArray(testCommandSocket)  $socket

    } elseif {$line == "Background wish is ready"} {

        backgroundWishReady
        
    } elseif {$line == "this is log socket"} {

        set socketArray(logSocket) $socket

    } elseif {$line == "this is command socket"} {

        set socketArray(commandSocket) $socket

    } elseif {$line == "this is data socket"} {

        set socketArray(dataSocket) $socket
    } elseif { $commandPattern == "portlist" } {

        debugMsg "[pid]>>>>>>>>> portMapList:$portMapList"
        testConfig::setCurrentTestMap $portMapList 
    }

    debugMsg "exit  handleEvent"
}


###############################################################################
# Procedure: generatePort
#
# Description: This function generates a port for then server side socket.
#              It is based on the current pid.
#
# Returns the generated port number.
###############################################################################
proc generatePort {} \
{
    debugMsg "enter generatePort"

    set port [pid]
    set len  [string length $port]
    debugMsg "pid=$port"

    if {$len > 4} {
        set port [string range $port [expr $len - 4] [expr $len - 1]]
    }

    if {[string compare $port 0] != 0} {
        set port [string trimleft $port 0] 
    }

    if {$port < 4000} {
        incr port 4000
    }

    debugMsg "exit  generatePort port=$port"
    return $port
}


###############################################################################
# Procedure: putsClient
#
# Description: This function sends a line to client.
#
# Arguments:
#    line - The string of characters that is to be sent to the client side.
###############################################################################
proc putsClient {line} \
{
    global socketArray

    debugMsg "enter putsClient line=$line"

    if {([info exists socketArray(testCommandSocket)] == 0) || \
            ($socketArray(testCommandSocket) == -1)} {
        debugMsg "exit putsClient on testCommandSocket does not exist"

    } else {
        catch {puts  $socketArray(testCommandSocket) $line}
        catch {flush $socketArray(testCommandSocket)}
        debugMsg "exit  putsClient"
    }
}


###############################################################################
# Procedure: createServerSocket
#
# Description: This function creates a server side socket on the specified
#              port. If port is not specified, the port number will be 
#              generated using pid and set to SCRIPTMATE_PORT as an environment
#              variable.  The spawned child process will retrieve the port
#              number from the environment and create a client side socket.
#
# Arguments:
#    port  - Optional.  The port number to use.  Defaults to -1 if not given.
#    retry - Optional.  Increase the port number by 1 until a port is available
#                       and server socket is created when this argument is true.
#                       Otherwise give up if the port is not available.
# Returns:
#    port  - The port number of server socket.
#
###############################################################################
proc createServerSocket {{port -1} {retry true}} \
{
    global env socketArray

    debugMsg "enter createServerSocket"

    if {$port == -1} {
        set port [generatePort]
    }

    while {[catch {socket -server serverSocketAccept $port} socketArray(serverSocket)] == 1} {
        if {$retry == "true"} {
            incr port
            debugMsg "port=$port"
        } else {
            set port -1
            break
        }
    }

    debugMsg "exit  createServerSocket $port"
    return $port
}


###############################################################################
# Procedure: closeSocket
#
# Description: Close either the given socket, or if none given, close the 
#              global new socket
#
# Arguments:
#    socket - Optional.  The socket to close
###############################################################################
proc closeSocket {socket} \
{
    global socketArray

    debugMsg "enter closeSocket $socket"

    if {$socket != -1} {
        # Close the given socket
        catch {close $socket}

        foreach name [array name socketArray] {
            if {$socketArray($name) == $socket} {
                catch {unset socketArray($name)}
                break
            }
        }
    }

    debugMsg "exit  closeSocket"
}


###############################################################################
# Procedure: closeServerSocket
#
# Description: Close the global main socket
###############################################################################
proc closeServerSocket {} \
{
    global socketArray

    debugMsg "enter closeServerSocket"

    if {[info exists socketArray(serverSocket)]} {
        catch {close $socketArray(serverSocket)}
        catch {unset socketArray(serverSocket)}
    }

    debugMsg "exit  closeServerSocket"
}

###############################################################################
# Procedure: isTestCommandSocket
#
# Description: Determine if the given socket is the same as the test command socket
#
# Arguments:
#    socket - the socket to check
#
# Returns 1 when it is the same socket, and 0 when it is not the same.
###############################################################################
proc isTestCommandSocket {socket} \
{
    global socketArray

    debugMsg "enter isTestCommandSocket $socket"

    set retCode 0

    if [info exists socketArray(testCommandSocket)] {
        if {$socket == $socketArray(testCommandSocket)} {
            set retCode 1
        }
    }

    debugMsg "exit  isTestCommandSocket $retCode"
    return $retCode
}

###############################################################################
# Procedure: isLogSocket
#
# Description: Determine if the given socket is the same as the log socket
#
# Arguments:
#    socket - the socket to check
#
# Returns 1 when it is the same socket, and 0 when it is not the same.
###############################################################################
proc isLogSocket {socket} \
{
    global socketArray

    debugMsg "enter isLogSocket $socket"

    set retCode 0

    if [info exists socketArray(logSocket)] {
        if {$socket == $socketArray(logSocket)} {
            set retCode 1
        }
    }

    debugMsg "exit  isLogSocket $retCode"
    return $retCode
}

###############################################################################
# Procedure: isCommandSocket
#
# Description: Determine if the given socket is the same as the command socket
#
# Arguments:
#    socket - the socket to check
#
# Returns 1 when it is the same socket, and 0 when it is not the same.
###############################################################################
proc isCommandSocket {socket} \
{
    global socketArray

    debugMsg "enter isCommandSocket $socket"

    set retCode 0

    if [info exists socketArray(commandSocket)] {
        if {$socket == $socketArray(commandSocket)} {
            set retCode 1
        }
    }

    debugMsg "exit  isCommandSocket $retCode"
    return $retCode
}

###############################################################################
# Procedure: isDataSocket
#
# Description: Determine if the given socket is the same as the data socket
#
# Arguments:
#    socket - the socket to check
#
# Returns 1 when it is the same socket, and 0 when it is not the same.
###############################################################################
proc isDataSocket {socket} \
{
    global socketArray

    debugMsg "enter isDataSocket $socket"

    set retCode 0

    if [info exists socketArray(dataSocket)] {
        if {$socket == $socketArray(dataSocket)} {
            set retCode 1
        }
    }

    debugMsg "exit  isDataSocket $retCode"
    return $retCode
}

###############################################################################
# Procedure: createClientSocket
#
# Description: Create a client socket for the given port name.
#
# Arguments:
#    port - Optional.  The port number to use for the socket being created.
#
# Returns the name of the socket created
###############################################################################
proc createClientSocket {{port -1}} \
{
    global ixgClientSocket

    debugMsg "enter createClientSocket"

    set socket [createClientSocketCreate localhost $port]

    if {$socket != -1} {
        fconfigure $socket -buffering line
        fileevent $socket readable [list readClientSocket $socket]
        #puts $socket "this is test command socket"
    }

    set ixgClientSocket $socket

    update idletask

    debugMsg "exit  createClientSocket $socket"
    return $socket
}


###############################################################################
# Procedure: closeClientSocket
#
# Description: Close the given socket.  If no socket given, close the global
#              ixgClientSocket
#
# Arguments:
#    socket - the name of the socket to close
###############################################################################
proc closeClientSocket {{socket -1}} \
{
    global ixgClientSocket

    if {$socket != -1} {
        catch {close $socket}
    } else {
        catch {close $ixgClientSocket}
    }
}


###############################################################################
# Procedure: closeAllSockets
#
# Description: Close the two global sockets
###############################################################################
proc closeAllSockets {} \
{
    global socketArray

    foreach name [array name socketArray] {
        closeSocket $socketArray($name)
    }
}


###############################################################################
# Procedure: readClientSocket
#
# Description: Read the data from the given socket
#
# Arguments:
#    socket - the socket to get the data from
###############################################################################
proc readClientSocket {socket} \
{
    if {[eof $socket] || [catch {gets $socket line}]} {
        debugMsg "readClientSocket: child eof line"
        close $socket
    } else {
        debugMsg "readClientSocket: $line"
        handleCommand $line
    }
}


###############################################################################
# Procedure: createClientSocketCreate
#
# Description: Create a client socket given a hostname and port id.
#
# Arguments:
#    host - the hostname to use
#    port - the port number to use
#
# Returns the name of the socket created
###############################################################################
proc createClientSocketCreate {host port} \
{
    global env

    if {$port == -1} {
        if {[info exists env(SCRIPTMATE_PORT)]} {
            set port $env(SCRIPTMATE_PORT)
        } else {
            debugMsg "Could not find env(SCRIPTMATE_PORT), failed creating socket."
            return -1
        }
    }

    set socketName [socket $host $port]
    fconfigure $socketName -blocking  0
    fconfigure $socketName -buffering line
    return $socketName
}


###############################################################################
# Procedure: putsServer
#
# Description:
#
# Arguments:
#    line - the character stream that is being sent to the server side.
#
# Returns 0 on success and 1 on failure
###############################################################################
proc putsServer {line} \
{
    global ixgClientSocket

    set retCode 0

    if {([info exists ixgClientSocket] == 0) || ($ixgClientSocket == -1)} {
        set retCode 1
        debugMsg "in putsServer, ixgClientSocket is bad"

    } else {
        debugMsg "in putsServer before line=$line is sent to server"
        if {[catch {puts $ixgClientSocket $line} retCode]} {

            # Stop the shell if the child socket is closed
            exit
        }
        catch {flush $ixgClientSocket}
    }

    return $retCode
}


###############################################################################
# Procedure: handleCommand
#
# Description: Handle the command sent to the client
#
# Arguments:
#    line - the character stream to handle
###############################################################################
proc handleCommand {line} \
{
    putsServer "client response: $line newline"

    if {$line == "stopTest"} {
        stopTest

    } elseif { $line == "closeSession" || $line == "stopTestNow" } {
        # kill current tcl shell
        closeAllSockets
        exit

    } elseif {[regexp {progressDialog} $line] == 1} {

        set msg [lindex [split $line :] 1]
        setMsgWinMessage $msg

    } elseif {$line == "createInterpreter"} {

        # Do nothing

    } elseif {[regexp {source\ ?} $line]} {

        regsub {source\ ?} $line "" filename

        if { [catch { eval "source \"$filename\"" } retCode] } {

            logMsg $retCode

        } else {

            if { $retCode == 0 } {
                logMsg "runningStatus:currentTestFinished"
            } else {
                logMsg "runningStatus:currentTestFailed"
            }
        }

        logOff

    } elseif {$line == "stopSF08Test"} {

        setStopTestFlag 1
        logOff

    } elseif { [regexp {connectToTclServer} $line] } {
        set serverName [lindex $line 1]
        tclServer::connectToTclServer $serverName errMsg

    } 

    debugMsg "handleCommand:Exit"

}
