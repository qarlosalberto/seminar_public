# vivado -nojournal -nolog -notrace -mode batch -source ./compile_standard_libs.tcl -tclargs /home/carlos/bin/questa/questa_fse/bin ./vivado_libs/standard
set simulator_exec_path [lindex $argv 0]
set output_path [lindex $argv 1]

puts "simulator_exec_path=${simulator_exec_path}"
puts "output_path=${output_path}"

set_param general.maxThreads 8

# If you do not have System Verilog Assert license
config_compile_simlib -reset
config_compile_simlib -cfgopt {riviera.verilog.xpm:-sv2k12 -na sva}

compile_simlib -force \
    -language all \
    -simulator questa \
    -verbose  \
    -library unisim \
    -library simprim \
    -library xpm \
    -family  all \
    -no_ip_compile \
    -simulator_exec_path ${simulator_exec_path} \
    -directory ${output_path}
