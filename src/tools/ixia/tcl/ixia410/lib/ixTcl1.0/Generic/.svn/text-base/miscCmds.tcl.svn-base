##################################################################################
# Version 4.10    $Revision: 91 $
# $Author: Mgithens $
#
# $Workfile: miscCmds.tcl $
#
#    Copyright © 1997 - 2005 by IXIA
#    All Rights Reserved.
#
#    Revision Log:
#    02-05-1998    DS    Genesis
#
# Description: Contains miscellaneous log file commands.
#
##################################################################################

########################################################################
# Procedure: logOn
#
# This command wraps the logger command logger on & sets the parameter
#              -logFileName to the defaulted file.
#
# Arguments:
#   filename    - filename, w/out directory, to open
#                 directory *must* be specified via cget -directory
#
########################################################################
proc logOn {{file {}}} \
{
    logger config -logFileName $file
    logger on
}


########################################################################
# Procedure: logOff
#
# This command wraps the logger command logger off
#
########################################################################
proc logOff {} \
{
    logger off
}


########################################################################
# Procedure: logMsg
#
# Description: This command wraps the logger command logger message
#
# Arguments: args - a list of valid arguments
#
# Results: Returns 0 for ok and 1 for error.  WARNING: Cannot use TCL_OK
#          and TCL_ERROR at this point.  It was failing on certain unix
#          and linux combinations
########################################################################
proc logMsg {args} \
{
    set retCode 0
    if {[lindex $args 0] == "-nonewline"} {
        set args [lreplace $args 0 0]
        if {[catch {eval logger::message -nonewline $args} err]} {
            set retCode 1
        }
    } else {
        if {[catch {eval logger::message $args} err]} {
            set retCode 1
        }
    }
    return $retCode
}


########################################################################
# Procedure: errorMsg
#
# This command prints the name of the current proc + a message - intended
# for output of error messages.
#
########################################################################
proc errorMsg {args} \
{
    set level [expr [info level] - 1]
    if {$level > 0} {
        set levelStr    "[lindex [info level $level] 0]: "
    } else {
        set levelStr    "Error: "
    }

    set verbose     1
    set nonewline   0

    while {[string index [lindex $args 0] 0] == "-"} {    
        switch [string range [lindex $args 0] 1 end] {
            "verbose" {
                set verbose 1
                set args [lreplace $args 0 0]
            }
            "noVerbose" {
                set verbose 0
                set args [lreplace $args 0 0]
            }
            "nonewline" {
                set nonewline 1
                set args [lreplace $args 0 0]
            }
            default {
                break
            }
        }
    }

    if {$verbose} {
        if {$nonewline} {
            logger message -priority 1 -nonewline $levelStr[join $args " "]
        } else {
            logger message -priority 1 "$levelStr[join $args " "]"
        }
    }
}


########################################################################
# Procedure: debugOn
#
# This command enables debug messages & sends them to a file.
#
########################################################################
proc debugOn {{file {}}} \
{
    global debug

    set debug(enabled) 1
    if {[string length $file] == 0} {
        set debug(file) [file join [logger cget -directory] debugfile.log]
    } else {
        set debug(file) [file join [logger cget -directory] $file]
    }

    if [catch {open $debug(file) w} fileID] {
        puts stdout "Cannot open $debug(file): $fileID"
        set debug(file) stdout
    } else {
        set debug(file) $fileID
    }

    proc debugMsg {args} \
    {
        global debug

        set levelStr    ""
        set level       [expr [info level] - 1]
        if {$level > 0} {
            set levelStr    "[lindex [info level $level] 0]: "
        }

        puts $debug(file) $levelStr[join $args " "]
    }
}


########################################################################
# Procedure: debugOff
#
# This command disables debug messages & sets the proc debugMsg to empty
#
########################################################################
proc debugOff {} \
{
    global debug
    if [info exists debug(enabled)] {
        unset debug(enabled)
        flush $debug(file)
        if {$debug(file) != "stdout"} {
            close $debug(file)
        }
    }
    proc debugMsg {args} \
    {
    }
}



