######################################################################################
# Version 4.10	$
# $Date: 9/30/02 3:52p $
# $Author: Mgithens $
#
# $Workfile: dhcpExchange.tcl $               
#
#   Copyright © 1997 - 2005 by IXIA
#   All Rights Reserved.
#
#	Revision Log:
#	12-02-1998	Debby Stopp
#
# Description: This file contains procedures that send out DHCP exchange messages and
#   conforms to the DHCP specifications RFC 2131 and RFC 1533 with the following
#   exceptions:
#
#       Timers 1 & 2 not implemented in a port by port fashion
#       Lease expiration not handled in a port by port fashion
#       Release not implemented.
#
########################################################################################

set nullIP       "0.0.0.0"
set broadcastIP  "255.255.255.255"

#
#   Wrappers routines for dhcpClient namespace procedures
#
proc dhcpSetState               {chassis card port newState}        {dhcpClient::SetState $chassis $card $port $newState}
proc dhcpGetState               {chassis card port}                 {dhcpClient::GetState $chassis $card $port}
proc dhcpSetLease               {chassis card port lease}           {dhcpClient::SetLease $chassis $card $port $lease}
proc dhcpGetLease               {chassis card port}                 {dhcpClient::GetLease $chassis $card $port}
proc dhcpSetIP                  {chassis card port ip}              {dhcpClient::SetIP $chassis $card $port $ip}
proc dhcpGetIP                  {chassis card port}                 {dhcpClient::GetIP $chassis $card $port}
proc dhcpSetServer              {chassis card port server}          {dhcpClient::SetServer $chassis $card $port $server}
proc dhcpGetServer              {chassis card port}                 {dhcpClient::GetServer $chassis $card $port}
proc dhcpGetTimer               {timer}                             {dhcpClient::GetTimer $timer}
proc dhcpStartTimers            {lease {timer1 0} {timer2 0}}       {dhcpClient::StartTimers $lease $timer1 $timer2}
proc dhcpStartTimer             {timer lease}                       {dhcpClient::StartTimer $timer $lease}
proc dhcpStopTimers             {}                                  {dhcpClient::StopTimers}
proc dhcpStopTimer              {timer}                             {dhcpClient::StopTimer $timer}
proc dhcpSetStreamRegion        {region}                            {dhcpClient::SetStreamRegion $region}
proc dhcpGetStreamRegion        {}                                  {dhcpClient::GetStreamRegion}
proc dhcpSetPortList            {portList}                          {dhcpClient::SetPortList $portList}
proc dhcpGetPortList            {}                                  {dhcpClient::GetPortList}
proc dhcpStop                   {}                                  {dhcpClient::Stop}
proc dhcpStopPort               {chassis card port {release false}} {dhcpClient::StopPort $chassis $card $port $release}
proc dhcpEnableStateMachine     {{stateList dhcpClient::stateList} \
                                 {eventList dhcpClient::eventList} \
                                 {actionList dhcpClient::actionList}} \
                                                                    {dhcpClient::Initialize $stateList $eventList $actionList}
proc dhcpDisableStateMachine    {{stateList dhcpClient::stateList} \
                                 {eventList dhcpClient::eventList} \
                                 {actionList {}}}                   {dhcpClient::Initialize $stateList $eventList $actionList}


namespace eval dhcpClient {
variable debugLevel
#set debugLevel [list default state]
#set debugLevel [list default]
set debugLevel [list]
#
#   Public Procedures:  dhcpEnableStateMachine  (dhcpClient::Initialize)
#                       dhcpDisableStateMachine (dhcpClient::Initialize)
#                       dhcpStop                (dhcpClient::Stop)
#                       dhcpSetState            (dhcpClient::SetState)
#                       dhcpGetState            (dhcpClient::GetState)
#                       dhcpSetLease            (dhcpClient::SetLease)   
#                       dhcpGetLease            (dhcpClient::GetLease)
#                       dhcpGetTimer            (dhcpClient::GetTimer)
#                       dhcpStartTimers         (dhcpClient::StartTimers)
#                       dhcpStartTimer          (dhcpClient::StartTimer)
#                       dhcpStopTimers          (dhcpClient::StopTimers)
#                       dhcpStopTimer           (dhcpClient::StopTimer)
#                       dhcpSetIP               (dhcpClient::SetIP)
#                       dhcpGetIP               (dhcpClient::GetIP)
#                       dhcpSetServer           (dhcpClient::SetServer)
#                       dhcpGetServer           (dhcpClient::GetServer)
#                       dhcpSetStreamRegion     (dhcpClient::SetStreamRegion)
#                       dhcpGetStreamRegion     (dhcpClient::GetStreamRegion)
#                       dhcpSetPortList         (dhcpClient::SetPortList)
#                       dhcpGetPortList         (dhcpClient::GetPortList)
#												 dhcpClient::GetStateNames
#												 dhcpClient::GetStateCodes
#												 dhcpClient::GetStateName
#												 dhcpClient::ValidState
#												 dhcpClient::GetEventCodes
#												 dhcpClient::GetEventName
#												 dhcpClient::ValidEvent
#												 dhcpClient::debug

#
#   Private Procedures: dhcpClient::StateLookup
#                       dhcpClient::InitStateTable
#                       dhcpClient::ActionNull
#                       dhcpClient::ActionRenew
#                       dhcpClient::ActionRebound
#
#   Private Variables:  dhcpClient::dhcpLeaseRecord
#                       dhcpClient::stateList
#                       dhcpClient::eventList
#                       dhcpClient::actionList
#                       dhcpClient::streamRegion
#                       dhcpClient::portList
#                       
#
#   DHCP Stream Building.
#
#   When a DHCP lease needs to renew, the client must interrupt it's current
#       activities and send a renewal request.  This disrrupts the current
#       stream construct in region 0.  Rather than use region 0, DHCP streams
#       are constructed in region 1 and an asynchonous transmission is used for 
#       the renewal process.
#
variable    streamRegion
set         streamRegionMax 7
set         streamRegionMin 0

variable    portList
#   
#   DHCP timers.
#
#   Following the DHCP negotiation, the client has (hopefully) been supplied
#       with: IP address, lease duration, and a DHCP server ID.  Each of
#       these items are necessary for renewal of the IP lease.
#
#       Three time periods are associated with any given lease:
#           Timer1 = lease * .50
#           Timer2 = lease * .875
#           Expiration = lease
#
#       At the expiry of timer1, a dhcp Client tries to renew from current server
#       At the expiry of timer2, a dhcp Client tries to rebind from any server
#       At the expiry of lease,  a dhcp Client returns to the Init state and starts discovery.
#
#       However, IXIA is not attempting to implement a DHCP client state 
#           machine, and simply needs the insure that a renewal or rebind 
#           request maintains an IP address so that performance testing may 
#           resume.  A single timer, rather than a timer for each port, initiates 
#           the renewal process for ALL ports.
#
variable dhcpLeaseRecord
# dhcpLeaseRecord(timer1)       = identification of TCL timer (after), timer 1
# dhcpLeaseRecord(timer2)       = identification of TCL timer (after), timer 2
# dhcpLeaseRecord(leaseExpire)  = identification of TCL timer (after), lease expiration
# dhcpLeaseRecord(c,l,p,state)  = dhcp state for this port
# dhcpLeaseRecord(c,l,p,lease)  = duration of lease
# dhcpLeaseRecord(c,l,p,ip)     = leased IP address
# dhcpLeaseRecord(c,l,p,server) = dhcp server for leased IP address
#
#
#   DHCP States:    A state table allows the dhcpClient to respond to 
#                   background events (ie timers), the following are valid states:
#
#   Valid states:
#       idle:       Entered after client initially boots or lease expires
#       select:     Entered when client broadcasts for an IP address
#       request:    Entered when client has accepted an IP lease offer
#       bound:      Entered when client & server have agreed upon lease
#       renew:      Entered when timer1 expires
#       rebind:     Entered when/if timer2 expires
#
variable state
set state(idle)     0
set state(select)   1
set state(request)  2
set state(bound)    3
set state(renew)    4
set state(rebind)   5

#
#
#   DHCP State Table.
#
#   The table is organized by state/event.  For each state, and for each
#       potential event, there is a corresponding action.  If no action 
#       is desired for a particular event, the table element should
#       contain a referance to the NULL routine.
#
#       Currently this table is only being used with the renew & rebind 
#       states.
#
#       Example:    State/
#                   Event       Time Out            SomeEvent
#
#                   idle        dhcpActionNull      dhcpActionNull
#                   select      dhcpActionNull      dhcpDoSomething
#                   request     dhcpActionNull      dhcpDoSomething
#                   bound       dhcpActionRenew     dhcpDoSomething
#                   renew       dhcpActionRebind    dhcpDoSomething
#                   rebind      dhcpActionInit      dhcpDoSomething
#
#       The stateList contains a list of all known states.
#       The eventList contains a list of all potential events.
#       The actionList contains a list of all possible actions for each
#           state.  Note that an action *must* be listed for each event.
#
#
#   IXIA's DHCP Client:
#
#   This is not a true DHCP client implementation (the DHCP Client state
#       machine belongs in the protocol server).  IXIA requires
#       DHCP only for the establishment of IP address so that performance
#       testing may ensue.  Therefore, when timer1 expires, for any port, 
#       the assumption is made that all port timers are about to expire and
#       all ports are 'renewed' at that time.
#
variable stateTable
variable stateList
set stateList [list $state(idle) $state(select) $state(request) \
                    $state(bound) $state(renew) $state(rebind)]
#
# Known events
variable event
set event(timeOut)  1
#
variable eventList
set eventList [list $event(timeOut)]
#
# Action list by state.
#   The # of actions per state must equal the size of the eventList.
#   Set actionList [list] to disable the state machine.
#
#                         TimeOut      
#                         ------------ 
variable action
set action(idle)    [list ActionNull  ]
set action(select)  [list ActionNull  ]
set action(request) [list ActionNull  ]
set action(bound)   [list ActionRenew ]
set action(renew)   [list ActionRebind]
set action(rebind)  [list ActionInit  ]

variable actionList
set actionList      [list $action(idle) $action(select) $action(request) \
                          $action(bound) $action(renew) $action(rebind)]  

#   DHCP Option Parameter List.
#    
#   When the dhcp client issues a message, it has the option of specifying a 
#       list of configuration parameters it is interested in recieving from the
#       dhcp server.  The parameter list must be identical in all commands, except
#       dhcpRelease where no parameter list is specified.  Refer to section 9.6 of
#       RFC 1533.
variable paramRequestList


#   DHCP Magic Cookie
#       As defined in RFC 2131 (section 3), the first 4 bytes of option data
#       are always the dhcp magic cookie: 99,130, 83, 99.
variable magicCookie
set magicCookie {63 82 53 63}

#   DHCP Start Time
#       The time that the dhcp process was started.
variable startTime

}
## End of DhcpClient namespace

