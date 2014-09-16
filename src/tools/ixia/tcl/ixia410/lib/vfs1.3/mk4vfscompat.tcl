# Compatibility package to keep the ability to use vfs::mk4 via
# mk4vfs. Keep the version number in sync with version of vfs::mk4,
# and pkgIndex.tcl, of course. There is no other functionality, only
# the redirection.
package require vfs::mk4 1.10.1
package provide mk4vfs   1.10.1