########################################################################
# Procedure: debugMsg
#
# If debugging is enabled, prints a message to the debug file.
#
########################################################################
proc debugMsg {args} \
{
}


##################################################################################
# Procedure: showCmd
#
# This command lists all available cget options & their current values
#
# Argument(s):
#   cmd     name of command to show
#
##################################################################################
proc showCmd {cmd {method cget}} \
{
    catch {$cmd $method} paramList
    foreach param [lsort [join $paramList]] {
        if {$param == "-this"} {
            continue
        }
        if {[string index $param 0] == "-"} {
            logMsg "$cmd $method $param: [$cmd cget $param]"
        }
    }
}


########################################################################
# Procedure:   openMyFile
#
# Description: This command opens a file set by a command, w/backup if required.
#
# The global array openedFileName contains the full name of opened files indexed
# by their channels. This information will be used to set the permission of the file
# back to both readable and writable when its channel is closed by closeMyFile. 
#
# Arguments:   filename - filename, w/out directory, to open directory *must* be specified via cget -directory
#              testCmd  - test command name, ie., logger or results
#
# Returns:     fileID if successful, or "" if unsuccessful
########################################################################
proc openMyFile {filename {fileAccess w} {command logger}} \
{
    global openedFileName

    set fileID  stdout
    set fullFileName [file join [$command cget -directory] $filename]

    if {[$command cget -fileBackup] == "true" && $fileAccess == "w"} {
        # if the log file by this name exists, then copy it into a different name
        # with a magic number that increments every time the test is run
        if {[file exists $fullFileName]} {
            set filePrefix      [file rootname [file tail $fullFileName]]
            set magicNum        [clock format [file mtime $fullFileName] -format "%H%M%S"]

            # put the full path for new file name
            set newFileName         [format "%s%s%s" $filePrefix $magicNum [file extension $filename]]
            set newFullFileName     [file join [$command cget -directory] $newFileName]
            if [catch {file rename -force $fullFileName $newFullFileName} res] {
                errorMsg "$res"
            }
        }
    }

    set fileID [ixFileUtils::open $fullFileName $fileAccess]
    if {$fileID == ""} {
        set fileID  stdout
    } else {
        set openedFileName($fileID) $fullFileName
    }

    return $fileID
}


########################################################################
# Procedure:   closeMyFile
#
# Description: This command closes a file that is opened by the command openMyFile.
#
# Arguments:   fileId - channel id of the file to be closed
#
# Returns:     None
########################################################################
proc closeMyFile {fileId} \
{
    global openedFileName

    if {$fileId == "stdout"} {
        return
    }

    ixFileUtils::close $fileId

    if { [info exists openedFileName($fileId)] } {
        catch {unset openedFileName($fileId)}
    }
}


########################################################################
# Procedure: callTraceMsg
#
# This command prints a trace of the procs
#
########################################################################
proc callTraceMsg {{arg ""}} \
{
    errorMsg $arg
    for {set x [expr [info level]-1]} {$x > 0} {incr x -1} {
        ixPuts "$x: [info level $x]"
    }
}


########################################################################
# Procedure: traceVariableMsg
#
# This command traces 
#
########################################################################
proc traceVariableMsg {name1 name2 op} \
{
    upvar $name1 Name1
    errorMsg [format "variable = %s, value = %s" $name1 $Name1]
}


##################################################################################
# Procedure: isDigit
#
# This command checks to see if it is digit.
#
# Argument(s):
#
##################################################################################
proc isDigit {arg} \
{
    set retCode 1

    if [catch {format %d $arg}] {
        set retCode 0
    } 
    return $retCode
} 


##################################################################################
# Procedure: isNegative
#
# This command checks to see if it is negative - (needed for >32 bit numbers)
#
# Argument(s):
#
##################################################################################
proc isNegative {arg} \
{
    set retCode 0

    if { [regexp {^-[0-9]+$} $arg] } {
        set retCode 1
    }

    return $retCode
}


