set root [file dirname [file normalize [info script]]]
create_project servo_ctrl [file normalize [file join $root .. .. build servo]] -part xc7s75fgga484-1 -force
add_files [list [file join $root servo_ctrl.v]]
add_files -fileset sim_1 [list [file join $root tb_servo_ctrl.sv]]
add_files -fileset constrs_1 [file join $root servo_clock_only.xdc]
set_property top servo_ctrl [get_filesets sources_1]
set_property top tb_servo_ctrl [get_filesets sim_1]
set_property xsim.simulate.runtime all [get_filesets sim_1]
update_compile_order -fileset sources_1
