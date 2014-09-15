########################################################################
# Version 4.10	$Revision: 15 $
# $Date: 9/30/02 3:57p $
# $Author: Mgithens $
#
# $Workfile: fileTransferClient.tcl $
#
#   Copyright © 1997 - 2005 by IXIA
#   All Rights Reserved.
#
# Revision Log:
#       5-14-2001       Andy Balogh created
#
# Description: 
#	commands to transfer files using ixTclServer as the server
#
#   NOTE:  We use this mechanism because the ixTclServer is not setup
#          to be a 'real' fully-functioning FTP server; it really only
#          does some simple file transfer stuff.
#
########################################################################


########################################################################
# Protocol Description
# 
# bytes  reqd  description
# -----  ----  ----------------------------------------
#    20  Y     length of transaction
#     1  Y     command 0=success, 1=error, 2=getFile, 3=putFile, 4=listDirectory, 5=deleteFile
#    20  Y     length of command details
# above  Y     command details, error=errorCode
#                               getFile=fileName
#                               putFile=fileName
#                               listDirectory=directory
#                               deleteFile=fileName
#    20  Y     length of data
# above  N     data for the command being executed, 
#              error=text description of the error, 
#              getFile=the file data, 
#              putFile=the file Data, 
#              listDirectory=the directory listing, 
#              deleteFile=null
#
########################################################################
namespace eval fileTransferClient {} \
{
    variable dataSocket
    variable sourceFile
    variable destinationFile
        
    variable transactionSize
    variable commandId
    variable commandDetailsSize
    variable commandDetails
    variable dataSize

    variable totalBytesRead
    variable buffer
    variable destinationFileId
    variable transferOutcome
    variable transferOutcomeDetails
}


########################################################################
# Procedure: fileTransferClient::openConnectionToTclServer
#
# Description: This command connects to an ixTclServer
#
# Argument(s):
#    hostname               - hostname of the ixTclServer
#    port                   - port number, should be 4500
#
# Return Values: returns 0-success, 1-error
########################################################################
proc fileTransferClient::openConnectionToTclServer { hostname {port 4500} } \
{
    variable dataSocket
    variable commandId

    set returnValue 1

    catch { set dataSocket [socket $hostname $port] }

    if { $dataSocket != "" } {
        
        fconfigure $dataSocket -blocking  0
        fconfigure $dataSocket -buffering none
        fconfigure $dataSocket -buffersize 8192
        
        if { $commandId == 2 } {

            fconfigure $dataSocket -translation {binary binary}
            fconfigure $dataSocket -encoding binary
        
        } else {

            fconfigure $dataSocket -encoding binary
            fconfigure $dataSocket -translation {binary binary}
        
        }

        set returnValue 0

    }

    return $returnValue
}


########################################################################
# Procedure: fileTransferClient::closeTclServerConnection
#
# Description: This command closes the connection to an ixTclServer
#              and optionally closes the destinationFileId if the
#              command is a getFile
#
# Argument(s):
#
# Return Values: always returns 0
########################################################################
proc fileTransferClient::closeTclServerConnection {} \
{
    variable dataSocket
    variable destinationFileId

    close $dataSocket

    if { $destinationFileId != "" } { 

        close $destinationFileId

    }

    return 0
}


########################################################################
# Procedure: fileTransferClient::sendTransactionToTclServer
#
# Description: This command sends a formatted transaction to an ixTclServer
#
# Argument(s):
#
# Return Values: returns 0-success, 1-error
########################################################################
proc fileTransferClient::sendTransactionToTclServer { transaction } \
{
    variable dataSocket
    variable totalBytesRead 0
    variable buffer ""
    variable transferOutcomeDetails
    variable transferOutcome
    variable destinationFile
    variable transactionSize 0
    variable commandSize 0
    variable commandDetails ""
    variable commandDetailsSize 0
    variable dataSize -1

    set returnValue 1

    if { $dataSocket != "" } {

        fconfigure $dataSocket -blocking  1
        set line [puts $dataSocket $transaction]
        flush $dataSocket

        set totalBytesRead [expr $totalBytesRead + [string length $line] ]
        set buffer $line

        set returnValue [fileTransferClient::getTransferOutcome]
    }

    return $returnValue
}


########################################################################
# Procedure: fileTransferClient::getFile
#
# Description: This command gets a file using ixTclServer as the server
#
# Argument(s):
#    hostname        - hostname of the ixTclServer
#    port            - port number, should be 4500
#    sourceFile      - name of the file to get, can be absolute or relative
#    destinationFile - name of the file that the contents will be saved as
#
# Return Values: returns 0-success, 1-error
########################################################################
proc fileTransferClient::getFile { hostname port sourceFile destinationFile } \
{
    variable totalBytesRead 0
    variable transactionSize 0
    variable commandSize 0
    variable commandDetails 0
    variable destinationFileId ""
    variable transferOutcomeDetails 0
    variable commandId 2
    
    set returnValue 1

    if { [openConnectionToTclServer $hostname $port] == 0 } { 

        set commandDetails $sourceFile
        set commandDetailsSize [format "%.20d" [string length $commandDetails]]
        set transactionSize [format "%.20d" [expr 20 + [string length $commandId] + [string length $commandDetailsSize] + [string length $commandDetails]]]
        set transaction $transactionSize$commandId$commandDetailsSize$commandDetails

        set destinationFileId [ixFileUtils::open $destinationFile w]
        if { $destinationFileId != "" } { 

            fconfigure $destinationFileId -encoding binary
            fconfigure $destinationFileId -eofchar { "" "" }
            fconfigure $destinationFileId -translation { lf lf }
            
            set returnValue [sendTransactionToTclServer $transaction]
        
        } else { 
        
            closeTclServerConnection

            set transferOutcomeDetails "Unable to open source file"
        }
    
    } else {

        set transferOutcomeDetails "Unable to open socket"
    }

    return $returnValue
}


