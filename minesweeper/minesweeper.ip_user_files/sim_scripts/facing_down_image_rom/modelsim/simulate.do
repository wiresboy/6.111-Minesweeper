onbreak {quit -f}
onerror {quit -f}

vsim -voptargs="+acc" -t 1ps -L xpm -L blk_mem_gen_v8_4_4 -L xil_defaultlib -L unisims_ver -L unimacro_ver -L secureip -lib xil_defaultlib xil_defaultlib.facing_down_image_rom xil_defaultlib.glbl

do {wave.do}

view wave
view structure
view signals

do {facing_down_image_rom.udo}

run -all

quit -force