########################################################################################
# Procedure: DHCPdiscoverIP
#
# Description: This procedure uses the DHCP protocol to get an IP address for each
#              client
#
# Argument(s):
#	PortList  list of ports, ie, ixgSortMap
#   startState: The state to start in, default is state(discover):
#               0 = discover    (issue discover message)
#               1 = offer       (rx offer)
#               2 = request     (issue request)
#               3 = ack         (rx ack)
#               4 = done        (dhcp exchange complete)
#
########################################################################################
proc DHCPdiscoverIP {PortList {startState 0} {stateMachine disable}} \
{
    global dhcpAck dhcpNak dhcpOffer

  	upvar $PortList portList

    set retCode 0

    # Initialize state variables
    set state(discover) 0
    set state(offer)    1
    set state(request)  2
    set state(ack)      3
    set state(done)     4


    # Save the port list.
    set discoverList [getAllPorts portList]
    dhcpSetPortList  $discoverList

    # Enable/Disable state machine for IP renewal
    if {$startState == $state(discover)} {
        if {$stateMachine == "enable"} {
            dhcpEnableStateMachine
        } else {
            dhcpDisableStateMachine
        }
    }

    set discoverRetries 1
    set maxRetries      3
    set NAKCounter      0
    set currState       $startState

    # Start DHCP State Machine.
    while {$currState != $state(done)} {
        switch $currState { 
            0 {
                if [send_DHCP_discover $discoverList] {
                    errorMsg "Error sending discover frames. Discover failed."
                    set currState   $state(done)
                    set retCode     1
                } else {
                    incr currState
                }
            }

            1 {
                if [get_DHCP_offer discoverList] {
                    if {$discoverRetries < $maxRetries} {
                        incr discoverRetries
                        set currState   $state(discover)
                        errorMsg "Discover failed on one or more ports, retrying discover $discoverRetries of $maxRetries times..."
                    } else {
                        errorMsg "Error receiving offer frames. Discover failed."
                        set currState   $state(done)
                        set retCode     1
                    }
                } else {
                    incr currState
                }
            }

            2 {
                set requestList [getAllPorts portList]
                if [send_DHCP_request $requestList] {
                    errorMsg "Error sending request frames. Discover/Renew failed."
                    set currState   $state(done)
                    set retCode     1
                } else {
                    set currState $state(ack)
                }
            }

            3 {
                if [get_DHCP_ack $requestList command] {
                    errorMsg "Error receiving ack frames. Discover failed.\n"
                    set currState   $state(done)
                    set retCode     1
                } else {
                    if {$command == $dhcpAck} {
                        set NAKCounter 0
                        set currState $state(done)
                    }
                    if {$command == $dhcpNak} {
                        set discoverList $requestList
                        incr NAKCounter 
                        if {$NAKCounter >= 3} {
                            set currState $state(done)
                        } else {
                            set currState $state(discover)
                        }
                    }
                }
            }

            default {
                errorMsg "Error - invalid state $currState"
                set retCode 1
                break
            }
        }
    }

    return $retCode
}


########################################################################################
# Procedure: send_DHCP_discover
#
# Description: This command sends a DHCP discover frame (client broadcast to locate
#              available servers)
#
# Argument(s):
#   portList    list of ports to tx dhcp discover frames to
#
########################################################################################
proc send_DHCP_discover {portList} \
{
    return [sendDhcpPacket $portList dhcpDiscover]
}


########################################################################################
# Procedure: get_DHCP_offer
#
# Description: This command gets a DHCP offer frame sent from the DUT
#
# Argument(s):
#   PortList    list of ports to tx dhcp discover frames to, removes ports from the
#               portList if they received an offer.
#
########################################################################################
proc get_DHCP_offer {PortList} \
{
	upvar $PortList portList

    global dhcpOffer

	set retCode $::TCL_OK

	set wait    [learn cget -dhcpWaitTime]

    foreach portMap [lnumsort $portList] {
		scan $portMap "%d %d %d" chassis lm port

        if  {[get_DHCP_packet $chassis $lm $port dhcpOffer $wait] == $dhcpOffer} {
            if [ip get $chassis $lm $port] {
				errorMsg "Error getting ip on port $chassis $lm $port"
				continue
            }
            ip config -sourceIpAddr     [dhcp cget -yourIpAddr]

			set msg	"DHCP Gateway"
			if {![dhcp getOption dhcpGateways]} {
			    if {[dhcp cget -optionDataLength] != 4} {
				    errorMsg "Invalid IP address in $msg option"
				    continue
			    }

                ip config -destDutIpAddr  [dhcp cget -optionData]
			}

			set msg "DHCP Server Identifer"
			if {![dhcp getOption dhcpSvrIdentifier]} {
			    if {[dhcp cget -optionDataLength] != 4} {
				    errorMsg "Invalid IP address in $msg option"
				    continue
			    }

                dhcp config -serverIpAddr   [dhcp cget -optionData]
                if [dhcp set $chassis $lm $port] {
                    errorMsg "Error setting dhcp on port $chassis $lm $port"
		            continue
	            }
            }

            ip config -ipProtocol       udp
            if [ip set $chassis $lm $port] {
                errorMsg "Error setting ip on port $chassis $lm $port"
                continue
	        }

            set indx [lsearch $portList [list $chassis $lm $port]]
            if {$indx != -1} {
                set portList [lreplace $portList $indx $indx]
            }
            logMsg "Got DHCP OFFER on $chassis,$lm,$port, offered IP: [dhcp cget -yourIpAddr]"
        }
    }
    logMsg ""

    if {[llength $portList] > 0} {
        set retCode $::TCL_ERROR
    }

	return $retCode
}


########################################################################################
# Procedure: send_DHCP_request
#
# Description: This command sends a DHCP request frame to the DUT
#
# Argument(s):
#   portList    list of ports to tx dhcp request frames to
#
########################################################################################
proc send_DHCP_request {portList} \
{
    return [sendDhcpPacket $portList dhcpRequest]
}


