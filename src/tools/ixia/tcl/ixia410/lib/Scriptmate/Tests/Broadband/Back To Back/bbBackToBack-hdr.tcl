##################################################################################
#
#   Copyright © 2005 by IXIA
#   All Rights Reserved.
#
##################################################################################

#global supportImixNDRFrameSize;
#set supportImixNDRFrameSize(broadband_bbThroughput) 0;

namespace eval bbBackToBackHeader {}

set bbBackToBackHeader::headerTable {
    { TEST_NAME        bbBackToBack }
    { TEST_NAME_STR    "Back To Back" }
    { TEST_CAT         broadband }
    { TEST_CAT_STR     "Broadband" }
}

return broadband_bbBackToBack;
