onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib blue_coe_opt

do {wave.do}

view wave
view structure
view signals

do {blue_coe.udo}

run -all

quit -force
