######################################################################################
# Version 3.70 $     $Revision: 9 $
# $Date: 1/15/03 10:33a $
# $Author: Zzhang $
#
# $Workfile: dapconfiguration.tcl $               
#
#   This file contains the configuration parameters for running ixDapConfig::main.
#
#   Copyright © 1997 - 2003 by IXIA
#   All Rights Reserved.
#
#	Revision Log:
#	11-14-02	Debby Stopp
#
########################################################################################

source ixDapConfig.tcl
logOn ixDapConfig.log

##
#  Application name
#       Need to set the exact name of the application to be downloaded to each port
##
set applicationName      ""


##
#  Startup procedure/executable
#       If there's a startup procedure that needs to be excuted after downloading, put the name
#       of that executable here. The entire patch to the executable must be specified in the startupProcedureExe.
#       No action taken if variable is set to ""
##
set startupProcedureExe  ""


##
#  Specify login name to use for taking ownership of ports.
#  Ownership is *mandatory* for this application.
##
ixDapLogin "ixDapConfig"


##
# Chassis list
#    Put chassis ip OR DNS host name; put in order of usage.
#    First chassis == ID 1, second chassis == ID 2, etc... 
##
ixDapConfig::setChassisList {loopback}


##
# Port array & ip stuff - Configure port interface details 
#                         <portId, macAddress, ipAddress, gateway, mask, enableVlan, vlanId>
#   NOTE: 
#       portID == {<chassisID> <cardID> <portID>}
##
ixDapAddPortInterface   -portId         {1 1 1} \
                        -macAddress     "00 de bb 01 01 01" \
                        -ipAddress      "198.18.1.100" \
                        -gateway        "198.18.1.1" \
                        -mask           "255.255.255.0" \
                        -enableVlan     false \
                        -vlanId         101

ixDapAddPortInterface   -portId         {1 1 1} \
                        -macAddress     "00 de bb 01 02 01" \
                        -ipAddress      "198.18.2.100" \
                        -gateway        "198.18.2.1" \
                        -mask           "255.255.255.0" \
                        -enableVlan     false \
                        -vlanId         101

ixDapAddPortInterface   -portId         {1 1 1} \
                        -macAddress     "00 de bb 01 03 01" \
                        -ipAddress      "198.18.3.100" \
                        -gateway        "198.18.3.1" \
                        -mask           "255.255.255.0" \
                        -enableVlan     false \
                        -vlanId         101

ixDapAddPortInterface   -portId         {1 1 2} \
                        -macAddress     "00 de bb 01 01 02" \
                        -ipAddress      "198.18.1.102" \
                        -gateway        "198.18.1.1" \
                        -mask           "255.255.255.0" \
                        -enableVlan     true \
                        -vlanId         102

ixDapAddPortInterface   -portId         {1 1 3} \
                        -macAddress     "00 de bb 01 01 03" \
                        -ipAddress      "198.18.1.103" \
                        -gateway        "198.18.1.1" \
                        -mask           "255.255.255.0" \
                        -enableVlan     false \
                        -vlanId         103

ixDapAddPortInterface   -portId         {1 1 4} \
                        -macAddress     "00 de bb 01 01 04" \
                        -ipAddress      "198.18.1.104" \
                        -gateway        "198.18.1.1" \
                        -mask           "255.255.255.0" \
                        -enableVlan     false \
                        -vlanId         104


##
#  Config test network topology - Add route table details 
#                         <portId, target(net or host), ipAddress, gateway, mask>
##
ixDapAddRouteTable      -portId         {1 1 1} \
                        -target         "net" \
                        -ipAddress      "198.20.0.0" \
                        -gateway        "198.18.2.1" \
                        -mask           "255.255.0.0"

ixDapAddRouteTable      -portId         {1 1 1} \
                        -target         "host" \
                        -ipAddress      "198.20.1.100" \
                        -gateway        "198.18.3.1" \
                        -mask           "255.255.255.255"

##
#  Config port filter - Add port filter details 
#                       <reset, port list, action, filter type, type valueList>
##
ixDapAddPortFilter      -reset      true \
                        -portList   {{1 1 1} {1 1 2}} \
                        -action     "enable" \
                        -type       "ip-protocols" \
                        -valueList  {4 17}

ixDapAddPortFilter      -reset      false \
                        -portList   {{1 1 1}} \
                        -action      "disable" \
                        -type       "udp-ports" \
                        -valueList  {22-23 25}

ixDapAddPortFilter      -reset      false \
                        -portList   {{1 1 1}} \
                        -action      "enable" \
                        -type       "tcp-ports" \
                        -valueList  {22-23 25}

##
# alternatively, set port list via loop:
##
#set firstChassisId   1
#set lastChassisId    1
#set firstCardId      3
#set lastCardId       3
#set firstPortId      5
#set lastPortId       8
#set ipAddress        "198.18.1.100"
#set gateway          "198.18.1.1"
#set mask             "255.255.255.0"
#set incrSubnetByte   3
#
#for {set chassis $firstChassisId} {$chassis <= $lastChassisId} {incr chassis} {
#    for {set card $firstCardId} {$card <= $lastCardId} {incr card} {
#        for {set port $firstPortId} {$port <= $lastPortId} {incr port} {
#            set macAddress [format "00 de bb %02x %02x %02x" $chassis $card $port]
#            ixDapConfigPort $chassis $card $port $macAddress $ipAddress $gateway $mask
#            set ipAddress [incrIpField $ipAddress $incrSubnetByte]
#            set gateway   [incrIpField $gateway   $incrSubnetByte]
#        }
#    }
#}

#########################################################################################
# end of user configuration stuff
########################################################################################

########################################################################################
# execute config/download app here
########################################################################################
if {![ixDapConfig::main -appName $applicationName]} {
    if {$startupProcedureExe != ""} {
        if [catch {exec $startupProcedureExe &} error] {
            logMsg $error
        }
    }

    logMsg "\n*** Setup now complete!!! ***"
}

