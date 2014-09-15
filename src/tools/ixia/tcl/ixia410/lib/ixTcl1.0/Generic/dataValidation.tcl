###############################################################################
# Version 4.10	$Revision: 53 $
# $Date: 10/07/02 5:09p $
# $Author: Mgithens $
#
# $Workfile: dataValidation.tcl $
#
# Copyright © 1997 - 2005 by IXIA
# All Rights Reserved.
#
# Description: This file contains the namespace and its procedures that verify
#              IXIA test parameters when a new test is started.
#
# Revision Log:
#
# Date		    Author				Comments
# -----------	-------------------	-------------------------------------------
# 2001/04/24	Scott Si	        Created
#
###############################################################################

namespace eval dataValidation {} \
{
    #
    # All the following ARRAYs are indexed by the name of TCL variable of IXIA
    # test, such as numIterations (number of iterations) and percentMaxRate
    # (max percent rate).
    #
    variable typeArray
    variable validValuesArray
    variable validRangeArray
    variable validateProcArray
    variable helpArray

    #
    # typePattern defines the valid types for all the test parameters, which
    # are the following.
    #     {integer, integerList, double, boolean, string, stringList, ipaddress, imixlist, macaddress, portlist}
    #
    variable typePattern {^integer$|^integerList$|^double$|^boolean$|^string$|^stringList$|^ipaddress$|^imixlist$|^macaddress$|^portlist$}

    #
    # booleanPattern defines the valid values for all the test parameters that is of
    # the type boolean. The valide value must be one of the following.
    #     {ture false yes no 1 0}
    #
    variable booleanPattern {^true$|^false$|^yes$|^no$|^1$|^0$}
}

###############################################################################
#
# dataValidation::initialize
#
# Description:  Initialize rules for data validation. This function should be
#               invoked when a new test is selected.
#
# Input:        None
#
# Output:       None.
#
###############################################################################
proc dataValidation::initialize {} \
{
    variable typeArray
    variable validValuesArray
    variable validRangeArray
    variable validateProcArray
    variable helpArray

    variable errorString ""

    catch {unset typeArray        }
    catch {unset validValuesArray }
    catch {unset validRangeArray  }
    catch {unset validateProcArray}
    catch {unset helpArray        }

    #
    # The following parameters are kept by the global array testConf.
    #
    setParameter -parameter hostname              -type stringList
    setParameter -parameter cableLength           -type stringList  -validValues {cable3feet cable6feet cable9feet cable12feet cable15feet cable18feet cable21feet cable24feet}
    setParameter -parameter chassisID             -type integerList -validRange  {0 NULL}
    setParameter -parameter chassisSequence       -type integerList -validRange  {1 NULL}
    set speedList [list 10 100 1000 usb oc3 oc12 stm1c stm4c oc48 stm16c oc192 stm64c "WAN (Sonet)" "WAN (SDH)" 10000 9294 Copper10 Copper100 Copper1000 Fiber1000]

    setParameter -parameter speed                 -type string     -validValues $speedList -validateProc dataValidation::validatePortSpeed
    setParameter -parameter RxPortSpeed           -type string     -validValues $speedList -validateProc dataValidation::validatePortSpeed
    setParameter -parameter TxPortSpeed           -type string     -validValues $speedList -validateProc dataValidation::validatePortSpeed
    setParameter -parameter serverSpeed           -type string     -validValues $speedList -validateProc dataValidation::validatePortSpeed
    setParameter -parameter clientSpeed           -type string     -validValues $speedList -validateProc dataValidation::validatePortSpeed
    setParameter -parameter PPPnegotiation        -type boolean
    setParameter -parameter autoMapGeneration     -type boolean
    setParameter -parameter autonegotiate         -type boolean
    setParameter -parameter duplex                -type string     -validValues {full half}
    setParameter -parameter incrIpAddrByteNum     -type integer    -validValues {1 2 3 4}
    setParameter -parameter mapDirection          -type string     -validValues {unidirectional bidirectional}
    setParameter -parameter sonetRxCRC            -type string     -validValues {sonetCrc16 sonetCrc32}
    setParameter -parameter sonetTxCRC            -type string     -validValues {sonetCrc16 sonetCrc32}
    setParameter -parameter supportsPOS           -type boolean
    setParameter -parameter useMagicNumber        -type boolean
    setParameter -parameter useRecoveredClock     -type boolean
    setParameter -parameter dataScrambling        -type boolean
    setParameter -parameter enable802dot1qTag     -type boolean
    setParameter -parameter enableISLtag          -type boolean
    setParameter -parameter firstDestDUTIpAddress -type ipaddress  
    setParameter -parameter firstSrcIpxSocket     -type string
    setParameter -parameter ethernetType          -type string     -validValues {noType ethernetII}
    setParameter -parameter hdlcHeader            -type string     -validValues {ppp cisco}
    setParameter -parameter maxPercentRate        -type double     -validRange  {0.0001 100}
    setParameter -parameter responseTime          -type integer    -validRange  {0 NULL}
    setParameter -parameter protocolName          -type string     -validValues {mac ip ipV6 ipx}
}

