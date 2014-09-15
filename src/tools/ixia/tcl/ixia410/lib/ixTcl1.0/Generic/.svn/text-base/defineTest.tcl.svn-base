##################################################################################
# Version 4.10	$Revision: 25 $
# $Author: Mgithens $
#
# $Workfile: defineTest.tcl $
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

namespace eval defineTest {} \
{
    variable defaultParms
    variable defaultParmType
    variable defaultCommands

#   moved parameter:numtrials to proc defineTest::registerCommand.
#   set defaultParms(numtrials)		        1
    set defaultParms(duration)		        20
    set defaultParms(waitResidual)		    2
    set defaultParms(testName) 		        ""
    set defaultParms(framesize)		        64
    set defaultParms(framesizeList)		    {}


#   set defaultParmType(numtrials)	        integer
    set defaultParmType(duration)	        integer
    set defaultParmType(waitResidual)	    integer
    set defaultParmType(testName) 	        string
    set defaultParmType(framesize) 	        integer
    set defaultParmType(framesizeList)      integerList

    set defaultCommands(config)             [array names defaultParms]
    set defaultCommands(cget)               [array names defaultParms]
    set defaultCommands(registerResultVars) {}
    set defaultCommands(start)              {}
}

########################################################################################
# Procedure: initializeDefineTest
#
# Description: This command is used to initialize the defineTest commands
#
########################################################################################
proc initializeDefineTest {} \
{
    defineTest::initialize
}

########################################################################################
# Procedure: defineTest::initialize
#
# Description: This command is used to initialize the defineTest commands
#
########################################################################################
proc defineTest::initialize {} \
{
    set retCode 0

    defineCommand registerCommand defineTest
    defineCommand registerMethod  defineTest registerCommand
    defineCommand registerMethod  defineTest registerParameter
    defineCommand registerMethod  defineTest registerTest

    return $retCode
}


########################################################################################
# Procedure: defineTest::registerCommand
#
# Description: This command registers a new Tcl test command
#
########################################################################################
proc defineTest::registerCommand {testCmd} \
{
    variable defaultParms
    variable defaultParmType
    variable defaultCommands

    set retCode 0

    defineCommand registerCommand $testCmd

    # assign global parms automatically on registration
    foreach parm [array names defaultParms] {
        defineCommand registerParameter -command $testCmd -parameter $parm -defaultValue $defaultParms($parm) -type $defaultParmType($parm)
    }

    defineTest registerParameter -command $testCmd -parameter numtrials      -defaultValue 1                 -type integer -validRange  {1 NULL}
    defineTest registerParameter -command $testCmd -parameter staggeredStart -defaultValue notStaggeredStart -type string  -validValues {staggeredStart notStaggeredStart true false}
    defineTest registerParameter -command $testCmd -parameter framesize      -defaultValue 64                -type integer 
    defineTest registerParameter -command $testCmd -parameter framesizeList  -defaultValue {}                -type integerList

    foreach method [array names defaultCommands] {
        defineCommand registerMethod $testCmd $method $defaultCommands($method)
    }

    return $retCode
}


########################################################################################
# Procedure: defineTest::registerParameter
#
# Description: This command registers a new parameter for this Tcl test command
#
########################################################################################
proc defineTest::registerParameter {args} \
{
    return [defineCommand registerParameter $args]
}


########################################################################################
# Procedure: defineTest::registerTest 
#
# Description: This command registers a new test (start command) for this Tcl command
#
########################################################################################
proc defineTest::registerTest  {testCmd testSubCmd {testSubCmdParameterList ""}} \
{
    return [defineCommand registerMethod $testCmd start $testSubCmd]
}