########################################################################################
# Procedure: get_DHCP_ack
#
# Description: This command gets a DHCP ack frame sent from the DUT
#
# Argument(s):
#   portList    list of ports to tx dhcp request frames to
#
########################################################################################
proc get_DHCP_ack {portList command} \
{
    global dhcpAck dhcpNak
	variable dhcpClient::state

    upvar $command Command

	set retCode 0

    ipAddressSetDefault

    foreach portMap [lnumsort $portList] {
		scan $portMap "%d %d %d" chassis lm port

        #   Get the dhcp packet.
        set messageType [get_DHCP_packet $chassis $lm $port [list dhcpAck dhcpNak]]
        if  {$messageType != $dhcpAck && \
             $messageType != $dhcpNak} {
            set retCode 1
            continue
        }


        # Reset the timers.
        dhcpStopTimer timer1
        dhcpStopTimer timer2
        dhcpStopTimer leaseExpire

        #   Handle DHCP ACK.
        if {$messageType == $dhcpAck} {
            
            set Command $dhcpAck

            #   Collect & validate the dhcp server id.
            if  [dhcp getOption dhcpSvrIdentifier] {
                errorMsg "DHCP Server Identifier option not found in dhcpAck frame"
                set retCode 1
                continue
            }
            set dhcpSvrIdentifier [dhcp cget -optionData]
            
            if {[dhcp cget -optionDataLength] != 4} {
                errorMsg "Invalid IP address in DHCP Server ID option"
                set retCode 1
                continue
            }
            
            
            #   Collect and validate the lease duration.
            if  [dhcp getOption dhcpIPAddrLeaseTime] {
                errorMsg "DHCP IP Lease Duration option not found in dhcpAck frame"
                set retCode 1
                continue
            }
            set dhcpIPAddrLeaseTime [dhcp cget -optionData]

            set dhcpRenewalTimeValue 0
            if {![dhcp getOption dhcpRenewalTimeValue]} {
                set dhcpRenewalTimeValue [dhcp cget -optionData]
            }
            set dhcpRebindingTimeValue 0
            if {![dhcp getOption dhcpRebindingTimeValue]} {
                set dhcpRebindingTimeValue [dhcp cget -optionData]
            }

            
            # Set IP address into ip configuration.
            if [ip get $chassis $lm $port] {
		    	errorMsg "Error getting ip on port $chassis $lm $port"
		    	set retCode 1
		    	continue
            }
            ip config -sourceIpAddr     [dhcp cget -yourIpAddr]
            
                
		    set msg	"DHCP Gateway"
		    if {![dhcp getOption dhcpGateways]} {
		    	if {[dhcp cget -optionDataLength] != 4} {
		    		errorMsg "Invalid IP address in $msg option"
		    		set retCode 1
		    		continue
		    	}
            
                ip config -destDutIpAddr  [dhcp cget -optionData]
		    }
            
		    set msg "DHCP Server Identifer"
		    if  {![dhcp getOption dhcpSvrIdentifier]} {
		    	if {[dhcp cget -optionDataLength] != 4} {
		    		errorMsg "Invalid IP address in $msg option"
		    		set retCode 1
		    		continue
		    	}
                set dhcpSvrIdentifier [dhcp cget -optionData]
                dhcp config -serverIpAddr  $dhcpSvrIdentifier
                if [dhcp set $chassis $lm $port] {
                    errorMsg "Error setting dhcp on port $chassis $lm $port"
		            set retCode 1
		            continue
	            }
            }
            
            ip config -ipProtocol       udp
            if [ip set $chassis $lm $port] {
                errorMsg "Error setting ip on port $chassis $lm $port"
		        set retCode 1
		        continue
	        }
            logMsg "Got DHCP ACK on $chassis,$lm,$port, allocated IP: [ip cget -sourceIpAddr] \
                    from server $dhcpSvrIdentifier"
            
            # add the new ip address to the ipAddressTable
            ipAddressSetDefault
            if [updateIpAddressTable $chassis $lm $port] {
                set retCode 1
                continue
            }

# TBD.
#           interfaceTable::setDefault
#  	        set protocolName    [getProtocolName [protocol cget -name]]
#           switch $protocolName {
#               ip {
#                   set protocolList $::ipV4
#                   if {[interfaceTable::configurePort $chassis $lm $port $protocolList]} {
#                       set retCode $::TCL_ERROR
#                       continue
#                   }
#               }
#               ipV6 {
#                   set protocolList $::ipV6                
#                   if {[interfaceTable::configurePort $chassis $lm $port $protocolList]} {
#                       set retCode $::TCL_ERROR
#                       continue
#                   }
#               }
#            }
#            
            #   
            #   This could be a renewal of this IP address, if so, it will
            #       already have a lease record with timers running.  Stop any
            #       associated timers.
            #
            
               
            #   Create/Update dhcpLeaseRecord and start lease timers.
            dhcpSetIP       $chassis $lm $port [dhcp cget -yourIpAddr]
            dhcpSetServer   $chassis $lm $port $dhcpSvrIdentifier
            dhcpSetLease    $chassis $lm $port $dhcpIPAddrLeaseTime
            dhcpSetState    $chassis $lm $port $dhcpClient::state(bound)

        }

        # Handle dhcpNAK.
        if {$messageType == $dhcpNak} {
            set dhcpError ""
            if ![dhcp getOption dhcpMessage] {
                set dhcpError [dhcp cget -optionData]
            }
            logMsg "Got DHCP NAK on $chassis,$lm,$port, allocated. $dhcpError"

            dhcpStopPort $chassis $lm $port
            set Command $dhcpNak
        }
    }

    if {$messageType == $dhcpAck} {
        dhcpStartTimers \
            $dhcpIPAddrLeaseTime $dhcpRenewalTimeValue $dhcpRebindingTimeValue 
    }
        

    logMsg ""

	return $retCode
}


########################################################################################
# Procedure: send_DHCP_release
#
# Description: Given a portMap, sends a dhcpRelease to the DUT.
#
# Argument(s):
#   chassis
#   lm
#   port
#
# Output:       retCode     : 0 if okay, else
#                             1 if failure
#
########################################################################################
proc send_DHCP_release {portList} \
{
    set retCode     [sendDhcpPacket $portList dhcpRelease]

    return $retCode
}



########################################################################################
############                    DHCP Utility Procedures                      ###########
########################################################################################


########################################################################################
# Procedure: setupUDPbootp
#
# Description: This procedure sets up the UDP bootp ports
#
# Argument(s):
#	chassis
#   lm
#   port
#
########################################################################################
proc setupUDPbootp {chassis lm port} \
{
    set retCode 0

    udp setDefault
    udp config -sourcePort  bootpClientPort
    udp config -destPort    bootpServerPort
    if [udp set $chassis $lm $port] {
        errorMsg "Error setting udp on port $chassis $lm $port"
	    set retCode 1
    }

    return $retCode
}


########################################################################################
# Procedure: setupDhcpBroadcastIP
#
# Description: This procedure sets up broadcast IP addr for destination & null IP for 
#              source (don't know what our IP address is at this point).
#
# Argument(s):
#	chassis
#   lm
#   port
#   address     : defaults to broadcast,
#
########################################################################################
proc setupDhcpBroadcastIP {chassis lm port} \
{
    global nullIP
    global broadcastIP

    set retCode 0

    #ip setDefault
    if [ip get $chassis $lm $port] {
		errorMsg "Error getting ip on port $chassis $lm $port"
		set retCode 1
    }
    ip config -sourceIpAddr $nullIP
    ip config -destIpAddr   $broadcastIP
    ip config -ipProtocol   udp
    ip config -ttl          128
    ip config -identifier   512
    if [ip set $chassis $lm $port] {
        errorMsg "Error setting ip on port $chassis $lm $port"
		set retCode 1
	}

    return $retCode
}

########################################################################################
# Procedure: setupDhcpUnicastIP
#
# Description: This procedure sets up a unicast IP addr for destination
#
# Argument(s):
#	chassis
#   lm
#   port
#   sourceIpAddr:   source Ip Address
#   destIpAddr:     destination Ip Address
#
########################################################################################
proc setupDhcpUnicastIP {chassis lm port sourceIpAddr destIpAddr} \
{

    set retCode 0

    #ip setDefault
    if [ip get $chassis $lm $port] {
		errorMsg "Error getting ip on port $chassis $lm $port"
		set retCode 1
    }
    ip config -sourceIpAddr $sourceIpAddr
    ip config -destIpAddr   $destIpAddr
    ip config -ipProtocol   udp
    ip config -ttl          128
    ip config -identifier   512
    if [ip set $chassis $lm $port] {
        errorMsg "Error setting ip on port $chassis $lm $port"
		set retCode 1
	}

    return $retCode
}




