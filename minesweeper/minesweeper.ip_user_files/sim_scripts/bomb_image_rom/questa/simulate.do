onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib bomb_image_rom_opt

do {wave.do}

view wave
view structure
view signals

do {bomb_image_rom.udo}

run -all

quit -force
