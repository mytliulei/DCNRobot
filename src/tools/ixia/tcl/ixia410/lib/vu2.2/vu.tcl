# vu.tcl --
#
# Global runtime file for vu widget extension.
#
# Copyright (c) 1998-2001 Jeffrey Hobbs
#
# RCS: @(#) $Id: vu.tcl,v 1.4 2001/12/07 21:26:13 hobbs Exp $

namespace eval ::vu {
    variable Priv
    array set Priv {}

    set dir [file dirname [info script]]
    # combobox.tcl - not yet finished
    set files [list dial.tcl]
    if {[info tclversion] < 8.4} {
	# in 8.4 core
	lappend files spinbox.tcl
    } else {
	# only works for 8.4a2+
	lappend files panedwindow.tcl
    }
    foreach file $files {
	set file [file join $dir $file]
	if {[file exists $file]} {
	    namespace inscope :: [list source $file]
	}
    }
    namespace export -clear {[a-z]*}
}

# ::vu::CancelRepeat --
# A copy of tkCancelRepeat, just in case it's not available or changes.
# This procedure is invoked to cancel an auto-repeat action described
# by ::vu::Priv(afterId).  It's used by several widgets to auto-scroll
# the widget when the mouse is dragged out of the widget with a
# button pressed.
#
# Arguments:
# None.

proc ::vu::CancelRepeat {} {
    variable Priv
    if {[info exists Priv(afterId)]} {
	after cancel $Priv(afterId)
	set Priv(afterId) {}
    }
}

# ::vu::GetSelection --
#   Copy of ::tk::GetSelection
#   This tries to obtain the default selection.  On Unix, we first try
#   and get a UTF8_STRING, a type supported by modern Unix apps for
#   passing Unicode data safely.  We fall back on the default STRING
#   type otherwise.  On Windows, only the STRING type is necessary.
# Arguments:
#   w	The widget for which the selection will be retrieved.
#	Important for the -displayof property.
#   sel	The source of the selection (PRIMARY or CLIPBOARD)
# Results:
#   Returns the selection, or an error if none could be found
#
if {[string equal $tcl_platform(platform) "unix"]} {
    proc ::vu::GetSelection {w {sel PRIMARY}} {
	if {[catch {selection get -displayof $w -selection $sel \
		-type UTF8_STRING} txt] \
		&& [catch {selection get -displayof $w -selection $sel} txt]} {
	    return -code error "could not find default selection"
	} else {
	    return $txt
	}
    }
} else {
    proc ::vu::GetSelection {w {sel PRIMARY}} {
	if {[catch {selection get -displayof $w -selection $sel} txt]} {
	    return -code error "could not find default selection"
	} else {
	    return $txt
	}
    }
}
