##################################################################################
# Version 4.10	$Revision: 45 $
# $Author: Mgithens $
#
# $Workfile: testCmdControl.tcl $
#
#   Copyright © 1997 - 2005 by IXIA
#   All Rights Reserved.
#
#	Revision Log:
#	01-06-1999	HS	Genesis
#
# Description: This file contains the commands for all the tests. When a new test
# is added, create a new proc for that test here.
#
##################################################################################


########################################################################################
# Procedure: parseCmd
#
# Description: This command parses the test parameters and calls the appropriate functions.
#
########################################################################################
proc parseCmd {testName {method_name ""} {Args {}}} \
{
    upvar $Args args
    set testMethods [format "%s%s" $testName Methods]
    global $testMethods

    set retCode 0

    set methods [array names ${testMethods}]
    set methods [lsort [lappend methods exists]]

    if {[lsearch $methods $method_name] == -1} {
        error "$testName methods : { $methods }"
        return
    }

    switch $method_name {
        "config" -
        "configure" {
            configureOptions $testName args
        }
        "cget" {
            set retCode [cgetOptions $testName args]
        }
        "exists" {
            set retCode [existsOptions $testName args]
        }
        "start" {
            set retCode [startOptions $testName args]
        }
        "registerResultVars" {
            set retCode [registerResultVarsOptions $testName args]
        }
        "getType" {
            set retCode [getParmProperty $testName type $args]
        }
        "getValidRange" {
            set retCode [getParmProperty $testName validRange $args]
        }
        "getValidValues" {
            set retCode [getParmProperty $testName validValues $args]
        }
        "getValidateProc" {
            set retCode [getParmProperty $testName validateProc $args]
        }
        "getHelp" {
            set retCode [getParmProperty $testName help $args]
        }
        "get" -
        "set" {
	        set mname [format "%s::_%s" $testName $method_name]
	        set retCode [uplevel $mname $args]
        }
        default {

	        set mname [format "%s::%s" $testName $method_name]

	        set retCode [uplevel $mname $args]
        }
    }
    return $retCode
}


########################################################################################
# Procedure: configureOptions
#
# Description: This command is used to configure the parameters.
#
########################################################################################
proc configureOptions {testName arguments} \
{
    upvar $arguments args

    set testMethods [format "%s%s" $testName Methods]
    set testParms   [format "%s%s" $testName Parms]
    set testConfigVals   [format "%s%s" $testName ConfigVals]

	global $testMethods $testParms $testConfigVals

	set argLen [llength $args]
	set type $testName

	# if no option name was passed then display all options available for config
	if {$argLen == 0} {
		set errMsg "Usage: $type config "
		foreach op [set ${testMethods}(config)] {
			set errMsg  [format "%s\n       -$op  <value>" $errMsg]
		}
        error $errMsg
		return
	}

	if {[string index [lindex $args 0] 0] != "-"} {
		set errMsg "Usage: $type config "
		foreach op [set ${testMethods}(config)] {
			set errMsg  [format "%s\n       -$op  <value>" $errMsg]
		}
        error $errMsg
		return
	}
	set opt [lindex [string trimleft [lindex $args 0] "-"] 0]

	# if a wrong option is passed then display all options available for config
	if {[lsearch [set ${testMethods}(config)] $opt] == -1} {
		set errMsg "Usage: $type config "
		foreach op [set [set testMethods](config)] {
			set errMsg  [format "%s\n       -$op  <value>" $errMsg]
		}
        error $errMsg
		return
	}

    if {[info exists ${testConfigVals}]} {
	    # if an option is passed but no value then display the values expected for this parm
	    if {$argLen == 1} {
		    set errMsg "Usage: $type config -$opt "
		    set valList [array names ${testConfigVals}]
		    if {[lsearch $valList $opt] != -1} {
			    foreach val [set ${testConfigVals}($opt)] {
				    set errMsg  [format "%s<$val> " $errMsg]
		        }
		    }
            set errMsg [format "%s\n" $errMsg]
            error $errMsg 
	    }

	    # at this point, it is confirmed that a valid option name with a value has
	    # been passed. Validate the value passed now. Do this only for parms who are
	    # expecting only one value, not multiple. Also, check only if this parm is
	    # expecting a certain type or range of values.
	    if {$argLen == 2} {
		    set valList [array names ${testConfigVals}]
		    if {[lsearch $valList $opt] != -1} {

			    # if the values are required options then it is a list of more
			    # than one element. If values are "one of" type, like a|b|c,
			    # then this is a list of 1 element. First search for the
			    # expected value in the list
			    if {[lsearch [set ${testConfigVals}($opt)] [lindex $args 1]] == -1} {
				    # now it may be an a|b|c type value
				    if {[regexp [set ${testConfigVals}($opt)] [lindex $args 1]] == 0} {
					    set errMsg "Invalid value. Usage: $type config -$opt "
					    foreach val [set ${testConfigVals}($opt)] {
						    set errMsg [format "%s<$val> " $errMsg]
					    }
                        set errMsg [format "%s\n" $errMsg]
					    error $errMsg
				    }
			    }
		    }
	    }
    }

	# if more than one parm is passed then convert it to a list because it is
	# one of the parms that is expecting multiple values. But first check if the
	# right number of values are passed.
	if {$argLen > 2} {
        if {[info exists ${testConfigVals}]} {
		    if {[expr $argLen - 1] != [llength [set [set testConfigVals]($opt)]]} {
			    set errMsg "Invalid number of arguments. Usage: $type config -$opt "
                foreach val [set ${testConfigVals}($opt)] {
				    set errMsg [format "%s<$val> " $errMsg]
                }
                set errMsg [format "%s\n" $errMsg]
			    error $errMsg
		    }
        }
		set argList {}
		for {set i 1} {$i < $argLen} {incr i} {
			set argList [lappend argList [lindex $args $i]]
		}
		set ${testParms}($opt) $argList
	} else {
		set ${testParms}($opt) [lindex $args 1]
	}

	return 0
}

