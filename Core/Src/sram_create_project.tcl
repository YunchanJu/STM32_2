set root [file dirname [file normalize [info script]]]
create_project sram [file normalize [file join $root .. .. build sram]] -part xc7s75fgga484-1 -force
add_files [list [file join $root sram.v]]
add_files -fileset sim_1 [list [file join $root tb_sram.sv]]
add_files -fileset constrs_1 [file join $root sram_clock_only.xdc]
set_property top sram [get_filesets sources_1]
set_property top tb_sram [get_filesets sim_1]
set_property xsim.simulate.runtime all [get_filesets sim_1]
update_compile_order -fileset sources_1
