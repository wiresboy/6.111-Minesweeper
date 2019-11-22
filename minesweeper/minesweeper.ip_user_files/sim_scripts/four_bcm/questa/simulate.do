onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib four_bcm_opt

do {wave.do}

view wave
view structure
view signals

do {four_bcm.udo}

run -all

quit -force