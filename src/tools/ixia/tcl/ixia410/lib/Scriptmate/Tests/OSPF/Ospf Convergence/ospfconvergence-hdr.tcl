##################################################################################
#
#   Copyright © 2005 by IXIA
#   All Rights Reserved.
#
##################################################################################

namespace eval ospfConvergenceHeader {}

set ospfConvergenceHeader::headerTable {
    { TEST_NAME        ospfConvergence }
    { TEST_NAME_STR    "Ospf Convergence" }
    { TEST_CAT         OSPF }
    { TEST_CAT_STR     "OSPF" }
    { TEST_CMD         ospfSuite }
}

return OSPF_ospfConvergence;

