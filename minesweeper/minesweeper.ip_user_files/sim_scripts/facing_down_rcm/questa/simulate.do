onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib facing_down_rcm_opt

do {wave.do}

view wave
view structure
view signals

do {facing_down_rcm.udo}

run -all

quit -force
