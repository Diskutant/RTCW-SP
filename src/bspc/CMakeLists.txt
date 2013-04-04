cmake_minimum_required(VERSION 2.8)

# Get all C source files
file(GLOB C_SOURCES RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} "*.c")

# Additional source files -- ### Find a better way of doing this.
list(APPEND C_SOURCES
	../botlib/be_aas_bspq3.c
	../botlib/be_aas_cluster.c
	../botlib/be_aas_move.c
	../botlib/be_aas_optimize.c
	../botlib/be_aas_reach.c
	../botlib/be_aas_sample.c
	../botlib/l_libvar.c
	../botlib/l_precomp.c
	../botlib/l_script.c
	../botlib/l_struct.c
	../qcommon/cm_load.c
	../qcommon/cm_patch.c
	../qcommon/cm_test.c
	../qcommon/cm_trace.c
	../qcommon/md4.c
	../qcommon/unzip.c
)

# Sort the C sources into a neat list
list(SORT C_SOURCES)

# These may need to be changed.
add_definitions(-DBSPC -DGTKRADIANT)
include_directories(../../../../GtkRadiant)

# Set the compiler to use
set_source_files_properties(${C_SOURCES} PROPERTIES LANGUAGE C)

# Add to our library. 
add_library(bspc MODULE ${C_SOURCES})
set_target_properties(bspc PROPERTIES LINKER_LANGUAGE C)
target_link_libraries(bspc m)