########################################################################################
# Procedure: cgetOptions
#
# Description: This command is used to get the configured parameters.
#
########################################################################################
proc cgetOptions {testName arguments} \
{
    upvar $arguments args

    set testMethods [format "%s%s" $testName "Methods"]
    set testParms   [format "%s%s" $testName "Parms"]

	global $testMethods $testParms

	set type $testName
	if {[llength $args] == 0} {
		set errMsg "Usage: $type cget "
		foreach op [set ${testMethods}(cget)] {
			set errMsg  [format "%s\n       -$op" $errMsg]
		}
        error $errMsg
		return
	}

	if {[string index [lindex $args 0] 0] != "-"} {
		set errMsg  "Usage: $type cget "
		foreach op [set ${testMethods}(cget)] {
			set errMsg  [format "%s\n       -$op" $errMsg]
		}
        error $errMsg
		return
	}
	set opt [lindex [string trimleft [lindex $args 0] "-"] 0]

	if {[lsearch [set ${testMethods}(cget)] $opt] == -1} {
		set errMsg   "Usage: $type cget "
		foreach op [set ${testMethods}(cget)] {
			set errMsg  [format "%s\n       -$op" $errMsg]
		}
        error $errMsg
		return
	}

	return [set ${testParms}($opt)]
}

########################################################################################
# Procedure: getParmProperty
#
# Description: This command is used to get the configured parameters.
#
########################################################################################
proc getParmProperty {testName property parmName} \
{
    set retCode 0

    switch $property {
        type         {set propertyArray [format %sType         $testName]}
        validRange   {set propertyArray [format %sValidRange   $testName]}
        validValues  {set propertyArray [format %sConfigVals   $testName]}
        validateProc {set propertyArray [format %sValidateProc $testName]}
        help         {set propertyArray [format %sHelp         $testName]}
        default {
            error "Parameter property \'$property\' does not exist."
            set retCode 1
        }
    }

    global $propertyArray
    regsub {^-} $parmName "" parmName

    if {($retCode == 0) && [info exists ${propertyArray}($parmName)]} {
        set retCode [set ${propertyArray}($parmName)]
    } else {
        set retCode ""
    }

    return $retCode
}

