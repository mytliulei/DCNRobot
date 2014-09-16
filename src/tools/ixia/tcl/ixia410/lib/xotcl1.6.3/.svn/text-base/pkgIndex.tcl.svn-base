set __dir__ $dir 
foreach index [concat \
		   [glob -nocomplain [file join $dir * pkgIndex.tcl]] \
		   [glob -nocomplain [file join $dir * * pkgIndex.tcl]]] {
  set dir [file dirname $index]
  source $index
} 
set dir $__dir__ 
unset __dir__ 

  package ifneeded XOTcl 1.6.3 [list load \
    [file join $dir xotcl163.dll] XOTcl]


