onbreak {quit -force}
onerror {quit -force}

asim -t 1ps +access +r +m+bomb_gcm -L xpm -L blk_mem_gen_v8_4_4 -L xil_defaultlib -L unisims_ver -L unimacro_ver -L secureip -O5 xil_defaultlib.bomb_gcm xil_defaultlib.glbl

do {wave.do}

view wave
view structure

do {bomb_gcm.udo}

run -all

endsim

quit -force