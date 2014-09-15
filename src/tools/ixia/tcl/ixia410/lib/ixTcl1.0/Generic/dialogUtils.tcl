##################################################################################
# Version 4.10    $Revision: 22 $
# $Author: Mgithens $
#
# $Workfile: dialogUtils.tcl $
#
#    Copyright © 1997 - 2005 by IXIA
#    All Rights Reserved.
#
#    Revision Log:
#    03-12-2001    DS    Genesis
#
# Description: Contains miscellaneous dialog for transmit/pause dialog procedures.
#
##################################################################################

proc createDialog {dialogName {window textDialog}} \
{
    dialogUtils::create $dialogName $window
}

proc writeDialog {dialogText {window textDialog}} \
{
    dialogUtils::writeText $dialogText $window
}

proc destroyDialog {{window textDialog}} \
{
    dialogUtils::destroy $window
}


#######################################################################
#
# Procedure:    dialogUtils
# Description:  
# Argument(s):
# Results:
#
#######################################################################
namespace eval dialogUtils {} \
{
    variable state  [advancedTestParameter cget -dialogState]
}

########################################################################
# Procedure: dialogUtils::init
#
# Description: This command doesn't do anything, just want to source this  
# file when it is called.
#
########################################################################
proc dialogUtils::init {} \
{
}

########################################################################
# Procedure: dialogUtils::create
#
# This command creates a dialog box of name "dialogName"
#
########################################################################
proc dialogUtils::create {dialogName window} \
{
    variable state

    set retCode $::TCL_OK

    set window .$window

    if {$state != "destroyedByUser"} {
        if [regexp -nocase wish [file tail [info nameofexecutable]]] {

            if {[winfo exists $window] == 0} {
                toplevel     $window -class Dialog
                wm resizable $window 0 1
                wm withdraw  $window
                wm title     $window $dialogName

                text $window.text -width 40 -wrap word -yscrollcommand "$window.textScroll set"

                # unix didn't look nice, so just set a different font here..
                if {[isUNIX]} {
                    createNamedFont application arial 7
                    $window.text config -font application
                }

                scrollbar $window.textScroll -command "$window.text yview"

                grid $window.text       -row 0 -column 0 -sticky snew
                grid $window.textScroll -row 0 -column 1 -sticky sn
                grid rowconfigure    $window 0 -weight 1
                grid columnconfigure $window 0 -weight 1

                wm geometry  $window 270x100+100+100
                wm protocol  $window WM_DELETE_WINDOW "dialogUtils::destroyedByUser $window"

                if {$state == "normal"} {
                    wm deiconify $window
                } else {
                    wm iconify $window
                }
            } else {
                $window.text delete 0.0 end
            }
        }
    }
    return $retCode
}


########################################################################
# Procedure: dialogUtils::writeText
#
# This command writes to a dialog box of name "window"
#
########################################################################
proc dialogUtils::writeText {dialogText window} \
{
    set window .$window

    if [catch {
            $window.text insert end "$dialogText\n"
            $window.text see end
            update
        } err] {
        ixPuts $dialogText
    }
}

########################################################################
# Procedure: dialogUtils::getWindowState
#
# This command gets the state the dialog box of name "window"
#
########################################################################
proc dialogUtils::getWindowState {window} \
{
    set windowState .$window

    if [catch {wm state $windowState} state] {
        set state   destroyedByUser
    }

    return $state
}

########################################################################
# Procedure: dialogUtils::setWindowState
#
# This command sets the state variable for the dialog box
#
########################################################################
proc dialogUtils::setWindowState {newState} \
{
    variable state

    set state $newState

    return $state
}


########################################################################
# Procedure: dialogUtils::saveWindowState
#
# This command save the static state to bring the dialog back up in next time
#
########################################################################
proc dialogUtils::saveWindowState {window} \
{    
    setWindowState [getWindowState $window]
}


########################################################################
# Procedure: dialogUtils::destroyedByUser
#
# This command destroys the dialog box of name "window"
#
########################################################################
proc dialogUtils::destroyedByUser {window} \
{
    catch {::destroy $window}
    setWindowState destroyedByUser
}


########################################################################
# Procedure: dialogUtils::destroy
#
# This command destroys the dialog box of name "dialogName"
#
########################################################################
proc dialogUtils::destroy {window} \
{    
    saveWindowState $window

    set window .$window
    catch {::destroy $window}
}
