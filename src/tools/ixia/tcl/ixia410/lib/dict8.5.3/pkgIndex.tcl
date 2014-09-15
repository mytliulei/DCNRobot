if {![package vsatisfies [package provide Tcl] 8.4]} {return} ; \
if {[package vsatisfies [package provide Tcl] 8.5]} { \
    package ifneeded dict 8.5.3 {package provide dict 8.5.3} ; \
    return \
} ; \
package ifneeded dict 8.5.3 [list load [file join $dir dict853.dll] Dict] 
