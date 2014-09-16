# dial.tcl --
#
# This file defines the default bindings for Tk dial widgets and provides
# procedures that help in implementing the bindings.
#
# Copyright (c) 1998-2001 Jeffrey Hobbs
#
# RCS: @(#) $Id: dial.tcl,v 1.4 2001/12/07 21:26:31 hobbs Exp $
#
# See the file "license.terms" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
#
# Based on tkTurndial-2.0b package:
# Copyright (c) 1995 Marco Beijersbergen (beijersb@rulhm1.leidenuniv.nl)
# 
# Based upon scale.tcl of the tk4.0b4 package:
#   Copyright (c) 1994 The Regents of the University of California.
#   Copyright (c) 1994-1995 Sun Microsystems, Inc.
#

namespace eval ::vu::dial {}

#-------------------------------------------------------------------------
# The code below creates the default class bindings for dials.
#-------------------------------------------------------------------------

bind Dial <Enter> {
    if {$tk_strictMotif} {
	set ::vu::Priv(activeBg) [%W cget -activebackground]
	%W config -activebackground [%W cget -background]
    }
    ::vu::dial::Activate %W %x %y
}
bind Dial <Motion> {
    ::vu::dial::Activate %W %x %y
}
bind Dial <Leave> {
    if {$tk_strictMotif} {
	%W config -activebackground $::vu::Priv(activeBg)
    }
    if {[%W cget -state] == "active"} {
	%W configure -state normal
    }
}
bind Dial <1> {
    ::vu::dial::ButtonDown %W %x %y
}
bind Dial <B1-Motion> {
    ::vu::dial::Drag %W %x %y
}
bind Dial <B1-Leave> { }
bind Dial <B1-Enter> { }
bind Dial <ButtonRelease-1> {
    ::vu::CancelRepeat
    ::vu::dial::EndDrag %W
    ::vu::dial::Activate %W %x %y
}
bind Dial <2> {
    ::vu::dial::ButtonDown %W %x %y
}
bind Dial <B2-Motion> {
    ::vu::dial::Drag %W %x %y
}
bind Dial <B2-Leave> { }
bind Dial <B2-Enter> { }
bind Dial <ButtonRelease-2> {
    ::vu::CancelRepeat
    ::vu::dial::EndDrag %W
    ::vu::dial::Activate %W %x %y
}
bind Dial <Control-1> {
    ::vu::dial::ControlPress %W %x %y
}
bind Dial <Up> {
    ::vu::dial::Increment %W up little noRepeat
}
bind Dial <Down> {
    ::vu::dial::Increment %W down little noRepeat
}
bind Dial <Left> {
    ::vu::dial::Increment %W up little noRepeat
}
bind Dial <Right> {
    ::vu::dial::Increment %W down little noRepeat
}
bind Dial <Control-Up> {
    ::vu::dial::Increment %W up big noRepeat
}
bind Dial <Control-Down> {
    ::vu::dial::Increment %W down big noRepeat
}
bind Dial <Control-Left> {
    ::vu::dial::Increment %W up big noRepeat
}
bind Dial <Control-Right> {
    ::vu::dial::Increment %W down big noRepeat
}
bind Dial <Home> {
    %W set [%W cget -from]
}
bind Dial <End> {
    %W set [%W cget -to]
}

# ::vu::dial::Activate --
# This procedure is invoked to check a given x-y position in the
# dial and activate the dial if the x-y position falls within
# the dial.
#
# Arguments:
# w -		The dial widget.
# x, y -	Mouse coordinates.

proc ::vu::dial::Activate {w x y} {
    if {[$w cget -state] == "disabled"} {
	return
    }
    if {[$w identify $x $y] == "dial"} {
	if {[string compare "active" [$w cget -state]]} {
	    $w configure -state active
	}
    } else {
	if {[string compare "normal" [$w cget -state]]} {
	    $w configure -state normal
	}
    }
}

# ::vu::dial::ButtonDown --
# This procedure is invoked when a button is pressed in a dial.  It
# takes different actions depending on where the button was pressed.
#
# Arguments:
# w -		The dial widget.
# x, y -	Mouse coordinates of button press.

proc ::vu::dial::ButtonDown {w x y} {
    variable ::vu::Priv
    set Priv(dragging) 0
    set el [$w identify $x $y]
    if {$el == "left"} {
	Increment $w up little initial
    } elseif {$el == "right"} {
	Increment $w down little initial
    } elseif {$el == "dial"} {
	set Priv(dragging) 1
	set Priv(initValue) [$w get]
	$w set [$w get $x $y]
    }
}

# ::vu::dial::Drag --
# This procedure is called when the mouse is dragged with
# mouse button 1 down.  If the drag started inside the dial
# (i.e. the dial is active) then the dial's value is adjusted
# to reflect the mouse's position.
#
# Arguments:
# w -		The dial widget.
# x, y -	Mouse coordinates.

proc ::vu::dial::Drag {w x y} {
    variable ::vu::Priv
    if {![info exists Priv(dragging)] || !$Priv(dragging)} {
	return
    }
    $w set [$w get $x $y]
}

# ::vu::dial::EndDrag --
# This procedure is called to end an interactive drag of the
# dial.  It just marks the drag as over.
#
# Arguments:
# w -		The dial widget.

proc ::vu::dial::EndDrag {w} {
    variable ::vu::Priv
    set Priv(dragging) 0
}

# ::vu::dial::Increment --
# This procedure is invoked to increment the value of a dial and
# to set up auto-repeating of the action if that is desired.  The
# way the value is incremented depends on the "dir" and "big"
# arguments.
#
# Arguments:
# w -		The dial widget.
# dir -		"up" means move value towards -from, "down" means
#		move towards -to.
# big -		Size of increments: "big" or "little".
# repeat -	Whether and how to auto-repeat the action:  "noRepeat"
#		means don't auto-repeat, "initial" means this is the
#		first action in an auto-repeat sequence, and "again"
#		means this is the second repetition or later.

proc ::vu::dial::Increment {w dir big repeat} {
    variable ::vu::Priv
    if {$big == "big"} {
	set inc [$w cget -bigincrement]
	if {$inc == 0} {
	    set inc [expr {abs([$w cget -to] - [$w cget -from])/10.0}]
	}
	if {$inc < [$w cget -resolution]} {
	    set inc [$w cget -resolution]
	}
    } else {
	set inc [$w cget -resolution]
    }
    if {([$w cget -from] > [$w cget -to]) ^ ($dir == "up")} {
	set inc [expr {-$inc}]
    }
    $w set [expr {[$w get] + $inc}]

    if {$repeat == "again"} {
	set Priv(afterId) [after [$w cget -repeatinterval] \
		[namespace code [list Increment $w $dir $big again]]]
    } elseif {$repeat == "initial"} {
	set Priv(afterId) [after [$w cget -repeatdelay] \
		[namespace code [list Increment $w $dir $big again]]]
    }
}

# ::vu::dial::ControlPress --
# This procedure handles button presses that are made with the Control
# key down.  Depending on the mouse position, it adjusts the dial
# value to one end of the range or the other.
#
# Arguments:
# w -		The dial widget.
# x, y -	Mouse coordinates where the button was pressed.

proc ::vu::dial::ControlPress {w x y} {
    set el [$w identify $x $y]
    if {$el == "left"} {
	$w set [$w cget -from]
    } elseif {$el == "right"} {
	$w set [$w cget -to]
    }
}
