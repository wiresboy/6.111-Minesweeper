onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib two_gcm_opt

do {wave.do}

view wave
view structure
view signals

do {two_gcm.udo}

run -all

quit -force