###############################################################################
#
# dataValidation::setParameter
#
# Description:  Create an entry in the data validation database.
#
# Input:        args - arguments that define the name, type, values, and command
#                      for a test parameter in the following format.
#
#                      -parameter   $name   \
#                      -type        $type   \
#                      -validValues $values \
#                      -validRange  $range  \
#                      -command     $command
#
# Output:       status of the procedure
#
###############################################################################
proc dataValidation::setParameter {args} \
{
    variable typeArray
    variable validValuesArray
    variable validRangeArray
    variable validateProcArray
    variable helpArray

    variable typePattern

    set retCode $::TCL_OK

    #
    # This one is different in that the args could contain multiple -validateProc.
    #
    set validateProcArg {}

    foreach arg $args {

        if {[regexp {^-[a-zA-Z].+} $arg]} {
            #
            # Current argument is preceeded by '-'.
            #

            # Remove the preceeding '-'.
            regsub {^-} $arg "" option

            switch $option {
                parameter     -
                type          -
                validValues   -
                validRange    -
                validateProc  -
                help {
                    set currentOption $option
                    set currentAction getValue
                }
                default {
                    set retCode $::TCL_ERROR
                    break
                }
            }
        } else {
            if {[info exists currentAction]} {
                switch $currentAction {
                    "getValue" {
                        if {$currentOption == "validateProc"} {
                            lappend ${currentOption}Arg $arg
                        } else {
                            set ${currentOption}Arg $arg
                        }

                        unset currentOption
                        unset currentAction
                    }
                    default {
                        set retCode $::TCL_ERROR
                        break
                    }
                }
            } else {
                set retCode $::TCL_ERROR
                break
            }
        }
    }

    if {$retCode == $::TCL_OK} {
        #
        # Parameter name, and parameter type are mandatory when setting a test parameter.
        #
        if {[info exists parameterArg] == 0} {
        
            set retCode $::TCL_ERROR
        
        } elseif {[info exists typeArg] == 0} {

            set retCode $::TCL_ERROR

        } elseif {[info exists validValuesArg] && [info exists validRangeArg]} {

            set retCode $::TCL_ERROR

        }
    }

    if {$retCode == $::TCL_ERROR} {
        errorMsg "Invalid arguments: \"$args\"."
        return $retCode
    }

    if {[info exists typeArg]} {
        set typeArray($parameterArg) $typeArg
    }

    if {[info exists validValuesArg] && ($validValuesArg != "")} {
        set validValuesArray($parameterArg) $validValuesArg
    }

    if {[info exists validRangeArg]} {
        set validRangeArray($parameterArg) $validRangeArg
    }

    if {[info exists validateProcArg]} {
        set validateProcArray($parameterArg) $validateProcArg
    }

    if {[info exists helpArg]} {
        set helpArray($parameterArg) $helpArg
    }

    return $retCode
}

###############################################################################
#
# dataValidation::getParameter
#
# Description:  Retrieve properties of test parameter(s).
#
# Input:        args - arguments of the following format
#                      (-parameter parameter) (-type) (-validValues) (-validRange) (-help)
#
# Output:       Prints out all the rules if no arguments specified.
#               Returns the rules for a parameter if only the parameter name 
#               is specified. 
#               Retruns the property if both the parameter name and the 
#               property name are specified.
#
###############################################################################
proc dataValidation::getParameter {args} \
{
    variable typeArray
    variable validValuesArray
    variable validRangeArray
    variable validateProcArray
    variable helpArray
    variable command

    set retCode $::TCL_OK

    set numArgs [llength $args]

    switch $numArgs {
        0 {
            #
            # No arguments. Show everything.
            #
            showRules
        }
        2 {
            #
            # Has to be {-parameter $name}. Will return everything in a list of the
            # format {{$type} {$value} {$command}}. Primarily for find out the
            # general information the parameter about a parameter.
            #
            if {[lindex $args 0] == "-parameter"} {
                set argName [lindex $args 1]
                set retCode ""
                if [info exists typeArray($argName)] {
                    append retCode "-parameter $argName -type $typeArray($argName) "

                    if [info exists validValuesArray($argName)] {
                        append retCode "-validValues [list $validValuesArray($argName)] "
                    }
                    if [info exists validRangeArray($argName)] {
                        append retCode "-validRange [list $validRangeArray($argName)] "
                    }
                    if [info exists validateProcArray($argName)] {
                        append retCode "-validateProc $validateProcArray($argName)"
                    }
                    if [info exists helpArray($argName)] {
                        append retCode "-help $helpArray($argName)"
                    }
                }
            } else {
                errorMsg "Invalid format \"$args\"."
                set retCode $::TCL_ERROR
            }
        }
        3 {
            #
            # Has to be "-parameter $name -{type|validValues|validRange|validateProc|help}". 
            # Will return exactly what the caller wants.
            #
            if {[lindex $args 0] == "-parameter"} {
                set argName [lindex $args 1]

                if [info exists typeArray($argName)] {
                    #
                    # The specified parameter name exists.
                    #
                    set property [string trimleft [lindex $args 2] -]

                    if {$property == "type"} {

                        set retCode $typeArray($argName)

                    } elseif {$property == "validValues"} {
                        
                        if [info exists validValuesArray($argName)] {
                            set retCode $validValuesArray($argName)
                        } else {
                            set retCode ""
                        }
                    } elseif {$property == "validRange"} {
                        
                        if [info exists validRangeArray($argName)] {
                            set retCode $validRangeArray($argName)
                        } else {
                            set retCode ""
                        }
                    } elseif {$property == "validateProc"} {

                        if [info exists validateProcArray($argName)] {
                            set retCode $validateProcArray($argName)
                        } else {
                            set retCode ""
                        }
                    } elseif {$property == "help"} {

                        if [info exists helpArray($argName)] {
                            set retCode $helpArray($argName)
                        } else {
                            set retCode ""
                        }
                    } else {
                        errorMsg "Invalid type \"$args\"."
                        set retCode $::TCL_ERROR
                    }
                } else {
                    #
                    # The specified parameter name does not exist.
                    #
                    debugMsg "The parameter \"$argName\" does not exist."
                }
            } else {
                errorMsg "Invalid format \"$args\"."
                set retCode $::TCL_ERROR
            }
        }
        default {
            #
            # Error.
            #
            errorMsg "Invalid format \"$args\"."
            set retCode $::TCL_ERROR
        }
    }
    
    return $retCode
}

###############################################################################
#
# dataValidation::showRules
#
# Description:  This command displays the data validation database.
#
# Input:        None
#
# Output:       None
#
###############################################################################
proc dataValidation::showRules {} \
{    
    variable typeArray
    variable validValuesArray
    variable validRangeArray
    variable validateProcArray
    variable helpArray
    variable command

    ixPuts "========================================================================"
    ixPuts [format "%-24s %-10s %-80s %-s" "Parameter" "Type" "Values" "ValidateProc"]
    ixPuts "========================================================================"

    foreach name [lsort [array name typeArray]] {

        set rule [format "%-24s %-10s" $name $typeArray($name)]
        
        if [info exists validValuesArray($name)] {
            append rule [format " %-80s" $validValuesArray($name)]
        }
        if [info exists validRangeArray($name)] {
            append rule [format " %-80s" $validRangeArray($name)]
        }
        if [info exists validateProcArray($name)] {
            append rule [format " %-30s" $validateProcArray($name)]
        }
        if [info exists helpArray($name)] {
            append rule [format " %-30s" $helpArray($name)]
        }

        ixPuts $rule
    }
}

