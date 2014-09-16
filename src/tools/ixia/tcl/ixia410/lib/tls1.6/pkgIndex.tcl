package ifneeded tls 1.6 \
    "[list source [file join $dir tls.tcl]] ; \
     [list tls::initlib $dir tls16.dll]"
