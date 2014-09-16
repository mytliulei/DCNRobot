set env(TIX_LIBRARY) [file join [file dirname [info script]]]
package ifneeded Tix 8.1.4 [list load [file join $dir tix8184.dll] Tix]