##################################################################################
# Procedure:   isValidExponentialFloat
#
# Description: Tells if a value is a legal exponential float.
#
# Argument(s): valueToCheck - the value to check.
#
# Returns:     true if valid, false otherwise
##################################################################################
proc isValidExponentialFloat { valueToCheck } \
{
    if {($valueToCheck == "+") || ($valueToCheck == "-")} {
        # Do not allow just these symbols.  Regexp will not catch them.
        set retCode $::false
    } else {
        # First check for the one digit - a lot clearer than putting alternates in one big pattern
        # Whole digit
        set wholeDigit {^[+-]?[0-9]+}
        # No whole digit but fraction digit
        set fraction {^[+-]?([\.][0-9]+)+}
        if {!([regexp $wholeDigit $valueToCheck] || [regexp $fraction $valueToCheck])} {
            set retCode $::false
        } else {
            # The expression for a legal exponential float means:  An optional +/-
            # followed by zero or more digits followed (the fractional part is 
            # optional) by decimal followed by one or more digits followed by
            # optional exponential expression which consists of e/E followed by
            # optional +/- followed by an integer.
            set validFloat {^[+-]?[0-9]*([\.][0-9]+)?([eE][+-]?[0-9]+)?$}
            if {[regexp $validFloat $valueToCheck]} {
                set retCode $::true
            } else {
                set retCode $::false
            }
        }
    }
    return $retCode
}


##################################################################################
# Procedure:   isValidPositiveExponentialFloat
#
# Description: Tells if a given value is a legal positive exponential float
#
# Argument(s): valueToCheck - the input value to check
#
# Returns:     true if valid, false otherwise
##################################################################################
proc isValidPositiveExponentialFloat { valueToCheck } \
{
    if {[isValidExponentialFloat $valueToCheck] && [expr $valueToCheck > 0]} {
        set retCode $::true
    } else {
        set retCode $::false
    }
    return $retCode
}


##################################################################################
# Procedure:   isValidPartialFloat
#
# Description: Tells if a given value is a legal partial float.
#
# Argument(s): valueToCheck - the input value to check
#
# Returns:     true if valid, false otherwise
##################################################################################
proc isValidPartialFloat { valueToCheck } \
{
    # The expression for a legal partial float means:
    # An optional +/- followed by digits.  Followed by optional decimal and
    # more digits.  Followed by pieces of the optional exponential expression
    # The key difference between partial and full is that partial uses *
    # after 0-9 to show it can have 0 or more values.  The values number
    # must have 1 or more that is why it uses the +.
    set validPartialFloat {^[+-]?[0-9]*([\.][0-9]*)?([eE][+-]?[0-9]*)?$}
    if {[regexp $validPartialFloat $valueToCheck]} {
        set retCode $::true
    } else {
        set retCode $::false
    }
    return $retCode
}


##################################################################################
# Procedure:   isValidPositivePartialFloat
#
# Description: Tells if a given value is a legal positive partial float.
#
# Argument(s): valueToCheck - the input value to check
#
# Returns:     true if valid, false otherwise
##################################################################################
proc isValidPositivePartialFloat { valueToCheck } \
{
    set validPositivePartialFloat {^[+]?[0-9]*([\.][0-9]*)?([eE][+-]?[0-9]*)?$}
    if {[regexp $validPositivePartialFloat $valueToCheck]} {
        set retCode $::true
    } else {
        set retCode $::false
    }
    return $retCode
}


##################################################################################
# Procedure:   isValidPositiveFloat
#
# Description: Tells if a given number is a legal positive float.
#
# Argument(s): valueToCheck - the input value to check
#
# Returns:     true if valid, false otherwise
##################################################################################
proc isValidPositiveFloat { valueToCheck } \
{
    # Special case to handle the singular plus and period
    if {($valueToCheck == "+") || ($valueToCheck == ".")} {
        set retCode $::false
    } else {
        # The expression for a legal float is an optional + followed by either
        # (zero or more digits followed by decimal followed by one or more digits)
        # or one or more digits.
        set validPositiveFloat {^[+]?[0-9]+([\.]?[0-9]+)?$}
        if {[regexp $validPositiveFloat $valueToCheck]} {
            set retCode $::true
        } else {
            set retCode $::false
        }
    }
    return $retCode
}


