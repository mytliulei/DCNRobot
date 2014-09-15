##################################################################################
# Version 4.10	$Revision: 40 $
# $Author: Mgithens $
#
# $Workfile: map.tcl $ - Map parameters
#
#   Copyright © 1997 - 2005 by IXIA
#   All Rights Reserved.
#
#	Revision Log:
#	02-05-1998	DS	Genesis
#
# Description: This file contains all the commands to configure the mapping
# of traffic which could be from ports of one card of one chassis to any port
# on same card on same chassis, different card on same chassis or different
# cards on different chassis. Any combination can be specified.
#
##################################################################################



########################################################################################
# Procedure: map::new
#
# Description: This command deletes the existing type & creates a new map.
#
########################################################################################
proc map::new {args} \
{
	global mapMethods mapParms

	set type "map"

	if {[llength $args] == 0} {
		logMsg "Usage: $type new "
		foreach op $mapMethods(new) {
			logMsg "       -$op  <value>"
		}
		return
	}

	if {[string index [lindex $args 0] 0] != "-"} {
		logMsg "Usage: $type new "
		foreach op $mapMethods(new) {
			logMsg "       -$op  <value>"
		}
		return
	}
	set opt [string trimleft [lindex $args 0] "-"]
	if {[lsearch $mapMethods(new) $opt] == -1} {
		logMsg "Usage: $type new "
		foreach op $mapMethods(new) {
			logMsg "       -$op  <value>"
		}
		return
	}

    set mapType [lindex $args 1]

    if {![validateMapType $mapType]} {
        set mapArray    [format "%sArray" $mapType]
        global $mapArray

        if [info exists $mapArray] {
            unset $mapArray
        }
    }
}


#######################################################################################
# Procedure: map::add
#
# Description: This command adds a chassis, card and port number for tx and rx.
#
########################################################################################
proc map::add {args} \
{
	global mapMethods mapParms mapConfigVals 
	global one2oneArray one2manyArray many2oneArray many2manyArray

	# if no option name was passed then display all options available for tx
	if {[llength $args] == 0} {
		return -code error "Usage: map add $mapMethods(add)"
	}

	if {[llength $args] != [llength $mapMethods(add)]} {
		return -code error "Usage: map add $mapMethods(add)"
	}

	if {![info exists mapParms(type)]} {
		return -code error "map type not configured yet."
	}

	set tx_c [lindex $args 0]
	set tx_l [lindex $args 1]
	set tx_p [lindex $args 2]
	set rx_c [lindex $args 3]
	set rx_l [lindex $args 4]
	set rx_p [lindex $args 5]

	# first of all, don't let tx=rx!! 
    #if {($tx_c == $rx_c) && ($tx_l == $rx_l) && ($tx_p == $rx_p)} {
    #    return -code error "Invalid map: Tx == Rx"
    #}

	switch $mapParms(type) {
		"one2one" {
			# check if tx is already configured as tx
			if {[info exists one2oneArray($tx_c,$tx_l,$tx_p)]} {
				return -code error "map Tx:[getPortId $tx_c $tx_l $tx_p] exists.\
					                Delete it and add again to change the Rx"
			}

			# check if rx is already configured as rx
			foreach r [array names one2oneArray] {
				if {[string compare $one2oneArray($r) "{$rx_c $rx_l $rx_p}"] == 0} {
					return -code error "map Rx:[getPortId $rx_c $rx_l $rx_p] is already configured for Rx."
				}
			}

			set one2oneArray($tx_c,$tx_l,$tx_p) [list [list $rx_c $rx_l $rx_p]]
		}

		"one2many" {
			# check if rx is already configured as rx on this tx port
			foreach txPort [array names one2manyArray] {
    			if {[lsearch $one2manyArray($txPort) [list $rx_c $rx_l $rx_p]] >= 0} {
                    if {"$tx_c,$tx_l,$tx_p" == $txPort} {
    				    return -code error "map Tx:[getPortId $tx_c $tx_l $tx_p] to Rx:[getPortId $rx_c $rx_l $rx_p] already exists."
                    } else {
    				    return -code error "map Rx:[getPortId $rx_c $rx_l $rx_p] is already configured for Rx."
                    }
    			}
            }

			set one2manyArray($tx_c,$tx_l,$tx_p) [lappend one2manyArray($tx_c,$tx_l,$tx_p) [list $rx_c $rx_l $rx_p]]
		}

		"many2one" {
			# check if tx is already configured as tx
			if {[info exists many2oneArray($tx_c,$tx_l,$tx_p)]} {
    			if {$many2oneArray($tx_c,$tx_l,$tx_p) == "{$rx_c $rx_l $rx_p}"} {
    			    return -code error "map Tx:[getPortId $tx_c $tx_l $tx_p] to Rx:[getPortId $rx_c $rx_l $rx_p] already exists."
                } else {
    			    return -code error "map Tx:[getPortId $tx_c $tx_l $tx_p] is already configured for Tx."
                }
			}

			set many2oneArray($tx_c,$tx_l,$tx_p) [list [list $rx_c $rx_l $rx_p]]
		}

		"many2many" {
            if {([lsearch [array names many2manyArray] "$tx_c,$tx_l,$tx_p"] != -1)} {
                if {[lsearch $many2manyArray($tx_c,$tx_l,$tx_p) "$rx_c $rx_l $rx_p"] == -1} {
		            set many2manyArray($tx_c,$tx_l,$tx_p) [lappend many2manyArray($tx_c,$tx_l,$tx_p) [list $rx_c $rx_l $rx_p]]
                }
            } else {
		        set many2manyArray($tx_c,$tx_l,$tx_p) [lappend many2manyArray($tx_c,$tx_l,$tx_p) [list $rx_c $rx_l $rx_p]]
            }
		}

	}

	return -code ok
}