########################################################################################
# Procedure: startOptions
#
# Description: This command starts the specified test. The frames on desired ports should
# have been configured using the "port" and "streams" commands.  For this test,
# there is only one stream per port with a specific frame size and rate.
#
########################################################################################
proc startOptions {testName arguments} \
{
    upvar $arguments args

    set testMethods [format "%s%s" $testName "Methods"]

	global $testMethods

	set type    $testName
	set methods [lsort [eval set ${testMethods}(start)]]

    # this is some special stuff to preserve backwards compatibility...
	switch $testName {
        tput {
            if {[llength $args] == 0} {
		        lappend args -rfc2544
	        }
            # Protect the depricated test command
            if { $args == "-Rfc2544" } {
                set args    "-rfc2544"
            }
        }
        bcast {
            if {[llength $args] == 0} {
		        lappend args -rate
	        }
        }
        tputjitter {
            if {[llength $args] == 0} {
		        lappend args -linearIteration
	        }
        }
        imix {
            if {[llength $args] == 0} {
		        lappend args -linearIteration
	        }
        }
        tputvlan {
            if {[llength $args] == 0} {
		        lappend args -one2many
	        }
        }
        cableModem {
            # since the percentMaxRate vars have been obseleted, do this for backwards compatiblity
            # w/the new vars
            if {[cableModem cget -clientPercentMaxRate] > 0} {
                cableModem config -rateSelect   percentMaxRate
                cableModem config -clientRate   [cableModem cget -clientPercentMaxRate]
            }  

            if {[cableModem cget -serverPercentMaxRate] > 0} {
                cableModem config -rateSelect   percentMaxRate
                cableModem config -serverRate   [cableModem cget -serverPercentMaxRate]
            }
            
            # Protect the depricated test
            if { $args == "-LLCFiltering" } {
                set args    "-usb02LLCFiltering"
            }
            
            if { $args == "-LLCTransfer" } {
                set args    "-usb02LLCTransfer"
            }
            if { $args == "-multiAddrIPFiltering" } {
                set args    "-usb02MultiAddrIPFiltering"
            }
            if { $args == "-multiAddrIPTransfer" } {
                set args    "-usb02MultiAddrIPTransfer"
            }
            if { $args == "-usb02MultiAddrIPFiltering" } {
                set args    "-usb02MultiAddrFiltering"
            }
            if { $args == "-usb02MultiAddrIPTransfer" } {
                set args    "-usb02MultiAddrTransfer"
            }                 
        }
    }

    switch [llength $args] {
        0 {
            if {[llength $methods] > 0} {
		        puts "Usage: $type start "
		        foreach op $methods {
			        puts "       -$op"
		        }
		        return $::TCL_ERROR
            }
            set opt "start"
        }
        1 {
	        if {[string index [lindex $args 0] 0] != "-"} {
		        puts "Usage: $type start "
		        foreach op $methods {
			        puts "       -$op"
		        }
		        return $::TCL_ERROR
	        }
	        set opt [string trimleft [lindex $args 0] "-"]

	        if {[lsearch $methods $opt] == -1} {
		        puts "Invalid ${testName} command: $methods"
		        return $::TCL_ERROR
	        }
        }
        default {
		    puts "Usage: $type start "
		    foreach op ${testName} {
			    puts "       -$op  <value>"
		    }
		    return $::TCL_ERROR
        }
    }

    set mname [format "%s::%s" $testName $opt]
	set retCode [uplevel $mname]
	
	return $retCode
}


########################################################################################
# Procedure: registerResultVarsOptions
#
# Description: This command registers the results variables.
#
########################################################################################
proc registerResultVarsOptions {testName arguments} \
{
    upvar $arguments args

    set testMethods [format "%s%s" $testName "Methods"]

	global $testMethods

	set type    $testName
	set methods [lsort [eval set ${testMethods}(registerResultVars)]]

    switch [llength $args] {
        0 {
            if {[llength $methods] > 0} {
		        puts "Usage: $type registerResultVars "
		        foreach op $methods {
			        puts "       -$op"
		        }
		        return
            }
            set opt "registerResultVars"
        }
        1 {
	        if {[string index [lindex $args 0] 0] != "-"} {
		        puts "Usage: $type registerResultVars "
		        foreach op $methods {
			        puts "       -$op"
		        }
		        return
	        }
	        set opt [string trimleft [lindex $args 0] "-"]

	        if {[lsearch $methods $opt] == -1} {
		        puts "Invalid ${testName} command: $methods"
		        return
	        }
            set opt [format "registerResultVars_%s" $opt]
        }
        default {
		    puts "Usage: $type registerResultVars "
		    foreach op ${testName} {
			    puts "       -$op  <value>"
		    }
		    return
        }
    }

    set mname [format "%s::%s" $testName $opt]
	set ret [uplevel $mname]

	return $ret
}



########################################################################################
# Procedure: existsOptions
#
# Description: This command is used check if the options exists.
#
# If exists, return 
#
########################################################################################
proc existsOptions {testName arguments} \
{
    upvar $arguments args

    set retCode 0

    set testMethods [format "%s%s" $testName "Methods"]
    set testParms   [format "%s%s" $testName "Parms"]

	global $testMethods $testParms

	set type $testName
	if {[llength $args] == 0} {
        if [info exists ${testMethods}] {
            set retCode 1
        }
	} else {
	    set opt [lindex [string trimleft [lindex $args 0] "-"] 0]

	    if {[lsearch [set ${testMethods}(cget)] $opt] != -1} {
            set retCode 1
	    }
    }

	return $retCode
}



