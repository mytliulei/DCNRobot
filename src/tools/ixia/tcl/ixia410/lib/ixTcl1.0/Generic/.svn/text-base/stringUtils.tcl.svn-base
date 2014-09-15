########################################################################
# Version 4.10	$Revision: 36 $
# $Author: Mgithens $
#
# $Workfile: stringUtils.tcl $ - String helpers
#
#   Copyright © 1997 - 2005 by IXIA
#   All Rights Reserved.
#
#	Revision Log:
#	03-07-2001	DS	Genesis
#
# Description: This file contains string helpers, including wrappers
#              for string commands not supported in 8.0
#
########################################################################


##################################################################################
# Procedure: capitalizeString
#
# This command returns the string w/the first char toupper
#
# Argument(s):
#   str     string to capitalize
#
##################################################################################
proc capitalizeString {str} \
{
    if {[info tclversion] > 8.0} {
        set capString   [string totitle $str]
    } else {
        set capString [format "%s%s" [string toupper [string index $str 0]] [string range $str 1 end]]
    }
    return $capString
}



##################################################################################
# Procedure: stringRepeat
#
# Helper proc to create a string consists of specialized charaters or strings.
#
# Argument(s):
#   string		- the string to repeat, eg. "*", "," ...
#   repeatCount - number of times to repeat the string
#
##################################################################################
proc stringRepeat {string repeatCount} \
{
    if {$repeatCount <= 0} {
        return ""
    }

	# string repeat is a new option added in Tcl8.1
    if {[info tclversion] > 8.0} {
		set outPutString [string repeat $string $repeatCount]

    } else {
        regsub -all {[ ]} [format "%$repeatCount\s" " "] $string outPutString
	}

	return $outPutString
}


##################################################################################
# Procedure: stringIsInteger
#
# Helper proc to verify if a string is an integer value or not.
#
# Argument(s):
#   string		- the string to check
#
# Return value:
#   1 if true
#   0 if false
#
##################################################################################
proc stringIsInteger {string} \
{
	# string is integer is a new option added in Tcl8.1
    if {[info tclversion] > 8.0} {
		set retCode [string is integer $string]
    } else {
        set retCode 1
        if [catch {format %d $string}] {
            set retCode 0
        }
    }

    return $retCode
}


##################################################################################
# Procedure: stringIsDouble
#
# Helper proc to verify if a string is an floating value or not.
#
# Argument(s):
#   string		- the string to check
#
# Return value:
#   1 if true
#   0 if false
#
##################################################################################
proc stringIsDouble {string} \
{
	# string is integer is a new option added in Tcl8.1
    if {[info tclversion] > 8.0} {
		set retCode [string is double $string]
    } else {
        set retCode 1
        if [catch {format %f $string}] {
            set retCode 0
        }
    }

    return $retCode
}


##################################################################################
# Procedure: stringSubstitute
#
# Helper proc to replace a string w/in another string.
#
# Argument(s):
#   string1     - string to look in
#   old	        - the string to replace	
#   new		    - replace w/this string
#
# Return value:
#   new string
#
##################################################################################
proc stringSubstitute {string1 old new} \
{
    set oldLength   [string length $old]
    set index       [string first $old $string1]
    if {$index < 0} {
        set newString   $string1
    } else {

        # string is integer is a new option added in Tcl8.1
        if {[info tclversion] > 8.0} {
            set newString [string replace $string1 $index [expr $index + $oldLength - 1] $new]
        } else {
            set newString [format %s%s%s [string range $string1 0 [expr $index - 1]] $new \
                    [string range $string1 [expr $oldLength + $index] end]]
        }
    }

    return $newString
}

##################################################################################
# Procedure:    stringUnderscore
#
# Description:  Given an alpha-numeric string, build the same string underscored.
#                   Tabs are left in-tact by default, but may be ignored.
#
#                   Given the string:
#                       "Now is the time for all good people to come to the aid of their universe"
#
#                   Returns:
#                       "Now is the time for all good people to come to the aid of their universe"
#                        ========================================================================
#
#                   OR...
#
#                   Given a string with tabs:
#                       "This is a\ttab."
#
#                   Returns:
#                       "This is a\ttab."
#                        =========\t====
#
#                        Looks like:
#
#                       "This is a  tab."
#                        =========  ====

