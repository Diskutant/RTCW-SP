cmake_minimum_required(VERSION 2.8)

# Get all C source files
file(GLOB C_SOURCES RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} "*.c")

# Additional source files -- ### Find a better way of doing this.
list(APPEND C_SOURCES
	${CMAKE_SOURCE_DIR}/src/botlib/be_aas_bspq3.c
	${CMAKE_SOURCE_DIR}/src/botlib/be_aas_cluster.c
	${CMAKE_SOURCE_DIR}/src/botlib/be_aas_move.c
	${CMAKE_SOURCE_DIR}/src/botlib/be_aas_optimize.c
	${CMAKE_SOURCE_DIR}/src/botlib/be_aas_reach.c
	${CMAKE_SOURCE_DIR}/src/botlib/be_aas_sample.c
	${CMAKE_SOURCE_DIR}/src/botlib/l_libvar.c
	${CMAKE_SOURCE_DIR}/src/botlib/l_precomp.c
	${CMAKE_SOURCE_DIR}/src/botlib/l_script.c
	${CMAKE_SOURCE_DIR}/src/botlib/l_struct.c
	${CMAKE_SOURCE_DIR}/src/qcommon/cm_load.c
	${CMAKE_SOURCE_DIR}/src/qcommon/cm_patch.c
	${CMAKE_SOURCE_DIR}/src/qcommon/cm_test.c
	${CMAKE_SOURCE_DIR}/src/qcommon/cm_trace.c
	${CMAKE_SOURCE_DIR}/src/qcommon/md4.c
	${CMAKE_SOURCE_DIR}/src/qcommon/unzip.c
)

# Sort the C sources into a neat list
list(SORT C_SOURCES)

# This may need to be changed.
include_directories(${CMAKE_SOURCE_DIR}/GtkRadiant)

# Set the compiler to use
set_source_files_properties(${C_SOURCES} PROPERTIES LANGUAGE C)

# Add to our library. 
add_library(bspc MODULE ${C_SOURCES})
set_target_properties(bspc PROPERTIES LINKER_LANGUAGE C PREFIX "" SUFFIX "" COMPILE_DEFINITIONS "BSPC;GTKRADIANT")
target_link_libraries(bspc m)
