onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib one_gcm_opt

do {wave.do}

view wave
view structure
view signals

do {one_gcm.udo}

run -all

quit -force