########################################################################
# Procedure: fileTransferClient::putFile
#
# Description: This commands puts a file using ixTclServer as the server
#
# Argument(s):
#    hostname        - hostname of the ixTclServer
#    port            - port number, should be 4500
#    sourceFile      - name of the file to get, can be absolute or relative
#    destinationFile - name of the file that the contents will be saved as
#
# Return Values: always returns 0
########################################################################
proc fileTransferClient::putFile { hostname port sourceFile destinationFile } \
{
    variable totalBytesRead 0
    variable transactionSize 0
    variable commandSize 0
    variable commandDetails ""
    variable dataSize -1
    variable buffer
    variable destinationFileId ""
    variable transferOutcomeDetails 0
    variable commandId 3

    set returnValue 1
        
    if { [openConnectionToTclServer $hostname $port] == 0 } { 

        set commandDetails $destinationFile
        set commandDetailsSize [format "%.20d" [string length $commandDetails]]
        set dataSize [format "%.20d" [file size $sourceFile]] 

        set sourceFileId [ixFileUtils::open $sourceFile r]

        if { $sourceFileId != "" } { 
 
            fconfigure $sourceFileId -translation { binary binary }
            fconfigure $sourceFileId -encoding binary
            set fileData [read -nonewline $sourceFileId]
            close $sourceFileId

            set transactionSize [format "%.20d" [expr 20 + [string length $commandId] + [string length $commandDetailsSize] + [string length $commandDetails] + [string length $dataSize] + [string length $fileData]]]
            set transaction $transactionSize$commandId$commandDetailsSize$commandDetails$dataSize$fileData

            set returnValue [sendTransactionToTclServer $transaction]

        } else {

            closeTclServerConnection

            set transferOutcomeDetails "Unable to open source file"
        }

    } else {

        set transferOutcomeDetails "Unable to open socket"
    }

    return $returnValue
}


########################################################################
# Procedure: fileTransferClient::getTransferOutcome
#
# Description: This command reads the response from the ixTclServer
#
# Argument(s):
#    dataSocket      - a connected socket 
#
# Return Values: always returns 0
########################################################################
proc fileTransferClient::getTransferOutcome {} \
{
    variable totalBytesRead 0
    variable transactionSize 0
    variable commandId -1
    variable commandDetailsSize -1
    variable commandDetails ""
    variable dataSize -1
    variable buffer ""
    variable destinationFileId
    variable transferOutcome
    variable transferOutcomeDetails
    variable dataSocket
    
    fconfigure $dataSocket -blocking 0

    set returnValue 1
    set endSocketRead 0

    while { $endSocketRead == 0 } {
        
        set line [read $dataSocket 2048]
        set totalBytesRead [expr $totalBytesRead + [string length $line]]
        append buffer $line

        if { ( $transactionSize == 0 ) && ( [string length $buffer] >= 40 ) } {

            set transactionSize [string range $buffer 0 19]
            set transactionSize [string trimleft $transactionSize "0"]
            set transactionSize [expr int( $transactionSize )]
                
            set commandId [string range $buffer 20 20]

            set commandDetailsSize [string range $buffer 21 40]
            set commandDetailsSize [string trimleft $commandDetailsSize "0"]
            set commandDetailsSize [expr int( $commandDetailsSize )]
        
            set buffer [string range $buffer 41 [string length $buffer]]
        
        }

        if { $commandDetailsSize > 0 && [string length $commandDetails] == 0 && $totalBytesRead >= [expr 41 + $commandDetailsSize] } {
            set commandDetails [string range $buffer 0 [expr $commandDetailsSize - 1]]
        
            set buffer [string range $buffer $commandDetailsSize [string length $buffer]]
        }

        if { $commandId == 0 && $dataSize == -1 && $commandDetailsSize > 0 } {
            set dataSize [string range $buffer 0 19]
        
            if { [string length $dataSize] > 0 } {
    
                set dataSize [string trimleft $dataSize "0"]
                set dataSize [expr int( $dataSize )]
                set buffer [string range $buffer 20 [string length $buffer]]
    
            } else {
                set dataSize 0
            }
        }

        if { $transactionSize > 0 && $totalBytesRead == $transactionSize } { 
            set endSocketRead 1
        }

       if { $destinationFileId != "" && $dataSize != -1 } {
           puts -nonewline $destinationFileId $buffer
	       flush $destinationFileId
           set buffer ""
       }
    }
    
    closeTclServerConnection

    if { $totalBytesRead - [expr 41 + $commandDetailsSize] >= $dataSize && $commandId == 0 } {

        set transferOutcomeDetails "SUCCESS"
        set returnValue 0

    } else {
        set transferOutcomeDetails $commandDetails
    }

    return $returnValue
}




