onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib three_rcm_opt

do {wave.do}

view wave
view structure
view signals

do {three_rcm.udo}

run -all

quit -force