###############################################################################
#
# dataValidation::parseValues
#
# Description:  This command makes sure that the validateValues or validateRange
#               comply with the given type. (NEED TO BE MODIFIED)
#
# Input:        
#
# Output:       
#
###############################################################################
proc dataValidation::parseValues {type values} \
{
    if {[llength $values] != 2} {
        errorMsg "Wrong format for values \"$values\"."
        return $::TCL_ERROR
    }

    set retCode $::TCL_OK

    set valueProperty [lindex $values 0]

    switch $valueProperty {
        enum {
            set valueList [lindex $values 1]
            set retCode   [areValuesOfTheType $type $valueList]
        }
        range {
            set valueRange [lindex $values 1]

            if {[llength $valueRange] != 2} {
                errorMsg "Invalid range \"$valueRange\"."
                set retCode $::TCL_ERROR
            } else {
                set lowerLimit [lindex $valueRange 0]
                set upperLimit [lindex $valueRange 1]

                if {($type == "integer") || ($type == "double")} {

                    if {($lowerLimit != "NULL") && ($upperLimit != "NULL")} {
                        if {([areValuesOfTheType $type $valueRange] == $::TCL_OK) &&
                            ($lowerLimit >= $upperLimit)} {
                            errorMsg "Invalid range \"$valueRange\"."
                            set retCode $::TCL_ERROR
                        }
                    } elseif {$lowerLimit == "NULL"} {
                        if {[areValuesOfTheType $type $upperLimit] != $::TCL_OK} {
                            errorMsg "Invalid range \"$valueRange\"."
                            set retCode $::TCL_ERROR
                        }
                    } elseif {$upperLimit == "NULL"} {
                        if {[areValuesOfTheType $type $lowerLimit] != $::TCL_OK} {
                            errorMsg "Invalid range \"$valueRange\"."
                            set retCode $::TCL_ERROR
                        }
                    }
                }
            }
        }
        default {
            errorMsg "Wrong value property for values \"$values\"."
            set retCode $::TCL_ERROR
        }
    }

    return $retCode
}


###############################################################################
#
# dataValidation::isPortList
#
# Description:  Find out if the given value is a valid port list.
#
# Input:        value to be checked.
#
# Output:       1 if yes.
#               0 otherwise.
#
###############################################################################
proc dataValidation::isPortList {value} \
{
    foreach args $value {
        foreach arg $args {
            if {$arg >=0 && [isInteger $arg]} {
                return 1
            } else {
                return 0
            }
        }
    }
}

###############################################################################
#
# dataValidation::isString
#
# Description:  Find out if the given value is a valid IP addresss.
#
# Input:        value to be checked.
#
# Output:       1 if yes.
#               0 otherwise.
#
###############################################################################
proc dataValidation::isString {value} \
{
#   return [regexp {^[a-zA-Z].+} $value]
    return 1
}

###############################################################################
#
# dataValidation::isInteger
#
# Description:  Find out if the given value is a valid IP addresss.
#
# Input:        value to be checked.
#
# Output:       1 if yes.
#               0 otherwise.
#
###############################################################################
proc dataValidation::isInteger {value} \
{
    return [regexp {^[-]?[0-9]+$} $value]
}

###############################################################################
#
# dataValidation::isDouble
#
# Description:  Find out if the given value is a valid IP addresss.
#
# Input:        value to be checked
#
# Output:       1 if yes.
#               0 otherwise.
#
###############################################################################
proc dataValidation::isDouble {value} \
{
    set retCode 0

    if { [string length $value] > 0 } { 
        set retCode [regexp {^-?[0-9]*\.?[0-9]*$} $value]
    } 
    return $retCode
}

###############################################################################
#
# dataValidation::areValuesOfTheType
#
# Description:  Find out if all the given values are of the given type.
#
# Input:        type  - integer, double, string, ipaddress, or portlist
#               value - list of values to be checked
#
# Output:       TCL_OK    if no error
#               TCL_ERROR otherwise
#
###############################################################################
proc dataValidation::areValuesOfTheType {type value} \
{
    set retCode $::TCL_OK

    if {[llength $value] == 0} {
        set retCode $::TCL_ERROR
	    return $retCode
    }

    set flagList 0
        
    switch $type {
        integer   { set function isInteger        }
        double    { set function isDouble         }
        string    { set function isString         }
        ipaddress { set function isIpAddressValid }
        portlist  { set function portlist         }
        integerList {
            set function isInteger
            set flagList 1
        }
        stringList {
            set function isString
            set flagList 1
        }
        default   {
            errorMsg "Invalid type \"$type\"."
            return $::TCL_ERROR
        }
    }

    if { $flagList == 1 } {

        foreach item $value {
            if {[eval {$function $item}] == 0} {
            set retCode $::TCL_ERROR
                break
            }
        }

    } else {

        if {[eval {$function $value}] == 0} {
            set retCode $::TCL_ERROR
        }
    }

    return $retCode
}

###############################################################################
#
# dataValidation::validateTest
#
# Description:  This command is invoked to validate the test parameters of the
#               given test command.
#
# Input: 
#   cmd     - test command
#          
#
# Output:       TCL_OK    if no error
#               TCL_ERROR otherwise       
#
###############################################################################
proc dataValidation::validateTest {cmd {method cget}} \
{
    set retCode   $::TCL_OK
    
    catch {$cmd $method} paramList
    foreach param [lsort [join $paramList]] {
        if {$param == "-this"} {
            continue
        }
        if {[string index $param 0] == "-"} {
            set param   [string trim $param -]
            if [validateCommandParameter $cmd $param] {
                ixPuts "Invalid value specified for parameter -$param :[$cmd cget -$param], \
                        Valid value(s):[getValidValueString $cmd $param]"
                set retCode   $::TCL_ERROR
            }
        }
    }
    return $retCode    
}

