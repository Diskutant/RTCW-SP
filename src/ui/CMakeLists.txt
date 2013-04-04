cmake_minimum_required(VERSION 2.8)

# Get all C source files
file(GLOB C_SOURCES RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} "*.c")

# Additional source files -- ### Find a better way of doing this.
list(APPEND C_SOURCES
	../game/bg_misc.c
	../game/q_math.c
	../game/q_shared.c
)

# Sort the C sources into a neat list
list(SORT C_SOURCES)

# Set the compiler to use
set_source_files_properties(${C_SOURCES} PROPERTIES LANGUAGE C COMPILE_FLAGS "-fPIC")

# use the OS suffix instead of .dll, things get confusing when that happens
# the variable name is `SO` because I am on linux
set(SO ui-rtcw${CMAKE_SHARED_LIBRARY_SUFFIX})

# Add to our library. 
add_library(${SO} MODULE ${C_SOURCES})
set_target_properties(${SO} PROPERTIES LINKER_LANGUAGE C PREFIX "" SUFFIX "")
target_link_libraries(${SO} dl m)
