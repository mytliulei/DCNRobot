#################################################################
#
#   Copyright © 1997 - 2004 by IXIA
#   All Rights Reserved.
#
# Description: gui file for test "RouterConvergence"
#
#################################################################


namespace eval routeConvergenceGUI {}

#####################################################################
# routeConvergenceGUI::runParamsContent
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
set routeConvergenceGUI::runParamsContent {
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
				{ ROW               0 }
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
                { NAME invisible1 }
                { LABEL ""}
                { ELEMENTS {
                { ELEMENT {
                    { NAME              numtrials }
                    { WIDGET_CLASS      PropertyInt }
                    { ROW               0 }
                    { COLUMN            0 }
                    { STICKY            w }
                    { PADX 10 }
                    { LABEL_WIDTH       24 }
                } </ELEMENT> }
                { ELEMENT {
                    { NAME              percentMaxRate }
                    { WIDGET_CLASS      PropertyFloat }
                    { ROW               0 }
                    { COLUMN            1 }
                    { STICKY            w }
                    { LABEL_WIDTH       14 }
                    { PADX 10 }
                } </ELEMENT> }
                { ELEMENT {
                    { NAME              areaId }
                    { WIDGET_CLASS      PropertyInt }
                    { ROW               1 }
                    { COLUMN            0 }
                    { STICKY            w }
                    { LABEL_WIDTH       24 }
                    { PADX 10 }
                } </ELEMENT> }
				{ ELEMENT {
                    { NAME              numberOfFlaps }
                    { WIDGET_CLASS      PropertyInt }
                    { ROW               2 }
                    { COLUMN            0 }
                    { STICKY            w }
                    { LABEL_WIDTH       24 }
                    { PADX 10 }
                } </ELEMENT> }
				{ ELEMENT {
                    { NAME              dutProcessingDelay }
                    { WIDGET_CLASS      PropertyFloat }
                    { ROW               3 }
                    { COLUMN            0 }
                    { STICKY            w }
                    { LABEL_WIDTH       24 }
                    { PADX 10 }
                } </ELEMENT> }
                { ELEMENT {
                    { NAME              networkType }
                    { WIDGET_CLASS      PropertyEnumString }
                    { ROW               4 }
                    { COLUMN            0 }
                    { STICKY            w }
                    { LABEL_WIDTH       24 }
                    { ENTRY_WIDTH       12 }
                    { PADX 10 }
                } </ELEMENT> }
				} </ELEMENTS> }
            } </FRAME> }
            { FRAME {
                { NAME invisible2 }
                { LABEL "" }
                { ELEMENTS {
                    { ELEMENT {
                        { NAME              enableValidateMtu }
                        { WIDGET_CLASS      PropertyBoolean }
                        { ROW               1 }
                        { COLUMN            0 }
                        { STICKY            w }
                        { PADX 10 }
                    } </ELEMENT> }
                    { ELEMENT {
                        { NAME              interfaceMTUSize }
                        { WIDGET_CLASS      PropertyInt }
                        { ROW               1 }
                        { COLUMN            1 }
                        { STICKY            w }
                        { PADX 10 }
                    } </ELEMENT> }
                } </ELEMENTS> }
            } </FRAME> }
            } </FRAMES> }
		    { FILL            x }
		} </FRAME> }
		{ FRAME {
		    { NAME  ospfFrame }
		    { LABEL "Advertised Parameters" }
            { FRAMES {
            { FRAME {
                { NAME invisible 3 }
                { LABEL "" }
                { ELEMENTS {
                { ELEMENT {
                    { NAME              networkIpAddress }
                    { WIDGET_CLASS      PropertyEntryString }
                    { PADX 10 }
                    { LABEL_WIDTH       25 }
                    { ENTRY_WIDTH       15 }
                    { STICKY            w }
                    { ROW               0 }
                    { COLUMN            0 }
                } </ELEMENT> }
                { ELEMENT {
                    { NAME              prefixLength }
                    { WIDGET_CLASS      PropertyEnumString }
                    { PADX 10 }
                    { LABEL_WIDTH       25 }
                    { ENTRY_WIDTH       6 }
                    { STICKY            w }
                    { ROW               1 }
                    { COLUMN            0 }
                } </ELEMENT> }
                { ELEMENT {
                    { NAME              numberOfRoutes }
                    { WIDGET_CLASS      PropertyFloat }
                    { PADX 10 }
                    { LABEL_WIDTH       25 }
                    { ENTRY_WIDTH       6 }
                    { STICKY            w }
                    { ROW               2 }
                    { COLUMN            0 }
                } </ELEMENT> }
                { ELEMENT {
                    { NAME              advertiseDelayPerRoute }
                    { WIDGET_CLASS      PropertyFloat }
                    { PADX 10 }
                    { LABEL_WIDTH       25 }
                    { ENTRY_WIDTH       8 }
                    { STICKY            w }
                    { ROW               3 }
                    { COLUMN            0 }
                } </ELEMENT> }
                { ELEMENT {
                    { NAME              totalDelay }
                    { WIDGET_CLASS      PropertyEntryString }
                    { STATE             disabled }
                    { PADX 10 }
                    { LABEL_WIDTH       25 }
                    { STICKY            w }
                    { ROW               4 }
                    { COLUMN            0 }
                } </ELEMENT> }			
                } </ELEMENTS> }
            } </FRAME> }
            } </FRAMES> }
            { FILL            x }
            { ANCHOR            w }
		} </FRAME> }
		{ FRAME {
		    { NAME  passFail }
		    { LABEL "Pass Criteria" }
		    { FRAMES {
			{ FRAME {
			    { NAME  passFailInvisible2 }
			    { LABEL "" }
			    { ELEMENTS {
                    { ELEMENT { 
                        { NAME              enablePassFail }
                        { WIDGET_CLASS      PropertyBoolean }
                        { LABEL_WIDTH       10 }
                        { ROW               0 }
                        { COLUMN            3 }
                    } </ELEMENT> }
				{ ELEMENT { 
				    { NAME              convergenceTime }
				    { WIDGET_CLASS      PropertyFloat }
				    { LABEL_WIDTH       0 }
				    { ROW               1 }
				    { COLUMN            0 }
				} </ELEMENT> }
				{ ELEMENT { 
				    { NAME              convergenceType }
				    { WIDGET_CLASS      PropertyRadio }
				    { LABEL_WIDTH       0 }
				    { ROW               1 }
				    { COLUMN            1 }
				} </ELEMENT> }
				} </ELEMENTS> } 
			    { ANCHOR            w }
			} </FRAME> }
		    } </FRAMES> }
		    { FILL            x }
		} </FRAME> }
	    } </FRAMES> }
	    { ANCHOR   w }
	    { FILL     none }
	    { EXPAND   n }
	} </FRAME> }
    } </FRAMES> }
}


#####################################################################
# routeConvergenceGUI::trafficContent
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
set routeConvergenceGUI::trafficContent {
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
		    { NAME              frameDataWidget }
		    { WIDGET_CLASS      PropertyFrameData }
		    { X                 0 }
		    { Y                 300 }
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