###############################################################################
#
# dataValidation::getValidValueString
#
# Description:  This command is 
#
# Input:        
#   cmd     - test command
#   param   - command parameter
#
# Output:       
#
###############################################################################
proc dataValidation::getValidValueString {cmd param} \
{
    set retCode   $::TCL_OK

 
    return $retCode    
}

###############################################################################
#
# dataValidation::validateTestConfParameter
#
# Description:  This command validate the the specified parameter of testConf.
#
# Input:        parameter - name of the parameter
#               value     - value of the parameter
#
# Output:       TCL_OK if no error.
#               TCL_ERROR otherwise.
#
###############################################################################
proc dataValidation::validateTestConfParameter {parameter value} \
{
    set retCode $::TCL_OK

    switch $parameter {
        hdlcHeader        -
        duplex            -
        speed             -
        TxPortSpeed       -
        RxPortSpeed       -
        useMagicNumber    -
        sonetRxCRC        -
        sonetTxCRC        -
        dataScrambling    -
        useRecoveredClock -
        autonegotiate     -
        PPPnegotiation {

            #
            # The values of these parameters could be in a list of pairs (value interface).
            #

            # checking speed for 10GE WAN/OC192.
            if {$parameter == "speed" && (($value == "WAN (Sonet)") || ($value == "WAN (SDH)"))} {
                set retCode $::TCL_OK
            } elseif {$parameter == "speed" && (($value == "Copper10") || ($value == "Copper100") || \
                    ($value == "Copper1000") || ($value == "Fiber1000"))} {
                set retCode $::TCL_OK
            } else {
                foreach elemOfValue $value {
                    set currValue [lindex $elemOfValue 0]
                    set retCode [doValidateTestConfParameter $parameter $currValue]
                    if {$retCode != $::TCL_OK} {
                        break
                    }
                }
            }
        }
        default {
            set retCode [doValidateTestConfParameter $parameter $value]
        }
    }

    return $retCode
}

###############################################################################
#
# dataValidation::doValidateTestConfParameter
#
# Description:  This command performs the validation of the specified parameter of testConf.
#
# Input:        parameter - name of the parameter
#               value     - value of the parameter
#
# Output:       TCL_OK if no error.
#               TCL_ERROR otherwise.
#
###############################################################################
proc dataValidation::doValidateTestConfParameter {parameter value} \
{
    variable booleanPattern

    set retCode $::TCL_OK

    set parameterType [getParameter -parameter $parameter -type]
    if {$parameterType == ""} {
        return $::TCL_ERROR
    }

    switch $parameterType {
        boolean {
            if {[regexp $booleanPattern $value] == 0} {
                set retCode $::TCL_ERROR
            }
        }
        integer -
        double {
            set retCode [areValuesOfTheType $parameterType $value]
            if {$retCode == $::TCL_OK} {
                set retCode [validateNumber "testConfig" $parameter $value]
            } 
        }
        integerList {
            set retCode [areValuesOfTheType $parameterType $value]        
            if {$retCode == $::TCL_OK} {
                foreach valueOfList $value {
                    set retCode [validateNumber "testConfig" $parameter $valueOfList]
                    if { $retCode == $::TCL_ERROR } {
                        break
                    }
                }
            } 
        }
        string {
            set validValues [getParameter -parameter $parameter -validValues]
            if {$validValues != ""} {
                if {[lsearch $validValues $value] == -1} {
                    set retCode $::TCL_ERROR
                }
            }
        }
        stringList {
            set validValues [getParameter -parameter $parameter -validValues]
            if {$validValues != ""} {
                foreach valueOfList $value {
                    if {[lsearch $validValues $valueOfList] == -1} {
                        set retCode $::TCL_ERROR
                    }
                }
            }
        }
        ipaddress {
            if {[testConfig::getTestConfItem protocolName] == "ip"} {
                if {![isIpAddressValid $value]} {
                    set retCode $::TCL_ERROR
                }
            }
        }        
        portlist {
            if {[isPortList $value] == 0} {
                set retCode $::TCL_ERROR
            }
        }
        default {
        }
    }

    if {[getParameter -parameter $parameter -validateProc] != ""} {
        foreach validateProc [getParameter -parameter $parameter -validateProc] {
            if {[info command "::$validateProc"] != ""} {
                set cmdLine "::$validateProc $value"
            } elseif {[info command "[namespace current]::$validateProc"] != ""} {
                set cmdLine "$validateProc $value"
            }

            if {[info exists cmdLine]} {

                set result [eval $cmdLine]

                if {$result != $::TCL_OK} {

                    if { $result == $::TCL_ERROR } {
            
                        setErrorString "Failed on $validateProc."
            
                    } else {
    
                        # If result is neither TCL_OK nor TCL_ERROR, it must contain a string of 
                        # error message.
                        #
                        setErrorString $result
                    }
                }
            }
        }
    }

    return $retCode
}