##################################################################################
# Procedure:   isValidInteger
#
# Description: Tell if a given number is a legal integer
#
# Argument(s): valueToCheck - the input value to check
#
# Returns:     true if valid, false otherwise
##################################################################################
proc isValidInteger { valueToCheck } \
{
    # The expression for a legal integer is an optional +/- followed by one or more digits.
    set validInteger {^[+-]?[0-9]+$}
    if {[regexp $validInteger $valueToCheck]} {
        set retCode $::true
    } else {
        set retCode $::false
    }
    return $retCode
}


##################################################################################
# Procedure:   isValidPositiveInteger
#
# Description: Tell if a given number is a legal non-zero positive integer
#
# Argument(s): valueToCheck - the input value to check
#
# Returns:     true if valid, false otherwise
##################################################################################
proc isValidPositiveInteger { valueToCheck } \
{
    set validPositiveInteger {^[+]?[0-9]+([eE][+-]?[0-9]+)?$}
    # If valueToCheck is zero, special case failure
    if {$int == "0"} {
        set retCode $::false
    } else {
        if {[regexp $validPositiveInteger $valueToCheck]} {
            set retCode $::true
        } else {
            set retCode $::false
        }
    }
    return $retCode
}



##################################################################################
# Procedure: getProcList
#
# This command opens a Tcl file & prints all procs that live in that file.
#
# Argument(s):
#   fileName        file name
#   sortOn          sort either by proc name or line number (default is proc name)
#
##################################################################################
proc getProcList {fileName {sortOn procName} {ProcList ""} {verbose verbose}} \
{
    set retCode 0

    upvar $ProcList procList

    set cmd      "proc "
    if [catch {open $fileName r} fid] {
        errorMsg "Cannot open file $fileName"
        set retCode 1
    } else {

        if {$verbose == "verbose"} {
            ixPuts "FILE:  $fileName"
            ixPuts "============================================================================"
        }

        if [info exists procList] {
            unset procList
        }

        set linenum 1
        while {![eof $fid]} {
            gets $fid originalLine

            if {[string first $cmd $originalLine] == 0} {
                lappend procList   [list $linenum [string range [string trim $originalLine \\] 5 end]]
            }
            incr linenum
        }        
        close $fid

        if {$sortOn == "procName"} {
            set procList    [lsort -index 1 $procList]
        } else {
            set procList    [lsort -index 0 -integer $procList]
        }

        if {$verbose == "verbose"} {
            foreach item $procList {
                scan $item "%s %s" linenum name
                ixPuts [format "Line: %4d ::::\t%s" $linenum [join [lrange $item 1 end]]]
            }
        }
    }

    return $retCode
}


##################################################################################
# Procedure: getTxBasedOnRx
#
# This command returns the tx port based on rx port from TxRxArray
#
# Argument(s):
#   TxRxArray       - map, ie. one2oneArray
#
##################################################################################
proc getTxBasedOnRx {TxRxArray c l p } \
{
    upvar $TxRxArray txRxArray
    
    set breakFlag   0

    foreach txMap [lnumsort [array names txRxArray]] {
        scan $txMap    "%d,%d,%d" tx_c tx_l tx_p

        foreach rxMap $txRxArray($tx_c,$tx_l,$tx_p) {
            scan $rxMap "%d %d %d" rx_c rx_l rx_p

            if { [list $rx_c $rx_l $rx_p] == [list $c $l $p]} {
                set txPort  [list $tx_c $tx_l $tx_p]
                set breakFlag   1
                break
            }
        }
        if {$breakFlag ==1} {
            break
        }
    }
    return $txPort
}

