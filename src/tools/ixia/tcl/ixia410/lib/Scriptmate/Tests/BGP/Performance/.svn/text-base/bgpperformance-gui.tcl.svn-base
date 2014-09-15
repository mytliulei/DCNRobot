############################################################
# Copyright (c) Ixia 2004-2005
# All rights reserved
#
# DESCRIPTION:
# This file provides methods used to generate GUI 
# for bgpPerformance.
#
############################################################

namespace eval bgpPerformanceGUI {};

#####################################################################
# bgpPerformanceGUI::runParamsContent
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
set bgpPerformanceGUI::runParamsContent {
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
		        { ELEMENT {
		            { NAME              tolerance }
		            { WIDGET_CLASS      PropertyFloat }
		            { STICKY            e }
		            { LABEL_WIDTH       20 }
		            { ROW               2 }
		            { COLUMN            0 }
		            { PADX 10 }
		        } </ELEMENT> }
                        { ELEMENT {
                            { NAME              delayTime }
                            { WIDGET_CLASS      PropertyInt }
                            { STICKY            e }
                            { LABEL_WIDTH       20 }
                            { ROW               3 }
                            { COLUMN            0 }
                            { PADX 10 }
                        } </ELEMENT> }
		        } </ELEMENTS> }
		    } </FRAME> }
		    } </FRAMES> }
		    { FILL            x }
		} </FRAME> }
        { FRAME {
		    { NAME  atmparamsframe }
		    { LABEL "ATM Header Parameters" }
		    { GEOMGR            pack }
		    { ELEMENTS {
			{ ELEMENT {
			    { NAME              atmHeaderWidget }
			    { WIDGET_CLASS      PropertyAtmHeader }
			    { SIDE            left }
			} </ELEMENT> }
		    } </ELEMENTS> }
		    { FILL            x }
		} </FRAME> }
        { FRAME {
		    { NAME  passFail }
		    { LABEL "Pass Criteria" }
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
		        { NAME              thresholdMode }
		        { WIDGET_CLASS      PropertyRadio }
		        { WIDGET_OPTIONS    vertical }
		        { ROW               1 }
		        { COLUMN            0 }
		        { STICKY            e }
		        { ROWSPAN           2 }
		        { LABEL_WIDTH       10 }
		    } </ELEMENT> }
		    { ELEMENT { 
		        { NAME              lineThresholdValue }
		        { WIDGET_CLASS      PropertyFloat }
		        { ROW               1 }
		        { COLUMN            1 }
		        { STICKY            e }
		        { LABEL_WIDTH       0 }
		    } </ELEMENT> }
		    { ELEMENT { 
		        { NAME              dataThresholdValue }
		        { WIDGET_CLASS      PropertyFloat }
		        { ROW               2 }
		        { COLUMN            1 }
		        { STICKY            e }
		        { LABEL_WIDTH       0 }
		    } </ELEMENT> }
		    { ELEMENT { 
		        { NAME              dataThresholdScale }
		        { WIDGET_CLASS      PropertyEnumString }
		        { ROW               2 }
		        { COLUMN            2 }
		        { STICKY            e }
		        { LABEL_WIDTH       0 }
		    } </ELEMENT> }
		    { ELEMENT { 
		        { NAME              latencyLabel }
		        { WIDGET_CLASS      PropertyString }
		        { ROW               3 }
		        { COLUMN            0 }
		        { STICKY            e }
		        { LABEL_WIDTH       10 }
		    } </ELEMENT> }
		    { ELEMENT { 
		        { NAME              latencyValue }
		        { WIDGET_CLASS      PropertyFloat }
		        { ROW               3 }
		        { COLUMN            1 }
		        { STICKY            e }
		        { LABEL_WIDTH       0 }
		    } </ELEMENT> }
		    { ELEMENT { 
		        { NAME              latencyThresholdScale }
		        { WIDGET_CLASS      PropertyEnumString }
		        { ROW               3 }
		        { COLUMN            2 }
		        { STICKY            e }
		        { LABEL_WIDTH       0 }
		    } </ELEMENT> }
		    { ELEMENT { 
		        { NAME              latencyThresholdMode }
		        { WIDGET_CLASS      PropertyRadio }
		        { ROW               3 }
		        { COLUMN            3 }
		        { STICKY            e }
		        { LABEL_WIDTH       10 }
            } </ELEMENT> }
		    } </ELEMENTS> } 
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
            { NAME  bgpParams }
            { LABEL "BGP Parameters" }
            { FRAMES {
            { FRAME {
                { NAME  invisibleBgpParams }
                { LABEL "" }
                { ELEMENTS {
                { ELEMENT { 
                    { NAME              bgpType }
                    { WIDGET_CLASS      PropertyEnumString }
                    { STICKY            w }
                    { ENTRY_WIDTH       7 } 
                    { LABEL_WIDTH       25 }
                    { ROW               0 }
                    { COLUMN            0 }
                    { PADX 10 }
                } </ELEMENT> }
                { ELEMENT {
                    { NAME              firstAsNumber }
                    { WIDGET_CLASS      PropertyInt }
                    { STICKY            w }
                    { ENTRY_WIDTH       8 }
                    { LABEL_WIDTH       25 }
                    { ROW               1 }
                    { COLUMN            0 }
                    { PADX 10 }
                } </ELEMENT> }
                { ELEMENT {
                    { NAME              numPeers }
                    { WIDGET_CLASS      PropertyInt }
                    { STICKY            w }
                    { ENTRY_WIDTH       8 }
                    { LABEL_WIDTH       25 }
                    { ROW               2 }
                    { COLUMN            0 }
                    { PADX 10 }
                } </ELEMENT> }
		{ ELEMENT {
                    { NAME              ipSrcIncrm }
		    { WIDGET_CLASS      PropertyEntryString }
                    { ENTRY_WIDTH       14 }
		    { LABEL_WIDTH       25 }
                    { ROW               3 }
                    { COLUMN            0 }
                    { PADX 10 }
                } </ELEMENT> }
                { ELEMENT {
                    { NAME              routesPerPeer }
                    { WIDGET_CLASS      PropertyInt }
                    { STICKY            w }
                    { ENTRY_WIDTH       8 }
                    { LABEL_WIDTH       25 }
                    { ROW               4 }
                    { COLUMN            0 }
                    { PADX 10 }
                } </ELEMENT> }
                { ELEMENT {
                    { NAME              firstRoute }
		            { WIDGET_CLASS      PropertyEntryString }
                    { ENTRY_WIDTH       14 }
		            { LABEL_WIDTH       25 }
                    { ROW               5 }
                    { COLUMN            0 }
                    { PADX 10 }
                } </ELEMENT> }
                { ELEMENT {
                    { NAME              incrByRoutes }
		            { WIDGET_CLASS      PropertyInt }
                    { STICKY            w }
                    { ENTRY_WIDTH       8 }
                    { LABEL_WIDTH       25 }
                    { ROW               6 }
                    { COLUMN            0 }
                    { PADX 10 }
                } </ELEMENT> }
		{ ELEMENT {
                    { NAME              incrByRouters }
		            { WIDGET_CLASS      PropertyEntryString }
                    { ENTRY_WIDTH       14 }
		            { LABEL_WIDTH       25 }
                    { ROW               7 }
                    { COLUMN            0 }
                    { PADX 10 }
                } </ELEMENT> }
                } </ELEMENTS> }
             } </FRAME> }
             } </FRAMES> }
             { FILL            x }
        } </FRAME> }
			{ FRAME {
		    { NAME  invisible10 }
		    { LABEL "VLAN Parameters" }
		    { FRAMES {
			{ FRAME {
			    { NAME  vlanInvisible1 }
			    { LABEL "" }
			    { ELEMENTS {
				{ ELEMENT {
				    { NAME              enable802dot1qTag }
				    { WIDGET_CLASS      PropertyBoolean }
				    { ROW               0 }
				    { COLUMN            0 }
				} </ELEMENT> }
				{ ELEMENT {
				    { NAME              firstVlanID }
				    { WIDGET_CLASS      PropertyInt }
				    { ROW               1 }
				    { COLUMN            0 }
				    { LABEL_WIDTH       12 }
				} </ELEMENT> }
				{ ELEMENT {
				    { NAME              incrementVlanID }
				    { WIDGET_CLASS      PropertyBoolean }
				    { ROW               1 }
				    { COLUMN            1 }
				} </ELEMENT> }
			    } </ELEMENTS> }
			} </FRAME> }
			{ FRAME {
			    { NAME  vlanInvisible3 }
			    { LABEL "" }
			    { ELEMENTS {
				{ ELEMENT {
				    { NAME              vlanWarningLabel1 }
				    { WIDGET_CLASS      PropertyString }
				    { ROW               1 }
				    { COLUMN            0 }
				    { LABEL_WIDTH       55 }
				} </ELEMENT> }
				{ ELEMENT {
				    { NAME              vlanWarningLabel2 }
				    { WIDGET_CLASS      PropertyString }
				    { ROW               2 }
				    { COLUMN            0 }
				    { LABEL_WIDTH       55 }
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
    } </FRAMES> }
}


#####################################################################
# bgpPerformanceGUI::trafficContent
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
set bgpPerformanceGUI::trafficContent {
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
		    { HEIGHT            200 }
		    { WIDTH             400 }
		} </ELEMENT> }
        { ELEMENT { 
		    { NAME              frameDataWidget }
		    { WIDGET_CLASS      PropertyFrameData }
		    { X                 0 }
		    { Y                 200 }
		    { HEIGHT            600 }
		    { WIDTH             400 }
		} </ELEMENT> }
        { ELEMENT { 
		    { NAME              trafficMapWidget }
		    { WIDGET_CLASS      PropertyTrafficMap }
		    { X                 400 }
		    { Y                 0 }
		    { HEIGHT            800 }
		    { WIDTH             400 }
		} </ELEMENT> }
	    } </ELEMENTS> }
	} </FRAME> }
    } </FRAMES> }
}




