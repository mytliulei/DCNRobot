############################################################
# Copyright (c) Ixia 2004-2005
# All rights reserved
#
# DESCRIPTION:
# This file provides methods used to generate GUI 
# for TrafficTester.
#
############################################################

namespace eval stpConvergenceGUI {};

#####################################################################
# stpConvergenceGUI::runParamsContent
# 
# DESCRIPTION:
# This content table contains a list of FRAMES and/or ELEMENTS which 
# represent the graphical content of the Run Parameters frame on the 
# Test Setup tab.  The content table MUST start with either a FRAMES 
# block or an ELEMENTS block.  ELEMENT blocks are contained within 
# ELEMENTS blocks.  Depending on the gemoetry manager in use by a FRAME, 
# extra container frames may be needed.
#  
###
set stpConvergenceGUI::runParamsContent {
    { FRAMES {
        { FRAME {
            { NAME  left }
            { LABEL "" }
                { FRAMES {

                    { FRAME {
                        { NAME  duration }
                        { LABEL "Duration" }
                        { FRAMES {                  
                            { FRAME {
                                { NAME  invisibleDuration }
                                { LABEL "" }
                                { ELEMENTS {
                                { ELEMENT {
                                    { NAME              duration }
                                    { WIDGET_CLASS      PropertyDuration }
                                    { ROW               1 }
                                    { COLUMN            0 }
                                } </ELEMENT> }
                                } </ELEMENTS> }
                            } </FRAME> }
                        } </FRAMES> }
                        { FILL            x }
                    } </FRAME> }

                    { FRAME {
                        { NAME  testParams }
                        { LABEL "Test Parameters" }
                        { FRAMES {              
                            { FRAME {
                                { NAME  invisibleTestParams }
                                { LABEL "" }
                                { ELEMENTS {
                                { ELEMENT {
                                    { NAME              numtrials }
                                    { WIDGET_CLASS      PropertyInt }
                                    { ROW               0 }
                                    { STICKY            e }
                                    { COLUMN            0 }
                                    { LABEL_WIDTH       20 }
                                    { PADX 10 }
                                } </ELEMENT> }
                                { ELEMENT {
                                    { NAME              percentMaxRate }
                                    { WIDGET_CLASS      PropertyFloat }
                                    { STICKY            e }
                                    { LABEL_WIDTH       20 }
                                    { ROW               1 }
                                    { COLUMN            0 }
                                    { PADX 10 }
                                } </ELEMENT> }
                                } </ELEMENTS> }
                            } </FRAME> }
                        } </FRAMES> }
                        { FILL            x }
                    } </FRAME> }
                    { FRAME {
                            { NAME  passFail }
                            { LABEL "Pass Criteria" }
                            { FRAMES {              
                                { FRAME {
                                    { NAME  invisibleTestParams }
                                    { LABEL "" }

                            { ELEMENTS {
                            { ELEMENT { 
                                { NAME              enablePassFail }
                                { WIDGET_CLASS      PropertyBoolean }
                                { ROW               0 }
                                { COLUMN            3 }
                                { STICKY            e }
                                { LABEL_WIDTH       10 }
                            } </ELEMENT> }
                            { ELEMENT { 
                                { NAME              passTimeValue }
                                { WIDGET_CLASS      PropertyFloat }
                                { ROW               1 }
                                { COLUMN            1 }
                                { STICKY            e }
                                { LABEL_WIDTH       0 }
                                { ENTRY_WIDTH       11 }
                                { PADX              5 }
                            } </ELEMENT> }
                            { ELEMENT { 
                                { NAME              timeUnit }
                                { WIDGET_CLASS      PropertyEnumString }
                                { ROW               1 }
                                { COLUMN            2 }
                                { STICKY            e }
                                { LABEL_WIDTH       0 }
                                { PADX              5 }
                            } </ELEMENT> }
                            } </ELEMENTS> } 

                                } </FRAME> }
                            } </FRAMES> }
                            { FILL            x }

                    } </FRAME> }
                } </FRAMES> }
                { SIDE             left }
                { FILL             both }
                { EXPAND           n } 
        } </FRAME> }

        { FRAME {
            { NAME  right }
            { LABEL "" }
            { FRAMES {
                { FRAME {
                    { NAME  stpParameters }
                    { LABEL "STP Parameters" }
                    { FRAMES {
                        { FRAME {
                            { NAME  stpParamsInvisible }
                            { LABEL "" }
                            { ELEMENTS {
                                { ELEMENT { 
                                            { NAME              macPerPort }
                                            { WIDGET_CLASS      PropertyInt }
                                            { LABEL_WIDTH       0 }
                                            { ROW               1 }
                                            { COLUMN            0 }
                                            { STICKY            w }
                                            { LABEL_WIDTH       30 }
                                            { ENTRY_WIDTH       8 }
                                } </ELEMENT> }
                                { ELEMENT { 
                                            { NAME              convergenceCause }
                                            { WIDGET_CLASS      PropertyEnumString }
                                            { LABEL_WIDTH       0 }
                                            { ROW               2 }
                                            { COLUMN            0 }
                                            { STICKY            w }
                                            { LABEL_WIDTH       30 }
                                            { ENTRY_WIDTH       20 }
                                } </ELEMENT> }
                                { ELEMENT { 
                                            { NAME              bridgingProtocol }
                                            { WIDGET_CLASS      PropertyEnumString }
                                            { LABEL_WIDTH       0 }
                                            { ROW               3 }
                                            { COLUMN            0 }
                                            { STICKY            w }
                                            { LABEL_WIDTH       30 }
                                            { ENTRY_WIDTH       20 }
                                } </ELEMENT> }
                                { ELEMENT { 
                                            { NAME              measurementType }
                                            { WIDGET_CLASS      PropertyEnumString }
                                            { LABEL_WIDTH       0 }
                                            { ROW               4 }
                                            { COLUMN            0 }
                                            { STICKY            w }
                                            { LABEL_WIDTH       30 }
                                            { ENTRY_WIDTH       20 }
                                } </ELEMENT> }
                                { ELEMENT { 
                                            { NAME              rootPriority }
                                            { WIDGET_CLASS      PropertyEnumString }
                                            { LABEL_WIDTH       0 }
                                            { ROW               5 }
                                            { COLUMN            0 }
                                            { STICKY            w }
                                            { LABEL_WIDTH       30 }
                                            { ENTRY_WIDTH       20 }
                                } </ELEMENT> }
                                { ELEMENT { 
                                            { NAME              rootMacAddress }
                                            { WIDGET_CLASS      PropertyEntryString }
                                            { LABEL_WIDTH       0 }
                                            { ROW               6 }
                                            { COLUMN            0 }
                                            { STICKY            w }
                                            { LABEL_WIDTH       30 }
                                            { ENTRY_WIDTH       16 }
                                } </ELEMENT> }
                                { ELEMENT { 
                                            { NAME              helloInterval }
                                            { WIDGET_CLASS      PropertyInt }
                                            { LABEL_WIDTH       0 }
                                            { ROW               7 }
                                            { COLUMN            0 }
                                            { STICKY            w }
                                            { LABEL_WIDTH       30 }
                                            { ENTRY_WIDTH       8 }
                                } </ELEMENT> }
                                { ELEMENT { 
                                            { NAME              maxAge }
                                            { WIDGET_CLASS      PropertyInt }
                                            { LABEL_WIDTH       0 }
                                            { ROW               8 }
                                            { COLUMN            0 }
                                            { STICKY            w }
                                            { LABEL_WIDTH       30 }
                                            { ENTRY_WIDTH       8 }
                                } </ELEMENT> }
                                { ELEMENT { 
                                            { NAME              forwardDelay }
                                            { WIDGET_CLASS      PropertyInt }
                                            { LABEL_WIDTH       0 }
                                            { ROW               9 }
                                            { COLUMN            0 }
                                            { STICKY            w }
                                            { LABEL_WIDTH       30 }
                                            { ENTRY_WIDTH       8 }
                                } </ELEMENT> }
                            } </ELEMENTS> } 
                            { ANCHOR            w }
                        } </FRAME> }
                    } </FRAMES> }
                    { FILL            x }
                } </FRAME> }
            } </FRAMES> }
            { SIDE             left }
            { FILL             both }
            { EXPAND           n }
        } </FRAME> }
    } </FRAMES> }
}


