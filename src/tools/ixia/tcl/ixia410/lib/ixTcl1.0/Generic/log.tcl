##################################################################################
# Version 4.10	$Revision: 44 $
# $Date: 9/30/02 3:59p $
# $Author: Mgithens $
#
# FILE: log.tcl
#
#   Copyright © 1997 - 2005 by IXIA
#   All Rights Reserved.
#
#	Revision Log:
#	10-22-1999	HS	Genesis
#
# Description: Command to set log parameters.
#
##################################################################################



#######################################################################################
# Procedure: logger::on
#
# Description: This command is used to turn on logging. Usage is as follows:
#				log on
#
#######################################################################################
proc logger::on {args} \
{
	global loggerParms

    # if there are any current log files open, close them first
    if [info exists loggerParms(enabled)] {
        logOff
    }

    set loggerParms(enabled) 1
    if {[string length [logger cget -logFileName]] == 0} {
        logger config -logFileName     defaultFile.log
        logger config -fileBackup      false
    }

    set loggerParms(fileID)  [openMyFile [logger cget -logFileName]]

    set startTime [clock seconds]
    catch {results config -startTime $startTime}

    puts [logger cget -fileID] ">>>>>>> Start Time: [clock format [clock seconds] -format "%A, %b %d, %Y    %I:%M:%S %p"]\n"
    logger config -startTime $startTime

    if {[info script] != ""} {
        puts [logger cget -fileID] "\nFile being sourced : [info script]\n"
    }
}


#######################################################################################
# Procedure: logger::off
#
# Description: This command is used to turn off logging. Usage is as follows:
#				log off
#
#######################################################################################
proc logger::off {args} \
{
    global loggerParms

    if [info exists loggerParms(enabled)] {
        logger config -endTime [clock seconds]
        if {[info exists loggerParms(fileID)]} {
		    puts [logger cget -fileID] "\n>>>>>>> End Time: [clock format [clock seconds] -format "%A, %b %d, %Y    %I:%M:%S %p"]"
		    puts [logger cget -fileID] "Actual Duration of Test: [formatDurationTime [expr $loggerParms(endTime) - $loggerParms(startTime)]] seconds"
	        flush [logger cget -fileID]
		    if {[logger cget -fileID] != "stdout"} {
			    closeMyFile [logger cget -fileID]
		    }
            set loggerParms(fileID) stdout
        }
        unset loggerParms(enabled)
    }
}


###############################################################################
# Procedure: logger::message
#
# Description: This command is used to write messages to the log.
#              Usage is as follows:
#                  log message <-priority 1> "This is my message"
#
###############################################################################
proc logger::message {args} \
{
    global loggerParms loggerMethods tcl_platform

    set argLen [llength $args]
    set type   logger

    if {[lindex $args 0] == "-priority"} {
        set args  [lreplace $args 0 0]
        set value [lindex $args 0]
        if [catch {format %d $value} err] {
            set errMsg "Usage: $type message "
            foreach op $loggerMethods(message) {
                set errMsg [format "%s\n       -$op <value> <message>" $errMsg]
            }
            error $errMsg
            return
        }
        set args [lreplace $args 0 0]
        # set the priority here when we decide to use it...
    }

    if {[lindex $args 0] == "-nonewline"} {
        set args [lreplace $args 0 0]

        catch {puts -nonewline [logger cget -ioHandle] [join $args " "]}

        if [info exists loggerParms(enabled)] {
            puts -nonewline [logger cget -fileID] [join $args " "]
        }
    } else {
        catch {puts [logger cget -ioHandle] [join $args " "]}

        if [info exists loggerParms(enabled)] {
            puts [logger cget -fileID] [join $args " "]
        }
    }

    flush [logger cget -ioHandle]

    # required not only for flushing the stdout, but also to flush anything from the
    # open socket connections  (should probably revisit the socket code later)
    update
}


#######################################################################################
# Procedure: logger::show
#
# Description: This command is used to show log parameters. Usage is as follows:
#				logger show
#
#######################################################################################
proc logger::show {args} \
{
    ixPuts "	logger parameters"
    ixPuts "	=================================="
    showCmd logger
}