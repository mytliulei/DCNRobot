#
# $Id: stepTheme.tcl,v 1.28 2006/11/06 02:30:49 jenglish Exp $
#
# Appearance settings for "Step" theme.
#

namespace eval ttk::theme::step {

    variable colors ; array set colors {
	-frame		"#a0a0a0"
	-activebg	"#aeb2c3"
	-selectbg	"#fdcd00"
	-disabledfg	"#808080"
	-trough		"#c3c3c3"
    }

    namespace import -force ::ttk::style
    style theme settings step {

	style configure "." \
	    -background 	$colors(-frame) \
	    -foreground 	black \
	    -troughcolor 	$colors(-trough) \
	    -selectbackground 	$colors(-selectbg) \
	    -font  		TkDefaultFont \
	    ;

	style map "." \
	    -foreground [list disabled $colors(-disabledfg)] \
	    -background [list {active !disabled} $colors(-activebg)] \
	    ;

	style configure TButton -padding "3m 0" -relief raised -shiftrelief 1
	style map TButton -relief {
	    {pressed !disabled} 	sunken
	    {active !disabled} 	raised
	}

	style configure TCheckbutton \
	    -indicatorrelief groove \
	    -indicatorcolor $colors(-frame) \
	    -borderwidth 2 -padding 2
	style map TCheckbutton \
	    -indicatorrelief {pressed ridge} \
	    -indicatorcolor  [list active $colors(-activebg)]

	style configure TRadiobutton -indicatorcolor $colors(-frame) -padding 2
	style map TRadiobutton -indicatorrelief [list pressed sunken] 

	style configure TMenubutton -padding "3 3" -relief raised

	style configure TEntry \
	    -relief sunken -borderwidth 1 -padding 1 -font TkTextFont

	style configure TLabelframe -borderwidth 2 -relief groove

	style map TScrollbar -relief { pressed sunken  {} raised }
	style map TScrollbar -background \
	    [list  disabled $colors(-frame)  active $colors(-activebg)] ;

	style configure TProgressbar \
	    -borderwidth 1 \
	    -background $colors(-activebg) \
	    -stripecolor $colors(-selectbg) \
	    -thickness 10 -stripethickness 8 -period 50 ;

	style configure TScale \
	    -borderwidth 1 -groovewidth 4 -troughrelief sunken

	style configure TNotebook.Tab \
	    -padding {10 3} -background $colors(-frame)
	style map TNotebook.Tab \
	    -padding [list selected {12 6 12 3}] \
	    -background [list \
	    	selected $colors(-frame) \
		active $colors(-activebg)] \
	    ;
    }
}
