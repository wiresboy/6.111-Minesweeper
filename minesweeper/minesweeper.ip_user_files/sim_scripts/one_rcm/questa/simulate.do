onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib one_rcm_opt

do {wave.do}

view wave
view structure
view signals

do {one_rcm.udo}

run -all

quit -force