###############################################################################
#
# dataValidation::validateCommandParameter
#
# Description:  This command validate the parameters of the specified command.
#
# Input:        command   - name of the test commmand
#               parameter - name of the parameter
#               value     - value of the parameter
#
# Output:       TCL_OK if no error.
#               TCL_ERROR otherwise.
#
###############################################################################
proc dataValidation::validateCommandParameter {command parameter {value ""}} \
{
    variable booleanPattern
    set retCode $::TCL_OK

    set value         [$command cget    -$parameter]
    set parameterType [$command getType -$parameter]

    if {$parameterType == ""} {
        return $::TCL_ERROR
    }

    switch $parameterType {
        boolean {
            if {[regexp -nocase $booleanPattern $value] == 0} {
                set retCode $::TCL_ERROR
            }

        }
        integer -
        double {
            set retCode [areValuesOfTheType $parameterType $value]
            if {$retCode == $::TCL_OK} {
                set retCode [validateNumber $command $parameter $value]
            } 
        }
        integerList {
            set retCode [areValuesOfTheType $parameterType $value]        
            if {$retCode == $::TCL_OK} {
                foreach valueOfList $value {
                    set retCode [validateNumber $command $parameter $valueOfList]
                    if { $retCode == $::TCL_ERROR } {
                        break
                    }
                }
            } 
        }
        string {
            set validValues [$command getValidValues -$parameter]
            if {$validValues != ""} {
                if {[lsearch $validValues $value] == -1} {
                    set retCode $::TCL_ERROR
                }
            }
        }
        stringList {
            set validValues [$command getValidValues -$parameter]
            if {$validValues != ""} {
                foreach valueOfList $value {
                    if {[lsearch $validValues $valueOfList] == -1} {
                        set retCode $::TCL_ERROR
                        break
                    }
                }
            }
        }
        ipaddress {
            if {[testConfig::getTestConfItem protocolName] == "ip"} {
                if {![isIpAddressValid $value]} {
                    set retCode $::TCL_ERROR
                }
            }
        }
        portlist {
            if {[isPortList $value] == 0} {
                set retCode $::TCL_ERROR
            }
        }
        default {
        }
    }

    if {[$command getValidateProc -$parameter] != ""} {
        foreach validateProc [$command getValidateProc -$parameter] {
            if {[info command "::$validateProc"] != ""} {
                set cmdLine "::$validateProc $value"
            } elseif {[info command "[namespace current]::$validateProc"] != ""} {
                set cmdLine "$validateProc $value"
            }

            if {[info exists cmdLine]} {

                set result [eval $cmdLine]

                if {$result != $::TCL_OK} {

                    if { $result == $::TCL_ERROR } {

                        setErrorString "Failed on $validateProc."
            
                    } else {
    
                        # If result is neither TCL_OK nor TCL_ERROR, it must contain a string of 
                        # error message.
                        #
                        setErrorString $result
                        set retCode $::TCL_ERROR
                    }
                }
            }
        }
    }

    return $retCode
}

###############################################################################
#
# dataValidation::setErrorString
#
# Description:  
#
# Input:        
#
# Output:       
#
###############################################################################
proc dataValidation::setErrorString {line} {
    variable errorString

    set errorString $line
}

###############################################################################
#
# dataValidation::getErrorString
#
# Description:  
#
# Input:        
#
# Output:       
#
###############################################################################
proc dataValidation::getErrorString {} {
    variable errorString

    set retVal $errorString
    set errorString ""

    return $retVal
}

###############################################################################
#
# dataValidation::isDataInRange
#
# Description:  This command finds out if a given value is in the specified range.
#
# Input:        data - data to be checked.
#               range - the range to be checked against. Must be in the format of 
#                       {lowerLimit, upperLimit}.
#
# Output:       TCL_OK if yes. TCL_ERROR otherwise.
#
###############################################################################
proc dataValidation::isDataInRange {data range} \
{
    set retCode $::TCL_OK

    set lowerLimit [lindex $range 0]
    set upperLimit [lindex $range 1]

    if {    (($lowerLimit != "NULL") && ($data < $lowerLimit)) || \
            (($upperLimit != "NULL") && ($data > $upperLimit))} {
        set retCode $::TCL_ERROR
    }

    return $retCode
}

###############################################################################
#
# dataValidation::validatePortSpeed
#
# Description:  
#
# Input:        
#
# Output:       
#
###############################################################################
proc dataValidation::validatePortSpeed {args} \
{
    # puts "validating speed $args"
    return $::TCL_OK
}

###############################################################################
#
# dataValidation::getProtocol
#
# Description:  This command finds out available protocols.
#
# Input:        
#
# Output: protocol list      
#
###############################################################################
proc dataValidation::getProtocol {} \
{
    set protocolTable [imix cget -protocolTable]
    set protocolList {}
    foreach list $protocolTable {
        lappend protocolList [lindex $list 0]
    }

    return $protocolList
}

###############################################################################
#
# dataValidation::checkIdentical
#
# Description:  This command finds out if a given value is identical to others.
#               If it isn't, then add it to list.
#
# Input:        list      - available list
#               args      - args to be checked.    
#
# Output:       list      
#
###############################################################################
proc dataValidation::checkIdentical {list value} \
{
    set length [llength $list]
	set different 0

	if {$length == 0} {
		lappend list $value
		incr length
	}

	for {set index 0} {$index < $length} {incr index} {
		if {$value != [lindex $list $index]} {
			if {$index == [expr $length - 1]} {
				set different 1
			}
			continue
		} else {
			break
		}
	}

	if {$different == 1} {
		lappend list $value
	}

	return $list

}

###############################################################################
#
# dataValidation::checkMatched
#
# Description:  This command finds out if a given value is match to list.
#
# Input:    list    - available list
#           value   - value to be checked.   
#
# Output:  TCL_OK if yes. TCL_ERROR otherwise.      
#
###############################################################################
proc dataValidation::checkMatched {list value} \
{
    set retCode $::TCL_OK

    foreach arg $list {
        if {$arg == $value } {
            break
        } elseif {$arg != $value && $arg == [lindex $list end]} {
            set retCode $::TCL_ERROR
        }
    }
            
    return $retCode

}


