if {[catch {package require Tcl 8.1}]} return
if {![info exists ::env(VU_LIBRARY)]
    && [file exists [file join $dir vu.tcl]]} {
    set ::env(VU_LIBRARY) $dir
}
package ifneeded vu 2.3 \
    [list load [file join $dir vu23.dll]]
