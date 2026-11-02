set root [file dirname [file normalize [info script]]]
create_project dac [file normalize [file join $root .. .. build dac]] -part xc7s75fgga484-1 -force
add_files [list [file join $root dac.v]]
add_files -fileset sim_1 [list [file join $root tb_dac.sv]]
add_files -fileset constrs_1 [file join $root dac_clock_only.xdc]
set_property top dac [get_filesets sources_1]
set_property top tb_dac [get_filesets sim_1]
set_property xsim.simulate.runtime all [get_filesets sim_1]
update_compile_order -fileset sources_1
