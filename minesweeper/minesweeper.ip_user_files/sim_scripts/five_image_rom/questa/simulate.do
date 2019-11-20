onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib five_image_rom_opt

do {wave.do}

view wave
view structure
view signals

do {five_image_rom.udo}

run -all

quit -force
