############################################################
# Copyright (c) Ixia 2004-2005
# All rights reserved
#
# DESCRIPTION:
# This file provides methods used to generate GUI 
# for TrafficTester.
#
############################################################

namespace eval isisPerformanceGUI {};

#####################################################################
# isisPerformanceGUI::runParamsContent
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
set isisPerformanceGUI::runParamsContent {
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
                                    { NAME              routeDelay }
                                    { WIDGET_CLASS      PropertyFloat }
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
                            { SIDE              left }
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
                    { NAME  isisParameters }
                    { LABEL "ISIS Parameters" }
                    { FRAMES {
                        { FRAME {
                            { NAME  isisParamsInvisible }
                            { LABEL "" }
                            { ELEMENTS {
                                { ELEMENT { 
                                            { NAME              emulatedRoutersPerPortNumber }
                                            { WIDGET_CLASS      PropertyInt }
                                            { LABEL_WIDTH       0 }
                                            { ROW               1 }
                                            { COLUMN            0 }
                                            { STICKY            w }
                                            { LABEL_WIDTH       30 }
                                } </ELEMENT> }
                                { ELEMENT {
                                            { NAME              ipSrcIncrm }
                                            { WIDGET_CLASS      PropertyEntryString }
                                            { ENTRY_WIDTH       14 }
                                            { LABEL_WIDTH       30 }
                                            { ROW               2 }
                                            { STICKY            w }
                                            { COLUMN            0 }
                                } </ELEMENT> }
                                { ELEMENT { 
                                            { NAME              isisOsiLevel }
                                            { WIDGET_CLASS      PropertyEnumString }
                                            { LABEL_WIDTH       0 }
                                            { ROW               3 }
                                            { COLUMN            0 }
                                            { STICKY            w }
                                            { LABEL_WIDTH       30 }
                                            { ENTRY_WIDTH       10 }
                                } </ELEMENT> }
                                { ELEMENT { 
                                            { NAME              holdtime }
                                            { WIDGET_CLASS      PropertyInt }
                                            { LABEL_WIDTH       0 }
                                            { ROW               4 }
                                            { COLUMN            0 }
                                            { STICKY            w }
                                            { LABEL_WIDTH       30 }
                                } </ELEMENT> }
                                { ELEMENT { 
                                            { NAME              advertiseRoutes }
                                            { WIDGET_CLASS      PropertyBoolean }
                                            { LABEL_WIDTH       0 }
                                            { ROW               5 }
                                            { COLUMN            0 }
                                            { STICKY            w }
                                            { LABEL_WIDTH       30 }
                                            { PADX 10 }
                                } </ELEMENT> }
                                { ELEMENT { 
                                            { NAME              routesPerRouterNumber }
                                            { WIDGET_CLASS      PropertyInt }
                                            { LABEL_WIDTH       0 }
                                            { ROW               6 }
                                            { COLUMN            0 }
                                            { STICKY            w }
                                            { LABEL_WIDTH       30 }
                                } </ELEMENT> }
                                { ELEMENT { 
                                            { NAME              firstRoute }
                                            { WIDGET_CLASS      PropertyEntryString }
                                            { LABEL_WIDTH       0 }
                                            { ROW               7 }
                                            { COLUMN            0 }
                                            { STICKY            w }
                                            { LABEL_WIDTH       30 }
                                            { ENTRY_WIDTH       16 }
                                } </ELEMENT> }
                                { ELEMENT { 
                                            { NAME              routeMaskWidth }
                                            { WIDGET_CLASS      PropertyInt }
                                            { LABEL_WIDTH       0 }
                                            { ROW               8 }
                                            { COLUMN            0 }
                                            { STICKY            w }
                                            { LABEL_WIDTH       30 }
                                            { ENTRY_WIDTH       6 }
                                } </ELEMENT> }
                                { ELEMENT { 
                                            { NAME              incrPerRouter }
                                            { WIDGET_CLASS      PropertyEntryString }
                                            { LABEL_WIDTH       0 }
                                            { ROW               9 }
                                            { COLUMN            0 }
                                            { STICKY            w }
                                            { LABEL_WIDTH       30 }
                                            { ENTRY_WIDTH       10 }
                                } </ELEMENT> }
                                { ELEMENT { 
                                            { NAME              routeOrigin }
                                            { WIDGET_CLASS      PropertyEnumString }
                                            { LABEL_WIDTH       0 }
                                            { ROW               10 }
                                            { COLUMN            0 }
                                            { STICKY            w }
                                            { LABEL_WIDTH       30 }
                                            { ENTRY_WIDTH       10 }
                                } </ELEMENT> }
                                { ELEMENT { 
                                            { NAME              advertiseNetworkRange }
                                            { WIDGET_CLASS      PropertyBoolean }
                                            { LABEL_WIDTH       0 }
                                            { ROW               11 }
                                            { COLUMN            0 }
                                            { STICKY            w }
                                            { LABEL_WIDTH       30 }
                                            { PADX              10 }
                                } </ELEMENT> }
                                { ELEMENT { 
                                            { NAME              rowsNumber }
                                            { WIDGET_CLASS      PropertyInt }
                                            { LABEL_WIDTH       0 }
                                            { ROW               12 }
                                            { COLUMN            0 }
                                            { STICKY            w }
                                            { LABEL_WIDTH       30 }
                                } </ELEMENT> }
                                { ELEMENT { 
                                            { NAME              columnsNumber }
                                            { WIDGET_CLASS      PropertyInt }
                                            { LABEL_WIDTH       0 }
                                            { ROW               13 }
                                            { COLUMN            0 }
                                            { STICKY            w }
                                            { LABEL_WIDTH       30 }
                                } </ELEMENT> }
                                { ELEMENT { 
                                            { NAME              firstSubnet }
                                            { WIDGET_CLASS      PropertyEntryString }
                                            { LABEL_WIDTH       0 }
                                            { ROW               14 }
                                            { COLUMN            0 }
                                            { STICKY            w }
                                            { LABEL_WIDTH       30 }
                                            { ENTRY_WIDTH       16 }
                                } </ELEMENT> }
                                { ELEMENT { 
                                            { NAME              subnetMaskWidth }
                                            { WIDGET_CLASS      PropertyInt }
                                            { LABEL_WIDTH       0 }
                                            { ROW               15 }
                                            { COLUMN            0 }
                                            { STICKY            w }
                                            { LABEL_WIDTH       30 }
                                            { ENTRY_WIDTH       6 }
                                } </ELEMENT> }
                                { ELEMENT { 
                                            { NAME              linkType }
                                            { WIDGET_CLASS      PropertyEnumString }
                                            { ROW               16 }
                                            { COLUMN            0 }
                                            { STICKY            w }
                                            { LABEL_WIDTH       30 }
                                            { ENTRY_WIDTH       12 }
                                            { ENTRY_HEIGHT      2 }
                                } </ELEMENT> }
                            } </ELEMENTS> } 
                            { ANCHOR            w }
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
# isisPerformanceGUI::trafficContent
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
set isisPerformanceGUI::trafficContent {
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


