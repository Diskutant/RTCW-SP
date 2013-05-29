cmake_minimum_required(VERSION 2.8)

# Get all C source files
file(GLOB C_SOURCES RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} "*.c")

# Sort the C sources into a neat list
list(SORT C_SOURCES)

add_definitions(-DSCREWUP)

if(NOT WIN32)
	# Set the compiler to use
	set_source_files_properties(${C_SOURCES} PROPERTIES LANGUAGE C COMPILE_FLAGS "${CXXFLAGS} -g")
else(NOT WIN32)
	set_source_files_properties(${C_SOURCES} PROPERTIES LANGUAGE C COMPILE_FLAGS "${CXXFLAGS}")
endif(NOT WIN32)

# Compile our program
add_executable(extractfuncs ${C_SOURCES})
set_target_properties(extractfuncs PROPERTIES LINKER_LANGUAGE C PREFIX "" SUFFIX "")

if(NOT WIN32)
	target_link_libraries(extractfuncs m)
endif(NOT WIN32)