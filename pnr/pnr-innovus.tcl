set init_mmmc_file "setup-timing.tcl"
set init_verilog   "../02-design-compiler-synth/outputs/post-synth.v"
set init_top_cell  "sync_fifo"
set init_lef_file  "$env(STDVIEW_45)/rtk-tech.lef  $env(STDVIEW_45)/stdcells.lef"
set init_gnd_net   "VSS"
set init_pwr_net   "VDD"

init_design

setDesignMode -process 45

setDelayCalMode -SIAware false
setOptMode -usefulSkew false

setOptMode -holdTargetSlack 0.010
setOptMode -holdFixingCells {BUF_X1 BUF_X1 BUF_X2 BUF_X4 BUF_X8 BUF_X16 BUF_X32}

floorPlan -r 1.0 0.70 4.0 4.0 4.0 4.0

place_opt_design

addTieHiLo -cell "LOGIC1_X1 LOGIC0_X1"

assignIoPins -pin *

globalNetConnect VDD -type pgpin -pin VDD -all -verbose
globalNetConnect VSS -type pgpin -pin VSS -all -verbose
globalNetConnect VDD -type tiehi -pin VDD -all -verbose
globalNetConnect VSS -type tielo -pin VSS -all -verbose

sroute -nets {VDD VSS}

addRing \
  -nets {VDD VSS} -width 0.8 -spacing 0.8 \
  -layer [list top 9 bottom 9 left 8 right 8]

addStripe \
  -nets {VSS VDD} -layer 9 -direction horizontal \
  -width 0.8 -spacing 4.8 \
  -set_to_set_distance 11.2 -start_offset 2.4

addStripe \
  -nets {VSS VDD} -layer 8 -direction vertical \
  -width 0.8 -spacing 4.8 \
  -set_to_set_distance 11.2 -start_offset 2.4

create_ccopt_clock_tree_spec
set_ccopt_property update_io_latency false
clock_opt_design

optDesign -postCTS -setup
optDesign -postCTS -hold

routeDesign

optDesign -postRoute -setup
optDesign -postRoute -hold

extractRC

setFillerMode -core {FILLCELL_X4 FILLCELL_X2 FILLCELL_X1}
addFiller

verifyConnectivity
verify_drc

saveDesign post-pnr.enc

file mkdir outputs
rcOut -rc_corner typical -spef outputs/post-pnr.spef
write_sdf outputs/post-pnr.sdf
saveNetlist outputs/post-pnr.v

streamOut outputs/post-pnr.gds \
  -merge "$env(STDVIEW_45)/stdcells.gds" \
  -mapFile "$env(STDVIEW_45)/rtk-stream-out.map"

file mkdir reports

report_timing -late -max_paths 999 > reports/setup.rpt
report_timing -late -max_slack 0 > reports/setup_negs.rpt
report_timing -early -max_paths 999 > reports/hold.rpt
report_timing -early -max_slack 0 > reports/hold_negs.rpt
report_area -verbose > reports/area.rpt
report_power -hierarchy all > reports/power.rpt

exit
