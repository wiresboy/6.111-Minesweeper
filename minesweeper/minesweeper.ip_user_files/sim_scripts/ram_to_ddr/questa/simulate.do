onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib ram_to_ddr_opt

do {wave.do}

view wave
view structure
view signals

do {ram_to_ddr.udo}

run -all

quit -force