###############################################################################
#
# dataValidation::frameSizeProtocolSame
#
# Description:  This command finds out if both frame size and protocol are same.
#
# Input:  args - args to be checked.      
#
# Output: TCL_OK if no. TCL_ERROR otherwise.     
#
###############################################################################
proc dataValidation::frameSizeProtocolSame {args} \
{
    set retCode $::TCL_OK
    set imixList [lindex $args 0]
    debugMsg "imixList: $imixList"
    set argsLength [llength $imixList]
    set frameSizeProtocolList {}

    foreach arg $imixList {
        set length [llength [lindex $arg 0]]
        if {$length == 1} {
            lappend frameSizeProtocolList [lindex $arg 0]
            lappend frameSizeProtocolList UDP
        } else {
            lappend frameSizeProtocolList [lindex [lindex $arg 0] 0]
            lappend frameSizeProtocolList [lindex [lindex $arg 0] 1]
        }
    }

    debugMsg "frameSizeProtocolList:$frameSizeProtocolList"

    for {set index1 0} {$index1 < [expr 2 * $argsLength]} {incr index1 0} {
        set frameSize1 [lindex $frameSizeProtocolList $index1]
        incr index1
        set protocol1 [lindex $frameSizeProtocolList $index1]
        incr index1
        for {set index2 $index1} {$index2 < [expr 2 * $argsLength]} {incr index2 0} {
            set frameSize2 [lindex $frameSizeProtocolList $index2]
            incr index2
            set protocol2 [lindex $frameSizeProtocolList $index2]
            incr index2

            if {$frameSize1 == $frameSize2} {
                if {[stringCompare -nocase $protocol1 $protocol2] == 0} {
                    logMsg "Invalid for both frame size $frameSize1 and $frameSize2 have same protocols"
                    set retCode $::TCL_ERROR
                    break
                }
            }
        }
        if {$retCode == $::TCL_ERROR} {
            break
        }
    }

    return $retCode
}


###############################################################################
#
# dataValidation::validateImixList
#
# Description:  This command finds out if a given imixList is valid.
#
# Input:  args - args to be checked. For example:
#                set list  {{{80     tcp           }         20} \
#                           { 74                             20} \
#                           {{570    udp           }         20} \
#                           {{81     aaa           }         20} \
#                           {570                             20}}     
#
# Output: TCL_OK if yes. TCL_ERROR otherwise.     
#
###############################################################################
proc dataValidation::validateImixList {args} \
{
	set retCode $::TCL_OK
    set sum 0
    set bandwidthList {}

    set imixList [lindex $args 0]
    debugMsg "imixList= $imixList"

    if [frameSizeProtocolSame $imixList] {
        set retCode $::TCL_ERROR 
        return $retCode
    } 

    foreach arg $imixList { 
        debugMsg "--------------------------------------------"
        debugMsg "arg:$arg"
        for {set index2 0} {$index2 < 2} {incr index2} {
            switch $index2 {
                0 {
                    set subArg [lindex $arg 0]
                    set len3 [llength $subArg]
                    for {set index3 0} {$index3 < $len3} {incr index3} {
                        set parameter [lindex $subArg $index3]
                        switch $index3 {
                            0 {
                                debugMsg "********** fs:$parameter ***********"
                                if {[isInteger $parameter] == 0} {
                                    debugMsg "fs:$parameter invalid which isnot an integer"
                                    set retCode $::TCL_ERROR
                                } elseif {$parameter < 0} {
                                    debugMsg "fs:$parameter invalid which is less than 0"
                                    set retCode $::TCL_ERROR
                                } elseif {$parameter <70} {
                                    set protocol [lindex $subArg 1]
                                    debugMsg "subArg=$subArg"
                                    debugMsg "protocol:$protocol"
                                    if {[stringCompare -nocase "Ethernet" $protocol] == 0} {
                                        debugMsg "fs:$parameter invalid which is less than 70 while using Ethernet"
                                        set retCode $::TCL_ERROR
                                    }
                                }
                            }
                            1 {
                                debugMsg "********** protocol:$parameter ***********"
                                set protocolList [getProtocol]
                                if {[checkMatched $protocolList $parameter] == 1} {
                                    debugMsg "protocol:$parameter invalid which doesnot match your protocol list"
                                    set retCode $::TCL_ERROR
                                }                             
                            }
                            2 {
                                debugMsg "********** precedence:$parameter ***********"
                                if {[isInteger $parameter] == 0} {
                                    debugMsg "precedence:$parameter invalid which isnot an integer"
                                    set retCode $::TCL_ERROR
                                } elseif {$parameter < 0} {
                                    debugMsg "precedence:$parameter invalid which is less than 0"
                                    set retCode $::TCL_ERROR
                                }                                   
                            }
                        }
                    }

                }
                1 {
                    set parameter [lindex $arg 1]
                    debugMsg "********** %bandwidth:$parameter ***********"
                    if {[isDouble $parameter] == 0} {
                        debugMsg "%bandwidth:$parameter invalid which isnot an integer or double"
                        set retCode $::TCL_ERROR
                    } elseif {$parameter < 0} {
                        debugMsg "%bandwidth:$parameter invalid which is less than 0"
                        set retCode $::TCL_ERROR
                    } elseif {[expr $sum + $parameter] > 100} {
                        debugMsg "%bandwidth:$parameter invalid which is more than [expr 100 - $sum]"
                        set retCode $::TCL_ERROR
                    } else {
                        set sum [expr $sum + $parameter]
                    }
                }
            }
        }
 
    }  
    debugMsg "--------------------------------------------"

	return $retCode
}

