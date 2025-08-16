set_global_assignment -entity "mod_adc_core_ip" -library "lib_mod_adc_core_ip" -name IP_TOOL_NAME "Qsys"
set_global_assignment -entity "mod_adc_core_ip" -library "lib_mod_adc_core_ip" -name IP_TOOL_VERSION "24.1"
set_global_assignment -entity "mod_adc_core_ip" -library "lib_mod_adc_core_ip" -name IP_TOOL_ENV "Qsys"
set_global_assignment -library "lib_mod_adc_core_ip" -name SPD_FILE [file join $::quartus(sip_path) "../mod_adc_core_ip.spd"]
set_global_assignment -library "lib_mod_adc_core_ip" -name MISC_FILE [file join $::quartus(sip_path) "../../mod_adc_core_ip.qsys"]

set_global_assignment -library "lib_mod_adc_core_ip" -name MISC_FILE [file join $::quartus(sip_path) "mod_adc_core_ip.v"]
set_global_assignment -library "lib_mod_adc_core_ip" -name MISC_FILE [file join $::quartus(sip_path) "submodules/mod_adc_core_ip_modular_adc_0.v"]
set_global_assignment -library "lib_mod_adc_core_ip" -name MISC_FILE [file join $::quartus(sip_path) "submodules/altera_modular_adc_control.v"]
set_global_assignment -library "lib_mod_adc_core_ip" -name MISC_FILE [file join $::quartus(sip_path) "submodules/altera_modular_adc_control_avrg_fifo.v"]
set_global_assignment -library "lib_mod_adc_core_ip" -name MISC_FILE [file join $::quartus(sip_path) "submodules/altera_modular_adc_control_fsm.v"]
set_global_assignment -library "lib_mod_adc_core_ip" -name MISC_FILE [file join $::quartus(sip_path) "submodules/chsel_code_converter_sw_to_hw.v"]
set_global_assignment -library "lib_mod_adc_core_ip" -name MISC_FILE [file join $::quartus(sip_path) "submodules/fiftyfivenm_adcblock_primitive_wrapper.v"]
set_global_assignment -library "lib_mod_adc_core_ip" -name MISC_FILE [file join $::quartus(sip_path) "submodules/fiftyfivenm_adcblock_top_wrapper.v"]