########################################################################################
# Procedure: setupDefaultDhcpParameters
#
# Description: This procedure sets up the default DHCP parameters for discover & request
#
# Argument(s):
#	chassis
#   lm
#   port
#   transactionID   - transaction ID
#   txSA            - mac address of the chassis lm port
#
########################################################################################
proc setupDefaultDhcpParameters {chassis lm port transactionID txSA {clientIpAddr "0.0.0.0"}} \
{
    global nullIP

    dhcp setDefault
    dhcp config -opCode           $::dhcpBootRequest
    dhcp config -clientIpAddr     $clientIpAddr
    dhcp config -yourIpAddr       $nullIP
    dhcp config -serverIpAddr     $nullIP
    dhcp config -relayAgentIpAddr $nullIP
    dhcp config -clientHwAddr     $txSA
    dhcp config -transactionID    $transactionID
    dhcp config -seconds          [dhcpClient::getStartTime]
}    


########################################################################################
# Procedure: setDhcpOptions
#
# Description: This procedure sets the options specified in the optionList
#
# Argument(s):
#   OptionList  - list of options & data to set using dhcp setOption; data must be in
#                 in the appropriate byte format before passing through to this proc
#
########################################################################################
proc setDhcpOptions {OptionList} \
{
	upvar $OptionList optionList
    set retCode 0

    # make sure there's an 'end' at the back end of each set of options
    lappend optionList dhcpEnd dhcpEnd

    foreach {option data} $optionList {
        dhcp config -optionData       $data
        if [dhcp setOption $option] {
            errorMsg "Error setting DHCP option <$option>"
            set retCode 1
            continue
        }
    }

    return $retCode
}


########################################################################################
# Procedure: sendDhcpPacket
#
# Description: This procedure sends a Dhcp packet to each Tx port in the map
#
# Argument(s):  portList:   list of ports to send DHCP packets: {{c l p} {c l p}}
#               opcode:     operation to perform:   dhcpDiscover
#                                                   dhcpRequest
#                                                   dhcpRelease
#
# Returns:      0 if successful, else
#               1 if failure
#
########################################################################################
proc sendDhcpPacket {portList opcode} \
{
    set retCode     0

    # save original protocol config
    set tempApp     [protocol cget -appName]
    set tempName    [protocol cget -name]
    protocol config -appName    Dhcp
    protocol config -name       ip

    foreach portMap [lnumsort $portList] {
		scan $portMap "%d %d %d" c l p

        # Temporary workaround (DHCP was consumed by Protocol Server)
        if [protocolServer get $c $l $p] {
            errorMsg "Error getting protocolServer on port [getPortId $c $l $p]"
            set retCode 1
            continue
        }

        set enableArp   [protocolServer cget -enableArpResponse]
        if {$enableArp} {
            protocolServer config -enableArpResponse    false
            if [protocolServer set $c $l $p] {
                errorMsg "Error setting protocolServer on port [getPortId $c $l $p]"
                set retCode 1
            }
        }

        if [buildDhcpPacket $c $l $p $opcode] {
            errorMsg "Error building dhcp packet for port [getPortId $c $l $p]"
            set retCode 1
            continue
        }
    }

    # now put back original protocol config
    protocol config -appName    $tempApp
    protocol config -name       $tempName

    # if this port was *ever* in packetGroup mode, change it or we won't be able to capture... 
    if [setCaptureMode portList write] {
		return -code error
    }

    if {![writeConfigToHardware portList] && ![zeroStats portList] && ![startCapture portList]} {
        logMsg ""
        foreach portMap [lnumsort $portList] {
		    scan $portMap "%d %d %d" c l p

	        logMsg "----->Sending $opcode frame from [getPortId $c $l $p] to DHCP server."

	        if [startPortTx $c $l $p] {
		        errorMsg "Error starting Tx on port [getPortId $c $l $p]"
		        set retCode 1
	        }
        }
        logMsg ""
        if {[learn cget -waitTime] > 1000} {
            logMsg "Waiting on DHCP response for [expr [learn cget -waitTime]/1000] second(s)..."
        }
	    after [learn cget -waitTime]

    } else {
        set retCode 1
    }

    # Temporary workaround (DHCP was consumed by Protocol Server)
    # If arp was enabled in the first place, reenable it here...
    if {$enableArp} {
        foreach portMap [lnumsort $portList] {
		    scan $portMap "%d %d %d" c l p

            if [protocolServer get $c $l $p] {
                errorMsg "Error getting protocolServer on port [getPortId $c $l $p]"
                set retCode 1
                continue
            }

            protocolServer config -enableArpResponse    true
            if [protocolServer set $c $l $p] {
                errorMsg "Error setting protocolServer on port [getPortId $c $l $p]"
                set retCode 1
            }
        }
    }
       
    return $retCode
}