#
# Input:        theString:  string to underscore
#               underscore: default is "="
#               tabs:       ignore OR observe (default)
#
# Output:       underscored string
#
##################################################################################
proc stringUnderscore {theString {underscore "="} {tabs "observe"}} {

    if [string length $theString] {
        
        # Strip out tabs if ignoring.
        if {$tabs != "observe"} {
            regsub -all \t $theString " " theString
        }
        if {[info tclversion] > 8.0} {
            regsub -all {[[:alnum:][:punct:] ]} $theString $underscore underscores
        } else {
            regsub -all {[-a-zA-z0-9 ;:"/?.<>!@#$%&*()+']} $theString $underscore underscores
        }
        
        return $theString\n$underscores\n
    }

}

##################################################################################
# Procedure:    stringTitle
#
# Description:  Convert a string to a title, ie all words capitalized.
#
#                   Given the string:
#                       "Now is the time for all good people to come to the aid of their universe"
#
#                   Returns:
#                       "Now is the Time For All Good People to Come to the Aid of Their Universe"
#
#
# Input:        theString:  string to convert
#               whichWords: significant (default) OR all
#
# Output:       new string
#
#
# This capitalizes all words:
#
#
##################################################################################
proc stringTitle {theString {whichWords "significant"}} \
{

    if {$whichWords == "significant"} {
        set title ""
        foreach i $theString {
            switch -- $i {
                the -
                is -
                to -
                of -
                and {
                    append title "$i "
                }
        
                default {
                    append title "[stringToUpper $i 0 0] "
                }
            }
        }
    set title [string range $title 0 [expr [string length $theString] -1]]
    } else {
        regsub -all {(.+?\M)} $theString {[stringToUpper \1 0 0] } title
        set title [string trim [subst $title]]
    }

    return $title
}




##################################################################################
# Procedure:    stringSplitToTitle
#
# Description:  Splits a string into a title, ie all words capitalized.
#
#                   Given the string:
#                       "headerBytesReceived"
#                   Returns:
#                       "Header Bytes Received"
#
#
# Input:        theString:  string to convert
#
# Output:       new string
#
#
# This capitalizes all words:
#
#
##################################################################################
proc stringSplitToTitle {theString} \
{
    regsub -all {[A-Z]} $theString " &" newText
    set theString [stringToUpper $newText 0 0]

    return $theString
}

##################################################################################
# Procedure:    stringJoinFromTitle
#
# Description:  Joins a title into a string, the first letter of each word (except
#                   the first is kept/made uppercase, for example:
#
#                   Given the string:
#                       "Site Level Aggregation Id"
#                   Returns:
#                       "siteLevelAggregationId"
#
#
# Input:        theString:  string to convert
#
# Output:       new string
#
##################################################################################
proc stringJoinFromTitle {theString} \
{
    set theString [string tolower [stringTitle $theString all] 0 0]
    regsub -all { } $theString "" theString

    return $theString
}




##################################################################################
# Procedure:    stringToUpper
#
# Description:  Return string in upper case
#
#
#
# Input:        theString:  string to convert
#               index1   : If it is specified, it refers to the first char index in the string to start modifying. 
#               index2   : If it is specified, it refers to the char index in the string to stop at. 
#
# Output:       new string
#
#
##################################################################################
proc stringToUpper {theString {index1 -1} {index2  -1}} \
{
    if {[info tclversion] > 8.0} {
        if { $index1 == -1 && $index2 == -1 } {
            set newString [string toupper $theString]
        } elseif { $index2 == -1 } {
            set newString [string toupper $theString $index1]
        } else {
            set newString [string toupper $theString $index1 $index2]
        }

    } else {
        if {$index1 == -1 && $index2 == -1 } {
            set newString [string toupper $theString]
        } elseif { $index2 < $index1 && $index2 != -1} {
            set newString $theString
        } else {
            if {$index2 == -1} {
                set index2 $index1
            }
            set part1 [string range $theString 0 [expr $index1 - 1]]
            set part2 [string range $theString $index1 $index2]
            set part3 [string range $theString [expr $index2 + 1] [string length $theString]]
            set newString [append part1 [string toupper $part2] $part3]

        }
    }        
    return $newString
}

########################################################################################
# Procedure:    stringMap
#
# Description:  Given a translation map, perform character tranlation (same function
#                   as [string map] available in 8.3.
#
# Arguments:    value:	string of characters
#
# Returns:      retValue:	string with characters mapped to the corresponding 
#							characters in the map.  Note that characters not in the 
#                           map are returned unaltered.
#
#
########################################################################################
proc stringMap {{map ""} value} \
{
    set retValue ""
    
    array set translation $map

    set length [string length $value]
    for {set i 0} {$i < $length} {incr i} {

        set translatedValue [string index $value $i]
        if {[info exists translation($translatedValue)]} {
            set translatedValue $translation($translatedValue)
        }
        append retValue $translatedValue
    }

    return $retValue
}


########################################################################################
# Procedure:    stringCompare
#
# Description:  Compare the given strings with option that are all specified by the
#               argument "args".
#
# Arguments:    args - a list that contains options and strings to be compared
#               
#
# Returns:      retValue - the result of the comparison.
#
#
########################################################################################
proc stringCompare {args} \
{
    set retValue 1

    if { [info tclversion] > 8.0 } {

        if [catch {eval "string compare $args"} result] {
            errorMsg $result
        } else {
            set retValue $result
        }

    } else {
        
        set flagNocase  0
        set flagLength  0

        foreach arg $args {

            switch -- $arg {
                "-nocase" {
                    set flagNocase 1
                }
                "-length" {
                    set flagLength 1
                    set state length
                }
                default {

                    if { [info exists state] && ($state == "length") } {

                        set length $arg
                        catch {unset state}

                        if { ![stringIsInteger $length] } {
                            errorMsg "expected integer but got \"$length\""
                            break
                        }

                    } elseif { [info exists string1] == 0 } {
                        set string1 $arg
                    } elseif { [info exists string2] == 0 } {
                        set string2 $arg
                    }
                }
            }
        }

        if { [info exists string1] && [info exists string2] } {

            if { $flagLength == 1 } {
        
                if { $length > 0 } {
                    set index [expr $length - 1]
                    set string1 [string range $string1 0 $index]
                    set string2 [string range $string2 0 $index]
                } else {
                    set string1 ""
                    set string2 ""
                }
            }

            if { $flagNocase == 1 } {
                set string1 [string tolower $string1]
                set string2 [string tolower $string2]
            }

            if [catch {eval "string compare \"$string1\" \"$string2\""} result] {
                errorMsg $result
            } else {
                set retValue $result
            }

        } else {
            errorMsg "wrong # args: should be \"stringCompare ?-nocase? ?-length int? string1 string2\""
        }
        
        return $retValue
    }
}

##################################################################################
# Procedure:    stringFormatNumber
#
# Description:  Take a string on numbers (doesn't support special characters yet)
#                   and insert commas appropriately. 
#
#                   Note: normally the value to be converted is in the parameter
#                   string, when called by a GUI callback function, the value is
#                   in args
#                   
#                   Handles:    -/+ in initial position
#                               comma insertion
#                               removal of non-numeric data
#                               integer with decimal
#
# Arguments:    string
#               args
#
# Returns:      formatted string
#
##################################################################################
proc stringFormatNumber { value {args {}} } \
{
    set retValue 0

    if {[llength $args] > 0} {
        set value [lindex $args 1]
    }

    # Check if there is any numeric characters in the string
    regsub -all {[^0-9]} $value "" temp

    if { [string length $temp] > 0 } {
        set retValue ""

        # Remember sign.
        if {[string compare [string index $value 0] "-"] == 0} {
            set sign $::true
        } else {
            set sign $::false
        }

        # Remove non-numeric characters (except ".")
        regsub -all {[^0-9\.]} $value "" value

        set useDecimal [expr [scan [split $value .] "%s %s" integer decimal] > 1 ? $::true:$::false]
    
        # remove leading '0's before adding commas from INTEGER PORTION ONLY!!
        set integer [string trimleft $integer '0']
        if {[string length $integer] == 0} {
            set integer 0
        }

        if {[string length $integer] > 0} {

            set repetition [mpexpr int([string length $integer] / 3)]
            incr repetition -[expr [expr [mpexpr [string length $integer] % 3]>0] ? 0:1]
        
            for {set i $repetition} {$i > 0} {incr i -1} {
                set startIndex [expr [string length $integer] - 3]
                set triplet [string range $integer $startIndex end]
                set integer [stringReplace $integer $startIndex end]
                set retValue ",$triplet$retValue"
            }
        }
        
        set retValue "$integer$retValue"
        if {$useDecimal} {
            set retValue [join [list $retValue $decimal] .]
        }

        if {$sign} {
            set retValue [format "%s%s" "-" $retValue]
        }
    }

    return $retValue
}


##################################################################################
# Procedure:   stringReplace
#
# Description: Helper proc to replicate the string replace command which is not supported in tcl 8.0
#
# Argument(s): oldString - the original string value
#              first - the index of the starting point for the replacement
#              last - the index of the ending point for the replacement, we will accept end, but not end minus a value
#              newString - (optional, defaults to null) the new string to use
#
# Returns:     Returns a new string created by replacing characters first through last with newString, or nothing.
##################################################################################
proc stringReplace {oldString first last {newString ""}} \
{
    # string replace is a new option added in Tcl8.1
    if {[info tclversion] > 8.0} {
        set newString [string replace $oldString $first $last $newString]
    } else {
        if {$last == "end"} {
            set last [expr [string length $oldString] - 1]
        }
        set newString [format %s%s%s [string range $oldString 0 [expr $first - 1]] $newString \
                [string range $oldString [expr $last + 1] end]]
    }

    return $newString
}
