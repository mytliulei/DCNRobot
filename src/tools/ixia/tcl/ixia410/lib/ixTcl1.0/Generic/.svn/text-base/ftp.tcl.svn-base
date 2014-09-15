##################################################################################
#	Version 4.10	$Revision: 10 $
#	$Author: Mgithens $
#
#	$Workfile: ftp.tcl $
#
#   Copyright © 1997 - 2005 by IXIA
#   All Rights Reserved.
#
#	Description:  This file contains utilities FileTransfer
#
#	Revision Log:
#	Date		Author				Comments
#	-----------	-------------------	--------------------------------------------
#   10/25/2000  ds          		initial release
#
##################################################################################

package require FTP

########################################################################################
# Procedure:	putFtpLogWindow
#
# Description: 	Write a message to the ftp log window
#				
# Input:		textEntry
#
########################################################################################
proc putFtpLogWindow {textEntry} \
{
    logMsg $textEntry
}


########################################################################################
# Procedure:	ixFileSend
#
# Description: 	FTP protocol stuff... 
#
# Input:
#
########################################################################################
proc ixFileSend {ipAddress filename username password sourceDirectory destDirectory} \
{
    set retCode 0

    global ftpDone

    putFtpLogWindow "ipAddress=$ipAddress\nfilename=$filename\nusername=$username\npassword=$password\nsourceDirectory=$sourceDirectory\ndestDirectory=$destDirectory"

    set retCode 1
    if {[file isdirectory $destDirectory]} {
        if {![FTP::Open $ipAddress $username $password  -mode passive]} {
            putFtpLogWindow"Error opening FTP session"
            set retCode 2
        } else {
            if {![FTP::Get $sourceDirectory$filename $destDirectory$filename]} {
                putFtpLogWindow "Error getting file $sourceDirectory$filename"
                set retCode 3
            }
        }
        FTP::Close
    } else {
        putFtpLogWindow "Error - invalid destination directory $destDirectory"
        set retCode 4
    }

    set ftpDone $retCode

    if {$ftpDone == 1} {
        set retCode 0
    } else {
        set retCode 1
    }

    return $retCode
}


########################################################################################
# Procedure:	ixFileTransferStart
#
# Description: 	FTP protocol stuff... 
#
# Input:
#
########################################################################################
proc ixFileTransferStart { ipAddress filename username password sourceDirectory destDirectory } \
{
    global ixTclSvrHandle ftpDone

    set retCode 0

    ixFileSend $ipAddress $filename $username $password $sourceDirectory $destDirectory

    set ftpDone 0
    while {$ftpDone==0} {
        ;# Make a time out counter here
        ;# probably count to about 100 then
        ;# a failure should be returned
        set x 0
        after 1000 {set x 1}
        vwait x
    }
  
    switch $ftpDone {
        1 {
            ixPuts "File transfer complete."
        }
        2 {
            ixPuts "Error opening FTP session on $ipAddress, username:$username."
            set retCode 1
        }
        3 {
            ixPuts "Error transferring file $sourceDirectory$filename to $destDirectory$filename."
            set retCode 1
        }
        4 {
            ixPuts "Error - invalid destination directory $destDirectory"
            set retCode 1
        }
    }

    return $retCode
}