########################################################################################
# Procedure: buildDhcpPacket
#
# Description: This procedure builds a Dhcp packet
#
# Argument(s):
#	chassis
#   lm
#   port
#   opcode      opcode, ie, dhcpDiscover, dhcpRequest, dhcpRelease
#            } else if {$state == $dhcpClient::state(rebind)} {
#            if {$state == $dhcpClient::state(renew)} {
#
########################################################################################
proc buildDhcpPacket {chassis lm port opcode} \
{

    global nullIP broadcastIP 
    variable dhcpClient::state

	set retCode 0

    set clientIpAddr $nullIP
    set txAddress    $nullIP

    set ethernetType [protocol cget -ethernetType]
    protocol config -ethernetType $::noType

    set destMacAddress $::kBroadcastMacAddress

    udf setDefault
    dhcp setDefault
    filter setDefault
    stream setDefault
    filterPallette setDefault

    dhcpSetStreamRegion 0

    # delete any existing streams first
    if [port reset $chassis $lm $port] {
        errorMsg "Error deleting streams on port $chassis $lm $port"
        set retCode 1
    }

	# set the stream parameters.
	set preambleSize		8
	set framesize			[learn cget -framesize]

	set streamName          $opcode
    append streamName "Stream"

    disableUdfs {1 2 3 4}

    stream config -region    [dhcpGetStreamRegion]
    stream config -rateMode  usePercentRate
    stream config -name		 $streamName
	stream config -framesize $framesize
	stream config -dma		 stopStream
	stream config -numFrames [learn cget -numDHCPframes]
	stream config -fcs		 good
    stream config -enableIbg false
    stream config -enableIsg false
    stream config -gapUnit   gapNanoSeconds

	filter config -captureFilterError   errGoodFrame
	filter config -captureTriggerError  errGoodFrame

	if [port get $chassis $lm $port] {
		errorMsg "port $chassis $lm $port has not been configured yet"
		set retCode 1
	}

	set txSA	        [port cget -MacAddress]
    set transactionID   [dhcpClient::getTransactionID $port]

    set optionList      [list dhcpHostName [format "IxiaHost_%u.%u.%u" $chassis $lm $port]]


    switch $opcode {
        dhcpDiscover {
#            set txAddress       $broadcastIP
            lappend optionList  dhcpMessageType dhcpDiscover \
                                dhcpClientId $txSA \
                                dhcpParamRequestList [dhcpClient::getParameterRequestList]


			# Capture Boot Replies with the dhcpMagicCookie
#			filter config -captureTriggerPattern pattern1
#			filter config -captureFilterPattern  pattern1
#			filterPallette config -pattern1 [dhcpClient::getMagicCookie]
#			filterPallette config -patternOffset1 {278}

			filter config -captureTriggerPattern pattern1AndPattern2
			filter config -captureFilterPattern  pattern1AndPattern2
			filterPallette config -pattern1 [format "%02x" $::dhcpBootReply]
			filterPallette config -pattern2 [dhcpClient::getMagicCookie]
			filterPallette config -patternOffset1 {42}
			filterPallette config -patternOffset2 {278}

			if [filterPallette set $chassis $lm $port] {
				errorMsg "Error setting filter pallette on $chassis,$lm,$port"
			}
        }

        dhcpRequest {
            if [ip get $chassis $lm $port] {
		        errorMsg "port $chassis $lm $port has not been configured for IP yet"
		        set retCode 1
	        }
            set txIP    [ip cget -sourceIpAddr]

            # we need to use the same transaction ID for the complete dhcp transaction... if we don't have a dhcp object 
            # for this port yet, setup a transaction ID for it using a random number, otherwise use the existing transactionID
            # in the dhcp object.
            if [dhcp get $chassis $lm $port] {
		        errorMsg "Error getting dhcp configuration for port $chassis $lm $port"
		        set retCode 1
            } else {
                set transactionID   [dhcp cget -transactionID]
            }

            #
            #   Build option list based upon state (these are 
            #       common to all dhcpRequest messages).
            #
            lappend optionList  dhcpMessageType dhcpRequest \
                                dhcpParamRequestList [dhcpClient::getParameterRequestList]

                                  
            set portState [dhcpGetState $chassis $lm $port]
            if ![dhcpClient::ValidState $portState] {
                set portState 0
            }

            switch [dhcpClient::GetStateName $portState] {

                renew {

                    #         
                    #   For state Renew, the following are required:
                    #       - Server Id is not set
                    #       - Requested IP is not set
                    #       - ciaddr is set to Client's IP address
                    #       - giaddr (dhcpRouter) is not set
                    #         
                    set clientIpAddr [dhcpGetIP $chassis $lm $port]
                    set txAddress  [dhcp cget -serverIpAddr]
                    set destMacAddress [port cget -DestMacAddress]

                    lappend optionList dhcpClientId $txSA 
                }
                
                
                rebind {
                    #         
                    #   For state Rebind, the following are required:
                    #       - Server Id is not set
                    #       - Requested IP is not set
                    #       - ciaddr is set to Client's IP address
                    #         
                    set clientIpAddr    [dhcpGetIP $chassis $lm $port]
                    lappend optionList  dhcpClientId $txSA \
                                        dhcpRouter [ip cget -destDutIpAddr] \
                                        dhcpSvrIdentifier $nullIP \
                                        dhcpRequestedIPAddr $nullIP 
                
                }
                
                default {
                    #         
                    #   For states Select, the following are required:
                    #       - Server Id is set to address supplied in offer
                    #       - Requested IP is set to address supplied in offer
                    #       - ciaddr is not set
                    #       - giaddr is set to relay agent
                    #         
                    lappend optionList  dhcpClientId $txSA \
                                        dhcpRequestedIPAddr $txIP \
                                        dhcpRouter [ip cget -destDutIpAddr] \
                                        dhcpSvrIdentifier [dhcp cget -serverIpAddr]
                }
            }
			# Capture Boot Replies
			filter config -captureTriggerPattern pattern1
			filter config -captureFilterPattern  pattern1
			filterPallette config -pattern1 [format "%02x" $::dhcpBootReply]
			filterPallette config -patternOffset1 {42}

			if [filterPallette set $chassis $lm $port] {
				errorMsg "Error setting filter pallette on $chassis,$lm,$port"
			}

        }
        dhcpRelease {

            # Collect the IP configuration on this port.
            if [ip get $chassis $lm $port] {
		        errorMsg "port $chassis $lm $port has not been configured for IP yet"
		        set retCode 1
	        }
            set txIP    [ip cget -sourceIpAddr]
            # Collect the current DHCP configuration on this port.
            if [dhcp get $chassis $lm $port] {
		        errorMsg "Error getting dhcp configuration for port $chassis $lm $port"
		        set retCode 1
            }


            # Build DHCP packet.
            set clientIpAddr    [dhcpGetIP $chassis $lm $port]
            set serverIpAddr    [dhcp cget -serverIpAddr]
            set txAddress       $serverIpAddr
            set destMacAddress  [port cget -DestMacAddress]



            lappend optionList  dhcpMessageType dhcpRelease \
                                dhcpClientId $txSA \
                                dhcpSvrIdentifier $serverIpAddr
        }                                 
        default {
            errorMsg "Unsupported packet type"
            return 1
        }
    }

    if {$txAddress != $nullIP} {
        setupDhcpUnicastIP $chassis $lm $port $txIP $txAddress
    } else {
        setupDhcpBroadcastIP $chassis $lm $port
    }

    setupUDPbootp $chassis $lm $port
    setupDefaultDhcpParameters $chassis $lm $port $transactionID $txSA $clientIpAddr

    setDhcpOptions optionList

    if [dhcp set $chassis $lm $port] {
        errorMsg "Error setting DHCP on port $chassis $lm $port"
        set retCode 1
    }

	set speed	[port cget -speed]
    
	stream config -da		$destMacAddress
	stream config -numDA	1

  	stream config -sa		$txSA
	stream config -numSA	1

    stream config -frameSizeType    sizeAuto
	if [stream set $chassis $lm $port 1] {
		errorMsg "Error setting stream 1, port $chassis,$lm,$port for $opcode frames"
		set retCode 1
	}

    # since we set this for autoframe size calc, get the calculated framesize to use
    # in calculating the IFG.
    set framesize [stream cget -framesize]
    set learnPercentRate             [expr double([learn cget -rate])/[calculateMaxRate $chassis $lm $port $framesize]*100.]
    stream config -percentPacketRate $learnPercentRate

	if [stream set $chassis $lm $port 1] {
		errorMsg "Error setting stream 1, port $chassis,$lm,$port for $opcode frames"
		set retCode 1
	}

	# set the filter parameters for receiving the DHCP response
    filter config -captureTriggerDA         any
    filter config -captureFilterDA          any
	filter config -captureFilterEnable		true
	filter config -captureTriggerEnable		true
	if [filter set $chassis $lm $port] {
		errorMsg "Error setting filters on $chassis,$lm,$port"
		set retCode 1
	}

    protocol config -ethernetType $ethernetType

    return $retCode
}



########################################################################################
# Procedure: get_DHCP_packet
#
# Description: This command gets a DHCP packet sent from the DUT & fills the dhcp command
#              memory using dhcp decode $packet
#
# Argument(s):
#	chassis
#   lm
#   port
#   messageType -   name of DHCP message type to search.  Note that this can be a list
#                   of message types, ie [list dhcpAck dhcpNak]
#
#   Output:         First message type (of messageType list) found in buffer:
#                       0 if no match, else
#                       dhcpMessageType (as defined in Dhcp.hpp)
#
########################################################################################
proc get_DHCP_packet {chassis lm port messageType {wait 0}} \
{
    set retCode 0

	# Wait till data in capture buffer, or timer expires.
	set expire [expr [clock seconds] + $wait]
	while {$expire > [clock seconds]} {
		if {![stat get statCaptureFilter $chassis $lm $port]} {
		    if {[stat cget -counterVal] > 0} {
		       break
		    }
	    }
	}

    # make sure there's something there to look at first!
    if {[captureBuffer get $chassis $lm $port 1 1000]} {
		errorMsg "Error getting capture data on $chassis,$lm,$port"
		return 0
	}

    # You have to have the transactionID before we can process any further...
    if [dhcp get $chassis $lm $port] {
        errorMsg "Error getting DHCP on port $chassis $lm $port"
        return 0
    }
    set transactionID   [dhcp cget -transactionID]

	set found 0
    set nPackets [captureBuffer cget -numFrames]
	for {set nFrame 1} {$nFrame <= $nPackets} {incr nFrame} {
		if [captureBuffer getframe $nFrame] {
			errorMsg "Error getting frame $nFrame from capture buffer for $chassis,$lm,$port"
			continue
		}
		set capframe	[captureBuffer cget -frame]
        if [dhcp decode $capframe $chassis $lm $port] {
            continue
        }

		# What is the message type?
        if {![dhcp getOption dhcpMessageType]} {
            set dhcpMessageType [dhcp cget -optionData]
        }

        #   The transaction ID must match.
        if {[dhcp cget -transactionID] == $transactionID} {

            # The message type must match one in the list of message types.
            foreach item $messageType {
                global $item
                upvar $item MessageType
                if {$dhcpMessageType == $MessageType} {
			        set found 1
                    set retCode $MessageType
			        break
                }
            }
        }
        # Break out of packet search loop.
        if $found {
            break
        }

	}

	if {$found == 0} {
		logMsg "No $messageType frames received on $chassis $lm $port"
	} else {
        set destinationAddr [lrange $capframe 6 11]        
		if [port get $chassis $lm $port] {
			errorMsg "Error getting port $chassis,$lm,$port"
			set retCode 0
		}
		port config -DestMacAddress	$destinationAddr
		if [port set $chassis $lm $port] {
			errorMsg "Error setting port on $chassis,$lm,$port"
			set retCode 0
		}
    }

    return $retCode
}



########################################################################################
# Procedure:    dhcpInitialize
#
# Description:  Setup dhcpClient initial settings.
#
# Input:        eventList: list of potential events
#               stateList: list of all known states
#               actionList: list of list of actions per state per event (can be an
#                   empty list if state machine is to be disabled.
#
# Output:       None
#
########################################################################################
proc dhcpClient::Initialize {   {stateList dhcpClient::stateList} \
                                {eventList dhcpClient::eventList} \
                                {actionList dhcpClient::actionList}} \
{
	debug
    variable dhcpLeaseRecord

    if [info exists dhcpLeaseRecord] {
        unset dhcpLeaseRecord
    }

    # Initialize state table.
    InitStateTable $stateList $eventList $actionList

    # Set default stream region.
    SetStreamRegion 0

    # Create the default parameter request list used by dhcpDiscover & dhcpRequest.
    clearParameterRequestList
    setParameterRequestList dhcpSubnetMask
    setParameterRequestList dhcpDomainName
    setParameterRequestList dhcpGateways
    setParameterRequestList dhcpNetBIOSNameSvr
    setParameterRequestList dhcpNetBIOSNodeType
    setParameterRequestList dhcpNetBIOSScope
    setParameterRequestList dhcpDomainNameServer

    # Record dhcp start-time.
    setStartTime [clock seconds]

}

