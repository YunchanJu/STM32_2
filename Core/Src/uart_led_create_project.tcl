set root [file dirname [file normalize [info script]]]
create_project uart_led [file normalize [file join $root .. .. build uart_led]] -part xc7s75fgga484-1 -force
add_files [list [file join $root uart_led.v]]
add_files -fileset sim_1 [list [file join $root tb_uart_led.sv]]
add_files -fileset constrs_1 [file join $root uart_led_clock_only.xdc]
set_property top uart_led [get_filesets sources_1]
set_property top tb_uart_led [get_filesets sim_1]
set_property xsim.simulate.runtime all [get_filesets sim_1]
update_compile_order -fileset sources_1
