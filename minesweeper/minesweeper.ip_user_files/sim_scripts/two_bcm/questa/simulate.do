onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib two_bcm_opt

do {wave.do}

view wave
view structure
view signals

do {two_bcm.udo}

run -all

quit -force
