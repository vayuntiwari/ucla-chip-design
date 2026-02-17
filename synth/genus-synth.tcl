set_db init_lib_search_path <full_path_of_technology_library_directory_lib>
set_db init_hdl_search_path <hdl>

set_db library <technology_library>
read_hdl <hdl_file_names>

elaborate <top_devel_design_name>

# dont uses ? scan flip flops in nangate

set clock [create_clock -period <> -name clock_name <ports>]
external_delay -input <>
external_delay -output <>

syn_generic #rtl optimization

syn_map #mapping

report_timing >
report_area >

write_hdl > post-synth.v
write_script > 

quit
