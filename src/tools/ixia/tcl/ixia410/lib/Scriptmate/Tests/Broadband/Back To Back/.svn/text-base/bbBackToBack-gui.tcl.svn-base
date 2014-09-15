############################################################
# Copyright (c) Ixia 2004-2005
# All rights reserved
#
# DESCRIPTION:
# This file provides methods used to generate GUI 
# for Throughput Real Time Latency.
#
############################################################

namespace eval bbBackToBackGUI {};

#####################################################################
# bbBackToBackGUI::runParamsContent
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
set bbBackToBackGUI::runParamsContent {
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
                            } </ELEMENT> }
                        } </ELEMENTS> }
                    } </FRAME> }
                    { SIDE       left }
                } </FRAMES> }
                { FILL           x }
            } </FRAME> }

            { FRAME {
                { NAME  invisible }
                { LABEL "Test Parameters" }
                { FRAMES {
                    { FRAME {
                        { NAME  invisibleTestParms }
                        { LABEL "" }
                        { ELEMENTS {
                        { ELEMENT {
                            { NAME              numtrials }
                            { WIDGET_CLASS      PropertyInt }                    
                            { LABEL_WIDTH       21 }
                            { ENTRY_WIDTH       5 }  
                            { ROW               0 }
                        { COLUMN            0 }
                        } </ELEMENT> }
                        { ELEMENT {
                            { NAME              numAddressesPerPort }
                            { WIDGET_CLASS      PropertyInt }                                        
                            { LABEL_WIDTH       21 }
                            { ENTRY_WIDTH       5 }                    
                            { ROW               1 }
                        { COLUMN            0 }
                        } </ELEMENT> }
                        { ELEMENT {
                            { NAME              tolerance }
                            { WIDGET_CLASS      PropertyFloat }                    
                            { ROW               0 }
                        { COLUMN            1 }
                            { PADX              5}                        
                        } </ELEMENT> }
                        { ELEMENT {
                            { NAME              staggeredStart }
                            { WIDGET_CLASS      PropertyBoolean }                                        
                            { ROW               1 }
                        { COLUMN            1 }
                            { PADX              5}                
                        } </ELEMENT> }
                        } </ELEMENTS> }
                    } </FRAME> }
                } </FRAMES> }
                { FILL           x }
            } </FRAME> }
                    
            { FRAME {
                { NAME  invisibleBinarySearch }
                { LABEL "Binary Search Direction" }
                { FRAMES {
                    { FRAME {
                        { NAME  invisibleTestParms }
                        { LABEL "" }
                        { ELEMENTS {
                            { ELEMENT { 
                                { NAME              binarySearchDirection }
                                { WIDGET_CLASS      PropertyRadio }
                                { LABEL_WIDTH       8 }                             
                            } </ELEMENT> }
                        } </ELEMENTS> } 
                    } </FRAME> }
                } </FRAMES> }
                { FILL           x }
            } </FRAME> } 

            { FRAME {
                { NAME  invisibleLoadRate }
                { LABEL "Load Rate" }

                { FRAMES {
                    { FRAME {
                        { NAME  invisibleTestParms }
                        { LABEL "" }
                        { ELEMENTS {
                          { ELEMENT {
                                { NAME              loadRateBroadBandWidget }
                                { WIDGET_CLASS      PropertyLoadRateBroadBand }
                                { SHOW_INCREMENT    n }
                            } </ELEMENT> }        
                        } </ELEMENTS> }
                   } </FRAME> }
                } </FRAMES> }
                { FILL           x }
            } </FRAME> }
        
            { FRAME {
                { NAME  passFail }
                { LABEL "Pass Criteria" }
                { FRAMES {
                    { FRAME {
                        { NAME  invisiblePassFail }
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
                                { NAME              thresholdMode }
                                { WIDGET_CLASS      PropertyRadio }
                                { WIDGET_OPTIONS    vertical }
                                { ROW               1 }
                                { COLUMN            0 }
                                { ROWSPAN           2 }
                                { STICKY            e }                                
                            } </ELEMENT> }

                            { ELEMENT { 
                                { NAME              passFailMinDuration }
                                { WIDGET_CLASS      PropertyInt }
                                { ROW               1 }
                                { COLUMN            1 }
                                { STICKY            e }  
                                { LABEL_WIDTH       0 }
                            } </ELEMENT> }
                                                        
                            { ELEMENT { 
                                { NAME              dataThresholdScale }
                                { WIDGET_CLASS      PropertyEnumString }
                                { ROW               1 }
                                { COLUMN            2 }
                                { STICKY            e }
                                { LABEL_WIDTH       0 }
                            } </ELEMENT> }

                            { ELEMENT { 
                                { NAME              passFailBackToBackFrames }
                                { WIDGET_CLASS      PropertyInt }
                                { ROW               2 }
                                { COLUMN            1 }
                                { STICKY            e }
                                { LABEL_WIDTH       0 }
                            } </ELEMENT> 
                            }
                        } </ELEMENTS> } 
                    } </FRAME> }
    
                } </FRAMES> }
                { FILL           x }
            } </FRAME> }

        } </FRAMES> }
        { SIDE             left }
        { PADX             0 }
        { PADY             0 }
        { FILL             both }
        { EXPAND           n }
    } </FRAME> }
    } </FRAMES> }
}


#####################################################################
# bbBackToBackGUI::trafficContent
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
set bbBackToBackGUI::trafficContent {
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
                    { NAME              learnFramesWidget }
                    { WIDGET_CLASS      PropertyLearnFrames }
                    { DONOTSUPPORTLEARNMACONLY  n }
                    { LEARNFREQVALUES {oncePerTest oncePerFramesize onTrial never onIteration} }
                    { X                 400 }
                    { Y                 0 }
                    { HEIGHT            300 }
                    { WIDTH             400 }
                } </ELEMENT> }
                { ELEMENT { 
                    { NAME              trafficMapWidget }
                    { WIDGET_CLASS      PropertyTrafficMap }
                    { X                 400 }
                    { Y                 300 }
                    { HEIGHT            300 }
                    { WIDTH             400 }
                } </ELEMENT> }
            } </ELEMENTS> }
        } </FRAME> }
    } </FRAMES> }
}


