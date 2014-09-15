#
# Tcl package index file
#
# Note sqlite*3* init specifically
#
package ifneeded sqlite3 3.6.18 \
    [list load [file join $dir sqlite3618.dll] Sqlite3]