########################################################################################
# Procedure: map::del
#
# Description: This command deletes a chassis, card and port number for tx and rx.
#
########################################################################################

proc map::del {args} \
{
	global mapMethods mapParms mapConfigVals

    set retCode $::TCL_ERROR

	# if no option name was passed then display all options available for tx
	if {[llength $args] == 0} {
		logMsg "Usage: map del $mapMethods(del)"
		return $::TCL_ERROR
	}

	if {[llength $args] != [llength $mapMethods(add)]} {
		logMsg "Usage: map del $mapMethods(del)"
		return $::TCL_ERROR
	}

	if {![info exists mapParms(type)]} {
		logMsg "map type not configured yet."
		return $::TCL_ERROR
	}

	set tx_c [lindex $args 0]
	set tx_l [lindex $args 1]
	set tx_p [lindex $args 2]
	set rx_c [lindex $args 3]
	set rx_l [lindex $args 4]
	set rx_p [lindex $args 5]

	switch $mapParms(type) {
		"one2one" {
            global one2oneArray
			foreach tx [array names one2oneArray] {
				if {$tx == "$tx_c,$tx_l,$tx_p" && [join $one2oneArray($tx)] == [list $rx_c $rx_l $rx_p]} {
					unset one2oneArray($tx)
                    set retCode $::TCL_OK
                    break
				}
			}
		}

		"one2many" {
            global one2manyArray

            if [info exists one2manyArray($tx_c,$tx_l,$tx_p)] {				
			    set indx [lsearch $one2manyArray($tx_c,$tx_l,$tx_p) [list $rx_c $rx_l $rx_p]]
			    if {$indx >= 0} {
			        if {[llength $one2manyArray($tx_c,$tx_l,$tx_p)] == 1} {
				        unset one2manyArray($tx_c,$tx_l,$tx_p)
			        } else {
				        set one2manyArray($tx_c,$tx_l,$tx_p) [lreplace $one2manyArray($tx_c,$tx_l,$tx_p) $indx $indx]
			        }
                    set retCode $::TCL_OK
                }
            }
		}

		"many2one" {
            global many2oneArray
			foreach tx [array names many2oneArray] {
				if {$tx == "$tx_c,$tx_l,$tx_p" && [join $many2oneArray($tx)] == [list $rx_c $rx_l $rx_p]} {
					unset many2oneArray($tx)
                    set retCode $::TCL_OK
                    break
				}
			}
		}

		"many2many" {
            global many2manyArray
            if [info exists many2manyArray($tx_c,$tx_l,$tx_p)] {				
			    set indx [lsearch $many2manyArray($tx_c,$tx_l,$tx_p) [list $rx_c $rx_l $rx_p]]
			    if {$indx >= 0} {
			        if {[llength $many2manyArray($tx_c,$tx_l,$tx_p)] == 1} {
				        unset many2manyArray($tx_c,$tx_l,$tx_p)
			        } else {
				        set many2manyArray($tx_c,$tx_l,$tx_p) [lreplace $many2manyArray($tx_c,$tx_l,$tx_p) $indx $indx]
			        }
                    set retCode $::TCL_OK
                }
            }
		}

	}

	return $retCode
}


########################################################################################
# Procedure: map::show
#
# Description: This command is used to show the current port map.
#
# Arguments:
#   mapType     - valid options are: one2one, one2many, many2one or many2many
#                 Default is current configured mapType
#
########################################################################################
proc map::show {{mapType ""}} \
{
    global  mapConfigVals

    if {$mapType == ""} {
        set mapType [map cget -type]
    }

    if [validateMapType $mapType] {
        return
    }

    set mapArray    [format "%sArray" $mapType]
    global $mapArray

    logMsg "\nMap type: $mapType"

    if {[llength [array names $mapArray]] < 1} {
        logMsg "--->No ports in map.\n"
        set retCode 1
    } else {
        foreach txMap [lnumsort [array names $mapArray]] {
            scan [join $txMap] "%d,%d,%d" tx_c tx_l tx_p

            foreach rxMap [set ${mapArray}($tx_c,$tx_l,$tx_p)] {
                scan [join $rxMap] "%d %d %d" rx_c rx_l rx_p

                logMsg "\tTx:[getPortId $tx_c $tx_l $tx_p]   Rx: [getPortId $rx_c $rx_l $rx_p]"
            }
        }
        logMsg "\n"
    }
}


########################################################################################
# Procedure: map::validateMapType
#
# Description: This command is used to find out if the given map type is valid.
#
# Arguments:
#   mapType     - valid options are: one2one, one2many, many2one or many2many
#
########################################################################################
proc map::validateMapType {mapType {verbose verbose}} \
{
    global  mapConfigVals

    set notValidMap    1

    foreach thing [map getValidValues -type] {
        if {$mapType == $thing} {
            set notValidMap    0
            break
        }
    }
    if {$notValidMap && $verbose == "verbose"} {
        errorMsg "Error - invalid map type: $mapType"
    }

    return $notValidMap
}


########################################################################################
# Procedure: showmaps
#
# Description: This command is used to show all port maps.
#
#
########################################################################################
proc showmaps {} \
{
    global  mapConfigVals

    foreach thing [split $mapConfigVals(type) |] {
        map show $thing
    }
}


