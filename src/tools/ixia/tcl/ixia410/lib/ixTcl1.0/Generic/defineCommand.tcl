##################################################################################
# Version 4.10	$Revision: 33 $
# $Author: Mgithens $
#
# $Workfile: defineCommand.tcl $ - Define Command handling test
#
#   Copyright © 1997 - 2005 by IXIA
#   All Rights Reserved.
#
# Revision Log:
# 12-13-1999	DS	Genesis
#
# Description: This file contains the commands for all the tests. When a new test
# is added, create a new proc for that test here.
#
##################################################################################



########################################################################################
# Namespace: defineCommand
#
# Description: This namespace is used to initialize the defineCommand commands
#
########################################################################################
namespace eval defineCommand {} \
{
    variable commands
    variable commandList
    
    set      commandList               {}
    set      commands(config)          {}
    set      commands(cget)            {}
    set      commands(show)            {}
    set      commands(setDefault)      {}

    set      commands(getType)         {}
    set      commands(getValidRange)   {}
    set      commands(getValidValues)  {}
    set      commands(getValidateProc) {}
    set      commands(getHelp)         {}
}

########################################################################################
# Procedure: initializeDefineCommand
#
# Description: This command is used to initialize the defineCommand commands
#
########################################################################################
proc initializeDefineCommand {} \
{
    defineCommand::initialize
}

########################################################################################
# Procedure: defineCommand::initialize
#
# Description: This command is used to initialize the defineCommand commands
#
########################################################################################
proc defineCommand::initialize {} \
{
    set retCode 0

    # once we get this one registered, then we can use its methods
    registerCommand defineCommand
    registerMethod defineCommand registerCommand
    registerMethod defineCommand registerMethod

    # now that we have registered the registerMethod, we can use it for the other methods
    defineCommand registerMethod defineCommand isRegistered
    defineCommand registerMethod defineCommand registerParameter

    return $retCode
}


########################################################################################
# Procedure: defineCommand::isRegistered
#
# Description: This command checks to see if a command is registered
#
########################################################################################
proc defineCommand::isRegistered {testCmd} \
{
    set retCode 0

    if [catch {$testCmd exists} retCode] {
        set retCode 0
    }
    return [expr $retCode]
}

########################################################################################
# Procedure: defineCommand::getAllRegisteredCommands
#
# Description: This command gets the Tcl command list
#
########################################################################################
proc defineCommand::getAllRegisteredCommands { } \
{
    set retCode 0

    variable commandList

    return $commandList
}

########################################################################################
# Procedure: defineCommand::registerCommand
#
# Description: This command registers a new Tcl command
#
########################################################################################
proc defineCommand::registerCommand {testCmd} \
{
    set retCode 0

    global   defineCommandParms
    variable commands
    variable commandList


    if [isRegistered $testCmd] {
        debugMsg "registerCommand: $testCmd is already registered"
        set retCode 1
    } else {

        lappend commandList $testCmd

        set parmArray   [format %sParms $testCmd]
        set methodArray [format %sMethods $testCmd]
        global $parmArray $methodArray
       
        #define namespace for testCmd
        #NOTE: Not defined variable here, may define them in proc testCmd::setDefault later.
        #      Defined results and dataVerify namespaces twice in two files. 
        #      Defined tclClient and advancedTestParameter namespaces which we may not need.
        #      We need modify those later.
        namespace eval ::$testCmd {} {
        }
         
        # assign global parms automatically on registration
        foreach parm [array names defineCommandParms] {
            set ${parmArray}($parm)   $defineCommandParms($parm)
        }
        foreach command [array names commands] {
            set ${methodArray}($command)    $commands($command)
        }
        set cmdLine "proc ::$testCmd \{\{method_name \{\}\} \{args \{\}\}\} \{return \[parseCmd $testCmd \$method_name args\]\}"
        eval $cmdLine

        # create the default set of methods
        foreach command [array names commands] {
            registerMethod $testCmd $command
        }
    }

    return $retCode
}


########################################################################################
# Procedure:   defineCommand::registerMethod
#
# Description: This command registers a new method for this Tcl command
#
# Arguments:   
#
# Results:     0 if succeeded. 1 otherwise.
#
########################################################################################
proc defineCommand::registerMethod {testCmd method {parameterList {}}} \
{
    set retCode 0

    if {![isRegistered $testCmd]} {
        puts "$testCmd is not yet registered, registering method failed."
        set retCode 1
    } else {
        set methodArray [format %sMethods $testCmd]

        global $methodArray

        set method_name [format "%s_%s" $testCmd $method]

        if [info exists ${methodArray}($method)] {
            foreach parm $parameterList {
                if {[lsearch [eval set ${methodArray}($method)] $parm] == -1} {
                    lappend ${methodArray}($method) $parm
                }
            }
        } else {
            set ${methodArray}($method)     $parameterList
        }

        if [catch {info body $method_name}] {
            if {$method == "setDefault"} {
                set defaultArray    [format %sDefaultVals $testCmd]
                set cmdLine "proc \:\:$testCmd\:\:$method \{\{args \{\}\}\} \{global $defaultArray; \
                        foreach name \[array names ${defaultArray}\] { \
                        $testCmd config -\$name  \$${defaultArray}(\$name); \
                    }; \
                    return 0\}"
                eval $cmdLine
            }
        }
    }
    return $retCode
}


