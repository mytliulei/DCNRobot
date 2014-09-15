############################################################
# Copyright (c) Ixia 2004-2005
# All rights reserved
#
# DESCRIPTION:
# This file provides methods used to generate GUI 
# for Throughput Real Time Latency.
#
############################################################

namespace eval bbThroughputGUI {};

#####################################################################
# bbThroughputGUI::runParamsContent
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
set bbThroughputGUI::runParamsContent {
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
                    { ROW               0 }
                    { COLUMN            0 } 
                    { LABEL_WIDTH       11 }
                    { ENTRY_WIDTH       2 }                   
                } </ELEMENT> }
                { ELEMENT {
                    { NAME              numAddressesPerPort }
                    { WIDGET_CLASS      PropertyInt }                    
                    { ROW               0 }          
                    { COLUMN            2 }
                    { LABEL_WIDTH       21 }
                    { ENTRY_WIDTH       2 }
                    { PADX              15 }
                } </ELEMENT> }
                { ELEMENT { 
                    { NAME              latencyTypes }
                    { WIDGET_CLASS      PropertyEnumString }
                    { ROW               0 }
                    { COLUMN            1 }
                    { LABEL_WIDTH       13 }
                    { ENTRY_WIDTH       13 }
                } </ELEMENT> }
                { ELEMENT {
                    { NAME              calculateLatency }
                    { WIDGET_CLASS      PropertyBoolean }
                    { ROW               1 }                    
                    { COLUMN            0 }
                    { LABEL_WIDTH       16 }
                    { ENTRY_WIDTH       10 }                    
                } </ELEMENT> }
                { ELEMENT {
                    { NAME              calculateJitter }
                    { WIDGET_CLASS      PropertyBoolean }
                    { ROW               1 }                 
                    { COLUMN            1 }
                    { LABEL_WIDTH       16 }
                    { ENTRY_WIDTH       10 }                    
                    { PADX              35 }
                } </ELEMENT> }
                { ELEMENT {
                    { NAME              staggeredStart }
                    { WIDGET_CLASS      PropertyBoolean }
                    { ROW               1 }              
                    { COLUMN            2 }
                    { PADX              25 }
                } </ELEMENT> }
                { ELEMENT {
                    { NAME              calculateDataIntegrity }
                    { WIDGET_CLASS      PropertyBoolean }
                    { ROW               2 }                 
                    { COLUMN            0 }
                    { LABEL_WIDTH       16 }
                    { ENTRY_WIDTH       10 }                    
                    { PADX              2 }
                } </ELEMENT> }
                } </ELEMENTS> }
            } </FRAME> }
            } </FRAMES> }
            { FILL           x }
        } </FRAME> }
        { FRAME {
            { NAME  linearBinarySearchs }
            { LABEL "Search" }
            { FRAMES {            
            { FRAME {
                { NAME  invisibleBinarySearch }
                { LABEL "" }
                { ELEMENTS {
                { ELEMENT { 
                    { NAME              searchType }
                    { WIDGET_CLASS      PropertyEnumString }
                    { ROW               0 }
                    { COLUMN            0 }
                    { LABEL_WIDTH       12 }
                    { ENTRY_WIDTH       6 }
                } </ELEMENT> }
                { ELEMENT {
                    { NAME              numIterations }
                    { WIDGET_CLASS      PropertyInt }
                    { ROW               0 }
                    { COLUMN            1}
                    { LABEL_WIDTH       12 }
                    { ENTRY_WIDTH       3 }
                    { PADX              10 }                
                } </ELEMENT> }
                { ELEMENT {
                    { NAME              tolerance }
                    { WIDGET_CLASS      PropertyFloat }
                    { ROW               0 }
                    { COLUMN            2 }
                    { LABEL_WIDTH       16 }
                    { ENTRY_WIDTH       3 }
                    { PADX              10 }
                } </ELEMENT> }                     
                } </ELEMENTS> }
            } </FRAME> }
            { FRAME {
                { NAME  invisibleBinarySearch21 }
                { LABEL "Binary Search Direction" }
                { ELEMENTS {
                { ELEMENT { 
                    { NAME              binarySearchDirection }
                    { WIDGET_CLASS      PropertyRadio }
                    { LABEL_WIDTH       8 } 
                    { ROW               0 }
                    { COLUMN            4 }
                } </ELEMENT> }
                } </ELEMENTS> }
                { SIDE       right }
            } </FRAME> }            
             { FRAME {
                { NAME  invisibleBinarySearch2 }
                { LABEL "Load Rate" }
                { ELEMENTS {
                  { ELEMENT {
                    { NAME              loadRateBroadBandWidget }
                    { WIDGET_CLASS      PropertyLoadRateBroadBand }
                    { ROW               0 }
                    { COLUMN            3 }
                  } </ELEMENT> }        
                } </ELEMENTS> }
            } </FRAME> }

            } </FRAMES> }
            { FILL           x }
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
                { NAME              lineThresholdMode }
                { WIDGET_CLASS      PropertyRadio }
                { WIDGET_OPTIONS    horizontal }
                { ROW               1 }
                { COLUMN            3 }
                { STICKY            e }
                { LABEL_WIDTH       10 }
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
                { NAME              dataThresholdMode }
                { WIDGET_CLASS      PropertyRadio }
                { ROW               2 }
                { COLUMN            3 }
                { STICKY            e }
                { LABEL_WIDTH       10 }
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
             { ELEMENT { 
                { NAME              jitterLabel }
                { WIDGET_CLASS      PropertyString }
                { ROW               4 }
                { COLUMN            0 }
                { STICKY            e }
                { LABEL_WIDTH       10 }
            } </ELEMENT> }
            { ELEMENT { 
                { NAME              jitterValue }
                { WIDGET_CLASS      PropertyFloat }
                { ROW               4 }
                { COLUMN            1 }
                { STICKY            e }
                { LABEL_WIDTH       0 }
            } </ELEMENT> }
            { ELEMENT { 
                { NAME              jitterThresholdScale }
                { WIDGET_CLASS      PropertyEnumString }
                { ROW               4 }
                { COLUMN            2 }
                { STICKY            e }
                { LABEL_WIDTH       0 }
            } </ELEMENT> }
            { ELEMENT { 
                { NAME              jitterThresholdMode }
                { WIDGET_CLASS      PropertyRadio }
                { ROW               4 }
                { COLUMN            3 }
                { STICKY            e }
                { LABEL_WIDTH       10 }
            } </ELEMENT> }
            } </ELEMENTS> }
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
# bbThroughputGUI::trafficContent
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
set bbThroughputGUI::trafficContent {
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


