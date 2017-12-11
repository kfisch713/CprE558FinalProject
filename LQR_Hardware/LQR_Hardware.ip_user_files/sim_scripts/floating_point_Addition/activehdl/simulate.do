onbreak {quit -force}
onerror {quit -force}

asim -t 1ps +access +r +m+floating_point_Addition -L xbip_utils_v3_0_7 -L axi_utils_v2_0_3 -L xbip_pipe_v3_0_3 -L xbip_dsp48_wrapper_v3_0_4 -L xbip_dsp48_addsub_v3_0_3 -L xbip_dsp48_multadd_v3_0_3 -L xbip_bram18k_v3_0_3 -L mult_gen_v12_0_12 -L floating_point_v7_1_4 -L xil_defaultlib -L secureip -O5 xil_defaultlib.floating_point_Addition

do {wave.do}

view wave
view structure

do {floating_point_Addition.udo}

run -all

endsim

quit -force
