proc ::TreeCtrlLoad {dir} {
	uplevel #0 source [list [file join $dir treectrl.tcl]]
	uplevel #0 source [list [file join $dir filelist-bindings.tcl]]
	tclPkgSetup $dir treectrl 1.0 {
		{treectrl10.dll load {treectrl imagetint textlayout}}
	}
}
package ifneeded treectrl 1.0 [list ::TreeCtrlLoad $dir]

