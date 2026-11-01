create_clock -name clk_50mhz -period 20.000 [get_ports clk_50mhz]
# Use board manual to confirm clock/reset/LED pins and extension-header RX.
# RX must NOT retain internal USB-UART C6 when receiving STM32 PC10.
# PC echo TX can use the documented USB-UART F6 after connector verification.
# No invented physical pin assignments are included.
