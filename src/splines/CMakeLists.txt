cmake_minimum_required(VERSION 2.8)

# Get all C source files
file(GLOB CXX_SOURCES RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} "*.cpp")

# Sort the C sources into a neat list
list(SORT CXX_SOURCES)

if(NOT WIN32)
	# Set the compiler to use
	set_source_files_properties(${C_SOURCES} PROPERTIES LANGUAGE C COMPILE_FLAGS "${CXXFLAGS} -g")
else(NOT WIN32)
	set_source_files_properties(${C_SOURCES} PROPERTIES LANGUAGE C COMPILE_FLAGS "${CXXFLAGS}")
endif(NOT WIN32)

# Add to our library.
add_library(splines${CMAKE_STATIC_LIBRARY_SUFFIX} STATIC ${CXX_SOURCES})
set_target_properties(splines${CMAKE_STATIC_LIBRARY_SUFFIX} PROPERTIES LINKER_LANGUAGE CXX PREFIX "" SUFFIX "")