########################################################################################
# Procedure:    dhcpStop
#
# Description:  Cancel any outstanding timers, remove dhcpLeaseRecord, release all
#               IP addresses that are currently leased.
#
# Input:        None
#
# Output:       None
#
########################################################################################
proc dhcpClient::Stop {} \
{
	debug 
    variable dhcpLeaseRecord

    foreach port [GetPortList] {
        scan $port "%d %d %d" c l p
        StopPort $c $l $p true
    }
    SetPortList {}
    catch {unset dhcpLeaseRecord}

    StopTimer timer1
    StopTimer timer2
    StopTimer leaseExpire
}

########################################################################################
# Procedure:    dhcpStopPort
#
# Description:  Release IP address, unset dhcpLeaseRecord for a single port.
#
# Input:        chassis
#               card
#               port
#               release:    true if IP address should be released, default is false
#
# Output:       None
#
########################################################################################
proc dhcpClient::StopPort {chassis card port {release false}} \
{
	debug
    variable dhcpLeaseRecord

    if {$release == "true"} {
        set portList [list [list $chassis $card $port]]
        send_DHCP_release $portList
    }

    catch {unset dhcpLeaseRecord($chassis,$card,$port,ip)}
    catch {unset dhcpLeaseRecord($chassis,$card,$port,server)}
    catch {unset dhcpLeaseRecord($chassis,$card,$port,lease)}
    catch {unset dhcpLeaseRecord($chassis,$card,$port,state)}

}

########################################################################################
# Procedure:    dhcpSetState
#
# Description:  Store the current state of dhcp process.
#
# Input:        chassis-card-port
#               state: discover, offer, request, ack, bound, renew, rebind, idle
#
# Output:       0, success, else
#               1, failure (invalid state) 
#
########################################################################################
proc dhcpClient::SetState {chassis card port newState} \
{

	debug

    variable dhcpLeaseRecord

    # Valid state?
	if ![ValidState $newState] {
        return 1
    }
            
    set dhcpLeaseRecord($chassis,$card,$port,state) $newState

    return 0
}


########################################################################################
# Procedure:    dhcpGetState
#
# Description:  Get the current state for the given port.
#
# Input:        chassis
#               card:
#               port:
#               lease:  duration of lease
#
# Output:       state (possible states are: idle, discover, offer, request, ack,
#                   done, renew, rebind)
#
########################################################################################
proc dhcpClient::GetState {chassis card port} \
{
    variable dhcpLeaseRecord

    if [info exists dhcpLeaseRecord($chassis,$card,$port,state)] {
        return $dhcpLeaseRecord($chassis,$card,$port,state)
    }

}

########################################################################################
# Procedure:    dhcpSetLease
#
# Description:  Set the DHCP lease.
#
# Input:        chassis
#               card:
#               port:
#               lease:  duration of lease
#
# Output:       None
#
########################################################################################
proc dhcpClient::SetLease {chassis card port lease} \
{
	debug
    variable dhcpLeaseRecord

    #   Store the lease
    set dhcpLeaseRecord($chassis,$card,$port,lease) $lease
}

########################################################################################
# Procedure:    dhcpGetLease
#
# Description:  Return the value of the lease for a given port
#
# Input:        chassis
#               card:
#               port:
#
# Output:       lease
#
########################################################################################
proc dhcpClient::GetLease {chassis card port} \
{
	debug
    variable dhcpLeaseRecord

    if [info exists dhcpLeaseRecord($chassis,$card,$port,lease)] {
        return $dhcpLeaseRecord($chassis,$card,$port,lease)
    }

}


########################################################################################
# Procedure:    dhcpStartTimers
#
# Description:  Start DHCP timers.
#
# Input:        lease:  duration of lease
#
# Output:       0 if successful, else
#               1
#
########################################################################################
proc dhcpClient::StartTimers {lease {timer1 0 } {timer2 0}} \
{
	debug
    variable dhcpLeaseRecord

    set returnCode 0

    # If timers already running, don't restart.        
    if [info exist dhcpLeaseRecord(timer1)] {
        if {$dhcpLeaseRecord(timer1) != ""} {
            return 1
        }
    }

    # Start timer 1
    if [StartTimer timer1 $lease $timer1] {
        set returnCode 1
    }

    # Start timer 2
    if [StartTimer timer2 $lease $timer2] {
        set returnCode 1
    }

    # Start lease timer
    if [StartTimer leaseExpire $lease] {
        set returnCode 1
    }


    return $returnCode  
}


########################################################################################
# Procedure:    dhcpStopTimers
#
# Description:  Stop DHCP timers.
#
# Input:        lease:  duration of lease
#
# Output:       0 if successful, else
#               1
#
########################################################################################
proc dhcpClient::StopTimers {} \
{
	debug
    set returnCode 0

    # Stop timer 1
    if [StopTimer timer1] {
        set returnCode 1
    }

    # Stop timer 2
    if [StopTimer timer2] {
        set returnCode 1
    }

    # Stop lease timer
    if [StopTimer leaseExpire] {
        set returnCode 1
    }

    return $returnCode
}


########################################################################################
# Procedure:    dhcpStartTimer
#
# Description:  Initiate DHCP timers based upon the value supplied by the server.
#                   TIMER 1 will expire at (lease * .50)
#                   TIMER 2 will expire at (lease * .875)
#
# Input:        timer:  timer1, timer2 or leaseExpire
#
# Output:       0 if successful, else
#               1
#
########################################################################################
proc dhcpClient::StartTimer {timer lease {value 0}} \
{
	debug
    variable dhcpLeaseRecord
    variable event

    # Initiate timers
    switch $timer {

        timer1 {
            if $value {
                set timerValue $value
            } else {
                set timerValue [expr round([mpexpr $lease * .50])]
            }
        }

        timer2 {
            if $value {
                set timerValue $value
            } else {
                set timerValue [expr round([mpexpr $lease * .875])]
            }
        }

        leaseExpire {
            set timerValue $lease
        }

        default {
            return 1
        }

    }

    # Start the timer, set the timer Id into the lease record.
    set portList [lindex [GetPortList] 0]
    scan $portList "%d %d %d" c l p
    set dhcpLeaseRecord($timer) \
        [after [expr 1000 * $timerValue] \
        [namespace current]::StateLookup $c $l $p $event(timeOut)]


    return 0
        
}

########################################################################################
# Procedure:    dhcpStopTimer
#
# Description:  Cancels a given DHCP timer for a given port.
#
# Input:        timer:  timer1, timer2 or leaseExpire
#
#
# Output:       0 if successful, else
#               1
#
########################################################################################
proc dhcpClient::StopTimer {timer} \
{
	debug
    variable dhcpLeaseRecord

    switch $timer {

        timer1 -
        timer2 -
        leaseExpire {
            if {[dhcpGetTimer $timer] != ""} {
                after cancel [dhcpGetTimer $timer]
                set dhcpLeaseRecord($timer) ""
            }
        }

        default {
            return 1
        }
    }

    return 0
        
}


########################################################################################
# Procedure:    dhcpGetTimer
#
# Description:  Return the value of the timer id for a given port
#
# Input:        timer:  timer1, timer2 or leaseExpire
#
# Output:       timer Id 
#
########################################################################################
proc dhcpClient::GetTimer {timer} \
{
	debug
    variable dhcpLeaseRecord
    set returnValue 0

    switch $timer {

        timer1 -
        timer2 -
        leaseExpire {
            if [info exists dhcpLeaseRecord($timer)] {
                set returnValue $dhcpLeaseRecord($timer)
            }
        }

        default {
            set returnValue 0
        }
    }

    return $returnValue

}


########################################################################################
# Procedure:    dhcpSetIP
#
# Description:  Set the DHCP IP address as offered by the dhcp server for a given
#                   port.
#
# Input:        chassis
#               card:
#               port:
#               ip:     IP address
#
# Output:       None
#
########################################################################################
proc dhcpClient::SetIP {chassis card port ip} \
{
	debug
    variable dhcpLeaseRecord

    #   Store the IP address
    set dhcpLeaseRecord($chassis,$card,$port,ip) $ip
}

