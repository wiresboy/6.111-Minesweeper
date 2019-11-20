onbreak {quit -force}
onerror {quit -force}

asim -t 1ps +access +r +m+five_image_rom -L xpm -L blk_mem_gen_v8_4_4 -L xil_defaultlib -L unisims_ver -L unimacro_ver -L secureip -O5 xil_defaultlib.five_image_rom xil_defaultlib.glbl

do {wave.do}

view wave
view structure

do {five_image_rom.udo}

run -all

endsim

quit -force