#####################################################################
# stpConvergenceGUI::trafficContent
# 
# DESCRIPTION:
# This content table contains a list of FRAMES and/or ELEMENTS which 
# represent the graphical content of the invisible container frame on the 
# Traffic Setup tab.  The content table MUST start with either a FRAMES 
# block or an ELEMENTS block.  ELEMENT blocks are contained within ELEMENTS
# blocks.  Depending on the gemoetry manager in use by a FRAME, extra container 
# frames may be needed.
#  
###
set stpConvergenceGUI::trafficContent {
     { FRAMES {
	{ FRAME {
	    { NAME              x }
	    { GEOMGR            place }
	    { LABEL             "" }
	    { EXPAND            y }
	    { FILL              both }
	    { ELEMENTS {
		{ ELEMENT { 
		    { NAME              frameSizeWidget }
		    { WIDGET_CLASS      PropertyFrameSize }
		    { X                 0 }
		    { Y                 0 }
		    { HEIGHT            300 }
		    { WIDTH             400 }
		} </ELEMENT> }
		{ ELEMENT { 
		    { NAME              trafficMapWidget }
		    { WIDGET_CLASS      PropertyTrafficMap }
		    { X                 400 }
		    { Y                 0 }
		    { HEIGHT            300 }
		    { WIDTH             400 }
		} </ELEMENT> }
	    } </ELEMENTS> }
	} </FRAME> }
    } </FRAMES> }
}