##################################################################################
# Procedure: convertFromSeconds
#
# This command formats the duration in hour:minute:seconds format.
#
# Argument(s):
#   duration        duration of the test
#
##################################################################################
proc convertFromSeconds {time Hours Minutes Seconds} \
{
    set retCode $::TCL_OK

    upvar $Hours   hours
    upvar $Minutes minutes
    upvar $Seconds seconds

    set hours       [expr {$time / 3600}]

    set minuteTemp  [expr {$time - $hours * 3600}]
    set minutes     [expr {$minuteTemp / 60}]

    set seconds     [expr {$minuteTemp - $minutes * 60}]

    return $retCode
}


###############################################################################
# Procedure: convertToSeconds
#
# Description: Convert hours:min:seconds to seconds
#
# Arguments: hours
#            minutes
#            seconds
#
# Returns:   time, in seconds
#
###############################################################################
proc convertToSeconds {hours minutes seconds} \
{
    if {[scan $hours "%d" x] <= 0} {
        set hours 0
    }
    if {[scan $minutes "%d" x] <= 0} {
        set minutes 0
    }
    if {[scan $seconds "%d" x] <= 0} {
        set seconds 0
    }

    return [expr ((($hours*60) + $minutes) * 60) + $seconds]
}



##################################################################################
# Procedure: formatDurationTime
#
# This command formats the duration in hour:minute:seconds format.
#
# Argument(s):
#   duration        duration of the test
#
##################################################################################
proc formatDurationTime {duration} \
{
    convertFromSeconds $duration hour minute seconds   
    return  [format "%.2d:%.2d:%.2d" $hour $minute $seconds]   
}


##################################################################################
# Procedure: formatNumber
#
# This command formats the number based on the format given
#
# Argument(s):
#   number        number to be formated
#
##################################################################################
proc formatNumber {number formatTemplete} \
{
 	scan $formatTemplete "%d.%d" intDigits decDigits
	set base [expr pow(10,$decDigits)]

    if {$number > 0.00 && $number < [expr 1/$base]} {
        set number [expr ceil($number * $base)/$base]
    } else {
		set newFormat [format "%d.%df" $intDigits $decDigits]
        set number  [format "%$newFormat" $number]
    }
 
   return  $number
   
}

##################################################################################
# Procedure: unixCludgeGetExpr
#
# This command reroutes mpexpr command. (Note: for UNIX)
#
# Argument(s):
#   duration        duration of the test
#
##################################################################################
proc unixCludgeGetExpr {} \
{
    set expr    mpexpr

    if {[lsearch [join [info loaded]] Mpexpr] < 0} {
        set expr    expr
    }

    return $expr
}


##################################################################################
# Procedure: useProfile
#
# This command get the profiles
#
# Argument(s):
#   use         "true" for using profile and "false" for not using it. It is set to 
#               "false" so whenever you want to use it set it to "true". 
#
##################################################################################
proc useProfile {use} \
{
    if { $use == "true" } \
    {
        if {[info tclversion] > 8.0} {
            proc ixInitProfiler {} \
            {
                global currTime
                set currTime    [clock clicks -milliseconds]
            }
            proc profiler {args} \
            {
                global currTime

                set now         [clock clicks -milliseconds]
                set diff        [expr $now - $currTime]
                set currTime    $now

                return $diff
            }
                
        } else {
            global halCommands
        
            if {[lsearch $halCommands profiler] == -1} {
                lappend halCommands profiler
            }

            proc ixInitProfiler {} \
            {
                if {[TCLProfile profiler] == ""} {
                    puts "Error instantiating TCLProfile object!"
                    return 1
                }
            }
        }
        catch {ixInitProfiler}
        proc ixProfile {args} \
        {   # take an optional comment string
            set commentStr  ""
            if {[llength $args] > 0} {
                set commentStr "[lindex $args 0]"
            }
            set levelStr    ""
            set level [expr [info level] - 1]
            if {$level > 0} {
                set levelStr    "[lindex [info level $level] 0]: "
            }
            logMsg "$levelStr: [profiler getDiffTime] $commentStr"
        }
    } else {
        proc ixInitProfiler {} {}
        proc ixProfile {args} {}
        proc profiler {{arg ""}} {}
    }
}        

