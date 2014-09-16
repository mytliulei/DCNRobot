#
# $Id: tile.tcl,v 1.104 2006/12/13 17:05:25 jenglish Exp $
#
# Tile widget set initialization script.
#

namespace eval tile {}		;# Old namespace, being phased out
namespace eval ttk {}		;# New official namespace

### Source library scripts.
#

namespace eval tile {
    if {![info exists library]} {
	variable library [file dirname [info script]]
    }
}

source [file join $tile::library keynav.tcl]
source [file join $tile::library fonts.tcl]
source [file join $tile::library cursors.tcl]
source [file join $tile::library icons.tcl]
source [file join $tile::library utils.tcl]

### Deprecated aliases.
#

## ttk::deprecated $old $new --
#	Define $old command as a deprecated alias for $new command
#	$old and $new must be fully namespace-qualified.
#
proc ttk::deprecated {old new} {
    interp alias {} $old {} ttk::do'deprecate $old $new
}
## do'deprecate --
#	Implementation procedure for deprecated commands --
#	issue a warning (once), then re-alias old to new.
#
proc ttk::do'deprecate {old new args} {
    deprecated'warning $old $new
    interp alias {} $old {} $new
    uplevel 1 [linsert $args 0 $new]
}

## deprecated'warning --
#	Gripe about use of deprecated commands. 
#
proc ttk::deprecated'warning {old new} {
    puts stderr "$old deprecated -- use $new instead"
}

### Backward compatibility:
#

## 0.7.X compatibility: renamed in 0.8.0 
#
ttk::deprecated ::ttk::paned		::ttk::panedwindow
ttk::deprecated ::tile::availableThemes	::ttk::themes
ttk::deprecated ::tile::setTheme	::ttk::setTheme
#Not yet: ttk::deprecated ::style	::ttk::style
interp alias {} ::style {} ::ttk::style

ttk::deprecated ::tile::defineImage	::ttk::defineImage
ttk::deprecated ::tile::stockIcon	::ttk::stockIcon

ttk::deprecated ::tile::CopyBindings	::ttk::copyBindings

### Exported routines:
#
namespace eval ttk {

    namespace export style

    # All widget constructor commands are exported:
    variable widgets {
	button checkbutton radiobutton menubutton label entry
	frame labelframe scrollbar
	notebook progressbar combobox separator 
	panedwindow treeview sizegrip
	scale
    }

    variable wc
    foreach wc $widgets  {
	namespace export $wc
    }
}

### ttk::ThemeChanged --
#	Called from [style theme use].
#	Sends a <<ThemeChanged>> virtual event to all widgets.
#
proc ttk::ThemeChanged {} {
    set Q .
    while {[llength $Q]} {
	set QN [list]
	foreach w $Q {
	    event generate $w <<ThemeChanged>>
	    foreach child [winfo children $w] {
		lappend QN $child
	    }
	}
	set Q $QN
    }
}

### Public API.
#

## ttk::themes --
#	Return list of themes registered in the package database.
#
proc ttk::themes {} {
    set themes [list]

    foreach pkg [lsearch -inline -all -glob [package names] ttk::theme::*] {
	lappend themes [lindex [split $pkg :] end]
    }

    return $themes
}

## ttk::setTheme $theme --
#	Set the current theme to $theme, loading it if necessary.
#
proc ttk::setTheme {theme} {
    variable currentTheme
    if {[lsearch [style theme names] $theme] < 0} {
	package require ttk::theme::$theme
    }
    style theme use $theme
    set currentTheme $theme
}

### Load widget bindings.
#
source [file join $tile::library button.tcl]
source [file join $tile::library menubutton.tcl]
source [file join $tile::library scrollbar.tcl]
source [file join $tile::library scale.tcl]
source [file join $tile::library progress.tcl]
source [file join $tile::library notebook.tcl]
source [file join $tile::library paned.tcl]
source [file join $tile::library entry.tcl]
source [file join $tile::library combobox.tcl]	;# dependency: entry.tcl
source [file join $tile::library treeview.tcl]
source [file join $tile::library sizegrip.tcl]
source [file join $tile::library dialog.tcl]

## Label and Labelframe bindings:
#  (not enough to justify their own file...)
#
bind TLabelframe <<Invoke>>	{ ttk::traverseTo [tk_focusNext %W] }
bind TLabel <<Invoke>>		{ ttk::traverseTo [tk_focusNext %W] }

### Load settings for built-in themes:
#
proc ttk::LoadThemes {} {
    variable ::tile::library

    # "default" always present:
    uplevel #0 [list source [file join $library defaults.tcl]] 

    set builtinThemes [style theme names]
    foreach {theme script} {
	classic 	classicTheme.tcl
	alt 		altTheme.tcl
	clam 		clamTheme.tcl
	winnative	winTheme.tcl
	xpnative	xpTheme.tcl
	aqua 		aquaTheme.tcl
    } {
	if {[lsearch -exact $builtinThemes $theme] >= 0} {
	    uplevel #0 [list source [file join $library $script]]
	}
    }
}

ttk::LoadThemes; rename ::ttk::LoadThemes {}

### Select platform-specific default theme:
#
# Notes: 
#	+ On OSX, aqua theme is the default
#	+ On Windows, xpnative takes precedence over winnative if available.
#	+ On X11, users can use the X resource database to
#	  specify a preferred theme (*TkTheme: themeName);
#	  otherwise "default" is used.
#

proc ttk::DefaultTheme {} {
    set preferred [list aqua xpnative winnative]

    set userTheme [option get . tkTheme TkTheme]
    if {$userTheme != {} && ![catch {
	uplevel #0 [list package require ttk::theme::$userTheme]
    }]} {
	return $userTheme
    }

    foreach theme $preferred {
	if {[package provide ttk::theme::$theme] != ""} {
	    return $theme
	}
    }
    return "default"
}

ttk::setTheme [ttk::DefaultTheme] ; rename ttk::DefaultTheme {}

#*EOF*
