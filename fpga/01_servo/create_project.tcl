set root [file dirname [file normalize [info script]]]
create_project servo_ctrl [file join $root vivado_recreated] -part xc7s75fgga484-1 -force
add_files [glob [file join $root src *.v]]
add_files -fileset sim_1 [glob [file join $root sim *.sv]]
add_files -fileset constrs_1 [file join $root constraints clock_only.xdc]
set_property top servo_ctrl [get_filesets sources_1]
set_property top tb_servo_ctrl [get_filesets sim_1]
set_property xsim.simulate.runtime all [get_filesets sim_1]
update_compile_order -fileset sources_1
