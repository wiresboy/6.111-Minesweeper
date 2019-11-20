onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib bomb_gcm_opt

do {wave.do}

view wave
view structure
view signals

do {bomb_gcm.udo}

run -all

quit -force