########################################################################################
# Procedure: defineCommand::registerParameter
#
# Description: This command registers a new parameter for this Tcl command
#
# Arguments:   args - must be in the following format.
#                       -command      command      \
#                       -parameter    parameter    \
#                       -type         type         \
#                       -defaultValue defaultValue \
#                       -validValues  validValues  \
#                       -validRange   validRange   \
#                       -validateProc validateProc \
#                       -access       access
#                     where -command, -parameter, and -type are mandatory.
#
# Results:     0 if succeeded. 1 otherwise.
#
########################################################################################
proc defineCommand::registerParameter {args} \
{
    set retCode 0
    
    #
    # If the argument comes in as a list. Take away the curly braces around it.
    #
    if {[regexp {^\{} $args]} {
        regsub -all {(^{|}$)} $args "" args
    }

    #
    # This one is different in that the args could contain multiple -validateProc.
    #
    set validateProcArg {}

    foreach arg $args {

        if {[regexp {^-[a-zA-Z].+} $arg]} {
            #
            # Current argument is preceeded by '-'.
            #
            switch -- $arg {
                "-command"       -
                "-parameter"     -
                "-type"          -
                "-defaultValue"  -
                "-validValues"   -
                "-validRange"    -
                "-validateProc"  -
                "-access"        -
                "-help" {
                    set currentOption [string trimleft $arg -]
                    set currentAction getValue
                }
                default {
                    set retCode 1
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
                        set retCode 1
                        break
                    }
                }
            } else {
                set retCode 1
                break
            }
        }
    }

    if {$retCode == 0} {
        #
        # Test command name, parameter name, and parameter type are mandatory when
        # registring a test parameter.
        #
        if {[info exists commandArg] == 0} {

            set retCode 1
        
        } elseif {[info exists parameterArg] == 0} {
        
            set retCode 1
        
        } elseif {[info exists typeArg] == 0} {

            set retCode 1

        } elseif {[info exists validValuesArg] && [info exists validRangeArg]} {

            set retCode 1

        }
    }

    if {$retCode == 1} {
        puts "Invalid arguments: \"$args\"."
        return $retCode
    }

    if {![isRegistered $commandArg]} {
        puts "$commandArg is not yet registered, registering parameter failed."
        set retCode 1
    } else {

        if {[info exists defaultValueArg] == 0} {
            set defaultValueArg 0
        }

        #
        # $parmArray         - contains the values defined by the option -parameter
        # $methodArray       - contains the values defined by the option -command
        # $validateArray     - contains the values defined by the option -validValues
        # $defaultArray      - contains the values defined by the option -defaultValue
        # $validRangeArray   - contains the values defined by the option -validRange
        # $validateProcArray - contains the values defined by the option -validateProc
        # $typeArray         - contains the values defined by the option -type
        # $helpArray         - contains the values defined by the option -help
        #
        set parmArray         ${commandArg}Parms
        set methodArray       ${commandArg}Methods
        set validateArray     ${commandArg}ConfigVals
        set defaultArray      ${commandArg}DefaultVals
        set validRangeArray   ${commandArg}ValidRange
        set validateProcArray ${commandArg}ValidateProc
        set typeArray         ${commandArg}Type
        set helpArray         ${commandArg}Help

        global $parmArray $methodArray $validateArray $defaultArray
        global $validRangeArray $validateProcArray $typeArray $helpArray

        foreach parm $parameterArg {
            set ${parmArray}($parm)    $defaultValueArg
            set ${defaultArray}($parm) $defaultValueArg
        }

        if {[info exists access] == 0} {
            set access rw
        }

        switch $access {
            r {
                defineCommand registerMethod $commandArg cget   $parameterArg
            }
            w {
                defineCommand registerMethod $commandArg config $parameterArg
            }
            wr -
            default {
                defineCommand registerMethod $commandArg cget   $parameterArg
                defineCommand registerMethod $commandArg config $parameterArg
            }
        }

        if {[info exists validValuesArg] && ($validValuesArg != "")} {
            foreach parm $parameterArg {
                set ${validateArray}($parm) $validValuesArg
            }
        }

        if {[info exists validRangeArg]} {
            foreach parm $parameterArg {
                set ${validRangeArray}($parm) $validRangeArg
            }
        }

        if {[info exists validateProcArg]} {
            foreach parm $parameterArg {
                set ${validateProcArray}($parm) $validateProcArg
            }
        }

        if {[info exists typeArg]} {
            foreach parm $parameterArg {
                set ${typeArray}($parm) $typeArg
            }
        }

        if {[info exists helpArg]} {
            foreach parm $parameterArg {
                set ${helpArray}($parm) $helpArg
            }
        }
    }

    return $retCode
}
