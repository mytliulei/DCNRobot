##################################################################################
#
#   Copyright © 2005 by IXIA
#   All Rights Reserved.
#
##################################################################################

namespace eval bgpPerformanceHeader {}

set bgpPerformanceHeader::headerTable {
    { TEST_NAME        bgpPerformance }
    { TEST_NAME_STR    "Performance" }
    { TEST_CAT         BGP }
    { TEST_CAT_STR     "BGP" }
    { TEST_CMD         bgpSuite }
}

return BGP_bgpPerformance;