########################################################################################
# Procedure:    CountGlobalMemory
#
# Description:  Counts the memory usage of a global variable or array, or all global
#					variables and arrays.
#
#					Tcl arrays are stored as hash tables, the indices are stored
#						as strings.  The overhead in the hash tables is not easily
#						accounted for, thus it is not accounted for in this procedure.
#
#					The following is a quote from www.scriptic.com/bboard
#
#					"...Each array entry will have an overhead of 16 bytes (on a 32-bit
#					machine) over the size of the data due to the code that manages the
#					hashtable on which the array is based, another 32 bytes due to the 
#					fact that it is a Tcl array entry and is not just a simple mapping 
#					between strings, and another 24 bytes for each unique value in the 
#					array. (There is also a small overhead due to the overall array and 
#					hashtable management themselves, but this probably doesn't matter 
#					since it is roughly invariant with the size of the table; the only
#					non-constant part is the size of the C array holding the addresses
#					of the bucket chains, but that's generally going to average at less
#					than a byte per entry.) This gives you an overhead of 72 bytes per 
#					entry assuming a worst case of all values being different, which is
#					likely to be the case with your code since Tcl doesn't work incredibly
#					hard at merging values which look the same (if it did, the cost of doing
#					this would be prohibitive.)"
#
# Input:        memory:		array name, wildcard characters are usuable (gxi*)
#								default is all globals.
#
# Output:       byte count
#
#
########################################################################################
proc CountGlobalMemory {{memory ""}} \
{

	# Hash table overhead is 16 bytes per entry
	set hashTableOverhead 16

	# Tcl Array mapping overhead is 32 bytes per entry
	set arrayMappingOverhead 32

	# Unique value overhead is 24 bytes per entry
	set uniqueValueOverhead 24

	# Overall Overhead per Entry
	set TclOverhead \
		[expr $hashTableOverhead + $arrayMappingOverhead + $uniqueValueOverhead]

	set arrayCounter 0
	set arraySizeCounter 0
	set arrayIndexSizeCounter 0

	if {[string length $memory] == 0} {
		set command [list info globals]
	} else {
		set command [list info globals $memory]
	}

	foreach i [lsort [eval $command]] {
		global $i
		if [array exists $i] {
			incr arrayCounter [array size $i]
			foreach j [array names $i] {
				incr arraySizeCounter [string length ${i}($j)]
				incr arrayIndexSizeCounter [string length $j]
			}
	
		} else {
			incr arraySizeCounter [string length ${i}]
		}
	}

	set totalOverhead [expr $TclOverhead * $arrayCounter]

#	errorMsg "Array Elements: $arrayCounter, \
#			  Array Element Overhead: $totalOverhead \
#			  Array Size: $arraySizeCounter, \
#			  Array Index Overhead: $arrayIndexSizeCounter"


	return [expr $arraySizeCounter + $arrayIndexSizeCounter + $totalOverhead]											

}


########################################################################################
# Procedure:    createNamedFont
#
# Description:  Create a font with the given name, font family, and size.
#               If a font exists with the same name, set it to the given font family
#               and size.
#
# Input:        name:   font name
#               family: name of the font family
#               size:   size of the font
#
# Output:       nothing
#
########################################################################################
proc createNamedFont { name family size } \
{
    if {[lsearch [font names] $name] == -1} { 
        font create $name -family $family -size $size
    } else {
        font config $name -family $family -size $size
    }
}


########################################################################################
# Procedure:    buildFileName
#
# Description:  Builds a new file name by appending the type to the main fileName. This 
#               is used mostly for the tests that either generate mutiple results files
#               
#
# Input:        fileName: filename without the ".results"
#               type :    type, ie. runtype, errorType etc..
#
# Output:       The new filename
#
########################################################################################
proc buildFileName { fileName  type} \
{
    if { [regexp {\.} $fileName] == 1} {

        set firstPart   [string range $fileName 0 [expr [string last . $fileName] -1] ]
        set lastPart    [string range $fileName [string last . $fileName] end ] 
        unset fileName
        append fileName $firstPart _$type $lastPart 
    } else {
        append fileName _$type
    }

    return $fileName
}