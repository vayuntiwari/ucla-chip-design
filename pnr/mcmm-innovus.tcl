create_rc_corner -name typical \
   -cap_table "$env(STDVIEW_45)/rtk-typical.captable" \
   -T 25

create_library_set -name libs_typical \
   -timing [list "$env(STDVIEW_45)/stdcells.lib"]

## TODO: link library and RC to create a corner ##

create_delay_corner -name delay_default \
   -library_set libs_typical \
   -rc_corner typical

## TODO: load sdc to create a mode ##

create_constraint_mode -name constraints_default \
   -sdc_files [list ../02-design-compiler-synth/outputs/post-synth.sdc]

## TODO: link mode and corner to create an analysis view ##

create_analysis_view -name analysis_default \
   -constraint_mode constraints_default \
   -delay_corner delay_default

## TODO: set setup and hold analyses ##

set_analysis_view -setup analysis_default -hold analysis_default