###############################################################################
#
# dataValidation::validateProtocolTable
#
# Description:  This command finds out if a given protocolTable List is valid.
#
# Input:   args: - protocolTable List. For example:
#                  protocolTable {{ tcp          tcp        0         0   } \
#                                 { http         tcp        1053     80   } \
#                                 { ftp          tcp        1054     21   } \
#                                 { dns          udp        1055     22   } \
#                                 { telnet       tcp        1056     23   } \
#                                 { test1        egp        1057     24   } \
#                                 { test2        icmp       1058     25   }}      
#
# Output:  TCL_OK if yes. TCL_ERROR otherwise.     
#
###############################################################################
proc dataValidation::validateProtocolTable {args} \
{
    set retCode $::TCL_OK
    debugMsg "protocol table: args= $args"
    set argsList [lindex $args 0]
    set len [llength $argsList]
    set yourProtocolList {}
    set standardProtocolList {http telnet ftp tcp udp icmp bgp ospf rsvp rvp ethernet}

    foreach arg $argsList { 
        debugMsg "--------------------------------------------"
        debugMsg "arg:$arg"
        for {set index 0} {$index < $len} {incr index} {
            set parameter [lindex $arg $index]
            switch $index {
                0 {
                    debugMsg "********** your protocol:$parameter **********"
                    set length [llength $yourProtocolList]
                    set yourProtocolList [checkIdentical $yourProtocolList $parameter]
                    if {$length == [llength $yourProtocolList]} { 
                        debugMsg "yourProtocol:$parameter invalid which is identical to others"
                        set retCode $::TCL_ERROR
                    }
                }
                1 {
                    debugMsg "********** protocol:$parameter ***********"
                    if {[checkMatched $standardProtocolList $parameter] == 1} {
                        debugMsg "Protocol:$parameter invalid which is not a standard protocol"
                        set retCode $::TCL_ERROR
                    }
                }
                2 {
                    debugMsg "********** srcPort:$parameter ***********"
                    if {[isInteger $parameter] == 0} {
                        debugMsg "srcPort:$parameter invalid which isnot an integer"
                        set retCode $::TCL_ERROR
                    } elseif {$parameter < 0} {
                        debugMsg "srcPort:$parameter invalid which is less than 0"
                        set retCode $::TCL_ERROR
                    }
                      
                    
                }
                3 {
                    debugMsg "********** destPort:$parameter **********"
                    if {[isInteger $parameter] == 0} {
                        debugMsg "destPort:$parameter invalid which isnot an integer"
                        set retCode $::TCL_ERROR
                    } elseif {$parameter < 0} {
                        debugMsg "destPort:$parameter invalid which is less than 0"
                        set retCode $::TCL_ERROR
                    }
                }
            }
     
        }
    }
    debugMsg "--------------------------------------------"

	return $retCode
}

###############################################################################
#
# dataValidation::validateCmFlowMix
#
# Description:  
#
# Input:        
#
# Output:       
#
###############################################################################
proc dataValidation::validateCmFlowMix {args} \
{
}

###############################################################################
#
# dataValidation::validateRunType
#
# Description:  
#
# Input:        
#
# Output:       
#
###############################################################################
proc dataValidation::validateRunType {args} \
{
}


###############################################################################
#
# dataValidation::validateNumber
#
# Description:  Validates a number that can be either integer or double.
#
# Input:  command   - name of the test commmand
#         parameter - name of the parameter
#         value     - value of the parameter
#
# Output: TCL_OK if yes. TCL_ERROR otherwise.     
#
###############################################################################
proc dataValidation::validateNumber {command parameter value} \
{
    set retCode $::TCL_OK

    set enumOrRange ""
    if { $command == "testConfig" } {
        set validValue [getParameter -parameter $parameter -validValues]
    } else {
        set validValue [$command getValidValues -$parameter]
    }

    if {$validValue != ""} {
        set enumOrRange enum
    } else {
        if { $command == "testConfig" } {
            set validValue [getParameter -parameter $parameter -validValues]
        } else {
            set validValue [$command getValidRange -$parameter]
        }

        if {$validValue != ""} {
            set enumOrRange range
        }
    }
                
    if {$enumOrRange == "enum"} {
        foreach elemOfValue $value {
            if {[lsearch $validValue $elemOfValue] == -1} {
                set retCode $::TCL_ERROR
                break
            }
        }
    } elseif {$enumOrRange == "range"} {
        foreach elemOfValue $value {
            set retCode [isDataInRange $elemOfValue $validValue]
                if {$retCode == $::TCL_ERROR} {
                break
            }
        }
    }
    
	return $retCode
}


###############################################################################
#
# dataValidation::checkErrFrameFrameErrorList
#
# Description:  This command validates frame error list for 2889 error frame test.
#
# Input:        framesize
#
# Output:       TCL_OK, if no error
#               Error string, otherwise
#
###############################################################################
proc dataValidation::checkErrFrameFrameErrorList { frameErrorList } \
{
 
    set retCode $::TCL_OK

    if { [llength $frameErrorList] == 0 } {

        set retCode "frameErrorList must not be empty.\nAt least one type of the frame sizes\nhave to be selected."

    } else {

        set frameSizeCount 0

        foreach item $frameErrorList {
            switch $item {
                undersize {
                    incr frameSizeCount [llength [errframe cget -undersizeList]]
                }
                oversize {
                    incr frameSizeCount [llength [errframe cget -oversizeList]]
                }
                default {
                    incr frameSizeCount [llength [errframe cget -framesizeList]]
                }
            }
        }

        if { $frameSizeCount == 0 } {
            set retCode "No valid frame sizes were selected\n\
                         for current framesize option(s)"
        }
    }

    return $retCode
}


###############################################################################
#
# dataValidation::checkCmatsIpAndMacAddress
#
# Description:  This command validates address of Cmats test.
#               The address of cableModem command can be either IP address and
#               MAC address. The last bit of the first byte has to be on if it
#               is MAC address. 
#
# Input:        address
#
# Output:       TCL_OK, if no error
#               Error string, otherwise
#
###############################################################################
proc dataValidation::checkCmatsIpAndMacAddress { address } \
{
    global currContext

    set retCode $::TCL_OK

    if {![isIpAddressValid $address]} {
        set retCode $::TCL_ERROR
    }

    if { $retCode == $::TCL_ERROR } {

        # The address is not IP address. Let's see if it is MAC address.

        if { [isMacAddressValid $address] == $::TCL_OK } {
    
            if { $currContext(testSubCat) == "eth01McastUpstream" || \
                    $currContext(testSubCat) == "eth01McastDownstream" } {

                # The last bit of the first byte has to be on.

                set firstByte [lindex [split $address] 0]
                if { [expr 0x$firstByte & 01] == 1 } {
                    set retCode $::TCL_OK
                }

            } else {
                set retCode $::TCL_OK
            }
        }
    }

    if { $retCode == $::TCL_ERROR } {
        set retCode "Valid IP or MAC address."

        if { $currContext(testSubCat) == "eth01McastUpstream" || \
                $currContext(testSubCat) == "eth01McastDownstream" } {
            append retCode "The last bit of the first byte has to be on for MAC address."
        }
    }

    return $retCode
}