########################################################################################
# Procedure:    dhcpGetIP
#
# Description:  Return the leased IP address for a given port
#
# Input:        chassis
#               card:
#               port:
#
# Output:       lease
#
########################################################################################
proc dhcpClient::GetIP {chassis card port} \
{
	debug
    variable dhcpLeaseRecord

    if [info exists dhcpLeaseRecord($chassis,$card,$port,ip)] {
        return $dhcpLeaseRecord($chassis,$card,$port,ip)
    }

}


########################################################################################
# Procedure:    dhcpSetServer
#
# Description:  Set the DHCP Server address for a given port.
#
# Input:        chassis
#               card:
#               port:
#               server: server address (that which offered the lease)
#
# Output:       None
#
########################################################################################
proc dhcpClient::SetServer {chassis card port server} \
{
	debug
    variable dhcpLeaseRecord

    #   Store the server address
    set dhcpLeaseRecord($chassis,$card,$port,server) $server
}

########################################################################################
# Procedure:    dhcpGetServer
#
# Description:  Return the address of the dhcp server which leased this port an
#                   IP address.
#
# Input:        chassis
#               card:
#               port:
#
# Output:       server address
#
########################################################################################
proc dhcpClient::GetServer {chassis card port} \
{
	debug
    variable dhcpLeaseRecord

    if [info exists dhcpLeaseRecord($chassis,$card,$port,server)] {
        return $dhcpLeaseRecord($chassis,$card,$port,server)
    }

}

########################################################################################
# Procedure:    dhcpSetStreamRegion
#
# Description:  Set the region that DHCP streams are build within.
#
# Input:        Region: 0 is default, else 1-7
#
# Output:       None
#
########################################################################################
proc dhcpClient::SetStreamRegion {{region 0}} \
{
	debug

    variable streamRegion
    variable streamRegionMax
    variable streamRegionMin

    if {$region <= $streamRegionMax && \
        $region >= $streamRegionMin} {
        set streamRegion $region
    }

}

########################################################################################
# Procedure:    dhcpGetStreamRegion
#
# Description:  Returns the region that DHCP streams are build within.
#
# Input:        None
#
# Output:       region #
#
########################################################################################
proc dhcpClient::GetStreamRegion {} \
{
	debug
    variable streamRegion

    if [info exists streamRegion] {
        return $streamRegion
    }

}

########################################################################################
# Procedure:    dhcpSetPortList
#
# Description:  Store the list of ports working with DHCP addresses
#
# Input:        ports:  {{c l p} {c l p} ...}
#
# Output:       None
#
########################################################################################
proc dhcpClient::SetPortList {ports} \
{
	debug
    variable portList
    set portList $ports
}

########################################################################################
# Procedure:    dhcpGetPortList
#
# Description:  Returns the list of ports using DHCP addresses.
#
# Input:        None
#
# Output:       region #
#
########################################################################################
proc dhcpClient::GetPortList {} \
{
    variable portList

    if [info exists portList] {
        return $portList
    }

}


########################################################################################
# Procedure:    dhcpInitStateTable
#
# Description:  Set the DHCP state table to it's initial value (all events in all
#                   state are set to the NULL routine).
#
# Input:        eventList: list of potential events
#               stateList: list of all known states
#               actionList: list of list of actions per state per event (can be an
#                   empty list if state machine is to be disabled.
#
# Output:       None
#
########################################################################################
proc dhcpClient::InitStateTable { stateList eventList {actionList {}} } \
{
	debug
    variable stateTable

    upvar $stateList StateList
    upvar $eventList EventList
    if [catch "upvar $actionList ActionList"] {
        set ActionList [list]
    }

    # Empty state list? If so, exit.
    if {[llength $StateList] == 0} {
        return
    }

    # Empty event list? If so, exit.
    if {[llength $EventList] == 0} {
        return
    }

    if [info exists stateTable] {
        unset stateTable
    }

    # Empty Action List?  If so, fill stateTable with the NULL routine.
    if {[llength $ActionList] == 0} {
        foreach state $StateList {
            foreach event $EventList {
                set stateTable($state,$event) [namespace current]::ActionNull
            }
        }

    # Otherwise, fill the stateTable w/given list of action routines.
    } else {
        set ActionList [join $ActionList]
        set i 0

        foreach state $StateList {
            foreach event $EventList {
                set stateTable($state,$event) [lindex $ActionList $i]
                incr i
            }
        }
    }
}

########################################################################################
# Procedure:    dhcpClient::StateLookup
#
# Description:  Perform state table lookup, execute action routine.
#
# Input:        event:  event that resulted in this procedure call
#               port:   port that event occurred on
#
# Output:       None
#
########################################################################################
proc dhcpClient::StateLookup {chassis card port event} \
{ 
	debug
    variable stateTable

	if ![ValidEvent $event] {
		return
	}

    set state [GetState $chassis $card $port]
	if [ValidState $state] {
		eval $stateTable($state,$event) [list [list $chassis $card $port]]
	}
}



########################################################################################
#
#   DHCP State Machine - Action Routines
#
#   The following routines perform actions as a result of a background
#       event.  Based on the state and the event, and action is looked-up and
#       executed.
#
########################################################################################

########################################################################################
# Procedure:    dhcpClient::ActionNull
#
# Description:  Place holder for events which don't require handling.
#
# Input:        None
#
# Output:       None
#
########################################################################################
proc dhcpClient::ActionNull {port} \
{ 
	debug
}

########################################################################################
# Procedure:    dhcpClient::ActionRenew
#
# Description:  Perform 'renew' behavior as defined in the DHCP RFC for all
#               ports in the port list.
#                   - Set state = renew
#                   - Request lease extension from the current dhcp server
#
#               The occurance of this action indicates that in a bound state
#               a timeOut occurred indicating that it is time to renew the lease.
#
# Input:        None
#
# Output:       None
#
########################################################################################
proc dhcpClient::ActionRenew {port} \
{ 
	debug
    variable state

    set portList [GetPortList]
    foreach item [lnumsort $portList] {
        scan $item "%d %d %d" c l p
        SetState    $c $l $p $state(renew)
    }

    dhcpStopTimer timer1
    DHCPdiscoverIP portList 2 enable

}

########################################################################################
# Procedure:    dhcpClient::ActionRebind
#
# Description:  Perform 'rebind' behavior as defined in the DHCP RFC.
#                   - Set state = rebind
#                   - Request lease extension from the any dhcp server
#
#               The occurance of this action routine indicates that in state(renew)
#               a timeout occurred indicated that no IP addresses were offered for
#               renewal from the current dhcp server.
#
# Input:        None
#
# Output:       None
#
########################################################################################
proc dhcpClient::ActionRebind {port} \
{ 
	debug $port
    variable state

    set portList [GetPortList]
    foreach item [lnumsort $portList] {
        scan $item "%d %d %d" c l p
        SetState    $c $l $p $state(rebind)
    }

    dhcpStopTimer timer2
    DHCPdiscoverIP portList 2 enable

}

########################################################################################
# Procedure:    dhcpClient::ActionInit
#
# Description:  Perform 'discovery' behavior as defined in the DHCP RFC.
#                   - Set state = idle
#                   - Send discover message
#
#               The occurance of this action routine indicates that in state(rebind)
#               a timeout occurred indicating that the IP lease expired.
#
# Input:        None
#
# Output:       None
#
########################################################################################
proc dhcpClient::ActionInit {port} \
{ 

	debug $port

    #   Release all ports, turn off timers.
    set portList [GetPortList]
    dhcpStop

    #   Restart IP acquisition with Discovery.
    DHCPdiscoverIP portList 0 enable
}


########################################################################################
# Procedure:    dhcpClient::GetStateNames
#
# Description:  Returns a list of textual state names.
#
# Input:        None
#
# Output:       List of state names
#
########################################################################################
proc dhcpClient::GetStateNames {} \
{
	variable state
	return [array names state]
}
													 
########################################################################################
# Procedure:    dhcpClient::GetStateName
#
# Description:  Given a state code, return a textual state name.
#
# Input:        stateCode:	state code (refer to dhcpClient::state)
#
# Output:       state name
#
########################################################################################
proc dhcpClient::GetStateName {stateCode} \
{
	variable state
	set retValue ""

	foreach {name value} [array get state] {
		set stateNames($value) $name
	}

	if [info exists stateNames($stateCode)] {
		set retValue $stateNames($stateCode)
	}

	return $retValue
}

########################################################################################
# Procedure:    dhcpClient::GetStateCodes
#
# Description:  Returns a list of state codes.
#
# Input:        None
#
# Output:       List of state codes
#
########################################################################################
proc dhcpClient::GetStateCodes {} \
{
	variable state

	set states [list]
	foreach {name value} [array get state] {
		lappend states $value
	}

	return $states
}

