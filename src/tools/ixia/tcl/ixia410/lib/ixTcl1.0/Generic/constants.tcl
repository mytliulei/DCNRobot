##################################################################################
# Version 4.10	$Revision: 39 $
# $Date: 9/30/02 3:52p $
# $Author: Mgithens $
#
# $Workfile: constants.tcl $ - Constants parameters
#
#   Copyright © 1997 - 2005 by IXIA
#   All Rights Reserved.
#
#	Revision Log:
#	12-30-1998	Hardev Soor
#
# Description: This file contains common constants
#
##################################################################################

# -----------------------------------------------------
# Hardcoded from HAL so that the connection TclSvrConnect 
# can be made after the package require ->  if using UNIX
# -----------------------------------------------------

# protocol mapping
set kProtocol(0)				mac
set kProtocol(4)				ip
set kProtocol(5)				udp
set kProtocol(6)        		tcp
set kProtocol(7)				ipx
set kProtocol(31)				ipV6

# IP address class mapping
set kIpAddrClass(0)     		classA
set kIpAddrClass(1)     		classB
set kIpAddrClass(2)     		classC
set kIpAddrClass(3)     		classD
set kIpAddrClass(4)     		noClass


# some link state constants
set kLinkState(linkDown)                0
set kLinkState(linkUp)                  1
set kLinkState(linkLoopback)            2
set kLinkState(miiWrite)                3
set kLinkState(restartAuto)             4
set kLinkState(autoNegotiating)         5
set kLinkState(miiFail)                 6
set kLinkState(noTransceiver)           7
set kLinkState(invalidAddress)          8
set kLinkState(readLinkPartner)         9
set kLinkState(noLinkPartner)           10
set kLinkState(restartAutoEnd)          11	
set kLinkState(fpgaDownloadFail)        12
set kLinkState(noGbicModule)            13    
set kLinkState(fifoReset)               14       
set kLinkState(fifoResetComplete)       15
set kLinkState(pppOff)                  16          
set kLinkState(pppUp)                   17           
set kLinkState(pppDown)                 18         
set kLinkState(pppInit)                 19         
set kLinkState(pppWaitForOpen)          20  
set kLinkState(pppAutoNegotiate)        21
set kLinkState(pppClose)                22        
set kLinkState(pppConnect)              23      
set kLinkState(lossOfFrame)             24     
set kLinkState(lossOfFramePppDisabled)  25	
set kLinkState(stateMachineFailure)     26  
set kLinkState(pppRestartNegotiation)   27
set kLinkState(pppRestartInit)          28       
set kLinkState(pppRestartWaitForOpen)   29
set kLinkState(pppRestartWaitForClose)  30
set kLinkState(pppRestartFinish)        31     


# some generic frame constants
set kFirSize			6
set kCrcSize			4
set kUdfSize			4


# duplex mode mapping
set kDuplexMode(0)		half
set kDuplexMode(1)		full

# levels of storing results
set kResultLevel(test)      test
set kResultLevel(iter)      iter
set kResultLevel(port)      port
set kResultLevel(portCat)   portCat
set kResultLevel(portItem)  portItem

# IPX constants
set kSapOperation(request)                      1
set kSapOperation(response)                     2    ;# General Service Response
set kSapOperation(getNearestServerRequest)      3
set kSapOperation(getNearestServerResponse)     4
set kSapServiceType(unknown)                    {00 00}
set kSapServiceType(printQueue)                 {00 03}
set kSapServiceType(fileServer)                 {00 04}
set kSapServiceType(jobServer)                  {00 05}
set kSapServiceType(printServer)                {00 07}
set kSapServiceType(archiveServer)              {00 09}
set kSapServiceType(remoteBridgeServer)         {00 24}
set kSapServiceType(advertisingPrintServer)     {00 47}
set kRIPXOperation(request)                     1
set kRIPXOperation(response)                    2
set kBroadcastMacAddress                        {ff ff ff ff ff ff}
set kSapSocket                                  0x452
set kRipSocket                                  0x453
set kHeaderLength(ip)	                        20
set kHeaderLength(ipV6)	                        40
set	kHeaderLength(udp)                      	8
set	kHeaderLength(rip)	                        4
set	kHheaderLength(icmp)                    	8
set kIPXHeaderLength	                    	30

if {![info exists TCL_OK]} {
    set TCL_OK      0
    set TCL_ERROR   1
}


### Mii constants for 10ge ###
set miiPreemphasisNone      0   ;# 0x0000
set miiPreemphasis18        1   ;# 0x4000 
set miiPreemphasis38        2   ;# 0x8000
set miiPreemphasis75        3   ;# 0xC000
 

set miiLossOfSignal160mv    0   ;# 0x0000
set miiLossOfSignal240mv    1   ;# 0x0010
set miiLossOfSignal200mv    2   ;# 0x0020
set miiLossOfSignal120mv    3   ;# 0x0030
set miiLossOfSignal80mv     4   ;# 0x0040

set miiRecoveredClock       0 
set miiLocalRefClock        1   