##################################################################################
# Procedure: dataValidation::isValidMulticastIp
#
# Description: 
#   Helper proc to check if ipAddress is a valid IP by making sure it falls in the
#   range (224.0.0.0 - 239.255.255.255).
#
# Arguments(s):
#   ipAddress - IP address
#
# Returns:
#   $::TCL_OK, if is valid unicast IP address
#   Valid range, otherwise
#
##################################################################################
proc dataValidation::isValidMulticastIp {ipAddress} \
{
    set retCode "\(224.0.0.0 - 239.255.255.255\)"

    if {[isIpAddressValid $ipAddress]} {

        set multicastIpStartNum [ip2num "224.0.0.0"]
        set multicastIpEndNum   [ip2num "239.255.255.255"]
        set ipNum               [ip2num $ipAddress]

        if { ($ipNum >= $multicastIpStartNum) && ($ipNum <= $multicastIpEndNum) } {
            set retCode $::TCL_OK
        }
    }

    return $retCode
}


##################################################################################
# Procedure: dataValidation::isValidUnicastIp
#
# Description: 
#   Helper proc to check if ipAddress accomplied with the following
#       1) it is not 0.x.x.x
#       2) it is not 255.255.255.255
#       3) it is not loopback address (127.x.x.x)
#       4) it is not multicast address (224.0.0.0 - 239.255.255.255, i.e first 4 bits not 1110)
#       5) it is not reserved for future use (240.0.0.0 - 247.255.255.255)
#       6) it is invalid when it is < 1.0.0.0 or >= 224.0.0.0 on port
#
# Arguments(s):
#   ipAddress - IP address
#
# Returns:
#   $::true     if is valid unicast IP address
#   $::false    if is not valid unicast IP address
#
##################################################################################
proc dataValidation::isValidUnicastIp {ipAddress} \
{
    set valid $::false

    if {[isIpAddressValid $ipAddress]} {
        set valid $::true

        set multicastIpStartNum [ip2num "224.0.0.0"]
        set ipNum               [ip2num $ipAddress]
        
        if {([lindex [split $ipAddress .] 0] == 127) || ([lindex [split $ipAddress .] 0] == 255) || \
            ([lindex [split $ipAddress .] 0] == 0)} {
            set valid $::false
        }
                
        if { [mpexpr $ipNum >= $multicastIpStartNum] } {
            set valid $::false
        }
    }

    return $valid
}

##################################################################################
# Procedure: dataValidation::isOverlappingIpAddress
#
# Description: 
#   Helper proc to check if IP addresses are overlapping
#
# Arguments(s):
#   ipAddress1  - ipAddress to compare to
#   mask1       - net mask
#   ipAddress2  - ipAddress to compare to
#   mask2       - net mask
#
# Returns:
#   $::true     - if overlapping
#   $::false    - if not overlapping
#
##################################################################################
proc dataValidation::isOverlappingIpAddress {ipAddress1 count1 ipAddress2 count2} \
{
    set overlap $::false

    set firstIp1 [ip2num $ipAddress1]
    set lastIp1  [mpexpr $firstIp1 + $count1 - 1]

    set firstIp2 [ip2num $ipAddress2]
    set lastIp2  [mpexpr $firstIp2 + $count2 - 1] 
 
    if {($firstIp1 <= $firstIp2 && $firstIp2 <= $lastIp1) || \
        ($firstIp1 <= $lastIp2 && $lastIp2 <= $lastIp1)} {
        set overlap $::true
    }           

    if {($firstIp2 <= $firstIp1 && $firstIp1 <= $lastIp2) || \
        ($firstIp2 <= $lastIp1 && $lastIp1 <= $lastIp2)} {
        set overlap $::true
    } 

    return $overlap
}

##################################################################################
# Procedure: dataValidation::isSameSubnet
#
# Description: 
#   Helper proc to check if ports in two different user profiles are in the same subnet.
#   Note that all ports in one user porfile are in the same subnet.
#
# Arguments(s):
#   ipAddr1 - ipAddress to compare to
#   mask1   - net mask
#   ipAddr2 - ipAddress to compare to
#   mask2   - net mask
#
# Returns:
#   $::true if in same subnet
#   $::false if not in same subnet
#
##################################################################################
proc dataValidation::isSameSubnet {ipAddr1 mask1 ipAddr2 mask2} \
{
    set retCode $::true

    set range1Subnet    [num2ip [expr [ip2num $ipAddr1] & [ip2num $mask1]]]
    set range2Subnet    [num2ip [expr [ip2num $ipAddr2] & [ip2num $mask2]]]

    if {[string compare $range1Subnet $range2Subnet] != 0} {
        set retCode $::false
    } 

    return $retCode
}


##################################################################################
# Procedure: dataValidation::isValidNetMask
#
# Description: 
#   Helper proc to check if net mask is valid. i.e. In binary form, the mask must 
#   have consecutive 1's followed by consecutive 0's
#
# Arguments(s):
#   mask - net mask
#
# Returns:
#   $::true     - if valid mask
#   $::false    - if not valid mask
#
##################################################################################
proc dataValidation::isValidNetMask {mask} \
{
    set valid $::false

    if {[isIpAddressValid $mask]} {
        set numMask [ip2num $mask]

        if {![catch {expr fmod(0x80000000, ($numMask ^ 0xffffffff) +1)} value] && $value == 0} {
            set valid $::true
        }            
    }

    return $valid
}

##################################################################################
# Procedure: dataValidation::isValidHostPart
#
# Description: 
#   Helper proc to check if ipAddress is valid within the net mask
#               The host bits cannot be all 0s or 1s
#
# Arguments(s):
#   ipAddress - IP address, net mask
#
# Returns:
#   $::true     if is valid IP address within net mask
#   $::false    if is not valid IP address within net mask
#
##################################################################################
proc dataValidation::isValidHostPart {ipAddress mask} \
{
    set valid $::false

    if {[isValidUnicastIp $ipAddress] && [isValidNetMask $mask]} {

        set ipNum       [ip2num $ipAddress]
        set maskNum     [ip2num $mask]

        set valid  [expr ((1 + $ipNum) & (~$maskNum)) > 1]
    }

    return $valid
}