########################################################################################
# Procedure:    dhcpClient::ValidState
#
# Description:  True/False: Is the given state code a valid member of the list
#					of state codes (dhcpClient::state)
#
# Input:        stateCode:	state code
#
# Output:       1 if valid, else
#				0
#
########################################################################################
proc dhcpClient::ValidState {stateCode} \
{
	if {[lsearch [GetStateCodes] $stateCode] < 0} {
		return 0
	}
	return 1
}


########################################################################################
# Procedure:    dhcpClient::GetEventName
#
# Description:  Given a event code, return a textual event name.
#
# Input:        eventCode:	event code (refer to dhcpClient::event)
#
# Output:       event name
#
########################################################################################
proc dhcpClient::GetEventName {eventCode} \
{
	variable event
	set retValue ""

	foreach {name value} [array get event] {
		set eventNames($value) $name
	}

	if [info exists eventNames($eventCode)] {
		set retValue $eventNames($eventCode)
	}

	return $retValue
}

########################################################################################
# Procedure:    dhcpClient::GetEventCodes
#
# Description:  Returns a list of event codes (dhcpClient::event).
#
# Input:        None
#
# Output:       List of event codes
#
########################################################################################
proc dhcpClient::GetEventCodes {} \
{
	variable event

	set events [list]
	foreach {name value} [array get event] {
		lappend events $value
	}

	return $events
}

########################################################################################
# Procedure:    dhcpClient::ValidEvent
#
# Description:  True/False: Is the given event code a valid member of the list
#					of event codes (dhcpClient::event)
#
# Input:        eventCode:	event code
#
# Output:       1 if valid, else
#				0
#
########################################################################################
proc dhcpClient::ValidEvent {eventCode} \
{
	if {[lsearch [GetEventCodes] $eventCode] < 0} {
		return 0
	}
	return 1
}

########################################################################################
# Procedure:    dhcpClient::getTransactionID
#
# Description:  Derive a unique transaction id, given a port id by adding the 
#               the port # to the current system time in 'clicks'.
#
# Input:        port:   port id
#
# Output:       transaction id
#
########################################################################################
proc dhcpClient::getTransactionID {port} \
{
    return [expr [clock clicks] + $port]
}

########################################################################################
# Procedure:    dhcpClient::clearParameterRequestList
#
# Description:  Empty parameter request list.
#
# Input:        None
#
# Output:       None
#
########################################################################################
proc dhcpClient::clearParameterRequestList {} \
{
    variable paramRequestList
    set paramRequestList [list]
}

########################################################################################
# Procedure:    dhcpClient::getParameterRequestList
#
# Description:  Return the values currently set into the list of requested DHCP 
#                   options.  DHCP options are described in RFC 1533.
#
# Input:        None
#
# Output:       dhcpClient::paramRequestList
#
########################################################################################
proc dhcpClient::getParameterRequestList {} \
{
    variable paramRequestList
    return $paramRequestList
}

########################################################################################
# Procedure:    dhcpClient::setParameterRequestList
#
# Description:  Set the list of requested DHCP options.  DHCP options are described
#                   in RFC 1533, the parameter request list is described in section
#                   9.6 of RFC 1533.
#
# Input:        option: name of dhcp option (refer to Tcl Development Guide - DHCP,
#                       for a list of valid options or RFC 1533).
#
# Output:       0 if okay, else
#               1
#
########################################################################################
proc dhcpClient::setParameterRequestList {option} \
{
    variable paramRequestList
    set retCode 1
    
    switch $option {
        dhcpPad -
        dhcpEnd -
        dhcpSubnetMask -
        dhcpTimeOffset -
        dhcpGateways -
        dhcpTimeServer -
        dhcpNameServer -
        dhcpDomainNameServer -
        dhcpLogServer -
        dhcpCookieServer -
        dhcpLPRServer -
        dhcpImpressServer -
        dhcpResourceLocationServer -
        dhcpHostName -
        dhcpBootFileSize -
        dhcpMeritDumpFile -
        dhcpDomainName -
        dhcpSwapServer -
        dhcpRootPath -
        dhcpExtensionPath -
        dhcpIpForwardingEnable -
        dhcpPolicyFilter -
        dhcpMaxDatagramReassemblySize -
        dhcpDefaultIpTTL -
        dhcpPathMTUAgingTimeout -
        dhcpPathMTUPlateauTable -
        dhcpInterfaceMTU -
        dhcpAllSubnetsAreLocal -
        dhcpBroadcastAddress -
        dhcpPerformMaskDiscovery -
        dhcpMaskSupplier -
        dhcpPerformRouterDiscovery -
        dhcpRouterSolicitAddr -
        dhcpStaticRoute -
        dhcpTrailerEncapsulation -
        dhcpARPCacheTimeout -
        dhcpEthernetEncapsulation -
        dhcpTCPDefaultTTL -
        dhcpTCPKeepAliveInterval -
        dhcpTCPKeepGarbage -
        dhcpNISDomain -
        dhcpNISServer -
        dhcpMTPServer -
        dhcpVendorSpecificInfo -
        dhcpNetBIOSNameSvr -
        dhcpNetBIOSDatagramDistSvr -
        dhcpNetBiosNodeType -
        dhcpNetBIOSScope -
        dhcpXWINSysFontSvr -
        dhcpRequestedIPAddr -
        dhcpIPAddrLeaseTime -
        dhcpOptionOverload -
        dhcpTFTPSvrName -
        dhcpBOOTFileName -
        dhcpMessageType -
        dhcpSvrIdentifier -
        dhcpParamRequestList -
        dhcpMessage -
        dhcpMaxMessageSize -
        dhcpRenerwalTimeValue -
        dhcpRebindingTimeValue -
        dhcpVendorClassId -
        dhcpClientId -
        dhcpXWinSysDisplayMgr -
        dhcpNISplusDomain -
        dhcpNISplusServer -
        dhcpMobileIPHomeAgent -
        dhcpSMTPSvr -
        dhcpPOP3Svr -
        dhcpNNTPSvr -
        dhcpWWWSvr -
        dhcpDefaultFingerSvr -
        dhcpDefaulttIRCSvr -
        dhcpStreetTalkSvr -
        dhcpSTDASvr {
            if {[lsearch $paramRequestList $option] < 0} {
                set paramRequestList [lappend paramRequestList $option]
            }
            set retCode 0
        }
    }

    return $retCode
}

########################################################################################
# Procedure:    dhcpClient::getMagicCookie
#
# Description:  Return the dhcp magic cookie (defined in dhcpClient namespace)
#
# Input:        None
#
# Output:       magic cookie (hex value)
#
########################################################################################
proc dhcpClient::getMagicCookie {} \
{
    variable magicCookie
    return $magicCookie
}

########################################################################################
# Procedure:    dhcpClient::setStartTime
#
# Description:  Record the start of dhcp processing.
#
# Input:        seconds:    start time in seconds
#
# Output:       None
#
########################################################################################
proc dhcpClient::setStartTime {seconds} \
{
    variable startTime
    set startTime $seconds
}

########################################################################################
# Procedure:    dhcpClient::getStartTime
#
# Description:  Return the start time of dhcp processing in seconds.
#
# Input:        None
#
# Output:       start time.
#
########################################################################################
proc dhcpClient::getStartTime {} \
{
    variable startTime
    return $startTime
}




########################################################################################
# Procedure:    dhcpClient::debug
#
# Description:  Depending upon the list of items contained in variable 
#				dhcpClient::debugLevel, debug information is built and
#				printed.
#
# Input:        args:	list of arguments, these are added to debug output
#
# Output:       Printable debug information
#
########################################################################################
proc dhcpClient::debug {args} \
{
	variable debugLevel
	if {[string length $debugLevel] == 0} {
		return
	}

	set output ""
	foreach item $debugLevel {

		switch $item {

			state {		
				set stateName ""
				set port [lindex [GetPortList] 0]
				if {[string length $port] > 0} {
					scan $port "%d %d %d" c l p
					set stateName [GetStateName [GetState $c $l $p]]
				}
				append output "State: $stateName "
			}

			default {			
				set procedure [info level [expr [info level]-1]]
				set arguments [info args [lindex $procedure 0]]
				set defaultInfo [string toupper [lindex $procedure 0]]
				set procedure [lreplace $procedure 0 0]
				
				for {set i 0} {$i < [llength $procedure]} {incr i} {
					set defaultInfo [lappend defaultInfo [lindex $arguments $i] \
														 [lindex $procedure $i]]
				}
				append output "$defaultInfo "
			}
		}
	}
	append output "$args"

	errorMsg "$output"
}

