onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib six_gcm_opt

do {wave.do}

view wave
view structure
view signals

do {six_gcm.udo}

run -all

quit -force