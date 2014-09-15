############################################################
# Copyright (c) Ixia 2004-2005
# All rights reserved
#
# DESCRIPTION:
# This file provides methods used to generate GUI 
# for TrafficTester.
#
############################################################

namespace eval ospfConvergenceGUI {};

#####################################################################
# ospfConvergenceGUI::runParamsContent
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
set ospfConvergenceGUI::runParamsContent {
    { FRAMES {
	{ FRAME {
	    { NAME  left }
	    { LABEL "" }
	    { FRAMES {
		{ FRAME {
		    { NAME  testParams }
		    { LABEL "Test Parameters" }
		    { ELEMENTS {
			{ ELEMENT {
			    { NAME              numtrials }
			    { WIDGET_CLASS      PropertyInt }
			    { ROW               0 }
			    { COLUMN            0 }
			    { STICKY            w }
			    { PADX 10 }
			    { LABEL_WIDTH       22 }
			} </ELEMENT> }
			{ ELEMENT {
			    { NAME              percentMaxRate }
			    { WIDGET_CLASS      PropertyFloat }
			    { ROW               0 }
			    { COLUMN            1 }
			    { STICKY            w }
			    { LABEL_WIDTH       30 }
			    { PADX 10 }
			} </ELEMENT> }
			{ ELEMENT {
			    { NAME              areaId }
			    { WIDGET_CLASS      PropertyInt }
			    { ROW               0 }
			    { COLUMN            2 }
			    { STICKY            w }
			    { LABEL_WIDTH       18 }
			    { PADX 10 }
			} </ELEMENT> }
			{ ELEMENT {
			    { NAME              numberOfFlaps }
			    { WIDGET_CLASS      PropertyInt }
			    { ROW               1 }
			    { COLUMN            0 }
			    { STICKY            w }
			    { LABEL_WIDTH       22 }
			    { PADX 10 }
			} </ELEMENT> }
			{ ELEMENT {
			    { NAME              transmitDurationBetweenFlaps }
			    { WIDGET_CLASS      PropertyFloat }
			    { ROW               2 }
			    { COLUMN            1 }
			    { LABEL_WIDTH       30 }
			    { STICKY            w }
			    { COLSPAN           2 }
			    { PADX 10 }
			} </ELEMENT> }
			{ ELEMENT {
			    { NAME              dutProcessingDelay }
			    { WIDGET_CLASS      PropertyFloat }
			    { ROW               1 }
			    { COLUMN            1 }
			    { STICKY            w }
			    { LABEL_WIDTH       30 }
			    { PADX 10 }
			} </ELEMENT> }
			{ ELEMENT {
			    { NAME              transmitTimeout }
			    { WIDGET_CLASS      PropertyFloat }
			    { ROW               1 }
			    { COLUMN            2 }
			    { STICKY            w }
			    { LABEL_WIDTH       18 }
			    { PADX 10 }
			} </ELEMENT> }
			{ ELEMENT {
			    { NAME              networkType }
			    { WIDGET_CLASS      PropertyEnumString }
			    { ROW               2 }
			    { COLUMN            0 }
			    { STICKY            w }
			    { LABEL_WIDTH       22 }
			    { ENTRY_WIDTH       12 }
			    { PADX 10 }
			} </ELEMENT> }
		    } </ELEMENTS> }
		    { FILL            x }
		} </FRAME> }
		{ FRAME {
		    { NAME  mtuFrame }
		    { LABEL "MTU Parameters" }
		    { FRAMES {
			{ FRAME {
			    { NAME  mtuFrameInvisible }
			    { LABEL "" }

			    { ELEMENTS {
				{ ELEMENT {
				    { NAME              enableValidateMtu }
				    { WIDGET_CLASS      PropertyBoolean }
				    { ROW               0 }
				    { COLUMN            0 }
				    { STICKY            e }
				    { PADX 10 }
				} </ELEMENT> }
				{ ELEMENT {
				    { NAME              interfaceMTUSize }
				    { WIDGET_CLASS      PropertyInt }
				    { ROW               0 }
				    { COLUMN            1 }
				    { STICKY            e }
				    { PADX 10 }
				} </ELEMENT> }
			    } </ELEMENTS> }
			    { SIDE            left }
			} </FRAME> }
		    } </FRAMES> }
		    { FILL            x }
		} </FRAME> }
		{ FRAME {
		    { NAME trafficPatternFrame }
		    { LABEL "Traffic Pattern" }
		    { FRAMES {
			{ FRAME {
			    { NAME  trafficPatternFrameInvisible }
			    { LABEL "" }
			    { ELEMENTS {
				{ ELEMENT {
				    { NAME              enableOspfV2SummaryLsa }
				    { WIDGET_CLASS      PropertyBoolean }
				    { ROW               0 }
				    { COLUMN            0 }
				    { STICKY            w }
				    { PADX 10 }
				} </ELEMENT> }
				{ ELEMENT {
				    { NAME              numOspfV2SummaryLsa }
				    { WIDGET_CLASS      PropertyInt }
				    { ROW               0 }
				    { COLUMN            1 }
				    { ENTRY_WIDTH       7 }
				    { STICKY            w }
				    { PADX 10 }
				} </ELEMENT> }
				{ ELEMENT {
				    { NAME              flapOspfV2SummaryLsa }
				    { WIDGET_CLASS      PropertyBoolean }
				    { ROW               0 }
				    { COLUMN            2 }
				    { STICKY            w }
				    { PADX 10 }
				} </ELEMENT> }
				{ ELEMENT {
				    { NAME              enableOspfV2ExternalLsa }
				    { WIDGET_CLASS      PropertyBoolean }
				    { ROW               1 }
				    { COLUMN            0 }
				    { STICKY            w }
				    { PADX 10 }
				} </ELEMENT> }
				{ ELEMENT {
				    { NAME              numOspfV2ExternalLsa }
				    { WIDGET_CLASS      PropertyInt }
				    { ROW               1 }
				    { COLUMN            1 }
				    { ENTRY_WIDTH       7 }
				    { STICKY            w }
				    { PADX 10 }
				} </ELEMENT> }
				{ ELEMENT {
				    { NAME              flapOspfV2ExternalLsa }
				    { WIDGET_CLASS      PropertyBoolean }
				    { ROW               1 }
				    { COLUMN            2 }
				    { STICKY            w }
				    { PADX 10 }
				} </ELEMENT> }
				{ ELEMENT {
				    { NAME              enableOspfV2RouterLsa }
				    { WIDGET_CLASS      PropertyBoolean }
				    { ROW               2 }
				    { COLUMN            0 }
				    { STICKY            w }
				    { PADX 10 }
				} </ELEMENT> }
				{ ELEMENT {
				    { NAME              numOspfV2RouterLsa }
				    { WIDGET_CLASS      PropertyInt }
				    { ROW               2 }
				    { COLUMN            1 }
				    { ENTRY_WIDTH       7 }
				    { STICKY            w }
				    { PADX 10 }
				} </ELEMENT> }
				{ ELEMENT {
				    { NAME              flapOspfV2RouterLsa }
				    { WIDGET_CLASS      PropertyBoolean }
				    { ROW               2 }
				    { COLUMN            2 }
				    { STICKY            w }
				    { PADX 10 }
				} </ELEMENT> }
				{ ELEMENT {
				    { NAME              enableOspfV3InterAreaPrefixLsa }
				    { WIDGET_CLASS      PropertyBoolean }
				    { ROW               3 }
				    { COLUMN            0 }
				    { STICKY            w }
				    { PADX 10 }
				} </ELEMENT> }
				{ ELEMENT {
				    { NAME              numOspfV3InterAreaPrefixLsa }
				    { WIDGET_CLASS      PropertyInt }
				    { ROW               3 }
				    { COLUMN            1 }
				    { ENTRY_WIDTH       7 }
				    { STICKY            w }
				    { PADX 10 }
				} </ELEMENT> }
				{ ELEMENT {
				    { NAME              flapOspfV3InterAreaPrefixLsa }
				    { WIDGET_CLASS      PropertyBoolean }
				    { ROW               3 }
				    { COLUMN            2 }
				    { STICKY            w }
				    { PADX 10 }
				} </ELEMENT> }
				{ ELEMENT {
				    { NAME              enableOspfV3ExternalLsa }
				    { WIDGET_CLASS      PropertyBoolean }
				    { ROW               4 }
				    { COLUMN            0 }
				    { STICKY            w }
				    { PADX 10 }
				} </ELEMENT> }
				{ ELEMENT {
				    { NAME              numOspfV3ExternalLsa }
				    { WIDGET_CLASS      PropertyInt }
				    { ROW               4 }
				    { COLUMN            1 }
				    { ENTRY_WIDTH       7 }
				    { STICKY            w }
				    { PADX 10 }
				} </ELEMENT> }
				{ ELEMENT {
				    { NAME              flapOspfV3ExternalLsa }
				    { WIDGET_CLASS      PropertyBoolean }
				    { ROW               4 }
				    { COLUMN            2 }
				    { STICKY            w }
				    { PADX 10 }
				} </ELEMENT> }
				{ ELEMENT {
				    { NAME              enableOspfV3RouterLsa }
				    { WIDGET_CLASS      PropertyBoolean }
				    { ROW               5 }
				    { COLUMN            0 }
				    { STICKY            w }
				    { PADX 10 }
				} </ELEMENT> }
				{ ELEMENT {
				    { NAME              numOspfV3RouterLsa }
				    { WIDGET_CLASS      PropertyInt }
				    { ROW               5 }
				    { COLUMN            1 }
				    { ENTRY_WIDTH       7 }
				    { STICKY            w }
				    { PADX 10 }
				} </ELEMENT> }
				{ ELEMENT {
				    { NAME              flapOspfV3RouterLsa }
				    { WIDGET_CLASS      PropertyBoolean }
				    { ROW               5 }
				    { COLUMN            2 }
				    { STICKY            w }
				    { PADX 10 }
				} </ELEMENT> }
			    } </ELEMENTS> }
			    { SIDE            left }
			} </FRAME> }
		    } </FRAMES> }
		    { FILL            x }
		} </FRAME> }
		{ FRAME {
		    { NAME  delayFrame }
		    { LABEL "Advertise Delay Parameters" }
		    { FRAMES {
			{ FRAME {
			    { NAME  delayFrameInvisible }
			    { LABEL "" }
			    { ELEMENTS {
				{ ELEMENT {
				    { NAME              advertiseDelayPerRoute }
				    { WIDGET_CLASS      PropertyFloat }
				    { PADX 10 }
				    { LABEL_WIDTH       25 }
				    { ENTRY_WIDTH       6 }
				    { STICKY            w }
				    { ROW               0 }
				    { COLUMN            0 }
				} </ELEMENT> }
				{ ELEMENT {
				    { NAME              totalDelay }
				    { WIDGET_CLASS      PropertyEntryString }
				    { STATE             disabled }
				    { PADX 10 }
				    { LABEL_WIDTH       25 }
				    { STICKY            w }
				    { ROW               0 }
				    { COLUMN            1 }
				} </ELEMENT> }			
			    } </ELEMENTS> }
			    { SIDE            left }
			} </FRAME> }
		    } </FRAMES> }
		    { FILL            x }
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
                                    { ROW               1 }
                                    { COLUMN            5 }
                                } </ELEMENT> }
				{ ELEMENT { 
				    { NAME              advertiseThresholdValue }
				    { WIDGET_CLASS      PropertyFloat }
				    { LABEL_WIDTH       0 }
				    { ROW               1 }
				    { COLUMN            0 }
				} </ELEMENT> }
				{ ELEMENT { 
				    { NAME              withdrawThresholdValue }
				    { WIDGET_CLASS      PropertyFloat }
				    { LABEL_WIDTH       0 }
				    { ROW               2 }
				    { COLUMN            0 }
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
# ospfConvergenceGUI::trafficContent
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
set ospfConvergenceGUI::trafficContent {
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


