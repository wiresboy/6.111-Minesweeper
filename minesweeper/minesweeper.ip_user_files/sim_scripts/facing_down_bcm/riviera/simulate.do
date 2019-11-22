onbreak {quit -force}
onerror {quit -force}

asim -t 1ps +access +r +m+facing_down_bcm -L xpm -L blk_mem_gen_v8_4_4 -L xil_defaultlib -L unisims_ver -L unimacro_ver -L secureip -O5 xil_defaultlib.facing_down_bcm xil_defaultlib.glbl

do {wave.do}

view wave
view structure

do {facing_down_bcm.udo}

run -all

endsim

quit -force